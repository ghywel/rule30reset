module

public import Ruliology.CellularAutomata.Rule30Certificates.TrappedRunMasks

/-! At width 45 the second exterior input can change the final observed cell.
All earlier output cells agree with a packed double step. The ordinary transfer
already handles every subtree that stops before that last cell. In each remaining
subtree the kernel checks both choices of the exterior input. -/
@[expose] public section

namespace Ruliology.CellularAutomata.Rule30TrappedRunBoundary
open Rule30DrivenPrefix Rule30TrappedRunMasks Rule30TrappedRuns Rule30GateTrap Rule30RunWindow
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

def lastBit (x : Nat) (exterior : Bool) : Bool :=
  let mid := step false x
  xor (mid.testBit 43) (mid.testBit 44 || exterior)

/-- x includes the first exterior bit. The second exterior bit is chosen independently. -/
def Edge (x y : Nat) (exterior : Bool) : Prop :=
  double x % 2^44 = y % 2^44 ∧ y.testBit 44 = lastBit x exterior

private theorem lastBit_prefix (x : Nat) (e : Bool) : lastBit (x%2^46) e = lastBit x e := by
  have mid := step_agree (k := 45) false (a := x%2^46) (c := x)
    (by intro j hj; rw [Nat.testBit_mod_two_pow]; simp [show j<46 by omega])
  simp only [lastBit,mid 43 (by decide),mid 44 (by decide)]

private def checkExtra (c : Nat) (a b : Tree) (k p : Nat) : Nat → Bool
  | 0 => false
  | n+1 =>
    if k+b.depth ≤ 44 then true
    else if subset ((a.high <<< 1) &&& c) b.low then true
    else if k = 44 then
      let boundary (e : Bool) := subset ((a.high <<< 1) &&& c) (b.child (lastBit p e)).low
      boundary false && boundary true
    else
      let visit (bit : Bool) := let q := nextCode p k bit
        checkExtra c (a.child bit) (b.child ((double q).testBit k)) (k+1) q n
      visit false && visit true

private def checkAtExtra (a : Tree) (p : Nat) : Bool :=
  let out := double p
  checkExtra (colourMask (out.testBit 0)) (a.follow p 4) (a.follow out 2) 2 p 43

private theorem carry {a b : Tree} {x y d j c t : Nat} (va : a.valid = true) (vb : b.valid = true)
    (ok : subset ((a.high <<< 1) &&& c) b.low = true)
    (ha : (a.value x d).testBit t = true) (hc : c.testBit (t+1) = true) :
    (b.value y j).testBit (t+1) = true := by
  apply (b.bounds vb _ _ _).1
  apply subset_sound ok
  have h := (a.bounds va _ _ _).2 ha
  simp [Nat.testBit_and,Nat.testBit_shiftLeft,h,hc]

private theorem checkExtra_sound (n : Nat) {a b : Tree} {c k p x y t : Nat} {e : Bool}
    (ok : checkExtra c a b k p n = true) (va : a.valid = true) (vb : b.valid = true)
    (hk : k ≤ 44) (hp : p=x%2^(k+2)) (edge : Edge x y e)
    (ha : (a.value x (k+2)).testBit t = true) (hc : c.testBit (t+1) = true)
    (physical : (b.value (double x) k).testBit (t+1) = true) :
    (b.value y k).testBit (t+1) = true := by
  induction n generalizing a b k p with
  | zero => simp [checkExtra] at ok
  | succ n ih =>
    simp only [checkExtra] at ok
    split at ok
    · rename_i short
      rwa [← b.value_congr edge.1 k short]
    split at ok
    · rename_i included
      exact carry va vb included ha hc
    split at ok
    · rename_i last
      subst k
      have bit : lastBit p e = y.testBit 44 := by rw [hp,lastBit_prefix,edge.2]
      have included : subset ((a.high <<< 1) &&& c) (b.child (lastBit p e)).low = true := by
        rcases Bool.and_eq_true_iff.mp ok with ⟨l,r⟩
        cases e <;> assumption
      rw [bit] at included
      have fin := carry (y := y) (j := 45) va (b.child_valid vb _) included ha hc
      simpa only [Tree.child_value] using fin
    · rename_i interior
      let bit := x.testBit (k+2)
      let q := nextCode p k bit
      have hq : q=x%2^((k+1)+2) := by simpa [q,bit,hp,Nat.add_assoc] using extend_code x k
      have dq : (double q).testBit k = (double x).testBit k := by
        rw [hq]; exact double_low x (k+1) k (by omega)
      have outbit := bit_of_congr edge.1 (show k<44 by omega)
      have next : checkExtra c (a.child bit) (b.child ((double q).testBit k)) (k+1) q n = true := by
        rcases Bool.and_eq_true_iff.mp ok with ⟨l,r⟩
        cases hb : bit <;> simpa only [q,hb] using (by first | exact l | exact r)
      rw [dq] at next
      have input : ((a.child bit).value x ((k+1)+2)).testBit t = true := by
        change ((a.child (x.testBit (k+2))).value x ((k+2)+1)).testBit t = true
        rwa [Tree.child_value]
      have fin := ih next (a.child_valid va _) (b.child_valid vb _) (by omega) hq input
        (by simpa only [Tree.child_value] using physical)
      rw [outbit] at fin
      simpa only [Tree.child_value] using fin

