# Sweep J3: divisibility criterion (sweep J) over all non-abelian simple
# groups with 500000 <= |S| <= 10500000 other than PSL(2,q).  The 38
# PSL(2,q) entries in the independent 51-group inventory are routed to the
# uniform Dickson/valuation proof (Theorem 6.1 and sweep L), not re-enumerated
# here; this avoids making a redundant, expensive GAP maximal-subgroup sweep
# part of the logical certificate.  M23 and PSL(5,2) are likewise delegated
# to sweep J6's direct automorphism constructions.  For each remaining S and every
# Inn <= X <= Aut(S), report an all-k witness or survivor status.  Survivors
# get the sweep-K novelty treatment in a later pass.

Read("sweepJ_lib.g");

it := SimpleGroupsIterator(500000, 10500000);
for S0 in it do
  nm := StructureDescription(S0);
  if PositionSublist(nm,"PSL(2,") <> 1
     and Size(S0)<>9999360 and Size(S0)<>10200960 then
    if IsPermGroup(S0) then S := S0;
    else S := Image(IsomorphismPermGroup(S0)); fi;
    S := Image(SmallerDegreePermutationRepresentation(S));
    DivCriterion(nm, AutPerm(S, NrMovedPoints(S)));
  fi;
od;
Print("SWEEP J3 DONE.|PASS\n");
QUIT_GAP(0);
