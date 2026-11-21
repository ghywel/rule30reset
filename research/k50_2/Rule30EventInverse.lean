import Rule30EventGate
import Ruliology.CellularAutomata.Rule30GateTrapWords

/-! Invert Lowry's marker stream after trap entry, using the kit's five-sample kick guarantee. -/
namespace Ruliology.CellularAutomata.Rule30EventInverse

open Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoSideways Rule30EventGate

private def markOf (a b c d e : Bool) : Bool := !a && !b && (c || (!d && e))

/-- In the trap, a first kick is at most four steps away. Thus the positive even
distances recognized by the marker are exactly two and four. -/
private theorem marker_five (R : Nat → Bool) {t0 : Nat} (odd : t0%2=1)
    (entry : win R t0 ∈ trap) (s : Nat) (late : t0≤2*s+1) :
    Event R s ↔ markOf (u R s) (u R (s+1)) (u R (s+2)) (u R (s+3)) (u R (s+4)) = true := by
  have cap := u_black_within_five_of_entry R odd entry s late
  have h (d : Nat) (q : ∀ i, i<d → u R (s+i)=false) (k : u R (s+d)=true) :
      Event R s ↔ 0<d ∧ d%2=0 := driven_marker_iff_even_distance R s d q k
  cases a : u R s with
  | true =>
    rw [h 0 (by omega) (by simpa using a)]
    simp [markOf]
  | false =>
    cases b : u R (s+1) with
    | true =>
      rw [h 1 (by intro i hi; rcases (show i=0 by omega) with rfl; exact a) b]
      simp [markOf]
    | false =>
      cases c : u R (s+2) with
      | true =>
        rw [h 2 (by intro i hi; rcases (show i=0 ∨ i=1 by omega) with rfl|rfl <;> simp [a,b]) c]
        simp [markOf]
      | false =>
        cases d : u R (s+3) with
        | true =>
          rw [h 3 (by intro i hi; rcases (show i=0 ∨ i=1 ∨ i=2 by omega) with rfl|rfl|rfl <;> simp [a,b,c]) d]
          simp [markOf]
        | false =>
          have e : u R (s+4)=true := by simpa [a,b,c,d] using cap
          rw [h 4 (by intro i hi; rcases (show i=0 ∨ i=1 ∨ i=2 ∨ i=3 by omega) with rfl|rfl|rfl|rfl <;> simp [a,b,c,d]) e]
          simp [markOf,e]

/-- The gate at s+1 is recovered from the marker bits at s and s+2.
This is an inverse on the actual physical stream, including every trapped finite start. -/
theorem gate_iff_markers (R : Nat → Bool) {t0 : Nat} (odd : t0%2=1)
    (entry : win R t0 ∈ trap) (s : Nat) (late : t0≤2*s+1) :
    u R (s+1)=true ↔ Event R (s+2) ∧ ¬Event R s := by
  rw [marker_five R odd entry (s+2) (by omega), marker_five R odd entry s late]
  have cap := u_black_within_five_of_entry R odd entry s late
  have h0 := gaps_of_entry R odd entry s late
  have h1 := gaps_of_entry R odd entry (s+1) (by omega)
  simp only [Nat.add_assoc, Nat.reduceAdd] at *
  let v := u R
  exact (by
    intro a b c d e f g
    cases a <;> cases b <;> cases c <;> cases d <;> cases e <;> cases f <;> cases g <;> simp [markOf]
    : ∀ a b c d e f g : Bool,
    (a=true ∨ b=true ∨ c=true ∨ d=true ∨ e=true) →
    (a=true → (b=false ∧ c=false ∧ d=true) ∨
         (b=false ∧ c=false ∧ d=false ∧ e=false ∧ f=true)) →
    (b=true → (c=false ∧ d=false ∧ e=true) ∨
         (c=false ∧ d=false ∧ e=false ∧ f=false ∧ g=true)) →
    (b=true ↔ markOf c d e f g = true ∧ ¬markOf a b c d e = true))
    (v s) (v (s+1)) (v (s+2)) (v (s+3)) (v (s+4)) (v (s+5)) (v (s+6)) cap h0 h1

end Ruliology.CellularAutomata.Rule30EventInverse
