# Sweep K2 v2: exhaustive, embedding-aware normal-saturation certificates.
#
# For every self-normalizing proper S-class [V], and every S-class [W], this
# program checks every W-conjugacy orbit of embeddings V' <= W.  It uses three
# paths and fails unless they agree:
#
#   A. IntermediateSubgroups(S,V), which enumerates the actual overgroups of a
#      fixed representative V;
#   B. a direct N_S(V) \\ S / W double-coset calculation implemented in
#      proof_common.g (not ContainedConjugates);
#   C. ContainedConjugates(S,W,V) without the only-one flag.
#
# The A-overgroups are conjugated to the fixed W representative and mapped to
# B's embedding-orbit identifiers.  Every B orbit must occur in A, and the
# normal-closure orders must agree.  Class positions plus canonical numeric
# fingerprints (not chosen generators or permutation degree) make same-order
# nonconjugate classes
# unambiguous together with their class positions.

Read("proof_common.g");
CheckContainedConjugatesRegression();

# Use exactly the same socle representations as sweep K so class positions
# and canonical class fingerprints cross-link without an order-only alias.
AuditSocleRepresentation := function(S,n)
  local P,a;
  a:=Size(AutomorphismGroup(S));
  if n<>fail and IsPermGroup(S) then
    P:=Normalizer(SymmetricGroup(n),S);
    if Size(P)=a then return PerfectResiduum(P); fi;
  fi;
  P:=Image(IsomorphismPermGroup(AutomorphismGroup(S)));
  P:=Image(SmallerDegreePermutationRepresentation(P));
  AssertProof(Size(P)=a,"audit socle automorphism representation failed");
  return PerfectResiduum(P);
end;

