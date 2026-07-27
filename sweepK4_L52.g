# Sweep K4: novelty certification for the sweep-J6 survivor L5(2)@x=2.
# The duality fuses the parabolic pairs {P1, P4} and {P2, P3}; the only
# X-stable maximal class is the Singer normalizer 31:5, so maximal-class
# pairs cannot fire.  Candidate novelty pair: the incident-flag parabolics
#   V1 = P1 cap P4 = Stab(point < hyperplane),   index 31*15  = 465,
#   V2 = P2 cap P3 = Stab(2-space < 3-space),    index 155*7 = 1085.
# Both are duality-stable (the duality maps a (point < hyperplane) flag to
# a (point < hyperplane) flag, and a (2 < 3) flag to a (2 < 3) flag) and
# both avoid 31, giving d_31 = 1 > 0 = v_31(x).
# Certification (self-normalizing, X-stable, saturating, P_X-maximal,
# divisibility) is mechanical via sweepK_lib.g.

Read("/Users/richiesater/dev/math/kourovka-10.34/sweepK_lib.g");

res := CALL_WITH_CATCH(function()
  local vecs, dom, act, gens, dualperm, S, A, e, p1, h1, V1,
        pts2, pts3, P2s, P3s, V2, sub2, sub3;
  vecs := Filtered(Elements(GF(2)^5), v -> not IsZero(v));
  dom := Concatenation(List(vecs, v -> [1, v]), List(vecs, w -> [2, w]));
  act := function(x, g)
    if x[1] = 1 then return [1, x[2]*g];
    else return [2, x[2]*TransposedMat(g^-1)]; fi;
  end;
  gens := List(GeneratorsOfGroup(GL(5,2)), g -> Permutation(g, dom, act));
  dualperm := PermListList(dom, List(dom, x -> [3 - x[1], x[2]]));
  S := Group(gens);
  if Size(S) <> 9999360 then Error("L5(2) construction wrong"); fi;
  e := IdentityMat(5, GF(2));
  # V1: stabilizer of incident flag  point <e1>  <  hyperplane normal e2
  V1 := Stabilizer(S, [Position(dom, [1, e[1]]), Position(dom, [2, e[2]])],
                   OnTuples);
  if Size(V1) <> 9999360/465 then Error("V1 wrong size"); fi;
  # V2: stabilizer of flag  <e1,e2>  <  <e1,e2,e3>, via point-set stabilizers
  sub2 := Filtered(vecs, v -> v[4] = 0*Z(2) and v[5] = 0*Z(2)
                              and v[3] = 0*Z(2));
  sub3 := Filtered(vecs, v -> v[4] = 0*Z(2) and v[5] = 0*Z(2));
  pts2 := Set(List(sub2, v -> Position(dom, [1, v])));
  pts3 := Set(List(sub3, v -> Position(dom, [1, v])));
  P2s := Stabilizer(S, pts2, OnSets);
  P3s := Stabilizer(S, pts3, OnSets);
  V2 := Intersection(P2s, P3s);
  if Size(V2) <> 9999360/1085 then Error("V2 wrong size"); fi;
  if CertifyPair("L5_2", S, [dualperm], 2, V1, V2, "P14flag", "P23flag") then
    Print("L5_2: ALL k >= 2 EXCLUDED FOR ALL X (novelty pair certified).\n");
  else
    Print("L5_2: certification INCOMPLETE -- needs attention.\n");
  fi;
  return true;
end, []);
if res[1] <> true then Print("L5_2 K4: ERROR\n"); fi;
Print("SWEEP K4 DONE.\n");
QUIT;
