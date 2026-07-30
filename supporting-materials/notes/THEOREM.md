# Towards a negative solution of Kourovka 10.34

Working draft of the theorem and proof architecture. Machine certificates
live in `../computations/certificates/`, with their GAP and Python sources
in the sibling `gap/` and `python/` directories; STATUS.md tracks their
coverage.

## Statement aimed at

**Conjecture (to be proved).** Every finite group which coincides with the
product of any two of its non-conjugate maximal subgroups is soluble.
(Negative answer to Kourovka Notebook 10.34, V.S. Monakhov 1986.)

**Proved so far (machine-certified + lemmas below):** a minimal
counterexample has socle S^k with S simple of order ≥ 500000 (sweeps J, K,
K2; being pushed to ~10⁷ by sweep J3), and its excluded (S, k) territory
includes every S < 500000 for *every* k ≥ 2 — the first unbounded-k
closures.

## 1. Reduction (elementary, complete)

P(G): for all non-conjugate maximal A, B ≤ G: G = AB.

1. G = AB ⟹ G = A^x B^y (conjugation lemma; standard).
2. P passes to quotients.
3. A minimal counterexample G (non-soluble with P, least order) has a
   unique minimal normal subgroup N = S^k, S non-abelian simple,
   C_G(N) = 1, G/N soluble, and G ≤ Aut(S) wr S_k acting transitively on
   coordinates. After base-conjugation, G ≤ X wr S_k with
   X = coordinate closure, Inn(S) ≤ X ≤ Aut(S), x := |X/Inn|, and
   t := |G/N| divides x^k·k!.
4. k = 1 impossible (Tikhonenko–Tyutyanov 2010; independently
   machine-verified for |S| ≤ 20160, sweep D).
5. Top–supplement pairs always factorize: if M ⊇ N and B is maximal with
   B ⊉ N then BN = G (maximality), so MB ⊇ M(BN) ... = G. Hence P(G) is
   equivalent to: (i) P(G/N) and (ii) every supplement–supplement pair of
   non-conjugate maximals factorizes. [Machine data: 0 top–supp failures
   in ~200 exhaustively tested candidate groups.]

## 2. Product-supplement machinery

Fix G as in the reduction: N = S^k ≤ G ≤ X wr S_k, coordinate closure X
(so X = π₁(G₁)·Inn(S) where G₁ is the stabilizer of coordinate 1 and π₁
the projection to Aut(S); by coordinate-transitivity all coordinates give
the same X up to conjugacy), t = |G/N|. For V ≤ S write [V] for its
S-conjugacy class; an S-class is *X-stable* if X permutes it (equivalently
V^a is S-conjugate to V for every a ∈ X — Inn-stability is automatic).

**Definition.** P_X(S) := { [V] : 1 < V < S, N_S(V) = V, [V] X-stable },
partially ordered by containment up to S-conjugacy. Say V is *normally
saturating* if ⟨V^W⟩ = W for every overgroup V ≤ W ≤ S.

Note (used throughout): if V is a **maximal subgroup** of S, then [V] ∈
P_X(S) whenever [V] is X-stable (maximal subgroups of a non-abelian simple
group are self-normalizing), [V] is automatically a maximal element of the
poset, and V is automatically normally saturating — its only overgroups
are V itself and S, and ⟨V^S⟩ = S because S is simple. So Lemmas A–C below
apply to X-stable maximal classes with no computational hypothesis; the
saturation certificates (sweep K2) are needed only for novelty classes.

**Lemma A (existence).** Let [V] ∈ P_X(S) be X-stable with N_S(V) = V,
and set B_V := N_G(V^k). Then:
(i) B_V ∩ N = N_S(V)^k = V^k;
(ii) B_V N = G;
(iii) hence |B_V| = t·|V|^k exactly.

