module

public import Ruliology.CellularAutomata.Rule30PeriodTwoSideways

/-!
# Repetitions of variable-duration excursions beside a finite left edge

Troy Lowry's PR #379 applies the kit's quantitative Jen bound to equal windows of
the gate sampled on white ticks. Here a letter can encode any nonempty gate word.
Equal excursion blocks give an exact bound involving the two physical clock times.
We specialize it to the width-43 X spacings of R69 whose edges attain equality in
the spacing potential. The physical premise is a reading of the actual gate.
One time unit below is two Rule 30 ticks.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30ExcursionClocks

open Rule30ZeroBoundary
open Rule30PeriodTwoSideways (Psi u Psi_free Psi_inX)

def BlockEq {α : Type} (a : Nat → α) (i j n : Nat) : Prop :=
  ∀ k, k < n → a (i+k) = a (j+k)

/-- The emitted bits may be different for every letter and its duration may vary. -/
structure Clock {α : Type} (v : Nat → Bool) (a : Nat → α)
    (width : α → Nat) (emit : α → Nat → Bool) where
  time : Nat → Nat
  positive : ∀ i, 0 < width (a i)
  next : ∀ i, time (i+1) = time i + width (a i)
  reads : ∀ i k, k < width (a i) → v (time i + k) = emit (a i) k

private theorem time_lt {α : Type} {a : Nat → α} {v width emit}
    (c : Clock v a width emit) {i j : Nat}
    (ij : i < j) : c.time i < c.time j := by
  induction j with
  | zero => omega
  | succ j ih =>
    rw [c.next]
    have := c.positive j
    by_cases h : i = j
    · subst i; omega
    · have := ih (by omega)
      omega

private theorem same_bits {α : Type} {a : Nat → α} {v width emit} (c : Clock v a width emit)
    {i j n : Nat} (eq : BlockEq a i j n) (k : Nat)
    (hk : c.time j + k < c.time (j+n)) :
    v (c.time i + k) = v (c.time j + k) := by
  induction n generalizing i j k with
  | zero => simp at hk; omega
  | succ n ih =>
    have first : a i = a j := by simpa using eq 0 (by omega)
    have w : width (a i) = width (a j) := congrArg width first
    by_cases early : k < width (a j)
    · rw [c.reads i k (by omega), c.reads j k early, first]
    · have tail : BlockEq a (i+1) (j+1) n := by
        intro q hq
        simpa only [Nat.add_assoc, Nat.add_comm 1 q] using eq (q+1) (by omega)
      have hi := c.next i
      have hj := c.next j
      have bound : c.time (j+1) + (k - width (a j)) < c.time ((j+1)+n) := by
        rw [show j+1+n = j+(n+1) by omega]
        omega
      have bit := ih tail (k - width (a j)) bound
      rwa [show c.time (i+1) + (k - width (a j)) = c.time i + k by omega,
           show c.time (j+1) + (k - width (a j)) = c.time j + k by omega] at bit

/-- Lowry's sampled-edge argument, applied directly to the compatible row in the merged kit. -/
private theorem sample_bound (R : Nat → Bool) {m s t w : Nat} (hm : 1 ≤ m)
    (hb : Psi R m = true) (hz : ∀ k, m < k → Psi R k = false)
    (st : s < t) (eq : BlockEq (u R) s t w) : 2*w+1 < m+2*t := by
  have clock := jen_clock hm hb hz (T := 2*s) (P := 2*(t-s))
    (ℓ := 2*(t-s)+2*w) (by omega) (by
      intro q start stop
      by_cases even : q%2=0
      · rw [show q+2*(t-s)=2*(q/2+(t-s)) by omega, Psi_inX R,
            show q=2*(q/2) by omega, Psi_inX R]
      · let k := q/2-s
        have oddBit (x : Nat) : zrow (Psi R) (2*x+1) 1 = !u R x := Psi_free R x
        calc
          zrow (Psi R) (q+2*(t-s)) 1 = zrow (Psi R) (2*(t+k)+1) 1 := by
            congr 1; dsimp [k]; omega
          _ = !u R (t+k) := oddBit _
          _ = !u R (s+k) := congrArg Bool.not (eq k (by dsimp [k]; omega)).symm
          _ = zrow (Psi R) (2*(s+k)+1) 1 := (oddBit _).symm
          _ = zrow (Psi R) q 1 := by congr 1; dsimp [k]; omega)
  omega

