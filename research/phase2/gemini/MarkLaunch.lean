import Ruliology.CellularAutomata.Rule30MarkedGaps
import Ruliology.CellularAutomata.Rule30SettledRepeats
import Ruliology.CellularAutomata.Rule30LightCone
import Ruliology.CellularAutomata.Rule30CenterRuns

/-! Primitive sources of marked gaps in the singleton spacetime. -/
namespace PhaseTwo.MarkLaunch
open Ruliology.CellularAutomata Rule30Jen Rule30Realization Rule30MarkedGaps

/-- A capped interval of white sites immediately to the west of the centre. -/
def Gap (s l : Nat) : Prop :=
  (∀ p : Int, -(l:Int) ≤ p → p < 0 → cell s p = false) ∧ cell s (-(l:Int)-1) = true

def active (t : Nat) : Bool := cell t (-1) || cell t 0

/-- The exact black run read westward from -2, at an active tick of the observer bond. -/
def Bar (t l : Nat) : Prop :=
  active t = true ∧ cell t (-(l:Int)-2) = false ∧
    ∀ p : Int, -(l:Int)-1 ≤ p → p ≤ -2 → cell t p = true

/-- The kit's one-step white-run dichotomy in fixed-observer coordinates. -/
theorem gap_back {t l : Nat} (hl : 0 < l) (gap : Gap (t+1) l) :
    (active t = false ∧ Gap t (l+1)) ∨ Bar t l := by
  let e : Int := (t: Int) + 1
  have old (k : Int) : Rule30ClockNearSquares.D seed e k t = cell t (k+1) := by
    simp only [Rule30ClockNearSquares.D, evol_seed, e]; congr 1; omega
  have newc (k : Int) : Rule30ClockNearSquares.D seed e k (t+1) = cell (t+1) k := by
    simp only [Rule30ClockNearSquares.D, evol_seed, e]; congr 1; omega
  have dich := Rule30SettledRepeats.back seed e (-(l:Int)-1) (-1) t (by omega)
    (by rw [newc]; exact gap.2) (fun k lo hi => by rw [newc]; exact gap.1 _ (by omega) (by omega))
  simp only [old] at dich
  rcases dich with ⟨white, cap⟩ | ⟨black, endBits⟩
  · have wh (p : Int) (lo : -(l:Int)-1 ≤ p) (hi : p ≤ 0) : cell t p = false := by
      simpa using white (p-1) (by omega) (by omega)
    refine Or.inl ⟨by simp [active, wh (-1) (by omega) (by omega), wh 0 (by omega) (by omega)],
      fun p lo hi => wh _ (by omega) (by omega), ?_⟩
    simpa only [show -(l:Int)-1-2+1 = -((l+1:Nat):Int)-1 by omega] using cap
  · right
    have bk (p : Int) (lo : -(l:Int)-1 ≤ p) (hi : p ≤ -2) : cell t p = true := by
      simpa using black (p-1) (by omega) (by omega)
    refine ⟨?_, ?_, bk⟩
    · change cell t (-1) = true ∨ cell t 0 = true at endBits
      exact Bool.or_eq_true_iff.mpr endBits
    · have hcap := gap.2
      change rule (cell t (-(l:Int)-1-1)) (cell t (-(l:Int)-1)) _ = true at hcap
      rw [bk (-(l:Int)-1) (by omega) (by omega)] at hcap
      simpa [rule, show -(l:Int)-1-1 = -(l:Int)-2 by omega] using hcap

theorem gap_of_bar {t l : Nat} (bar : Bar t l) : Gap (t+1) l := by
  obtain ⟨ha,hcap,black⟩ := bar
  constructor
  · intro p lo hi
    change rule (cell t (p-1)) (cell t p) (cell t (p+1)) = false
    rw [black _ (by omega) (by omega)]
    by_cases he : p = -1
    · subst p
      change xor true (active t) = false
      rw [ha]; decide
    · simp [rule, black p (by omega) (by omega)]
  · change rule (cell t (-(l:Int)-1-1)) (cell t (-(l:Int)-1)) (cell t (-(l:Int)-1+1)) = true
    rw [show -(l:Int)-1-1 = -(l:Int)-2 by omega, hcap]
    by_cases hz : l = 0
    · subst l; simpa [rule, active] using ha
    · simp [rule, black (-(l:Int)-1) (by omega) (by omega)]

