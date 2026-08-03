#!/usr/bin/env python3
"""Validate exact source coverage for all classification boundaries."""
from __future__ import annotations

import csv
import json
import os
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[2]
)).resolve()
AUDIT = ROOT / "audit"
MAP = AUDIT / "BOUNDARY-SOURCE-MAP.csv"
PAPER = ROOT / "paper" / "kourovka1034.tex"

FIELDS = [
    "claim_id", "manifest_scope", "covered_family_ids", "boundary_claim",
    "exception_ids", "primary_source", "pinpoint", "independent_source",
    "independent_pinpoint", "status",
]
EXPECTED = {
    # family IDs, exception IDs, primary source/pinpoint, and independent
    # source/pinpoint.  Exact routing is pinned so swapping two otherwise
    # complete boundary rows cannot pass merely by preserving set coverage.
    "BND-CFSG-PARAMETERS": (
        "alternating;psl2;psl_rank_ge3;psu3;psu_rank_ge4;symplectic;odd_orthogonal;plus_orthogonal;minus_orthogonal;suzuki;small_ree;triality;g2;f4;e6;twisted_e6;e7;e8;large_ree;tits;sporadic",
        "", "GLS1", "Chapter 1, Table I, pp. 8--10", "ATLAS1985",
        "Sections 2--3, pp. xi--xvi",
    ),
    "BND-PSL2": (
        "psl2", "SIMP-PSL2-2-3", "GLS3", "Theorem 2.2.7(a)",
        "ATLAS1985", "Section 3.5, p. xv",
    ),
    "BND-PSU3": (
        "psu3", "SIMP-PSU3-2", "GLS3", "Theorem 2.2.7(a)",
        "ATLAS1985", "Section 3.5, p. xv",
    ),
    "BND-PSU4-2": (
        "psu_rank_ge4", "ISO-PSU4-2", "CameronClassicalGroups",
        "Theorem 5.3, p. 61", "ATLASWeb",
        "U4(2) page: natural characteristic-3 representation as Sp4(3)",
    ),
    "BND-SP4": (
        "symplectic", "SIMP-SP4-2", "ATLAS1985",
        "Section 2.4, p. xii; A6 entry, pp. 4--5", "GLS3",
        "Theorem 2.2.7(a)",
    ),
    "BND-G2": (
        "g2", "SIMP-G2-2", "ATLAS1985",
        "Section 3.5, p. xv; U3(3) entry, pp. 14--15", "GLS3",
        "Theorem 2.2.7(a)",
    ),
    "BND-REE3": (
        "small_ree", "SIMP-REE3", "ATLAS1985",
        "Section 3.5, p. xv; PSL(2,8) entry, p. 6", "GLS3",
        "Theorem 2.2.7(a)",
    ),
    "BND-TITS": (
        "large_ree;tits", "SIMP-2F4-2", "ATLAS1985",
        "Section 3.5, p. xv; Tits entry, pp. 74--75", "GLS3",
        "Theorem 2.2.7(a)",
    ),
    "BND-BC-EVEN": (
        "odd_orthogonal;symplectic", "ISO-BC-EVEN", "ATLAS1985",
        "Section 2.4, pp. xi--xii; Section 3.1, p. xiv", "GLS1",
        "Chapter 1, Table I, pp. 8--10",
    ),
    "BND-2D-LOW": (
        "minus_orthogonal", "ISO-2D-LOWRANK", "ATLAS1985",
        "Section 2.4, p. xii; Section 3.2, p. xiv", "GLS1",
        "Chapter 1, Table I, pp. 8--10",
    ),
    "BND-PSL3-2": (
        "psl_rank_ge3", "", "ATLAS1985",
        "Section 3.5, p. xv; PSL(3,2) entry, p. 3", "GLS1",
        "Chapter 1, Table I, pp. 8--10",
    ),
    "BND-SUZUKI-2": (
        "suzuki", "", "GLS3", "Theorem 2.2.7(a)", "ATLAS1985",
        "Section 3.5, p. xv",
    ),
}


def die(message: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + message)


