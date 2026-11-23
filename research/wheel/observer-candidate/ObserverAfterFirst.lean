module
public import PortableObserver
public import word_cover_nine
public import WheelObserverCleanup

/-! One preceding white sample removes the exceptional exterior 47-bit word.
The independent result `Rule30Submission.no_short_classifier_after_first`
gives the lower bound for fixed windows available after the first sample. -/
@[expose] public section
namespace Ruliology.CellularAutomata.ObserverAfterFirst
open Rule30GateTrapWords Rule30PeriodTwoSideways WheelGateObserver WordCover

-- A final, exact language check uses the nine markers already needed for 48.
-- The prefix-search induction is adapted from word_cover_language.
private def hits (patterns : List (List Bool)) (suffix : List Bool) := patterns.any (·.isPrefixOf suffix)

/-- Grow the word towards its beginning and stop at the first recognized factor. -/
private def search (patterns : List (List Bool)) : Nat → List Bool → Bool
  | 0, suffix => hits patterns suffix
  | n+1, suffix => hits patterns suffix || (search patterns n (false::suffix) && search patterns n (true::suffix))

private def readings (g : Nat → Bool) (s : Nat) : Nat → List Bool
  | 0 => []
  | n+1 => g s :: readings g (s+1) n

private theorem readings_len (g s n) : (readings g s n).length = n := by
  induction n generalizing s with
  | zero => rfl
  | succ n ih => simpa only [readings,List.length_cons] using congrArg Nat.succ (ih (s+1))

private theorem read_index (g s n i) (h : i<n) :
    (readings g s n).getD i false = g (s+i) := by
  induction n generalizing s i with
  | zero => omega
  | succ n ih =>
    cases i with
    | zero => rfl
    | succ i =>
      change (readings g (s+1) n).getD i false = _
      simpa only [show s+1+i=s+(i+1) by omega] using ih (s+1) i (by omega)

private theorem hit_sound (patterns : List (List Bool)) (g s n) (hit : hits patterns (readings g s n) = true) :
    ∃ w ∈ patterns, w.length ≤ n ∧ Reads g s w := by
  obtain ⟨w,mem,h⟩ := List.any_eq_true.mp hit
  obtain ⟨rest,eq⟩ := List.isPrefixOf_iff_prefix.mp h
  have len := congrArg List.length eq
  simp only [List.length_append,readings_len] at len
  refine ⟨w,mem,by omega,?_⟩
  intro j bound
  have h := congrArg (fun l : List Bool => l.getD j false) eq
  rw [read_index g s n j (by omega)] at h
  simpa only [List.getD_eq_getElem?_getD,List.getElem?_append_left bound] using h.symm

private theorem search_sound (patterns : List (List Bool)) (g : Nat → Bool) (s n tail : Nat)
    (checked : search patterns n (readings g (s+n) tail) = true) :
    ∃ off w, w ∈ patterns ∧ off+w.length ≤ n+tail ∧ Reads g (s+off) w := by
  have here (yes : hits patterns (readings g (s+n) tail) = true) :
      ∃ off w, w ∈ patterns ∧ off+w.length ≤ n+tail ∧ Reads g (s+off) w := by
    obtain ⟨w,mem,bound,r⟩ := hit_sound patterns _ _ _ yes
    exact ⟨n,w,mem,by omega,r⟩
  induction n generalizing tail with
  | zero => exact here checked
  | succ n ih =>
    rcases Bool.or_eq_true_iff.mp checked with done | both
    · exact here done
    · have branches := Bool.and_eq_true_iff.mp both
      have sub : search patterns n (readings g (s+n) (tail+1)) = true := by
        change search patterns n (g (s+n) :: readings g (s+n+1) tail) = true
        cases g (s+n) <;> first | exact branches.1 | exact branches.2
      obtain ⟨off,w,mem,size,matchW⟩ := ih (tail+1) sub (by
        intro found
        obtain ⟨w,mem,bound,r⟩ := hit_sound patterns _ _ _ found
        exact ⟨n,w,mem,by omega,r⟩)
      exact ⟨off,w,mem,by omega,matchW⟩

