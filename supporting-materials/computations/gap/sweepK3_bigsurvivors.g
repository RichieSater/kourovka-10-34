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

Read("sweepK_lib.g");

# ---------- O(5,4) = PSp(4,4), X = full Aut (x = 4) ----------
# Survivor because the graph automorphism fuses the two parabolic classes;
# the only X-stable maximal classes give no obstruction.  Candidate pair:
# the Borel subgroup (= normalizer of a Sylow 2-subgroup; its overgroups
# are the two parabolics, fused by X, hence X-unstable) and the subfield
# subgroup Sp(4,2) (= centralizer of the field involution; maximal in S).
CertO54 := function()
  local f4, Sm, Tm2, conv, Tm, isoS, S0, T0, A, I, isoA, TI,
        S, P, hom, Xgens, B, sub;
  # Construct the subfield subgroup from first principles rather than finding
  # a coset element.  Embed the standard Sp(4,2) matrices entrywise in
  # Sp(4,4), transport them through the same two explicit isomorphisms as the
  # socle, and then let the full abstract automorphism group supply the graph
  # and field actions.  No random search, arbitrary coset representative, or
  # representation-dependent element hash lies on this path.
  f4 := GF(4);
  Sm := Sp(4,f4);
  Tm2 := Sp(4,GF(2));
  conv := m -> ImmutableMatrix(f4,
    List(m,row -> List(row,z -> IntFFE(z)*One(f4))));
  Tm := Group(List(GeneratorsOfGroup(Tm2),conv));
  AssertProof(Size(Sm)=979200 and Size(Tm)=720 and IsSubgroup(Sm,Tm),
              "standard GF(2)-subfield embedding in Sp(4,4) failed");
  isoS := IsomorphismPermGroup(Sm);
  S0 := Image(isoS);
  T0 := Image(isoS,Tm);
  AssertProof(Size(Normalizer(S0,T0))=720,
              "GF(2)-subfield subgroup is not self-normalizing");

  A := AutomorphismGroup(S0);
  I := InnerAutomorphismsAutomorphismGroup(A);
  isoA := IsomorphismPermGroup(A);
  P := Image(isoA);
  S := Image(isoA,I);
  TI := Group(List(GeneratorsOfGroup(T0),
                   t -> InnerAutomorphism(S0,t)));
  AssertProof(IsSubgroup(I,TI) and Size(TI)=720,
              "inner-automorphism transport of Sp(4,2) failed");
  sub := Image(isoA,TI);
  AssertProof(Size(P)=4*Size(S),"AutPerm O54 failed");
  AssertProof(IsSimpleGroup(S) and IsNormal(P,S) and Size(Centralizer(P,S))=1,
              "O(5,4) automorphism representation failed validation");
  AssertProof(S=PerfectResiduum(P),"O(5,4) residual is not the transported socle");
  hom := NaturalHomomorphismByNormalSubgroup(P, S);
  Xgens := List(GeneratorsOfGroup(Image(hom)),
                q -> PreImagesRepresentative(hom, q));
  # Borel
  B := Normalizer(S, SylowSubgroup(S, 2));
  AssertProof(Size(B)=2304 and Size(sub)=720 and IsSubgroup(S,sub),
              "O(5,4) constructed witness orders are wrong");
  Print("SOCLE|group=O(5,4)|",GroupFingerprint(S),"|P=",Size(P),
        "|out=4|faithful=true|simple=true\n");
  Print("WITNESS|group=O(5,4)|construction=GF2-subfield-matrices",
        "|subfield=",Size(sub),"|normalizer=",Size(Normalizer(S,sub)),
        "|result=PASS\n");
  return CertifyPair("O(5,4)", S, Xgens, 4, B, sub, "Borel", "Sp(4,2)");
end;

AssertProof(CertO54(),"O(5,4) certification returned false");
Print("O(5,4): ALL k >= 2 EXCLUDED FOR ALL X (novelty pair certified).\n");
Print("SWEEP K3 (current survivor list) DONE.|PASS\n");
QUIT_GAP(0);
