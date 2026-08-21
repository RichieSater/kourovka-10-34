# Mathematical yield and seminar outline

## Three-paragraph explanation

The theorem says that a finite group in which every pair of non-conjugate maximal subgroups factorizes the whole group must be soluble. After quotient inheritance and a minimal-counterexample argument, the unresolved case has a unique minimal normal subgroup $N=S^k$, with $S$ nonabelian simple, together with a transitive coordinate action inside an automorphism wreath product. The proof therefore has to rule out every multiplicity $k\ge 2$, not merely each fixed direct power.

The reusable step begins with an $X$-stable, self-normalizing class represented by $V<S$. Exact intersection and order follow from those two hypotheses; maximality of the ambient normalizer $B_V=N_G(V^k)$ additionally requires that $[V]$ be maximal in the stable-class poset and that $V$ be normally saturating. Under all four hypotheses, $B_VN=G$, $B_V\cap N=V^k$, and $|B_V|=|G/N|\,|V|^k$. Two distinct suitable classes produce non-conjugate maximal supplements. If property P held, their product would be $G$, so the subgroup-product formula would force a linearly growing $p$-part into $|G/N|$. The wreath embedding bounds that quotient by the coordinate outer automorphisms and $k!$; a fixed local valuation gap in $S$ contradicts this bound for every $k\ge 2$.

The classification work supplies one local pair and one obstruction prime for each nonabelian finite simple group. Ordinary stable maximal classes suffice in many families, while graph automorphisms sometimes fuse the obvious maximal parabolics; invariant flag parabolics restore a stable class and are the distinctive exceptional mechanism. The infinite-family arguments use cited order, Levi, automorphism, parabolic, and primitive-prime-divisor inputs; GAP certifies the designated finite and sporadic cases. Thus the transferable result is the local-to-all-$k$ supplement criterion, not the case ledger, and the structurally essential assumptions are exactly those that make the coordinate normalizers maximal and stable.
Li--Yang's subsequently submitted arXiv:2608.19478v1 treats the same theorem through a different product--socle lifting architecture, providing a direct comparison between two structural approaches to the monolithic branch.

## Twenty-minute seminar outline

- **0:00--2:00 — Problem and answer.** State property P and the solubility theorem; distinguish the prior almost-simple result from the new $S^k$, $k\ge2$, branch.
- **2:00--5:00 — Monolithic reduction.** Explain quotient inheritance, the unique minimal normal subgroup $S^k$, transitivity on factors, and the wreath-product quotient budget.
- **5:00--9:00 — Stable product normalizers.** From an $X$-stable, self-normalizing class $[V]$ that is maximal in the stable-class poset and normally saturating, construct $B_V=N_G(V^k)$; separate the hypotheses needed for supplement/intersection/exact order from those needed for maximality, then explain nonconjugacy.
- **9:00--13:00 — The all-$k$ obstruction.** Derive the subgroup-product divisibility condition and compare its linear valuation demand with the outer-automorphism and $k!$ supply.
- **13:00--15:00 — Worked $A_5$ example.** Use the $A_4$ and $S_3$ classes with $p=5$ to show the valuation gap and the uniform contradiction.
- **15:00--17:30 — Graph fusion.** Explain why fused maximal parabolics are unavailable and how invariant flag parabolics recover stable objects; show the projective-linear representative.
- **17:30--19:00 — CFSG coverage.** Display the family routing table, describe the fixed appendix template, and separate uniform arguments from finite certificates.
- **19:00--20:00 — Yield, subsequent work, and trust boundary.** Contrast the local-to-all-$k$ valuation principle with Li--Yang's later product--socle lifting architecture; state what ordinary mathematics, Lean, Rocq, GAP, and Python establish; and identify the external classifications and unclosed `PAR-NOVELTY` formalization boundary.
