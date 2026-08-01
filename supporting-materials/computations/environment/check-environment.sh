#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
GAP_BIN=${GAP_BIN:-"$HOME/gap-4.16.0/gap"}
[ -x "$GAP_BIN" ] || { echo "HARD-FAIL: GAP missing: $GAP_BIN" >&2; exit 1; }
cd "$ROOT/computations/gap"
"$GAP_BIN" -q -b <<'GAPEOF'
Read("proof_common.g");
CheckContainedConjugatesRegression();
Print("ENVIRONMENT CHECK|PASS\n");
QUIT_GAP(0);
GAPEOF
python3 - <<'PY'
import json, pathlib, sys
p=pathlib.Path('../environment/environment.lock.json')
d=json.loads(p.read_text())
if sys.version_info < (3,9): raise SystemExit('HARD-FAIL: Python < 3.9')
if d['gap']['contained_conjugates_fix_commit'] != 'b12f8342d641075d58fcbe62cc00dd433d7b8e18':
    raise SystemExit('HARD-FAIL: lock drift')
docker=pathlib.Path('../environment/Dockerfile').read_text()
common=pathlib.Path('proof_common.g').read_text()
tokens=[
 d['container_base']['oci_index_digest'].split(':',1)[1],
 d['gap']['source_sha256'],d['gap']['patched_lib_csetgrp_gi_sha256'],
 d['gap_packages']['CTblLib']['archive_sha256'],
 d['gap_packages']['AtlasRep']['archive_sha256'],
 d['elan']['linux_amd64_archive_sha256'],d['elan']['linux_arm64_archive_sha256'],
 d['lean']['toolchain'],d['gap_packages']['CTblLib']['version'],
 d['gap_packages']['AtlasRep']['version'],
]
missing=[x for x in tokens if x not in docker]
if missing: raise SystemExit('HARD-FAIL: Docker/lock mismatch: '+repr(missing))
for token in [d['gap']['release'],d['gap_packages']['CTblLib']['version'],
              d['gap_packages']['AtlasRep']['version'],
              d['gap']['patched_lib_csetgrp_gi_sha256'],
              str(d['gap']['proof_rng_seed'])]:
    if token not in common: raise SystemExit('HARD-FAIL: GAP common/lock mismatch: '+token)
print('ENVIRONMENT LOCK PARSE|PASS')
PY
