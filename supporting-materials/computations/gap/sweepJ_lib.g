# Sweep J: the divisibility criterion (all-k exclusion).
#
# Setting: G a candidate counterexample, socle N = S^k, transitive top,
# t = |G/N|.  Let X <= Aut(S) be the (common, up to conjugacy) image in
# Aut(S) of the coordinate stabilizers ("coordinate closure"), Inn <= X.
# Then G/N embeds in (X/Inn) wr S_k, so  t | x^k * k!  with x = |X/Inn|.
#
# For every X-stable class [U] of maximal subgroups of S, B_U = N_G(U^k)
# is a maximal subgroup of G with B_U ∩ N = U^k and B_U N = G (the
# existence and maximality lemmas in the paper). Distinct stable classes give
# non-conjugate B's.
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

Read("proof_common.g");

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

VpFactorial := function(k, p)
  local v, q; v := 0; q := p;
  while q <= k do v := v + Int(k/q); q := q*p; od; return v;
end;

AutPerm := function(S, n)
  local P, a;
  AssertProof(IsSimpleGroup(S), "AutPerm input is not simple");
  a := Size(AutomorphismGroup(S));
  if n <> fail then
    AssertProof(IsPermGroup(S), "natural-degree AutPerm requested for a non-permutation group");
    P := Normalizer(SymmetricGroup(n), S);
    if Size(P) = a then
      AssertProof(IsNormal(P,S), "natural normalizer does not contain S normally");
      AssertProof(Size(Centralizer(P,S))=1,
                  "natural normalizer does not act faithfully on S");
      return P;
    fi;
  fi;
  P := Image(IsomorphismPermGroup(AutomorphismGroup(S)));
  P := Image(SmallerDegreePermutationRepresentation(P));
  AssertProof(Size(P)=a,"AutPerm failed to preserve automorphism-group order");
  return P;
end;

