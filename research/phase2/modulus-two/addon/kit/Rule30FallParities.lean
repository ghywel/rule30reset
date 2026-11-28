module

public import Ruliology.CellularAutomata.Rule30FallResidues
public import Ruliology.CellularAutomata.Rule30Certificates.FallParityData

/-!
# Rule 30: falls on both parities in every 27 adjacent singleton columns

A column *falls* at tick `t` when it is black at `t` and white at `t + 1` (`Rule30FallResidues.Fall`).

* `two_parities_every_27`: for every integer `i`, one of the 27 columns `i, …, i + 26` of Rule 30 from a single
  black cell has falls on even ticks and on odd ticks, each after every cutoff (`Rule30FallResidues.Cofinal`).
* `two_cofinal_from_goodAny`: the step to the single seed, for any width and modulus. If every column of a strip
  kept its late falls to one residue, the strip would follow a path of the strip graph, and `GoodAny` would make two
  of its columns eventually periodic, which Jen's theorem forbids.

With `Rule30FallResidues.two_cofinal_every_modulus` (six columns for every modulus from three), every modulus from
two has two cofinal falling residues in every 27 adjacent columns. At modulus two the six-cell strip is not enough
(`Rule30FallResidues.not_good_parity`).
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30FallParities

open Ruliology.CellularAutomata Rule30StripCertificates Rule30FallResidues Rule30Jen

/-! ### Physical rows of any width -/

def rowW (W T : Nat) (j : Int) : Nat := encRow T (j-1) W

theorem rowW_lt (W T : Nat) (j : Int) : rowW W T j < 2^W :=
  (enc_encRow W T (j-1)).1

theorem rowW_bit (W T : Nat) (j : Int) (k : Nat) (hk : k < W) :
    (rowW W T j).testBit k = cell T (j+k) := by
  simpa [rowW] using (enc_encRow W T (j-1)).2 k hk

theorem rowW_step (W T : Nat) (j : Int) :
    rowW W (T+1) j = stripStep W (cell T (j-1)) (cell T (j+W)) (rowW W T j) := by
  have nxt := enc_step (enc_encRow W T (j-1))
  simp only [Int.sub_add_cancel] at nxt
  apply Nat.eq_of_testBit_eq
  intro k
  by_cases hk : k < W
  · rw [rowW_bit _ _ _ k hk]
    simpa [rowW] using (nxt.2 k hk).symm
  · have cut : 2^W ≤ 2^k := Nat.pow_le_pow_right (by decide) (by omega)
    rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _) cut)]
    exact (Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (stripStep_lt _ _ _ _) cut)).symm

/-! ### The singleton -/

private theorem escapeW {W m : Nat} (_hW : 0 < W) (hm : 0 < m) (i : Int) (a : Fin W → Fin m)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) (T : Nat) :
    ∃ (j : Fin W) (t : Nat), T ≤ t ∧ Fall (i+j.val) t ∧ t%m ≠ (a j).val := by
  apply Classical.byContradiction
  intro no
  let S := T*m
  have Slarge : T ≤ S := by
    simpa [S] using Nat.mul_le_mul_left T (show 1 ≤ m by omega)
  let phases (j : Nat) := if hj : j < W then (a ⟨j,hj⟩).val else 0
  let x (t : Nat) := rowW W (S+t) i
  have run : Run W m phases x := by
    refine ⟨fun t => rowW_lt _ _ _, fun t => ?_⟩
    have adv := rowW_step W (S+t) i
    refine ⟨mem_successors.mpr ⟨_, _, by simpa [x, Nat.add_assoc] using adv⟩, (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    by_cases hj : j < W
    · rw [permit_bit, decide_eq_true_eq]
      refine ⟨hj, ?_⟩
      have b : Fall (i+j) (S+t) := by
        unfold x at on off
        rw [rowW_bit _ _ _ _ hj] at on off
        exact ⟨on, by simpa only [Nat.add_assoc] using off⟩
      have eq : (S+t)%m = (a ⟨j,hj⟩).val := by
        apply Classical.byContradiction
        intro neq
        exact no ⟨⟨j,hj⟩, S+t, by omega, b, neq⟩
      simpa only [S, phases, dite_eq_left hj, Nat.add_comm _ t, Nat.add_mul_mod_self_right] using eq.symm
    · have hn : (x t).testBit j = false :=
        Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _)
          (Nat.pow_le_pow_right (by decide : 0<2) (by omega : W ≤ j)))
      simp [hn] at on
  have phasesBound (j : Nat) (hj : j < W) : phases j < m := by
    simpa only [phases, dite_eq_left hj] using (a ⟨j,hj⟩).isLt
  obtain ⟨j, L, N, hL, hj, per⟩ := good phases phasesBound x run
  apply not_adjacent (i+j)
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have left := (pair_bits (per (t-S) (by omega))).1
    unfold x at left
    rw [rowW_bit _ _ _ _ (by omega), rowW_bit _ _ _ _ (by omega),
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at left
    exact left
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have right := (pair_bits (per (t-S) (by omega))).2
    unfold x at right
    rw [rowW_bit _ _ _ _ hj, rowW_bit _ _ _ _ hj,
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at right
    simpa only [Int.natCast_add, Int.natCast_one, ← Int.add_assoc] using right

private theorem common_boundW {k : Nat} (f : Fin k → Nat) : ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0, fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B, upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

/-- `GoodAny` at every assignment of a width-`W` strip gives, in every `W` adjacent singleton columns, a column
with cofinal falls at two distinct residues modulo `m`. -/
theorem two_cofinal_from_goodAny {W m : Nat} (hW : 0 < W) (hm : 0 < m) (i : Int)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) :
    ∃ (j : Fin W) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin W) : ∃ r : Fin m, ∀ q, q ≠ r → ¬ Cofinal (i+j.val) q := by
    by_cases h : ∃ r : Fin m, Cofinal (i+j.val) r
    · obtain ⟨r, hr⟩ := h
      exact ⟨r, fun q neq hq => no ⟨j, r, q, Ne.symm neq, hr, hq⟩⟩
    · exact ⟨⟨0, hm⟩, fun q _ hq => h ⟨q, hq⟩⟩
  let phase (j : Fin W) := Classical.choose (single j)
  have cutoff (j : Fin W) (q : Fin m) :
      ∃ B, ∀ t, B ≤ t → t%m = q.val → Fall (i+j.val) t → q = phase j := by
    by_cases eq : q = phase j
    · exact ⟨0, fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T, fun t ht htq hit => (absent ⟨t, ht, htq, hit⟩).elim⟩
  let B (j : Fin W) (q : Fin m) := Classical.choose (cutoff j q)
  let C (j : Fin W) := Classical.choose (common_boundW (B j))
  obtain ⟨M, hm'⟩ := common_boundW C
  obtain ⟨j, t, late, hit, off⟩ := escapeW hW hm i phase good M
  let q : Fin m := ⟨t%m, Nat.mod_lt t hm⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_boundW (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm' j) late)) rfl hit
  exact off (congrArg Fin.val eq)

/-- **Modulus two.** Every 27 adjacent singleton Rule 30 columns contain a column whose black-to-white falls
start on even ticks and on odd ticks, each after every cutoff. -/
theorem two_parities_every_27 (i : Int) :
    ∃ (j : Fin 27) (r q : Fin 2), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=
  two_cofinal_from_goodAny (by decide) (by decide) i goodAny27

end Ruliology.CellularAutomata.Rule30FallParities
