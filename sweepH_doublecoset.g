# Sweep H: double-coset exclusion criterion (sharpening of sweep E).
#
# Derivation.  Let G be a candidate counterexample with socle N = S^k,
# transitive top, t = |G/N| <= |Out(S)|^k k!.  For two Aut-stable maximal
# classes [U] <> [V] of S there are non-conjugate product-type maximal
# supplements A = N_G(U_1 x...x U_k), B = N_G(V_1 x...x V_k).  If G = AB,
# then writing each n in N as n = ab and splitting over the <= t cosets of
# N meeting both A and B:
#     N  is covered by <= t sets  (U_1x...xU_k) a_z (V_1x...xV_k) b_z ,
# each of size prod_i |U_i g_i V'_i| where U_i, V'_i are Aut(S)-conjugates
# of U, V.  For an Aut-STABLE class, every Aut(S)-conjugate is S-conjugate,
# and |U g V^s| = |U g' V|, so each factor is bounded by the LARGEST
# (U,V)-double coset in S:   maxDC(U,V) := max_g |UgV|.
# Hence G = AB forces  |S|^k <= t * maxDC(U,V)^k, and
#     |Out(S)|^k * k! * maxDC(U,V)^k  <  |S|^k
# for one stable pair [U] <> [V] excludes the socle S^k entirely.
# Since maxDC <= |U||V|, this is strictly sharper than sweep E.

StableMaximalReps := function(S)
  local A, gens, mx, stable, U, ok, a, V;
  A := AutomorphismGroup(S);
  gens := GeneratorsOfGroup(A);
  mx := MaximalSubgroupClassReps(S);
  stable := [];
  for U in mx do
    ok := true;
    for a in gens do
      V := Image(a, U);
      if not IsConjugate(S, V, U) then ok := false; break; fi;
    od;
    if ok then Add(stable, U); fi;
  od;
  return rec(stable := stable, out := Size(A)/Size(S));
end;

DCExclude := function(name, S, ks)
  local r, o, k, i, j, m, dc, pairs, best, tmax, good, excluded;
  r := StableMaximalReps(S);
  o := r.out;
  Print(name, ": |S| = ", Size(S), ", |Out| = ", o,
        ", stable classes: ", List(r.stable, Size), "\n");
  # maxDC for each stable pair
  pairs := [];
  for i in [1..Length(r.stable)] do
    for j in [i+1..Length(r.stable)] do
      dc := DoubleCosetRepsAndSizes(S, r.stable[i], r.stable[j]);
      m := Maximum(List(dc, x -> x[2]));
      Add(pairs, rec(u := Size(r.stable[i]), v := Size(r.stable[j]),
                     ndc := Length(dc), maxdc := m));
      Print("    pair (", Size(r.stable[i]), ",", Size(r.stable[j]),
            "): ", Length(dc), " double cosets, maxDC = ", m,
            " = |S|/", Size(S)/m, "\n");
    od;
  od;
  for k in ks do
    tmax := o^k * Factorial(k);
    good := false; best := fail;
    for m in pairs do
      if m.maxdc^k * tmax < Size(S)^k then
        good := true; best := [m.u, m.v];
      fi;
    od;
    if good then
      Print("    k=", k, ": EXCLUDED via stable pair ", best, "\n");
    else
      Print("    k=", k, ": not excluded\n");
    fi;
  od;
end;

RunDC := function(name, S, ks)
  local res;
  res := CALL_WITH_CATCH(function()
    DCExclude(name, S, ks);
    return true;
  end, []);
  if res[1] <> true then Print(name, ": ERROR, skipped\n"); fi;
end;

# Validation set: the known k=2 / k=3 survivors of sweep E (ground truth
# from sweeps C, F, G: all fail).  How much does the double-coset
# criterion recover without exhaustive computation?
RunDC("A5",    AlternatingGroup(5),          [2..8]);
RunDC("L3_2",  PSL(3,2),                     [2..8]);
RunDC("A6",    PSL(2,9),                     [2..8]);
RunDC("L2_8",  PSL(2,8),                     [2..8]);
RunDC("L2_11", PSL(2,11),                    [2..8]);
RunDC("A7",    AlternatingGroup(7),          [2..8]);
RunDC("L2_16", PSL(2,16),                    [2..8]);
RunDC("U3_3",  PSU(3,3),                     [2..8]);
RunDC("M11",   MathieuGroup(11),             [2..8]);
RunDC("A8",    AlternatingGroup(8),          [2..8]);
RunDC("L3_4",  PSL(3,4),                     [2..8]);
RunDC("Sp43",  PSp(4,3),                     [2..8]);
RunDC("L2_32", PSL(2,32),                    [2..8]);
RunDC("U3_5",  PSU(3,5),                     [2..8]);
RunDC("A9",    AlternatingGroup(9),          [2..8]);
RunDC("M22",   MathieuGroup(22),             [2..8]);
Print("SWEEP H DONE.\n");
QUIT;
