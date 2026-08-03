#!/usr/bin/env python3
"""Fail-closed source/hypothesis audit for every Zsigmondy invocation.

This checks the exact published statement, the positive-base specialization,
the manuscript anchor for every invocation, and complete routing of every
exception.  It does not prove Zsigmondy's theorem; that theorem is an explicit
published dependency.
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
MAP = ROOT / "audit" / "ZSIGMONDY-INVOCATIONS.csv"
EXCEPTIONS = ROOT / "audit" / "EXCEPTION-MANIFEST.json"
PAPER = ROOT / "paper" / "kourovka1034.tex"

FIELDS = [
    "invocation_id", "manuscript_location", "family_branch", "base",
    "exponent", "parameter_range", "minimum_exponent", "manuscript_token",
    "exception_equation", "exception_ids", "resolution", "primary_source",
    "pinpoint", "pdf_sha256", "independent_source",
    "independent_pinpoint", "independent_pdf_sha256", "status",
]
EXPECTED_IDS = {
    "ZIG-PSL2-EVEN", "ZIG-BC-HIGHRANK", "ZIG-C2-ODD",
    "ZIG-G2-NOGRAPH", "ZIG-F4-NOGRAPH", "ZIG-E7", "ZIG-E8",
    "ZIG-PSU-ODD", "ZIG-PSU-EVEN", "ZIG-2DN", "ZIG-3D4",
    "ZIG-2E6", "ZIG-2F4", "ZIG-PSU3", "ZIG-SUZUKI",
    "ZIG-SMALL-REE", "ZIG-PSLN-TRIVIAL", "ZIG-DPLUS-ALL",
    "ZIG-SP4-TRIVIAL", "ZIG-F4-TRIVIAL", "ZIG-G2-TRIVIAL",
    "ZIG-PSL3-GRAPH", "ZIG-PSL4-GRAPH", "ZIG-PSLN-GRAPH",
    "ZIG-D4-TRIALITY", "ZIG-E6", "ZIG-SP4-GRAPH-ODD",
    "ZIG-SP4-GRAPH-EVEN", "ZIG-F4-GRAPH", "ZIG-G2-GRAPH-ODD",
    "ZIG-G2-GRAPH-EVEN",
}
EXPECTED_Z_EXCEPTIONS = {
    "Z-PSL2-8", "Z-PSU4-2", "Z-PSL3-4", "Z-PSL6-2",
    "Z-D4-2", "Z-SP6-2", "Z-SP4-8",
}
EXPECTED_SOURCE = "Zsigmondy1892"
EXPECTED_PINPOINT = "specialized theorem, journal p. 283"
EXPECTED_HASH = "45b2aea11e6e92711ab9b744b368dcb8ae0e84e69e5267c8515f61072faa9132"
EXPECTED_INDEPENDENT = (
    "Jones2007", "Theorem 2.2, journal p. 2",
    "8f03df2a69b7af5e47a1d27582519bcb2dba980b1e2c3dcc44b4050d881cceac",
)
# base, exponent, parameter range, minimum exponent, exception equation,
# routed exception IDs.  This is a separately authored semantic inventory,
# not a set comparison derived from the CSV.  In particular, changing an
# exponent while leaving all 31 row IDs present must hard-fail.
EXPECTED_INVOCATIONS = {
    "ZIG-PSL2-EVEN": ("2", "2f", "f>=3", "6", "2f=6", "Z-PSL2-8"),
    "ZIG-BC-HIGHRANK": (
        "p", "2nf", "n>=3; B_n has p odd; C_n arbitrary", "6",
        "p=2, n=3, f=1", "Z-SP6-2",
    ),
    "ZIG-C2-ODD": ("p", "4f", "p odd; f>=1", "4", "", ""),
    "ZIG-G2-NOGRAPH": (
        "p", "6f", "p!=3; simple group", "6", "p=2, f=1", "SIMP-G2-2",
    ),
    "ZIG-F4-NOGRAPH": ("p", "12f", "p!=2; f>=1", "12", "", ""),
    "ZIG-E7": ("p", "18f", "f>=1", "18", "", ""),
    "ZIG-E8": ("p", "30f", "f>=1", "30", "", ""),
    "ZIG-PSU-ODD": ("p", "2nf", "odd n>=5; f>=1", "10", "", ""),
    "ZIG-PSU-EVEN": (
        "p", "2(n-1)f", "even n>=4; f>=1", "6",
        "p=2, n=4, f=1", "Z-PSU4-2",
    ),
    "ZIG-2DN": ("p", "2nf", "n>=4; f>=1", "8", "", ""),
    "ZIG-3D4": ("p", "12f", "f>=1", "12", "", ""),
    "ZIG-2E6": ("p", "18f", "f>=1", "18", "", ""),
    "ZIG-2F4": ("2", "12f", "odd f>=3", "36", "", ""),
    "ZIG-PSU3": (
        "p", "6f", "q>=8 in the uniform branch", "6",
        "p=2, f=1", "SIMP-PSU3-2",
    ),
    "ZIG-SUZUKI": ("2", "4f", "odd f>=3", "12", "", ""),
    "ZIG-SMALL-REE": ("3", "6f", "odd f>=3", "18", "", ""),
    "ZIG-PSLN-TRIVIAL": (
        "p", "nf", "n>=3; f>=1", "3", "p=2, nf=6",
        "Z-PSL3-4;Z-PSL6-2",
    ),
    "ZIG-DPLUS-ALL": (
        "p", "2(n-1)f", "n>=4; f>=1", "6",
        "p=2, n=4, f=1", "Z-D4-2",
    ),
    "ZIG-SP4-TRIVIAL": ("2", "4f", "f>=2", "8", "", ""),
    "ZIG-F4-TRIVIAL": ("2", "12f", "f>=1", "12", "", ""),
    "ZIG-G2-TRIVIAL": ("3", "6f", "f>=1", "6", "", ""),
    "ZIG-PSL3-GRAPH": (
        "p", "3f", "q>=5", "3", "p=2, f=2", "Z-PSL3-4",
    ),
    "ZIG-PSL4-GRAPH": ("p", "4f", "f>=1", "4", "", ""),
    "ZIG-PSLN-GRAPH": (
        "p", "nf", "n>=5; f>=1", "5", "p=2, n=6, f=1", "Z-PSL6-2",
    ),
    "ZIG-D4-TRIALITY": (
        "p", "6f", "f>=1", "6", "p=2, f=1", "Z-D4-2",
    ),
    "ZIG-E6": ("p", "12f", "f>=1", "12", "", ""),
    "ZIG-SP4-GRAPH-ODD": (
        "2", "2f", "odd f>=3", "6", "f=3", "Z-SP4-8",
    ),
    "ZIG-SP4-GRAPH-EVEN": ("2", "4f", "even f>=2", "8", "", ""),
    "ZIG-F4-GRAPH": ("2", "12f", "f>=1", "12", "", ""),
    "ZIG-G2-GRAPH-ODD": ("3", "3f", "odd f>=1", "3", "", ""),
    "ZIG-G2-GRAPH-EVEN": ("3", "6f", "even f>=2", "12", "", ""),
}


def die(message: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + message)


def normalized(text: str) -> str:
    return " ".join(text.split())


def main() -> int:
    with MAP.open(newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            die(f"Zsigmondy map columns drift: {reader.fieldnames!r}")
        rows = list(reader)
    ids = [row["invocation_id"] for row in rows]
    if set(ids) != EXPECTED_IDS or len(ids) != len(set(ids)):
        die(f"Zsigmondy invocation inventory mismatch: {sorted(ids)!r}")
    if set(EXPECTED_INVOCATIONS) != EXPECTED_IDS:
        die("internal semantic invocation inventory is inconsistent")

    manifest = json.loads(EXCEPTIONS.read_text())
    exception_records = {item["id"]: item for item in manifest["exceptions"]}
    manifest_z = {
        item["id"] for item in manifest["exceptions"]
        if item["kind"] == "Zsigmondy"
    }
    if manifest_z != EXPECTED_Z_EXCEPTIONS:
        die(f"Zsigmondy exception-manifest inventory drift: {sorted(manifest_z)!r}")

    paper = normalized(PAPER.read_text())
    mapped_z: set[str] = set()
    for row in rows:
        cid = row["invocation_id"]
        if any(not row[field].strip() for field in (
            "manuscript_location", "family_branch", "base", "exponent",
            "parameter_range", "minimum_exponent", "manuscript_token",
            "resolution",
        )):
            die(f"{cid}: empty required field")
        try:
            minimum = int(row["minimum_exponent"])
        except ValueError:
            die(f"{cid}: minimum exponent is not an integer")
        semantic_record = tuple(row[field] for field in (
            "base", "exponent", "parameter_range", "minimum_exponent",
            "exception_equation", "exception_ids",
        ))
        if semantic_record != EXPECTED_INVOCATIONS[cid]:
            die(f"{cid}: base/exponent/range/minimum/exception routing drift")
        # The manuscript only invokes the positive-base specialization at
        # exponent >=3, so Zsigmondy's n=2/Mersenne exception cannot apply.
        if minimum < 3:
            die(f"{cid}: exponent-2 exception was not excluded")
        if (row["primary_source"], row["pinpoint"], row["pdf_sha256"], row["status"]) != (
            EXPECTED_SOURCE, EXPECTED_PINPOINT, EXPECTED_HASH, "CITED-PASS"
        ):
            die(f"{cid}: source, pinpoint, PDF hash, or status drift")
        if (
            row["independent_source"], row["independent_pinpoint"],
            row["independent_pdf_sha256"],
        ) != EXPECTED_INDEPENDENT:
            die(f"{cid}: independent modern statement or hash drift")
        token = normalized(row["manuscript_token"])
        if paper.count(token) != 1:
            die(f"{cid}: manuscript anchor count is {paper.count(token)}, expected 1")
        exception_ids = [x for x in row["exception_ids"].split(";") if x]
        if bool(exception_ids) != bool(row["exception_equation"].strip()):
            die(f"{cid}: exception equation/routing mismatch")
        for exception_id in exception_ids:
            if exception_id not in exception_records:
                die(f"{cid}: unknown exception {exception_id}")
            if exception_id.startswith("Z-"):
                mapped_z.add(exception_id)

    if mapped_z != manifest_z:
        die(
            "Zsigmondy invocation/exception topology mismatch: "
            f"missing={sorted(manifest_z-mapped_z)!r}, extra={sorted(mapped_z-manifest_z)!r}"
        )

    required_tex = {
        r"\cite[specialized theorem, p.~283]{Zsigmondy}",
        r"\cite[Thm.~2.2, p.~2]{Jones2007}",
        r"DOI 10.1007/BF01692444",
        "additional positive-base exception",
        "exponent $2$, outside every invocation here",
    }
    missing = sorted(token for token in required_tex if token not in PAPER.read_text())
    if missing:
        die(f"manuscript lacks exact Zsigmondy source/hypothesis text: {missing!r}")

    print(f"Zsigmondy invocation rows: {len(rows)}")
    print("published statement: Zsigmondy 1892, specialized theorem, journal p. 283")
    print("independent modern statement: Jones 2007, Theorem 2.2, journal p. 2")
    print("positive-base exponent-2 exception excluded: PASS")
    print("routed positive-base (2,6) cases: " + ",".join(sorted(mapped_z)))
    print("ZSIGMONDY SOURCE/HYPOTHESIS AUDIT|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, json.JSONDecodeError, KeyError) as exc:
        die(str(exc))