*Proof.* (i) An element of N = S^k normalizes V^k iff each coordinate
normalizes V. (ii) Frattini argument: for g ∈ G write g = (a₁,…,a_k)σ
with a_i ∈ X, σ ∈ S_k. Then (V^k)^g = V^{a_{1'}} × ⋯ × V^{a_{k'}} (indices
permuted by σ), and X-stability gives s_i ∈ S with V^{a_i} = V^{s_i}. So
(V^k)^g is N-conjugate to V^k: there is n ∈ N with (V^k)^{gn} = V^k, i.e.
gn ∈ B_V, g ∈ B_V N. (iii) |B_V| = |B_V N|·|B_V ∩ N|/|N| = t·|V|^k. ∎

**Lemma B (maximality).** If in addition [V] is a maximal element of
P_X(S) and V is normally saturating, then B_V is maximal in G.

*Proof.* Let B_V ≤ H ≤ G. Since H ⊇ B_V and B_V N = G we have H N = G, so
H surjects onto G/N and in particular H acts coordinate-transitively.

Step 1 (H's twists recover X). Let H₁, G₁ be the coordinate-1 stabilizers.
For g ∈ G₁ write g = hn (h ∈ H, n ∈ N); n fixes every coordinate, hence so
does h, so h ∈ H₁ and π₁(G₁) = π₁(H₁)·π₁(N∩G₁) = π₁(H₁)·Inn(S). Therefore
π₁(H₁) and Inn(S) together generate X, and a class of subgroups of S is
X-stable iff it is stable under π₁(H₁) (S-classes are Inn-stable).

Step 2 (Goursat + saturation: H ∩ N is a product). Let T := H ∩ N ⊇ V^k,
let W_i := π_i(T) ≤ S be the coordinate projections and K_i := T ∩ S_i the
coordinate kernels (S_i = i-th factor). Then V ≤ K_i (as V^k ∩ S_i = V_i),
K_i ⊴ W_i (standard), and V ≤ W_i. Since K_i is a normal subgroup of W_i
containing V, it contains ⟨V^{W_i}⟩, which equals W_i by saturation. So
K_i = W_i for every i and T = ∏ W_i.

Step 3 (the W_i force H = B_V or H = G). T is H-invariant; H permutes the
coordinates transitively and twists by π₁(H₁), so all [W_i] coincide with
a single class [W] which, by Step 1, is X-stable. If W = S then T = N, so
H ⊇ N and H = HN = G. Otherwise 1 < V ≤ W < S. Form the normalizer tower
W ≤ N_S(W) ≤ N_S(N_S(W)) ≤ ⋯; it is strictly increasing until it becomes
self-normalizing, and it cannot reach S (the penultimate term would be a
proper normal subgroup of the simple group S). Its terminal member U is
proper, self-normalizing, and [U] is X-stable (N_S(W^a) = N_S(W)^a, so
stability propagates up the tower), i.e. [U] ∈ P_X(S) with [U] ≥ [W] ≥
[V]. Maximality of [V] in P_X(S) forces [U] = [V]; then |U| = |V| and
V ≤ W ≤ U gives V = W = U. So T = V^k, hence |H| = |HN|·|H∩N|/|N| =
t·|V|^k = |B_V| and H = B_V. ∎

**Lemma C (non-conjugacy).** Distinct [V] ≠ [W] in P_X(S) give
non-conjugate B_V, B_W.

*Proof.* If B_V^g = B_W then (B_V ∩ N)^g = B_W ∩ N (N ⊴ G), i.e.
(V^k)^g = W^k. Reading off any coordinate, W = V^{aσ⁻¹...} is the image of
V under an element of X composed with the coordinate permutation, so [W] =
[V^a] = [V] by X-stability — contradiction. ∎

**Lemma P (parabolic novelties).** Let S be a simple group of Lie type
(possibly twisted) with split BN-pair of rank ℓ ≥ 2, B a Borel subgroup,
and for J a subset of the nodes of the (twisted) diagram let Q_J ⊇ B be
the standard parabolic whose Levi subgroup is generated by the torus and
the root subgroups of J. Fix J and put V := Q_J. Suppose X is such that
(a) the S-class [Q_J] is X-stable, and (b) for every J ⊊ K ⊊ Δ the class
[Q_K] is **not** X-stable. Then [V] ∈ P_X(S), [V] is a maximal element of
P_X(S), and V is normally saturating. Consequently Lemmas A–C apply to V
with no computational hypothesis.

*Proof.* Parabolic subgroups are self-normalizing [Carter, Simple Groups
of Lie Type, Thm. 8.4.4], so [V] ∈ P_X(S) by (a). *Overgroups:* every
subgroup containing V contains B, and every subgroup containing a Borel
is a standard parabolic Q_K, K ⊇ J, up to this Borel's parabolic lattice
[Carter, Thm. 8.3.2, 8.4.3]; moreover Q_K and Q_{K′} are S-conjugate iff
K = K′ (types of parabolics are conjugation invariants of the building).
*Poset-maximality:* if [U] ∈ P_X(S) with V ≤ U^s < S for some s, then
U^s = Q_K for some J ⊆ K ⊊ Δ; K = J gives [U] = [V], while J ⊊ K
contradicts (b) since [U] = [Q_K] would be X-stable. *Saturation:* let
V ≤ W ≤ S be an overgroup, so W = Q_K (K ⊋ J) or W = S; we must show
⟨V^W⟩ = W. The normal closure of V in W contains the normal closure of
B. Write W = U_K ⋊ L_K (Levi decomposition; for W = S read U = 1,
L = S). Then U_K ≤ U ≤ B, and modulo U_K the image of B is a Borel
subgroup B_L = T·(U ∩ L_K) of L_K containing the full torus T. For each
node α ∈ K the reflection representative n_α lies in L_K, and
U_{−α} = U_α^{n_α}. The subgroup ⟨B_L^{L_K}⟩ contains every
L_K-conjugate of every subgroup of B_L; in particular it contains T,
each U_α (α ∈ K positive), and each U_{−α} = U_α^{n_α}. These generate
L_K [Carter, Thm. 8.1.5 with 7.2.2: L_K = ⟨T, U_{±α} : α ∈ K⟩]. So
⟨B^W⟩ ⊇ U_K·L_K = W. ∎

Note the exact shape in which Lemma P is used below (FAMILY-PROOFS.md,
Theorems 4–6): when X contains a graph automorphism fusing the maximal
parabolic classes above Q_J, hypothesis (b) holds automatically, and the
"novelty" B_{Q_J} = N_G(Q_J^k) is a maximal subgroup of G by Lemma B.

Saturation was certified by machine for the novelty classes actually used
in exclusions (sweep K2); the recorded saturation failures (size-6 classes
in A6 and L3(4), size-12 classes in L3(4)) belong to classes that no
exclusion pair uses.

## 3. The divisibility criterion

**Theorem D.** Let [V] ≠ [W] be maximal elements of P_X(S), both normally
saturating, and let p be a prime with
    d := v_p(|S|) − v_p(|V|) − v_p(|W|) > v_p(x).
Then no G (with this S, X, any k ≥ 2) has property P.

*Proof.* B_V, B_W are non-conjugate maximals, so P forces G = B_V B_W and
|B_V ∩ B_W| = |B_V||B_W|/|G| = t·(|V||W|/|S|)^k ∈ ℤ, whence p^{dk} | t.
But v_p(t) ≤ k·v_p(x) + v_p(k!) = k·v_p(x) + (k − s_p(k))/(p−1)
< k(v_p(x)+1) ≤ dk. ∎

Remarks. (i) The criterion is independent of k — this is what closes
infinite families, which no size-based counting bound can do (k! outgrows
any fixed ratio). (ii) Only existence of the two B's is used; the full
classification of maximal subgroups of G is *not* needed.

**Theorem D′ (k = 1).** The same criterion excludes the almost simple case:
for S ≤ G ≤ Aut(S) put X := G, x := |G/S| = t. For [V] a maximal element of
P_X(S), B_V := N_G(V) satisfies B_V ∩ S = V, B_V S = G (Frattini via
X-stability), |B_V| = t·|V|, and B_V is maximal in G — the proof is Lemma
B without the Goursat step: T := H ∩ S ⊴ H contains V; if T = S then
H = G; otherwise the normalizer tower of T ends at a proper
self-normalizing H-invariant (hence X-stable) subgroup ≥ T ≥ V, so
poset-maximality forces T = V and H ≤ N_G(V) = B_V. Then G = B_V B_W
forces t·|V||W|/|S| ∈ ℤ, and d > v_p(x) = v_p(t)-bound gives the
contradiction — no k! term even appears.

Consequence: the sweep J/J2/J4/K certificates, which cover **every** X with
Inn ≤ X ≤ Aut(S), re-prove the Tikhonenko–Tyutyanov theorem (no almost
simple group has property P) for all |S| < 500000, and the §5 program
covers k = 1 uniformly with k ≥ 2 — the paper need not lean on [TT2010]
as a black box.

## 4. Machine-certified base (sweeps J, J2, J4, K, K2)

For every non-abelian simple S with |S| < 500000 and every X: Theorem D
applies. Certificate inventory (cross-checked against GAP's
SimpleGroupsIterator canonical list of all 47 such groups by
`../computations/python/verify_coverage.py`; receipt in
`../computations/certificates/verify_coverage.log`):
- 43 socles certified by maximal-class pairs (sweeps J, J2, and J4 — the
  latter added Sz(8), whose original run silently errored on a
  matrix-vs-permutation-group mismatch, and the sixteen L2(q),
  41 ≤ q ≤ 97, that earlier drafts claimed without certificates);
- the four families where maximal-class pairs do not suffice are settled
  by novelty pairs (sweep K, saturation certified in K2):
  - L3(2)@x=2: (S3, 7:3), p=2, d=2 > 1.
  - A6@{2₂,2₃,2²}: (D8, 3²:4), p=5, d=1 > 0.
  - L2(11)@x=2: (A4, D12), p=11, d=1 > 0.
  - L3(4)@{x=3,6,12}: (3²:Q8, 2⁴:A4), p=7, d=1 > 0 (and others).

Corollary: **if Kourovka 10.34 has a positive answer, then a counterexample
of least order has a unique minimal normal subgroup S^k with S simple of
order ≥ 500000** (and k ≥ 2). Equivalently: to prove the negative answer it
suffices to exclude the socles S^k with |S| ≥ 500000. (Note the statement
is about the minimal witness; the argument does not bound composition
factors of an arbitrary counterexample, which is all the final theorem
needs, since a counterexample of least order exists if any does.)

## 5. Program for all simple groups (the paper's case analysis)

The uniform lever: primitive prime divisors. For S of Lie type over F_q,
q = p^f, a Zsygmondy prime r of q^h − 1 (h the relevant torus exponent)
satisfies r ≡ 1 (mod h·f·(diagram order)), hence r ∤ x for every X, and r
divides no proper parabolic or small-Levi subgroup order. So any two
X-stable classes [V], [W] avoiding r give d = v_r(|S|) ≥ 1 > 0 = v_r(x).

- **PSL(2,q)**, q ≥ 13 odd: dihedral classes D_{q−1}, D_{q+1} (both
  Aut-stable, maximal); ratio 2/q gives d = f > v_p(2f) at p. q even ≥ 8:
  (Borel, D_{2(q−1)}) with r a Zsygmondy prime of q+1 (q=8: r=3, v=2 > 1
  works). Small q machine-done. **Complete modulo writing up.**
- **A_n**: let p be the largest prime ≤ n; by Bertrand p > n/2, so
  v_p(|A_n|) = 1. Candidate classes avoiding p: the intransitive
  stabilizers (S_m×S_{n−m})∩A_n with n−p < m < n/2 (then both parts are
  < p), and for even n the imprimitive (S_{n/2} wr S_2)∩A_n (parts n/2 <
  p). All are S_n-stable, hence X-stable (Out(A_n) = 2 for n ≥ 7, n ≠ 6),
  and maximal for n outside the known small exceptions. Any two give
  d = 1 > 0 = v_p(2). Two such classes exist whenever p ≥ n/2 + 2 (even
  n: ≥ 1 intransitive + the imprimitive class, e.g. n = 10, p = 7:
  m = 4 and 5+5; odd n: ≥ 2 intransitive, e.g. n = 11, p = 11: m = 1, 2;
  n = 12, p = 11: m = 2, 3 — note the earlier draft's window
  n/2 < p ≤ n−3 fails at n = 12 and is repaired by dropping the upper
  restriction). The largest prime ≤ n satisfies p ≥ n/2 + 2 for all
  n ≥ 8 except finitely many small n, by Nagura's theorem (a prime in
  (x, 1.2x] for x ≥ 25); small n and the maximality exceptions are in
  machine range (A_n for n ≤ 9 certified; A10, A11 to be added to the
  J3/K3 base). **Complete modulo write-up.**
