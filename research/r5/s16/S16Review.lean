module

public import Rule30Submission
public import Ruliology.CellularAutomata.Rule30EtherThreeDeparture
public import Ruliology.CellularAutomata.Rule30PeriodThreeLanguage

/-! Independent comparisons for the M152 source on kit main. -/

@[expose] public section

namespace S16Review
open Rule30Submission Ruliology.CellularAutomata
open Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30EtherThreeDeparture
open Rule30PeriodThreeLanguage

set_option maxRecDepth 100000
set_option maxHeartbeats 0

/-- These two trap members have no incoming edge from their own trap in the
three-tick physical window graph used by M152's `image_mem`. -/
theorem physical_nonminimal_001 : 675 ∈ trap001 ∧
    (trap001.all fun x => !(images false true false 14 x).contains 675) = true := by
  decide +kernel

theorem physical_nonminimal_011 : 893 ∈ trap011 ∧
    (trap011.all fun x => !(images false true true 14 x).contains 893) = true := by
  decide +kernel

/-- Every old forbidden word contains a new one at some offset. -/
private def covers (small large : List (List Bool)) : Bool :=
  large.all fun p => small.any fun v => (List.range (p.length+1)).any fun j =>
    decide (j+v.length ≤ p.length) &&
      (List.range v.length).all fun i => v.getD i false == p.getD (j+i) false

private theorem free_of_cover {small large : List (List Bool)} (h : covers small large = true)
    {g K : Nat} {u : Nat → Bool} (free : Free small g u K) : Free large g u K := by
  intro k hk phase p hp spells
  obtain ⟨v, hv, offsets⟩ := List.any_eq_true.mp (List.all_eq_true.mp h p hp)
  obtain ⟨j, _, hit⟩ := List.any_eq_true.mp offsets
  obtain ⟨bound, cells⟩ := Bool.and_eq_true_iff.mp hit
  have bound' := of_decide_eq_true bound
  apply free (k+3*j) (by omega) (by omega) v hv
  intro i hi
  have eq := beq_iff_eq.mp (List.all_eq_true.mp cells i (List.mem_range.mpr hi))
  rw [show k+3*j+3*i = k+3*(j+i) by omega, spells (j+i) (by omega), eq]

theorem left001_of_C3g (h : C3g001) : Left001 := by
  rintro s hs ⟨K, pat, free⟩
  have old := free_of_cover (large := col1Forbidden001) (by decide) free
  exact h s hs ⟨K, fun k hk => ⟨pat k hk, old k hk⟩⟩

theorem left011_of_C3r (h : C3r011) : Left011 := by
  rintro s hs ⟨K, pat, free⟩
  have old := free_of_cover (large := col1Forbidden011) (by decide) free
  exact h s hs ⟨K, fun k hk => ⟨pat k hk, old k hk⟩⟩

/-- A finite row with its first ether defect at D. -/
def cut (j φ D p : Nat) : Bool :=
  if p < D then eth j φ p 0 else if p = D then !eth j φ p 0 else false

theorem cut_finite (j φ D : Nat) {p : Nat} (hp : D < p) : cut j φ D p = false := by
  simp [cut, show ¬p < D by omega, show p ≠ D by omega]

private theorem travel {F : Nat → Nat → Bool} (hF : IsR30 F) {j φ : Nat}
    (clock : ∀ t, F t 0 = eth j φ 0 t) (k c t : Nat) (hc : 7 ≤ c)
    (front : Front F j φ t (4*k+c)) (hrec : IsRec F j φ t (4*k+c)) :
    Front F j φ (t+10*k) c := by
  induction k generalizing t with
  | zero => simpa using front
  | succ k ih =>
    obtain ⟨next, nextRec, _⟩ := ten_ticks hF (fun u _ => clock u) front hrec (by omega)
    rw [show 4*(k+1)+c-4 = 4*k+c by omega] at next nextRec
    simpa only [show t+10*(k+1) = t+10+10*k by omega] using ih (t+10) next nextRec

private theorem outside_at (w : List Bool) (trap : List Nat) (j φ c n : Nat)
    (aligned : aligned3 w j 0 = true) (hc : 14 < c) (state : (j+c+4*φ)%12 = 0)
    (outside : code (fun _ p => ether3 (j+p) φ) 0 14 ∉ trap) :
    ¬ InTrap trap (half w (cut j φ (12*n+c)) φ) (30*n) := by
  let D := 12*n+c
  let F := half w (cut j φ D) φ
  have clock (t : Nat) : F t 0 = eth j φ 0 t := by
    rw [show F t 0 = wordAt3 w (t+φ) from half_zero ..]
    simpa [eth] using (aligned3_spec aligned (t+φ)).symm
  have initial (p : Nat) (hp : 1 ≤ p) : F 0 p = cut j φ D p := drv_init _ _ _ hp
  have first : Front F j φ 0 D := by
    constructor
    · intro p hp
      by_cases z : p = 0
      · subst p; exact clock 0
      · rw [initial p (by omega)]; simp [cut, hp]
    · rw [initial D (by dsimp [D]; omega)]
      simp [cut]
  have state' : cls j φ D 0 = 0 := by unfold cls; dsimp [D]; omega
  have hrec : IsRec F j φ 0 D := by
    unfold IsRec; rw [state']; cases ubit F j φ 0 D <;> decide
  have dEq : D = 4*(3*n)+c := by dsimp [D]; omega
  rw [dEq] at first hrec
  have late := travel (half_isR30 w (cut j φ D) φ) clock (3*n) c 0 (by omega) first hrec
  rw [show 0+10*(3*n) = 30*n by omega] at late
  have same : code F (30*n) 14 = code (fun _ p => ether3 (j+p) φ) 0 14 := by
    unfold code; congr 1
    apply seg_congr
    intro i hi
    exact (late.1 (i+1) (by omega)).trans (ether3_congr rfl (by omega))
  change code F (30*n) 14 ∉ trap
  rwa [same]

/-- At gate time 30n, a row supported through 12n+20 beside 001 can still be outside. -/
theorem slow_001 (n : Nat) :
    ¬ InTrap trap001 (half w001 (cut 0 1 (12*n+20)) 1) (30*n) :=
  outside_at _ _ _ _ _ _ (by decide) (by decide) (by decide) (by decide +kernel)

/-- At the same gate time, support through 12n+25 suffices beside 011. -/
theorem slow_011 (n : Nat) :
    ¬ InTrap trap011 (half w011 (cut 11 0 (12*n+25)) 0) (30*n) :=
  outside_at _ _ _ _ _ _ (by decide) (by decide) (by decide) (by decide +kernel)

end S16Review
