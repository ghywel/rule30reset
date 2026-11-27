import LocalBackground
import Ruliology.CellularAutomata.Rule30SettledBarrierEffective

namespace PhaseFalls

open Ruliology.CellularAutomata Rule30Jen

/-- Each fall has a preceding fall of a different phase within three sites.
The earlier tick is one or two updates before the specified fall. -/
theorem fall_has_predecessor (t : Nat) (i : Int) (ht : 2 ≤ t)
    (on : cell t i = true) (off : cell (t+1) i = false) :
    ∃ s : Nat, ∃ j : Int, t-2 ≤ s ∧ s < t ∧ i-3 ≤ j ∧ j ≤ i+3 ∧
      s%3 ≠ t%3 ∧ cell s j = true ∧ cell (s+1) j = false := by
  apply Classical.byContradiction
  intro no
  have quiet (k : Nat) (hk : k < 2) (j : Int) (lo : i-3 ≤ j) (hi : j ≤ i+3) :
      ¬ (cell (t-2+k) j = true ∧ cell (t-2+k+1) j = false) := by
    intro fall
    exact no ⟨t-2+k,j,by omega,by omega,lo,hi,by omega,fall⟩
  have eq := fixed_site (t-2) i quiet 2 (by decide)
  rw [show t-2+2=t by omega,off,on] at eq
  contradiction

/-- Near a changing site, falls cannot all have a prescribed residue modulo
three. The two candidate times start at the most recent tick of phase r+1. -/
theorem near_change (t : Nat) (i : Int) (r : Nat) (ht : 2 ≤ t)
    (change : cell (t+1) i ≠ cell t i) :
    ∃ s : Nat, ∃ j : Int, t-2 ≤ s ∧ s < t+2 ∧ i-3 ≤ j ∧ j ≤ i+3 ∧
      s%3 ≠ r ∧ cell s j = true ∧ cell (s+1) j = false := by
  obtain ⟨u, before, after, phase⟩ : ∃ u : Nat,
      t-2 ≤ u ∧ u ≤ t ∧ u%3=(r+1)%3 := by
    by_cases h : t%3=(r+1)%3
    · exact ⟨t, by omega, by omega, h⟩
    by_cases h' : (t-1)%3=(r+1)%3
    · exact ⟨t-1, by omega, by omega, h'⟩
    · exact ⟨t-2, by omega, by omega, by omega⟩
  apply Classical.byContradiction
  intro no
  have quiet (k : Nat) (hk : k < 2) (j : Int) (lo : i-3 ≤ j) (hi : j ≤ i+3) :
      ¬ (cell (u+k) j = true ∧ cell (u+k+1) j = false) := by
    intro fall
    exact no ⟨u+k,j,by omega,by omega,lo,hi,by omega,fall⟩
  have eq := fixed_site u i quiet (t-u) (by omega)
  rw [show u+(t-u)=t by omega] at eq
  exact change eq

/-- The effective centre-run bound supplies a change in the interior of
every sufficiently late doubling window. Seven columns centered at the
prize column therefore contain a fall outside each specified phase. -/
theorem seven_band_escape (U r : Nat) (hU : 2^128 ≤ U) :
    ∃ s : Nat, ∃ j : Int, U ≤ s ∧ s < 2*U ∧ -3 ≤ j ∧ j ≤ 3 ∧
      s%3 ≠ r ∧ cell s j = true ∧ cell (s+1) j = false := by
  have ha : 256 ≤ U+2 := by
    have : (256 : Nat) ≤ 2^128 := by decide
    omega
  have hlog : 128 ≤ Nat.log2 (U+2) :=
    (Nat.le_log2 (by omega)).2 (Nat.le_trans hU (by omega))
  have hll : 7 ≤ Nat.log2 (Nat.log2 (U+2)) :=
    (Nat.le_log2 (by omega)).2 (by simpa using hlog)
  obtain ⟨k,hk,ch⟩ := Rule30SettledBarrierEffective.exists_transition_in_window_loglog
    (U+2) (U-2) ha (by omega)
  obtain ⟨s,j,lo,hi,lj,hj,off,b,w⟩ := near_change (U+2+k) 0 r (by omega) ch
  exact ⟨s,j,by omega,by omega,by simpa using lj,by simpa using hj,off,b,w⟩

/-- The two falls may occur at different sites of the seven-column band. -/
theorem seven_band_two_phases (U : Nat) (hU : 2^128 ≤ U) :
    ∃ s t : Nat, ∃ i j : Int, U ≤ s ∧ s < 2*U ∧ U ≤ t ∧ t < 2*U ∧
      -3 ≤ i ∧ i ≤ 3 ∧ -3 ≤ j ∧ j ≤ 3 ∧ s%3 ≠ t%3 ∧
      cell s i = true ∧ cell (s+1) i = false ∧ cell t j = true ∧ cell (t+1) j = false := by
  obtain ⟨s,i,sl,sh,il,ih,_,b,w⟩ := seven_band_escape U 0 hU
  obtain ⟨t,j,tl,th,jl,jh,p,b',w'⟩ := seven_band_escape U (s%3) hU
  exact ⟨s,t,i,j,sl,sh,tl,th,il,ih,jl,jh,Ne.symm p,b,w,b',w'⟩

end PhaseFalls
