import Std

/-! Controls in the temporal-hybrid convention of K98. -/
namespace HybridParity
abbrev Row := Int → Bool
def linear (x : Row) (i : Int) := xor (xor (x (i-1)) (x i)) (x (i+1))
def nonlinear (x : Row) (i : Int) := xor (x (i-1)) (x i || x (i+1))
def iter (f : Row → Row) (x : Row) : Nat → Row
  | 0 => x
  | t+1 => f (iter f x t)
def round (x : Row) := linear (nonlinear x)
def Pure (p : Int) (x : Row) := ∀ i, i % 2 ≠ p → x i = false

private theorem atPure {p : Int} {x : Row} (h : Pure p x) : nonlinear x = linear x := by
  funext i
  by_cases hi : i % 2 = p
  · have z := h (i+1) (by omega)
    simp [linear, nonlinear, z]
  · simp [linear, nonlinear, h i hi]

/-- Squaring rule 150 doubles the spacing of its three inputs. -/
theorem linear_two (x : Row) (i : Int) :
    linear (linear x) i = xor (xor (x (i-2)) (x i)) (x (i+2)) := by
  simp only [linear, show i-1-1 = i-2 by omega, show i-1+1 = i by omega,
    show i+1-1 = i by omega, show i+1+1 = i+2 by omega]
  cases x (i-2) <;> cases x (i-1) <;> cases x i <;> cases x (i+1) <;> cases x (i+2) <;> rfl

theorem pure_round {p : Int} {x : Row} (h : Pure p x) : Pure p (round x) := by
  intro i hi
  rw [round, atPure h, linear_two, h i hi, h (i-2) (by omega), h (i+2) (by omega)]
  rfl

theorem same_even_and_odd {p : Int} {x : Row} (h : Pure p x) (n : Nat) :
    iter round x n = iter linear x (2*n) ∧
    nonlinear (iter round x n) = iter linear x (2*n+1) := by
  have hp (k : Nat) : Pure p (iter round x k) := by
    induction k with
    | zero => exact h
    | succ _ ih => exact pure_round ih
  have he (k : Nat) : iter round x k = iter linear x (2*k) := by
    induction k with
    | zero => rfl
    | succ k ih =>
      rw [show 2*(k+1) = (2*k+1)+1 by omega]
      change linear (nonlinear (iter round x k)) = linear (linear (iter linear x (2*k)))
      rw [atPure (hp k), ih]
  exact ⟨he n, by rw [atPure (hp n), he]; rfl⟩

def Symmetric (x : Row) := ∀ i, x (-i) = x i
private theorem sym_step {x : Row} (h : Symmetric x) : Symmetric (linear x) := by
  intro i
  simp only [linear, show -i-1 = -(i+1) by omega, show -i+1 = -(i-1) by omega]
  rw [h (i+1), h i, h (i-1)]
  cases x (i-1) <;> cases x i <;> cases x (i+1) <;> rfl

private theorem centre_linear {x : Row} (h : Symmetric x) : linear x 0 = x 0 := by
  have h1 := h 1
  change x (-1) = x 1 at h1
  change xor (xor (x (-1)) (x 0)) (x 1) = x 0
  rw [h1]
  cases x 0 <;> cases x 1 <;> rfl

/-- Every reflection-symmetric start supported on one parity keeps its centre
colour at every tick of the temporal (30,150) hybrid. -/
theorem constant_centre {x : Row} {p : Int} (hp : Pure p x) (hs : Symmetric x) (n : Nat) :
    iter round x n 0 = x 0 ∧ nonlinear (iter round x n) 0 = x 0 := by
  have h (t : Nat) : Symmetric (iter linear x t) ∧ iter linear x t 0 = x 0 := by
    induction t with
    | zero => exact ⟨hs, rfl⟩
    | succ t ih => exact ⟨sym_step ih.1, (centre_linear ih.1).trans ih.2⟩
  rw [(same_even_and_odd hp n).2, (same_even_and_odd hp n).1]
  exact ⟨(h _).2, (h _).2⟩

def wolfram (n : Nat) (l c r : Bool) :=
  n.testBit (4*l.toNat+2*c.toNat+r.toNat)

/-- Removing the alternating background of 45/75 gives the two opposite
orders of (210,180); a fixed normalized wall flashes in the original system. -/
theorem flashing (l c r : Bool) :
    (!wolfram 45 l c r) = wolfram 210 l c r ∧
    wolfram 45 (!l) (!c) (!r) = wolfram 180 l c r ∧
    (!wolfram 75 l c r) = wolfram 180 l c r ∧
    wolfram 75 (!l) (!c) (!r) = wolfram 210 l c r := by
  cases l <;> cases c <;> cases r <;> decide

end HybridParity
