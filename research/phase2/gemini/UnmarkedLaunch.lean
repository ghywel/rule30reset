import MarkLaunch
import Ruliology.CellularAutomata.Rule30FiniteConfigs

/-! The first active check after a white arrival, and primitive births near a fall. -/
namespace PhaseTwo.UnmarkedLaunch
open Ruliology.CellularAutomata Rule30Jen Rule30Realization Rule30DrivenLeft Rule30MarkedGaps
open PhaseTwo.MarkLaunch

abbrev tape (s j : Nat) := cell (s+j) 0
def singleCap (l : Nat) (p : Int) : Bool := decide (p = -(l:Int)-1)
def response (s l : Nat) : Bool :=
  xor (L (tape s) (fun _ => false) (l+1) (-1)) (L (tape s) (singleCap l) (l+1) (-1))

private theorem failed_iff (s k : Nat) : Failed (tape s) k ↔
    tape s k = true ∧ L (tape s) (fun _ => false) k (-1) ≠ L (tape s) (cell s) k (-1) := by
  have on (h : tape s k = true) : L (tape s) (cell s) k (-1) = !(tape s (k+1)) := by
    change cell (s+k) 0 = true at h
    rw [cell_eq_L s k _ (by decide)]
    have e := cell_left (s+k) 0
    rw [h,Bool.true_or] at e
    unfold tape
    rw [← Nat.add_assoc]
    cases bit : cell (s+k+1) 0 <;> simpa [bit] using e
  exact ⟨fun h => ⟨h.1,by rw [on h.1]; exact h.2⟩, fun h => ⟨h.1,by rw [← on h.1]; exact h.2⟩⟩

private theorem cap_flank {s l : Nat} (g : Gap s l) :
    L (tape s) (cell s) (l+1) (-1) =
      xor (cell s (-(l:Int)-2)) (L (tape s) (singleCap l) (l+1) (-1)) := by
  have shared (p : Int) (lo : -((l+1:Nat):Int) ≤ p) (hi : p < 0) :
      cell s p = singleCap l p := by
    by_cases eq : p = -(l:Int)-1
    · simpa [singleCap,eq] using g.2
    · simpa [singleCap,eq] using g.1 p (by omega) hi
  have deep : -((l+1+1:Nat):Int) = -(l:Int)-2 := by omega
  have clear : singleCap l (-(l:Int)-2) = false := by simp [singleCap]
  cases b : cell s (-(l:Int)-2) with
  | false =>
    have eq (p : Int) (lo : -((l+1+1:Nat):Int) ≤ p) (hi : p < 0) : cell s p = singleCap l p := by
      by_cases e : p = -(l:Int)-2
      · rw [e,b,clear]
      · exact shared p (by omega) hi
    simpa using (light_cone (c:=tape s) (k:=l+1) eq (l+1) (by omega) (-1) (by omega) (by decide))
  | true =>
    have diff : cell s (-((l+1+1:Nat):Int)) = !singleCap l (-((l+1+1:Nat):Int)) := by rw [deep,b,clear]; rfl
    have h := (permutive_aux (c:=tape s) (k:=l+1) shared diff (l+1) (by omega)).2
    simpa [show -((l+1+1-(l+1):Nat):Int) = -1 by omega] using h

