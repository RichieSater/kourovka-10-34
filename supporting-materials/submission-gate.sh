#!/bin/sh
# Binary release gate.  No weighted score and no success-by-omission.
# The expensive GAP enumerations are frozen receipts checked by verify-quick.sh;
# run verify-full.sh first when producing a new release candidate.
set -u
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
PROFILE=${1:-}
case "$PROFILE" in
  submission|confidence99) ;;
  *) echo "usage: $0 submission|confidence99" >&2; exit 2 ;;
esac

fail=0
run() {
  label=$1; shift
  echo "== $label =="
  if "$@"; then
    echo "$label|PASS"
  else
    rc=$?
    echo "$label|FAIL|exit=$rc" >&2
    fail=1
  fi
}

run "committed receipt suite" sh "$ROOT/verify-quick.sh"

GAP_BIN=${GAP_BIN:-"$HOME/gap-4.16.0/gap"}
if [ -x "$GAP_BIN" ]; then
  run "pinned GAP/package environment and regressions" \
    env GAP_BIN="$GAP_BIN" sh "$ROOT/computations/environment/check-environment.sh"
else
  echo "pinned GAP/package environment and regressions|FAIL|missing $GAP_BIN" >&2
  fail=1
fi

if command -v lake >/dev/null 2>&1; then
  run "Lean kernel build and formal coverage" python3 "$ROOT/formal/check_formal.py"
else
  echo "Lean kernel build and formal coverage|FAIL|lake missing" >&2
  fail=1
fi

run "mutation suite" python3 "$ROOT/computations/mutation-tests/run_mutation_tests.py"

# The ledger is authoritative.  It intentionally fails while even one required
# mathematical, source, literature, or reproduction obligation remains open.
if python3 "$ROOT/audit/check_audit.py" --profile "$PROFILE"; then
  ledger=0
else
  ledger=$?
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "${PROFILE} GATE|FAIL"
  exit 1
fi
if [ "$ledger" -ne 0 ]; then
  echo "${PROFILE} GATE|FAIL"
  exit 1
fi
echo "${PROFILE} GATE|PASS"