- **Lie type, no graph symmetry** (B_n, C_n n≥3, E7, E8, F4 p≠2, G2 p≠3):
  two parabolic classes P_1, P_2 are Aut-stable (no diagram symmetry to
  fuse them; diagonal and field automorphisms preserve each parabolic
  class). Worked argument for C_n = PSp(2n,q), q = p^f, n ≥ 3, which is
  the template for all: let r be a primitive prime divisor of q^{2n}−1
  (Zsygmondy). Then (i) r | |S| since q^{2n}−1 is a factor of the order
  formula q^{n²}∏(q^{2i}−1); (ii) r divides no proper parabolic order:
  |P_i| = q^N·|GL_i(q)|·|Sp(2n−2i,q)| involves only factors q^j−1 with
  j < 2n, which r cannot divide by primitivity; (iii) ord_r(p) = 2nf
  gives r ≡ 1 (mod 2nf), so r > 2f and r ∤ x for every X (x divides
  gcd(2,q−1)·f). Hence d = v_r(|S|) ≥ 1 > 0 = v_r(x) for the pair
  (P_1, P_2): Theorem D fires for all k, all X. **The only Zsygmondy
  exception in the family is p^{2nf} = 2⁶, i.e. Sp(6,2) — already
  machine-certified (sweep J3).** B_n = Ω(2n+1,q) (q odd): identical with
  the same torus q^{2n}−1. E7 (Φ₁₈), E8 (Φ₃₀), F4 p≠2 (Φ₁₂), G2 p≠3
  (Φ₆): same shape; Zsygmondy exceptions land only at tiny q whose groups
  are non-simple or already certified (G2(2)′ = U3(3) done). **Substance
  complete; referee-grade prose pending.**
  Exceptional graph autos (Sp4/F4 p=2, G2 p=3) and Suzuki–Ree: item-5
  territory — use (Borel-novelty = P_1∩P_2, subfield or torus
  normalizer) with the same r; template certified on Sp(4,4) (sweep K3).
