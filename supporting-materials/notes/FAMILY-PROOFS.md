# Family proofs — completed cases (HITLIST items 1, 2, 4, 5)

> **Historical working note (non-normative).** This file preserves the
> development history and may contain stale counts, citations, or claims. The
> normative paper, binary obligation ledger, source maps, and current blockers
> are in `../paper/kourovka1034.tex` and `../audit/`. Do not use this note as a
> proof or release certificate.


Referee-grade write-ups. Framework, notation and Theorems D/D′ are in
THEOREM.md; machine certificates in the sweep logs. Throughout: S is
simple, X is any group with Inn(S) ≤ X ≤ Aut(S), x = |X/Inn(S)|, and
"excluded" means: by Theorem D (k ≥ 2) and Theorem D′ (k = 1), no finite
group G with socle S^k and coordinate closure X has property P — i.e. S
cannot occur in a minimal counterexample to Kourovka 10.34.

Recall (THEOREM.md §2, note after the definition of P_X): when the two
exhibited classes are classes of **maximal** subgroups of S, the
hypotheses of Lemmas A–C (self-normalization, normal saturation,
poset-maximality) hold automatically; the only things to verify are
X-stability of the two classes and the valuation inequality
d := v_p(|S|) − v_p(|U|) − v_p(|V|) > v_p(x).

---

## Theorem 1 (HITLIST item 1). Let S = PSL(2,q), q = p^f ≥ 4. Then S is
excluded, for every k ≥ 1 and every X.

**Proof.** For q ≤ 271 (equivalently every case with |S| ≤ 1.05·10⁷, and
in particular every exceptional case of Dickson's subgroup theorem) this
is machine-certified: sweeps J (q ≤ 37), J4 (41 ≤ q ≤ 97), J3
(101 ≤ q ≤ 271, including q = 121, 125, 128, 169, 243, 256), logs in
this directory. Assume q ≥ 13; we give the uniform argument, which is
independent of the machine base for q ≥ 13 except where noted.

Recall |PSL(2,q)| = q(q²−1)/e with e = gcd(2, q−1), and
Out(PSL(2,q)) = C_e × C_f (diagonal × field automorphisms), so x | ef.

**Case A: q odd, q ≥ 13.** Let T₊ ≤ S be the split maximal torus (cyclic
of order (q−1)/2) and T₋ the nonsplit one (order (q+1)/2). Their
normalizers U := N_S(T₊) and V := N_S(T₋) are dihedral of orders q−1 and
q+1 respectively. By Dickson's subgroup theorem [Dickson 1901; Huppert,
Endliche Gruppen I, Hauptsatz II.8.27; Suzuki, Group Theory I, Thm.
6.25], both are maximal subgroups of S for q ≥ 13. (For q ≤ 11 one or
both fail maximality — D₄ < A₄ at q = 5, D₆ < S₄ at q = 7, etc. — these
are in the machine base.)

*Stability.* All split maximal tori of S are S-conjugate, and every
automorphism of S maps a split maximal torus to a split maximal torus
(diagonal and field automorphisms act algebraically; there is no graph
automorphism for type A₁). Hence [U] is a single S-class preserved by
Aut(S), so it is X-stable for every X; likewise [V]. Alternatively:
[U] is the unique class of maximal dihedral subgroups of order q−1, and
uniqueness forces stability.

*Valuation.* |U||V|/|S| = (q−1)(q+1)·e/(q(q²−1)) = e/q. Take the prime
p. Then d = v_p(|S|) − v_p(q−1) − v_p(q+1) = f − 0 − 0 = f (p is odd, so
p ∤ q ± 1 and p ∤ e). Since x | 2f, v_p(x) = v_p(f) ≤ log_p f < f = d.
Theorem D (and D′) applies to the pair ([U],[V]). ∎(Case A)

**Case B: q = 2^f, f ≥ 3.** Here e = 1, |S| = q(q²−1), and
Out(S) = C_f, so x | f. Let U := a Borel subgroup (the stabilizer of a
point of the projective line, equivalently N_S(Q) for Q ∈ Syl₂(S)), of
order q(q−1), and let V := N_S(T₊), the normalizer of a split maximal
torus, dihedral of order 2(q−1), maximal for q ≥ 8 by Dickson (for
q = 4, S ≅ A₅ is in the machine base; maximality of V at q = 8, 16 is
also visible directly in the sweep E log: classes of sizes 14 and 30).

*Stability.* [U] is the class of Sylow-2 normalizers: stable under every
automorphism. [V] is the unique class of normalizers of split maximal
tori: stable as in Case A.

*Valuation.* |U||V|/|S| = q(q−1)·2(q−1)/(q(q−1)(q+1)) = 2(q−1)/(q+1).
Since q is even, q+1 is odd and gcd(q−1, q+1) = gcd(2(q−1), q+1) = 1, so
in lowest terms the denominator is exactly q+1. It suffices to produce a
prime r | q+1 with v_r(q+1) > v_r(f):

- If f ≠ 3, let r be a primitive prime divisor of 2^{2f}−1, which exists
  by Zsygmondy's theorem (the only relevant exception is 2f = 6). By
  primitivity r ∤ 2^f−1, and r | (2^{2f}−1)/(2^f−1) = q+1. Moreover
  ord_r(2) = 2f divides r−1, so r ≡ 1 (mod 2f); in particular r > f, so
  r ∤ f and v_r(x) ≤ v_r(f) = 0 < v_r(q+1) = d.
- If f = 3 (q = 8): q+1 = 9, r = 3: d = v_3(9) = 2 > 1 = v_3(3) ≥
  v_3(x). (Also machine-certified, sweep J.)

Theorem D (and D′) applies to the pair ([U],[V]). ∎(Case B)

