import Mathlib.NumberTheory.Padics.PadicVal.Basic
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.NormNum.Prime
import Mathlib.Tactic.Ring

/-!
# Universal arithmetic certificates for the finite-simple-group families

This module kernel-checks the arithmetic deductions in the manuscript results
labeled `thm:an`, `thm:psl2`, `thm:nograph`, `thm:twisted2`, `thm:twisted1`,
and `thm:graph`,
conditional on the exact published group/Levi/outer-order formulas named in
`audit/FAMILY-ARITHMETIC-MANIFEST.json`.  It does not assert those published
classification formulas as new axioms.  It proves the universal affine
cyclotomic bounds, the complete Zsigmondy `(2,6)` parameter routing, the two
special residue arguments, the defining-characteristic and alternating
lemmas, and the six exact substitute-prime valuation certificates.
-/

namespace Kourovka1034
namespace FamilyArithmetic

inductive Branch where
  | psl2Odd | psl2Even | alternating
  | cHigh | bHigh | c2Odd | g2NoGraph | f4NoGraph | e7 | e8
  | psuOdd | psuEven | twistedD | trialityTwisted | twistedE6 | largeRee
  | psu3 | suzuki | smallRee
  | pslTrivial | dPlus | sp4Trivial | f4Trivial | g2Trivial
  | psl3Graph | psl4Graph | pslnGraph | d4Triality | e6
  | sp4GraphOdd | sp4GraphEven | f4Graph | g2GraphOdd | g2GraphEven
  deriving DecidableEq, Repr

open Branch

def allBranches : List Branch :=
  [psl2Odd, psl2Even, alternating,
   cHigh, bHigh, c2Odd, g2NoGraph, f4NoGraph, e7, e8,
   psuOdd, psuEven, twistedD, trialityTwisted, twistedE6, largeRee,
   psu3, suzuki, smallRee,
   pslTrivial, dPlus, sp4Trivial, f4Trivial, g2Trivial,
   psl3Graph, psl4Graph, pslnGraph, d4Triality, e6,
   sp4GraphOdd, sp4GraphEven, f4Graph, g2GraphOdd, g2GraphEven]

theorem exact_branch_inventory : allBranches.length = 34 := by decide

theorem branch_inventory_complete :
    allBranches.Nodup ∧ ∀ b : Branch, b ∈ allBranches := by
  constructor
  · decide
  · intro b
    cases b <;> simp [allBranches]

def isPrimitive : Branch → Bool
  | psl2Odd | alternating => false
  | _ => true

def rankOK : Branch → ℕ → Prop
  | psl2Odd, n => n = 0
  | psl2Even, n => n = 0
  | alternating, n => 15 ≤ n
  | cHigh, n => 3 ≤ n
  | bHigh, n => 3 ≤ n
  | pslTrivial, n => 3 ≤ n
  | c2Odd, n => n = 2
  | g2NoGraph, n => n = 2
  | suzuki, n => n = 2
  | smallRee, n => n = 2
  | sp4Trivial, n => n = 2
  | sp4GraphOdd, n => n = 2
  | sp4GraphEven, n => n = 2
  | g2Trivial, n => n = 2
  | g2GraphOdd, n => n = 2
  | g2GraphEven, n => n = 2
  | f4NoGraph, n => n = 4
  | twistedD, n => n = 4
  | largeRee, n => n = 4
  | dPlus, n => n = 4
  | psl4Graph, n => n = 4
  | d4Triality, n => n = 4
  | f4Trivial, n => n = 4
  | f4Graph, n => n = 4
  | trialityTwisted, n => n = 4
  | e7, n => n = 7
  | e8, n => n = 8
  | psuOdd, n => 5 ≤ n ∧ Odd n
  | psuEven, n => 4 ≤ n ∧ Even n
  | twistedE6, n => n = 6
  | e6, n => n = 6
  | psu3, n => n = 3
  | psl3Graph, n => n = 3
  | pslnGraph, n => 5 ≤ n

def fieldOK : Branch → ℕ → Prop
  | psl2Even, f => 3 ≤ f
  | largeRee, f => 3 ≤ f ∧ Odd f
  | suzuki, f => 3 ≤ f ∧ Odd f
  | smallRee, f => 3 ≤ f ∧ Odd f
  | sp4GraphOdd, f => 3 ≤ f ∧ Odd f
  | sp4Trivial, f => 2 ≤ f
  | sp4GraphEven, f => 2 ≤ f ∧ Even f
  | g2GraphEven, f => 2 ≤ f ∧ Even f
  | g2GraphOdd, f => 1 ≤ f ∧ Odd f
  | _, f => 1 ≤ f

/-- Whether characteristic two lies in the algebraic invocation range.  The
simple-group/q-minimum boundary is routed separately, so G2(2), PSU(3,2), and
PSL(3,4) remain visible in the exception theorem. -/
def characteristicTwoAllowed : Branch → Bool
  | bHigh | c2Odd | f4NoGraph | smallRee | g2Trivial |
      g2GraphOdd | g2GraphEven => false
  | _ => true

