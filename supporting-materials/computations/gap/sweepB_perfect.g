# Sweep B: all groups in GAP's perfect groups library (orders <= 2,000,000;
# the library omits a few orders 61440*2^a, 86016, ... where too many exist —
# those omissions are reported at the end).
Read("property.g");

sizes := ShallowCopy(SizesPerfectGroups());
Sort(sizes);
found := [];
skipped := [];
total := 0;
for n in sizes do
  for i in [1..NrPerfectLibraryGroups(n)] do
    res := CALL_WITH_CATCH(function()
      local G, t;
      G := PerfectGroup(IsPermGroup, n, i);
      t := KourovkaTest(G);
      return t = true;
    end, []);
    if res[1] = true then
      if res[2] = true then
        Add(found, [n,i]);
        Print("!!! PERFECT COUNTEREXAMPLE: PerfectGroup(", n, ",", i, ")\n");
      fi;
    else
      Add(skipped, [n,i]);
      Print("ERROR on PerfectGroup(", n, ",", i, ") -- skipped\n");
    fi;
    total := total + 1;
  od;
  Print("perfect order ", n, " done (cumulative ", total, ")\n");
od;
Print("SWEEP B DONE. tested: ", total, "  counterexamples: ", found,
      "  errors: ", skipped, "\n");
QUIT;
