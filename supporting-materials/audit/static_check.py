#!/usr/bin/env python3
"""Static fail-closed checks for nondeterminism, soft failure, and prose drift."""
from __future__ import annotations
import os,re,sys
from pathlib import Path
ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[1])).resolve()
GAP=ROOT/'computations/gap'
ESSENTIAL=[
'sweepJ_divisibility.g','sweepJ2_tail.g','sweepJ3_bigrange.g','sweepJ4_patch.g','sweepJ5_smallAn.g','sweepJ6_L52_M23.g',
'sweepK_novelty.g','sweepK2_saturation.g','sweepK3_bigsurvivors.g','sweepK4_L52.g','sweepM_sporadic.g',
'sweepL_psl2_arith.g','sweepL2_an_arith.g']
LIBRARIES=['proof_common.g','sweepJ_lib.g','sweepK_lib.g']
PYTHON_ESSENTIAL=[
'computations/python/sweepN_item5_arith.py','computations/python/verify_coverage.py',
'computations/python/verify_coverage_big.py','computations/independent/family_arithmetic_symbolic.py',
'computations/independent/verify_family_manifest.py','computations/independent/verify_finite_witnesses.py',
'computations/independent/verify_lie_sources.py','computations/independent/verify_maximality_sources.py',
'computations/independent/verify_logs.py','computations/independent/verify_manuscript.py',
'audit/check_dependency_dag.py','audit/check_universal_claims.py',
'audit/update_reports.py']

def die(m): raise SystemExit('HARD-FAIL: '+m)
for name in ESSENTIAL+LIBRARIES:
    text=(GAP/name).read_text()
    code=re.sub(r'#.*','',text)
    for pat in [r'\bRandom\s*\(',r'\bPseudoRandom',r'\bSmallGeneratingSet\s*\(',
                r'CALL_WITH_CATCH',r'ContainedConjugates\s*\([^\n]*,\s*true\s*\)']:
        if re.search(pat,code): die(f'{name}: forbidden operation matches {pat}')
    if name in ESSENTIAL and '|PASS' not in text: die(f'{name}: no terminal PASS marker')
for relative in PYTHON_ESSENTIAL:
    code=(ROOT/relative).read_text()
    if re.search(r'^\s*(?:from\s+random\s+import|import\s+random\b)',code,re.M):
        die(f'{relative}: random module on proof path')
k2=(GAP/'sweepK2_saturation.g').read_text()
for token in ['IntermediateSubgroups','DirectContainedConjugates','ContainedConjugates(S,W,V)']:
    if token not in k2: die('K2 lost required path '+token)
k=(GAP/'sweepK_novelty.g').read_text()
for token in ['CanonicalQuotientClassActionRecords(Q0,classHom,Length(reps),hom)','qreps := qrecord.reps',
              'for XQ in qreps do','signature := [maxel,best]',
              'xclass_sha256=','xconjugates=']:
    if token not in k: die('K lost quotient-class canonicalization: '+token)
jlib=(GAP/'sweepJ_lib.g').read_text()
for token in ['CanonicalQuotientClassActionRecords(Q0,classHom,Length(mx),hom)','qreps := qrecord.reps',
              'for XQ in qreps do','classAllk := fail','XCASE|group=',
              'xclass_sha256=','xconjugates=',
              'GroupHomomorphismByImages(Q0,classSym,qgens,qperms)']:
    if token not in jlib: die('J lost quotient-class canonicalization: '+token)
k3=(GAP/'sweepK3_bigsurvivors.g').read_text()
for token in ['GF2-subfield-matrices','ImmutableMatrix','InnerAutomorphism(S0,t)']:
    if token not in k3: die('deterministic Sp(4,2) subfield construction missing: '+token)
if 'Random' in re.sub(r'#.*','',k3): die('random O(5,4) witness construction returned')
common=(GAP/'proof_common.g').read_text()
for token in ['PROOF_RNG_SEED := 1034','Reset(GlobalMersenneTwister,PROOF_RNG_SEED)',
              'Reset(GlobalRandomSource,PROOF_RNG_SEED)','|rng_seed=',
              'CanonicalQuotientClassActionRecords','PermutationSubgroupKey']:
    if token not in common: die('fixed GAP random-source policy missing: '+token)
for f in (ROOT/'formal').glob('Kourovka1034/**/*.lean'):
    text=f.read_text()
    if re.search(r'^\s*(sorry|admit|axiom)\b',text,re.M): die(f'{f}: placeholder/custom axiom')
for extra in (ROOT/'computations/certificates').glob('*.regen'):
    die(f'stale regeneration file: {extra.name}')
for extra in (ROOT/'computations/certificates').glob('*.new'):
    die(f'stale incomplete file: {extra.name}')
lock=(ROOT/'computations/environment/environment.lock.json').read_text()
if 'b12f8342d641075d58fcbe62cc00dd433d7b8e18' not in lock: die('GAP regression fix pin missing')
full=(ROOT/'verify-full.sh').read_text()
if 'set -eu' not in full or 'cmp -s' not in full or 'exit 1' not in full:
    die('full reproduction lost fail-closed shell/diff behavior')
print(f'STATIC DETERMINISM/SOFT-FAIL CHECK|PASS|gap_drivers={len(ESSENTIAL)}|gap_libraries={len(LIBRARIES)}|python_checkers={len(PYTHON_ESSENTIAL)}')
