module
public import WheelMarkerGraph

/-! Check all 65,536 windows. Each label carries all forty suffix positions. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelMarker
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0

def batch (k : Nat) : Bool := (List.range 16).all fun i => page (16*k+i)
private theorem batch00 : batch 0 = true := by decide +kernel
private theorem batch01 : batch 1 = true := by decide +kernel
private theorem batch02 : batch 2 = true := by decide +kernel
private theorem batch03 : batch 3 = true := by decide +kernel
private theorem batch04 : batch 4 = true := by decide +kernel
private theorem batch05 : batch 5 = true := by decide +kernel
private theorem batch06 : batch 6 = true := by decide +kernel
private theorem batch07 : batch 7 = true := by decide +kernel
private theorem batch08 : batch 8 = true := by decide +kernel
private theorem batch09 : batch 9 = true := by decide +kernel
private theorem batch10 : batch 10 = true := by decide +kernel
private theorem batch11 : batch 11 = true := by decide +kernel
private theorem batch12 : batch 12 = true := by decide +kernel
private theorem batch13 : batch 13 = true := by decide +kernel
private theorem batch14 : batch 14 = true := by decide +kernel
private theorem batch15 : batch 15 = true := by decide +kernel

private theorem checked (k : Fin 16) : batch k.val = true := by
  have h : k.val = 0 ∨ k.val = 1 ∨ k.val = 2 ∨ k.val = 3 ∨ k.val = 4 ∨ k.val = 5 ∨ k.val = 6 ∨ k.val = 7 ∨ k.val = 8 ∨ k.val = 9 ∨ k.val = 10 ∨ k.val = 11 ∨ k.val = 12 ∨ k.val = 13 ∨ k.val = 14 ∨ k.val = 15 := by omega
  rcases h with h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h
  · exact h ▸ batch00
  · exact h ▸ batch01
  · exact h ▸ batch02
  · exact h ▸ batch03
  · exact h ▸ batch04
  · exact h ▸ batch05
  · exact h ▸ batch06
  · exact h ▸ batch07
  · exact h ▸ batch08
  · exact h ▸ batch09
  · exact h ▸ batch10
  · exact h ▸ batch11
  · exact h ▸ batch12
  · exact h ▸ batch13
  · exact h ▸ batch14
  · exact h ▸ batch15

theorem valid (w : BitVec 16) : validRow w = true := by
  have bound := w.isLt
  have h := checked ⟨w.toNat/4096, by omega⟩
  have p := List.all_eq_true.mp h (w.toNat/256%16) (List.mem_range.mpr (Nat.mod_lt _ (by decide)))
  have q := List.all_eq_true.mp p (w.toNat%256) (List.mem_range.mpr (Nat.mod_lt _ (by decide)))
  change validRow (BitVec.ofNat 16 (256*(16*(w.toNat/4096)+(w.toNat/256%16))+w.toNat%256)) = true at q
  rwa [show 256*(16*(w.toNat/4096)+(w.toNat/256%16))+w.toNat%256 = w.toNat by omega, BitVec.ofNat_toNat] at q

end Ruliology.CellularAutomata.WheelMarker
