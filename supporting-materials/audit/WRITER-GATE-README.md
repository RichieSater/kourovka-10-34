# Writer guide to the binary gates

This is the operating manual for anyone editing the manuscript. The gates do
not produce a score. One open required obligation means that profile fails.

## The two burdens of proof

| Profile | Meaning | Command from repository root |
|---|---|---|
| Journal submission | Responsible to send as a proposed proof for referee evaluation | `sh supporting-materials/submission-gate.sh submission` |
| 99% conditional confidence | No material unresolved failure mode, conditional on CFSG, the cited classifications, Atlas/CTblLib, and the trusted software/kernel boundary | `sh supporting-materials/submission-gate.sh confidence99` |

The authoritative granular checklist is
[`BURDEN-OF-PROOF-MATRIX.csv`](BURDEN-OF-PROOF-MATRIX.csv). It contains one row
for every requirement extracted from the audit standard, including the four
original stop-ship defects, Gates 1–10, independence rules, evidence-bundle
requirements, and the separate sole-author defense questions. Each row says:

- whether it is required for submission, 99% confidence, or the PhD defense;
- which binary obligation(s) close it;
- its closure condition;
- its derived `PASS` or `OPEN` state; and
- the next action while open.

[`BURDEN-POLICY.json`](BURDEN-POLICY.json) pins the complete row inventory and
both profile mappings. `check_audit.py` rejects missing rows, altered mappings,
incorrect derived statuses, profile weakening, undocumented operational files,
and ignore rules that would hide proof evidence.

## Before editing

Read, in this order:

1. `audit/STOP-SHIP.md` — current binary blockers.
2. `audit/BURDEN-OF-PROOF-MATRIX.csv` — every granular requirement.
3. `audit/OBLIGATIONS.csv` — the coarser evidence-bearing claims.
4. `audit/ASSUMPTIONS.md` — what the confidence statement is conditional on.
5. `formal/FORMAL-COVERAGE.json` — what Lean does and does not prove.
6. `audit/DEPENDENCY-DAG.json` — the exact main-theorem hypotheses,
   dependencies, evidence routes, and current status of every essential node.
7. `audit/UNIVERSAL-CLAIMS.csv` — the occurrence-by-occurrence audit of the
   manuscript's high-risk universal vocabulary.

Do not infer a pass from prose or from a successful test suite. The selected
profile gate is authoritative.

## Writer-only check after every manuscript change

From `supporting-materials/`:

```sh
python3 computations/independent/verify_manuscript.py
python3 audit/check_universal_claims.py
python3 audit/check_dependency_dag.py
tectonic --outdir .. paper/kourovka1034.tex
```

Then inspect the rebuilt `../kourovka1034.pdf`. Do not manually edit generated
counts, manifests, certificate logs, status fields, or hashes to match prose.
If the manuscript checker fails, repair the paper or the underlying evidence;
never weaken the checker to accept a discrepancy.

Any manuscript edit that moves or changes an audited high-risk occurrence will
intentionally make `check_universal_claims.py` fail. Produce a review copy that
preserves decisions for unchanged contexts:

```sh
python3 audit/check_universal_claims.py \
  --extract-template /tmp/UNIVERSAL-CLAIMS.review.csv
```

Review every row marked `REVIEW REQUIRED`, verify all transferred mappings,
then deliberately replace `audit/UNIVERSAL-CLAIMS.csv`. The helper refuses to
overwrite the authoritative manifest directly. Do not classify a mathematical
claim as bibliography, metadata, or a definition merely to avoid an open
evidence route.

## Fast integrity check

From `supporting-materials/`:

```sh
sh verify-quick.sh
```

This validates committed receipts, manifests, source-map topology, manuscript
consistency, formal coverage metadata, determinism policy, and hashes. It does
not rerun the expensive GAP enumerations and does not by itself authorize
submission or a 99% claim.

## Full local reproduction

