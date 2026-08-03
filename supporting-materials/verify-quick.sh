#!/bin/sh
# Fast, fail-closed verification of every committed receipt.  This does not
# replace verify-full.sh: it validates the frozen outputs without rerunning the
# expensive GAP enumerations.
set -eu
cd "$(dirname "$0")"

echo "== 1/18 coverage, |S| < 5e5 =="
python3 computations/python/verify_coverage.py

echo "== 2/18 coverage, 5e5..1.05e7 =="
python3 computations/python/verify_coverage_big.py

echo "== 3/18 concrete family arithmetic receipts =="
python3 computations/python/sweepN_item5_arith.py

echo "== 4/18 exact universal family-arithmetic manifest =="
python3 computations/independent/family_arithmetic_universal.py

echo "== 5/18 independent symbolic family arithmetic =="
python3 computations/independent/family_arithmetic_symbolic.py

echo "== 6/18 independent classification/exception topology =="
python3 computations/independent/verify_family_manifest.py

echo "== 7/18 independent finite-witness recomputation =="
python3 computations/independent/verify_finite_witnesses.py

echo "== 8/18 high-risk Lie sources and 2E6 Levi derivation =="
python3 computations/independent/verify_lie_sources.py

echo "== 9/18 family maximality source topology =="
python3 computations/independent/verify_maximality_sources.py

echo "== 10/18 exact group/subgroup/Levi order-formula sources =="
python3 computations/independent/verify_order_formula_sources.py

echo "== 11/18 exact Zsigmondy statement and invocation hypotheses =="
python3 computations/independent/verify_zsigmondy_sources.py

echo "== 12/18 classification boundary and exceptional-isomorphism sources =="
python3 computations/independent/verify_boundary_sources.py

echo "== 13/18 Rocq/MathComp characteristically-simple and explicit-power theorems =="
formal-rocq/verify.sh

echo "== 14/18 fail-closed certificate-log scan =="
python3 computations/independent/verify_logs.py

echo "== 15/18 manuscript/manifest consistency =="
python3 computations/independent/verify_manuscript.py

echo "== 16/18 explicit formal coverage and cross-kernel interface =="
python3 formal/check_formal.py --no-build

echo "== 17/18 static determinism/soft-failure scan =="
python3 audit/static_check.py

echo "== 18/18 certificate and evidence checksums =="
if command -v shasum >/dev/null 2>&1; then
  (cd computations/certificates && shasum -a 256 -c SHA256SUMS)
else
  (cd computations/certificates && sha256sum -c SHA256SUMS)
fi
python3 audit/evidence_hashes.py --verify

echo "QUICK VERIFICATION SUITE: ALL CHECKS PASSED."
