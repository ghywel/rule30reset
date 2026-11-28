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

/-- A fall whose five-cell word differs from 11001. -/
def ForcingFall (t : Nat) : Prop :=
  (cell t (-2) = true ∧ cell (t+1) (-2) = false) ∧
  ¬(cell t (-1) = false ∧ cell t 0 = false ∧ cell t 1 = true)

private def pairStart (t : Nat) : Nat :=
  if active t then (if cell (t+1) 0 = cell (t+2) 0 then t+1 else t+2) else t

private theorem pair_spec {t : Nat} (f : ForcingFall t) :
    t ≤ pairStart t ∧ pairStart t ≤ t+2 ∧
    cell (pairStart t) 0 = cell (pairStart t+1) 0 ∧
    (pairStart t = t → cell (pairStart t) 0 = false) ∧
    (pairStart t = t+2 → cell (pairStart t) 0 = true) := by
  obtain ⟨west,cap⟩ := (fall_iff t).mp f.1
  cases a : active t with
  | false =>
    obtain ⟨w,c⟩ := Bool.or_eq_false_iff.mp a
    have east : cell t 1 = false := by
      cases b : cell t 1 with
      | false => rfl
      | true => exact (f.2 ⟨w,c,b⟩).elim
    have next : cell (t+1) 0 = rule (cell t (-1)) (cell t 0) (cell t 1) := rfl
    simp [pairStart,a,c,w,east,next,rule]
  | true =>
    obtain ⟨l,wide,b⟩ := (two_iff_four_cells _).mpr ⟨west,cap,a⟩
    have g := gap_of_bar b
    have near := g.1 (-1) (by omega) (by decide)
    have eq := equal_pair near (g.1 (-2) (by omega) (by decide))
    by_cases first : cell (t+1) 0 = cell (t+2) 0
    · have p : pairStart t = t+1 := by simp [pairStart,a,first]
      rw [p]
      exact ⟨by omega,by omega,first,by omega,by omega⟩
    · have p : pairStart t = t+2 := by simp [pairStart,a,first]
      have next : cell (t+2) 0 = rule (cell (t+1) (-1)) (cell (t+1) 0) (cell (t+1) 1) := rfl
      have raised : cell (t+2) 0 = true := by
        cases c : cell (t+1) 0 <;> cases e : cell (t+1) 1 <;> simp_all only [rule, Bool.false_xor,
          Bool.or_false,Bool.or_true,not_true_eq_false]
      rw [p]
      exact ⟨by omega,by omega,eq.resolve_left first,by omega,fun _ => raised⟩

private theorem pair_increases {t u : Nat} (f : ForcingFall t) (g : ForcingFall u) (lt : t < u) :
    pairStart t < pairStart u := by
  have gap : t+1 < u := by
    have ne : t+1 ≠ u := by
      intro eq
      have white := f.1.2
      rw [eq,g.1.1] at white
      contradiction
    omega
  obtain ⟨_,hi,_,_,endBlack⟩ := pair_spec f
  obtain ⟨lo,_,_,startWhite,_⟩ := pair_spec g
  by_cases same : pairStart t = pairStart u
  · have b := endBlack (by omega)
    rw [same,startWhite (by omega)] at b
    contradiction
  · omega

