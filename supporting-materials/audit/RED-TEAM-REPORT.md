# Adversarial red-team report

Audit date: **2026-08-01**.  Standard: every universal claim must terminate in
`FORMAL-PASS`, `CITED-PASS`, or `COMPUTED-PASS`; otherwise the applicable gate
fails.  AI agreement is not counted as independent evidence.

## Defects reproduced and repaired

| Attack | Original failure mode | Repair | Fail-closed evidence |
|---|---|---|---|
| Multiple embeddings | `ContainedConjugates(S,W,V,true)` selected one contained copy | enumerate every orbit by `IntermediateSubgroups`, direct double cosets, and fixed GAP `ContainedConjugates` without `true` | K2 rejects an orbit-count, fingerprint, or normal-closure mismatch |
| GAP regression | a historically faulty routine lay on the proof path | exact fixed source/commit and hash; both upstream regressions; direct implementation not calling the routine | environment check and K2 three-way comparison |
| Order-only identity | subgroup order could conflate conjugacy classes | exact class position plus order, index, normalizer order, and SHA-256 of that canonical numeric tuple | independent finite-witness parser |
| Sporadic prose/code drift | prose claimed stored fusions while code used unique order | manuscript now states the actual unique-order argument; every selected `Maxes` position and identifier is recorded | 42-row sporadic source map and finite verifier |
| Random witness | the `Sp(4,4)` field-involution fallback used random search | deterministic entrywise `Sp(4,2)<Sp(4,4)` matrix embedding | static scan rejects `Random`/`PseudoRandom` |
| Implicit generator/representation nondeterminism | generator hashes, pcgs labels, raw quotient-class order, fallback permutation degrees, and equivalent stable-class representatives changed between clean GAP processes although the mathematics was unchanged | reset both GAP global pseudorandom sources to recorded seed 1034; replace generator/representation hashes by pinned class/action fingerprints; audit every quotient-class representative; canonically order each `XCASE` by its complete induced class action and intrinsic kernel/extension data; forbid `SmallGeneratingSet` | repeated-process byte comparison, exact `XCASE`/`CERT` cross-link, and static scan |
| Soft failure | drivers could catch errors and continue | proof drivers do not use `CALL_WITH_CATCH`; missing/failed/ambiguous cases exit nonzero | log scanner, shell `set -eu`, and byte comparison |
| Infinite testing fallacy | 7,892 instances risked being described as proof | receipts are labeled regression tests; an independent symbolic checker covers the encoded exponent inequalities | manuscript checker and arithmetic logs |
| Ineffective exceptional-gap assertion | the direct-prime helper accepted a declared `need_d_gt` argument but did not enforce it | compare the computed gap with both the outer-order valuation and the declared exceptional threshold | dedicated arithmetic mutation changes the threshold and must fail |
| Coordinate-action orientation | treating the input-coordinate permutation as a homomorphism while reading source coordinate `sigma(g)(i)` is incompatible with composition in a general wreath action | use the genuine permutation homomorphism and read source coordinate `sigma(g)^{-1}(i)`; the maximality theorem also requires and uses the corresponding component cocycle | locked Lean build checks existence, maximality, and non-conjugacy with the corrected action equation |
| Partial maximality proxy | saturation, normalizer-tower, and final coatom helpers did not close the ambient overgroup quantifier | prove supplement recovery of coordinate-closure generators, transported-intersection invariance, projection stability/uniformity, the full intersection dichotomy, and the exact coatom theorem | `coordinate_product_normalizer_isCoatom` is axiom-audited and bound to `SUP-MAX` |
| Toy minimal-counterexample proxies | generic least-number and unique-witness lemmas did not prove Proposition 2.3 | formalize quotient order decrease, soluble extensions, absence of soluble normal subgroups, existence/uniqueness of a minimal normal subgroup, quotient solubility, nonsolubility, and the centralizer argument | `minimal_counterexample_unique_minimal_normal` is axiom-audited and bound to `RED-MIN`; the direct-power/wreath part remains `RED-COORD` |
| Same-source coverage | GAP-generated inventory was compared with GAP output | separately authored CFSG manifest and exception manifest | independent topology checker |
| Unpinned structural facts | twisted BN-pairs, automorphisms, `^2E6` Levi types, and maximality used broad citations | exact theorem/table/page rows plus independent high-risk derivations/corroboration | Lie and maximality source-map checkers |
| Priority overclaim | the 1997 Zenkov announcement was absent | disclosure added; absolute first-proof language prohibited | priority ledger and manuscript checker |

## Deliberate mutations

`computations/mutation-tests/run_mutation_tests.py` requires every injected
fault to make its designated checker return nonzero.  The suite covers removal
of a canonical simple group, a CFSG family, an exception, or an `X` case;
changes to a subgroup class, obstruction prime, valuation, result, package
version, source pinpoint, obligation-bound evidence, or formal lock; an injected
GAP failure; an audit `TODO`; an inline Lean placeholder; an altered exceptional
valuation gap; and a weakened two-machine clean-room policy. A passing baseline
is required before any mutation is counted.

## Adversarial mathematical questions still open

The following are not paper-review comments; they are binary blockers recorded
in `OBLIGATIONS.csv`:

1. Kernel-check the remaining direct-power, transitive wreath-embedding, and
   coordinate-normalization reduction. Quotient inheritance and the exact
   minimal-order core through uniqueness, soluble quotient, nonsolubility, and
   trivial centralizer are now kernel checked.
2. Kernel-check the reduction which supplies the normalized coordinate-action
   data used by the now-checked product-supplement machinery. The exact
   coordinate-product construction, orbit argument from `X`-stability,
   normalizer intersection/supplement/order conclusions, and non-conjugacy are
   checked; so is maximality, including supplement recovery of the
   coordinate-closure generators, invariant stable/uniform projections, the
   saturation/Goursat product step, the normalizer-tower/poset overgroup
   dichotomy, the ambient intersection dichotomy, and the final coatom step.
3. Capture every infinite-family group/Levi order formula and every branch in
   one exact formal or equivalently universal symbolic theorem.
4. Obtain two clean, independent fresh-clone reproductions.
5. Remove the documented subscriber-level MathSciNet priority-search limit.

## Outcome

The original computational stop-ship defects are closed.  The locked Lean build
currently closes exact quotient inheritance, the minimal-order structure
through the unique minimal normal subgroup and trivial centralizer, all three product-supplement
lemmas in the normalized coordinate model, the Property-P subgroup-product and
lower-divisibility bridge, and the universal-in-`k` numerical contradiction,
but not the remaining direct-power/coordinate-reduction bridge. Therefore
the **99%-confidence gate remains `FAIL`**, as it must: no amount of passing
engineering checks is allowed to compensate for an open proof obligation.
