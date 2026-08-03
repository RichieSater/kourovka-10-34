#!/usr/bin/env python3
"""Universal, fail-closed audit of every arithmetic branch in Theorems 6.1--6.6.

This verifier consumes the exact branch specification in
``audit/FAMILY-ARITHMETIC-MANIFEST.json``.  Published group, subgroup,
Levi, and outer-automorphism formulas are deliberately treated as named
source assumptions: every branch must bind those assumptions to exact rows in
``ORDER-FORMULA-SOURCE-MAP.csv``.  Starting from those source-derived factor
lists, this program proves the remaining deductions for *all* permitted ranks
and field degrees, rather than sampling parameters:

* the primitive exponent occurs in the simple-group order;
* every selected-subgroup and central/diagonal exponent is strictly smaller;
* the outer-order factors cannot contain the primitive prime;
* the exceptional equation is solved exhaustively;
* every exceptional parameter has a substitute or exact finite certificate;
* the alternating and defining-characteristic branches satisfy their exact
  universal numerical lemmas.

The independently structured checker ``family_arithmetic_symbolic.py`` does
not read this manifest.  Lean additionally kernel-checks the universal
arithmetic lemmas and all affine branch certificates.
"""
from __future__ import annotations

import argparse
import csv
import json
import math
import os
import re
import sys
from collections import Counter
from pathlib import Path
from typing import NoReturn

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[2]
)).resolve()
AUDIT = ROOT / "audit"
MANIFEST = AUDIT / "FAMILY-ARITHMETIC-MANIFEST.json"
GENERATED = AUDIT / "ARITHMETIC-EXCEPTIONS.generated.json"

EXPECTED_BRANCH_IDS = [
    "AR-PSL2-ODD", "AR-PSL2-EVEN", "AR-ALTERNATING",
    "AR-C-HIGHRANK", "AR-B-HIGHRANK", "AR-C2-ODD",
    "AR-G2-NOGRAPH", "AR-F4-NOGRAPH", "AR-E7", "AR-E8",
    "AR-PSU-ODD", "AR-PSU-EVEN", "AR-2D", "AR-3D4", "AR-2E6",
    "AR-2F4", "AR-PSU3", "AR-SUZUKI", "AR-SMALL-REE",
    "AR-PSL-TRIVIAL", "AR-DPLUS", "AR-SP4-TRIVIAL",
    "AR-F4-TRIVIAL", "AR-G2-TRIVIAL", "AR-PSL3-GRAPH",
    "AR-PSL4-GRAPH", "AR-PSLN-GRAPH", "AR-D4-TRIALITY", "AR-E6",
    "AR-SP4-GRAPH-ODD", "AR-SP4-GRAPH-EVEN", "AR-F4-GRAPH",
    "AR-G2-GRAPH-ODD", "AR-G2-GRAPH-EVEN",
]
EXPECTED_DIRECT = {
    "AR-PSL2-ODD": "defining-characteristic",
    "AR-ALTERNATING": "alternating-prime-interval",
}
EXPECTED_SPECIAL = {
    "AR-SP4-GRAPH-ODD":
        "if r|q+1 then r does not divide q^2+1 because their common divisor divides 2 and r>2",
    "AR-G2-GRAPH-ODD":
        "if r|q^3-1 then r does not divide q^3+1 because their common divisor divides 2 and r>2",
}
EXPECTED_SUBSTITUTES = {
    "SUB-PSL2-8", "SUB-PSL6-2-A", "SUB-PSL6-2-B",
    "SUB-D4-2-ORDINARY", "SUB-D4-2-TRIALITY", "SUB-SP4-8",
}
EXPECTED_FINITE = {"Z-PSU4-2", "Z-PSL3-4", "Z-SP6-2"}

LEAN_BRANCH_BY_ID = {
    "AR-PSL2-ODD": "psl2Odd", "AR-PSL2-EVEN": "psl2Even",
    "AR-ALTERNATING": "alternating", "AR-C-HIGHRANK": "cHigh",
    "AR-B-HIGHRANK": "bHigh", "AR-C2-ODD": "c2Odd",
    "AR-G2-NOGRAPH": "g2NoGraph", "AR-F4-NOGRAPH": "f4NoGraph",
    "AR-E7": "e7", "AR-E8": "e8", "AR-PSU-ODD": "psuOdd",
    "AR-PSU-EVEN": "psuEven", "AR-2D": "twistedD",
    "AR-3D4": "trialityTwisted", "AR-2E6": "twistedE6",
    "AR-2F4": "largeRee", "AR-PSU3": "psu3", "AR-SUZUKI": "suzuki",
    "AR-SMALL-REE": "smallRee", "AR-PSL-TRIVIAL": "pslTrivial",
    "AR-DPLUS": "dPlus", "AR-SP4-TRIVIAL": "sp4Trivial",
    "AR-F4-TRIVIAL": "f4Trivial", "AR-G2-TRIVIAL": "g2Trivial",
    "AR-PSL3-GRAPH": "psl3Graph", "AR-PSL4-GRAPH": "psl4Graph",
    "AR-PSLN-GRAPH": "pslnGraph", "AR-D4-TRIALITY": "d4Triality",
    "AR-E6": "e6", "AR-SP4-GRAPH-ODD": "sp4GraphOdd",
    "AR-SP4-GRAPH-EVEN": "sp4GraphEven", "AR-F4-GRAPH": "f4Graph",
    "AR-G2-GRAPH-ODD": "g2GraphOdd", "AR-G2-GRAPH-EVEN": "g2GraphEven",
}

