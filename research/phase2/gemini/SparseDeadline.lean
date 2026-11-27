import Ruliology.CellularAutomata.Rule30ZeroBoundary

namespace PhaseTwo.SparseDeadline
open Ruliology.CellularAutomata.Rule30ZeroBoundary IntegerForm

/-- Increasing zero-based positions of the as yet unspecified black cells. -/
def Ordered : Nat → List Nat → Prop
  | _, [] => True
  | lo, j :: js => lo ≤ j ∧ Ordered (j+1) js

def pack (y : Nat) : List Nat → Nat
  | [] => y
  | j :: js => pack (y ||| 2^j) js

private theorem untouched {js : List Nat} {lo i : Nat} (ord : Ordered lo js) (hi : i < lo)
    (y : Nat) : (pack y js).testBit i = y.testBit i := by
  induction js generalizing lo y with
  | nil => rfl
  | cons j js ih =>
    obtain ⟨hj, rest⟩ := ord
    rw [pack, ih rest (by omega), Nat.testBit_or, Nat.testBit_two_pow]
    simp [show j ≠ i by omega]

def fails (y k : Nat) : Bool := !(iter F (2*k) y).testBit 0

/-- The horizon H counts even observations past tick zero. Each child
    spends one black cell. A discovered failure at tick 2k restricts the
    range of possible repairs without imposing a support-width bound. -/
def check (H : Nat) : Nat → Nat → Nat → Bool
  | 0, _, y => (List.range (H+1)).any (fails y)
  | b+1, lo, y =>
    match (List.range (H+1)).find? (fails y) with
    | none => false
    | some k => (List.range (2*k+1-lo)).all fun i =>
        check H b (lo+i+1) (y ||| 2^(lo+i))

private theorem dead {y k : Nat} (h : fails y k = true) :
    zrow (rowOfNat y) (2*k) 1 = false := by
  simpa [fails, zrow_rowOfNat_col1] using h

theorem sound {H b lo y : Nat} (ok : check H b lo y = true)
    (js : List Nat) (ord : Ordered lo js) (budget : js.length ≤ b) :
    ∃ k ≤ H, zrow (rowOfNat (pack y js)) (2*k) 1 = false := by
  induction b generalizing lo y js with
  | zero =>
    have emp : js = [] := List.length_eq_zero_iff.mp (by omega)
    subst js
    obtain ⟨k, mem, hit⟩ := List.any_eq_true.mp ok
    exact ⟨k, by have := List.mem_range.mp mem; omega, dead hit⟩
  | succ b ih =>
    simp only [check] at ok
    split at ok
    next => contradiction
    next k found =>
      have mem := List.mem_range.mp (List.mem_of_find?_eq_some found)
      have hit := dead (List.find?_some found)
      cases js with
      | nil => exact ⟨k, by omega, hit⟩
      | cons j js =>
        obtain ⟨start, tail⟩ := ord
        by_cases near : j ≤ 2*k
        · have member : j-lo ∈ List.range (2*k+1-lo) := List.mem_range.mpr (by omega)
          have child := List.all_eq_true.mp ok _ member
          rw [show lo+(j-lo)=j by omega] at child
          exact ih child js tail (by simpa using budget)
        · refine ⟨k, by omega, ?_⟩
          rw [← hit]
          apply zrow_light_cone
          intro i pos bound
          cases i with
          | zero => omega
          | succ i => exact untouched (lo := j) (js := j::js) ⟨by omega, tail⟩ (by omega) y

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem eight : check 24 8 0 0 = true := by decide +kernel

/-- The upper bound of 48 ticks is attained by an eight-black-cell row. -/
theorem sharp_eight :
    pack 0 [0,1,6,7,8,11,12,27] = 134224323 ∧
    (List.range 24).all (fun k => !fails 134224323 k) = true ∧ fails 134224323 24 = true := by
  decide +kernel

/-- Uniform failure time for a budget of additional black cells at
arbitrary distances. There is no cutoff on the last occupied position. -/
def Uniform (b lo y H : Nat) : Prop :=
  ∀ js, Ordered lo js → js.length ≤ b →
    ∃ k ≤ H, zrow (rowOfNat (pack y js)) (2*k) 1 = false

