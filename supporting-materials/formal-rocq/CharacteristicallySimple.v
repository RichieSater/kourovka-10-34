From mathcomp Require Import boot finite_group solvable.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

(** A finite, characteristically simple, nonsolvable group is an internal
    direct product of a positive number of automorphic copies of one
    nonsolvable, explicitly nonabelian simple subgroup.  The internal
    direct-product identity is the
    MathComp encoding of the manuscript's [N = S^k]; it is stronger than an
    order-only assertion. *)
Lemma nonsolvable_charsimple_dprod (gT : finGroupType) (G : {group gT}) :
  charsimple G -> ~~ solvable G ->
  exists H : {group gT},
    [/\ H \subset G, simple H, ~~ solvable H, ~~ abelian H
      & exists I : {set {perm gT}},
          [/\ I \subset Aut G,
              \big[dprod/1%g]_(f in I) f @: H = G,
              #|G| = #|H| ^ #|I|
            & 0 < #|I|]].
Proof.
move=> chG nsolG.
case: (charsimple_dprod chG) => H [sHG simH [I Aut_I defG]].
have nsolH : ~~ solvable H.
  apply/negP=> solH.
  have cHH : abelian H :=
    cyclic_abelian (prime_cyclic (simple_sol_prime solH simH)).
  have solG : solvable G.
    apply: abelian_sol.
    elim/big_rec: _ (G) defG => [_ <-|f B If IH_B M defM].
    - exact: abelian1.
    - have Af := subsetP Aut_I f If.
      have [groupsAB defProd cBA _] := dprodP defM.
      case: groupsAB => K L defA defB.
      rewrite -defProd defA defB abelianM.
      apply/and3P; split.
      + rewrite -defA -(autmE Af) -morphimEsub //.
        exact: morphim_abelian cHH.
      + exact: IH_B L defB.
      + by rewrite defA defB in cBA.
  by move/negP: nsolG; apply.
have nabH : ~~ abelian H.
  exact: contra (@abelian_sol gT H) nsolH.
have card_image (f : {perm gT}) : #|f @: H| = #|H| :=
  card_imset H (@perm_inj _ f).
have cardG : #|G| = #|H| ^ #|I|.
  rewrite -(bigdprod_card defG).
  transitivity (\prod_(f in I) #|H|).
  - apply: eq_bigr => f _; exact: card_image f.
  - exact: prod_nat_const.
have posI : 0 < #|I|.
  rewrite card_gt0; apply/eqP=> I0.
  have cardG1 : #|G| = 1 by rewrite cardG I0 cards0 expn0.
  have G1 := card1_trivg cardG1.
  move/negP: nsolG; apply; rewrite G1; exact: solvable1.
by exists H; split=> //; exists I; split.
Qed.

(** A factorwise isomorphism between two finite internal direct products
    induces an isomorphism between the products. *)
Lemma bigdprod_isog_family
    (gT hT : finGroupType) (I : eqType) (r : seq I) (P : pred I)
    (A : I -> {group gT}) (B : I -> {group hT})
    (G : {group gT}) (L : {group hT}) :
  \big[dprod/1%g]_(i <- r | P i) A i = G ->
  \big[dprod/1%g]_(i <- r | P i) B i = L ->
  (forall i, i \in r -> P i -> A i \isog B i) -> G \isog L.
Proof.
elim: r G L => [|i r IHr] G L.
  rewrite !big_nil; move=> <- <- _; apply: trivial_isog => //.
rewrite !big_cons; case Pi: (P i) => /=.
  move=> defG defL isoAB.
  have [[Ai H -> defH] _ _ _] := dprodP defG.
  have [[Bi K -> defK] _ _ _] := dprodP defL.
  apply: (isog_dprod defG defL).
    exact: isoAB i (mem_head i r) Pi.
  rewrite defH defK.
  apply: (IHr H K defH defK) => j jr Pj.
  have jir : j \in i :: r by rewrite in_cons jr orbT.
  exact: isoAB j jir Pj.
move=> defG defL isoAB.
apply: (IHr G L defG defL) => j jr Pj.
have jir : j \in i :: r by rewrite in_cons jr orbT.
exact: isoAB j jir Pj.
Qed.

(** An internal direct product of automorphic copies of [H] is isomorphic to
    the explicit coordinate-indexed external product of copies of [H]. *)
Lemma internal_bigdprod_isog_power
    (gT : finGroupType) (G H : {group gT})
    (I : {set {perm gT}}) :
  H \subset G -> I \subset Aut G ->
  \big[dprod/1%g]_(f in I) f @: H = G ->
  G \isog setXn (fun _ : {f | f \in I} => H).
Proof.
move=> sHG Aut_I defG.
pose Af (u : {f | f \in I}) : val u \in Aut G :=
  subsetP Aut_I (val u) (valP u).
pose Au (u : {f | f \in I}) : {group gT} :=
  (autm (Af u) @* H)%G.
have AuE (u : {f | f \in I}) : (Au u : {set gT}) = (val u) @: H.
  rewrite /Au.
  apply: (etrans (@morphimEsub gT gT G (autm (Af u)) H sHG)).
  by rewrite (autmE (Af u)).
have defA : \big[dprod/1%g]_(u : {f | f \in I}) Au u = G.
  apply: (etrans _ defG).
  apply: (etrans _ (esym (big_sub I (fun f => f @: H)))).
  apply: eq_bigr => u _.
  exact: AuE u.
have defX := setXn_dprod (fun _ : {f | f \in I} => H).
refine (@bigdprod_isog_family
  gT
  (@finfun_dfinfun_of__canonical__fingroup_FinGroup
    {f | f \in I} (fun _ => gT))
  {f | f \in I}
  _
  _
  Au
  (fun u : {f | f \in I} => @groupXn1 {f | f \in I} (fun _ => gT) u H)
  G
  (setXn (fun _ : {f | f \in I} => H))
  _ _ _).
- exact: defA.
- exact: defX.
- move=> u _ _.
  have isoHAu : H \isog Au u.
    rewrite /Au.
    exact: sub_isog sHG (injm_autm (Af u)).
  apply: (isog_trans (isog_symr isoHAu)).
  exact: isog_setXn.
Qed.

(** Exact coordinate form of the characteristically-simple decomposition,
    retaining explicit nonabelianness of the simple factor.
    The index type is the finite subtype of the automorphism set [I], hence
    has cardinality [#|I|].  Thus the conclusion supplies the external
    coordinate product consumed by the ambient-wreath formalization, rather
    than leaving an informal internal-product-to-coordinate conversion. *)
Lemma nonsolvable_charsimple_explicit_power
    (gT : finGroupType) (G : {group gT}) :
  charsimple G -> ~~ solvable G ->
  exists H : {group gT},
    [/\ H \subset G, simple H, ~~ solvable H, ~~ abelian H
      & exists I : {set {perm gT}},
          [/\ I \subset Aut G,
              \big[dprod/1%g]_(f in I) f @: H = G,
              G \isog setXn (fun _ : {f | f \in I} => H),
              #|G| = #|H| ^ #|I|
            & 0 < #|I|]].
Proof.
move=> chG nsolG.
have [H [sHG simH nsolH nabH [I [Aut_I defG cardG posI]]]] :=
  nonsolvable_charsimple_dprod chG nsolG.
have isoG := internal_bigdprod_isog_power sHG Aut_I defG.
by exists H; split=> //; exists I; split.
Qed.

Print Assumptions nonsolvable_charsimple_dprod.
Print Assumptions bigdprod_isog_family.
Print Assumptions internal_bigdprod_isog_power.
Print Assumptions nonsolvable_charsimple_explicit_power.
