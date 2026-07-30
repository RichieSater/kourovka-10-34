# Sweep K: novelty-aware divisibility analysis for the four (S, X) families
# that survive sweep J:  L3(2)@x2, A6@{x2,x2,x4}, L2(11)@x2, L3(4)@{x6,x6,x12}.
#
# Correction to the sweep-J-era picture (discovered from the sweep C failure
# certificates for A6^2): the product-type maximal supplements of a candidate
# G with socle S^k and coordinate closure X are N_G(V^k) for V in the set
#     P_X(S) = maximal elements of { V < S : N_S(V) = V, [V]^S is X-stable }
# ordered by containment up to S-conjugacy.  When X fuses two maximal classes
# of S, their intersections typically enter P_X as "novelties" (this is the
# wreath analogue of novelty maximals in almost simple groups).
# Existence/maximality argument: as for B_U in STATUS.md — uniformity of the
# coordinate pattern is forced by top-transitivity plus X-stability of
# classes, and the poset-maximality of V blocks all intermediate subgroups.
#
# For each family we list P_X(S), then apply the divisibility criterion to
# every pair of distinct classes in P_X(S): pair (V, W), prime p,
#     d = v_p(|S|) - v_p(|V|) - v_p(|W|) > v_p(x)  ==>  S^k excluded, all k.
# Pairs with |V||W|/|S| an integer are flagged (they need non-arithmetic
# treatment: exact/near factorizations).

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

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

NoveltyAnalysis := function(name, P)
  local S, hom, Q0, cls, XQ, Xgens, x, good, V, ok, a, i, j, maxel, isMax,
        p, d, allk, best, intpairs, sizes, W, versus;
  S := PerfectResiduum(P);
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Q0 := Image(hom);
  Print("### ", name, ": |S| = ", Size(S), ", |Out| = ", Size(Q0), "\n");
  cls := List(ConjugacyClassesSubgroups(S), Representative);
  cls := Filtered(cls, V -> Size(V) < Size(S) and Size(V) > 1
                            and Normalizer(S, V) = V);
  Print("    self-normalizing proper classes: ", Length(cls),
        " with sizes ", Set(List(cls, Size)), "\n");
  for XQ in List(ConjugacyClassesSubgroups(Q0), Representative) do
    x := Size(XQ);
    Xgens := List(GeneratorsOfGroup(XQ), q -> PreImagesRepresentative(hom, q));
    good := [];
    for V in cls do
      ok := true;
      for a in Xgens do
        if not IsConjugate(S, V^a, V) then ok := false; break; fi;
      od;
      if ok then Add(good, V); fi;
    od;
    # maximal elements under containment-up-to-conjugacy
    isMax := List(good, V -> true);
    for i in [1..Length(good)] do
      for j in [1..Length(good)] do
        if i <> j and Size(good[i]) < Size(good[j])
           and Size(good[j]) mod Size(good[i]) = 0 then
          if ContainedConjugates(S, good[j], good[i], true) <> fail then
            isMax[i] := false; break;
          fi;
        fi;
      od;
    od;
    maxel := good{Filtered([1..Length(good)], i -> isMax[i])};
    sizes := List(maxel, Size);
    Print("    X/Inn (x=", x, "): P_X classes ", sizes, "\n");
    allk := false; best := fail; intpairs := [];
    for i in [1..Length(maxel)] do
      for j in [i+1..Length(maxel)] do
        versus := Size(maxel[i])*Size(maxel[j]);
        if versus mod Size(S) = 0 then
          Add(intpairs, [Size(maxel[i]), Size(maxel[j])]);
        fi;
        for p in PrimeDivisors(Size(S)) do
          d := Vp(Size(S), p) - Vp(Size(maxel[i]), p) - Vp(Size(maxel[j]), p);
          if d > Vp(x, p) then
            allk := true; best := [Size(maxel[i]), Size(maxel[j]), p, d];
          fi;
        od;
      od;
    od;
    if allk then
      Print("        ALL k >= 2 EXCLUDED via (|V|,|W|,p,d) = ", best, "\n");
    else
      Print("        NOT excluded; integer-ratio pairs: ", intpairs, "\n");
    fi;
  od;
end;

RunNov := function(name, S, n)
  local res;
  res := CALL_WITH_CATCH(function()
    NoveltyAnalysis(name, AutPerm(S, n));
    return true;
  end, []);
  if res[1] <> true then Print(name, ": ERROR, skipped\n"); fi;
end;

RunNov("L3_2",  PSL(3,2),      8);
RunNov("A6",    PSL(2,9),     10);
RunNov("L2_11", PSL(2,11),    12);
RunNov("L3_4",  PSL(3,4),   fail);
Print("SWEEP K DONE.\n");
QUIT;
