import Kourovka1034.Property
import Mathlib.Algebra.Group.Subgroup.Finite
import Mathlib.GroupTheory.Coset.Card
import Mathlib.GroupTheory.Index
import Mathlib.GroupTheory.Solvable
import Mathlib.GroupTheory.Subgroup.Centralizer
import Mathlib.Order.Preorder.Finite

/-!
# Minimal-counterexample reduction

This module checks the minimal-order and elementary finite-group part of
Manuscript label `prop:min`: every nontrivial proper quotient is soluble, there is a unique
minimal normal subgroup, that subgroup and the ambient group are nonsoluble,
and its centralizer is trivial.  The direct-power description is checked in
the separate Rocq project, and `AmbientWreath.lean` checks the transitive
wreath-coordinate realization from an explicit direct-power equivalence.  The
strengthened Rocq explicit-product theorem and the finite-index reindexing in
`DirectPower.lean` close the exact `RED-COORD` interface between them.
-/

namespace Kourovka1034

/-- A least counterexample cannot have a smaller counterexample. -/
theorem no_smaller_counterexample
    (bad : ℕ → Prop) (n : ℕ)
    (least : bad n ∧ ∀ m, bad m → n ≤ m) :
    ∀ m < n, ¬ bad m := by
  intro m hm hbad
  exact (Nat.not_le_of_lt hm) (least.2 m hbad)

/-- Two different values cannot both be the unique witness to a predicate. -/
theorem unique_witnesses_equal
    {α : Type} {P : α → Prop} {a b : α}
    (_ha : P a) (hua : ∀ x, P x → x = a) (hb : P b) : a = b := by
  exact (hua b hb).symm


/-- A nontrivial normal subgroup minimal by inclusion. -/
def IsMinimalNormal {G : Type*} [Group G] (N : Subgroup G) : Prop :=
  N.Normal ∧ N ≠ ⊥ ∧ ∀ K : Subgroup G, K.Normal → K ≤ N → K = ⊥ ∨ K = N

/-- A group with no proper nontrivial characteristic subgroup.  Mathlib does
not currently bundle this standard finite-group notion. -/
def IsCharacteristicallySimple (H : Type*) [Group H] : Prop :=
  Nontrivial H ∧
    ∀ K : Subgroup H, K.Characteristic → K = ⊥ ∨ K = ⊤

theorem proper_quotient_solvable_of_least_counterexample
    {G : Type u} [Group G] [Finite G]
    (hP : PropertyP G)
    (hleast : ∀ (H : Type u) [Group H] [Finite H],
      PropertyP H → ¬ IsSolvable H → Nat.card G ≤ Nat.card H)
    (N : Subgroup G) [N.Normal] (hN : N ≠ ⊥) :
    IsSolvable (G ⧸ N) := by
  by_contra hnot
  have hle := hleast (G ⧸ N) (propertyP_quotient N hP) hnot
  have hlt : Nat.card (G ⧸ N) < Nat.card G := by
    rw [← Subgroup.index_eq_card, ← N.index_mul_card]
    exact lt_mul_of_one_lt_right
      (Nat.pos_of_ne_zero Subgroup.index_ne_zero_of_finite)
      (N.one_lt_card_iff_ne_bot.mpr hN)
  exact (Nat.not_le_of_lt hlt) hle

