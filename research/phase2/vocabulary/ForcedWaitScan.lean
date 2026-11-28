import SettlingWaits

namespace PhaseTwo.ForcedWaitScan

open Ruliology.CellularAutomata Rule30FourFrontsBase Rule30FourFronts Rule30FourLeftSides

private def step (word t : Nat) := if word = 0 then t else t + srch word t 16 + 1

private theorem step_eq (w : Nat → Nat) (j : Nat) :
    step (w (j+1)) (F w (j+1)) = F w (j+2) := by
  by_cases h : w (j+1) = 0
  · simp [step, h, F_white_simp w j h]
  · simp [step, h, F_black_simp w j h]

/-- Read a phase in 256-wheel pieces so kernel replay can reuse the extracted bits. -/
private def bit (v j r : Nat) : Bool :=
  (((Rule30UniversalLeftSide.rowAt 87867 v r) >>> (j/256*256)) % 2^256).testBit (j%256)

private theorem bit_eq (v j r : Nat) (hr : r < 16) : bit v j r = (wd v j).testBit r := by
  rw [wd_row v j r hr, bit, Nat.testBit_mod_two_pow, Nat.testBit_shiftRight]
  rw [decide_eq_true (by omega : j%256 < 256), Bool.true_and]
  congr 1
  omega

private def first (v j t : Nat) : Nat → Nat
  | 0 => 16
  | f+1 => if bit v j ((t+(16-(f+1)))%16) then 16-(f+1) else first v j t f

private theorem first_eq (v j t f : Nat) : first v j t f = srch (wd v j) t f := by
  induction f with
  | zero => rfl
  | succ f ih => simp only [first, srch, bit_eq _ _ _ (Nat.mod_lt _ (by decide)), ih]

private def advanceWait (v j t : Nat) :=
  let n := first v j t 16
  if n=16 then t else t+n+1

private theorem next_eq (v j : Nat) : advanceWait v (j+1) (F (wd v) (j+1)) = F (wd v) (j+2) := by
  rw [← step_eq]
  simp only [advanceWait, first_eq, step]
  by_cases h : wd v (j+1) = 0
  · have zero (t f : Nat) : srch 0 t f = 16 := by
      induction f with
      | zero => rfl
      | succ f ih => simp [srch, ih]
    simp [h, zero]
  · have lt := srch_lt_sixteen_of_ne_zero (wd_lt _ _) h (F (wd v) (j+1))
    simp [h, Nat.ne_of_lt lt]

/-- Scan n transitions beginning at wheel j+1, with a balanced evaluation tree. -/
private def scan (v : Nat) (cap : Nat) : Nat → Nat → Nat → Nat → Nat × Bool
  | 0, n, j, t => if n = 0 then (t, true) else
      let u := advanceWait v (j+1) t
      (u, decide (u ≤ t+cap ∧ 10*u ≤ 21*(j+2)))
  | f+1, n, j, t =>
      let a := scan v cap f (n/2) j t
      let b := scan v cap f (n-n/2) (j+n/2) a.1
      (b.1, a.2 && b.2)

private theorem scan_sound (v : Nat) (cap f n j : Nat) (hn : n ≤ 2^f) :
    let result := scan v cap f n j (F (wd v) (j+1))
    result.1 = F (wd v) (j+n+1) ∧
      (result.2=true → ∀ k, j ≤ k → k < j+n →
        F (wd v) (k+2) ≤ F (wd v) (k+1)+cap ∧ 10*F (wd v) (k+2) ≤ 21*(k+2)) := by
  induction f generalizing n j with
  | zero =>
    simp only [Nat.pow_zero] at hn
    rcases Nat.eq_zero_or_pos n with rfl | hp
    · simp [scan]; omega
    · have : n=1 := by omega
      subst n
      simp only [scan, Nat.reduceEqDiff, ↓reduceIte, next_eq, decide_eq_true_eq]
      refine ⟨True.intro, fun h k lo hi => ?_⟩
      have e : k=j := by omega
      simpa only [e] using h
  | succ f ih =>
    rw [Nat.pow_succ] at hn
    have left := ih (n/2) j (by omega)
    have right := ih (n-n/2) (j+n/2) (by omega)
    simp only [scan, left.1, Bool.and_eq_true]
    rw [right.1, show j+n/2+(n-n/2)=j+n by omega]
    refine ⟨rfl, fun h k lo hi => ?_⟩
    by_cases p : k < j+n/2
    · exact left.2 h.1 k lo p
    · exact right.2 h.2 k (by omega) (by omega)