theorem gap_of_quiet {t l : Nat} (quiet : active t = false) (old : Gap t (l+1)) :
    Gap (t+1) l := by
  have z : cell t 0 = false := (Bool.or_eq_false_iff.mp quiet).2
  have wh (p : Int) (lo : -(l:Int)-1 ≤ p) (hi : p ≤ 0) : cell t p = false := by
    by_cases h : p = 0
    · simpa [h] using z
    · apply old.1 _ (by omega) (by omega)
  constructor
  · intro p lo hi
    change rule (cell t (p-1)) (cell t p) (cell t (p+1)) = false
    simp [rule, wh (p-1) (by omega) (by omega), wh p (by omega) (by omega),
      wh (p+1) (by omega) (by omega)]
  · have hb : cell t (-(l:Int)-1-1) = true := by
      simpa only [show -((l+1:Nat):Int)-1 = -(l:Int)-1-1 by omega] using old.2
    change rule (cell t (-(l:Int)-1-1)) (cell t (-(l:Int)-1)) (cell t (-(l:Int)-1+1)) = true
    rw [hb, wh (-(l:Int)-1) (by omega) (by omega), wh (-(l:Int)-1+1) (by omega) (by omega)]
    rfl

theorem next_gap_iff {t l : Nat} (hl : 0 < l) : Gap (t+1) l ↔
    (active t = false ∧ Gap t (l+1)) ∨ Bar t l :=
  ⟨gap_back hl, fun h => h.elim (fun z => gap_of_quiet z.1 z.2) gap_of_bar⟩

/-- Walking a mark back to the most recent active bond tick preserves its arrival age. -/
theorem birth_of_mark {s l : Nat} (hl : 0 < l) (mark : Mark s l) :
    ∃ t w : Nat, t < s ∧ l ≤ w ∧ t+1+w = s+l ∧ Bar t w ∧ Mark (t+1) w ∧
      ∀ v, t < v → v < s → active v = false := by
  induction s generalizing l with
  | zero =>
    have cap := mark.2.1
    simp [cell, show -(l:Int)-1 ≠ 0 by omega] at cap
  | succ s ih =>
    rcases gap_back hl ⟨mark.1,mark.2.1⟩ with ⟨quiet, interval⟩ | bar
    · have earlier : Mark s (l+1) := ⟨interval.1,interval.2, by
        simpa only [show s+(l+1) = s+1+l by omega] using mark.2.2⟩
      obtain ⟨t,w,ht,hw,he,hb,hm,hq⟩ := ih (by omega) earlier
      refine ⟨t,w,by omega,by omega,by omega,hb,hm,fun v lo hi => ?_⟩
      by_cases h : v = s
      · simpa [h] using quiet
      · exact hq v lo (by omega)
    · exact ⟨s,l,by omega,by omega,rfl,bar,mark,fun v a b => by omega⟩

/-- Every strict width record is born in the preceding update. -/
theorem record_is_birth {s l : Nat} (hl : 0 < l) (mark : Mark (s+1) l)
    (record : ∀ k, Mark s k → k ≤ l) : Bar s l := by
  rcases gap_back hl ⟨mark.1,mark.2.1⟩ with ⟨_,g⟩ | born
  · have older : Mark s (l+1) := ⟨g.1,g.2, by
      simpa only [show s+(l+1) = s+1+l by omega] using mark.2.2⟩
    have := record _ older
    omega
  · exact born

/-- Evaluate the birth row with the preceding black bar continued indefinitely
to the west. Its two finite cone endpoints are -(l+1), l+1. -/
def arrival (l : Nat) (east : Int → Bool) : Bool :=
  evol (fun p => if p < -1 then true else east p) (l+1) 0

theorem arrival_eq {t l : Nat} (bar : Bar t l) :
    arrival l (cell t) = cell (t+1+l) 0 := by
  have eq : arrival l (cell t) = evol (cell t) (l+1) 0 := by
    apply Rule30LightCone.evol_window
    intro p lo _
    by_cases side : p < -1
    · simpa only [side, ite_true] using (bar.2.2 p (by omega) (by omega)).symm
    · simp [side]
  have reset := Rule30ZeroBoundaryBarriers.evol_restart seed t (l+1) 0
  simpa only [evol_seed, show t+1+l = t+(l+1) by omega] using eq.trans (by simpa only [evol_seed] using reset)

theorem unbounded_iff_births : (∀ B, ∃ s l, B < l ∧ Mark s l) ↔
    ∀ B, ∃ t l, B < l ∧ Bar t l ∧ arrival l (cell t) = true := by
  constructor
  · intro all B
    obtain ⟨s,l,hl,mark⟩ := all B
    obtain ⟨t,w,_,hw,_,bar,m,_⟩ := birth_of_mark (by omega) mark
    exact ⟨t,w,by omega,bar,(arrival_eq bar).trans m.2.2⟩
  · intro all B
    obtain ⟨t,l,hl,bar,h⟩ := all B
    have g := gap_of_bar bar
    exact ⟨t+1,l,hl,g.1,g.2,(arrival_eq bar).symm.trans h⟩

