#!/usr/bin/env python3
"""Recompute only the derived PASS/OPEN column of the burden matrix.

This tool intentionally cannot edit profile flags, obligation mappings, closure
conditions, or the pinned policy. Those are reviewable assurance-policy changes,
not generated output.
"""
from __future__ import annotations

import argparse
import csv
import os
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[1]
)).resolve()
LEDGER = ROOT / "audit/OBLIGATIONS.csv"
MATRIX = ROOT / "audit/BURDEN-OF-PROOF-MATRIX.csv"
CLOSED = {"FORMAL-PASS", "CITED-PASS", "COMPUTED-PASS", "REDUNDANT"}


def load(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open(newline="") as handle:
        reader = csv.DictReader(handle)
        return list(reader.fieldnames or []), list(reader)


def main() -> int:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    _, ledger = load(LEDGER)
    fields, matrix = load(MATRIX)
    statuses = {row["claim_id"]: row["status"] for row in ledger}
    changed = []
    for row in matrix:
        ids = row["obligation_ids"].split(";")
        unknown = set(ids) - set(statuses)
        if unknown:
            raise SystemExit(
                f"HARD-FAIL: {row['requirement_id']}: unknown obligations {sorted(unknown)}"
            )
        expected = "PASS" if all(statuses[x] in CLOSED for x in ids) else "OPEN"
        if row["derived_status"] != expected:
            changed.append((row["requirement_id"], row["derived_status"], expected))
            if args.write:
                row["derived_status"] = expected

    if args.write:
        with MATRIX.open("w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
            writer.writeheader()
            writer.writerows(matrix)
        print(f"BURDEN STATUS|WROTE|changed={len(changed)}")
        return 0
    if changed:
        for requirement, actual, expected in changed:
            print(f"DRIFT|{requirement}|actual={actual}|expected={expected}")
        raise SystemExit("HARD-FAIL: burden-matrix derived statuses differ")
    print(f"BURDEN STATUS|PASS|requirements={len(matrix)}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error) as exc:
        raise SystemExit("HARD-FAIL: " + str(exc))