Cases A, B and the machine base for q ≤ 11 cover all q ≥ 4. ∎

*Receipts:* the valuation inequalities of Cases A and B were additionally
verified numerically for all 1272 prime powers 13 ≤ q ≤ 10⁴
(sweepL_psl2_arith.log, zero failures).

---

## Theorem 2 (HITLIST item 4). Let S be a simple group of Lie type of
rank ≥ 2 over F_q, q = p^f, of a type with no graph symmetry acting on
its Dynkin diagram in the given characteristic:
  C_n = PSp(2n,q) (n ≥ 2, and p odd when n = 2),
  B_n = Ω(2n+1,q) (n ≥ 3, q odd; B₂ ≅ C₂),
  G₂(q) (p ≠ 3),  F₄(q) (p ≠ 2),  E₇(q),  E₈(q).
Then S is excluded, for every k ≥ 1 and every X.

**Proof.** Write h for the exponent of the Coxeter torus used below per
type: h = 2n for B_n/C_n, h = 6 for G₂, 12 for F₄, 18 for E₇, 30 for E₈.

**Setup.** Let P₁, P₂ be two maximal parabolic subgroups of S from
distinct classes (rank ≥ 2 guarantees at least two classes; concretely we
take the ends of the diagram). Maximal parabolics are maximal subgroups
of S: any overgroup of a parabolic contains a Borel subgroup, and every
subgroup containing a Borel is parabolic [Tits; Carter, Simple Groups of
Lie Type, Thm. 8.3.2, 8.4.3], so a maximal parabolic is maximal among
proper subgroups.

*Stability.* Aut(S) is generated by inner, diagonal, field and graph
automorphisms [Steinberg; Carter Ch. 12]. Diagonal and field
automorphisms act on the building preserving types of vertices, hence
preserve each parabolic class. Type-permuting automorphisms arise only
from symmetries of the Dynkin diagram — absent for the listed types in
the listed characteristics (the exceptional symmetries of B₂/C₂, F₄ in
characteristic 2 and G₂ in characteristic 3 are excluded by hypothesis;
those groups are HITLIST item 5). Hence every parabolic class is
X-stable for every X.

*The obstruction prime.* Let r be a primitive prime divisor of
p^{hf}−1 = q^h−1 (Zsygmondy), so ord_r(p) = hf. Then:

(i) *r | |S|.* The order formula of each listed type contains the factor
q^h−1 (equivalently, the cyclotomic factor Φ_h(q)): for B_n/C_n,
|S| = q^{n²}∏_{i=1}^{n}(q^{2i}−1)/e contains q^{2n}−1; for G₂:
q^6(q^6−1)(q^2−1); for F₄: Φ₁₂ | |F₄(q)|; for E₇: Φ₁₈; for E₈: Φ₃₀
[Carter, §14.1, order formulas].

(ii) *r divides no maximal parabolic order.* |P_i| = q^{N_i}·|L_i|·
(q−1)^{c_i} where L_i is the semisimple part of the Levi factor, a lower
rank group whose order is a product of q-power and factors q^j−1 with
j ≤ h_i for h_i the largest torus exponent of L_i; in every listed case
each proper Levi satisfies h_i < h. (B_n/C_n: Levis of type
A_{i−1} × C_{n−i} give j ≤ max(i, 2(n−i)) < 2n. G₂: Levis of type A₁,
j ≤ 2 < 6. F₄: Levis B₃, C₃, A₂×A₁, j ≤ 6 < 12. E₇: Levis E₆, D₆, A₆
etc., cyclotomic exponents ≤ 12 < 18. E₈: Levis E₇, D₇, A₇, exponents
≤ 18 < 30.) By primitivity r divides none of these factors, and r ∤ q,
r ∤ (q−1). Hence v_r(|P₁|) = v_r(|P₂|) = 0.

(iii) *r ∤ x.* Since ord_r(p) = hf, r ≡ 1 (mod hf), so r > hf ≥ 2f ≥
|Out(S)|-relevant part: |Out(S)| divides d_S·f·g_S with d_S ≤ 4 the
diagonal part and g_S = 1 here (no graph); r > hf ≥ 6f > 4f ≥ d_S·f ≥ x
would suffice, and in any case r ∤ x because r is a prime exceeding x.
[For B_n/C_n, d_S = gcd(2, q−1) ≤ 2 and h ≥ 4, so r ≡ 1 mod 4f gives
r ≥ 4f+1 > 2f ≥ x.]

So d = v_r(|S|) ≥ 1 > 0 = v_r(x) for the X-stable maximal pair
([P₁],[P₂]), and Theorem D/D′ excludes S — provided r exists.

**Zsygmondy exceptions.** A primitive prime divisor of p^{hf}−1 fails to
exist only for p^{hf} = 2⁶ (the case hf = 2, p+1 a power of 2 cannot
occur since h ≥ 4... for h ≥ 4, hf ≥ 4, and the unique exception with
exponent ≥ 3 is 2⁶). p^{hf} = 2⁶ forces p = 2, and:
  h = 6, f = 1: G₂(2) — not simple; G₂(2)′ ≅ PSU(3,3) is
    machine-certified (sweep J). G₂(q) with p = 2 and f ≥ 2 has hf ≥ 12:
    no exception.
  h = 2n = 6, f = 1: Sp(6,2) — machine-certified (sweep J3).
  h = 12, 18, 30: hf = 6 impossible.
No other case arises (B_n with q odd has p ≠ 2; C₂ requires p odd here).
∎

*Certificates doubling as spot checks:* Sp(6,2) = O(7,2), Sp(4,5) =
O(5,5), G₂(3), Sp(4,4)-adjacent cases and all rank-2 groups in the
machine range appear in the sweep J3 log with exactly the predicted
obstruction primes.

