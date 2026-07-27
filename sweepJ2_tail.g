Read("/Users/richiesater/dev/math/kourovka-10.34/sweepJ_lib.g");
RunDiv("J1",    SimpleGroup("J1"),  fail);
RunDiv("A9",    AlternatingGroup(9),   9);
RunDiv("L3_5",  PSL(3,5),           fail);
RunDiv("M22",   MathieuGroup(22),     22);
Print("SWEEP J2 DONE.\n");
QUIT;
