#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,re,subprocess,sys
from pathlib import Path
import os
ROOT=Path(os.environ.get('KOUROVKA_FORMAL_ROOT', Path(__file__).resolve().parent)).resolve()
ap=argparse.ArgumentParser()
ap.add_argument('--no-build',action='store_true',help='validate sources/coverage only')
args=ap.parse_args()
cov=json.loads((ROOT/'FORMAL-COVERAGE.json').read_text())

def die(msg): raise SystemExit('HARD-FAIL: '+msg)

interface = subprocess.run(
 ['python3', str(ROOT/'check_formal_interface.py')], cwd=ROOT,
 text=True, capture_output=True,
 env={**os.environ, 'KOUROVKA_FORMAL_ROOT': str(ROOT)},
)
if interface.returncode:
 die('formal prover interface failed:\n'+interface.stdout+interface.stderr)
print(interface.stdout.strip())

def code_only(text: str) -> str:
 """Remove nested Lean comments, line comments, and string contents."""
 out=[]; i=0; depth=0; in_string=False
 while i < len(text):
  if depth:
   if text.startswith('/-',i): depth+=1; i+=2
   elif text.startswith('-/',i): depth-=1; i+=2
   else: i+=1
   continue
  if in_string:
   if text[i]=='\\': i+=2
   elif text[i]=='"': in_string=False; i+=1
   else: i+=1
   continue
  if text.startswith('/-',i): depth=1; i+=2
  elif text.startswith('--',i):
   j=text.find('\n',i)
   i=len(text) if j<0 else j
  elif text[i]=='"': in_string=True; i+=1
  else: out.append(text[i]); i+=1
 if depth or in_string: die('unterminated comment/string in Lean source')
 return ''.join(out)

if set(cov.get('forbidden_constructs',[])) != {'sorry','admit','axiom','constant'}:
 die('formal forbidden-construct policy drift')

toolchain=(ROOT/'lean-toolchain').read_text().strip()
if toolchain != cov['toolchain']:
 die(f"toolchain drift: {toolchain!r} != {cov['toolchain']!r}")
manifest=json.loads((ROOT/'lake-manifest.json').read_text())
mathlib=[p for p in manifest['packages'] if p['name']=='mathlib']
if len(mathlib)!=1 or mathlib[0]['rev'] != cov['mathlib_commit']:
 die('mathlib lock does not match FORMAL-COVERAGE.json')

files=list((ROOT/'Kourovka1034').glob('*.lean'))+[ROOT/'Kourovka1034.lean',ROOT/'AxiomAudit.lean']
for f in files:
 t=code_only(f.read_text())
 if re.search(r'\b(sorry|admit|axiom|constant)\b',t):
  die('placeholder/custom axiom in '+str(f))
for item in cov['closed_manuscript_claims']:
 f=ROOT/item['file']
 theorem=item['theorem'].split('.')[-1]
 if not re.search(r'\btheorem\s+'+re.escape(theorem)+r'\b',code_only(f.read_text())):
  die('declared formal theorem missing: '+theorem)
if set(cov['closed_manuscript_claims'][0].keys()) != {'claim_id','theorem','file','scope'}:
 die('formal coverage schema drift')
closed_ids=[item['claim_id'] for item in cov['closed_manuscript_claims']]
open_ids=cov['explicitly_not_closed']
if len(closed_ids)!=len(set(closed_ids)) or len(open_ids)!=len(set(open_ids)):
 die('duplicate formal coverage claim ID')
if set(closed_ids) & set(open_ids): die('formal claim is both closed and open')
audit_source=code_only((ROOT/'AxiomAudit.lean').read_text())
for item in cov['closed_manuscript_claims']:
 if f"#print axioms {item['theorem']}" not in audit_source:
  die('closed theorem omitted from AxiomAudit.lean: '+item['theorem'])
if audit_source.count('#print axioms') != len(closed_ids):
 die('AxiomAudit.lean contains an extra or duplicate theorem')
if not args.no_build:
 r=subprocess.run(['lake','build'],cwd=ROOT)
 if r.returncode: raise SystemExit(r.returncode)
 r=subprocess.run(['lake','env','lean','AxiomAudit.lean'],cwd=ROOT,
                  text=True,capture_output=True)
 if r.returncode: die('axiom audit failed:\n'+r.stdout+r.stderr)
 reports=re.findall(r"depends on axioms: \[([^]]*)\]",r.stdout+r.stderr)
 no_axioms=(r.stdout+r.stderr).count('does not depend on any axioms')
 if len(reports)+no_axioms != len(closed_ids):
  die('axiom-audit report count does not match closed theorem count')
 allowed={'propext','Classical.choice','Quot.sound'}
 for report in reports:
  used={x.strip() for x in report.split(',') if x.strip()}
  if not used <= allowed: die('nonstandard axiom dependency: '+', '.join(sorted(used-allowed)))
 label='FORMAL BUILD/COVERAGE'
else:
 label='FORMAL SOURCE/COVERAGE'
print(
 f"{label}|PASS|closed_claims={len(cov['closed_manuscript_claims'])}|"
 f"declared_outside_lean={len(cov['explicitly_not_closed'])}"
)
