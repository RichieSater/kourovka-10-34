#!/usr/bin/env python3
"""Mutation tests for every advertised fail-closed gate class."""
from __future__ import annotations
import json, os, re, shutil, subprocess, sys, tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PY=sys.executable
SCRIPTS={
 'finite': ROOT/'computations/independent/verify_finite_witnesses.py',
 'logs': ROOT/'computations/independent/verify_logs.py',
 'family': ROOT/'computations/independent/verify_family_manifest.py',
 'coverage': ROOT/'computations/python/verify_coverage.py',
 'audit': ROOT/'audit/check_audit.py',
 'maximality': ROOT/'computations/independent/verify_maximality_sources.py',
 'formal': ROOT/'formal/check_formal.py',
 'arith': ROOT/'computations/python/sweepN_item5_arith.py',
}

def snapshot(dst: Path) -> None:
    # Copy the entire evidence tree rather than only the files used by the
    # original mutations.  The obligation ledger binds closed rows to GAP
    # sources, environment locks, independent checkers, and receipts; a
    # mutation baseline that omits any of those artifacts must fail.
    dst.mkdir(parents=True)
    shutil.copytree(ROOT/'computations',dst/'computations',
                    ignore=shutil.ignore_patterns('__pycache__','*.regen'))
    shutil.copytree(ROOT/'audit',dst/'audit')
    for name in ['README.md','verify-quick.sh','verify-full.sh','submission-gate.sh']:
        shutil.copy2(ROOT/name,dst/name)
    (dst/'paper').mkdir()
    shutil.copy2(ROOT/'paper/kourovka1034.tex',dst/'paper/kourovka1034.tex')
    shutil.copytree(ROOT/'formal',dst/'formal',ignore=shutil.ignore_patterns('.lake'))
    # check_audit also validates repository-root operational instructions.
    # Give every snapshot its own non-Git operational root so mutations cannot
    # leak between otherwise isolated cases.
    operational=dst/'_repo'; operational.mkdir()
    for name in ['AGENTS.md','CLAUDE.md','.gitignore']:
        shutil.copy2(ROOT.parent/name,operational/name)

def run(which: str, root: Path) -> subprocess.CompletedProcess:
    env=os.environ.copy(); env['KOUROVKA_SUPPORTING_ROOT']=str(root)
    env['KOUROVKA_FORMAL_ROOT']=str(root/'formal')
    env['KOUROVKA_REPO_ROOT']=str(root/'_repo')
    # Most checkers accept an explicit evidence-root environment variable.  The
    # self-contained arithmetic program does not read repository files, so its
    # mutated snapshot itself must be executed.
    script=(root/'computations/python/sweepN_item5_arith.py') if which=='arith' else SCRIPTS[which]
    cmd=[PY,str(script)]
    if which=='audit': cmd += ['--profile','lint']
    if which=='formal': cmd += ['--no-build']
    return subprocess.run(cmd,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)

def replace_first(path: Path, pattern: str, repl) -> None:
    text=path.read_text()
    new,n=re.subn(pattern,repl,text,count=1,flags=re.M)
    if n!=1: raise RuntimeError(f'mutation pattern absent: {pattern} in {path}')
    path.write_text(new)

