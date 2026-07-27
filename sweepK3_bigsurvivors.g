# Sweep K3: novelty certification for the sweep-J3 survivors (|S| >= 500000
# where the divisibility criterion on X-stable *maximal* classes fails for
# some X).  Unlike sweep K we avoid a full subgroup-lattice enumeration:
# for a specified candidate pair (V, W) we certify directly
#   (a) N_S(V) = V and [V] X-stable          (ditto W),
#   (b) V normally saturates all overgroups   (via IntermediateSubgroups),
#   (c) no X-stable self-normalizing class sits strictly above [V]
#       (normalizer-tower terminals of all overgroups are X-unstable),
#   (d) a prime p with d = v_p(|S|)-v_p(|V|)-v_p(|W|) > v_p(x).
# (a)-(c) are exactly the hypotheses of Lemmas A-C / Theorem D in THEOREM.md;
# (b)+(c) come from one IntermediateSubgroups sweep per candidate.

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

TowerTerminal := function(S, W)
  local U, Un;
  U := W;
  Un := Normalizer(S, U);
  while Size(Un) > Size(U) and Size(Un) < Size(S) do
    U := Un; Un := Normalizer(S, U);
  od;
  if Size(Un) = Size(S) then return S; fi;   # tower hit a normal subgroup: impossible in simple S unless U=S
  return U;
end;

IsXStableClass := function(S, Xgens, V)
  local a;
  for a in Xgens do
    if not IsConjugate(S, V^a, V) then return false; fi;
  od;
  return true;
end;

CertifyClass := function(S, Xgens, V, name)
  local ints, W, U, ok;
  if Normalizer(S, V) <> V then
    Print("      ", name, ": NOT self-normalizing -- FAIL\n"); return false;
  fi;
  if not IsXStableClass(S, Xgens, V) then
    Print("      ", name, ": NOT X-stable -- FAIL\n"); return false;
  fi;
  ok := true;
  ints := IntermediateSubgroups(S, V).subgroups;
  Print("      ", name, ": ", Length(ints), " intermediate subgroups\n");
  for W in ints do
    if Size(NormalClosure(W, V)) <> Size(W) then
      Print("      ", name, ": saturation FAILS in overgroup of size ",
            Size(W), "\n");
      ok := false;
    fi;
    U := TowerTerminal(S, W);
    if Size(U) < Size(S) and IsXStableClass(S, Xgens, U) then
      Print("      ", name, ": P_X-maximality FAILS: X-stable ",
            "self-normalizing class above it, size ", Size(U), "\n");
      ok := false;
    fi;
  od;
  if ok then Print("      ", name, ": certified (self-norm, X-stable, ",
                   "saturating, P_X-maximal)\n"); fi;
  return ok;
end;

CertifyPair := function(label, S, Xgens, x, V, W, nameV, nameW)
  local okV, okW, p, d, good;
  Print("  == pair (", nameV, " ", Size(V), ", ", nameW, " ", Size(W),
        ") for ", label, ", x = ", x, "\n");
  okV := CertifyClass(S, Xgens, V, nameV);
  okW := CertifyClass(S, Xgens, W, nameW);
  if IsConjugate(S, V, W) then
    Print("      classes coincide -- FAIL\n"); return false;
  fi;
  good := false;
  for p in PrimeDivisors(Size(S)) do
    d := Vp(Size(S), p) - Vp(Size(V), p) - Vp(Size(W), p);
    if d > Vp(x, p) then
      Print("      divisibility: p = ", p, ", d = ", d, " > v_p(x) = ",
            Vp(x, p), "  ==> ALL k >= 2 EXCLUDED\n");
      good := true;
    fi;
  od;
  if not good then Print("      NO divisibility obstruction -- FAIL\n"); fi;
  return okV and okW and good;
end;

# ---------- O(5,4) = PSp(4,4), X = full Aut (x = 4) ----------
# Survivor because the graph automorphism fuses the two parabolic classes;
# the only X-stable maximal classes give no obstruction.  Candidate pair:
# the Borel subgroup (= normalizer of a Sylow 2-subgroup; its overgroups
# are the two parabolics, fused by X, hence X-unstable) and the subfield
# subgroup Sp(4,2) (= centralizer of the field involution; maximal in S).
CertO54 := function()
  local S, P, hom, Q, Xgens, B, cands, a, C, sub;
  # the graph automorphism does not act on the 85-point representation
  # (it swaps points and totally isotropic lines), so build Aut generically
  P := Image(IsomorphismPermGroup(AutomorphismGroup(PSp(4,4))));
  P := Image(SmallerDegreePermutationRepresentation(P));
  S := PerfectResiduum(P);
  if Size(P) <> 4*Size(S) then Error("AutPerm O54 failed"); fi;
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Xgens := List(GeneratorsOfGroup(Image(hom)),
                q -> PreImagesRepresentative(hom, q));
  # Borel
  B := Normalizer(S, SylowSubgroup(S, 2));
  # subfield Sp(4,2) = centralizer of a field-type involution in the coset
  # over the order-2 element of P/S.  First try the odd-power trick to make
  # the coset representative an involution; fall back to random search.
  a := First(Image(hom), q -> Order(q) = 2);
  C := PreImagesRepresentative(hom, a);
  C := C^(Order(C) / 2^Vp(Order(C), 2));   # odd-part power: 2-element, same coset
  sub := fail;
  if Order(C) = 2 then
    sub := Centralizer(S, C);
    if Size(sub) <> 720 then sub := fail; fi;
  fi;
  if sub = fail then
    for a in [1..5000] do
      C := PreImagesRepresentative(hom, First(Image(hom), q -> Order(q)=2))
           * Random(S);
      if Order(C) = 2 then
        sub := Centralizer(S, C);
        if Size(sub) = 720 then break; fi;
        sub := fail;
      fi;
    od;
  fi;
  if sub = fail then Error("no subfield Sp(4,2) found"); fi;
  return CertifyPair("O(5,4)", S, Xgens, 4, B, sub, "Borel", "Sp(4,2)");
end;

if CertO54() then
  Print("O(5,4): ALL k >= 2 EXCLUDED FOR ALL X (novelty pair certified).\n");
else
  Print("O(5,4): certification INCOMPLETE -- needs attention.\n");
fi;
Print("SWEEP K3 (current survivor list) DONE.\n");
QUIT;
