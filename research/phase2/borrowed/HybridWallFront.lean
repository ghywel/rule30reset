import Std

/-! White-front speed in the time hybrid with Rule 30 first and Rule 180 second.
    Integer positions increase from west to east. A wall clamps every site at and east of 0. -/
namespace HybridWallFront

abbrev Row := Int → Bool
abbrev Local := Bool → Bool → Bool → Bool
def r30 (l c r : Bool) := xor l (c || r)
def r180 (l c r : Bool) := xor l (c && !r)
def line : Row := fun _ => true
def wall : Row := fun p => decide (p < 0)

def tick (mask : Row) (f : Local) (x : Row) (p : Int) : Bool :=
  mask p && f (x (p - 1)) (x p) (x (p + 1))

def pair (mask : Row) (x : Row) := tick mask r180 (tick mask r30 x)

def rounds (mask : Row) : Nat → Row → Row
  | 0, x => x
  | n+1, x => rounds mask n (pair mask x)

def WhiteBelow (x : Row) (L : Int) := ∀ p, p < L → x p = false

private theorem stays {mask x : Row} {L : Int} (hw : WhiteBelow x L)
    (hm : ∀ p, p ≤ L → mask p = true) : WhiteBelow (pair mask x) L := by
  intro p hp
  unfold WhiteBelow at hw
  simp +arith (disch := omega) [pair, tick, r30, r180, hm, hw]
  cases x (p+1) <;> cases x (p+2) <;> decide

private theorem clears {mask x : Row} {L : Int} (hw : WhiteBelow x L)
    (hm : ∀ p, p < L+4 → mask p = true) :
    pair mask (pair mask x) L = false := by
  unfold WhiteBelow at hw
  simp +arith (disch := omega) [pair, tick, r30, r180, hm, hw]
  cases x L <;> cases x (L+1) <;> cases x (L+2) <;> cases x (L+3) <;> cases x (L+4) <;> decide

private theorem advance {mask x : Row} {L : Int} (hw : WhiteBelow x L)
    (hm : ∀ p, p < L + 4 → mask p = true) :
    WhiteBelow (pair mask (pair mask x)) (L+1) := by
  have localOpen (p : Int) (hp : p ≤ L) := hm p (by omega)
  have stay := stays (stays hw localOpen) localOpen
  intro p hp
  by_cases heq : p = L
  · exact heq ▸ clears hw hm
  · exact stay p (by omega)

/-- At tick 4n everything strictly west of L+n is white, even with an infinite east. -/
theorem line_four_tick_front (x : Row) (L : Int) (hw : WhiteBelow x L) (n : Nat) :
    WhiteBelow (rounds line (2*n) x) (L + (n : Int)) := by
  induction n generalizing x L with
  | zero => simpa [rounds] using hw
  | succ n ih =>
    rw [Nat.mul_succ]
    have next := advance hw (mask := line) (fun _ _ => rfl)
    simpa +arith [rounds] using ih _ _ next

private theorem into_three (n : Nat) (x : Row) (hw : WhiteBelow x (-3 - (n : Int))) :
    WhiteBelow (rounds wall (2*n) x) (-3) := by
  induction n generalizing x with
  | zero => simpa [rounds] using hw
  | succ n ih =>
    have next := advance hw (mask := wall) (fun p hp => by
      simp only [wall, decide_eq_true_eq]; omega)
    rw [Nat.mul_succ]
    apply ih
    simpa +arith using next

private theorem rounds_add (mask : Row) (a b : Nat) (x : Row) :
    rounds mask (a + b) x = rounds mask b (rounds mask a x) := by
  induction a generalizing x with
  | zero => simp [rounds]
  | succ a ih => simpa [Nat.succ_add, rounds] using ih (pair mask x)

private theorem line_even_front (x : Row) (L : Int) (hw : WhiteBelow x L) (k : Nat) :
    WhiteBelow (rounds line k x) (L + ((k/2 : Nat) : Int)) := by
  have h := line_four_tick_front x L hw (k/2)
  rcases Nat.mod_two_eq_zero_or_one k with even | odd
  · rwa [show 2*(k/2) = k by omega] at h
  · have h' : WhiteBelow (rounds line (2*(k/2)+1) x) (L + ((k/2 : Nat) : Int)) := by
      rw [rounds_add]
      exact stays h (fun _ _ => rfl)
    rwa [show 2*(k/2)+1 = k by omega] at h'

/-- The line row at a physical tick, applying Rule 30 to even-tick inputs. -/
def lineAt (x : Row) (t : Nat) :=
  if t%2 = 0 then rounds line (t/2) x else tick line r30 (rounds line (t/2) x)

/-- All ticks beyond one deadline give a white reading at a fixed site. -/
theorem line_eventually_white (x : Row) (L : Int) (hw : WhiteBelow x L) (i : Int) :
    ∃ T : Nat, ∀ t ≥ T, lineAt x t i = false := by
  let n := (i-L+2).toNat
  refine ⟨4*n, ?_⟩
  intro t ht
  have west := line_even_front x L hw (t/2)
  have hi : i+1 < L + ((t/2/2 : Nat) : Int) := by dsimp [n] at ht; omega
  unfold lineAt
  split
  · exact west i (by omega)
  · simp [tick, r30, west (i-1) (by omega), west i (by omega), west (i+1) hi]

/-- The reversed hybrid takes one Rule 180 tick and then runs the forward hybrid. -/
def reverseLineAt (x : Row) : Nat → Row
  | 0 => x
  | t+1 => lineAt (tick line r180 x) t

