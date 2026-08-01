import Kourovka1034.Divisibility
import Kourovka1034.Property
import Mathlib.Algebra.Group.Subgroup.Finite
import Mathlib.Algebra.Group.Subgroup.Pointwise
import Mathlib.GroupTheory.Index
import Mathlib.NumberTheory.Padics.PadicVal.Basic

/-!
# Product supplements and the group-to-arithmetic bridge

This file formalizes four exact pieces of the manuscript's supplement
machinery.

* The exact coordinate-product construction in a normalized wreath-action
  model, including the derivation of the ambient orbit premise from
  `X`-stability.
* An abstract Frattini-normalizer theorem: if every ambient conjugate of a
  subgroup can be returned by an element of a normal subgroup, its normalizer
  supplements that normal subgroup.
* The exact normalizer intersection and order when the subgroup is
  self-normalizing inside the normal subgroup.
* The finite subgroup-product cardinality formula and the resulting
  prime-power divisibility forced by Property P.

The reduction which constructs the normalized coordinate-action model remains
a separate explicit obligation in `FORMAL-COVERAGE.json`; the maximality
argument using that model is checked in `Maximality.lean`.
-/

namespace Kourovka1034

/-- Normalizers commute with unrestricted direct products. -/
theorem normalizer_pi_univ
    {I S : Type*} [DecidableEq I] [Group S] (V : Subgroup S) :
    Subgroup.normalizer
        (Subgroup.pi Set.univ (fun _ : I => V) : Set (I → S)) =
      Subgroup.pi Set.univ (fun _ : I => Subgroup.normalizer (V : Set S)) := by
  ext n
  constructor
  · intro hn
    apply (Subgroup.mem_pi Set.univ).2
    intro i _
    apply Subgroup.mem_normalizer_iff.mpr
    intro v
    let a : I → S := Function.update (fun _ => 1) i v
    have h := (Subgroup.mem_normalizer_iff.mp hn) a
    constructor
    · intro hv
      have ha : a ∈ Subgroup.pi Set.univ (fun _ : I => V) := by
        apply (Subgroup.mem_pi Set.univ).2
        intro j _
        by_cases hji : j = i
        · subst j
          simpa [a] using hv
        · simp [a, hji]
      have hc := h.mp ha
      have hci := (Subgroup.mem_pi Set.univ).mp hc i (Set.mem_univ i)
      simpa [a] using hci
    · intro hv
      have hc : n * a * n⁻¹ ∈ Subgroup.pi Set.univ (fun _ : I => V) := by
        apply (Subgroup.mem_pi Set.univ).2
        intro j _
        by_cases hji : j = i
        · subst j
          simpa [a] using hv
        · simp [a, hji]
      have ha := h.mpr hc
      have hai := (Subgroup.mem_pi Set.univ).mp ha i (Set.mem_univ i)
      simpa [a] using hai
  · intro hn
    apply Subgroup.mem_normalizer_iff.mpr
    intro a
    constructor
    · intro ha
      apply (Subgroup.mem_pi Set.univ).2
      intro i _
      have hni := (Subgroup.mem_pi Set.univ).mp hn i (Set.mem_univ i)
      have hai := (Subgroup.mem_pi Set.univ).mp ha i (Set.mem_univ i)
      exact (Subgroup.mem_normalizer_iff.mp hni (a i)).mp hai
    · intro ha
      apply (Subgroup.mem_pi Set.univ).2
      intro i _
      have hni := (Subgroup.mem_pi Set.univ).mp hn i (Set.mem_univ i)
      have hai := (Subgroup.mem_pi Set.univ).mp ha i (Set.mem_univ i)
      exact (Subgroup.mem_normalizer_iff.mp hni (a i)).mpr hai

/-- Coordinatewise identification of the full product subgroup with a
function into the subgroup. -/
def piSubgroupMulEquiv
    {I S : Type*} [Group S] (V : Subgroup S) :
    Subgroup.pi Set.univ (fun _ : I => V) ≃* (I → V) where
  toFun a i := ⟨a.1 i, (Subgroup.mem_pi Set.univ).mp a.2 i (Set.mem_univ i)⟩
  invFun f := ⟨fun i => (f i : S),
    (Subgroup.mem_pi Set.univ).2 fun i _ => (f i).2⟩
  left_inv a := by ext i; rfl
  right_inv f := by ext i; rfl
  map_mul' a b := by ext i; rfl

/-- Exact order of `V^k`. -/
theorem card_pi_subgroup_fin
    {S : Type*} [Group S] [Finite S] (V : Subgroup S) (k : ℕ) :
    Nat.card (Subgroup.pi Set.univ (fun _ : Fin k => V)) = Nat.card V ^ k := by
  rw [Nat.card_congr (piSubgroupMulEquiv V).toEquiv, Nat.card_fun]
  simp

