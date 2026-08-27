#!/usr/bin/env python3
"""Static fail-closed checks for nondeterminism, soft failure, and prose drift."""
from __future__ import annotations
import ast,json,os,re,sys
from pathlib import Path
ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[1])).resolve()
REPO=Path(os.environ.get('KOUROVKA_REPO_ROOT',ROOT.parent)).resolve()
GAP=ROOT/'computations/gap'
ESSENTIAL=[
'sweepJ_divisibility.g','sweepJ2_tail.g','sweepJ3_bigrange.g','sweepJ4_patch.g','sweepJ5_smallAn.g','sweepJ6_L52_M23.g',
'sweepK_novelty.g','sweepK2_saturation.g','sweepK3_bigsurvivors.g','sweepK4_L52.g','sweepM_sporadic.g',
'sweepL_psl2_arith.g','sweepL2_an_arith.g']
LIBRARIES=['proof_common.g','sweepJ_lib.g','sweepK_lib.g']
PYTHON_ESSENTIAL=[
'computations/python/sweepN_item5_arith.py','computations/python/verify_coverage.py',
'computations/python/verify_coverage_big.py','computations/independent/family_arithmetic_universal.py',
'computations/independent/family_arithmetic_symbolic.py',
'computations/independent/verify_family_manifest.py','computations/independent/verify_finite_witnesses.py',
'computations/independent/verify_lie_sources.py','computations/independent/verify_maximality_sources.py',
'computations/independent/verify_order_formula_sources.py',
'computations/independent/verify_zsigmondy_sources.py',
'computations/independent/verify_boundary_sources.py',
'computations/independent/verify_logs.py','computations/independent/verify_manuscript.py',
'computations/independent/test_public_corpus_policy.py',
'formal/check_formal_interface.py']

# Proof-facing prose must point to stable manuscript labels, not a printed
# theorem number that silently becomes false after an architecture revision.
FAMILY_LABELS={
    'thm:an','thm:psl2','thm:nograph','thm:twisted2','thm:twisted1','thm:graph',
}
ARTIFACT_LABELS={
    'audit/FAMILY-ARITHMETIC-MANIFEST.json': FAMILY_LABELS,
    'audit/SOURCE-LEDGER.md': FAMILY_LABELS,
    'audit/ORDER-FORMULA-SOURCE-MAP.csv': {'thm:nograph'},
    'formal/FORMAL-COVERAGE.json': {'lem:B'},
    'formal/Kourovka1034/Property.lean': {'lem:quot'},
    'formal/Kourovka1034/Reduction.lean': {'prop:min'},
    'formal/Kourovka1034/CoordinateReduction.lean': {
        'conv:coord','lem:coordinate-normalization',
    },
    'formal/Kourovka1034/ProductSupplements.lean': {
        'lem:A','conv:coord','lem:C','thm:D',
    },
    'formal/Kourovka1034/Maximality.lean': {'lem:B'},
    'formal/Kourovka1034/FamilyArithmetic.lean': FAMILY_LABELS,
    'formal/Kourovka1034/Divisibility.lean': {'thm:D'},
    'computations/independent/family_arithmetic_universal.py': FAMILY_LABELS,
    'computations/independent/family_arithmetic_symbolic.py': FAMILY_LABELS,
    'computations/independent/verify_order_formula_sources.py': FAMILY_LABELS,
    'computations/gap/sweepJ3_bigrange.g': {'thm:psl2'},
}

def die(m): raise SystemExit('HARD-FAIL: '+m)

tex=(ROOT/'paper/kourovka1034.tex').read_text()
manuscript_labels=set(re.findall(r'\\label\{([^}]+)\}',tex))
if not manuscript_labels:
    die('principal manuscript labels could not be parsed')
artifact_ref_count=0
label_pattern=re.compile(
    r'(?<![A-Za-z0-9_-])(?:thm|lem|prop|conv|def|rem|cor|sec|app|tab):[A-Za-z0-9_-]+'
)
for relative,expected in ARTIFACT_LABELS.items():
    path=ROOT/relative
    if not path.is_file(): die(f'missing proof-facing artifact: {relative}')
    text=path.read_text()
    refs=set(label_pattern.findall(text))
    missing=expected-refs
    if missing:
        die(f'{relative}: required manuscript labels missing: {sorted(missing)}')