---

## Theorem 3 (HITLIST item 2). Let S = A_n, n ≥ 5. Then S is excluded,
for every k ≥ 1 and every X.

**Proof.** For n ≤ 14 this is machine-certified (sweeps J, J5; n = 6,
whose exceptional outer automorphisms fuse classes, is handled there
with all four X). Assume n ≥ 15, so Aut(A_n) = S_n and x | 2.

Let p be the largest prime with p ≤ n. For m < n/2 write
M_m := (S_m × S_{n−m}) ∩ A_n, of order m!(n−m)!/2, and for n even write
I := (S_{n/2} wr S_2) ∩ A_n, of order (n/2)!² (half of 2·(n/2)!²).

*Maximality.* Each M_m (1 ≤ m < n/2) is a maximal subgroup of A_n, and I
is maximal for n even outside a finite list of small exceptions (the
classical one being n = 8, where I < AGL(3,2)); all exceptions have
n ≤ 14, hence lie in the machine base [Liebeck–Praeger–Saxl, *A
classification of the maximal subgroups of the finite alternating and
symmetric groups*, J. Algebra 111 (1987)].

*Stability.* Conjugation by any element of S_n preserves the partition
shape {m, n−m} (resp. the block structure), and each shape is a single
A_n-class; since n ≠ 6, Aut(A_n) = S_n, so every class [M_m] and [I] is
X-stable for every X.

*Valuation.* For any two distinct classes [U], [V] among
{M_m : n−p < m < n/2} ∪ {I if n even and n/2 < p}:
v_p(|A_n|) = v_p(n!) = 1 (since n/2 < p ≤ n, by Bertrand), while
v_p(|U|) = v_p(|V|) = 0: for M_m both parts satisfy m < n/2 < p and
n−m < p (as m > n−p), and for I both blocks have size n/2 < p. Also
p ≥ 3 gives v_p(x) ≤ v_p(2) = 0. So d = 1 > 0 = v_p(x), and Theorem
D/D′ applies — provided two such classes exist.

*Existence of two classes.* The count of admissible intransitive m is
⌈n/2⌉ − 1 − (n−p) = p − ⌊n/2⌋ − 1, plus one for I when n is even. So two
classes exist whenever p ≥ n/2 + 3 (n even: one intransitive + I
suffices already for p ≥ n/2 + 2; n odd: need p ≥ (n+5)/2). By Nagura's
theorem (a prime in (x, 6x/5] for x ≥ 25), for n ≥ 31 there is a prime
p ∈ (5n/6, n], and 5n/6 > n/2 + 3 for n > 18. For 15 ≤ n ≤ 30 one
checks directly that the largest prime ≤ n satisfies the bound
(p = 13, 13, 17, 17, 19, 19, 19, 19, 23, 23, 23, 23, 23, 29, 29, 29 for
n = 15, …, 30; every value satisfies p ≥ n/2 + 3). The numerical receipt
sweepL2_an_arith.log verifies the two-class count for all 12 ≤ n ≤ 10⁴
with zero failures. ∎

---

## Theorem 4 (HITLIST item 5, part I: twisted groups of twisted rank ≥ 2).
Let S be one of
  PSU(n,q) (n ≥ 4),  PΩ⁻(2n,q) = ²D_n(q) (n ≥ 4),  ³D₄(q),  ²E₆(q),
  ²F₄(q) (q = 2^f, f odd ≥ 3).
Then S is excluded, for every k ≥ 1 and every X.

**Proof.** These are exactly the twisted types whose twisted BN-pair rank
is ≥ 2, so S has at least two classes of maximal parabolic subgroups
P₁, P₂ (stabilizers of the two smallest-dimensional types of vertices of
the twisted building; for ³D₄ and ²F₄, the two parabolic classes of the
rank-2 BN-pair). Maximal parabolics are maximal subgroups exactly as in
Theorem 2 (Tits; [Carter, Thm. 8.3.2, 8.4.3], valid for the twisted
BN-pairs).

*Stability.* For every twisted type the group of automorphisms is
Inndiag(S) extended by the (cyclic) group of field automorphisms — there
are **no** graph automorphisms: the twisted Dynkin diagram (type BC/B/C
for ²A, B for ²D, G₂-shape for ³D₄, F₄-shape for ²E₆, and the rank-2
²F₄ pair, whose two parabolics have non-isomorphic Levi factors ²B₂(q)
and SL₂(q)) admits no symmetry that an automorphism could induce
[Gorenstein–Lyons–Solomon, *The Classification of the Finite Simple
Groups, Number 3*, Thm. 2.5.12]. Field and diagonal automorphisms act on
the twisted building preserving types of vertices. Hence every parabolic
class is X-stable for every X.

*The obstruction prime.* Choose the exponent h and the Zsygmondy prime
r | p^{hf·(order of twist as needed)} − 1 per type as follows; in each
case r has ord_r(p) = e for the stated e, r | |S|, and r divides neither
|P₁| nor |P₂|:

- **²A_{n−1} = PSU(n,q), n odd.** e = 2nf, so r | Φ_{2n}(q) | q^n + 1,
  which divides |SU(n,q)| = q^{n(n−1)/2}∏_{i=2}^{n}(q^i − (−1)^i) (the
  i = n factor). The Levi factor of P_i (i = 1, 2) is a central product
  of GL_i(q²) and GU(n−2i, q): its p′-order is a product of factors
  q^{2j}−1 (j ≤ 2) and q^j − (−1)^j (j ≤ n−2), all of which divide
  p^m − 1 with m ≤ max(4f, 2(n−2)f) < 2nf. By primitivity r divides
  none of them.
