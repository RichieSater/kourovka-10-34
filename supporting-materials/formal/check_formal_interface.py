#!/usr/bin/env python3
"""Fail-closed theorem-signature audit for the Rocq/Lean RED-COORD seam."""
from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(os.environ.get("KOUROVKA_FORMAL_ROOT", Path(__file__).resolve().parent)).resolve()
SUPPORT = ROOT.parent


def die(message: str) -> None:
    raise SystemExit("FORMAL PROVER INTERFACE|FAIL|" + message)


def code_only_lean(text: str) -> str:
    out: list[str] = []
    i = 0
    depth = 0
    in_string = False
    while i < len(text):
        if depth:
            if text.startswith("/-", i):
                depth += 1
                i += 2
            elif text.startswith("-/", i):
                depth -= 1
                i += 2
            else:
                i += 1
        elif in_string:
            if text[i] == "\\":
                i += 2
            elif text[i] == '"':
                in_string = False
                i += 1
            else:
                i += 1
        elif text.startswith("/-", i):
            depth = 1
            i += 2
        elif text.startswith("--", i):
            end = text.find("\n", i)
            i = len(text) if end < 0 else end
        elif text[i] == '"':
            in_string = True
            i += 1
        else:
            out.append(text[i])
            i += 1
    if depth or in_string:
        die("unterminated Lean comment or string")
    return "".join(out)


