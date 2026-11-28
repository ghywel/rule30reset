import Std

/-! Time (150,180) on the white-wall half-line. Index 0 is depth 1, and each
    successive index goes one site farther west. A round consists of two ticks. -/
namespace Hybrid150Edge

abbrev Row := Nat → Bool

def east (x : Row) : Nat → Bool
  | 0 => false
  | i + 1 => x i

private theorem east_succ (x : Row) (i : Nat) : east x (i+1) = x i := rfl

def tick (g : Bool → Bool → Bool) (x : Row) (i : Nat) : Bool :=
  xor (x (i+1)) (g (x i) (east x i))

def linear (x : Row) := tick xor x
def nonlin (x : Row) := tick (fun c r => c && !r) x
def round (x : Row) := nonlin (linear x)

def run : Nat → Row → Row
  | 0, x => x
  | n+1, x => run n (round x)

theorem run_add (a b : Nat) (x : Row) : run (a+b) x = run b (run a x) := by
  induction a generalizing x with
  | zero => simp [run]
  | succ a ih => simpa only [Nat.succ_add, run] using ih (round x)

def Within (x : Row) (w : Nat) := ∀ i, w ≤ i → x i = false
def Edge (x : Row) (i : Nat) := Within x (i+1) ∧ x i = true
def Locked (x : Row) (i : Nat) := Edge x (i+1) ∧ x i = true

private theorem support (x : Row) (w : Nat) (hw : Within x w) : Within (round x) (w+1) := by
  intro i hi
  cases i with
  | zero => omega
  | succ i =>
    have white (j : Nat) (hj : w ≤ j) : linear x (j+1) = false := by
      simp [linear, tick, east_succ, hw j hj, hw (j+1) (by omega), hw (j+1+1) (by omega)]
    have a := white i (by omega)
    have b := white (i+1) (by omega)
    simp [round, nonlin, tick, a, b]

private theorem edge_bits (x : Row) (d : Nat) (h : Edge x (d+1)) :
    round x (d+2) = x d ∧ round x (d+1) = (x d || !east x d) := by
  obtain ⟨hw, black⟩ := h
  simp only [round, nonlin, linear, tick, east_succ, hw (d+2) (by omega), hw (d+3) (by omega),
    hw (d+4) (by omega), black]
  cases x d <;> cases east x d <;> decide

/-- A leading pair of black cells advances one depth and reproduces itself every round. -/
theorem locked_step (x : Row) (d : Nat) (h : Locked x d) : Locked (round x) (d+1) := by
  obtain ⟨top, second⟩ := h
  obtain ⟨a, b⟩ := edge_bits x d top
  exact ⟨⟨support x (d+2) top.1, a.trans second⟩, by simp [b, second]⟩

theorem locked_run (n : Nat) (x : Row) (d : Nat) (h : Locked x d) :
    Locked (run n x) (d+n) := by
  induction n generalizing x d with
  | zero => exact h
  | succ n ih => simpa +arith [run] using ih (round x) (d+1) (locked_step x d h)

private theorem no_growth {x : Row} {d : Nat} (h : Edge x (d+1)) (h0 : x d = false) :
    Within (round x) (d+2) := by
  intro i hi
  by_cases he : i = d+2
  · rw [he, (edge_bits x d h).1, h0]
  · exact support x (d+2) h.1 i (by omega)

private theorem retreat {x : Row} {n : Nat} (h : Edge x (n+2))
    (b : x (n+1) = false) (c : x n = true) : Edge (round x) (n+1) := by
  obtain ⟨_, old⟩ := edge_bits x (n+1) h
  constructor
  · intro i hi
    by_cases he : i = n+2
    · simp [he, old, b, east, c]
    · exact no_growth h b i (by omega)
  · simp only [round, nonlin, linear, tick, east_succ, h.1 (n+3) (by omega), h.2, b, c]
    cases east x n <;> decide

private theorem stall {x : Row} {n : Nat} (h : Edge x (n+3))
    (b : x (n+2) = false) (c : x (n+1) = false) :
    Edge (round x) (n+3) ∧ round x (n+2) = x n ∧
      (x n = false → round x (n+1) = true) := by
  refine ⟨⟨no_growth h b, ?_⟩, ?_, ?_⟩
  · simp [(edge_bits x (n+2) h).2, b, c, east]
  · simp only [round, nonlin, linear, tick, east, h.1 (n+4) (by omega), h.2, b, c]
    cases x n <;> decide
  · intro z
    simp only [round, nonlin, linear, tick, east_succ, h.2, b, c, z]
    cases east x n <;> decide

