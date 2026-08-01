#!/usr/bin/env python3
"""Fail-closed validator for the main-theorem dependency DAG."""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[1]
)).resolve()
AUDIT = ROOT / "audit"
CLOSED = {"FORMAL-PASS", "CITED-PASS", "COMPUTED-PASS", "REDUNDANT"}
EVIDENCE = {"FORMAL", "CITED", "COMPUTED", "REDUNDANT"}
NODE_FIELDS = {
    "id", "manuscript_ref", "statement", "hypotheses", "dependencies",
    "evidence_class", "obligation_id", "source_or_certificate", "essential",
    "status",
}


def die(message: str) -> None:
    raise SystemExit("HARD-FAIL: dependency DAG: " + message)


def _local_evidence_path(record: str) -> str | None:
    """Return the local file portion of a source record, if it names one."""
    head = record.split(",", 1)[0].split("#", 1)[0].strip()
    if not head or "://" in head:
        return None
    if head.startswith(("paper/", "audit/", "formal/", "computations/")):
        return head
    return None


def validate() -> dict[str, int]:
    with (AUDIT / "OBLIGATIONS.csv").open(newline="") as f:
        ledger_rows = list(csv.DictReader(f))
    ledger = {row["claim_id"]: row for row in ledger_rows}
    if len(ledger) != len(ledger_rows):
        die("duplicate obligation id")

    obj = json.loads((AUDIT / "DEPENDENCY-DAG.json").read_text())
    if set(obj) != {
        "schema_version", "root", "allowed_evidence_classes",
        "logical_obligation_ids", "nodes",
    }:
        die("top-level schema drift")
    if obj["schema_version"] != 2:
        die("schema_version must be 2")
    if set(obj["allowed_evidence_classes"]) != EVIDENCE:
        die("allowed evidence classes drift")
    if not isinstance(obj["nodes"], list) or not obj["nodes"]:
        die("nodes must be a nonempty list")

    ids: list[str] = []
    backed: list[str] = []
    by_id: dict[str, dict] = {}
    for node in obj["nodes"]:
        if not isinstance(node, dict) or set(node) != NODE_FIELDS:
            die(f"node schema drift: {node.get('id', '<unknown>')!r}")
        nid = node["id"]
        if not isinstance(nid, str) or not re.fullmatch(r"[A-Z0-9-]+", nid):
            die(f"invalid node id {nid!r}")
        if nid in by_id:
            die(f"duplicate node {nid}")
        ids.append(nid)
        by_id[nid] = node

        for key in ("manuscript_ref", "statement"):
            if not isinstance(node[key], str) or not node[key].strip():
                die(f"{nid}: empty {key}")
        # A proof node must point to a numbered/localized manuscript unit, not
        # merely say "the paper".
        if not re.search(
            r"(Theorem|Lemma|Proposition|Convention|Section|proof of Theorem)",
            node["manuscript_ref"],
        ):
            die(f"{nid}: manuscript_ref lacks an exact manuscript unit")
        if (not isinstance(node["hypotheses"], list)
                or not node["hypotheses"]
                or any(not isinstance(x, str) or not x.strip()
                       for x in node["hypotheses"])):
            die(f"{nid}: exact hypotheses must be a nonempty string list")
        if (not isinstance(node["dependencies"], list)
                or len(node["dependencies"]) != len(set(node["dependencies"]))
                or any(not isinstance(x, str) or not x
                       for x in node["dependencies"])):
            die(f"{nid}: dependencies must be a duplicate-free string list")
        if node["evidence_class"] not in EVIDENCE:
            die(f"{nid}: forbidden evidence class {node['evidence_class']!r}")
        if not isinstance(node["essential"], bool):
            die(f"{nid}: essential must be boolean")
        if (not isinstance(node["source_or_certificate"], list)
                or not node["source_or_certificate"]
                or any(not isinstance(x, str) or not x.strip()
                       for x in node["source_or_certificate"])):
            die(f"{nid}: source_or_certificate must be a nonempty string list")
        for evidence in node["source_or_certificate"]:
            local = _local_evidence_path(evidence)
            if local is not None and not (ROOT / local).is_file():
                die(f"{nid}: missing local evidence {local}")

        oid = node["obligation_id"]
        if oid is not None:
            if not isinstance(oid, str) or oid not in ledger:
                die(f"{nid}: unknown obligation_id {oid!r}")
            if oid in backed:
                die(f"{nid}: duplicate obligation-backed node for {oid}")
            backed.append(oid)
            claim = ledger[oid]
            if node["evidence_class"] != claim["claim_type"]:
                die(
                    f"{nid}: evidence class {node['evidence_class']} does not "
                    f"match ledger claim_type {claim['claim_type']}"
                )
            if node["status"] != claim["status"]:
                die(
                    f"{nid}: status {node['status']!r} does not match ledger "
                    f"{claim['status']!r}"
                )
        elif node["status"] not in CLOSED | {"UNRESOLVED"}:
            die(f"{nid}: invalid aggregate status {node['status']!r}")

    if obj["root"] not in by_id:
        die("root is not a node")
    if obj["logical_obligation_ids"] != backed:
        die("logical obligation inventory/order drift")
    if len(backed) != len(set(backed)):
        die("duplicate logical obligation inventory")

    for node in obj["nodes"]:
        unknown = set(node["dependencies"]) - set(ids)
        if unknown:
            die(f"{node['id']}: unknown dependencies {sorted(unknown)}")
        if node["id"] in node["dependencies"]:
            die(f"{node['id']}: self dependency")

    # Cycle check, derived aggregate statuses, and reachability from MAIN.
    visiting: set[str] = set()
    done: set[str] = set()

    def visit(nid: str) -> None:
        if nid in visiting:
            die(f"cycle through {nid}")
        if nid in done:
            return
        visiting.add(nid)
        for dep in by_id[nid]["dependencies"]:
            visit(dep)
        visiting.remove(nid)
        done.add(nid)

    visit(obj["root"])
    unreachable = sorted(
        n["id"] for n in obj["nodes"] if n["essential"] and n["id"] not in done
    )
    if unreachable:
        die(f"essential nodes unreachable from root: {unreachable}")

    memo: dict[str, str] = {}

    def expected_status(nid: str) -> str:
        if nid in memo:
            return memo[nid]
        node = by_id[nid]
        if node["obligation_id"] is not None:
            result = ledger[node["obligation_id"]]["status"]
        else:
            result = (
                node["evidence_class"] + "-PASS"
                if all(expected_status(d) in CLOSED for d in node["dependencies"])
                else "UNRESOLVED"
            )
        memo[nid] = result
        return result

    for node in obj["nodes"]:
        expected = expected_status(node["id"])
        if node["status"] != expected:
            die(
                f"{node['id']}: stored status {node['status']!r}, "
                f"derived {expected!r}"
            )

    tex = (ROOT / "paper/kourovka1034.tex").read_text()
    # Exact anchor tokens for every manuscript proof unit in the DAG.
    anchors = {
        "Theorem 1.1", "Lemma 2.2", "Proposition 2.3", "Convention 2.4",
        "Lemma 3.2", "Lemma 3.3", "Lemma 3.4", "Lemma 3.5",
        "Theorem 4.1", "Theorem 4.2", "Proposition 5.1",
        "Proposition 5.2", "Theorems 6.1--6.6", "Proposition 7.1",
    }
    referenced = {
        anchor for anchor in anchors
        if any(anchor in n["manuscript_ref"] for n in obj["nodes"])
    }
    if referenced != anchors:
        die(f"numbered manuscript anchor coverage drift: {sorted(anchors-referenced)}")
    for label in (
        "thm:main", "lem:quot", "prop:min", "conv:X", "lem:A", "lem:B",
        "lem:C", "lem:P", "thm:D", "thm:Dprime", "prop:base",
        "prop:sporadic", "thm:psl2", "thm:an", "thm:nograph",
        "thm:twisted2", "thm:twisted1", "thm:graph", "prop:coverage",
    ):
        if f"\\label{{{label}}}" not in tex:
            die(f"manuscript label disappeared: {label}")

    open_nodes = sum(n["status"] == "UNRESOLVED" for n in obj["nodes"])
    return {
        "nodes": len(obj["nodes"]),
        "obligation_nodes": len(backed),
        "open_nodes": open_nodes,
    }


