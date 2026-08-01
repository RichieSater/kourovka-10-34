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

Read("sweepJ_lib.g");

DivCriterion("M23", MathieuGroup(23));

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
AssertProof(Size(S)=9999360,"L5(2) construction wrong");
AssertProof(Size(A)=2*Size(S),"L5(2).2 construction wrong");
AssertProof(IsNormal(A,S),"S not normal in L5(2).2");
AssertProof(Size(Centralizer(A,S))=1,"L5(2).2 action on S is not faithful");
DivCriterion("L5_2", A);
Print("SWEEP J6 DONE.|PASS\n");
QUIT_GAP(0);
