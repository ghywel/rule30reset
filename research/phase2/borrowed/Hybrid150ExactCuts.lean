import Hybrid150PostSupport
import WallDifference

/-! All sufficiently wide cuts of the I330 reference. A two-diagonal parity
    identity bounds the proof to 72 residues, including odd arrivals. -/
namespace Hybrid150Edge.PostSupport

open WallDifference

def phase (t : Nat) : Bool := decide (t%2=1)
def schedule (t : Nat) := gate (phase t)

private theorem ref_valid : Valid schedule refRow := fun t => (physical_step t).symm

private theorem clock_eq {u : Field} (h : Valid schedule u) (s k : Nat) :
    clock (phase s) (u s) k = u (s+k) := by
  induction k generalizing s with
  | zero => rfl
  | succ k ih =>
    have toggle : (!phase s) = phase (s+1) := by
      rcases Nat.mod_two_eq_zero_or_one s with even | odd
      · simp [phase, even, show (s+1)%2=1 by omega]
      · simp [phase, odd, show (s+1)%2=0 by omega]
    change clock (!phase s) (tick (schedule s) (u s)) k = u (s+(k+1))
    rw [toggle, ← h s, ih, show s+1+k=s+(k+1) by omega]

private def correct := correction schedule refRow

private theorem correction_repeat (first : Nat) (hf : 81 ≤ first) :
    correct (first+72) = correct first := by
  refine correction_period schedule refRow 36 81 (fun t => time_period t 3) ?_
    (fun t i h => space_period t i 4 h) first hf
  intro t
  simp only [schedule, phase, show (t+36)%2=t%2 by omega]

private theorem odd_table : ∀ r : Fin 72,
    let n := 83+r.val
    n%2=1 → refRow 0 n=true → xor (refRow 0 (n+1)) (correct n)=true := by
  decide +kernel

private theorem odd_catch (n : Nat) (hn : 83 ≤ n) (odd : n%2=1) (black : refRow 0 n=true) :
    xor (refRow 0 (n+1)) (correct n)=true := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases small : n < 155
    · have eq : 83+(n-83)=n := by omega
      have hit := odd_table ⟨n-83, by omega⟩
      change (83+(n-83))%2=1 → refRow 0 (83+(n-83))=true → _ at hit
      rw [eq] at hit
      exact hit odd black
    · let k := n-72
      have hk : 83 ≤ k := by dsimp [k]; omega
      have low : k < n := by dsimp [k]; omega
      have eq : k+72=n := by dsimp [k]; omega
      rw [← eq] at odd black ⊢
      rw [show k+72=k+9*8 by omega, space_period _ _ _ (by omega)] at black
      rw [show k+72+1=k+1+9*8 by omega, space_period _ _ _ (by omega),
        correction_repeat k (by omega)]
      exact ih k low hk (by omega) black

private def gaps : List Nat := [2,1,0,4,3,2,1,0,0]

/-- Distance from the cutoff to the first black cell omitted from the reference. -/
def gap (w : Nat) : Nat := gaps[(w-83)%9]'(by unfold gaps; simp; omega)

private theorem gap_table : ∀ r : Fin 9,
    let w := 83+r.val
    gap w ≤ 4 ∧ refRow 0 (w+gap w) = true ∧
      (∀ d : Fin 4, d.val < gap w → refRow 0 (w+d.val) = false) := by
  decide +kernel

theorem gap_spec (w : Nat) (hw : 83 ≤ w) :
    gap w ≤ 4 ∧ refRow 0 (w+gap w)=true ∧
      ∀ j, w ≤ j → j < w+gap w → refRow 0 j = false := by
  let r : Fin 9 := ⟨(w-83)%9, by omega⟩
  let k := (w-83)/9
  have width : w=83+r.val+9*k := by
    dsimp [r, k]
    have h := Nat.mod_add_div (w-83) 9
    omega
  have res : (w-83)%9=(83+r.val-83)%9 := by
    have rlt := r.isLt
    have rEq : r.val = (w-83)%9 := rfl
    rw [show 83+r.val-83=r.val by omega, Nat.mod_eq_of_lt rlt, rEq]
  have gg : gap w = gap (83+r.val) := by simp only [gap, res]
  have table := gap_table r
  have short : gap w ≤ 4 := (congrArg (fun z => z ≤ 4) gg).mpr table.1
  refine ⟨short, ?_, ?_⟩
  · have addr : w+gap w = 83+r.val+gap (83+r.val)+9*k := by omega
    exact (congrArg (refRow 0) addr).trans ((space_period 0 _ k (by omega)).trans table.2.1)
  · intro j lo hi
    have d : j-w < 4 := by omega
    have finite : (⟨j-w,d⟩ : Fin 4).val < gap (83+r.val) := by
      change j-w < gap (83+r.val)
      omega
    have cell := table.2.2 ⟨j-w, d⟩ finite
    have addr : j = 83+r.val+(j-w)+9*k := by omega
    exact (congrArg (refRow 0) addr).trans ((space_period 0 _ k (by omega)).trans cell)

def FirstEvenWhite (x : Row) (age : Nat) : Prop :=
  age%2=0 ∧ clock false x age 0 = false ∧
    ∀ s < age, s%2=0 → clock false x s 0 = true

