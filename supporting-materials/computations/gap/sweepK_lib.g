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

Read("proof_common.g");

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
    HardFail(Concatenation(name,": not self-normalizing"));
  fi;
  if not IsXStableClass(S, Xgens, V) then
    HardFail(Concatenation(name,": not X-stable"));
  fi;
  ok := true;
  ints := IntermediateSubgroups(S, V).subgroups;
  Print("      ", name, ": ", Length(ints), " intermediate subgroups\n");
  for W in ints do
    if Size(NormalClosure(W, V)) <> Size(W) then
      Print("      ", name, ": saturation FAILS in overgroup of size ",
            Size(W), "\n");
      HardFail(Concatenation(name,": normal saturation failed"));
    fi;
    U := TowerTerminal(S, W);
    if Size(U) < Size(S) and IsXStableClass(S, Xgens, U) then
      Print("      ", name, ": P_X-maximality FAILS: X-stable ",
            "self-normalizing class above it, size ", Size(U), "\n");
      HardFail(Concatenation(name,": P_X maximality failed"));
    fi;
  od;
  if ok then Print("      ", name, ": certified (self-norm, X-stable, ",
                   "saturating, P_X-maximal)\n"); fi;
  return ok;
end;

CertifyPair := function(label, S, Xgens, x, V, W, nameV, nameW)
  local okV, okW, p, d, good, witnesses, best;
  AssertProof(IsSimpleGroup(S),Concatenation(label,": S is not simple"));
  Print("  == pair (", nameV, " ", Size(V), ", ", nameW, " ", Size(W),
        ") for ", label, ", x = ", x, "\n");
  okV := CertifyClass(S, Xgens, V, nameV);
  okW := CertifyClass(S, Xgens, W, nameW);
  if IsConjugate(S, V, W) then
    HardFail(Concatenation(label,": constructed classes coincide"));
  fi;
  good := false; witnesses:=[];
  for p in PrimeDivisors(Size(S)) do
    d := Vp(Size(S), p) - Vp(Size(V), p) - Vp(Size(W), p);
    if d > Vp(x, p) then
      Print("      divisibility: p = ", p, ", d = ", d, " > v_p(x) = ",
            Vp(x, p), "  ==> ALL k >= 2 EXCLUDED\n");
      good := true; Add(witnesses,[p,d]);
    fi;
  od;
  if not good then HardFail(Concatenation(label,": no divisibility obstruction")); fi;
  Sort(witnesses); best:=witnesses[1];
  Print("CERT|kind=constructed-novelty|group=",label,"|s=",Size(S),
        "|x=",x,"|uclass=",nameV,"|u=",Size(V),
        "|ufp=",SubgroupFingerprint(S,0,V),
        "|vclass=",nameW,"|v=",Size(W),
        "|vfp=",SubgroupFingerprint(S,0,W),
        "|p=",best[1],"|d=",best[2],"|vpx=",Vp(x,best[1]),
        "|result=PASS\n");
  return okV and okW and good;
end;
