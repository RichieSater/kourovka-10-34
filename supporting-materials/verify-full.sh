#!/bin/sh
# Full GAP reproduction of every committed certificate. EXPENSIVE: the
# exhaustive consistency sweeps take hours to days. Requires GAP 4.16.0
# with the standard package distribution (ctbllib, AtlasRep, perfect
# groups data). Regenerated logs are written next to the committed ones
# with a .regen suffix so they can be diffed against the originals.
# Run from the supporting-materials/ directory:  sh verify-full.sh
set -e
cd "$(dirname "$0")/computations/gap"

GAP="gap -q -b -o 8g -T"

# Order: cheap certificate sweeps first, exhaustive consistency runs last.
SWEEPS="
sanity
sweepJ_divisibility sweepJ2_tail sweepJ4_patch
sweepK_novelty sweepK2_saturation sweepK4_L52
sweepM_sporadic
sweepL_psl2_arith sweepL2_an_arith
sweepJ5_smallAn
sweepJ3_bigrange sweepJ6_L52_M23 sweepK3_bigsurvivors
sweepA_smallgroups sweepB_perfect sweepB2_perfect sweepC_socle
sweepF_survivors sweepG_k3 sweepI_k4 sweepD_almostsimple
"

for s in $SWEEPS; do
  echo "== running $s.g =="
  $GAP "$s.g" > "../certificates/$s.log.regen"
  echo "   wrote ../certificates/$s.log.regen"
done

echo "Full sweep complete. Diff each *.log.regen against the committed log."
