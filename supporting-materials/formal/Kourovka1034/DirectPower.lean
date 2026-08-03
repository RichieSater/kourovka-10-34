import Kourovka1034.CoordinateReduction
import Mathlib.Algebra.Group.Subgroup.Map
import Mathlib.GroupTheory.Commutator.Basic
import Mathlib.GroupTheory.Subgroup.Center

/-!
# Automorphisms of a finite direct power: coordinate factors

This file supplies the Lean side of `RED-COORD` rather than postulating a
wreath realization.  It first kernel-checks reindexing any finite external
coordinate product to `Fin k`.  For a finite direct power of a nonabelian
simple group, every automorphism carries each coordinate factor to a unique
coordinate factor.  The proof is elementary: coordinate factors are simple
and normal; if an automorphic image had trivial intersection with a coordinate
on which one of its elements is nontrivial, the two normal subgroups would
commute, forcing that nontrivial coordinate into the (trivial) center.
-/

namespace Kourovka1034
namespace DirectPower

variable {S I : Type*} [Group S] [DecidableEq I]

/-- Reindex a constant direct power along an equivalence of coordinate
types.  This is the kernel-checked finite-index conversion used at the
Rocq/Lean interface: an external product over any finite factor index is the
same direct power as one indexed by `Fin` of its cardinality. -/
def reindexPower {J : Type*} (e : I ≃ J) :
    (I → S) ≃* (J → S) where
  toFun x j := x (e.symm j)
  invFun y i := y (e i)
  left_inv x := by
    funext i
    simp
  right_inv y := by
    funext j
    simp
  map_mul' x y := by
    funext j
    rfl

/-- Canonical conversion from a direct power indexed by an arbitrary finite
type to the manuscript's `Fin k` convention, with `k = Nat.card I`. -/
noncomputable def reindexPowerFin [Finite I] :
    (I → S) ≃* (Fin (Nat.card I) → S) :=
  reindexPower (S := S) (Finite.equivFin I)

/-- Compose any explicit external-power equivalence with the canonical finite
reindexing.  This is the precise Lean endpoint of `RED-COORD`. -/
noncomputable def explicitPowerEquivFin {N : Type*} [Group N] [Finite I]
    (e : N ≃* (I → S)) :
    N ≃* (Fin (Nat.card I) → S) :=
  e.trans (reindexPowerFin (S := S) (I := I))

omit [DecidableEq I] in
/-- Existential form used by the formal interface audit.  A coordinate
isomorphism over an arbitrary finite factor type supplies exactly the
`Fin k`-indexed `MulEquiv` expected by `AmbientWreath`, with
`k = Nat.card I`. -/
theorem explicitPowerEquivFin_nonempty {N : Type*} [Group N] [Finite I]
    (e : N ≃* (I → S)) :
    Nonempty (N ≃* (Fin (Nat.card I) → S)) :=
  ⟨explicitPowerEquivFin (S := S) e⟩

omit [DecidableEq I] in
/-- Strengthened interface form: a positive factor type supplies both the
standard-coordinate equivalence and the base coordinate required by the
ambient-wreath theorem. -/
theorem explicitPowerEquivFin_with_base {N : Type*} [Group N] [Finite I]
    [Nonempty I] (e : N ≃* (I → S)) :
    Nonempty (Fin (Nat.card I)) ∧
      Nonempty (N ≃* (Fin (Nat.card I) → S)) := by
  constructor
  · exact ⟨Finite.equivFin I (Classical.choice inferInstance)⟩
  · exact explicitPowerEquivFin_nonempty (S := S) e

/-- The copy of `S` supported at coordinate `i` in the direct power `I -> S`. -/
noncomputable def coordinate (i : I) : Subgroup (I → S) := by
  classical
  exact (⊤ : Subgroup S).map (MonoidHom.mulSingle (fun _ : I => S) i)

