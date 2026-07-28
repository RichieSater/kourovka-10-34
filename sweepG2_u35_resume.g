# Sweep G2: resume of sweep G's final socle U3(5)^3 after the session
# restart killed the GAP process at candidate 20 of 34 (certificates for
# candidates 1-20 are in sweepG_k3.log).  Reconstructs the same candidate
# enumeration (deterministic for a fixed GAP version and construction
# path), prints |G| for the skipped candidates so the two logs can be
# cross-checked line by line, and tests candidates 21-34.
Read("/Users/richiesater/dev/math/kourovka-10.34/property.g");

SKIP := 20;

P := Image(IsomorphismPermGroup(AutomorphismGroup(PSU(3,5))));;
P := Image(SmallerDegreePermutationRepresentation(P));;
socP := PerfectResiduum(P);;
W := WreathProduct(P, SymmetricGroup(3));;
pr := Projection(W);;
gens := [];;
for i in [1..3] do
  for g in GeneratorsOfGroup(socP) do
    Add(gens, Image(Embedding(W,i), g));
  od;
od;
N := Subgroup(W, gens);;
hom := NaturalHomomorphismByNormalSubgroup(W, N);;
Q := Image(hom);;
Print("=== socle U35^3 (resume):  |S|^k = ", Size(N),
      ",  |W/N| = ", Size(Q), "\n");
reps := List(ConjugacyClassesSubgroups(Q), Representative);;
tcount := 0;;
for T in reps do
  G := PreImage(hom, T);
  if not IsTransitive(Image(pr, G), [1..3]) then continue; fi;
  tcount := tcount + 1;
  if tcount <= SKIP then
    Print("    [skip ", tcount, "] |G| = ", Size(G),
          "  [G:N] = ", Size(G)/Size(N), "  (certified in sweepG_k3.log)\n");
    continue;
  fi;
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
  Print("    [", tcount, "] |G| = ", n, "  [G:N] = ", n/Size(N),
        "  maxclasses = ", Length(mx), " (suppl: ", nsupp, ")  ");
  if ok then
    Print("!!! COUNTEREXAMPLE !!!\n");
  else
    Print("fails: ", failinfo, "\n");
  fi;
od;
Print("=== socle U35^3 RESUME DONE: candidates ", SKIP+1, "..", tcount,
      " tested\n");
Print("SWEEP G2 DONE.\n");
QUIT;
