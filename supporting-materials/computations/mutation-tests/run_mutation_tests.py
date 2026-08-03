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
 'evidence': ROOT/'audit/evidence_hashes.py',
 'maximality': ROOT/'computations/independent/verify_maximality_sources.py',
 'order_sources': ROOT/'computations/independent/verify_order_formula_sources.py',
 'zsigmondy_sources': ROOT/'computations/independent/verify_zsigmondy_sources.py',
 'boundary_sources': ROOT/'computations/independent/verify_boundary_sources.py',
 'formal': ROOT/'formal/check_formal.py',
 'static': ROOT/'audit/static_check.py',
 'rocq': ROOT/'formal-rocq/verify.sh',
 'arith': ROOT/'computations/python/sweepN_item5_arith.py',
 'universal_arith': ROOT/'computations/independent/family_arithmetic_universal.py',
 'symbolic_arith': ROOT/'computations/independent/family_arithmetic_symbolic.py',
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
    for name in ['README.md','verify-quick.sh','verify-full.sh']:
        shutil.copy2(ROOT/name,dst/name)
    shutil.copy2(ROOT/'.gitignore',dst/'.gitignore')
    (dst/'paper').mkdir()
    shutil.copy2(ROOT/'paper/kourovka1034.tex',dst/'paper/kourovka1034.tex')
    shutil.copytree(ROOT/'paper/submission',dst/'paper/submission')
    shutil.copytree(ROOT/'formal',dst/'formal',ignore=shutil.ignore_patterns('.lake'))
    shutil.copytree(ROOT/'formal-rocq',dst/'formal-rocq',
                    ignore=shutil.ignore_patterns('*.vo','*.glob','.*.aux'))
    # Give every snapshot its own non-Git operational root so mutations cannot
    # leak between otherwise isolated cases.
    operational=dst/'_repo'; operational.mkdir()
    for name in ['.gitignore','.dockerignore']:
        shutil.copy2(ROOT.parent/name,operational/name)

