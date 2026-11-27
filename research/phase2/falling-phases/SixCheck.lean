import SixCheckCore

namespace PhaseFalls.Six

set_option maxHeartbeats 0
set_option maxRecDepth 100000

private def batch (g : Nat) := (List.range 27).all fun i => checkAssignment (27*g+i)

private theorem batch_0 : batch 0 = true := by decide +kernel
private theorem batch_1 : batch 1 = true := by decide +kernel
private theorem batch_2 : batch 2 = true := by decide +kernel
private theorem batch_3 : batch 3 = true := by decide +kernel
private theorem batch_4 : batch 4 = true := by decide +kernel
private theorem batch_5 : batch 5 = true := by decide +kernel
private theorem batch_6 : batch 6 = true := by decide +kernel
private theorem batch_7 : batch 7 = true := by decide +kernel
private theorem batch_8 : batch 8 = true := by decide +kernel
private theorem batch_9 : batch 9 = true := by decide +kernel
private theorem batch_10 : batch 10 = true := by decide +kernel
private theorem batch_11 : batch 11 = true := by decide +kernel
private theorem batch_12 : batch 12 = true := by decide +kernel
private theorem batch_13 : batch 13 = true := by decide +kernel
private theorem batch_14 : batch 14 = true := by decide +kernel
private theorem batch_15 : batch 15 = true := by decide +kernel
private theorem batch_16 : batch 16 = true := by decide +kernel
private theorem batch_17 : batch 17 = true := by decide +kernel
private theorem batch_18 : batch 18 = true := by decide +kernel
private theorem batch_19 : batch 19 = true := by decide +kernel
private theorem batch_20 : batch 20 = true := by decide +kernel
private theorem batch_21 : batch 21 = true := by decide +kernel
private theorem batch_22 : batch 22 = true := by decide +kernel
private theorem batch_23 : batch 23 = true := by decide +kernel
private theorem batch_24 : batch 24 = true := by decide +kernel
private theorem batch_25 : batch 25 = true := by decide +kernel
private theorem batch_26 : batch 26 = true := by decide +kernel

private theorem validated (a : Nat) (ha : a < 729) : checkAssignment a = true := by
  have group (g : Nat) (hg : g < 27) : batch g = true := by
    match g with
    | 0 => exact batch_0
    | 1 => exact batch_1
    | 2 => exact batch_2
    | 3 => exact batch_3
    | 4 => exact batch_4
    | 5 => exact batch_5
    | 6 => exact batch_6
    | 7 => exact batch_7
    | 8 => exact batch_8
    | 9 => exact batch_9
    | 10 => exact batch_10
    | 11 => exact batch_11
    | 12 => exact batch_12
    | 13 => exact batch_13
    | 14 => exact batch_14
    | 15 => exact batch_15
    | 16 => exact batch_16
    | 17 => exact batch_17
    | 18 => exact batch_18
    | 19 => exact batch_19
    | 20 => exact batch_20
    | 21 => exact batch_21
    | 22 => exact batch_22
    | 23 => exact batch_23
    | 24 => exact batch_24
    | 25 => exact batch_25
    | 26 => exact batch_26
    | n+27 => omega
  have h := List.all_eq_true.mp (group (a/27) (by omega))
    (a%27) (List.mem_range.mpr (Nat.mod_lt _ (by decide)))
  simpa only [show 27*(a/27)+a%27=a by omega] using h

private theorem node {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64) :
    checkNode a t s = true :=
  List.all_eq_true.mp (List.all_eq_true.mp (validated a ha) t (List.mem_range.mpr ht))
    s (List.mem_range.mpr hs)

theorem bounded_rank {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64) :
    rk (entry a t s) < 11 :=
  of_decide_eq_true (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp (node ha ht hs)).1).1

theorem current {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64) :
    idx (tag (entry a t s)) < 5 ∧
    s.testBit (idx (tag (entry a t s))) = bit0 (tag (entry a t s)) t ∧
    s.testBit (idx (tag (entry a t s))+1) = bit1 (tag (entry a t s)) t :=
  of_decide_eq_true (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp (node ha ht hs)).1).2

theorem edge {a t s : Nat} (ha : a < 729) (ht : t < 3) (hs : s < 64)
    (w e : Bool) (h : allowed a t s (step s w e) = true) :
    let x := entry a t s
    let y := entry a ((t+1)%3) (step s w e)
    rk y < rk x ∨ (rk y = rk x ∧ tag y = tag x) := by
  have yes := (Bool.and_eq_true_iff.mp (node ha ht hs)).2
  simp only [Bool.and_eq_true, decide_eq_true_eq] at yes
  cases w <;> cases e
  · exact yes.1.1.1 h
  · exact yes.1.1.2 h
  · exact yes.1.2 h
  · exact yes.2 h

end PhaseFalls.Six
