import Mathlib.Algebra.Group.Subgroup.Order
import Mathlib.GroupTheory.QuotientGroup.Basic

/-!
# The factorization property and quotients

This file gives the manuscript's property P an exact group-theoretic
statement and proves that it passes through every surjective group
homomorphism, hence in particular to every quotient.  Maximal subgroups are
`IsCoatom` elements of the subgroup lattice; conjugacy and setwise
factorization are written elementwise to avoid any hidden finiteness or
cardinality assumptions.
-/

namespace Kourovka1034

/-- Two subgroups are conjugate when one is obtained from the other by one
inner conjugation.  The displayed orientation is immaterial, but is fixed here
so that the definition can be unfolded literally in quotient arguments. -/
def AreConjugateSubgroups {G : Type*} [Group G]
    (A B : Subgroup G) : Prop :=
  ∃ g : G, ∀ x : G, x ∈ B ↔ g * x * g⁻¹ ∈ A

/-- The underlying group is the setwise product `A B`. -/
def SubgroupFactorization {G : Type*} [Group G]
    (A B : Subgroup G) : Prop :=
  ∀ x : G, ∃ a : G, a ∈ A ∧ ∃ b : G, b ∈ B ∧ x = a * b

/-- Property P from Kourovka Problem 10.34: every pair of non-conjugate
maximal subgroups factorizes the whole group. -/
def PropertyP (G : Type*) [Group G] : Prop :=
  ∀ A B : Subgroup G, IsCoatom A → IsCoatom B →
    ¬ AreConjugateSubgroups A B → SubgroupFactorization A B

/-- Conjugacy of the full preimages of two subgroups under a surjection forces
conjugacy of the two subgroups downstairs. -/
theorem areConjugateSubgroups_of_comap_of_surjective
    {G H : Type*} [Group G] [Group H]
    (φ : G →* H) (hφ : Function.Surjective φ)
    {A B : Subgroup H}
    (h : AreConjugateSubgroups (A.comap φ) (B.comap φ)) :
    AreConjugateSubgroups A B := by
  rcases h with ⟨g, hg⟩
  refine ⟨φ g, ?_⟩
  intro y
  obtain ⟨x, rfl⟩ := hφ y
  simpa only [Subgroup.mem_comap, map_mul, map_inv] using hg x

/-- Property P descends along every surjective homomorphism. -/
theorem propertyP_of_surjective
    {G H : Type*} [Group G] [Group H]
    (φ : G →* H) (hφ : Function.Surjective φ)
    (hP : PropertyP G) : PropertyP H := by
  intro A B hA hB hnconj
  have hA' : IsCoatom (A.comap φ) :=
    Subgroup.isCoatom_comap_of_surjective hφ hA
  have hB' : IsCoatom (B.comap φ) :=
    Subgroup.isCoatom_comap_of_surjective hφ hB
  have hnconj' : ¬ AreConjugateSubgroups (A.comap φ) (B.comap φ) := by
    intro h
    exact hnconj (areConjugateSubgroups_of_comap_of_surjective φ hφ h)
  have hFactors := hP (A.comap φ) (B.comap φ) hA' hB' hnconj'
  intro y
  obtain ⟨x, rfl⟩ := hφ y
  obtain ⟨a, ha, b, hb, hab⟩ := hFactors x
  refine ⟨φ a, ha, φ b, hb, ?_⟩
  rw [hab, map_mul]

/-- Manuscript Lemma 2.2: property P passes to a quotient by a normal
subgroup. -/
theorem propertyP_quotient
    {G : Type*} [Group G] (N : Subgroup G) [N.Normal]
    (hP : PropertyP G) : PropertyP (G ⧸ N) :=
  propertyP_of_surjective (QuotientGroup.mk' N)
    (QuotientGroup.mk'_surjective N) hP

end Kourovka1034
