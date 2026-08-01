# Sweep A: all non-soluble groups of order <= 2000.
# A non-soluble group has a non-abelian simple composition factor, whose order
# divides |G|. Non-abelian simple orders <= 2000: 60 (A5), 168 (L2(7)),
# 360 (A6, = 6*60), 504 (L2(8)), 660 (L2(11)), 1092 (L2(13)).
# So it suffices to scan orders divisible by 60, 168, 504, 660 or 1092.
Read("property.g");
LoadPackage("smallgrp");

orders := Filtered([60..2000], n -> n mod 60 = 0 or n mod 168 = 0
                     or n mod 504 = 0 or n mod 660 = 0 or n mod 1092 = 0);
found := [];
total := 0;
for n in orders do
  gs := AllSmallGroups(Size, n, IsSolvableGroup, false);
  total := total + Length(gs);
  Print("order ", n, ": ", Length(gs), " non-soluble groups\n");
  for G in gs do
    if KourovkaTest(G) = true then
      Add(found, IdGroup(G));
      Print("!!! COUNTEREXAMPLE: SmallGroup", IdGroup(G), "\n");
    fi;
  od;
od;
Print("SWEEP A DONE. non-soluble groups tested: ", total,
      "  counterexamples: ", found, "\n");
QUIT;
