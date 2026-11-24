module
public import ObserverAfterFirst

/-! Two controls for the quantifiers in the S15 carrying read. -/
@[expose] public section
namespace S15Read
open Ruliology.CellularAutomata
open Rule30PeriodTwoSideways Rule30GateTrapWords WheelGateObserver WordCover

/-- Signal whenever a forcing factor finishes. At startup, only available bits are used. -/
def Signal (g : Nat → Bool) (t : Nat) : Prop :=
  ∃ s w, w ∈ markers ∧ Reads g s w ∧ s + (w.length - 1) = t

theorem marker_length {w : List Bool} (mem : w ∈ markers) :
    0 < w.length ∧ w.length ≤ 38 :=
  of_decide_eq_true (List.all_eq_true.mp (by decide +kernel :
    markers.all (fun p => decide (0 < p.length ∧ p.length ≤ 38)) = true) w mem)

/-- Changing any readings before the last 38 leaves the signal unchanged. -/
theorem signal_local {g h : Nat → Bool} {t : Nat}
    (same : ∀ i, i ≤ t → t < i + 38 → g i = h i) : Signal g t ↔ Signal h t := by
  have transfer (p q : Nat → Bool) (eq : ∀ i, i ≤ t → t < i + 38 → p i = q i)
      (signal : Signal p t) : Signal q t := by
    obtain ⟨s,w,mem,read,last⟩ := signal
    obtain ⟨pos,bound⟩ := marker_length mem
    refine ⟨s,w,mem,?_,last⟩
    intro j small
    exact (eq (s+j) (by omega) (by omega)).symm.trans (read j small)
  exact ⟨transfer g h same, transfer h g (fun i hi lo => (same i hi lo).symm)⟩

theorem signal_sound {R t} (h : Signal (u R) t) : InTrap R t := by
  obtain ⟨s,w,mem,read,rfl⟩ := h
  obtain ⟨k,cut⟩ := nine_cuts mem
  exact marker_enters cut read

/-- Every entry has a subsequent signal within 53 white intervals. -/
theorem signal_after_entry {R a} (entry : InTrap R a) :
    ∃ t, a ≤ t ∧ t ≤ a + 53 ∧ Signal (u R) t := by
  have clean := WheelObserverCleanup.clean_after_six entry (Nat.le_refl (a+6)) 48
  obtain ⟨off,w,mem,size,read⟩ := clean_contains_marker _ _ clean
  have positive := (marker_length mem).1
  exact ⟨a+6+off+(w.length-1),by omega,by omega,a+6+off,w,mem,read,rfl⟩

/-- A side input telling whether the first white tick has passed admits a
47-sample rule even in a stream that can start at reset. -/
def AgeGuard (laterStart : Bool) (bits : Nat → Bool) : Prop :=
  laterStart = true ∧ Clean bits 0 47

private theorem clean_shift (g : Nat → Bool) (s : Nat) :
    Clean (fun i => g (s+i)) 0 47 ↔ Clean g s 47 := by
  simp only [Clean, Reads, Nat.zero_add, Nat.add_assoc]

theorem age_guard_sound {R s} (h : AgeGuard (decide (0 < s)) (fun i => u R (s+i))) :
    InTrap R (s+46) := by
  obtain ⟨later,clean⟩ := h
  have pos : 0 < s := of_decide_eq_true later
  obtain ⟨j,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : s ≠ 0)
  exact ObserverAfterFirst.sound_47_after_first _ _ ((clean_shift ..).mp clean)

theorem age_guard_accepts {R a s} (entry : InTrap R a) (late : a+10 ≤ s) :
    AgeGuard (decide (0 < s)) (fun i => u R (s+i)) := by
  exact ⟨decide_eq_true (by omega),
    (clean_shift ..).mpr (WheelObserverCleanup.clean_after_six entry (by omega) 47)⟩

end S15Read
