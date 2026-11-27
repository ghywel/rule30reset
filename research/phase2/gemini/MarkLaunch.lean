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

/-- A bar of width at least two occurs exactly on the four-site words
1101, 1110, 1111, read from west to east. -/
theorem two_iff_four_cells (t : Nat) :
    (∃ l, 2 ≤ l ∧ Bar t l) ↔
    cell t (-3) = true ∧ cell t (-2) = true ∧ active t = true := by
  constructor
  · rintro ⟨l,wide,bar⟩
    exact ⟨bar.2.2 _ (by omega) (by omega), bar.2.2 _ (by omega) (by omega), bar.1⟩
  · rintro ⟨at3,at2,gate⟩
    let W (j : Nat) := cell t (-(j:Int)-2) = false
    have least (n : Nat) : W n → ∃ w, W w ∧ ∀ j < w, ¬ W j := by
      induction n using Nat.strongRecOn with
      | ind n ih =>
        intro white
        by_cases earlier : ∃ j < n, W j
        · obtain ⟨j,lt,h⟩ := earlier
          exact ih j lt h
        · exact ⟨n,white,fun j lt h => earlier ⟨j,lt,h⟩⟩
    obtain ⟨w,white,first⟩ := least t (cell_eq_false_of_lt t _ (by omega))
    have wide : 2 ≤ w := by
      apply Classical.byContradiction
      intro narrow
      have tiny : w = 0 ∨ w = 1 := by omega
      rcases tiny with h | h <;> subst w <;> simp [W,at2,at3] at white
    refine ⟨w,wide,gate,white,fun p lo hi => ?_⟩
    let j := (-p-2).toNat
    have pos : -(j:Int)-2 = p := by dsimp [j]; omega
    cases h : cell t p with
    | false => exact (first j (by dsimp [j]; omega) (by simpa [W,pos] using h)).elim
    | true => rfl

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
private theorem white_of_m3 {t : Nat} (west : cell t (-3) = true) :
    ∃ k ≤ 3, cell (t+k) 0 = false := by
  apply Classical.byContradiction
  intro missed
  have all (k : Nat) (hk : k < 4) : cell (t+k) 0 = true := by
    cases h : cell (t+k) 0 with
    | false => exact (missed ⟨k, by omega, h⟩).elim
    | true => rfl
  have triangle := Rule30CenterRuns.black_triangle t 4 all 3 t (by omega) (by omega)
  change cell t (-3) = false at triangle
  rw [west] at triangle
  contradiction

theorem near_white {t l : Nat} (bar : Bar t l) (wide : 2 ≤ l) :
    ∃ k ≤ 3, cell (t+k) 0 = false :=
  white_of_m3 (bar.2.2 _ (by omega) (by omega))

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

private theorem count_le_twice (N k : Nat) (time : Fin k → Nat) (b : Bool)
    (distinct : ∀ i j, time i = time j → i = j) (before : ∀ i, time i < N)
    (apart : ∀ i j, time i < time j → time i+1 < time j)
    (hit : ∀ i, ∃ d ≤ 3, cell (time i+d) 0 = b) :
    k ≤ 2 * ((List.range (N+3)).filter fun t => decide (cell t 0 = b)).length := by
  let pick (i : Fin k) := time i + Classical.choose (hit i)
  let code (i : Fin k) := (pick i, decide (pick i ≤ time i+1))
  have bounds (i : Fin k) : time i ≤ pick i ∧ pick i ≤ time i+3 := by
    have h := (Classical.choose_spec (hit i)).1
    dsimp [pick]; omega
  have inject (i j : Fin k) (eq : code i = code j) : i = j := by
    obtain ⟨same,tag⟩ := Prod.ext_iff.mp eq
    change pick i = pick j at same
    change decide (pick i ≤ time i+1) = decide (pick j ≤ time j+1) at tag
    have bi := bounds i
    have bj := bounds j
    have close : time i ≤ time j+1 ∧ time j ≤ time i+1 := by
      by_cases a : pick i ≤ time i+1 <;> by_cases b : pick j ≤ time j+1 <;>
        simp [a,b] at tag <;> omega
    rcases Nat.lt_trichotomy (time i) (time j) with lt | e | gt
    · have := apart i j lt; omega
    · exact distinct i j e
    · have := apart j i gt; omega
  let ticks := (List.range (N+3)).filter fun t => decide (cell t 0 = b)
  let tagged := ticks.map (fun t => (t, true)) ++ ticks.map (fun t => (t, false))
  have clean : ((List.finRange k).map code).Nodup :=
    (List.nodup_finRange k).map code (fun i j ne eq => ne (inject i j eq))
  have included : (List.finRange k).map code ⊆ tagged := by
    intro x hx
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp hx
    have mem : pick i ∈ ticks := by
      have less := before i
      have bi := bounds i
      simp only [ticks, List.mem_filter, List.mem_range, decide_eq_true_eq]
      exact ⟨by omega, (Classical.choose_spec (hit i)).2⟩
    apply List.mem_append.mpr
    by_cases e : pick i ≤ time i+1
    · exact Or.inl (List.mem_map.mpr ⟨pick i,mem,by simp [code,e]⟩)
    · exact Or.inr (List.mem_map.mpr ⟨pick i,mem,by simp [code,e]⟩)
  simpa [tagged, ticks, Nat.two_mul] using clean.length_le_of_subset included

