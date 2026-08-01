# Stop-ship register

This file is generated from the binary obligation ledger and burden matrix.
Do not edit it by hand; run `python3 audit/update_reports.py --write`.
A blocker disappears only when its mapped obligation has permitted closed
evidence and the corresponding profile gate verifies it.

**Audit date:** 2026-08-01  
**Counterexample status:** no counterexample has been established by this audit.

## Journal-submission blockers

- **`SRC-REDUCTION-STRUCTURE`** — The finite characteristically-simple decomposition and automorphism-wreath embedding used by the non-formal submission proof have exact published pinpoints
  - Next evidence: paper proof and source ledger
- **`SRC-BOUNDARY-ISOMORPHISMS`** — Every exceptional isomorphism, simplicity exclusion, and low-parameter boundary in the classification and exception manifests has an exact published source
  - Next evidence: classification and exception manifests
- **`SRC-ORDER-FORMULAS`** — Every simple-group, subgroup, and Levi order formula used in the family proof has an exact source pinpoint and matching parameter assumptions
  - Next evidence: paper formulas and source ledger
- **`SRC-ZSIGMONDY`** — The exact primitive-prime-divisor theorem, including every exception used by the manuscript, is pinned and its hypotheses match every invocation
  - Next evidence: Zsigmondy 1892 and source ledger
- **`LIT-PRIORITY`** — No prior full solution was found in the stated databases as of the search date
  - Next evidence: web/arXiv/Crossref/MathNet/official Kourovka searches
- **`ADV-PROOF-AUDITS`** — At least two fresh adversarial proof audits have been archived and every verified finding is either repaired or remains an explicit stop-ship row
  - Next evidence: audit/adversarial-reports/

## Additional 99%-confidence blockers

- **`RED-COORD`** — The unique minimal normal subgroup is S^k with S nonabelian simple; G has the transitive wreath embedding and normalized coordinate closure; and t divides x^k k!
  - Next evidence: paper proof
- **`ARITH-UNIVERSAL`** — Every infinite-family arithmetic branch including all formula assumptions and exceptions is formally or symbolically proved exactly as stated
  - Next evidence: paper proof plus partial symbolic checker
- **`CLEANROOM`** — Full suite is reproduced from fresh clones on two separate machines with byte-identical normalized output
  - Next evidence: Dockerfile and environment lock
- **`FORM-CORE`** — Entire new abstract group-theoretic core matches the manuscript and is kernel checked
  - Next evidence: partial Lean project

## Separate sole-author/PhD-defense blockers

- **`RED-COORD`** — The unique minimal normal subgroup is S^k with S nonabelian simple; G has the transitive wreath embedding and normalized coordinate closure; and t divides x^k k!
- **`DEFENSE-READINESS`** — The sole author can reconstruct and defend every listed proof transition and answer the counterfactual questions without AI assistance

## Original immediate defects

- Closed granular findings: **11/11**.
- `IMM-01` — **PASS** — Check every embedding of every selected V in every relevant overgroup W, not one representative.
- `IMM-02` — **PASS** — Enumerate actual overgroups of a fixed V with IntermediateSubgroups.
- `IMM-03` — **PASS** — Enumerate every contained-conjugate orbit without the one-result flag.
- `IMM-04` — **PASS** — Require the actual-overgroup and contained-orbit methods to agree.
- `IMM-05` — **PASS** — Pin a GAP source that contains the ContainedConjugates regression fix.
- `IMM-06` — **PASS** — Run the upstream multiple-contained-copy regression cases.
- `IMM-07` — **PASS** — Independently bypass ContainedConjugates with a direct double-coset implementation.
- `IMM-08` — **PASS** — Make the manuscript describe the same stability method the sporadic code uses.
- `IMM-09` — **PASS** — Identify sporadic and finite subgroup classes by exact persistent class records, not order alone.
- `IMM-10` — **PASS** — Remove random proof witnesses or replace them with fixed explicit constructions.
- `IMM-11` — **PASS** — Exit nonzero on skipped, missing, ambiguous, failed, or inconsistent computations.

## Binary rule

The submission profile and the 99%-confidence profile remain **FAIL** while
their respective lists above are nonempty. Passing engineering checks cannot
offset an unresolved mathematical, source, literature, or independent-reproduction
obligation.