TOP_FIELDS = {
    "schema_version", "scope", "affine_convention", "expected_branch_count",
    "branches", "substitute_certificates", "finite_exception_anchors",
}
COMMON_FIELDS = {
    "id", "theorem", "family", "proof_kind", "domain", "pair",
    "order_source_ids", "zsigmondy_invocation_id", "exception_ids",
}
PRIMITIVE_FIELDS = COMMON_FIELDS | {
    "primitive_exponent", "group_factor", "selected_factor_bound_sets",
    "outer", "exception_cases",
}


def die(message: str) -> NoReturn:
    raise SystemExit("HARD-FAIL: universal family arithmetic: " + message)


def load_json(path: Path) -> dict:
    try:
        obj = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        die(f"cannot load {path.relative_to(ROOT)}: {exc}")
    if not isinstance(obj, dict):
        die(f"{path.relative_to(ROOT)} is not a JSON object")
    return obj


def affine(expr: object, label: str) -> tuple[int, int]:
    if (not isinstance(expr, list) or len(expr) != 2
            or any(type(x) is not int for x in expr)):
        die(f"{label}: affine expression must be [integer,integer]")
    return expr[0], expr[1]


def at(expr: tuple[int, int], n: int) -> int:
    return expr[0] * n + expr[1]


def rank_data(domain: dict, label: str) -> tuple[str, int]:
    rank = domain.get("rank")
    if rank is None:
        return "none", 0
    if not isinstance(rank, dict) or set(rank) not in (
        {"fixed"}, {"variable", "min", "parity"}
    ):
        die(f"{label}: malformed rank domain")
    if "fixed" in rank:
        if type(rank["fixed"]) is not int or rank["fixed"] < 1:
            die(f"{label}: invalid fixed rank")
        return "fixed", rank["fixed"]
    if rank["variable"] != "n" or type(rank["min"]) is not int or rank["min"] < 1:
        die(f"{label}: invalid variable-rank domain")
    if rank["parity"] not in {"any", "odd", "even"}:
        die(f"{label}: invalid rank parity")
    return "variable", rank["min"]


def strict_affine_for_domain(
    lower: tuple[int, int], upper: tuple[int, int], domain: dict, label: str
) -> None:
    """Prove `(lower(n))*f < (upper(n))*f` for every admissible n,f.

    Since f>=1, cancellation reduces the statement to affine expressions in
    n.  A nonnegative difference slope and a positive left-endpoint value are
    an exact proof on the unbounded integer ray.  Fixed/no-rank cases are
    checked directly.
    """
    kind, n0 = rank_data(domain, label)
    if kind in {"none", "fixed"}:
        if not 0 < at(lower, n0) < at(upper, n0):
            die(f"{label}: exponent is nonpositive or not strictly below E")
        return
    da, db = upper[0] - lower[0], upper[1] - lower[1]
    if da < 0 or da * n0 + db <= 0 or at(lower, n0) <= 0:
        die(f"{label}: affine inequality is not proved for every n>={n0}")


def affine_equal(left: tuple[int, int], right: tuple[int, int], label: str) -> None:
    if left != right:
        die(f"{label}: affine identity mismatch {left!r}!={right!r}")


def min_exponent(expr: tuple[int, int], domain: dict, label: str) -> int:
    kind, n0 = rank_data(domain, label)
    if kind == "variable" and expr[0] < 0:
        die(f"{label}: primitive exponent decreases on an unbounded rank ray")
    value = at(expr, n0)
    fmin = domain.get("f_min")
    if type(fmin) is not int or fmin < 1:
        die(f"{label}: primitive branch has invalid f_min")
    return value * fmin


def prime_factors(n: int) -> set[int]:
    if type(n) is not int or n < 1:
        die(f"invalid positive integer factor {n!r}")
    ans: set[int] = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            ans.add(d)
            n //= d
        d += 1
    if n > 1:
        ans.add(n)
    return ans


def is_prime(n: int) -> bool:
    return n >= 2 and all(n % d for d in range(2, math.isqrt(n) + 1))


def vp(n: int, p: int) -> int:
    if n <= 0 or not is_prime(p):
        die("valuation input is not a positive integer/prime")
    out = 0
    while n % p == 0:
        n //= p
        out += 1
    return out


def parity_ok(value: int, parity: str) -> bool:
    return parity == "any" or (parity == "odd" and value % 2 == 1) or (
        parity == "even" and value % 2 == 0
    )


def characteristic_two_allowed(domain: dict, label: str) -> bool:
    mode = domain.get("p_mode")
    if mode in {"any", "selected-largest-prime"}:
        return mode == "any"
    if mode == "odd":
        return False
    if mode == "fixed":
        return domain.get("p") == 2
    if mode == "not":
        return domain.get("p") != 2
    die(f"{label}: invalid p_mode {mode!r}")