private def Covered (v cap j tick : Nat) : Prop :=
  F (wd v) (j+1) = tick ∧ ∀ k, k < j →
    F (wd v) (k+2) ≤ F (wd v) (k+1)+cap ∧ 10*F (wd v) (k+2) ≤ 21*(k+2)

private theorem extend {v cap j t k u : Nat} (prev : Covered v cap j t) (le : j ≤ k)
    (check : scan v cap ((k-j).log2+1) (k-j) j t = (u,true)) : Covered v cap k u := by
  have h := scan_sound v cap ((k-j).log2+1) (k-j) j (Nat.le_of_lt Nat.lt_log2_self)
  dsimp only at h
  rw [prev.1, check, show j+(k-j)=k by omega] at h
  refine ⟨h.1.symm, fun i hi => ?_⟩
  by_cases early : i < j
  · exact prev.2 i early
  · exact h.2 rfl i (by omega) hi

private theorem start (v cap : Nat) : Covered v cap 0 1 :=
  ⟨F_one _, fun _ h => by omega⟩

set_option maxHeartbeats 0
set_option maxRecDepth 100000
private theorem a_2048 : Covered A0 15 2048 4056 :=
  extend (start A0 15) (by decide) (by decide +kernel)
private theorem a_4096 : Covered A0 15 4096 8122 :=
  extend a_2048 (by decide) (by decide +kernel)
private theorem a_6144 : Covered A0 15 6144 12295 :=
  extend a_4096 (by decide) (by decide +kernel)
private theorem a_8192 : Covered A0 15 8192 16553 :=
  extend a_6144 (by decide) (by decide +kernel)
private theorem a_10240 : Covered A0 15 10240 20672 :=
  extend a_8192 (by decide) (by decide +kernel)
private theorem a_12288 : Covered A0 15 12288 24841 :=
  extend a_10240 (by decide) (by decide +kernel)
private theorem a_14336 : Covered A0 15 14336 28909 :=
  extend a_12288 (by decide) (by decide +kernel)
private theorem a_16384 : Covered A0 15 16384 32985 :=
  extend a_14336 (by decide) (by decide +kernel)
private theorem a_18432 : Covered A0 15 18432 37110 :=
  extend a_16384 (by decide) (by decide +kernel)
private theorem a_20480 : Covered A0 15 20480 41222 :=
  extend a_18432 (by decide) (by decide +kernel)
private theorem a_22528 : Covered A0 15 22528 45352 :=
  extend a_20480 (by decide) (by decide +kernel)
private theorem a_24576 : Covered A0 15 24576 49486 :=
  extend a_22528 (by decide) (by decide +kernel)
private theorem a_25544 : Covered A0 15 25544 51580 :=
  extend a_24576 (by decide) (by decide +kernel)
private theorem a_25545 : Covered A0 15 25545 51595 :=
  extend a_25544 (by decide) (by decide +kernel)
private theorem a_26624 : Covered A0 15 26624 53857 :=
  extend a_25545 (by decide) (by decide +kernel)
private theorem a_28672 : Covered A0 15 28672 58007 :=
  extend a_26624 (by decide) (by decide +kernel)
private theorem a_30720 : Covered A0 15 30720 62231 :=
  extend a_28672 (by decide) (by decide +kernel)
private theorem a_32768 : Covered A0 15 32768 66275 :=
  extend a_30720 (by decide) (by decide +kernel)
private theorem a_34816 : Covered A0 15 34816 70305 :=
  extend a_32768 (by decide) (by decide +kernel)
private theorem a_36864 : Covered A0 15 36864 74469 :=
  extend a_34816 (by decide) (by decide +kernel)
