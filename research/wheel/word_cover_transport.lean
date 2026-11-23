module
public import word_cover_language
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open Rule30DrivenPrefix Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoCoupled
open Rule30Ether Rule30StripCertificates Rule30PeriodTwoSideways WheelGateObserver

private theorem firsts {r : Nat → Nat} (t : Nat) (bits : List Bool)
    (read : ∀ i, i<bits.length → (r (t+i)).testBit 0 = bits.getD i false) :
    PureThreeExit.fits 1 r t (bits.map fun b => [b.toNat]) := by
  induction bits generalizing t with
  | nil => trivial
  | cons b ds ih =>
    constructor
    · have e := read 0 (by simp)
      simp only [Nat.add_zero, List.getD_cons_zero] at e
      have lt := Nat.mod_lt (r t) (by decide : 0<2)
      cases b <;> simp_all [Nat.testBit_zero] <;> omega
    · apply ih
      intro i hi
      simpa [Nat.add_assoc,Nat.add_comm 1 i] using read (i+1) (by simpa using hi)

/-- Covering the finite light cone allows an arbitrary eastern continuation. -/
private theorem cone (R : Nat → Bool) (b x W : Nat)
    (start : ∀ j, j < W → x.testBit j = drv altCol R b (j+1)) :
    ∀ t j, j+t < W → (packed (fun k => altCol (b+k)) x t).testBit j =
      drv altCol R (b+t) (j+1) := by
  intro t
  induction t with
  | zero => exact start
  | succ t ih =>
    intro j hj
    rw [packed,step_bit,show b+(t+1)=b+t+1 by omega,drv_isR30 altCol R (b+t) j]
    unfold Rule30Jen.rule
    rw [ih j (by omega),ih (j+1) (by omega)]
    cases j with
    | zero => simp [drv_col0]
    | succ j => simp [ih j (by omega)]

private theorem twice (b x : Nat) (h : b%2=1) :
    ∀ i, iterate x i = packed (fun k => altCol (b+k)) x (2*i) := by
  intro i
  induction i with
  | zero => rfl
  | succ i ih =>
    have ho : altCol (b+2*i)=false := by unfold altCol; simp; omega
    have he : altCol (b+2*i+1)=true := by unfold altCol; simp; omega
    rw [iterate,ih,show 2*(i+1)=2*i+1+1 by omega,packed,packed,ho,
      show b+(2*i+1)=b+2*i+1 by omega,he,double]

/-- A disappearing width lift certifies a physical trap entry at the end of that very word. -/
theorem marker_enters {w : List Bool} {k : Nat} (cut : (PureThreeExit.layers w true k).head? = some [])
    {R : Nat → Bool} {s : Nat} (read : Reads (u R) s w) : InTrap R (s+(w.length-1)) := by
  let b := 2*s+1
  let W := 16+2*w.length
  let row := drv altCol R b
  let x := Rule30ZeroBoundary.IntegerForm.natOfRow row W
  have initBits (j : Nat) (bound : j<W) : x.testBit j=row (j+1) := by
    simp [x,Rule30ZeroBoundary.IntegerForm.testBit_natOfRow,bound]
  have agree (i j : Nat) (bound : j+2*i<W) :
      (iterate x i).testBit j = drv altCol R (2*(s+i)+1) (j+1) := by
    rw [twice b x (by dsimp [b]; omega),show 2*(s+i)+1=b+2*i by dsimp [b];omega]
    exact cone R b x W initBits _ _ bound
  have base := firsts (r:=iterate x) 0 w (by
    intro i hi
    simpa only [Nat.zero_add] using (agree i 0 (by dsimp [W];omega)).trans (read i hi))
  have inside : iterate x (w.length-1)%65536 ∈ trapCodes := by
    apply Classical.byContradiction
    intro outside
    exact PureThreeExit.blocked (PureThreeExit.link_double _ (fun _ => rfl)) base (fun _ => outside) cut
  apply List.mem_map.mpr
  refine ⟨_,inside,?_⟩
  unfold decode win rowOf
  apply Rule30SidewaysLocks.seg_congr
  intro j hj
  change ((iterate x (w.length-1)) % 2^16).testBit j = _
  rw [Nat.testBit_mod_two_pow]
  simpa [hj] using agree (w.length-1) j (by dsimp [W];omega)

theorem later {R : Nat → Bool} {a b : Nat} (h : InTrap R a) (bound : a≤b) : InTrap R b := by
  have next := win_mem_trap R (t0:=2*a+1) (by omega) h (b-a)
  simpa only [InTrap,show 2*a+1+2*(b-a)=2*b+1 by omega] using next

/-- The nine forcing factors cover the clean 48-letter language. -/
theorem sound_of_markers
    (cuts : ∀ w ∈ markers, ∃ k, (PureThreeExit.layers w true k).head? = some []) :
    Sound 47 := by
  intro R s clean
  obtain ⟨off,w,mem,bound,read⟩ := clean_contains_marker _ _ clean
  obtain ⟨k,cut⟩ := cuts w mem
  have nonempty := of_decide_eq_true (List.all_eq_true.mp
    (by decide +kernel : markers.all (fun p => decide (0<p.length))=true) w mem)
  exact later (marker_enters cut read) (by omega)
end Ruliology.CellularAutomata.WordCover
