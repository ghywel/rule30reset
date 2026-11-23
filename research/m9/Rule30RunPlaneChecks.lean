module

public import Ruliology.CellularAutomata.Rule30RunPlaneData

/-! Replay the prefix exclusions and join them to the physical trace. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunPlaneChecks
open Rule30RunPlanes Rule30RunPlaneData Rule30TrappedRuns
set_option maxHeartbeats 0
set_option maxRecDepth 100000

macro "plane_pass " name:ident n:num : command =>
  `(theorem $name : stageOK (frames $n) (slots $n) := by
      apply stage_intro
      · iterate 98 (apply prepsCons; · as_aux_lemma => decide +kernel)
        rfl
      · rfl
      · iterate 97 (apply fEdgesCons; · as_aux_lemma => decide +kernel)
        rfl
      · iterate 97 (apply bEdgesCons; · as_aux_lemma => decide +kernel)
        rfl)

plane_pass check0 0
plane_pass check1 1
plane_pass check2 2
plane_pass check3 3
plane_pass check4 4
plane_pass check5 5
plane_pass check6 6
plane_pass check7 7
plane_pass check8 8
plane_pass check9 9
plane_pass check10 10
plane_pass check11 11
plane_pass check12 12
plane_pass check13 13
plane_pass check14 14
plane_pass check15 15
plane_pass check16 16
plane_pass check17 17
plane_pass check18 18
plane_pass check19 19
plane_pass check20 20
plane_pass check21 21
plane_pass check22 22
plane_pass check23 23
plane_pass check24 24
plane_pass check25 25
plane_pass check26 26
plane_pass check27 27
plane_pass check28 28
plane_pass check29 29

theorem no_trace (r : Nat) : ¬ Rule30RunWindow.Trace r initial := by
  intro h
  have h0 : Trace r (frames 0) := start_trace h
  have h1 : Trace r (frames 1) := stage_sound check0 h0
  have h2 : Trace r (frames 2) := stage_sound check1 h1
  have h3 : Trace r (frames 3) := stage_sound check2 h2
  have h4 : Trace r (frames 4) := stage_sound check3 h3
  have h5 : Trace r (frames 5) := stage_sound check4 h4
  have h6 : Trace r (frames 6) := stage_sound check5 h5
  have h7 : Trace r (frames 7) := stage_sound check6 h6
  have h8 : Trace r (frames 8) := stage_sound check7 h7
  have h9 : Trace r (frames 9) := stage_sound check8 h8
  have h10 : Trace r (frames 10) := stage_sound check9 h9
  have h11 : Trace r (frames 11) := stage_sound check10 h10
  have h12 : Trace r (frames 12) := stage_sound check11 h11
  have h13 : Trace r (frames 13) := stage_sound check12 h12
  have h14 : Trace r (frames 14) := stage_sound check13 h13
  have h15 : Trace r (frames 15) := stage_sound check14 h14
  have h16 : Trace r (frames 16) := stage_sound check15 h15
  have h17 : Trace r (frames 17) := stage_sound check16 h16
  have h18 : Trace r (frames 18) := stage_sound check17 h17
  have h19 : Trace r (frames 19) := stage_sound check18 h18
  have h20 : Trace r (frames 20) := stage_sound check19 h19
  have h21 : Trace r (frames 21) := stage_sound check20 h20
  have h22 : Trace r (frames 22) := stage_sound check21 h21
  have h23 : Trace r (frames 23) := stage_sound check22 h22
  have h24 : Trace r (frames 24) := stage_sound check23 h23
  have h25 : Trace r (frames 25) := stage_sound check24 h24
  have h26 : Trace r (frames 26) := stage_sound check25 h25
  have h27 : Trace r (frames 27) := stage_sound check26 h26
  have h28 : Trace r (frames 28) := stage_sound check27 h27
  have h29 : Trace r (frames 29) := stage_sound check28 h28
  have h30 : Trace r (frames 30) := stage_sound check29 h29
  have empty : (frames 30).any (fun f => f.live == 0) = true := by decide +kernel
  exact Bool.noConfusion ((no_empty h30).symm.trans empty)

end Ruliology.CellularAutomata.Rule30RunPlaneChecks