private theorem table_extra : (List.range 16).all (checkAtExtra table) = true := by decide +kernel

theorem step45 {x y t : Nat} {e : Bool} (edge : Edge x y e)
    (ha : (table.value x 0).testBit t = true)
    (hc : (colourMask (y.testBit 0)).testBit (t+1) = true) :
    (table.value y 0).testBit (t+1) = true := by
  let p := x%2^4
  have chk := List.all_eq_true.mp table_extra p (List.mem_range.mpr (Nat.mod_lt x (by decide : 0<16)))
  have dp (i : Nat) (hi : i<2) : (double p).testBit i = (double x).testBit i := double_low x 2 i hi
  have xy (i : Nat) (hi : i<2) : (double x).testBit i = y.testBit i := bit_of_congr edge.1 (by omega)
  have dy (i : Nat) (hi : i<2) := (dp i hi).trans (xy i hi)
  change checkExtra (colourMask ((double p).testBit 0)) (table.follow p 4) (table.follow (double p) 2) 2 p 43 = true at chk
  rw [table.follow_congr (double p) y 2 dy,dy 0 (by decide),table.follow_mod x 4] at chk
  have phys := step_all table_valid table_steps x t ha (by
    change (colourMask ((double x).testBit 0)).testBit (t+1) = true
    rwa [xy 0 (by decide)])
  have atPhys : ((table.follow y 2).value (double x) 2).testBit (t+1) = true := by
    rw [← table.follow_congr (double x) y 2 xy,Tree.follow_value]
    exact phys
  have fin := checkExtra_sound 43 chk (table.follow_valid table_valid x 4) (table.follow_valid table_valid y 2)
    (by decide) rfl edge (by simpa only [Tree.follow_value] using ha) hc atPhys
  simpa only [Tree.follow_value] using fin

private theorem frame_time {r i : Nat} (hi : i<98) (h : Holds (entry (colours.getD i none)) r) :
    (colourMask (r.testBit 0)).testBit i = true := by
  have matchMask : ∀ j : Fin 98, ∀ b : Bool, (colourMask b).testBit j.val = fits (colours.getD j.val none) b :=
    by decide +kernel
  rw [matchMask ⟨i,hi⟩]
  cases hc : colours.getD i none with
  | none => rfl
  | some b =>
    rw [hc] at h
    change r%2^16 ∈ trapCodes.filter (fun x => x.testBit 0 == b) at h
    simpa [fits,Nat.testBit_mod_two_pow] using (List.mem_filter.mp h).2

/-- Each edge may use fresh exterior choices. The first and last time bits still disagree. -/
theorem no_frames45 (row : Nat → Nat)
    (link : ∀ i, ∃ x e, x%2^45=row i%2^45 ∧ Edge x (row (i+1)) e)
    (frames : ∀ i, i<98 → Holds (entry (colours.getD i none)) (row i)) : False := by
  have reached (i : Nat) (hi : i<98) : (table.value (row i) 0).testBit i = true := by
    induction i with
    | zero =>
      have first := frames 0 (by decide)
      change row 0 % 2^16 ∈ trapCodes at first
      have base := List.all_eq_true.mp table_start _ first
      rw [Tree.follow_mod] at base
      have bit := ((table.follow (row 0) 16).bounds (table.follow_valid table_valid _ _) (row 0) 16 0).1 base
      simpa only [Tree.follow_value] using bit
    | succ i ih =>
      obtain ⟨x,e,same,next⟩ := link i
      apply step45 next _ (frame_time hi (frames (i+1) hi))
      rw [table.value_congr same 0 (by simpa using table_width)]
      exact ih (by omega)
  have bit := (table.bounds table_valid _ _ 97).2 (reached 97 (by decide))
  simp [table_end] at bit

end Ruliology.CellularAutomata.Rule30TrappedRunBoundary
