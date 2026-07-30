# Sweep K2: certify the normal-saturation hypothesis of the novelty-
# maximality lemma for every self-normalizing proper subgroup class of the
# four exceptional socles (not only those used in the final exclusion pairs,
# for robustness):  for each self-normalizing V < S and each overgroup class
# V <= W <= S, check <V^W> = W.
#
# (For V in P_X(S) this certifies that B_V = N_G(V^k) is maximal in every
# candidate G; see STATUS.md.)

CheckSaturation := function(name, S)
  local cls, sn, V, W, ok, bad, up, cc, pair;
  cls := List(ConjugacyClassesSubgroups(S), Representative);
  sn := Filtered(cls, V -> Size(V) > 1 and Size(V) < Size(S)
                           and Normalizer(S, V) = V);
  Print("### ", name, ": ", Length(sn), " self-normalizing classes, sizes ",
        List(sn, Size), "\n");
  bad := [];
  for V in sn do
    # overgroup classes: W with a conjugate of V inside
    for W in cls do
      if Size(W) > Size(V) and Size(W) mod Size(V) = 0 then
        pair := ContainedConjugates(S, W, V, true);
        if pair <> fail then
          # V' := pair[1] is a conjugate of V inside W
          if Size(NormalClosure(W, pair[1])) <> Size(W) then
            Add(bad, [Size(V), Size(W)]);
            Print("    !!! saturation FAILS: V of size ", Size(V),
                  " in W of size ", Size(W), ", closure ",
                  Size(NormalClosure(W, pair[1])), "\n");
          fi;
        fi;
      fi;
    od;
    # W = S itself: closure is normal, nontrivial, S simple => = S.  OK.
  od;
  if bad = [] then
    Print("    ALL self-normalizing classes normally saturate: OK\n");
  fi;
end;

CheckSaturation("L3_2",  PSL(3,2));
CheckSaturation("A6",    PSL(2,9));
CheckSaturation("L2_11", PSL(2,11));
CheckSaturation("L3_4",  PSL(3,4));
Print("SWEEP K2 DONE.\n");
QUIT;
