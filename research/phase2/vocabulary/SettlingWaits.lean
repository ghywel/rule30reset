import Ruliology.CellularAutomata.Rule30FourFronts

namespace PhaseTwo.SettlingWaits

open Ruliology.CellularAutomata Rule30FourFrontsBase Rule30FourFronts Rule30FourLeftSides
open Rule30UniversalLeftSide (rowAt)

/-- A positive increment ends just after the first black reading. A skipped wheel costs zero. -/
def Hit (a : Nat → Bool) (t k : Nat) : Prop :=
  k = 0 ∨ (a (t+k-1) = true ∧ ∀ i, t ≤ i → i < t+k-1 → a i = false)

/-- In any three consecutive wheels, periodic waits cost at most two periods plus one tick.
The only local rule used is that 000 cannot produce a black cell. -/
theorem triple_wait {P t a b c : Nat} {A B C : Nat → Bool}
    (pb : ∀ i, B (i+P) = B i) (pc : ∀ i, C (i+P) = C i)
    (birth : ∀ i, A i = false → B i = false → C i = false → C (i+1) = false)
    (ha : Hit A t a) (hb : Hit B (t+a) b) (hc : Hit C (t+a+b) c)
    (la : a ≤ P) (lb : b ≤ P) (lc : c ≤ P) : a+b+c ≤ 2*P+1 := by
  apply Nat.le_of_not_gt
  intro big
  rcases ha with z | ⟨_, wa⟩
  · omega
  rcases hb with z | ⟨_, wb⟩
  · omega
  rcases hc with z | ⟨black, wc⟩
  · omega
  let i := t+a+b+c-2-2*P
  have index : i+1+P+P = t+a+b+c-1 := by dsimp [i]; omega
  have ah := wa i (by dsimp [i]; omega) (by dsimp [i]; omega)
  have bh := wb (i+P) (by dsimp [i]; omega) (by dsimp [i]; omega)
  have ch := wc (i+P+P) (by dsimp [i]; omega) (by dsimp [i]; omega)
  rw [pb] at bh
  rw [pc, pc] at ch
  rw [← index, pc, pc, birth i ah bh ch] at black
  contradiction

private theorem srch_before (w t : Nat) : ∀ fuel, fuel ≤ 16 → ∀ k,
    16-fuel ≤ k → k < srch w t fuel → w.testBit ((t+k)%16) = false := by
  intro fuel
  induction fuel with
  | zero => intro _ k lo hi; simp [srch] at hi; omega
  | succ f ih =>
    intro hf k lo hi
    simp only [srch] at hi
    split at hi
    · omega
    · rename_i h
      by_cases he : k=16-(f+1)
      · subst k; simpa using h
      · exact ih (by omega) k (by omega) hi

def reading (w : Nat → Nat) (j t : Nat) : Bool := (w j).testBit (t%16)

theorem forced_hit {w : Nat → Nat} (hw : ∀ j, w j < 2^16) (j : Nat) :
    Hit (reading w (j+1)) (F w (j+1)) (F w (j+2)-F w (j+1)) := by
  by_cases h : w (j+1) = 0
  · exact Or.inl (by rw [F_white_simp w j h]; omega)
  · apply Or.inr
    rw [F_black_simp w j h]
    let t := F w (j+1)
    let r := srch (w (j+1)) t 16
    change reading w (j+1) (t + (t+r+1-t)-1) = true ∧ _
    have idx : t+(t+r+1-t)-1=t+r := by omega
    constructor
    · rw [idx]
      exact srch_black _ _ (bit_of_ne (hw _) h)
    · intro i lo hi
      change t ≤ i at lo
      change i < t+(t+r+1-t)-1 at hi
      have e := srch_before (w (j+1)) t 16 (by decide) (i-t) (by omega) (by change i-t<r; omega)
      simpa [reading, show t+(i-t)=i by omega] using e

/-- A genuinely recurrent 16-phase prefix has the required zero-neighborhood rule. -/
def CompatibleThrough (w : Nat → Nat) (J : Nat) : Prop :=
  ∀ j, j+2 ≤ J → ∀ t, reading w j t = false → reading w (j+1) t = false →
    reading w (j+2) t = false → reading w (j+2) (t+1) = false

theorem forced_three {w : Nat → Nat} (hw : ∀ j, w j < 2^16) {j J : Nat}
    (compat : CompatibleThrough w J) (h : j+3 ≤ J) :
    F w (j+4) ≤ F w (j+1)+33 := by
  let a := F w (j+2)-F w (j+1)
  let b := F w (j+3)-F w (j+2)
  let c := F w (j+4)-F w (j+3)
  have m1 := F_step_le w j
  have m2 : F w (j+2) ≤ F w (j+3) := F_step_le w (j+1)
  have m3 : F w (j+3) ≤ F w (j+4) := F_step_le w (j+2)
  have i1 : F w (j+1)+a = F w (j+2) := by dsimp [a]; omega
  have i2 : F w (j+1)+a+b = F w (j+3) := by dsimp [a,b]; omega
  have per (i t : Nat) : reading w i (t+16) = reading w i t := by simp [reading]
  have cost := triple_wait (t := F w (j+1)) (a := a) (b := b) (c := c)
    (per (j+2)) (per (j+3)) (compat (j+1) h)
    (forced_hit hw j) (i1 ▸ forced_hit hw (j+1)) (i2 ▸ forced_hit hw (j+2))
    (by have := F_step_diff_le_sixteen hw j; dsimp [a]; omega)
    (by have : F w (j+3) ≤ F w (j+2)+16 := F_step_diff_le_sixteen hw (j+1); dsimp [b]; omega)
    (by have : F w (j+4) ≤ F w (j+3)+16 := F_step_diff_le_sixteen hw (j+2); dsimp [c]; omega)
  dsimp [a,b,c] at cost
  omega

theorem forced_linear {w : Nat → Nat} (hw : ∀ j, w j < 2^16) {J : Nat}
    (compat : CompatibleThrough w J) (j : Nat) (bound : j ≤ J+1) : F w j ≤ 11*j := by
  induction j using Nat.strongRecOn with
  | ind j ih =>
    match j with
    | 0 => rw [F_zero]; omega
    | 1 => rw [F_one]; omega
    | 2 =>
      have : F w 2 ≤ F w 1 + 16 := F_step_diff_le_sixteen hw 0
      have := F_one w
      omega
    | 3 =>
      have : F w 2 ≤ F w 1 + 16 := F_step_diff_le_sixteen hw 0
      have : F w 3 ≤ F w 2 + 16 := F_step_diff_le_sixteen hw 1
      have := F_one w
      omega
    | k+4 =>
      have := ih (k+1) (by omega) (by omega)
      have := forced_three hw compat (j := k) (by omega)
      omega

theorem strip_compatible {v : Nat} (ret : rowAt 87867 v 16 = v) :
    CompatibleThrough (wd v) 87866 := by
  have e (j t : Nat) : reading (wd v) j t = Sp v j t := by
    unfold reading
    rw [wd_row _ _ _ (by omega), Sp_mod ret j t]
    rfl
  intro j hj t h0 h1 h2
  rw [e, Sp_rec _ _ _ (by omega), ← e j t, ← e (j+1) t, ← e (j+2) t, h0, h1, h2]
  rfl

theorem physical_forced_bound {v : Nat} (ret : rowAt 87867 v 16 = v) {j : Nat} (hj : j ≤ 87866) :
    F (wd v) j ≤ 11*j := forced_linear (wd_lt v) (strip_compatible ret) j (by omega)

end PhaseTwo.SettlingWaits