theorem mem_coordinate_iff (i : I) (x : I → S) :
    x ∈ coordinate (S := S) i ↔ ∃ s : S, Pi.mulSingle i s = x := by
  classical
  simp [coordinate, Subgroup.mem_map]

/-- The canonical equivalence between `S` and one coordinate factor. -/
noncomputable def coordinateEquiv (i : I) :
    S ≃* coordinate (S := S) i := by
  classical
  refine
    { toFun := fun s =>
        ⟨Pi.mulSingle i s, (mem_coordinate_iff (S := S) i _).2 ⟨s, rfl⟩⟩
      invFun := fun x => (x : I → S) i
      left_inv := fun s => by simp
      right_inv := fun x => by
        apply Subtype.ext
        rcases (mem_coordinate_iff (S := S) i x).1 x.property with ⟨s, hs⟩
        have hxi : (x : I → S) i = s := by
          simpa using (congrFun hs i).symm
        exact (congrArg (Pi.mulSingle i) hxi).trans hs
      map_mul' := fun x y => by
        apply Subtype.ext
        exact Pi.mulSingle_mul (f := fun _ : I => S) i x y }

instance coordinate_normal (i : I) : (coordinate (S := S) i).Normal := by
  classical
  constructor
  intro n hn g
  rcases (mem_coordinate_iff (S := S) i n).1 hn with ⟨s, rfl⟩
  apply (mem_coordinate_iff (S := S) i _).2
  refine ⟨g i * s * (g i)⁻¹, ?_⟩
  ext j
  by_cases hji : j = i
  · subst j
    simp
  · simp [Pi.mulSingle, hji]

instance coordinate_simple [IsSimpleGroup S] (i : I) :
    IsSimpleGroup (coordinate (S := S) i) :=
  (coordinateEquiv (S := S) i).symm.isSimpleGroup

/-- Distinct indices give distinct coordinate factors. -/
theorem coordinate_injective [Nontrivial S] :
    Function.Injective (coordinate (S := S) : I → Subgroup (I → S)) := by
  classical
  intro i j hij
  by_contra hne
  obtain ⟨s, hs⟩ := exists_ne (1 : S)
  have hmem : Pi.mulSingle i s ∈ coordinate (S := S) j := by
    rw [← hij]
    exact (mem_coordinate_iff (S := S) i _).2 ⟨s, rfl⟩
  rcases (mem_coordinate_iff (S := S) j _).1 hmem with ⟨t, ht⟩
  have hti := congrFun ht i
  simp [Pi.mulSingle, hne] at hti
  exact hs hti.symm

/-- The center of a nonabelian simple group is trivial. -/
theorem center_eq_bot_of_not_isMulCommutative [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) : Subgroup.center S = ⊥ := by
  rcases (inferInstance : (Subgroup.center S).Normal).eq_bot_or_eq_top with h | h
  · exact h
  · exact False.elim (hncomm (Subgroup.center_eq_top_iff.mp h))

/-- The image of a coordinate factor under an automorphism of the direct
power. -/
noncomputable def imageCoordinate (a : MulAut (I → S)) (i : I) :
    Subgroup (I → S) :=
  (coordinate (S := S) i).map a.toMonoidHom

instance imageCoordinate_normal (a : MulAut (I → S)) (i : I) :
    (imageCoordinate (S := S) a i).Normal :=
  (inferInstance : (coordinate (S := S) i).Normal).map
    a.toMonoidHom a.surjective

instance imageCoordinate_simple [IsSimpleGroup S]
    (a : MulAut (I → S)) (i : I) :
    IsSimpleGroup (imageCoordinate (S := S) a i) :=
  (a.subgroupMap (coordinate (S := S) i)).symm.isSimpleGroup

theorem card_coordinate [Finite S] (i : I) :
    Nat.card (coordinate (S := S) i) = Nat.card S := by
  exact Nat.card_congr (coordinateEquiv (S := S) i).toEquiv |>.symm

