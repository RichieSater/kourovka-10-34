# Canonical list of non-abelian simple groups 500000 <= |S| <= 10500000,
# from GAP's SimpleGroupsIterator. Run this script from computations/gap;
# the canonical list is written to the sibling data directory.
it := SimpleGroupsIterator(500000, 10500000);
out := OutputTextFile("../data/simple_groups_5e5_to_1.05e7.txt", false);
n := 0;
for G in it do
  n := n + 1;
  info := IsomorphismTypeInfoFiniteSimpleGroup(G);
  AppendTo(out, Size(G), "  ", info.shortname, "\n");
od;
CloseStream(out);
Print("wrote ", n, " groups\n");
QUIT;