/-- Exact repeat deadline for every size and every variable-duration reading of the gate. -/
theorem repeat_deadline (R : Nat → Bool) {α : Type} {a : Nat → α} {width emit}
    (c : Clock (u R) a width emit) {m i j n : Nat} (hm : 1 ≤ m)
    (hb : Psi R m = true) (hz : ∀ k, m < k → Psi R k = false)
    (ij : i < j) (eq : BlockEq a i j n) :
    2*c.time (j+n)+1 < m+4*c.time j := by
  have mono : c.time j ≤ c.time (j+n) := by
    cases n with
    | zero => simp
    | succ n => exact Nat.le_of_lt (time_lt c (by omega))
  have bits : BlockEq (u R) (c.time i) (c.time j) (c.time (j+n)-c.time j) :=
    fun k hk => same_bits c eq k (by omega)
  have := sample_bound R hm hb hz (time_lt c ij) bits
  omega

/-- A rational enclosure for the mean duration at the two endpoints of a repeat.
No frequency of individual letters is assumed. -/
theorem slope_repeat_bound (R : Nat → Bool) {α : Type} {a : Nat → α} {width emit}
    (c : Clock (u R) a width emit) {m i j n p d : Nat} (hm : 1 ≤ m)
    (hb : Psi R m = true) (hz : ∀ k, m < k → Psi R k = false)
    (ij : i < j) (eq : BlockEq a i j n) (hd : 0 < d)
    (lower : p*(j+n) ≤ d*c.time (j+n)) (upper : d*c.time j ≤ (p+2)*j) :
    2*(p*n) < 2*(p*j) + 8*j + d*m := by
  have h := Nat.mul_lt_mul_of_pos_left (repeat_deadline R c hm hb hz ij eq) hd
  rw [Nat.mul_add, Nat.mul_left_comm d 2, Nat.mul_one, Nat.mul_add,
      Nat.mul_left_comm d 4] at h
  rw [Nat.mul_add] at lower
  rw [Nat.add_mul] at upper
  omega

/-- Arbitrarily fine, eventually valid rational brackets for the prefix mean
duration. Any clock with a strictly positive finite limiting mean satisfies this.
At denominator d, endpoints two units apart can straddle even an integer mean. -/
def StableMean (time : Nat → Nat) : Prop :=
  ∀ M, ∃ p d J : Nat, M ≤ p ∧ 0 < d ∧
    ∀ k ≥ J, p*k ≤ d*time k ∧ d*time k ≤ (p+2)*k

/-- An infinite family of early repeats with a fixed relative excess defeats
every finite left support when the physical excursion clock has a stable mean. -/
theorem stable_mean_infinite_support (R : Nat → Bool) {α : Type} {a : Nat → α}
    {width emit} (c : Clock (u R) a width emit) (stable : StableMean c.time)
    (early : ∃ r : Nat, 0 < r ∧ ∀ J, ∃ i j n, J ≤ j ∧ i < j ∧
      BlockEq a i j n ∧ (r+1)*j ≤ r*n) : ¬ FinSupp (Psi R) := by
  rintro ⟨W, beyond⟩
  obtain ⟨m, hm, hb, hz⟩ := last_black (show Psi R 1 = true from Psi_inX R 0) W beyond
  obtain ⟨r, hr, repeats⟩ := early
  obtain ⟨p, d, J, hp, hd, bracket⟩ := stable (4*r+1)
  obtain ⟨i,j,n,hj,ij,eq,ratio⟩ := repeats (J + r*(d*m) + 1)
  have upper := (bracket j (by omega)).2
  have lower := (bracket (j+n) (by omega)).1
  have bound := slope_repeat_bound R c hm hb hz ij eq hd lower upper
  have scaled := Nat.mul_lt_mul_of_pos_left bound hr
  have longer := Nat.mul_le_mul_left p ratio
  have steep := Nat.mul_le_mul_right j hp
  grind

/-- R69's five spacing transitions with zero slack in the width-43 potential. -/
inductive Phase | ready | short | seven

inductive Tight : Phase → Nat → Phase → Prop
  | four : Tight .ready 4 .short
  | shortSeven : Tight .short 7 .seven
  | shortTen : Tight .short 10 .ready
  | sevenSeven : Tight .seven 7 .seven
  | sevenTen : Tight .seven 10 .ready

def lag : Phase → Nat
  | .ready => 0
  | .short | .seven => 21

def excursionWidth (spacing : Nat) := 34+7*spacing

/-- E = 33535555, followed by as many copies of A = 25 as the spacing specifies. -/
def excursionBit (_spacing offset : Nat) : Bool :=
  if offset < 34 then [0,3,6,11,14,19,24,29].contains offset
  else decide ((offset-34)%7=0 ∨ (offset-34)%7=2)

private theorem tight_duration {p q a} (e : Tight p a q) :
    excursionWidth a + lag q = 83 + lag p := by cases e <;> decide

