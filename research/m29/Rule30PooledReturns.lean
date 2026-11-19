module

public import Ruliology.CellularAutomata.Rule30TemporalProfiles

/-! Pooled first returns of pointed periodic temporal words at a fixed clock. -/
@[expose] public section

namespace Ruliology.CellularAutomata.Rule30TemporalProfiles
open Rule30Jen

namespace PooledReturn

abbrev Word := Nat → Bool
def white : Word := fun _ => false

/-- Repeat the labelled bits of a list in their original temporal order. -/
def repeatWord (w : List Bool) : Word := fun t => w[t % w.length]?.getD false

theorem repeat_periodic (w : List Bool) : Periodic w.length (repeatWord w) := by
  intro t
  simp [repeatWord]

private theorem repeat_injective {a b : List Bool} (hlen : a.length = b.length)
    (h : repeatWord a = repeatWord b) : a = b := by
  apply List.ext_getElem hlen
  intro i ha hb
  have e := congrFun h i
  simpa [repeatWord, Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb, ha, hb] using e

private theorem black_of_ne {B : Word} (h : B ≠ white) : ∃ t, B t = true := by
  apply Classical.byContradiction
  intro hn
  apply h
  funext t
  cases ht : B t with
  | false => rfl
  | true => exact (hn ⟨t, ht⟩).elim

noncomputable def next (q : Nat) (A B : Word) : Word :=
  open Classical in
  if h : ∃ t, B t = true then childOf A B q h.choose else white

private theorem next_periodic {q} (hq : 0 < q) {A B} (ha : Periodic q A) (hb : Periodic q B) :
    Periodic q (next q A B) := by
  unfold next
  split
  next h => exact (child_exists hq ha hb h.choose_spec).1
  next => intro t; rfl

private theorem next_child {q} (hq : 0 < q) {A B} (ha : Periodic q A) (hb : Periodic q B)
    (hn : B ≠ white) : Child (· + 1) A B (next q A B) := by
  unfold next
  split
  next h => exact (child_exists hq ha hb h.choose_spec).2
  next h => exact (h (black_of_ne hn)).elim

/-- The auxiliary continuation past a first white uses a white fallback.
Only strict pre-return triples are used in the theorem. -/
noncomputable def wheel (q : Nat) (c : Word) : Nat → Word
  | 0 => white
  | 1 => c
  | n+2 => next q (wheel q c n) (wheel q c (n+1))

private theorem wheel_periodic {q c} (hq : 0 < q) (hc : Periodic q c) :
    ∀ n, Periodic q (wheel q c n)
  | 0 => fun _ => rfl
  | 1 => hc
  | n+2 => next_periodic hq (wheel_periodic hq hc n) (wheel_periodic hq hc (n+1))

theorem wheel_child {q c} (hq : 0 < q) (hc : Periodic q c) (i : Nat)
    (hn : wheel q c (i+1) ≠ white) :
    Child (· + 1) (wheel q c i) (wheel q c (i+1)) (wheel q c (i+2)) :=
  next_child hq (wheel_periodic hq hc i) (wheel_periodic hq hc (i+1)) hn

private theorem least_witness {P : Nat → Prop} (h : ∃ n, P n) :
    ∃ n, P n ∧ ∀ j, j < n → ¬ P j := by
  obtain ⟨n, hn⟩ := h
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases he : ∃ j, j < n ∧ P j
    · obtain ⟨j, hj, hp⟩ := he
      exact ih j hj hp
    · exact ⟨n, hn, fun j hj hp => he ⟨j, hj, hp⟩⟩

def FirstReturn (q : Nat) (c : Word) (g : Nat) : Prop :=
  0 < g ∧ wheel q c g = white ∧ ∀ i, 0 < i → i < g → wheel q c i ≠ white