def packed (y : Nat) : Row := y.testBit

private theorem small_shape {x : Row} {w : Nat} (h : Within x w) (v : Nat)
    (hv : v < 2^w) (bits : ∀ i < w, x i = (packed v) i) : x = packed v := by
  funext i
  by_cases hi : i < w
  · exact bits i hi
  · have bound : v < 2^i := Nat.lt_of_lt_of_le hv (Nat.pow_le_pow_right (by decide) (by omega))
    rw [h _ (by omega)]
    exact (Nat.testBit_lt_two_pow bound).symm

private theorem three_eq (u v : Nat) (hu : u < 8) (hv : v < 16)
    (bits : ∀ i : Fin 4, round (packed u) i.val = (packed v) i.val) :
    round (packed u) = packed v := by
  have hw : Within (packed u) 3 := by
    intro i hi
    apply Nat.testBit_lt_two_pow
    exact Nat.lt_of_lt_of_le hu (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) hi)
  exact small_shape (support _ _ hw) v hv (fun i hi => bits ⟨i, hi⟩)

theorem terminal_steps : round (packed 0) = packed 0 ∧ round (packed 1) = packed 0 ∧
    round (packed 2) = packed 2 ∧ round (packed 4) = packed 5 ∧ round (packed 5) = packed 3 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> apply three_eq <;> decide +kernel

private theorem three_locked : Locked (packed 3) 0 := by
  refine ⟨⟨fun i hi => Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (by decide : 3 < 2^2)
    (Nat.pow_le_pow_right (by decide) hi)), rfl⟩, rfl⟩

/-- The remaining index `d` starts at zero for a pair of width two. Charging
    each unit of `d` two rounds also bounds the time spent before launch. -/
def Launched (x : Row) (budget : Nat) :=
  ∃ t d, t + 2*d ≤ budget ∧ Locked (run t x) d

private theorem already {x : Row} {bound d : Nat} (h : Locked x d) (hb : 2*d ≤ bound) :
    Launched x bound := ⟨0, d, by omega, h⟩

private theorem prepend {x : Row} {k b c : Nat} (h : Launched (run k x) b) (hc : k+b ≤ c) :
    Launched x c := by
  obtain ⟨t, d, ht, hd⟩ := h
  exact ⟨k+t, d, by omega, by rwa [run_add]⟩

private theorem width_three {x : Row} (h : Edge x 2) : Launched x 2 := by
  cases b : x 1 with
  | true => exact already (d := 1) ⟨h, b⟩ (by decide)
  | false =>
    have small (v : Nat) (hv : v < 8) (a : x 0 = (packed v) 0)
        (b' : (packed v) 1 = false) (c : (packed v) 2 = true) : x = packed v := by
      apply small_shape h.1 _ hv
      intro i hi
      rcases (by omega : i = 0 ∨ i = 1 ∨ i = 2) with rfl | rfl | rfl
      · exact a
      · exact b.trans b'.symm
      · exact h.2.trans c.symm
    cases a : x 0 with
    | false =>
      rw [small 4 (by decide) a rfl rfl]
      exact ⟨2, 0, by decide, by simpa only [run, terminal_steps.2.2.2.1, terminal_steps.2.2.2.2] using three_locked⟩
    | true =>
      rw [small 5 (by decide) a rfl rfl]
      exact ⟨1, 0, by decide, by simpa only [run, terminal_steps.2.2.2.2] using three_locked⟩

/-- With input width W=n+3, there is a launch at width K and time t with
    t+2K ≤ 2W+1. Packed 3 at width two starts locked. -/
theorem launch_budget (n : Nat) (x : Row) (h : Edge x (n+2)) : Launched x (2*n+3) := by
  induction n generalizing x with
  | zero => exact prepend (k := 0) (width_three h) (by decide)
  | succ n ih =>
    cases b : x (n+2) with
    | true => exact already (d := n+2) ⟨h, b⟩ (by omega)
    | false =>
      cases c : x (n+1) with
      | true => exact prepend (k := 1) (ih (round x) (retreat h b c)) (by omega)
      | false =>
        obtain ⟨top, second, third⟩ := stall h b c
        cases e : x n with
        | true => exact ⟨1, n+2, by omega, top, second.trans e⟩
        | false => exact prepend (k := 2) (ih _ (retreat top (second.trans e) (third e))) (by omega)

theorem packed_launch {y : Nat} (hy : 3 ≤ y) : Launched (packed y) (2*(y.log2-1)+1) := by
  by_cases h3 : y = 3
  · subst y
    exact already three_locked (by decide)
  have nz : y ≠ 0 := by omega
  have two : 2 ≤ y.log2 := (Nat.le_log2 nz).2 (by omega)
  have edge : Edge (packed y) y.log2 := by
    refine ⟨fun i hi => Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le Nat.lt_log2_self
      (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) hi)), Nat.testBit_log2 nz⟩
  have h := launch_budget (y.log2-2) (packed y) (by simpa only [Nat.sub_add_cancel two] using edge)
  rwa [show 2*(y.log2-2)+3 = 2*(y.log2-1)+1 by omega] at h

