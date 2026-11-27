import Lean
import Ruliology.CellularAutomata.Rule30MixedGapClocks

/-! A short reset built from seven- and nine-white gaps inside Galindo's
width-12 pulse invariant. Each mask supplied by the elaborator is checked
in the kernel against both free exterior bits. -/
namespace SevenNineReset

open Ruliology.CellularAutomata Rule30StripCertificates Rule30RunEnvelopes
open Rule30RankedWords Rule30MixedGapClocks Rule30MixedGapClocks.Strip
open Rule30MixedGapClocks.Rank

def motif : List Nat := [9, 9, 7, 9, 9, 7, 9, 9, 7, 9]

open Lean Elab Term in
elab "sevenNineMasks" : term => do
  let mut a := F
  let mut masks : List Nat := []
  for wall in blocks motif do
    let mut b := 0
    for r in [:4096] do
      if a.testBit r then
        for east in [false, true] do
          b := b ||| (1 <<< stripStep 12 wall east r)
    masks := b :: masks
    a := b
  return toExpr masks.reverse

private def masks : List Nat := sevenNineMasks

private def check : List Bool → Nat → List Nat → Bool
  | [], a, [] => a &&& E == a
  | c :: w, a, b :: rest => covers 12 c a b && check w b rest
  | _, _, _ => false

private theorem sound (w : List Bool) (a : Nat) (ms : List Nat)
    (h : check w a ms = true) : Sub (applyWord 12 w a) E := by
  induction w generalizing a ms with
  | nil =>
    cases ms with
    | cons => simp [check] at h
    | nil =>
      have eq : a &&& E = a := beq_iff_eq.mp h
      intro i hi
      change a.testBit i = true at hi
      have v := congrArg (fun n : Nat => n.testBit i) eq
      simpa only [Nat.testBit_and, hi, Bool.true_and] using v
  | cons c w ih =>
    cases ms with
    | nil => simp [check] at h
    | cons b rest =>
      obtain ⟨hstep, htail⟩ := Bool.and_eq_true_iff.mp h
      exact cover_cons (covers_sound hstep) (ih b rest htail)

set_option maxHeartbeats 0 in
set_option maxRecDepth 16384 in
theorem reset_motif : Sub (applyWord 12 (blocks motif) F) E :=
  sound _ _ masks (by decide +kernel)

/-- Any written period containing the motif, with arbitrary other gaps of
seven or at least nine whites, is excluded at every singleton onset. -/
theorem excludes_motif (left right : List Nat)
    (hl : ∀ q ∈ left, Safe q) (hr : ∀ q ∈ right, Safe q) :
    ¬ EventuallyWord (blocks (left ++ motif ++ right)) := by
  let qs := left ++ motif ++ right
  have safe : ∀ q ∈ qs, Safe q := by
    intro q h
    rcases List.mem_append.mp h with h | h
    · rcases List.mem_append.mp h with h | h
      · exact hl _ h
      · have fixed : motif.all (fun x => x == 7 || decide (9 ≤ x)) = true := by decide
        simpa [Safe] using List.all_eq_true.mp fixed q h
    · exact hr _ h
  have hn : qs ≠ [] := by simp [qs, motif]
  have hp : 0 < (blocks qs).length := by
    cases he : qs with
    | nil => exact (hn he).elim
    | cons q rest => simp [blocks, pulse]
  have cap : Sub (applyWord 12 (blocks qs) F) E := by
    simp only [qs, blocks, List.flatMap_append, apply_append]
    exact sub_trans (word_mono 12
      (sub_trans (word_mono 12 (preserves F stableF left hl) _) reset_motif) _)
      (preserves E stableE right hr)
  obtain ⟨g, ranked⟩ := ranked_gaps qs safe
  apply no_word_ranked 12 E 2 (fun _ => 0) (blocks qs) g hp _ ranked
  exact sub_trans (word_mono 12 (first_period qs hn safe) _) cap

#print axioms excludes_motif

end SevenNineReset