theorem problem1_of_births (h : ∀ B, ∃ t l, B < l ∧ Bar t l ∧ arrival l (cell t) = true) :
    Rule30Prize.Problem1 := problem1_of_marks (unbounded_iff_births.mpr h)

-- A bar clears one interior white triangle before another such bar can occur.
private theorem remains_white (s k : Nat) (a b : Int)
    (hw : ∀ p, a ≤ p → p ≤ b → cell s p = false) :
    ∀ p, a + (k:Int) ≤ p → p ≤ b - k → cell (s+k) p = false := by
  induction k with
  | zero => simpa using hw
  | succ k ih =>
    intro p lo hi
    change rule (cell (s+k) (p-1)) (cell (s+k) p) (cell (s+k) (p+1)) = false
    rw [ih (p-1) (by omega) (by omega), ih p (by omega) (by omega), ih (p+1) (by omega) (by omega)]
    rfl

/-- Distinct primitive sources of width at least 2d are more than d ticks apart. -/
theorem wide_births_apart {d s t l m : Nat} (hs : Bar s l) (ht : Bar t m)
    (hsw : 2*d ≤ l) (htw : 2*d ≤ m) (order : s < t) : s+d < t := by
  apply Classical.byContradiction
  intro notFar
  have hd : 0 < d := by omega
  let p : Int := -(d:Int)-1
  have swept (q : Int) (lo : -((2*d:Nat):Int) ≤ q) (hi : q ≤ -2) : cell (s+1) q = false := by
    change rule (cell s (q-1)) (cell s q) (cell s (q+1)) = false
    simp [rule, hs.2.2 (q-1) (by omega) (by omega), hs.2.2 q (by omega) hi]
  have dark := ht.2.2 p (by dsimp [p]; omega) (by dsimp [p]; omega)
  have pale := remains_white (s+1) (t-(s+1)) _ _ swept p
    (by dsimp [p]; omega) (by dsimp [p]; omega)
  rw [show s+1+(t-(s+1)) = t by omega, dark] at pale
  contradiction

/-- The leftmost black cap of a white interval persists on its east-moving
light ray for as long as both inputs to its right lie in the white cone. -/
private theorem cap_advances {s l : Nat} (gap : Gap s l) (k : Nat) (hk : 2*k ≤ l) :
    cell (s+k) (-(l:Int)-1+k) = true := by
  induction k with
  | zero => simpa using gap.2
  | succ k ih =>
    have front := ih (by omega)
    let p : Int := -(l:Int)-1+(k+1:Nat)
    have next : cell (s+k+1) p = rule (cell (s+k) (p-1)) (cell (s+k) p) (cell (s+k) (p+1)) := rfl
    have west : cell (s+k) (p-1) = true := by
      rwa [show p-1 = -(l:Int)-1+k by dsimp [p]; omega]
    have pale := remains_white s k (-(l:Int)) (-1) (fun q lo hi => gap.1 q lo (by omega))
    have one := pale p (by dsimp [p]; omega) (by dsimp [p]; omega)
    have two := pale (p+1) (by dsimp [p]; omega) (by dsimp [p]; omega)
    rw [west,one,two] at next
    exact next

/-- For distinct births sharing an arrival, the second width is less than half
the first. This result holds for unmarked gaps as well. -/
theorem collision_widths {t u l m : Nat} (h₁ : Bar t l) (h₂ : Bar u m)
    (prior : t < u) (collision : t+1+l = u+1+m) : 2*m+3 ≤ l := by
  apply Classical.byContradiction
  intro small
  let k := u-(t+1)
  have hcap := cap_advances (gap_of_bar h₁) k (by dsimp [k]; omega)
  rw [show t+1+k = u by dsimp [k]; omega,
    show -(l:Int)-1+k = -(m:Int)-2 by dsimp [k]; omega, h₂.2.1] at hcap
  contradiction

/-- In a single width band, counting primitive marks counts distinct black arrivals. -/
theorem band_arrivals_injective {t u l m L : Nat} (h₁ : Bar t l) (h₂ : Bar u m)
    (lo : L ≤ l ∧ L ≤ m) (hi : l ≤ 2*L+2 ∧ m ≤ 2*L+2)
    (same : t+1+l = u+1+m) : t = u := by
  rcases Nat.lt_trichotomy t u with a | e | b
  · have := collision_widths h₁ h₂ a same; omega
  · exact e
  · have := collision_widths h₂ h₁ b same.symm; omega

