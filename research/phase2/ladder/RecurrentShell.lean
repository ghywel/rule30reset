import Ruliology.CellularAutomata.Rule30LateTwins
import Ruliology.CellularAutomata.Rule30EveryKInverse

namespace PhaseTwo.RecurrentShell

open Ruliology.CellularAutomata Rule30ZeroBoundary IntegerForm Rule30LateTwins
open Rule30EveryKStatement (OddBand topBand bandAt settlingBound)
open Rule30EveryKInverse (uniform_settling)

/-- The leading band of depth d is full and already lies on a physical edge cycle. -/
def RecurrentAt (d y : Nat) : Prop :=
  d ≤ y.log2 + 1 ∧ OddBand d (topBand d y) ∧
    ∃ q, 0 < q ∧ bandAt d (topBand d y) q = topBand d y

/-- A fixed immortal must occupy the recurrent-band part of every sufficiently
late shell in its width parity. Both the top index and band depth may vary. -/
theorem immortal_on_recurrent_shell {x p d : Nat} (alive : ∀ s, iter G s x % 2 = 1)
    (hd : 0 < d) (room : x.log2 + settlingBound d ≤ p)
    (par : p % 2 = x.log2 % 2) :
    ∃ y, Top y p ∧ RecurrentAt d y ∧ ∀ s, iter G s y % 2 = 1 := by
  have nz : x ≠ 0 := by
    have z := alive 0
    change x % 2 = 1 at z
    omega
  let q := (p - x.log2) / 2
  have age : p = x.log2 + 2*q := by dsimp [q]; omega
  refine ⟨iter G q x, ?_, ?_, ?_⟩
  · rw [iter_G_eq_iter_F_two_mul, age]
    exact Top_iter (top_log2 nz) _
  · rw [iter_G_eq_iter_F_two_mul]
    exact uniform_settling hd x (2*q) nz (by omega)
  · intro s
    simpa only [iter_add] using alive (q+s)

/-- To rule out immortality it suffices to exclude recurrent-band rows
on shells whose top index minus the band's uniform settling age is
unbounded in both parities. -/
theorem q01_of_recurrent_shell_exclusion
    (holes : ∀ b r : Nat, r < 2 → ∃ p d k, 0 < d ∧ b + settlingBound d ≤ p ∧
      p % 2 = r ∧ ∀ y, Top y p → RecurrentAt d y → ∃ s < k, iter G s y % 2 = 0) :
    Q01 := by
  apply Q01_iff_integer.mpr
  intro x
  apply Classical.byContradiction
  intro no
  have alive (s : Nat) : iter G s x % 2 = 1 := by
    have := not_exists.mp no s
    omega
  obtain ⟨p, d, k, hd, room, par, dead⟩ := holes x.log2 (x.log2 % 2) (by omega)
  obtain ⟨y, top, recurring, remains⟩ := immortal_on_recurrent_shell alive hd room par
  obtain ⟨s, _, white⟩ := dead y top recurring
  have := remains s
  omega

/-- In particular, the pair of top positions 2*2^d and 2*2^d+1
can use an unbounded band depth d and its own finite check horizon. -/
theorem q01_of_dyadic_recurrent_shells
    (holes : ∀ b, ∃ d, b + 2 ≤ d ∧ ∀ r < 2, ∃ k, ∀ y, Top y (2 * 2^d + r) →
      RecurrentAt d y → ∃ s < k, iter G s y % 2 = 0) : Q01 := by
  apply q01_of_recurrent_shell_exclusion
  intro b r hr
  obtain ⟨d, hd, kill⟩ := holes b
  obtain ⟨k, hk⟩ := kill r hr
  have growth (n : Nat) : 2*n ≤ 2^n := by
    induction n with
    | zero => decide
    | succ n ih =>
      cases n with
      | zero => decide
      | succ n =>
        rw [Nat.pow_succ]
        omega
  have := growth d
  refine ⟨2 * 2^d + r, d, k, by omega, ?_, by omega, hk⟩
  unfold settlingBound
  omega

end PhaseTwo.RecurrentShell
