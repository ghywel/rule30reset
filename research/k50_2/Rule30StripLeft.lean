import Rule30EventLeft
import Ruliology.CellularAutomata.Rule30PeriodTwoOnset

/-! Intersect GE2 with the entire finite right strip, using the kit's own
word recognizer and initial image. At width six this decides the exact
survivors of the 12-, 18- and 24-bit classifications. -/
namespace Ruliology.CellularAutomata.Rule30StripLeft

open Rule30Jen Rule30Prize Rule30PeriodTwo Rule30PeriodTwoWidth13
open Rule30PeriodTwoOnset (excludes img no_word cell_obeys)

def gateWord (b : Nat → Bool) (m : Nat) : List Bool := List.ofFn (fun i : Fin m => !b (2*i.val))

def StripGE2 (w : Nat) (b : Nat → Bool) (m : Nat) : Prop :=
  GE2 b m ∧ excludes (img w) (gateWord b m) = false

theorem prefixDet_strip (w : Nat) : PrefixDet (StripGE2 w) := by
  intro b b' m eq h
  have e : gateWord b m = gateWord b' m := by
    unfold gateWord
    congr 1
    exact funext fun i => congrArg Bool.not (eq _ (by omega))
  exact ⟨prefixDet_GE2 _ _ _ eq h.1, e ▸ h.2⟩