private def alternative := word 47 0x210842109090
private def options := [exceptional, alternative]
set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
private theorem covers47 : search (forbidden ++ (options ++ markers)) 47 [] = true := by decide +kernel

private theorem option_extends_clean {R : Nat → Bool} {s : Nat}
    {w : List Bool} (opt : w ∈ options) (ex : Reads (u R) (s+1) w) : Clean (u R) s 48 := by
  have test : w.length = 47 ∧ (∀ j : Fin 4, w.getD j.val false = false) ∧
      cleanb (fun i => (true::w).getD i false) 0 48 = true := by
    rcases List.mem_cons.mp opt with h | other
    · subst w; decide +kernel
    · have h := List.mem_singleton.mp other
      subst w; decide +kernel
  have zeros (k : Fin 4) : u R (s+1+k.val) = false :=
    (ex k.val (by have := k.isLt; omega)).trans (test.2.1 k)
  have black : u R s = true := by
    obtain ⟨j,small,hit⟩ := Rule30Submission.black_in_every_five R s
    cases j with
    | zero => exact hit
    | succ j =>
      have white := zeros ⟨j,by omega⟩
      rw [show s+1+j=s+(j+1) by omega,hit] at white
      contradiction
  let bits := true :: w
  have agree (i : Nat) (small : i<48) : u R (s+i) = bits.getD i false := by
    cases i with
    | zero => exact black
    | succ i =>
      have eq := ex i (by omega)
      simpa only [bits,List.getD_cons_succ,show s+1+i=s+(i+1) by omega] using eq
  have literal : Clean (fun i => bits.getD i false) 0 48 :=
    (cleanb_spec ..).mp test.2.2
  intro off w member bound read
  apply literal off w member bound
  intro j size
  simp only [Nat.zero_add]
  change bits.getD (off+j) false = _
  rw [←agree (off+j) (by omega),←Nat.add_assoc]
  exact read j size

/-- At every white sample after the first, a clean 47-bit observation certifies
membership at the endpoint. The bit before the observation need not be supplied. -/
theorem sound_47_after_first (R : Nat → Bool) (s : Nat)
    (clean : Clean (u R) (s+1) 47) : InTrap R (s+1+46) := by
  obtain ⟨off,w,member,bound,read⟩ := search_sound _ (u R) (s+1) 47 0 covers47
  rcases List.mem_append.mp member with bad | good
  · exact False.elim (clean off w bad bound read)
  rcases List.mem_append.mp good with special | marked
  · have len : w.length = 47 := by
      rcases List.mem_cons.mp special with h | h
      · subst w; decide
      · have e := List.mem_singleton.mp h
        subst w; decide
    have start : off=0 := by omega
    subst off
    exact sound_48 R s (option_extends_clean special (by simpa only [Nat.add_zero] using read))
  · obtain ⟨k,cut⟩ := nine_cuts marked
    have positive := of_decide_eq_true (List.all_eq_true.mp
      (by decide +kernel : markers.all (fun p => decide (0<p.length)) = true) w marked)
    exact later (marker_enters cut read) (by omega)

/-- If an entry occurs at sample a, the gate-only filter accepts every 47-sample
window starting at a+6 or later, hence has confirmed by endpoint a+52. -/
theorem confirm_by_52 (R : Nat → Bool) (a k : Nat) (entry : InTrap R a) :
    Clean (u R) (a+6+k) 47 ∧ InTrap R (a+52+k) := by
  have clean := WheelObserverCleanup.clean_after_six entry (by omega : a+6≤a+6+k) 47
  refine ⟨clean,?_⟩
  have cut := sound_47_after_first R (a+5+k)
  simpa only [show a+5+k+1=a+6+k by omega,show a+6+k+46=a+52+k by omega] using
    (cut (by simpa only [show a+5+k+1=a+6+k by omega] using clean))

end Ruliology.CellularAutomata.ObserverAfterFirst
