import Rule30EventKickExclusion
import Ruliology.CellularAutomata.Rule30PeriodTwoWidth13

/-! Lowry's event returns, in R67's kick coordinates, restrict the finite
zero-wall seeds needed in the kit's width-13 period-two reduction. -/
namespace Ruliology.CellularAutomata.Rule30EventLeft

open Rule30Jen Rule30Prize Rule30PeriodTwo Rule30PeriodTwoWidth13
open Rule30EventKickExclusion (KickGap)

/-- A 5-gap followed by k complete 2-gaps and a 5-gap; index zero is a kick. -/
def Bracket (u : Nat → Bool) (k : Nat) : Prop :=
  KickGap u 0 5 ∧ (∀ j, j < k → KickGap u (5+2*j) 2) ∧ KickGap u (5+2*k) 5

/-- m white samples contain the complete word only when its last kick is visible. -/
def EventGE2 (b : Nat → Bool) (m : Nat) : Prop :=
  GE2 b m ∧ ∀ s k, 2 ≤ k → s+10+2*k < m → ¬ Bracket (fun i => !b (2*(s+i))) k

private theorem gap_congr {u v : Nat → Bool} {a d : Nat}
    (h : ∀ j, a ≤ j → j ≤ a+d → u j = v j) (g : KickGap u a d) : KickGap v a d := by
  obtain ⟨pos, first, inner, last⟩ := g
  exact ⟨pos, (h a (by omega) (by omega)).symm.trans first,
    fun j hj hj' => (h (a+j) (by omega) (by omega)).symm.trans (inner j hj hj'),
    (h (a+d) (by omega) (by omega)).symm.trans last⟩

private theorem bracket_congr {u v : Nat → Bool} {k : Nat}
    (h : ∀ j, j ≤ 10+2*k → u j = v j) (g : Bracket u k) : Bracket v k :=
  ⟨gap_congr (fun j _ hj => h j (by omega)) g.1,
    fun i hi => gap_congr (fun j _ hj => h j (by omega)) (g.2.1 i hi),
    gap_congr (fun j _ hj => h j (by omega)) g.2.2⟩

theorem prefixDet_eventGE2 : PrefixDet EventGE2 := by
  intro b b' m eq h
  refine ⟨prefixDet_GE2 b b' m eq h.1, ?_⟩
  intro s k hk room bad
  apply h.2 s k hk room
  exact bracket_congr (fun j hj => congrArg Bool.not (eq (2*(s+j)) (by omega)).symm) bad

/-- Every late white anchor eligible for the kit's GE2 theorem passes the event filter. -/
theorem lang_eventGE2 (T : Nat) (hT : AltFrom T) : ∃ K, ∀ k0, K ≤ k0 →
    cell (T+2*k0+1) (-1) = false →
    ∀ m, EventGE2 (fun j => cell (T+2*k0+1+j) (-1)) m := by
  obtain ⟨K, hK⟩ := lang_GE2 T hT
  refine ⟨K, fun k0 hk0 white m => ⟨hK k0 hk0 white m, ?_⟩⟩
  intro s k hk _ bad
  let t := T+2*(k0+s)+1
  apply Rule30EventKickExclusion.singleton_no_long_twos_to_odd t 5 k 5
    (by decide) hk (by decide) (by decide)
  · intro i _
    rw [show t+2*i = T+2*(k0+s+i)+1 by dsimp [t]; omega]
    exact (hT _).2
  · intro i _
    rw [show t+2*i+1 = T+2*(k0+s+i+1) by dsimp [t]; omega]
    exact (hT _).1
  · apply bracket_congr _ bad
    intro i _
    change (!cell (T+2*k0+1+2*(s+i)) (-1)) = cell (t+2*i) 1
    rw [show t+2*i = T+2*(k0+s+i)+1 by dsimp [t]; omega, p1_odd hT]
    congr 2 <;> omega

/-- A bound on the white count by any function of weight suffices on this smaller language. -/
theorem no_period_two_of_event_mass (g : Nat → Nat) (bound : MassBoundFunP EventGE2 g) :
    ¬ ∃ T0, ∀ t, T0 ≤ t → center (t+2) = center t :=
  not_eventually_period_two_of_lang_fun EventGE2 prefixDet_eventGE2 (fun _ _ h => h.1.1)
    g bound lang_eventGE2

