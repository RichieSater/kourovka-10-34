# Sweep J4: certificate patch. Covers the 17 socles |S| < 500000 that were
# missing from sweeps J/J2 (audit finding, 2026-07-25):
#   - Sz(8): present in sweep J but skipped with an error — SuzukiGroup(8)
#     returns a MATRIX group and AutPerm's Normalizer(SymmetricGroup(65), S)
#     has no method for it.  Fixed here by constructing the degree-65
#     permutation representation.
#   - L2(q), q in {41,43,47,49,53,59,61,64,67,71,73,79,81,83,89,97}: never
#     added to the sweep J RunDiv list (the earlier hand dihedral-pair argument
#     covered them mathematically; this sweep supplies machine certificates).
# After this sweep, every non-abelian simple S with |S| < 500000 has a
# machine certificate excluding socle S^k for all k >= 2 and all X.

Read("sweepJ_lib.g");

RunDiv("Sz8",   SuzukiGroup(IsPermGroup, 8), 65);
RunDiv("L2_41", PSL(2,41), 42);
RunDiv("L2_43", PSL(2,43), 44);
RunDiv("L2_47", PSL(2,47), 48);
RunDiv("L2_49", PSL(2,49), 50);
RunDiv("L2_53", PSL(2,53), 54);
RunDiv("L2_59", PSL(2,59), 60);
RunDiv("L2_61", PSL(2,61), 62);
RunDiv("L2_64", PSL(2,64), 65);
RunDiv("L2_67", PSL(2,67), 68);
RunDiv("L2_71", PSL(2,71), 72);
RunDiv("L2_73", PSL(2,73), 74);
RunDiv("L2_79", PSL(2,79), 80);
RunDiv("L2_81", PSL(2,81), 82);
RunDiv("L2_83", PSL(2,83), 84);
RunDiv("L2_89", PSL(2,89), 90);
RunDiv("L2_97", PSL(2,97), 98);

Print("SWEEP J4 DONE.|PASS\n");
QUIT_GAP(0);
