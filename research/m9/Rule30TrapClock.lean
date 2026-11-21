module
public import TrapClockCertificate
public import TrapClockWindow
public import Rule30ExcursionClocks

/-! The cost of the actual 3/5 white-slot gaps after odd-time entry into the 16-column trap.
The clock and the physical finite-edge comparison come from I48 on the merged kit. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30TrapClock
open Rule30GateTrap TrapClockWindow Rule30PeriodTwoSideways Rule30ZeroBoundary
open Rule30ExcursionClocks TrapClockCertificate

/-- I48's clock specialized to a gap of 3 or 5 white slots, with a kick at its first slot. -/
structure GapClock (v : Nat → Bool) where
  gap : Nat → Nat
  lengths : ∀ i, gap i = 3 ∨ gap i = 5
  samples : Clock v gap id (fun _ k => decide (k = 0))

abbrev GapClock.time {v : Nat → Bool} (c : GapClock v) := c.samples.time

/-- Every black sample following odd-time trap entry starts an infinite 3/5 gap clock. -/
theorem exists_clock (R : Nat → Bool) {t₀ s : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (after : t₀ ≤ 2*s+1) (black : u R s = true) :
    ∃ c : GapClock (u R), c.time 0 = s := by
  let Slot := {q : Nat // t₀ ≤ 2*q+1 ∧ u R q = true}
  let gap (q : Slot) : Nat := if u R (q.val+3) then 3 else 5
  have advanceFacts (q : Slot) : u R (q.val+gap q) = true ∧
      ∀ k, k < gap q → u R (q.val+k) = decide (k=0) := by
    obtain h | h := gaps_of_entry R odd entered q.val q.property.1 q.property.2
    · obtain ⟨h1,h2,h3⟩ := h
      have g : gap q = 3 := by simp [gap,h3]
      refine ⟨g ▸ h3, ?_⟩
      intro k hk
      rw [g] at hk
      have casesK : k=0 ∨ k=1 ∨ k=2 := by omega
      rcases casesK with rfl|rfl|rfl <;> simp [q.property.2, *]
    · obtain ⟨h1,h2,h3,h4,h5⟩ := h
      have g : gap q = 5 := by simp [gap,h3]
      refine ⟨g ▸ h5, ?_⟩
      intro k hk
      rw [g] at hk
      have casesK : k=0 ∨ k=1 ∨ k=2 ∨ k=3 ∨ k=4 := by omega
      rcases casesK with rfl|rfl|rfl|rfl|rfl <;> simp [q.property.2, *]
  let advance (q : Slot) : Slot := ⟨q.val+gap q, by
    have h := q.property.1
    constructor
    · omega
    · exact (advanceFacts q).1⟩
  let term : Nat → Slot := Nat.rec (⟨s,after,black⟩ : Slot) (fun _ q => advance q)
  refine ⟨{gap := fun i => gap (term i), lengths := ?_,
           samples := {time := fun i => (term i).val, next := fun _ => rfl,
                       positive := ?_, reads := fun i => (advanceFacts (term i)).2}}, rfl⟩
  · intro i
    simp only [gap]
    split <;> simp
  · intro i
    simp only [id_eq, gap]
    split <;> decide

/-- Initial colors at columns 1,2,... are bits 0,1,... of 1164. -/
def witness (p : Nat) : Bool := (1164 : Nat).testBit (p-1)

theorem witness_enters : win witness 1 ∈ trap := by
  have W : win witness 1 = decode 4055 := by decide +kernel
  rw [W]
  exact List.mem_map.mpr ⟨4055, by decide +kernel, rfl⟩

theorem witness_first_seven : (List.range 7).map (u witness) =
    [true,false,false,true,false,false,true] := by decide +kernel

/-- The additive ten in the physical uniform estimate is attained by two actual gaps. -/
theorem sharp_transient : ∃ c : GapClock (u witness),
    c.time 0 = 0 ∧ c.gap 0 = 3 ∧ c.gap 1 = 3 ∧ 17*2 = 4*(c.time 2-c.time 0)+10 := by
  have b : u witness 0 = true := by decide +kernel
  obtain ⟨c,zero⟩ := exists_clock witness (t₀ := 1) (s := 0)
    (by decide) witness_enters (by decide) b
  have g0 : c.gap 0 = 3 := by
    rcases c.lengths 0 with ok | five
    · exact ok
    · have H : u witness (c.time 0+3) = false := c.samples.reads 0 3 (show 3 < c.gap 0 by omega)
      rw [zero] at H
      have B : u witness (0+3) = true := by decide +kernel
      simp [B] at H
  have one : c.time 1 = 3 := by simpa [zero,g0] using c.samples.next 0
  have g1 : c.gap 1 = 3 := by
    rcases c.lengths 1 with ok | five
    · exact ok
    · have H : u witness (c.time 1+3) = false := c.samples.reads 1 3 (show 3 < c.gap 1 by omega)
      rw [one] at H
      have B : u witness (3+3) = true := by decide +kernel
      simp [B] at H
  have two : c.time 2 = 6 := by simpa [one,g1] using c.samples.next 1
  exact ⟨c,zero,g0,g1,by rw [zero,two]⟩

private def height (R : Nat → Bool) (s : Nat) : Nat := potential (win18 R (2*s+1))

private theorem one_step (R : Nat → Bool) {t₀ : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) {s : Nat} (after : t₀ ≤ 2*s+1) :
    height R (s+1) + (if u R (s+1) then 17 else 0) ≤ height R s + 4 := by
  have mem := win_mem_trap R odd entered ((2*s+1-t₀)/2)
  rw [show t₀ + 2 * ((2*s+1-t₀)/2) = 2*s+1 by omega] at mem
  obtain ⟨x,y,hxy⟩ := win18_step2 R (2*s+1) (by omega)
  have H := local_step mem (Rule30Ether.drv Rule30PeriodTwoCoupled.altCol R (2*s+1) 17)
    (Rule30Ether.drv Rule30PeriodTwoCoupled.altCol R (2*s+1) 18) x y
  rw [← win18_eq, ← hxy] at H
  unfold inequality at H
  have bound := of_decide_eq_true H
  rw [show 2*s+1+2 = 2*(s+1)+1 by omega, win18_head] at bound
  exact bound

private theorem walk (R : Nat → Bool) {t₀ s : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (after : t₀ ≤ 2*s+1) (d : Nat) :
    height R (s+d) ≤ height R s + 4*d := by
  induction d with
  | zero => simp
  | succ d ih =>
    have next := one_step R odd entered (s := s+d) (by omega)
    rw [show s + d + 1 = s + (d + 1) by omega] at next
    omega

private theorem black_to_black (R : Nat → Bool) {t₀ s d : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (after : t₀ ≤ 2*s+1) (pos : 0 < d)
    (black : u R (s+d) = true) : height R (s+d) + 17 ≤ height R s + 4*d := by
  cases d with
  | zero => omega
  | succ k =>
    have W := walk R odd entered after k
    have S := one_step R odd entered (s := s+k) (by omega)
    rw [show s+k+1 = s+(k+1) by omega, black] at S
    simp only [↓reduceIte] at S
    omega

private theorem black_sample {v : Nat → Bool} (c : GapClock v) (i : Nat) :
    v (c.time i) = true := by
  have lens := c.lengths i
  simpa using c.samples.reads i 0 (show 0 < c.gap i by omega)

private theorem height_at_kick (R : Nat → Bool) (c : GapClock (u R)) (i : Nat) :
    height R (c.time i) ≤ 10 := by
  have b := black_sample c i
  have hb : (win18 R (2*c.time i+1)).headD false = true := by rw [win18_head]; exact b
  unfold height potential
  rw [hb]
  exact Nat.min_le_left _ _


private theorem telescope (R : Nat → Bool) {t₀ : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (c : GapClock (u R)) (n i : Nat)
    (after : t₀ ≤ 2*c.time i+1) :
    height R (c.time (i+n)) + 17*n + 4*c.time i ≤ height R (c.time i) + 4*c.time (i+n) := by
  induction n generalizing i with
  | zero => simp
  | succ n ih =>
    have next : c.time (i+1) = c.time i + c.gap i := c.samples.next i
    have lens := c.lengths i
    have black := black_sample c (i+1)
    rw [next] at black
    have step := black_to_black R odd entered after (d := c.gap i) (by omega) black
    rw [← next] at step
    have tail := ih (i+1) (by omega)
    rw [show (i+1)+n = i+(n+1) by omega] at tail
    omega

/-- The first n gaps from any post-entry kick take D white slots with 17n ≤ 4D+10. -/
theorem physical_span (R : Nat → Bool) {t₀ : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (c : GapClock (u R)) (i n : Nat)
    (after : t₀ ≤ 2*c.time i+1) : 17*n ≤ 4*(c.time (i+n)-c.time i) + 10 := by
  have := telescope R odd entered c n i after
  have := height_at_kick R c i
  omega

private theorem upper_time {v} (c : GapClock v) (j : Nat) :
    c.time j ≤ c.time 0 + 5*j := by
  induction j with
  | zero => simp
  | succ j ih =>
    have next : c.time (j+1) = c.time j + c.gap j := c.samples.next j
    have lengths := c.lengths j
    omega

/-- Equal n-gap blocks starting at i < j obey this deadline for a finite compatible left.
Only the later occurrence must start after entry. -/
theorem physical_repeat (R : Nat → Bool) {t₀ m : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (c : GapClock (u R)) (hm : 1 ≤ m)
    (black : Psi R m = true) (white : ∀ k, m < k → Psi R k = false)
    {i j n : Nat} (ij : i < j) (after : t₀ ≤ 2*c.time j+1)
    (eq : BlockEq c.gap i j n) : 17*n ≤ 20*j + 2*m + 4*c.time 0 + 6 := by
  have edge := repeat_deadline R c.samples hm black white ij eq
  have valid := telescope R odd entered c n j after
  have height := height_at_kick R c j
  have upper := upper_time c j
  change 2*c.time (j+n)+1 < m+4*c.time j at edge
  omega

/-- Unbounded 17n−20j on equal blocks whose second copy starts after entry gives
infinite left support, with no hypothesis on a limiting mean or gap separation. -/
theorem infinite_left_of_early_repeats (R : Nat → Bool) {t₀ : Nat} (odd : t₀ % 2 = 1)
    (entered : win R t₀ ∈ trap) (c : GapClock (u R))
    (repeats : ∀ K, ∃ i j n, i < j ∧ t₀ ≤ 2*c.time j+1 ∧ BlockEq c.gap i j n ∧ 20*j+K ≤ 17*n) :
    ¬ FinSupp (Psi R) := by
  rintro ⟨width, beyond⟩
  obtain ⟨m, hm, b, tail⟩ := last_black (show Psi R 1 = true from Psi_inX R 0) width beyond
  obtain ⟨i,j,n,ij,after,eq,large⟩ := repeats (2*m+4*c.time 0+7)
  have := physical_repeat R odd entered c hm b tail ij after eq
  omega

end Ruliology.CellularAutomata.Rule30TrapClock