/-- At every positive width the same late left anchor passes the full strip test. -/
theorem lang_all_widths (T : Nat) (hT : AltFrom T) : ∃ K, ∀ k, K ≤ k →
    cell (T+2*k+1) (-1) = false → ∀ m w, 0 < w →
    StripGE2 w (fun i => cell (T+2*k+1+i) (-1)) m := by
  obtain ⟨K, hk⟩ := lang_GE2 T hT
  refine ⟨K+1, fun k late white m w hw => ⟨hk k (by omega) white m, ?_⟩⟩
  let b := fun i => cell (T+2*k+1+i) (-1)
  let pat := gateWord b m
  have len : pat.length = m := by simp [pat, gateWord]
  let s := T+2*k-1
  have start : s+2 = T+2*k+1 := by dsimp [s]; omega
  cases bad : excludes (img w) pat with
  | false => rfl
  | true =>
    apply False.elim
    apply no_word hw (cell_obeys w) bad s
    · intro i _
      rcases exists_half i with ⟨j, rfl | rfl⟩
      · rw [show s+2*j = T+2*(k-1+j)+1 by dsimp [s]; omega, (hT _).2]
        simp
      · rw [show s+(2*j+1) = T+2*(k+j) by dsimp [s]; omega, (hT _).1]
        simp
    · intro i hi
      have hi' : i < m := len ▸ hi
      have get : pat.getD i false = !b (2*i) := by
        simp [pat, gateWord, List.getD_eq_getElem?_getD, hi']
      rw [get, start, show T+2*k+1+2*i = T+2*(k+i)+1 by omega, p1_odd hT]
      dsimp [b]
      rw [show T+2*k+1+2*i = T+2*(k+i)+1 by omega]

/-- The test width can be chosen separately at each horizon. The anchor in
`lang_all_widths` is uniform, so a mass bound on this intersection suffices. -/
theorem no_period_two_of_strip_mass (width : Nat → Nat) (pos : ∀ m, 0 < width m)
    (g : Nat → Nat) (bound : MassBoundFunP (fun b m => StripGE2 (width m) b m) g) :
    ¬ ∃ T0, ∀ t, T0 ≤ t → center (t+2) = center t := by
  apply not_eventually_period_two_of_lang_fun _ (fun b b' m => prefixDet_strip (width m) b b' m)
    (fun _ _ h => h.1.1) g bound
  intro T hT
  obtain ⟨K, hK⟩ := lang_all_widths T hT
  exact ⟨K, fun k hk hw m => hK k hk hw m (width m) (pos m)⟩

def survivors (m : Nat) (seeds : List Nat) : List Nat :=
  seeds.filter fun y => ge2B m y && !excludes (img 6) (gateWord (tr y) m)

private theorem classification (m : Nat) (hm : 0 < m) (seeds : List Nat)
    (cover : ∀ y, GE2 (tr y) m → y % 2^(2*m) ∈ seeds) (X : Nat) :
    StripGE2 6 (tr X) m ↔ X % 2^(2*m) ∈ survivors m seeds := by
  let Y := X % 2^(2*m)
  have eq (t : Nat) (ht : t < 2*m) : tr Y t = tr X t := tr_mod X _ t ht
  constructor
  · intro h
    have cut := prefixDet_strip 6 _ _ _ (fun t ht => (eq t ht).symm) h
    exact List.mem_filter.mpr ⟨cover X h.1, by simp [ge2B_true_of_GE2 hm cut.1, cut.2, Y]⟩
  · intro h
    obtain ⟨_, yes⟩ := List.mem_filter.mp h
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at yes
    apply prefixDet_strip 6 _ _ _ eq
    exact ⟨Rule30EventLeft.ge2_of_check yes.1, yes.2⟩

/-- The surviving residues at all three published kit horizons, with both directions. -/
theorem kit_classes (X : Nat) :
    (StripGE2 6 (tr X) 6 ↔ X % 4096 ∈ survivors 6 seeds6) ∧
    (StripGE2 6 (tr X) 9 ↔ X % 262144 ∈ survivors 9 seeds9) ∧
    (StripGE2 6 (tr X) 12 ↔ X % 16777216 ∈ survivors 12 seeds12) :=
  ⟨classification 6 (by decide) seeds6 (fun y h => (ge2_six_five_seeds_and_mass_excess y h).1) X,
   classification 9 (by decide) seeds9 (fun y h => (ge2_nine_twelve_seeds_and_mass_excess y h).1) X,
   classification 12 (by decide) seeds12 (fun y h => (ge2_twelve_twenty_six_seeds_and_mass_excess y h).1) X⟩

set_option maxRecDepth 8192 in
set_option maxHeartbeats 0 in
theorem exact_deletions :
    survivors 6 seeds6 = seeds6 ∧
    survivors 9 seeds9 = seeds9.erase 49958 ∧
    survivors 12 seeds12 = seeds12.filter (fun y => ![10011430,12620582,12992790,14205734].contains y) ∧
    (survivors 6 seeds6).length = 5 ∧ (survivors 9 seeds9).length = 11 ∧
    (survivors 12 seeds12).length = 22 := by decide +kernel

section BlackStart
open Rule30PeriodTwoOnset

private def blackImage : List (List Bool) :=
  (allLists 6).flatMap fun x => [step true false x, step true true x]

/-- The known shortened nine-sample obstruction already holds when the first white
is immediately preceded by a black update. Only the stated six sites obey the rule. -/
theorem no_short_after_black {H : Nat → Int → Bool} (hH : Obeys 6 H) (s : Nat)
    (black : H s 0 = true) (clock : ∀ i, i < 16 → H (s+1+i) 0 = (i%2 == 1)) :
    ¬ ∀ i, i < short6.length → H (s+1+2*i) 1 = short6.getD i false := by
  intro reads
  have inside : seg H (s+1) 1 6 ∈ blackImage := by
    rw [seg_step H s 6 1 (fun j h1 h2 => hH j h1 (by omega))]
    change step (H s 0) (H s 7) (seg H s 1 6) ∈ _
    rw [black]
    apply List.mem_flatMap.mpr
    refine ⟨seg H s 1 6, ?_, ?_⟩
    · have e := mem_allLists (seg H s 1 6)
      simpa [length_seg] using e
    · cases H s 7 <;> simp
  have first : H (s+1) 1 = true := reads 0 (by decide)
  have on : seg H (s+1) 1 6 ∈ layer true blackImage :=
    List.mem_filter.mpr ⟨inside, by rw [headD_seg]; simp [first]⟩
  have reach := mem_run (by decide : 0 < 6) hH short6.tail (layer true blackImage) (s+1) on
    (fun i hi => clock i hi) (fun i hi => by
      have r := reads (i+1) (by change i < 8 at hi; change i+1 < 9; omega)
      rw [show s+1+2+2*i = s+1+2*(i+1) by omega]
      exact r)
  have empty : Rule30PeriodTwoOnset.run (layer true blackImage) short6.tail = [] := by decide +kernel
  rw [empty] at reach
  exact List.not_mem_nil reach

end BlackStart

section ThreeFive
open Rule30PeriodTwoOnset (layer succs nub mem_nub)

/-- At a kick, codes 23 and 39 can prepare the next gap of three and five respectively. -/
private def ready (five : Bool) : List Bool := [true,true,true,false,!five,five]

def gapBits (five : Bool) : List Bool :=
  if five then [false,false,false,false,true] else [false,false,true]

private theorem connectors : ∀ a b : Bool,
    ready b ∈ Rule30PeriodTwoOnset.run [ready a] (gapBits a) := by decide +kernel

private theorem run_mono (bits : List Bool) {L R : List (List Bool)} (h : L ⊆ R) :
    Rule30PeriodTwoOnset.run L bits ⊆ Rule30PeriodTwoOnset.run R bits := by
  induction bits generalizing L R with
  | nil => exact h
  | cons b bs ih =>
    apply ih
    intro y hy
    simp only [mem_nub, layer, List.mem_filter, List.mem_flatMap] at hy ⊢
    obtain ⟨⟨x, hx, hxy⟩, read⟩ := hy
    exact ⟨⟨x, h hx, hxy⟩, read⟩

private theorem run_append (L : List (List Bool)) (u v : List Bool) :
    Rule30PeriodTwoOnset.run L (u++v) =
      Rule30PeriodTwoOnset.run (Rule30PeriodTwoOnset.run L u) v := by
  induction u generalizing L with
  | nil => rfl
  | cons _ _ ih => exact ih _

private theorem connect {L : List (List Bool)} {a : Bool} (start : ready a ∈ L) (b : Bool) :
    ready b ∈ Rule30PeriodTwoOnset.run L (gapBits a) := by
  apply run_mono _ _ (connectors a b)
  intro x hx
  rw [List.mem_singleton.mp hx]
  exact start

private theorem schedule (rest : List Bool) (a z : Bool) (L : List (List Bool)) (start : ready a ∈ L) :
    ready z ∈ Rule30PeriodTwoOnset.run L (gapBits a ++ rest.flatMap gapBits) := by
  induction rest generalizing a L with
  | nil => simpa using connect start z
  | cons b bs ih =>
    rw [run_append]
    exact ih b _ (connect start b)

/-- Every finite sequence of gaps 3 and 5 is admitted by the full width-six
strip. Choosing the state at its next pulse requires only the next gap. -/
theorem every_three_five_schedule (gaps : List Bool) :
    excludes (img 6) (true :: gaps.flatMap gapBits) = false := by
  have starts : ∀ a : Bool, ready a ∈ layer true (img 6) := by decide +kernel
  have last : ready false ∈ Rule30PeriodTwoOnset.run (layer true (img 6)) (gaps.flatMap gapBits) := by
    cases gaps with
    | nil => exact starts false
    | cons a rest => exact schedule rest a false _ (starts a)
  change (Rule30PeriodTwoOnset.run _ _).isEmpty = false
  cases eq : Rule30PeriodTwoOnset.run (layer true (img 6)) (gaps.flatMap gapBits) with
  | nil => rw [eq] at last; exact False.elim (List.not_mem_nil last)
  | cons _ _ => rfl

end ThreeFive

end Ruliology.CellularAutomata.Rule30StripLeft
