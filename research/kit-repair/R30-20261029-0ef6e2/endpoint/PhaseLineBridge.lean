import RealBridge

/-! The exact real interpretation of the increment predicate used for a second line. -/

namespace RotationRealBridge

open Ruliology.CellularAutomata.Rule30RotationEndpoints

private theorem strict_floor_mul (α : ℝ) (ha : Irrational α) {n : ℕ} (hn : 0 < n) :
    (⌊(n : ℝ) * α⌋ : ℝ) < (n : ℝ) * α :=
  lt_of_le_of_ne (Int.floor_le _) ((ha.natCast_mul hn.ne').ne_int _).symm

/-- Every line whose increments are the rounded increments of an irrational slope is
either the lower or the upper mechanical line, including its value at zero. -/
theorem phaseLine_iff (α : ℝ) (ha : Irrational α) (f : ℕ → ℤ) :
    PhaseLine (fun n : ℕ => ⌊(n : ℝ) * α⌋) f ↔
      ∃ θ : ℝ, (∀ t : ℕ, f t = ⌊(t : ℝ) * α + θ⌋) ∨
                (∀ t : ℕ, f t = ⌈(t : ℝ) * α + θ⌉ - 1) := by
  constructor
  · intro hf
    let err (t : ℕ) : ℝ := (f t : ℝ) - (t : ℝ) * α
    have step (t n : ℕ) (hn : 0 < n) :
        err (t+n) < err t + 1 ∧ err t < err (t+n) + 1 := by
      obtain ⟨h₁, h₂⟩ := hf t n hn
      have lo : (f t : ℝ) + (⌊(n : ℝ) * α⌋ : ℝ) ≤ f (t+n) := by exact_mod_cast h₁
      have hi : (f (t+n) : ℝ) ≤ (f t : ℝ) + (⌊(n : ℝ) * α⌋ : ℝ) + 1 := by exact_mod_cast h₂
      have lower := strict_floor_mul α ha hn
      have upper := Int.lt_floor_add_one ((n : ℝ) * α)
      dsimp [err]
      push_cast
      constructor <;> linarith [add_mul (t : ℝ) n α]
    have diameter (s t : ℕ) : err s < err t + 1 := by
      rcases lt_trichotomy s t with h | rfl | h
      · simpa only [Nat.add_sub_of_le h.le] using (step s (t-s) (by omega)).2
      · linarith
      · simpa only [Nat.add_sub_of_le h.le] using (step t (s-t) (by omega)).1
    let θ := sSup (Set.range err)
    have sup_lo (t : ℕ) : err t ≤ θ := by
      apply le_csSup (s := Set.range err)
      · refine ⟨err 0 + 1, ?_⟩
        rintro _ ⟨n, rfl⟩
        exact (diameter n 0).le
      · exact ⟨t, rfl⟩
    have sup_hi (t : ℕ) : θ ≤ err t + 1 := by
      apply csSup_le (Set.range_nonempty err)
      rintro _ ⟨n, rfl⟩
      exact (diameter n t).le
    refine ⟨θ, ?_⟩
    by_cases boundary : ∃ s, θ = err s + 1
    · obtain ⟨s, hs⟩ := boundary
      right
      intro t
      have strict : err t < θ := hs ▸ diameter t s
      have hi := sup_hi t
      have ce : ⌈(t : ℝ) * α + θ⌉ = f t + 1 := by
        rw [Int.ceil_eq_iff]
        dsimp [err] at strict hi
        push_cast
        constructor <;> linarith
      omega
    · left
      intro t
      have strict := lt_of_le_of_ne (sup_hi t) (fun h => boundary ⟨t, h⟩)
      have lo := sup_lo t
      symm
      rw [Int.floor_eq_iff]
      dsimp [err] at strict lo
      constructor <;> linarith
  · rintro ⟨θ, h | h⟩
    · simpa only [funext h] using real_phase α θ
    · intro t n hn
      have base := real_phase (-α) (-θ) t n hn
      have fu (j : ℕ) : ⌊(j : ℝ) * (-α) + -θ⌋ = -(f j) - 1 := by
        rw [show (j : ℝ) * (-α) + -θ = -((j : ℝ) * α + θ) by ring, Int.floor_neg, h]
        omega
      have ce : ⌈(n : ℝ) * α⌉ = ⌊(n : ℝ) * α⌋ + 1 := by
        rw [Int.ceil_eq_iff]
        push_cast
        constructor
        · linarith [strict_floor_mul α ha hn]
        · exact (Int.lt_floor_add_one _).le
      dsimp only at base ⊢
      rw [fu t, fu (t+n)] at base
      simp only [mul_neg, Int.floor_neg, ce] at base
      omega

/-- At most one sample of a phase line can differ from its ordinary floor form. -/
theorem phaseLine_one_exception (α : ℝ) (ha : Irrational α) (f : ℕ → ℤ)
    (hf : PhaseLine (fun n : ℕ => ⌊(n : ℝ) * α⌋) f) :
    ∃ (θ : ℝ) (e : ℕ), ∀ t : ℕ, t ≠ e → f t = ⌊(t : ℝ) * α + θ⌋ := by
  obtain ⟨θ, lower | upper⟩ := (phaseLine_iff α ha f).mp hf
  · exact ⟨θ, 0, fun t _ => lower t⟩
  by_cases ex : ∃ e : ℕ, f e ≠ ⌊(e : ℝ) * α + θ⌋
  · obtain ⟨e, he⟩ := ex
    have cut (t : ℕ) (h : f t ≠ ⌊(t : ℝ) * α + θ⌋) :
        (t : ℝ) * α + θ = (⌊(t : ℝ) * α + θ⌋ : ℝ) := by
      let y := (t : ℝ) * α + θ
      have floor_le := Int.floor_le y
      have le_ceil := Int.le_ceil y
      have ceil_eq : ⌈y⌉ = ⌊y⌋ := by
        rw [upper] at h
        change ⌈y⌉ - 1 ≠ ⌊y⌋ at h
        have := Int.ceil_le_floor_add_one y
        have := Int.floor_le_ceil y
        omega
      exact le_antisymm (ceil_eq ▸ le_ceil) floor_le
    refine ⟨θ, e, fun t hte => ?_⟩
    by_contra ht
    have irr := ha.intCast_mul (m := (t : ℤ) - e) (by omega : (t : ℤ) - e ≠ 0)
    apply irr.ne_int (⌊(t : ℝ) * α + θ⌋ - ⌊(e : ℝ) * α + θ⌋)
    push_cast
    rw [sub_mul]
    linarith [cut t ht, cut e he]
  · exact ⟨θ, 0, fun t _ => Classical.byContradiction (fun h => ex ⟨t, h⟩)⟩

end RotationRealBridge
