import ImmortalThreshold
import Ruliology.CellularAutomata.Rule30AgeTwentyFourInverse

namespace PhaseTwo.HistoryFibre

open Ruliology.CellularAutomata Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm
open Rule30Submission

/-- A splice of depth h at target age t preserves a common H-tick image
    with the reference, at the new width offset s+(t-h). -/
theorem splice {H s h t a b y : Nat} (hH : h ≤ H) (ht : h ≤ t)
    (common : iter F H a = iter F (s+H) y) (branch : iter F h b = iter F t a) :
    iter F H b = iter F (s+(t-h)+H) y := by
  calc
    iter F H b = iter F (H-h) (iter F h b) := by
      rw [← iter_add F h (H-h) b, show h + (H-h) = H by omega]
    _ = iter F (H-h) (iter F t a) := by rw [branch]
    _ = iter F (t-h) (iter F H a) := by
      rw [← iter_add F t (H-h) a, ← iter_add F H (t-h) a,
          show t + (H-h) = H + (t-h) by omega]
    _ = iter F (s+(t-h)+H) y := by
      rw [common, ← iter_add F (s+H) (t-h) y,
          show s + H + (t-h) = s + (t-h) + H by omega]

private theorem one_back {a b : Nat} (image : F a = F b)
    (wall : a.testBit 0 = b.testBit 0) : a = b := by
  have same := Rule30AgeTwentyFourInverse.predecessor_unique_of_bit1
    (X := rowOfNat a) (X' := rowOfNat b) (y := rowOfNat (F b))
    (fun j _ => by rw [zrow_rowOfNat_one, image])
    (fun j _ => zrow_rowOfNat_one b j) wall
  exact Nat.eq_of_testBit_eq fun j => same (j+1) (by omega)

/-- The endpoint plus the first h wall-neighbour readings determine the entire start. -/
theorem history_unique {a b h : Nat} (image : iter F h a = iter F h b)
    (bits : ∀ j < h, (iter F j a).testBit 0 = (iter F j b).testBit 0) : a = b := by
  induction h with
  | zero => exact image
  | succ h ih => exact ih (one_back image (bits h (by omega))) (fun j hj => bits j (by omega))

/-- Encode exactly the readings at odd ticks below 2m. -/
def oddCode (a : Nat) : Nat → Nat
  | 0 => 0
  | m+1 => 2 * oddCode a m + ((iter F (2*m+1) a).testBit 0).toNat

theorem oddCode_lt (a m : Nat) : oddCode a m < 2^m := by
  induction m with
  | zero => simp [oddCode]
  | succ m ih =>
    simp only [oddCode, Nat.pow_succ]
    cases (iter F (2*m+1) a).testBit 0 <;> simp <;> omega

private theorem code_bits {a b m : Nat} (eq : oddCode a m = oddCode b m) :
    ∀ j < m, (iter F (2*j+1) a).testBit 0 = (iter F (2*j+1) b).testBit 0 := by
  induction m with
  | zero => omega
  | succ m ih =>
    simp only [oddCode] at eq
    have parts : (iter F (2*m+1) a).testBit 0 = (iter F (2*m+1) b).testBit 0 ∧
        oddCode a m = oddCode b m := by
      cases ha : (iter F (2*m+1) a).testBit 0 <;>
        cases hb : (iter F (2*m+1) b).testBit 0 <;>
        simp_all <;> omega
    intro j hj
    rcases Nat.eq_or_lt_of_le (Nat.le_of_lt_succ hj) with rfl | lt
    · exact parts.1
    · exact ih parts.2 j lt

/-- In one H-tick fibre, starts passing all the even checks before H
    inject into the integers below 2^(H/2), via their odd wall readings. -/
theorem eq_of_oddCode {a b H : Nat} (image : iter F H a = iter F H b)
    (ha : ∀ j, 2*j < H → (iter F (2*j) a).testBit 0 = true)
    (hb : ∀ j, 2*j < H → (iter F (2*j) b).testBit 0 = true)
    (eq : oddCode a (H/2) = oddCode b (H/2)) : a = b := by
  apply history_unique image
  intro t ht
  by_cases even : t % 2 = 0
  · have e : t = 2*(t/2) := by omega
    exact e ▸ (ha (t/2) (by omega)).trans (hb (t/2) (by omega)).symm
  · have e : t = 2*(t/2) + 1 := by omega
    exact e ▸ (code_bits eq (t/2) (by omega))

/-- Recover the shared endpoint deliberately omitted from the published
    multiplicity headline. The 4096 witnesses fill one 24-tick fibre. -/
theorem filled_24 {y q : Nat} (imm : InX (rowOfNat y)) (late : 389 ≤ 2*q) :
    ∃ f : Fin 4096 → Nat, (∀ ⦃i j⦄, f i = f j → i = j) ∧
      ∀ i, iter F 24 (f i) = iter F (2*q+24) y ∧
        Top (f i) (y.log2+2*q) ∧ InX (rowOfNat (f i)) := by
  have odd := (inX_iff_odd y).mp imm
  have histories := histories_gap (m := 12) (by decide) (by decide)
  have existsRow (i : Fin 4096) := histories y (2*q+24)
    (nonzero_of_odd_orbit odd) (by change 389+24 ≤ 2*q+24; omega) (freeBits 12 i)
  let f (i : Fin 4096) := Classical.choose (existsRow i)
  have spec (i : Fin 4096) := Classical.choose_spec (existsRow i)
  refine ⟨f, ?_, ?_⟩
  · intro i j eq
    apply freeBits_injective (m := 12)
    intro tick
    exact ((spec i).2.2 tick).symm.trans
      ((congrArg (fun a => rowOfNat (iter F tick.val a) 1) eq).trans ((spec j).2.2 tick))
  · intro i
    refine ⟨(spec i).1, ?_, (inX_iff_odd _).mpr ?_⟩
    · simpa [show y.log2 + (2*q+24) - 2*12 = y.log2+2*q by omega] using (spec i).2.1
    · apply odd_ancestor (k := 12) (t := q+12) odd
      · simpa [Nat.mul_add] using (spec i).1
      · intro s hs
        simpa [f, freeBits, rowOfNat] using (spec i).2.2 ⟨2*s, by omega⟩

end PhaseTwo.HistoryFibre