theorem solvable_of_solvable_normal_and_quotient
    {G : Type*} [Group G]
    (N : Subgroup G) [N.Normal]
    (hN : IsSolvable N) (hQ : IsSolvable (G ⧸ N)) : IsSolvable G := by
  letI : IsSolvable N := hN
  letI : IsSolvable (G ⧸ N) := hQ
  apply solvable_of_ker_le_range N.subtype (QuotientGroup.mk' N)
  rw [QuotientGroup.ker_mk', Subgroup.range_subtype]

theorem no_nontrivial_solvable_normal_of_proper_quotients
    {G : Type*} [Group G]
    (hG : ¬ IsSolvable G)
    (hquot : ∀ (N : Subgroup G) [N.Normal], N ≠ ⊥ → IsSolvable (G ⧸ N)) :
    ∀ (N : Subgroup G) [N.Normal], N ≠ ⊥ → ¬ IsSolvable N := by
  intro N _ hN hsolvN
  exact hG (solvable_of_solvable_normal_and_quotient N hsolvN (hquot N hN))

theorem exists_minimalNormal
    {G : Type*} [Group G] [Finite G] [Nontrivial G] :
    ∃ N : Subgroup G, IsMinimalNormal N := by
  letI : Finite (Subgroup G) :=
    Finite.of_injective (fun H : Subgroup G => (H : Set G)) SetLike.coe_injective
  let P : Subgroup G → Prop := fun N => N.Normal ∧ N ≠ ⊥
  have hPnonempty : Set.Nonempty {N : Subgroup G | P N} := by
    refine ⟨⊤, inferInstance, top_ne_bot⟩
  obtain ⟨N, hNP, hNmin⟩ :=
    Set.toFinite {N : Subgroup G | P N} |>.exists_minimal hPnonempty
  refine ⟨N, hNP.1, hNP.2, ?_⟩
  intro K hKnormal hKN
  by_cases hKbot : K = ⊥
  · exact Or.inl hKbot
  · right
    exact le_antisymm hKN (hNmin ⟨hKnormal, hKbot⟩ hKN)

theorem exists_minimalNormal_le
    {G : Type*} [Group G] [Finite G]
    (C : Subgroup G) [C.Normal] (hC : C ≠ ⊥) :
    ∃ N : Subgroup G, IsMinimalNormal N ∧ N ≤ C := by
  letI : Finite (Subgroup G) :=
    Finite.of_injective (fun H : Subgroup G => (H : Set G)) SetLike.coe_injective
  let P : Subgroup G → Prop := fun N => N.Normal ∧ N ≠ ⊥ ∧ N ≤ C
  have hPnonempty : Set.Nonempty {N : Subgroup G | P N} :=
    ⟨C, inferInstance, hC, le_rfl⟩
  obtain ⟨N, hNP, hNmin⟩ :=
    Set.toFinite {N : Subgroup G | P N} |>.exists_minimal hPnonempty
  refine ⟨N, ⟨hNP.1, hNP.2.1, ?_⟩, hNP.2.2⟩
  intro K hKnormal hKN
  by_cases hKbot : K = ⊥
  · exact Or.inl hKbot
  · right
    exact le_antisymm hKN
      (hNmin ⟨hKnormal, hKbot, hKN.trans hNP.2.2⟩ hKN)

theorem minimalNormal_inter_eq_bot
    {G : Type*} [Group G]
    {N M : Subgroup G} (hN : IsMinimalNormal N) (hM : IsMinimalNormal M)
    (hne : N ≠ M) : N ⊓ M = ⊥ := by
  haveI : N.Normal := hN.1
  haveI : M.Normal := hM.1
  rcases hN.2.2 (N ⊓ M) inferInstance inf_le_left with hbot | heq
  · exact hbot
  · have hNM : N ≤ M := by
      rw [← heq]
      exact inf_le_right
    rcases hM.2.2 N hN.1 hNM with hNbot | hNM'
    · exact False.elim (hN.2.1 hNbot)
    · exact False.elim (hne hNM')

theorem minimalNormal_unique_of_no_solvable_normal
    {G : Type*} [Group G]
    (hquot : ∀ (N : Subgroup G) [N.Normal], N ≠ ⊥ → IsSolvable (G ⧸ N))
    (hnosolv : ∀ (N : Subgroup G) [N.Normal], N ≠ ⊥ → ¬ IsSolvable N)
    {N M : Subgroup G} (hN : IsMinimalNormal N) (hM : IsMinimalNormal M) :
    N = M := by
  by_contra hne
  have hinter : N ⊓ M = ⊥ := minimalNormal_inter_eq_bot hN hM hne
  letI : N.Normal := hN.1
  letI : M.Normal := hM.1
  let f : M →* G ⧸ N := (QuotientGroup.mk' N).comp M.subtype
  have hker : f.ker = ⊥ := by
    ext m
    rw [MonoidHom.mem_ker, Subgroup.mem_bot]
    constructor
    · intro hm
      have hmN : (m : G) ∈ N := by
        change ((m : G) : G ⧸ N) = 1 at hm
        exact (QuotientGroup.eq_one_iff (m : G)).mp hm
      have hmI : (m : G) ∈ N ⊓ M := ⟨hmN, m.property⟩
      rw [hinter] at hmI
      exact Subtype.ext (Subgroup.mem_bot.mp hmI)
    · rintro rfl
      simp [f]
  have hf : Function.Injective f := f.ker_eq_bot_iff.mp hker
  letI : IsSolvable (G ⧸ N) := hquot N hN.2.1
  have hMsolv : IsSolvable M := solvable_of_solvable_injective hf
  exact hnosolv M hM.2.1 hMsolv

/-- Every minimal normal subgroup is characteristically simple.  This is the
kernel-checked bridge from the ambient minimality statement to the standard
finite characteristically-simple direct-power theorem. -/
theorem minimalNormal_isCharacteristicallySimple
    {G : Type*} [Group G]
    {N : Subgroup G} (hN : IsMinimalNormal N) :
    IsCharacteristicallySimple N := by
  letI : N.Normal := hN.1
  refine ⟨not_subsingleton_iff_nontrivial.mp ?_, ?_⟩
  · intro hsub
    exact hN.2.1 (Subgroup.eq_bot_of_subsingleton N)
  · intro K hK
    letI : K.Characteristic := hK
    have hmap_normal : (K.map N.subtype).Normal := inferInstance
    rcases hN.2.2 (K.map N.subtype) hmap_normal
        (K.map_le_range N.subtype |>.trans_eq N.range_subtype) with hbot | htop
    · left
      rw [← Subgroup.map_subtype_inj, Subgroup.map_bot]
      exact hbot
    · right
      rw [← Subgroup.map_subtype_inj]
      rw [← MonoidHom.range_eq_map, N.range_subtype]
      exact htop

theorem centralizer_minimalNormal_eq_bot
    {G : Type*} [Group G] [Finite G]
    (hnosolv : ∀ (K : Subgroup G) [K.Normal], K ≠ ⊥ → ¬ IsSolvable K)
    {N : Subgroup G} (hN : IsMinimalNormal N)
    (hunique : ∀ M : Subgroup G, IsMinimalNormal M → M = N) :
    Subgroup.centralizer (N : Set G) = ⊥ := by
  letI : N.Normal := hN.1
  let C : Subgroup G := Subgroup.centralizer (N : Set G)
  let K : Subgroup G := N ⊓ C
  have hKcomm : ∀ a b : K, a * b = b * a := by
    intro a b
    apply Subtype.ext
    exact ((Subgroup.mem_centralizer_iff.mp a.property.2) (b : G) b.property.1).symm
  have hKsolv : IsSolvable K := isSolvable_of_comm hKcomm
  have hKbot : K = ⊥ := by
    by_contra hKne
    exact hnosolv K hKne hKsolv
  by_contra hCne
  have hCne' : C ≠ ⊥ := hCne
  obtain ⟨M, hM, hMC⟩ := exists_minimalNormal_le C hCne'
  have hMN : M = N := hunique M hM
  have hNC : N ≤ C := by simpa [hMN] using hMC
  have hNK : N ≤ K := le_inf le_rfl hNC
  have : N = ⊥ := le_bot_iff.mp (hNK.trans_eq hKbot)
  exact hN.2.1 this

/-- The kernel of the conjugation action on a normal subgroup is exactly its
ambient centralizer.  Keeping this identity explicit prevents the later
wreath realization from silently assuming faithfulness. -/
theorem conjNormal_ker_eq_centralizer
    {G : Type*} [Group G]
    (N : Subgroup G) [N.Normal] :
    (MulAut.conjNormal : G →* MulAut N).ker =
      Subgroup.centralizer (N : Set G) := by
  ext g
  rw [MonoidHom.mem_ker, Subgroup.mem_centralizer_iff]
  constructor
  · intro hg n hn
    have heq : MulAut.conjNormal g = 1 := hg
    have ha := congrArg (fun f : MulAut N => f ⟨n, hn⟩) heq
    have ha' : g * n * g⁻¹ = n := by
      simpa using congrArg Subtype.val ha
    have hgn : g * n = n * g := (mul_inv_eq_iff_eq_mul).mp ha'
    exact hgn.symm
  · intro hg
    apply MulEquiv.ext
    intro n
    apply Subtype.ext
    change g * (n : G) * g⁻¹ = (n : G)
    rw [← hg (n : G) n.property]
    simp

/-- A self-centralizing normal subgroup gives a faithful conjugation
homomorphism into its automorphism group. -/
theorem conjNormal_injective_of_centralizer_eq_bot
    {G : Type*} [Group G]
    (N : Subgroup G) [N.Normal]
    (hcentralizer : Subgroup.centralizer (N : Set G) = ⊥) :
    Function.Injective (MulAut.conjNormal : G →* MulAut N) := by
  apply (MonoidHom.ker_eq_bot_iff _).mp
  rw [conjNormal_ker_eq_centralizer N, hcentralizer]

/-- Exact minimal-counterexample core through uniqueness of the minimal normal
subgroup.  The direct-power structure and wreath embedding are intentionally
left to the separate coordinate-reduction theorem. -/
theorem minimal_counterexample_unique_minimal_normal
    {G : Type u} [Group G] [Finite G]
    (hP : PropertyP G) (hG : ¬ IsSolvable G)
    (hleast : ∀ (H : Type u) [Group H] [Finite H],
      PropertyP H → ¬ IsSolvable H → Nat.card G ≤ Nat.card H) :
    ∃ N : Subgroup G, ∃ hnormal : N.Normal,
      IsMinimalNormal N ∧
      IsCharacteristicallySimple N ∧
      @IsSolvable (G ⧸ N)
        (@QuotientGroup.Quotient.group G _ N hnormal) ∧
      (∀ (K : Subgroup G) [K.Normal], K ≠ ⊥ → ¬ IsSolvable K) ∧
      ¬ IsSolvable N ∧
      Subgroup.centralizer (N : Set G) = ⊥ ∧
      Function.Injective (@MulAut.conjNormal G _ N hnormal) ∧
      ∀ M : Subgroup G, IsMinimalNormal M → M = N := by
  have hnsub : ¬ Subsingleton G := by
    intro hsub
    letI : Subsingleton G := hsub
    exact hG (inferInstance : IsSolvable G)
  letI : Nontrivial G := not_subsingleton_iff_nontrivial.mp hnsub
  let hquot : ∀ (K : Subgroup G) [K.Normal], K ≠ ⊥ →
      IsSolvable (G ⧸ K) := fun K _ =>
    proper_quotient_solvable_of_least_counterexample hP hleast K
  let hnosolv : ∀ (K : Subgroup G) [K.Normal], K ≠ ⊥ →
      ¬ IsSolvable K :=
    no_nontrivial_solvable_normal_of_proper_quotients hG hquot
  obtain ⟨N, hN⟩ := exists_minimalNormal (G := G)
  letI : N.Normal := hN.1
  have hunique : ∀ M : Subgroup G, IsMinimalNormal M → M = N := by
    intro M hM
    exact minimalNormal_unique_of_no_solvable_normal hquot hnosolv hM hN
  have hcentralizer : Subgroup.centralizer (N : Set G) = ⊥ :=
    centralizer_minimalNormal_eq_bot hnosolv hN hunique
  have hfaithful :
      Function.Injective (@MulAut.conjNormal G _ N hN.1) :=
    conjNormal_injective_of_centralizer_eq_bot N hcentralizer
  refine ⟨N, hN.1, hN, minimalNormal_isCharacteristicallySimple hN,
    hquot N hN.2.1, hnosolv,
    hnosolv N hN.2.1, hcentralizer, hfaithful, hunique⟩
end Kourovka1034