/-- Every five-cell exception pays for a different equal pair, including silent 11000 falls. -/
theorem forcing_count_le_equal_pairs (N : Nat) :
    ((List.range N).filter (fun t => (cell t (-2) && !cell (t+1) (-2)) &&
      (cell t (-1) || cell t 0 || !cell t 1))).length ≤
    ((List.range (N+2)).filter (fun q => decide (cell q 0 = cell (q+1) 0))).length := by
  let ts := (List.range N).filter (fun t => (cell t (-2) && !cell (t+1) (-2)) &&
    (cell t (-1) || cell t 0 || !cell t 1))
  have prop {t : Nat} (h : t ∈ ts) : t < N ∧ ForcingFall t := by
    obtain ⟨bound,ok⟩ := List.mem_filter.mp h
    refine ⟨List.mem_range.mp bound,?_,?_⟩
    · simpa using (Bool.and_eq_true_iff.mp ok).1
    · rintro ⟨w,c,e⟩
      simp [w,c,e] at ok
  have distinct : (ts.map pairStart).Nodup := by
    have ordered : ts.Pairwise (· < ·) := List.pairwise_lt_range.filter _
    apply List.pairwise_map.mpr
    apply ordered.imp_of_mem
    intro a b ha hb lt
    exact Nat.ne_of_lt (pair_increases (prop ha).2 (prop hb).2 lt)
  have sub : ts.map pairStart ⊆ (List.range (N+2)).filter (fun q => decide (cell q 0 = cell (q+1) 0)) := by
    intro q h
    obtain ⟨t,ht,rfl⟩ := List.mem_map.mp h
    obtain ⟨bound,f⟩ := prop ht
    obtain ⟨_,hi,eq,_⟩ := pair_spec f
    exact List.mem_filter.mpr ⟨List.mem_range.mpr (by omega),decide_eq_true eq⟩
  simpa [ts] using distinct.length_le_of_subset sub

/-- At the first black before the gap runs out, the adjacent western bit is
still white. Thus the next centre tick is also black. -/
theorem first_black_pairs {s l : Nat} (g : Gap s l) :
    (∀ j, j < l → tape s j = false) ∨
    ∃ j < l, (∀ i, i < j → tape s i = false) ∧ tape s j = true ∧ tape s (j+1) = true := by
  induction l generalizing s with
  | zero => exact Or.inl (by omega)
  | succ l ih =>
    have west := g.1 (-1) (by omega) (by decide)
    cases c : cell s 0 with
    | true =>
      have next : cell (s+1) 0 = rule (cell s (-1)) (cell s 0) (cell s 1) := rfl
      exact Or.inr ⟨0,by omega,by omega,c,by simp [tape,next,west,c,rule]⟩
    | false =>
      have rest := gap_of_quiet (t:=s) (l:=l) (by simp [active,west,c]) g
      have shift (j : Nat) : tape s (j+1) = tape (s+1) j := by
        simp only [tape,show s+(j+1)=s+1+j by omega]
      rcases ih rest with zeros | ⟨j,hj,wh,yes,next⟩
      · left
        rintro (_ | j) h
        · exact c
        · exact (shift _).trans (zeros _ (by omega))
      · right
        refine ⟨j+1,by omega,?_,(shift _).trans yes,(shift _).trans next⟩
        rintro (_ | i) hi
        · exact c
        · exact (shift _).trans (wh _ (by omega))

/-- From any proposed tail start, one western gap of width w excludes a clock
with at least one black in every w ticks and no consecutive blacks. -/
theorem excludes_isolated_clock {T s w : Nat} (late : T ≤ s) (g : Gap s w)
    (hits : ∀ u, T ≤ u → ∃ j < w, tape u j = true)
    (isolated : ∀ u, T ≤ u → cell u 0 = true → cell (u+1) 0 = false) : False := by
  rcases first_black_pairs g with zeros | ⟨j,_,_,b,pair⟩
  · obtain ⟨j,lt,h⟩ := hits s late
    rw [zeros _ lt] at h
    contradiction
  · have z := isolated (s+j) (by omega) b
    change cell (s+(j+1)) 0 = true at pair
    rw [← Nat.add_assoc,z] at pair
    contradiction

theorem no_period_two_of_forcing_falls
    (late : ∀ T, ∃ t, T ≤ t ∧ ForcingFall t) :
    ¬ ∃ T, ∀ t, T ≤ t → cell (t+2) 0 = cell t 0 := by
  rintro ⟨T,per⟩
  obtain ⟨t,late,f⟩ := late T
  obtain ⟨lower,_,pair,_⟩ := pair_spec f
  exact no_equal_in_alternation (Rule30FiniteConfigs.alternates_of_period_two per (nonconstant 0))
    (by omega) pair

