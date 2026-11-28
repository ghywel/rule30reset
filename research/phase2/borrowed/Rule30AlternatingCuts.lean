import WallDifference
import Ruliology.CellularAutomata.Rule30ZeroBoundary

/-! Exact first failed even observation for the truncations of the reference
    with wall trace 1010… . Four adjacent differences return after eight
    ticks in its outer stripe. This gives an induction on the cutoff. -/
namespace Rule30AlternatingCuts

open Hybrid150Edge WallDifference
open Ruliology.CellularAutomata.Rule30ZeroBoundary

def rule30 : Gate := fun _ c r => c || r

private def stripe (i : Nat) : Bool := decide (i%2=1)

/-- The wall-adjacent bit alternates. All exterior bits form a stationary stripe. -/
def reference (t i : Nat) : Bool := if i=0 then decide (t%2=0) else stripe i

theorem reference_valid : Valid rule30 reference := by
  intro t
  funext i
  cases i with
  | zero =>
    rcases Nat.mod_two_eq_zero_or_one t with ev | od
    · simp [reference, tick, east, stripe, rule30, ev, show (t+1)%2=1 by omega]
    · simp [reference, tick, east, stripe, rule30, od, show (t+1)%2=0 by omega]
  | succ i =>
    cases i with
    | zero => simp [reference, tick, east, stripe, rule30]
    | succ j =>
      rcases Nat.mod_two_eq_zero_or_one j with ev | od
      · simp [reference, tick, east, stripe, rule30, show (j+1)%2=1 by omega,
          show (j+2)%2=0 by omega, show (j+3)%2=1 by omega]
      · simp [reference, tick, east, stripe, rule30, show (j+1)%2=0 by omega,
          show (j+2)%2=1 by omega, show (j+3)%2=0 by omega]

private def cut (n : Nat) : Row := fun i => if i<n then reference 0 i else false
private def sample (n : Nat) := evolve rule30 (cut n)

private theorem ref_before (n t i : Nat) (h : t+i<n) : reference t i = sample n t i :=
  before reference_valid (evolve_valid _ _) (fun j hj => by simp [evolve, cut, hj]) t i h

private def delta (n t d : Nat) : Bool := xor (reference t (n-t+d)) (sample n t (n-t+d))

private def earlierLane (v : Row) (offset d : Nat) : Bool :=
  if d<offset then false else v (d-offset)

private theorem lane (n t d offset : Nat) (ht : t+offset≤n) :
    xor (reference t (n-t+d-offset)) (sample n t (n-t+d-offset)) =
      earlierLane (delta n t) offset d := by
  by_cases small : d<offset
  · have agree := ref_before n t (n-t+d-offset) (by omega)
    rw [earlierLane, ite_eq_left small, agree, Bool.xor_self]
  · simp only [earlierLane, ite_eq_right small, delta, show n-t+(d-offset)=n-t+d-offset by omega]

private def nextStrip (t : Nat) (v : Row) (d : Nat) : Bool :=
  let centre := stripe (d+t)
  let right := !centre
  xor (v d) (xor (centre || right)
    (xor centre (earlierLane v 1 d) || xor right (earlierLane v 2 d)))

