# Sweep E2: extension of sweep E (arithmetic exclusion via Aut-stable maximal
# class pairs) to all non-abelian simple S with 500000 <= |S| < 5000000 and
# k = 2..6.  Criterion (see sweepE_exclusion.g): socle S^k is excluded if
# there are distinct Aut-stable maximal classes [U], [V] with
#     (|U| |V|)^k * |Out(S)|^k * k!  <  |S|^k .
# We also re-run k = 4..6 on the |S| < 500000 range for completeness.

StableMaximalClassSizes := function(S)
  local A, gens, mx, stable, U, ok, a, V;
  A := AutomorphismGroup(S);
  gens := GeneratorsOfGroup(A);
  mx := MaximalSubgroupClassReps(S);
  stable := [];
  for U in mx do
    ok := true;
    for a in gens do
      V := Image(a, U);
      if not IsConjugate(S, V, U) then ok := false; break; fi;
    od;
    if ok then Add(stable, Size(U)); fi;
  od;
  return rec(all := List(mx, Size), stable := stable,
             out := Size(A)/Size(S));
end;

ExcludeSocle := function(name, S, ks)
  local r, o, k, tmax, good, i, j, best;
  r := StableMaximalClassSizes(S);
  o := r.out;
  Print(name, ": |S| = ", Size(S), ", |Out| = ", o,
        ", maximal class sizes = ", r.all,
        ", Aut-stable = ", r.stable, "\n");
  for k in ks do
    tmax := o^k * Factorial(k);
    good := false; best := fail;
    for i in [1..Length(r.stable)] do
      for j in [i+1..Length(r.stable)] do
        if (r.stable[i]*r.stable[j])^k * tmax < Size(S)^k then
          good := true; best := [r.stable[i], r.stable[j]];
        fi;
      od;
    od;
    if good then
      Print("    k=", k, ": EXCLUDED via stable pair ", best, "\n");
    else
      Print("    k=", k, ": not excluded by this criterion\n");
    fi;
  od;
end;

# k = 4..6 for the old range, k = 2..6 for the new range
it := SimpleGroupsIterator(60, 5000000);
for S0 in it do
  res := CALL_WITH_CATCH(function()
    local S, nm, ks;
    nm := StructureDescription(S0);
    if IsPermGroup(S0) then S := S0;
    else S := Image(IsomorphismPermGroup(S0)); fi;
    S := Image(SmallerDegreePermutationRepresentation(S));
    if Size(S) < 500000 then ks := [4,5,6]; else ks := [2,3,4,5,6]; fi;
    ExcludeSocle(nm, S, ks);
    return true;
  end, []);
  if res[1] <> true then
    Print("ERROR on a simple group of order ", Size(S0), " -- skipped\n");
  fi;
od;
Print("SWEEP E2 DONE.\n");
QUIT;
