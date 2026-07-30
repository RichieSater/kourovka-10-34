# Sweep B2: completion of sweep B.  The original run died at order ~1376256
# because GAP's distributed perfect groups library omits some orders > 10^6;
# the missing files perf27.grp and perf33.grp (all that exist, per
# https://github.com/hulpke/extraperfect) are now installed in gap/grp.
# Re-run all library orders >= 1370880 up to the library maximum.
Read("property.g");

sizes := Filtered(ShallowCopy(SizesPerfectGroups()), n -> n >= 1370880);
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
Print("SWEEP B2 DONE. tested: ", total, "  counterexamples: ", found,
      "  errors: ", skipped, "\n");
QUIT;