def main() -> int:
    with tempfile.TemporaryDirectory(prefix='kourovka-mutations-') as t:
        base=Path(t)/'base'; snapshot(base)
        for checker in ['coverage','family','finite','logs','audit','maximality','formal','arith']:
            r=run(checker,base)
            if r.returncode:
                print(r.stdout)
                raise SystemExit(f'HARD-FAIL: baseline {checker} checker fails')

        tests=[]
        def case(name, checker, mutate): tests.append((name,checker,mutate))
        case('remove canonical simple group','coverage',lambda r:
             (r/'computations/data/simple_groups_below_500000.txt').write_text(
              '\n'.join((r/'computations/data/simple_groups_below_500000.txt').read_text().splitlines()[1:])+'\n'))
        def remove_family(r):
            p=r/'audit/CLASSIFICATION-MANIFEST.json'; d=json.loads(p.read_text()); d['families'].pop(); p.write_text(json.dumps(d))
        case('remove CFSG family','family',remove_family)
        def change_family_route(r):
            p=r/'audit/CLASSIFICATION-MANIFEST.json'; d=json.loads(p.read_text())
            d['families'][0]['route']='WRONG-ROUTE'; p.write_text(json.dumps(d))
        case('change CFSG family route','family',change_family_route)
        def remove_exception(r):
            p=r/'audit/EXCEPTION-MANIFEST.json'; d=json.loads(p.read_text()); d['exceptions'].pop(0); p.write_text(json.dumps(d))
        case('remove routed exception','family',remove_exception)
        def remove_x(r):
            p=r/'computations/certificates/sweepJ_divisibility.log'
            lines=p.read_text().splitlines(); i=next(i for i,x in enumerate(lines) if x.startswith('CERT|')); lines.pop(i); p.write_text('\n'.join(lines)+'\n')
        case('remove one X-case certificate','finite',remove_x)
        def change_class(r):
            p=r/'computations/certificates/sweepJ_divisibility.log'
            replace_first(p,r'(?m)^(CERT\|[^\n]*\|uclass=)(\d+)',lambda m:m.group(1)+str(int(m.group(2))+1))
        case('change maximal-subgroup class','finite',change_class)
        def change_prime(r):
            p=r/'computations/certificates/sweepJ_divisibility.log'
            replace_first(p,r'(?m)^(CERT\|[^\n]*\|p=)\d+',r'\g<1>4')
        case('change obstruction prime','finite',change_prime)
        def change_val(r):
            p=r/'computations/certificates/sweepJ_divisibility.log'
            replace_first(p,r'(?m)^(CERT\|[^\n]*\|d=)(\d+)',lambda m:m.group(1)+str(int(m.group(2))+1))
        case('alter one valuation','finite',change_val)
        def corrupt_cert(r):
            p=r/'computations/certificates/sweepJ_divisibility.log'; replace_first(p,r'(?m)^(CERT\|[^\n]*\|result=)PASS',r'\g<1>CORRUPT')
        case('corrupt certificate result','finite',corrupt_cert)
        def force_fail(r):
            p=r/'computations/certificates/sweepK2_saturation.log'; p.write_text(p.read_text()+'HARD-FAIL: injected\n')
        case('force GAP-style failure','logs',force_fail)
        def package_drift(r):
            p=r/'computations/certificates/sweepM_sporadic.log'; replace_first(p,'ctbllib=1.3.11','ctbllib=1.3.10')
        case('change package version','logs',package_drift)
        def add_todo(r):
            p=r/'audit/OBLIGATIONS.csv'; p.write_text(p.read_text()+'TODO\n')
        case('leave TODO in audit matrix','audit',add_todo)
        def drift_hashed_evidence(r):
            p=r/'paper/kourovka1034.tex'; p.write_text(p.read_text()+'\n% injected evidence drift\n')
        case('alter obligation-bound evidence','audit',drift_hashed_evidence)
        def source_pinpoint_drift(r):
            p=r/'audit/MAXIMALITY-SOURCE-MAP.csv'
            replace_first(p,r'Theorem C, pp\. 33--34','Theorem C, p. 999')
        case('change maximality source pinpoint','maximality',source_pinpoint_drift)
        def add_sorry(r):
            p=r/'formal/Kourovka1034/Reduction.lean'
            p.write_text(p.read_text()+'\nexample : True := by sorry\n')
        case('insert inline Lean placeholder','formal',add_sorry)
        def formal_lock_drift(r):
            p=r/'formal/FORMAL-COVERAGE.json'; d=json.loads(p.read_text())
            d['mathlib_commit']='0'*40; p.write_text(json.dumps(d))
        case('change formal library lock','formal',formal_lock_drift)
        def exceptional_gap_drift(r):
            p=r/'computations/python/sweepN_item5_arith.py'
            replace_first(p,
                          r'check_direct\("X:S4\(8\)", 3, spo\(4, 8\), \[8\*\*4\*49, szo\(8\)\], 6, 1\)',
                          'check_direct("X:S4(8)", 3, spo(4, 8), [8**4*49, szo(8)], 6, 4)')
        case('alter exceptional valuation gap','arith',exceptional_gap_drift)
        def cleanroom_schema_drift(r):
            p=r/'audit/CLEANROOM-RECEIPTS.json'; d=json.loads(p.read_text())
            d['required_distinct_machines']=1; p.write_text(json.dumps(d))
        case('weaken clean-room machine policy','audit',cleanroom_schema_drift)
        def remove_burden_row(r):
            p=r/'audit/BURDEN-OF-PROOF-MATRIX.csv'
            lines=p.read_text().splitlines(); lines.pop(1)
            p.write_text('\n'.join(lines)+'\n')
        case('remove granular burden row','audit',remove_burden_row)
        def weaken_submission_profile(r):
            p=r/'audit/BURDEN-OF-PROOF-MATRIX.csv'
            replace_first(p,r'(?m)^(IMM-01,[^\n]*?),YES,YES,NO,',r'\1,NO,YES,NO,')
        case('weaken burden profile flag','audit',weaken_submission_profile)
        def forge_derived_status(r):
            p=r/'audit/BURDEN-OF-PROOF-MATRIX.csv'
            replace_first(p,r'(?m)^(IMM-01,[^\n]*?),PASS,',r'\1,OPEN,')
        case('forge granular burden status','audit',forge_derived_status)
        def hide_proof_logs(r):
            p=r/'_repo/.gitignore'; p.write_text(p.read_text()+'\n*.log\n')
        case('hide proof logs in gitignore','audit',hide_proof_logs)
        def break_writer_gate_guide(r):
            p=r/'audit/WRITER-GATE-README.md'
            text=p.read_text()
            if 'submission-gate.sh confidence99' not in text:
                raise RuntimeError('writer guide gate command absent')
            p.write_text(text.replace(
                'submission-gate.sh confidence99',
                'submission-gate.sh confidence98',
            ))
        case('remove writer guide gate command','audit',break_writer_gate_guide)
        def break_dependency_dag(r):
            p=r/'audit/DEPENDENCY-DAG.json'; d=json.loads(p.read_text())
            d['nodes'][0]['hypotheses']=[]; p.write_text(json.dumps(d))
        case('erase dependency-DAG hypotheses','audit',break_dependency_dag)
        def remove_universal_occurrence(r):
            p=r/'audit/UNIVERSAL-CLAIMS.csv'
            lines=p.read_text().splitlines(); lines.pop(1)
            p.write_text('\n'.join(lines)+'\n')
        case('remove universal-claim audit row','audit',remove_universal_occurrence)
        def stale_submission_report(r):
            p=r/'audit/SUBMISSION-REPORT.md'; p.write_text(p.read_text()+'stale injected count\n')
        case('stale generated submission report','audit',stale_submission_report)

        for index,(name,checker,mutate) in enumerate(tests,1):
            d=Path(t)/f'm{index}'; shutil.copytree(base,d)
            mutate(d); result=run(checker,d)
            if result.returncode==0:
                raise SystemExit(f'HARD-FAIL: mutation escaped detection: {name}')
            print(f'MUTATION DETECTED|{name}|checker={checker}|PASS')
        print(f'MUTATION TEST SUITE|PASS|detected={len(tests)}/{len(tests)}')
    return 0

if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as exc:
        raise SystemExit('HARD-FAIL: '+str(exc))
