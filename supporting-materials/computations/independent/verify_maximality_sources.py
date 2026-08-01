#!/usr/bin/env python3
"""Fail-closed topology check for the family maximality source map.

This checker validates exact row coverage, citation pinpoints, exception routing,
and manuscript/source-map agreement.  It deliberately does not treat a CSV row
as a proof of the theorem it cites: the published source remains an explicit
external mathematical assumption.
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
MAP = AUDIT / "MAXIMALITY-SOURCE-MAP.csv"
EXCEPTIONS = AUDIT / "EXCEPTION-MANIFEST.json"
PAPER = ROOT / "paper" / "kourovka1034.tex"

FIELDS = [
    "claim_id", "manuscript_location", "families", "subgroup_classes",
    "parameter_range", "primary_source", "pinpoint",
    "independent_corroboration", "exception_ids", "status",
]
REQUIRED = {
    "MAX-PARABOLIC", "MAX-RANK1-BOREL", "MAX-PSL2", "MAX-AN",
    "MAX-PSU3", "MAX-SZ", "MAX-REE", "MAX-PSL3", "MAX-SP4", "MAX-G2",
}
EXPECTED_SOURCES = {
    "MAX-PARABOLIC": ("Carter1972", "Theorems 8.3.2--8.3.3, p. 112"),
    "MAX-RANK1-BOREL": ("Hiss2011", "Example 1.16 and Section 1.3.5, pp. 10--11"),
    "MAX-PSL2": ("BHRD", "Tables 8.1--8.2, p. 376; Table 8.7, p. 380"),
    "MAX-AN": ("LPS1987", "Theorem 1 and Tables I--II, pp. 366--368"),
    "MAX-PSU3": ("BHRD", "Table 8.5, p. 379"),
    "MAX-SZ": ("BHRD", "Theorem 7.3.5, p. 367; Table 8.16, p. 384"),
    "MAX-REE": ("Kleidman1988", "Theorem C, pp. 33--34"),
    "MAX-PSL3": ("BHRD", "Table 8.3, p. 378"),
    "MAX-SP4": ("BHRD", "Table 8.14, p. 384"),
    "MAX-G2": ("Kleidman1988", "Theorem A, p. 33"),
}
REQUIRED_TEX = {
    r"\cite[Tables~8.1--8.2, p.~376, and Table~8.7, p.~380]{BHRD}",
    r"\cite[Thm.~1 and Tables~I--II, pp.~366--368]{LPS1987}",
    r"\cite[Table~8.5, p.~379]{BHRD}",
    r"\cite[Thm.~7.3.5, p.~367, and Table~8.16, p.~384]{BHRD}",
    r"\cite[Thm.~C, pp.~33--34]{Kleidman1988}",
    r"\cite[Table~8.3, p.~378]{BHRD}",
    r"\cite[Table~8.14, p.~384]{BHRD}",
    r"\cite[Thm.~A, p.~33]{Kleidman1988}",
    r"DOI 10.1017/CBO9781139192576",
    r"DOI 10.1016/0021-8693(88)90239-6",
    r"DOI 10.1016/0021-8693(87)90223-7",
    r"DOI 10.2307/1970423",
}


def die(msg: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + msg)


def main() -> int:
    with MAP.open(newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            die(f"maximality source-map columns drift: {reader.fieldnames!r}")
        rows = list(reader)

    ids = [row["claim_id"] for row in rows]
    if set(ids) != REQUIRED or len(ids) != len(set(ids)):
        die(f"maximality source-map IDs mismatch: {sorted(ids)!r}")

    manifest = json.loads(EXCEPTIONS.read_text())
    exception_ids = {item["id"] for item in manifest["exceptions"]}
    routed: set[str] = set()
    for row in rows:
        if row["status"] != "CITED-PASS":
            die(f"{row['claim_id']}: non-passing status {row['status']!r}")
        required_nonempty = [field for field in FIELDS[:-2]]
        if any(not row[field].strip() for field in required_nonempty):
            die(f"{row['claim_id']}: empty required source-map field")
        actual_source = (row["primary_source"], row["pinpoint"])
        if actual_source != EXPECTED_SOURCES[row["claim_id"]]:
            die(f"{row['claim_id']}: source/pinpoint drift: {actual_source!r}")
        for exc_id in filter(None, (x.strip() for x in row["exception_ids"].split(";"))):
            if exc_id not in exception_ids:
                die(f"{row['claim_id']}: unknown exception ID {exc_id}")
            routed.add(exc_id)

    expected_routed = {
        "SIMP-PSU3-2", "SIMP-REE3", "MAX-PSL2-LE11", "MAX-AN-LE14",
        "MAX-PSU3-SMALL", "MAX-PSL3-LE4", "SIMP-SP4-2",
    }
    if routed != expected_routed:
        die(f"maximality exception topology mismatch: {sorted(routed)!r}")

    tex = PAPER.read_text()
    missing = sorted(token for token in REQUIRED_TEX if token not in tex)
    if missing:
        die(f"manuscript missing pinned maximality citations: {missing!r}")

    print(f"exact maximality source rows: {len(rows)}")
    print("routed maximality/simplicity exceptions: " + ",".join(sorted(routed)))
    for row in rows:
        print(
            "SOURCE|claim={}|source={}|pinpoint={}|status=PASS".format(
                row["claim_id"], row["primary_source"], row["pinpoint"]
            )
        )
    print("MAXIMALITY SOURCE TOPOLOGY VERIFICATION|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, json.JSONDecodeError, KeyError) as exc:
        die(str(exc))