def solve_zsigmondy_equation(branch: dict) -> list[tuple[int | None, int]]:
    """Solve p=2 and E=6 exactly under the algebraic n/f domain.

    The q_min/simple-domain boundary is intentionally not applied: a solution
    just outside the uniform range must still be visibly routed (for example
    PSU(3,2), G2(2), and PSL(3,4) in graph Case B1).
    """
    domain = branch["domain"]
    if not characteristic_two_allowed(domain, branch["id"]):
        return []
    e = affine(branch["primitive_exponent"], branch["id"] + ": E")
    kind, n0 = rank_data(domain, branch["id"])
    if kind == "none":
        ns: list[int | None] = [None]
    elif kind == "fixed":
        ns = [n0]
    else:
        if e[0] <= 0:
            die(f"{branch['id']}: variable-rank exception equation is not finitely bounded")
        nmax = (6 - e[1]) // e[0]
        ns = list(range(n0, max(n0 - 1, nmax) + 1))
        parity = domain["rank"]["parity"]
        ns = [n for n in ns if parity_ok(int(n), parity)]
    out: list[tuple[int | None, int]] = []
    for n in ns:
        coefficient = at(e, 0 if n is None else n)
        if coefficient <= 0:
            die(f"{branch['id']}: nonpositive primitive coefficient")
        for f in range(domain["f_min"], 7):
            if not parity_ok(f, domain["f_parity"]):
                continue
            if coefficient * f == 6:
                out.append((n, f))
    return out


def validate_domain(domain: object, label: str) -> None:
    if not isinstance(domain, dict):
        die(f"{label}: domain is not an object")
    required = {"rank", "f_min", "f_parity", "p_mode", "q_min"}
    extra = set(domain) - (required | {"p"})
    if extra or not required <= set(domain):
        die(f"{label}: domain schema drift: missing={required-set(domain)}, extra={extra}")
    rank_data(domain, label)
    if domain["f_parity"] not in {None, "any", "odd", "even"}:
        die(f"{label}: invalid field-degree parity")
    if domain["q_min"] is not None and (
        type(domain["q_min"]) is not int or domain["q_min"] < 2
    ):
        die(f"{label}: invalid q_min")


def validate_primitive(branch: dict) -> list[dict]:
    bid = branch["id"]
    allowed = PRIMITIVE_FIELDS | {"central_divisor_exponents", "special_avoidance"}
    if set(branch) != allowed - ({"central_divisor_exponents"} if "central_divisor_exponents" not in branch else set()) - ({"special_avoidance"} if "special_avoidance" not in branch else set()):
        die(f"{bid}: primitive-branch schema drift")
    domain = branch["domain"]
    e = affine(branch["primitive_exponent"], bid + ": E")
    emin = min_exponent(e, domain, bid)
    if emin < 3:
        die(f"{bid}: Zsigmondy invocation can reach exponent below 3")

    group = branch["group_factor"]
    if not isinstance(group, dict) or set(group) != {"kind", "q_exponent", "minimum_valuation"}:
        die(f"{bid}: group-factor schema drift")
    qexp = affine(group["q_exponent"], bid + ": group factor")
    if group["kind"] in {"minus", "cyclotomic"}:
        affine_equal(e, qexp, bid + ": group occurrence")
    elif group["kind"] == "plus":
        affine_equal(e, (2 * qexp[0], 2 * qexp[1]), bid + ": plus-factor occurrence")
    else:
        die(f"{bid}: unknown group-factor kind")
    if type(group["minimum_valuation"]) is not int or group["minimum_valuation"] < 1:
        die(f"{bid}: invalid minimum group valuation")

    sets = branch["selected_factor_bound_sets"]
    if not isinstance(sets, list) or len(sets) < 2:
        die(f"{bid}: fewer than two source-derived subgroup factor sets")
    subgroup_names: set[str] = set()
    for index, record in enumerate(sets, 1):
        if not isinstance(record, dict) or set(record) != {"subgroup", "exponents", "constants"}:
            die(f"{bid}: selected subgroup factor-set schema drift")
        name = record["subgroup"]
        if not isinstance(name, str) or not name or name in subgroup_names:
            die(f"{bid}: empty/duplicate selected subgroup identifier")
        subgroup_names.add(name)
        if not isinstance(record["exponents"], list) or not record["exponents"]:
            die(f"{bid}: empty exponent-bound set for {name}")
        for j, raw in enumerate(record["exponents"], 1):
            strict_affine_for_domain(
                affine(raw, f"{bid}: subgroup {index} exponent {j}"), e, domain,
                f"{bid}: subgroup {index} exponent {j}",
            )
        if not isinstance(record["constants"], list):
            die(f"{bid}: subgroup constants are not a list")
        for constant in record["constants"]:
            if any(prime > emin for prime in prime_factors(constant)):
                die(f"{bid}: a fixed subgroup factor can contain primitive r")

    for index, raw in enumerate(branch.get("central_divisor_exponents", []), 1):
        strict_affine_for_domain(
            affine(raw, f"{bid}: central exponent {index}"), e, domain,
            f"{bid}: central exponent {index}",
        )

    special = branch.get("special_avoidance", [])
    if bid in EXPECTED_SPECIAL:
        if special != [EXPECTED_SPECIAL[bid]]:
            die(f"{bid}: special residue argument drift")
        if group["minimum_valuation"] < (2 if bid == "AR-SP4-GRAPH-ODD" else 1):
            die(f"{bid}: special branch lost its exact group valuation")
    elif special:
        die(f"{bid}: unexpected special avoidance rule")

    outer = branch["outer"]
    if not isinstance(outer, dict) or outer.get("kind") not in {"size-bound", "factorwise"}:
        die(f"{bid}: malformed outer-order rule")
    if outer["kind"] == "size-bound":
        if set(outer) != {"kind", "coefficient"} or type(outer["coefficient"]) is not int:
            die(f"{bid}: malformed outer size bound")
        # E(n) >= coefficient for all n; r>E*f then gives r>x.
        kind, n0 = rank_data(domain, bid)
        diff = (e[0], e[1] - outer["coefficient"])
        if (kind == "variable" and (diff[0] < 0 or at(diff, n0) < 0)) or (
            kind != "variable" and at(diff, n0) < 0
        ):
            die(f"{bid}: primitive exponent does not dominate outer size bound")
    else:
        if set(outer) != {"kind", "constant", "diagonal_exponents"}:
            die(f"{bid}: malformed factorwise outer rule")
        # r>E>=3 and r>f.  Its only remaining candidates are prime factors of
        # the fixed constant or of a diagonal factor, checked here.
        if any(prime > emin for prime in prime_factors(outer["constant"])):
            die(f"{bid}: fixed outer factor can contain primitive r")
        for index, raw in enumerate(outer["diagonal_exponents"], 1):
            strict_affine_for_domain(
                affine(raw, f"{bid}: outer diagonal exponent {index}"), e,
                domain, f"{bid}: outer diagonal exponent {index}",
            )

    solved = solve_zsigmondy_equation(branch)
    declared = branch["exception_cases"]
    if not isinstance(declared, list):
        die(f"{bid}: exception_cases is not a list")
    keys: list[tuple[int | None, int]] = []
    for case in declared:
        if not isinstance(case, dict) or set(case) != {"p", "f", "n", "ids", "route"}:
            die(f"{bid}: exception-case schema drift")
        if case["p"] != 2 or not isinstance(case["ids"], list) or not case["ids"]:
            die(f"{bid}: malformed Zsigmondy exception route")
        if case["route"] not in {"substitute", "finite", "finite-alias", "finite-boundary", "boundary"}:
            die(f"{bid}: unknown exception route")
        keys.append((case["n"], case["f"]))
    if len(keys) != len(set(keys)) or sorted(keys, key=str) != sorted(solved, key=str):
        die(f"{bid}: exhaustive equation solutions {solved!r} != declared {keys!r}")
    return declared


