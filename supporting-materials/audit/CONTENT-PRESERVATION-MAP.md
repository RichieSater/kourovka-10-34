# Baseline-to-revision content-preservation map

**Baseline:** commit `35942dc7cf00cd145434661167de9f2224241717`
**Baseline source:** `supporting-materials/paper/kourovka1034.tex`
**Audit date:** 2026-08-20

This audit answers one question: after the architecture revision moved material
out of the body, where did every substantive mathematical or verification
component go? It is a preservation record, not a new mathematical claim and
not a release designation.

## Audit method and result

The baseline source was extracted directly from the frozen commit and compared
with the working manuscript by section, labeled environment, proof block,
bibliography key, finite-inventory datum, family-exception route, and formal or
computational boundary statement.

- All **22 labeled mathematical environments** from the baseline remain under
  the same labels. Their hypotheses and conclusions are unchanged.
- All **29 non-structural and structural labels** that still name mathematical
  content remain. The four retired labels (`sec:machine`, `sec:families`,
  `sec:proof`, and `tab:roadmap`) named old locations, not deleted claims; the
  map below gives their replacements.
- Every baseline proof obligation is now in the body, Appendix A, Appendix B,
  or Appendix C. No family or finite case was dropped.
- Command lines, package pins, exact receipt names, hashes, random-source
  controls, and sweep-label mechanics remain in the repository supplement, as
  required by the controlling architecture plan. They were relocated rather
  than discarded.
- The bibliography still contains every baseline entry. The two entries that
  had temporarily become uncited during reorganization, `CTblLib` and
  `RoneyDougal2021`, are again cited at the claims they support.

## Section-by-section map

| Baseline location | Preserved content | Revised location | Preservation status |
|---|---|---|---|
| Abstract and Introduction | Problem, answer, theorem, history, priority boundary, relation to maximal factorizations | Abstract and Section 1 | Retained and compressed around the principal mechanism |
| Introduction, “Strategy” | Minimal counterexample, stable product normalizers, all-multiplicity valuation contradiction | Section 1, “Proof mechanism”; Sections 2--4 | Retained; the three-paragraph mechanism now precedes verification detail |
| Introduction, classification inventory | CFSG routes, finite ranges, family exceptions, ordinary versus graph-fusion cases | Section 6; Appendices A and B | Retained and made claim-centered |
| Introduction, computer verification | Exact Lean/Rocq/GAP/Python allocation and trust boundary | Appendix C | Restored at claim level; operational reproduction detail is in the supplement |
| Introduction, proof/verification roadmap | Five logical layers and their evidence | Section 6 coverage table; Appendix C trust tables and exact-interface paragraphs | Retained in three reader-facing tables with the conceptual and computational trust layers separated |
| Section 2, Reduction to socle analysis | `lem:conj`, `lem:quot`, `prop:min`, coordinate normalization and wreath bound | Section 2 | Retained; normalization and the quotient divisor are now named lemmas with ordinary proofs |
| Section 3, Product supplements | `def:poset`, `rem:maxauto`, `lem:A`, `lem:B`, `lem:C`, `lem:P` | Section 3 | Statements and proofs retained; `cor:supplement-engine` packages their outputs |
| Section 4, Divisibility criterion | `thm:D`, `rem:crit`, `thm:Dprime` and proofs | Section 4 and Appendix A | Retained; the unused detailed $k=1$ proof moved to Appendix A, while its theorem statement remains in Section 4 |
| Section 5, Machine base | Finite inventories, closure records, ordinary and novelty witnesses, saturation, sporadic/Tits evidence, arithmetic receipts | Appendix B | Restored in full mathematical detail |
| Section 5, environment and sweep operations | Versions, patch, seed, scripts, receipts, package and mutation mechanics | `supporting-materials/README.md` and evidence manifests | Preserved outside the article by explicit plan requirement |
| Section 6.1, projective rank one | `thm:psl2` proof | Appendix A, `app:psl2` | Retained under the fixed family-audit template |
| Section 6.2, alternating groups | `thm:an` proof | Section 5, ordinary representative application | Retained in the body because it teaches the normal workflow |
| Section 6.3, Lie type without graph symmetry | `thm:nograph` proof | Appendix A, `app:nograph` | Retained under the fixed family-audit template |
| Section 6.4, twisted rank at least two | `thm:twisted2` proof | Appendix A, `app:twisted2` | Retained under the fixed family-audit template |
| Section 6.5, twisted rank one | `thm:twisted1` proof | Appendix A, `app:twisted1` | Retained under the fixed family-audit template |
| Section 6.6, graph symmetry | `thm:graph` proof, including every B1--B7 branch | Section 5 (`prop:psl-flag`) and Appendix A, `app:graph` | Projective flag branch extracted to body; every B1--B7 obligation is retained in the new summary table or the triality, flag, and graph--field detail paragraphs |
| Section 7, main proof | `prop:coverage`, proof of the main theorem, supplementary almost-simple reproof, stronger monolithic remark | Section 6 and Appendix A | Main proof and monolithic remark remain in Section 6; the unused supplementary almost-simple proof is preserved in Appendix A |
| Data and declarations | Data location, funding, interests, responsibility statement | End matter following Appendix C | Retained in the required concise form |
| Bibliography | All baseline sources | Bibliography | Retained; one related-work entry was added |

## Finite and exceptional details explicitly restored in Appendix B

