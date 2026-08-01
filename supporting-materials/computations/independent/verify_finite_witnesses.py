#!/usr/bin/env python3
"""Independent parser/recomputation for every proof-essential finite witness.

This program shares no GAP subgroup-enumeration code.  It treats the committed
GAP records as untrusted input, parses every exact class record, independently
recomputes all valuations, cross-links sweep K classes to the embedding-aware
sweep K2 saturation ledger, and checks the sporadic Maxes positions/stability
records.  Any malformed, duplicate, missing, or order-only record is fatal.
"""
from __future__ import annotations

import csv
import hashlib
import re
import os
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[2]
)).resolve()
CERT = ROOT / "computations" / "certificates"
SPORADIC_SOURCE_MAP = ROOT / "audit" / "SPORADIC-SOURCE-MAP.csv"

J_LOGS = [
    "sweepJ_divisibility.log", "sweepJ2_tail.log", "sweepJ4_patch.log",
    "sweepJ3_bigrange.log", "sweepJ5_smallAn.log", "sweepJ6_L52_M23.log",
]
K_LOGS = ["sweepK_novelty.log", "sweepK3_bigsurvivors.log", "sweepK4_L52.log"]
M_LOG = "sweepM_sporadic.log"
K2_LOG = "sweepK2_saturation.log"


def die(msg: str) -> "NoReturn":
    raise SystemExit(f"HARD-FAIL: {msg}")


def vp(n: int, p: int) -> int:
    if p < 2:
        die(f"invalid prime {p}")
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def is_prime(p: int) -> bool:
    if p < 2:
        return False
    q = 2
    while q * q <= p:
        if p % q == 0:
            return False
        q += 1
    return True


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()


def gap_integer_list(values: list[int]) -> str:
    return "[ " + ", ".join(str(x) for x in values) + " ]"


def class_fingerprint_fields(fp: str, where: str) -> dict[str, str]:
    fields = {}
    for piece in fp.split(","):
        if "=" not in piece:
            die(f"{where}: malformed class fingerprint")
        key, value = piece.split("=", 1)
        if key in fields:
            die(f"{where}: duplicate class-fingerprint field {key}")
        fields[key] = value
    expected = {"class", "order", "index", "normalizer", "class_sha256"}
    if set(fields) != expected:
        die(f"{where}: class-fingerprint schema drift")
    try:
        numeric = [int(fields[k]) for k in ("class", "order", "index", "normalizer")]
    except ValueError:
        die(f"{where}: noninteger class-fingerprint guard")
    if fields["class_sha256"] != sha256_text(gap_integer_list(numeric)):
        die(f"{where}: canonical class SHA-256 mismatch")
    return fields


def factor_pairs(n: int) -> list[list[int]]:
    out = []
    p = 2
    while p * p <= n:
        exponent = 0
        while n % p == 0:
            n //= p
            exponent += 1
        if exponent:
            out.append([p, exponent])
        p += 1
    if n > 1:
        out.append([n, 1])
    return out


def gap_nested_pairs(pairs: list[list[int]]) -> str:
    return "[ " + ", ".join(gap_integer_list(pair) for pair in pairs) + " ]"


def records(path: Path, prefix: str):
    for line_no, line in enumerate(path.read_text().splitlines(), 1):
        if not line.startswith(prefix + "|"):
            continue
        fields: dict[str, str] = {}
        for piece in line.split("|")[1:]:
            if "=" not in piece:
                die(f"{path.name}:{line_no}: malformed field {piece!r}")
            key, value = piece.split("=", 1)
            if key in fields:
                die(f"{path.name}:{line_no}: duplicate field {key}")
            fields[key] = value
        yield line_no, fields


def integer(rec, key, where):
    try:
        return int(rec[key])
    except (KeyError, ValueError):
        die(f"{where}: invalid/missing integer field {key}")


def check_group_record(rec: dict[str, str], where: str, *, require_action: bool) -> None:
    order = integer(rec, "order", where)
    expected_hash = sha256_text(gap_nested_pairs(factor_pairs(order)))
    if rec.get("order_factors_sha256") != expected_hash:
        die(f"{where}: deterministic socle-order fingerprint mismatch")
    if require_action:
        out, ambient = integer(rec, "out", where), integer(rec, "P", where)
        if out < 1 or ambient != order * out:
            die(f"{where}: ambient/socle/outer orders are inconsistent")
        if rec.get("faithful") != "true" or rec.get("simple") != "true":
            die(f"{where}: simple/faithful action assertions missing")


