import ModulusStrip

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30Jen

/-- Skip slot d in every round, keeping the row at the end of the idle update. -/
def insertSlot (d k : Nat) : Nat := if k < d then k else k+1

def deleteSlot (d k : Nat) : Nat := if k ≤ d then k else k-1

def expandTime (m d t : Nat) : Nat := (t/(m-1))*m + insertSlot d (t%(m-1))

def contractTime (m d t : Nat) : Nat := (t/m)*(m-1) + deleteSlot d (t%m)

theorem insert_bound {m d k : Nat} (hk : k < m-1) : insertSlot d k < m := by
  unfold insertSlot
  split <;> omega

private theorem not_insert {d k : Nat} : insertSlot d k ≠ d := by
  unfold insertSlot
  split <;> omega

theorem delete_bound {m d k : Nat} (hk : k < m) (hd : d+2 < m) :
    deleteSlot d k < m-1 := by
  unfold deleteSlot
  split <;> omega

private theorem phase_equiv {r k d : Nat} (hr : r ≠ d) :
    deleteSlot d r = k ↔ r = insertSlot d k := by
  unfold deleteSlot insertSlot
  split <;> split <;> omega

private theorem expand_phase {m d t : Nat} (hm : 1 < m) :
    expandTime m d t % m = insertSlot d (t%(m-1)) := by
  unfold expandTime
  rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt]
  exact insert_bound (Nat.mod_lt _ (by omega))

private theorem divMod_succ {t p : Nat} (hp : 0 < p) :
    (t+1)/p = (t%p+1)/p + t/p ∧ (t+1)%p = (t%p+1)%p := by
  have q : t+1 = t%p+1+p*(t/p) := by have := Nat.mod_add_div t p; omega
  conv => lhs; rw [q, Nat.add_mul_div_left _ _ hp]
  exact ⟨rfl, by conv => lhs; rw [q, Nat.add_mul_mod_self_left]⟩

private theorem expand_succ {m d t : Nat} (hd : 0 < d) (hb : d+2 < m) :
    expandTime m d (t+1) = expandTime m d t + (if t%(m-1)+1=d then 2 else 1) := by
  have hp : 0 < m-1 := by omega
  have hr := Nat.mod_lt t hp
  obtain ⟨dvd,mod⟩ := divMod_succ (t:=t) hp
  unfold expandTime
  rw [dvd,mod]
  by_cases c : t%(m-1)+1 < m-1
  · rw [Nat.div_eq_of_lt c, Nat.mod_eq_of_lt c, Nat.zero_add]
    unfold insertSlot
    split <;> split <;> split <;> omega
  · have e : t%(m-1)+1=m-1 := by omega
    rw [e, Nat.div_self hp, Nat.mod_self, ite_eq_right (show m-1≠d by omega)]
    simp only [insertSlot, ite_eq_left hd, ite_eq_right (show ¬ t%(m-1)<d by omega),
      Nat.add_zero, Nat.add_mul, Nat.one_mul]
    omega

private theorem expand_contract {m d t : Nat} (hb : d+2 < m) :
    expandTime m d (contractTime m d t) = t + (if t%m=d then 1 else 0) := by
  have hp : 0 < m-1 := by omega
  have hr := Nat.mod_lt t (show 0 < m by omega)
  have hsmall := delete_bound hr hb
  have div : contractTime m d t / (m-1) = t/m := by
    unfold contractTime
    rw [Nat.add_comm, Nat.mul_comm (t/m) (m-1), Nat.add_mul_div_left _ _ hp,
      Nat.div_eq_of_lt hsmall, Nat.zero_add]
  have mod : contractTime m d t % (m-1) = deleteSlot d (t%m) := by
    unfold contractTime
    rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hsmall]
  unfold expandTime
  rw [div,mod]
  have decom := Nat.div_add_mod t m
  rw [Nat.mul_comm (t/m) m]
  unfold insertSlot deleteSlot
  split <;> split <;> split <;> omega

private theorem quiet_idle {m d t : Nat} {a x : Nat → Nat} (h : Run 6 m a x)
    (hb : d+2 < m) (ht : t%m=d)
    (quiet : ∀ j, j < 6 → a j < d ∨ d+2 < a j) : x (t+1) = x t := by
  have zero (i : Nat) (hi : i ≤ 2) : permit 6 a ((t+i)%m) = 0 := by
    rw [Nat.add_mod t i m, ht, Nat.mod_eq_of_lt (show i < m by omega),
      Nat.mod_eq_of_lt (show d+i<m by omega)]
    apply Nat.eq_of_testBit_eq
    intro j
    rw [permit_bit, Nat.zero_testBit]
    by_cases hj : j < 6
    · have := quiet j hj
      simp [show a j ≠ d+i by omega]
    · simp [hj]
  have h0 := h.edge t
  have h1 := h.edge (t+1)
  have h2 := h.edge (t+2)
  rw [show permit 6 a (t%m) = 0 by simpa using zero 0 (by decide)] at h0
  rw [zero 1 (by decide)] at h1
  rw [zero 2 (by decide)] at h2
  exact quiet_eq (h.bounded t) h0 h1 h2