private theorem telescope {v a} (c : Clock v a excursionWidth excursionBit)
    (q : Nat → Phase) (edges : ∀ k, Tight (q k) (a k) (q (k+1))) (k : Nat) :
    c.time k + lag (q k) = c.time 0 + lag (q 0) + 83*k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have tick := tight_duration (edges k)
    rw [c.next]
    omega

/-- Equal blocks of the fastest exterior excursions cannot run arbitrarily far ahead
of their second start if the compatible left row is finite. Startup is arbitrary. -/
theorem tight_X_repeat (R : Nat → Bool) {a : Nat → Nat}
    (c : Clock (u R) a excursionWidth excursionBit) (q : Nat → Phase)
    (start : q 0 = .ready) (edges : ∀ k, Tight (q k) (a k) (q (k+1)))
    {m i j n : Nat} (hm : 1 ≤ m) (hb : Psi R m = true)
    (hz : ∀ k, m < k → Psi R k = false) (ij : i < j) (eq : BlockEq a i j n) :
    166*n < 166*j + m + 2*c.time 0 + 41 := by
  have h := repeat_deadline R c hm hb hz ij eq
  have endClock := telescope c q edges (j+n)
  have startClock := telescope c q edges j
  have maxLag : lag (q (j+n)) ≤ 21 := by cases q (j+n) <;> decide
  have startLag : lag (q 0) = 0 := by rw [start]; rfl
  rw [startLag, Nat.add_zero] at endClock startClock
  omega

/-- A test on the excursion order alone, with no given size for the left support. -/
theorem tight_X_infinite_support (R : Nat → Bool) {a : Nat → Nat}
    (c : Clock (u R) a excursionWidth excursionBit) (q : Nat → Phase)
    (start : q 0 = .ready) (edges : ∀ k, Tight (q k) (a k) (q (k+1)))
    (early : ∀ K, ∃ i j n, i < j ∧ BlockEq a i j n ∧ j+K ≤ n) :
    ¬ FinSupp (Psi R) := by
  rintro ⟨W, beyond⟩
  obtain ⟨m, hm, hb, hz⟩ := last_black (show Psi R 1 = true from Psi_inX R 0) W beyond
  obtain ⟨i, j, n, ij, eq, large⟩ := early (m+2*c.time 0+41)
  have := tight_X_repeat R c q start edges hm hb hz ij eq
  omega

/-- The kth excursion block is 4, then 4^k copies of 7, then 10. Each such
block returns the width-43 spacing machine from ready to ready. -/
def blockStart : Nat → Nat
  | 0 => 0
  | k+1 => blockStart k + 4^k + 2

def SparseX (a : Nat → Nat) : Prop := ∀ k,
  a (blockStart k) = 4 ∧ (∀ h < 4^k, a (blockStart k + 1 + h) = 7) ∧
  a (blockStart k + 1 + 4^k) = 10

private theorem block_room (k : Nat) : blockStart (k+2)+k+5 ≤ 4^(k+2) := by
  induction k with
  | zero => decide
  | succ k ih =>
    rw [show k+1+2 = (k+2)+1 by omega, blockStart, Nat.pow_succ 4 (k+2)]
    omega

theorem sparse_X_aperiodic {a : Nat → Nat} (h : SparseX a) :
    ¬ ∃ T P : Nat, 0 < P ∧ ∀ n ≥ T, a (n+P) = a n := by
  rintro ⟨T,P,hP,period⟩
  let k := T+P+2
  have large (b : Nat) : b ≤ blockStart b := by
    induction b with
    | zero => decide
    | succ b ih =>
      rw [blockStart]
      have := Nat.le_add_right (blockStart b) (4^b)
      exact Nat.le_trans (Nat.succ_le_succ ih) (by omega)
  have tail := large k
  have room := block_room (T+P)
  have inside : P-1 < 4^k := by dsimp [k]; omega
  have active := Nat.le_trans (show T ≤ k by dsimp [k]; omega) tail
  have z := (h k).2.1 (P-1) inside
  rw [show blockStart k+1+(P-1)=blockStart k+P by omega,
      period _ active, (h k).1] at z
  contradiction