# Reject unknown label tokens anywhere in the proof-facing source corpus, not
# merely in the files that have mandatory mappings above.
scan_roots=[
    ROOT/'audit', ROOT/'formal', ROOT/'computations/independent',
    ROOT/'computations/python', ROOT/'computations/gap',
    ROOT/'computations/mutation-tests',
]
scan_suffixes={'.csv','.g','.json','.lean','.md','.py','.sh','.toml','.txt','.v'}
# These two documents explicitly quote/map the frozen baseline label set; they
# are archival comparison records rather than references to the current paper.
label_archives={
    ROOT/'audit/REVISION-BASELINE.md',
    ROOT/'audit/CONTENT-PRESERVATION-MAP.md',
}
for base in scan_roots:
    for path in base.rglob('*'):
        if not path.is_file() or path.suffix not in scan_suffixes:
            continue
        if path in label_archives:
            continue
        if any(part in {'.lake','certificates','exploratory','__pycache__'} for part in path.parts):
            continue
        refs=set(label_pattern.findall(path.read_text(errors='replace')))
        unknown=refs-manuscript_labels
        if unknown:
            die(f'{path.relative_to(ROOT)}: unknown manuscript labels: {sorted(unknown)}')
        artifact_ref_count += len(refs)

# Formal comments have no external bibliography role, so printed result
# numbers there are always fragile manuscript references and are forbidden.
numeric_manuscript_ref=re.compile(
    r'(?i)\b(?:theorems?|lemmas?|conventions?|propositions?|corollaries?)\s+'
    r'(?:[1-9][0-9]*|[A-C])\.[0-9]'
)
for path in (ROOT/'formal/Kourovka1034').glob('*.lean'):
    match=numeric_manuscript_ref.search(path.read_text())
    if match:
        die(f'{path.relative_to(ROOT)}: printed manuscript reference remains: {match.group(0)}')
for stale in [
    'Theorems 6.1--6.6','Theorem 6.3','Theorem 6.1 and sweep L',
    'manuscript Lemma 3.2','manuscript Lemma 3.3','manuscript Lemma 3.4',
    'Convention 2.4',
]:
    for relative in ARTIFACT_LABELS:
        if stale in (ROOT/relative).read_text():
            die(f'{relative}: obsolete manuscript numbering remains: {stale}')

# Bind the ordinary coordinate-normalization calculation to the orientation
# used by the Lean model.  In the TeX notation i is the source and j the
# target, so the stabilizing transporter is target^{-1} * g * source.  In the
# Lean proof the local names are reversed (i is the target and j the source),
# and `ti⁻¹ * g * tj` expresses the same order.
normalization_match=re.search(
    r'\\begin\{lemma\}\[Coordinate normalization\].*?\\end\{proof\}',
    tex,re.S,
)
if not normalization_match:
    die('coordinate-normalization proof block missing')
normalization=normalization_match.group(0)
for token in [
    r'$g_j^{-1}\,g\,g_i$',
    r'$a_j^{-1}\circ c\circ a_i$',
    r'$G$ by $\delta^{-1}G\delta$',
]:
    if token not in normalization:
        die('ordinary normalization formula missing: '+token)
for stale in [
    r'$g_i\,g\,g_j^{-1}$',
    r'$a_i\,c\,a_j^{-1}$',
    r'$\delta G\delta^{-1}$',
]:
    if stale in normalization:
        die('reversed ordinary normalization formula returned: '+stale)
coordinate_lean=(ROOT/'formal/Kourovka1034/CoordinateReduction.lean').read_text()
coordinate_lean_flat=re.sub(r'\s+',' ',coordinate_lean)
for token in [
    'normalizedHom rho base htrans g = (delta rho base htrans)⁻¹ * rho g * delta rho base htrans',
    'let h : G := ti⁻¹ * g * tj',
]:
    if token not in coordinate_lean_flat:
        die('Lean normalization orientation drift: '+token)

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
    if any(isinstance(node, ast.Assert) for node in ast.walk(ast.parse(code))):
        die(f'{relative}: assert statement on proof path (disabled by python -O)')
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
for required in [
    ROOT/'formal/Kourovka1034/DirectPower.lean',
    ROOT/'formal/Kourovka1034/AmbientWreath.lean',
    ROOT/'formal/FORMAL-INTERFACE.json',
    ROOT/'formal/check_formal_interface.py',
]:
    if not required.is_file(): die(f'missing formal coordinate source: {required.name}')
ambient=(ROOT/'formal/Kourovka1034/AmbientWreath.lean').read_text()
for token in ['ambientWreathHom_injective','ambientWreath_transitive',
              'ambientWreath_base_iff','ambient_coordinate_realization_and_bound']:
    if token not in ambient: die('formal ambient-wreath interface missing: '+token)
