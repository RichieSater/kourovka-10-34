# Sweep I: exhaustive k = 4 tests (transitive top) for the small socles not
# excluded at k = 4 by sweeps E/E2/H and feasible for full enumeration:
#   L3(2), L2(8), L2(11), A6, A7.   (A5^4 was done in sweep C.)
# Method identical to sweep F/G.
Read("/Users/richiesater/dev/math/kourovka-10.34/property.g");
Read("/Users/richiesater/dev/math/kourovka-10.34/sweepFG_lib.g");

RunCase("L3_2", PSL(3,2),             8, 4);
RunCase("L2_8", PSL(2,8),             9, 4);
RunCase("L2_11", PSL(2,11),          12, 4);
RunCase("A6",   PSL(2,9),            10, 4);
RunCase("A7",   AlternatingGroup(7),  7, 4);
Print("SWEEP I DONE.\n");
QUIT;
