import Ruliology.CellularAutomata.Rule30Certificates.PeriodTwoWidth13

/-! First event returns in the nine-pair GE2 kick language. A state specifies
a kick gap and an offset starting at its first kick. One graph edge is two
physical ticks. At a white gate the decoded event is an even distance from
the next kick. No physical realisability of paths in this graph is assumed. -/
namespace Ruliology.CellularAutomata.Rule30GE2Phase

abbrev State := Fin 14

def gap (s : State) : Nat :=
  if s.val < 2 then 2 else if s.val < 5 then 3 else if s.val < 9 then 4 else 5

def offset (s : State) : Nat :=
  if s.val < 2 then s.val else if s.val < 5 then s.val-2 else if s.val < 9 then s.val-5 else s.val-9

def mark (s : State) : Bool :=
  decide (0 < offset s ∧ (gap s - offset s) % 2 = 0)

def step (s t : State) : Bool :=
  if offset s + 1 < gap s then decide (gap s = gap t ∧ offset t = offset s + 1)
  else decide (offset t = 0) && Rule30PeriodTwoWidth13.pairOK 1 (gap s) (gap t)

/-- Walk from a to b with every strictly intermediate state unmarked. -/
def quietTo (a : State) : Nat → State → Prop
  | 0, b => b = a
  | n+1, b => ∃ z, quietTo a n z ∧ (n = 0 ∨ mark z = false) ∧ step z b = true

def Returns (a b : State) (n : Nat) : Prop :=
  0 < n ∧ mark a = true ∧ mark b = true ∧ quietTo a n b

private def stage (n : Nat) : Fin 7 :=
  ⟨if n < 5 then n else 5 + (n+1)%2, by split <;> omega⟩

private def advance (s : Fin 7) : Fin 7 :=
  ⟨if s.val = 6 then 5 else s.val+1, by split <;> omega⟩

private theorem stage_succ (n : Nat) : stage (n+1) = advance (stage n) := by
  apply Fin.ext
  simp only [stage, advance]
  split <;> split <;> split <;> omega

private def mask (a : State) (s : Fin 7) : Nat :=
  match a.val with
  | 3  => [8,16,516,1032,0,0,0].getD s.val 0
  | 7  => [128,256,512,1024,0,0,0].getD s.val 0
  | 10 => [1024,2048,4096,0,0,0,0].getD s.val 0
  | 12 => [4096,8192,517,1034,545,1090,673].getD s.val 0
  | _  => 0

private def reaches (a : State) (s : Fin 7) (b : State) : Prop :=
  (mask a s).testBit b.val = true
private instance (a : State) (s : Fin 7) (b : State) : Decidable (reaches a s b) :=
  inferInstanceAs (Decidable (_ = true))

private theorem initial : ∀ a b : State, mark a = true → (reaches a (stage 0) b ↔ b = a) :=
  by decide +kernel

private theorem transition : ∀ s : Fin 7, ∀ a b : State, mark a = true →
    (reaches a (advance s) b ↔ ∃ z : State, reaches a s z ∧
      (s.val = 0 ∨ mark z = false) ∧ step z b = true) := by decide +kernel

private theorem reach_iff (a : State) (ha : mark a = true) (n : Nat) (b : State) :
    reaches a (stage n) b ↔ quietTo a n b := by
  induction n generalizing b with
  | zero => exact initial a b ha
  | succ n ih =>
    rw [stage_succ, transition _ _ _ ha]
    have stage0 : (stage n).val = 0 ↔ n = 0 := by
      unfold stage
      split <;> simp_all <;> omega
    simp only [quietTo, ih, stage0]

private def label (s : Fin 7) (a b : State) : Bool :=
  match s.val with
  | 2 => decide (a.val = 10 ∧ b.val = 12)
  | 3 => decide ((a.val = 3 ∨ a.val = 12) ∧ (b.val = 3 ∨ b.val = 10) ∨
                  a.val = 7 ∧ b.val = 10)
  | 5 => decide (a.val = 12 ∧ b.val = 10)
  | 6 => decide (a.val = 12 ∧ b.val = 7)
  | _ => false

private theorem read_label : ∀ s : Fin 7, ∀ a b : State,
    (s.val ≠ 0 ∧ mark a = true ∧ mark b = true ∧ reaches a s b) ↔ label s a b = true :=
  by decide +kernel

