import Ruliology.CellularAutomata.Rule30StripCertificates

/-! Coupling six observed columns to the graph with two free exterior bits.
Bit zero and ternary digit zero refer to the westernmost observed site. -/
namespace PhaseFalls.Six

open Ruliology.CellularAutomata Rule30Jen Rule30StripCertificates

def step (s : Nat) (w e : Bool) : Nat := stripStep 6 w e s

def row (T : Nat) (j : Int) : Nat := encRow T (j-1) 6

theorem row_lt (T : Nat) (j : Int) : row T j < 64 :=
  (enc_encRow 6 T (j-1)).1

theorem row_bit (T : Nat) (j : Int) (k : Nat) (hk : k<6) :
    (row T j).testBit k = cell T (j+k) := by
  simpa [row] using (enc_encRow 6 T (j-1)).2 k hk

theorem row_step (T : Nat) (j : Int) :
    row (T+1) j = step (row T j) (cell T (j-1)) (cell T (j+6)) := by
  have nxt := enc_step (enc_encRow 6 T (j-1))
  simp only [Int.sub_add_cancel] at nxt
  apply Nat.eq_of_testBit_eq
  intro k
  by_cases hk : k<6
  · rw [row_bit _ _ k hk]
    simpa [step,row] using (nxt.2 k hk).symm
  · have cut : 2^6 ≤ 2^k := Nat.pow_le_pow_right (by decide) (by omega)
    rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (row_lt _ _) cut)]
    exact (Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le nxt.1 cut)).symm

/-- In a permitted edge, every site falling now has its assigned time phase. -/
def allowed (a t s d : Nat) : Bool :=
  (List.range 6).all fun k => !(s.testBit k && !d.testBit k) || t == a / 3^k % 3

theorem allowed_succ (a t T : Nat) (j : Int)
    (h : ∀ k : Nat, k<6 → cell T (j+k) = true → cell (T+1) (j+k) = false →
      t = a / 3^k % 3) :
    allowed a t (row T j) (row (T+1) j) = true := by
  apply List.all_eq_true.mpr
  intro k hk
  have bound := List.mem_range.mp hk
  simp only [row_bit _ _ k bound]
  cases on : cell T (j+k) <;> cases off : cell (T+1) (j+k) <;> try rfl
  simp [h k bound on off]

def encode (p : Nat → Nat) : Nat :=
  p 0 + 3 * p 1 + 9 * p 2 + 27 * p 3 + 81 * p 4 + 243 * p 5

theorem encode_lt (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) : encode p < 729 := by
  have := hp 0 (by decide)
  have := hp 1 (by decide)
  have := hp 2 (by decide)
  have := hp 3 (by decide)
  have := hp 4 (by decide)
  have := hp 5 (by decide)
  unfold encode
  omega

theorem encode_digit (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) (k : Nat) (hk : k<6) :
    encode p / 3^k % 3 = p k := by
  have := hp 0 (by decide)
  have := hp 1 (by decide)
  have := hp 2 (by decide)
  have := hp 3 (by decide)
  have := hp 4 (by decide)
  have := hp 5 (by decide)
  unfold encode
  rcases (show k=0 ∨ k=1 ∨ k=2 ∨ k=3 ∨ k=4 ∨ k=5 by omega) with
    rfl | rfl | rfl | rfl | rfl | rfl <;> simp only [Nat.reducePow] <;> omega

theorem encode_mod (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) (h0 : p 0=0) :
    encode p % 3 = 0 := by
  simpa [h0] using encode_digit p hp 0 (by decide)

end PhaseFalls.Six
