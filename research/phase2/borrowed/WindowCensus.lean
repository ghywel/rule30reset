-- Build the published R30-20261126-e2e0e2 source as ImmortalThreshold.lean.
import ImmortalThreshold

namespace PhaseTwo.Census

open Rule30Submission
open Ruliology.CellularAutomata.Rule30ZeroBoundary
open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm

/-- All starts below 2^B passing the first k even-time wall checks. -/
def survivors (B k : Nat) : List Nat :=
  (List.range (2 ^ B)).filter fun y =>
    (List.range k).all fun s => zrow (rowOfNat y) (2*s) 1

/-- A single immortal start supplies 4096 disjoint witnesses per pair of
    sufficiently large widths, simultaneously at every observation horizon. -/
theorem lower_of_immortal {y : Nat} (hy : InX (rowOfNat y)) (B k : Nat) :
    4096 * ((B - (y.log2 + 391)) / 2) ≤ (survivors B k).length := by
  let base := y.log2 + 391
  let n := (B - base) / 2
  have atWidth (q : Nat) := immortal_rows_4096 hy (base + 2*q)
    (by dsimp [base]; omega) (by dsimp [base]; omega)
  let row (q : Nat) := Classical.choose (atWidth q)
  have spec (q : Nat) := Classical.choose_spec (atWidth q)
  let witness (i : Fin (4096*n)) := row (i.val / 4096) ⟨i.val % 4096, Nat.mod_lt _ (by decide)⟩
  have top (i : Fin (4096*n)) :
      Top (witness i) (base + 2*(i.val/4096) - 1) :=
    ((spec _).2 _).1
  have inj {i j : Fin (4096*n)} (eq : witness i = witness j) : i = j := by
    have left := top i
    rw [eq] at left
    have width := Top_unique left (top j)
    have hbase : 0 < base := by dsimp [base]; omega
    have same : i.val / 4096 = j.val / 4096 := by omega
    change row (i.val / 4096) _ = row (j.val / 4096) _ at eq
    rw [same] at eq
    have rem := congrArg Fin.val ((spec _).1 eq)
    exact Fin.ext (by dsimp at rem; omega)
  have subset : (List.finRange (4096*n)).map witness ⊆ survivors B k := by
    intro z hz
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp hz
    have hi := i.isLt
    have small : i.val / 4096 < n := by omega
    have width : base + 2*(i.val/4096) ≤ B := by dsimp [n] at small; omega
    have htop := top i
    have nz : witness i ≠ 0 := by
      intro h
      have bit := htop.1
      simp [h] at bit
    have hlog := Top_unique (top_log2 nz) htop
    have below : witness i < 2 ^ B := Nat.lt_of_lt_of_le Nat.lt_log2_self
      (Nat.pow_le_pow_right (by decide : 0 < 2) (by dsimp [base] at *; omega))
    have alive : InX (rowOfNat (witness i)) := ((spec _).2 _).2
    simp [survivors, below]
    exact fun s _ => alive s
  have nodup : ((List.finRange (4096*n)).map witness).Nodup :=
    (List.nodup_finRange (4096*n)).map witness (fun _ _ ne eq => ne (inj eq))
  simpa [n, base] using nodup.length_le_of_subset subset

/-- A cumulative census needs no separately specified odd and even widths.
    Arbitrarily large deficits below the slope 2048 force Q01. -/
theorem q01_of_unbounded_deficit
    (h : ∀ d : Nat, ∃ B k : Nat, (survivors B k).length + d < 2048 * B) : Q01 := by
  apply Classical.byContradiction
  intro bad
  obtain ⟨y, hy, _⟩ := many_immortal_rows_small bad
  obtain ⟨B, k, sparse⟩ := h (2048 * (y.log2 + 392))
  have dense := lower_of_immortal hy B k
  omega

/-- The forward direction uses the kit's uniform death at each support bound. -/
theorem q01_iff_unbounded_deficit :
    Q01 ↔ ∀ d : Nat, ∃ B k : Nat, (survivors B k).length + d < 2048 * B := by
  refine ⟨?_, q01_of_unbounded_deficit⟩
  intro hq d
  let B := d + 1
  obtain ⟨D, dies⟩ := uniform_death hq B
  have empty : survivors B (D + 1) = [] := by
    apply List.eq_nil_iff_forall_not_mem.mpr
    intro y hy
    simp [survivors] at hy
    have supported (j : Nat) (large : B < j) : rowOfNat y j = false := by
      cases j with
      | zero => omega
      | succ i => exact Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le hy.1
          (Nat.pow_le_pow_right (by decide : 0 < 2) (by omega : B ≤ i)))
    obtain ⟨s, hs, hwhite⟩ := dies (rowOfNat y) supported
    have hblack := hy.2 s (by omega)
    simp [hwhite] at hblack
  refine ⟨B, D+1, ?_⟩
  simp [empty, B]
  omega

end PhaseTwo.Census
