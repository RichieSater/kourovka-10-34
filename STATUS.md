# Kourovka 10.34 — status of play

**Problem (V.S. Monakhov, Kourovka Notebook 10.34, 1986).** Does there exist
a non-soluble finite group which coincides with the product of any two of its
non-conjugate maximal subgroups?

Property **P(G)**: for all non-conjugate maximal subgroups `A, B` of `G`:
`G = AB`. The question: is there a non-soluble `G` with P? (Soluble examples
exist and are allowed; the problem is open as of the 20th Kourovka edition.)

## Reduction (minimal counterexample)

All steps elementary or cited:

1. **Conjugation lemma.** `G = AB ⟹ G = A^x B^y` for all `x, y`. So P only
   needs one representative pair per pair of distinct maximal classes
   (`property.g`), and trivially no group is `A·A^g` for a proper subgroup
   `A` (used below).
2. **P passes to quotients.** Maximal subgroups of `G/K` are images of
   maximal subgroups of `G` containing `K`; non-conjugate ones lift to
   non-conjugate ones, and factorizations project.
3. **Minimal counterexample structure.** Let `G` be a counterexample
   (non-soluble, P) of least order. Every proper quotient has P, hence by
   minimality is soluble... combined with standard arguments: the soluble
   radical is trivial (else `G/R` is a smaller counterexample — `G/R`
   non-soluble since `R` soluble), so `G` has trivial Fitting subgroup and
   its socle is a product of non-abelian minimal normal subgroups. If `N₁ ≠
   N₂` are two minimal normals, `G/N₁` is soluble, contradicting
   `N₂ ≅ N₂N₁/N₁ ≤ G/N₁` non-soluble. So there is a **unique** minimal
   normal `N = S^k` (`S` non-abelian simple), `C_G(N) = 1` (as `C_G(N) ⊴ G`
   intersects `N` trivially, so it would be another minimal normal's home),
   i.e. `N ≤ G ≤ Aut(S) wr S_k`, `G` transitive on the `k` copies, and
   **`G/N` is soluble**.
4. **k = 1 is impossible.** `k = 1` means `G` almost simple, excluded by
   V.A. Tikhonenko, V.N. Tyutyanov, *Dokl. NAN Belarusi* (2010): no almost
   simple group has P. (Machine-verified independently for socle order ≤
   20160 in sweep D.) Hence `k ≥ 2`.

So a counterexample search = search over socles `S^k`, `k ≥ 2`, with
`N ≤ G ≤ Aut(S) wr S_k`, transitive top, `G/N` soluble.

## Machine sweeps (GAP 4.16.0; scripts + logs in this directory)

| Sweep | What it proves | Result |
|---|---|---|
| A | All 1024 non-soluble groups of order ≤ 2000 | no counterexample |
| B | All perfect library groups (order < 1370880) | no counterexample |
| B2 | Perfect library groups, orders 1370880–2·10⁶ (needs `perf27/33.grp` from hulpke/extraperfect, now installed) | running |
| C | **Exhaustive**: all `N ≤ G ≤ Aut(S) wr S_k` for `S²` with `S` ∈ {A5, L2(7), A6, L2(8), L2(11), L2(13), L2(17), A7, L2(19), L2(16), L3(3), U3(3), L2(23), L2(25), M11, L2(27), L2(29), L2(31), A8, L3(4)}; `S³` for {A5, L2(7), A6, L2(8), L2(11)}; `A5⁴` | all fail; **0 top–supp failures** (every failure is supp–supp or top–top) |
| D | Almost simple `S ≤ G ≤ Aut(S)`, `|S| ≤ 20160` (verifies Tikhonenko–Tyutyanov in range) | all fail |
| E | Arithmetic exclusion, all simple `|S| < 5·10⁵`, `k = 2, 3`: excluded if distinct Aut-stable maximal classes `[U] ≠ [V]` have `(|U||V|)^k · |Out(S)|^k · k! < |S|^k` | most socles excluded; survivors below |
| E2 | Same criterion, `|S| < 5·10⁶`, `k ≤ 6` | running |
| F | **Exhaustive**, transitive top, `S²` for the four k=2 survivors of C+E: PSp(4,3), A9, M22, U3(5) | PSp(4,3)², A9², M22² all fail (supp–supp); U3(5)² running |
| G | **Exhaustive**, transitive top, `S³` for the k=3 survivors: M11, A7, A8, A9, M22, U3(3), PSp(4,3), L2(16), L2(32), L3(4), U3(5) | running |

The transitive-top restriction in F/G is justified by step 3 of the
reduction (intransitive top ⟹ `N` is not the unique minimal normal).

### Current frontier (assuming running sweeps finish as started)

- `k = 2`: **closed for all `|S| < 500000`** once U3(5)² finishes.
- `k = 3`: closed for `|S| < 500000` once sweep G finishes.
- `k ≥ 4`: only A5⁴ done exhaustively; sweep E2 extends arithmetic
  exclusion to `k ≤ 6`.
- `|S| ≥ 500000`: nothing yet (E2 pushes the exclusion bound to 5·10⁶).

## The divisibility criterion (sweep J) — main theoretical advance

**Setup.** Candidate `G`, socle `N = S^k`, transitive top, `t = |G/N|`.
After conjugating in `Aut(S) wr S_k` we may assume `G ≤ X wr S_k` where
`Inn(S) ≤ X ≤ Aut(S)` is the coordinate closure (image of a coordinate
stabilizer); write `x = |X/Inn|`. Then `t | x^k · k!`.

**Existence lemma.** For every X-stable class `[U]` of maximal subgroups of
`S`, the subgroup `B_U = N_G(U^k)` satisfies:
- `B_U ∩ N = U^k` (maximal subgroups of simple groups are self-normalizing);
- `B_U N = G` (X-stability makes the G-orbit of `U^k` a single N-orbit);
- `B_U` is **maximal** in `G`: any `H` with `B_U < H < G` would have
  `H ∩ N = ∏ X_i` with `U ≤ X_i` (a Goursat argument shows subgroups of
  `S^k` containing `U^k` are products of coordinate subgroups), and
  top-transitivity of `H̄ = Ḡ` forces uniformity, so `H ∩ N ∈ {U^k, N}`,
  both impossible;
- distinct stable classes give non-conjugate `B_U`.
So `|B_U| = t·|U|^k` **exactly**.

**Theorem (divisibility criterion).** If `[U] ≠ [V]` are X-stable maximal
classes and `p` is a prime with
`d := v_p(|S|) − v_p(|U|) − v_p(|V|) > v_p(x)`,
then no `G` as above has property P — for **every** `k ≥ 2` simultaneously.
*Proof.* P forces `G = B_U B_V`, hence `|B_U ∩ B_V| = |B_U||B_V|/|G| =
t·(|U||V|/|S|)^k ∈ ℤ`, i.e. `p^{dk} | t`. But
`v_p(t) ≤ k·v_p(x) + v_p(k!) = k·v_p(x) + (k − s_p(k))/(p−1)
< k(v_p(x) + 1)` `≤ dk`. ∎

Example: `S = A5`, `U = A4`, `V = S3`, `p = 5`: `d = 1 > 0` — **no group
with socle A5^k, any k ≥ 2, any X, has property P**. First infinite family
closed.

**Sweep J results** (all socles `|S| < 500000` not previously closed for
unbounded k): all are excluded for all `k ≥ 2` and all `X`, **except** four
exceptional (S, X) families:
- `L3(2)` with `x = 2` (only stable maximal class `7:3`);
- `A6` with `X/Inn ∈ {2₂, 2₃, 2²}` (only stable maximal class `3²:4`);
- `L2(11)` with `x = 2` (stable classes `11:5`, `D12` — exact
  factorization `L2(11) = (11:5)·D12`, no arithmetic obstruction);
- `L3(4)` with `x ∈ {6, 6, 12}` (stable maximal class `3²:Q8` only).
In particular **M22, A9, U3(5), J1, M12, Sp(4,3), A7, A8, all L2(q ≤ 97),
L3(3), L3(5), U3(3), U3(4), U3(5), Sz(8), M11 are closed for ALL k**.

## Novelty correction (sweep K)

The sweep C certificates for A6² reveal supplement maximals of orders
`8·8²` and `8·10²`: product-type maximals `N_G(V^k)` with `V` **not
maximal** in `S` — wreath analogues of novelty maximals. Correct statement:
product-type maximal supplements correspond to the **maximal elements of
`P_X(S) = {V < S : N_S(V) = V, [V] X-stable}`** (ordered by containment up
to conjugacy). When X fuses two maximal classes, their intersections (e.g.
`D8 = S4a ∩ S4b` in A6) enter `P_X`. This does not affect sweep J's
exclusions (existence of `B_U` for stable maximal classes stands) but
gives the exceptional families **more** supplement classes and hence more
divisibility pairs — e.g. A6@x=2: pair `(3²:4, D8)` has `36·8/360 = 4/5`,
a 5-adic obstruction excluding all k.

**Sweep K result: all four exceptional families are excluded for all
k ≥ 2.** (L3(2)@x=2 falls via the novelty pair `(S3, 7:3)`: `6·21/168 =
3/4`, `d = 2 > v₂(x) = 1`.) Hence, modulo the novelty-maximality lemma
below: **no group with socle S^k, |S| < 500000, k ≥ 2, has property P**.
Combined with the k = 1 case (Theorem D applies verbatim at k = 1, see
THEOREM.md; also Tikhonenko–Tyutyanov 2010) and the reduction, this means:
**a counterexample to 10.34 of least order must have socle S^k with S
simple of order ≥ 500000.** (Statement deliberately about the minimal
witness — the argument does not bound composition factors of arbitrary
counterexamples, and the final theorem does not need it to.)

**Novelty-maximality lemma (needs the saturation hypothesis).** If `V` is
a maximal element of `P_X(S)` and `⟨V^W⟩ = W` for every overgroup
`V ≤ W ≤ S` (*normal saturation* — verified computationally in sweep K2),
then `B_V = N_G(V^k)` is maximal in `G` with `|B_V| = t·|V|^k`. Saturation
kills subdirect intermediates (the coordinate kernels `K_i ⊴ π_i(H∩N)`
contain `V`, hence equal the projections), and the normalizer-tower of any
X-stable intermediate class terminates in a self-normalizing X-stable
class strictly above `V`, contradicting P_X-maximality.

## Extension to |S| ≤ 1.05·10⁷ (sweeps J3, J5, J6, K3, K4)

All simple groups with 500000 ≤ |S| ≤ 10500000 are excluded for all k ≥ 2
and all X. Directly by the divisibility criterion: every PSL(2,q) in
range, A10 (and A11–A14 beyond it, sweep J5), HJ = J2, Sp(6,2), G2(3),
Sp(4,5), L3(7), U3(7), U3(8), U4(3), L4(3), M23, and more. Two groups
needed novelty pairs, both fitting the predicted graph-automorphism
pattern:
- **Sp(4,4)@x=4** (graph auto fuses the parabolics): pair (Borel,
  subfield Sp(4,2)), obstructions at p = 5 and p = 17 (sweep K3);
- **L5(2)@x=2** (duality fuses P1/P4 and P2/P3; only the Singer
  normalizer 31:5 stays stable): pair of incident-flag parabolics
  (P1∩P4, P2∩P3) of orders 21504 and 9216, obstructions at p = 5 and
  p = 31 (sweep K4).
Certificate status: **complete and gap-free.** Sweep J3 finished with 51
verdicts over the whole range (including its own independent runs of
L5(2) and M23, confirming the sweep J6 constructions); its only
survivors are the two novelty-certified groups above. Together with the
47-group base below 500000: every non-abelian simple S with |S| ≤
1.05·10⁷ is certified excluded as a socle constituent, for all k and
all X.

## Family proofs complete (HITLIST items 1–5, 2026-07-26)

FAMILY-PROOFS.md now holds referee-grade uniform proofs covering every
infinite family, closing the last open item (5, graph-symmetric and
twisted Lie types):

- **Theorem 4** (twisted, twisted rank ≥ 2: PSU(n,q) n ≥ 4, PΩ⁻(2n,q),
  ³D₄, ²E₆, ²F₄): twisted groups admit **no graph automorphisms**, so
  two maximal-parabolic classes are X-stable for every X; a Zsygmondy
  prime for the leading torus exponent avoids both Levis and x. Sole
  exception PSU(4,2) — machine base.
- **Theorem 5** (twisted rank 1: U3(q), Sz(q), ²G₂(q)): pair (Borel,
  second maximal class — nonisotropic point stabilizer / D_{2(q−1)} /
  involution centralizer 2×L2(q)). All maximal classes, no novelties.
- **Theorem 6** (untwisted with graph symmetry: PSL(n,q) n ≥ 3, D_n,
  E₆, and Sp(4)/F₄ at p = 2, G₂ at p = 3): for X without graph part,
  Theorem-2-style parabolic pairs. For X with graph part: E₆ and D_n
  (n ≥ 5) have graph-fixed diagram nodes (P₂/P₄, resp. P₁/P₂) — maximal
  pairs still work; PSL uses incident-flag parabolic novelties
  (point–hyperplane and line–(n−2)-space stabilizers; n = 3 pairs the
  Borel with the maximal torus normalizer (q−1)²:S₃, n = 4 uses the
  δ-fixed P₂); D₄-triality pairs P₂ with the novelty Q_{{2}}; Sp(4,2^f)
  and G₂(3^f) pair the Borel novelty with Fix(ρ̃^f) — Sz(q)/²G₂(q) for
  f odd, subfield subgroup for f even (Aut-stable since ρ̃ commutes
  with its own power; maximal by BHRD/Kleidman); F₄(2^f) uses the two
  ρ-stable flag novelties Q_{{2,3}}, Q_{{1,4}}.
- **Lemma P** (THEOREM.md §2): standard-parabolic novelties Q_J satisfy
  every Lemma B hypothesis structurally (self-normalizing, poset-
  maximal when the parabolic overgroups are graph-fused, normally
  saturating via root-subgroup generation) — no computational
  saturation certificates needed for any of the above.
- Zsygmondy exceptions above the machine base: **PSL(6,2)** (r = 31 =
  Φ₅(2)) and **Ω⁺(8,2)** (r = 5 = Φ₄(2), split by graph part of X) —
  both closed in-prose inside Theorem 6.
- **Receipt: sweepN_item5_arith.py / sweepN_item5_arith.log** — 7892
  parameter instances across all Theorem 4–6 families (ranks to 25,
  fields to 200–3000 per family), verifying r's existence, r ∤ both
  subgroup orders, r ∤ x, and v_r(|S|) ≥ 1; zero failures, and the
  Zsygmondy-exception set is exactly the 7 documented tags.

With items 1–6 all checked, what remains for the paper is assembly:
reduction (§1), machinery (§2–3), machine base (§4 + logs), family
proofs (Theorems 1–6), then submission and the Kourovka entry update.

## Structural observations for the general theorem

1. **Maximal subgroup types.** For `G` with unique minimal normal `N = S^k`
   and transitive top, a maximal `M`: (top) `M ⊇ N`, `M/N` maximal in the
   soluble group `G/N`; (product) `M ∩ N = U₁ × … × U_k`, `U_i` Aut(S)-
   conjugate maximal subgroups of `S` (class must be stable under the
   relevant coordinate action); (diagonal) `M ∩ N` = product of full
   diagonals over a block partition of the coordinates. The 0-count of
   top–supp failures in sweeps C/F suggests the decisive pairs are
   supp–supp; every observed failure certificate so far is supp–supp or
   top–top.
2. **Why arithmetic exclusion cannot close unbounded `k`.** The criterion
   compares `(|U||V|/|S|)^k` against `1/(|Out|^k k!)`; since `k!^{1/k} → ∞`
   while `|U||V|/|S|` is a fixed ratio, for every fixed `S` the criterion
   fails for large `k`. Any full solution needs a structural argument in
   `k`, not counting.
3. **Sharper pair conditions (derived, not yet exploited).** If `G = AB`
   for maximals `A, B` with `A∩N = ∏U_i`, `B∩N = ∏V_i`, then writing `N ⊆
   AB` along `G/N`-cosets gives `|S|^k ≤ Σ_{x ≤ t} ∏_i |U_i g_{x,i} V_i|`
   with `t = |G/N|` — i.e. a bound by `t` products of **double cosets**
   `|U g V^γ|`, `γ ∈ Aut(S)`, each of which is computable in GAP
   (`DoubleCosetRepsAndSizes`) and each `< |S|` when `U, V` are S-conjugate
   (conjugation lemma). For diagonal-vs-product pairs the pieces are
   `|S|·|U|²/|U ∩ U^γ|`-type. This gives a criterion strictly sharper than
   sweep E when maximal double cosets are small; still bounded-`k` only.
4. **Literature levers for the endgame.** Liebeck–Praeger–Saxl (Mem. AMS
   1990) classifies maximal factorizations of almost simple groups —
   relevant to which `S = UV` can occur at all; Praeger–Schneider
   (factorizations of characteristically simple groups) for `S^k = AB`
   with subdirect factors; Tikhonenko–Tyutyanov for `k = 1`.

## Verification notes

- All logs produced by the scripts named; `property.g` is the single
  definition of P used everywhere; `sanity.g` checks known positives and
  negatives (S4 has P; A5, S5, SL(2,5), A5 wr C2 fail).
- Failure certificates record the class sizes of a failing pair, so any
  single log line is independently re-checkable.
- GAP 4.16.0 built from release tarball with full package set
  (`~/gap-4.16.0`).