direct=(ROOT/'formal/Kourovka1034/DirectPower.lean').read_text()
for token in ['reindexPower','reindexPowerFin','explicitPowerEquivFin_nonempty',
              'explicitPowerEquivFin_with_base','Finite.equivFin I']:
    if token not in direct: die('formal finite-index reindexing missing: '+token)
rocq_source=(ROOT/'formal-rocq/CharacteristicallySimple.v').read_text()
if re.search(r'(^|[^A-Za-z])(Admitted|admit|Axiom)([^A-Za-z]|$)',rocq_source,re.I):
    die('formal-rocq/CharacteristicallySimple.v: placeholder/custom axiom')
for token in ['internal_bigdprod_isog_power',
              'nonsolvable_charsimple_explicit_power',
              '~~ abelian H',
              'G \\isog setXn (fun _ : {f | f \\in I} => H)']:
    if token not in rocq_source: die('Rocq explicit-power bridge missing: '+token)
rocq_verify=(ROOT/'formal-rocq/verify.sh').read_text()
for token in ['coqc --print-version','maximal.v','Closed under the global context',
              '70bcd07cc9e1826525def1c65fdaab2236094dd9de82d2fad5f2bbc3e00f5ffe',
              '41f31d99d6b07f4dcafcdb528cd369fc71f6aed1c5273546e8b6145263517d63']:
    if token not in rocq_verify: die('Rocq verification pin missing: '+token)
for extra in (ROOT/'computations/certificates').glob('*.regen'):
    die(f'stale regeneration file: {extra.name}')
for extra in (ROOT/'computations/certificates').glob('*.new'):
    die(f'stale incomplete file: {extra.name}')
lock_path=ROOT/'computations/environment/environment.lock.json'
lock=lock_path.read_text()
if 'b12f8342d641075d58fcbe62cc00dd433d7b8e18' not in lock: die('GAP regression fix pin missing')
env=json.loads(lock)
docker=(ROOT/'computations/environment/Dockerfile').read_text()
for token in [
    env['container_base']['oci_index_digest'].split(':',1)[1],
    env['gap']['source_sha256'],env['gap']['patched_lib_csetgrp_gi_sha256'],
    env['gap_packages']['CTblLib']['archive_sha256'],
    env['gap_packages']['AtlasRep']['archive_sha256'],
    env['elan']['linux_amd64_archive_sha256'],env['elan']['linux_arm64_archive_sha256'],
    f"ARG OCAML_VERSION={env['rocq']['ocaml_compiler']}",
    f"ARG ROCQ_VERSION={env['rocq']['version']}.0",
    f"ARG MATHCOMP_VERSION={env['mathcomp']['version']}",
    '"rocq-core.${ROCQ_VERSION}"','"rocq-mathcomp-solvable.${MATHCOMP_VERSION}"',
    'exec rocq compile "$@"',
    'COPY .gitignore .dockerignore /work/',
]:
    if token not in docker: die('container/environment lock mismatch: '+token)
if re.search(r'\b(?:AGENTS|CLAUDE)\.md\b',docker):
    die('container recipe references local agent instructions')
for ignore_file in [REPO/'.gitignore',REPO/'.dockerignore']:
    ignore_text=ignore_file.read_text().splitlines()
    for name in [
        'AGENTS.md','CLAUDE.md','agents.md','claude.md',
        'CODEX-*.md',
    ]:
        if name not in ignore_text:
            die(f'{ignore_file.name} does not exclude local agent file {name}')
full=(ROOT/'verify-full.sh').read_text()
if 'set -eu' not in full or 'cmp -s' not in full or 'exit 1' not in full:
    die('full reproduction lost fail-closed shell/diff behavior')
env_check=(ROOT/'computations/environment/check-environment.sh').read_text()
if 'GAP_FLAGS="-r -q -b -o 8g -T"' not in full:
    die('full reproduction does not suppress user GAP roots')
if '"$GAP_BIN" -r -q -b' not in env_check:
    die('environment gate does not suppress user GAP roots')
for token in [
    'mutation_tests.log.regen',
    'run_mutation_tests.py" >"$mutation_regen"',
    'cmp -s "$CERT_DIR/mutation_tests.log" "$mutation_regen"',
]:
    if token not in full:
        die('mutation receipt is not regenerated and byte-compared: '+token)
print(
    f'STATIC DETERMINISM/SOFT-FAIL CHECK|PASS|gap_drivers={len(ESSENTIAL)}|'
    f'gap_libraries={len(LIBRARIES)}|python_checkers={len(PYTHON_ESSENTIAL)}|'
    f'artifact_label_refs={artifact_ref_count}|normalization_bridge=PASS'
)