/-- Boundedness here concerns the even rows. The intervening linear tick adds
    at most one outer cell. -/
theorem bounded_iff (y : Nat) : (∃ w, ∀ n, Within (run n (packed y)) w) ↔ y ≤ 2 := by
  constructor
  · rintro ⟨w, bound⟩
    apply Nat.le_of_not_gt
    intro hy
    obtain ⟨t, d, _, hd⟩ := packed_launch (by omega : 3 ≤ y)
    have black := (locked_run w _ _ hd).1.2
    rw [← run_add, bound (t+w) (d+w+1) (by omega)] at black
    contradiction
  · intro h
    have small (n y : Nat) (hy : y ≤ 2) : Within (run n (packed y)) 2 := by
      induction n generalizing y with
      | zero =>
        intro i hi
        exact Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (by omega : y < 2^2)
          (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) hi))
      | succ n ih =>
        rcases (by omega : y=0 ∨ y=1 ∨ y=2) with rfl | rfl | rfl <;>
          simp only [run, terminal_steps.1, terminal_steps.2.1, terminal_steps.2.2.1] <;> apply ih <;> decide
    exact ⟨2, fun n => small n y h⟩

/-- One forward round reads the former depth three at the wall exactly. -/
theorem wall_round (x : Row) : round x 0 = x 2 := by
  simp only [round, nonlin, linear, tick, east]
  cases x 0 <;> cases x 1 <;> cases x 2 <;> decide

/-- Physical time, starting in either phase. Both rules are permutive in the west cell. -/
def gate (odd : Bool) (c r : Bool) := if odd then c && !r else xor c r
def clock (odd : Bool) (x : Row) : Nat → Row
  | 0 => x
  | t+1 => clock (!odd) (tick (gate odd) x) t

theorem clock_even (x : Row) (n : Nat) : clock false x (2*n) = run n x := by
  induction n generalizing x with
  | zero => rfl
  | succ n ih => exact ih (round x)

theorem clock_odd (x : Row) (n : Nat) : clock false x (2*n+1) = linear (run n x) := by
  induction n generalizing x with
  | zero => rfl
  | succ n ih => exact ih (round x)

/-- The first k+1 boundary readings determine the first k+1 initial cells,
    including the one at index k. This is the finite left-permutive trace argument. -/
theorem trace_prefix (k : Nat) (odd : Bool) (x y : Row)
    (h : ∀ t ≤ k, clock odd x t 0 = clock odd y t 0) : ∀ i ≤ k, x i = y i := by
  induction k generalizing odd x y with
  | zero => intro i hi; simpa [clock, show i=0 by omega] using h 0 (by omega)
  | succ k ih =>
    have now := ih odd x y (fun t ht => h t (by omega))
    have next := ih (!odd) (tick (gate odd) x) (tick (gate odd) y) (fun t ht => h (t+1) (by omega))
    intro i hi
    by_cases inside : i ≤ k
    · exact now i inside
    have r : east x k = east y k := by
      cases k with
      | zero => rfl
      | succ j => exact now j (by omega)
    have pair := next k (by omega)
    simp only [tick, now k (by omega), r, Bool.xor_left_inj] at pair
    simpa only [show i=k+1 by omega] using pair

