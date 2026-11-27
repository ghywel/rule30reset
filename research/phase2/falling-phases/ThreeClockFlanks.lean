import Ruliology.CellularAutomata.Rule30EtherThreeSkeleton

/-! The two hypothetical period-three centre clocks already force two cofinal
falling phases on a particular western column. All phases here are relative to
the first tick `T` of the stated clock. -/

namespace PhaseFalls.ThreeClock

open Ruliology.CellularAutomata Rule30Jen Rule30EtherThree

def CofinalFall (T : Nat) (j : Int) (r : Nat) : Prop :=
  ∀ N, ∃ t, N ≤ t ∧ T ≤ t ∧ (t - T) % 3 = r ∧
    cell t j = true ∧ cell (t + 1) j = false

private theorem clock_periodic {w : List Bool} {T : Nat}
    (h : ∀ t, T ≤ t → cell t 0 = wordAt3 w (t - T)) :
    EventuallyPeriodic (fun t => cell t 0) := by
  refine ⟨T, 3, by decide, fun t ht => ?_⟩
  change cell (t+3) 0 = cell t 0
  rw [h _ (by omega), h _ ht]
  unfold wordAt3
  rw [show (t + 3 - T) % 3 = (t - T) % 3 by omega]

/-- A flank with phase triple `(b, g b, 1)` cannot settle the free bit
while its distinct centre column is periodic: it would itself have period 3. -/
private theorem flank_phases (T K : Nat) (j : Int) (hj : j ≠ 0)
    (g : Bool → Bool) (hg : g true = false)
    (hp : EventuallyPeriodic (fun t => cell t 0))
    (h : ∀ k, K ≤ k →
      cell (T + 3 * k + 1) j = g (cell (T + 3 * k) j) ∧
      cell (T + 3 * k + 2) j = true) (r : Nat) :
    CofinalFall T j r ↔ r = 0 ∨ r = 2 := by
  have both (c : Bool) (N : Nat) : ∃ k, N ≤ k ∧ cell (T + 3*k) j = c := by
    apply Classical.byContradiction
    intro hn
    have fixed (k : Nat) (hk : N ≤ k) : cell (T + 3*k) j = !c := by
      have ne : cell (T + 3*k) j ≠ c := fun e => hn ⟨k, hk, e⟩
      revert ne
      cases c <;> cases cell (T + 3*k) j <;> decide
    apply jen j 0 hj ⟨?_, hp⟩
    refine ⟨T + 3*(K+N), 3, by decide, fun t ht => ?_⟩
    change cell (t+3) j = cell t j
    let k := (t-T) / 3
    have hK : K ≤ k := by dsimp [k]; omega
    have hN : N ≤ k := by dsimp [k]; omega
    have d : t = T+3*k ∨ t = T+3*k+1 ∨ t = T+3*k+2 := by dsimp [k]; omega
    rcases d with d | d | d
    · rw [show t+3 = T+3*(k+1) by omega, d, fixed _ (by omega), fixed _ hN]
    · rw [show t+3 = T+3*(k+1)+1 by omega, d, (h _ (by omega)).1,
          (h k hK).1, fixed _ (by omega), fixed _ hN]
    · rw [show t+3 = T+3*(k+1)+2 by omega, d, (h _ (by omega)).2, (h k hK).2]
  constructor
  · intro hr
    obtain ⟨t, ht, _, hφ, _, hfalse⟩ := hr (T+3*K)
    apply Classical.byContradiction
    intro hn
    have e : t+1 = T+3*((t-T)/3)+2 := by omega
    rw [e, (h _ (by omega)).2] at hfalse
    contradiction
  · rintro (rfl | rfl) N
    · obtain ⟨k, hk, hb⟩ := both true (N+K)
      exact ⟨T+3*k, by omega, by omega, by omega, hb, by rw [(h k (by omega)).1, hb, hg]⟩
    · obtain ⟨k, hk, hb⟩ := both false (N+K+1)
      refine ⟨T+3*(k-1)+2, by omega, by omega, by omega, (h _ (by omega)).2, ?_⟩
      rwa [show T+3*(k-1)+2+1 = T+3*k by omega]

/-- Under a `011` centre the cofinal fall phases in column −1 are exactly 0 and 2. -/
theorem flank_011 (T : Nat) (h : ∀ t, T ≤ t → cell t 0 = wordAt3 w011 (t - T))
    (r : Nat) : CofinalFall T (-1) r ↔ r = 0 ∨ r = 2 := by
  apply flank_phases T 0 (-1) (by decide) (fun _ => false) rfl (clock_periodic h) _ r
  intro k _
  exact ⟨(col_m1_011 T h _ (by omega)).2.1 (by omega),
         (col_m1_011 T h _ (by omega)).2.2 (by omega)⟩

/-- Under a `001` centre the cofinal fall phases in column −2 are exactly 0 and 2. -/
theorem flank_001 (T : Nat) (h : ∀ t, T ≤ t → cell t 0 = wordAt3 w001 (t - T))
    (r : Nat) : CofinalFall T (-2) r ↔ r = 0 ∨ r = 2 := by
  obtain ⟨B, _, hs⟩ := col_m1_001_skeleton T h
  apply flank_phases T B (-2) (by decide) Bool.not rfl (clock_periodic h) _ r
  intro k hk
  let t := T + 3*k
  have h0 : cell t (-1) = false := (hs _ (by dsimp [t]; omega)).1 (by dsimp [t]; omega)
  have h2 : cell (t+2) (-1) = true :=
    (hs _ (by dsimp [t]; omega)).2.2 (by dsimp [t]; omega)
  have h3 : cell (t+3) (-1) = false := (hs _ (by dsimp [t]; omega)).1 (by dsimp [t]; omega)
  have hc (d : Nat) (hd : d < 2) : cell (t+d) 0 = false := by
    rw [h _ (by dsimp [t]; omega), wordAt3_001]
    simp [show (t+d-T) % 3 ≠ 2 by dsimp [t]; omega]
  have s0 := cell_left t (-1)
  have s1 := cell_left (t+1) (-1)
  have s2 := cell_left (t+2) (-1)
  change cell t (-2) = xor _ (cell t (-1) || cell t 0) at s0
  change cell (t+1) (-2) = xor (cell (t+2) (-1)) (cell (t+1) (-1) || cell (t+1) 0) at s1
  change cell (t+2) (-2) = xor (cell (t+3) (-1)) (cell (t+2) (-1) || cell (t+2) 0) at s2
  have hc0 : cell t 0 = false := hc 0 (by decide)
  rw [h0, hc0] at s0
  rw [h2, hc 1 (by decide)] at s1
  rw [h3, h2] at s2
  change cell (t+1) (-2) = !(cell t (-2)) ∧ cell (t+2) (-2) = true
  rw [s0, s1, s2]
  cases cell (t+1) (-1) <;> exact ⟨rfl, rfl⟩

end PhaseFalls.ThreeClock
