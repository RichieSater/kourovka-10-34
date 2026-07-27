S := MathieuGroup(22);;
P := Normalizer(SymmetricGroup(22), S);;
Print("M22: |Aut| = ", Size(P), "\n");
W := WreathProduct(P, SymmetricGroup(2));;
Print("|W| = ", Size(W), ", degree ", NrMovedPoints(W), "\n");
t0 := Runtime();;
mx := MaximalSubgroupClassReps(W);;
Print("W has ", Length(mx), " maximal classes, sizes ", List(mx, Size),
      ", time ", Runtime()-t0, "ms\n");
QUIT;