/-- A fixed finite left seed surviving the event filter at every horizon is necessary
for eventual period two of the official centre. -/
theorem no_period_two_of_no_event_seed (h : ∀ X : Nat, ¬ ∀ m, EventGE2 (tr X) m) :
    ¬ ∃ T0, ∀ t, T0 ≤ t → center (t+2) = center t := by
  rintro ⟨T0, hp⟩
  obtain ⟨T, hT⟩ := normalize hp
  obtain ⟨K, hK⟩ := lang_eventGE2 T hT
  have white : ∃ k0, K ≤ k0 ∧ cell (T+2*k0+1) (-1) = false := by
    apply Classical.byContradiction
    intro none
    apply not_eventually_const (rowNat T) (2*K)
    intro t ht
    rw [tr_rowNat T (alt_guard0 hT) t]
    rcases exists_half t with ⟨j, rfl | rfl⟩
    · exact m1_even hT j
    · rw [show T+(2*j+1) = T+2*j+1 by omega]
      cases hj : cell (T+2*j+1) (-1)
      · exact False.elim (none ⟨j, by omega, hj⟩)
      · rfl
  obtain ⟨k0, hk0, hw⟩ := white
  apply h (rowNat (T+2*k0+1))
  intro m
  have eq := funext (tr_rowNat _ (alt_guard hT k0))
  rw [eq]
  exact hK k0 hk0 hw m

/-- Before the fifteenth white sample, no complete forbidden bracket fits. -/
theorem unchanged_through_fourteen (b : Nat → Bool) (m : Nat) (hm : m ≤ 14) :
    EventGE2 b m ↔ GE2 b m :=
  ⟨And.left, fun h => ⟨h, fun _ _ _ room => by omega⟩⟩