/-- Coefficient E/f of the primitive exponent. -/
def exponentCoefficient : Branch → ℕ → ℕ
  | psl2Even, _ => 2
  | cHigh, n => 2 * n
  | bHigh, n => 2 * n
  | c2Odd, _ => 4
  | g2NoGraph, _ => 6
  | f4NoGraph, _ => 12
  | e7, _ => 18
  | e8, _ => 30
  | psuOdd, n => 2 * n
  | psuEven, n => 2 * n - 2
  | twistedD, n => 2 * n
  | trialityTwisted, _ => 12
  | twistedE6, _ => 18
  | largeRee, _ => 12
  | psu3, _ => 6
  | suzuki, _ => 4
  | smallRee, _ => 6
  | pslTrivial, n => n
  | dPlus, n => 2 * n - 2
  | sp4Trivial, _ => 4
  | f4Trivial, _ => 12
  | g2Trivial, _ => 6
  | psl3Graph, _ => 3
  | psl4Graph, _ => 4
  | pslnGraph, n => n
  | d4Triality, _ => 6
  | e6, _ => 12
  | sp4GraphOdd, _ => 2
  | sp4GraphEven, _ => 4
  | f4Graph, _ => 12
  | g2GraphOdd, _ => 3
  | g2GraphEven, _ => 6
  | psl2Odd, _ => 0
  | alternating, _ => 0

/-- The twelve branch occurrences of the unique positive-base Zsigmondy
exception.  Repeated groups occur because distinct graph branches require
separate witness pairs. -/
def zsigmondyExceptionPoints : List (Branch × ℕ × ℕ) :=
  [(psl2Even, 0, 3), (cHigh, 3, 1), (g2NoGraph, 2, 1),
   (psuEven, 4, 1), (psu3, 3, 1),
   (pslTrivial, 3, 2), (pslTrivial, 6, 1),
   (dPlus, 4, 1), (psl3Graph, 3, 2), (pslnGraph, 6, 1),
   (d4Triality, 4, 1), (sp4GraphOdd, 2, 3)]

theorem primitive_exponent_positive
    (b : Branch) (n f : ℕ) (hp : isPrimitive b = true)
    (hn : rankOK b n) (hf : fieldOK b f) :
    0 < exponentCoefficient b n ∧ 0 < f := by
  cases b <;> simp [isPrimitive, rankOK, fieldOK, exponentCoefficient] at * <;> omega

/-- Exhaustive solution of the only Zsigmondy exception equation. -/
theorem zsigmondy_exception_complete
    (b : Branch) (n f : ℕ) (hp : isPrimitive b = true)
    (hn : rankOK b n) (hf : fieldOK b f)
    (hchar : characteristicTwoAllowed b = true)
    (heq : exponentCoefficient b n * f = 6) :
    (b, n, f) ∈ zsigmondyExceptionPoints := by
  obtain ⟨hcoef, hfpos⟩ := primitive_exponent_positive b n f hp hn hf
  have hcoef_le : exponentCoefficient b n ≤ 6 := by
    calc
      exponentCoefficient b n ≤ exponentCoefficient b n * f :=
        Nat.le_mul_of_pos_right _ hfpos
      _ = 6 := heq
  have hf_le : f ≤ 6 := by
    calc
      f ≤ exponentCoefficient b n * f := Nat.le_mul_of_pos_left _ hcoef
      _ = 6 := heq
  have hn_le : n ≤ 8 := by
    cases b <;>
      simp [isPrimitive, rankOK, exponentCoefficient] at hp hn hcoef_le ⊢ <;> omega
  cases b <;>
    simp [isPrimitive, rankOK, fieldOK, characteristicTwoAllowed,
      exponentCoefficient, zsigmondyExceptionPoints] at hp hn hf hchar heq ⊢ <;>
    try omega
  all_goals
    (interval_cases n <;> (try interval_cases f) <;>
      (try norm_num at heq ⊢))
  all_goals omega

structure ZAffine where
  a : ℤ
  b : ℤ
  deriving DecidableEq, Repr

namespace ZAffine

def eval (x : ZAffine) (n : ℕ) : ℤ := x.a * n + x.b

end ZAffine

structure BoundCertificate where
  branch : Branch
  lower : ZAffine
  upper : ZAffine
  n0 : ℕ
  deriving DecidableEq, Repr

namespace BoundCertificate

def Valid (c : BoundCertificate) : Prop :=
  0 ≤ c.lower.a ∧
  0 < c.lower.eval c.n0 ∧
  0 ≤ c.upper.a - c.lower.a ∧
  0 < c.upper.eval c.n0 - c.lower.eval c.n0

instance (c : BoundCertificate) : Decidable c.Valid := by
  unfold Valid
  infer_instance

