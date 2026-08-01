#!/usr/bin/env python3
"""Generate or verify the binary stop-ship and submission reports."""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[1]
)).resolve()
AUDIT = ROOT / "audit"
CLOSED = {"FORMAL-PASS", "CITED-PASS", "COMPUTED-PASS", "REDUNDANT"}
PROFILE_COL = {
    "submission": "submission_required",
    "confidence99": "confidence99_required",
    "phd_defense": "phd_defense_required",
}


def load():
    with (AUDIT / "OBLIGATIONS.csv").open(newline="") as f:
        obligations = list(csv.DictReader(f))
    with (AUDIT / "BURDEN-OF-PROOF-MATRIX.csv").open(newline="") as f:
        matrix = list(csv.DictReader(f))
    policy = json.loads((AUDIT / "BURDEN-POLICY.json").read_text())
    return obligations, matrix, policy


def required_obligations(obligations, policy, profile):
    wanted = set(policy["profiles"][profile]["required_obligation_ids"])
    return [r for r in obligations if r["claim_id"] in wanted]


def required_requirements(matrix, profile):
    col = PROFILE_COL[profile]
    return [r for r in matrix if r[col] == "YES"]


def profile_counts(obligations, matrix, policy, profile):
    obs = required_obligations(obligations, policy, profile)
    req = required_requirements(matrix, profile)
    return {
        "closed_obligations": sum(r["status"] in CLOSED for r in obs),
        "obligations": len(obs),
        "closed_requirements": sum(r["derived_status"] == "PASS" for r in req),
        "requirements": len(req),
        "open_obligations": [r for r in obs if r["status"] not in CLOSED],
        "open_requirements": [r for r in req if r["derived_status"] != "PASS"],
    }


def audit_date() -> str:
    text = (AUDIT / "SOURCE-LEDGER.md").read_text()
    match = re.search(r"Search/audit date: \*\*(\d{4}-\d{2}-\d{2})\*\*", text)
    if not match:
        raise SystemExit("HARD-FAIL: cannot derive report date from SOURCE-LEDGER.md")
    return match.group(1)


def render_stop_ship(obligations, matrix, policy) -> str:
    sub = profile_counts(obligations, matrix, policy, "submission")
    c99 = profile_counts(obligations, matrix, policy, "confidence99")
    phd = profile_counts(obligations, matrix, policy, "phd_defense")
    sub_ids = {r["claim_id"] for r in sub["open_obligations"]}
    c99_only = [r for r in c99["open_obligations"] if r["claim_id"] not in sub_ids]
    imm = [r for r in matrix if r["requirement_id"].startswith("IMM-")]
    lines = [
        "# Stop-ship register",
        "",
        "This file is generated from the binary obligation ledger and burden matrix.",
        "Do not edit it by hand; run `python3 audit/update_reports.py --write`.",
        "A blocker disappears only when its mapped obligation has permitted closed",
        "evidence and the corresponding profile gate verifies it.",
        "",
        f"**Audit date:** {audit_date()}  ",
        "**Counterexample status:** no counterexample has been established by this audit.",
        "",
        "## Journal-submission blockers",
        "",
    ]
    if sub["open_obligations"]:
        for row in sub["open_obligations"]:
            lines += [
                f"- **`{row['claim_id']}`** — {row['statement']}",
                f"  - Next evidence: {row['primary_evidence']}",
            ]
    else:
        lines.append("- None.")
    lines += ["", "## Additional 99%-confidence blockers", ""]
    if c99_only:
        for row in c99_only:
            lines += [
                f"- **`{row['claim_id']}`** — {row['statement']}",
                f"  - Next evidence: {row['primary_evidence']}",
            ]
    else:
        lines.append("- None beyond the submission blockers.")
    lines += ["", "## Separate sole-author/PhD-defense blockers", ""]
    if phd["open_obligations"]:
        for row in phd["open_obligations"]:
            lines.append(f"- **`{row['claim_id']}`** — {row['statement']}")
    else:
        lines.append("- None.")
    lines += [
        "",
        "## Original immediate defects",
        "",
        f"- Closed granular findings: **{sum(r['derived_status']=='PASS' for r in imm)}/{len(imm)}**.",
    ]
    for row in imm:
        lines.append(
            f"- `{row['requirement_id']}` — **{row['derived_status']}** — {row['requirement']}"
        )
    lines += [
        "",
        "## Binary rule",
        "",
        "The submission profile and the 99%-confidence profile remain **FAIL** while",
        "their respective lists above are nonempty. Passing engineering checks cannot",
        "offset an unresolved mathematical, source, literature, or independent-reproduction",
        "obligation.",
        "",
    ]
    return "\n".join(lines)