def main() -> None:
    manifest_path = ROOT / "FORMAL-INTERFACE.json"
    data = json.loads(manifest_path.read_text())
    if set(data) != {
        "schema_version", "claim_id", "producer", "reindex", "consumer",
        "definition_correspondence", "composition", "checker",
    }:
        die("top-level schema drift")
    if data["schema_version"] != 1 or data["claim_id"] != "RED-COORD":
        die("version or claim drift")
    if data["checker"] != "check_formal_interface.py":
        die("checker self-reference drift")
    if len(data["definition_correspondence"]) != 4:
        die("definition-correspondence inventory drift")

    producer = data["producer"]
    reindex = data["reindex"]
    consumer = data["consumer"]
    expected_producer_keys = {
        "proof_assistant", "library", "coverage_manifest", "file", "theorem",
        "output", "factor_properties", "factor_index", "factor_count",
        "positive_count", "exact_order",
    }
    if set(producer) != expected_producer_keys:
        die("producer schema drift")
    if set(reindex) != {
        "proof_assistant", "library", "coverage_manifest", "file", "theorem",
        "input", "output",
    }:
        die("reindex schema drift")
    if set(consumer) != {
        "proof_assistant", "library", "coverage_manifest", "file", "theorem",
        "input",
    }:
        die("consumer schema drift")
    expected_producer = {
        "proof_assistant": "The Rocq Prover 9.2",
        "library": "MathComp 2.6.0",
        "coverage_manifest": "../formal-rocq/FORMAL-COVERAGE.json",
        "file": "../formal-rocq/CharacteristicallySimple.v",
        "theorem": "nonsolvable_charsimple_explicit_power",
        "output": r"G \isog setXn (fun _ : {f | f \in I} => H)",
        "factor_properties": r"H \subset G; simple H; ~~ solvable H; ~~ abelian H",
        "factor_index": r"{f | f \in I}",
        "factor_count": "#|I|",
        "positive_count": "0 < #|I|",
        "exact_order": "#|G| = #|H| ^ #|I|",
    }
    expected_reindex = {
        "proof_assistant": "Lean 4.32.2",
        "library": "mathlib 905b95818eb32af7874a58b427f50c1711a5e96c",
        "coverage_manifest": "FORMAL-COVERAGE.json",
        "file": "Kourovka1034/DirectPower.lean",
        "theorem": "Kourovka1034.DirectPower.explicitPowerEquivFin_with_base",
        "input": "[Nonempty I]; e : N ≃* (I → S)",
        "output": (
            "Nonempty (Fin (Nat.card I)) ∧ "
            "Nonempty (N ≃* (Fin (Nat.card I) → S))"
        ),
    }
    expected_consumer = {
        "proof_assistant": "Lean 4.32.2",
        "library": "mathlib 905b95818eb32af7874a58b427f50c1711a5e96c",
        "coverage_manifest": "FORMAL-COVERAGE.json",
        "file": "Kourovka1034/AmbientWreath.lean",
        "theorem": "Kourovka1034.AmbientWreath.ambient_coordinate_realization_and_bound",
        "input": "e : N ≃* (Fin k → S)",
    }
    if producer != expected_producer:
        die("producer values drift")
    if reindex != expected_reindex:
        die("reindex values drift")
    if consumer != expected_consumer:
        die("consumer values drift")
    expected_correspondence = [
        {
            "rocq": r"G \isog L",
            "lean": "Nonempty (G ≃* L)",
            "justification": (
                "MathComp isogP expands isog to an injective group morphism "
                "whose image is exactly L; restricting the map and inverse "
                "to the subgroup carriers is exactly existence of a group "
                "equivalence between the subgroup types."
            ),
        },
        {
            "rocq": "setXn (fun _ : J => H)",
            "lean": "J → H",
            "justification": (
                "MathComp setXn is the subgroup of dependent finite functions "
                "whose j-th value lies in H, with pointwise group operations; "
                "for the constant family H its subgroup carrier is canonically "
                "the coordinatewise function group J → H."
            ),
        },
        {
            "rocq": r"J = {f | f \in I}, with #|J| = #|I| and 0 < #|I|",
            "lean": "[Nonempty J]; Fin (Nat.card J)",
            "justification": (
                "Positive finite cardinality supplies a factor element. The "
                "Lean theorem explicitPowerEquivFin_with_base kernel-checks "
                "both the resulting base coordinate in Fin (Nat.card J) and "
                "reindexing along Finite.equivFin."
            ),
        },
        {
            "rocq": "simple H; ~~ solvable H; ~~ abelian H",
            "lean": "S is a finite nonabelian simple group",
            "justification": (
                "The Rocq theorem now returns nonabelianness explicitly, "
                "derived in-kernel from nonsolvability via MathComp "
                "abelian_sol, so the same factor meets the Lean ambient "
                "theorem without an unstated implication at the interface."
            ),
        },
    ]
    if data["definition_correspondence"] != expected_correspondence:
        die("definition-correspondence values drift")
    expected_composition = (
        "Existential elimination chooses the Rocq-proved external-product "
        "isomorphism and positive factor index; Lean reindexes that index to "
        "Fin k, constructs the required base coordinate, and supplies the "
        "resulting MulEquiv to the universally quantified ambient theorem. "
        "The only cross-kernel trust is the audited definition correspondence "
        "between MathComp subgroup isomorphism/external product and Lean "
        "MulEquiv/function product; no unproved group-theoretic lemma is "
        "inserted at the seam."
    )
    if data["composition"] != expected_composition:
        die("composition rule drift")

    rocq_cov = json.loads((ROOT / producer["coverage_manifest"]).resolve().read_text())
    lean_cov = json.loads((ROOT / reindex["coverage_manifest"]).resolve().read_text())
    rocq_item = [x for x in rocq_cov["closed_manuscript_claims"]
                 if x["claim_id"] == "RED-COORD"]
    lean_item = [x for x in lean_cov["closed_manuscript_claims"]
                 if x["claim_id"] == "RED-COORD"]
    if len(rocq_item) != 1 or rocq_item[0]["theorem"] != producer["theorem"]:
        die("Rocq coverage does not bind the producer theorem")
    if len(lean_item) != 1 or lean_item[0]["theorem"] != reindex["theorem"]:
        die("Lean coverage does not bind the reindex theorem")
    if "RED-COORD" in rocq_cov["explicitly_not_closed"]:
        die("Rocq coverage still lists RED-COORD open")
    if "RED-COORD" in lean_cov["explicitly_not_closed"]:
        die("Lean coverage still lists RED-COORD open")

    rocq = (ROOT / producer["file"]).resolve().read_text()
    required_rocq = [
        r"Lemma\s+nonsolvable_charsimple_explicit_power\b",
        r"H\s*\\subset\s*G",
        r"simple\s+H",
        r"~~\s*solvable\s+H",
        r"~~\s*abelian\s+H",
        r"I\s*\\subset\s*Aut\s+G",
        r"\\big\[dprod/1%g\]_\(f in I\) f @: H = G",
        r"G\s*\\isog\s*setXn\s*\(fun _ : \{f \| f \\in I\} => H\)",
        r"#\|G\|\s*=\s*#\|H\|\s*\^\s*#\|I\|",
        r"0\s*<\s*#\|I\|",
        r"Print Assumptions nonsolvable_charsimple_explicit_power\.",
    ]
    for pattern in required_rocq:
        if not re.search(pattern, rocq):
            die("Rocq producer signature/body token missing: " + pattern)

    lean_reindex = code_only_lean((ROOT / reindex["file"]).resolve().read_text())
    required_reindex = [
        r"def\s+reindexPower\b",
        r"noncomputable\s+def\s+reindexPowerFin\b",
        r"theorem\s+explicitPowerEquivFin_with_base\b",
        r"\[Nonempty\s+I\]",
        r"Nonempty\s*\(Fin\s*\(Nat\.card\s+I\)\)",
        r"Nonempty\s*\(N\s*≃\*\s*\(Fin\s*\(Nat\.card\s+I\)\s*→\s*S\)\)",
        r"Finite\.equivFin\s+I",
    ]
    for pattern in required_reindex:
        if not re.search(pattern, lean_reindex):
            die("Lean reindex signature/body token missing: " + pattern)

    lean_consumer = code_only_lean((ROOT / consumer["file"]).resolve().read_text())
    required_consumer = [
        r"theorem\s+ambient_coordinate_realization_and_bound\b",
        r"\(k\s*:\s*ℕ\)\s*\(e\s*:\s*N\s*≃\*\s*\(Fin\s+k\s*→\s*S\)\)",
        r"Nat\.card\s*\(G\s*⧸\s*N\)\s*∣\s*Nat\.card\s*\(X\s*⧸\s*KX\)\s*\^\s*k\s*\*\s*k\.factorial",
    ]
    for pattern in required_consumer:
        if not re.search(pattern, lean_consumer):
            die("Lean consumer signature token missing: " + pattern)

    mathcomp_override = os.environ.get("KOUROVKA_MATHCOMP_ROOT")
    if mathcomp_override:
        mathcomp = Path(mathcomp_override).resolve()
    else:
        located = subprocess.run(
            ["coqc", "-where"], text=True, capture_output=True
        )
        if located.returncode or not located.stdout.strip():
            die("cannot locate the pinned MathComp sources with coqc -where")
        mathcomp = (
            Path(located.stdout.strip()) / "user-contrib" / "mathcomp"
        ).resolve()
    morphism = mathcomp / "finite_group/morphism.v"
    finset = mathcomp / "boot/finset.v"
    gproduct = mathcomp / "finite_group/gproduct.v"
    for source in (morphism, finset, gproduct):
        if not source.is_file():
            die("pinned MathComp interface source missing: " + str(source))
    mtext = morphism.read_text()
    if "Definition isog := [exists f : {ffun aT -> rT}, misom f]." not in mtext:
        die("installed MathComp isog definition drift")
    if not re.search(
        r"Lemma isogP\s*:\s*\n\s*reflect \(exists2 f : \{morphism G >-> rT\},"
        r" 'injm f & f @\* G = H\)",
        mtext,
    ):
        die("installed MathComp isogP statement drift")
    ftext = finset.read_text()
    if "Definition setXn := [set x : {dffun _} in family A]." not in ftext:
        die("installed MathComp setXn definition drift")
    if not re.search(
        r"Lemma setXnP x\s*:\s*reflect \(forall i, x i \\in A i\) "
        r"\(x \\in setXn\)\.",
        ftext,
    ):
        die("installed MathComp setXnP statement drift")
    gtext = gproduct.read_text()
    for token in (
        "Definition extnprod_mulg (x y : gTn) : gTn := "
        "[ffun i => (x i * y i)%g].",
        "Canonical setXn_group H := Group (group_setXn H).",
        "Lemma setXn_dprod H :",
    ):
        if token not in gtext:
            die("installed MathComp external-product definition drift: " + token)

    print("FORMAL PROVER INTERFACE|PASS|claim=RED-COORD|producer=Rocq|reindex=Lean|consumer=Lean")


if __name__ == "__main__":
    main()
