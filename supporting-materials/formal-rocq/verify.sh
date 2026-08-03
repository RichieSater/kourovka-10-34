#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
EXPECTED_ROCQ="9.2"
EXPECTED_MAXIMAL_SHA="70bcd07cc9e1826525def1c65fdaab2236094dd9de82d2fad5f2bbc3e00f5ffe"

fail() {
  printf 'ROCQ CHARSIMPLE|FAIL|%s\n' "$*" >&2
  exit 1
}

command -v coqc >/dev/null 2>&1 || fail "coqc not found"
command -v rocq >/dev/null 2>&1 || fail "rocq launcher not found"

set -- $(coqc --print-version)
[ "${1:-}" = "$EXPECTED_ROCQ" ] ||
  fail "expected Rocq $EXPECTED_ROCQ, got ${1:-unknown}"

# Homebrew's rocq-elpi bottle keeps its findlib universe under libexec.  This
# branch is inert in opam/container environments whose OCAMLFIND_CONF is
# already correct.
if [ -z "${OCAMLFIND_CONF:-}" ] &&
   [ -f /opt/homebrew/opt/rocq-elpi/libexec/lib/findlib.conf ]; then
  export OCAMLFIND_CONF=/opt/homebrew/opt/rocq-elpi/libexec/lib/findlib.conf
fi

COQLIB=$(coqc -where)
MAXIMAL="$COQLIB/user-contrib/mathcomp/solvable/maximal.v"
[ -f "$MAXIMAL" ] || fail "MathComp solvable/maximal.v not found"

if command -v sha256sum >/dev/null 2>&1; then
  ACTUAL_SHA=$(sha256sum "$MAXIMAL" | awk '{print $1}')
else
  ACTUAL_SHA=$(shasum -a 256 "$MAXIMAL" | awk '{print $1}')
fi
[ "$ACTUAL_SHA" = "$EXPECTED_MAXIMAL_SHA" ] ||
  fail "MathComp maximal.v hash mismatch: $ACTUAL_SHA"