def oddBit (x : Row) (r : Nat) := linear (run r x) 0

/-- While the even samples are black, any two listed length-m odd words differ.
    The bound is inclusive in j. After a launch of width K=d+2 this gives
    2m+2−K distinct starts, with natural subtraction. -/
theorem distinct_odd_windows {x : Row} {d i j m : Nat} (hd : Locked x d)
    (ij : i < j) (fits : d+j+1 ≤ 2*m)
    (pin : ∀ t ≤ j+m, run t x 0 = true) :
    ∃ k < m, oddBit x (i+k) ≠ oddBit x (j+k) := by
  apply Classical.byContradiction
  intro hn
  have agree (k : Nat) (hk : k < m) : oddBit x (i+k) = oddBit x (j+k) := by
    apply Classical.byContradiction
    exact fun h => hn ⟨k, hk, h⟩
  have window (t : Nat) (ht : t ≤ 2*m) :
      clock false (run i x) t 0 = clock false (run j x) t 0 := by
    rcases Nat.mod_two_eq_zero_or_one t with e | o
    · rw [show t = 2*(t/2) by omega, clock_even, clock_even, ← run_add, ← run_add]
      rw [pin _ (by omega), pin _ (by omega)]
    · rw [show t = 2*(t/2)+1 by omega, clock_odd, clock_odd, ← run_add, ← run_add]
      exact agree (t/2) (by omega)
  have same := trace_prefix (2*m) false _ _ window (d+j+1) fits
  have white := (locked_run i x d hd).1.1 (d+j+1) (by omega)
  have black := (locked_run j x d hd).1.2
  rw [white, black] at same
  contradiction

def oddWord (x : Row) (m start : Nat) : Fin m → Bool := fun k => oddBit x (start+k.val)

/-- An explicit list of different odd words, all read from one finite prefix. -/
theorem odd_vocabulary_floor {x : Row} {d : Nat} (hd : Locked x d) (m : Nat)
    (pin : ∀ t < (2*m-d)+m, run t x 0 = true) :
    ((List.range (2*m-d)).map (oddWord x m)).Nodup := by
  rw [List.nodup_iff_pairwise_ne, List.pairwise_map]
  apply List.Pairwise.imp_of_mem _ List.pairwise_lt_range
  intro i j _ hj ij eq
  have jbound := List.mem_range.mp hj
  obtain ⟨k, hk, ne⟩ := distinct_odd_windows hd ij (by omega : d+j+1 ≤ 2*m)
    (fun t ht => pin t (by omega))
  exact ne (congrFun eq ⟨k, hk⟩)

/-- In the first H odd readings, at most m+1 words of each length m occur. -/
def LowVocabulary (x : Row) (H : Nat) := ∀ m, ∃ words : List (Fin m → Bool),
  words.length ≤ m+1 ∧ ∀ i, i+m ≤ H → oddWord x m i ∈ words

theorem low_vocabulary_deadline {x : Row} {B : Nat} (launch : Launched x B)
    (low : LowVocabulary x (B+5)) : ∃ n ≤ B+5, run n x 0 = false := by
  apply Classical.byContradiction
  intro noWhite
  have pin (t : Nat) (ht : t ≤ B+5) : run t x 0 = true := by
    cases b : run t x 0 with
    | true => rfl
    | false => exact False.elim (noWhite ⟨t, ht, b⟩)
  obtain ⟨t, d, cost, hd⟩ := launch
  obtain ⟨words, size, covers⟩ := low (d+2)
  have unique := odd_vocabulary_floor hd (d+2) (fun k hk => by rw [← run_add]; exact pin _ (by omega))
  have sub : (List.range (2*(d+2)-d)).map (oddWord (run t x) (d+2)) ⊆ words := by
    intro word hw
    obtain ⟨i, hi, rfl⟩ := List.mem_map.mp hw
    have hi' := List.mem_range.mp hi
    have eq : oddWord (run t x) (d+2) i = oddWord x (d+2) (t+i) := by
      funext k
      simp [oddWord, oddBit, ← run_add, Nat.add_assoc]
    rw [eq]
    exact covers _ (by omega)
  have card := unique.length_le_of_subset sub
  simp only [List.length_map, List.length_range] at card
  omega

