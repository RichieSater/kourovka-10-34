# Comparator: exact Lean theorem exposed by the paper

## Mathematical statement

`conditionalProductSupplementSpine` is the conditional formal spine of the
stable-class divisibility argument. For a finite group `G`, it assumes two
subgroups `A` and `B` that are maximal and non-conjugate, the exact order
identities produced by the product-normalizer construction, the wreath-top
divisor, and the strict prime-valuation gap. It concludes that `G` does not
have property P.

The theorem corresponds to the group-to-arithmetic bridge and final
contradiction in the manuscript's stable-class divisibility criterion. Its
conclusion expands property P rather than importing the project's definition,
so the challenge statement can be read using mathlib alone.

## External inputs

This theorem does **not** prove that the hypotheses hold for every finite
simple coordinate group. The following remain outside this challenge:

- CFSG and the almost-simple result;
- maximal-subgroup, group-order, Levi-order, and automorphism data;
- stability and normal saturation of the selected classes;
- the graph-fusion flag-parabolic theorem (`PAR-NOVELTY`);
- the finite and sporadic GAP certificates;
- the Rocq-to-Lean direct-power interface.

Those inputs are mapped separately in the manuscript and coverage manifests.
Consequently this package is not an end-to-end formal proof of the main
theorem.

## Files and comparison

- `Challenge.lean` imports only mathlib and contains the independent statement.
  Its `sorry` is an intentional challenge placeholder and is not listed as a
  closed formal claim.
- `Solution.lean` imports the project theorem
  `Kourovka1034.no_propertyP_of_product_supplement_data`, proves the exact
  expanded proposition, and ends with an elaboration-level comparison. The
  comparison type-checks only if the challenge and solution theorem constants
  have definitionally identical propositions.

From `supporting-materials/formal/`, run:

```sh
lake build +Comparator.Challenge +Comparator.Solution
```

The build reports the expected warning for the challenge placeholder and must
otherwise finish without an error. Building `Comparator.Solution` elaborates
the proposition comparison. The repository verification suite repeats the
solution check while keeping the challenge placeholder outside the
closed-claim and axiom audits.

Quick verification runs `check_formal.py --no-build`; it checks the source
tokens and coverage record only and reports
`comparator=SOURCE-CHECK-PASS`. The full formal run actually elaborates
`Solution.lean` and reserves the proposition-level label
`comparator=ELABORATED-PASS` for that result.
