#!/bin/sh
# Fail-closed reproduction of every proof-essential computed certificate.
# Each regenerated output is scanned, byte-compared with its committed log,
# and rejected on any missing/ambiguous/soft-failure marker.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
GAP_BIN=${GAP_BIN:-"$HOME/gap-4.16.0/gap"}
# -r suppresses user GAP roots, preventing duplicate or shadowing package
# metadata from contaminating the pinned CTblLib/AtlasRep environment.
GAP_FLAGS="-r -q -b -o 8g -T"
GAP_DIR="$ROOT/computations/gap"
CERT_DIR="$ROOT/computations/certificates"

[ -x "$GAP_BIN" ] || { echo "HARD-FAIL: GAP binary missing: $GAP_BIN" >&2; exit 1; }

echo "== versioned proof tools, pinned artifacts, and upstream regressions =="
GAP_BIN="$GAP_BIN" sh "$ROOT/computations/environment/check-environment.sh"

SWEEPS="
sweepJ_divisibility sweepJ2_tail sweepJ4_patch
sweepK_novelty sweepK2_saturation
sweepM_sporadic
sweepL_psl2_arith sweepL2_an_arith
sweepJ5_smallAn
sweepJ3_bigrange sweepJ6_L52_M23 sweepK3_bigsurvivors sweepK4_L52
"

check_log() {
  f=$1
  if grep -E 'HARD-FAIL|ERROR|skipped|MANUAL|needs attention|INCOMPLETE|HAS PROBLEMS|Traceback' "$f" >/dev/null; then
    echo "HARD-FAIL: soft-failure marker in $f" >&2
    grep -nE 'HARD-FAIL|ERROR|skipped|MANUAL|needs attention|INCOMPLETE|HAS PROBLEMS|Traceback' "$f" >&2 || true
    exit 1
  fi
  grep -F '|PASS' "$f" >/dev/null || {
    echo "HARD-FAIL: no terminal PASS marker in $f" >&2; exit 1;
  }
}

cd "$GAP_DIR"
for s in $SWEEPS; do
  committed="$CERT_DIR/$s.log"
  regen="$CERT_DIR/$s.log.regen"
  [ -f "$committed" ] || { echo "HARD-FAIL: missing committed log $committed" >&2; exit 1; }
  echo "== running $s.g =="
  "$GAP_BIN" $GAP_FLAGS "$s.g" >"$regen" 2>&1
  check_log "$regen"
  if ! cmp -s "$committed" "$regen"; then
    echo "HARD-FAIL: certificate drift for $s" >&2
    diff -u "$committed" "$regen" >&2 || true
    exit 1
  fi
  rm -f "$regen"
  echo "   byte-identical: PASS"
done

cd "$ROOT"
for item in \
  "computations/python/sweepN_item5_arith.py:computations/certificates/sweepN_item5_arith.log" \
  "computations/python/verify_coverage.py:computations/certificates/verify_coverage.log" \
  "computations/python/verify_coverage_big.py:computations/certificates/verify_coverage_big.log" \
  "computations/independent/verify_finite_witnesses.py:computations/certificates/verify_finite_witnesses.log" \
  "computations/independent/verify_family_manifest.py:computations/certificates/verify_family_manifest.log" \
  "computations/independent/family_arithmetic_universal.py:computations/certificates/family_arithmetic_universal.log" \
  "computations/independent/family_arithmetic_symbolic.py:computations/certificates/family_arithmetic_symbolic.log" \
  "computations/independent/verify_lie_sources.py:computations/certificates/verify_lie_sources.log" \
  "computations/independent/verify_maximality_sources.py:computations/certificates/verify_maximality_sources.log" \
  "computations/independent/verify_order_formula_sources.py:computations/certificates/verify_order_formula_sources.log" \
  "computations/independent/verify_zsigmondy_sources.py:computations/certificates/verify_zsigmondy_sources.log" \
  "computations/independent/verify_boundary_sources.py:computations/certificates/verify_boundary_sources.log" \
  "computations/independent/verify_logs.py:computations/certificates/verify_logs.log" \
  "computations/independent/verify_manuscript.py:computations/certificates/verify_manuscript.log"
do
  script=${item%%:*}; committed=${item#*:}; regen="$committed.regen"
  [ -f "$script" ] || { echo "HARD-FAIL: missing checker $script" >&2; exit 1; }
  [ -f "$committed" ] || { echo "HARD-FAIL: missing committed log $committed" >&2; exit 1; }
  echo "== running $script =="
  python3 "$script" >"$regen" 2>&1
  check_log "$regen"
  if ! cmp -s "$committed" "$regen"; then
    echo "HARD-FAIL: certificate drift for $script" >&2
    diff -u "$committed" "$regen" >&2 || true
    exit 1
  fi
  rm -f "$regen"
  echo "   byte-identical: PASS"
done

echo "== formal arithmetic build (no placeholders/custom axioms) =="
(cd "$ROOT/formal" && lake exe cache get)
python3 "$ROOT/formal/check_formal.py"
echo "== Rocq/MathComp characteristically-simple and explicit-power build =="
rocq_regen="$CERT_DIR/formal_rocq_charsimple.log.regen"
sh "$ROOT/formal-rocq/verify.sh" >"$rocq_regen" 2>&1
check_log "$rocq_regen"
if ! cmp -s "$CERT_DIR/formal_rocq_charsimple.log" "$rocq_regen"; then
  echo "HARD-FAIL: Rocq characteristically-simple certificate drift" >&2
  diff -u "$CERT_DIR/formal_rocq_charsimple.log" "$rocq_regen" >&2 || true
  exit 1
fi
rm -f "$rocq_regen"
echo "   byte-identical: PASS"
python3 "$ROOT/audit/static_check.py"
echo "== mutation suite =="
mutation_regen="$CERT_DIR/mutation_tests.log.regen"
python3 "$ROOT/computations/mutation-tests/run_mutation_tests.py" >"$mutation_regen" 2>&1
check_log "$mutation_regen"
if ! cmp -s "$CERT_DIR/mutation_tests.log" "$mutation_regen"; then
  echo "HARD-FAIL: mutation-test receipt drift" >&2
  diff -u "$CERT_DIR/mutation_tests.log" "$mutation_regen" >&2 || true
  exit 1
fi
rm -f "$mutation_regen"
echo "   byte-identical: PASS"
python3 "$ROOT/audit/evidence_hashes.py" --verify

echo "FULL PROOF CERTIFICATE REPRODUCTION: PASS"
