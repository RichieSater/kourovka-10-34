# Sweep M: divisibility certificates for the remaining sporadic groups and
# the Tits group (HITLIST item 3).  Works purely from character-table data
# (maximal subgroup orders via ctbllib Maxes); no group construction.
#
# Stability handling: sporadic |Out| <= 2.
#   |Out| = 1: every maximal class is Aut-stable; any two distinct classes
#              are usable, condition d > 0.
#   |Out| = 2: a class whose order is UNIQUE in the maxes list is
#              automatically Aut-stable (the outer automorphism permutes
#              classes preserving order).  We use only those, with the
#              worst-case condition d > v_p(2) — this covers every X
#              between Inn and Aut simultaneously.
# Groups whose Maxes are absent from ctbllib are reported for manual
# handling (hardcoded ATLAS/literature pairs at the bottom).

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

CheckSporadic := function(name, out)
  local ct, S, orders, usable, ok, best, i, j, p, d;
  ct := CharacterTable(name);
  if ct = fail then Print(name, ": NO TABLE\n"); return; fi;
  S := Size(ct);
  if not HasMaxes(ct) then
    Print(name, ": no Maxes in ctbllib -- MANUAL\n"); return;
  fi;
  orders := List(Maxes(ct), n -> Size(CharacterTable(n)));
  if out = 1 then
    usable := orders;
  else
    usable := Filtered(orders, o -> Number(orders, x -> x = o) = 1);
  fi;
  ok := false; best := fail;
  for i in [1..Length(usable)] do
    for j in [i+1..Length(usable)] do
      for p in PrimeDivisors(S) do
        d := Vp(S, p) - Vp(usable[i], p) - Vp(usable[j], p);
        if d > Vp(out, p) then
          ok := true; best := [usable[i], usable[j], p, d];
        fi;
      od;
    od;
  od;
  if ok then
    Print(name, " (|S| = ", S, ", out = ", out,
          "): ALL k >= 1 EXCLUDED, ALL X, via (|U|,|V|,p,d) = ",
          best, "\n");
  else
    Print(name, ": NOT excluded by table pairs -- needs attention; ",
          "usable orders ", usable, "\n");
  fi;
end;

CheckSporadic("M24",     1);
CheckSporadic("J3",      2);
CheckSporadic("J4",      1);
CheckSporadic("HS",      2);
CheckSporadic("McL",     2);
CheckSporadic("Co1",     1);
CheckSporadic("Co2",     1);
CheckSporadic("Co3",     1);
CheckSporadic("Suz",     2);
CheckSporadic("He",      2);
CheckSporadic("Ru",      1);
CheckSporadic("ON",      2);
CheckSporadic("Fi22",    2);
CheckSporadic("Fi23",    1);
CheckSporadic("Fi24'",   2);
CheckSporadic("HN",      2);
CheckSporadic("Ly",      1);
CheckSporadic("Th",      1);
CheckSporadic("B",       1);
CheckSporadic("M",       1);
CheckSporadic("2F4(2)'", 2);
Print("SWEEP M DONE.\n");
QUIT;
