# HIT LIST — road to "no counterexample exists" (Kourovka 10.34)

**Goal.** Prove: every finite group equal to the product of any two of its
non-conjugate maximal subgroups is soluble. Standing instruction from
Richie (2026-07-26): treat items 1–6 below as the work queue for this and
all future sessions until every box is checked. Keep this file current —
check items off with date + certificate/section reference.

**Method recap** (details: THEOREM.md). A minimal counterexample has socle
S^k inside X wr S_k, Inn(S) ≤ X ≤ Aut(S). Theorem D/D′: two X-stable
certified classes [V] ≠ [W] (maximal, or novelty with the Lemma B
hypotheses) with v_p(|S|) − v_p(|V|) − v_p(|W|) > v_p(|X/Inn|) kill S for
ALL k ≥ 1 at once. So the whole proof = for every simple S and every X,
exhibit one such pair. CFSG makes this: finitely many families + machine
base (done to |S| ≤ 1.05·10⁷, receipts in this directory).

## The list

- [x] **1. PSL(2,q), all q ≥ 4.** DONE 2026-07-26: FAMILY-PROOFS.md
  Theorem 1 (referee-grade, with Dickson/Huppert citations, both parity
  cases, Zsygmondy exception q=8 handled, small q pinned to machine
  logs). Receipts sweepL (q ≤ 10⁴, zero failures). Remaining work is
  LaTeX assembly only.

- [x] **2. Alternating A_n, n ≥ 5.** DONE 2026-07-26: FAMILY-PROOFS.md
  Theorem 3 (LPS-1987 maximality citation, Nagura interval for n ≥ 31,
  explicit prime table 15 ≤ n ≤ 30, n ≤ 14 machine-certified, receipts
  sweepL2 to n = 10⁴). Remaining work is LaTeX assembly only.

- [x] **3. Sporadics + Tits group (27 groups).** DONE 2026-07-26,
  sweepM_sporadic.log: all 21 remaining groups (M24, J3, J4, HS, McL,
  Co1–3, Suz, He, Ru, ON, Fi22, Fi23, Fi24′, HN, Ly, Th, B, M, ²F₄(2)′)
  excluded via ctbllib maximal-order pairs — e.g. M: (59:29, 41:40) at
  p = 71; B at p = 31; Fi24′ at p = 23. |Out| = 2 groups used
  unique-order classes (automatically Aut-stable). Note: the criterion
  needs only the two used subgroups to be maximal + stable, not
  completeness of the Maxes list. Earlier: M11, M12, M22, M23, J1, J2
  (sweeps J/J2/J3/J6).

- [x] **4. Lie type rank ≥ 2, no graph symmetry.** DONE 2026-07-26:
  FAMILY-PROOFS.md Theorem 2 (referee-grade: parabolic-pair stability
  via building/type-preservation, per-type Levi exponent bounds h_i < h,
  r ≡ 1 mod hf kills v_r(x), full Zsygmondy-exception analysis — only
  Sp(6,2) and G2(2)′ = U3(3), both machine-certified). Covers C_n
  (n ≥ 2, p odd if n = 2), B_n, G2 (p≠3), F4 (p≠2), E7, E8. Remaining
  work is LaTeX assembly only.

- [x] **5. Lie type with graph symmetry + twisted groups.** DONE
  2026-07-26: FAMILY-PROOFS.md Theorems 4 (twisted rank ≥ 2: PSU n ≥ 4,
  ²D_n, ³D₄, ²E₆, ²F₄), 5 (twisted rank 1: U3, Sz, ²G₂ — maximal pairs
  only, no novelties needed), 6 (untwisted with graph: PSL n ≥ 3, D_n,
  E₆, Sp4/F4 p=2, G2 p=3), plus Lemma P (THEOREM.md §2: parabolic
  novelties satisfy all Lemma B hypotheses structurally — no
  computational saturation needed). Key simplifications found: twisted
  groups have NO graph automorphisms, so parabolic pairs are
  automatically stable (³D₄ and Ree, the feared cases, are easy); E₆
  and D_n (n ≥ 5) have graph-fixed nodes, so maximal parabolic pairs
  work for every X; only PSL, D₄-triality, Sp4/F4/G2 wrong-char need
  novelties or Fix(√Frobenius) classes (Sz(q) ≤ Sp(4,q), ²G₂ ≤ G₂,
  subfield subgroups — Aut-stability via commuting endomorphisms).
  Zsygmondy exceptions above machine base: L6(2) (r = 31) and Ω⁺(8,2)
  (r = 5), both closed in-prose. Receipt: sweepN_item5_arith.py/log —
  7892 instances (all families, q up to 200–3000, rank up to 25), zero
  failures, exceptions exactly the documented 7. Remaining work is
  LaTeX assembly only.

- [x] **6. k = 1 (almost simple case).** Done 2026-07-25: Theorem D′
  (THEOREM.md §3) — same criterion, t | x, no k! term; re-proves
  Tikhonenko–Tyutyanov below the machine bound; the family arguments
  above cover k = 1 uniformly with k ≥ 2.

## Machine base (done — certificates in this directory)

- All 47 simple |S| < 5·10⁵: sweeps J/J2/J4 + novelty K (+K2 saturation);
  receipt verify_coverage.log.
- All 51 simple 5·10⁵ ≤ |S| ≤ 1.05·10⁷: sweep J3 (+J5 A11–A14, J6) +
  novelty K3 (Sp(4,4)), K4 (L5(2)); coverage receipt
  verify_coverage_big.log (canonical list from gen_biglist.g, matched
  by order to J3 verdicts, survivors re-checked against K3/K4).
- Exhaustive ground truth (zero counterexamples, zero top-supp failures):
  k=2 all |S| < 5·10⁵ (C, F); k=3 same range (G; U3(5)³ verification
  still running, redundant); k=4 small socles (I); order ≤ 2000 (A);
  perfect groups ≤ 2·10⁶ (B, B2).

## Definition of done

Every box checked; a paper draft assembling: reduction (§1), machinery
(§2–3), machine base (§4 + logs), family proofs (items 1–5), with every
machine claim backed by a committed log. Then: submit, and update the
Kourovka Notebook entry.
