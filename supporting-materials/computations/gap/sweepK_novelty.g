# Sweep K: novelty-aware divisibility analysis for the four (S, X) families
# that survive sweep J:  L3(2)@x2, A6@{x2,x2,x4}, L2(11)@x2, L3(4)@{x6,x6,x12}.
#
# Correction to the sweep-J-era picture (discovered from the sweep C failure
# certificates for A6^2): the product-type maximal supplements of a candidate
# G with socle S^k and coordinate closure X are N_G(V^k) for V in the set
#     P_X(S) = maximal elements of { V < S : N_S(V) = V, [V]^S is X-stable }
# ordered by containment up to S-conjugacy.  When X fuses two maximal classes
# of S, their intersections typically enter P_X as "novelties" (this is the
# wreath analogue of novelty maximals in almost simple groups).
# Existence/maximality argument: as for B_U in STATUS.md — uniformity of the
# coordinate pattern is forced by top-transitivity plus X-stability of
# classes, and the poset-maximality of V blocks all intermediate subgroups.
#
# For each family we list P_X(S), then apply the divisibility criterion to
# every pair of distinct classes in P_X(S): pair (V, W), prime p,
#     d = v_p(|S|) - v_p(|V|) - v_p(|W|) > v_p(x)  ==>  S^k excluded, all k.
# Pairs with |V||W|/|S| an integer are flagged (they need non-arithmetic
# treatment: exact/near factorizations).

Read("proof_common.g");
CheckContainedConjugatesRegression();

Vp := function(n, p)
  local v; v := 0; while n mod p = 0 do n := n/p; v := v+1; od; return v;
end;

AutPerm := function(S, n)
  local P, a;
  AssertProof(IsSimpleGroup(S),"AutPerm input is not simple");
  a := Size(AutomorphismGroup(S));
  if n <> fail then
    P := Normalizer(SymmetricGroup(n), S);
    if Size(P) = a then
      AssertProof(IsNormal(P,S) and Size(Centralizer(P,S))=1,
                  "natural automorphism representation is not faithful");
      return P;
    fi;
  fi;
  P := Image(IsomorphismPermGroup(AutomorphismGroup(S)));
  P := Image(SmallerDegreePermutationRepresentation(P));
  AssertProof(Size(P)=a,"AutPerm failed");
  return P;
end;

