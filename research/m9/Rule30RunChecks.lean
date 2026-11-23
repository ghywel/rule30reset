module

public import Ruliology.CellularAutomata.Rule30RunCertificate

/-! Kernel proofs for the successive window refinements. Each local equality is a separate
lemma, so replay can release its temporary expressions before the next time slice. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunChecks
open Rule30RunCertificate Rule30RunWindow Rule30TrappedRuns
set_option maxHeartbeats 0
set_option maxRecDepth 100000

macro "window_pass " name:ident n:num : command =>
  `(theorem $name : verifies (state $n) (pass $n) := by
      apply verifies_intro
      · rfl
      · iterate 97 (apply fCons; · as_aux_lemma => decide +kernel)
        rfl
      · iterate 97 (apply bCons; · as_aux_lemma => decide +kernel)
        rfl)

window_pass check0 0
window_pass check1 1
window_pass check2 2
window_pass check3 3
window_pass check4 4
window_pass check5 5
window_pass check6 6
window_pass check7 7
window_pass check8 8
window_pass check9 9
window_pass check10 10
window_pass check11 11
window_pass check12 12
window_pass check13 13
window_pass check14 14
window_pass check15 15
window_pass check16 16
window_pass check17 17
window_pass check18 18
window_pass check19 19
window_pass check20 20
window_pass check21 21
window_pass check22 22
window_pass check23 23
window_pass check24 24
window_pass check25 25
window_pass check26 26
window_pass check27 27
window_pass check28 28
window_pass check29 29

theorem no_trace (r : Nat) : ¬ Trace r initial := by
    intro h0
    have h1 := stage check0 h0
    have h2 := stage check1 h1
    have h3 := stage check2 h2
    have h4 := stage check3 h3
    have h5 := stage check4 h4
    have h6 := stage check5 h5
    have h7 := stage check6 h6
    have h8 := stage check7 h7
    have h9 := stage check8 h8
    have h10 := stage check9 h9
    have h11 := stage check10 h10
    have h12 := stage check11 h11
    have h13 := stage check12 h12
    have h14 := stage check13 h13
    have h15 := stage check14 h14
    have h16 := stage check15 h15
    have h17 := stage check16 h16
    have h18 := stage check17 h17
    have h19 := stage check18 h18
    have h20 := stage check19 h19
    have h21 := stage check20 h20
    have h22 := stage check21 h21
    have h23 := stage check22 h22
    have h24 := stage check23 h23
    have h25 := stage check24 h24
    have h26 := stage check25 h25
    have h27 := stage check26 h26
    have h28 := stage check27 h27
    have h29 := stage check28 h28
    have h30 := stage check29 h29
    have empty : (state 30).any (fun d => d.codes.isEmpty) = true := by decide +kernel
    exact Bool.noConfusion ((trace_ne _ _ h30).symm.trans empty)

end Ruliology.CellularAutomata.Rule30RunChecks