/-- A specific aperiodic spacing order obeying the zero-slack grammar is
incompatible with a finitely supported reconstructed left half. -/
theorem sparse_X_infinite_support (R : Nat → Bool) {a : Nat → Nat} (h : SparseX a)
    (c : Clock (u R) a excursionWidth excursionBit) (q : Nat → Phase)
    (start : q 0 = .ready) (edges : ∀ k, Tight (q k) (a k) (q (k+1))) :
    ¬ FinSupp (Psi R) := by
  apply tight_X_infinite_support R c q start edges
  intro K
  let k := K+2
  have room := block_room K
  refine ⟨blockStart k+1, blockStart k+2, 4^k-1, by omega, ?_, ?_⟩
  · intro h' hh
    have first := (h k).2.1 h' (by omega)
    have second := (h k).2.1 (1+h') (by omega)
    rw [show blockStart k+1+(1+h')=blockStart k+2+h' by omega] at second
    exact first.trans second.symm
  · dsimp [k]
    omega

private def advance (b h : Nat) : Nat × Nat :=
  if h = 4^b+1 then (b+1,0) else (b,h+1)

private def cursor : Nat → Nat × Nat
  | 0 => (0,0)
  | n+1 => advance (cursor n).1 (cursor n).2

private theorem cursor_within (b h : Nat) (base : cursor (blockStart b) = (b,0))
    (inside : h ≤ 4^b+1) : cursor (blockStart b+h) = (b,h) := by
  induction h with
  | zero => simpa using base
  | succ h ih =>
    change advance (cursor (blockStart b+h)).1 (cursor (blockStart b+h)).2 = _
    rw [ih (by omega)]
    simp [advance, show h ≠ 4^b+1 by omega]

private theorem cursor_start (b : Nat) : cursor (blockStart b) = (b,0) := by
  induction b with
  | zero => rfl
  | succ b ih =>
    have endPos := cursor_within b (4^b+1) ih (by omega)
    rw [blockStart, show blockStart b+4^b+2 = (blockStart b+(4^b+1))+1 by omega,
        cursor, endPos]
    simp [advance]

private def spacingAt (b h : Nat) : Nat :=
  if h=0 then 4 else if h=4^b+1 then 10 else 7

private def phaseAt (h : Nat) : Phase :=
  if h=0 then .ready else if h=1 then .short else .seven

private theorem cursor_edge (b h : Nat) (inside : h ≤ 4^b+1) :
    Tight (phaseAt h) (spacingAt b h) (phaseAt (advance b h).2) := by
  have pos := Nat.pow_pos (by decide : 0 < 4) (n := b)
  by_cases first : h=0
  · subst h; simpa [advance, phaseAt, spacingAt] using Tight.four
  by_cases last : h=4^b+1
  · subst h
    simpa [advance, phaseAt, spacingAt, show 4^b+1 ≠ 1 by omega] using Tight.sevenTen
  by_cases second : h=1
  · subst h; simpa [advance, phaseAt, spacingAt, last] using Tight.shortSeven
  · simpa [advance, phaseAt, spacingAt, first, last, second] using Tight.sevenSeven

/-- A legal aperiodic exterior spacing order for which every physical reading
forces infinite support on the compatible left. No realization by a right half
is needed for the exclusion. -/
theorem exists_aperiodic_X_exclusion :
    ∃ a : Nat → Nat, (∃ q : Nat → Phase, q 0 = .ready ∧
        ∀ k, Tight (q k) (a k) (q (k+1))) ∧
      (¬ ∃ T P : Nat, 0 < P ∧ ∀ n ≥ T, a (n+P) = a n) ∧
      ∀ R : Nat → Bool, Clock (u R) a excursionWidth excursionBit → ¬ FinSupp (Psi R) := by
  let a := fun n => spacingAt (cursor n).1 (cursor n).2
  let q := fun n => phaseAt (cursor n).2
  have inside (n : Nat) : (cursor n).2 ≤ 4^(cursor n).1+1 := by
    induction n with
    | zero => decide
    | succ n ih =>
      rw [cursor]; unfold advance; split <;> simp_all <;> omega
  have edges (n : Nat) : Tight (q n) (a n) (q (n+1)) :=
    cursor_edge _ _ (inside n)
  have shape : SparseX a := by
    intro b
    have value (h : Nat) (hh : h ≤ 4^b+1) : a (blockStart b+h) = spacingAt b h := by
      simp only [a, cursor_within b h (cursor_start b) hh]
    refine ⟨?_, ?_, ?_⟩
    · simpa [spacingAt] using value 0 (Nat.zero_le _)
    · intro h hh
      rw [show blockStart b+1+h = blockStart b+(h+1) by omega, value _ (by omega)]
      simp [spacingAt, show h ≠ 4^b by omega]
    · rw [show blockStart b+1+4^b=blockStart b+(4^b+1) by omega, value _ (by omega)]
      simp [spacingAt]
  exact ⟨a, ⟨q,rfl,edges⟩, sparse_X_aperiodic shape,
    fun R c => sparse_X_infinite_support R shape c q rfl edges⟩

end Ruliology.CellularAutomata.Rule30ExcursionClocks
