module

public import Rule30EveryKInverse

/-!
# Kernel controls for the one- and two-tick instances of S2

Check the actual minimum K1 at two witness widths. The small lists below
bound periodic words only for these controls. The every-k proof in the
imported module is independent of these lists.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30EveryKControls

open Rule30EveryKStatement Rule30EveryKInverse Rule30UniversalLeftSide

/-- At width n+2, extend each candidate of width n+1 with either high
bit, advance four ticks, and keep one copy of each image. -/
private def candidates : Nat → List Nat
  | 0 => [1]
  | n+1 => ((candidates n).flatMap (fun v =>
      [bandAt (n+2) v 4, bandAt (n+2) (v+2^(n+1)) 4])).eraseDups

private theorem project (w v t : Nat) :
    bandAt (w+1) v t % 2^w = bandAt w (v%2^w) t := by
  induction t with
  | zero => rfl
  | succ t ih =>
    change bandStep (w+1) _ % 2^w = bandStep w _
    unfold bandAt at ih
    rw [← ih]
    unfold bandStep stepK
    rw [Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 (Nat.le_succ w))]
    simp only [Nat.xor_mod_two_pow, Nat.or_mod_two_pow,
      Nat.mod_two_pow_shiftLeft_mod_two_pow, Nat.mod_mod]

private theorem candidates_cover (n v q : Nat) (odd : OddBand (n+1) v)
    (pos : 0 < q) (cycle : bandAt (n+1) v q = v) : v ∈ candidates n := by
  induction n generalizing v with
  | zero =>
    have lt : v < 2 := odd.1
    have parity : v%2=1 := by simpa [Nat.testBit_zero] using odd.2
    simp [candidates,show v=1 by omega]
  | succ n ih =>
    let w := n+1
    let a := bandAt (w+1) v (4*q-4)
    have add (s t : Nat) : bandAt (w+1) v (s+t) = bandAt (w+1) (bandAt (w+1) v s) t := by
      induction t with
      | zero => rfl
      | succ t h => exact congrArg (bandStep _) h
    have oddAt (t : Nat) : OddBand (w+1) (bandAt (w+1) v t) := by
      induction t with
      | zero => exact odd
      | succ t h => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _),(stepK_bit_zero (by omega) _).trans h.2⟩
    have oa := oddAt (4*q-4)
    have back : bandAt (w+1) a 4 = v := by
      rw [← add,show 4*q-4+4 = 0+4*q by omega]
      exact rowAt_add_mul cycle 0 4
    have c : bandAt (w+1) a q = a := by rw [← add]; exact rowAt_add_period cycle _
    let low := a % 2^w
    have bit : low.testBit 0 = true := by
      simp only [low, Nat.testBit_mod_two_pow, show 0<w by dsimp [w]; omega, decide_true, Bool.true_and]
      exact oa.2
    have sub : low ∈ candidates n := ih low ⟨Nat.mod_lt _ (Nat.two_pow_pos _),bit⟩ (by
      rw [← project, c])
    have size : a < 2^w * 2 := by simpa only [Nat.pow_succ] using oa.1
    have parts := Nat.mod_add_div a (2^w)
    have divlt : a / 2^w < 2 := (Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _)).mpr (by omega)
    have decomp : a = low ∨ a = low+2^w := by
      rcases (show ∀ z : Nat, z < 2 → z = 0 ∨ z = 1 by omega) _ divlt with z | one
      · simp [z,low] at parts ⊢; exact Or.inl parts.symm
      · simp [one] at parts; exact Or.inr parts.symm
    rw [candidates,List.mem_eraseDups,List.mem_flatMap]
    refine ⟨low,sub,?_⟩
    rcases decomp with eq | eq <;> rw [eq] at back <;> simp [← back,w]

private theorem walk_sound (w v fuel e q : Nat)
    (h : returnPeriod.walk w v fuel (bandAt w v e) e = some q) :
    0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing e with
  | zero => simp [returnPeriod.walk] at h
  | succ fuel ih =>
    rw [returnPeriod.walk] at h
    split at h <;> rename_i eq
    · cases h; exact ⟨by omega,eq⟩
    · exact ih (e+1) h

private def sufficient (w k v : Nat) := match returnPeriod w v with
  | none => true
  | some q => decide (k ≤ phaseCapacity w v q)

private theorem checked_minimum (n k : Nat) (small : k ≤ n+1)
    (test : (candidates n).all (sufficient (n+1) k) = true) : k ≤ K1 (n+1) := by
  let step (b i : Nat) := match returnPeriod (n+1) (2*i+1) with
    | none => b
    | some q => min b (phaseCapacity (n+1) (2*i+1) q)
  have preserve (b i : Nat) (hb : k ≤ b) (hi : i < 2^n) : k ≤ step b i := by
    unfold step
    split <;> rename_i found
    · exact hb
    · obtain ⟨pos,cyc⟩ := walk_sound (n+1) (2*i+1) _ 0 _ found
      have odd : OddBand (n+1) (2*i+1) := ⟨by rw [Nat.pow_succ]; omega,by simp [Nat.testBit_zero]⟩
      have ht := List.all_eq_true.mp test _ (candidates_cover _ _ _ odd pos cyc)
      simp [sufficient,found] at ht
      exact Nat.le_min.mpr ⟨hb,ht⟩
  have bound (xs : List Nat) (b : Nat) (hb : k ≤ b) (hxs : ∀ i ∈ xs, i < 2^n) :
      k ≤ xs.foldl step b := by
    induction xs generalizing b with
    | nil => exact hb
    | cons a xs ih => exact ih _ (preserve _ _ hb (hxs a (by simp))) (fun i hi => hxs i (by simp [hi]))
  exact bound _ _ small fun _ hi => List.mem_range.mp hi

set_option maxRecDepth 16384 in
private theorem width_eight : 1 ≤ K1 8 := checked_minimum 7 1 (by decide) (by decide +kernel)

set_option maxRecDepth 16384 in
private theorem width_twenty : 2 ≤ K1 20 := checked_minimum 19 2 (by decide) (by decide +kernel)

theorem one_tick : TargetAt 1 263 :=
  capacity_at_settling_age 1 8 _ (by decide) width_eight (uniform_settling (by decide : 0 < 8))

theorem two_ticks : TargetAt 2 1048595 :=
  capacity_at_settling_age 2 20 _ (by decide) width_twenty (uniform_settling (by decide : 0 < 20))

end Ruliology.CellularAutomata.Rule30EveryKControls
