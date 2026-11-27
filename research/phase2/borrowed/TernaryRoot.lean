import Ruliology.CellularAutomata.Rule30FiniteMaskedJen

/-! Wolfram's ternary square roots, NKS p. 956. The intermediate sites lie on
bonds; the second half step takes the two bonds touching the original site. -/
namespace TernaryRoot
open Ruliology.CellularAutomata Rule30Realization Rule30Jen

abbrev Colour := Fin 3
def embed (b : Bool) : Colour := if b then 2 else 0
def bond (a b : Bool) : Colour := if a then 1 else if b then 2 else 0
def headBit (c : Colour) : Bool := decide (c = 1)
def orBit (c : Colour) : Bool := decide (c ≠ 0)

inductive Root | first | second | third deriving DecidableEq
def Root.code : Root → Nat
  | .first => 11736
  | .second => 11739
  | .third => 11742

def half (q : Root) (a b : Colour) : Colour :=
  ⟨q.code / 3 ^ (3 * a.val + b.val) % 3, Nat.mod_lt _ (by decide)⟩

theorem encode (q : Root) (a b : Bool) : half q (embed a) (embed b) = bond a b := by
  cases q <;> cases a <;> cases b <;> decide

theorem square (q : Root) (l c r : Bool) :
    half q (bond l c) (bond c r) = embed (rule l c r) := by
  cases q <;> cases l <;> cases c <;> cases r <;> decide

def mid (q : Root) (x : Int → Colour) (i : Int) := half q (x i) (x (i+1))
def rounds (q : Root) (x : Int → Bool) : Nat → Int → Colour
  | 0 => fun i => embed (x i)
  | t+1 => fun i => half q (mid q (rounds q x t) (i-1)) (mid q (rounds q x t) i)

theorem rounds_eq (q : Root) (x : Int → Bool) (t : Nat) (i : Int) :
    rounds q x t i = embed (evol x t i) := by
  induction t generalizing i with
  | zero => rfl
  | succ t ih =>
    simp only [rounds, mid, ih, encode, show i-1+1 = i by omega, square, evol]

theorem intermediate_eq (q : Root) (x : Int → Bool) (t : Nat) (i : Int) :
    mid q (rounds q x t) i = bond (evol x t i) (evol x t (i+1)) := by
  simp only [mid, rounds_eq, encode]

theorem projections (a b : Bool) :
    headBit (bond a b) = a ∧ orBit (bond a b) = (a || b) := by
  cases a <;> cases b <;> decide

/-- The OR gate and the next head bit recover the west cell. -/
theorem decodeWest (q : Root) (x : Int → Bool) (t : Nat) (i : Int) :
    evol x t (i-1) = xor (headBit (mid q (rounds q x (t+1)) i))
                         (orBit (mid q (rounds q x t) i)) := by
  simpa only [intermediate_eq, (projections _ _).1, (projections _ _).2,
    Rule30FiniteMaskedJen.orCol] using Rule30FiniteMaskedJen.evol_left' x t i

/-- The only forbidden adjacent words in a physical intermediate row are 01, 20 and 22. -/
def Legal (z : Int → Colour) : Prop := ∀ i,
  (z i = 0 → z (i+1) ≠ 1) ∧ (z i = 2 → z (i+1) = 1)

theorem legal_iff_image (z : Int → Colour) :
    Legal z ↔ ∃ x : Int → Bool, ∀ i, z i = bond (x i) (x (i+1)) := by
  constructor
  · intro h
    refine ⟨headBit ∘ z, fun i => ?_⟩
    change z i = bond (headBit (z i)) (headBit (z (i+1)))
    have h0 := (h i).1
    have h2 := (h i).2
    have three : ∀ c : Colour, c = 0 ∨ c = 1 ∨ c = 2 := by decide
    obtain hi | hi | hi := three (z i)
    · simp [hi, headBit, bond, h0 hi]
    · simp [hi, headBit, bond]
    · simp [hi, headBit, bond, h2 hi]
  · rintro ⟨x,h⟩ i
    rw [h i, h (i+1)]
    cases x i <;> cases x (i+1) <;> cases x (i+1+1) <;> decide

/-- Masked Jen, read at a fixed physical bond at the intermediate half ticks. -/
theorem bond_aperiodic (q : Root) {x : Int → Bool} {lo : Int}
    (hlo : x lo = true) (hz : ∀ i, i < lo → x i = false) (i : Int) :
    ¬ ∃ T P : Nat, 0 < P ∧ ∀ t ≥ T,
      mid q (rounds q x (t+P)) i = mid q (rounds q x t) i := by
  rintro ⟨T, P, hp, h⟩
  apply Rule30FiniteMaskedJen.orCol_not_eventuallyPeriodic hlo hz i
  · exact ⟨T,P,hp,fun t ht => by
      simpa only [intermediate_eq, (projections _ _).1] using congrArg headBit (h t ht)⟩
  · exact ⟨T,P,hp,fun t ht => by
      simpa only [intermediate_eq, (projections _ _).2, Rule30FiniteMaskedJen.orCol]
        using congrArg orBit (h t ht)⟩

end TernaryRoot
