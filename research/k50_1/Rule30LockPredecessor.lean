module

public import Rule30Lock7Compactness
public import Rule30Lock7Prefixes

/-! Exact finite-horizon completeness of the free-boundary predecessor when its width can grow. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LockPredecessor
open Rule30StripCertificates Rule30SidewaysLocks Rule30PlantedSurvivor
open Rule30Lock7Prefixes Rule30Lock7Compactness Rule30Ether Rule30PeriodTwoCoupled

private theorem lin3_append_prefix : ∀ x z : List Bool, lin3 x <+: lin3 (x++z)
  | [], z => by simp [lin3]
  | [_], z => by simp [lin3]
  | [_,_], z => by simp [lin3]
  | a::b::c::xs, z => by
    change _ :: lin3 (b::c::xs) <+: _ :: lin3 ((b::c::xs)++z)
    exact (List.prefix_cons_inj _).mpr (lin3_append_prefix (b::c::xs) z)

private theorem lin3_prefix {x y : List Bool} (pref : x <+: y) : lin3 x <+: lin3 y := by
  obtain ⟨z,rfl⟩ := pref
  exact lin3_append_prefix _ _

/-- From an odd tick the left W cells two ticks later use just the first W+2 cells. -/
private theorem shrink_real (R : Nat → Bool) (W t : Nat) (odd : t%2=1) :
    winW W R (t+2) = lin3 (true :: lin3 (false :: winW (W+2) R t)) := by
  rw [winW_dstep W R t odd]
  unfold dstep
  have cols : winW (W+2) R t = winW W R t ++
      [drv altCol R t (W+1), drv altCol R t (W+2)] := by
    unfold winW rowOf
    rw [seg_succ,seg_succ]
    simp [List.append_assoc]
  rw [cols]

/-- Freshly chosen exterior values at a double step preserve two fewer inner columns. -/
theorem inner_step (R : Nat → Bool) {W t : Nat} (odd : t%2=1) {w : List Bool}
    (inner : winW (W+2) R t <+: w) (a b : Bool) :
    winW W R (t+2) <+: dstep w a b := by
  rw [shrink_real R W t odd]
  unfold dstep
  apply lin3_prefix
  apply (List.prefix_cons_inj _).mpr
  apply lin3_prefix
  apply (List.prefix_cons_inj _).mpr
  exact List.prefix_append_of_prefix inner

/-- Stronger than early reachability. Every branch of fresh exterior pairs ends in the lock at J. -/
def allLeaves (target : List Bool → Prop) : Nat → List Bool → Prop
  | 0, w => target w
  | n+1,w => ∀ a b : Bool, allLeaves target n (dstep w a b)

theorem allLeaves_forces {target : List Bool → Prop} (J : Nat) (w : List Bool)
    (h : allLeaves target J w) : forcesWithin target J w := by
  induction J generalizing w with
  | zero => exact h
  | succ J ih => exact Or.inr (fun a b => ih _ (h a b))

theorem physical_to_leaves (R : Nat → Bool) (J t : Nat) (odd : t%2=1) (w : List Bool)
    (inner : winW (30+2*J) R t <+: w)
    (hit : ∃ k : Fin 7, winW 30 R (t+2*J) ∈ cls 30 lock7Codes k.val) :
    allLeaves lockTarget J w := by
  induction J generalizing t w with
  | zero =>
    obtain ⟨k,hk⟩ := hit
    have p : winW 30 R t <+: w := by simpa using inner
    have l : (winW 30 R t).length = 30 := length_seg _ _
    have agree := List.prefix_iff_eq_take.mp p
    rw [l] at agree
    exact ⟨k,by rw [← agree]; simpa using hk⟩
  | succ J ih =>
    intro a b
    have p : winW (30+2*J+2) R t <+: w := by simpa only [Nat.mul_succ,Nat.add_assoc] using inner
    exact ih (t+2) (by omega) _ (inner_step R odd p a b)
      (by simpa only [show t+2+2*J = t+2*(J+1) by omega] using hit)

/-- I49's finite game at a specified width and deadline. -/
def Predecessor (m c W J : Nat) : Prop :=
  ∀ q, q < 2^(W+1) → (∀ i, i<m → q.testBit i = c.testBit i) →
    forcesWithin lockTarget J (Rule30GateTrap.evolve 0 1 (decodeW (W+1) q))

theorem all_branches_at_deadline {m c W J : Nat} (radius : 30+2*J ≤ W)
    (checked : checkCover m c J = true) (q : Nat)
    (fixedBits : ∀ i, i<m → q.testBit i = c.testBit i) :
    allLeaves lockTarget J (Rule30GateTrap.evolve 0 1 (decodeW (W+1) q)) := by
  let R := rh q
  have phys : HasPrefix m c R := fun i hi => ((rh_prefix q m) i hi).trans (fixedBits i hi)
  have hit := (checkCover_spec m c J).mp checked R phys
  rw [← winW_prefix (R := R) (W := W) (t0 := 1) (rh_prefix q (W+1))]
  apply physical_to_leaves R J 1 (by decide) _ _ hit
  have p := List.take_prefix (30+2*J) (winW W R 1)
  rwa [winW_take R 1 (30+2*J) W radius] at p

/-- The free-boundary game is exact for each horizon once W contains its light cone and prefix. -/
theorem cover_iff_predecessor {m c W J : Nat} (radius : 30+2*J ≤ W) (fits : m ≤ W+1) :
    checkCover m c J = true ↔ Predecessor m c W J := by
  constructor
  · intro checked q _ pref
    exact allLeaves_forces J _ (all_branches_at_deadline radius checked q pref)
  · intro game
    apply (checkCover_spec m c J).mpr
    intro R pref
    obtain ⟨j,le,k,hk⟩ := prefix_forces_lock (by omega : 30 ≤ W) fits game R pref
    exact locked_later le ⟨k,hk⟩

/-- Choosing the width from the deadline makes the practical criterion complete over horizons. -/
theorem all_completions_iff_predecessor (m c : Nat) :
    (∀ R, HasPrefix m c R → ∃ j, Locked R j) ↔
      ∃ J, Predecessor m c (max (30+2*J) (m-1)) J := by
  rw [all_completions_iff_check]
  apply exists_congr
  intro J
  apply cover_iff_predecessor (Nat.le_max_left _ _)
  have := Nat.le_max_right (30+2*J) (m-1)
  omega

end Ruliology.CellularAutomata.Rule30LockPredecessor