theorem reversed_line_eventually_white (x : Row) (L : Int) (hw : WhiteBelow x L) (i : Int) :
    ∃ T : Nat, ∀ t ≥ T, reverseLineAt x t i = false := by
  have hw' : WhiteBelow (tick line r180 x) L := by
    intro p hp
    simp [tick, r180, hw p hp, hw (p-1) (by omega)]
  obtain ⟨T, h⟩ := line_eventually_white _ _ hw' i
  refine ⟨T+1, ?_⟩
  intro t ht
  cases t with
  | zero => omega
  | succ t => exact h t (by omega)

private def short (a b c : Bool) (p : Int) : Bool :=
  if p = -1 then a else if p = -2 then b else if p = -3 then c else false

/-- A row encoded by the three bits at depths 1 through 3, least significant first. -/
def packed (n : Nat) := short (n.testBit 0) (n.testBit 1) (n.testBit 2)

private theorem packed_white (n : Nat) (p : Int) (h : p < -3 ∨ 0 ≤ p) : packed n p = false := by
  unfold packed short
  rw [ite_eq_right (by omega), ite_eq_right (by omega), ite_eq_right (by omega)]

private theorem shape {x : Row} (hw : WhiteBelow x (-3))
    (hz : ∀ p, 0 ≤ p → x p = false) : x = short (x (-1)) (x (-2)) (x (-3)) := by
  funext p
  by_cases h1 : p = -1
  · simp [short, h1]
  by_cases h2 : p = -2
  · simp [short, h2]
  by_cases h3 : p = -3
  · simp [short, h3]
  simp [short, h1, h2, h3]
  by_cases hp : p < -3
  · exact hw _ hp
  · exact hz _ (by omega)

private theorem clamped {x : Row} (hz : ∀ p, 0 ≤ p → x p = false) (n : Nat) :
    ∀ p, 0 ≤ p → rounds wall n x p = false := by
  induction n generalizing x with
  | zero => exact hz
  | succ n ih =>
    apply ih
    intro p hp
    simp [pair, tick, wall, Int.not_lt.mpr hp]

/-- The exact even-tick map on the final three cells at the wall. -/
def nextThree (y : Fin 8) : Nat := [0, 0, 2, 1, 5, 3, 3, 2][y.val]'(by simp)

theorem wall_three_cell_map (y : Fin 8) : pair wall (packed y.val) = packed (nextThree y) := by
  have bits : ∀ j : Fin 8,
      pair wall (packed j.val) (-1) = (nextThree j).testBit 0 ∧
      pair wall (packed j.val) (-2) = (nextThree j).testBit 1 ∧
      pair wall (packed j.val) (-3) = (nextThree j).testBit 2 := by decide +kernel
  have west : WhiteBelow (packed y.val) (-3) := fun p hp => packed_white _ _ (Or.inl hp)
  have west' := stays west (mask := wall) (fun p hp => by simp only [wall, decide_eq_true_eq]; omega)
  have east (p : Int) (hp : 0 ≤ p) : pair wall (packed y.val) p = false := by
    simp [pair, tick, wall, Int.not_lt.mpr hp]
  exact (shape west' east).trans (by rw [(bits y).1, (bits y).2.1, (bits y).2.2]; rfl)

private theorem finish_short (a b c : Bool) :
    ∃ k ≤ 3, rounds wall k (short a b c) (-1) = false := by
  cases a <;> cases b <;> cases c <;> decide +kernel

/-- Every width-W west fails an even check by tick 4*(W-3)+6 (natural subtraction).
    Each round in the formal bound corresponds to two physical ticks. -/
theorem wall_deadline (W : Nat) (x : Row) (hw : WhiteBelow x (-(W : Int)))
    (hz : ∀ p, 0 ≤ p → x p = false) :
    ∃ k ≤ 2*(W-3)+3, rounds wall k x (-1) = false := by
  let n := W - 3
  let z := rounds wall (2*n) x
  have hh : WhiteBelow x (-3 - (n : Int)) := by
    intro p hp; apply hw; dsimp [n] at hp; omega
  have sh := shape (x := z) (into_three n x hh) (clamped hz (2*n))
  obtain ⟨k, hk, res⟩ := finish_short (z (-1)) (z (-2)) (z (-3))
  refine ⟨2*n+k, by dsimp [n] at *; omega, ?_⟩
  rw [rounds_add]
  change rounds wall k z (-1) = false
  rwa [sh]

theorem reverse_steps : tick wall r180 (packed 7) = packed 2 ∧
    tick wall r30 (packed 2) = packed 7 := by
  constructor <;> funext p
  all_goals
    by_cases west : p ≤ -5
    · simp (disch := omega) [tick, packed_white, r30, r180]
    by_cases east : 0 ≤ p
    · simp [tick, wall, Int.not_lt.mpr east, packed_white _ _ (Or.inr east)]
    have sites : p = -1 ∨ p = -2 ∨ p = -3 ∨ p = -4 := by omega
    rcases sites with h | h | h | h <;> subst p <;> decide

def reverseRounds : Nat → Row → Row
  | 0, x => x
  | n+1, x => reverseRounds n (tick wall r30 (tick wall r180 x))

/-- Reversing the time order gives an actual invariant even row, with depth one black. -/
theorem reversed_seven (n : Nat) :
    reverseRounds n (packed 7) = packed 7 ∧ reverseRounds n (packed 7) (-1) = true := by
  have fixed : reverseRounds n (packed 7) = packed 7 := by
    induction n with
    | zero => rfl
    | succ n ih => simpa only [reverseRounds, reverse_steps.1, reverse_steps.2] using ih
  exact ⟨fixed, by rw [fixed]; decide⟩

end HybridWallFront
