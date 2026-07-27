# Sweep G: exhaustive test of the k = 3 socles surviving sweeps C + E among
# simple S with |S| < 500000.  Sweep C already covered k = 3 for A5, L2(7),
# A6, L2(8), L2(11); sweep E excludes most of the rest; the survivors are:
#   A7, L2(16), U3(3), M11, A8, L3(4), PSp(4,3), L2(32), PSU(3,5), A9, M22.
# Same method and transitivity justification as sweep F (see
# sweepF_survivors.g); the top image in S_3 must be transitive (C3 or S3).
# Cases ordered by expected cost; the heaviest (L3(4), U3(5)) come last.

Read("/Users/richiesater/dev/math/kourovka-10.34/property.g");

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

RunCase("M11",  MathieuGroup(11),     11, 3);
RunCase("A7",   AlternatingGroup(7),   7, 3);
RunCase("A8",   AlternatingGroup(8),   8, 3);
RunCase("A9",   AlternatingGroup(9),   9, 3);
RunCase("M22",  MathieuGroup(22),     22, 3);
RunCase("U33",  PSU(3,3),             28, 3);
RunCase("Sp43", PSp(4,3),             40, 3);
RunCase("L2_16", PSL(2,16),           17, 3);
RunCase("L2_32", PSL(2,32),           33, 3);
RunCase("L3_4", PSL(3,4),           fail, 3);
RunCase("U35",  PSU(3,5),            126, 3);
Print("SWEEP G DONE.\n");
QUIT;
