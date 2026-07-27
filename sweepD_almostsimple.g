# Sweep D: machine verification of the Tikhonenko-Tyutyanov theorem (negative
# answer for almost simple groups) for all almost simple groups with socle of
# order <= 20160: every group S <= G <= Aut(S) must FAIL the property.
Read("/Users/richiesater/dev/math/kourovka-10.34/property.g");

CheckAS := function(name, S, n)
  local a, P, hom, Q, reps, T, G, t;
  a := Size(AutomorphismGroup(S));
  P := fail;
  if n <> fail then
    P := Normalizer(SymmetricGroup(n), S);
    if Size(P) <> a then P := fail; fi;
  fi;
  if P = fail then
    P := Image(SmallerDegreePermutationRepresentation(
           Image(IsomorphismPermGroup(AutomorphismGroup(S)))));
  fi;
  hom := NaturalHomomorphismByNormalSubgroup(P, PerfectResiduum(P));
  Q := Image(hom);
  reps := List(ConjugacyClassesSubgroups(Q), Representative);
  for T in reps do
    G := PreImage(hom, T);
    t := KourovkaTest(G);
    Print(name, " ext of index-", Size(Q)/Size(T), " over socle, |G| = ",
          Size(G), ": ");
    if t = true then
      Print("!!! HAS PROPERTY -- CONTRADICTS TT2010 !!!\n");
    else
      Print("fails (ok)\n");
    fi;
  od;
end;

CheckAS("A5",    AlternatingGroup(5),  5);
CheckAS("L2_7",  PSL(2,7),   8);
CheckAS("A6",    PSL(2,9),  10);
CheckAS("L2_8",  PSL(2,8),   9);
CheckAS("L2_11", PSL(2,11), 12);
CheckAS("L2_13", PSL(2,13), 14);
CheckAS("L2_17", PSL(2,17), 18);
CheckAS("A7",    AlternatingGroup(7),  7);
CheckAS("L2_19", PSL(2,19), 20);
CheckAS("L2_16", PSL(2,16), 17);
CheckAS("L3_3",  PSL(3,3),  fail);
CheckAS("U3_3",  PSU(3,3),  28);
CheckAS("L2_23", PSL(2,23), 24);
CheckAS("L2_25", PSL(2,25), 26);
CheckAS("M11",   MathieuGroup(11), 11);
CheckAS("L2_27", PSL(2,27), 28);
CheckAS("L2_29", PSL(2,29), 30);
CheckAS("L2_31", PSL(2,31), 32);
CheckAS("A8",    AlternatingGroup(8),  8);
CheckAS("L3_4",  PSL(3,4),  fail);
Print("SWEEP D DONE.\n");
QUIT;
