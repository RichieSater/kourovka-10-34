#!/bin/sh
# Fast, fail-closed verification of every committed receipt.  This does not
# replace verify-full.sh: it validates the frozen outputs without rerunning the
# expensive GAP enumerations.
set -eu
cd "$(dirname "$0")"

echo "== 1/13 coverage, |S| < 5e5 =="
python3 computations/python/verify_coverage.py

echo "== 2/13 coverage, 5e5..1.05e7 =="
python3 computations/python/verify_coverage_big.py

echo "== 3/13 concrete family arithmetic receipts =="
python3 computations/python/sweepN_item5_arith.py

echo "== 4/13 independent symbolic family arithmetic =="
python3 computations/independent/family_arithmetic_symbolic.py

echo "== 5/13 independent classification/exception topology =="
python3 computations/independent/verify_family_manifest.py

echo "== 6/13 independent finite-witness recomputation =="
python3 computations/independent/verify_finite_witnesses.py

echo "== 7/13 high-risk Lie sources and 2E6 Levi derivation =="
python3 computations/independent/verify_lie_sources.py

echo "== 8/13 family maximality source topology =="
python3 computations/independent/verify_maximality_sources.py

echo "== 9/13 fail-closed certificate-log scan =="
python3 computations/independent/verify_logs.py

echo "== 10/13 manuscript/manifest consistency =="
python3 computations/independent/verify_manuscript.py

echo "== 11/13 audit schema and explicit formal coverage =="
python3 audit/check_audit.py --profile lint
python3 formal/check_formal.py --no-build

echo "== 12/13 static determinism/soft-failure scan =="
python3 audit/static_check.py

echo "== 13/13 certificate and evidence checksums =="
if command -v shasum >/dev/null 2>&1; then
  (cd computations/certificates && shasum -a 256 -c SHA256SUMS)
else
  (cd computations/certificates && sha256sum -c SHA256SUMS)
fi
python3 audit/evidence_hashes.py --verify

echo "QUICK VERIFICATION SUITE: ALL CHECKS PASSED."
