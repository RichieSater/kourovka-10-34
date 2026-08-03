import Kourovka1034.Reduction
import Mathlib.Algebra.Group.Subgroup.Finite
import Mathlib.Data.Finite.Perm
import Mathlib.GroupTheory.Coset.Card
import Mathlib.GroupTheory.Index
import Mathlib.GroupTheory.QuotientGroup.Basic

/-!
# Transitive coordinate normalization and the wreath quotient bound

This file formalizes the coordinate bookkeeping in Convention 2.4 after the
standard structural realization `N ≃ S^k` and
`G ↪ Aut(S) wr Sym(k)` has been supplied.  The structural realization itself
is an explicit external-source obligation; it is not postulated as an axiom.

The wreath convention here is the one used by the manuscript and the product
supplement files: output coordinate `i` reads source coordinate
`sigma(g)⁻¹(i)`.  Thus components satisfy

`a_(gh,i) = a_(g,i) * a_(h,sigma(g)⁻¹(i))`.
-/

namespace Kourovka1034

/-- The imprimitive coordinate wreath product `D^I ⋊ Sym(I)`, with the
inverse-source convention used throughout the formal project. -/
@[ext]
structure CoordinateWreath (D I : Type*) where
  component : I → D
  permutation : Equiv.Perm I

namespace CoordinateWreath

variable {D I : Type*} [Group D]

instance : Mul (CoordinateWreath D I) where
  mul a b :=
    ⟨fun i => a.component i * b.component (a.permutation.symm i),
      a.permutation * b.permutation⟩

@[simp] theorem mul_component (a b : CoordinateWreath D I) (i : I) :
    (a * b).component i =
      a.component i * b.component (a.permutation.symm i) := rfl

@[simp] theorem mul_permutation (a b : CoordinateWreath D I) :
    (a * b).permutation = a.permutation * b.permutation := rfl

instance : One (CoordinateWreath D I) where
  one := ⟨1, 1⟩

@[simp] theorem one_component (i : I) :
    (1 : CoordinateWreath D I).component i = 1 := rfl

@[simp] theorem one_permutation :
    (1 : CoordinateWreath D I).permutation = 1 := rfl

instance : Inv (CoordinateWreath D I) where
  inv a :=
    ⟨fun i => (a.component (a.permutation i))⁻¹, a.permutation⁻¹⟩

@[simp] theorem inv_component (a : CoordinateWreath D I) (i : I) :
    a⁻¹.component i = (a.component (a.permutation i))⁻¹ := rfl

@[simp] theorem inv_permutation (a : CoordinateWreath D I) :
    a⁻¹.permutation = a.permutation⁻¹ := rfl

instance : Group (CoordinateWreath D I) where
  mul_assoc a b c := by
    apply CoordinateWreath.ext
    · funext i
      have hsource :
          (a.permutation * b.permutation).symm i =
            b.permutation.symm (a.permutation.symm i) := by
        apply (a.permutation * b.permutation).injective
        simp [Equiv.Perm.mul_apply]
      simp only [mul_component]
      rw [mul_permutation, hsource, mul_assoc]
    · exact mul_assoc _ _ _
  one_mul a := by
    apply CoordinateWreath.ext
    · funext i
      have hsource : (1 : Equiv.Perm I).symm i = i := by rfl
      rw [mul_component, one_component, one_permutation, hsource, one_mul]
    · exact one_mul _
  mul_one a := by
    apply CoordinateWreath.ext
    · funext i
      simp
    · exact mul_one _
  inv_mul_cancel a := by
    apply CoordinateWreath.ext
    · funext i
      simp [Equiv.Perm.inv_def]
    · exact inv_mul_cancel _

instance : Inhabited (CoordinateWreath D I) := ⟨1⟩

/-- Projection to the coordinate permutation. -/
def permutationHom : CoordinateWreath D I →* Equiv.Perm I where
  toFun := CoordinateWreath.permutation
  map_one' := rfl
  map_mul' _ _ := rfl