def check_cert(path: Path, line_no: int, rec: dict[str, str]):
    where = f"{path.name}:{line_no}"
    required = {"kind", "group", "s", "x", "uclass", "u", "vclass", "v",
                "p", "d", "vpx", "result"}
    missing = required - rec.keys()
    if missing:
        die(f"{where}: missing fields {sorted(missing)}")
    if rec["result"] != "PASS":
        die(f"{where}: non-PASS record")
    s, x = integer(rec, "s", where), integer(rec, "x", where)
    u, v = integer(rec, "u", where), integer(rec, "v", where)
    p, d = integer(rec, "p", where), integer(rec, "d", where)
    if not is_prime(p):
        die(f"{where}: obstruction is not prime: {p}")
    independent_d = vp(s, p) - vp(u, p) - vp(v, p)
    if d != independent_d:
        die(f"{where}: d={d}, independently recomputed {independent_d}")
    if integer(rec, "vpx", where) != vp(x, p):
        die(f"{where}: incorrect v_p(x)")
    if d <= vp(x, p):
        die(f"{where}: valuation inequality is false")
    if rec["uclass"] == rec["vclass"]:
        die(f"{where}: selected class identifiers coincide")
    if rec["kind"] in {"maximal", "novelty"}:
        for side in ("u", "v"):
            fp = rec.get(side + "fp", "")
            fields = class_fingerprint_fields(fp, f"{where}:{side}")
            if fields["class"] != rec[side+"class"] or fields["order"] != rec[side]:
                die(f"{where}: {side} fingerprint does not bind class and order")
    if ((rec["kind"] == "novelty" and path.name == "sweepK_novelty.log")
            or (rec["kind"] == "maximal" and path.name in J_LOGS)):
        if integer(rec, "xconjugates", where) < 1:
            die(f"{where}: quotient-class representative audit is empty")
        xhash = rec.get("xclass_sha256", "")
        if not re.fullmatch(r"[0-9a-f]{64}", xhash):
            die(f"{where}: missing/malformed exact quotient-class fingerprint")
        integer(rec, "xclass", where)
        return (rec["kind"], rec["group"], xhash), rec
    return (rec["kind"], rec["group"], rec.get("xclass", rec["x"])), rec


