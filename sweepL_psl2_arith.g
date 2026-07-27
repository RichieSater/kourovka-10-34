# Sweep L: arithmetic receipts for the PSL(2,q) case of the THEOREM.md
# section-5 program, for all prime powers 13 <= q <= 10000.  No group
# construction: just the valuation arithmetic of the claimed exclusion
# pairs.  (Group-theoretic inputs — maximality and Aut-stability of the
# dihedral/Borel classes, Dickson — are classical for q >= 13 and
# machine-certified for q <= 97 by sweeps J/J4.)
#
#   q odd:  pair (D_{q-1}, D_{q+1}), sizes q-1, q+1;
#           |S| = q(q^2-1)/2, x | 2f;  claim: d = f > v_p(2f).
#   q even: pair (Borel q(q-1), D_{2(q-1)}), sizes q(q-1), 2(q-1);
#           |S| = q(q^2-1), x | f;  claim: some odd prime r | q+1 with
#           v_r(q+1) > v_r(f).
# Report any q where the claimed obstruction fails to hold.

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

bad := [];
checked := 0;
for q in [13..10000] do
  if IsPrimePowerInt(q) then
    p := SmallestRootInt(q); f := LogInt(q, p);
    checked := checked + 1;
    if p > 2 then
      # d at the defining prime for the dihedral pair
      d := Vp(q*(q^2-1)/2, p) - Vp(q-1, p) - Vp(q+1, p);
      if not d > Vp(2*f, p) then Add(bad, q); fi;
    else
      ok := false;
      for r in PrimeDivisors(q+1) do
        d := Vp(q*(q^2-1), r) - Vp(q*(q-1), r) - Vp(2*(q-1), r);
        if d > Vp(f, r) then ok := true; fi;
      od;
      if not ok then Add(bad, q); fi;
    fi;
  fi;
od;
Print("checked ", checked, " prime powers 13 <= q <= 10000\n");
Print("failures of the claimed obstruction: ", bad, "\n");
if bad = [] then
  Print("PSL(2,q) ARITHMETIC RECEIPTS OK for all 13 <= q <= 10000.\n");
fi;
Print("SWEEP L DONE.\n");
QUIT;
