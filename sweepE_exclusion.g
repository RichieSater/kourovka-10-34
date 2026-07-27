# Sweep E: exclusion certificates for socle S^k, k = 2, 3, over a large list
# of simple groups S.
#
# Basis: in any candidate counterexample G with socle N = S^k (k>=2, C_G(N)=1,
# G/N soluble), every Aut(S)-stable conjugacy class [U] of maximal subgroups
# of S yields a product-type maximal supplement B_U = N_G(U_1 x ... x U_k),
# and distinct stable classes give non-conjugate maximals.  If G had the
# Kourovka property then G = B_U B_V, which forces
#     prod_i |U_i V_i|  >=  |S|^k / t,   t = |G/N| <= |Out(S)|^k * k!.
# Since |U_i V_i| <= |U||V|, the inequality
#     |U| * |V|  <  |S| / (|Out(S)|^k * k!)^(1/k)
# for some pair of distinct Aut-stable maximal classes [U],[V] excludes the
# socle S^k completely.  (No intersection computations needed.)

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

ExcludeSocle := function(name, S)
  local r, o, k, tmax, bound, good, i, j, best;
  r := StableMaximalClassSizes(S);
  o := r.out;
  Print(name, ": |S| = ", Size(S), ", |Out| = ", o,
        ", maximal class sizes = ", r.all,
        ", Aut-stable = ", r.stable, "\n");
  for k in [2,3] do
    tmax := o^k * Factorial(k);
    # need |U|*|V| < |S| / tmax^(1/k);  use rational arithmetic:
    # condition (|U||V|)^k * tmax < |S|^k
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

# All non-abelian simple groups of order < 500000
it := SimpleGroupsIterator(60, 500000);
for S0 in it do
  res := CALL_WITH_CATCH(function()
    local S, nm;
    nm := StructureDescription(S0);
    if IsPermGroup(S0) then S := S0;
    else S := Image(IsomorphismPermGroup(S0)); fi;
    S := Image(SmallerDegreePermutationRepresentation(S));
    ExcludeSocle(nm, S);
    return true;
  end, []);
  if res[1] <> true then
    Print("ERROR on a simple group of order ", Size(S0), " -- skipped\n");
  fi;
od;
Print("SWEEP E DONE.\n");
QUIT;