private theorem ge2_of_check {m X : Nat} (yes : ge2B m X = true) : GE2 (tr X) m := by
  simp only [ge2B, gvalidB, e2runB, Bool.and_eq_true, Bool.not_eq_true', List.all_eq_true] at yes
  exact ⟨⟨fun _ => yes.1.1.1, fun j hj => yes.1.1.2 j (List.mem_range.mpr hj),
    fun j hj => yes.1.2 j (List.mem_range.mpr (by omega))⟩,
    fun j hj => yes.2 j (List.mem_range.mpr hj)⟩

private def fiveKicks (i : Nat) : Bool := decide (i = 0 ∨ i = 5 ∨ i = 7 ∨ i = 9 ∨ i = 14)

private theorem example_samples : ∀ i : Fin 15, fiveKicks i.val = !tr 697483606 (2*i.val) := by
  decide +kernel

/-- Strictness at the first possible horizon, witnessed by a genuine finite left row. -/
theorem first_strict_seed : GE2 (tr 697483606) 15 ∧ ¬ EventGE2 (tr 697483606) 15 := by
  refine ⟨ge2_of_check (by decide +kernel), fun h => h.2 0 2 (by decide) (by decide) ?_⟩
  apply bracket_congr (u := fiveKicks)
  · intro i hi
    simpa using example_samples ⟨i, by omega⟩
  · unfold Bracket KickGap fiveKicks
    simp only [Nat.zero_add, decide_eq_true_eq, decide_eq_false_iff_not]
    refine ⟨⟨by decide, by simp, ?_, by simp⟩,
      fun j hj => ⟨by decide, ?_, ?_, ?_⟩, ⟨by decide, by simp, ?_, by simp⟩⟩ <;> omega

/-- Every higher-bit extension of this 30-bit residue fails at the same horizon. -/
theorem excluded_residue (X : Nat) (low : X % 2^30 = 697483606) : ¬ EventGE2 (tr X) 15 := by
  intro h
  apply first_strict_seed.2
  apply prefixDet_eventGE2 _ _ _ _ h
  intro t ht
  rw [← low]
  exact (tr_mod X 30 t ht).symm

/-- A prefix of an infinite physical tail must have a valid next white sample.
The continuation is allowed to use either value of the next two seed bits. -/
def LiveGE2 (b : Nat → Bool) (m : Nat) : Prop :=
  EventGE2 b m ∧ ∃ c, (∀ t, t < 2*m → c t = b t) ∧ EventGE2 c (m+1)

theorem lang_liveGE2 (T : Nat) (hT : AltFrom T) : ∃ K, ∀ k0, K ≤ k0 →
    cell (T+2*k0+1) (-1) = false →
    ∀ m, LiveGE2 (fun j => cell (T+2*k0+1+j) (-1)) m := by
  obtain ⟨K, hK⟩ := lang_eventGE2 T hT
  exact ⟨K, fun k h w m => ⟨hK k h w m, _, fun _ _ => rfl, hK k h w (m+1)⟩⟩

theorem no_period_two_of_live_mass (g : Nat → Nat) (bound : MassBoundFunP LiveGE2 g) :
    ¬ ∃ T0, ∀ t, T0 ≤ t → center (t+2) = center t := by
  apply not_eventually_period_two_of_lang_fun LiveGE2 _ (fun _ _ h => h.1.1.1) g bound lang_liveGE2
  intro b b' m eq h
  obtain ⟨h0, c, hc, next⟩ := h
  exact ⟨prefixDet_eventGE2 _ _ _ eq h0, c, fun t ht => (hc t ht).trans (eq t ht), next⟩

/-- Fifteen low bits identify Galindo's seven-spaced mass witnesses. Their first
two complete gaps are 3,4; the width-13 machine already fails at physical tick 14. -/
theorem seven_spaced_fails_GE2 (X : Nat) (low : X % 2^15 = 278) : ¬ GE2 (tr X) 8 := by
  intro h
  have ok := h.2 14 (by decide)
  have eq : ∀ t, t ≤ 14 → tr X t = tr 278 t := by
    intro t ht
    rw [← low]
    exact (tr_mod _ _ _ (by omega)).symm
  rw [run_congr 1 _ (fun t => t%2 == 0 && !tr 278 t) 10 14
    (fun t ht => by rw [eq t ht])] at ok
  have no : (run 1 (fun t => t%2 == 0 && !tr 278 t) 10 14).isSome = false := by decide +kernel
  simp [no] at ok

private def quietEnd (t : Nat) : Bool := if t = 28 then true else tr 697483606 t

/-- The 28-bit parent of the first completed counterexample has no legal continuation.
With a quiet next reading the automaton times out. A kick completes the forbidden bracket. -/
theorem early_residue (X : Nat) (low : X % 2^28 = 160612694) : ¬ LiveGE2 (tr X) 14 := by
  rintro ⟨_, c, hc, next⟩
  have pref (t : Nat) (ht : t < 28) : c t = tr 697483606 t := by
    rw [hc t ht, ← tr_mod X 28 t ht, low, ← tr_mod 697483606 28 t ht]
  have last : c 28 = false := by
    cases h28 : c 28
    · rfl
    · have ok := next.1.2 28 (by decide)
      have agree (t : Nat) (ht : t ≤ 28) : c t = quietEnd t := by
        by_cases h : t = 28
        · simpa [h, quietEnd] using h28
        · simpa [quietEnd, h] using pref t (by omega)
      rw [run_congr 1 _ (fun t => t%2 == 0 && !quietEnd t) 10 28
        (fun t ht => by rw [agree t ht])] at ok
      have no : (run 1 (fun t => t%2 == 0 && !quietEnd t) 10 28).isSome = false := by decide +kernel
      simp [no] at ok
  apply first_strict_seed.2
  apply prefixDet_eventGE2 c _ 15 _ next
  intro t ht
  by_cases hsmall : t < 28
  · exact pref t hsmall
  · rcases (show t = 28 ∨ t = 29 by omega) with rfl | rfl
    · exact last.trans (by decide +kernel)
    · exact (next.1.1.2.1 14 (by decide)).trans (by decide +kernel)

end Ruliology.CellularAutomata.Rule30EventLeft
