# Claude instructions for this repository

Follow `AGENTS.md` and the authoritative writer guide at
`supporting-materials/audit/WRITER-GATE-README.md` before making any change.
The complete, granular standards for both burdens of proof live in
`supporting-materials/audit/BURDEN-OF-PROOF-MATRIX.csv` and are pinned by
`supporting-materials/audit/BURDEN-POLICY.json`.

## Binary gate policy

- Journal-submission command:
  `sh supporting-materials/submission-gate.sh submission`
- 99%-confidence command:
  `sh supporting-materials/submission-gate.sh confidence99`
- A single open required row means failure. There is no weighted score.
- Do not change `YES` to `NO`, weaken a closure condition, delete an exception,
  or relabel `UNRESOLVED` merely to obtain a pass.
- A manuscript edit must also pass the occurrence-level universal-claim audit;
  use the review-template workflow in `WRITER-GATE-README.md`, not a blind
  overwrite.
- Refresh only derived DAG/matrix statuses, generate both audit reports with
  `audit/update_reports.py --write`, then bind hashes. Do not hand-edit report
  counts or delete an open dependency.
- AI agreement is not independent mathematical evidence. Archive hostile audit
  results, but close mathematical claims only with the evidence type required
  by the obligation ledger.
- Never ignore proof receipts or reports in Git; follow the scoped root
  `.gitignore` policy.