NoveltyAnalysis := function(name, P)
  local S, hom, Q0, classes, reps, cls, XQ, Xgens, x, good, V, ok, a,
        i, j, maxel, isMax, p, d, allk, best, intpairs, sizes, W, versus,
        qclasses, qpos, qreps, candidates, upos, vpos, signature,
        bestSignature, chosenMaxel, chosenBest, chosenXQ, qrecords,
        qrecord, classSym, qgens, qperms, q, images, targets, classHom,
        action;
  S := PerfectResiduum(P);
  AssertProof(IsSimpleGroup(S),Concatenation(name,": residual is not simple"));
  AssertProof(IsNormal(P,S) and Size(Centralizer(P,S))=1,
              Concatenation(name,": automorphism action is not faithful"));
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Q0 := Image(hom);
  Print("### ", name, ": |S| = ", Size(S), ", |Out| = ", Size(Q0), "\n");
  Print("SOCLE|group=",name,"|",GroupFingerprint(S),"|P=",Size(P),
        "|out=",Size(Q0),"|faithful=true|simple=true\n");
  classes := ConjugacyClassesSubgroups(S);
  reps := List(classes,Representative);
  cls := Filtered([1..Length(reps)], i -> Size(reps[i]) < Size(S)
                   and Size(reps[i]) > 1 and Normalizer(S,reps[i])=reps[i]);
  Print("    self-normalizing proper classes: ", Length(cls),
        " with ids/sizes ", List(cls,i->[i,Size(reps[i])]), "\n");

  # Compute the exact Out(S)-action on every recorded S-subgroup class once.
  # Besides avoiding repeated representative-dependent conjugacy tests, this
  # action supplies the canonical quotient-class identifier used below.
  classSym := SymmetricGroup(Length(reps));
  qgens := GeneratorsOfGroup(Q0);
  qperms := [];
  for q in qgens do
    a := PreImagesRepresentative(hom,q);
    images := [];
    for i in [1..Length(reps)] do
      targets := Filtered([1..Length(reps)],j -> Size(reps[j])=Size(reps[i]));
      if Length(targets)>1 then
        targets := Filtered(targets,j -> IsConjugate(S,reps[i]^a,reps[j]));
      fi;
      AssertProof(Length(targets)=1,
                  Concatenation(name,": outer action does not identify one subgroup class"));
      Add(images,targets[1]);
    od;
    AssertProof(Set(images)=[1..Length(reps)],
                Concatenation(name,": outer subgroup-class action is not a permutation"));
    Add(qperms,PermList(images));
  od;
  classHom := GroupHomomorphismByImages(Q0,classSym,qgens,qperms);
  AssertProof(classHom<>fail and IsGroupHomomorphism(classHom),
              Concatenation(name,": outer subgroup-class action is not a homomorphism"));
  qrecords := CanonicalQuotientClassActionRecords(Q0,classHom,Length(reps),hom);
  for qpos in [1..Length(qrecords)] do
    # A subgroup-class representative returned by GAP need not be stable
    # between clean processes.  Audit every Q0-conjugate and select the
    # lexicographically least mathematical certificate.  This makes the
    # receipt independent of the arbitrary representative while also
    # checking that every representative of the coordinate-closure class
    # gives an obstruction.
    qrecord := qrecords[qpos];
    qreps := qrecord.reps;
    AssertProof(Length(qreps)>0,Concatenation(name,": empty quotient class"));
    bestSignature := fail;
    for XQ in qreps do
      x := Size(XQ);
      good := [];
      for i in cls do
        ok := true;
        for q in GeneratorsOfGroup(XQ) do
          action := Image(classHom,q);
          if i^action <> i then ok := false; break; fi;
        od;
        if ok then Add(good, i); fi;
      od;
      # maximal elements under containment-up-to-conjugacy
      isMax := List(good, V -> true);
      for i in [1..Length(good)] do
        for j in [1..Length(good)] do
          if i <> j and Size(reps[good[i]]) < Size(reps[good[j]])
             and Size(reps[good[j]]) mod Size(reps[good[i]]) = 0 then
            if Length(DirectContainedConjugates(
                        S,reps[good[j]],reps[good[i]]))>0 then
              isMax[i] := false; break;
            fi;
          fi;
        od;
      od;
      maxel := good{Filtered([1..Length(good)], i -> isMax[i])};
      allk := false; best := fail; intpairs := []; candidates:=[];
      for i in [1..Length(maxel)] do
        for j in [i+1..Length(maxel)] do
          versus := Size(reps[maxel[i]])*Size(reps[maxel[j]]);
          if versus mod Size(S) = 0 then
            Add(intpairs,[maxel[i],maxel[j],Size(reps[maxel[i]]),
                          Size(reps[maxel[j]])]);
          fi;
          for p in PrimeDivisors(Size(S)) do
            d := Vp(Size(S),p)-Vp(Size(reps[maxel[i]]),p)
                 -Vp(Size(reps[maxel[j]]),p);
            if d > Vp(x, p) then
              allk := true;
              Add(candidates,[p,d,maxel[i],maxel[j],
                              Size(reps[maxel[i]]),Size(reps[maxel[j]])]);
            fi;
          od;
        od;
      od;
      if not allk then
        HardFail(Concatenation(name,
          ": a representative of an X-case was not excluded; pairs=",
          String(intpairs)));
      fi;
      Sort(candidates); best:=candidates[1];
      signature := [maxel,best];
      if bestSignature=fail or signature < bestSignature then
        bestSignature := signature;
        chosenMaxel := maxel;
        chosenBest := best;
        chosenXQ := XQ;
      fi;
    od;
    AssertProof(bestSignature<>fail,
                Concatenation(name,": no quotient-class certificate"));
    x := Size(chosenXQ);
    maxel := chosenMaxel;
    best := chosenBest;
    sizes := List(maxel,i->[i,Size(reps[i])]);
    Print("    X/Inn (class=",qpos,", x=", x,
          ", conjugates=",Length(qreps),"): P_X classes ", sizes, "\n");
    p:=best[1]; d:=best[2]; upos:=best[3]; vpos:=best[4];
    Print("        ALL k >= 2 EXCLUDED via (|V|,|W|,p,d) = ",
          [best[5],best[6],p,d], "\n");
    Print("CERT|kind=novelty|group=",name,"|s=",Size(S),
          "|out=",Size(Q0),"|xclass=",qpos,"|x=",x,
          "|xclass_sha256=",qrecord.hash,
          "|xstructure=",StructureDescription(chosenXQ),
          "|xconjugates=",Length(qreps),
          "|uclass=",upos,"|u=",Size(reps[upos]),
          "|ufp=",SubgroupFingerprint(S,upos,reps[upos]),
          "|vclass=",vpos,"|v=",Size(reps[vpos]),
          "|vfp=",SubgroupFingerprint(S,vpos,reps[vpos]),
          "|p=",p,"|d=",d,"|vpx=",Vp(x,p),"|result=PASS\n");
  od;
end;

RunNov := function(name, S, n)
  NoveltyAnalysis(name, AutPerm(S,n));
end;

RunNov("L3_2",  PSL(3,2),      8);
RunNov("A6",    PSL(2,9),     10);
RunNov("L2_11", PSL(2,11),    12);
RunNov("L3_4",  PSL(3,4),   fail);
Print("SWEEP K DONE.|PASS\n");
QUIT_GAP(0);