private theorem difference_update : ∀ a b c a' b' c' : Bool,
    xor (xor a (b||c)) (xor a' (b'||c')) =
      xor (xor a a') (xor (b||c) ((xor b (xor b b')) || (xor c (xor c c')))) := by decide

private theorem east_pred (x : Row) (i : Nat) (pos : 0<i) : east x i = x (i-1) := by
  cases i with
  | zero => omega
  | succ i => rfl

private theorem next_delta (n t d : Nat) (odd : n%2=1) (space : t+3≤n) :
    delta n (t+1) d = nextStrip t (delta n t) d := by
  let i := n-(t+1)+d
  have eq1 : i+1=n-t+d := by dsimp [i]; omega
  have cm : i=n-t+d-1 := by dsimp [i]; omega
  have em : i-1=n-t+d-2 := by dsimp [i]; omega
  have pos : 2≤i := by dsimp [i]; omega
  have re := east_pred (reference t) i (by omega)
  have se := east_pred (sample n t) i (by omega)
  have ce : reference t i = stripe (d+t) := by
    simp only [reference, ite_eq_right (by omega : i≠0), stripe, show i%2=(d+t)%2 by dsimp [i]; omega]
  have ee : reference t (i-1) = !stripe (d+t) := by
    simp only [reference, ite_eq_right (by omega : i-1≠0), stripe]
    rcases Nat.mod_two_eq_zero_or_one (d+t) with ev | od
    · simp [ev, show (i-1)%2=1 by dsimp [i]; omega]
    · simp [od, show (i-1)%2=0 by dsimp [i]; omega]
  have cd := lane n t d 1 (by omega)
  have ed := lane n t d 2 (by omega)
  rw [← cm] at cd
  rw [← em] at ed
  change xor (reference (t+1) i) (sample n (t+1) i) = _
  rw [reference_valid t]
  change xor (tick (rule30 t) (reference t) i) (tick (rule30 t) (sample n t) i) = _
  simp only [tick, rule30, re, se]
  rw [difference_update, cd, ed, ce, ee, eq1]
  rfl

private def strip : Nat → Row
  | 0 => fun d => decide (d%2=0)
  | t+1 => nextStrip t (strip t)

private theorem delta_strip (n t : Nat) (odd : n%2=1) (space : t+2≤n) :
    delta n t = strip t := by
  induction t with
  | zero =>
    funext d
    change xor (reference 0 (n+d)) (cut n (n+d)) = decide (d%2=0)
    have h : ¬n+d<n := by omega
    simp only [cut, ite_eq_right h, Bool.xor_false, reference,
      ite_eq_right (by omega : n+d≠0), stripe]
    exact decide_eq_decide.mpr (by omega)
  | succ t ih =>
    funext d
    rw [next_delta n t d odd (by omega), ih (by omega)]
    rfl

private theorem strip_returns : ∀ d : Fin 4, strip 8 d.val = decide (d.val%2=0) := by
  decide +kernel

private theorem crop_after_eight (n : Nat) (hn : 3≤n) (odd : n%2=1) :
    ∀ i < n+4, sample (n+8) 8 i = sample n 0 i := by
  intro i hi
  have time : reference 8 i = reference 0 i := by simp [reference]
  by_cases inner : i<n
  · exact (ref_before _ _ _ (by omega)).symm.trans (time.trans (ref_before n 0 i (by omega)))
  · let d : Fin 4 := ⟨i-n, by omega⟩
    have id : n+8-8+d.val=i := by dsimp [d]; omega
    have eq := congrFun (delta_strip (n+8) 8 (by omega) (by omega)) d.val
    change xor (reference 8 (n+8-8+d.val)) (sample (n+8) 8 (n+8-8+d.val)) = strip 8 d.val at eq
    rw [id, time, strip_returns d] at eq
    have bit : reference 0 i = decide (d.val%2=0) := by
      simp only [reference, ite_eq_right (by omega : i≠0), stripe]
      exact decide_eq_decide.mpr (by dsimp [d]; omega)
    rw [← bit] at eq
    have rr : sample n 0 i = false := by simp [sample, evolve, cut, inner]
    exact rr.symm ▸ Bool.xor_right_inj.mp (eq.trans (Bool.xor_false _).symm)

private theorem wall_after_eight (n : Nat) (hn : 3≤n) (odd : n%2=1)
    (t : Nat) (ht : t<n+4) : sample (n+8) (8+t) 0 = sample n t 0 := by
  have valid : Valid rule30 (fun s => sample (n+8) (8+s)) := by
    intro s
    change sample (n+8) (8+(s+1)) = tick (rule30 s) (sample (n+8) (8+s))
    rw [show 8+(s+1)=8+s+1 by omega]
    rfl
  exact before valid (evolve_valid _ _) (crop_after_eight n hn odd) t 0 (by omega)

private def death (n : Nat) : Nat := n+1+(if n%4=3 then 2 else 0)

private def FirstEvenFailure (u : Field) (t : Nat) : Prop :=
  t%2=0 ∧ u t 0=false ∧ ∀ s<t, s%2=0 → u s 0=true

private theorem base : ∀ n : Fin 11, 3≤n.val → n.val%2=1 →
    sample n.val (death n.val) 0 = false ∧
      ∀ s : Fin 14, s.val < death n.val → s.val%2=0 → sample n.val s.val 0 = true := by
  decide +kernel

private theorem exact_failure (n : Nat) (hn : 3≤n) (odd : n%2=1) : FirstEvenFailure (sample n) (death n) := by
  have ev : death n%2=0 := by unfold death; split <;> omega
  refine ⟨ev, ?_⟩
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases small : n<11
    · have cert := base ⟨n,small⟩ hn odd
      exact ⟨cert.1, fun s hs he => cert.2 ⟨s, by unfold death at hs; split at hs <;> omega⟩ hs he⟩
    · let j := n-8
      have jodd : j%2=1 := by dsimp [j]; omega
      have jmin : 3≤j := by dsimp [j]; omega
      have jlt : j<n := by dsimp [j]; omega
      have width : j+8=n := by dsimp [j]; omega
      have off : death n=8+death j := by
        unfold death
        have lt : n%4=j%4 := by omega
        rw [lt]
        split <;> omega
      have range : death j < j+4 := by unfold death; split <;> omega
      obtain ⟨bad, good⟩ := ih j jlt jmin jodd (by omega)
      constructor
      · rw [off, ← width, wall_after_eight j jmin jodd _ range, bad]
      · intro s hs he
        by_cases early : s<8
        · exact (ref_before n s 0 (by omega)).symm.trans (by simp [reference, he])
        · have t : s=8+(s-8) := by omega
          have h := wall_after_eight j jmin jodd (s-8) (by omega)
          rw [width, ← t] at h
          exact h.trans (good (s-8) (by omega) (by omega))

private theorem kit_evolve (x : Row) (t i : Nat) : evolve rule30 x t i = zrow (east x) t (i+1) := by
  induction t generalizing i with
  | zero => rfl
  | succ t ih =>
    have tail : east (evolve rule30 x t) i = zrow (east x) t i := by
      cases i with
      | zero => exact (zrow_wall _ t).symm
      | succ j => exact ih j
    rw [zrow_succ]
    change xor (evolve rule30 x t (i+1)) (evolve rule30 x t i || east (evolve rule30 x t) i) = _
    rw [ih, ih, tail]

/-- The actual Rule 30 half-line, with physical depths starting at one. -/
def seed (width : Nat) : Nat → Bool := east (cut (width+1))

/-- The first missing black is heard at the odd tick W+1. -/
theorem first_arrival (w : Nat) (he : w%2=0) :
    (∀ t<w+1, zrow (seed w) t 1 = decide (t%2=0)) ∧ zrow (seed w) (w+1) 1=true := by
  constructor
  · intro t h
    have before := ref_before (w+1) t 0 (by omega)
    exact (kit_evolve (cut (w+1)) t 0).symm.trans (by simpa [reference, sample] using before.symm)
  · have hit := leading reference_valid (evolve_valid rule30 (cut (w+1)))
      (fun j hj => by simp [evolve, cut, hj]) (w+1) 0 (by omega : w+1+0=w+1)
    have b : reference 0 (w+1) = true := by simp [reference, stripe, show (w+1)%2=1 by omega]
    have r : reference (w+1) 0 = false := by simp [reference, show (w+1)%2=1 by omega]
    have zz : evolve rule30 (cut (w+1)) 0 (w+1) = false := by simp [evolve, cut]
    rw [r, b, zz, Bool.false_xor] at hit
    exact (kit_evolve (cut (w+1)) (w+1) 0).symm.trans hit

/-- For every even W≥2, the cut has exact support width W and first fails at
    W+2 if W is 0 mod 4, or W+4 if W is 2 mod 4. -/
theorem first_failed_even (w : Nat) (hw : 2≤w) (he : w%2=0) :
    let t := w + (if w%4=0 then 2 else 4)
    seed w w = true ∧ (∀ i>w, seed w i = false) ∧
      t%2=0 ∧ zrow (seed w) t 1=false ∧ ∀ s<t, s%2=0 → zrow (seed w) s 1=true := by
  have hit := exact_failure (w+1) (by omega) (by omega)
  have time : death (w+1) = w+(if w%4=0 then 2 else 4) := by
    unfold death
    by_cases zero : w%4=0
    · simp [zero, show (w+1)%4≠3 by omega]
    · simp [zero, show (w+1)%4=3 by omega]
  rw [time] at hit
  refine ⟨?_, ?_, hit.1, ?_, ?_⟩
  · obtain ⟨k, rfl⟩ : ∃ k, w=k+1 := ⟨w-1, by omega⟩
    simp [seed, east, cut, reference, stripe, show k≠0 by omega, show k%2=1 by omega,
      show k<k+1+1 by omega]
  · intro i hi
    obtain ⟨k, rfl⟩ : ∃ k, i=k+1 := ⟨i-1, by omega⟩
    have beyond : ¬k<w+1 ∨ k=w := by omega
    rcases beyond with far | eq
    · simp [seed, east, cut, far]
    · rw [eq]
      simp [seed, east, cut, reference, stripe, show w≠0 by omega, he]
  · exact (kit_evolve _ _ 0).symm.trans hit.2.1
  · intro s hs hse
    exact (kit_evolve _ _ 0).symm.trans (hit.2.2 s hs hse)

end Rule30AlternatingCuts
