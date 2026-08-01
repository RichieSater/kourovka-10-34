#!/bin/sh
# Run from a genuinely fresh, clean clone on each independent machine.
# Usage: run-cleanroom.sh /absolute/path/to/receipt.json
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
OUT=${1:?usage: $0 /absolute/path/to/receipt.json}
case "$OUT" in /*) ;; *) echo "HARD-FAIL: receipt path must be absolute" >&2; exit 2;; esac
FULL_LOG_OUT="$OUT.full.log"
command -v docker >/dev/null 2>&1 || { echo "HARD-FAIL: docker missing" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "HARD-FAIL: git missing" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "HARD-FAIL: python3 missing" >&2; exit 1; }

TOP=$(git -C "$ROOT" rev-parse --show-toplevel)
[ "$ROOT" = "$TOP/supporting-materials" ] || {
  echo "HARD-FAIL: supporting-materials is not in the expected clone root" >&2; exit 1;
}
[ -z "$(git -C "$TOP" status --porcelain=v1 --untracked-files=all)" ] || {
  echo "HARD-FAIL: checkout is not clean; clean-room receipt refused" >&2; exit 1;
}
case "$OUT" in "$TOP"/*) echo "HARD-FAIL: write the receipt outside the clean clone" >&2; exit 1;; esac
[ ! -e "$OUT" ] || { echo "HARD-FAIL: receipt already exists: $OUT" >&2; exit 1; }
[ ! -e "$FULL_LOG_OUT" ] || { echo "HARD-FAIL: full log already exists: $FULL_LOG_OUT" >&2; exit 1; }
COMMIT=$(git -C "$TOP" rev-parse HEAD)
TAG="kourovka1034-cleanroom:$COMMIT"
TMPROOT=$(mktemp -d "${TMPDIR:-/tmp}/kourovka-cleanroom.XXXXXX")
LOG="$TMPROOT/full.log"
CLONE="$TMPROOT/repository"
cleanup() {
python3 - "$TMPROOT" <<'PY'
import shutil
from pathlib import Path
import sys
p=Path(sys.argv[1])
if p.exists(): shutil.rmtree(p)
PY
}
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

# Make a real, non-hardlinked clone on the host before constructing the image.
# This turns "fresh clone" from a user assertion into an enforced precondition.
git clone --quiet --no-local "$TOP" "$CLONE"
git -C "$CLONE" checkout --quiet --detach "$COMMIT"
CANDIDATE_ROOT="$CLONE/supporting-materials"
[ -z "$(git -C "$CLONE" status --porcelain=v1 --untracked-files=all)" ] || {
  echo "HARD-FAIL: internally generated clone is not clean" >&2; exit 1;
}

docker build --no-cache -t "$TAG" -f "$CANDIDATE_ROOT/computations/environment/Dockerfile" "$CLONE"
docker run --rm "$TAG" >"$LOG" 2>&1
grep -F 'FULL PROOF CERTIFICATE REPRODUCTION: PASS' "$LOG" >/dev/null || {
  cat "$LOG" >&2; echo "HARD-FAIL: full suite did not pass" >&2; exit 1;
}
IMAGE_ID=$(docker image inspect --format '{{.Id}}' "$TAG")
ROOT="$CANDIDATE_ROOT"
export ROOT OUT FULL_LOG_OUT COMMIT LOG IMAGE_ID
python3 - <<'PY'
from pathlib import Path
import datetime,hashlib,json,os,platform,subprocess
root=Path(os.environ['ROOT']); out=Path(os.environ['OUT']); log_out=Path(os.environ['FULL_LOG_OUT'])
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
machine=[]
for p in ['/etc/machine-id','/var/lib/dbus/machine-id']:
 q=Path(p)
 if q.is_file(): machine.append(q.read_text(errors='replace').strip())
if not machine:
 try:
  machine.append(subprocess.check_output(
   ['ioreg','-rd1','-c','IOPlatformExpertDevice'],text=True,stderr=subprocess.DEVNULL))
 except (OSError,subprocess.SubprocessError):
  machine.append(platform.node())
fingerprint=hashlib.sha256(('\0'.join(machine)+'\0'+platform.machine()).encode()).hexdigest()
payload={
 'receipt_id':'',
 'machine_fingerprint_sha256':fingerprint,
 'architecture':platform.machine(),
 'os':platform.platform(),
 'git_commit':os.environ['COMMIT'],
 'container_image_id':os.environ['IMAGE_ID'],
 'evidence_manifest_sha256':sha(root/'audit/EVIDENCE.sha256'),
 'certificate_manifest_sha256':sha(root/'computations/certificates/SHA256SUMS'),
 'full_log_sha256':sha(os.environ['LOG']),
 'fresh_clone':True,
 'full_suite_result':'PASS',
 'generated_utc':datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00','Z'),
}
canonical=json.dumps({k:v for k,v in payload.items() if k!='receipt_id'},sort_keys=True,separators=(',',':')).encode()
payload['receipt_id']=hashlib.sha256(canonical).hexdigest()
out.parent.mkdir(parents=True,exist_ok=True)
log_out.write_bytes(Path(os.environ['LOG']).read_bytes())
out.write_text(json.dumps(payload,indent=2,sort_keys=True)+'\n')
print('CLEANROOM RECEIPT|PASS|path='+str(out)+'|full_log='+str(log_out)+'|receipt_id='+payload['receipt_id'])
PY
