#!/usr/bin/env python3
"""Fail-closed source audit for every family order-formula branch.

The arithmetic checkers deliberately treat published group, outer-group,
parabolic, and Levi order formulas as inputs.  This checker binds those inputs
to exact published locations, requires a unique manuscript anchor for each
row, and checks that every non-finite CFSG family route is covered.  It does
not re-prove the cited classification results.
"""
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
MAP = AUDIT / "ORDER-FORMULA-SOURCE-MAP.csv"
PAPER = ROOT / "paper" / "kourovka1034.tex"

FIELDS = [
    "claim_id", "manuscript_location", "families", "covered_family_ids",
    "parameter_range", "formula_obligation", "manuscript_token",
    "primary_source", "pinpoint", "independent_corroboration", "status",
]

EXPECTED = {
    # covered_family_ids, parameter_range, primary_source, pinpoint,
    # independent_corroboration.  Keeping the mathematical routing here,
    # independently of the CSV, prevents a complete-but-wrong reassignment of
    # a formula row from passing the set-coverage test below.
    "ORD-ALT": (
        "alternating", "n>=15", "LPS1987",
        "Theorem 1 and Tables I--II, pp. 366--368",
        "The displayed subgroup definitions give the orders directly; |A_n|=n!/2",
    ),
    "ORD-ALT-PRIME-INTERVAL": (
        "alternating", "n>=31", "Nagura1952",
        "Theorem, pp. 180--181",
        "Official J-STAGE PDF DOI 10.3792/pja/1195570997; finite n=15..30 endpoint list independently recomputed",
    ),
    "ORD-PSL2-GROUP-OUTER": (
        "psl2", "q=p^f>=4", "ATLAS1985",
        "Section 2.1, p. x; Table 5, p. xvi",
        "Carter1965, Section 10, pp. 220--221, and summary table, p. 239",
    ),
    "ORD-PSL2-SUBGROUPS": (
        "psl2", "odd q>=13; even q>=8", "BHRD2013",
        "Tables 8.1--8.2, p. 376; Table 8.7, p. 380",
        "Dickson1901 and Huppert1967, II.8.27",
    ),
    "ORD-CLASSICAL-GROUPS": (
        "psl_rank_ge3;psu3;psu_rank_ge4;symplectic;odd_orthogonal;plus_orthogonal;minus_orthogonal",
        "all simple parameters used in the named theorem branches", "ATLAS1985",
        "Sections 2.1--2.4, pp. x--xii",
        "Carter1965, Section 10, pp. 220--221, and summary table, p. 239",
    ),
    "ORD-EXCEPTIONAL-GROUPS": (
        "suzuki;small_ree;triality;g2;f4;e6;twisted_e6;e7;e8;large_ree",
        "all simple parameters used in the named theorem branches", "ATLAS1985",
        "Table 6, p. xvi", "Carter1965, summary table, p. 239",
    ),
    "ORD-LIE-OUTER": (
        "psl2;psl_rank_ge3;psu3;psu_rank_ge4;symplectic;odd_orthogonal;plus_orthogonal;minus_orthogonal;suzuki;small_ree;triality;g2;f4;e6;twisted_e6;e7;e8;large_ree",
        "all simple parameters used in the named theorem branches", "ATLAS1985",
        "Table 5, p. xvi",
        "Broto--Moller--Oliver 2019, Definition 3.3 and Theorem 3.4, p. 32",
    ),
    "ORD-PARABOLIC-LEVI-GENERAL": (
        "psl_rank_ge3;psu3;psu_rank_ge4;symplectic;odd_orthogonal;plus_orthogonal;minus_orthogonal;suzuki;small_ree;triality;g2;f4;e6;twisted_e6;e7;e8;large_ree",
        "rank at least two, including twisted node-orbits", "ATLAS1985",
        "Section 3.6, p. xv", "Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-NOGRAPH-LEVIS": (
        "symplectic;odd_orthogonal;g2;f4;e7;e8", "ranges in manuscript label thm:nograph",
        "Carter1972", "Section 8.5, pp. 118--120",
        "ATLAS1985, Table 3, p. xiv; Tables 6--7, p. xvi",
    ),
    "ORD-PSU-LEVIS": (
        "psu_rank_ge4", "n>=4", "ATLAS1985",
        "Section 2.2, p. x; Table 4 and Section 3.6, p. xv; Table 6, p. xvi",
        "Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-2D-LEVIS": (
        "minus_orthogonal", "n>=4", "ATLAS1985",
        "Section 2.4, p. xii; Table 4 and Section 3.6, p. xv; Table 6, p. xvi",
        "Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-3D4-LEVIS": (
        "triality", "all q", "ATLAS1985",
        "Table 4 and Section 3.6, p. xv; Table 6, p. xvi",
        "Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-2E6-LEVIS": (
        "twisted_e6", "all q", "Montinaro2024",
        "Lemma 6.8 proof, journal p. 82",
        "Independent E6 graph-orbit derivation in verify_lie_sources.py",
    ),
    "ORD-2F4-LEVIS": (
        "large_ree", "q=2^f with odd f>=3", "Wilson2009",
        "Theorem 4.5(i)--(ii), p. 166", "Malle1991, Main Theorem, pp. 52--53",
    ),
    "ORD-PSU3-SUBGROUPS": (
        "psu3", "q>=8", "BHRD2013", "Table 8.5, p. 379",
        "ATLAS1985, Section 2.2, p. x; Table 6, p. xvi",
    ),
    "ORD-SUZUKI-SUBGROUPS": (
        "suzuki", "q=2^f with odd f>=3", "BHRD2013",
        "Theorem 7.3.5, p. 367; Table 8.16, p. 384",
        "Suzuki1962; ATLAS1985, Table 6, p. xvi",
    ),
    "ORD-REE-SUBGROUPS": (
        "small_ree", "q=3^f with odd f>=3", "Kleidman1988",
        "Theorem C, pp. 33--34", "ATLAS1985, Table 6, p. xvi",
    ),
    "ORD-PSL-GRAPH-SUBGROUPS": (
        "psl_rank_ge3", "n>=3", "BHRD2013", "Table 8.3, p. 378",
        "ATLAS1985, Section 2.1, p. x; Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-D4-SMALL": (
        "plus_orthogonal", "q=2", "ATLAS1985",
        "Section 2.4, pp. xi--xii; Table 6, p. xvi",
        "Carter1972, Section 8.5, pp. 118--120",
    ),
    "ORD-E6-LEVIS": (
        "e6", "all q", "Carter1972", "Section 8.5, pp. 118--120",
        "ATLAS1985, Table 3, p. xiv; Table 6, p. xvi",
    ),
    "ORD-SP4-FIXED": (
        "symplectic", "f>=2", "BHRD2013", "Table 8.14, p. 384",
        "ATLAS1985, Section 2.3, p. xi; Table 6, p. xvi",
    ),
    "ORD-F4-GRAPH-LEVIS": (
        "f4", "f>=1", "Carter1972", "Section 8.5, pp. 118--120",
        "ATLAS1985, Table 3, p. xiv; Table 6, p. xvi",
    ),
    "ORD-G2-FIXED": (
        "g2", "f>=1", "Kleidman1988", "Theorem A, p. 33",
        "ATLAS1985, Table 6, p. xvi",
    ),
}

REQUIRED_TEX = {
    r"\cite[Tables~5--6, p.~xvi]{ATLAS}",
    r"\cite[\S\S2.1--2.4, pp.~x--xii]{ATLAS}",
    r"\cite[\S10, pp.~220--221, and summary table, p.~239]{Carter1965}",
    r"\cite[\S3.6, p.~xv]{ATLAS}",
    r"\cite[\S8.5, pp.~118--120]{Carter}",
    r"\cite[Theorem, pp.~180--181]{Nagura}",
    r"\cite[Thm.~4.5(i)--(ii), p.~166]{Wilson2009}",
    r"DOI 10.1112/jlms/s1-40.1.193",
    r"DOI 10.1007/978-1-84800-988-2",
    r"DOI 10.1016/0021-8693(91)90283-E",
    r"DOI 10.3792/pja/1195570997",
}


def die(message: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + message)


def normalized(value: str) -> str:
    return " ".join(value.split())


def main() -> int:
    with MAP.open(newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            die(f"order-formula source-map columns drift: {reader.fieldnames!r}")
        rows = list(reader)

    ids = [row["claim_id"] for row in rows]
    if set(ids) != set(EXPECTED) or len(ids) != len(set(ids)):
        die(f"order-formula source-map IDs mismatch: {sorted(ids)!r}")

    classification = json.loads((AUDIT / "CLASSIFICATION-MANIFEST.json").read_text())
    all_families = {item["id"] for item in classification["families"]}
    # Sporadics and the Tits group are finite table/certificate routes, not
    # uniform family formula branches labeled thm:an, thm:psl2, thm:nograph,
    # thm:twisted2, thm:twisted1, and thm:graph.
    expected_families = all_families - {"sporadic", "tits"}

    paper_raw = PAPER.read_text()
    paper = normalized(paper_raw)
    covered: set[str] = set()
    for row in rows:
        cid = row["claim_id"]
        if row["status"] != "CITED-PASS":
            die(f"{cid}: non-passing status {row['status']!r}")
        for field in FIELDS[1:-1]:
            if not row[field].strip():
                die(f"{cid}: empty required field {field}")
        routed_record = (
            row["covered_family_ids"], row["parameter_range"],
            row["primary_source"], row["pinpoint"],
            row["independent_corroboration"],
        )
        if routed_record != EXPECTED[cid]:
            die(f"{cid}: family/range/source/corroboration drift")
        token = normalized(row["manuscript_token"])
        count = paper.count(token)
        if count != 1:
            die(f"{cid}: manuscript anchor count is {count}, expected 1")
        for family_id in row["covered_family_ids"].split(";"):
            if family_id not in all_families:
                die(f"{cid}: unknown classification family {family_id!r}")
            covered.add(family_id)

    if covered != expected_families:
        die(
            "formula map does not cover every non-finite family route: "
            f"missing={sorted(expected_families-covered)!r}, "
            f"extra={sorted(covered-expected_families)!r}"
        )

    missing_tex = sorted(token for token in REQUIRED_TEX if token not in paper_raw)
    if missing_tex:
        die(f"manuscript missing exact formula citations: {missing_tex!r}")

    # The source audit and the independent symbolic arithmetic audit must be
    # separate programs.  The latter must continue to state the source trust
    # boundary rather than silently presenting its encoded formulas as proof.
    symbolic = (ROOT / "computations" / "independent" /
                "family_arithmetic_symbolic.py").read_text()
    for token in (
        "Published order formulas and Zsigmondy's theorem remain external assumptions",
        "CASES =", "DIRECT_SPECS =", "def substitute_valuations()",
        "does **not** read FAMILY-ARITHMETIC-MANIFEST.json",
    ):
        if token not in symbolic:
            die(f"symbolic/source independence boundary lost: {token!r}")

    print(f"exact order-formula source rows: {len(rows)}")
    print(f"non-finite classification families source-covered: {len(covered)}")
    print("published formula/source boundary: explicit")
    print("ORDER-FORMULA SOURCE TOPOLOGY VERIFICATION|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, json.JSONDecodeError, KeyError) as exc:
        die(str(exc))