SOURCE_PINS="
boot/bigop.v:ace2aaa4cef9ba0e32872740017511ad4458232111c6c1388a3946c39ffcb3d4
boot/finset.v:d99ac8546ab87ab71d612c001cff1d4ba208f055f8f3798ee8221822e676d453
finite_group/automorphism.v:08a55384548dedb9bf73029e69dd11914d1f453a01bfdaa40f33c3419a100d2b
finite_group/gproduct.v:28f399eca0cd4877219a53531a9a7e5566d2d1b8789c00628abc602b05563c0a
finite_group/morphism.v:41f31d99d6b07f4dcafcdb528cd369fc71f6aed1c5273546e8b6145263517d63
solvable/maximal.v:70bcd07cc9e1826525def1c65fdaab2236094dd9de82d2fad5f2bbc3e00f5ffe
"
for pin in $SOURCE_PINS; do
  rel=${pin%%:*}
  expected=${pin#*:}
  path="$COQLIB/user-contrib/mathcomp/$rel"
  [ -f "$path" ] || fail "MathComp source missing: $rel"
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$path" | awk '{print $1}')
  else
    actual=$(shasum -a 256 "$path" | awk '{print $1}')
  fi
  [ "$actual" = "$expected" ] ||
    fail "MathComp source hash mismatch for $rel: $actual"
done

python3 - "$ROOT" <<'PY' || exit 1
import json, re, sys
from pathlib import Path
root = Path(sys.argv[1])
cov = json.loads((root / 'FORMAL-COVERAGE.json').read_text())
tool = json.loads((root / 'TOOLCHAIN.json').read_text())
if set(tool) != {
    'schema_version','proof_assistant','rocq_version','mathcomp_version',
    'mathcomp_release_tag','mathcomp_release_commit',
    'mathcomp_maximal_v_sha256','mathcomp_source_sha256',
    'local_reference_environment',
    'trusted_boundary','closed_scope',
}:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|toolchain schema drift')
if (tool['schema_version'] != 1 or tool['proof_assistant'] != 'The Rocq Prover'
        or tool['rocq_version'] != '9.2' or tool['mathcomp_version'] != '2.6.0'
        or tool['mathcomp_release_tag'] != 'mathcomp-2.6.0'
        or tool['mathcomp_release_commit'] != '7cde45afa55ead3410e17081d9ab4bdd53def3e7'
        or tool['mathcomp_maximal_v_sha256'] !=
            '70bcd07cc9e1826525def1c65fdaab2236094dd9de82d2fad5f2bbc3e00f5ffe'):
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|toolchain/source pin drift')
expected_sources = {
    'boot/bigop.v': 'ace2aaa4cef9ba0e32872740017511ad4458232111c6c1388a3946c39ffcb3d4',
    'boot/finset.v': 'd99ac8546ab87ab71d612c001cff1d4ba208f055f8f3798ee8221822e676d453',
    'finite_group/automorphism.v': '08a55384548dedb9bf73029e69dd11914d1f453a01bfdaa40f33c3419a100d2b',
    'finite_group/gproduct.v': '28f399eca0cd4877219a53531a9a7e5566d2d1b8789c00628abc602b05563c0a',
    'finite_group/morphism.v': '41f31d99d6b07f4dcafcdb528cd369fc71f6aed1c5273546e8b6145263517d63',
    'solvable/maximal.v': '70bcd07cc9e1826525def1c65fdaab2236094dd9de82d2fad5f2bbc3e00f5ffe',
}
if tool['mathcomp_source_sha256'] != expected_sources:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|MathComp source-pin inventory drift')
if set(cov) != {
    'schema_version','toolchain_manifest','closed_manuscript_claims',
    'explicitly_not_closed','forbidden_constructs',
}:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|coverage schema drift')
if cov['schema_version'] != 1 or cov['toolchain_manifest'] != 'TOOLCHAIN.json':
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|coverage version/toolchain drift')
items = cov['closed_manuscript_claims']
if len(items) != 2 or any(set(item) != {'claim_id','theorem','file','scope'} for item in items):
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|closed-claim inventory drift')
expected_claims = {
    'RED-DIRECT-POWER': 'nonsolvable_charsimple_dprod',
    'RED-COORD': 'nonsolvable_charsimple_explicit_power',
}
if {item['claim_id']: item['theorem'] for item in items} != expected_claims:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|claim/theorem drift')
for item in items:
    source = (root / item['file']).read_text()
    if not re.search(r'\bLemma\s+' + re.escape(item['theorem']) + r'\b', source):
        raise SystemExit('ROCQ CHARSIMPLE|FAIL|declared theorem missing')
    if item['claim_id'] in {'RED-DIRECT-POWER', 'RED-COORD'} and not re.search(
            r'~~\s*abelian\s+H', source):
        raise SystemExit('ROCQ CHARSIMPLE|FAIL|explicit nonabelian factor missing')
if cov['explicitly_not_closed'] != []:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|explicit-open inventory drift')
if set(cov['forbidden_constructs']) != {'Admitted','admit','Axiom'}:
    raise SystemExit('ROCQ CHARSIMPLE|FAIL|forbidden-construct policy drift')
PY

TMP=${TMPDIR:-/tmp}/kourovka-rocq.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
cp "$ROOT/CharacteristicallySimple.v" "$TMP/CharacteristicallySimple.v"

(
  cd "$TMP"
  coqc -q CharacteristicallySimple.v >compile.log 2>&1
)

closed_count=$(grep -Fc 'Closed under the global context' "$TMP/compile.log" || true)
[ "$closed_count" -eq 4 ] ||
  fail "Rocq assumption audit expected 4 closed declarations, got $closed_count"

if grep -Eiq '(^|[^[:alpha:]])(admit|admitted|axiom)([^[:alpha:]]|$)' \
    "$ROOT/CharacteristicallySimple.v"; then
  fail "forbidden proof escape found in Rocq source"
fi

printf 'ROCQ TOOLCHAIN|PASS|rocq=%s|mathcomp-maximal-sha256=%s\n' \
  "$EXPECTED_ROCQ" "$ACTUAL_SHA"
printf 'ROCQ CHARSIMPLE|PASS|theorem=nonsolvable_charsimple_dprod|assumptions=none\n'
printf 'ROCQ EXPLICIT POWER|PASS|theorem=nonsolvable_charsimple_explicit_power|assumptions=none|source-pins=6\n'
