# Repository instructions for coding and writing agents

This repository uses binary proof-assurance gates. Read these files before
editing the paper, formalization, audit data, or proof computations:

1. `supporting-materials/audit/WRITER-GATE-README.md`
2. `supporting-materials/audit/BURDEN-OF-PROOF-MATRIX.csv`
3. `supporting-materials/audit/STOP-SHIP.md`
4. `supporting-materials/audit/ASSUMPTIONS.md`

## Non-negotiable rules

- A universal claim closes only through its mapped formal proof, exact
  published theorem, or genuinely exhaustive computation.
- Never weaken a theorem, checker, requirement, profile flag, or exception
  range to make a gate pass.
- Never manually invent a passing status, count, receipt, or certificate hash.
- Never describe the work as reaching 99% confidence unless
  `sh supporting-materials/submission-gate.sh confidence99` prints its final
  `CONFIDENCE99 GATE|PASS` line.
- Before proposing journal submission, run
  `sh supporting-materials/submission-gate.sh submission` and report every
  open row verbatim if it fails.
- Proof-essential logs, audit reports, manifests, source maps, environment
  locks, and clean-room receipts must remain trackable by Git. Do not add a
  broad ignore rule for logs, JSON, CSV, `audit/`, `formal/`, or certificate
  directories.
- After changing manuscript text, run the manuscript checker and rebuild the
  PDF as described in `WRITER-GATE-README.md`; also refresh and review the
  occurrence-level `UNIVERSAL-CLAIMS.csv` audit rather than bypassing it.
- Keep `DEPENDENCY-DAG.json` current with
  `python3 supporting-materials/audit/check_dependency_dag.py --write-status`,
  and generate `STOP-SHIP.md`/`SUBMISSION-REPORT.md` with
  `update_reports.py --write`; never hand-edit optimistic blocker counts.
- Preserve explicit unresolved rows. An honest `FAIL` is preferable to a
  mislabeled `PASS`.

## Local skills

- `/research-god`: deep multi-angle web research, including exact source and
  priority audits.
- `/browser-harness`: browser automation when ordinary source retrieval is not
  sufficient.
- `/cmux`: macOS terminal/workspace automation; anchor to
  `CMUX_WORKSPACE_ID` and avoid unnecessary focus changes.