def write_statuses() -> int:
    """Refresh only ledger-derived/aggregate statuses; never edit DAG content."""
    with (AUDIT / "OBLIGATIONS.csv").open(newline="") as f:
        ledger = {row["claim_id"]: row for row in csv.DictReader(f)}
    path = AUDIT / "DEPENDENCY-DAG.json"
    obj = json.loads(path.read_text())
    by_id = {node["id"]: node for node in obj["nodes"]}
    if len(by_id) != len(obj["nodes"]):
        die("cannot update statuses in a DAG with duplicate nodes")
    visiting: set[str] = set()
    memo: dict[str, str] = {}

    def derive(nid: str) -> str:
        if nid in memo:
            return memo[nid]
        if nid in visiting:
            die(f"cannot update statuses: cycle through {nid}")
        if nid not in by_id:
            die(f"cannot update statuses: unknown node {nid}")
        visiting.add(nid)
        node = by_id[nid]
        oid = node.get("obligation_id")
        if oid is not None:
            if oid not in ledger:
                die(f"cannot update statuses: unknown obligation {oid}")
            result = ledger[oid]["status"]
        else:
            result = (
                node.get("evidence_class", "FORMAL") + "-PASS"
                if all(derive(dep) in CLOSED for dep in node.get("dependencies", []))
                else "UNRESOLVED"
            )
        visiting.remove(nid)
        memo[nid] = result
        return result

    changed = 0
    for node in obj["nodes"]:
        expected = derive(node["id"])
        if node.get("status") != expected:
            node["status"] = expected
            changed += 1
    path.write_text(json.dumps(obj, indent=2) + "\n")
    return changed


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument("--write-status", action="store_true")
        args = parser.parse_args()
        if args.write_status:
            changed = write_statuses()
            print(f"DEPENDENCY DAG STATUS|WROTE|changed={changed}")
            sys.exit(0)
        counts = validate()
        print(
            "DEPENDENCY DAG|PASS|"
            f"nodes={counts['nodes']}|obligation_nodes={counts['obligation_nodes']}|"
            f"open_nodes={counts['open_nodes']}"
        )
    except (OSError, UnicodeError, json.JSONDecodeError, csv.Error) as exc:
        die(str(exc))