/-- For each cutoff W≥83, the first missing black arrives at W+gap W.
    The first failed check is that tick rounded up to an even tick. -/
theorem all_cuts (w : Nat) (hw : 83 ≤ w) :
    FirstEvenWhite (crop w) ((w+gap w)+(w+gap w)%2) := by
  let n := w+gap w
  let u := evolve schedule (crop w)
  have cropped : Valid schedule u := evolve_valid schedule (crop w)
  have same (i : Nat) (hi : i < n) : refRow 0 i = u 0 i := by
    by_cases lo : i<w
    · simp [u, evolve, crop, lo]
    · simpa [u, evolve, crop, lo] using (gap_spec w hw).2.2 i (by omega) hi
  have black : refRow 0 n = true := (gap_spec w hw).2.1
  have differ : xor (refRow 0 n) (u 0 n) = true := by
    simp [u, evolve, crop, black, show ¬n<w by dsimp [n]; omega]
  have asClock (t : Nat) : clock false (crop w) t = u t := by
    have eq := clock_eq cropped 0 t
    change clock false (crop w) t = u (0+t) at eq
    rwa [Nat.zero_add] at eq
  have earlier (s : Nat) (hs : s < n) (ev : s%2=0) : clock false (crop w) s 0 = true := by
    rw [asClock, ← before ref_valid cropped same s 0 (by omega), ref_even s ev]
  have white (t : Nat) (ev : t%2=0) (hd : xor (refRow t 0) (u t 0)=true) :
      clock false (crop w) t 0 = false := by
    rw [asClock]
    rw [ref_even t ev] at hd
    cases bit : u t 0 <;> simp_all
  rcases Nat.mod_two_eq_zero_or_one n with even | odd
  · change FirstEvenWhite (crop w) (n+n%2)
    rw [even, Nat.add_zero]
    have arrive : xor (refRow n 0) (u n 0) = true :=
      (leading ref_valid cropped same n 0 (by omega)).trans differ
    exact ⟨even, white n even arrive, earlier⟩
  · have ev : (n+1)%2=0 := by omega
    have adj := adjacent ref_valid cropped same differ (n+1) 0 (by omega)
    have atNext : u 0 (n+1) = false := by simp [u, evolve, crop, show ¬n+1<w by dsimp [n]; omega]
    rw [atNext, Bool.xor_false] at adj
    have exactNext := adj.trans (odd_catch n (by dsimp [n]; omega) odd black)
    change FirstEvenWhite (crop w) (n+n%2)
    rw [odd]
    exact ⟨ev, white (n+1) ev exactNext, fun s hs parity => earlier s (by omega) parity⟩

theorem cut_deadline (w : Nat) (hw : 83 ≤ w) :
    ∃ t ≤ w+5, FirstEvenWhite (crop w) t := by
  have bound := (gap_spec w hw).1
  exact ⟨_, by omega, all_cuts w hw⟩

/-- The bound is sharp for actual width W, with no trailing white sites in the cutoff. -/
theorem sharp_five (k : Nat) :
    let w := 95+18*k
    crop w (w-1)=true ∧ FirstEvenWhite (crop w) (w+5) := by
  let w := 95+18*k
  have g : gap w=4 := by
    have r : (w-83)%9=3 := by dsimp [w]; omega
    simp only [gap, r, gaps]
    rfl
  have hit := all_cuts w (by dsimp [w]; omega)
  rw [g, show (w+4)%2=1 by dsimp [w]; omega] at hit
  refine ⟨?_, by simpa only [show w+4+1=w+5 by omega] using hit⟩
  have b : refRow 0 94 = true := by decide +kernel
  have a : w-1=94+9*(2*k) := by dsimp [w]; omega
  have below : w-1<w := by dsimp [w]; omega
  change crop w (w-1) = true
  rw [crop, ite_eq_left below, a, space_period 0 94 (2*k) (by omega), b]

private def otherReference := fromTrace schedule (fun t => decide (t%4≠1))

/-- A four-phase reference gives a genuine odd-arrival escape from the next
    even check. The finite crop of the leading three ones first fails at 6. -/
theorem other_reference : Valid schedule otherReference ∧ (∀ r, otherReference (2*r) 0 = true) ∧
    (∀ i, (packed 7) i = if i<3 then otherReference 0 i else false) ∧
    otherReference 0 3 = true ∧ FirstEvenWhite (packed 7) 6 := by
  let ref := otherReference
  have early : ∀ i : Fin 3, packed 7 i.val = ref 0 i.val := by decide +kernel
  refine ⟨fromTrace_valid _ _, ?_, ?_, by decide +kernel, by decide, by decide +kernel, ?_⟩
  · intro r
    change decide ((2*r)%4≠1)=true
    simp [show (2*r)%4≠1 by omega]
  · intro i
    by_cases inside : i<3
    · exact (early ⟨i,inside⟩).trans (ite_eq_left inside).symm
    · rw [ite_eq_right inside]
      apply Nat.testBit_lt_two_pow
      exact Nat.lt_of_lt_of_le (by decide : 7 < 2^3)
        (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) (by omega))
  · have checks : ∀ s : Fin 6, s.val%2=0 → clock false (packed 7) s.val 0 = true := by decide +kernel
    exact fun s hs h => checks ⟨s,hs⟩ h

end Hybrid150Edge.PostSupport
