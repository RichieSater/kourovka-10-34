#!/usr/bin/env python3
"""Fail-closed structural/source audit for the high-risk Lie-type inputs.

The source ledger is hand-authored.  This checker enforces its closed-row schema,
checks that the manuscript actually cites each pinned source, and independently
derives the four ^2E6 maximal-parabolic Levi types from the E6 graph and its
order-two symmetry.  It does not prove the cited classification theorems.
"""
from __future__ import annotations

import csv
import os
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[2]
)).resolve()
AUDIT = ROOT / "audit"
PAPER = ROOT / "paper" / "kourovka1034.tex"
MAP = AUDIT / "LIE-SOURCE-MAP.csv"

FIELDS = ["claim_id", "manuscript_location", "families", "claim",
          "primary_source", "pinpoint", "independent_corroboration", "status"]
REQUIRED = {
    "LIE-BN-TWISTED", "LIE-AUT-GENERAL", "LIE-AUT-TWISTED", "LIE-AUT-D4",
    "LIE-AUT-EXCEPTIONAL", "LIE-FIXED-SUBGROUPS", "LIE-2E6-LEVI",
}
EXPECTED_SOURCES = {
    "LIE-BN-TWISTED": ("Hiss2011", "Example 1.16 and Section 1.3.5, pp. 10--11"),
    "LIE-AUT-GENERAL": ("BrotoMollerOliver2019", "Definition 3.3 and Theorem 3.4, p. 32"),
    "LIE-AUT-TWISTED": ("BrotoMollerOliver2019", "Definition 3.3(c) and Theorem 3.4, p. 32"),
    "LIE-AUT-D4": ("BrotoMollerOliver2019", "Definition 3.1(b), p. 31; Lemma 3.2, p. 32"),
    "LIE-AUT-EXCEPTIONAL": ("BrotoMollerOliver2019", "Definition 3.1(b), p. 31 (the square relation follows directly from its displayed root-group formula)"),
    "LIE-FIXED-SUBGROUPS": ("BrotoMollerOliver2019", "Definition 3.1(b)--(c), p. 31, followed by the parity calculation"),
    "LIE-2E6-LEVI": ("Montinaro2024", "Lemma 6.8 proof, journal p. 82"),
}
REQUIRED_TEX = {
    r"\cite[Thms.~8.3.2--8.3.3, p.~112]{Carter}",
    r"\cite[Example~1.16 and \S1.3.5, pp.~10--11]{Hiss2011}",
    r"\cite[Def.~3.3 and Thm.~3.4, p.~32]{BrotoMollerOliver2019}",
    r"\cite[Lemma~6.8, p.~82]{Montinaro2024}",
}


def die(msg: str) -> "NoReturn":
    raise SystemExit("HARD-FAIL: " + msg)


def components(nodes: set[int], edges: set[frozenset[int]]) -> list[frozenset[int]]:
    todo = set(nodes)
    out = []
    while todo:
        stack = [min(todo)]
        comp = set()
        while stack:
            v = stack.pop()
            if v in comp:
                continue
            comp.add(v)
            todo.discard(v)
            stack.extend(w for e in edges if v in e for w in e if w != v and w in nodes)
        out.append(frozenset(comp))
    return sorted(out, key=lambda c: (len(c), tuple(c)))


def dynkin_type(comp: frozenset[int], edges: set[frozenset[int]]) -> str:
    degrees = sorted(sum(1 for e in edges if v in e and e <= comp) for v in comp)
    n = len(comp)
    if n == 1 and degrees == [0]:
        return "A1"
    if n >= 2 and degrees == ([1, 1] if n == 2 else [1, 1] + [2] * (n - 2)):
        return f"A{n}"
    if n == 4 and degrees == [1, 1, 1, 3]:
        return "D4"
    die(f"unrecognized induced component {sorted(comp)} with degrees {degrees}")


