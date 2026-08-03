#!/usr/bin/env python3
"""Generic proof-log terminal marker and soft-failure scanner."""
import os,re,sys
from pathlib import Path
ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[2])).resolve()
CERT=ROOT/'computations/certificates'
ESSENTIAL=['sweepJ_divisibility','sweepJ2_tail','sweepJ3_bigrange','sweepJ4_patch','sweepJ5_smallAn','sweepJ6_L52_M23',
'sweepK_novelty','sweepK2_saturation','sweepK3_bigsurvivors','sweepK4_L52','sweepM_sporadic','sweepL_psl2_arith','sweepL2_an_arith','sweepN_item5_arith']
PYTHON_RECEIPTS={
 'family_arithmetic_universal.log':('UNIVERSAL FAMILY ARITHMETIC MANIFEST|PASS',),
 'family_arithmetic_symbolic.log':('INDEPENDENT SYMBOLIC FAMILY ARITHMETIC|PASS',),
 'formal_rocq_charsimple.log':(
   'ROCQ CHARSIMPLE|PASS|theorem=nonsolvable_charsimple_dprod|assumptions=none',
   'ROCQ EXPLICIT POWER|PASS|theorem=nonsolvable_charsimple_explicit_power|assumptions=none|source-pins=6',
 ),
}
BAD=re.compile(r'HARD-FAIL|Traceback|\bERROR\b|\bskipped\b|INCOMPLETE|HAS PROBLEMS|needs attention',re.I)
ENV='ENV|gap=4.16.0|ctbllib=1.3.11|atlasrep=2.1.11|csetgrp_sha256=3e7a00ef8730f6c058213db2f13c076565603ea2467e04aeea756e4afcb76b9f|rng_seed=1034'
for base in ESSENTIAL:
 p=CERT/(base+'.log')
 if not p.is_file(): raise SystemExit('HARD-FAIL: missing '+p.name)
 t=p.read_text()
 m=BAD.search(t)
 if m: raise SystemExit(f'HARD-FAIL: {p.name}: soft failure marker {m.group(0)!r}')
 if '|PASS' not in t: raise SystemExit('HARD-FAIL: no PASS marker in '+p.name)
 if base != 'sweepN_item5_arith' and ENV not in t:
  raise SystemExit('HARD-FAIL: exact environment record missing/drifted in '+p.name)
for name,markers in PYTHON_RECEIPTS.items():
 p=CERT/name
 if not p.is_file(): raise SystemExit('HARD-FAIL: missing '+name)
 t=p.read_text(); m=BAD.search(t)
 if m: raise SystemExit(f'HARD-FAIL: {name}: soft failure marker {m.group(0)!r}')
 for marker in markers:
  if marker not in t: raise SystemExit(f'HARD-FAIL: terminal PASS marker missing/drifted in {name}')
manifest=CERT/'SHA256SUMS'
if not manifest.is_file(): raise SystemExit('HARD-FAIL: missing SHA256SUMS')
listed=[]
for line_no,line in enumerate(manifest.read_text().splitlines(),1):
 parts=line.split('  ',1)
 if len(parts)!=2 or not re.fullmatch(r'[0-9a-f]{64}',parts[0]):
  raise SystemExit(f'HARD-FAIL: malformed SHA256SUMS line {line_no}')
 name=parts[1].lstrip('*')
 if '/' in name or not name.endswith('.log'):
  raise SystemExit(f'HARD-FAIL: non-log/path entry in SHA256SUMS: {name}')
 listed.append(name)
if len(listed)!=len(set(listed)):
 raise SystemExit('HARD-FAIL: duplicate SHA256SUMS entry')
actual=sorted(p.name for p in CERT.glob('*.log'))
if sorted(listed)!=actual:
 missing=sorted(set(actual)-set(listed)); extra=sorted(set(listed)-set(actual))
 raise SystemExit(f'HARD-FAIL: SHA256SUMS is not complete: missing={missing}, extra={extra}')
print(f'PROOF LOG FAIL-CLOSED SCAN|PASS|logs={len(ESSENTIAL)}|python_receipts={len(PYTHON_RECEIPTS)}|hashed_logs={len(actual)}')
