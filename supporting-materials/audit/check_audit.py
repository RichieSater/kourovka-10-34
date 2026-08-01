#!/usr/bin/env python3
"""Schema linter and binary submission/99%-confidence obligation gate."""
from __future__ import annotations
import argparse, csv, json, os, subprocess, sys
from pathlib import Path
from obligation_hashes import verify_rows as verify_obligation_hashes
from check_cleanroom import validate as validate_cleanroom
from check_dependency_dag import validate as validate_dependency_dag
from check_universal_claims import validate as validate_universal_claims
from update_reports import validate_reports

ROOT = Path(os.environ.get("KOUROVKA_SUPPORTING_ROOT",
                           Path(__file__).resolve().parents[1])).resolve()
AUDIT = ROOT / "audit"
COLS = ['claim_id','manuscript_lines','statement','claim_type','assumptions',
        'primary_evidence','independent_evidence','source_pinpoint','checker',
        'certificate_hash','status','notes']
MATRIX_COLS = [
    'requirement_id','source_section','category','requirement',
    'submission_required','confidence99_required','phd_defense_required',
    'obligation_ids','closure_condition','derived_status','next_action',
]
CLOSED = {'FORMAL-PASS','CITED-PASS','COMPUTED-PASS','REDUNDANT'}
WORKING = CLOSED | {'UNRESOLVED'}
PROFILE_COLUMN = {
    'submission': 'submission_required',
    'confidence99': 'confidence99_required',
    'phd_defense': 'phd_defense_required',
}

def die(msg): raise SystemExit('HARD-FAIL: '+msg)


