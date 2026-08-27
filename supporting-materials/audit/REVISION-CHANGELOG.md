# Architecture-revision claim and exposition ledger

**Baseline:** commit `35942dc7cf00cd145434661167de9f2224241717`
**Working branch:** `revision/architecture-2026-08-20`

This ledger separates mathematical-claim changes from changes of exposition
and evidence interface. Richie authorized the corrected public reproducibility
release as `v1.1.0` on 21 August 2026; the frozen `v1.0.8` state remains the
comparison baseline. Release `v1.1.1`, dated 27 August 2026, supersedes the
earlier public archive reference without changing any mathematical claim.
Release `v1.1.2`, also dated 27 August 2026, supersedes `v1.1.1`
with venue-format and archive-metadata corrections only.

## Mathematical claim comparison

- **Main theorem:** unchanged. The paper still proves that every finite group
  with property P is soluble.
- **Uniform criterion:** unchanged in hypotheses and conclusion. The former
  “Divisibility criterion” is now titled the “Uniform stable-class
  divisibility criterion” so that its all-$k$ content is visible.
- **Supplement lemmas:** the claims formerly labeled `lem:A`, `lem:B`,
  `lem:C`, and `lem:P` retain their stable labels and mathematical content.
  The new `cor:supplement-engine` merely packages their exact outputs for the
  criterion; it is a derived organizational statement.
- **Worked example:** the new $A_5$ example extracts the existing certified
  witness $A_4,S_3,p=5$ and demonstrates the criterion. It introduces no new
  coverage dependency.
- **Representative applications:** the alternating proof and the
  projective-linear graph-fusion/flag-parabolic proof were extracted from the
  existing family coverage and placed in the body. The latter is named
  `prop:psl-flag` and now has the correct fixed-$X$ conclusion; the remaining
  family theorem combines its graph-containing and graph-free branches to
  supply the full projective-linear coverage. An intermediate architecture
  draft incorrectly promoted the fixed-$X$ calculation to the universally
  quantified term “excluded”; that quantifier mismatch has been removed.
- **CFSG coverage and final proof:** the family routes, finite inventory,
  sporadic claims, external assumptions, and conclusion are unchanged. The
  coverage ledger is compressed into a body table and detailed proofs are
  routed to appendices.
- **Almost-simple corollary:** unchanged; it remains a supplementary reproof,
  while the main proof continues to use the prior Tikhonenko--Tyutyanov result
  for the $k=1$ branch.
- **Related work:** a narrow citation to the stable public Kourovka 18.68
  release was added. It identifies a shared preliminary wreath-top budget and
  states the evidence-matched comparison that neither proof reduces to the
  other criterion.

No unresolved proof obligation remains promoted to theorem status in the
corrected working revision.

## Independent accuracy-audit remediation (2026-08-20)

- Replaced every stability-only summary of the supplement construction with
  the exact dependency split: $X$-stability and self-normalization give the
  supplement, intersection, and order; stable-poset maximality and normal
  saturation are additionally required for maximality.
- Narrowed `prop:psl-flag` to the fixed coordinate closure $X$ treated by its
  proof. The global projective-linear conclusion remains in `thm:graph`, where
  the graph-containing and graph-free branches are both present.
- Defined “graph part” before its first body use, clarified that either or both
  selected classes may be supplied by the flag-parabolic lemma, expanded the
  graph-family coverage row, and added a conclusion collecting transferable
  yield, essential hypotheses, external dependencies, and adjacent questions.
- Replaced self-qualifying proof-status wording with the concrete statement
  that the paper proves the theorem but does not claim priority for the
  conclusion.
- Normalized all 3,784 square-delimited subgroup-index strings in eleven
  tracked exploratory scripts/logs to `|G:N|`. The manuscript checker now
  scans all repository text artifacts, and the mutation suite injects a legacy
  notation violation to verify that the gate fails closed.
- Corrected the finite-inventory description: the upper range is independently
  regenerated with GAP's iterator; the lower range is frozen input checked
  exhaustively against its certificate routing, not independently regenerated
  by the committed replay.
- Replaced all 39 proof-path Python `assert` statements with explicit fatal
  `require` checks. The static gate now forbids `assert` on essential Python
  paths, and the symbolic arithmetic mutation runs with optimization enabled.