/-- A gap of three quiet ticks can be shortened by a uniform deletion in each
period. A paired reading in the shorter calendar lifts to the original one. -/
theorem good_of_deleted {m d : Nat} {a : Nat → Nat} (hd : 0 < d) (hb : d+2 < m)
    (quiet : ∀ j, j < 6 → a j < d ∨ d+2 < a j)
    (good : Good 6 (m-1) (fun j => deleteSlot d (a j))) : Good 6 m a := by
  intro x h
  let y (t : Nat) := x (expandTime m d t)
  have hy : Run 6 (m-1) (fun j => deleteSlot d (a j)) y := by
    refine ⟨fun t => h.bounded _, fun t => ?_⟩
    have edge := h.edge (expandTime m d t)
    rw [expand_phase (show 1<m by omega)] at edge
    have same : permit 6 (fun j => deleteSlot d (a j)) (t%(m-1)) =
        permit 6 a (insertSlot d (t%(m-1))) := by
      apply Nat.eq_of_testBit_eq
      intro j
      rw [permit_bit, permit_bit]
      by_cases hj : j < 6
      · have hn := quiet j hj
        simp only [hj, true_and]
        rw [Bool.eq_iff_iff, decide_eq_true_eq, decide_eq_true_eq]
        exact phase_equiv (by omega)
      · simp [hj]
    rw [same]
    change Edge 6 _ (x (expandTime m d t)) (x (expandTime m d (t+1)))
    rw [expand_succ hd hb]
    by_cases cut : t%(m-1)+1=d
    · rw [ite_eq_left cut]
      have atCut : (expandTime m d t + 1)%m = d := by
        rw [Nat.add_mod, expand_phase (show 1<m by omega), Nat.mod_eq_of_lt (show 1<m by omega)]
        simp only [insertSlot, ite_eq_left (show t%(m-1)<d by omega)]
        exact (congrArg (fun r => r % m) cut).trans (Nat.mod_eq_of_lt (by omega))
      have eq := quiet_idle h hb atCut quiet
      rwa [show expandTime m d t + 2 = expandTime m d t + 1 + 1 by omega, eq]
    · rwa [ite_eq_right cut]
  obtain ⟨j,N,hj,per⟩ := good y hy
  refine ⟨j,N*m,hj,fun t ht => ?_⟩
  have reads (s : Nat) : y (contractTime m d s) = x s := by
    unfold y
    rw [expand_contract hb]
    by_cases atCut : s%m=d
    · simpa only [ite_eq_left atCut] using quiet_idle h hb atCut quiet
    · rw [ite_eq_right atCut, Nat.add_zero]
  have repr : contractTime m d (t+m) = contractTime m d t+(m-1) := by
    unfold contractTime
    rw [Nat.add_div_right _ (show 0<m by omega), Nat.add_mod_right, Nat.add_mul, Nat.one_mul]
    omega
  have age : N ≤ contractTime m d t := by
    have hdiv := (Nat.le_div_iff_mul_le (show 0<m by omega)).mpr ht
    have hmul : t/m ≤ (t/m)*(m-1) := by
      simpa using (Nat.mul_le_mul_left (t/m) (show 1 ≤ m-1 by omega))
    unfold contractTime
    omega
  simpa only [← repr, reads] using per (contractTime m d t) age

private theorem quiet_gap {m : Nat} (hm : 18 < m) {a : Nat → Nat} (zero : a 0 = 0) :
    ∃ d, 0 < d ∧ d+2 < m ∧ ∀ j, j < 6 → a j < d ∨ d+2 < a j := by
  apply Classical.byContradiction
  intro nh
  let hit := (List.range 6).map (fun j => (a j+2)/3)
  have covered : ∀ k ∈ List.range 7, k ∈ hit := by
    intro k hk
    have hk := List.mem_range.mp hk
    by_cases z : k=0
    · exact List.mem_map.mpr ⟨0,List.mem_range.mpr (by decide),by omega⟩
    · let d := 3*k-2
      have member : ∃ j, j < 6 ∧ d ≤ a j ∧ a j ≤ d+2 := by
        apply Classical.byContradiction
        intro absent
        exact nh ⟨d,by dsimp [d]; omega,by dsimp [d]; omega,fun j hj => by
          by_cases lo : a j < d
          · exact Or.inl lo
          · exact Or.inr (by
              apply Classical.byContradiction
              intro hi
              exact absent ⟨j,hj,by omega,by omega⟩)⟩
      obtain ⟨j,hj,lo,hi⟩ := member
      exact List.mem_map.mpr ⟨j,List.mem_range.mpr hj,by dsimp [d] at lo hi; omega⟩
  have bad := length_le_of_subset (List.nodup_range (n:=7)) covered
  simp [hit] at bad

/-- The six-site problem at every modulus reduces to moduli 3 through 18. -/
theorem good_of_small {m : Nat} {a : Nat → Nat} (hm : 3 ≤ m)
    (ha : ∀ j, j < 6 → a j < m)
    (small : ∀ m, 3 ≤ m → m ≤ 18 → ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) :
    Good 6 m a := by
  induction m using Nat.strongRecOn generalizing a with
  | ind m ih =>
    by_cases short : m ≤ 18
    · exact small m hm short a ha
    · apply good_of_rotated (q:=a 0) (ha 0 (by decide)) ha
      let b (j : Nat) := rotate m (a 0) (a j)
      change Good 6 m b
      have b0 : b 0 = 0 := by simp [b,rotate]
      obtain ⟨d,hd,hb,quiet⟩ := quiet_gap (by omega : 18 < m) b0
      apply good_of_deleted hd hb quiet
      exact ih (m-1) (by omega) (by omega) (fun j hj =>
        delete_bound (rotate_lt (ha 0 (by decide)) (ha j hj)) hb)

end PhaseFalls.Moduli