theorem card_imageCoordinate [Finite S] [Finite I]
    (a : MulAut (I → S)) (i : I) :
    Nat.card (imageCoordinate (S := S) a i) = Nat.card S := by
  rw [imageCoordinate]
  exact (Subgroup.card_mapSubgroup (H := coordinate (S := S) i) a).trans
    (card_coordinate (S := S) i)

/-- Every automorphism of a finite direct power of a nonabelian simple group
maps a coordinate factor onto some coordinate factor. -/
theorem exists_imageCoordinate_eq_coordinate
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) :
    ∃ j : I, imageCoordinate (S := S) a i = coordinate (S := S) j := by
  classical
  let H := imageCoordinate (S := S) a i
  obtain ⟨s, hs⟩ := exists_ne (1 : S)
  let z : I → S := a (Pi.mulSingle i s)
  have hzH : z ∈ H := by
    refine ⟨Pi.mulSingle i s,
      (mem_coordinate_iff (S := S) i _).2 ⟨s, rfl⟩, rfl⟩
  have hz_ne : z ≠ 1 := by
    intro hz
    have hinput : Pi.mulSingle i s = (1 : I → S) :=
      a.injective (by simpa [z] using hz)
    have hpoint := congrFun hinput i
    exact hs (by simpa using hpoint)
  have hexj : ∃ j : I, z j ≠ 1 := by
    by_contra h
    apply hz_ne
    funext j
    exact not_ne_iff.mp (not_exists.mp h j)
  obtain ⟨j, hzj⟩ := hexj
  let F := coordinate (S := S) j
  have hinter : H ⊓ F ≠ ⊥ := by
    intro hbot
    have hdis : Disjoint H F := disjoint_iff_inf_le.mpr (by rw [hbot])
    have hzcenter : z j ∈ Subgroup.center S := by
      rw [Subgroup.mem_center_iff]
      intro y
      have hyF : Pi.mulSingle j y ∈ F :=
        (mem_coordinate_iff (S := S) j _).2 ⟨y, rfl⟩
      have hcomm := Subgroup.commute_of_normal_of_disjoint H F
        (inferInstance : H.Normal) (inferInstance : F.Normal) hdis z
        (Pi.mulSingle j y) hzH hyF
      have hpoint := congrFun hcomm.eq j
      simpa using hpoint.symm
    have hzbot : z j ∈ (⊥ : Subgroup S) := by
      simpa [center_eq_bot_of_not_isMulCommutative (S := S) hncomm] using hzcenter
    exact hzj (Subgroup.mem_bot.mp hzbot)
  have hHsimple : IsSimpleGroup H := inferInstance
  have hnormalSub : ((H ⊓ F).subgroupOf H).Normal := inferInstance
  rcases (Subgroup.isSimpleGroup_iff.mp hHsimple).2 (H ⊓ F) inf_le_left
      hnormalSub with hzero | hfull
  · exact False.elim (hinter hzero)
  · refine ⟨j, Subgroup.eq_of_le_of_card_ge ?_ ?_⟩
    · change H ≤ F
      rw [← hfull]
      exact inf_le_right
    · rw [card_coordinate (S := S) j, card_imageCoordinate (S := S) a i]

/-- The target coordinate of an automorphic image is unique. -/
theorem existsUnique_imageCoordinate_eq_coordinate
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) :
    ∃! j : I, imageCoordinate (S := S) a i = coordinate (S := S) j := by
  obtain ⟨j, hj⟩ :=
    exists_imageCoordinate_eq_coordinate (S := S) hncomm a i
  refine ⟨j, hj, ?_⟩
  intro j' hj'
  apply coordinate_injective (S := S)
  rw [← hj, ← hj']

/-- The coordinate to which `a` sends coordinate `i`. -/
noncomputable def factorTarget
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) : I :=
  Classical.choose
    (existsUnique_imageCoordinate_eq_coordinate (S := S) hncomm a i)