- Split Comparator reporting into `SOURCE-CHECK-PASS` for quick no-build mode
  and `ELABORATED-PASS` for the full proposition build. Narrowed the
  cross-kernel checker description to its enumerated signatures,
  correspondence rows, and definition-source tokens; arbitrary semantic
  equivalence remains a trusted mathematical correspondence.
- Corrected the Kourovka pinpoint to page 40 and the Breuer--Malle--O'Brien
  range to pages 21--31; refreshed the priority-search record through 20 August
  while retaining the MathSciNet, proceedings, and original-Zenkov-item
  limitations. Related-work wording now says that neither the 10.34 nor 18.68
  proof reduces to the other's criterion.
- Qualified the environment description: named runtime tools and direct
  downloads are pinned, but the Debian package snapshot and complete opam
  solver closure are not fully frozen.
- Rebuilt the canonical and nested manuscript PDFs from the corrected source;
  they are byte-identical. The preservation map records why none of these
  corrections removed a baseline proof obligation.
`PAR-NOVELTY`, the graph-fusion flag-parabolic formalization item, remains
explicitly outside closed Lean coverage.

## Subsequent literature update (2026-08-21)

- Identified and directly inspected Jinbao Li and Yong Yang,
  *Products of Nonconjugate Maximal Subgroups and Solvability*,
  `arXiv:2608.19478v1`, submitted 19 August 2026. The present paper's arXiv v1
  and v2 are dated 4 and 6 August 2026.
- Added the exact citation to the introduction, conclusion, bibliography,
  repository overview, contribution map, mathematical-yield note, source
  ledger, and priority-search record.
- Compared the mechanisms explicitly: Li--Yang organize their argument around
  product--socle lifting from nonfactorizing maximal subgroups of an
  almost-simple coordinate group, while this paper uses suitable stable
  classes, exact-order maximal supplements, and a uniform valuation
  obstruction.
- Revised the reader-facing chronology to begin “After this paper's arXiv v1
  and v2” and to end the comparison at “distinct proof architectures.” The
  internal source ledger continues to record the exact public dates and
  evidentiary limitations.
- Recorded a source-level v1 caveat in `PRIORITY-SEARCH.md`: Proposition 2.5
  has unresolved projective-linear $q=2$ rank coverage and an overbroad
  $\operatorname{Sz}(q)$ choice in its even-characteristic symplectic branch.
  The new paper is therefore cited as subsequent related work rather than as
  correctness certification of the present proof.
- Extended the manuscript checker to require the citation and method
  comparison and to reject unsupported independence or official-closure
  language. Added a mutation that injects an unsupported Li--Yang independence
  claim and requires the gate to reject it.

## Evidence-interface changes

- Added a neutral-mathlib Comparator challenge stating the exact conditional
  product-supplement spine and a project solution proving the definitionally
  identical proposition.
- Added a machine check for the challenge import surface, its single
  intentional placeholder, the placeholder-free solution, and the exact
  proposition equality.
- Added a `comparator` record to `formal/FORMAL-COVERAGE.json`; no new item was
  added to `closed_manuscript_claims`.
- Reconciled the source-map manuscript locations after moving the family
  arguments. The underlying cited sources and manifest row counts are
  unchanged.
- Replaced stale manuscript-token checks with architecture, label, citation,
  disclosure-location, status-language, group-index-notation, and
  manuscript-to-manifest checks.

## Exposition and repository changes

- Rewrote the abstract and introduction around the three retained ideas and
  added the three-paragraph proof mechanism and contribution/dependence table.
- Renamed and oriented the reduction, supplement, and criterion sections with
  descriptive statements of purpose.
- Kept two teaching applications in the body and moved repetitive family work
  to Appendix A under a fixed eight-part audit template.
- Replaced the former machine-base narrative with claim-centered finite and
  sporadic propositions in Appendix B; operational commands, log names,
  package pins, hashes, and mutation mechanics remain in the repository guide.
- Added Appendix C's six-column allocation of ordinary proof, Lean, Rocq,
  GAP/Python, and external inputs.
- Added canonical-baseline, contribution-map, and mathematical-yield/seminar
  documents.
- Removed the duplicate disclosure from the repository README. The principal
  manuscript source contains the sole disclosure.
- Updated both repository guides and the submission abstract to match the new
  architecture and exact formal boundary.

## Baseline-content preservation follow-up

- Compared the frozen source block by block against the revised body and
  appendices and recorded every destination in
  `CONTENT-PRESERVATION-MAP.md`.