def main() -> int:
    saturation: dict[tuple[str, str], tuple[str, str]] = {}
    k2 = CERT / K2_LOG
    summaries = set()
    embedding_orbits: dict[tuple[str, str, str], set[int]] = defaultdict(set)
    method_a_records: dict[tuple[str, str, str], int] = defaultdict(int)
    orbit_checks: dict[tuple[str, str, str], tuple[int, int, int, int]] = {}
    k2_groups = set()
    for line_no, rec in records(k2, "GROUP"):
        where = f"{k2.name}:{line_no}"
        check_group_record(rec, where, require_action=False)
        if integer(rec, "subgroup_classes", where) < 1 or integer(
                rec, "self_normalizing_classes", where) < 1:
            die(f"{where}: empty subgroup-class inventory")
        if rec.get("name", "") in k2_groups:
            die(f"{where}: duplicate GROUP record")
        k2_groups.add(rec.get("name", ""))
    if k2_groups != {"L3_2", "A6", "L2_11", "L3_4"}:
        die(f"{k2.name}: group records incomplete: {sorted(k2_groups)}")
    for line_no, rec in records(k2, "VCLASS"):
        key = (rec.get("group", ""), rec.get("class", ""))
        # Store the exact guard fingerprint serialized in the same field order.
        fp = ",".join(f"{k}={rec[k]}" for k in
                      ("class", "order", "index", "normalizer", "class_sha256"))
        class_fingerprint_fields(fp, f"{k2.name}:{line_no}")
        if key in saturation:
            die(f"{k2.name}:{line_no}: duplicate VCLASS {key}")
        saturation[key] = (fp, "UNKNOWN")
    for line_no, rec in records(k2, "SATURATION"):
        key = (rec.get("group", ""), rec.get("vclass", ""))
        if key not in saturation:
            die(f"{k2.name}:{line_no}: SATURATION without VCLASS {key}")
        saturation[key] = (saturation[key][0], rec.get("status", ""))
    for line_no, rec in records(k2, "EMBEDDING-A"):
        where = f"{k2.name}:{line_no}"
        key = (rec.get("group", ""), rec.get("vclass", ""), rec.get("wclass", ""))
        v, w = integer(rec, "v", where), integer(rec, "w", where)
        closure = integer(rec, "closure", where)
        if w % v or rec.get("result") != str(closure == w).lower():
            die(f"{where}: invalid method-A overgroup record")
        method_a_records[key] += 1
    for line_no, rec in records(k2, "ORBIT-CHECK"):
        where = f"{k2.name}:{line_no}"
        key = (rec.get("group", ""), rec.get("vclass", ""), rec.get("wclass", ""))
        if key in orbit_checks:
            die(f"{where}: duplicate ORBIT-CHECK")
        values = tuple(integer(rec, field, where) for field in
                       ("methodA_records", "methodA_normalizer_orbits",
                        "direct_orbits", "builtin_orbits"))
        if rec.get("result") != "PASS" or min(values) < 0:
            die(f"{where}: failed/invalid method comparison")
        orbit_checks[key] = values
    for line_no, rec in records(k2, "EMBEDDING-B"):
        where = f"{k2.name}:{line_no}"
        group, vc, wc = rec.get("group", ""), rec.get("vclass", ""), rec.get("wclass", "")
        orbit = integer(rec, "orbit", where)
        v, w = integer(rec, "v", where), integer(rec, "w", where)
        closure = integer(rec, "closure", where)
        wnormalizer = integer(rec, "wnormalizer", where)
        if orbit < 1 or w % v or wnormalizer % v or not (v <= wnormalizer <= w):
            die(f"{where}: impossible embedding/normalizer orders")
        if rec.get("result") != str(closure == w).lower():
            die(f"{where}: result does not match normal-closure order")
        embedding_data = [integer(rec, key, where) for key in
                          ("vclass", "wclass", "orbit", "v", "w", "closure", "wnormalizer")]
        if rec.get("embedding_sha256") != sha256_text(gap_integer_list(embedding_data)):
            die(f"{where}: canonical embedding SHA-256 mismatch")
        key = (group, vc, wc)
        if orbit in embedding_orbits[key]:
            die(f"{where}: duplicate embedding-orbit identifier")
        embedding_orbits[key].add(orbit)
    for key, orbit_ids in embedding_orbits.items():
        if orbit_ids != set(range(1, max(orbit_ids) + 1)):
            die(f"{k2.name}: noncontiguous embedding-orbit identifiers for {key}")
        if key not in orbit_checks:
            die(f"{k2.name}: no ORBIT-CHECK for {key}")
        a_records, a_normalizer, direct_count, builtin_count = orbit_checks[key]
        if a_records != method_a_records[key]:
            die(f"{k2.name}: method-A record count mismatch for {key}")
        if direct_count != len(orbit_ids) or builtin_count != direct_count:
            die(f"{k2.name}: direct/builtin orbit count mismatch for {key}")
        if not (1 <= a_normalizer <= direct_count and a_normalizer <= a_records):
            die(f"{k2.name}: impossible method-A normalizer-orbit count for {key}")
    for key, (a_records, a_normalizer, direct_count, builtin_count) in orbit_checks.items():
        if direct_count == 0 and (a_records or a_normalizer or builtin_count):
            die(f"{k2.name}: inconsistent empty embedding domain for {key}")
        if direct_count > 0 and key not in embedding_orbits:
            die(f"{k2.name}: positive ORBIT-CHECK without method-B records for {key}")
    positive_b = {key for key, values in orbit_checks.items() if values[2] > 0}
    positive_a = {key for key, values in orbit_checks.items() if values[0] > 0}
    if positive_b != set(embedding_orbits) or positive_a != set(method_a_records):
        die(f"{k2.name}: methods A/B/C have different overgroup-pair domains")
    for _, rec in records(k2, "GROUP-SUMMARY"):
        if rec.get("methods_agree") != "true":
            die(f"{k2.name}: independent saturation methods disagree")
        summaries.add(rec.get("name"))
    if summaries != {"L3_2", "A6", "L2_11", "L3_4"}:
        die(f"{k2.name}: group summaries incomplete: {sorted(summaries)}")

    seen = set()
    redundant_routes = 0
    counts = defaultdict(int)
    all_logs = [*J_LOGS, *K_LOGS, M_LOG]
    for log_name in all_logs:
        path = CERT / log_name
        if not path.exists():
            die(f"missing log {log_name}")
        text = path.read_text()
        if "|PASS" not in text:
            die(f"{log_name}: missing terminal PASS marker")
        socles = list(records(path, "SOCLE"))
        for socle_line, socle in socles:
            where = f"{path.name}:{socle_line}"
            check_group_record(socle, where, require_action=True)
        if log_name in J_LOGS:
            header_groups = re.findall(r"^### ([^:]+):", text, re.M)
            socle_groups = [rec.get("group", "") for _, rec in socles]
            if header_groups != socle_groups or not header_groups:
                die(f"{log_name}: group headers and SOCLE records differ")
        elif log_name == "sweepK_novelty.log" and len(socles) != 4:
            die(f"{log_name}: expected four SOCLE action records")
        elif log_name in {"sweepK3_bigsurvivors.log", "sweepK4_L52.log"} and len(socles) != 1:
            die(f"{log_name}: expected one SOCLE action record")
        parsed = list(records(path, "CERT"))
        if log_name in J_LOGS:
            # J emits one exact XCASE record for every conjugacy class of
            # coordinate closures, including the exceptional classes routed
            # to novelty certificates.  This prevents survivors from being
            # identified only by their order and binds every successful CERT
            # to the canonical quotient-class SHA-256.
            xcases = list(records(path, "XCASE"))
            by_group = defaultdict(list)
            for xline, xrec in xcases:
                where = f"{path.name}:{xline}"
                required_x = {"group", "out", "xclass", "xclass_sha256",
                              "x", "xstructure", "xconjugates", "result"}
                if set(xrec) != required_x:
                    die(f"{where}: XCASE schema drift")
                xclass = integer(xrec, "xclass", where)
                x, out = integer(xrec, "x", where), integer(xrec, "out", where)
                if xclass < 1 or x < 1 or out % x:
                    die(f"{where}: impossible quotient-subgroup orders/class")
                if integer(xrec, "xconjugates", where) < 1:
                    die(f"{where}: empty quotient conjugacy class")
                if xrec["result"] not in {"EXCLUDED", "SURVIVES"}:
                    die(f"{where}: invalid XCASE result")
                if not xrec["xstructure"] or not re.fullmatch(
                        r"[0-9a-f]{64}", xrec["xclass_sha256"]):
                    die(f"{where}: incomplete exact quotient-class identity")
                by_group[xrec["group"]].append(xrec)
            if set(by_group) != set(header_groups):
                die(f"{log_name}: XCASE groups differ from group headers")
            for group, grows in by_group.items():
                positions = [integer(r, "xclass", f"{log_name}:{group}")
                             for r in grows]
                hashes = [r["xclass_sha256"] for r in grows]
                if sorted(positions) != list(range(1, len(grows) + 1)):
                    die(f"{log_name}: noncanonical/gapped X-class positions for {group}")
                if len(hashes) != len(set(hashes)):
                    die(f"{log_name}: duplicate exact X-class fingerprint for {group}")
            cert_by_x = {}
            for cline, crec in parsed:
                where = f"{path.name}:{cline}"
                key = (crec.get("group", ""), integer(crec, "xclass", where))
                if key in cert_by_x:
                    die(f"{where}: duplicate successful CERT for one XCASE")
                cert_by_x[key] = crec
            excluded = {}
            for _, xrec in xcases:
                if xrec["result"] == "EXCLUDED":
                    excluded[(xrec["group"], int(xrec["xclass"]))] = xrec
            if set(cert_by_x) != set(excluded):
                die(f"{log_name}: successful CERT/XCASE domain mismatch")
            for key, crec in cert_by_x.items():
                xrec = excluded[key]
                for field in ("out", "x", "xstructure", "xconjugates",
                              "xclass_sha256"):
                    if crec.get(field) != xrec.get(field):
                        die(f"{log_name}: CERT/XCASE {field} mismatch for {key}")
            expected = len(re.findall(r"X/Inn\s*=.*?: ALL k >= 2 EXCLUDED", text))
            if len(parsed) != expected:
                die(f"{log_name}: {len(parsed)} CERT records but {expected} successful X-cases")
        elif log_name == "sweepK_novelty.log":
            expected = len(re.findall(r"ALL k >= 2 EXCLUDED via", text))
            if len(parsed) != expected:
                die(f"{log_name}: {len(parsed)} CERT records but {expected} X-cases")
        elif log_name in {"sweepK3_bigsurvivors.log", "sweepK4_L52.log"}:
            if len(parsed) != 1:
                die(f"{log_name}: expected exactly one constructed certificate")
        elif log_name == M_LOG and len(parsed) != 21:
            die(f"{log_name}: expected exactly 21 sporadic/Tits certificates")

        seen_in_file = set()
        for line_no, rec in parsed:
            key, rec = check_cert(path, line_no, rec)
            if key in seen_in_file:
                die(f"{path.name}:{line_no}: duplicate certificate key within one log: {key}")
            seen_in_file.add(key)
            if key in seen:
                # J6 is a deliberately redundant construction of two J3 cases.
                # It is independent evidence, not an ambiguity within a sweep.
                redundant_routes += 1
            seen.add(key)
            counts[rec["kind"]] += 1
            if rec["kind"] == "novelty":
                for side in ("u", "v"):
                    skey = (rec["group"], rec[side + "class"])
                    if skey not in saturation:
                        die(f"{path.name}:{line_no}: no K2 record for {skey}")
                    fp, status = saturation[skey]
                    if fp != rec[side + "fp"]:
                        die(f"{path.name}:{line_no}: K/K2 fingerprint mismatch for {skey}")
                    if status != "SATURATES":
                        die(f"{path.name}:{line_no}: selected class does not saturate: {skey}")

    # Cross-check every sporadic CERT against the exact MAXCLASS records.
    mpath = CERT / M_LOG
    maxclasses = {}
    for line_no, rec in records(mpath, "MAXCLASS"):
        key = (rec.get("group"), rec.get("position"))
        if key in maxclasses:
            die(f"{mpath.name}:{line_no}: duplicate MAXCLASS {key}")
        maxclasses[key] = rec
    sporadic = []
    for line_no, rec in records(mpath, "CERT"):
        if rec.get("kind") != "sporadic":
            continue
        sporadic.append(rec["group"])
        for side in ("u", "v"):
            key = (rec["group"], rec[side + "class"])
            mr = maxclasses.get(key)
            if mr is None:
                die(f"{mpath.name}:{line_no}: missing MAXCLASS {key}")
            if mr.get("identifier") != rec[side + "id"] or mr.get("order") != rec[side]:
                die(f"{mpath.name}:{line_no}: class identity mismatch for {key}")
            if integer(rec, "out", mpath.name) == 2:
                if mr.get("multiplicity") != "1" or not rec[side + "stability"].startswith("unique-order"):
                    die(f"{mpath.name}:{line_no}: invalid outer-stability evidence for {key}")
    if len(sporadic) != 21 or len(set(sporadic)) != 21:
        die(f"sporadic certificate count is {len(sporadic)}, expected 21")

    # The citation audit is data, not prose: bind every selected CTblLib
    # position/identifier/order tuple to one exact published-source row.
    with SPORADIC_SOURCE_MAP.open(newline="") as f:
        rd = csv.DictReader(f)
        expected_fields = ["group", "position", "identifier", "order",
                           "source_document", "source_pinpoint",
                           "published_structure", "status"]
        if rd.fieldnames != expected_fields:
            die(f"sporadic source-map columns drift: {rd.fieldnames!r}")
        source_rows = list(rd)
    source_map = {}
    allowed_documents = {
        "Wilson2017", "DietrichLeePisaniPopiel2026",
        "Wilson1984+Tchakerian1986",
    }
    for row_no, row in enumerate(source_rows, 2):
        key = (row["group"], row["position"])
        if key in source_map:
            die(f"sporadic source map:{row_no}: duplicate class {key}")
        if row["status"] != "CITED-PASS":
            die(f"sporadic source map:{row_no}: non-passing source row")
        if row["source_document"] not in allowed_documents:
            die(f"sporadic source map:{row_no}: unknown source document")
        if not row["source_pinpoint"] or not row["published_structure"]:
            die(f"sporadic source map:{row_no}: missing pinpoint/structure")
        try:
            int(row["order"])
        except ValueError:
            die(f"sporadic source map:{row_no}: non-integral order")
        source_map[key] = row
    selected_maxclasses = {}
    for rec in records(mpath, "CERT"):
        if rec[1].get("kind") != "sporadic":
            continue
        cert = rec[1]
        for side in ("u", "v"):
            key = (cert["group"], cert[side + "class"])
            selected_maxclasses[key] = (
                cert[side + "id"], cert[side],
            )
    if set(source_map) != set(selected_maxclasses):
        missing = sorted(set(selected_maxclasses) - set(source_map))
        extra = sorted(set(source_map) - set(selected_maxclasses))
        die(f"sporadic source-map key mismatch; missing={missing}, extra={extra}")
    for key, (identifier, order) in selected_maxclasses.items():
        row = source_map[key]
        if row["identifier"] != identifier or row["order"] != order:
            die(f"sporadic source-map identity mismatch for {key}")

    expected_kinds = {"maximal", "novelty", "constructed-novelty", "sporadic"}
    if set(counts) != expected_kinds:
        die(f"certificate kinds mismatch: {sorted(counts)}")
    print("finite certificates independently recomputed:", sum(counts.values()))
    print("redundant independently constructed routes:", redundant_routes)
    print("by kind:", ", ".join(f"{k}={counts[k]}" for k in sorted(counts)))
    print("exact novelty classes cross-linked to exhaustive saturation: PASS")
    print("exact sporadic Maxes positions and stability evidence: PASS")
    print("exact sporadic class-to-published-source rows: PASS")
    print("INDEPENDENT FINITE WITNESS VERIFICATION|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError) as exc:
        die(str(exc))