- **²A_{n−1} = PSU(n,q), n even.** e = 2(n−1)f, r | Φ_{2(n−1)}(q) |
  q^{n−1} + 1 (the i = n−1 factor, n−1 odd). Levi factors as above:
  their cyclotomic factors have exponents ≤ max(4f, 2(n−3)f, (n−2)f)
  < 2(n−1)f for n ≥ 4 (the GU(n−2i,q) part contributes q^j + 1 only for
  odd j ≤ n−3).
- **²D_n(q), n ≥ 4.** e = 2nf, r | Φ_{2n}(q) | q^n + 1, which divides
  |²D_n(q)|·d = q^{n(n−1)}(q^n+1)∏_{i=1}^{n−1}(q^{2i}−1). The Levi of
  P_i (i = 1, 2) is GL_i(q) × O⁻(2(n−i), q)-type: cyclotomic exponents
  ≤ max(2f, 2(n−1)f) < 2nf.
- **³D₄(q).** e = 12f, r | Φ₁₂(q) = q⁴−q²+1, which divides
  q⁸+q⁴+1 = Φ₃(q)Φ₆(q)Φ₁₂(q)·… — precisely, q⁸+q⁴+1 =
  (q⁴+q²+1)(q⁴−q²+1) — hence r | |³D₄(q)| =
  q^{12}(q⁸+q⁴+1)(q⁶−1)(q²−1). The two Levi factors are SL₂(q³)·(q−1)
  and SL₂(q)·(q³−1) (mod centers): p′-orders divide (q⁶−1)(q−1) and
  (q²−1)(q³−1), exponents ≤ 6f < 12f.
- **²E₆(q).** e = 18f, r | Φ₁₈(q) | q⁹ + 1, which divides |²E₆(q)|·d =
  q^{36}(q^{12}−1)(q⁹+1)(q⁸−1)(q⁶−1)(q⁵+1)(q²−1). The four maximal
  parabolic classes correspond to the four ⟨τ⟩-orbits of nodes of E₆
  (τ the order-2 symmetry): {2}, {4}, {1,6}, {3,5}; removing them
  leaves the τ-stable subdiagrams A₅, A₂×A₁×A₂, D₄, A₂+A₁+A₁ with
  induced twists, so the Levi derived groups are SU(6,q),
  SL₂(q)×SL₃(q²), ²D₄(q) = Spin⁻₈(q)-type, and SL₃(q)×SL₂(q²).
  Their cyclotomic exponents are ≤ 10f (from q⁵+1 in SU(6,q)), 6f, 8f
  (from q⁴+1), 4f respectively — all < 18f. Any two classes serve as
  P₁, P₂.
- **²F₄(q), q = 2^f, f odd ≥ 3.** e = 12f, r | Φ₁₂(q) | q⁶ + 1, which
  divides |²F₄(q)| = q^{12}(q⁶+1)(q⁴−1)(q³+1)(q−1). The two Levi
  derived groups are ²B₂(q) ≅ Sz(q) and SL₂(q) [GLS3, §2.9; Malle]:
  p′-orders divide (q²+1)(q−1)² and (q²−1)(q−1), exponents ≤ 4f < 12f.
  (²F₄(2) is not simple; its derived group, the Tits group, is
  certified in the sporadic sweep M.)

*r ∤ x.* In every case x divides d_S·|field part| with the diagonal
order d_S | q+1 (²A: d_S = gcd(n, q+1); ²D: gcd(4, q^n+1); ²E₆:
gcd(3, q+1)) or d_S = 1 (³D₄, ²F₄), and field part of order 2f (²A, ²D,
²E₆), 3f (³D₄), f (²F₄). Since r ≡ 1 (mod e) and e ≥ 2nf ≥ 8f (²A n≥4,
²D), 12f (³D₄, ²F₄), 18f (²E₆), we get r > e ≥ field-part order, so
r does not divide the field part; and if r | d_S then r | q^m ± 1 with
m ≤ n forces ord_r(p) ≤ 2nf... precisely: r | q+1 would give
ord_r(p) | 2f < e, and r | gcd(4, ·) is impossible for the odd prime
r > 4. Hence v_r(x) = 0, while d = v_r(|S|) ≥ 1. Theorem D/D′ applies
to ([P₁], [P₂]).

**Zsygmondy exceptions.** r fails to exist only if p^e = 2⁶ or e = 2.
Here e ≥ 6f ≥ 6 always, and e = 6 occurs only for ²A₃ = PSU(4,q) with
f = 1 (e = 2(n−1)f = 6): then p^6 = 2^6 forces S = PSU(4,2), which is
in the machine base (|PSU(4,2)| = 25920 < 5·10⁵, sweeps J/K). For
²A₄ = PSU(5,q): e = 2nf = 10f ≥ 10 ≠ 6. No other case reaches
p^e = 2⁶. ∎

---

## Theorem 5 (HITLIST item 5, part II: twisted rank one).
Let S be one of
  PSU(3,q) (q ≥ 3),  Sz(q) = ²B₂(q) (q = 2^f, f odd ≥ 3),
  ²G₂(q) (q = 3^f, f odd ≥ 3).
Then S is excluded, for every k ≥ 1 and every X.

**Proof.** Each group has a single class of parabolic subgroups — the
Borel subgroup B = N_S(Q), Q ∈ Syl_p(S) — which is a **maximal**
subgroup of S (rank-one BN-pair; [Carter, Thm. 8.3.2]) and whose class
is X-stable for every X (Sylow normalizers form one class stable under
all automorphisms). In each case we pair it with a second X-stable
maximal class avoiding a Zsygmondy prime.