theorem imageCoordinate_eq_coordinate_factorTarget
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) :
    imageCoordinate (S := S) a i =
      coordinate (S := S) (factorTarget (S := S) hncomm a i) :=
  (Classical.choose_spec
    (existsUnique_imageCoordinate_eq_coordinate (S := S) hncomm a i)).1

theorem factorTarget_eq_of_imageCoordinate_eq
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i j : I)
    (h : imageCoordinate (S := S) a i = coordinate (S := S) j) :
    factorTarget (S := S) hncomm a i = j := by
  exact ((Classical.choose_spec
    (existsUnique_imageCoordinate_eq_coordinate (S := S) hncomm a i)).2 j h).symm

theorem factorTarget_injective
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) :
    Function.Injective (factorTarget (S := S) hncomm a) := by
  intro i j hij
  apply coordinate_injective (S := S)
  apply (MulEquiv.mapSubgroup a).injective
  change imageCoordinate (S := S) a i = imageCoordinate (S := S) a j
  rw [imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm,
      imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm, hij]

theorem imageCoordinate_mul
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a b : MulAut (I → S)) (i : I) :
    imageCoordinate (S := S) (a * b) i =
      coordinate (S := S)
        (factorTarget (S := S) hncomm a
          (factorTarget (S := S) hncomm b i)) := by
  calc
    imageCoordinate (S := S) (a * b) i =
        (imageCoordinate (S := S) b i).map a.toMonoidHom := by
          change (coordinate (S := S) i).map
              (a.toMonoidHom.comp b.toMonoidHom) = _
          rw [← Subgroup.map_map]
          rfl
    _ = (coordinate (S := S) (factorTarget (S := S) hncomm b i)).map
          a.toMonoidHom := by
          rw [imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm]
    _ = imageCoordinate (S := S) a
          (factorTarget (S := S) hncomm b i) := rfl
    _ = coordinate (S := S)
          (factorTarget (S := S) hncomm a
            (factorTarget (S := S) hncomm b i)) :=
      imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm _ _

theorem factorTarget_mul
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a b : MulAut (I → S)) (i : I) :
    factorTarget (S := S) hncomm (a * b) i =
      factorTarget (S := S) hncomm a
        (factorTarget (S := S) hncomm b i) :=
  factorTarget_eq_of_imageCoordinate_eq (S := S) hncomm _ _ _
    (imageCoordinate_mul (S := S) hncomm a b i)

theorem factorTarget_one
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) (i : I) :
    factorTarget (S := S) hncomm 1 i = i := by
  apply factorTarget_eq_of_imageCoordinate_eq (S := S) hncomm
  change (coordinate (S := S) i).map (MonoidHom.id (I → S)) = _
  exact Subgroup.map_id (G := I → S) (K := coordinate (S := S) i)

/-- The permutation induced by an automorphism on the coordinate factors. -/
noncomputable def factorPermutation
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) : Equiv.Perm I :=
  Equiv.ofBijective (factorTarget (S := S) hncomm a)
    ⟨factorTarget_injective (S := S) hncomm a,
      Finite.injective_iff_surjective.mp
        (factorTarget_injective (S := S) hncomm a)⟩

@[simp] theorem factorPermutation_apply
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) :
    factorPermutation (S := S) hncomm a i =
      factorTarget (S := S) hncomm a i := rfl

/-- The factor-permutation construction is a homomorphism. -/
noncomputable def factorPermutationHom
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) :
    MulAut (I → S) →* Equiv.Perm I where
  toFun := factorPermutation (S := S) hncomm
  map_one' := by
    ext i
    exact factorTarget_one (S := S) hncomm i
  map_mul' a b := by
    ext i
    exact factorTarget_mul (S := S) hncomm a b i

/-- The automorphism of `S` carried by `a` from source coordinate `i` to
target coordinate `factorTarget a i`. -/
noncomputable def sourceComponent
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) : MulAut S :=
  (coordinateEquiv (S := S) i).trans
    ((a.subgroupMap (coordinate (S := S) i)).trans
      ((MulEquiv.subgroupCongr
          (imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm a i)).trans
        (coordinateEquiv (S := S)
          (factorTarget (S := S) hncomm a i)).symm))

