module

public import Rule30LockPredecessor
public import Rule30LockFirstBoundary

/-! A width-30 or width-31 free-boundary predecessor can miss a genuinely
forcing prefix at every rank. A fabricated branch reaches the odd window
of a different physical seed whose entire future stays in the 16-cell trap. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LockRankObstruction
open Rule30SidewaysLocks Rule30GateTrap Rule30Lock7Prefixes Rule30Lock7Compactness
open Rule30LockPredecessor Rule30StripCertificates

def outside (w : List Bool) :=
  decide (¬∃ k : Fin 7, w.take 30 ∈ cls 30 lock7Codes k.val)

def Refuses (w : List Bool) : Prop := ∀ j, ¬forcesWithin lockTarget j w

/-- A finite path outside the lock can carry an obstruction back to its start. -/
def avoidsTo : List (Bool × Bool) → List Bool → List Bool → Bool
  | [], w, goal => decide (w = goal)
  | (a,b)::s, w, goal => outside w && avoidsTo s (dstep w a b) goal

theorem refuses_of_avoiding_path {path : List (Bool × Bool)} {w goal : List Bool}
    (safe : avoidsTo path w goal = true) (endBad : Refuses goal) : Refuses w := by
  induction path generalizing w with
  | nil =>
    have eq : w = goal := of_decide_eq_true safe
    exact eq ▸ endBad
  | cons edge tail ih =>
    obtain ⟨a,b⟩ := edge
    simp only [avoidsTo, Bool.and_eq_true] at safe
    obtain ⟨h, next⟩ := safe
    have noHit : ¬lockTarget w := by
      unfold lockTarget
      exact of_decide_eq_true h
    have noNext := ih next
    intro j
    cases j with
    | zero => exact noHit
    | succ j =>
      rintro (hit | paths)
      · exact noHit hit
      · exact noNext j (paths a b)

/-- A real trapped continuation of the endpoint defeats every universal rank. -/
theorem refuses_of_trap {W seed : Nat} (wide : 30 ≤ W)
    (trapped : win (rh seed) 1 ∈ trap) :
    Refuses (evolve 0 1 (decodeW (W+1) seed)) := by
  rw [←winW_prefix (R:=rh seed) (W:=W) (t0:=1) (rh_prefix seed (W+1))]
  intro n rank
  obtain ⟨j, _, k, hit⟩ := forcesWithin_reaches (rh seed) W lockTarget n 1 (by decide) rank
  rw [winW_take (rh seed) (1+2*j) 30 W wide] at hit
  exact locked_outside_trap (R:=rh seed) (j:=j) ⟨k,hit⟩
    (win_mem_trap (rh seed) (t0:=1) (by decide) trapped j)

private def path30 := (List.range 43).map fun i => (decide (i=3 ∨ i=13 ∨ i=16), false)
private def path31 := (List.range 43).map fun i => (decide (i=6 ∨ i=20), false)

set_option maxRecDepth 50000
set_option maxHeartbeats 12000000

private theorem trap_seed30 : win (rh 364085500) 1 ∈ trap := by
  change winW 16 (rh 364085500) 1 ∈ trap
  rw [winW_prefix (rh_prefix 364085500 17)]
  decide +kernel

private theorem trap_seed31 : win (rh 540246268) 1 ∈ trap := by
  change winW 16 (rh 540246268) 1 ∈ trap
  rw [winW_prefix (rh_prefix 540246268 17)]
  decide +kernel

theorem width30_refuses : ∀ J, ¬ Predecessor 31 542492123 30 J := by
  have path : avoidsTo path30 (evolve 0 1 (decodeW 31 542492123))
      (evolve 0 1 (decodeW 31 364085500)) = true := by decide +kernel
  have bad := refuses_of_avoiding_path path (refuses_of_trap (W:=30) (by decide) trap_seed30)
  exact fun J rank => bad J (rank 542492123 (by decide) (fun _ _ => rfl))

theorem width31_refuses : ∀ J, ¬ Predecessor 31 542492123 31 J := by
  have path : avoidsTo path31 (evolve 0 1 (decodeW 32 2689975771))
      (evolve 0 1 (decodeW 32 540246268)) = true := by decide +kernel
  have bad := refuses_of_avoiding_path path (refuses_of_trap (W:=31) (by decide) trap_seed31)
  have prefBits : ∀ i : Fin 31, (2689975771 : Nat).testBit i.val = (542492123 : Nat).testBit i.val := by decide +kernel
  exact fun J rank => bad J (rank 2689975771 (by decide) (fun i hi => prefBits ⟨i,hi⟩))

/-- Every completion locks at tick three. Even unlimited ranks at widths 30
and 31 fail, whereas width 32 already succeeds at rank one. -/
theorem separating_prefix :
    checkCover 31 542492123 1 = true ∧ Predecessor 31 542492123 32 1 ∧
      (∀ J, ¬Predecessor 31 542492123 30 J) ∧ (∀ J, ¬Predecessor 31 542492123 31 J) := by
  have yes : checkCover 31 542492123 1 = true := by decide +kernel
  exact ⟨yes, (cover_iff_predecessor (by decide) (by decide)).mp yes, width30_refuses, width31_refuses⟩


/-- The feasible boundary test gives the same exact window and phase for all suffixes. -/
theorem physical_endpoint (R : Nat → Bool) (pref : HasPrefix 31 542492123 R) :
    winW 30 R 3 = decodeW 30 793950727 ∧ winW 30 R 3 ∈ cls 30 lock7Codes 3 := by
  let P := fun w : List Bool => w = decodeW 30 793950727 ∧ w ∈ cls 30 lock7Codes 3
  apply (Rule30LockFirstBoundary.exact_one_step 29 542492123 P).mpr ?_ R pref
  dsimp [P]
  decide +kernel

/-- Width 32 is minimal even when the narrower game may use any finite rank. -/
theorem eventual_rank_iff (W : Nat) (wide : 30 ≤ W) :
    (∃ J, Predecessor 31 542492123 W J) ↔ 32 ≤ W := by
  constructor
  · rintro ⟨J, h⟩
    apply Classical.byContradiction
    intro short
    rcases (show W = 30 ∨ W = 31 by omega) with rfl | rfl
    · exact width30_refuses J h
    · exact width31_refuses J h
  · intro room
    exact ⟨1, (cover_iff_predecessor (by omega) (by omega)).mp separating_prefix.1⟩

end Ruliology.CellularAutomata.Rule30LockRankObstruction
