import Comparator.Challenge
import Kourovka1034.ProductSupplements

/-!
# Comparator solution: the project theorem

The theorem below has the independently stated challenge proposition exactly.
Its proof is the project's kernel-checked product-supplement theorem. The final
unnamed example elaborates only when the challenge and solution declarations
have definitionally identical types; proof irrelevance then closes the term
comparison.
-/

namespace Kourovka1034.Comparator.Solution

open Kourovka1034

theorem conditionalProductSupplementSpine
    {G : Type*} [Group G] [Finite G]
    {p d k t x s v w : ℕ}
    (A B : Subgroup G)
    (hp : p.Prime) (hk : 2 ≤ k)
    (hAmax : IsCoatom A) (hBmax : IsCoatom B)
    (hnconj : ¬ ∃ g : G, ∀ y : G, y ∈ B ↔ g * y * g⁻¹ ∈ A)
    (ht : 0 < t) (hx : x ≠ 0) (hs : s ≠ 0)
    (hv : v ≠ 0) (hw : w ≠ 0)
    (hcardG : Nat.card G = t * s ^ k)
    (hcardA : Nat.card A = t * v ^ k)
    (hcardB : Nat.card B = t * w ^ k)
    (hd : padicValNat p s =
      padicValNat p v + padicValNat p w + d)
    (hTop : t ∣ x ^ k * k.factorial)
    (hGap : padicValNat p x < d) :
    ¬ (∀ C D : Subgroup G, IsCoatom C → IsCoatom D →
      (¬ ∃ g : G, ∀ y : G, y ∈ D ↔ g * y * g⁻¹ ∈ C) →
      ∀ y : G, ∃ c : G, c ∈ C ∧ ∃ e : G, e ∈ D ∧ y = c * e) := by
  simpa only [PropertyP, AreConjugateSubgroups, SubgroupFactorization] using
    no_propertyP_of_product_supplement_data A B hp hk hAmax hBmax hnconj
      ht hx hs hv hw hcardG hcardA hcardB hd hTop hGap

end Kourovka1034.Comparator.Solution

/-- Elaboration is the proposition-comparison check: the two theorem constants
must have exactly the same type before proof irrelevance can be applied. -/
example :
    @Kourovka1034.Comparator.Challenge.conditionalProductSupplementSpine =
    @Kourovka1034.Comparator.Solution.conditionalProductSupplementSpine :=
  Subsingleton.elim _ _