The line-by-line audit identified details that the first compression of the
machine-base section had summarized too aggressively. Appendix B now again
states all of the following:

1. the disjoint inventories of 47 and 51 groups, the 38 uniform
   `PSL(2,q)` routes, and the 13 finite-certificate routes;
2. the only two upper-range failures of ordinary maximal-class pairs:
   `Sp(4,4)` at outer size 4 and `PSL(5,2)` at outer size 2;
3. all seven above-bound exception records: `A11`--`A14`, `PSL(6,2)`,
   `Omega+(8,2)`, and `Sp(4,8)`;
4. all six stable-poset substitute groups (whose machine records retain the
   historical `novelty` field) and the exact designated coordinate closures;
5. the three distinct saturation implementations, their shared GAP/data trust
   base, and the structural treatment of the two flag-parabolic cases;
6. the `A5`, `PSL(3,2)`, `Sp(4,4)`, and `PSL(5,2)` sample witnesses;
7. the complete split of the 26 sporadic groups, the 42 selected-class
   records, the unique-order stability boundary, and the Monster and Baby
   Monster sample positions, pairs, and primes;
8. all 34 arithmetic branches, the 12 branches representing seven distinct
   positive-base exception records, and the independent symbolic route; and
9. all regression ranges: 1,272 projective-linear prime powers, alternating
   degrees through 10,000, and 7,892 Lie-type instances through rank 25 and
   field size 3,000, explicitly labeled as regression checks rather than
   universal proofs.

## Formal and computational details explicitly restored in Appendix C

Appendix C now names, rather than merely summarizes, the baseline formal
surface:

- the exact minimal-counterexample facts checked in Lean;
- the supplement intersection, order, maximality, nonconjugacy,
  lower-divisibility, and all-multiplicity contradiction;
- the conditional 34-branch family arithmetic;
- the Rocq internal and external direct-power conclusions, positivity, and
  exact order;
- Lean reindexing, coordinate permutation, faithful wreath map, transitivity,
  inner-base preimage, coordinate normalization, and quotient divisor;
- the producer/reindexer/consumer interface, the enumerated source/signature
  drift checks, and the remaining trusted cross-library semantic boundary; and
- deterministic fail-closed finite verification, identity fingerprints, and
  exclusion of exploratory scripts from proof evidence.

The detailed package-installation and command interface remains in the
repository guide so that Appendix C stays a verification architecture rather
than an execution transcript.

## Preservation after the independent accuracy audit

The 20 August accuracy corrections did not delete a baseline proof obligation.
They made the following status-preserving changes:

1. The false stability-only shorthand in the abstract and summaries was not
   moved or retained: it was corrected. The exact supplement hypotheses and
   their separate roles remain proved in Section 3, and Appendix A still
   supplies every family witness to those hypotheses.
2. The body projective-linear proposition was narrowed from the universal
   term “excluded” to its proved fixed-$X$ conclusion. Its complete subgroup,
   Levi-avoidance, outer-bound, and exceptional calculation remains in the
   body; Appendix A.5 still combines the graph-containing calculation with
   the graph-free branch to prove the global family theorem.
3. No family calculation, finite certificate claim, sporadic record, exception
   route, formal theorem, or trust-boundary statement was removed. Repetitive
   mathematical verification remains in Appendices A--C; commands and other
   execution details remain in the repository guide, exactly as mapped above.
4. The lower finite inventory is now described accurately as frozen input
   checked against its routes, while independent iterator regeneration is
   claimed only for the upper range. No inventory row or route was removed.
5. The legacy exploratory logs and scripts retain their numerical content;
   only their displayed subgroup-index delimiter was normalized from the
   disallowed square form to `|G:N|`.

## Preservation after the final local-correction pass

The 21 August final local corrections changed no theorem, family route, or
certificate obligation. The $B_n/C_n$ sentence now distinguishes the two
correct Levi types while retaining the same exponent estimate and
primitive-prime-divisor argument. The finite-inventory paragraph now names the
actual routing/coverage check without changing either inventory or its
destinations. The new “Common inputs for the family analysis” heading only
signposts material already preserved in Appendix A, and the complete unused
almost-simple proof remains under `app:almost-simple`.

The subsequent artifact-reference pass likewise removes no mathematical
content. It replaces obsolete printed manuscript numbers in proof-facing
comments and metadata by the stable labels of the same results. The abstract,
criterion statement, coordinate-normalization convention, and size-bound
remark are clarifications of the existing proof architecture; all family
arguments, finite routes, formal statements, and certificate obligations
remain in their previously mapped destinations.

The coordinate-normalization correction of 21 August repairs, rather than
removes or relocates, the ordinary proof of `lem:coordinate-normalization`.
The corrected transporter $g_j^{-1}gg_i$, component
$a_j^{-1}\circ c\circ a_i$, and conjugate $\delta^{-1}G\delta$ now agree with
the existing Lean realization. Every downstream supplement, valuation,
family, finite-case, and trust-boundary obligation remains in the body or its
previously mapped appendix destination. No baseline material was discarded.

Release finalization as `v1.1.0` changes only archive, citation, reproduction,
and Data Availability metadata. The body/appendix allocation is unchanged:
the supplementary family proofs remain in Appendix A, finite and sporadic
certificate claims in Appendix B, and the formal/computational trust boundary
in Appendix C. Operational replay detail remains in the repository guide. No
mathematical item was removed for the public archive.