/-- At the maximum possible white-run length, an isolated-black clock forces
the whole gap interval white followed by a mark exactly at its endpoint. -/
theorem mark_at_max_white_run {s l : Nat} (g : Gap s l)
    (hit : ∃ j ≤ l, tape s j = true)
    (isolated : ∀ j < l, tape s j = true → tape s (j+1) = false) :
    (∀ j < l, tape s j = false) ∧ Mark s l := by
  rcases first_black_pairs g with zeros | ⟨j,hj,_,b,pair⟩
  · obtain ⟨k,le,on⟩ := hit
    have e : k = l := by
      by_cases lt : k < l
      · rw [zeros _ lt] at on
        contradiction
      · omega
    exact ⟨zeros,g.1,g.2,e ▸ on⟩
  · rw [isolated _ hj b] at pair
    contradiction

/-- Two black cells placed on opposite cone tips attain the finite endpoint
at every width: the observer reads l whites, one black, then white. -/
def twoTips (l : Nat) (p : Int) : Bool := decide (p = -(l:Int)-1 ∨ p = (l:Int))

private theorem advancing_tips (l k : Nat) (hk : k ≤ l) :
    evol (twoTips l) k (-(l:Int)-1+k) = true ∧ evol (twoTips l) k ((l:Int)-k) = true ∧
    ∀ p : Int, -(l:Int)-1+k < p → p < (l:Int)-k → evol (twoTips l) k p = false := by
  induction k with
  | zero =>
    refine ⟨by simp [evol,twoTips],by simp [evol,twoTips],?_⟩
    intro p lo hi
    simp [evol,twoTips,show p ≠ -(l:Int)-1 by omega,show p ≠ (l:Int) by omega]
  | succ k ih =>
    obtain ⟨left,right,white⟩ := ih (by omega)
    let a : Int := -(l:Int)-1+k
    let b : Int := (l:Int)-k
    have step (p : Int) : evol (twoTips l) (k+1) p =
        rule (evol (twoTips l) k (p-1)) (evol (twoTips l) k p) (evol (twoTips l) k (p+1)) := rfl
    have moveL : -(l:Int)-1+(k+1:Nat) = a+1 := by dsimp [a]; omega
    have moveR : (l:Int)-(k+1:Nat) = b-1 := by dsimp [b]; omega
    rw [moveL,moveR]
    refine ⟨?_,?_,?_⟩
    · rw [step,show a+1-1=a by omega,left,white (a+1) (by dsimp [a]; omega) (by dsimp [a]; omega),
          white (a+1+1) (by dsimp [a]; omega) (by dsimp [a]; omega)]
      rfl
    · rw [step,show b-1+1=b by omega,right,white (b-1-1) (by dsimp [b]; omega) (by dsimp [b]; omega)]
      simp [rule]
    · intro p lo hi
      rw [step,white (p-1) (by dsimp [a] at lo; omega) (by dsimp [b] at hi; omega),
        white p (by dsimp [a] at lo; omega) (by dsimp [b] at hi; omega),
        white (p+1) (by dsimp [a] at lo; omega) (by dsimp [b] at hi; omega)]
      rfl

theorem endpoint_attained (l : Nat) :
    (∀ j < l, evol (twoTips l) j 0 = false) ∧ evol (twoTips l) l 0 = true ∧
    evol (twoTips l) (l+1) 0 = false := by
  obtain ⟨west,center,_⟩ := advancing_tips l l (by omega)
  rw [show -(l:Int)-1+l = -1 by omega] at west
  rw [show (l:Int)-l = 0 by omega] at center
  refine ⟨fun j lt => (advancing_tips l j (by omega)).2.2 0 (by omega) (by omega),center,?_⟩
  change rule (evol (twoTips l) l (-1)) (evol (twoTips l) l 0) _ = false
  simp [rule,west,center]

