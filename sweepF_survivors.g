# Sweep F: exhaustive test of the k = 2 socles surviving sweeps C + E among
# simple S with |S| < 500000:  PSp(4,3), PSU(3,5), A9, M22.
#
# For each socle S^2 we test every group N <= G <= W = Aut(S) wr S_2 (up to
# conjugacy) whose image in the top S_2 is transitive.  Justification for the
# transitivity restriction: a counterexample arising in the minimal-
# counterexample reduction has N = S^k as its UNIQUE minimal normal subgroup,
# which forces G to permute the k copies of S transitively (an orbit of
# copies generates a proper G-normal subgroup of N otherwise).  Groups with
# intransitive top have S x 1 (or 1 x S) as a normal subgroup and are covered
# by induction/smaller cases.
#
# As in sweep C we record, for each failing pair, whether it is a
# (supplement, supplement), (top, top) or mixed pair relative to N.

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
  pr := Projection(W);   # W -> S_k
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

# U35 last: its degree-252 wreath product is by far the slowest case.
RunCase("Sp43", PSp(4,3),             40, 2);
RunCase("A9",   AlternatingGroup(9),   9, 2);
RunCase("M22",  MathieuGroup(22),     22, 2);
RunCase("U35",  PSU(3,5),            126, 2);
Print("SWEEP F DONE.\n");
QUIT;