- Restored Appendix B's exact finite and exceptional routing, designated
  coordinate closures, representative finite and sporadic witnesses, complete
  sporadic inventory, 42-record binding statement, seven arithmetic-exception
  records, and full regression-range bounds.
- Restored Appendix C's exact Lean and Rocq claim surface, wreath-realization
  outputs, producer/reindexer/consumer interface boundary, and deterministic
  fail-closed certificate safeguards.
- Preserved the deliberately displaced operational material in the repository
  guide, including the exact GAP patch, seed, inventory receipts, and the
  J--N sweep-to-script-to-receipt map. These execution details remain outside
  the article in accordance with the controlling architecture plan.
- Reinstated manuscript citations to the pinned character-table library and
  the secondary CFSG overview so that no baseline bibliography item became an
  orphan solely because of the reorganization.
- Corrected two transposed maximality-source locations: the projective
  rank-one row now points to Appendix A.1 and the alternating row to Section
  5.1.

## Submission-readiness audit follow-up (2026-08-21)

- Promoted coordinate closure normalization and the wreath-top quotient
  divisor from conventions to named lemmas with complete ordinary proofs.
  The valuation theorem now cites the divisor lemma at the exact point of use.
- Kept the $k=1$ comparison theorem in the body but moved its unused detailed
  proof and supplementary consequence to Appendix A.
- Replaced the B1--B7 graph-symmetry ledger with a four-column roadmap of
  classes, maximality/stability mechanisms, obstruction primes and Levi
  bounds, outer contributions, and exception destinations. Full prose remains
  for triality, invariant flag parabolics, and graph--field fixed-point
  subgroups; the preservation map records every displaced obligation.
- Renamed the finite proposition “Finite-range coverage,” distinguished
  uniform routes from finite certificates, and replaced the reader-facing
  “novelty” terminology with “stable-poset substitute” or “flag-parabolic
  substitute.” Historical machine fields and filenames remain unchanged and
  are explained explicitly.
- Recalibrated the three saturation procedures as distinct GAP
  implementations sharing one runtime, representation layer, and pinned data
  base. Split the former six-column trust table into two readable tables.
- Revised the abstract to state that the valuation gap rules out the entire
  direct-power branch and to name CFSG and published subgroup/order data.
  Renamed the coordinate-kernel step, narrowed the fixed-ratio remark, broke
  the twisted-family stability argument into cited claims, and replaced the
  former “trivially” wording with “by conjugation.”
- Made user-package-root isolation intrinsic to both `verify-full.sh` and the
  environment gate by invoking GAP with `-r`; documented the same flag for
  individual runs and added a mutation test that deletes the isolation flag.
  The unmodified documented command then regenerated every proof-essential
  certificate byte-identically and completed both formal builds, the mutation
  suite, and the evidence check.

## Final adversarial local-correction pass (2026-08-21)

- Corrected the untwisted Levi description: the $B_n$ and $C_n$ factors are
  respectively $A_{i-1}\times B_{n-i}$ and
  $A_{i-1}\times C_{n-i}$, with the unchanged exponent bound
  $\max(i,2(n-i))<2n$.
- Replaced the remaining reader-facing “novelties” occurrence with
  “flag-parabolic substitutes.” The historical machine identifier
  `PAR-NOVELTY` remains documented as an identifier rather than mathematical
  terminology.
- Replaced the overbroad “independent inventory generation” sentence by the
  exact claim that an independent routing and coverage check verifies every
  inventory entry exactly once. The adjacent paragraph continues to state
  that the lower inventory is frozen and the upper inventory is regenerated.
- Simplified the abstract to describe two stable coordinate classes satisfying
  the supplement criterion, while leaving the four structural hypotheses to
  the introduction and theorem statements. The submission abstract was kept
  synchronized.
- Smoothed the Li--Yang literature paragraph, added a “Common inputs for the
  family analysis” appendix heading, replaced the proof-only appendix pointer
  after the almost-simple theorem with ordinary prose, and qualified the main
  theorem's ordinary-proof status as complete relative to cited external
  inputs.
- Extended the manuscript checker with fail-closed guards for all three local
  corrections and the added navigation/status wording.

## Artifact-reference and final exposition pass (2026-08-21)

- Replaced the abstract's forward references to property $\mathrm P$ and the
  “wreath top” by the factorization hypothesis and wreath-product quotient,
  and expanded CFSG on first use. The plain-text submission abstract is
  synchronized.
