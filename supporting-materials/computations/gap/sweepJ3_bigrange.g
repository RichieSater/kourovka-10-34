# Sweep J3: divisibility criterion (sweep J) over all non-abelian simple
# groups with 500000 <= |S| <= 10500000 (and, redundantly, re-verification is
# harmless if any smaller group appears).  Reports, for each S and each
# Inn <= X <= Aut(S):  all-k exclusion witness, or survivor status.
# Survivors get the sweep-K novelty treatment in a later pass.

Read("sweepJ_lib.g");

it := SimpleGroupsIterator(500000, 10500000);
for S0 in it do
  res := CALL_WITH_CATCH(function()
    local S, nm;
    nm := StructureDescription(S0);
    if IsPermGroup(S0) then S := S0;
    else S := Image(IsomorphismPermGroup(S0)); fi;
    S := Image(SmallerDegreePermutationRepresentation(S));
    DivCriterion(nm, AutPerm(S, NrMovedPoints(S)));
    return true;
  end, []);
  if res[1] <> true then
    Print("ERROR on simple group of order ", Size(S0), " -- skipped\n");
  fi;
od;
Print("SWEEP J3 DONE.\n");
QUIT;
