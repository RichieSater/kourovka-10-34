#!/usr/bin/env python3
"""Write or verify per-obligation SHA-256 evidence bindings.

Each closed ledger row is bound to an explicit, reviewable set of local
artifacts.  The digest includes every relative path and its bytes in sorted
order.  Unresolved rows deliberately carry no passing evidence hash.
"""
from __future__ import annotations
import argparse, csv, hashlib, os, sys
from pathlib import Path

ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[1])).resolve()
LEDGER=ROOT/'audit/OBLIGATIONS.csv'
CLOSED={'FORMAL-PASS','CITED-PASS','COMPUTED-PASS','REDUNDANT'}

BASE={
 'RED-QUOT':['formal/Kourovka1034/Property.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'RED-MIN':['formal/Kourovka1034/Reduction.lean','formal/Kourovka1034/Property.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'RED-COORD-BOUND':['formal/Kourovka1034/CoordinateReduction.lean','formal/Kourovka1034/Reduction.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'SRC-REDUCTION-STRUCTURE':['audit/SOURCE-LEDGER.md','paper/kourovka1034.tex','formal/Kourovka1034/CoordinateReduction.lean'],
 'PAR-NOVELTY':['paper/kourovka1034.tex','audit/SOURCE-LEDGER.md'],
 'DIV-ARITH':['formal/Kourovka1034/Divisibility.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'DIV-GROUP':['formal/Kourovka1034/ProductSupplements.lean','formal/Kourovka1034/Property.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'SUP-EXIST':['formal/Kourovka1034/ProductSupplements.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'SUP-MAX':['formal/Kourovka1034/Maximality.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'SUP-NONCONJ':['formal/Kourovka1034/ProductSupplements.lean','formal/Kourovka1034/Property.lean','formal/FORMAL-COVERAGE.json','formal/AxiomAudit.lean','formal/check_formal.py','formal/lean-toolchain','formal/lake-manifest.json'],
 'K1-TT':['paper/kourovka1034.tex','audit/SOURCE-LEDGER.md'],
 'COMP-ENV':['computations/environment/environment.lock.json','computations/environment/Dockerfile','computations/environment/check-environment.sh','computations/gap/proof_common.g'],
 'COMP-K2':['computations/gap/sweepK2_saturation.g','computations/gap/proof_common.g','computations/certificates/sweepK2_saturation.log','computations/independent/verify_finite_witnesses.py'],
 'COMP-SPORADIC':['computations/gap/sweepM_sporadic.g','computations/certificates/sweepM_sporadic.log','audit/SPORADIC-SOURCE-MAP.csv','computations/independent/verify_finite_witnesses.py'],
 'CFSG-INVENTORY':['audit/CLASSIFICATION-MANIFEST.json','audit/EXCEPTION-MANIFEST.json','computations/independent/verify_family_manifest.py','computations/certificates/verify_family_manifest.log'],
 'CFSG-BOUNDARIES':['audit/CLASSIFICATION-MANIFEST.json','audit/EXCEPTION-MANIFEST.json','computations/independent/verify_family_manifest.py','computations/certificates/verify_family_manifest.log'],
 'ARITH-REGRESSION':['computations/python/sweepN_item5_arith.py','computations/certificates/sweepN_item5_arith.log','audit/EXCEPTION-MANIFEST.json'],
 'ARITH-SYMBOLIC':['computations/independent/family_arithmetic_symbolic.py','computations/certificates/family_arithmetic_symbolic.log'],
 'SRC-CFSG-PINPOINT':['audit/CLASSIFICATION-MANIFEST.json','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex'],
 'SRC-TWISTED-BN':['audit/LIE-SOURCE-MAP.csv','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex'],
 'SRC-2E6-LEVI':['audit/LIE-SOURCE-MAP.csv','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex','computations/independent/verify_lie_sources.py','computations/certificates/verify_lie_sources.log'],
 'SRC-AUTOMORPHISMS':['audit/LIE-SOURCE-MAP.csv','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex','computations/independent/verify_lie_sources.py'],
 'SRC-MAXIMALITY':['audit/MAXIMALITY-SOURCE-MAP.csv','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex','computations/independent/verify_maximality_sources.py','computations/certificates/verify_maximality_sources.log'],
 'SRC-SPORADIC-MAX':['audit/SPORADIC-SOURCE-MAP.csv','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex','computations/independent/verify_finite_witnesses.py'],
 'LIT-KOUROVKA':['audit/PRIORITY-SEARCH.md','audit/SOURCE-LEDGER.md','paper/kourovka1034.tex'],
 'MANUSCRIPT-CODE':['paper/kourovka1034.tex','computations/independent/verify_manuscript.py','computations/certificates/verify_manuscript.log','audit/CLASSIFICATION-MANIFEST.json','audit/EXCEPTION-MANIFEST.json'],
 'DEPENDENCY-AUDIT':['audit/DEPENDENCY-DAG.json','audit/check_dependency_dag.py','paper/kourovka1034.tex'],
 'UNIVERSAL-CLAIM-AUDIT':['audit/UNIVERSAL-CLAIMS.csv','audit/check_universal_claims.py','paper/kourovka1034.tex'],
 'AUDIT-REPORTS':['audit/update_reports.py','audit/STOP-SHIP.md','audit/SUBMISSION-REPORT.md','audit/BURDEN-OF-PROOF-MATRIX.csv','audit/BURDEN-POLICY.json','formal/FORMAL-COVERAGE.json','computations/certificates/mutation_tests.log','audit/CLEANROOM-RECEIPTS.json'],
 'DETERMINISM':['verify-full.sh','audit/static_check.py','audit/RED-TEAM-REPORT.md','computations/gap/proof_common.g','computations/gap/sweepJ_lib.g','computations/gap/sweepK_novelty.g','computations/gap/sweepK2_saturation.g','computations/gap/sweepK3_bigsurvivors.g','computations/certificates/SHA256SUMS','computations/certificates/verify_logs.log','computations/certificates/mutation_tests.log'],
 'MUTATIONS':['computations/mutation-tests/run_mutation_tests.py','computations/certificates/mutation_tests.log'],
 'CLEANROOM':['audit/CLEANROOM-RECEIPTS.json','audit/check_cleanroom.py',
              'computations/environment/run-cleanroom.sh','computations/environment/Dockerfile',
              'computations/environment/environment.lock.json'],
}

def targets(claim_id:str)->list[Path]:
    if claim_id=='CLEANROOM':
        rel=BASE[claim_id][:]
        rel += [p.relative_to(ROOT).as_posix() for p in sorted(
            (ROOT/'audit/cleanroom-logs').glob('*.log')) if p.is_file()]
        return [ROOT/x for x in rel]
    if claim_id=='COMP-FINITE-BASE':
        names=['sweepJ_divisibility','sweepJ2_tail','sweepJ3_bigrange','sweepJ4_patch','sweepJ5_smallAn','sweepJ6_L52_M23','sweepK_novelty','sweepK2_saturation','sweepK3_bigsurvivors','sweepK4_L52','verify_coverage','verify_coverage_big']
        rel=['computations/data/simple_groups_below_500000.txt','computations/data/simple_groups_5e5_to_1.05e7.txt','computations/python/verify_coverage.py','computations/python/verify_coverage_big.py','computations/independent/verify_finite_witnesses.py']
        rel += [f'computations/certificates/{n}.log' for n in names]
        return [ROOT/x for x in rel]
    if claim_id=='COMP-INDEPENDENT':
        rel=[]
        for p in sorted((ROOT/'computations/independent').glob('*.py')): rel.append(p.relative_to(ROOT).as_posix())
        for p in sorted((ROOT/'computations/certificates').glob('verify_*.log')): rel.append(p.relative_to(ROOT).as_posix())
        rel.append('computations/certificates/family_arithmetic_symbolic.log')
        return [ROOT/x for x in rel]
    if claim_id=='FORMAL-CLEAN':
        return sorted([p for p in (ROOT/'formal').rglob('*') if p.is_file() and '/.lake/' not in '/'+p.relative_to(ROOT).as_posix()],key=lambda p:p.relative_to(ROOT).as_posix())
    if claim_id not in BASE: raise KeyError(claim_id)
    return [ROOT/x for x in BASE[claim_id]]

def digest(claim_id:str)->str:
    h=hashlib.sha256()
    paths=targets(claim_id)
    if not paths: raise ValueError(f'{claim_id}: empty evidence target set')
    for p in sorted(paths,key=lambda p:p.relative_to(ROOT).as_posix().encode()):
        if not p.is_file(): raise FileNotFoundError(f'{claim_id}: missing evidence {p.relative_to(ROOT)}')
        rel=p.relative_to(ROOT).as_posix().encode()
        h.update(rel); h.update(b'\0'); h.update(p.read_bytes()); h.update(b'\0')
    return 'sha256:'+h.hexdigest()

def load():
    with LEDGER.open(newline='') as f:
        rd=csv.DictReader(f); return rd.fieldnames,list(rd)

def write(fieldnames,rows):
    with LEDGER.open('w',newline='') as f:
        wr=csv.DictWriter(f,fieldnames=fieldnames,lineterminator='\n'); wr.writeheader(); wr.writerows(rows)

def verify_rows(rows)->None:
    for r in rows:
        cid,status,actual=r['claim_id'],r['status'],r['certificate_hash']
        if status in CLOSED:
            try: expected=digest(cid)
            except KeyError: raise SystemExit(f'HARD-FAIL: no hash target map for closed obligation {cid}')
            if actual!=expected: raise SystemExit(f'HARD-FAIL: {cid}: evidence hash missing/drifted')
        elif actual:
            raise SystemExit(f'HARD-FAIL: {cid}: unresolved obligation carries a passing evidence hash')

def main()->int:
    ap=argparse.ArgumentParser(); g=ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--write',action='store_true'); g.add_argument('--verify',action='store_true'); a=ap.parse_args()
    fields,rows=load()
    if a.write:
        for r in rows: r['certificate_hash']=digest(r['claim_id']) if r['status'] in CLOSED else ''
        write(fields,rows)
        print(f'OBLIGATION EVIDENCE HASHES|WROTE|closed={sum(r["status"] in CLOSED for r in rows)}')
    else:
        verify_rows(rows)
        print(f'OBLIGATION EVIDENCE HASHES|PASS|closed={sum(r["status"] in CLOSED for r in rows)}')
    return 0
if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,UnicodeError,ValueError) as exc: raise SystemExit('HARD-FAIL: '+str(exc))