- Made the uniform divisibility criterion self-contained by directly binding
  $S$, $X$, and $x$ before quantifying over $k$ and $G$.
- Added the component-composition and conjugation conventions locally at the
  start of the coordinate-normalization proof, before its transporter
  calculation uses them.
- Replaced the fixed-ratio shorthand in Remark 4.3 by the actual size upper
  bound and its divergent $k$-th root, making explicit why a valuation gap is
  required.
- Reconciled proof-facing audit metadata, Lean comments, formal coverage prose,
  Python arithmetic docstrings, and the GAP upper-inventory routing comment
  with the current stable manuscript labels. External source theorem numbers
  remain unchanged and clearly belong to their cited works.
- Added a static label gate that parses every label from the principal TeX,
  rejects unknown or missing proof-artifact labels, and forbids printed
  manuscript numbering in formal comments. A dedicated mutation restores the
  obsolete family numbering and must be detected.
- Removed the separate Problem 18.68 reciprocal citation from this paper's
  release gate. The reciprocal cross-reference remains appropriate scholarly
  maintenance in its own repository.

## Coordinate-normalization proof correction (2026-08-21)

- Corrected the transporter order in Lemma `lem:coordinate-normalization`.
  With left conjugation and a transporter $g_r$ carrying coordinate $1$ to
  coordinate $r$, an element carrying $S_i$ to $S_j$ is returned to the first
  coordinate by $g_j^{-1}gg_i$, whose component is
  $a_j^{-1}\circ c\circ a_i$. The preceding working draft had printed these
  three factors in the reverse order.
- Consequently corrected the normalizing replacement from
  $\delta G\delta^{-1}$ to $\delta^{-1}G\delta$. The proof now displays the
  coordinate path and fixes ordinary right-to-left composition before the
  calculation, removing the earlier convention ambiguity.
- Added an explicit sentence at the start of the proof of `thm:D` applying
  the coordinate-normalization lemma before invoking Conventions `conv:X`--
  `conv:coord` and Lemmas `lem:A`--`lem:C`.
- Added a fail-closed manuscript/Lean correspondence gate. It checks the
  corrected ordinary formula against the Lean normalization
  $\delta^{-1}\rho(g)\delta$ and its target-inverse/source transporter order.
  A dedicated mutation restores the reversed TeX transporter and must be
  rejected.
- Normalized trailing whitespace in the five already-regenerated legacy logs
  changed by the repository-wide subgroup-index repair. Their numerical and
  routing content is unchanged; the full working-tree diff now passes the
  whitespace gate.

## Authorized reproducibility release (2026-08-21)

- Designated the corrected archive as version `v1.1.0` and synchronized
  `CITATION.cff`, `.zenodo.json`, both repository guides, the manuscript Data
  Availability statement, the repository bibliography entry, clone commands,
  and container tag.
- Included the ten previously untracked architecture and Comparator files in
  the release evidence tree. The static metadata gate rejects any return to
  the obsolete `v1.0.8` reproduction instructions.
- Bound the release metadata to the stable Zenodo concept DOI
  `10.5281/zenodo.21709124`; Zenodo assigns the immutable version DOI when it
  archives the exact GitHub tag.
- A reciprocal 18.68 cross-reference remains appropriate maintenance in that
  separate repository, but it is not a release gate for this paper.

## Public-corpus maintenance release (2026-08-27)

- Removed an internal process artifact from the tracked repository tree; no
  theorem, hypothesis, proof, formal statement, or computational certificate
  changed.
- Added a fail-closed public-corpus gate, a three-mutation self-test, and three
  corresponding mutations in the main suite.
- Designated the synchronized archive as `v1.1.1` and updated the manuscript,
  both repository guides, citation metadata, Zenodo metadata, clone commands,
  and container tag.
- The rendered manuscript changes only its date and archive version/link; the
  mathematical text and 26-page layout are preserved.

## Venue-format metadata release (2026-08-27)

- Expanded the abstract to the required 150--250-word range and made the
  reusable all-`k` direct-power-socle obstruction its concluding point.
- Completed the unaffiliated-author address as Washington, DC, United States.
- Consolidated data availability, funding, competing interests, and the
  existing disclosure under `Statements and Declarations`.
- Added fail-closed checks for the abstract length, complete address, and
  declaration heading. No theorem, proof, formal statement, computation, or
  certificate changed.
- Designated the synchronized GitHub and Zenodo archive as `v1.1.2` and
  rebuilt the corrected 26-page manuscript.