@[simp] theorem sourceComponent_apply
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) (s : S) :
    sourceComponent (S := S) hncomm a i s =
      (a (Pi.mulSingle i s)) (factorTarget (S := S) hncomm a i) := by
  rfl

/-- An automorphism sends a one-coordinate element to the corresponding
one-coordinate element, with the `sourceComponent` automorphism applied. -/
theorem apply_mulSingle
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (i : I) (s : S) :
    a (Pi.mulSingle i s) =
      Pi.mulSingle (factorTarget (S := S) hncomm a i)
        (sourceComponent (S := S) hncomm a i s) := by
  let j := factorTarget (S := S) hncomm a i
  have hmemImage : a (Pi.mulSingle i s) ∈ imageCoordinate (S := S) a i :=
    ⟨Pi.mulSingle i s,
      (mem_coordinate_iff (S := S) i _).2 ⟨s, rfl⟩, rfl⟩
  have hmemCoordinate : a (Pi.mulSingle i s) ∈ coordinate (S := S) j := by
    rw [← imageCoordinate_eq_coordinate_factorTarget (S := S) hncomm a i]
    exact hmemImage
  rcases (mem_coordinate_iff (S := S) j _).1 hmemCoordinate with ⟨t, ht⟩
  rw [← ht]
  congr 1
  have hpoint := congrFun ht j
  simpa [j] using hpoint

/-- Source components compose with the intervening factor permutation. -/
theorem sourceComponent_mul
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a b : MulAut (I → S)) (i : I) :
    sourceComponent (S := S) hncomm (a * b) i =
      sourceComponent (S := S) hncomm a
          (factorTarget (S := S) hncomm b i) *
        sourceComponent (S := S) hncomm b i := by
  apply MulEquiv.ext
  intro s
  rw [sourceComponent_apply]
  rw [factorTarget_mul (S := S) hncomm]
  change (a (b (Pi.mulSingle i s)))
      (factorTarget (S := S) hncomm a
        (factorTarget (S := S) hncomm b i)) = _
  rw [apply_mulSingle (S := S) hncomm b i s]
  rw [apply_mulSingle (S := S) hncomm a
    (factorTarget (S := S) hncomm b i)
    (sourceComponent (S := S) hncomm b i s)]
  simp

@[simp] theorem sourceComponent_one
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) (i : I) :
    sourceComponent (S := S) hncomm 1 i = 1 := by
  apply MulEquiv.ext
  intro s
  rw [sourceComponent_apply, factorTarget_one (S := S) hncomm]
  simp

/-- The full coordinate-wreath record attached to an automorphism of the
direct power.  Components are indexed by their target coordinate, hence the
inverse factor permutation in the definition. -/
noncomputable def automorphismWreathData
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) : CoordinateWreath (MulAut S) I :=
  ⟨fun j => sourceComponent (S := S) hncomm a
      ((factorPermutation (S := S) hncomm a).symm j),
    factorPermutation (S := S) hncomm a⟩

@[simp] theorem automorphismWreathData_permutation
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) :
    (automorphismWreathData (S := S) hncomm a).permutation =
      factorPermutation (S := S) hncomm a := rfl

@[simp] theorem automorphismWreathData_component
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) (j : I) :
    (automorphismWreathData (S := S) hncomm a).component j =
      sourceComponent (S := S) hncomm a
        ((factorPermutation (S := S) hncomm a).symm j) := rfl

