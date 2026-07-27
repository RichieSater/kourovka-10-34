# Sweep J5: divisibility certificates for the small alternating groups just
# beyond the |S| < 500000 base and the J3 order range, supporting the A_n
# case of the THEOREM.md section-5 program (small-n territory).
Read("/Users/richiesater/dev/math/kourovka-10.34/sweepJ_lib.g");
RunDiv("A11", AlternatingGroup(11), 11);
RunDiv("A12", AlternatingGroup(12), 12);
RunDiv("A13", AlternatingGroup(13), 13);
RunDiv("A14", AlternatingGroup(14), 14);
Print("SWEEP J5 DONE.\n");
QUIT;
