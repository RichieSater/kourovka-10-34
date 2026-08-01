#!/usr/bin/env python3
"""Machine-check high-risk manuscript/manifest/certificate consistency tokens."""
from __future__ import annotations
import csv,json,os,re,sys
from pathlib import Path
ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[2])).resolve()
TEX=(ROOT/'paper/kourovka1034.tex').read_text()
CFSG=json.loads((ROOT/'audit/CLASSIFICATION-MANIFEST.json').read_text())

def die(m): raise SystemExit('HARD-FAIL: '+m)
for forbidden in ['TODO','ContainedConjugates(S, W, V, true)',
 'checked against the stored class fusions','Our argument is independent of \\cite{TT2010}',
 'four independent layers','exhaustively tested candidate groups',
 'the first full proof','the first solution']:
 if forbidden in TEX: die('forbidden/stale manuscript phrase: '+forbidden)
required=[
 'CTblLib~1.3.11','AtlasRep~2.1.11','b12f8342d641075d58fcbe62cc00dd433d7b8e18',
 'recorded seed $1034$','no explicit random witness search',
 'IntermediateSubgroups(S,V)','N_S(V)\\backslash S/W','without','positions $45,46$',
 'unique-order stability argument','If $k=1$','Tikhonenko--Tyutyanov \\cite{TT2010}',
 'Zenkov had announced a negative','\\cite{Zenkov1997}',
 'we claim a proof of the stated theorem, not absolute priority',
 'five separately auditable layers',
 'every quotient-class representative',
 'Raw GAP class positions and pc-generator',
 'contiguous, fingerprint-distinct',
 'the $38$ groups', 'the other $13$',
 'regression checks, not proofs of the statements',
 'quotient inheritance and the minimal-order core',
 'subgroup-product/lower-divisibility bridge',
 ']{GLS1}','\\cite{LPS1990}','$7892$ parameter instances',
 '\\cite[Lemma~2.10, pp.~173--174]{ZhangShi2009}',
 '\\cite[p.~432]{LucchiniMorini2002}',
]
for token in required:
 if token not in TEX: die('required manuscript token missing: '+token)
labels=set(re.findall(r'\\label\{([^}]+)\}',TEX))
for label in ['thm:main','thm:D','thm:psl2','thm:an','thm:nograph','thm:twisted2','thm:twisted1','thm:graph','prop:base','prop:sporadic','prop:coverage']:
 if label not in labels: die('missing theorem label '+label)
# Ensure the hand-authored classification routes are represented by the exact
# family names in the coverage proposition/manuscript.
family_tokens={
 'alternating':'$A_n$', 'psl2':'$\\PSL(2,q)$', 'psl_rank_ge3':'$\\PSL(n,q)$',
 'psu3':'$\\PSU(n,q)$', 'psu_rank_ge4':'$\\PSU(n,q)$',
 'symplectic':'$\\PSp(2n,q)$',
 'odd_orthogonal':'$\\Omega(2n{+}1,q)$', 'plus_orthogonal':'$D_n(q)$',
 'minus_orthogonal':'${}^2D_n(q)$', 'suzuki':'$\\Sz(2^f)$',
 'small_ree':'${}^2G_2(3^f)$', 'triality':'${}^3D_4(q)$',
 'g2':'$G_2(q)$', 'f4':'$F_4(q)$', 'e6':'$E_6(q)$',
 'twisted_e6':'${}^2E_6(q)$', 'e7':'$E_7(q)$', 'e8':'$E_8(q)$',
 'large_ree':'${}^2F_4(2^f)$', 'tits':'${}^2F_4(2)\'$','sporadic':'Sporadic groups'
}
ids={x['id'] for x in CFSG['families']}
if ids != set(family_tokens): die('checker family token map drift')
for fid,token in family_tokens.items():
 if token not in TEX: die(f'manuscript lacks family token for {fid}: {token}')

def noncomment_lines(path: Path) -> list[str]:
 return [line for line in path.read_text().splitlines()
         if line.strip() and not line.lstrip().startswith(('#','TOTAL'))]

if len(noncomment_lines(ROOT/'computations/data/simple_groups_below_500000.txt')) != 47:
 die('small finite-inventory count drift')
if len(noncomment_lines(ROOT/'computations/data/simple_groups_5e5_to_1.05e7.txt')) != 51:
 die('big finite-inventory count drift')
arith=(ROOT/'computations/certificates/sweepN_item5_arith.log').read_text()
if 'instances checked: 7892' not in arith or 'FAILURES: 0' not in arith:
 die('7892-instance receipt does not match manuscript')
for name,count in [('LIE-SOURCE-MAP.csv',7),('MAXIMALITY-SOURCE-MAP.csv',10),
                   ('SPORADIC-SOURCE-MAP.csv',42)]:
 with (ROOT/'audit'/name).open(newline='') as f: actual=sum(1 for _ in csv.DictReader(f))
 if actual != count: die(f'{name}: row count drift: {actual} != {count}')
exceptions=json.loads((ROOT/'audit/EXCEPTION-MANIFEST.json').read_text())['exceptions']
if len(exceptions) != 17: die('exception-manifest count drift')

gap_essential=[
 'sweepJ_divisibility','sweepJ2_tail','sweepJ3_bigrange','sweepJ4_patch',
 'sweepJ5_smallAn','sweepJ6_L52_M23','sweepK_novelty','sweepK2_saturation',
 'sweepK3_bigsurvivors','sweepK4_L52','sweepM_sporadic',
 'sweepL_psl2_arith','sweepL2_an_arith',
]
full=(ROOT/'verify-full.sh').read_text()
log_checker=(ROOT/'computations/independent/verify_logs.py').read_text()
static_checker=(ROOT/'audit/static_check.py').read_text()
for base in gap_essential:
 for path in [ROOT/f'computations/gap/{base}.g',ROOT/f'computations/certificates/{base}.log']:
  if not path.is_file(): die(f'missing proof-essential artifact {path.relative_to(ROOT)}')
 if base not in full or base not in log_checker or f'{base}.g' not in static_checker:
  die(f'proof-essential sweep omitted from a gate: {base}')

python_checkers=[
 'computations/python/sweepN_item5_arith.py',
 'computations/python/verify_coverage.py','computations/python/verify_coverage_big.py',
 'computations/independent/family_arithmetic_symbolic.py',
 'computations/independent/verify_family_manifest.py',
 'computations/independent/verify_finite_witnesses.py',
 'computations/independent/verify_lie_sources.py',
 'computations/independent/verify_maximality_sources.py',
 'computations/independent/verify_logs.py',
 'computations/independent/verify_manuscript.py',
]
quick=(ROOT/'verify-quick.sh').read_text()
for script in python_checkers:
 if not (ROOT/script).is_file(): die('missing proof checker '+script)
 if script not in full or script not in quick: die('checker omitted from quick/full gate: '+script)

print(f'MANUSCRIPT/MANIFEST CONSISTENCY|PASS|families={len(ids)}|required_tokens={len(required)}|source_rows=59|exceptions={len(exceptions)}|gap_sweeps={len(gap_essential)}|checkers={len(python_checkers)}')