theorem firstReturn_exists {q c} (hq : 0 < q) (hc : Periodic q c) : ∃ g, FirstReturn q c g := by
  have he : ∃ g, 0 < g ∧ wheel q c g = white := by
    apply Classical.byContradiction
    intro hn
    have hch (i : Nat) := wheel_child hq hc i (fun e => hn ⟨i+1, by omega, e⟩)
    obtain ⟨k, hk, hw⟩ := rooted_chain_returns hq _ (wheel_periodic hq hc) (fun _ => rfl) hch
    exact hn ⟨k, hk, funext hw⟩
  obtain ⟨g, ⟨hp, hw⟩, hm⟩ := least_witness he
  exact ⟨g, hp, hw, fun i hi hig e => hm i hig ⟨hi, e⟩⟩

/-- First positive white index for a pointed word. The fallback at width zero
only makes this a total function. -/
noncomputable def gap (w : List Bool) : Nat :=
  if h : 0 < w.length then (firstReturn_exists h (repeat_periodic w)).choose else 0

theorem gap_spec {w : List Bool} (h : 0 < w.length) :
    FirstReturn w.length (repeatWord w) (gap w) := by
  rw [gap, dite_eq_left h]
  exact (firstReturn_exists h (repeat_periodic w)).choose_spec

/-- Equal pairs before two first returns determine both their distance from
the root and their pointed first child. -/
private theorem recover {q c d g k} (hq : 0 < q) (hc : Periodic q c) (hd : Periodic q d)
    (hg : FirstReturn q c g) (hk : FirstReturn q d k) (i j : Nat)
    (hi : i < g) (hj : j < k) (e : wheel q c i = wheel q d j)
    (f : wheel q c (i+1) = wheel q d (j+1)) : i = j ∧ c = d := by
  induction i generalizing j with
  | zero =>
    cases j with
    | zero => exact ⟨rfl, f⟩
    | succ j => exact (hk.2.2 _ (by omega) hj e.symm).elim
  | succ i ih =>
    cases j with
    | zero => exact (hg.2.2 _ (by omega) hi e).elim
    | succ j =>
      have hc' := wheel_child hq hc i (hg.2.2 _ (by omega) hi)
      have hd' := wheel_child hq hd j (hk.2.2 _ (by omega) hj)
      rw [e, f] at hc'
      have ep := child_parent_unique _ _ _ _ _ hc' hd'
      obtain ⟨hij, hcd⟩ := ih j (by omega) (by omega) ep e
      exact ⟨by omega, hcd⟩

private theorem word_length {q : Nat} {w : List Bool} (h : w ∈ allLists q) : w.length = q := by
  induction q generalizing w with
  | zero => simpa [allLists] using h
  | succ n ih =>
    simp only [allLists, List.mem_append, List.mem_map] at h
    obtain ⟨a, ha, rfl⟩ | ⟨a, ha, rfl⟩ := h <;> simp [ih ha]

private theorem words_nodup : ∀ q, (allLists q).Nodup
  | 0 => by simp [allLists]
  | q+1 => by
    rw [allLists, List.nodup_append]
    refine ⟨nodup_map_of_inj _ (words_nodup q) (by simp), ?_, ?_⟩
    · exact nodup_map_of_inj _ (words_nodup q) (by simp)
    · intro a ha b hb
      obtain ⟨_, _, rfl⟩ := List.mem_map.mp ha
      obtain ⟨_, _, rfl⟩ := List.mem_map.mp hb
      simp

/-- All nonwhite labelled Q-bit words. Repetition and temporal rotation
are identified only insofar as the labelled bit lists themselves coincide. -/
def ensemble (q : Nat) := (allLists q).erase (List.replicate q false)

private theorem zero_mem (q : Nat) : List.replicate q false ∈ allLists q := by
  simpa using mem_allLists (List.replicate q false)

theorem ensemble_size (q : Nat) : (ensemble q).length = 2^q - 1 := by
  rw [ensemble, List.length_erase_of_mem (zero_mem q), length_allLists]

private def code (q : Nat) (u : Word) := (List.range q).map u

private noncomputable def mark (q : Nat) (w : List Bool) (i : Nat) :=
  code q (wheel q (repeatWord w) i) ++ code q (wheel q (repeatWord w) (i+1))

private noncomputable def marks (q : Nat) (w : List Bool) :=
  (List.range (gap w)).map (mark q w)

