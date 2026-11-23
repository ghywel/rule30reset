module

public import Ruliology.CellularAutomata.Rule30RunWindow
public import Ruliology.CellularAutomata.Rule30RunChecks

/-! The trapped-gate run words and their physical witnesses. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30TrappedRuns
open Rule30GateTrap Rule30DrivenPrefix Rule30Ether Rule30StripCertificates
open Rule30PeriodTwoCoupled Rule30RunWindow

private def bits (a : Nat) : Nat → Bool
  | 0 => false
  | j+1 => a.testBit j

private theorem physical_gate (a s : Nat) :
    Rule30PeriodTwoSideways.u (bits a) s = (packed altCol a (2*s+1)).testBit 0 :=
  (packed_sound altCol (bits a) a (fun _ => rfl) _ 0).symm

private theorem physical_window (a t : Nat) : win (bits a) t =
    seg (fun i => (packed altCol a t).testBit i) 16 := by
  apply Rule30Ether.seg_congr
  intro i _
  simpa only [Nat.zero_add] using (packed_sound altCol (bits a) a (fun _ => rfl) t i).symm

private theorem witness {a code n s : Nat} (hc : code ∈ trapCodes)
    (hw : seg (fun i => (packed altCol a 1).testBit i) 16 = decode code)
    (hh : (List.range (closed n).length).all (fun i =>
      (packed altCol a (2*(s+i)+1)).testBit 0 == (closed n).getD i false) = true) :
    win (bits a) 1 ∈ trap ∧ ∀ i, i < (closed n).length →
      Rule30PeriodTwoSideways.u (bits a) (s+i) = (closed n).getD i false := by
  refine ⟨?_, fun i hi => ?_⟩
  · rw [physical_window, hw]
    exact List.mem_map.mpr ⟨_, hc, rfl⟩
  · rw [physical_gate]
    exact beq_iff_eq.mp (List.all_eq_true.mp hh i (List.mem_range.mpr hi))

set_option maxRecDepth 10000
set_option maxHeartbeats 0

/-- Four closed runs occur one sample after a trapped tick. -/
theorem four_one_sample :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 4).length →
      Rule30PeriodTwoSideways.u R (1+i) = (closed 4).getD i false := by
  let a := 17911952117231624625415841284791634824617432618773606279499
  exact ⟨_, witness (a := a) (code := 44920) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)⟩

/-- Three closed runs occur sixty samples after a trapped tick. -/
theorem three_sixty_samples :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 3).length →
      Rule30PeriodTwoSideways.u R (60+i) = (closed 3).getD i false := by
  let a := 88769951030016947892698456558596051073035529750717722303543758321481268415460012
  exact ⟨_, witness (a := a) (code := 40615) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)⟩

private theorem cone (R : Nat → Bool) (b x W : Nat)
    (start : ∀ j, j < W → x.testBit j = drv altCol R b (j+1)) :
    ∀ t j, j+t < W →
      (packed (fun k => altCol (b+k)) x t).testBit j = drv altCol R (b+t) (j+1) := by
  intro t
  induction t with
  | zero => exact start
  | succ t ih =>
    intro j hj
    rw [packed,step_bit,show b+(t+1) = b+t+1 by omega, drv_isR30 altCol R (b+t) j]
    unfold Rule30Jen.rule
    rw [ih j (by omega), ih (j+1) (by omega)]
    cases j with
    | zero => simp [drv_col0]
    | succ j => simp [ih j (by omega)]

private theorem packed_twice (b x : Nat) (hb : b%2=1) :
    ∀ i, iterate x i = packed (fun k => altCol (b+k)) x (2*i) := by
  intro i
  induction i with
  | zero => rfl
  | succ i ih =>
    have ho : altCol (b+2*i) = false := by unfold altCol; simp; omega
    have he : altCol (b+(2*i+1)) = true := by unfold altCol; simp; omega
    rw [iterate,ih,show 2*(i+1)=2*i+1+1 by omega, packed,packed,ho,he,double]

private theorem shift_iterate (r : Nat) : ∀ i, iterate (double r) i = iterate r (i+1)
  | 0 => rfl
  | i+1 => congrArg double (shift_iterate r i)

private theorem from_frames (ds : List Window) (r : Nat)
    (h : ∀ i (hi : i < ds.length), Holds ds[i] (iterate r i)) : Trace r ds := by
  induction ds generalizing r with
  | nil => trivial
  | cons a ds ih =>
    refine ⟨h 0 (by simp), ih _ (fun i hi => ?_)⟩
    rw [shift_iterate]
    exact h (i+1) (by simpa using hi)

private theorem seg_at : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), j<n → (seg f n).getD j false = f j
  | 0, _, _, h => absurd h (by omega)
  | _+1, _, 0, _ => rfl
  | n+1, f, j+1, h => seg_at n (fun i => f (i+1)) j (by omega)

private theorem trap_bounds : trapCodes.all (fun n => n < 2^16) = true := by decide +kernel