theorem uniform_of_q01 (hq : Q01) (b : Nat) : ∀ lo y, ∃ H, Uniform b lo y H := by
  induction b with
  | zero =>
    intro lo y
    obtain ⟨k, hk⟩ := Q01_iff_integer.mp hq y
    refine ⟨k, fun js _ len => ?_⟩
    have empty : js = [] := List.length_eq_zero_iff.mp (by omega)
    subst js
    exact ⟨k, Nat.le_refl _, by simp [pack, zrow_rowOfNat_col1,
      ← iter_G_eq_iter_F_two_mul, Nat.testBit_zero, hk]⟩
  | succ b ih =>
    intro lo y
    obtain ⟨k, hk⟩ := Q01_iff_integer.mp hq y
    have first : zrow (rowOfNat y) (2*k) 1 = false := by
      simp [zrow_rowOfNat_col1, ← iter_G_eq_iter_F_two_mul, Nat.testBit_zero, hk]
    let bound (j : Nat) := Classical.choose (ih (j+1) (y ||| 2^j))
    let horizons := (List.range (2*k+1)).map bound
    refine ⟨max k (horizons.max?.getD 0), ?_⟩
    intro js ord budget
    cases js with
    | nil => exact ⟨k, Nat.le_max_left .., first⟩
    | cons j js =>
      obtain ⟨_, tail⟩ := ord
      by_cases near : j ≤ 2*k
      · obtain ⟨m, hm, deadAt⟩ := Classical.choose_spec (ih (j+1) (y ||| 2^j))
          js tail (by simpa using budget)
        have mem : bound j ∈ horizons := List.mem_map.mpr ⟨j, List.mem_range.mpr (by omega), rfl⟩
        have upper : bound j ≤ horizons.max?.getD 0 := by
          cases eq : horizons.max? with
          | none => simp [List.max?_eq_none_iff.mp eq] at mem
          | some z => exact (List.max?_eq_some_iff.mp eq).2 _ mem
        exact ⟨m, Nat.le_trans (Nat.le_trans hm upper) (Nat.le_max_right ..), deadAt⟩
      · refine ⟨k, Nat.le_max_left .., ?_⟩
        rw [← first]
        apply zrow_light_cone
        intro i pos cap
        cases i with
        | zero => omega
        | succ i => exact untouched (lo := j) (js := j::js) ⟨by omega, tail⟩ (by omega) y

private def sites (y lo : Nat) : Nat → List Nat
  | 0 => []
  | n+1 => if y.testBit lo then lo :: sites y (lo+1) n else sites y (lo+1) n

private theorem relax {js lo hi} (h : Ordered hi js) (le : lo ≤ hi) : Ordered lo js := by
  cases js with
  | nil => trivial
  | cons j js => exact ⟨Nat.le_trans le h.1, h.2⟩

private theorem sites_ordered (y lo n : Nat) : Ordered lo (sites y lo n) := by
  induction n generalizing lo with
  | zero => trivial
  | succ n ih =>
    unfold sites
    split
    · exact ⟨Nat.le_refl _, ih _⟩
    · exact relax (ih _) (by omega)

private theorem sites_mem (y lo i n : Nat) :
    i ∈ sites y lo n ↔ lo ≤ i ∧ i < lo+n ∧ y.testBit i = true := by
  induction n generalizing lo with
  | zero => simp [sites]; omega
  | succ n ih =>
    simp only [sites]
    split <;> rename_i test
    · simp only [List.mem_cons, ih]
      by_cases eq : i = lo
      · subst i; simp [test]
      · simp only [eq, false_or]
        by_cases bit : y.testBit i = true <;> simp [bit] <;> omega
    · rw [ih]
      by_cases eq : i = lo
      · subst i; simp [test]
      · by_cases bit : y.testBit i = true <;> simp [bit] <;> omega

private theorem packed_bit (js : List Nat) (y i : Nat) :
    (pack y js).testBit i = (y.testBit i || decide (i ∈ js)) := by
  induction js generalizing y with
  | nil => simp [pack]
  | cons j js ih =>
    simp [pack, ih, Nat.testBit_or, Nat.testBit_two_pow, Bool.or_assoc, eq_comm]