/-- Automorphisms of `S^I` map homomorphically to the imprimitive coordinate
wreath product. -/
noncomputable def automorphismWreathHom
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) :
    MulAut (I → S) →* CoordinateWreath (MulAut S) I where
  toFun := automorphismWreathData (S := S) hncomm
  map_one' := by
    apply CoordinateWreath.ext
    · funext j
      have hperm : factorPermutation (S := S) hncomm
          (1 : MulAut (I → S)) = (1 : Equiv.Perm I) :=
        (factorPermutationHom (S := S) hncomm).map_one
      change sourceComponent (S := S) hncomm 1
          ((factorPermutation (S := S) hncomm 1).symm j) = 1
      rw [hperm]
      simp
    · exact (factorPermutationHom (S := S) hncomm).map_one
  map_mul' a b := by
    apply CoordinateWreath.ext
    · funext j
      let σab := factorPermutation (S := S) hncomm (a * b)
      let σa := factorPermutation (S := S) hncomm a
      let σb := factorPermutation (S := S) hncomm b
      have hperm : σab = σa * σb :=
        (factorPermutationHom (S := S) hncomm).map_mul a b
      have hinv : σab.symm j = σb.symm (σa.symm j) := by
        rw [hperm]
        rfl
      have htarget : factorTarget (S := S) hncomm b (σab.symm j) =
          σa.symm j := by
        rw [hinv]
        change σb (σb.symm (σa.symm j)) = σa.symm j
        simp
      change sourceComponent (S := S) hncomm (a * b) (σab.symm j) =
        sourceComponent (S := S) hncomm a (σa.symm j) *
          sourceComponent (S := S) hncomm b (σb.symm (σa.symm j))
      rw [sourceComponent_mul (S := S) hncomm, htarget, hinv]
    · exact (factorPermutationHom (S := S) hncomm).map_mul a b

/-- The coordinate-wreath encoding remembers the whole automorphism. -/
theorem automorphismWreathHom_injective
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) :
    Function.Injective (automorphismWreathHom (S := S) (I := I) hncomm) := by
  intro a b hab
  have hperm : factorPermutation (S := S) hncomm a =
      factorPermutation (S := S) hncomm b :=
    congrArg CoordinateWreath.permutation hab
  apply MulEquiv.ext
  intro x
  let E := a.toMonoidHom.eqLocus b.toMonoidHom
  have hxE : x ∈ E := by
    apply Subgroup.pi_mem_of_mulSingle_mem x
    intro i
    change a (Pi.mulSingle i (x i)) = b (Pi.mulSingle i (x i))
    have htarget : factorTarget (S := S) hncomm a i =
        factorTarget (S := S) hncomm b i := by
      simpa using congrArg (fun σ : Equiv.Perm I => σ i) hperm
    have hcomponentRaw := congrArg
      (fun w : CoordinateWreath (MulAut S) I =>
        w.component (factorPermutation (S := S) hncomm a i)) hab
    have hcomponent : sourceComponent (S := S) hncomm a i =
        sourceComponent (S := S) hncomm b i := by
      change sourceComponent (S := S) hncomm a
          ((factorPermutation (S := S) hncomm a).symm
            (factorPermutation (S := S) hncomm a i)) =
        sourceComponent (S := S) hncomm b
          ((factorPermutation (S := S) hncomm b).symm
            (factorPermutation (S := S) hncomm a i)) at hcomponentRaw
      have htargetPerm : factorPermutation (S := S) hncomm a i =
          factorPermutation (S := S) hncomm b i :=
        congrArg (fun σ : Equiv.Perm I => σ i) hperm
      have hleft : (factorPermutation (S := S) hncomm a).symm
          (factorPermutation (S := S) hncomm a i) = i :=
        (factorPermutation (S := S) hncomm a).symm_apply_apply i
      have hright : (factorPermutation (S := S) hncomm b).symm
          (factorPermutation (S := S) hncomm a i) = i := by
        rw [htargetPerm]
        exact (factorPermutation (S := S) hncomm b).symm_apply_apply i
      simpa only [hleft, hright] using hcomponentRaw
    rw [apply_mulSingle (S := S) hncomm,
        apply_mulSingle (S := S) hncomm, htarget, hcomponent]
  exact hxE

