#!/bin/sh
# Quick verification suite for the Kourovka 10.34 supporting materials.
# Runs in seconds, requires only Python 3.9+ (standard library). Verifies:
#   1. coverage of all 47 non-abelian simple groups with |S| < 5e5;
#   2. coverage of all 51 simple groups with 5e5 <= |S| <= 1.05e7;
#   3. the 7,892 family-proof arithmetic receipts (incl. Zsigmondy exceptions);
#   4. SHA-256 integrity of every committed certificate log.
# Run from the supporting-materials/ directory:  sh verify-quick.sh
set -e
cd "$(dirname "$0")"

echo "== 1/4 coverage, |S| < 5e5 =="
python3 computations/python/verify_coverage.py

echo "== 2/4 coverage, 5e5..1.05e7 =="
python3 computations/python/verify_coverage_big.py

echo "== 3/4 family-proof arithmetic receipts =="
python3 computations/python/sweepN_item5_arith.py

echo "== 4/4 certificate checksums =="
if command -v shasum >/dev/null 2>&1; then
  (cd computations/certificates && shasum -a 256 -c SHA256SUMS)
else
  (cd computations/certificates && sha256sum -c SHA256SUMS)
fi

echo "QUICK VERIFICATION SUITE: ALL CHECKS PASSED."