private theorem a_38912 : Covered A0 15 38912 78504 :=
  extend a_36864 (by decide) (by decide +kernel)
private theorem a_40960 : Covered A0 15 40960 82510 :=
  extend a_38912 (by decide) (by decide +kernel)
private theorem a_43008 : Covered A0 15 43008 86721 :=
  extend a_40960 (by decide) (by decide +kernel)
private theorem a_45056 : Covered A0 15 45056 90866 :=
  extend a_43008 (by decide) (by decide +kernel)
private theorem a_47104 : Covered A0 15 47104 95135 :=
  extend a_45056 (by decide) (by decide +kernel)
private theorem a_49152 : Covered A0 15 49152 99283 :=
  extend a_47104 (by decide) (by decide +kernel)
private theorem a_51200 : Covered A0 15 51200 103395 :=
  extend a_49152 (by decide) (by decide +kernel)
private theorem a_53248 : Covered A0 15 53248 107399 :=
  extend a_51200 (by decide) (by decide +kernel)
private theorem a_55296 : Covered A0 15 55296 111637 :=
  extend a_53248 (by decide) (by decide +kernel)
private theorem a_57344 : Covered A0 15 57344 115590 :=
  extend a_55296 (by decide) (by decide +kernel)
private theorem a_59392 : Covered A0 15 59392 119637 :=
  extend a_57344 (by decide) (by decide +kernel)
private theorem a_61440 : Covered A0 15 61440 123757 :=
  extend a_59392 (by decide) (by decide +kernel)
private theorem a_63488 : Covered A0 15 63488 127910 :=
  extend a_61440 (by decide) (by decide +kernel)
private theorem a_65536 : Covered A0 15 65536 131946 :=
  extend a_63488 (by decide) (by decide +kernel)
private theorem a_67584 : Covered A0 15 67584 136093 :=
  extend a_65536 (by decide) (by decide +kernel)
private theorem a_69632 : Covered A0 15 69632 140169 :=
  extend a_67584 (by decide) (by decide +kernel)
private theorem a_71680 : Covered A0 15 71680 144337 :=
  extend a_69632 (by decide) (by decide +kernel)
private theorem a_73728 : Covered A0 15 73728 148437 :=
  extend a_71680 (by decide) (by decide +kernel)
private theorem a_75776 : Covered A0 15 75776 152511 :=
  extend a_73728 (by decide) (by decide +kernel)
private theorem a_77824 : Covered A0 15 77824 156566 :=
  extend a_75776 (by decide) (by decide +kernel)
private theorem a_79872 : Covered A0 15 79872 160716 :=
  extend a_77824 (by decide) (by decide +kernel)
private theorem a_81920 : Covered A0 15 81920 164847 :=
  extend a_79872 (by decide) (by decide +kernel)
private theorem a_83968 : Covered A0 15 83968 169054 :=
  extend a_81920 (by decide) (by decide +kernel)
private theorem a_86016 : Covered A0 15 86016 173116 :=
  extend a_83968 (by decide) (by decide +kernel)
private theorem a_87865 : Covered A0 15 87865 176968 :=
  extend a_86016 (by decide) (by decide +kernel)