- **PSU(3,q), q ≥ 8.** |S| = q³(q³+1)(q²−1)/d, d = gcd(3, q+1);
  |B| = q³(q²−1)/d. Let V be the stabilizer of a nonisotropic point of
  the natural unitary geometry: V ≅ GU(2,q)·(scalar quotient), of order
  q(q−1)(q+1)²/d. V is maximal for q ≥ 3, q ≠ 5 (Mitchell, Hartley;
  [Bray–Holt–Roney-Dougal, Table 8.5], class C₁), and nonisotropic
  points form a single S-orbit whose stabilizer class every semilinear
  automorphism preserves — X-stable for every X. Take r a primitive
  prime divisor of p^{6f}−1 (exists: p^{6f} = 2⁶ would force q = 2,
  not simple; q = 4, 8 have 6f = 12, 18): r | Φ₆(q) = q²−q+1, which
  divides (q³+1)/(q+1) | |S|. Since ord_r(p) = 6f: r ∤ q(q²−1) = the
  p′-content bound of |B|·d, and r ∤ q(q−1)(q+1)² ⊇ |V|·d-content.
  Also x | d·2f, and r ≡ 1 (mod 6f) gives r > 2f, while r | d | q+1
  would force ord_r(p) | 2f < 6f. So d_val := v_r(|S|) ≥ 1 > 0 =
  v_r(x). Theorem D/D′ applies. For q = 3, 4, 5, 7 (in particular the
  maximality exception q = 5) S is in the machine base: |PSU(3,q)| ≤
  5663616 < 1.05·10⁷ (sweeps J, J3 — U3(3), U3(4), U3(5), U3(7), U3(8)
  all logged).
- **Sz(q), f odd ≥ 3.** |S| = q²(q²+1)(q−1); |B| = q²(q−1). Let
  V := D_{2(q−1)}, the normalizer of a "split torus" C_{q−1}: maximal
  by Suzuki's classification of subgroups of Sz(q) [Suzuki 1962, Thm.
  9], one class, stable under Aut(S) = S⋊C_f (the cyclic subgroups of
  order q−1 form one class; normalizers follow). Let r be a primitive
  prime divisor of 2^{4f}−1 (exists: 4f ≥ 12): r | Φ₄(q) = q²+1, so
  r | |S|, r ∤ |B|, r ∤ |V| = 2(q−1). x | f and r ≡ 1 (mod 4f) > f.
  So v_r(|S|) ≥ 1 > 0 = v_r(x). (Sz(8) is also in the machine base,
  sweep J4.)
- **²G₂(q), f odd ≥ 3.** |S| = q³(q³+1)(q−1); |B| = q³(q−1). Let
  V := C_S(ι) ≅ ⟨ι⟩ × PSL(2,q), ι an involution (one class of
  involutions in S, so [V] is Aut-stable), |V| = q(q²−1); V is maximal
  [Kleidman 1988, maximal subgroups of ²G₂(q); also Levchuk–Nuzhin].
  Let r be a primitive prime divisor of 3^{6f}−1 (exists: 6f ≥ 18):
  r | Φ₆(q) = q²−q+1 | (q³+1)/(q+1), so r | |S|; ord_r(3) = 6f rules
  out r | q³(q−1) = |B| and r | q(q²−1) = |V|. x | f < r. So
  v_r(|S|) ≥ 1 > 0 = v_r(x). (²G₂(3) is not simple: ²G₂(3)′ ≅
  PSL(2,8) is covered by Theorem 1.)

In each case Theorem D (k ≥ 2) and D′ (k = 1) exclude S. ∎

---

## Theorem 6 (HITLIST item 5, part III: untwisted types with graph
symmetry). Let S be one of
  PSL(n,q) (n ≥ 3),  PΩ⁺(2n,q) = D_n(q) (n ≥ 4),  E₆(q),
  Sp(4,q) (q = 2^f, f ≥ 2),  F₄(q) (q = 2^f),  G₂(q) (q = 3^f).
Then S is excluded, for every k ≥ 1 and every X.

**Conventions.** Δ is the set of nodes of the Dynkin diagram; Q_J ⊇ B
(J ⊆ Δ) the standard parabolic whose Levi is generated by the torus and
the root subgroups of J, so the maximal parabolic P_i = Q_{Δ∖{i}}. The
*graph part* of X is the image of X in the quotient of Out(S) by its
inndiag–field part: for PSL(n,q) (n ≥ 3), D_n (n ≥ 5) and E₆ it is a
subgroup of C₂ = ⟨δ⟩; for D₄ a subgroup of S₃ (triality); for
Sp(4,2^f), F₄(2^f), G₂(3^f), Out(S) is cyclic of order 2f generated by
the exceptional graph-field automorphism ρ with ρ² = φ_p [GLS3, Thm.
2.5.12], and "X has graph part" means the image of X in Out(S) is not
contained in ⟨ρ²⟩. An automorphism acts on the building permuting
vertex types by a diagram symmetry; automorphisms with trivial graph
part preserve every type. Since property P and the criterion of Theorem
D are invariant under replacing X by X^a (a ∈ Aut(S)) — conjugating
G ≤ X wr S_k by (a, …, a) — we may normalize the graph part inside
Aut(S) up to conjugacy; for D₄ this lets us assume a C₂ graph part is
generated by the symmetry fixing nodes 1, 2 and swapping 3, 4.

**Case A: X with trivial graph part.** Every parabolic class is
X-stable, and the Theorem 2 argument applies verbatim with these data:

- PSL(n,q), pair ([P₁], [P₂]), r a primitive prime divisor of
  p^{nf}−1: r | Φ_n(q) | q^n−1 | |S|·d; Levi factors GL_{n−1}(q)-type
  and GL₂×GL_{n−2}-type have cyclotomic exponents ≤ (n−1)f < nf;
  x | 2df with d = gcd(n, q−1), and r ≡ 1 (mod nf) rules out r | 2f
  (as nf > 2f... precisely r > nf ≥ 3f > 2f) and r | d (else r | q−1,
  ord_r(p) | f). Zsygmondy exceptions p^{nf} = 2⁶: (n,f) = (3,2) is
  PSL(3,4) — machine base (sweeps J, K, all twelve X) — and
  (n,f) = (6,1), S = PSL(6,2): take instead r = 31 (= Φ₅(2),
  ord₃₁(2) = 5) and the pair ([P₂], [P₃]) with Levi types GL₂×GL₄ and
  GL₃×GL₃: 31 ∤ |P₂||P₃| since the exponents there are ≤ 4 < 5, while
  v₃₁(|PSL(6,2)|) = 1 and x | 2.
- D_n(q), n ≥ 4, pair ([P₁], [P₂]) (stabilizers of a singular point
  and a singular line), r primitive for p^{2(n−1)f}−1: r | Φ_{2n−2}(q)
  | q^{2(n−1)}−1 | |S|·d; Levi factors D_{n−1} and A₁×D_{n−2}-type
  have exponents ≤ max((n−1)f, 2(n−2)f) < 2(n−1)f; x | 8f (d_S ≤ 4,
  field f, and even throwing in the graph order ≤ 6 for n = 4:
  x | 24f) and r ≡ 1 (mod 2(n−1)f) with 2(n−1) ≥ 6 gives r > 6f, and
  r ∤ 24 since r ≡ 1 (mod 6) forces r ≥ 7, r ∉ {2,3}; for n ≥ 5,
  r > 8f ≥ x directly. Zsygmondy exception p^{2(n−1)f} = 2⁶:
  (n, f) = (4, 1), S = Ω⁺(8,2) — handled for all X in Case B3 below.
- E₆(q): see Case B4 — the pair used there is stable for every X.
- Sp(4,2^f): pair ([P₁], [P₂]), r primitive for 2^{4f}−1 (exists:
  4f ≥ 8): r | Φ₄(q) = q²+1 | |S| = q⁴(q²−1)(q⁴−1); Levi factors
  Sp₂(q) and GL₂(q) have exponents ≤ 2f < 4f; x | f here (trivial
  graph part means image in ⟨ρ²⟩ = ⟨φ⟩ ≅ C_f), r > 4f > f.
- F₄(2^f): pair ([P₁], [P₂]), r primitive for 2^{12f}−1: r | Φ₁₂(q);
  all proper Levis (types B₃, C₃, A₂×A₁, A₁×A₂) have exponents
  ≤ 6f < 12f; x | f < r. (This completes the p = 2 case excluded from
  Theorem 2 by hypothesis.)
- G₂(3^f): pair ([P₁], [P₂]), r primitive for 3^{6f}−1: r | Φ₆(q);
  Levis of type A₁ have exponents ≤ 2f < 6f; x | f < r. (The p = 3
  case excluded from Theorem 2.)

**Case B: X with nontrivial graph part.** Throughout, novelty classes
are standard parabolics Q_J handled by Lemma P (THEOREM.md §2): each
[Q_J] below is X-stable because J is invariant under the relevant
diagram symmetry (an automorphism with graph part γ maps the class of
Q_J to the class of Q_{γ(J)}), and its proper parabolic overgroups fall
into nontrivial γ-orbits, so hypothesis (b) of Lemma P holds and
B_{Q_J} is maximal in G by Lemma B. Pairs of distinct classes are
non-conjugate by Lemma C. The primes r are those of Case A unless
stated; r-avoidance for a novelty Q_J follows from the Levi order of
Q_J itself (its p′-part is a product of cyclotomic factors of the Levi
of type J, plus q−1 powers), as listed.

**B1. PSL(3,q), q ≥ 5** (q ≤ 4 machine: L3(2), L3(3) sweep J; L3(4)
sweeps J/K for all twelve X, including all graph-containing ones).
Pair: [B] (novelty; proper overgroups P₁, P₂ are swapped by δ, which
exchanges points and lines of PG(2,q)) and [N], N := N_S(T) the
normalizer of a maximal split torus, N ≅ ((q−1)²/d).S₃, maximal for
q ≥ 5 [Mitchell 1911, Hartley 1925; BHRD Table 8.3, class C₂], one
class, preserved by every automorphism (δ maps maximal split tori to
maximal split tori). r = ppd(p^{3f}−1) | Φ₃(q) = q²+q+1: r ∤ |B| =
q³(q−1)²/d (primitivity), r ∤ |N| = 6(q−1)²/d (r ≡ 1 mod 3 forces
r ≥ 7 > 6... r ∤ 6, r ∤ q−1); v_r(|S|) ≥ 1. x | 2df (d = gcd(3,q−1)):
r > 3f rules out r | 2f (3f+1 > 2f) and r = 3 ∤; r | d = 3
impossible. Zsygmondy exception p^{3f} = 2⁶ is L3(4): machine.