/-- A self-normalizing subgroup has self-normalizing full coordinate powers. -/
theorem normalizer_pi_eq_self
    {I S : Type*} [DecidableEq I] [Group S] (V : Subgroup S)
    (hself : Subgroup.normalizer (V : Set S) = V) :
    Subgroup.normalizer
        (Subgroup.pi Set.univ (fun _ : I => V) : Set (I → S)) =
      Subgroup.pi Set.univ (fun _ : I => V) := by
  rw [normalizer_pi_univ, hself]

/-- If every ambient conjugate of `A` can be returned to `A` by an element
of the normal subgroup `N`, then the normalizer of `A` supplements `N`.

The orbit premise is written elementwise.  For the paper's application it is
the precise conclusion obtained from `X`-stability after setting
`A = V^k` and `N = S^k`. -/
theorem normalizer_sup_eq_top_of_conjugates
    {G : Type*} [Group G]
    (N A : Subgroup G) [N.Normal]
    (horbit : ∀ g : G, ∃ n : N, ∀ a : G,
      a ∈ A ↔ (n : G)⁻¹ * g * a * g⁻¹ * (n : G) ∈ A) :
    Subgroup.normalizer (A : Set G) ⊔ N = (⊤ : Subgroup G) := by
  apply top_unique
  intro g _
  obtain ⟨n, hn⟩ := horbit g
  let b : G := (n : G)⁻¹ * g
  have hb : b ∈ Subgroup.normalizer (A : Set G) := by
    rw [Subgroup.mem_normalizer_iff]
    intro a
    simpa [b, mul_assoc] using hn a
  have hnmem : (n : G) ∈ N := n.property
  have hprod : (n : G) * b ∈ Subgroup.normalizer (A : Set G) ⊔ N :=
    (Subgroup.normalizer (A : Set G) ⊔ N).mul_mem
      ((show N ≤ Subgroup.normalizer (A : Set G) ⊔ N from le_sup_right) hnmem)
      ((show Subgroup.normalizer (A : Set G) ≤
          Subgroup.normalizer (A : Set G) ⊔ N from le_sup_left) hb)
  simpa [b, mul_assoc] using hprod

/-- Self-normalization inside `N` identifies the intersection of the ambient
normalizer with `N`. -/
theorem normalizer_inf_eq_of_self_normalizing_in
    {G : Type*} [Group G]
    (N A : Subgroup G) (hAN : A ≤ N)
    (hself : Subgroup.normalizer (A.subgroupOf N : Set N) = A.subgroupOf N) :
    Subgroup.normalizer (A : Set G) ⊓ N = A := by
  have hsub :
      (Subgroup.normalizer (A : Set G)).subgroupOf N = A.subgroupOf N := by
    rw [Subgroup.subgroupOf_normalizer_eq hAN, hself]
  have hi := Subgroup.subgroupOf_inj.mp hsub
  simpa [inf_eq_left.mpr hAN] using hi

