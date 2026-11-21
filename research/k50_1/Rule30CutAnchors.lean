import Rule30CutSplice
import Ruliology.CellularAutomata.Rule30DrivenPrefix
import Ruliology.CellularAutomata.Rule30PlantedSurvivor

/-! Finite witnesses of uninterrupted ether at column one, one cut per residue modulo seven
in each of the two alignments. The kit's 109-state wall carries each finite witness forever. -/
namespace Ruliology.CellularAutomata.Rule30CutAnchors
open Rule30CutSplice Rule30DrivenPrefix Rule30Ether Rule30PeriodTwoCoupled Rule30StripCertificates

def cutCode (s N : Nat) : Nat :=
  Rule30PlantedSurvivor.enc N (fun j => ether (3+(j+1)) s)

theorem packed_cut (s N t j : Nat) :
    (packed altCol (cutCode s N) t).testBit j = drv altCol (cut s N) t (j+1) := by
  apply packed_sound
  intro i
  unfold cutCode cut
  rw [Rule30PlantedSurvivor.testBit_enc]
  by_cases hi : i < N <;> simp [hi, Nat.succ_le_iff]

/-- A witness checks the first column through the transient and the physical 19 cells
at entry: the six ether columns ending at B3, then one of the kit's 13-cell walls. -/
def checkAnchor (s N t : Nat) : Bool :=
  let code := cutCode s N
  let row := packed altCol code t
  (List.range t).all (fun u => (packed altCol code u).testBit 0 == ether 4 (s+u)) &&
  (List.range 6).all (fun j => row.testBit j == ether (3+(j+1)) (t+s)) &&
  wallStates.contains ((t+s)%4, seg (fun i => row.testBit (6+i)) 13)

private theorem aligned (s : Nat) (hs : s=1 ∨ s=3) (u : Nat) :
    altCol u = ether 3 (u+s) := by
  have h4 : u % 4 < 4 := Nat.mod_lt _ (by decide)
  have hmod : u%2 = (u%4)%2 := by omega
  have he : ether 3 (u+s) = ether 3 (u%4+s) := ether_congr rfl (by omega)
  rw [he]
  unfold altCol
  rw [hmod]
  generalize u % 4 = z at h4 ⊢
  have cases4 : z=0 ∨ z=1 ∨ z=2 ∨ z=3 := by omega
  rcases hs with rfl | rfl <;> rcases cases4 with rfl | rfl | rfl | rfl <;> decide

theorem anchor_sound (s N t : Nat) (hs : s=1 ∨ s=3) (h : checkAnchor s N t = true) :
    Matches s N := by
  simp only [checkAnchor, Bool.and_eq_true, List.contains_iff_mem] at h
  obtain ⟨⟨early, prefixOK⟩, wall⟩ := h
  let F := drv altCol (cut s N)
  have prefixMatch : ∀ p, 1 ≤ p → p ≤ 6 → F t p = ether (3+p) (t+s) := by
    intro p hp hp6
    obtain ⟨j, rfl⟩ : ∃ j, p = j+1 := ⟨p-1, by omega⟩
    exact (packed_cut s N t j).symm.trans
      (beq_iff_eq.1 (List.all_eq_true.1 prefixOK j (List.mem_range.mpr (by omega))))
  have strip : ((t+s)%4, rowOf F t 6 13) ∈ wallStates := by
    have eq : rowOf F t 6 13 = seg (fun i => (packed altCol (cutCode s N) t).testBit (6+i)) 13 :=
      seg_congr _ _ _ (fun i _ => (packed_cut s N t (6+i)).symm)
    rwa [eq]
  have pinned := trap_invariant (drv_isR30 altCol (cut s N)) 3 s 6 t (by decide)
    (fun u _ => (drv_col0 _ _ _).trans (aligned s hs u)) prefixMatch strip
  intro u
  by_cases hu : u < t
  · exact (packed_cut s N u 0).symm.trans
      (beq_iff_eq.1 (List.all_eq_true.1 early u (List.mem_range.mpr hu)))
  · have eq := (pinned (u-t)).1 1 (by decide)
    simpa only [show t + (u-t) = u by omega, Nat.add_comm u s] using eq

def anchorWidth (s r : Nat) : Nat :=
  if s = 1 then 7+r else [7,43,9,24,32,33,6].getD r 0

private def entryTime (s r : Nat) : Nat :=
  if s = 1 then [7,7,7,7,7,17,17].getD r 0 else [7,222,5,82,186,186,8].getD r 0

set_option maxRecDepth 8192 in
set_option maxHeartbeats 50000000 in
private theorem checked : ∀ r : Fin 7,
    checkAnchor 1 (anchorWidth 1 r.val) (entryTime 1 r.val) = true ∧
    checkAnchor 3 (anchorWidth 3 r.val) (entryTime 3 r.val) = true := by decide +kernel

theorem anchor_matches (s : Nat) (hs : s=1 ∨ s=3) (r : Fin 7) :
    Matches s (anchorWidth s r.val) := by
  apply anchor_sound s _ (entryTime s r.val) hs
  rcases hs with rfl | rfl
  · exact (checked r).1
  · exact (checked r).2

end Ruliology.CellularAutomata.Rule30CutAnchors