def render_submission_report(obligations, matrix, policy) -> str:
    data = {
        p: profile_counts(obligations, matrix, policy, p)
        for p in ("submission", "confidence99", "phd_defense")
    }
    formal = json.loads((ROOT / "formal/FORMAL-COVERAGE.json").read_text())
    mutation = (ROOT / "computations/certificates/mutation_tests.log").read_text()
    mm = re.search(r"MUTATION TEST SUITE\|PASS\|detected=(\d+)/(\d+)", mutation)
    if not mm:
        raise SystemExit("HARD-FAIL: mutation receipt lacks terminal count")
    clean = json.loads((AUDIT / "CLEANROOM-RECEIPTS.json").read_text())
    receipts = clean.get("receipts", [])
    lines = [
        "# Binary submission report",
        "",
        f"**Audit date:** {audit_date()}  ",
        "**Standard:** no weighted score; one open required obligation or granular",
        "requirement makes the selected gate fail.",
        "",
        "## Current ledger outcomes",
        "",
        "| Profile | Outcome | Obligations | Granular requirements |",
        "|---|---:|---:|---:|",
    ]
    for profile, label in (
        ("submission", "Journal submission"),
        ("confidence99", "99% conditional confidence"),
        ("phd_defense", "Sole-author/PhD defense"),
    ):
        x = data[profile]
        outcome = "PASS" if not x["open_obligations"] and not x["open_requirements"] else "FAIL"
        lines.append(
            f"| {label} | **{outcome}** | "
            f"{x['closed_obligations']}/{x['obligations']} | "
            f"{x['closed_requirements']}/{x['requirements']} |"
        )
    lines += [
        "",
        "These are ledger results. They do not claim that `verify-quick.sh` or",
        "`verify-full.sh` was run at report-generation time; run those commands for",
        "an execution receipt.",
        "",
        "## Open journal-submission obligations",
        "",
    ]
    if data["submission"]["open_obligations"]:
        for row in data["submission"]["open_obligations"]:
            lines.append(f"- `{row['claim_id']}` — {row['statement']}")
    else:
        lines.append("- None.")
    sub_ids = {r["claim_id"] for r in data["submission"]["open_obligations"]}
    lines += ["", "## Additional open 99%-confidence obligations", ""]
    extra = [
        r for r in data["confidence99"]["open_obligations"]
        if r["claim_id"] not in sub_ids
    ]
    if extra:
        for row in extra:
            lines.append(f"- `{row['claim_id']}` — {row['statement']}")
    else:
        lines.append("- None beyond the submission list.")
    lines += [
        "",
        "## Assurance-package snapshot",
        "",
        f"- Formal coverage manifest: **{len(formal['closed_manuscript_claims'])}** closed claims; "
        f"**{len(formal['explicitly_not_closed'])}** explicitly open claims.",
        f"- Mutation receipt: **{mm.group(1)}/{mm.group(2)}** required faults detected.",
        f"- Independent clean-room receipts: **{len(receipts)}/2** recorded.",
        f"- Total ledger obligations: **{len(obligations)}**.",
        f"- Total granular burden rows: **{len(matrix)}**.",
        "",
        "## Interpretation",
        "",
        "No current failure is itself a counterexample to the theorem. It means the",
        "evidence package has not yet met the selected binary assurance standard.",
        "The release **must not** be described as having reached 99% certainty while",
        "the 99%-confidence profile is open.",
        "",
        "Any eventual 99% statement is conditional on accepted CFSG and cited",
        "classification theorems, Atlas/CTblLib mathematical data, and the trusted",
        "Lean/GAP/compiler/operating-system/hardware layers listed in `ASSUMPTIONS.md`.",
        "",
    ]
    return "\n".join(lines)


def expected_reports():
    obligations, matrix, policy = load()
    return {
        AUDIT / "STOP-SHIP.md": render_stop_ship(obligations, matrix, policy),
        AUDIT / "SUBMISSION-REPORT.md": render_submission_report(obligations, matrix, policy),
    }


def validate_reports() -> None:
    for path, text in expected_reports().items():
        if not path.is_file() or path.read_text() != text:
            raise SystemExit(f"HARD-FAIL: generated audit report drift: {path.name}")


def main() -> int:
    ap = argparse.ArgumentParser()
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--verify", action="store_true")
    args = ap.parse_args()
    expected = expected_reports()
    if args.write:
        for path, text in expected.items():
            path.write_text(text)
        print("AUDIT REPORTS|WROTE|files=2")
        return 0
    validate_reports()
    print("AUDIT REPORTS|PASS|files=2")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, csv.Error, json.JSONDecodeError) as exc:
        raise SystemExit("HARD-FAIL: " + str(exc))