def validate_direct(branch: dict) -> None:
    bid = branch["id"]
    if branch["proof_kind"] == "defining-characteristic":
        expected = COMMON_FIELDS | {"obstruction"}
        if set(branch) != expected:
            die(f"{bid}: defining-characteristic schema drift")
        exact = {
            "prime": "p", "group_valuation": "f", "subgroup_valuations": [0, 0],
            "outer_divisor": "2f", "universal_fact": "v_p(f)<f for f>0",
        }
        if branch["obstruction"] != exact:
            die(f"{bid}: defining-characteristic argument drift")
        d = branch["domain"]
        if d != {"rank": None, "f_min": 1, "f_parity": "any", "p_mode": "odd", "q_min": 13}:
            die(f"{bid}: exact uniform domain drift")
    elif branch["proof_kind"] == "alternating-prime-interval":
        expected = COMMON_FIELDS | {"obstruction", "large_range", "finite_range"}
        if set(branch) != expected:
            die(f"{bid}: alternating schema drift")
        finite = branch["finite_range"]
        if set(finite) != {"n_min", "n_max", "largest_primes"} or (
            finite["n_min"], finite["n_max"]
        ) != (15, 30) or len(finite["largest_primes"]) != 16:
            die("alternating finite interval drift")
        for n, p in zip(range(15, 31), finite["largest_primes"]):
            if not is_prime(p) or p > n or any(is_prime(k) for k in range(p + 1, n + 1)):
                die(f"alternating n={n}: recorded p is not the largest prime <=n")
            if 2 * p < n + 6 or not n < 2 * p:
                die(f"alternating n={n}: prime does not give two classes/Bertrand range")
            # n < 2p <= 2n implies v_p(n!)=1 exactly.
            if sum(n // (p ** k) for k in range(1, 8) if p ** k <= n) != 1:
                die(f"alternating n={n}: factorial valuation is not exactly one")
        large = branch["large_range"]
        if large != {"n_min": 31, "source": "Nagura", "inequality": "5n/6<p<=n"}:
            die("alternating large-range statement drift")
        # Symbolic linear certificate: 6p>5n and n>=31 imply
        # 12p>10n>=6n+36, hence 2p>=n+7 and in particular 2p>=n+6.
        if 4 * large["n_min"] - 36 <= 0:
            die("Nagura inequality no longer implies the two-class bound")
        if branch["obstruction"] != {
            "prime_condition": "n/2<p<=n", "group_valuation": 1,
            "subgroup_valuations": [0, 0], "outer_divisor": 2,
            "class_count_condition": "p>=n/2+3",
        }:
            die("alternating valuation/class-count specification drift")
    else:
        die(f"{bid}: unknown direct proof kind")


def validate_substitutes(manifest: dict, exception_records: dict[str, dict]) -> None:
    records = manifest["substitute_certificates"]
    if not isinstance(records, list) or {r.get("id") for r in records} != EXPECTED_SUBSTITUTES:
        die("substitute-certificate inventory drift")
    seen_pairs: set[tuple[str, str]] = set()
    for record in records:
        if set(record) != {
            "id", "exception_id", "branch_ids", "prime", "group_order",
            "subgroup_orders", "outer_multiple", "required_gap",
        }:
            die(f"{record.get('id')}: substitute schema drift")
        r = record["prime"]
        if not is_prime(r):
            die(f"{record['id']}: obstruction is not prime")
        if len(record["subgroup_orders"]) != 2:
            die(f"{record['id']}: substitute does not identify exactly two subgroup orders")
        gap = vp(record["group_order"], r) - sum(vp(x, r) for x in record["subgroup_orders"])
        if gap <= vp(record["outer_multiple"], r) or gap <= record["required_gap"]:
            die(f"{record['id']}: exact substitute valuation inequality fails")
        exid = record["exception_id"]
        if exid not in exception_records or exception_records[exid]["destination"] != "ARITH-SUBSTITUTE-PRIMES":
            die(f"{record['id']}: substitute destination is not exact")
        for bid in record["branch_ids"]:
            key = (exid, bid)
            if key in seen_pairs:
                die(f"duplicate substitute coverage for {key}")
            seen_pairs.add(key)
    required = {
        (case_id, branch["id"])
        for branch in manifest["branches"]
        if branch["proof_kind"] == "primitive-exponent"
        for case in branch["exception_cases"] if case["route"] == "substitute"
        for case_id in case["ids"] if exception_records[case_id]["kind"] == "Zsigmondy"
    }
    if seen_pairs != required:
        die(f"substitute coverage mismatch: missing={sorted(required-seen_pairs)}, extra={sorted(seen_pairs-required)}")


def validate_finite_anchors(manifest: dict, exception_records: dict[str, dict]) -> None:
    anchors = manifest["finite_exception_anchors"]
    if not isinstance(anchors, list) or {a.get("exception_id") for a in anchors} != EXPECTED_FINITE:
        die("finite arithmetic-exception anchor inventory drift")
    for anchor in anchors:
        if set(anchor) != {
            "exception_id", "alias_exception_id", "group", "order",
            "certificate", "expected_xcases", "terminal",
        }:
            die(f"{anchor.get('exception_id')}: finite anchor schema drift")
        exid = anchor["exception_id"]
        if exception_records.get(exid, {}).get("destination") != "COMP-FINITE-BASE":
            die(f"{exid}: finite anchor destination drift")
        alias = anchor["alias_exception_id"]
        if alias is not None and exception_records.get(alias, {}).get("destination") != "COMP-FINITE-BASE":
            die(f"{exid}: finite alias destination drift")
        path = ROOT / anchor["certificate"]
        if not path.is_file():
            die(f"{exid}: missing certificate {anchor['certificate']}")
        text = path.read_text()
        group = re.escape(anchor["group"])
        if not re.search(rf"^SOCLE\|group={group}\|order={anchor['order']}\|.*\|simple=true$", text, re.M):
            die(f"{exid}: exact simple-socle anchor absent")
        xcases = re.findall(rf"^XCASE\|group={group}\|.*\|result=EXCLUDED$", text, re.M)
        certs = re.findall(rf"^CERT\|[^\n]*\|group={group}\|[^\n]*\|result=PASS$", text, re.M)
        # The older novelty certificate predates the explicit XCASE record,
        # but its CERT records carry the same contiguous exact xclass field.
        # Accept that representation only when there are no XCASE lines and
        # the certificate inventory is exactly 1..expected_xcases.
        cert_classes = sorted(int(x) for x in re.findall(
            rf"^CERT\|[^\n]*\|group={group}\|[^\n]*\|xclass=(\d+)\|[^\n]*\|result=PASS$",
            text, re.M,
        ))
        xcase_ok = len(xcases) == anchor["expected_xcases"] or (
            not xcases and cert_classes == list(range(1, anchor["expected_xcases"] + 1))
        )
        if not xcase_ok or len(certs) != anchor["expected_xcases"]:
            die(f"{exid}: expected {anchor['expected_xcases']} exact X cases/certificates, got {len(xcases)}/{len(certs)}")
        if anchor["terminal"] not in text:
            die(f"{exid}: finite certificate lacks its terminal exclusion/PASS anchor")


def generated_view(manifest: dict, exception_records: dict[str, dict]) -> dict:
    case_rows = []
    for branch in manifest["branches"]:
        for case in branch.get("exception_cases", []):
            case_rows.append({
                "branch_id": branch["id"], "p": case["p"], "f": case["f"],
                "n": case["n"], "exception_ids": case["ids"], "route": case["route"],
            })
    zsig_ids = sorted({
        exid for row in case_rows for exid in row["exception_ids"]
        if exception_records[exid]["kind"] == "Zsigmondy"
    })
    boundary_ids = sorted({
        exid for row in case_rows for exid in row["exception_ids"]
        if exception_records[exid]["kind"] != "Zsigmondy"
    })
    return {
        "schema_version": 1,
        "generator": "computations/independent/family_arithmetic_universal.py",
        "branch_count": len(manifest["branches"]),
        "primitive_branch_count": sum(b["proof_kind"] == "primitive-exponent" for b in manifest["branches"]),
        "zsigmondy_equation": {"base": 2, "exponent": 6},
        "exception_cases": case_rows,
        "zsigmondy_exception_ids": zsig_ids,
        "non_zsigmondy_boundary_ids": boundary_ids,
        "substitute_certificate_ids": sorted(r["id"] for r in manifest["substitute_certificates"]),
        "finite_certificate_exception_ids": sorted(a["exception_id"] for a in manifest["finite_exception_anchors"]),
    }


def validate_lean_mirror(manifest: dict) -> None:
    """Bind the kernel-checked finite certificate lists to the JSON manifest.

    Lean proves every member of its explicit lists, while this fail-closed
    comparison proves that those lists are exactly the source-bound branch
    obligations (including multiplicity).  This prevents an omitted bound or
    a transcribed exponent from being hidden behind two separately passing
    tools.
    """
    path = ROOT / "formal/Kourovka1034/FamilyArithmetic.lean"
    if not path.is_file():
        die("missing formal arithmetic mirror")
    source = path.read_text()
    if set(LEAN_BRANCH_BY_ID) != set(EXPECTED_BRANCH_IDS):
        die("Lean/manifest branch-name map drift")

    def block(start: str, end: str) -> str:
        if source.count(start) != 1 or source.count(end) != 1:
            die(f"formal list marker drift: {start!r}/{end!r}")
        return source.split(start, 1)[1].split(end, 1)[0]

    bound_pattern = re.compile(
        r"⟨\.(\w+),\s*⟨(-?\d+),\s*(-?\d+)⟩,\s*"
        r"⟨(-?\d+),\s*(-?\d+)⟩,\s*(\d+)⟩"
    )
    actual_bounds = Counter(
        (name, (int(la), int(lb)), (int(ua), int(ub)), int(n0))
        for name, la, lb, ua, ub, n0 in bound_pattern.findall(
            block("def branchBounds", "theorem exact_bound_inventory")
        )
    )
    expected_bounds: Counter = Counter()
    expected_occurrences: Counter = Counter()
    expected_fixed: set[tuple[int, int]] = set()
    expected_exceptions: list[tuple[str, int, int]] = []
    for branch in manifest["branches"]:
        if branch["proof_kind"] != "primitive-exponent":
            continue
        bid = branch["id"]
        lean_name = LEAN_BRANCH_BY_ID[bid]
        domain = branch["domain"]
        _, n0 = rank_data(domain, bid)
        upper = affine(branch["primitive_exponent"], bid + ": E")
        lowers = [
            affine(raw, bid + ": selected formal mirror")
            for record in branch["selected_factor_bound_sets"]
            for raw in record["exponents"]
        ]
        lowers += [
            affine(raw, bid + ": central formal mirror")
            for raw in branch.get("central_divisor_exponents", [])
        ]
        lowers += [
            affine(raw, bid + ": outer formal mirror")
            for raw in branch["outer"].get("diagonal_exponents", [])
        ]
        expected_bounds.update((lean_name, low, upper, n0) for low in lowers)

        qexp = affine(branch["group_factor"]["q_exponent"], bid + ": group mirror")
        multiplier = 2 if branch["group_factor"]["kind"] == "plus" else 1
        expected_occurrences.update([(lean_name, upper, qexp, multiplier)])

        emin = min_exponent(upper, domain, bid)
        for record in branch["selected_factor_bound_sets"]:
            expected_fixed.update((emin, value) for value in record["constants"])
        if branch["outer"]["kind"] == "factorwise":
            expected_fixed.add((emin, branch["outer"]["constant"]))

        expected_exceptions.extend(
            (lean_name, 0 if case["n"] is None else case["n"], case["f"])
            for case in branch["exception_cases"]
        )
    if actual_bounds != expected_bounds or sum(actual_bounds.values()) != 107:
        die(
            "formal/manifest bound mirror mismatch: "
            f"missing={list((expected_bounds-actual_bounds).elements())[:4]}, "
            f"extra={list((actual_bounds-expected_bounds).elements())[:4]}"
        )

    occurrence_pattern = re.compile(
        r"⟨\.(\w+),\s*⟨(-?\d+),\s*(-?\d+)⟩,\s*"
        r"⟨(-?\d+),\s*(-?\d+)⟩,\s*(-?\d+)⟩"
    )
    actual_occurrences = Counter(
        (name, (int(pa), int(pb)), (int(qa), int(qb)), int(mult))
        for name, pa, pb, qa, qb, mult in occurrence_pattern.findall(
            block("def groupOccurrences", "theorem exact_occurrence_inventory")
        )
    )
    if actual_occurrences != expected_occurrences or sum(actual_occurrences.values()) != 32:
        die("formal/manifest group-occurrence mirror mismatch")

    fixed_pattern = re.compile(r"⟨(\d+),\s*(\d+)⟩")
    actual_fixed = {
        (int(e), int(c)) for e, c in fixed_pattern.findall(
            block("def constantCertificates", "theorem exact_fixed_factor_inventory")
        )
    }
    if actual_fixed != expected_fixed or len(actual_fixed) != 18:
        die(f"formal/manifest fixed-factor mirror mismatch: {actual_fixed ^ expected_fixed}")

    exception_pattern = re.compile(r"\((\w+),\s*(\d+),\s*(\d+)\)")
    actual_exceptions = [
        (name, int(n), int(f)) for name, n, f in exception_pattern.findall(
            block("def zsigmondyExceptionPoints", "theorem primitive_exponent_positive")
        )
    ]
    if Counter(actual_exceptions) != Counter(expected_exceptions) or len(actual_exceptions) != 12:
        die("formal/manifest Zsigmondy-exception mirror mismatch")


def validate_independent_symbolic_mirror(manifest: dict) -> None:
    """Mechanically compare the separately authored, manifest-free model.

    Importing the module here does not alter its independence: its default
    verifier never reads repository data, and all 34 branches remain literal
    data/code in that file.  This comparison merely makes disagreement between
    the two paths fatal instead of relying on a reviewer to compare summaries.
    """
    try:
        import family_arithmetic_symbolic as symbolic
    except (ImportError, AttributeError) as exc:
        die(f"cannot import independent symbolic model: {exc}")
    by_id = {case.key: case for case in symbolic.CASES}
    primitive = [b for b in manifest["branches"] if b["proof_kind"] == "primitive-exponent"]
    if list(by_id) != [b["id"] for b in primitive] or len(by_id) != 32:
        die("independent symbolic branch order/inventory mismatch")

    def lin(value: object) -> tuple[int, int]:
        return value.a, value.b

    for branch in primitive:
        bid = branch["id"]
        case = by_id[bid]
        domain = branch["domain"]
        rank = domain["rank"]
        if rank is None:
            n_kind, n0, n_parity = "none", 0, "any"
        elif "fixed" in rank:
            n_kind, n0, n_parity = "fixed", rank["fixed"], "any"
        else:
            n_kind, n0, n_parity = "variable", rank["min"], rank["parity"]
        expected_selected = tuple(
            tuple(tuple(raw) for raw in record["exponents"])
            for record in branch["selected_factor_bound_sets"]
        )
        expected_constants = tuple(
            tuple(record["constants"]) for record in branch["selected_factor_bound_sets"]
        )
        outer = branch["outer"]
        expected_outer_kind = "size" if outer["kind"] == "size-bound" else "factor"
        expected_outer_constant = (
            outer["coefficient"] if outer["kind"] == "size-bound" else outer["constant"]
        )
        expected_diagonal = tuple(tuple(x) for x in outer.get("diagonal_exponents", []))
        expected_central = tuple(tuple(x) for x in branch.get("central_divisor_exponents", []))
        expected_exception_points = tuple(
            (case_record["n"], case_record["f"])
            for case_record in branch["exception_cases"]
        )
        checks = {
            "rank domain": (case.n_kind, case.n0, case.n_parity) == (n_kind, n0, n_parity),
            "field domain": (case.f0, case.f_parity) == (domain["f_min"], domain["f_parity"]),
            "characteristic-two domain": case.characteristic_two_allowed == characteristic_two_allowed(domain, bid),
            "primitive exponent": lin(case.exponent) == tuple(branch["primitive_exponent"]),
            "group factor kind": case.group_kind == branch["group_factor"]["kind"],
            "group q-exponent": lin(case.group_q_exponent) == tuple(branch["group_factor"]["q_exponent"]),
            "selected exponents": tuple(tuple(lin(x) for x in xs) for xs in case.selected) == expected_selected,
            "selected constants": case.selected_constants == expected_constants,
            "outer kind": case.outer_kind == expected_outer_kind,
            "outer fixed/size factor": case.outer_constant == expected_outer_constant,
            "outer diagonal exponents": tuple(lin(x) for x in case.diagonal) == expected_diagonal,
            "central-divisor exponents": tuple(lin(x) for x in case.central) == expected_central,
            "exception equation solutions": case.exception_points == expected_exception_points,
        }
        failed = [name for name, passed in checks.items() if not passed]
        if failed:
            die(f"{bid}: independent symbolic mismatch: {', '.join(failed)}")

    direct_by_id = {b["id"]: b for b in manifest["branches"] if b["proof_kind"] != "primitive-exponent"}
    if set(direct_by_id) != set(symbolic.DIRECT_SPECS):
        die("independent direct-branch inventory mismatch")
    for bid, spec in symbolic.DIRECT_SPECS.items():
        branch = direct_by_id[bid]
        for field, value in spec.items():
            if branch.get(field) != value:
                die(f"{bid}: independent direct-branch {field} mismatch")

    symbolic_substitutes = list(symbolic.substitute_valuations())
    if symbolic_substitutes != manifest["substitute_certificates"]:
        die("independently evaluated substitute-certificate records mismatch")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-exception-view", action="store_true")
    args = parser.parse_args()

    manifest = load_json(MANIFEST)
    if set(manifest) != TOP_FIELDS or manifest.get("schema_version") != 1:
        die("top-level manifest schema drift")
    branches = manifest["branches"]
    if not isinstance(branches, list) or manifest["expected_branch_count"] != 34:
        die("branch-count declaration drift")
    ids = [b.get("id") for b in branches]
    if ids != EXPECTED_BRANCH_IDS or len(ids) != len(set(ids)):
        die("exact ordered 34-branch inventory drift")

    order_rows = {}
    with (AUDIT / "ORDER-FORMULA-SOURCE-MAP.csv").open(newline="") as f:
        for row in csv.DictReader(f):
            order_rows[row["claim_id"]] = row
    zsig_rows = {}
    with (AUDIT / "ZSIGMONDY-INVOCATIONS.csv").open(newline="") as f:
        for row in csv.DictReader(f):
            zsig_rows[row["invocation_id"]] = row
    exc_obj = load_json(AUDIT / "EXCEPTION-MANIFEST.json")
    exception_records = {row["id"]: row for row in exc_obj["exceptions"]}

    all_declared_cases: list[dict] = []
    used_zsig: list[str] = []
    for branch in branches:
        bid = branch["id"]
        if branch.get("proof_kind") != "primitive-exponent":
            if EXPECTED_DIRECT.get(bid) != branch.get("proof_kind"):
                die(f"{bid}: unexpected nonprimitive branch")
            validate_domain(branch["domain"], bid)
            validate_direct(branch)
        else:
            validate_domain(branch["domain"], bid)
            all_declared_cases.extend(validate_primitive(branch))
            zid = branch["zsigmondy_invocation_id"]
            if zid not in zsig_rows:
                die(f"{bid}: unknown Zsigmondy invocation {zid!r}")
            used_zsig.append(zid)
        if (not isinstance(branch["order_source_ids"], list)
                or not branch["order_source_ids"]):
            die(f"{bid}: no exact order-formula assumptions")
        for source_id in branch["order_source_ids"]:
            if source_id not in order_rows or order_rows[source_id]["status"] != "CITED-PASS":
                die(f"{bid}: missing/nonpassing order source {source_id}")
        for exid in branch["exception_ids"]:
            if exid not in exception_records:
                die(f"{bid}: unknown exception id {exid}")

    if set(used_zsig) != set(zsig_rows) or len(used_zsig) != 32:
        die("Zsigmondy invocation coverage drift (31 source rows, one shared by B/C)")
    # Invocation rows and branch equation solutions must name the same theorem
    # exceptions.  Alias IDs are excluded because they are routing facts, not
    # exceptions to Zsigmondy's theorem itself.
    for zid, row in zsig_rows.items():
        mapped = {
            exid
            for branch in branches if branch.get("zsigmondy_invocation_id") == zid
            for case in branch.get("exception_cases", []) for exid in case["ids"]
            if exid in exception_records and exception_records[exid]["kind"] != "exceptional isomorphism"
        }
        stated = {x for x in row["exception_ids"].split(";") if x}
        if mapped != stated:
            die(f"{zid}: invocation/branch exception mismatch {sorted(mapped)} != {sorted(stated)}")

    all_zsig = {x["id"] for x in exception_records.values() if x["kind"] == "Zsigmondy"}
    routed_zsig = {
        exid for case in all_declared_cases for exid in case["ids"]
        if exception_records[exid]["kind"] == "Zsigmondy"
    }
    if routed_zsig != all_zsig or len(all_zsig) != 7:
        die(f"main exception manifest/Zsigmondy branch mismatch: {sorted(routed_zsig)} != {sorted(all_zsig)}")

    validate_substitutes(manifest, exception_records)
    validate_finite_anchors(manifest, exception_records)
    validate_lean_mirror(manifest)
    validate_independent_symbolic_mirror(manifest)
    view = generated_view(manifest, exception_records)
    rendered = json.dumps(view, indent=2) + "\n"
    if args.write_exception_view:
        GENERATED.write_text(rendered)
        print(f"ARITHMETIC EXCEPTION VIEW|WROTE|cases={len(view['exception_cases'])}")
    else:
        if not GENERATED.is_file() or GENERATED.read_text() != rendered:
            die("generated arithmetic exception view is missing or stale; run --write-exception-view")

    print(f"exact arithmetic branches: {len(branches)}")
    print(f"primitive branches: {sum(b['proof_kind']=='primitive-exponent' for b in branches)}")
    print(f"Zsigmondy invocation rows covered: {len(set(used_zsig))} (B/C shared)")
    print(f"exhaustive (2,6) parameter routes: {len(view['exception_cases'])}")
    print(f"substitute valuations: {len(manifest['substitute_certificates'])}")
    print(f"finite exception anchors: {len(manifest['finite_exception_anchors'])}")
    print("formal manifest mirror: 107 bounds, 32 occurrences, 18 fixed factors, 12 exceptions")
    print("manifest-independent symbolic mirror: exact branch/formula/substitute equality")
    print("UNIVERSAL FAMILY ARITHMETIC MANIFEST|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, ValueError, TypeError) as exc:
        die(str(exc))
