import Kourovka1034.DirectPower

/-!
# The ambient conjugation action in direct-power coordinates

This file transports the faithful conjugation action on a normal subgroup
through an explicit direct-power equivalence, composes it with the proved
automorphism-wreath embedding, and identifies the exact inverse image of the
base inner-automorphism subgroup.
-/

namespace Kourovka1034
namespace AmbientWreath

open DirectPower

variable {A B : Type*} [Group A] [Group B]

/-- Transport automorphisms across a group equivalence. -/
def transportAut (e : A ≃* B) : MulAut A →* MulAut B where
  toFun a := e.symm.trans (a.trans e)
  map_one' := by
    apply MulEquiv.ext
    intro x
    simp
  map_mul' a b := by
    apply MulEquiv.ext
    intro x
    simp

@[simp] theorem transportAut_apply (e : A ≃* B) (a : MulAut A) (x : B) :
    transportAut e a x = e (a (e.symm x)) := rfl

theorem transportAut_injective (e : A ≃* B) :
    Function.Injective (transportAut e) := by
  intro a b hab
  apply MulEquiv.ext
  intro x
  apply e.injective
  have hpoint := congrArg (fun q : MulAut B => q (e x)) hab
  simpa using hpoint

@[simp] theorem transportAut_conj (e : A ≃* B) (a : A) :
    transportAut e (MulAut.conj a) = MulAut.conj (e a) := by
  apply MulEquiv.ext
  intro x
  simp [MulAut.conj_apply]

variable {T I : Type*} [Group T]

/-- Elements of the direct power supported on the coordinate set `J`. -/
noncomputable def supportSubgroup (J : Set I) : Subgroup (I → T) := by
  classical
  exact Subgroup.pi Set.univ fun i => if i ∈ J then ⊤ else ⊥

theorem mem_supportSubgroup_iff (J : Set I) (x : I → T) :
    x ∈ supportSubgroup (T := T) J ↔ ∀ i, i ∉ J → x i = 1 := by
  classical
  constructor
  · intro hx i hi
    have hxi := (Subgroup.mem_pi Set.univ).1 hx i (Set.mem_univ i)
    simp [hi] at hxi
    exact hxi
  · intro hx
    rw [supportSubgroup, Subgroup.mem_pi]
    intro i _
    by_cases hi : i ∈ J
    · simp [hi]
    · simp [hi, hx i hi]

theorem mulSingle_mem_supportSubgroup [DecidableEq I]
    (J : Set I) {i : I} (hi : i ∈ J)
    (t : T) : Pi.mulSingle i t ∈ supportSubgroup (T := T) J := by
  classical
  rw [supportSubgroup, Subgroup.mulSingle_mem_pi]
  simp [hi]

/-- A direct-power automorphism preserving a coordinate set sends its support
subgroup into itself. -/
theorem automorphism_mem_supportSubgroup
    [DecidableEq I] [Finite T] [Finite I] [IsSimpleGroup T]
    (hncomm : ¬ IsMulCommutative T)
    (J : Set I) (a : MulAut (I → T))
    (hJ : ∀ i ∈ J, factorTarget (S := T) hncomm a i ∈ J)
    {x : I → T} (hx : x ∈ supportSubgroup (T := T) J) :
    a x ∈ supportSubgroup (T := T) J := by
  let E := (supportSubgroup (T := T) J).comap a.toMonoidHom
  have hxE : x ∈ E := by
    apply Subgroup.pi_mem_of_mulSingle_mem x
    intro i
    change a (Pi.mulSingle i (x i)) ∈ supportSubgroup (T := T) J
    by_cases hi : i ∈ J
    · rw [apply_mulSingle (S := T) hncomm]
      exact mulSingle_mem_supportSubgroup (T := T) J (hJ i hi) _
    · have hxi := (mem_supportSubgroup_iff (T := T) J x).1 hx i hi
      simp [hxi]
  exact hxE

variable {H D : Type*} [Group H] [Group D]

/-- Orbit of one coordinate under the top permutation of a wreath
homomorphism. -/
def factorOrbit (rho : H →* CoordinateWreath D I) (base : I) : Set I :=
  {i | ∃ h : H, (rho h).permutation base = i}

theorem base_mem_factorOrbit (rho : H →* CoordinateWreath D I) (base : I) :
    base ∈ factorOrbit rho base := by
  refine ⟨1, ?_⟩
  simp

theorem factorOrbit_forward (rho : H →* CoordinateWreath D I) (base : I)
    (g : H) {i : I} (hi : i ∈ factorOrbit rho base) :
    (rho g).permutation i ∈ factorOrbit rho base := by
  rcases hi with ⟨h, hh⟩
  refine ⟨g * h, ?_⟩
  rw [map_mul, CoordinateWreath.mul_permutation, Equiv.Perm.mul_apply, hh]