- **Lie type with graph symmetry** (A_n duality, D_n, E6, triality D4):
  for X without graph part, parabolic pairs as above; for X with graph
  part, fused parabolic pairs produce novelty classes (flag stabilizers
  P_i ∩ P_j^op), and pairs of these (or with torus normalizers) avoid r.
  L3(q): (Borel, N((q−1)²-torus)) for q ≥ 5.
- **Sporadic + Tits**: 27 individual finite checks (M11, M12, M22, J1
  done; the rest are routine sweep-J runs off ATLAS maxes data).

Expected exceptions needing bespoke handling: Zsygmondy-less cases
(q^h = 2^6 patterns), tiny fields/ranks — all lie in machine-checkable
range.

## 6. Certification ledger

| Claim | Certificate |
|---|---|
| P quotient-hereditary, conj. lemma, top-supp lemma | elementary proofs (§1) |
| k=1 | TT2010 + sweep D log |
| all S < 5·10⁵, all k ≥ 2, all X | sweeps J, K logs |
| saturation hypotheses | sweep K2 log |
| exhaustive ground truth k=2 (S ≤ M22), k=3 (S ≤ U3(5)), k=4 (small S) | sweeps C, F, G, I logs |
| order-≤2000 groups, perfect groups ≤ 2·10⁶ | sweeps A, B, B2 logs |
| 5·10⁵ < |S| ≤ 1.05·10⁷ | sweep J3 (running) |
