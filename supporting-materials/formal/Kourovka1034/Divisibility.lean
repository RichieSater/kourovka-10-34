import Mathlib.NumberTheory.Padics.PadicVal.Basic

/-!
# The numerical core of the divisibility criterion

This file kernel-checks the final universal-in-`k` contradiction in
Theorem 4.1 of the manuscript.  It deliberately exposes the two divisibility
facts supplied by the group-theoretic part of the proof:

* `p ^ (d * k) ∣ t`, forced by a hypothetical factorization; and
* `t ∣ x ^ k * k!`, supplied by the wreath-product order bound.

There are no axioms, placeholders, or admitted results in this file.
-/

namespace Kourovka1034

/-- The exact arithmetic contradiction used in the paper's divisibility
criterion.  In the manuscript `t = |G/N|`, `x = |X/Inn(S)|`, and
`d = v_p(|S|)-v_p(|V|)-v_p(|W|)`.

The proof is uniform in every positive `k` (the main theorem only invokes it
for `k ≥ 2`). -/
theorem divisibility_contradiction
    {p k x t d : ℕ}
    (hp : p.Prime)
    (hk : 0 < k)
    (hx : x ≠ 0)
    (ht : t ≠ 0)
    (hTop : t ∣ x ^ k * k.factorial)
    (hForced : p ^ (d * k) ∣ t)
    (hGap : padicValNat p x < d) : False := by
  letI : Fact p.Prime := ⟨hp⟩

  have hLow : d * k ≤ padicValNat p t :=
    (padicValNat_dvd_iff_le ht).mp hForced

  have hProductNonzero : x ^ k * k.factorial ≠ 0 :=
    mul_ne_zero (pow_ne_zero _ hx) (Nat.factorial_ne_zero k)
  obtain ⟨c, hc⟩ := hTop
  have hc0 : c ≠ 0 := by
    intro hcz
    subst c
    simp only [mul_zero] at hc
    exact hProductNonzero hc
  have hTopVal : padicValNat p t ≤ padicValNat p (x ^ k * k.factorial) := by
    rw [hc, padicValNat.mul ht hc0]
    exact Nat.le_add_right _ _

  have hValuationBound :
      d * k ≤ k * padicValNat p x + padicValNat p k.factorial := by
    calc
      d * k ≤ padicValNat p t := hLow
      _ ≤ padicValNat p (x ^ k * k.factorial) := hTopVal
      _ = padicValNat p (x ^ k) + padicValNat p k.factorial := by
        rw [padicValNat.mul (pow_ne_zero _ hx) (Nat.factorial_ne_zero k)]
      _ = k * padicValNat p x + padicValNat p k.factorial := by
        rw [padicValNat.pow]

  have hFactorial : padicValNat p k.factorial < k :=
    padicValNat_factorial_lt_of_ne_zero p (Nat.ne_of_gt hk)
  have hStrict :
      k * padicValNat p x + padicValNat p k.factorial <
        k * padicValNat p x + k :=
    Nat.add_lt_add_left hFactorial _
  have hGapLe : padicValNat p x + 1 ≤ d := Nat.succ_le_iff.mpr hGap
  have hFinal : k * padicValNat p x + k ≤ d * k := by
    calc
      k * padicValNat p x + k = k * (padicValNat p x + 1) := by
        rw [Nat.mul_add, Nat.mul_one]
      _ ≤ k * d := Nat.mul_le_mul_left k hGapLe
      _ = d * k := Nat.mul_comm _ _

  exact (not_lt_of_ge hValuationBound) (hStrict.trans_le hFinal)

/-- The formulation used literally in the `k ≥ 2` branch of the paper. -/
theorem divisibility_contradiction_for_products
    {p k x t d : ℕ}
    (hp : p.Prime)
    (hk : 2 ≤ k)
    (hx : x ≠ 0)
    (ht : t ≠ 0)
    (hTop : t ∣ x ^ k * k.factorial)
    (hForced : p ^ (d * k) ∣ t)
    (hGap : padicValNat p x < d) : False :=
  divisibility_contradiction hp (by omega) hx ht hTop hForced hGap

end Kourovka1034
