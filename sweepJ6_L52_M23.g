# Sweep J6: the two mathematically new groups in sweep J3's remaining queue,
# run with the AutomorphismGroup bottleneck bypassed:
#   - M23: Out = 1, so P := S itself serves as Aut.
#   - L5(2): Out = C2 (inverse-transpose duality), which does not act on the
#     31 points; build Aut = L5(2).2 directly on 62 points (points and
#     hyperplanes of PG(4,2), hyperplanes labelled by their dot-product
#     normal vectors; matrices act on normals by inverse-transpose, and the
#     duality swaps [point v] <-> [hyperplane with normal v]).
# The rest of J3's queue (PSL(2,q), 239 <= q <= 271, 243, 256) is left to
# the running sweep; those cases are also covered by the sweep L receipts
# and the classical dihedral/Borel argument.

Read("/Users/richiesater/dev/math/kourovka-10.34/sweepJ_lib.g");

res := CALL_WITH_CATCH(function()
  DivCriterion("M23", MathieuGroup(23));
  return true;
end, []);
if res[1] <> true then Print("M23: ERROR\n"); fi;

res := CALL_WITH_CATCH(function()
  local vecs, dom, act, gens, dualperm, S, A;
  vecs := Filtered(Elements(GF(2)^5), v -> not IsZero(v));
  dom := Concatenation(List(vecs, v -> [1, v]), List(vecs, w -> [2, w]));
  act := function(x, g)
    if x[1] = 1 then return [1, x[2]*g];
    else return [2, x[2]*TransposedMat(g^-1)]; fi;
  end;
  gens := List(GeneratorsOfGroup(GL(5,2)), g -> Permutation(g, dom, act));
  dualperm := PermListList(dom, List(dom, x -> [3 - x[1], x[2]]));
  S := Group(gens);
  A := Group(Concatenation(gens, [dualperm]));
  if Size(S) <> 9999360 then Error("L5(2) construction wrong"); fi;
  if Size(A) <> 2*Size(S) then Error("L5(2).2 construction wrong"); fi;
  if not IsNormal(A, S) then Error("S not normal in A"); fi;
  DivCriterion("L5_2", A);
  return true;
end, []);
if res[1] <> true then Print("L5_2: ERROR\n"); fi;
Print("SWEEP J6 DONE.\n");
QUIT;