/-- Exact normalizer order in the abstract Frattini situation.  In the
manuscript, `A = V^k`, `N = S^k`, and `Nat.card (G ⧸ N) = t`. -/
theorem card_normalizer_eq_card_quotient_mul_card
    {G : Type*} [Group G] [Finite G]
    (N A : Subgroup G) [N.Normal] (hAN : A ≤ N)
    (horbit : ∀ g : G, ∃ n : N, ∀ a : G,
      a ∈ A ↔ (n : G)⁻¹ * g * a * g⁻¹ * (n : G) ∈ A)
    (hself : Subgroup.normalizer (A.subgroupOf N : Set N) = A.subgroupOf N) :
    Nat.card (Subgroup.normalizer (A : Set G)) =
      Nat.card (G ⧸ N) * Nat.card A := by
  let B : Subgroup G := Subgroup.normalizer (A : Set G)
  have hsup : B ⊔ N = (⊤ : Subgroup G) :=
    normalizer_sup_eq_top_of_conjugates N A horbit
  have hinf : B ⊓ N = A :=
    normalizer_inf_eq_of_self_normalizing_in N A hAN hself
  let f : B →* G ⧸ N := (QuotientGroup.mk' N).comp B.subtype
  have hf : Function.Surjective f := by
    intro q
    obtain ⟨g, rfl⟩ := QuotientGroup.mk'_surjective N q
    have hg : g ∈ B ⊔ N := by rw [hsup]; trivial
    change g ∈ (↑(B ⊔ N) : Set G) at hg
    rw [Subgroup.mul_normal] at hg
    obtain ⟨b, hb, n, hn, rfl⟩ := hg
    refine ⟨⟨b, hb⟩, ?_⟩
    change (b : G ⧸ N) = ((b * n : G) : G ⧸ N)
    rw [QuotientGroup.mk_mul, (QuotientGroup.eq_one_iff n).mpr hn, mul_one]
  have hAB : A ≤ B := by
    intro a ha
    exact Subgroup.le_normalizer ha
  have hker : f.ker = A.subgroupOf B := by
    calc
      f.ker = N.comap B.subtype := by
        change ((QuotientGroup.mk' N).comp B.subtype).ker = N.comap B.subtype
        rw [← MonoidHom.comap_ker, QuotientGroup.ker_mk']
      _ = N.subgroupOf B := Subgroup.comap_subtype N B
      _ = A.subgroupOf B := by
        apply Subgroup.subgroupOf_inj.mpr
        rw [inf_comm N B, hinf, inf_eq_left.mpr]
        exact hAB
  have hkerCard : Nat.card f.ker = Nat.card A := by
    rw [hker]
    exact Nat.card_congr (Subgroup.subgroupOfEquivOfLe hAB).toEquiv
  have hrange : f.range = ⊤ := MonoidHom.range_eq_top.mpr hf
  calc
    Nat.card B = Nat.card f.ker * f.ker.index := f.ker.card_mul_index.symm
    _ = Nat.card f.ker * Nat.card f.range := by rw [Subgroup.index_ker]
    _ = Nat.card A * Nat.card (G ⧸ N) := by
      rw [hkerCard, hrange, Subgroup.card_top]
    _ = Nat.card (G ⧸ N) * Nat.card A := Nat.mul_comm _ _

/-- The copy of `V^I` inside `G`, constructed from a chosen coordinate
equivalence `N ≃* (I → S)`.  No ambient subgroup is postulated: it is the
image under the injective inclusion `N → G` of the coordinatewise product. -/
def coordinateProductSubgroup
    {G S I : Type*} [Group G] [Group S]
    (N : Subgroup G) (coord : N ≃* (I → S)) (V : Subgroup S) : Subgroup G :=
  ((Subgroup.pi Set.univ (fun _ : I => V)).comap coord.toMonoidHom).map N.subtype

/-- The constructed coordinate product lies in `N`. -/
theorem coordinateProductSubgroup_le
    {G S I : Type*} [Group G] [Group S]
    (N : Subgroup G) (coord : N ≃* (I → S)) (V : Subgroup S) :
    coordinateProductSubgroup N coord V ≤ N := by
  exact Subgroup.map_subtype_le _

/-- Membership in the constructed subgroup is exactly coordinatewise
membership in `V`. -/
theorem mem_coordinateProductSubgroup
    {G S I : Type*} [Group G] [Group S]
    (N : Subgroup G) (coord : N ≃* (I → S)) (V : Subgroup S) (z : N) :
    (z : G) ∈ coordinateProductSubgroup N coord V ↔ ∀ i, coord z i ∈ V := by
  rw [coordinateProductSubgroup, Subgroup.mem_map]
  constructor
  · rintro ⟨w, hw, heq⟩
    have hwz : w = z := Subtype.ext heq
    subst w
    intro i
    exact (Subgroup.mem_pi Set.univ).mp hw i (Set.mem_univ i)
  · intro hz
    refine ⟨z, (Subgroup.mem_pi Set.univ).2 (fun i _ => hz i), rfl⟩

/-- In the normalized coordinate model, `X`-stability makes every ambient
conjugate of `V^I` returnable by an element of `N`.

`sigma` is the coordinate permutation and `component g i` is the automorphism
of `S` appearing in coordinate `i` when `g` conjugates `N`; thus output
coordinate `i` reads input coordinate `(sigma g).symm i`.  The two action
hypotheses are exactly the data obtained by unfolding `G ≤ X ≀ Sym(I)`; their
construction belongs to the separate coordinate-reduction obligation. -/
theorem coordinate_orbit_of_stable_components
    {G S I : Type*} [Group G] [Group S]
    (N A : Subgroup G) [N.Normal] (V : Subgroup S)
    (hAN : A ≤ N)
    (coord : N ≃* (I → S))
    (X : Subgroup (MulAut S))
    (sigma : G →* Equiv.Perm I)
    (component : G → I → MulAut S)
    (hcomponent : ∀ g i, component g i ∈ X)
    (haction : ∀ g (z : N) i,
      coord (MulAut.conjNormal g z) i =
        component g i (coord z ((sigma g).symm i)))
    (hA : ∀ z : N, (z : G) ∈ A ↔ ∀ i, coord z i ∈ V)
    (hstable : ∀ a : MulAut S, a ∈ X → ∃ s : S, ∀ y : S,
      y ∈ V ↔ s⁻¹ * a y * s ∈ V) :
    ∀ g : G, ∃ n : N, ∀ a : G,
      a ∈ A ↔ (n : G)⁻¹ * g * a * g⁻¹ * (n : G) ∈ A := by
  intro g
  choose s hs using fun i => hstable (component g i) (hcomponent g i)
  let n : N := coord.symm (fun i => s i)
  refine ⟨n, ?_⟩
  intro a
  constructor
  · intro ha
    let za : N := ⟨a, hAN ha⟩
    let rhsN : N := n⁻¹ * MulAut.conjNormal g za * n
    have hcoe : (rhsN : G) = (n : G)⁻¹ * g * a * g⁻¹ * (n : G) := by
      simp [rhsN, za, mul_assoc, MulAut.conjNormal_apply]
    rw [← hcoe]
    apply (hA rhsN).2
    intro i
    have hza : coord za ((sigma g).symm i) ∈ V :=
      (hA za).mp (by simpa [za] using ha) ((sigma g).symm i)
    have hc : coord rhsN i =
        (s i)⁻¹ * component g i (coord za ((sigma g).symm i)) * s i := by
      simp [rhsN, n, haction, mul_assoc]
    rw [hc]
    exact (hs i (coord za ((sigma g).symm i))).mp hza
  · intro hrhs
    let h : G := (n : G)⁻¹ * g
    have hrhsN : (n : G)⁻¹ * g * a * g⁻¹ * (n : G) ∈ N := hAN hrhs
    have haN : a ∈ N := by
      have hc := (inferInstance : N.Normal).conj_mem'
        ((n : G)⁻¹ * g * a * g⁻¹ * (n : G)) hrhsN h
      simpa [h, mul_assoc] using hc
    let za : N := ⟨a, haN⟩
    let rhsN : N := n⁻¹ * MulAut.conjNormal g za * n
    have hcoe : (rhsN : G) = (n : G)⁻¹ * g * a * g⁻¹ * (n : G) := by
      simp [rhsN, za, mul_assoc, MulAut.conjNormal_apply]
    have hrhs' : (rhsN : G) ∈ A := by simpa [hcoe] using hrhs
    have hcoords := (hA rhsN).mp hrhs'
    have hza : ∀ j, coord za j ∈ V := by
      intro j
      let i : I := sigma g j
      have hc : coord rhsN i =
          (s i)⁻¹ * component g i (coord za ((sigma g).symm i)) * s i := by
        simp [rhsN, n, haction, mul_assoc]
      have hv : (s i)⁻¹ * component g i (coord za ((sigma g).symm i)) * s i ∈ V := by
        rw [← hc]
        exact hcoords i
      have := (hs i (coord za ((sigma g).symm i))).mpr hv
      simpa [i] using this
    have : (za : G) ∈ A := (hA za).2 hza
    simpa [za] using this

/-- Coordinatewise self-normalization transports through the chosen
equivalence `N ≃* (I → S)`. -/
theorem coordinate_product_self_normalizing
    {G S I : Type*} [Group G] [Group S] [DecidableEq I]
    (N A : Subgroup G) (V : Subgroup S)
    (coord : N ≃* (I → S))
    (hA : ∀ z : N, (z : G) ∈ A ↔ ∀ i, coord z i ∈ V)
    (hself : Subgroup.normalizer (V : Set S) = V) :
    Subgroup.normalizer (A.subgroupOf N : Set N) = A.subgroupOf N := by
  let P : Subgroup (I → S) := Subgroup.pi Set.univ (fun _ : I => V)
  have hmap : (A.subgroupOf N).map coord.toMonoidHom = P := by
    ext f
    rw [Subgroup.mem_map_equiv, Subgroup.mem_subgroupOf, hA]
    simp [P, Subgroup.mem_pi]
  apply (Subgroup.map_injective (f := coord.toMonoidHom) coord.injective)
  calc
    (Subgroup.normalizer (A.subgroupOf N : Set N)).map coord.toMonoidHom =
        Subgroup.normalizer ((A.subgroupOf N).map coord.toMonoidHom : Set (I → S)) :=
      Subgroup.map_equiv_normalizer_eq (A.subgroupOf N) coord
    _ = Subgroup.normalizer (P : Set (I → S)) := by rw [hmap]
    _ = P := normalizer_pi_eq_self V hself
    _ = (A.subgroupOf N).map coord.toMonoidHom := hmap.symm

/-- Exact order of a coordinate product transported into the ambient group. -/
theorem card_coordinateProductSubgroup
    {G S : Type*} [Group G] [Group S] [Finite S]
    (N A : Subgroup G) (V : Subgroup S) (hAN : A ≤ N)
    (k : ℕ) (coord : N ≃* (Fin k → S))
    (hA : ∀ z : N, (z : G) ∈ A ↔ ∀ i, coord z i ∈ V) :
    Nat.card A = Nat.card V ^ k := by
  let P : Subgroup (Fin k → S) := Subgroup.pi Set.univ (fun _ : Fin k => V)
  have hmap : (A.subgroupOf N).map coord.toMonoidHom = P := by
    ext f
    rw [Subgroup.mem_map_equiv, Subgroup.mem_subgroupOf, hA]
    simp [P, Subgroup.mem_pi]
  calc
    Nat.card A = Nat.card (A.subgroupOf N) :=
      (Nat.card_congr (Subgroup.subgroupOfEquivOfLe hAN).symm.toEquiv)
    _ = Nat.card ((A.subgroupOf N).map coord.toMonoidHom) :=
      Nat.card_congr (coord.subgroupMap (A.subgroupOf N)).toEquiv
    _ = Nat.card P := by rw [hmap]
    _ = Nat.card V ^ k := card_pi_subgroup_fin V k

/-- Exact formal version of manuscript Lemma 3.2 (Existence), conditional on
the normalized coordinate-action data supplied by Convention 2.4.

For the constructed `A = V^k`, its ambient normalizer intersects `N` in
`A`, supplements `N`, and has order
`|G/N| * |V|^k`. -/
theorem coordinate_product_normalizer_data
    {G S : Type*} [Group G] [Group S] [Finite G] [Finite S]
    (N : Subgroup G) [N.Normal] (V : Subgroup S) (k : ℕ)
    (coord : N ≃* (Fin k → S))
    (X : Subgroup (MulAut S))
    (sigma : G →* Equiv.Perm (Fin k))
    (component : G → Fin k → MulAut S)
    (hcomponent : ∀ g i, component g i ∈ X)
    (haction : ∀ g (z : N) i,
      coord (MulAut.conjNormal g z) i =
        component g i (coord z ((sigma g).symm i)))
    (hstable : ∀ a : MulAut S, a ∈ X → ∃ s : S, ∀ y : S,
      y ∈ V ↔ s⁻¹ * a y * s ∈ V)
    (hself : Subgroup.normalizer (V : Set S) = V) :
    let A := coordinateProductSubgroup N coord V
    Subgroup.normalizer (A : Set G) ⊓ N = A ∧
      Subgroup.normalizer (A : Set G) ⊔ N = (⊤ : Subgroup G) ∧
      Nat.card (Subgroup.normalizer (A : Set G)) =
        Nat.card (G ⧸ N) * Nat.card V ^ k := by
  let A := coordinateProductSubgroup N coord V
  have hAN : A ≤ N := coordinateProductSubgroup_le N coord V
  have hA : ∀ z : N, (z : G) ∈ A ↔ ∀ i, coord z i ∈ V :=
    mem_coordinateProductSubgroup N coord V
  have horbit := coordinate_orbit_of_stable_components N A V hAN coord X
    sigma component hcomponent haction hA hstable
  have hselfA := coordinate_product_self_normalizing N A V coord hA hself
  have hinf := normalizer_inf_eq_of_self_normalizing_in N A hAN hselfA
  have hsup := normalizer_sup_eq_top_of_conjugates N A horbit
  have hcard := card_normalizer_eq_card_quotient_mul_card N A hAN horbit hselfA
  have hcardA := card_coordinateProductSubgroup N A V hAN k coord hA
  refine ⟨hinf, hsup, ?_⟩
  rw [hcard, hcardA]

/-- Exact formal version of manuscript Lemma 3.4 (Non-conjugacy), conditional
on the same normalized coordinate-action data.

If `V` and `W` are self-normalizing and represent distinct `S`-conjugacy
classes, then the ambient normalizers of their coordinate products are not
conjugate in `G`.  The proof extracts one coordinate from a hypothetical
ambient conjugacy and uses `X`-stability to turn it into an `S`-conjugacy. -/
theorem coordinate_product_normalizers_nonconjugate
    {G S I : Type*} [Group G] [Group S] [DecidableEq I] [Nonempty I]
    (N : Subgroup G) [N.Normal] (V W : Subgroup S)
    (coord : N ≃* (I → S))
    (X : Subgroup (MulAut S))
    (sigma : G →* Equiv.Perm I)
    (component : G → I → MulAut S)
    (hcomponent : ∀ g i, component g i ∈ X)
    (haction : ∀ g (z : N) i,
      coord (MulAut.conjNormal g z) i =
        component g i (coord z ((sigma g).symm i)))
    (hstableW : ∀ a : MulAut S, a ∈ X → ∃ s : S, ∀ y : S,
      y ∈ W ↔ s⁻¹ * a y * s ∈ W)
    (hselfV : Subgroup.normalizer (V : Set S) = V)
    (hselfW : Subgroup.normalizer (W : Set S) = W)
    (hdistinct : ¬ AreConjugateSubgroups W V) :
    let AV := coordinateProductSubgroup N coord V
    let AW := coordinateProductSubgroup N coord W
    ¬ AreConjugateSubgroups
      (Subgroup.normalizer (AV : Set G)) (Subgroup.normalizer (AW : Set G)) := by
  let AV := coordinateProductSubgroup N coord V
  let AW := coordinateProductSubgroup N coord W
  let BV := Subgroup.normalizer (AV : Set G)
  let BW := Subgroup.normalizer (AW : Set G)
  have hAVN : AV ≤ N := coordinateProductSubgroup_le N coord V
  have hAWN : AW ≤ N := coordinateProductSubgroup_le N coord W
  have hmemV : ∀ z : N, (z : G) ∈ AV ↔ ∀ i, coord z i ∈ V :=
    mem_coordinateProductSubgroup N coord V
  have hmemW : ∀ z : N, (z : G) ∈ AW ↔ ∀ i, coord z i ∈ W :=
    mem_coordinateProductSubgroup N coord W
  have hselfAV := coordinate_product_self_normalizing N AV V coord hmemV hselfV
  have hselfAW := coordinate_product_self_normalizing N AW W coord hmemW hselfW
  have hinfV : BV ⊓ N = AV :=
    normalizer_inf_eq_of_self_normalizing_in N AV hAVN hselfAV
  have hinfW : BW ⊓ N = AW :=
    normalizer_inf_eq_of_self_normalizing_in N AW hAWN hselfAW
  change ¬ AreConjugateSubgroups BV BW
  intro hconj
  rcases hconj with ⟨g, hg⟩
  have hV (z : N) : (z : G) ∈ AV ↔ (z : G) ∈ BV := by
    rw [← hinfV]
    simp [BV]
  have hW (z : N) : (z : G) ∈ AW ↔ (z : G) ∈ BW := by
    rw [← hinfW]
    simp [BW]
  have hprod (z : N) :
      (z : G) ∈ AW ↔ (((MulAut.conjNormal g) z : N) : G) ∈ AV := by
    let q : N := MulAut.conjNormal g z
    calc
      (z : G) ∈ AW ↔ (z : G) ∈ BW := hW z
      _ ↔ g * (z : G) * g⁻¹ ∈ BV := hg (z : G)
      _ ↔ (q : G) ∈ BV := by simp [q, MulAut.conjNormal_apply]
      _ ↔ (q : G) ∈ AV := (hV q).symm
  let i0 : I := Classical.choice (inferInstance : Nonempty I)
  let j : I := (sigma g).symm i0
  have hyiff (y : S) : y ∈ W ↔ component g i0 y ∈ V := by
    let base : I → S := Function.update (fun _ => 1) j y
    let z : N := coord.symm base
    constructor
    · intro hy
      have hzW : (z : G) ∈ AW := by
        apply (hmemW z).2
        intro l
        by_cases hlj : l = j
        · subst l
          simpa [z, base] using hy
        · simp [z, base, hlj]
      have hzgV := (hprod z).mp hzW
      have hi := (hmemV (MulAut.conjNormal g z)).mp hzgV i0
      rw [haction] at hi
      simpa [z, base, j] using hi
    · intro hay
      have hzgV : (((MulAut.conjNormal g) z : N) : G) ∈ AV := by
        apply (hmemV (MulAut.conjNormal g z)).2
        intro l
        rw [haction]
        by_cases hli : l = i0
        · subst l
          simpa [z, base, j] using hay
        · have hperm : (sigma g).symm l ≠ j := by
            intro heq
            apply hli
            exact (sigma g).symm.injective (by simpa [j] using heq)
          simp [z, base, hperm]
      have hzW := (hprod z).mpr hzgV
      have hj := (hmemW z).mp hzW j
      simpa [z, base, j] using hj
  obtain ⟨s, hs⟩ := hstableW (component g i0) (hcomponent g i0)
  apply hdistinct
  refine ⟨s⁻¹, ?_⟩
  intro y
  have h1 : y ∈ V ↔ (component g i0).symm y ∈ W := by
    simpa using (hyiff ((component g i0).symm y)).symm
  calc
    y ∈ V ↔ (component g i0).symm y ∈ W := h1
    _ ↔ s⁻¹ * component g i0 ((component g i0).symm y) * s ∈ W :=
      hs ((component g i0).symm y)
    _ ↔ s⁻¹ * y * s ∈ W := by simp
    _ ↔ (s⁻¹) * y * (s⁻¹)⁻¹ ∈ W := by simp

/-- Cancellation of the nonzero quotient order `t` from the exact order
identity that arises from a product factorization. -/
theorem cancel_quotient_order
    {t intersection sPower vPower wPower : ℕ}
    (ht : 0 < t)
    (h : intersection * (t * sPower) = (t * vPower) * (t * wPower)) :
    intersection * sPower = t * (vPower * wPower) := by
  apply Nat.eq_of_mul_eq_mul_left ht
  calc
    t * (intersection * sPower) = intersection * (t * sPower) := by
      ac_rfl
    _ = (t * vPower) * (t * wPower) := h
    _ = t * (t * (vPower * wPower)) := by
      ac_rfl

/-- Integrality of `intersection * sPower = t * vwPower` forces the
prime-power part missing from `vwPower` to occur in `t`.  This helper takes
the coprimality premise explicitly. -/
theorem missing_prime_power_moves_to_top
    {primePower intersection sPower t vwPower : ℕ}
    (hPrime : primePower ∣ sPower)
    (hOrder : intersection * sPower = t * vwPower)
    (hCoprime : Nat.Coprime primePower vwPower) :
    primePower ∣ t := by
  have hDivRight : primePower ∣ t * vwPower := by
    rw [← hOrder]
    exact dvd_mul_of_dvd_right hPrime intersection
  exact (hCoprime.dvd_mul_right).mp hDivRight

/-- A factorization `G = A B` makes the natural injection from the cosets
of `A ∩ B` in `A` onto the cosets of `B` in `G` surjective. -/
theorem quotientSubgroupEmbedding_surjective_of_factorization
    {G : Type*} [Group G] (A B : Subgroup G)
    (hfac : SubgroupFactorization A B) :
    Function.Surjective
      (Subgroup.quotientSubgroupOfEmbeddingOfLE B
        (show A ≤ (⊤ : Subgroup G) from le_top)) := by
  intro q
  induction q using Quotient.ind' with
  | _ g =>
      obtain ⟨a, ha, b, hb, hab⟩ := hfac (g : G)
      let aa : A := ⟨a, ha⟩
      refine ⟨QuotientGroup.mk aa, ?_⟩
      rw [Subgroup.quotientSubgroupOfEmbeddingOfLE_apply_mk]
      apply Quotient.sound'
      rw [QuotientGroup.leftRel_apply]
      change a⁻¹ * (g : G) ∈ B
      rw [hab]
      simpa using hb

/-- The exact finite-group order formula for a setwise subgroup
factorization. -/
theorem card_inf_mul_card_eq_of_factorization
    {G : Type*} [Group G] [Finite G]
    (A B : Subgroup G) (hfac : SubgroupFactorization A B) :
    Nat.card ↥(A ⊓ B) * Nat.card G = Nat.card A * Nat.card B := by
  let e := Subgroup.quotientSubgroupOfEmbeddingOfLE B
    (show A ≤ (⊤ : Subgroup G) from le_top)
  have hesurj : Function.Surjective e :=
    quotientSubgroupEmbedding_surjective_of_factorization A B hfac
  have hq : Nat.card (A ⧸ (B.subgroupOf A)) =
      Nat.card ((⊤ : Subgroup G) ⧸ (B.subgroupOf (⊤ : Subgroup G))) :=
    Nat.card_congr (Equiv.ofBijective e ⟨e.injective, hesurj⟩)
  have hBA : Nat.card (B.subgroupOf A) = Nat.card ↥(A ⊓ B) := by
    calc
      Nat.card (B.subgroupOf A) = Nat.card ((B ⊓ A).subgroupOf A) := by
        rw [Subgroup.inf_subgroupOf_right]
      _ = Nat.card ↥(B ⊓ A) :=
        Nat.card_congr (Subgroup.subgroupOfEquivOfLe
          (show B ⊓ A ≤ A from inf_le_right)).toEquiv
      _ = Nat.card ↥(A ⊓ B) := by rw [inf_comm]
  have hBT : Nat.card (B.subgroupOf (⊤ : Subgroup G)) = Nat.card B :=
    Nat.card_congr (Subgroup.subgroupOfEquivOfLe
      (show B ≤ (⊤ : Subgroup G) from le_top)).toEquiv
  have hA := Subgroup.card_eq_card_quotient_mul_card_subgroup (B.subgroupOf A)
  have hT := Subgroup.card_eq_card_quotient_mul_card_subgroup
    (B.subgroupOf (⊤ : Subgroup G))
  calc
    Nat.card ↥(A ⊓ B) * Nat.card G =
        Nat.card (B.subgroupOf A) * Nat.card (⊤ : Subgroup G) := by
          rw [hBA, Subgroup.card_top]
    _ = Nat.card (B.subgroupOf A) *
        (Nat.card ((⊤ : Subgroup G) ⧸ (B.subgroupOf (⊤ : Subgroup G))) *
          Nat.card (B.subgroupOf (⊤ : Subgroup G))) := by rw [hT]
    _ = Nat.card (B.subgroupOf A) *
        (Nat.card (A ⧸ (B.subgroupOf A)) * Nat.card B) := by rw [← hq, hBT]
    _ = (Nat.card (A ⧸ (B.subgroupOf A)) * Nat.card (B.subgroupOf A)) *
        Nat.card B := by ac_rfl
    _ = Nat.card A * Nat.card B := by rw [← hA]

/-- The valuation extraction used after the subgroup-product order identity. -/
theorem forced_prime_power_of_order_identity
    {p d k t intersection s v w : ℕ}
    (hp : p.Prime)
    (ht : t ≠ 0) (hi : intersection ≠ 0) (hs : s ≠ 0)
    (hv : v ≠ 0) (hw : w ≠ 0)
    (horder : intersection * s ^ k = t * (v ^ k * w ^ k))
    (hd : padicValNat p s =
      padicValNat p v + padicValNat p w + d) :
    p ^ (d * k) ∣ t := by
  letI : Fact p.Prime := ⟨hp⟩
  have hval := congrArg (padicValNat p) horder
  rw [padicValNat.mul hi (pow_ne_zero _ hs), padicValNat.pow,
      padicValNat.mul ht (mul_ne_zero (pow_ne_zero _ hv) (pow_ne_zero _ hw)),
      padicValNat.mul (pow_ne_zero _ hv) (pow_ne_zero _ hw),
      padicValNat.pow, padicValNat.pow, hd] at hval
  simp only [Nat.mul_add] at hval
  have hval' : padicValNat p intersection + d * k = padicValNat p t := by
    rw [Nat.mul_comm d k]
    omega
  apply (padicValNat_dvd_iff_le ht).2
  rw [← hval']
  exact Nat.le_add_left _ _

/-- Exact group-to-arithmetic bridge in Theorem 4.1.  The maximality,
nonconjugacy, and normalizer-order conclusions supplied by the preceding
product-supplement lemmas are explicit hypotheses here. -/
theorem product_supplement_forces_prime_power
    {G : Type*} [Group G] [Finite G]
    {p d k t s v w : ℕ}
    (A B : Subgroup G)
    (hp : p.Prime)
    (hP : PropertyP G)
    (hAmax : IsCoatom A) (hBmax : IsCoatom B)
    (hnconj : ¬ AreConjugateSubgroups A B)
    (ht : 0 < t) (hs : s ≠ 0) (hv : v ≠ 0) (hw : w ≠ 0)
    (hcardG : Nat.card G = t * s ^ k)
    (hcardA : Nat.card A = t * v ^ k)
    (hcardB : Nat.card B = t * w ^ k)
    (hd : padicValNat p s =
      padicValNat p v + padicValNat p w + d) :
    p ^ (d * k) ∣ t := by
  have hfac : SubgroupFactorization A B :=
    hP A B hAmax hBmax hnconj
  have hcard := card_inf_mul_card_eq_of_factorization A B hfac
  rw [hcardG, hcardA, hcardB] at hcard
  have horder : Nat.card ↥(A ⊓ B) * s ^ k = t * (v ^ k * w ^ k) :=
    cancel_quotient_order ht hcard
  exact forced_prime_power_of_order_identity hp ht.ne'
    Nat.card_pos.ne' hs hv hw horder hd

/-- The complete contradiction in Theorem 4.1 after the exact construction,
maximality, nonconjugacy, order, and wreath-quotient conclusions have been
supplied.  This combines the group-to-arithmetic bridge above with the
universal-in-`k` theorem in `Divisibility.lean`. -/
theorem no_propertyP_of_product_supplement_data
    {G : Type*} [Group G] [Finite G]
    {p d k t x s v w : ℕ}
    (A B : Subgroup G)
    (hp : p.Prime) (hk : 2 ≤ k)
    (hAmax : IsCoatom A) (hBmax : IsCoatom B)
    (hnconj : ¬ AreConjugateSubgroups A B)
    (ht : 0 < t) (hx : x ≠ 0) (hs : s ≠ 0) (hv : v ≠ 0) (hw : w ≠ 0)
    (hcardG : Nat.card G = t * s ^ k)
    (hcardA : Nat.card A = t * v ^ k)
    (hcardB : Nat.card B = t * w ^ k)
    (hd : padicValNat p s =
      padicValNat p v + padicValNat p w + d)
    (hTop : t ∣ x ^ k * k.factorial)
    (hGap : padicValNat p x < d) :
    ¬ PropertyP G := by
  intro hP
  have hForced : p ^ (d * k) ∣ t :=
    product_supplement_forces_prime_power A B hp hP hAmax hBmax hnconj
      ht hs hv hw hcardG hcardA hcardB hd
  exact divisibility_contradiction_for_products hp hk hx ht.ne' hTop hForced hGap

end Kourovka1034