private theorem transfer {v v' cap cap' j t : Nat} (prev : Covered v cap j t)
    (le : cap ≤ cap') (same : ∀ i, i+2 ≤ j+1 → wd v (i+1) = wd v' (i+1)) :
    Covered v' cap' j t := by
  have eq (k : Nat) (hk : k ≤ j+1) : F (wd v) k = F (wd v') k :=
    F_congr k (fun i hi => same i (by omega))
  refine ⟨(eq _ (by omega)).symm.trans prev.1, fun k hk => ?_⟩
  rw [← eq (k+2) (by omega), ← eq (k+1) (by omega)]
  have h := prev.2 k hk
  exact ⟨by omega, h.2⟩

private theorem a1_57344 : Covered A1 15 57344 115590 :=
  transfer a_57344 (by decide) (fun i hi => wA1_eq_A0 i (by omega))
private theorem a1_59392 : Covered A1 15 59392 119668 :=
  extend a1_57344 (by decide) (by decide +kernel)
private theorem a1_61440 : Covered A1 15 61440 123755 :=
  extend a1_59392 (by decide) (by decide +kernel)
private theorem a1_63488 : Covered A1 15 63488 127968 :=
  extend a1_61440 (by decide) (by decide +kernel)
private theorem a1_65536 : Covered A1 15 65536 132053 :=
  extend a1_63488 (by decide) (by decide +kernel)
private theorem a1_67584 : Covered A1 15 67584 136112 :=
  extend a1_65536 (by decide) (by decide +kernel)
private theorem a1_69632 : Covered A1 15 69632 140251 :=
  extend a1_67584 (by decide) (by decide +kernel)
private theorem a1_71680 : Covered A1 15 71680 144377 :=
  extend a1_69632 (by decide) (by decide +kernel)
private theorem a1_73728 : Covered A1 15 73728 148541 :=
  extend a1_71680 (by decide) (by decide +kernel)
private theorem a1_75776 : Covered A1 15 75776 152824 :=
  extend a1_73728 (by decide) (by decide +kernel)
private theorem a1_77824 : Covered A1 15 77824 157085 :=
  extend a1_75776 (by decide) (by decide +kernel)
private theorem a1_79872 : Covered A1 15 79872 161302 :=
  extend a1_77824 (by decide) (by decide +kernel)
private theorem a1_81920 : Covered A1 15 81920 165546 :=
  extend a1_79872 (by decide) (by decide +kernel)
private theorem a1_83968 : Covered A1 15 83968 169465 :=
  extend a1_81920 (by decide) (by decide +kernel)
private theorem a1_86016 : Covered A1 15 86016 173561 :=
  extend a1_83968 (by decide) (by decide +kernel)
private theorem a1_87865 : Covered A1 15 87865 177229 :=
  extend a1_86016 (by decide) (by decide +kernel)

private theorem b0_51200 : Covered B0 15 51200 103395 :=
  transfer a_51200 (by decide) (fun i hi => wB0_eq_A0 i (by omega))
private theorem b0_53248 : Covered B0 15 53248 107375 :=
  extend b0_51200 (by decide) (by decide +kernel)
private theorem b0_55296 : Covered B0 15 55296 111612 :=
  extend b0_53248 (by decide) (by decide +kernel)
private theorem b0_57344 : Covered B0 15 57344 115651 :=
  extend b0_55296 (by decide) (by decide +kernel)
private theorem b0_59392 : Covered B0 15 59392 119789 :=
  extend b0_57344 (by decide) (by decide +kernel)
private theorem b0_61440 : Covered B0 15 61440 123819 :=
  extend b0_59392 (by decide) (by decide +kernel)
private theorem b0_63488 : Covered B0 15 63488 127945 :=
  extend b0_61440 (by decide) (by decide +kernel)
private theorem b0_65536 : Covered B0 15 65536 132155 :=
  extend b0_63488 (by decide) (by decide +kernel)
private theorem b0_67584 : Covered B0 15 67584 136442 :=
  extend b0_65536 (by decide) (by decide +kernel)
private theorem b0_69632 : Covered B0 15 69632 140569 :=
  extend b0_67584 (by decide) (by decide +kernel)
private theorem b0_71680 : Covered B0 15 71680 144647 :=
  extend b0_69632 (by decide) (by decide +kernel)
private theorem b0_73728 : Covered B0 16 73728 148842 :=
  extend (transfer b0_71680 (by decide : 15 ≤ 16) (fun _ _ => rfl)) (by decide) (by decide +kernel)
private theorem b0_75776 : Covered B0 16 75776 152936 :=
  extend b0_73728 (by decide) (by decide +kernel)
private theorem b0_77824 : Covered B0 16 77824 157043 :=
  extend b0_75776 (by decide) (by decide +kernel)
private theorem b0_79872 : Covered B0 16 79872 161153 :=
  extend b0_77824 (by decide) (by decide +kernel)
private theorem b0_81920 : Covered B0 16 81920 165283 :=
  extend b0_79872 (by decide) (by decide +kernel)
private theorem b0_83968 : Covered B0 16 83968 169339 :=
  extend b0_81920 (by decide) (by decide +kernel)
private theorem b0_85304 : Covered B0 16 85304 172032 :=
  extend b0_83968 (by decide) (by decide +kernel)
private theorem b0_85305 : Covered B0 16 85305 172048 :=
  extend b0_85304 (by decide) (by decide +kernel)
private theorem b0_86016 : Covered B0 16 86016 173503 :=
  extend b0_85305 (by decide) (by decide +kernel)
private theorem b0_87865 : Covered B0 16 87865 177170 :=
  extend b0_86016 (by decide) (by decide +kernel)

private theorem b1_71680 : Covered B1 15 71680 144647 :=
  transfer b0_71680 (by decide) (fun i hi => wB1_eq_B0 i (by omega))
private theorem b1_73728 : Covered B1 15 73728 148744 :=
  extend b1_71680 (by decide) (by decide +kernel)
private theorem b1_75776 : Covered B1 15 75776 152934 :=
  extend b1_73728 (by decide) (by decide +kernel)
private theorem b1_77824 : Covered B1 15 77824 157080 :=
  extend b1_75776 (by decide) (by decide +kernel)
private theorem b1_79872 : Covered B1 15 79872 161065 :=
  extend b1_77824 (by decide) (by decide +kernel)
private theorem b1_81920 : Covered B1 15 81920 165300 :=
  extend b1_79872 (by decide) (by decide +kernel)
private theorem b1_83968 : Covered B1 15 83968 169521 :=
  extend b1_81920 (by decide) (by decide +kernel)
private theorem b1_86016 : Covered B1 15 86016 173677 :=
  extend b1_83968 (by decide) (by decide +kernel)
private theorem b1_87865 : Covered B1 15 87865 177560 :=
  extend b1_86016 (by decide) (by decide +kernel)


private theorem budgets {v cap tick : Nat} (h : Covered v cap 87865 tick) (hc : 1 ≤ cap)
    {j : Nat} (hj : j < 87866) :
    F (wd v) (j+1) ≤ F (wd v) j+cap ∧ 10*F (wd v) (j+1) ≤ 21*(j+1) := by
  cases j with
  | zero => rw [F_zero, F_one]; omega
  | succ k => exact h.2 k (by omega)

/-- On the seed’s strip the individual cap is 15, and the cumulative forced clock is at most 2.1j. -/
theorem seed_strip_waits {j : Nat} (hj : j < 87866) :
    F wdA0 (j+1) ≤ F wdA0 j+15 ∧ 10*F wdA0 (j+1) ≤ 21*(j+1) :=
  budgets a_87865 (by decide) hj

/-- The cap 15 is attained at the transition out of wheel 25545. -/
theorem seed_strip_long_wait : F wdA0 25545 = 51580 ∧ F wdA0 25546 = 51595 :=
  ⟨a_25544.1, a_25545.1⟩


/-- All four kit clocks satisfy the same cumulative estimate, including B0 where an
individual increment really reaches sixteen. -/
theorem four_strip_waits {j : Nat} (hj : j < 87866) :
    (F wdA1 (j+1) ≤ F wdA1 j+15 ∧ 10*F wdA1 (j+1) ≤ 21*(j+1)) ∧
    (F wdB0 (j+1) ≤ F wdB0 j+16 ∧ 10*F wdB0 (j+1) ≤ 21*(j+1)) ∧
    (F wdB1 (j+1) ≤ F wdB1 j+15 ∧ 10*F wdB1 (j+1) ≤ 21*(j+1)) ∧
    (F wdA0 (j+1) ≤ F wdA0 j+15 ∧ 10*F wdA0 (j+1) ≤ 21*(j+1)) :=
  ⟨budgets a1_87865 (by decide) hj, budgets b0_87865 (by decide) hj,
   budgets b1_87865 (by decide) hj, seed_strip_waits hj⟩

theorem full_wait_on_B0 : F wdB0 85305 = 172032 ∧ F wdB0 85306 = 172048 :=
  ⟨b0_85304.1, b0_85305.1⟩

end PhaseTwo.ForcedWaitScan
