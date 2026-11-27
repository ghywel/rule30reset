import SixComponentCore

namespace PhaseFalls.Six

set_option maxHeartbeats 0
set_option maxRecDepth 100000

private def componentBatch (g : Nat) :=
  (List.range 27).all fun k => checkComponentAssignment (27*g+k)

private theorem group_0 : componentBatch 0 = true := by decide +kernel
private theorem group_1 : componentBatch 1 = true := by decide +kernel
private theorem group_2 : componentBatch 2 = true := by decide +kernel
private theorem group_3 : componentBatch 3 = true := by decide +kernel
private theorem group_4 : componentBatch 4 = true := by decide +kernel
private theorem group_5 : componentBatch 5 = true := by decide +kernel
private theorem group_6 : componentBatch 6 = true := by decide +kernel
private theorem group_7 : componentBatch 7 = true := by decide +kernel
private theorem group_8 : componentBatch 8 = true := by decide +kernel
private theorem group_9 : componentBatch 9 = true := by decide +kernel
private theorem group_10 : componentBatch 10 = true := by decide +kernel
private theorem group_11 : componentBatch 11 = true := by decide +kernel
private theorem group_12 : componentBatch 12 = true := by decide +kernel
private theorem group_13 : componentBatch 13 = true := by decide +kernel
private theorem group_14 : componentBatch 14 = true := by decide +kernel
private theorem group_15 : componentBatch 15 = true := by decide +kernel
private theorem group_16 : componentBatch 16 = true := by decide +kernel
private theorem group_17 : componentBatch 17 = true := by decide +kernel
private theorem group_18 : componentBatch 18 = true := by decide +kernel
private theorem group_19 : componentBatch 19 = true := by decide +kernel
private theorem group_20 : componentBatch 20 = true := by decide +kernel
private theorem group_21 : componentBatch 21 = true := by decide +kernel
private theorem group_22 : componentBatch 22 = true := by decide +kernel
private theorem group_23 : componentBatch 23 = true := by decide +kernel
private theorem group_24 : componentBatch 24 = true := by decide +kernel
private theorem group_25 : componentBatch 25 = true := by decide +kernel
private theorem group_26 : componentBatch 26 = true := by decide +kernel

private theorem verifiedAssignment (a : Nat) (ha : a < 729) : checkComponentAssignment a = true := by
  have group (g : Nat) (hg : g < 27) : componentBatch g = true := by
    match g with
    | 0 => exact group_0
    | 1 => exact group_1
    | 2 => exact group_2
    | 3 => exact group_3
    | 4 => exact group_4
    | 5 => exact group_5
    | 6 => exact group_6
    | 7 => exact group_7
    | 8 => exact group_8
    | 9 => exact group_9
    | 10 => exact group_10
    | 11 => exact group_11
    | 12 => exact group_12
    | 13 => exact group_13
    | 14 => exact group_14
    | 15 => exact group_15
    | 16 => exact group_16
    | 17 => exact group_17
    | 18 => exact group_18
    | 19 => exact group_19
    | 20 => exact group_20
    | 21 => exact group_21
    | 22 => exact group_22
    | 23 => exact group_23
    | 24 => exact group_24
    | 25 => exact group_25
    | 26 => exact group_26
    | n+27 => omega
  have h := List.all_eq_true.mp (group (a/27) (by omega))
    (a%27) (List.mem_range.mpr (Nat.mod_lt _ (by decide)))
  simpa only [show 27*(a/27)+a%27=a by omega] using h

private theorem verifiedNode {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64) :
    checkComponentNode a t s = true :=
  List.all_eq_true.mp (List.all_eq_true.mp (verifiedAssignment a ha) t (List.mem_range.mpr ht))
    s (List.mem_range.mpr hs)

theorem component_bounds {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64) :
    level a t s ≤ 6 ∧ height a t s ≤ 11 := by
  have bound := (Bool.and_eq_true_iff.mp (verifiedNode ha ht hs)).1
  exact ⟨of_decide_eq_true (Bool.and_eq_true_iff.mp bound).1,
         of_decide_eq_true (Bool.and_eq_true_iff.mp bound).2⟩

theorem component_edge {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64)
    (w e : Bool) : ComponentEdge a t s w e := by
  have ok := (Bool.and_eq_true_iff.mp (verifiedNode ha ht hs)).2
  simp only [Bool.and_eq_true, decide_eq_true_eq] at ok
  cases w <;> cases e
  · exact ok.1.1.1
  · exact ok.1.1.2
  · exact ok.1.2
  · exact ok.2

end PhaseFalls.Six