/-- The four event states are 3=(gap 3, offset 1), 7=(4,2), 10=(5,1),
and 12=(5,3). The right side gives the exact first-return relation at every
positive distance. A zero return is excluded. -/
theorem exact_returns (a b : State) (n : Nat) :
    Returns a b n ↔
      ((n = 2 ∧ a.val = 10 ∧ b.val = 12) ∨
       (n = 3 ∧ (((a.val = 3 ∨ a.val = 12) ∧ (b.val = 3 ∨ b.val = 10)) ∨
                  (a.val = 7 ∧ b.val = 10))) ∨
       (5 ≤ n ∧ a.val = 12 ∧ b.val = (if n%2 = 0 then 7 else 10))) := by
  have h : Returns a b n ↔ label (stage n) a b = true := by
    rw [← read_label]
    have nz : (stage n).val ≠ 0 ↔ 0 < n := by
      unfold stage
      split <;> simp_all <;> omega
    simp only [nz, Returns]
    by_cases hm : mark a = true
    · rw [reach_iff _ hm]
    · simp [hm]
  have decode : ∀ s : Fin 7, ∀ x y : State, label s x y = true ↔
      ((s.val = 2 ∧ x.val = 10 ∧ y.val = 12) ∨
       (s.val = 3 ∧ (((x.val = 3 ∨ x.val = 12) ∧ (y.val = 3 ∨ y.val = 10)) ∨
                     (x.val = 7 ∧ y.val = 10))) ∨
       (s.val = 5 ∧ x.val = 12 ∧ y.val = 10) ∨
       (s.val = 6 ∧ x.val = 12 ∧ y.val = 7)) := by decide +kernel
  rw [h, decode]
  by_cases small : n < 5
  · simp only [stage, ite_eq_left small]
    split <;> omega
  · simp only [stage, ite_eq_right small]
    split <;> omega

private theorem even_returns {a b : State} {n : Nat} (hr : Returns a b n) (he : n%2=0) :
    (a.val=10 ∧ b.val=12) ∨ (a.val=12 ∧ b.val=7) := by
  have h := (exact_returns a b n).mp hr
  rcases h with h | h | h
  · exact Or.inl h.2
  · omega
  · exact Or.inr (by simpa [he] using h.2)

/-- In any four consecutive decoded events at least one of the three
intervening double-step gaps is odd, so both white phases occur among them. -/
theorem four_events_both_phases {a b c d : State} {p q r : Nat}
    (hp : Returns a b p) (hq : Returns b c q) (hr : Returns c d r) :
    p%2 = 1 ∨ q%2 = 1 ∨ r%2 = 1 := by
  apply Classical.byContradiction
  intro h
  have ep := even_returns hp (by omega)
  have eq := even_returns hq (by omega)
  have er := even_returns hr (by omega)
  omega

/-- If no more events occur, after one step the gate is on the two-state
gap-2 cycle. This statement also allows an initially partial kick gap. -/
theorem quiet_tail_two_cycle (v : Nat → State) (hs : ∀ i, step (v i) (v (i+1)) = true)
    (T : Nat) (hm : ∀ i, T ≤ i → mark (v i) = false) :
    ∀ i, T+1 ≤ i → v (i+2) = v i := by
  have quietFour : ∀ w x y z : State, step w x = true → step x y = true → step y z = true →
      mark w = false → mark x = false → mark y = false → mark z = false → gap x = 2 :=
    by decide +kernel
  have two (i : Nat) (hi : T+1 ≤ i) : gap (v i) = 2 := by
    obtain ⟨j, rfl⟩ : ∃ j, i = j+1 := ⟨i-1, by omega⟩
    exact quietFour _ _ _ _ (hs j) (hs (j+1)) (hs (j+2)) (hm _ (by omega))
      (hm _ (by omega)) (hm _ (by omega)) (hm _ (by omega))
  have returns : ∀ x y z : State, gap x = 2 → gap y = 2 → gap z = 2 →
      step x y = true → step y z = true → z = x := by decide +kernel
  intro i hi
  exact returns _ _ _ (two i hi) (two _ (by omega)) (two _ (by omega)) (hs i) (hs (i+1))

