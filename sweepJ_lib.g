# Sweep J: the divisibility criterion (all-k exclusion).
#
# Setting: G a candidate counterexample, socle N = S^k, transitive top,
# t = |G/N|.  Let X <= Aut(S) be the (common, up to conjugacy) image in
# Aut(S) of the coordinate stabilizers ("coordinate closure"), Inn <= X.
# Then G/N embeds in (X/Inn) wr S_k, so  t | x^k * k!  with x = |X/Inn|.
#
# For every X-stable class [U] of maximal subgroups of S, B_U = N_G(U^k)
# is a maximal subgroup of G with B_U ∩ N = U^k and B_U N = G (existence
# lemma; see STATUS.md).  Distinct stable classes give non-conjugate B's.
# If G has property P then G = B_U B_V, forcing
#     |B_U ∩ B_V| = |B_U||B_V|/|G| = t * (|U||V|/|S|)^k  ∈  Z.
# With d = v_p(|S|) - v_p(|U|) - v_p(|V|) > 0 this needs p^{dk} | t, while
# v_p(t) <= k v_p(x) + v_p(k!) <= k v_p(x) + (k - 1)/(p - 1).  Hence
#     (p-1) * (d - v_p(x)) >= 1
# for some pair of distinct X-stable classes and prime p excludes socle
# S^k FOR ALL k >= 2 (with coordinate closure X).  If that fails, specific
# k are still excluded whenever  d*k > k*v_p(x) + v_p(k!).
#
# For each S we run over ALL subgroups Inn <= X <= Aut(S) (it suffices to
# consider X up to Aut(S)-conjugacy; only X/Inn matters).  A socle S^k is
# globally excluded for all k iff the criterion succeeds for every X.

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

VpFactorial := function(k, p)
  local v, q; v := 0; q := p;
  while q <= k do v := v + Int(k/q); q := q*p; od; return v;
end;

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

# analyse one socle S (P = AutPerm containing socle)
DivCriterion := function(name, P)
  local S, mx, Q0, hom, subsQ, XQ, Xgens, stable, U, ok, a, i, j, p, d, x,
        pairs, allk, somek, best, kex, k, klist, primes, survivors;
  S := PerfectResiduum(P);
  mx := MaximalSubgroupClassReps(S);
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Q0 := Image(hom);   # Out(S) as it acts here
  Print("### ", name, ": |S| = ", Size(S), " = ",
        Collected(Factors(Size(S))), ", |Out| = ", Size(Q0),
        ", maximal classes ", List(mx, Size), "\n");
  survivors := [];
  for XQ in List(ConjugacyClassesSubgroups(Q0), Representative) do
    x := Size(XQ);
    Xgens := List(GeneratorsOfGroup(XQ), q -> PreImagesRepresentative(hom, q));
    # X-stable maximal classes of S (X = <S, Xgens>)
    stable := [];
    for U in mx do
      ok := true;
      for a in Xgens do
        if not IsConjugate(S, U^a, U) then ok := false; break; fi;
      od;
      if ok then Add(stable, U); fi;
    od;
    # divisibility pairs
    allk := false; best := fail; somek := [];
    for i in [1..Length(stable)] do
      for j in [i+1..Length(stable)] do
        for p in PrimeDivisors(Size(S)) do
          d := Vp(Size(S), p) - Vp(Size(stable[i]), p)
               - Vp(Size(stable[j]), p);
          if d > Vp(x, p) then
            # excluded k: d*k > k*v_p(x) + v_p(k!)
            if (p-1)*(d - Vp(x,p)) >= 1 then
              allk := true;
              best := [Size(stable[i]), Size(stable[j]), p, d];
            fi;
          fi;
        od;
      od;
    od;
    if allk then
      Print("    X/Inn = ", StructureDescription(XQ), " (x=", x,
            "): ALL k >= 2 EXCLUDED via (|U|,|V|,p,d) = ", best, "\n");
    else
      # which k <= 30 are excluded by the exact-valuation condition?
      klist := [];
      for k in [2..30] do
        kex := false;
        for i in [1..Length(stable)] do
          for j in [i+1..Length(stable)] do
            for p in PrimeDivisors(Size(S)) do
              d := Vp(Size(S), p) - Vp(Size(stable[i]), p)
                   - Vp(Size(stable[j]), p);
              if d*k > k*Vp(x,p) + VpFactorial(k,p) then kex := true; fi;
            od;
          od;
        od;
        if kex then Add(klist, k); fi;
      od;
      Print("    X/Inn = ", StructureDescription(XQ), " (x=", x,
            "): NOT all-k excluded; stable classes ",
            List(stable, Size), "; k<=30 excluded: ", klist, "\n");
      Add(survivors, [x, List(stable, Size)]);
    fi;
  od;
  if survivors = [] then
    Print("    ==> ", name, "^k EXCLUDED FOR ALL k >= 2 AND ALL X.\n");
  else
    Print("    ==> ", name, " SURVIVES for X with x in ",
          List(survivors, s -> s[1]), "\n");
  fi;
end;

RunDiv := function(name, S, n)
  local res;
  res := CALL_WITH_CATCH(function()
    DivCriterion(name, AutPerm(S, n));
    return true;
  end, []);
  if res[1] <> true then Print(name, ": ERROR, skipped\n"); fi;
end;

# the socles resistant to sweeps E/H (i.e. every socle not yet closed for
# unbounded k below order 500000), in order of size
