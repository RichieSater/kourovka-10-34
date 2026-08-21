# Mathematical contribution map

## Thesis

Every finite group that factorizes as the product of every pair of
non-conjugate maximal subgroups is soluble; the unbounded direct-power branch
is eliminated by one local pair of suitable stable, self-normalizing subgroup
classes in the simple coordinate group, with poset maximality and normal
saturation.

## Three ideas to retain

1. **Stable product normalizers.** An $X$-stable self-normalizing class
   $[V]$ in a simple group $S$ yields the supplement
   $B_V=N_G(V^k)$, with $B_V\cap S^k=V^k$ and
   $|B_V|=|G/S^k||V|^k$. Poset maximality and normal saturation make
   $B_V$ maximal; distinct suitable classes make the resulting supplements
   non-conjugate.
2. **Uniform product-supplement obstruction.** If two such classes leave a
   fixed $p$-adic gap beyond the coordinate outer-automorphism contribution,
   property P would force a $p$-part growing linearly in $k$ into the
   quotient, while the wreath top supplies only the coordinate outer part and
   $k!$. This contradiction works simultaneously for every $k\ge 2$.
3. **Stable flag parabolics under graph fusion.** When graph automorphisms fuse
   maximal-parabolic classes, intersections attached to invariant flags are
   maximal in the stable-class poset and recover the supplement mechanism.

## Novel, inherited, and repetitive components

| Component | Mathematical status |
|---|---|
| Stable product-normalizer construction with exact order | Central paper machinery |
| Uniform-in-$k$ valuation criterion | Principal reusable result |
| Flag-parabolic response to graph fusion | Distinctive structural application |
| Quotient inheritance and minimal-counterexample reduction | Standard ingredients assembled for property P |
| Direct-power and wreath realization | Standard structural input; coordinate normalization and the quotient divisor are proved as named lemmas |
| Almost-simple case | Prior theorem of Tikhonenko--Tyutyanov |
| CFSG, maximality lists, group and Levi orders | Cited external inputs |
| Zsigmondy and elementary valuation arithmetic | Classical input and routine family arithmetic |
| Repeated family-by-family substitutions | Verification material; best placed in an appendix |
| Finite and sporadic searches | Computationally certified finite component |

## Reusable yield

The reusable object is not the case ledger but the following pattern: start
with automorphism-stable, self-normalizing subgroup data in $S$, add stable-poset
maximality and normal saturation to obtain maximal supplements in every
transitive $S^k$-extension, then compare the linear missing
$p$-valuation against the sublinear-per-coordinate wreath-top budget. The
stable-poset maximality lemma and the flag-parabolic construction can be used
whenever outer automorphisms prevent ordinary maximal classes from remaining
stable.

## Subsequent related-work comparison

Li--Yang, arXiv:2608.19478v1 (submitted 19 August 2026), subsequently states
the same theorem through a product--socle lifting construction based on
nonfactorizing maximal subgroups of almost-simple coordinate groups. The
present paper's public v1 and v2 are dated 4 and 6 August 2026. The two
mechanisms are mathematically distinct: Li--Yang lifts a proper coordinate
product directly, whereas the present paper constructs two exact-order maximal
supplements and derives a uniform valuation contradiction.

## Verification boundary

- The manuscript gives the complete ordinary mathematical proof.
- Lean proves named structural and arithmetic theorems conditional on explicit
  coordinate, stability, maximality, order, and published family inputs; it
  does not prove the main theorem end to end.
- Rocq/MathComp proves the characteristically-simple direct-power producer.
  Its translation to Lean's external function product is an audited trusted
  interface, not a single-kernel theorem.
- GAP certifies the designated finite base, sporadic cases, class identities,
  and selected saturation computations.
- Python checks inventories, manifests, source maps, certificate parsing,
  arithmetic reproduction, and failure detection. Finite parameter sweeps are
  regression tests, not proofs of universal family statements.
- CFSG, maximal-subgroup classifications, group and Levi order formulas,
  automorphism descriptions, parabolic theory, and Zsigmondy's theorem remain
  external mathematical inputs.
- The graph-fusion flag-parabolic step remains outside the closed Lean
  coverage (`PAR-NOVELTY`).

## Separation decision

Kourovka 10.34 remains a standalone paper. Its product-supplement integrality
criterion and the regular-subgroup obstruction used for Kourovka 18.68 share a
preliminary monolithic-coordinate and wreath-top setting but have different
final mechanisms and different classification audits. A precise reciprocal
cross-reference is appropriate once a stable public version of the 18.68 work
is citable; a merger or a separate methods paper is not.
