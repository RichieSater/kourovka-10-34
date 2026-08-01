Read("property.g");

# Expected: A5 fails (A4 vs S3 pair), S4 has the property (soluble, allowed),
# A5 wr C2 fails, SL(2,5) ?
Print("A5:      ", KourovkaTest(AlternatingGroup(5)), "\n");
Print("S4:      ", KourovkaTest(SymmetricGroup(4)), "\n");
Print("S5:      ", KourovkaTest(SymmetricGroup(5)), "\n");
Print("SL25:    ", KourovkaTest(SL(2,5)), "\n");
Print("A5wrC2:  ", KourovkaTest(WreathProduct(AlternatingGroup(5), SymmetricGroup(2))), "\n");
QUIT;