/-- The same deadline applies to an arbitrary infinite tail. Only the
first 2H+1 depths are charged against the weight budget. -/
theorem prefix_of_uniform {H b : Nat} (good : Uniform b 0 0 H) (L : Nat → Bool)
    (budget : ((List.range (2*H+1)).filter (fun i => L (i+1))).length ≤ b) :
    ∃ k ≤ H, zrow L (2*k) 1 = false := by
  let y := natOfRow L (2*H+1)
  have bit (i : Nat) (hi : i < 2*H+1) : y.testBit i = L (i+1) := by
    simpa [y, hi] using testBit_natOfRow (2*H+1) L i
  let js := sites y 0 (2*H+1)
  have filt (n lo : Nat) : sites y lo n =
      ((List.range' lo n).filter (fun i => y.testBit i)) := by
    induction n generalizing lo with
    | zero => rfl
    | succ n ih => simp [sites, List.range', ih, List.filter_cons]
  have eq : js = (List.range (2*H+1)).filter (fun i => L (i+1)) := by
    rw [show js = _ from filt _ _, ← List.range_eq_range']
    apply List.filter_congr
    intro i mem
    exact bit i (List.mem_range.mp mem)
  obtain ⟨k, hk, hit⟩ := good js (sites_ordered ..) (eq ▸ budget)
  refine ⟨k, hk, ?_⟩
  rw [← hit]
  apply zrow_light_cone
  intro i pos bound
  cases i with
  | zero => omega
  | succ i =>
    change L (i+1) = (pack 0 js).testBit i
    have inside : i < 2*H+1 := by omega
    simp [packed_bit, js, sites_mem, inside, bit i inside]

theorem eight_prefix (L : Nat → Bool)
    (budget : ((List.range 49).filter (fun i => L (i+1))).length ≤ 8) :
    ∃ k ≤ 24, zrow L (2*k) 1 = false :=
  prefix_of_uniform (b := 8) (H := 24) (fun js => sound eight js) L budget

/-- Q01 is precisely divergence of the unrestricted prefix-weight floor.
Each fixed budget has one common deadline, however far apart the cells lie. -/
theorem q01_iff_sparse_deadlines : Q01 ↔ ∀ b, ∃ H, Uniform b 0 0 H := by
  refine ⟨fun h b => uniform_of_q01 h b 0 0, ?_⟩
  intro every
  apply Q01_iff_integer.mpr
  intro y
  let js := sites y 0 (y.log2+1)
  have repr : pack 0 js = y := by
    apply Nat.eq_of_testBit_eq
    intro i
    simp only [packed_bit, Nat.zero_testBit, Bool.false_or, js]
    by_cases within : i < y.log2+1
    · simp [sites_mem, within]
    · have zero : y.testBit i = false := Nat.testBit_lt_two_pow
        (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by decide) (by omega)))
      simp [sites_mem, within, zero]
  obtain ⟨H, dies⟩ := every js.length
  obtain ⟨k, _, hit⟩ := dies js (sites_ordered ..) (Nat.le_refl _)
  rw [repr, zrow_rowOfNat_col1, ← iter_G_eq_iter_F_two_mul, Nat.testBit_zero] at hit
  exact ⟨k, by simp at hit; omega⟩

theorem q01_iff_prefix_floors : Q01 ↔ ∀ b, ∃ H, ∀ L : Nat → Bool,
    ((List.range (2*H+1)).filter (fun i => L (i+1))).length ≤ b →
    ∃ k ≤ H, zrow L (2*k) 1 = false := by
  rw [q01_iff_sparse_deadlines]
  constructor
  · intro all b
    obtain ⟨H, good⟩ := all b
    exact ⟨H, prefix_of_uniform good⟩
  · intro all b
    obtain ⟨H, good⟩ := all b
    refine ⟨H, fun js _ budget => good (rowOfNat (pack 0 js)) ?_⟩
    let live := (List.range (2*H+1)).filter fun i => rowOfNat (pack 0 js) (i+1)
    have incl : live ⊆ js := by
      intro i mem
      have bit := (List.mem_filter.mp mem).2
      simpa [rowOfNat, packed_bit] using bit
    have distinct : live.Nodup := List.Pairwise.filter _ List.nodup_range
    exact Nat.le_trans (distinct.length_le_of_subset incl) budget

end PhaseTwo.SparseDeadline
