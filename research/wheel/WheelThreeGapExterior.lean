module
public import Ruliology.CellularAutomata.Rule30GateTrap
public import Ruliology.CellularAutomata.Rule30FiniteMaskedJen

/-! The October rotating 84-ring sustains the all-three gate outside Bosdure's
trap. Every finite observation also occurs on a right row of finite support.
The wall is black at time zero, as in the kit. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelThreeGapExterior
open Rule30Ether Rule30PeriodTwoCoupled Rule30PeriodTwoSideways Rule30GateTrap
open Rule30Jen (rule)

/-- Bit zero is the wall. This is the spatial phase 65 of the 84-cell row in
`Rule30ClockDensityExamples`; each update rotates it 14 cells to the right. -/
def ring (p : Nat) : Bool := (0xc7b9a23add2917bec2099 : Nat).testBit (p % 84)

def film (t p : Nat) : Bool := ring (p + 70*t)

private theorem wrap (n : Nat) :
    ring (n+71) = rule (ring n) (ring (n+1)) (ring (n+2)) := by
  have h : ∀ i : Fin 84, ring (i.val+71) = rule (ring i.val) (ring (i.val+1)) (ring (i.val+2)) := by
    decide +kernel
  simpa only [ring, Nat.mod_add_mod, Nat.mod_mod] using h ⟨n%84, Nat.mod_lt _ (by decide)⟩

theorem film_rule : IsR30 film := by
  intro t p
  simpa only [film, show p+1+70*(t+1) = p+70*t+71 by omega,
    show p+1+70*t = p+70*t+1 by omega, show p+2+70*t = p+70*t+2 by omega] using wrap (p+70*t)

private theorem film_mod (t p : Nat) : film t p = film (t%6) p := by
  unfold film ring
  rw [show (p+70*t)%84 = (p+70*(t%6))%84 by omega]

theorem wall (t : Nat) : film t 0 = altCol t := by
  have h : ∀ i : Fin 6, film i.val 0 = altCol i.val := by decide +kernel
  rw [film_mod]
  simpa only [altCol, show t%6%2=t%2 by omega] using h ⟨t%6, Nat.mod_lt _ (by decide)⟩

theorem driven_ring (t p : Nat) : drv altCol ring t p = film t p := by
  induction t generalizing p with
  | zero =>
    cases p with
    | zero => exact (drv_col0 _ _ _).trans (wall 0).symm
    | succ p => exact drv_init _ _ _ (Nat.succ_pos p)
  | succ t ih =>
    cases p with
    | zero => exact (drv_col0 _ _ _).trans (wall _).symm
    | succ p => rw [drv_isR30, film_rule, ih, ih, ih]

private theorem sample_mod (s p : Nat) : film (2*s+1) p = film (2*(s%3)+1) p := by
  rw [film_mod, show (2*s+1)%6 = 2*(s%3)+1 by omega]

/-- There is one kick per three white samples and the true width-16 window
stays outside the trap at every sample, for a single fixed infinite right row. -/
theorem outside_forever (s : Nat) :
    u ring s = (s%3 == 0) ∧ win ring (2*s+1) ∉ trap := by
  have hg : ∀ i : Fin 3, film (2*i.val+1) 1 = (i.val == 0) := by decide +kernel
  have hw : ∀ i : Fin 3, rowOf film (2*i.val+1) 0 16 ∉ trap := by decide +kernel
  constructor
  · change drv altCol ring (2*s+1) 1 = _
    rw [driven_ring, sample_mod]
    exact hg ⟨s%3, Nat.mod_lt _ (by decide)⟩
  · change rowOf (drv altCol ring) (2*s+1) 0 16 ∉ trap
    have same : rowOf (drv altCol ring) (2*s+1) 0 16 = rowOf film (2*(s%3)+1) 0 16 := by
      apply Rule30Ether.seg_congr
      intro i _
      rw [driven_ring, sample_mod]
    rw [same]
    exact hw ⟨s%3, Nat.mod_lt _ (by decide)⟩

private theorem cone {R S : Nat → Bool} {n : Nat} (same : ∀ p, 0<p → p≤n → R p=S p)
    (t p : Nat) (bound : p+t≤n) : drv altCol R t p = drv altCol S t p := by
  induction t generalizing p with
  | zero =>
    cases p with
    | zero => rw [drv_col0, drv_col0]
    | succ p => rw [drv_init _ _ _ (by omega), drv_init _ _ _ (by omega), same _ (by omega) (by omega)]
  | succ t ih =>
    cases p with
    | zero => rw [drv_col0, drv_col0]
    | succ p => rw [drv_isR30, drv_isR30, ih p (by omega), ih (p+1) (by omega), ih (p+2) (by omega)]

/-- The length can be prescribed before choosing a finite-support initial row. -/
theorem arbitrarily_long_finite (N : Nat) : ∃ R : Nat → Bool,
    (∀ p, 2*N+16 < p → R p = false) ∧
    ∀ s, s<N → u R s = (s%3 == 0) ∧ win R (2*s+1) ∉ trap := by
  let R := fun p => if p ≤ 2*N+16 then ring p else false
  have same : ∀ p, 0<p → p≤2*N+16 → R p=ring p := fun p _ h => by simp [R,h]
  refine ⟨R, fun p hp => by simp [R, Nat.not_le.mpr hp], fun s hs => ?_⟩
  have g : u R s = u ring s := cone same (2*s+1) 1 (by omega)
  have w : win R (2*s+1) = win ring (2*s+1) := by
    unfold win rowOf
    apply Rule30Ether.seg_congr
    intro i hi
    exact cone same _ _ (by omega)
  rw [g,w]
  exact outside_forever s

/-- On any full-line evolution with a leftmost black cell, an indefinitely
alternating wall cannot have an eventually periodic gate at its white ticks.
A is a white tick; the samples may start repeating at any later sample S. -/
theorem no_periodic_white_tail {x : Int → Bool} {lo : Int} {A S q : Nat}
    (black : x lo = true) (leftWhite : ∀ p, p < lo → x p = false) (positive : 0 < q)
    (clock : ∀ h, Rule30Realization.evol x (A+h) 0 = (h%2 == 1))
    (gate : ∀ s, S≤s → Rule30Realization.evol x (A+2*(s+q)) 1 =
      Rule30Realization.evol x (A+2*s) 1) : False := by
  apply Rule30FiniteMaskedJen.masked_jen black leftWhite 0 (T:=A+2*S) (P:=2*q) (by omega)
  · intro t ht
    have keep := clock (t-A)
    have later := clock (t-A+2*q)
    rw [show A+(t-A)=t by omega] at keep
    rw [show A+(t-A+2*q)=t+2*q by omega, show (t-A+2*q)%2=(t-A)%2 by omega] at later
    exact later.trans keep.symm
  · intro t ht white
    have keep := clock (t-A)
    rw [show A+(t-A)=t by omega,white] at keep
    have even : (t-A)%2=0 := by
      by_cases h : (t-A)%2=1
      · rw [h] at keep
        contradiction
      · omega
    let s := (t-A)/2
    have eq : A+2*s=t := by dsimp [s]; omega
    rw [show (0:Int)+1=1 by decide]
    simpa only [show A+2*(s+q)=t+2*q by omega,eq] using gate s (by omega)

end Ruliology.CellularAutomata.WheelThreeGapExterior
