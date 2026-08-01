#!/bin/sh
# Overlay exactly the regression-fixed ContainedConjugates implementation.
set -eu
GAP_ROOT=${1:?usage: $0 /path/to/gap-4.16.0}
TARGET="$GAP_ROOT/lib/csetgrp.gi"
COMMIT=b12f8342d641075d58fcbe62cc00dd433d7b8e18
EXPECTED=3e7a00ef8730f6c058213db2f13c076565603ea2467e04aeea756e4afcb76b9f
TMP="$TARGET.fixed.$$"
curl -LfsS "https://raw.githubusercontent.com/gap-system/gap/$COMMIT/lib/csetgrp.gi" -o "$TMP"
if command -v shasum >/dev/null 2>&1; then ACTUAL=$(shasum -a 256 "$TMP" | awk '{print $1}'); else ACTUAL=$(sha256sum "$TMP" | awk '{print $1}'); fi
[ "$ACTUAL" = "$EXPECTED" ] || { echo "HARD-FAIL: fix hash mismatch: $ACTUAL" >&2; rm -f "$TMP"; exit 1; }
[ -f "$TARGET" ] || { echo "HARD-FAIL: target missing: $TARGET" >&2; rm -f "$TMP"; exit 1; }
cp "$TARGET" "$TARGET.v4.16.0"
mv "$TMP" "$TARGET"
echo "ContainedConjugates fixed source installed: $EXPECTED"