/-- The active gate and the last black bar cell force a black centre by tick t+2,
regardless of the eventual mark. -/
theorem near_black {t l : Nat} (bar : Bar t l) (wide : 1 ≤ l) :
    ∃ k ≤ 2, cell (t+k) 0 = true := by
  by_cases c : cell t 0 = true
  · exact ⟨0, by decide, by simpa using c⟩
  have h0 : cell t 0 = false := Bool.eq_false_iff.mpr c
  have hm1 : cell t (-1) = true := by simpa [active, h0] using bar.1
  have hm2 := bar.2.2 (-2) (by omega) (by omega)
  cases east : cell t 1 with
  | false =>
    refine ⟨1, by decide, ?_⟩
    change rule (cell t (-1)) (cell t 0) (cell t 1) = true
    rw [hm1,h0,east]; decide
  | true =>
    refine ⟨2, by decide, ?_⟩
    have a : cell (t+1) (-1) = false := by
      change rule (cell t (-2)) (cell t (-1)) (cell t 0) = false
      rw [hm2,hm1,h0]; decide
    have b : cell (t+1) 1 = true := by
      change rule (cell t 0) (cell t 1) (cell t 2) = true
      simp [rule,h0,east]
    change rule (cell (t+1) (-1)) (cell (t+1) 0) (cell (t+1) 1) = true
    simp [rule,a,b]

/-- The kit's black-triangle law forces a white centre by t+3. -/
theorem near_white {t l : Nat} (bar : Bar t l) (wide : 2 ≤ l) :
    ∃ k ≤ 3, cell (t+k) 0 = false := by
  apply Classical.byContradiction
  intro missed
  have all (k : Nat) (hk : k < 4) : cell (t+k) 0 = true := by
    cases h : cell (t+k) 0 with
    | false => exact (missed ⟨k, by omega, h⟩).elim
    | true => rfl
  have triangle := Rule30CenterRuns.black_triangle t 4 all 3 t (by omega) (by omega)
  change cell t (-3) = false at triangle
  rw [bar.2.2 (-3) (by omega) (by omega)] at triangle
  contradiction

/-- Each width-at-least-six birth before N supplies a distinct centre tick
of either prescribed colour before N+3. -/
theorem birth_count_le (N k : Nat) (time width : Fin k → Nat)
    (distinct : ∀ i j, time i = time j → i = j) (before : ∀ i, time i < N)
    (wide : ∀ i, 6 ≤ width i) (birth : ∀ i, Bar (time i) (width i)) (b : Bool) :
    k ≤ ((List.range (N+3)).filter fun t => decide (cell t 0 = b)).length := by
  have hit (i : Fin k) : ∃ d ≤ 3, cell (time i+d) 0 = b := by
    cases b with
    | false => exact near_white (birth i) (by have := wide i; omega)
    | true =>
      obtain ⟨d,small,found⟩ := near_black (birth i) (by have := wide i; omega)
      exact ⟨d,by omega,found⟩
  let pick (i : Fin k) := time i + Classical.choose (hit i)
  have bounds (i : Fin k) : time i ≤ pick i ∧ pick i ≤ time i+3 := by
    have h := (Classical.choose_spec (hit i)).1
    dsimp [pick]; omega
  have inject (i j : Fin k) (eq : pick i = pick j) : i = j := by
    have bi := bounds i
    have bj := bounds j
    rcases Nat.lt_trichotomy (time i) (time j) with lt | same | gt
    · have := wide_births_apart (d := 3) (birth i) (birth j) (wide i) (wide j) lt; omega
    · exact distinct i j same
    · have := wide_births_apart (d := 3) (birth j) (birth i) (wide j) (wide i) gt; omega
  have clean : ((List.finRange k).map pick).Nodup :=
    (List.nodup_finRange k).map pick (fun i j ne eq => ne (inject i j eq))
  have included : (List.finRange k).map pick ⊆
      (List.range (N+3)).filter (fun t => decide (cell t 0 = b)) := by
    intro t ht
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp ht
    have less := before i
    have bi := bounds i
    simp only [List.mem_filter, List.mem_range, decide_eq_true_eq]
    exact ⟨by omega, (Classical.choose_spec (hit i)).2⟩
  simpa using clean.length_le_of_subset included

end PhaseTwo.MarkLaunch