/-- A three-integer certificate proves the strict affine inequality on the
entire unbounded rank ray. -/
theorem holds_on_ray (c : BoundCertificate) (h : c.Valid)
    (n : ℕ) (hn : c.n0 ≤ n) :
    0 < c.lower.eval n ∧ c.lower.eval n < c.upper.eval n := by
  rcases h with ⟨hlowSlope, hlow, hdiffSlope, hdiff⟩
  have hnInt : (c.n0 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn
  have hstep : 0 ≤ (n : ℤ) - c.n0 := sub_nonneg.mpr hnInt
  have hlowStep : 0 ≤ c.lower.a * ((n : ℤ) - c.n0) :=
    mul_nonneg hlowSlope hstep
  have hdiffStep :
      0 ≤ (c.upper.a - c.lower.a) * ((n : ℤ) - c.n0) :=
    mul_nonneg hdiffSlope hstep
  have hlowId :
      c.lower.eval n = c.lower.eval c.n0 + c.lower.a * ((n : ℤ) - c.n0) := by
    simp only [ZAffine.eval]
    ring
  have hdiffId :
      c.upper.eval n - c.lower.eval n =
        (c.upper.eval c.n0 - c.lower.eval c.n0) +
          (c.upper.a - c.lower.a) * ((n : ℤ) - c.n0) := by
    simp only [ZAffine.eval]
    ring
  constructor
  · rw [hlowId]
    exact add_pos_of_pos_of_nonneg hlow hlowStep
  · apply sub_pos.mp
    rw [hdiffId]
    exact add_pos_of_pos_of_nonneg hdiff hdiffStep

end BoundCertificate

def branchBounds : List BoundCertificate :=
[  ⟨.psl2Even, ⟨0, 1⟩, ⟨0, 2⟩, 0⟩,
  ⟨.psl2Even, ⟨0, 1⟩, ⟨0, 2⟩, 0⟩,
  ⟨.cHigh, ⟨2, -2⟩, ⟨2, 0⟩, 3⟩,
  ⟨.cHigh, ⟨2, -4⟩, ⟨2, 0⟩, 3⟩,
  ⟨.cHigh, ⟨0, 2⟩, ⟨2, 0⟩, 3⟩,
  ⟨.bHigh, ⟨2, -2⟩, ⟨2, 0⟩, 3⟩,
  ⟨.bHigh, ⟨2, -4⟩, ⟨2, 0⟩, 3⟩,
  ⟨.bHigh, ⟨0, 2⟩, ⟨2, 0⟩, 3⟩,
  ⟨.c2Odd, ⟨0, 2⟩, ⟨0, 4⟩, 2⟩,
  ⟨.c2Odd, ⟨0, 2⟩, ⟨0, 4⟩, 2⟩,
  ⟨.g2NoGraph, ⟨0, 2⟩, ⟨0, 6⟩, 2⟩,
  ⟨.g2NoGraph, ⟨0, 2⟩, ⟨0, 6⟩, 2⟩,
  ⟨.f4NoGraph, ⟨0, 6⟩, ⟨0, 12⟩, 4⟩,
  ⟨.f4NoGraph, ⟨0, 6⟩, ⟨0, 12⟩, 4⟩,
  ⟨.e7, ⟨0, 12⟩, ⟨0, 18⟩, 7⟩,
  ⟨.e7, ⟨0, 12⟩, ⟨0, 18⟩, 7⟩,
  ⟨.e8, ⟨0, 18⟩, ⟨0, 30⟩, 8⟩,
  ⟨.e8, ⟨0, 18⟩, ⟨0, 30⟩, 8⟩,
  ⟨.psuOdd, ⟨0, 2⟩, ⟨2, 0⟩, 5⟩,
  ⟨.psuOdd, ⟨2, -4⟩, ⟨2, 0⟩, 5⟩,
  ⟨.psuOdd, ⟨0, 4⟩, ⟨2, 0⟩, 5⟩,
  ⟨.psuOdd, ⟨2, -8⟩, ⟨2, 0⟩, 5⟩,
  ⟨.psuOdd, ⟨0, 2⟩, ⟨2, 0⟩, 5⟩,
  ⟨.psuEven, ⟨0, 4⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨2, -6⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨1, -2⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨0, 4⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨2, -6⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨1, -2⟩, ⟨2, -2⟩, 4⟩,
  ⟨.psuEven, ⟨0, 2⟩, ⟨2, -2⟩, 4⟩,
  ⟨.twistedD, ⟨0, 1⟩, ⟨2, 0⟩, 4⟩,
  ⟨.twistedD, ⟨2, -2⟩, ⟨2, 0⟩, 4⟩,
  ⟨.twistedD, ⟨0, 2⟩, ⟨2, 0⟩, 4⟩,
  ⟨.twistedD, ⟨2, -4⟩, ⟨2, 0⟩, 4⟩,
  ⟨.trialityTwisted, ⟨0, 6⟩, ⟨0, 12⟩, 4⟩,
  ⟨.trialityTwisted, ⟨0, 1⟩, ⟨0, 12⟩, 4⟩,
  ⟨.trialityTwisted, ⟨0, 2⟩, ⟨0, 12⟩, 4⟩,
  ⟨.trialityTwisted, ⟨0, 3⟩, ⟨0, 12⟩, 4⟩,
  ⟨.twistedE6, ⟨0, 10⟩, ⟨0, 18⟩, 6⟩,
  ⟨.twistedE6, ⟨0, 6⟩, ⟨0, 18⟩, 6⟩,
  ⟨.twistedE6, ⟨0, 8⟩, ⟨0, 18⟩, 6⟩,
  ⟨.twistedE6, ⟨0, 4⟩, ⟨0, 18⟩, 6⟩,
  ⟨.twistedE6, ⟨0, 2⟩, ⟨0, 18⟩, 6⟩,
  ⟨.largeRee, ⟨0, 4⟩, ⟨0, 12⟩, 4⟩,
  ⟨.largeRee, ⟨0, 1⟩, ⟨0, 12⟩, 4⟩,
  ⟨.largeRee, ⟨0, 2⟩, ⟨0, 12⟩, 4⟩,
  ⟨.largeRee, ⟨0, 1⟩, ⟨0, 12⟩, 4⟩,
  ⟨.psu3, ⟨0, 2⟩, ⟨0, 6⟩, 3⟩,
  ⟨.psu3, ⟨0, 2⟩, ⟨0, 6⟩, 3⟩,
  ⟨.psu3, ⟨0, 2⟩, ⟨0, 6⟩, 3⟩,
  ⟨.suzuki, ⟨0, 1⟩, ⟨0, 4⟩, 2⟩,
  ⟨.suzuki, ⟨0, 1⟩, ⟨0, 4⟩, 2⟩,
  ⟨.smallRee, ⟨0, 1⟩, ⟨0, 6⟩, 2⟩,
  ⟨.smallRee, ⟨0, 2⟩, ⟨0, 6⟩, 2⟩,
  ⟨.pslTrivial, ⟨1, -1⟩, ⟨1, 0⟩, 3⟩,
  ⟨.pslTrivial, ⟨0, 2⟩, ⟨1, 0⟩, 3⟩,
  ⟨.pslTrivial, ⟨1, -2⟩, ⟨1, 0⟩, 3⟩,
  ⟨.pslTrivial, ⟨0, 1⟩, ⟨1, 0⟩, 3⟩,
  ⟨.pslTrivial, ⟨0, 1⟩, ⟨1, 0⟩, 3⟩,
  ⟨.dPlus, ⟨1, -1⟩, ⟨2, -2⟩, 4⟩,
  ⟨.dPlus, ⟨2, -4⟩, ⟨2, -2⟩, 4⟩,
  ⟨.dPlus, ⟨0, 2⟩, ⟨2, -2⟩, 4⟩,
  ⟨.dPlus, ⟨1, -2⟩, ⟨2, -2⟩, 4⟩,
  ⟨.dPlus, ⟨2, -6⟩, ⟨2, -2⟩, 4⟩,
  ⟨.sp4Trivial, ⟨0, 2⟩, ⟨0, 4⟩, 2⟩,
  ⟨.sp4Trivial, ⟨0, 2⟩, ⟨0, 4⟩, 2⟩,
  ⟨.f4Trivial, ⟨0, 6⟩, ⟨0, 12⟩, 4⟩,
  ⟨.f4Trivial, ⟨0, 6⟩, ⟨0, 12⟩, 4⟩,
  ⟨.g2Trivial, ⟨0, 2⟩, ⟨0, 6⟩, 2⟩,
  ⟨.g2Trivial, ⟨0, 2⟩, ⟨0, 6⟩, 2⟩,
  ⟨.psl3Graph, ⟨0, 1⟩, ⟨0, 3⟩, 3⟩,
  ⟨.psl3Graph, ⟨0, 1⟩, ⟨0, 3⟩, 3⟩,
  ⟨.psl3Graph, ⟨0, 1⟩, ⟨0, 3⟩, 3⟩,
  ⟨.psl3Graph, ⟨0, 1⟩, ⟨0, 3⟩, 3⟩,
  ⟨.psl4Graph, ⟨0, 2⟩, ⟨0, 4⟩, 4⟩,
  ⟨.psl4Graph, ⟨0, 2⟩, ⟨0, 4⟩, 4⟩,
  ⟨.psl4Graph, ⟨0, 1⟩, ⟨0, 4⟩, 4⟩,
  ⟨.psl4Graph, ⟨0, 1⟩, ⟨0, 4⟩, 4⟩,
  ⟨.psl4Graph, ⟨0, 1⟩, ⟨0, 4⟩, 4⟩,
  ⟨.pslnGraph, ⟨1, -2⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨0, 1⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨0, 2⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨1, -4⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨0, 1⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨0, 1⟩, ⟨1, 0⟩, 5⟩,
  ⟨.pslnGraph, ⟨0, 1⟩, ⟨1, 0⟩, 5⟩,
  ⟨.d4Triality, ⟨0, 2⟩, ⟨0, 6⟩, 4⟩,
  ⟨.d4Triality, ⟨0, 2⟩, ⟨0, 6⟩, 4⟩,
  ⟨.d4Triality, ⟨0, 1⟩, ⟨0, 6⟩, 4⟩,
  ⟨.e6, ⟨0, 6⟩, ⟨0, 12⟩, 6⟩,
  ⟨.e6, ⟨0, 3⟩, ⟨0, 12⟩, 6⟩,
  ⟨.e6, ⟨0, 1⟩, ⟨0, 12⟩, 6⟩,
  ⟨.e6, ⟨0, 1⟩, ⟨0, 12⟩, 6⟩,
  ⟨.sp4GraphOdd, ⟨0, 1⟩, ⟨0, 2⟩, 2⟩,
  ⟨.sp4GraphOdd, ⟨0, 1⟩, ⟨0, 2⟩, 2⟩,
  ⟨.sp4GraphEven, ⟨0, 1⟩, ⟨0, 4⟩, 2⟩,
  ⟨.sp4GraphEven, ⟨0, 2⟩, ⟨0, 4⟩, 2⟩,
  ⟨.sp4GraphEven, ⟨0, 1⟩, ⟨0, 4⟩, 2⟩,
  ⟨.f4Graph, ⟨0, 4⟩, ⟨0, 12⟩, 4⟩,
  ⟨.f4Graph, ⟨0, 1⟩, ⟨0, 12⟩, 4⟩,
  ⟨.f4Graph, ⟨0, 2⟩, ⟨0, 12⟩, 4⟩,
  ⟨.f4Graph, ⟨0, 1⟩, ⟨0, 12⟩, 4⟩,
  ⟨.g2GraphOdd, ⟨0, 1⟩, ⟨0, 3⟩, 2⟩,
  ⟨.g2GraphOdd, ⟨0, 1⟩, ⟨0, 3⟩, 2⟩,
  ⟨.g2GraphEven, ⟨0, 1⟩, ⟨0, 6⟩, 2⟩,
  ⟨.g2GraphEven, ⟨0, 3⟩, ⟨0, 6⟩, 2⟩,
  ⟨.g2GraphEven, ⟨0, 1⟩, ⟨0, 6⟩, 2⟩
]

theorem exact_bound_inventory : branchBounds.length = 107 := by decide

theorem every_source_exponent_bound_is_universal :
    ∀ c ∈ branchBounds, ∀ n, c.n0 ≤ n →
      0 < c.lower.eval n ∧ c.lower.eval n < c.upper.eval n := by
  intro c hc
  apply BoundCertificate.holds_on_ray c
  have hall : ∀ x ∈ branchBounds, x.Valid := by decide
  exact hall c hc

structure OccurrenceCertificate where
  branch : Branch
  primitive : ZAffine
  qFactor : ZAffine
  multiplier : ℤ
  deriving DecidableEq, Repr

namespace OccurrenceCertificate

def Valid (c : OccurrenceCertificate) : Prop :=
  c.primitive.a = c.multiplier * c.qFactor.a ∧
  c.primitive.b = c.multiplier * c.qFactor.b ∧
  (c.multiplier = 1 ∨ c.multiplier = 2)

instance (c : OccurrenceCertificate) : Decidable c.Valid := by
  unfold Valid
  infer_instance

end OccurrenceCertificate

def groupOccurrences : List OccurrenceCertificate :=
[  ⟨.psl2Even, ⟨0, 2⟩, ⟨0, 1⟩, 2⟩,
  ⟨.cHigh, ⟨2, 0⟩, ⟨2, 0⟩, 1⟩,
  ⟨.bHigh, ⟨2, 0⟩, ⟨2, 0⟩, 1⟩,
  ⟨.c2Odd, ⟨0, 4⟩, ⟨0, 4⟩, 1⟩,
  ⟨.g2NoGraph, ⟨0, 6⟩, ⟨0, 6⟩, 1⟩,
  ⟨.f4NoGraph, ⟨0, 12⟩, ⟨0, 12⟩, 1⟩,
  ⟨.e7, ⟨0, 18⟩, ⟨0, 18⟩, 1⟩,
  ⟨.e8, ⟨0, 30⟩, ⟨0, 30⟩, 1⟩,
  ⟨.psuOdd, ⟨2, 0⟩, ⟨1, 0⟩, 2⟩,
  ⟨.psuEven, ⟨2, -2⟩, ⟨1, -1⟩, 2⟩,
  ⟨.twistedD, ⟨2, 0⟩, ⟨1, 0⟩, 2⟩,
  ⟨.trialityTwisted, ⟨0, 12⟩, ⟨0, 12⟩, 1⟩,
  ⟨.twistedE6, ⟨0, 18⟩, ⟨0, 9⟩, 2⟩,
  ⟨.largeRee, ⟨0, 12⟩, ⟨0, 6⟩, 2⟩,
  ⟨.psu3, ⟨0, 6⟩, ⟨0, 3⟩, 2⟩,
  ⟨.suzuki, ⟨0, 4⟩, ⟨0, 2⟩, 2⟩,
  ⟨.smallRee, ⟨0, 6⟩, ⟨0, 3⟩, 2⟩,
  ⟨.pslTrivial, ⟨1, 0⟩, ⟨1, 0⟩, 1⟩,
  ⟨.dPlus, ⟨2, -2⟩, ⟨2, -2⟩, 1⟩,
  ⟨.sp4Trivial, ⟨0, 4⟩, ⟨0, 2⟩, 2⟩,
  ⟨.f4Trivial, ⟨0, 12⟩, ⟨0, 12⟩, 1⟩,
  ⟨.g2Trivial, ⟨0, 6⟩, ⟨0, 6⟩, 1⟩,
  ⟨.psl3Graph, ⟨0, 3⟩, ⟨0, 3⟩, 1⟩,
  ⟨.psl4Graph, ⟨0, 4⟩, ⟨0, 4⟩, 1⟩,
  ⟨.pslnGraph, ⟨1, 0⟩, ⟨1, 0⟩, 1⟩,
  ⟨.d4Triality, ⟨0, 6⟩, ⟨0, 6⟩, 1⟩,
  ⟨.e6, ⟨0, 12⟩, ⟨0, 12⟩, 1⟩,
  ⟨.sp4GraphOdd, ⟨0, 2⟩, ⟨0, 1⟩, 2⟩,
  ⟨.sp4GraphEven, ⟨0, 4⟩, ⟨0, 2⟩, 2⟩,
  ⟨.f4Graph, ⟨0, 12⟩, ⟨0, 12⟩, 1⟩,
  ⟨.g2GraphOdd, ⟨0, 3⟩, ⟨0, 3⟩, 1⟩,
  ⟨.g2GraphEven, ⟨0, 6⟩, ⟨0, 3⟩, 2⟩
]

theorem exact_occurrence_inventory : groupOccurrences.length = 32 := by decide

theorem every_primitive_exponent_occurs_in_sourced_group_factor :
    ∀ c ∈ groupOccurrences, c.Valid := by decide

structure ConstantCertificate where
  exponentMinimum : ℕ
  fixedFactor : ℕ
  deriving DecidableEq, Repr

namespace ConstantCertificate

def Valid (c : ConstantCertificate) : Prop :=
  c.fixedFactor ∣ 24 ∧ 3 ≤ c.exponentMinimum

instance (c : ConstantCertificate) : Decidable c.Valid := by
  unfold Valid
  infer_instance

end ConstantCertificate

def constantCertificates : List ConstantCertificate :=
[  ⟨6, 2⟩,
  ⟨6, 1⟩,
  ⟨10, 3⟩,
  ⟨6, 3⟩,
  ⟨8, 12⟩,
  ⟨12, 3⟩,
  ⟨18, 3⟩,
  ⟨36, 3⟩,
  ⟨12, 2⟩,
  ⟨12, 1⟩,
  ⟨18, 1⟩,
  ⟨3, 2⟩,
  ⟨6, 24⟩,
  ⟨8, 1⟩,
  ⟨3, 6⟩,
  ⟨4, 2⟩,
  ⟨5, 2⟩,
  ⟨8, 2⟩
]

theorem exact_fixed_factor_inventory : constantCertificates.length = 18 := by decide

theorem every_fixed_factor_is_below_the_primitive_prime :
    ∀ c ∈ constantCertificates, c.Valid := by decide

theorem prime_avoids_certified_constant
    {E C r : ℕ} (hvalid : (ConstantCertificate.mk E C).Valid)
    (_hC : C ≠ 0) (hr : r.Prime) (hgt : E < r) : ¬ r ∣ C := by
  intro hdvd
  have hr24 : r ∣ 24 := hdvd.trans hvalid.1
  have hrle24 : r ≤ 24 := Nat.le_of_dvd (by norm_num) hr24
  have hrle3 : r ≤ 3 := by
    interval_cases r
    all_goals (solve | norm_num at hr | norm_num at hr24 | norm_num)
  have hE : 3 ≤ E := hvalid.2
  omega

/-- The exact defining-characteristic inequality in PSL(2,q), q odd. -/
theorem psl2_odd_field_valuation {p f : ℕ} (hf : 0 < f) :
    padicValNat p f < f :=
  Nat.padicValNat_lt_self (Nat.ne_of_gt hf)

/-- Nagura's `6p>5n` output gives enough room for two alternating-group
classes throughout the unbounded range n>=31. -/
theorem nagura_implies_two_class_bound {n p : ℕ}
    (hn : 31 ≤ n) (hnagura : 5 * n < 6 * p) : n + 6 ≤ 2 * p := by
  omega

/-- A prime in the Bertrand range occurs exactly once in n!. -/
theorem factorial_prime_valuation_one {n p : ℕ} (hp : p.Prime)
    (hpn : p ≤ n) (hn2p : n < 2 * p) : padicValNat p n.factorial = 1 := by
  letI : Fact p.Prime := ⟨hp⟩
  have hdiv : n / p = 1 := by
    apply Nat.div_eq_of_lt_le
    · simpa using hpn
    · simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using hn2p
  rw [← padicValNat_mul_div_factorial (p := p) n, hdiv]
  simpa using padicValNat_factorial_mul (p := p) 1

/-- Exact finite n=15..30 largest-prime/class-count certificate. -/
def alternatingFinitePrimes : List (ℕ × ℕ) :=
  [(15,13), (16,13), (17,17), (18,17), (19,19), (20,19),
   (21,19), (22,19), (23,23), (24,23), (25,23), (26,23),
   (27,23), (28,23), (29,29), (30,29)]

theorem alternating_finite_prime_certificates :
    ∀ np ∈ alternatingFinitePrimes,
      np.2.Prime ∧ np.2 ≤ np.1 ∧ np.1 < 2 * np.2 ∧ np.1 + 6 ≤ 2 * np.2 := by
  decide

/-- If r divides q+1 and q^2+1, it divides 2.  This closes the Suzuki-factor
avoidance in the odd Sp4 graph-field branch. -/
theorem common_divisor_q_add_one_q_square_add_one
    {r q : ℕ} (h₁ : r ∣ q + 1) (h₂ : r ∣ q ^ 2 + 1) : r ∣ 2 := by
  have h₁z : (r : ℤ) ∣ (q : ℤ) + 1 := by exact_mod_cast h₁
  have h₂z : (r : ℤ) ∣ (q : ℤ) ^ 2 + 1 := by exact_mod_cast h₂
  have hmz : (r : ℤ) ∣ (q : ℤ) ^ 2 - 1 := by
    rw [show (q : ℤ) ^ 2 - 1 = ((q : ℤ) + 1) * ((q : ℤ) - 1) by ring]
    exact dvd_mul_of_dvd_left h₁z _
  have htwoz : (r : ℤ) ∣ 2 := by
    convert Int.dvd_sub h₂z hmz using 1
    ring
  exact_mod_cast htwoz

/-- If r divides q^3-1 and q^3+1, it divides 2.  This closes the Ree-factor
avoidance in the odd G2 graph-field branch. -/
theorem common_divisor_q_cube_sub_one_q_cube_add_one
    {r q : ℕ} (hq : 0 < q) (h₁ : r ∣ q ^ 3 - 1) (h₂ : r ∣ q ^ 3 + 1) : r ∣ 2 := by
  have hpow : 1 ≤ q ^ 3 := one_le_pow₀ (by omega)
  have h₁z' : (r : ℤ) ∣ ((q ^ 3 - 1 : ℕ) : ℤ) := by exact_mod_cast h₁
  have hcast : ((q ^ 3 - 1 : ℕ) : ℤ) = (q : ℤ) ^ 3 - 1 := by
    rw [Nat.cast_sub hpow, Nat.cast_pow, Nat.cast_one]
  rw [hcast] at h₁z'
  have h₁z : (r : ℤ) ∣ (q : ℤ) ^ 3 - 1 := h₁z'
  have h₂z : (r : ℤ) ∣ (q : ℤ) ^ 3 + 1 := by exact_mod_cast h₂
  have htwoz : (r : ℤ) ∣ 2 := by
    convert Int.dvd_sub h₂z h₁z using 1
    ring
  exact_mod_cast htwoz

theorem prime_gt_two_avoids_sp4_special_factor
    {r q : ℕ} (_hr : r.Prime) (hgt : 2 < r)
    (hgroup : r ∣ q + 1) : ¬ r ∣ q ^ 2 + 1 := by
  intro hspecial
  have htwo := common_divisor_q_add_one_q_square_add_one hgroup hspecial
  have hrle : r ≤ 2 := Nat.le_of_dvd (by decide) htwo
  omega

theorem prime_gt_two_avoids_g2_special_factor
    {r q : ℕ} (_hr : r.Prime) (hgt : 2 < r) (hq : 0 < q)
    (hgroup : r ∣ q ^ 3 - 1) : ¬ r ∣ q ^ 3 + 1 := by
  intro hspecial
  have htwo := common_divisor_q_cube_sub_one_q_cube_add_one hq hgroup hspecial
  have hrle : r ≤ 2 := Nat.le_of_dvd (by decide) htwo
  omega

/-- Kernel-reducible certificate for an exact natural-number valuation.  This
avoids `native_decide`: the proof checks one divisibility and the failure of
the next power with `norm_num`, then uses the defining maximality theorem for
`padicValNat`. -/
theorem padicValNat_eq_of_pow_dvd_not_dvd {p n k : ℕ}
    (hp : p ≠ 1) (hn : n ≠ 0) (hdiv : p ^ k ∣ n)
    (hnot : ¬ p ^ (k + 1) ∣ n) : padicValNat p n = k := by
  apply Nat.le_antisymm
  · by_contra hle
    have hk : k + 1 ≤ padicValNat p n := by omega
    exact hnot ((Nat.pow_dvd_iff_le_padicValNat hp hn).2 hk)
  · exact (Nat.pow_dvd_iff_le_padicValNat hp hn).1 hdiv

/-- Six exact substitute-pair valuations (four exceptional groups, with both
PSL6 and D4 graph routes represented separately). -/
theorem substitute_prime_valuations :
    padicValNat 3 504 = 2 ∧ padicValNat 3 56 = 0 ∧
    padicValNat 3 14 = 0 ∧ padicValNat 3 3 = 1 ∧
    padicValNat 31 20158709760 = 1 ∧
    padicValNat 31 120960 = 0 ∧ padicValNat 31 28224 = 0 ∧
    padicValNat 31 20160 = 0 ∧ padicValNat 31 216 = 0 ∧
    padicValNat 5 174182400 = 2 ∧ padicValNat 5 20160 = 1 ∧
    padicValNat 5 216 = 0 ∧ padicValNat 5 6 = 0 ∧
    padicValNat 5 24 = 0 ∧
    padicValNat 3 1056706560 = 4 ∧ padicValNat 3 200704 = 0 ∧
    padicValNat 3 29120 = 0 ∧ padicValNat 3 6 = 1 := by
  repeat' constructor
  all_goals apply padicValNat_eq_of_pow_dvd_not_dvd <;> norm_num

/-- Single aggregate theorem used by FORMAL-COVERAGE.json.  Its fields are the
new arithmetic deductions; the published order formulas remain explicitly
named assumptions in the checked repository manifest rather than custom Lean
axioms. -/
structure UniversalCertificate : Prop where
  inventory : allBranches.length = 34 ∧ allBranches.Nodup ∧
    ∀ b : Branch, b ∈ allBranches
  boundInventory : branchBounds.length = 107
  occurrenceInventory : groupOccurrences.length = 32
  fixedFactorInventory : constantCertificates.length = 18
  exceptionInventory : zsigmondyExceptionPoints.length = 12 ∧
    zsigmondyExceptionPoints.Nodup
  bounds : ∀ c ∈ branchBounds, ∀ n, c.n0 ≤ n →
    0 < c.lower.eval n ∧ c.lower.eval n < c.upper.eval n
  occurrences : ∀ c ∈ groupOccurrences, c.Valid
  constants : ∀ c ∈ constantCertificates, c.Valid
  fixedFactorAvoidance : ∀ E C r,
    (ConstantCertificate.mk E C).Valid → C ≠ 0 → r.Prime → E < r → ¬ r ∣ C
  exceptions : ∀ b n f, isPrimitive b = true → rankOK b n → fieldOK b f →
    characteristicTwoAllowed b = true → exponentCoefficient b n * f = 6 →
    (b, n, f) ∈ zsigmondyExceptionPoints
  psl2Odd : ∀ p f, 0 < f → padicValNat p f < f
  nagura : ∀ n p, 31 ≤ n → 5 * n < 6 * p → n + 6 ≤ 2 * p
  factorial : ∀ n p, p.Prime → p ≤ n → n < 2 * p →
    padicValNat p n.factorial = 1
  alternatingFinite : ∀ np ∈ alternatingFinitePrimes,
    np.2.Prime ∧ np.2 ≤ np.1 ∧ np.1 < 2 * np.2 ∧ np.1 + 6 ≤ 2 * np.2
  sp4Special : ∀ r q, r.Prime → 2 < r → r ∣ q + 1 → ¬ r ∣ q ^ 2 + 1
  g2Special : ∀ r q, r.Prime → 2 < r → 0 < q →
    r ∣ q ^ 3 - 1 → ¬ r ∣ q ^ 3 + 1
  substitutes :
    padicValNat 3 504 = 2 ∧ padicValNat 3 56 = 0 ∧
    padicValNat 3 14 = 0 ∧ padicValNat 3 3 = 1 ∧
    padicValNat 31 20158709760 = 1 ∧
    padicValNat 31 120960 = 0 ∧ padicValNat 31 28224 = 0 ∧
    padicValNat 31 20160 = 0 ∧ padicValNat 31 216 = 0 ∧
    padicValNat 5 174182400 = 2 ∧ padicValNat 5 20160 = 1 ∧
    padicValNat 5 216 = 0 ∧ padicValNat 5 6 = 0 ∧
    padicValNat 5 24 = 0 ∧
    padicValNat 3 1056706560 = 4 ∧ padicValNat 3 200704 = 0 ∧
    padicValNat 3 29120 = 0 ∧ padicValNat 3 6 = 1

theorem family_arithmetic_universal : UniversalCertificate where
  inventory := ⟨exact_branch_inventory, branch_inventory_complete⟩
  boundInventory := exact_bound_inventory
  occurrenceInventory := exact_occurrence_inventory
  fixedFactorInventory := exact_fixed_factor_inventory
  exceptionInventory := by decide
  bounds := every_source_exponent_bound_is_universal
  occurrences := every_primitive_exponent_occurs_in_sourced_group_factor
  constants := every_fixed_factor_is_below_the_primitive_prime
  fixedFactorAvoidance := fun _ _ _ => prime_avoids_certified_constant
  exceptions := zsigmondy_exception_complete
  psl2Odd := fun _ _ => psl2_odd_field_valuation
  nagura := fun _ _ => nagura_implies_two_class_bound
  factorial := fun _ _ => factorial_prime_valuation_one
  alternatingFinite := alternating_finite_prime_certificates
  sp4Special := fun _ _ => prime_gt_two_avoids_sp4_special_factor
  g2Special := fun _ _ => prime_gt_two_avoids_g2_special_factor
  substitutes := substitute_prime_valuations

end FamilyArithmetic
end Kourovka1034