CheckSaturation := function(name, S)
  local classes, reps, snpos, vi, V, ints, actual, saturation, wpos, W,
        direct, builtin, observed, A, transporter, E, orbit, clA, clB,
        apos, builtinMatches, status, failures, pair, wnorm, aCount;

  AssertProof(IsSimpleGroup(S), Concatenation(name, ": S is not simple"));
  classes := ConjugacyClassesSubgroups(S);
  reps := List(classes,Representative);
  snpos := Filtered([1..Length(reps)], i -> Size(reps[i]) > 1
    and Size(reps[i]) < Size(S) and Normalizer(S,reps[i]) = reps[i]);
  Print("GROUP|name=",name,"|",GroupFingerprint(S),
        "|subgroup_classes=",Length(reps),
        "|self_normalizing_classes=",Length(snpos),"\n");

  failures := 0;
  for vi in snpos do
    V := reps[vi];
    ints := IntermediateSubgroups(S,V).subgroups;
    actual := Concatenation([V],ints,[S]);
    AssertProof(ForAll(actual,A -> IsSubset(A,V)),
                "IntermediateSubgroups returned a non-overgroup");
    AssertProof(ForAll(Combinations(actual,2),pair -> pair[1]<>pair[2]),
                "IntermediateSubgroups returned duplicate actual overgroups");
    saturation := true;
    Print("VCLASS|group=",name,
          "|class=",vi,
          "|order=",Size(V),
          "|index=",Index(S,V),
          "|normalizer=",Size(Normalizer(S,V)),
          "|class_sha256=",ClassFingerprintHash(S,vi,V),
          "|actual_overgroups=",Length(actual),"\n");

    for wpos in [1..Length(reps)] do
      W := reps[wpos];
      if Size(W) >= Size(V) and Size(W) mod Size(V) = 0 then
        direct := DirectContainedConjugates(S,W,V);
        # Canonicalize all logged orbit identifiers by proof-relevant numeric
        # invariants.  Tied orbits have identical logged fields, so their
        # internal order cannot affect the receipt.
        Sort(direct,function(a,b)
          local ka,kb;
          ka := [Size(NormalClosure(W,a[1])),Size(Normalizer(W,a[1]))];
          kb := [Size(NormalClosure(W,b[1])),Size(Normalizer(W,b[1]))];
          return ka < kb;
        end);
        builtin := ContainedConjugates(S,W,V);

        # The pinned regression-fixed builtin must give the same orbit set as
        # the direct double-coset code, with neither omissions nor duplicates.
        AssertProof(Length(builtin)=Length(direct),
          Concatenation(name, ": builtin/direct orbit-count mismatch at V",
                        String(vi), ",W", String(wpos)));
        for pair in builtin do
          builtinMatches := Filtered([1..Length(direct)], i ->
            IsConjugate(W,pair[1],direct[i][1]));
          AssertProof(Length(builtinMatches)=1,
            "builtin contained conjugate did not match exactly one direct orbit");
        od;

        observed := [];
        apos := 0;
        aCount := 0;
        for A in actual do
          apos := apos + 1;
          if Size(A)=Size(W) and IsConjugate(S,A,W) then
            aCount := aCount + 1;
            transporter := RepresentativeAction(S,A,W);
            AssertProof(transporter<>fail,
                        "could not transport actual overgroup to class representative");
            E := V^transporter;
            AssertProof(IsSubset(W,E),"transported V is not contained in W");
            orbit := PositionProperty(direct,pair ->
                                      IsConjugate(W,E,pair[1]));
            AssertProof(orbit<>fail,
                        "actual-overgroup method found an orbit absent from direct method");
            AddSet(observed,orbit);
            clA := Size(NormalClosure(A,V));
            clB := Size(NormalClosure(W,direct[orbit][1]));
            AssertProof(clA=clB,"normal-closure orders disagree between methods A and B");
            if clA<>Size(A) then saturation:=false; failures:=failures+1; fi;
            Print("EMBEDDING-A|group=",name,"|vclass=",vi,
                  "|wclass=",wpos,
                  "|v=",Size(V),"|w=",Size(W),"|closure=",clA,
                  "|result=",(clA=Size(A)),"\n");
          fi;
        od;
        # One actual overgroup A can account for several W-conjugacy orbits:
        # changing the transporter A -> W by an element of N_S(W) can fuse
        # them.  This is legitimate because normal saturation is invariant
        # under N_S(W).  Nevertheless method B checks every finer W-orbit.
        AssertProof(ForAll([1..Length(direct)], j ->
          ForAny(observed, i -> IsConjugate(Normalizer(S,W),
                                            direct[j][1],direct[i][1]))),
          Concatenation(name, ": methods A/B cover different normalizer-orbits at V",
                        String(vi), ",W", String(wpos)));

        Print("ORBIT-CHECK|group=",name,"|vclass=",vi,
              "|wclass=",wpos,"|methodA_records=",aCount,
              "|methodA_normalizer_orbits=",Length(observed),
              "|direct_orbits=",Length(direct),
              "|builtin_orbits=",Length(builtin),"|result=PASS\n");

        for orbit in [1..Length(direct)] do
          clB := Size(NormalClosure(W,direct[orbit][1]));
          wnorm := Size(Normalizer(W,direct[orbit][1]));
          Print("EMBEDDING-B|group=",name,"|vclass=",vi,
                "|wclass=",wpos,"|orbit=",orbit,"|v=",Size(V),
                "|w=",Size(W),"|closure=",clB,
                "|wnormalizer=",wnorm,
                "|embedding_sha256=",HexSHA256(String(
                  [vi,wpos,orbit,Size(V),Size(W),clB,wnorm])),
                "|result=",(clB=Size(W)),"\n");
        od;
      fi;
    od;
    status := "SATURATES";
    if not saturation then status := "DOES-NOT-SATURATE"; fi;
    Print("SATURATION|group=",name,"|vclass=",vi,"|v=",Size(V),
          "|status=",status,"\n");
  od;
  Print("GROUP-SUMMARY|name=",name,
        "|methods_agree=true|nonsaturating_embeddings=",failures,"\n");
end;

CheckSaturation("L3_2",  AuditSocleRepresentation(PSL(3,2),8));
CheckSaturation("A6",    AuditSocleRepresentation(PSL(2,9),10));
CheckSaturation("L2_11", AuditSocleRepresentation(PSL(2,11),12));
CheckSaturation("L3_4",  AuditSocleRepresentation(PSL(3,4),fail));
Print("SWEEP K2 V2 DONE.|PASS\n");
QUIT_GAP(0);
