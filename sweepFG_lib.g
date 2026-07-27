# Shared library for the exhaustive socle sweeps (F, G, I, ...).
# Requires property.g to be read first.  See sweepF_survivors.g for the
# transitivity justification.

AutPerm := function(S, n)
  local P, a;
  a := Size(AutomorphismGroup(S));
  if n <> fail then
    P := Normalizer(SymmetricGroup(n), S);
    if Size(P) = a then return P; fi;
  fi;
  P := Image(IsomorphismPermGroup(AutomorphismGroup(S)));
  P := Image(SmallerDegreePermutationRepresentation(P));
  if Size(P) <> a then Error("AutPerm failed"); fi;
  return P;
end;

TestSocleTransitive := function(name, P, k)
  local socP, W, pr, gens, i, g, N, hom, Q, reps, T, G, mx, n, isSupp,
        ii, jj, A, B, p, ok, failinfo, nsupp, tcount;
  socP := PerfectResiduum(P);
  W := WreathProduct(P, SymmetricGroup(k));
  pr := Projection(W);
  gens := [];
  for i in [1..k] do
    for g in GeneratorsOfGroup(socP) do
      Add(gens, Image(Embedding(W,i), g));
    od;
  od;
  N := Subgroup(W, gens);
  hom := NaturalHomomorphismByNormalSubgroup(W, N);
  Q := Image(hom);
  Print("=== socle ", name, "^", k, ":  |S|^k = ", Size(N),
        ",  |W/N| = ", Size(Q), "\n");
  reps := List(ConjugacyClassesSubgroups(Q), Representative);
  tcount := 0;
  for T in reps do
    G := PreImage(hom, T);
    if not IsTransitive(Image(pr, G), [1..k]) then continue; fi;
    tcount := tcount + 1;
    mx := MaximalSubgroupClassReps(G);
    n := Size(G);
    isSupp := List(mx, M -> not IsSubset(M, N));
    nsupp := Number(isSupp, x -> x);
    ok := true; failinfo := "";
    for ii in [1..Length(mx)] do
      if not ok then break; fi;
      for jj in [ii+1..Length(mx)] do
        A := mx[ii]; B := mx[jj];
        p := Size(A)*Size(B);
        if p mod n <> 0 or p <> n*Size(Intersection(A,B)) then
          ok := false;
          if isSupp[ii] and isSupp[jj] then failinfo := "supp-supp";
          elif not (isSupp[ii] or isSupp[jj]) then failinfo := "top-top";
          else failinfo := "TOP-SUPP(!!)"; fi;
          failinfo := Concatenation(failinfo, " sizes ", String(Size(A)),
                                    ",", String(Size(B)));
          break;
        fi;
      od;
    od;
    Print("    |G| = ", n, "  [G:N] = ", n/Size(N),
          "  maxclasses = ", Length(mx), " (suppl: ", nsupp, ")  ");
    if ok then
      Print("!!! COUNTEREXAMPLE !!!\n");
      Print("!!! generators: ", GeneratorsOfGroup(G), "\n");
    else
      Print("fails: ", failinfo, "\n");
    fi;
  od;
  Print("=== socle ", name, "^", k, " DONE: ", tcount,
        " transitive-top candidates tested\n");
end;

RunCase := function(name, S, n, k)
  local res;
  res := CALL_WITH_CATCH(function()
    TestSocleTransitive(name, AutPerm(S, n), k);
    return true;
  end, []);
  if res[1] <> true then
    Print("=== socle ", name, "^", k, ": ERROR, case skipped\n");
  fi;
end;
