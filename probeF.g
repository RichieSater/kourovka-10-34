# Feasibility probe for sweep F: check AutPerm construction and time
# MaximalSubgroupClassReps on the full wreath product for each survivor.
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

Probe := function(name, S, n)
  local P, W, t0, mx;
  t0 := Runtime();
  P := AutPerm(S, n);
  Print(name, ": |Aut| = ", Size(P), ", degree ", NrMovedPoints(P),
        ", autperm time ", Runtime()-t0, "ms\n");
  W := WreathProduct(P, SymmetricGroup(2));
  Print(name, ": |W| = ", Size(W), ", degree ", NrMovedPoints(W), "\n");
  t0 := Runtime();
  mx := MaximalSubgroupClassReps(W);
  Print(name, ": W has ", Length(mx), " maximal classes, sizes ",
        List(mx, Size), ", time ", Runtime()-t0, "ms\n");
end;

Probe("Sp43", PSp(4,3), 40);
Probe("A9",  AlternatingGroup(9), 9);
Probe("U35", PSU(3,5), 126);
Probe("M22", MathieuGroup(22), 22);
QUIT;