private theorem from_trap {R : Nat → Bool} {t q : Nat} (h : win R t ∈ trap)
    (hq : ∀ j, j<16 → q.testBit j = drv altCol R t (j+1)) : q % 2^16 ∈ trapCodes := by
  obtain ⟨c,hc,eq⟩ := List.mem_map.mp h
  have bound : c < 2^16 := of_decide_eq_true (List.all_eq_true.mp trap_bounds c hc)
  suffices q % 2^16 = c by rwa [this]
  apply Nat.eq_of_testBit_eq
  intro j
  rw [Nat.testBit_mod_two_pow]
  by_cases hj : j < 16
  · have e := congrArg (fun L : List Bool => L.getD j false) eq
    change (seg (fun i => c.testBit i) 16).getD j false =
      (seg (fun i => drv altCol R t (0+i+1)) 16).getD j false at e
    rw [seg_at _ _ _ hj,seg_at _ _ _ hj] at e
    simpa [hj, hq j hj] using e.symm
  · have bound' : c < 2^j := Nat.lt_of_lt_of_le bound (Nat.pow_le_pow_right (by decide) (by omega))
    simp [hj,Nat.testBit_lt_two_pow bound']

private theorem prefix_bit : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), j < n →
    (encList (seg f n)).testBit j = f j
  | 0, _, _, h => absurd h (by omega)
  | _+1, f, 0, _ => by
    rw [Nat.testBit_zero]
    simp only [seg, encList]
    cases f 0 <;> simp <;> omega
  | n+1, f, j+1, h => by
    rw [Nat.testBit_succ]
    change (((if f 0 then 1 else 0) + 2 * encList (seg (fun i => f (i+1)) n)) / 2).testBit j = _
    have e (a : Nat) : ((if f 0 then 1 else 0) + 2*a) / 2 = a := by cases f 0 <;> simp <;> omega
    rw [e]
    exact prefix_bit n _ j (by omega)

/-- Every proposed physical occurrence supplies one finite packed trace. -/
theorem occurrence_trace (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1)
    (word : ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false) :
    ∃ r, Trace r initial := by
  let b := 2*s+1-4
  have hb : b%2=1 := by dsimp [b]; omega
  have at_b := win_mem_trap R h0 hw ((b-t0)/2)
  rw [show t0+2*((b-t0)/2)=b by dsimp [b]; omega] at at_b
  let f := fun j => drv altCol R b (j+1)
  let r := encList (seg f 210)
  have agree (i j : Nat) (bound : j+2*i<210) :
      (iterate r i).testBit j = drv altCol R (b+2*i) (j+1) := by
    rw [packed_twice b r hb]
    exact cone R b r 210 (prefix_bit 210 f) _ _ bound
  refine ⟨r, from_frames initial r (fun i hi => ?_)⟩
  have il : i < 98 := by simpa only [show initial.length = 98 by decide] using hi
  have ht := from_trap (win_mem_trap R hb at_b i) (fun j hj => agree i j (by omega))
  have ic : i < colours.length := by simpa only [initial, List.length_map] using hi
  have cell : initial[i]'hi = entry (colours[i]'ic) := by simp only [initial, List.getElem_map]
  rw [cell]
  cases i with
  | zero => exact ht
  | succ i =>
    cases i with
    | zero => exact ht
    | succ i =>
      have il' : i < (closed 4).length := by rw [show (closed 4).length = 96 by decide]; omega
      have colour : colours[i+1+1] = some ((closed 4)[i]) := by
        simp [colours]
      rw [colour]
      apply List.mem_filter.mpr
      refine ⟨ht, beq_iff_eq.mpr ?_⟩
      rw [Nat.testBit_mod_two_pow]
      have w := word i (by omega)
      unfold Rule30PeriodTwoSideways.u at w
      have gate := agree (i+1+1) 0 (by omega)
      rw [show b+2*(i+1+1) = 2*(s+i)+1 by dsimp [b]; omega] at gate
      simpa [entry, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem il'] using gate.trans w

/-- Four closed runs of four 5-gaps cannot start two or more samples after trap entry. -/
theorem no_four_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1) :
    ¬ ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false := by
  intro word
  obtain ⟨r,h⟩ := occurrence_trace R h0 hw s hs word
  exact Rule30RunChecks.no_trace r h

/-- The five-block word is excluded from the trapped tick itself. -/
theorem no_five_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 ≤ 2*s+1) :
    ¬ ∀ i, i<116 → Rule30PeriodTwoSideways.u R (s+i) = five.getD i false := by
  intro word
  have suffix : ∀ i, i<96 → five.getD (20+i) false = (closed 4).getD i false := by decide
  apply no_four_runs_of_four R h0 hw (s+20) (by omega)
  intro i hi
  rw [Nat.add_assoc, word (20+i) (by omega), suffix i hi]

end Ruliology.CellularAutomata.Rule30TrappedRuns