/-- The underlying equivalence with `(I → D) × Sym(I)`. -/
def equivProd : CoordinateWreath D I ≃ (I → D) × Equiv.Perm I where
  toFun w := (w.component, w.permutation)
  invFun w := ⟨w.1, w.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

instance [Finite D] [Finite I] : Finite (CoordinateWreath D I) :=
  Finite.of_equiv ((I → D) × Equiv.Perm I) equivProd.symm

omit [Group D] in
/-- Exact order of the finite coordinate wreath product. -/
theorem card [Finite D] [Finite I] :
    Nat.card (CoordinateWreath D I) =
      Nat.card D ^ Nat.card I * (Nat.card I).factorial := by
  rw [Nat.card_congr equivProd, Nat.card_prod, Nat.card_fun, Nat.card_perm]

/-- Apply a group homomorphism to every base component, retaining the top
permutation. -/
def map {E : Type*} [Group E] (f : D →* E) :
    CoordinateWreath D I →* CoordinateWreath E I where
  toFun w := ⟨fun i => f (w.component i), w.permutation⟩
  map_one' := by ext <;> simp
  map_mul' a b := by ext <;> simp

@[simp] theorem map_component {E : Type*} [Group E] (f : D →* E)
    (w : CoordinateWreath D I) (i : I) :
    (map f w).component i = f (w.component i) := rfl

@[simp] theorem map_permutation {E : Type*} [Group E] (f : D →* E)
    (w : CoordinateWreath D I) :
    (map f w).permutation = w.permutation := rfl

/-- Embed a coordinate wreath product over a subgroup into the ambient
coordinate wreath product. -/
def subgroupMap (X : Subgroup D) :
    CoordinateWreath X I →* CoordinateWreath D I :=
  map X.subtype

theorem subgroupMap_injective (X : Subgroup D) :
    Function.Injective (subgroupMap (I := I) X) := by
  intro a b hab
  apply CoordinateWreath.ext
  · funext i
    apply Subtype.ext
    exact congrArg (fun w : CoordinateWreath D I => w.component i) hab
  · simpa [subgroupMap, map] using
      congrArg (fun w : CoordinateWreath D I => w.permutation) hab

/-- Conjugation by a fixed base element does not change the top
permutation. -/
theorem base_conjugate_permutation (delta w : CoordinateWreath D I)
    (hdelta : delta.permutation = 1) :
    (delta⁻¹ * w * delta).permutation = w.permutation := by
  simp [hdelta]

