# Two-specialist review protocol

This protocol implements the architecture plan's two-reader test without
asserting that an external review has occurred. Record dated responses below
before designating a submission version.

## Shared reading packet

1. Manuscript Sections 1--6, with particular attention to the stable-product
   supplement engine, the divisibility criterion, and the two representative
   applications.
2. Appendices A--C only as needed to trace a proof obligation.
3. `CONTRIBUTION-MAP.md` and `formal/Comparator/README.md`.
4. The source maps and coverage manifests relevant to any questioned input.

Each reader should finish by stating the paper's three principal
contributions in their own words. The responses should agree in substance
with `CONTRIBUTION-MAP.md`: stable product normalizers, the uniform-in-$k$
valuation obstruction, and stable flag parabolics under graph fusion.

## Finite-group specialist questions

1. What is the principal new theorem or mechanism?
2. Is the stable-class criterion stated at the right level of generality?
3. Are the graph-fusion and family inputs adequately sourced?
4. Can the main proof be understood without reading the appendices?
5. Does any family proof hide a classification or maximality obligation?

## Lean/formalization specialist questions

1. What exact theorem does `Comparator/Challenge.lean` state?
2. Does `Comparator/Solution.lean` prove the definitionally identical
   proposition?
3. Which claims are established by Lean, Rocq, GAP, ordinary proof, or
   external sources?
4. Does any wording imply an end-to-end formal proof?
5. Is the cross-kernel interface stated accurately?

## Review record

| Role | Reviewer | Date | Contribution hierarchy agrees? | Blocking findings resolved? |
|---|---|---|---:|---:|
| Finite-group specialist | Not yet assigned | --- | Pending | Pending |
| Lean/formalization specialist | Not yet assigned | --- | Pending | Pending |

An independent readiness audit dated 2026-08-20 supplied mathematical,
repository, citation, and verification findings, all of which are recorded in
`REVISION-CHANGELOG.md`. No reviewer identity was supplied for either named
specialist role, so receipt of that audit does not by itself complete either
row above.

The named two-reader test is not recorded as passed until the reviewers' dated
responses have been assessed and all blocking mathematical or boundary
findings have been resolved. Richie separately authorized public
reproducibility release `v1.1.0` on 21 August 2026; that authorization does not
complete either row above. The two-reader test remains a gate for designating
a journal-submission version.