def validate_operational_docs() -> None:
    """Keep the human/agent instructions and ignore policy on the gate path."""
    repo = Path(os.environ.get('KOUROVKA_REPO_ROOT', ROOT.parent)).resolve()
    required = {
        ROOT / 'audit/WRITER-GATE-README.md': [
            'submission-gate.sh submission', 'submission-gate.sh confidence99',
            'BURDEN-OF-PROOF-MATRIX.csv', 'UNIVERSAL-CLAIMS.csv',
            'check_dependency_dag.py --write-status', 'update_reports.py --write',
        ],
        repo / 'AGENTS.md': [
            'WRITER-GATE-README.md', 'BURDEN-OF-PROOF-MATRIX.csv',
            'submission-gate.sh confidence99', 'UNIVERSAL-CLAIMS.csv',
            'update_reports.py --write',
        ],
        repo / 'CLAUDE.md': [
            'WRITER-GATE-README.md', 'BURDEN-OF-PROOF-MATRIX.csv',
            'submission-gate.sh confidence99', 'update_reports.py --write',
        ],
        repo / '.gitignore': [
            'supporting-materials/formal/.lake/', '__pycache__/',
        ],
    }
    for path, tokens in required.items():
        if not path.is_file():
            die(f'required operational file missing: {path.relative_to(repo)}')
        text = path.read_text()
        for token in tokens:
            if token not in text:
                die(f'{path.relative_to(repo)}: required token missing: {token}')

    # A broad *.log / audit / certificate ignore rule would silently hide the
    # very evidence later gates are meant to bind.  Ask git about representative
    # future evidence paths, using --no-index so tracked state cannot mask a rule.
    probes = [
        'supporting-materials/audit/BURDEN-OF-PROOF-MATRIX.csv',
        'supporting-materials/audit/UNIVERSAL-CLAIMS.csv',
        'supporting-materials/audit/DEPENDENCY-DAG.json',
        'supporting-materials/audit/adversarial-reports/report-1.md',
        'supporting-materials/audit/cleanroom-logs/example.log',
        'supporting-materials/computations/certificates/example.log',
        'supporting-materials/formal/FORMAL-COVERAGE.json',
    ]
    is_worktree = subprocess.run(
        ['git', '-C', str(repo), 'rev-parse', '--is-inside-work-tree'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    ).returncode == 0
    if is_worktree:
        for rel in probes:
            proc = subprocess.run(
                ['git', '-C', str(repo), 'check-ignore', '--no-index', '-q', rel],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            if proc.returncode == 0:
                die(f'.gitignore hides proof evidence path: {rel}')
            if proc.returncode not in (0, 1):
                die(f'git check-ignore failed for {rel} with exit {proc.returncode}')
    else:
        patterns = {
            line.strip() for line in (repo / '.gitignore').read_text().splitlines()
            if line.strip() and not line.lstrip().startswith('#')
        }
        forbidden = {
            '*.log','*.json','*.csv','audit/','formal/',
            'supporting-materials/audit/',
            'supporting-materials/formal/',
            'supporting-materials/computations/certificates/',
        }
        bad = sorted(patterns & forbidden)
        if bad:
            die(f'.gitignore contains broad proof-evidence rules: {bad}')


def load_and_validate_matrix(rows: list[dict]) -> tuple[list[dict], dict]:
    by_id = {row['claim_id']: row for row in rows}
    with (AUDIT / 'BURDEN-OF-PROOF-MATRIX.csv').open(newline='') as f:
        rd = csv.DictReader(f)
        if rd.fieldnames != MATRIX_COLS:
            die(f'burden-matrix columns drift: {rd.fieldnames!r}')
        matrix = list(rd)
    req_ids = [row['requirement_id'] for row in matrix]
    if not req_ids or len(req_ids) != len(set(req_ids)):
        die('empty or duplicate burden-matrix requirement_id')
    flags = set(PROFILE_COLUMN.values())
    mapped: set[str] = set()
    for row in matrix:
        if any(row[key] not in {'YES', 'NO'} for key in flags):
            die(f"{row['requirement_id']}: profile flags must be YES or NO")
        if not any(row[key] == 'YES' for key in flags):
            die(f"{row['requirement_id']}: requirement is assigned to no profile")
        if row['submission_required'] == 'YES' and row['confidence99_required'] != 'YES':
            die(f"{row['requirement_id']}: confidence99 must subsume submission")
        if not row['source_section'] or not row['category'] or not row['requirement']:
            die(f"{row['requirement_id']}: empty source/category/requirement")
        if not row['closure_condition'] or not row['next_action']:
            die(f"{row['requirement_id']}: empty closure condition or next action")
        obs = row['obligation_ids'].split(';') if row['obligation_ids'] else []
        if not obs or len(obs) != len(set(obs)):
            die(f"{row['requirement_id']}: empty or duplicate obligation mapping")
        unknown = set(obs) - set(by_id)
        if unknown:
            die(f"{row['requirement_id']}: unknown obligations {sorted(unknown)}")
        mapped.update(obs)
        expected = 'PASS' if all(by_id[x]['status'] in CLOSED for x in obs) else 'OPEN'
        if row['derived_status'] != expected:
            die(f"{row['requirement_id']}: derived status is {row['derived_status']!r}, expected {expected!r}")
    if mapped != set(by_id):
        die(f'burden matrix obligation coverage drift: missing={sorted(set(by_id)-mapped)} extra={sorted(mapped-set(by_id))}')

    policy = json.loads((AUDIT / 'BURDEN-POLICY.json').read_text())
    expected_keys = {
        'schema_version','principle','allowed_closed_statuses',
        'allowed_working_statuses','all_requirement_ids','all_obligation_ids',
        'profiles',
    }
    if not isinstance(policy, dict) or set(policy) != expected_keys:
        die('burden policy top-level schema drift')
    if policy['schema_version'] != 1 or 'No weighted score' not in policy['principle']:
        die('burden policy version/principle drift')
    if set(policy['allowed_closed_statuses']) != CLOSED:
        die('burden policy closed statuses drift')
    if set(policy['allowed_working_statuses']) != WORKING - CLOSED:
        die('burden policy working statuses drift')
    if policy['all_requirement_ids'] != req_ids:
        die('burden policy requirement inventory drift')
    if policy['all_obligation_ids'] != [row['claim_id'] for row in rows]:
        die('burden policy obligation inventory drift')
    if set(policy['profiles']) != set(PROFILE_COLUMN):
        die('burden policy profile inventory drift')
    for profile, column in PROFILE_COLUMN.items():
        wanted_req = [row['requirement_id'] for row in matrix if row[column] == 'YES']
        wanted_obs = sorted({
            oid for row in matrix if row[column] == 'YES'
            for oid in row['obligation_ids'].split(';')
        })
        record = policy['profiles'][profile]
        if set(record) != {'required_requirement_ids','required_obligation_ids'}:
            die(f'burden policy {profile} schema drift')
        if record['required_requirement_ids'] != wanted_req:
            die(f'burden policy {profile} requirement set drift')
        if record['required_obligation_ids'] != wanted_obs:
            die(f'burden policy {profile} obligation set drift')
    validate_operational_docs()
    return matrix, policy

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument(
        '--profile', choices=['lint','submission','confidence99','phd_defense'],
        default='lint'
    )
    args=ap.parse_args()
    with (AUDIT/'OBLIGATIONS.csv').open(newline='') as f:
        rd=csv.DictReader(f)
        if rd.fieldnames != COLS: die(f'obligation columns drift: {rd.fieldnames!r}')
        rows=list(rd)
    ids=[r['claim_id'] for r in rows]
    if not ids or len(ids)!=len(set(ids)): die('empty or duplicate claim_id')
    for r in rows:
        if r['status'] not in WORKING: die(f"{r['claim_id']}: forbidden status {r['status']!r}")
        if not r['statement'] or not r['claim_type'] or not r['primary_evidence']:
            die(f"{r['claim_id']}: empty statement/type/primary evidence")
        if r['status']=='FORMAL-PASS' and r['claim_type']!='FORMAL':
            die(f"{r['claim_id']}: FORMAL-PASS on non-formal claim")
        if r['status']=='CITED-PASS' and r['claim_type']!='CITED':
            die(f"{r['claim_id']}: CITED-PASS on non-cited claim")
        if r['status']=='COMPUTED-PASS' and r['claim_type']!='COMPUTED':
            die(f"{r['claim_id']}: COMPUTED-PASS on non-computed claim")
    matrix, policy = load_and_validate_matrix(rows)
    verify_obligation_hashes(rows)
    validate_dependency_dag()
    validate_universal_claims()
    validate_reports()
    cfsg=json.loads((AUDIT/'CLASSIFICATION-MANIFEST.json').read_text())
    if cfsg['classification_source']['obligation'] not in ids:
        die('classification source obligation is not in ledger')
    source_text=(AUDIT/'SOURCE-LEDGER.md').read_text()
    if 'TODO' in (AUDIT/'OBLIGATIONS.csv').read_text() or 'TODO' in source_text:
        die('TODO remains in an obligation/source ledger')
    source_open=sum(1 for line in source_text.splitlines() if '| OPEN |' in line)

    unresolved=[r for r in rows if r['status']=='UNRESOLVED']
    cleanroom=next(r for r in rows if r['claim_id']=='CLEANROOM')
    validate_cleanroom(require_complete=cleanroom['status'] in CLOSED)
    if args.profile=='lint':
        open_requirements = sum(r['derived_status'] == 'OPEN' for r in matrix)
        print(
            'AUDIT SCHEMA|PASS|'
            f'obligations={len(rows)}|unresolved={len(unresolved)}|'
            f'requirements={len(matrix)}|open_requirements={open_requirements}|'
            f'source_open={source_open}'
        )
        return 0
    profile = policy['profiles'][args.profile]
    required_ids = set(profile['required_obligation_ids'])
    required = [r for r in rows if r['claim_id'] in required_ids]
    failed=[r for r in required if r['status'] not in CLOSED]
    required_req_ids = set(profile['required_requirement_ids'])
    required_matrix = [r for r in matrix if r['requirement_id'] in required_req_ids]
    failed_requirements = [r for r in required_matrix if r['derived_status'] != 'PASS']
    if args.profile=='confidence99':
        formal_required={'RED-QUOT','RED-MIN','RED-COORD','SUP-EXIST','SUP-MAX',
                         'SUP-NONCONJ','DIV-GROUP','DIV-ARITH','ARITH-UNIVERSAL','FORM-CORE'}
        wrong=[x for x in formal_required if next(r for r in rows if r['claim_id']==x)['status']!='FORMAL-PASS']
        if wrong:
            print('formal requirements not closed:', ', '.join(sorted(wrong)))
    print(f'profile: {args.profile}')
    print(f'closed obligations: {sum(r["status"] in CLOSED for r in required)}/{len(required)}')
    print(f'closed granular requirements: {sum(r["derived_status"] == "PASS" for r in required_matrix)}/{len(required_matrix)}')
    if failed:
        for r in failed:
            affected = sum(
                r['claim_id'] in q['obligation_ids'].split(';')
                for q in failed_requirements
            )
            print(f'OPEN-OBLIGATION|{r["claim_id"]}|requirements={affected}|{r["statement"]}')
        for r in failed_requirements:
            print(
                f'OPEN-REQUIREMENT|{r["requirement_id"]}|'
                f'{r["source_section"]}|{r["requirement"]}'
            )
        print(args.profile.upper()+' GATE|FAIL')
        return 1
    print(args.profile.upper()+' GATE|PASS')
    return 0

if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,UnicodeError,json.JSONDecodeError,csv.Error) as exc: die(str(exc))