/-- The exceptional five-cell word actually writes 0101. The fourth update
reads exactly the next cell west, irrespective of the unsupplied east side. -/
theorem exception_trace {t : Nat} (fall : cell t (-2) = true ∧ cell (t+1) (-2) = false)
    (near : cell t (-1) = false) (center : cell t 0 = false) (east : cell t 1 = true) :
    cell (t+1) 0 = true ∧ cell (t+2) 0 = false ∧ cell (t+3) 0 = true ∧
    cell (t+4) 0 = cell t (-4) := by
  obtain ⟨black,cap⟩ := (fall_iff _).mp fall
  have step (n : Nat) (p : Int) : cell (n+1) p =
    rule (cell n (p-1)) (cell n p) (cell n (p+1)) := rfl
  have one : cell (t+1) 0 = true := by simp [step,rule,near,center,east]
  have westOne : cell (t+1) (-1) = true := by simp [step,rule,cap,near,center]
  have eastOne : cell (t+1) 1 = true := by simp [step,rule,center,east]
  have two : cell (t+2) 0 = false := by
    change rule (cell (t+1) (-1)) (cell (t+1) 0) _ = false
    simp [westOne,one,rule]
  have westTwo : cell (t+2) (-1) = true := by
    change rule (cell (t+1) (-2)) (cell (t+1) (-1)) _ = true
    simp [rule,fall.2,westOne]
  have eastTwo : cell (t+2) 1 = false := by
    change rule (cell (t+1) 0) (cell (t+1) 1) _ = false
    simp [rule,one,eastOne]
  have three : cell (t+3) 0 = true := by
    change rule (cell (t+2) (-1)) (cell (t+2) 0) (cell (t+2) 1) = true
    simp [rule,westTwo,two,eastTwo]
  have far : cell (t+2) (-2) = cell t (-4) := by
    change rule (cell (t+1) (-3)) (cell (t+1) (-2)) (cell (t+1) (-1)) = _
    rw [westOne,step t (-3)]
    simp [rule,black]
  have westThree : cell (t+3) (-1) = !cell t (-4) := by
    change rule (cell (t+2) (-2)) (cell (t+2) (-1)) _ = _
    simp [rule,far,westTwo]
  refine ⟨one,two,three,?_⟩
  change rule (cell (t+3) (-1)) (cell (t+3) 0) _ = _
  simp [rule,three,westThree]

/-- A fixed-site version of the fall-residue target: after every cutoff,
two falls an odd distance apart at -2 suffice to rule out period two at 0. -/
theorem no_period_two_of_odd_fall_separations
    (late : ∀ T, ∃ t k, T ≤ t ∧
      (cell t (-2) = true ∧ cell (t+1) (-2) = false) ∧
      (cell (t+2*k+1) (-2) = true ∧ cell (t+2*k+2) (-2) = false)) :
    ¬ ∃ T, ∀ t, T ≤ t → cell (t+2) 0 = cell t 0 := by
  rintro ⟨T,per⟩
  have alt := Rule30FiniteConfigs.alternates_of_period_two per (nonconstant 0)
  have pale {u : Nat} (hu : T < u) (f : cell u (-2) = true ∧ cell (u+1) (-2) = false) :
      cell u 0 = false := by
    cases u with
    | zero => omega
    | succ u => exact (alternating_fall alt (by omega) f).2.2.1
  obtain ⟨t,k,ht,first,last⟩ := late (T+1)
  have start := pale (by omega) first
  have finish := pale (by omega) last
  have even (n : Nat) : cell (t+2*n) 0 = false := by
    induction n with
    | zero => simpa using start
    | succ n ih =>
      rw [show t+2*(n+1) = t+2*n+2 by omega,per (t+2*n) (by omega)]
      exact ih
  have odd := alt (t+2*k) (by omega)
  rw [even,finish] at odd
  contradiction

end PhaseTwo.UnmarkedLaunch
