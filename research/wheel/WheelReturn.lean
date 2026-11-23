module
public import WheelMarker

/-! A main-wheel observation followed by the 14-tick return can locate a failure
of a proposed alternating singleton centre using observations of column one alone. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelReturn
open Rule30Ether Rule30GateTrap Rule30PeriodTwoCoupled WheelMarker

private theorem driven_agrees {F : Nat → Nat → Bool} (hf : IsR30 F) (B H : Nat)
    (wall : ∀ j, j≤H → F (B+j) 0 = altCol j) (k : Nat) (hk : k≤H) (p : Nat) :
    F (B+k) p = drv altCol (F B) k p := by
  induction k generalizing p with
  | zero =>
    cases p with
    | zero => simpa only [drv_col0] using wall 0 (by omega)
    | succ p => exact (drv_init _ _ _ (Nat.succ_pos p)).symm
  | succ k ih =>
    cases p with
    | zero => simpa only [drv_col0] using wall (k+1) hk
    | succ p =>
      rw [show B+(k+1)=B+k+1 by omega,hf (B+k) p,(drv_isR30 altCol (F B)) k p]
      rw [ih (by omega) p,ih (by omega) (p+1),ih (by omega) (p+2)]

/-- Finite singleton-centre break from column one alone. A is the proposed white
phase of the centre clock. The return can start at either physical parity. -/
theorem singleton_return_break (A t : Nat) (p : Fin 28) (q : Fin 14)
    (later : A+132≤t) (aligned : (t-A)%2=q.val%2)
    (wheel : ∀ j, j<67 → Rule30Jen.cell (A+2*j) 1 = gateBit (p.val+j))
    (back : ∀ j, j<17 → Rule30Jen.cell (t+j) 1 = WheelTiles.secondary (q.val+j)) :
    ∃ v, A≤v ∧ v≤t+16 ∧ Rule30Jen.cell v 0 ≠ ((v-A)%2 == 1) := by
  classical
  apply Classical.byContradiction
  intro noBreak
  have keep (v : Nat) (lo : A≤v) (hi : v≤t+16) : trueRight v 0 = ((v-A)%2 == 1) :=
    Classical.byContradiction fun h => noBreak ⟨v,lo,hi,h⟩
  have white (j : Nat) (hj : j<66) : trueRight (A+2*j) 0 = false ∧
      trueRight (A+2*j+1) 0 = true := by
    rw [keep _ (by omega) (by omega),keep _ (by omega) (by omega),
        show ((A+2*j)-A)%2=0 by omega,show ((A+2*j+1)-A)%2=1 by omega]
    decide
  have hit := wheel_enters trueRight_isR30 A p white wheel
  let B := A+131
  let H := t+16-B
  have clock (j : Nat) (hj : j≤H) : trueRight (B+j) 0 = altCol j := by
    rw [keep _ (by dsimp [B]; omega) (by dsimp [H,B] at *; omega)]
    unfold B altCol
    by_cases even : j%2=0
    · simp only [even,show (A+131+j-A)%2=1 by omega]; decide
    · simp only [show j%2=1 by omega,show (A+131+j-A)%2=0 by omega]; decide
  have same := driven_agrees trueRight_isR30 B H clock
  have inside : win (trueRight B) 1 ∈ trap := by
    have eq : win (trueRight B) 1 = rowOf trueRight (A+132) 0 16 := by
      apply Rule30SidewaysLocks.seg_congr
      intro i _
      exact (same 1 (by dsimp [H,B]; omega) (0+i+1)).symm
    exact eq.symm ▸ hit
  apply WheelTiles.no_seventeen_secondary (trueRight B) (t0:=1) (t:=t-B) (by decide) inside
    (by dsimp [B]; omega) q (by dsimp [B]; omega)
  intro j hj
  rw [← same (t-B+j) (by dsimp [H,B]; omega) 1, show B+(t-B+j)=t+j by dsimp [B]; omega]
  exact back j hj

end Ruliology.CellularAutomata.WheelReturn