/-- An aperiodic kick stream on an infinite GE2 path has arbitrarily late
events. A kick is the first state of its gap. -/
theorem events_unbounded (v : Nat → State) (hs : ∀ i, step (v i) (v (i+1)) = true)
    (nonperiodic : ¬ ∃ T p : Nat, 0 < p ∧ ∀ i, T ≤ i →
      (offset (v (i+p)) = 0 ↔ offset (v i) = 0)) :
    ∀ T, ∃ i, T ≤ i ∧ mark (v i) = true := by
  intro T
  apply Classical.byContradiction
  intro absent
  have hm (i : Nat) (hi : T ≤ i) : mark (v i) = false := by
    cases h : mark (v i)
    · rfl
    · exact False.elim (absent ⟨i, hi, h⟩)
  apply nonperiodic
  exact ⟨T+1, 2, by decide, fun i hi => by rw [quiet_tail_two_cycle v hs T hm i hi]⟩

private theorem next_return (v : Nat → State) (hs : ∀ i, step (v i) (v (i+1)) = true)
    (late : ∀ T, ∃ i, T ≤ i ∧ mark (v i) = true) (i : Nat) (hi : mark (v i) = true) :
    ∃ n, Returns (v i) (v (i+n)) n := by
  let P (n : Nat) := 0 < n ∧ mark (v (i+n)) = true
  obtain ⟨j, hj, hm⟩ := late (i+1)
  have existsP : ∃ n, P n := ⟨j-i, by omega, by simpa [show i+(j-i)=j by omega]⟩
  have least (n : Nat) (hn : P n) : ∃ m, P m ∧ ∀ k, k < m → ¬ P k := by
    induction n using Nat.strongRecOn with
    | ind n ih =>
      by_cases smaller : ∃ m, m < n ∧ P m
      · obtain ⟨m, hlt, hm⟩ := smaller
        exact ih m hlt hm
      · exact ⟨n, hn, fun k hk hp => smaller ⟨k, hk, hp⟩⟩
  obtain ⟨n, hn, earlier⟩ := existsP.elim least
  have walk (m : Nat) (bound : m ≤ n) : quietTo (v i) m (v (i+m)) := by
    induction m with
    | zero => rfl
    | succ m ih =>
      refine ⟨v (i+m), ih (by omega), ?_, hs (i+m)⟩
      by_cases h : m = 0
      · exact Or.inl h
      · apply Or.inr
        cases e : mark (v (i+m))
        · rfl
        · exact False.elim (earlier m (by omega) ⟨by omega, e⟩)
  exact ⟨n, hn.1, hi, hn.2, walk n (by omega)⟩

/-- In an infinite GE2 path with a nonperiodic kick stream, both parities of
white-to-white time have arbitrarily late events. -/
theorem both_phases_unbounded (v : Nat → State) (hs : ∀ i, step (v i) (v (i+1)) = true)
    (nonperiodic : ¬ ∃ T p : Nat, 0 < p ∧ ∀ i, T ≤ i →
      (offset (v (i+p)) = 0 ↔ offset (v i) = 0)) (T : Nat) (phase : Fin 2) :
    ∃ i, T ≤ i ∧ i%2 = phase.val ∧ mark (v i) = true := by
  have late := events_unbounded v hs nonperiodic
  obtain ⟨i, hi, first⟩ := late T
  obtain ⟨p, hp⟩ := next_return v hs late i first
  obtain ⟨q, hq⟩ := next_return v hs late (i+p) hp.2.2.1
  obtain ⟨r, hr⟩ := next_return v hs late (i+p+q) hq.2.2.1
  have odd := four_events_both_phases hp hq hr
  have cases4 : i%2 = phase.val ∨ (i+p)%2 = phase.val ∨
      (i+p+q)%2 = phase.val ∨ (i+p+q+r)%2 = phase.val := by omega
  rcases cases4 with h | h | h | h
  · exact ⟨_, hi, h, first⟩
  · exact ⟨_, by omega, h, hp.2.2.1⟩
  · exact ⟨_, by omega, h, hq.2.2.1⟩
  · exact ⟨_, by omega, h, hr.2.2.1⟩

end Ruliology.CellularAutomata.Rule30GE2Phase
