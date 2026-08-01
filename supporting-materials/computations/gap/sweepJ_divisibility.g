# Sweep J: exact maximal-class divisibility certificates below 500000.
Read("sweepJ_lib.g");

RunDiv("A5",    AlternatingGroup(5),   5);
RunDiv("L3_2",  PSL(3,2),              8);
RunDiv("A6",    PSL(2,9),             10);
RunDiv("L2_8",  PSL(2,8),              9);
RunDiv("L2_11", PSL(2,11),            12);
RunDiv("L2_13", PSL(2,13),            14);
RunDiv("L2_17", PSL(2,17),            18);
RunDiv("A7",    AlternatingGroup(7),   7);
RunDiv("L2_19", PSL(2,19),            20);
RunDiv("L2_16", PSL(2,16),            17);
RunDiv("L3_3",  PSL(3,3),           fail);
RunDiv("U3_3",  PSU(3,3),             28);
RunDiv("L2_23", PSL(2,23),            24);
RunDiv("L2_25", PSL(2,25),            26);
RunDiv("M11",   MathieuGroup(11),     11);
RunDiv("L2_27", PSL(2,27),            28);
RunDiv("L2_29", PSL(2,29),            30);
RunDiv("L2_31", PSL(2,31),            32);
RunDiv("A8",    AlternatingGroup(8),   8);
RunDiv("L3_4",  PSL(3,4),           fail);
RunDiv("L2_37", PSL(2,37),            38);
RunDiv("Sp43",  PSp(4,3),             40);
# Force the known permutation representation; SuzukiGroup(8) without the
# filter is a matrix group and is rejected by the fail-closed AutPerm path.
RunDiv("Sz8",   SuzukiGroup(IsPermGroup,8), 65);
RunDiv("L2_32", PSL(2,32),            33);
RunDiv("U3_4",  PSU(3,4),             65);
RunDiv("M12",   MathieuGroup(12),     12);
RunDiv("U3_5",  PSU(3,5),            126);
# J1, A9, L3(5), and M22 are run by sweepJ2_tail.g using constructions
# known to be available in the pinned package set.
Print("SWEEP J DONE.|PASS\n");
QUIT_GAP(0);