/-- Quotient every base component by a fixed normal subgroup. -/
def quotientMap (K : Subgroup D) [K.Normal] :
    CoordinateWreath D I →* CoordinateWreath (D ⧸ K) I :=
  map (QuotientGroup.mk' K)

/-- The coordinate quotient is trivial exactly for a trivial top
permutation and base components lying in `K`. -/
theorem quotientMap_eq_one_iff (K : Subgroup D) [K.Normal]
    (w : CoordinateWreath D I) :
    quotientMap (I := I) K w = 1 ↔
      w.permutation = 1 ∧ ∀ i, w.component i ∈ K := by
  constructor
  · intro hw
    constructor
    · exact congrArg CoordinateWreath.permutation hw
    · intro i
      have hi := congrArg (fun q => q.component i) hw
      exact (QuotientGroup.eq_one_iff (w.component i)).mp hi
  · rintro ⟨hperm, hcomp⟩
    apply CoordinateWreath.ext
    · funext i
      exact (QuotientGroup.eq_one_iff (w.component i)).mpr (hcomp i)
    · exact hperm

/-- A homomorphism whose kernel is `N` embeds `G/N` as its range, so the
quotient order divides the exact order of the coordinate wreath codomain. -/
theorem quotient_card_dvd_wreath_card
    {G : Type*} [Group G] [Finite G] [Finite D] [Finite I]
    (N : Subgroup G) [N.Normal]
    (f : G →* CoordinateWreath D I) (hker : f.ker = N) :
    Nat.card (G ⧸ N) ∣
      Nat.card D ^ Nat.card I * (Nat.card I).factorial := by
  have hcard : Nat.card (G ⧸ N) = Nat.card f.range := by
    rw [← hker]
    exact Nat.card_congr (QuotientGroup.quotientKerEquivRange f).toEquiv
  rw [hcard, ← CoordinateWreath.card]
  exact Subgroup.card_subgroup_dvd_card f.range

/-- The manuscript's numerical form for `k` coordinates. -/
theorem quotient_card_dvd_wreath_card_fin
    {G : Type*} [Group G] [Finite G] [Finite D]
    (N : Subgroup G) [N.Normal]
    (k : ℕ) (f : G →* CoordinateWreath D (Fin k)) (hker : f.ker = N) :
    Nat.card (G ⧸ N) ∣ Nat.card D ^ k * k.factorial := by
  simpa using quotient_card_dvd_wreath_card N f hker

end CoordinateWreath

namespace CoordinateNormalization

variable {G A I : Type*} [Group G] [Group A]

/-- Components at a chosen coordinate contributed by elements stabilizing
that coordinate. -/
def stabilizerComponents (rho : G →* CoordinateWreath A I) (base : I) : Set A :=
  {a | ∃ g : G,
    (rho g).permutation base = base ∧ (rho g).component base = a}

/-- The coordinate closure generated by stabilizer components and a prescribed
normal base subgroup (in the application, the inner automorphisms). -/
def closure (K : Subgroup A) (rho : G →* CoordinateWreath A I)
    (base : I) : Subgroup A :=
  Subgroup.closure (stabilizerComponents rho base ∪ (K : Set A))

theorem le_closure (K : Subgroup A) (rho : G →* CoordinateWreath A I)
    (base : I) : K ≤ closure K rho base := by
  intro a ha
  exact Subgroup.subset_closure (Set.mem_union_right _ ha)

/-- A chosen element carrying the base coordinate to `i`. -/
noncomputable def transport (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (i : I) : G :=
  Classical.choose (htrans i)

theorem transport_permutation (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (i : I) :
    (rho (transport rho base htrans i)).permutation base = i :=
  Classical.choose_spec (htrans i)

/-- The base element used to normalize every coordinate component into the
coordinate closure. -/
noncomputable def delta (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) :
    CoordinateWreath A I :=
  ⟨fun i => (rho (transport rho base htrans i)).component i, 1⟩

@[simp] theorem delta_permutation (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) :
    (delta rho base htrans).permutation = 1 := rfl

/-- Conjugate the original wreath realization by the normalizing base
element. -/
noncomputable def normalizedHom (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) :
    G →* CoordinateWreath A I :=
  ((MulAut.conj (delta rho base htrans)⁻¹ :
      CoordinateWreath A I →* CoordinateWreath A I)).comp rho

@[simp] theorem normalizedHom_apply (rho : G →* CoordinateWreath A I)
    (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (g : G) :
    normalizedHom rho base htrans g =
      (delta rho base htrans)⁻¹ * rho g * delta rho base htrans := by
  simp [normalizedHom]

@[simp] theorem normalizedHom_permutation (rho : G →* CoordinateWreath A I)
    (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (g : G) :
    (normalizedHom rho base htrans g).permutation = (rho g).permutation := by
  rw [normalizedHom_apply]
  exact CoordinateWreath.base_conjugate_permutation _ _
    (delta_permutation rho base htrans)

/-- Every component of the normalized realization belongs to the coordinate
closure.  This is the exact transporter calculation in Convention 2.4. -/
theorem normalized_component_mem_closure
    (K : Subgroup A) (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) :
    ∀ g : G, ∀ i : I,
      (normalizedHom rho base htrans g).component i ∈ closure K rho base := by
  intro g i
  let ti : G := transport rho base htrans i
  let j : I := (rho g).permutation.symm i
  let tj : G := transport rho base htrans j
  let h : G := ti⁻¹ * g * tj
  have hti : (rho ti).permutation base = i :=
    transport_permutation rho base htrans i
  have htj : (rho tj).permutation base = j :=
    transport_permutation rho base htrans j
  have hgj : (rho g).permutation j = i := by
    simp [j]
  have htinv : (rho ti).permutation⁻¹ i = base := by
    apply (rho ti).permutation.injective
    simpa [Equiv.Perm.mul_apply] using hti.symm
  have hsource :
      ((rho ti).permutation⁻¹ * (rho g).permutation).symm base = j := by
    apply ((rho ti).permutation⁻¹ * (rho g).permutation).injective
    simp [Equiv.Perm.mul_apply, hgj, htinv]
  have hfix : (rho h).permutation base = base := by
    simp only [h, map_mul, map_inv, CoordinateWreath.mul_permutation,
      CoordinateWreath.inv_permutation, Equiv.Perm.mul_apply]
    rw [htj, hgj, htinv]
  apply Subgroup.subset_closure
  apply Set.mem_union_left
  refine ⟨h, hfix, ?_⟩
  simp only [normalizedHom_apply, h, map_mul, map_inv,
    CoordinateWreath.mul_component, CoordinateWreath.mul_permutation,
    CoordinateWreath.inv_component, CoordinateWreath.inv_permutation, delta]
  rw [hsource]
  simp [ti, tj, j, hti, Equiv.Perm.inv_def, mul_assoc]
  change (rho g).component i = (rho g).component i
  rfl

/-- Restrict all base components of a wreath homomorphism to a subgroup. -/
def restrictComponents (X : Subgroup A)
    (f : G →* CoordinateWreath A I)
    (hcomponent : ∀ g : G, ∀ i : I, (f g).component i ∈ X) :
    G →* CoordinateWreath X I where
  toFun g :=
    ⟨fun i => ⟨(f g).component i, hcomponent g i⟩, (f g).permutation⟩
  map_one' := by
    apply CoordinateWreath.ext
    · funext i
      apply Subtype.ext
      exact congrArg (fun w : CoordinateWreath A I => w.component i) (map_one f)
    · change (f 1).permutation = 1
      exact congrArg CoordinateWreath.permutation (map_one f)
  map_mul' g h := by
    apply CoordinateWreath.ext
    · funext i
      apply Subtype.ext
      exact congrArg (fun w : CoordinateWreath A I => w.component i) (map_mul f g h)
    · change (f (g * h)).permutation = (f g * f h).permutation
      exact congrArg CoordinateWreath.permutation (map_mul f g h)

@[simp] theorem restrictComponents_component (X : Subgroup A)
    (f : G →* CoordinateWreath A I)
    (hcomponent : ∀ g : G, ∀ i : I, (f g).component i ∈ X)
    (g : G) (i : I) :
    ((restrictComponents X f hcomponent g).component i : A) =
      (f g).component i := rfl

@[simp] theorem restrictComponents_permutation (X : Subgroup A)
    (f : G →* CoordinateWreath A I)
    (hcomponent : ∀ g : G, ∀ i : I, (f g).component i ∈ X)
    (g : G) :
    (restrictComponents X f hcomponent g).permutation =
      (f g).permutation := rfl

/-- The normalized homomorphism with its components restricted to the exact
coordinate closure. -/
noncomputable def restrictedNormalizedHom
    (K : Subgroup A) (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) :
    G →* CoordinateWreath (closure K rho base) I :=
  restrictComponents (closure K rho base) (normalizedHom rho base htrans)
    (normalized_component_mem_closure K rho base htrans)

@[simp] theorem restrictedNormalizedHom_permutation
    (K : Subgroup A) (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (g : G) :
    (restrictedNormalizedHom K rho base htrans g).permutation =
      (rho g).permutation := by
  simp [restrictedNormalizedHom]

@[simp] theorem restrictedNormalizedHom_component
    (K : Subgroup A) (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i)
    (g : G) (i : I) :
    ((restrictedNormalizedHom K rho base htrans g).component i : A) =
      (normalizedHom rho base htrans g).component i := rfl

/-- Conjugation detects the identity exactly. -/
theorem inv_mul_mul_eq_one_iff {H : Type*} [Group H] (a b : H) :
    a⁻¹ * b * a = 1 ↔ b = 1 := by
  constructor
  · intro h
    calc
      b = a * (a⁻¹ * b * a) * a⁻¹ := by simp [mul_assoc]
      _ = 1 := by rw [h]; simp
  · intro h
    subst b
    simp

/-- Quotienting the normalized realization by the normal base subgroup has
the same kernel as quotienting the original realization. -/
theorem normalized_quotient_eq_one_iff
    (K : Subgroup A) [K.Normal]
    (rho : G →* CoordinateWreath A I) (base : I)
    (htrans : ∀ i : I, ∃ g : G, (rho g).permutation base = i) (g : G) :
    CoordinateWreath.quotientMap (I := I) K
        (normalizedHom rho base htrans g) = 1 ↔
      CoordinateWreath.quotientMap (I := I) K (rho g) = 1 := by
  rw [normalizedHom_apply]
  simp only [map_mul, map_inv]
  exact inv_mul_mul_eq_one_iff _ _

/-- Exact coordinate-order bound.  The hypothesis `hbase` is the structural
wreath realization's identification of `N`: an element lies in `N` exactly
when its top permutation is trivial and all base components lie in `K`.

In the manuscript application, `A = Aut(S)`, `K = Inn(S)`, and the exact
published `Aut(S^k)` wreath theorem supplies `rho`, transitivity, and `hbase`.
Everything after those inputs--the transporter normalization, construction of
`X`, and the divisor `|G/N| ∣ |X/K|^k k!`--is kernel checked here. -/
theorem normalized_coordinate_quotient_bound
    {G A : Type*} [Group G] [Group A] [Finite G] [Finite A]
    (N : Subgroup G) [N.Normal]
    (K : Subgroup A) [K.Normal]
    (k : ℕ) (rho : G →* CoordinateWreath A (Fin k)) (base : Fin k)
    (htrans : ∀ i : Fin k, ∃ g : G, (rho g).permutation base = i)
    (hbase : ∀ g : G, g ∈ N ↔
      (rho g).permutation = 1 ∧ ∀ i, (rho g).component i ∈ K) :
    let X := closure K rho base
    let KX := K.comap X.subtype
    Nat.card (G ⧸ N) ∣ Nat.card (X ⧸ KX) ^ k * k.factorial := by
  let X := closure K rho base
  let KX : Subgroup X := K.comap X.subtype
  letI : KX.Normal := inferInstance
  let rhoX : G →* CoordinateWreath X (Fin k) :=
    restrictedNormalizedHom K rho base htrans
  let f : G →* CoordinateWreath (X ⧸ KX) (Fin k) :=
    (CoordinateWreath.quotientMap KX).comp rhoX
  have hker : f.ker = N := by
    ext g
    rw [MonoidHom.mem_ker]
    change CoordinateWreath.quotientMap KX (rhoX g) = 1 ↔ g ∈ N
    rw [CoordinateWreath.quotientMap_eq_one_iff]
    rw [hbase]
    have hnorm :
        CoordinateWreath.quotientMap (I := Fin k) K
            (normalizedHom rho base htrans g) = 1 ↔
          CoordinateWreath.quotientMap (I := Fin k) K (rho g) = 1 :=
      normalized_quotient_eq_one_iff K rho base htrans g
    rw [CoordinateWreath.quotientMap_eq_one_iff,
        CoordinateWreath.quotientMap_eq_one_iff] at hnorm
    constructor
    · rintro ⟨hperm, hcomp⟩
      have hnormleft :
          (normalizedHom rho base htrans g).permutation = 1 ∧
            ∀ i, (normalizedHom rho base htrans g).component i ∈ K := by
        refine ⟨?_, ?_⟩
        · change (normalizedHom rho base htrans g).permutation = 1 at hperm
          exact hperm
        · intro i
          exact hcomp i
      exact hnorm.mp hnormleft
    · intro horig
      have hnormleft := hnorm.mpr horig
      refine ⟨?_, ?_⟩
      · change (normalizedHom rho base htrans g).permutation = 1
        exact hnormleft.1
      · intro i
        exact hnormleft.2 i
  exact CoordinateWreath.quotient_card_dvd_wreath_card_fin N k f hker

end CoordinateNormalization

end Kourovka1034