**B2. PSL(n,q), n ≥ 4.** For n = 4: pair ([P₂], [Q_{{2}}]): node 2 is
δ-fixed, so [P₂] is an X-stable *maximal* class (Levi A₁×A₁, exponents
≤ 2f); Q_{{2}} is the stabilizer of an incident point–hyperplane flag,
with proper overgroups P₁, P₃ swapped by δ (Lemma P), Levi A₁ + torus,
exponents ≤ 2f. r = ppd(p^{4f}−1) | Φ₄(q): avoids both (2f < 4f);
v_r(|S|) ≥ 1, and x | 2df (d = gcd(4, q−1)): r ≡ 1 (mod 4f) rules out
r | 2f and r | d (r > 4 or ord argument). No Zsygmondy exception
(4f ≠ 6, 2^{4f} = 2⁶ impossible).
For n ≥ 5: pair of novelties ([Q_{J₁}], [Q_{J₂}]), J₁ := Δ∖{1, n−1},
J₂ := Δ∖{2, n−2} — the stabilizers of an incident point–hyperplane
flag and an incident line–(n−2)-space flag. Both J_i are δ-invariant
({1,n−1}, {2,n−2} are δ-orbits of node pairs); proper overgroups of
Q_{J₁} are P₁, P_{n−1} (swapped by δ), of Q_{J₂} are P₂, P_{n−2}
(swapped; distinct since n ≥ 5... for n = 5, P₂ and P₃ are distinct
classes). Levi types: blocks (1, n−2, 1) i.e. GL_{n−2} + torus,
exponents ≤ (n−2)f; blocks (2, n−4, 2), exponents ≤ max(2, n−4)f.
r = ppd(p^{nf}−1) avoids both; v_r ≥ 1 > 0 = v_r(x) as in Case A.
Zsygmondy exception (n,f) = (6,1): PSL(6,2) — take r = 31 = Φ₅(2)
again: the two Levi orders involve only GL₄(2), GL₂(2) factors and
2-powers, so 31 divides neither; v₃₁ = 1 > 0 = v₃₁(2). ((n,f) = (3,2)
does not arise here.)

**B3. D_n(q).** For n ≥ 5 the graph part is ≤ C₂ swapping the two
spinor nodes n−1, n and fixing 1, …, n−2: the Case A pair ([P₁],[P₂])
is X-stable for *every* X, and Case A's argument goes through
unchanged (its x-bound already allowed the graph factor). For n = 4:
if the graph part is trivial or (after the normalization above) the
C₂ fixing nodes 1, 2, the pair ([P₁], [P₂]) is X-stable and Case A
applies. If the graph part contains a triality (C₃ or S₃), take the
pair ([P₂], [Q_{{2}}]): node 2 is fixed by all of S₃, so [P₂] is an
X-stable maximal class (Levi A₁×A₁×A₁, exponents ≤ 2f), and Q_{{2}}
(Levi A₁ + torus, exponents ≤ 2f) has proper overgroups Q_K,
{2} ⊊ K ⊊ Δ, namely Q_{{1,2}}, Q_{{2,3}}, Q_{{2,4}} and P₄, P₃, P₁,
falling into the two regular ⟨triality⟩-orbits induced by the
permutation of the end nodes {1,3,4} — none X-stable (Lemma P).
r = ppd(p^{6f}−1) | Φ₆(q): avoids both classes (2f < 6f);
v_r(|S|) ≥ 1; x | 24f and r ≡ 1 (mod 6f) gives r ∤ x as in Case A.
*Zsygmondy exception (f = 1, p = 2): S = Ω⁺(8,2).* Here x | 24; take
r = 5 = Φ₄(2), so v₅(|S|) = v₅(2^{12}(2⁶−1)(2⁴−1)²(2²−1)) = 2 and
v₅(x) ≤ v₅(24) = 0. Triality case: pair ([P₂], [Q_{{2}}]): both Levi
orders are {2,3}-numbers (SL₂(2)-factors and tori of order 1), so
d = 2 − 0 − 0 = 2 > 0. Trivial/C₂ case: pair ([P₁], [P₂]):
v₅(|P₁|) = v₅(|SL₄(2)|) = 1 (Levi D₃ ≅ A₃), v₅(|P₂|) = 0, so
d = 2 − 1 − 0 = 1 > 0. Theorem D/D′ applies in both cases.

**B4. E₆(q) (all X).** The diagram involution fixes nodes 2 and 4
(Bourbaki numbering: δ swaps 1↔6, 3↔5). Pair ([P₂], [P₄]): two
X-stable classes of *maximal* parabolics for every X. r =
ppd(p^{12f}−1) | Φ₁₂(q) | |S|·d: the Levi of P₂ has type A₅
(exponents ≤ 6f), that of P₄ type A₂×A₁×A₂ (≤ 3f), both < 12f.
x | 2df (d = gcd(3, q−1)) ≤ 6f < r. No Zsygmondy exception
(p^{12f} = 2⁶ impossible). Note this simultaneously covers Case A
for E₆.

**B5. Sp(4,q), q = 2^f, f ≥ 2, X with graph part.** (f = 1: Sp(4,2)
is not simple; its derived group A₆ is in the machine base.) Pair:
[B] (novelty: proper overgroups P₁, P₂ — the point and
totally-isotropic-line stabilizers — are swapped by ρ; Lemma P) and
[V], V := the fixed-point subgroup of ρ̃^f, where ρ̃ is the Steinberg
endomorphism of the ambient algebraic group with ρ̃² = φ₂ and
ρ̃^{2f} = F_q. Explicitly V = Sz(q) for f odd [Suzuki; BHRD Table
8.14] and V = Sp(4, 2^{f/2}) (subfield subgroup, index-2 field
extension) for f even [BHRD Table 8.14, class C₅]; V is maximal in
both cases. *Stability of [V]:* Aut(S) = Inn(S)⟨ρ⟩ with ρ = ρ̃|_S;
ρ̃ commutes with its own power ρ̃^f, so ρ(V) = V, and inner
automorphisms preserve [V] trivially — [V] is Aut-stable. *Primes:*
f odd, 2f ≠ 6: r = ppd(2^{2f}−1) | q+1: v_r(|S|) =
v_r((q²−1)(q⁴−1)) = 2·v_r(q+1) ≥ 2; v_r(|B| = q⁴(q−1)²) = 0;
v_r(|Sz(q)| = q²(q²+1)(q−1)) = 0 since gcd(q+1, q(q²+1)(q−1)) = 1
for q even; x | 2f < r. f = 3 (q = 8): r = 3: v₃(|Sp(4,8)|) =
v₃(63·4095) = 4 > 1 ≥ v₃(x | 6); v₃(|B|) = v₃(|Sz(8)|) = 0. f even:
r = ppd(2^{4f}−1) | q²+1 (exists, 4f ≥ 8): v_r(|S|) ≥ 1;
|Sp(4,√q·√q)|... |V| = q²(q−1)(q²−1)·(√q+1)(√q−1)-content — precisely
|Sp(4,q₀)| = q₀⁴(q₀²−1)(q₀⁴−1) with q₀² = q, whose cyclotomic
exponents are ≤ 2f < 4f, so v_r(|V|) = 0; v_r(|B|) = 0; x | 2f < r.
(Sp(4,4) doubles as the machine template: sweep K3's certified pair
(Borel, Sp(4,2)) at p = 5 = Φ₄(2)... = ppd(2⁴−1) and p = 17 =
ppd(2⁸−1) matches this construction exactly.)

