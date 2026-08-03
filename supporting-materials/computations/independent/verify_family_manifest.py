#!/usr/bin/env python3
"""Fail-closed, GAP-independent CFSG-family/exception manifest checker.

This validates inventory topology and exception routing only.  It does not
purport to prove CFSG or the family theorems; those remain separate cited or
formal coverage manifests.
"""
from __future__ import annotations
import json, os, re, sys
from pathlib import Path

ROOT = Path(os.environ.get("KOUROVKA_SUPPORTING_ROOT",
                           Path(__file__).resolve().parents[2])).resolve()
AUDIT = ROOT / "audit"
CERT = ROOT / "computations" / "certificates"

REQUIRED_FAMILIES = {
    "alternating", "psl2", "psl_rank_ge3", "psu3", "psu_rank_ge4",
    "symplectic", "odd_orthogonal", "plus_orthogonal", "minus_orthogonal",
    "suzuki", "small_ree", "triality", "g2", "f4", "e6", "twisted_e6",
    "e7", "e8", "large_ree", "tits", "sporadic",
}
EXPECTED_ROUTES = {
    "alternating": "THM-AN",
    "psl2": "THM-PSL2",
    "psl_rank_ge3": "THM-GRAPH",
    "psu3": "THM-TWISTED-RANK1",
    "psu_rank_ge4": "THM-TWISTED-RANKGE2",
    "symplectic": "THM-NOGRAPH for n>=3 or q odd; THM-GRAPH for n=2 and q even >=4",
    "odd_orthogonal": "THM-NOGRAPH",
    "plus_orthogonal": "THM-GRAPH",
    "minus_orthogonal": "THM-TWISTED-RANKGE2",
    "suzuki": "THM-TWISTED-RANK1",
    "small_ree": "THM-TWISTED-RANK1",
    "triality": "THM-TWISTED-RANKGE2",
    "g2": "THM-NOGRAPH if p!=3; THM-GRAPH if p=3",
    "f4": "THM-NOGRAPH if p!=2; THM-GRAPH if p=2",
    "e6": "THM-GRAPH",
    "twisted_e6": "THM-TWISTED-RANKGE2",
    "e7": "THM-NOGRAPH",
    "e8": "THM-NOGRAPH",
    "large_ree": "THM-TWISTED-RANKGE2",
    "tits": "PROP-SPORADIC",
    "sporadic": "PROP-SPORADIC plus finite-base certificates for six small sporadics",
}
EXPECTED_EXCEPTIONS = {
    "alternating": {"MAX-AN-LE14"},
    "psl2": {"SIMP-PSL2-2-3", "MAX-PSL2-LE11", "Z-PSL2-8"},
    "psl_rank_ge3": {"Z-PSL3-4", "Z-PSL6-2", "MAX-PSL3-LE4"},
    "psu3": {"SIMP-PSU3-2", "MAX-PSU3-SMALL"},
    "psu_rank_ge4": {"Z-PSU4-2", "ISO-PSU4-2"},
    "symplectic": {"SIMP-SP4-2", "Z-SP6-2", "Z-SP4-8"},
    "odd_orthogonal": {"ISO-BC-EVEN"},
    "plus_orthogonal": {"Z-D4-2"},
    "minus_orthogonal": {"ISO-2D-LOWRANK"},
    "small_ree": {"SIMP-REE3"},
    "g2": {"SIMP-G2-2"},
    "large_ree": {"SIMP-2F4-2"},
}
REQUIRED_DESTINATIONS = {
    "COMP-FINITE-BASE", "ARITH-SUBSTITUTE-PRIMES", "CFSG-BOUNDARIES",
    "THM-PSL2", "THM-NOGRAPH", "PROP-SPORADIC",
}
EXPECTED_QUANTITATIVE_RESOLUTIONS = {
    "Z-PSL3-4": "all ten coordinate closures in exact finite certificates",
    "Z-SP4-8": "substitute prime 3 with d=4>v_3(6)=1",
}

def die(msg: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + msg)

def load(name: str):
    try:
        return json.loads((AUDIT / name).read_text())
    except (OSError, json.JSONDecodeError) as exc:
        die(f"cannot load {name}: {exc}")

def main() -> int:
    cfsg = load("CLASSIFICATION-MANIFEST.json")
    exc = load("EXCEPTION-MANIFEST.json")
    families = cfsg.get("families", [])
    ids = [x.get("id") for x in families]
    if len(ids) != len(set(ids)):
        die("duplicate CFSG family id")
    if set(ids) != REQUIRED_FAMILIES:
        die(f"family inventory mismatch: missing={sorted(REQUIRED_FAMILIES-set(ids))}, extra={sorted(set(ids)-REQUIRED_FAMILIES)}")
    if not all(x.get("parameters") and x.get("route") for x in families):
        die("a family has an empty parameter range or route")
    for family in families:
        if family["route"] != EXPECTED_ROUTES[family["id"]]:
            die(f"{family['id']}: family route drift")
        if set(family.get("exceptions", [])) != EXPECTED_EXCEPTIONS.get(family["id"], set()):
            die(f"{family['id']}: exception routing drift")
    if any("threshold" in x.get("route", "").lower() for x in families):
        die("an arbitrary order threshold was used as a primary family route")

    source = cfsg.get("classification_source", {})
    if (source.get("obligation") != "SRC-CFSG-PINPOINT" or
            source.get("pinpoint_status") != "CITED-PASS" or
            source.get("pinpoint") != "Chapter 1, Table I, pp. 8--10" or
            not source.get("independent_corroboration")):
        die("CFSG source pinpoint is missing or drifted")

    records = exc.get("exceptions", [])
    ex_ids = [x.get("id") for x in records]
    if len(ex_ids) != len(set(ex_ids)):
        die("duplicate exception id")
    referenced = {e for f in families for e in f.get("exceptions", [])}
    if referenced != set(ex_ids):
        die(f"family/exception cross-link mismatch: unreferenced={sorted(set(ex_ids)-referenced)}, missing={sorted(referenced-set(ex_ids))}")
    if not all(x.get("destination") in REQUIRED_DESTINATIONS and x.get("resolution") for x in records):
        die("an exception has an unknown/empty destination or resolution")
    by_id = {x["id"]: x for x in records}
    for exception_id, resolution in EXPECTED_QUANTITATIVE_RESOLUTIONS.items():
        if by_id[exception_id]["resolution"] != resolution:
            die(f"{exception_id}: quantitative resolution drift")

    expected = exc.get("zsigmondy_exception_tags_expected_from_sweepN", [])
    tagged = [tag for x in records for tag in x.get("tags", [])]
    if len(expected) != len(set(expected)) or sorted(expected) != sorted(tagged):
        die("Zsigmondy tag manifest has duplicates, omissions, or extra routes")
    nlog = (CERT / "sweepN_item5_arith.log").read_text()
    m = re.search(r"expected-exception tags encountered: \[(.*?)\]", nlog)
    if not m:
        die("sweep N did not record its exact exception tags")
    observed = re.findall(r"'([^']+)'", m.group(1))
    if sorted(observed) != sorted(expected):
        die(f"sweep N/exception manifest mismatch: {observed!r}")
    if "SWEEP N DONE.|PASS" not in nlog:
        die("sweep N lacks the fail-closed PASS marker")

    print(f"independent CFSG family rows: {len(ids)}")
    print(f"exception routes: {len(ex_ids)}")
    print(f"Zsigmondy exception tags cross-linked: {len(expected)}")
    print("INDEPENDENT FAMILY/EXCEPTION MANIFEST VERIFICATION|PASS")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError) as exc:
        die(str(exc))