/-- Each centre tick can account for at most two width-at-least-two births.
The four possible birth times split into two pairs of consecutive times. -/
theorem birth_count_le_twice (N k : Nat) (time width : Fin k → Nat)
    (distinct : ∀ i j, time i = time j → i = j) (before : ∀ i, time i < N)
    (wide : ∀ i, 2 ≤ width i) (birth : ∀ i, Bar (time i) (width i)) (b : Bool) :
    k ≤ 2 * ((List.range (N+3)).filter fun t => decide (cell t 0 = b)).length := by
  apply count_le_twice N k time b distinct before (fun i j =>
    wide_births_apart (d := 1) (birth i) (birth j) (wide i) (wide j))
  intro i
  cases b with
  | false => exact near_white (birth i) (wide i)
  | true =>
    obtain ⟨d,small,found⟩ := near_black (birth i) (by have := wide i; omega)
    exact ⟨d,by omega,found⟩

/-- On the whole-line checkerboard with a black centre, a width-one bar
occurs on every row while the centre stays black. -/
def checker (p : Int) : Bool := decide (p % 2 = 0)

private theorem checker_fixed (t : Nat) : ∀ p, evol checker t p = checker p := by
  induction t with
  | zero => intro p; rfl
  | succ t ih =>
    intro p
    change rule (evol checker t (p-1)) (evol checker t p) (evol checker t (p+1)) = _
    rw [ih,ih,ih]
    by_cases h : p % 2 = 0
    · have left : (p-1) % 2 ≠ 0 := by omega
      have right : (p+1) % 2 ≠ 0 := by omega
      simp [rule,checker,h,left,right]
    · have left : (p-1) % 2 = 0 := by omega
      have right : (p+1) % 2 = 0 := by omega
      simp [rule,checker,h,left,right]

theorem width_one_obstruction (t : Nat) :
    evol checker t (-3) = false ∧ evol checker t (-2) = true ∧
    evol checker t (-1) = false ∧ evol checker t 0 = true := by
  simp [checker_fixed, checker]

/-- A black-to-white transition at -2 is the spatial pair 11 at -3,-2. -/
theorem fall_iff (t : Nat) :
    (cell t (-2) = true ∧ cell (t+1) (-2) = false) ↔
    cell t (-3) = true ∧ cell t (-2) = true := by
  change (_ ∧ rule (cell t (-3)) (cell t (-2)) (cell t (-1)) = false) ↔ _
  cases cell t (-3) <;> cases cell t (-2) <;> simp [rule]

/-- Even falls at a quiet gate force a nearby white centre tick. -/
theorem fall_count_le_twice_white (N k : Nat) (time : Fin k → Nat)
    (distinct : ∀ i j, time i = time j → i = j) (before : ∀ i, time i < N)
    (fall : ∀ i, cell (time i) (-2) = true ∧ cell (time i+1) (-2) = false) :
    k ≤ 2 * ((List.range (N+3)).filter fun t => decide (cell t 0 = false)).length := by
  apply count_le_twice N k time false distinct before
  · intro i j h
    have ne : time i+1 ≠ time j := by
      intro same
      have pale := (fall i).2
      rw [same,(fall j).1] at pale
      contradiction
    omega
  · exact fun i => white_of_m3 ((fall_iff _).mp (fall i)).1

private def bit (b : Bool) : Nat := if b then 1 else 0

/-- Black cells before N in column p. -/
def black (p : Int) : Nat → Nat
  | 0 => 0
  | n+1 => black p n + bit (cell n p)

private theorem bit_bound (b : Bool) : bit b ≤ 1 := by cases b <;> decide

/-- If three successive centre bits are white, the bit two sites west is
exactly the rise of the eastern neighbour. The allowances on the right
account for centre blacks when this premise fails. -/
private theorem budget_step (a w c e r : Bool) :
    bit a + bit e ≤ bit (rule c e r) + 2 * bit c + bit (rule w c e) +
    bit (rule (rule a w c) (rule w c e) (rule c e r)) := by
  revert a w c e r
  decide +kernel

/-- A black centre count controls all black ticks two sites west, with no
condition on the intervening site or on the centre bond. -/
theorem black_two_west (N : Nat) :
    black (-2) N ≤ 4 * black 0 (N+2) + 1 := by
  have sum (n : Nat) : black (-2) n + bit (cell 0 1) ≤
      bit (cell n 1) + 2 * black 0 n + black 0 (n+1) + black 0 (n+2) := by
    induction n with
    | zero => simp [black, bit, cell]
    | succ n ih =>
      have step : bit (cell n (-2)) + bit (cell n 1) ≤ bit (cell (n+1) 1) +
          2 * bit (cell n 0) + bit (cell (n+1) 0) + bit (cell (n+2) 0) :=
        budget_step _ _ _ _ _
      have count (p : Int) (k : Nat) : black p (k+1) = black p k + bit (cell k p) := rfl
      have ca := count (-2) n
      have cb := count 0 n
      have cc := count 0 (n+1)
      have cd := count 0 (n+2)
      simp only [Nat.add_assoc, Nat.reduceAdd] at *
      omega
  have m₁ : black 0 N ≤ black 0 (N+1) := by change _ ≤ _ + _; omega
  have m₂ : black 0 (N+1) ≤ black 0 (N+2) := by change _ ≤ _ + _; omega
  have bounded := bit_bound (cell N 1)
  have total := sum N
  omega

end PhaseTwo.MarkLaunch