From `supporting-materials/`:

```sh
sh verify-full.sh
```

This regenerates proof-essential GAP/Python/Lean output and byte-compares it to
the frozen receipts. Run it before freezing a release candidate and whenever a
proof computation, environment lock, formal source, or committed certificate
changes.

## Run the binary profiles

From the repository root:

```sh
sh supporting-materials/submission-gate.sh submission
sh supporting-materials/submission-gate.sh confidence99
```

Expected behavior while work remains is `... GATE|FAIL`. The output gives both
open evidence obligations and every affected granular requirement. A passing
quick/full suite does not compensate for an open literature, formal,
arithmetic, adversarial-audit, or clean-room row.

For the separate sole-author checklist:

```sh
cd supporting-materials
python3 audit/check_audit.py --profile phd_defense
```

That profile is intentionally separate from mathematical correctness.

## How to respond to a failure

1. Find each `OPEN-OBLIGATION|...` line in `audit/OBLIGATIONS.csv`.
2. Find the associated `OPEN-REQUIREMENT|...` rows in
   `audit/BURDEN-OF-PROOF-MATRIX.csv`.
3. Produce the exact required evidence. Do not rewrite the requirement around
   the available evidence.
4. Add or repair the checker that distinguishes valid from invalid evidence.
5. Add a deliberate mutation if the new failure mode is not already tested.
6. Change an obligation to a passing status only after its complete evidence
   exists and its checker passes.
7. Recompute the matrix's derived status column only:
   `python3 audit/update_burden_status.py --write`.
8. Recompute DAG statuses only:
   `python3 audit/check_dependency_dag.py --write-status`.
9. Regenerate the human reports from canonical data:
   `python3 audit/update_reports.py --write`. Never edit report counts or
   blocker prose by hand.
10. Recompute per-obligation and global evidence hashes using the scripts below.
11. Rerun quick, full when applicable, and both binary profiles.

## Updating hashes after legitimate evidence changes

From `supporting-materials/`, after all substantive checks pass:

```sh
python3 audit/check_dependency_dag.py --write-status
python3 audit/update_burden_status.py --write
python3 audit/update_reports.py --write
python3 audit/obligation_hashes.py --write
python3 audit/evidence_hashes.py --write
python3 audit/check_dependency_dag.py
python3 audit/check_universal_claims.py
python3 audit/update_reports.py --verify
python3 audit/obligation_hashes.py --verify
python3 audit/evidence_hashes.py --verify
```

Hash regeneration is the final binding step, not a way to bless unreviewed
content. Review the diff before accepting new hashes.

## Clean-room receipts for the 99% profile

`CLEANROOM` cannot be closed by two runs on one host. Freeze a clean candidate
commit, then run on two genuinely distinct machines:

```sh
supporting-materials/computations/environment/run-cleanroom.sh \
  /tmp/kourovka-cleanroom.json
```

Import each receipt and its companion full log from `supporting-materials/`:

```sh
python3 audit/check_cleanroom.py \
  --add /tmp/kourovka-cleanroom.json \
  --log /tmp/kourovka-cleanroom.json.full.log
python3 audit/check_cleanroom.py --require-complete
```

The comparator requires two distinct machine fingerprints, the same candidate
commit and manifests, and byte-identical complete-suite logs.

## Git policy

The following are proof evidence and must remain visible to Git:

- `audit/*.csv`, `audit/*.json`, source ledgers, reports, and clean-room logs;
- `formal/*.lean`, toolchain locks, and `FORMAL-COVERAGE.json`;
- `computations/certificates/*.log` and checksum manifests;
- environment locks, source maps, exception manifests, and adversarial reports.

Only caches, editor debris, LaTeX auxiliaries, and local regeneration scratch
are ignored. Never add broad patterns such as `*.log`, `*.json`, `*.csv`,
`audit/`, `formal/`, or `computations/certificates/`.
