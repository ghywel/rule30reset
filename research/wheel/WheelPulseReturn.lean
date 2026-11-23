module
public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! The first return of a black gate beside a white alternating wall. Positive
sites 2 through 5 determine the return on arbitrary infinite right halves. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelPulseReturn
open Rule30Ether Rule30StripCertificates Rule30PeriodTwoCoupled Rule30PeriodTwoSideways
open Rule30GateTrap Rule30SidewaysLocks

/-- The next pulse gap in white-sample intervals, given sites 2 through 5. -/
def gap (b2 b3 b4 b5 : Bool) : Nat :=
  if b2 then
    if b3 then (if b4 || b5 then 3 else 5) else (if b4 then 5 else 4)
  else
    if b3 then 4 else if b4 || b5 then 2 else 4

def nearGap (b2 b5 : Bool) : Nat :=
  if b2 then (if b5 then 3 else 5) else (if b5 then 2 else 4)

def GapAt (R : Nat → Bool) (s d : Nat) : Prop :=
  u R s = true ∧ (∀ j, 0 < j → j < d → u R (s+j) = false) ∧ u R (s+d) = true

private def readCell (w : List Bool) (j : Nat) : Bool :=
  (evolve 1 j (w.take (1+j))).headD false

private theorem parity_evolve (n t v : Nat) (h : t%2 = v%2) (row : List Bool) :
    evolve t n row = evolve v n row := by
  induction n generalizing t v row with
  | zero => rfl
  | succ n ih =>
    have wall : altCol t = altCol v := by simp only [altCol,h]
    simp only [evolve,wall]
    exact ih _ _ (by omega) _

private theorem read_physical (R : Nat → Bool) (s j : Nat) (hj : j ≤ 5) :
    readCell (winW 11 R (2*s+1)) (2*j) = u R (s+j) := by
  unfold readCell winW u
  have sub : (rowOf (drv altCol R) (2*s+1) 0 11).take (1+2*j) =
      rowOf (drv altCol R) (2*s+1) 0 (1+2*j) :=
    seg_take 11 (1+2*j) _ (by omega)
  rw [sub, parity_evolve (2*j) 1 (2*s+1) (by omega), ← rowOf_evolve R (2*j) (2*s+1) 1,
      show 2*(s+j)+1=2*s+1+2*j by omega]
  rfl

private def predicted (w : List Bool) := gap (w.getD 1 false) (w.getD 2 false)
    (w.getD 3 false) (w.getD 4 false)

private def check (w : List Bool) : Bool :=
  !w.headD false || (readCell w (2*predicted w) && ((List.range (predicted w)).all fun j =>
      j == 0 || !(readCell w (2*j))))

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
private theorem cone_check : (Rule30Jen.allLists 11).all check = true := by decide +kernel

/-- At any white-time pulse the four neighboring bits give the exact next pulse,
including every intervening white reading. No condition on the eastern tail. -/
theorem next_gap (R : Nat → Bool) (s : Nat) (pulse : u R s = true) :
    GapAt R s (gap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 3)
      (drv altCol R (2*s+1) 4) (drv altCol R (2*s+1) 5)) := by
  let w := winW 11 R (2*s+1)
  have len : w.length = 11 := length_seg 11 (fun i => drv altCol R (2*s+1) (0+i+1))
  have mem : w ∈ Rule30Jen.allLists 11 := len ▸ Rule30Jen.mem_allLists w
  have verified := List.all_eq_true.mp cone_check w mem
  have black : w.headD false = true := pulse
  have bound : predicted w ≤ 5 := by
    unfold predicted gap
    split <;> split <;> simp_all (config := {decide := true}) <;> split <;> decide
  change GapAt R s (predicted w)
  simp only [check,black,Bool.not_true,Bool.false_or,Bool.and_eq_true] at verified
  refine ⟨pulse, ?_, (read_physical R s (predicted w) bound).symm.trans verified.1⟩
  intro j hj hd
  have ok := List.all_eq_true.mp verified.2 j (List.mem_range.mpr hd)
  have nonzero : (j == 0) = false := by simp [Nat.ne_of_gt hj]
  rw [← read_physical R s j (by omega)]
  simpa only [nonzero,Bool.false_or,Bool.not_eq_true'] using ok

theorem next_gap_of_eq (R : Nat → Bool) (s : Nat) (pulse : u R s = true)
    (eq : gap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 3)
        (drv altCol R (2*s+1) 4) (drv altCol R (2*s+1) 5) =
      nearGap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 5)) :
    GapAt R s (nearGap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 5)) :=
  eq ▸ next_gap R s pulse

/-- The five pulse prefixes found in the two W43 variable components, in order
10001, 10011, 10110, 11100, 11101. The initial black cell is implicit. -/
def corePrefix (b2 b3 b4 b5 : Bool) : Bool :=
  [(false,false,false,true), (false,false,true,true), (false,true,true,false),
   (true,true,false,false), (true,true,false,true)].contains (b2,b3,b4,b5)

private theorem core_lookup : ∀ a b c d : Bool,
    corePrefix a b c d = true → gap a b c d = nearGap a d := by decide

theorem next_gap_of_core_prefix (R : Nat → Bool) (s : Nat) (pulse : u R s = true)
    (good : corePrefix (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 3)
        (drv altCol R (2*s+1) 4) (drv altCol R (2*s+1) 5) = true) :
    GapAt R s (nearGap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 5)) :=
  next_gap_of_eq R s pulse (core_lookup _ _ _ _ good)

end Ruliology.CellularAutomata.WheelPulseReturn