def main() -> int:
    with MAP.open(newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            die(f"boundary source-map columns drift: {reader.fieldnames!r}")
        rows = list(reader)
    ids = [row["claim_id"] for row in rows]
    if set(ids) != set(EXPECTED) or len(ids) != len(set(ids)):
        die(f"boundary source-map IDs mismatch: {sorted(ids)!r}")

    classification = json.loads((AUDIT / "CLASSIFICATION-MANIFEST.json").read_text())
    family_ids = {item["id"] for item in classification["families"]}
    exception_manifest = json.loads((AUDIT / "EXCEPTION-MANIFEST.json").read_text())
    exception_records = {item["id"]: item for item in exception_manifest["exceptions"]}
    boundary_exception_ids = {
        item["id"] for item in exception_manifest["exceptions"]
        if ("simplicity" in item["kind"] or "isomorphism" in item["kind"]
            or item["kind"] == "low-rank identification")
    }

    covered_families: set[str] = set()
    routed: list[str] = []
    for row in rows:
        cid = row["claim_id"]
        if row["status"] != "CITED-PASS":
            die(f"{cid}: non-passing status {row['status']!r}")
        if any(not row[field].strip() for field in (
            "manifest_scope", "covered_family_ids", "boundary_claim",
            "primary_source", "pinpoint", "independent_source",
            "independent_pinpoint",
        )):
            die(f"{cid}: empty required source field")
        routed_record = tuple(row[field] for field in (
            "covered_family_ids", "exception_ids", "primary_source", "pinpoint",
            "independent_source", "independent_pinpoint",
        ))
        if routed_record != EXPECTED[cid]:
            die(f"{cid}: family/exception/source routing drift")
        for family_id in row["covered_family_ids"].split(";"):
            if family_id not in family_ids:
                die(f"{cid}: unknown family ID {family_id}")
            covered_families.add(family_id)
        for exception_id in filter(None, row["exception_ids"].split(";")):
            if exception_id not in exception_records:
                die(f"{cid}: unknown exception ID {exception_id}")
            routed.append(exception_id)

    if covered_families != family_ids:
        die(
            "boundary map does not cover every classification parameter row: "
            f"missing={sorted(family_ids-covered_families)!r}"
        )
    if len(routed) != len(set(routed)) or set(routed) != boundary_exception_ids:
        die(
            "boundary exceptions are not routed exactly once: "
            f"mapped={sorted(routed)!r}, expected={sorted(boundary_exception_ids)!r}"
        )
    psl = next(item for item in classification["families"] if item["id"] == "psl_rank_ge3")
    if "(n,q)=(3,2)" not in psl["parameters"] or "not from simplicity" not in psl["parameters"]:
        die("PSL(3,2) classification-boundary note drift")

    # The PSU(4,2) Zsigmondy exception is computed under the isomorphic
    # Sp(4,3)=O(5,3) alias.  Bind the published isomorphism row to both the
    # independently maintained canonical inventory and the exact finite SOCLE
    # record, rather than accepting a prose-only claim that it is "in the base".
    inventory = (ROOT / "computations/data/simple_groups_below_500000.txt").read_text()
    if inventory.splitlines().count("25920 O(5,3)") != 1:
        die("PSU(4,2)/Sp(4,3) canonical finite-inventory alias is missing")
    finite_log = (ROOT / "computations/certificates/sweepJ_divisibility.log").read_text()
    for token in (
        "SOCLE|group=Sp43|order=25920|",
        "|out=2|faithful=true|simple=true",
        "==> Sp43^k EXCLUDED FOR ALL k >= 2 AND ALL X.",
    ):
        if token not in finite_log:
            die(f"PSU(4,2)/Sp(4,3) finite-certificate anchor missing: {token!r}")

    tex = PAPER.read_text()
    required_tex = {
        r"\cite[Ch.~1, Table~I, pp.~8--10]{GLS1}",
        r"\cite[Thm.~2.2.7(a)]{GLS3}",
        r"\cite[\S2.4, pp.~xi--xii, and \S3.5, p.~xv]{ATLAS}",
        r"\cite[Thm.~5.3, p.~61]{CameronNotes}",
        r"$G_2(2)$ and ${}^2G_2(3)$ are not simple",
        r"${}^2D_2$, ${}^2D_3$ are",
    }
    missing = sorted(token for token in required_tex if token not in tex)
    if missing:
        die(f"manuscript missing boundary citations/assertions: {missing!r}")

    print(f"classification-boundary source rows: {len(rows)}")
    print(f"classification families source-covered: {len(covered_families)}")
    print(f"boundary exceptions routed exactly once: {len(routed)}")
    print("PSU(4,2)=PSp(4,3) finite-certificate alias: PASS")
    print("BOUNDARY SOURCE TOPOLOGY VERIFICATION|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, json.JSONDecodeError, KeyError) as exc:
        die(str(exc))