def run(which: str, root: Path) -> subprocess.CompletedProcess:
    env=os.environ.copy(); env['KOUROVKA_SUPPORTING_ROOT']=str(root)
    env['KOUROVKA_FORMAL_ROOT']=str(root/'formal')
    env['KOUROVKA_REPO_ROOT']=str(root/'_repo')
    # Most checkers accept an explicit evidence-root environment variable.  The
    # Self-contained arithmetic programs do not read repository files, so the
    # mutated snapshot itself must be executed.  Running the repository copy
    # here would make source mutations vacuous while still reporting a clean
    # baseline.
    if which == 'arith':
        script=root/'computations/python/sweepN_item5_arith.py'
    elif which == 'universal_arith':
        script=root/'computations/independent/family_arithmetic_universal.py'
    elif which == 'symbolic_arith':
        script=root/'computations/independent/family_arithmetic_symbolic.py'
    elif which == 'rocq':
        return subprocess.run(
            ['sh',str(root/'formal-rocq/verify.sh')],env=env,text=True,
            stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
        )
    else:
        script=SCRIPTS[which]
    cmd=[PY,str(script)]
    if which=='audit': cmd += ['--profile','lint']
    if which=='evidence': cmd += ['--verify']
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
        for checker in [
            'coverage','family','finite','logs','evidence','maximality',
            'order_sources','zsigmondy_sources','boundary_sources','formal','static','rocq','arith',
            'universal_arith','symbolic_arith',
        ]:
            r=run(checker,base)
            if r.returncode:
                print(r.stdout)
                raise SystemExit(f'HARD-FAIL: baseline {checker} checker fails')

        # Generated formal build products are intentionally ignored by both
        # Git and the global evidence closure.  Their appearance after a local
        # kernel build must not make a clean evidence manifest drift.
        build_products = [
            base/'formal-rocq/Injected.vo',
            base/'formal-rocq/.Injected.aux',
            base/'formal/Injected.olean',
        ]
        for artifact in build_products:
            artifact.write_bytes(b'generated-build-product\n')
        r = run('evidence', base)
        if r.returncode:
            print(r.stdout)
            raise SystemExit('HARD-FAIL: generated build product entered evidence closure')
        for artifact in build_products:
            artifact.unlink()
        print('BUILD PRODUCT EVIDENCE EXCLUSION|PASS|artifacts=3')

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
        def drift_hashed_evidence(r):
            p=r/'paper/kourovka1034.tex'; p.write_text(p.read_text()+'\n% injected evidence drift\n')
        case('alter hash-bound manuscript evidence','evidence',drift_hashed_evidence)
        def source_pinpoint_drift(r):
            p=r/'audit/MAXIMALITY-SOURCE-MAP.csv'
            replace_first(p,r'Theorem C, pp\. 33--34','Theorem C, p. 999')
        case('change maximality source pinpoint','maximality',source_pinpoint_drift)
        def remove_order_source_row(r):
            p=r/'audit/ORDER-FORMULA-SOURCE-MAP.csv'
            lines=p.read_text().splitlines(); lines.pop(1)
            p.write_text('\n'.join(lines)+'\n')
        case('remove order-formula source row','order_sources',remove_order_source_row)
        def order_semantic_drift(r):
            p=r/'audit/ORDER-FORMULA-SOURCE-MAP.csv'
            replace_first(p, r',n>=15,', ',n>=16,')
        case('alter order-formula parameter range','order_sources',order_semantic_drift)
        def zsigmondy_hash_drift(r):
            p=r/'audit/ZSIGMONDY-INVOCATIONS.csv'
            replace_first(
                p,
                r'45b2aea11e6e92711ab9b744b368dcb8ae0e84e69e5267c8515f61072faa9132',
                '05b2aea11e6e92711ab9b744b368dcb8ae0e84e69e5267c8515f61072faa9132',
            )
        case('alter Zsigmondy source hash','zsigmondy_sources',zsigmondy_hash_drift)
        def zsigmondy_exponent_drift(r):
            p=r/'audit/ZSIGMONDY-INVOCATIONS.csv'
            replace_first(p, r',2,2f,f>=3,6,', ',2,3f,f>=3,6,')
        case('alter Zsigmondy invocation exponent','zsigmondy_sources',zsigmondy_exponent_drift)
        def boundary_pinpoint_drift(r):
            p=r/'audit/BOUNDARY-SOURCE-MAP.csv'
            replace_first(p,r'Theorem 2\.2\.7\(a\)',r'Theorem 2.2.7(b)')
        case('alter boundary source pinpoint','boundary_sources',boundary_pinpoint_drift)
        def boundary_route_drift(r):
            p=r/'audit/BOUNDARY-SOURCE-MAP.csv'
            replace_first(
                p,
                r'BND-PSL2,"PSL\(2,q\) lower boundary",psl2,',
                'BND-PSL2,"PSL(2,q) lower boundary",psu3,',
            )
        case('misroute boundary family','boundary_sources',boundary_route_drift)
        def add_sorry(r):
            p=r/'formal/Kourovka1034/Reduction.lean'
            p.write_text(p.read_text()+'\nexample : True := by sorry\n')
        case('insert inline Lean placeholder','formal',add_sorry)
        def formal_lock_drift(r):
            p=r/'formal/FORMAL-COVERAGE.json'; d=json.loads(p.read_text())
            d['mathlib_commit']='0'*40; p.write_text(json.dumps(d))
        case('change formal library lock','formal',formal_lock_drift)
        def remove_wreath_coverage(r):
            p=r/'formal/FORMAL-COVERAGE.json'; d=json.loads(p.read_text())
            d['closed_manuscript_claims']=[
                x for x in d['closed_manuscript_claims']
                if x['claim_id']!='RED-WREATH-INTERFACE'
            ]
            p.write_text(json.dumps(d))
        case('remove ambient-wreath formal coverage','formal',remove_wreath_coverage)
        def formal_interface_signature_drift(r):
            p=r/'formal/FORMAL-INTERFACE.json'; d=json.loads(p.read_text())
            d['producer']['positive_count']='0 <= #|I|'; p.write_text(json.dumps(d))
        case('alter formal-interface producer signature','formal',formal_interface_signature_drift)
        def formal_interface_reindex_base_drift(r):
            p=r/'formal/FORMAL-INTERFACE.json'; d=json.loads(p.read_text())
            d['reindex']['output']='Nonempty (N ≃* (Fin (Nat.card I) → S))'
            p.write_text(json.dumps(d))
        case('remove formal-interface base-coordinate output','formal',formal_interface_reindex_base_drift)
        def formal_interface_correspondence_drift(r):
            p=r/'formal/FORMAL-INTERFACE.json'; d=json.loads(p.read_text())
            d['definition_correspondence'][1]['lean']='List H'
            p.write_text(json.dumps(d))
        case('alter cross-kernel definition correspondence','formal',formal_interface_correspondence_drift)
        def remove_coord_producer_coverage(r):
            p=r/'formal-rocq/FORMAL-COVERAGE.json'; d=json.loads(p.read_text())
            d['closed_manuscript_claims']=[
                x for x in d['closed_manuscript_claims'] if x['claim_id']!='RED-COORD'
            ]
            p.write_text(json.dumps(d))
        case('remove RED-COORD producer coverage','formal',remove_coord_producer_coverage)
        def delete_formal_interface_checker(r):
            (r/'formal/check_formal_interface.py').unlink()
        case('delete formal-interface checker','formal',delete_formal_interface_checker)
        def delete_wreath_source(r):
            (r/'formal/Kourovka1034/AmbientWreath.lean').unlink()
        case('delete ambient-wreath formal source','formal',delete_wreath_source)
        def rocq_source_pin_drift(r):
            p=r/'formal-rocq/TOOLCHAIN.json'; d=json.loads(p.read_text())
            d['mathcomp_release_commit']='0'*40; p.write_text(json.dumps(d))
        case('change Rocq/MathComp source pin','rocq',rocq_source_pin_drift)
        def rocq_bridge_source_pin_drift(r):
            p=r/'formal-rocq/TOOLCHAIN.json'; d=json.loads(p.read_text())
            d['mathcomp_source_sha256']['finite_group/morphism.v']='0'*64
            p.write_text(json.dumps(d))
        case('change Rocq bridge-source hash','rocq',rocq_bridge_source_pin_drift)
        def add_rocq_admitted(r):
            p=r/'formal-rocq/CharacteristicallySimple.v'
            p.write_text(p.read_text()+'\nLemma injected_escape : True. Admitted.\n')
        case('insert Rocq Admitted escape','rocq',add_rocq_admitted)
        def remove_rocq_from_evidence(r):
            (r/'formal-rocq/CharacteristicallySimple.v').unlink()
        case('remove Rocq source from global evidence closure','evidence',remove_rocq_from_evidence)
        def exceptional_gap_drift(r):
            p=r/'computations/python/sweepN_item5_arith.py'
            replace_first(p,
                          r'check_direct\("X:S4\(8\)", 3, spo\(4, 8\), \[8\*\*4\*49, szo\(8\)\], 6, 1\)',
                          'check_direct("X:S4(8)", 3, spo(4, 8), [8**4*49, szo(8)], 6, 4)')
        case('alter exceptional valuation gap','arith',exceptional_gap_drift)
        def arithmetic_branch_exponent_drift(r):
            p=r/'audit/FAMILY-ARITHMETIC-MANIFEST.json'; d=json.loads(p.read_text())
            branch=next(x for x in d['branches'] if x['id']=='AR-PSL2-EVEN')
            branch['primitive_exponent']=[0,3]; p.write_text(json.dumps(d))
        case('alter universal arithmetic branch exponent','universal_arith',arithmetic_branch_exponent_drift)
        def remove_arithmetic_branch(r):
            p=r/'audit/FAMILY-ARITHMETIC-MANIFEST.json'; d=json.loads(p.read_text())
            d['branches'].pop(); p.write_text(json.dumps(d))
        case('remove universal arithmetic branch','universal_arith',remove_arithmetic_branch)
        def arithmetic_exception_view_drift(r):
            p=r/'audit/ARITHMETIC-EXCEPTIONS.generated.json'; d=json.loads(p.read_text())
            d['exception_cases'].pop(); p.write_text(json.dumps(d))
        case('alter generated arithmetic exception view','universal_arith',arithmetic_exception_view_drift)
        def arithmetic_finite_anchor_drift(r):
            p=r/'audit/FAMILY-ARITHMETIC-MANIFEST.json'; d=json.loads(p.read_text())
            d['finite_exception_anchors'][0]['expected_xcases'] += 1
            p.write_text(json.dumps(d))
        case('alter finite arithmetic anchor count','universal_arith',arithmetic_finite_anchor_drift)
        def arithmetic_substitute_gap_drift(r):
            p=r/'audit/FAMILY-ARITHMETIC-MANIFEST.json'; d=json.loads(p.read_text())
            d['substitute_certificates'][0]['required_gap'] += 1
            p.write_text(json.dumps(d))
        case('alter universal substitute valuation gap','universal_arith',arithmetic_substitute_gap_drift)
        def arithmetic_formal_mirror_drift(r):
            p=r/'formal/Kourovka1034/FamilyArithmetic.lean'
            replace_first(
                p,
                r'(def branchBounds[\s\S]*?⟨\.psl2Even, ⟨0, )1(⟩, ⟨0, 2⟩, 0⟩)',
                r'\g<1>0\g<2>',
            )
        case('alter Lean arithmetic mirror bound','universal_arith',arithmetic_formal_mirror_drift)
        def arithmetic_independent_mirror_drift(r):
            p=r/'computations/independent/family_arithmetic_symbolic.py'
            replace_first(p, r'\(\(\), \(2,\)\), "factor", 1', '((), (1,)), "factor", 1')
        case('diverge independent arithmetic model','universal_arith',arithmetic_independent_mirror_drift)
        def psl2_8_gap_drift(r):
            p=r/'computations/independent/family_arithmetic_symbolic.py'
            replace_first(p, r'assert 2 > vp\(3, 3\) == 1', 'assert 1 > vp(3, 3) == 1')
        case('alter PSL(2,8) substitute-prime gap','symbolic_arith',psl2_8_gap_drift)
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