private theorem mark_unique {q : Nat} (hq : 0 < q) {a b : List Bool}
    (ha : a.length = q) (hb : b.length = q) {i j : Nat} (hi : i < gap a) (hj : j < gap b)
    (he : mark q a i = mark q b j) : i = j ∧ a = b := by
  have hpa := ha ▸ repeat_periodic a
  have hpb := hb ▸ repeat_periodic b
  have hga := ha ▸ gap_spec (w := a) (by omega)
  have hgb := hb ▸ gap_spec (w := b) (by omega)
  obtain ⟨e, f⟩ := List.append_inj he (by simp [code])
  have eqWord {u v : Word} (hu : Periodic q u) (hv : Periodic q v) (h : code q u = code q v) :
      u = v := periodic_ext hu hv hq fun t ht => List.map_inj_left.mp h t (List.mem_range.mpr ht)
  obtain ⟨hij, hab⟩ := recover hq hpa hpb hga hgb i j hi hj
    (eqWord (wheel_periodic hq hpa _) (wheel_periodic hq hpb _) e)
    (eqWord (wheel_periodic hq hpa _) (wheel_periodic hq hpb _) f)
  exact ⟨hij, repeat_injective (ha.trans hb.symm) hab⟩

private theorem distinct_marks {q : Nat} (hq : 0 < q) (ws : List (List Bool))
    (hn : ws.Nodup) (hl : ∀ w ∈ ws, w.length = q) : (ws.flatMap (marks q)).Nodup := by
  induction ws with
  | nil => simp
  | cons a ws ih =>
    obtain ⟨ha, hws⟩ := List.nodup_cons.mp hn
    have la := hl a (by simp)
    have ls (w) (hw : w ∈ ws) := hl w (by simp [hw])
    rw [List.flatMap_cons, List.nodup_append]
    refine ⟨?_, ih hws ls, ?_⟩
    · apply nodup_map_of_inj _ List.nodup_range
      intro i hi j hj e
      exact (mark_unique hq la la (List.mem_range.mp hi) (List.mem_range.mp hj) e).1
    · intro x hx y hy e
      obtain ⟨i, hi, rfl⟩ := List.mem_map.mp hx
      obtain ⟨b, hb, hy⟩ := List.mem_flatMap.mp hy
      obtain ⟨j, hj, rfl⟩ := List.mem_map.mp hy
      have hab := (mark_unique hq la (ls b hb) (List.mem_range.mp hi) (List.mem_range.mp hj) e).2
      exact ha (hab ▸ hb)

/-- The sum of the first white gaps over all nonzero pointed words at a
common positive clock is at most (2^q − 1)(2^q + 1). -/
theorem pooled_first_return_bound (q : Nat) (hq : 0 < q) :
    ((ensemble q).map gap).sum ≤ (2^q - 1) * (2^q + 1) := by
  let z := List.replicate q false
  let ws := z :: ensemble q
  have hn : ws.Nodup := List.nodup_cons.mpr
    ⟨(words_nodup q).not_mem_erase, List.Nodup.erase z (words_nodup q)⟩
  have hl : ∀ w ∈ ws, w.length = q := by
    intro w hw
    rcases List.mem_cons.mp hw with rfl | h
    · simp [z]
    · exact word_length (List.mem_of_mem_erase h)
  have h := length_le_of_subset (l₂ := allLists (q+q)) (distinct_marks hq ws hn hl) (by
    intro x hx
    obtain ⟨w, _, hm⟩ := List.mem_flatMap.mp hx
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp hm
    simpa [mark, code] using mem_allLists (mark q w i))
  rw [List.length_flatMap, length_allLists, Nat.pow_add] at h
  simp only [marks, List.length_map, List.length_range] at h
  change gap z + ((ensemble q).map gap).sum ≤ 2^q * 2^q at h
  have hz := (gap_spec (w := z) (by simpa [z] using hq)).1
  have hp : 0 < 2^q := Nat.two_pow_pos q
  have he : (2^q - 1) * (2^q + 1) + 1 = 2^q * 2^q := by
    generalize 2^q = n at *
    cases n with
    | zero => omega
    | succ n => simp [Nat.add_mul, Nat.mul_add]; omega
  omega

end PooledReturn
end Ruliology.CellularAutomata.Rule30TemporalProfiles