def derive_2e6() -> dict[tuple[int, ...], tuple[tuple[str, ...], int]]:
    nodes = set(range(1, 7))
    edges = {frozenset(e) for e in [(1, 3), (3, 4), (4, 5), (5, 6), (2, 4)]}
    tau = {1: 6, 6: 1, 3: 5, 5: 3, 2: 2, 4: 4}
    deletion_orbits = []
    unseen = set(nodes)
    while unseen:
        v = min(unseen)
        orb = frozenset({v, tau[v]})
        deletion_orbits.append(orb)
        unseen -= orb

    result = {}
    for deleted in sorted(deletion_orbits, key=lambda o: tuple(o)):
        keep = nodes - set(deleted)
        comps = components(keep, edges)
        if any(frozenset(tau[v] for v in c) not in comps for c in comps):
            die(f"deletion orbit {sorted(deleted)} does not leave a tau-stable diagram")
        done: set[frozenset[int]] = set()
        factors: list[str] = []
        exponents: list[int] = []
        for comp in comps:
            if comp in done:
                continue
            image = frozenset(tau[v] for v in comp)
            typ = dynkin_type(comp, edges)
            if image != comp:
                if dynkin_type(image, edges) != typ:
                    die("tau swaps nonisomorphic components")
                factors.append(f"{typ}(q^2)")
                # A_m(q^2) has factors through (q^2)^(m+1)-1.
                rank = int(typ[1:])
                exponents.append(2 * (rank + 1))
                done.update({comp, image})
                continue
            moved = any(tau[v] != v for v in comp)
            if not moved:
                factors.append(f"{typ}(q)")
                rank = int(typ[1:])
                exponents.append(rank + 1)
            elif typ == "A5":
                factors.append("2A5(q)")
                # SU_6(q): the q^5+1 factor has primitive exponent 10.
                exponents.append(10)
            elif typ == "D4":
                factors.append("2D4(q)")
                # Minus D4 has q^4+1, of primitive exponent 8.
                exponents.append(8)
            else:
                die(f"unexpected nontrivial fixed-component twist {typ}")
            done.add(comp)
        result[tuple(sorted(deleted))] = (tuple(sorted(factors)), max(exponents))
    return result


def main() -> int:
    with MAP.open(newline="") as f:
        rd = csv.DictReader(f)
        if rd.fieldnames != FIELDS:
            die(f"Lie source-map columns drift: {rd.fieldnames!r}")
        rows = list(rd)
    ids = [row["claim_id"] for row in rows]
    if set(ids) != REQUIRED or len(ids) != len(set(ids)):
        die(f"Lie source-map IDs mismatch: {sorted(ids)}")
    for row in rows:
        if row["status"] != "CITED-PASS":
            die(f"{row['claim_id']}: non-passing status")
        if any(not row[field].strip() for field in FIELDS[:-1]):
            die(f"{row['claim_id']}: empty source-map field")
        actual_source = (row["primary_source"], row["pinpoint"])
        if actual_source != EXPECTED_SOURCES[row["claim_id"]]:
            die(f"{row['claim_id']}: source/pinpoint drift: {actual_source!r}")

    tex = PAPER.read_text()
    missing = sorted(token for token in REQUIRED_TEX if token not in tex)
    if missing:
        die(f"manuscript missing pinned citations: {missing}")

    expected = {
        (2,): (("2A5(q)",), 10),
        (4,): (("A1(q)", "A2(q^2)"), 6),
        (1, 6): (("2D4(q)",), 8),
        (3, 5): (("A1(q^2)", "A2(q)"), 4),
    }
    got = derive_2e6()
    if got != expected:
        die(f"^2E6 Levi derivation mismatch: got={got!r}, expected={expected!r}")

    print(f"exact high-risk Lie source rows: {len(rows)}")
    for deleted in sorted(got):
        factors, exponent = got[deleted]
        print(f"2E6|deleted={deleted}|factors={'+'.join(factors)}|max_exponent={exponent}|PASS")
    print("LIE SOURCE AND 2E6 LEVI VERIFICATION|PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error) as exc:
        die(str(exc))
