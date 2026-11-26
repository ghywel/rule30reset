import Std

/-! The white western front of Rules 120 and 180, with no condition on the east. -/
namespace SiblingFront

inductive Rule where
  | r120 | r180

def Rule.cell : Rule → Bool → Bool → Bool → Bool
  | .r120, l, c, r => xor l (c && r)
  | .r180, l, c, r => xor l (c && !r)

def Rule.wait : Rule → Nat
  | .r120 => 3
  | .r180 => 2

abbrev Row := Int → Bool
def step (s : Rule) (x : Row) (i : Int) : Bool :=
  s.cell (x (i-1)) (x i) (x (i+1))

def evolve (s : Rule) (x : Row) : Nat → Row
  | 0 => x
  | t+1 => step s (evolve s x t)

def WhiteBelow (x : Row) (L : Int) : Prop := ∀ i, i < L → x i = false

private theorem stays (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) (t : Nat) :
    WhiteBelow (evolve s x t) L := by
  induction t with
  | zero => exact h
  | succ t ih =>
    intro i hi
    simp only [evolve, step, ih (i-1) (by omega), ih i hi]
    cases s <;> rfl

private theorem evolve_add (s : Rule) (x : Row) (a b : Nat) :
    evolve s x (a+b) = evolve s (evolve s x a) b := by
  induction b with
  | zero => rfl
  | succ b ih => exact congrArg (step s) ih

private theorem clears (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) :
    evolve s x s.wait L = false := by
  have edge (t : Nat) : evolve s x (t+1) L =
      s.cell false (evolve s x t L) (evolve s x t (L+1)) := by
    simp only [evolve, step, stays s x L h t (L-1) (by omega)]
  have next (t : Nat) : evolve s x (t+1) (L+1) =
      s.cell (evolve s x t L) (evolve s x t (L+1)) (evolve s x t (L+2)) := by
    simp only [evolve, step, show L+1-1=L by omega, show L+1+1=L+2 by omega]
  have third : evolve s x 1 (L+2) = s.cell (x (L+1)) (x (L+2)) (x (L+3)) := by
    simp only [evolve, step, show L+2-1=L+1 by omega, show L+2+1=L+3 by omega]
  cases s with
  | r120 =>
    change evolve .r120 x 3 L = false
    rw [edge 2, edge 1, next 1, edge 0, next 0, third]
    simp only [evolve]
    cases x L <;> cases x (L+1) <;> cases x (L+2) <;> cases x (L+3) <;> rfl
  | r180 =>
    change evolve .r180 x 2 L = false
    rw [edge 1, edge 0, next 0]
    simp only [evolve]
    cases x L <;> cases x (L+1) <;> cases x (L+2) <;> rfl

private theorem advance (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) :
    WhiteBelow (evolve s x s.wait) (L+1) := by
  intro i hi
  by_cases he : i = L
  · simpa only [he] using clears s x L h
  · exact stays s x L h s.wait i (by omega)

private theorem blocks (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) (n : Nat) :
    WhiteBelow (evolve s x (s.wait*n)) (L+(n:Int)) := by
  induction n with
  | zero => simpa [evolve] using h
  | succ n ih =>
    rw [Nat.mul_succ, evolve_add]
    simpa [Int.add_assoc] using advance s _ _ ih

/-- At every tick t all sites strictly west of L + floor(t / wait) are white. -/
theorem white_front (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) (t : Nat) :
    WhiteBelow (evolve s x t) (L+((t/s.wait:Nat):Int)) := by
  have split : s.wait*(t/s.wait) + t%s.wait = t := by
    simpa [Nat.add_comm] using Nat.mod_add_div t s.wait
  have drift := stays s _ _ (blocks s x L h (t/s.wait)) (t%s.wait)
  rwa [← evolve_add, split] at drift

/-- Each fixed site eventually stays white, including on rows with an infinite east. -/
theorem eventually_white (s : Rule) (x : Row) (L : Int) (h : WhiteBelow x L) (i : Int) :
    ∃ T : Nat, ∀ t ≥ T, evolve s x t i = false := by
  let n := (i - L + 1).toNat
  refine ⟨s.wait*n, fun t ht => ?_⟩
  have bound : i < L+(n:Int) := by dsimp [n]; omega
  have later := stays s _ _ (blocks s x L h n) (t - s.wait*n) i bound
  rwa [← evolve_add, Nat.add_sub_of_le ht] at later

end SiblingFront