/-- The inner automorphism subgroup. -/
def innerAut (T : Type*) [Group T] : Subgroup (MulAut T) :=
  MulAut.conj.range

instance innerAut_normal (T : Type*) [Group T] : (innerAut T).Normal := by
  constructor
  intro n hn a
  rcases (MonoidHom.mem_range.mp hn) with ⟨t, rfl⟩
  apply MonoidHom.mem_range.mpr
  refine ⟨a t, ?_⟩
  apply MulEquiv.ext
  intro x
  simp [MulAut.conj_apply]

theorem factorTarget_conj
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (n : I → S) (i : I) :
    factorTarget (S := S) hncomm (MulAut.conj n) i = i := by
  apply factorTarget_eq_of_imageCoordinate_eq (S := S) hncomm
  change (coordinate (S := S) i).map (MulAut.conj n).toMonoidHom =
    coordinate (S := S) i
  exact Subgroup.Normal.map_conj_eq (coordinate (S := S) i) n

theorem sourceComponent_conj
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (n : I → S) (i : I) :
    sourceComponent (S := S) hncomm (MulAut.conj n) i =
      MulAut.conj (n i) := by
  apply MulEquiv.ext
  intro s
  rw [sourceComponent_apply, factorTarget_conj (S := S) hncomm]
  simp [MulAut.conj_apply]

theorem factorPermutation_conj
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) (n : I → S) :
    factorPermutation (S := S) hncomm (MulAut.conj n) = 1 := by
  ext i
  exact factorTarget_conj (S := S) hncomm n i

/-- Under the wreath encoding, an inner automorphism of the direct power has
trivial top permutation and the coordinate inner automorphisms. -/
theorem automorphismWreathHom_conj
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S) (n : I → S) :
    automorphismWreathHom (S := S) (I := I) hncomm (MulAut.conj n) =
      (⟨fun i => MulAut.conj (n i), 1⟩ :
        CoordinateWreath (MulAut S) I) := by
  apply CoordinateWreath.ext
  · funext i
    change sourceComponent (S := S) hncomm (MulAut.conj n)
        ((factorPermutation (S := S) hncomm (MulAut.conj n)).symm i) = _
    rw [factorPermutation_conj (S := S) hncomm]
    have hone : (1 : Equiv.Perm I).symm i = i := rfl
    rw [hone, sourceComponent_conj (S := S) hncomm]
  · exact factorPermutation_conj (S := S) hncomm n

/-- The preimage of the base inner-automorphism subgroup under the wreath
encoding is exactly the inner automorphism subgroup of the direct power. -/
theorem wreath_base_iff_inner
    [Finite S] [Finite I] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (a : MulAut (I → S)) :
    let w := automorphismWreathHom (S := S) (I := I) hncomm a
    (w.permutation = 1 ∧ ∀ i, w.component i ∈ innerAut S) ↔
      a ∈ innerAut (I → S) := by
  dsimp only
  constructor
  · rintro ⟨hperm, hcomponent⟩
    let n : I → S := fun i => Classical.choose
      (MonoidHom.mem_range.mp (hcomponent i))
    have hn (i : I) : MulAut.conj (n i) =
        (automorphismWreathHom (S := S) (I := I) hncomm a).component i :=
      Classical.choose_spec (MonoidHom.mem_range.mp (hcomponent i))
    apply MonoidHom.mem_range.mpr
    refine ⟨n, ?_⟩
    apply automorphismWreathHom_injective (S := S) (I := I) hncomm
    rw [automorphismWreathHom_conj (S := S) hncomm n]
    apply CoordinateWreath.ext
    · funext i
      exact hn i
    · exact hperm.symm
  · rintro ⟨n, rfl⟩
    rw [automorphismWreathHom_conj (S := S) hncomm n]
    refine ⟨rfl, ?_⟩
    intro i
    exact MonoidHom.mem_range.mpr ⟨n i, rfl⟩

end DirectPower
end Kourovka1034