/-- For W equal to the bit length of y≥3 the deadline is 2W+2 rounds.
    This includes every Sturmian odd reading, uniformly in its slope and intercept. -/
theorem packed_low_deadline {y : Nat} (hy : 3 ≤ y)
    (low : LowVocabulary (packed y) (2*(y.log2+1)+2)) :
    ∃ n ≤ 2*(y.log2+1)+2, run n (packed y) 0 = false := by
  have h1 : 1 ≤ y.log2 := (Nat.le_log2 (by omega)).2 (by omega)
  have hb : 2*(y.log2-1)+1+5 = 2*(y.log2+1)+2 := by omega
  rw [← hb] at low ⊢
  exact low_vocabulary_deadline (packed_launch hy) low

private theorem cone (n : Nat) (odd : Bool) (x y : Row) (h : ∀ i ≤ n, x i = y i) :
    ∀ t ≤ n, clock odd x t 0 = clock odd y t 0 := by
  induction n generalizing odd x y with
  | zero => intro t ht; simpa [clock, show t=0 by omega] using h 0 (by omega)
  | succ n ih =>
    intro t ht
    cases t with
    | zero => exact h 0 (by omega)
    | succ t =>
      apply ih (!odd) (tick (gate odd) x) (tick (gate odd) y) _ t (by omega)
      intro i hi
      have r : east x i = east y i := by
        cases i with
        | zero => rfl
        | succ j => exact h j (by omega)
      simp [tick, h _ (by omega : i+1 ≤ n+1), h _ (by omega : i ≤ n+1), r]

private theorem realize (n : Nat) (b : Nat → Bool) :
    ∃ x : Row, ∀ t ≤ n, clock false x t 0 = b t := by
  induction n with
  | zero => exact ⟨fun _ => b 0, fun t ht => by simp [clock, show t=0 by omega]⟩
  | succ n ih =>
    obtain ⟨x, hx⟩ := ih
    let y : Row := fun i => if i = n+1 then !x i else x i
    have same := cone n false y x (fun i hi => by simp [y, show i ≠ n+1 by omega])
    have different : clock false x (n+1) 0 ≠ clock false y (n+1) 0 := by
      intro eq
      have far := trace_prefix (n+1) false x y (fun t ht => by
        by_cases he : t=n+1
        · simpa only [he] using eq
        · exact (same t (by omega)).symm) (n+1) (by omega)
      simp [y] at far
    by_cases a : clock false x (n+1) 0 = b (n+1)
    · exact ⟨x, fun t ht => by
        by_cases e : t=n+1
        · simpa only [e] using a
        · exact hx t (by omega)⟩
    · refine ⟨y, fun t ht => ?_⟩
      by_cases e : t=n+1
      · subst t
        have two : ∀ a b c : Bool, a ≠ b → a ≠ c → b = c := by decide
        exact two _ _ _ different a
      · exact (same t (by omega)).trans (hx t (by omega))

/-- Every prescribed finite odd word can occur while all m+1 even samples are
    black, on a row already locked and of exact width 2m+3. -/
theorem arbitrary_odd_prefix (m : Nat) (f : Nat → Bool) :
    ∃ x, Locked x (2*m+1) ∧ (∀ j ≤ m, run j x 0 = true) ∧ (∀ j < m, oddBit x j = f j) := by
  let b : Nat → Bool := fun t => if t%2=0 then true else f (t/2)
  obtain ⟨u, hu⟩ := realize (2*m) b
  let x : Row := fun i => if i ≤ 2*m then u i else decide (i ≤ 2*m+2)
  have same := cone (2*m) false x u (fun i hi => by simp [x, hi])
  refine ⟨x, ⟨⟨fun i hi => by simp [x, show ¬ i ≤ 2*m by omega, show ¬ i ≤ 2*m+2 by omega],
    by simp [x, show ¬(2*m+1+1 ≤ 2*m) by omega]⟩, by simp [x]⟩, ?_, ?_⟩
  · intro j hj
    have eq := (same (2*j) (by omega)).trans (hu _ (by omega))
    simpa [clock_even, b] using eq
  · intro j hj
    have eq := (same (2*j+1) (by omega)).trans (hu _ (by omega))
    simpa [clock_odd, b, oddBit, show (2*j+1)/2 = j by omega, show (2*j+1)%2 = 1 by omega] using eq

end Hybrid150Edge