variable {G S : Type*} [Group G] [Group S]

/-- The ambient conjugation homomorphism in the proved direct-power wreath
coordinates. -/
noncomputable def ambientWreathHom
    [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (e : N ≃* (Fin k → S)) :
    G →* CoordinateWreath (MulAut S) (Fin k) :=
  (automorphismWreathHom (S := S) (I := Fin k) hncomm).comp
    ((transportAut e).comp MulAut.conjNormal)

@[simp] theorem ambientWreathHom_apply
    [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (e : N ≃* (Fin k → S)) (g : G) :
    ambientWreathHom (S := S) hncomm N k e g =
      automorphismWreathHom (S := S) (I := Fin k) hncomm
        (transportAut e (MulAut.conjNormal g)) := rfl

/-- A self-centralizing direct-power normal subgroup gives a faithful ambient
wreath representation. -/
theorem ambientWreathHom_injective
    [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (e : N ≃* (Fin k → S))
    (hcentralizer : Subgroup.centralizer (N : Set G) = ⊥) :
    Function.Injective (ambientWreathHom (S := S) hncomm N k e) :=
  (automorphismWreathHom_injective (S := S) (I := Fin k) hncomm).comp
    ((transportAut_injective e).comp
      (conjNormal_injective_of_centralizer_eq_bot N hcentralizer))

/-- Transported conjugation is inner exactly for ambient elements lying in
`N`, provided `N` is self-centralizing. -/
theorem transported_conjNormal_mem_inner_iff
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (e : N ≃* (Fin k → S))
    (hcentralizer : Subgroup.centralizer (N : Set G) = ⊥)
    (g : G) :
    transportAut e (MulAut.conjNormal g) ∈ innerAut (Fin k → S) ↔
      g ∈ N := by
  constructor
  · rintro ⟨p, hp⟩
    let n : N := e.symm p
    have hntransport : transportAut e (MulAut.conjNormal (n : G)) =
        MulAut.conj p := by
      rw [MulAut.conjNormal_val, transportAut_conj]
      simp [n]
    have hconj : MulAut.conjNormal (H := N) g =
        MulAut.conjNormal (H := N) (n : G) := by
      apply transportAut_injective e
      exact hp.symm.trans hntransport.symm
    have hg : g = (n : G) :=
      conjNormal_injective_of_centralizer_eq_bot N hcentralizer hconj
    exact hg.symm ▸ n.property
  · intro hg
    let n : N := ⟨g, hg⟩
    apply MonoidHom.mem_range.mpr
    refine ⟨e n, ?_⟩
    rw [← transportAut_conj, ← MulAut.conjNormal_val]

/-- Exact base-kernel interface required by the normalized coordinate theorem:
an ambient element lies in `N` iff its wreath image has trivial top and every
base component is inner. -/
theorem ambientWreath_base_iff
    [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (e : N ≃* (Fin k → S))
    (hcentralizer : Subgroup.centralizer (N : Set G) = ⊥)
    (g : G) :
    g ∈ N ↔
      (ambientWreathHom (S := S) hncomm N k e g).permutation = 1 ∧
      ∀ i, (ambientWreathHom (S := S) hncomm N k e g).component i ∈
        innerAut S := by
  exact (((wreath_base_iff_inner (S := S) (I := Fin k) hncomm
      (transportAut e (MulAut.conjNormal (H := N) g))).trans
    (transported_conjNormal_mem_inner_iff N k e hcentralizer g))).symm

/-- Minimal normality forces the ambient action on the direct-power factors to
be transitive. -/
theorem ambientWreath_transitive
    [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (hminimal : IsMinimalNormal N)
    (k : ℕ) (e : N ≃* (Fin k → S)) (base : Fin k) :
    ∀ i : Fin k, ∃ g : G,
      (ambientWreathHom (S := S) hncomm N k e g).permutation base = i := by
  let rho := ambientWreathHom (S := S) hncomm N k e
  let J : Set (Fin k) := factorOrbit rho base
  let Q : Subgroup (Fin k → S) := supportSubgroup (T := S) J
  let L : Subgroup N := Q.comap e.toMonoidHom
  let M : Subgroup G := L.map N.subtype
  have hMnormal : M.Normal := by
    constructor
    intro m hm g
    rcases hm with ⟨n, hnL, hnm⟩
    let a : MulAut (Fin k → S) :=
      transportAut e (MulAut.conjNormal (H := N) g)
    have hJ : ∀ i ∈ J, factorTarget (S := S) hncomm a i ∈ J := by
      intro i hi
      change (rho g).permutation i ∈ J
      exact factorOrbit_forward rho base g hi
    have hinvariant : a (e n) ∈ Q := by
      apply automorphism_mem_supportSubgroup (T := S) hncomm J a hJ
      exact hnL
    let n' : N := MulAut.conjNormal (H := N) g n
    refine ⟨n', ?_, ?_⟩
    · change e n' ∈ Q
      simpa [a, n', transportAut_apply] using hinvariant
    · calc
        (n' : G) = g * (n : G) * g⁻¹ := rfl
        _ = g * m * g⁻¹ := congrArg (fun z : G => g * z * g⁻¹) hnm
  have hMN : M ≤ N := by
    intro m hm
    rcases hm with ⟨n, _hnL, rfl⟩
    exact n.property
  have hMne : M ≠ ⊥ := by
    obtain ⟨s, hs⟩ := exists_ne (1 : S)
    let x : Fin k → S := Pi.mulSingle base s
    have hbaseJ : base ∈ J := base_mem_factorOrbit rho base
    have hxQ : x ∈ Q :=
      mulSingle_mem_supportSubgroup (T := S) J hbaseJ s
    let n : N := e.symm x
    have hnL : n ∈ L := by
      change e n ∈ Q
      simpa [n] using hxQ
    have hnM : (n : G) ∈ M := ⟨n, hnL, rfl⟩
    intro hbot
    have hnval : (n : G) = 1 := Subgroup.mem_bot.mp (hbot ▸ hnM)
    have hn1 : n = 1 := Subtype.ext hnval
    have hx1 : x = 1 := by
      calc
        x = e n := by simp [n]
        _ = e 1 := by rw [hn1]
        _ = 1 := e.map_one
    have hpoint := congrFun hx1 base
    exact hs (by simpa [x] using hpoint)
  have hMeq : M = N := by
    rcases hminimal.2.2 M hMnormal hMN with hbot | htop
    · exact False.elim (hMne hbot)
    · exact htop
  have hQtop : Q = ⊤ := by
    apply (Subgroup.eq_top_iff' Q).2
    intro p
    let n : N := e.symm p
    have hnM : (n : G) ∈ M := by
      rw [hMeq]
      exact n.property
    rcases hnM with ⟨m, hmL, hmval⟩
    have hmn : m = n := Subtype.ext hmval
    subst m
    change e n ∈ Q at hmL
    simpa [n] using hmL
  intro i
  change i ∈ J
  by_contra hi
  obtain ⟨s, hs⟩ := exists_ne (1 : S)
  let x : Fin k → S := Pi.mulSingle i s
  have hxQ : x ∈ Q := by
    rw [hQtop]
    exact Subgroup.mem_top x
  have hxi := (mem_supportSubgroup_iff (T := S) J x).1 hxQ i hi
  exact hs (by simpa [x] using hxi)

/-- Complete kernel-checked ambient wreath interface and normalized quotient
bound, starting only from an explicit direct-power equivalence for the minimal
normal subgroup. -/
theorem ambient_coordinate_realization_and_bound
    [Finite G] [Finite S] [IsSimpleGroup S]
    (hncomm : ¬ IsMulCommutative S)
    (N : Subgroup G) [N.Normal]
    (hminimal : IsMinimalNormal N)
    (hcentralizer : Subgroup.centralizer (N : Set G) = ⊥)
    (k : ℕ) (e : N ≃* (Fin k → S)) (base : Fin k) :
    let rho := ambientWreathHom (S := S) hncomm N k e
    let K := innerAut S
    Function.Injective rho ∧
      (∀ i : Fin k, ∃ g : G, (rho g).permutation base = i) ∧
      (∀ g : G, g ∈ N ↔
        (rho g).permutation = 1 ∧ ∀ i, (rho g).component i ∈ K) ∧
      (let X := CoordinateNormalization.closure K rho base
       let KX := K.comap X.subtype
       Nat.card (G ⧸ N) ∣ Nat.card (X ⧸ KX) ^ k * k.factorial) := by
  dsimp only
  refine ⟨ambientWreathHom_injective (S := S) hncomm N k e hcentralizer,
    ambientWreath_transitive (S := S) hncomm N hminimal k e base,
    ambientWreath_base_iff (S := S) hncomm N k e hcentralizer, ?_⟩
  exact CoordinateNormalization.normalized_coordinate_quotient_bound
    N (innerAut S) k (ambientWreathHom (S := S) hncomm N k e) base
    (ambientWreath_transitive (S := S) hncomm N hminimal k e base)
    (ambientWreath_base_iff (S := S) hncomm N k e hcentralizer)

end AmbientWreath
end Kourovka1034
