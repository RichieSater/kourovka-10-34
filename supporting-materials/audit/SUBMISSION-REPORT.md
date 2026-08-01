# Binary submission report

**Audit date:** 2026-08-01  
**Standard:** no weighted score; one open required obligation or granular
requirement makes the selected gate fail.

## Current ledger outcomes

| Profile | Outcome | Obligations | Granular requirements |
|---|---:|---:|---:|
| Journal submission | **FAIL** | 27/33 | 179/208 |
| 99% conditional confidence | **FAIL** | 33/43 | 194/237 |
| Sole-author/PhD defense | **FAIL** | 9/11 | 14/34 |

These are ledger results. They do not claim that `verify-quick.sh` or
`verify-full.sh` was run at report-generation time; run those commands for
an execution receipt.

## Open journal-submission obligations

- `SRC-REDUCTION-STRUCTURE` — The finite characteristically-simple decomposition and automorphism-wreath embedding used by the non-formal submission proof have exact published pinpoints
- `SRC-BOUNDARY-ISOMORPHISMS` — Every exceptional isomorphism, simplicity exclusion, and low-parameter boundary in the classification and exception manifests has an exact published source
- `SRC-ORDER-FORMULAS` — Every simple-group, subgroup, and Levi order formula used in the family proof has an exact source pinpoint and matching parameter assumptions
- `SRC-ZSIGMONDY` — The exact primitive-prime-divisor theorem, including every exception used by the manuscript, is pinned and its hypotheses match every invocation
- `LIT-PRIORITY` — No prior full solution was found in the stated databases as of the search date
- `ADV-PROOF-AUDITS` — At least two fresh adversarial proof audits have been archived and every verified finding is either repaired or remains an explicit stop-ship row

## Additional open 99%-confidence obligations

- `RED-COORD` — The unique minimal normal subgroup is S^k with S nonabelian simple; G has the transitive wreath embedding and normalized coordinate closure; and t divides x^k k!
- `ARITH-UNIVERSAL` — Every infinite-family arithmetic branch including all formula assumptions and exceptions is formally or symbolically proved exactly as stated
- `CLEANROOM` — Full suite is reproduced from fresh clones on two separate machines with byte-identical normalized output
- `FORM-CORE` — Entire new abstract group-theoretic core matches the manuscript and is kernel checked

## Assurance-package snapshot

- Formal coverage manifest: **8** closed claims; **4** explicitly open claims.
- Mutation receipt: **23/23** required faults detected.
- Independent clean-room receipts: **0/2** recorded.
- Total ledger obligations: **44**.
- Total granular burden rows: **252**.

## Interpretation

No current failure is itself a counterexample to the theorem. It means the
evidence package has not yet met the selected binary assurance standard.
The release **must not** be described as having reached 99% certainty while
the 99%-confidence profile is open.

Any eventual 99% statement is conditional on accepted CFSG and cited
classification theorems, Atlas/CTblLib mathematical data, and the trusted
Lean/GAP/compiler/operating-system/hardware layers listed in `ASSUMPTIONS.md`.
