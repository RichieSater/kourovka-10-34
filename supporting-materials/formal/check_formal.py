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

# The Comparator challenge deliberately contains one placeholder and is not a
# closed formal claim.  Its solution must use the project theorem and must
# contain the elaboration-level equality check described in its README.
challenge=ROOT/'Comparator/Challenge.lean'
solution=ROOT/'Comparator/Solution.lean'
comparator_readme=ROOT/'Comparator/README.md'
for f in [challenge,solution,comparator_readme]:
 if not f.is_file(): die('Comparator package file missing: '+str(f.relative_to(ROOT)))
challenge_code=code_only(challenge.read_text())
solution_code=code_only(solution.read_text())
challenge_imports=re.findall(r'^\s*import\s+([^\s]+)',challenge.read_text(),re.M)
if challenge_imports != [
 'Mathlib.Algebra.Group.Subgroup.Order',
 'Mathlib.NumberTheory.Padics.PadicVal.Basic',
 'Mathlib.SetTheory.Cardinal.Finite',
]: die('Comparator challenge imports more than the neutral mathlib surface')
if len(re.findall(r'\bsorry\b',challenge_code)) != 1:
 die('Comparator challenge must contain exactly one intentional placeholder')
if re.search(r'\b(admit|axiom|constant)\b',challenge_code):
 die('Comparator challenge contains a non-challenge placeholder/custom axiom')
if re.search(r'\b(sorry|admit|axiom|constant)\b',solution_code):
 die('Comparator solution contains a placeholder/custom axiom')
for token in [
 'import Comparator.Challenge',
 'import Kourovka1034.ProductSupplements',
 'no_propertyP_of_product_supplement_data',
 '@Kourovka1034.Comparator.Challenge.conditionalProductSupplementSpine',
 '@Kourovka1034.Comparator.Solution.conditionalProductSupplementSpine',
 'Subsingleton.elim',
]:
 if token not in solution.read_text(): die('Comparator solution/check missing: '+token)
comparator=cov.get('comparator')
if comparator != {
 'challenge': 'Comparator/Challenge.lean',
 'solution': 'Comparator/Solution.lean',
 'theorem': 'conditionalProductSupplementSpine',
 'project_theorem': 'Kourovka1034.no_propertyP_of_product_supplement_data',
 'status': 'exact conditional spine; not an end-to-end main theorem',
}:
 die('Comparator coverage record drift')
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
 r=subprocess.run(
  ['lake','build','+Comparator.Challenge','+Comparator.Solution'],cwd=ROOT,
  text=True,capture_output=True)
 if r.returncode: die('Comparator module build failed:\n'+r.stdout+r.stderr)
 r=subprocess.run(['lake','env','lean','Comparator/Solution.lean'],cwd=ROOT,
                  text=True,capture_output=True)
 if r.returncode: die('Comparator proposition check failed:\n'+r.stdout+r.stderr)
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
 comparator_status='ELABORATED-PASS'
else:
 label='FORMAL SOURCE/COVERAGE'
 comparator_status='SOURCE-CHECK-PASS'
print(
 f"{label}|PASS|closed_claims={len(cov['closed_manuscript_claims'])}|"
 f"declared_outside_lean={len(cov['explicitly_not_closed'])}|comparator={comparator_status}"
)