# analyse one socle S (P = AutPerm containing socle)
DivCriterion := function(name, P)
  local S, mx, Q0, hom, XQ, stable, U, ok, a, i, j, p, d, x,
        allk, best, kex, k, klist, survivors, qclasses, qpos, candidates,
        cand, upos, vpos, qreps, signature, bestSignature, classAllk,
        chosenXQ, chosenStable, chosenBest, chosenKlist, classSym,
        qgens, qperms, q, images, targets, classHom, action, qrecords,
        qrecord, xresult;
  S := PerfectResiduum(P);
  AssertProof(IsSimpleGroup(S),Concatenation(name,": perfect residual is not simple"));
  AssertProof(IsNormal(P,S),Concatenation(name,": residual is not normal in P"));
  AssertProof(Size(Centralizer(P,S))=1,
              Concatenation(name,": P does not act faithfully on S"));
  mx := MaximalSubgroupClassReps(S);
  AssertProof(ForAll(mx,U -> Size(U)<Size(S) and IsSubset(S,U)),
              Concatenation(name,": invalid maximal-subgroup representative"));
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Q0 := Image(hom);   # Out(S) as it acts here
  AssertProof(KernelOfMultiplicativeGeneralMapping(hom)=S,
              Concatenation(name,": quotient kernel is not S"));
  Print("### ", name, ": |S| = ", Size(S), " = ",
        Collected(Factors(Size(S))), ", |Out| = ", Size(Q0),
        ", maximal classes ", List(mx, Size), "\n");
  Print("SOCLE|group=",name,"|",GroupFingerprint(S),
        "|P=",Size(P),"|out=",Size(Q0),"|faithful=true|simple=true\n");

  # Compute the Out(S)-action on maximal S-classes once.  Repeating subgroup
  # conjugacy tests separately for every X <= Out(S) is both expensive and a
  # source of arbitrary representative choices.  Classes of unique order are
  # fixed automatically; only same-order classes need an exact conjugacy test.
  classSym := SymmetricGroup(Length(mx));
  qgens := GeneratorsOfGroup(Q0);
  qperms := [];
  for q in qgens do
    a := PreImagesRepresentative(hom,q);
    images := [];
    for i in [1..Length(mx)] do
      targets := Filtered([1..Length(mx)],j -> Size(mx[j])=Size(mx[i]));
      if Length(targets)>1 then
        targets := Filtered(targets,j -> IsConjugate(S,mx[i]^a,mx[j]));
      fi;
      AssertProof(Length(targets)=1,
        Concatenation(name,": outer action does not identify one maximal class"));
      Add(images,targets[1]);
    od;
    AssertProof(Set(images)=[1..Length(mx)],
                Concatenation(name,": outer class action is not a permutation"));
    Add(qperms,PermList(images));
  od;
  classHom := GroupHomomorphismByImages(Q0,classSym,qgens,qperms);
  AssertProof(classHom<>fail and IsGroupHomomorphism(classHom),
              Concatenation(name,": outer maximal-class action is not a homomorphism"));
  survivors := [];
  qrecords := CanonicalQuotientClassActionRecords(Q0,classHom,Length(mx),hom);
  for qpos in [1..Length(qrecords)] do
    # GAP may return a different representative of a conjugacy class of
    # subgroups of Out(S) in another clean process.  Audit every conjugate and
    # select the lexicographically least mathematical receipt.  Invariance of
    # the all-k outcome across the full quotient class is asserted, not
    # assumed from one representative.
    qrecord := qrecords[qpos];
    qreps := qrecord.reps;
    AssertProof(Length(qreps)>0,
                Concatenation(name,": empty quotient-subgroup class"));
    bestSignature := fail;
    classAllk := fail;
    for XQ in qreps do
      x := Size(XQ);
      # X-stable maximal classes of S (X = <S, Xgens>)
      stable := [];
      for i in [1..Length(mx)] do
        ok := true;
        for q in GeneratorsOfGroup(XQ) do
          action := Image(classHom,q);
          if i^action <> i then ok := false; break; fi;
        od;
        if ok then Add(stable, [i,mx[i]]); fi;
      od;
      # divisibility pairs
      allk := false; best := fail; candidates := [];
      for i in [1..Length(stable)] do
        for j in [i+1..Length(stable)] do
          for p in PrimeDivisors(Size(S)) do
            d := Vp(Size(S), p) - Vp(Size(stable[i][2]), p)
                 - Vp(Size(stable[j][2]), p);
            if d > Vp(x, p) then
              # excluded k: d*k > k*v_p(x) + v_p(k!)
              if (p-1)*(d - Vp(x,p)) >= 1 then
                allk := true;
                Add(candidates,[p,d,stable[i][1],stable[j][1],
                                Size(stable[i][2]),Size(stable[j][2])]);
              fi;
            fi;
          od;
        od;
      od;
      if classAllk=fail then classAllk:=allk;
      else
        AssertProof(classAllk=allk,
          Concatenation(name,": all-k result varies inside an Out-class"));
      fi;
      if allk then
        Sort(candidates);
        best := candidates[1];
        signature := [0,best,List(stable,r->[r[1],Size(r[2])])];
      else
        # which k <= 30 are excluded by the exact-valuation condition?
        klist := [];
        for k in [2..30] do
          kex := false;
          for i in [1..Length(stable)] do
            for j in [i+1..Length(stable)] do
              for p in PrimeDivisors(Size(S)) do
                d := Vp(Size(S), p) - Vp(Size(stable[i][2]), p)
                     - Vp(Size(stable[j][2]), p);
                if d*k > k*Vp(x,p) + VpFactorial(k,p) then kex := true; fi;
              od;
            od;
          od;
          if kex then Add(klist, k); fi;
        od;
        signature := [1,klist,List(stable,r->[r[1],Size(r[2])])];
      fi;
      if bestSignature=fail or signature < bestSignature then
        bestSignature := signature;
        chosenXQ := XQ;
        chosenStable := stable;
        if allk then chosenBest := best;
        else chosenKlist := klist;
        fi;
      fi;
    od;
    AssertProof(bestSignature<>fail,
                Concatenation(name,": no quotient-class certificate"));
    XQ := chosenXQ;
    stable := chosenStable;
    x := Size(XQ);
    allk := classAllk;
    if allk then xresult := "EXCLUDED"; else xresult := "SURVIVES"; fi;
    Print("XCASE|group=",name,"|out=",Size(Q0),"|xclass=",qpos,
          "|xclass_sha256=",qrecord.hash,"|x=",x,
          "|xstructure=",StructureDescription(XQ),
          "|xconjugates=",Length(qreps),"|result=",xresult,"\n");
    if allk then
      best := chosenBest;
      p:=best[1]; d:=best[2]; upos:=best[3]; vpos:=best[4];
      Print("    X/Inn = ", StructureDescription(XQ), " (x=", x,
            ", conjugates=",Length(qreps),
            "): ALL k >= 2 EXCLUDED via (|U|,|V|,p,d) = ",
            [best[5],best[6],p,d], "\n");
      Print("CERT|kind=maximal|group=",name,"|s=",Size(S),
            "|out=",Size(Q0),"|xclass=",qpos,"|x=",x,
            "|xclass_sha256=",qrecord.hash,
            "|xstructure=",StructureDescription(XQ),
            "|xconjugates=",Length(qreps),
            "|uclass=",upos,"|u=",Size(mx[upos]),
            "|ufp=",SubgroupFingerprint(S,upos,mx[upos]),
            "|vclass=",vpos,"|v=",Size(mx[vpos]),
            "|vfp=",SubgroupFingerprint(S,vpos,mx[vpos]),
            "|p=",p,"|d=",d,"|vpx=",Vp(x,p),"|result=PASS\n");
    else
      klist := chosenKlist;
      Print("    X/Inn = ", StructureDescription(XQ), " (x=", x,
            ", conjugates=",Length(qreps),
            "): NOT all-k excluded; stable classes ",
            List(stable, r-> [r[1],Size(r[2])]),
            "; k<=30 excluded: ", klist, "\n");
      Add(survivors, [qpos,x,List(stable,r-> [r[1],Size(r[2])])]);
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
  DivCriterion(name, AutPerm(S, n));
end;

# the socles resistant to sweeps E/H (i.e. every socle not yet closed for
# unbounded k below order 500000), in order of size
