import Ruliology.CellularAutomata.Rule30Problem3Bounds

namespace PhaseTwo.LengthControl
open Ruliology.CellularAutomata Rule30Problem3 Rule30Problem3Bounds

/-- Each successive dyadic block changes colour. Zero is read from a blank tape. -/
def colour (n : Nat) := decide (bitLen n % 2 = 1)

def scanner : Machine where
  q := 1
  s := 0
  δ := fun p a => if a.val == 0 then .inl (decide (p.val = 1))
    else .inr (⟨1-p.val, by omega⟩, a, .right)

private def cfg (n t : Nat) : Cfg scanner where
  state := ⟨t % 2, by change t % 2 < 2; omega⟩
  head := t
  tape := (scanner.init n).tape

theorem scan_to_digit (n : Nat) : ∀ t, t ≤ bitLen n → scanner.run n t = .inr (cfg n t)
  | 0, _ => rfl
  | t+1, h => by
    simp only [Machine.run, scan_to_digit n t (by omega)]
    have pow := two_pow_le_of_lt_bitLen (show t < bitLen n by omega)
    have ha : (((scanner.init n).tape (t:Int)).val == 0) = false := by
      rw [init_tape_val_eq_zero_iff_lt_two_pow, decide_eq_false (by omega)]
    have hd : scanner.δ (cfg n t).state ((cfg n t).tape (cfg n t).head) =
        .inr ((cfg n (t+1)).state, (scanner.init n).tape (t:Int), Move.right) := by
      change (if (((scanner.init n).tape (t:Int)).val == 0) then _ else _) = _
      rw [ha]
      simp only [Bool.false_eq_true, ↓reduceIte, cfg]
      congr 3 <;> omega
    rw [step_eq_inr_of_delta_eq_inr hd]
    congr 1
    unfold cfg
    congr 1
    funext i
    split <;> rename_i hi
    · rw [hi]
    · rfl

theorem scan_time : Computes scanner colour (fun n => bitLen n + 1) := by
  intro n
  simp only [Machine.run, scan_to_digit n _ (Nat.le_refl _)]
  apply step_eq_inl_of_delta_eq_inl
  have ha : (((scanner.init n).tape (bitLen n:Int)).val == 0) = true := by
    rw [init_tape_val_eq_zero_iff_lt_two_pow, decide_eq_true (lt_two_pow_bitLen n)]
  change (if (((scanner.init n).tape (bitLen n:Int)).val == 0) then _ else _) = _
  rw [ha]
  rfl

/-- Adding a single leading digit flips the answer on every positive input.
    All the old digits agree. -/
theorem flip (n : Nat) :
    colour (n + 2 ^ bitLen n) ≠ colour n := by
  have small := lt_two_pow_bitLen n
  have pos := Nat.two_pow_pos (bitLen n)
  have nz : n + 2 ^ bitLen n ≠ 0 := by omega
  have log : (n + 2 ^ bitLen n).log2 = bitLen n := (Nat.log2_eq_iff nz).mpr
    ⟨by omega, by rw [Nat.pow_succ]; omega⟩
  have len : bitLen (n + 2 ^ bitLen n) = bitLen n + 1 := by
    rw [bitLen, ite_eq_right nz, log]
  simp only [colour, len, ne_eq, decide_eq_decide]
  omega

/-- Exact lower bound for every correct machine and every positive input. -/
theorem all_machines {M : Machine} {T} (hm : Computes M colour T) {n : Nat} (hn : 1 ≤ n) :
    bitLen n + 1 ≤ T n := by
  have ne : n ≠ 0 := by omega
  have h := flip n
  simp only [bitLen, ite_eq_right ne] at h ⊢
  exact log2_succ_succ_le_time_of_ray_flip (u := 1) hm hn (by simpa using h)

theorem sublinear (c : Nat) {n : Nat} (h : 2^(c+6) ≤ n) :
    c*(bitLen n+1) ≤ n := mul_bitLen_succ_le c h

private theorem shell {n j : Nat} (lo : 2^j ≤ n) (hi : n < 2^(j+1)) :
    bitLen n = j+1 := by
  have pos := Nat.two_pow_pos j
  have nz : n ≠ 0 := by omega
  rw [bitLen, ite_eq_right nz, (Nat.log2_eq_iff nz).mpr ⟨lo,hi⟩]

theorem aperiodic {P : Nat} (positive : 0 < P) :
    ¬ Rule30LeftReset.EvPer colour P := by
  rintro ⟨T, per⟩
  let j := T+P
  have large : T+P < 2^j := Nat.lt_two_pow_self
  let n := 2^(j+1)-P
  have boundary : n+P = 2^(j+1) := by dsimp [n]; rw [Nat.pow_succ]; omega
  have prev : bitLen n = j+1 := shell (by dsimp [n]; rw [Nat.pow_succ]; omega)
    (by dsimp [n]; rw [Nat.pow_succ]; omega)
  have pos := Nat.two_pow_pos (j+1)
  have next : bitLen (2^(j+1)) = j+1+1 := shell (Nat.le_refl _) (by
    rw [Nat.pow_succ 2 (j+1)]; omega)
  have h := per n (by dsimp [n]; rw [Nat.pow_succ]; omega)
  rw [boundary] at h
  simp only [colour, prev, next, decide_eq_decide] at h
  omega

end PhaseTwo.LengthControl