/-- One extra western bit decides precisely when a white arrival loses the next check. -/
theorem first_after_white_iff {s l : Nat} (g : Gap s l) (white : tape s l = false) :
    FirstFailure (tape s) (l+1) ↔
    tape s (l+1) = true ∧ cell s (-(l:Int)-2) ≠ response s l := by
  have early (j : Nat) (hj : j < l+1) : ¬Failed (tape s) j := by
    intro bad
    by_cases e : j = l
    · exact Bool.noConfusion (white.symm.trans (e ▸ bad.1))
    · have := light_cone (c:=tape s) (s:=cell s) (s':=fun _ => false) (k:=j)
                 (fun p lo hi => g.1 p (by omega) hi) j (by omega) (-1) (by omega) (by decide)
      exact ((failed_iff s j).mp bad).2 this.symm
  have eq : Failed (tape s) (l+1) ↔
      tape s (l+1) = true ∧ cell s (-(l:Int)-2) ≠ response s l := by
    rw [failed_iff,cap_flank g]
    unfold response
    cases cell s (-(l:Int)-2) <;> cases L (tape s) (fun _ => false) (l+1) (-1) <;>
      cases L (tape s) (singleCap l) (l+1) (-1) <;> simp
  exact ⟨fun h => eq.mp h.1,fun h => ⟨eq.mpr h,early⟩⟩

theorem problem1_of_white_births
    (h : ∀ B, ∃ t l, B < l ∧ Bar t l ∧ tape (t+1) l = false ∧ tape (t+1) (l+1) = true ∧
        cell (t+1) (-(l:Int)-2) ≠ response (t+1) l) : Rule30Prize.Problem1 := by
  apply problem1_of_first_failures
  intro B
  obtain ⟨t,l,wide,bar,white,ok⟩ := h B
  exact ⟨t+1,l+1,by omega,(first_after_white_iff (gap_of_bar bar) white).mpr ok⟩

/-- Any two western whites force an equal centre pair within the following two updates. -/
theorem equal_pair {s : Nat} (near : cell s (-1) = false) (far : cell s (-2) = false) :
    cell s 0 = cell (s+1) 0 ∨ cell (s+1) 0 = cell (s+2) 0 := by
  have next : cell (s+1) 0 = rule (cell s (-1)) (cell s 0) (cell s 1) := rfl
  have west : cell (s+1) (-1) = rule (cell s (-2)) (cell s (-1)) (cell s 0) := rfl
  have later : cell (s+2) 0 = rule (cell (s+1) (-1)) (cell (s+1) 0) (cell (s+1) 1) := rfl
  rw [near] at next west
  rw [far] at west
  cases a : cell s 0 <;> cases b : cell s 1 <;> simp_all [rule]

private theorem nonconstant (i : Int) : ¬∃ T b, ∀ t, T ≤ t → cell t i = b := by
  simpa only [evol_seed] using
    (Rule30FiniteConfigs.no_column_eventually_constant (x:=seed) (lo:=0) rfl
      (fun p hp => by simp [seed]; omega) i)

private theorem no_equal_in_alternation {T u : Nat}
    (alt : ∀ t, T ≤ t → cell (t+1) 0 = !cell t 0) (hu : T ≤ u) :
    cell u 0 ≠ cell (u+1) 0 := by
  intro eq
  have h := alt u hu
  rw [← eq] at h
  cases b : cell u 0 <;> simp [b] at h

private theorem no_bar_in_alternation {T t l : Nat}
    (alt : ∀ u, T ≤ u → cell (u+1) 0 = !cell u 0) (ht : T ≤ t+1)
    (wide : 2 ≤ l) (bar : Bar t l) : False := by
  have g := gap_of_bar bar
  rcases equal_pair (g.1 (-1) (by omega) (by decide)) (g.1 (-2) (by omega) (by decide)) with e | e
  · exact no_equal_in_alternation alt ht e
  · exact no_equal_in_alternation (u:=t+2) alt (by omega) e

theorem no_period_two_of_births
    (late : ∀ T, ∃ t l, T ≤ t ∧ 2 ≤ l ∧ Bar t l) :
    ¬ ∃ T, ∀ t, T ≤ t → cell (t+2) 0 = cell t 0 := by
  rintro ⟨T,per⟩
  obtain ⟨t,l,ht,wide,bar⟩ := late T
  exact no_bar_in_alternation (Rule30FiniteConfigs.alternates_of_period_two per (nonconstant 0))
    (by omega) wide bar

/-- The same capped gap and primitive birth viewed from observer +1. -/
def EastGap (s l : Nat) : Prop :=
  (∀ p : Int, 1-(l:Int) ≤ p → p ≤ 0 → cell s p = false) ∧ cell s (-(l:Int)) = true

def EastBirth (t l : Nat) : Prop :=
  (cell t 0 || cell t 1) = true ∧ EastGap (t+1) l

private theorem east_back {s l : Nat} (wide : 0 < l) (g : EastGap (s+1) l) :
    EastGap s (l+1) ∨ EastBirth s l := by
  let e : Int := (s:Int)+1
  have old (k : Int) : Rule30ClockNearSquares.D seed e k s = cell s (k+1) := by
    simp only [Rule30ClockNearSquares.D,evol_seed,e]; congr 1; omega
  have now (k : Int) : Rule30ClockNearSquares.D seed e k (s+1) = cell (s+1) k := by
    simp only [Rule30ClockNearSquares.D,evol_seed,e]; congr 1; omega
  have d := Rule30SettledRepeats.back seed e (-(l:Int)) 0 s (by omega)
    (by rw [now]; exact g.2) (fun p lo hi => by rw [now]; exact g.1 p (by omega) hi)
  simp only [old] at d
  rcases d with ⟨wh,cap⟩ | ⟨_,active⟩
  · left
    refine ⟨fun p lo hi => ?_,?_⟩
    · simpa using wh (p-1) (by omega) (by omega)
    · simpa only [show -(l:Int)-2+1 = -((l+1:Nat):Int) by omega] using cap
  · exact Or.inr ⟨Bool.or_eq_true_iff.mpr active,g⟩

private theorem east_source {s l : Nat} (wide : 0 < l) (g : EastGap s l) :
    ∃ v w, v < s ∧ l ≤ w ∧ v+1+w = s+l ∧ EastBirth v w := by
  induction s generalizing l with
  | zero =>
    have h := g.1 0 (by omega) (by decide)
    contradiction
  | succ s ih =>
    rcases east_back wide g with prev | birth
    · obtain ⟨v,w,hv,hw,age,b⟩ := ih (by omega) prev
      exact ⟨v,w,by omega,by omega,by omega,b⟩
    · exact ⟨s,l,by omega,by omega,rfl,birth⟩

/-- An active fall produces a centre birth. A silent fall at t charges a
unique-width birth at +1 at age v with t ≤ 2v and v+1+w = t+2. -/
theorem source_of_fall {t : Nat} (fall : cell t (-2) = true ∧ cell (t+1) (-2) = false) :
    (∃ w, 2 ≤ w ∧ Bar t w) ∨
    (∃ v w, v < t ∧ t ≤ 2*v ∧ 2 ≤ w ∧ v+1+w = t+2 ∧ EastBirth v w) := by
  obtain ⟨leftBit,rightBit⟩ := (fall_iff t).mp fall
  cases a : active t with
  | true => exact Or.inl ((two_iff_four_cells t).mpr ⟨leftBit,rightBit,a⟩)
  | false =>
    obtain ⟨near,center⟩ := Bool.or_eq_false_iff.mp a
    have gap : EastGap t 2 := by
      refine ⟨fun p lo hi => ?_,rightBit⟩
      have poss : p = -1 ∨ p = 0 := by omega
      rcases poss with h | h <;> simpa [h]
    obtain ⟨v,w,lt,wide,age,b⟩ := east_source (by decide) gap
    have bound : w ≤ v+1 := by
      apply Classical.byContradiction
      intro h
      have pale := cell_eq_false_of_lt (v+1) (-(w:Int)) (by omega)
      rw [b.2.2] at pale
      contradiction
    exact Or.inr ⟨v,w,lt,by omega,wide,age,b⟩

theorem east_birth_width_unique {v w u : Nat} (x : EastBirth v w) (y : EastBirth v u) : w = u := by
  rcases Nat.lt_trichotomy w u with h | h | h
  · have := y.2.1 (-(w:Int)) (by omega) (by omega)
    rw [x.2.2] at this
    contradiction
  · exact h
  · have := x.2.1 (-(u:Int)) (by omega) (by omega)
    rw [y.2.2] at this
    contradiction

private theorem late_fall (T : Nat) : ∃ t, T ≤ t ∧ cell t (-2) = true ∧ cell (t+1) (-2) = false := by
  apply Classical.byContradiction
  intro no
  have black : ∃ t, T ≤ t ∧ cell t (-2) = true := by
    apply Classical.byContradiction
    intro none
    apply nonconstant (-2)
    exact ⟨T,false,fun t ht => by
      cases h : cell t (-2) with
      | true => exact (none ⟨t,ht,h⟩).elim
      | false => rfl⟩
  obtain ⟨t,ht,b⟩ := black
  have stays (n : Nat) : cell (t+n) (-2) = true := by
    induction n with
    | zero => exact b
    | succ n ih =>
      cases h : cell (t+n+1) (-2) with
      | true => rfl
      | false => exact (no ⟨t+n,by omega,ih,h⟩).elim
  exact nonconstant (-2) ⟨t,true,fun u hu => by simpa [Nat.add_sub_of_le hu] using stays (u-t)⟩

/-- Unconditional two-observer recurrence of primitive births, all of width at least two. -/
theorem cofinal_births_either_site :
    (∀ T, ∃ t w, T ≤ t ∧ 2 ≤ w ∧ Bar t w) ∨
    (∀ T, ∃ t w, T ≤ t ∧ 2 ≤ w ∧ EastBirth t w) := by
  by_cases c : ∀ T, ∃ t w, T ≤ t ∧ 2 ≤ w ∧ Bar t w
  · exact Or.inl c
  · right
    obtain ⟨cut,bounded⟩ := Classical.not_forall.mp c
    intro T
    obtain ⟨t,large,fall⟩ := late_fall (cut+2*T)
    rcases source_of_fall fall with ⟨w,wide,b⟩ | ⟨v,w,_,hv,wide,_,b⟩
    · exact (bounded ⟨t,w,by omega,wide,b⟩).elim
    · exact ⟨v,w,by omega,wide,b⟩

/-- In an alternating tail every late fall is forced into the white phase.
The preceding tick launches an exact width-two gap at +1, and +1 is black at the fall. -/
theorem alternating_fall {T u : Nat} (alt : ∀ t, T ≤ t → cell (t+1) 0 = !cell t 0)
    (hu : T ≤ u) (fall : cell (u+1) (-2) = true ∧ cell (u+2) (-2) = false) :
    EastBirth u 2 ∧ cell (u+1) (-1) = false ∧ cell (u+1) 0 = false ∧ cell (u+1) 1 = true := by
  obtain ⟨west,cap⟩ := (fall_iff _).mp fall
  have quiet : active (u+1) = false := by
    cases a : active (u+1) with
    | false => rfl
    | true =>
      obtain ⟨l,wide,b⟩ := (two_iff_four_cells _).mpr ⟨west,cap,a⟩
      exact (no_bar_in_alternation alt (by omega) wide b).elim
  obtain ⟨near,center⟩ := Bool.or_eq_false_iff.mp quiet
  have oldBlack : cell u 0 = true := by
    have prev := alt u hu
    rw [center] at prev
    cases z : cell u 0 with
    | false => simp [z] at prev
    | true => rfl
  have nextBlack := alt (u+1) (by omega)
  rw [center] at nextBlack
  change rule (cell (u+1) (-1)) (cell (u+1) 0) (cell (u+1) 1) = true at nextBlack
  refine ⟨⟨by simp [oldBlack],fun p lo hi => ?_,cap⟩,near,center,by simpa [rule,near,center] using nextBlack⟩
  have pos : p = -1 ∨ p = 0 := by omega
  rcases pos with h | h <;> simpa [h]

end PhaseTwo.UnmarkedLaunch