**B6. F₄(q), q = 2^f, X with graph part.** ρ reverses the diagram
1−2⇒3−4 (swaps 1↔4, 2↔3). Pair of novelties ([Q_{J₁}], [Q_{J₂}]),
J₁ := {2,3}, J₂ := {1,4} — both ρ-invariant node sets. Proper
overgroups of Q_{J₁}: Q_{{1,2,3}} = P₄ and Q_{{2,3,4}} = P₁, swapped
by ρ; of Q_{J₂}: Q_{{1,2,4}} and Q_{{1,3,4}}, swapped by ρ (distinct
classes: distinct types). Lemma P applies to both. Levi types: B₂
(= Sp₄(q), exponents ≤ 4f) and A₁×A₁ (≤ 2f). r = ppd(2^{12f}−1) |
Φ₁₂(q): avoids both; v_r(|S|) ≥ 1; x | 2f < 12f < r. No exceptions.

**B7. G₂(q), q = 3^f, X with graph part.** ρ swaps the two nodes
(long ↔ short roots), ρ² = φ₃. Pair: [B] (novelty: overgroups P₁, P₂
swapped by ρ; Lemma P) and [V], V := Fix(ρ̃^f) exactly as in B5:
V = ²G₂(q) for f odd (maximal in G₂(q) [Kleidman 1988]; for f = 1,
V = ²G₂(3) ≅ PΓL₂(8) ≅ L₂(8):3, maximal in G₂(3) — ATLAS and
[Kleidman 1988]), and V = G₂(3^{f/2}) for f even (subfield, index-2
extension, maximal [Kleidman 1988]). [V] is Aut-stable by the same
commuting-endomorphism argument as B5 (Out(G₂(3^f)) = ⟨ρ⟩ ≅ C_{2f}).
*Primes:* f odd: r = ppd(3^{3f}−1) | Φ₃(q) = q²+q+1 (exists for all
f ≥ 1: p = 3 ≠ 2 excludes the 2⁶ exception; f = 1 gives r = 13 |
3³−1). Then r | q³−1 | q⁶−1 | |S| = q⁶(q⁶−1)(q²−1); r ∤ |B| =
q⁶(q−1)² (primitivity); r ∤ |²G₂(q)| = q³(q³+1)(q−1) since r | q³−1
and gcd(q³−1, q³+1) = 2 ∌ r; x | 2f and r ≡ 1 (mod 3f) gives
r ≥ 3f+1 > 2f, so v_r(x) = 0 < 1 ≤ v_r(|S|). f even:
r = ppd(3^{6f}−1) | Φ₆(q) = q²−q+1 | q³+1: r ∤ |B|; r ∤ |G₂(3^{f/2})|
= q³(q³−1)(q−1) (r | q³+1); x | 2f < 6f < r. (G₂(3) additionally
carries a full machine certificate for both X — sweep J3.)

In every case Theorem D (k ≥ 2) and Theorem D′ (k = 1) exclude S. ∎

---

## Status after this document

- Item 1 (PSL(2,q)): **complete** (Theorem 1).
- Item 2 (A_n): **complete** (Theorem 3).
- Item 4 (no-graph Lie types): **complete** (Theorem 2).
- Item 5 (graph-symmetric and twisted types): **complete**
  (Theorems 4, 5, 6 + Lemma P in THEOREM.md §2). Coverage check
  against CFSG: every simple group of Lie type is in Theorem 1
  (A₁), Theorem 2 (B_n n≥3 q odd; C_n n≥2 except Sp(4, 2^f); G₂
  p≠3; F₄ p≠2; E₇; E₈), Theorem 4 (²A_{n−1} n≥4, ²D_n, ³D₄, ²E₆,
  ²F₄), Theorem 5 (²A₂, ²B₂, ²G₂), or Theorem 6 (A_{n−1} n≥3, D_n,
  E₆, Sp(4,2^f), F₄ p=2, G₂ p=3); B_n q even ≅ C_n q even. A_n
  alternating: Theorem 3; sporadics + Tits: sweep M. All machine
  fallbacks (L3(4), PSU(4,2), small L2/L3/U3, A_{n≤14}, Sp(4,4),
  G₂(3), Sz(8), U3(q≤8), Sp(6,2), U3(3) = G2(2)′, A₆ = Sp(4,2)′,
  L2(8) = ²G₂(3)′) lie in the certified base |S| ≤ 1.05·10⁷. The two
  Zsygmondy exceptions above the base, PSL(6,2) and Ω⁺(8,2), are
  closed inside Theorem 6 with substitute primes (r = 31, r = 5).
