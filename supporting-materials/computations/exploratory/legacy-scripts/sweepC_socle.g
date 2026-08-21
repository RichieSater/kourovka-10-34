# Sweep C: exhaustive test of ALL groups G with socle S^k (k >= 2) for small
# simple S.  Rationale: a minimal counterexample G to a negative answer has
# trivial soluble radical, a unique minimal normal subgroup N = S^k with
# C_G(N) = 1 and G/N soluble, and k >= 2 (k = 1 is the almost simple case,
# excluded by Tikhonenko-Tyutyanov 2010).  Every such G embeds into
# W = Aut(S) wr S_k with N = Inn(S)^k <= G, so the groups between N and W
# (up to conjugacy) exhaust all candidates with this socle.
#
# For each candidate we also record how many classes of maximal subgroups
# are supplements of N (do not contain N): by the top-supplement lemma,
# every failure must come from a (supp,supp) or (top,top) pair.

Read("property.g");

# Aut(S) as a permutation group containing the given copy of S when the
# natural-degree normalizer realizes the full automorphism group; otherwise
# fall back to a generic (possibly larger-degree) faithful representation.
AutPerm := function(S, n)
  local P, a;
  a := Size(AutomorphismGroup(S));
  if n <> fail then
    P := Normalizer(SymmetricGroup(n), S);
    if Size(P) = a then return P; fi;
  fi;
  P := Image(IsomorphismPermGroup(AutomorphismGroup(S)));
  P := Image(SmallerDegreePermutationRepresentation(P));
  if Size(P) <> a then Error("AutPerm failed"); fi;
  return P;
end;

TestSocle := function(name, P, k)
  local socP, W, gens, i, g, N, hom, Q, reps, T, G, mx, n, top, isSupp,
        ii, jj, A, B, p, ok, failinfo, nsupp;
  socP := PerfectResiduum(P);   # = Soc(P) since P is almost simple
  W := WreathProduct(P, SymmetricGroup(k));
  gens := [];
  for i in [1..k] do
    for g in GeneratorsOfGroup(socP) do
      Add(gens, Image(Embedding(W,i), g));
    od;
  od;
  N := Subgroup(W, gens);
  hom := NaturalHomomorphismByNormalSubgroup(W, N);
  Q := Image(hom);
  Print("=== socle ", name, "^", k, ":  |S|^k = ", Size(N),
        ",  |W/N| = ", Size(Q), "\n");
  reps := List(ConjugacyClassesSubgroups(Q), Representative);
  Print("    candidates (subgroups N <= G <= W up to conjugacy): ",
        Length(reps), "\n");
  for T in reps do
    G := PreImage(hom, T);
    mx := MaximalSubgroupClassReps(G);
    n := Size(G);
    isSupp := List(mx, M -> not IsSubset(M, N));
    nsupp := Number(isSupp, x -> x);
    ok := true; failinfo := "";
    for ii in [1..Length(mx)] do
      if not ok then break; fi;
      for jj in [ii+1..Length(mx)] do
        A := mx[ii]; B := mx[jj];
        p := Size(A)*Size(B);
        if p mod n <> 0 or p <> n*Size(Intersection(A,B)) then
          ok := false;
          if isSupp[ii] and isSupp[jj] then failinfo := "supp-supp";
          elif not (isSupp[ii] or isSupp[jj]) then failinfo := "top-top";
          else failinfo := "TOP-SUPP(!!)"; fi;
          failinfo := Concatenation(failinfo, " sizes ", String(Size(A)),
                                    ",", String(Size(B)));
          break;
        fi;
      od;
    od;
    Print("    |G| = ", n, "  |G:N| = ", n/Size(N),
          "  maxclasses = ", Length(mx), " (suppl: ", nsupp, ")  ");
    if ok then
      Print("!!! COUNTEREXAMPLE !!!\n");
      Print("!!! generators: ", GeneratorsOfGroup(G), "\n");
    else
      Print("fails: ", failinfo, "\n");
    fi;
  od;
end;

RunCase := function(name, S, n, k)
  local res;
  res := CALL_WITH_CATCH(function()
    TestSocle(name, AutPerm(S, n), k);
    return true;
  end, []);
  if res[1] <> true then
    Print("=== socle ", name, "^", k, ": ERROR, case skipped\n");
  fi;
end;

# --- k = 2, all non-abelian simple S with |S| <= 20160 ---
RunCase("A5",    AlternatingGroup(5),  5, 2);
RunCase("L2_7",  PSL(2,7),   8, 2);
RunCase("A6",    PSL(2,9),  10, 2);
RunCase("L2_8",  PSL(2,8),   9, 2);
RunCase("L2_11", PSL(2,11), 12, 2);
RunCase("L2_13", PSL(2,13), 14, 2);
RunCase("L2_17", PSL(2,17), 18, 2);
RunCase("A7",    AlternatingGroup(7),  7, 2);
RunCase("L2_19", PSL(2,19), 20, 2);
RunCase("L2_16", PSL(2,16), 17, 2);
RunCase("L3_3",  PSL(3,3),  fail, 2);   # graph automorphism: generic Aut rep
RunCase("U3_3",  PSU(3,3),  28, 2);
RunCase("L2_23", PSL(2,23), 24, 2);
RunCase("L2_25", PSL(2,25), 26, 2);
RunCase("M11",   MathieuGroup(11), 11, 2);
RunCase("L2_27", PSL(2,27), 28, 2);
RunCase("L2_29", PSL(2,29), 30, 2);
RunCase("L2_31", PSL(2,31), 32, 2);
RunCase("A8",    AlternatingGroup(8),  8, 2);
RunCase("L3_4",  PSL(3,4),  fail, 2);   # graph automorphisms: generic Aut rep

# --- k = 3 ---
RunCase("A5",    AlternatingGroup(5),  5, 3);
RunCase("L2_7",  PSL(2,7),   8, 3);
RunCase("A6",    PSL(2,9),  10, 3);
RunCase("L2_8",  PSL(2,8),   9, 3);
RunCase("L2_11", PSL(2,11), 12, 3);

# --- k = 4 ---
RunCase("A5",    AlternatingGroup(5),  5, 4);

Print("SWEEP C DONE.\n");
QUIT;
