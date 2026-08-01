#!/usr/bin/env python3
"""Verify that every high-risk universal-claim word in the manuscript is inventoried."""
from __future__ import annotations

import argparse
import csv
import hashlib
import os
import re
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[1]
)).resolve()
TEX_PATH = ROOT / "paper/kourovka1034.tex"
MANIFEST = ROOT / "audit/UNIVERSAL-CLAIMS.csv"
TOKENS = (
    "all", "every", "exactly", "unique", "automatic", "stable", "maximal",
    "complete", "exhaustive", "independently", "certified",
)
TOKEN_RE = re.compile(
    r"\b(?:" + "|".join(re.escape(x) for x in TOKENS) + r")\w*\b",
    re.IGNORECASE,
)
COLS = [
    "occurrence_id", "token", "tex_line", "context_sha256", "context",
    "classification", "obligation_ids", "audit_note",
]
CLASSES = {
    "MATHEMATICAL-CLAIM", "DEFINITION", "METHODOLOGY-CLAIM",
    "METADATA-OR-DISCLOSURE", "BIBLIOGRAPHIC-TEXT",
}
CLOSED_OR_OPEN = {
    "FORMAL-PASS", "CITED-PASS", "COMPUTED-PASS", "REDUNDANT", "UNRESOLVED",
}


def die(message: str) -> None:
    raise SystemExit("HARD-FAIL: universal-claim audit: " + message)


def strip_comment(line: str) -> str:
    """Remove an unescaped TeX comment."""
    for i, ch in enumerate(line):
        if ch == "%" and (i == 0 or line[i - 1] != "\\"):
            return line[:i]
    return line


def extract() -> list[dict[str, str]]:
    out: list[dict[str, str]] = []
    for line_no, raw in enumerate(TEX_PATH.read_text().splitlines(), 1):
        context = strip_comment(raw).strip()
        if not context:
            continue
        context_hash = hashlib.sha256(context.encode()).hexdigest()
        for ordinal, match in enumerate(TOKEN_RE.finditer(context), 1):
            token = match.group(0)
            # Include the source line so repeated TeX lines still receive
            # distinct identifiers.  Any manuscript edit intentionally makes
            # the frozen audit manifest stale until it is reviewed again.
            seed = f"{line_no}|{context_hash}|{token.lower()}|{ordinal}"
            occurrence_id = "UC-" + hashlib.sha256(seed.encode()).hexdigest()[:16]
            out.append({
                "occurrence_id": occurrence_id,
                "token": token,
                "tex_line": str(line_no),
                "context_sha256": context_hash,
                "context": context,
            })
    return out


def validate() -> dict[str, int]:
    with (ROOT / "audit/OBLIGATIONS.csv").open(newline="") as f:
        obligations = {row["claim_id"]: row for row in csv.DictReader(f)}
    if not MANIFEST.is_file():
        die("UNIVERSAL-CLAIMS.csv is missing")
    with MANIFEST.open(newline="") as f:
        rd = csv.DictReader(f)
        if rd.fieldnames != COLS:
            die(f"column drift: {rd.fieldnames!r}")
        rows = list(rd)

    actual = extract()
    if len(rows) != len(actual):
        die(f"occurrence count drift: manifest={len(rows)} manuscript={len(actual)}")
    seen: set[str] = set()
    for index, (record, current) in enumerate(zip(rows, actual), 1):
        oid = record["occurrence_id"]
        if oid in seen:
            die(f"duplicate occurrence_id {oid}")
        seen.add(oid)
        for key in ("occurrence_id", "token", "tex_line", "context_sha256", "context"):
            if record[key] != current[key]:
                die(
                    f"row {index} drift in {key}: stored={record[key]!r} "
                    f"current={current[key]!r}"
                )
        if record["classification"] not in CLASSES:
            die(f"{oid}: invalid classification {record['classification']!r}")
        mapped = record["obligation_ids"].split(";") if record["obligation_ids"] else []
        if not mapped or len(mapped) != len(set(mapped)):
            die(f"{oid}: obligation mapping is empty or duplicated")
        unknown = set(mapped) - set(obligations)
        if unknown:
            die(f"{oid}: unknown obligations {sorted(unknown)}")
        if any(obligations[x]["status"] not in CLOSED_OR_OPEN for x in mapped):
            die(f"{oid}: mapped obligation has forbidden status")
        if len(record["audit_note"].strip()) < 20:
            die(f"{oid}: audit note is missing or too short")

    mathematical = sum(r["classification"] == "MATHEMATICAL-CLAIM" for r in rows)
    methodology = sum(r["classification"] == "METHODOLOGY-CLAIM" for r in rows)
    return {"occurrences": len(rows), "mathematical": mathematical, "methodology": methodology}


def write_review_template(destination: Path) -> tuple[int, int]:
    """Write a non-authoritative review file, preserving unchanged decisions."""
    if destination.resolve() == MANIFEST.resolve():
        die("refusing to overwrite the authoritative manifest with a template")
    previous: list[dict[str, str]] = []
    if MANIFEST.is_file():
        with MANIFEST.open(newline="") as f:
            rd = csv.DictReader(f)
            if rd.fieldnames == COLS:
                previous = list(rd)

    # Context hashes remain stable when unrelated lines move.  Pair repeated
    # occurrences in encounter order within each (context, normalized token).
    pools: dict[tuple[str, str], list[dict[str, str]]] = {}
    for row in previous:
        pools.setdefault(
            (row["context_sha256"], row["token"].lower()), []
        ).append(row)
    used: dict[tuple[str, str], int] = {}
    rows = []
    preserved = 0
    for current in extract():
        key = (current["context_sha256"], current["token"].lower())
        index = used.get(key, 0)
        used[key] = index + 1
        old = pools.get(key, [])
        if index < len(old):
            decision = {
                k: old[index][k]
                for k in ("classification", "obligation_ids", "audit_note")
            }
            preserved += 1
        else:
            decision = {
                "classification": "",
                "obligation_ids": "",
                "audit_note": "REVIEW REQUIRED: classify and map this new occurrence.",
            }
        rows.append({**current, **decision})
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=COLS, lineterminator="\n")
        wr.writeheader()
        wr.writerows(rows)
    return len(rows), preserved


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument("--extract-template", type=Path)
        args = parser.parse_args()
        if args.extract_template is not None:
            total, preserved = write_review_template(args.extract_template)
            print(
                "UNIVERSAL CLAIM TEMPLATE|WROTE|"
                f"rows={total}|preserved={preserved}|review={total-preserved}"
            )
            sys.exit(0)
        counts = validate()
        print(
            "UNIVERSAL CLAIM AUDIT|PASS|"
            f"occurrences={counts['occurrences']}|"
            f"mathematical={counts['mathematical']}|"
            f"methodology={counts['methodology']}"
        )
    except (OSError, UnicodeError, csv.Error) as exc:
        die(str(exc))
