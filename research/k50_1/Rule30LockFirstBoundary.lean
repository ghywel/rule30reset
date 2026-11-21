module

public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! Exact attainable exterior choices at the first odd window of a fixed black-time prefix. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LockFirstBoundary

open Ruliology.CellularAutomata
open Rule30Jen Rule30Ether Rule30PeriodTwoCoupled Rule30SidewaysLocks

/-- The feasible exterior pair at tick one. A and B are the last two fixed black-time cells. -/
def Feasible (a b p q : Bool) : Prop :=
  if b then p = !a else p = a ∨ q = true

instance (a b p q : Bool) : Decidable (Feasible a b p q) := by
  unfold Feasible
  cases b <;> infer_instance

theorem feasible_iff : ∀ (a b p q : Bool), Feasible a b p q ↔
    ∃ x y : Bool, rule a b x = p ∧ rule b x y = q := by decide +kernel

private def initial (n c : Nat) : List Bool :=
  Rule30GateTrap.evolve 0 1 (decodeW (n+2) c)

private theorem at_three (n c : Nat) (R : Nat → Bool)
    (pref : ∀ i, i<n+2 → R (i+1) = c.testBit i) :
    winW (n+1) R 3 = dstep (initial n c)
      (rule (c.testBit n) (c.testBit (n+1)) (R (n+3)))
      (rule (c.testBit (n+1)) (R (n+3)) (R (n+4))) := by
  rw [winW_dstep (n+1) R 1 (by decide), winW_prefix (W:=n+1) (t0:=1) pref]
  simp only [initial, drv]
  simp [pref n (by omega), pref (n+1) (by omega)]

/-- For a black-time prefix of length W+1 (W=n+1), all physical W-cell windows at time 3 satisfy P
exactly when P holds for the two or three feasible successors of the fixed window at time 1. -/
theorem exact_one_step (n c : Nat) (P : List Bool → Prop) :
    (∀ R : Nat → Bool, (∀ i, i<n+2 → R (i+1) = c.testBit i) → P (winW (n+1) R 3)) ↔
    ∀ p q : Bool, Feasible (c.testBit n) (c.testBit (n+1)) p q →
      P (dstep (Rule30GateTrap.evolve 0 1 (decodeW (n+2) c)) p q) := by
  constructor
  · intro h p q hpq
    obtain ⟨x,y,hp,hq⟩ := (feasible_iff _ _ _ _).mp hpq
    let R := fun j => if j=n+3 then x else if j=n+4 then y else rh c j
    have pref : ∀ i, i<n+2 → R (i+1) = c.testBit i := by
      intro i hi
      simp only [R, ite_eq_right (by omega : i+1 ≠ n+3), ite_eq_right (by omega : i+1 ≠ n+4)]
      exact rh_prefix c (n+2) i hi
    have e:=h R pref
    rw [at_three n c R pref] at e
    have hx : R (n+3)=x := by simp [R]
    have hy : R (n+4)=y := by simp [R]
    rwa [hx,hy,hp,hq] at e
  · intro all R hp
    rw [at_three n c R hp]
    exact all _ _ ((feasible_iff _ _ _ _).mpr ⟨_,_,rfl,rfl⟩)

/-- Indicators for the two rightmost final cells. Their physical values are obtained
by XOR with fixed interior bits, so equality of output pairs is equality of these indicators.
Bits f,g,h,a,b are black-time cells W-3 through W+1, for W≥4. -/
def signature (f g h a b p q : Bool) : Bool × Bool :=
  let r:=rule f g h
  let u:=rule g h a
  let v:=rule h a b
  let c:=rule r u v
  let y:=rule u v p
  let z:=rule v p q
  (c || y, y || z)

def suffixCode (f g h a b : Bool) : Nat :=
  16*f.toNat+8*g.toNat+4*h.toNat+2*a.toNat+b.toNat

/-- All four abstract boundary choices give a strictly larger set of two-bit
output signatures precisely on these trailing black-time words (most significant bit on the left). -/
theorem spurious_iff : ∀ f g h a b : Bool,
    (∃ p q : Bool, ∀ x y : Bool, signature f g h a b p q ≠
      signature f g h a b (rule a b x) (rule b x y)) ↔
    [2,5,7,9,13,14,18,25,29,30,31].contains (suffixCode f g h a b) = true := by
  decide +kernel

open Ruliology.CellularAutomata
open Rule30Jen Rule30StripCertificates Rule30SidewaysLocks

private theorem lin_last : ∀ (l : List Bool) (a b c : Bool),
    lin3 (l++[a,b,c]) = lin3 (l++[a,b]) ++ [rule a b c]
  | [],_,_,_ => rfl
  | [_],_,_,_ => rfl
  | [_,_],_,_,_ => rfl
  | d::e::f::xs,a,b,c => by
    change _ :: lin3 ((e::f::xs)++[a,b,c]) = _ :: (lin3 ((e::f::xs)++[a,b]) ++ [rule a b c])
    rw [lin_last (e::f::xs) a b c]

private theorem lin_four (l : List Bool) (a b c d : Bool) :
    lin3 (l++[a,b,c,d]) = lin3 (l++[a,b]) ++ [rule a b c,rule b c d] := by
  have h:=lin_last (l++[a]) b c d
  simp only [List.append_assoc,List.cons_append,List.nil_append] at h
  rw [h,lin_last]
  simp

private theorem lin_six (l : List Bool) (a b c d e f : Bool) :
    lin3 (l++[a,b,c,d,e,f]) =
      lin3 (l++[a,b]) ++ [rule a b c,rule b c d,rule c d e,rule d e f] := by
  have h:=lin_four (l++[a,b]) c d e f
  simp only [List.append_assoc,List.cons_append,List.nil_append] at h
  rw [h,lin_four]
  simp

private def edgeOut (i r u v p q : Bool) :=
  [rule (rule i r u) (rule r u v) (rule u v p), rule (rule r u v) (rule u v p) (rule v p q)]

private theorem frame_step (inner : List Bool) (i r u v p q : Bool) :
    dstep (inner++[i,r,u,v]) p q =
    lin3 ((true :: lin3 ((false::inner) ++ [i,r])) ++ [rule i r u,rule r u v]) ++ edgeOut i r u v p q := by
  unfold dstep
  rw [show false :: ((inner++[i,r,u,v])++[p,q])=(false::inner)++[i,r,u,v,p,q] by simp]
  rw [lin_six]
  change lin3 ((true :: _)++[_,_,_,_])=_
  exact lin_four _ _ _ _ _

private theorem edgeEq : ∀ (i f g h a b p q x y : Bool),
    edgeOut i (rule f g h) (rule g h a) (rule h a b) p q =
    edgeOut i (rule f g h) (rule g h a) (rule h a b) x y ↔
      signature f g h a b p q = signature f g h a b x y := by decide +kernel

/-- The output classification is exact for whole W-cell windows, for any unchanged interior
and any odd-time fourth cell i from the right. -/
theorem window_eq_iff_signature (inner : List Bool) (i f g h a b p q x y : Bool) :
    let w:=inner++[i,rule f g h,rule g h a,rule h a b]
    dstep w p q = dstep w x y ↔ signature f g h a b p q = signature f g h a b x y := by
  dsimp only
  rw [frame_step,frame_step]
  simpa only [List.append_right_inj] using (edgeEq i f g h a b p q x y)

open Ruliology.CellularAutomata
open Rule30Ether Rule30Jen Rule30StripCertificates Rule30PeriodTwoCoupled Rule30SidewaysLocks

private theorem tail_shape (n : Nat) (R : Nat → Bool) :
    winW (n+4) R 1 = winW n R 1 ++ [drv altCol R 1 (n+1),
      rule (R (n+1)) (R (n+2)) (R (n+3)),rule (R (n+2)) (R (n+3)) (R (n+4)),
      rule (R (n+3)) (R (n+4)) (R (n+5))] := by
  unfold winW rowOf
  rw [seg_succ (n+3),seg_succ (n+2),seg_succ (n+1),seg_succ n]
  simp only [List.append_assoc,List.cons_append,List.nil_append,Nat.zero_add]
  simp [drv]

/-- An exact family-level criterion for the unphysical whole-window successors of the
first white-time window. Width is n+4; the given black-time prefix fixes width+1 cells.
A general predicate can distinguish free from true successors only on these 11 of 32 suffixes. -/
theorem physical_spurious_iff (n c : Nat) :
    let w:=winW (n+4) (rh c) 1
    (∃ p q : Bool, ∀ S : Nat → Bool,
        (∀ i, i<n+5 → S (i+1) = c.testBit i) →
          dstep w p q ≠ winW (n+4) S 3) ↔
    [2,5,7,9,13,14,18,25,29,30,31].contains
      (16*(c.testBit n).toNat+8*(c.testBit (n+1)).toNat+4*(c.testBit (n+2)).toNat+
        2*(c.testBit (n+3)).toNat+(c.testBit (n+4)).toNat) = true := by
  dsimp only
  let w:=winW (n+4) (rh c) 1
  have canon : w=Rule30GateTrap.evolve 0 1 (decodeW (n+5) c) :=
    winW_prefix (W:=n+4) (t0:=1) (rh_prefix c (n+5))
  let sig:=signature (c.testBit n) (c.testBit (n+1)) (c.testBit (n+2))
    (c.testBit (n+3)) (c.testBit (n+4))
  have eq (p q x y : Bool) : dstep w p q=dstep w x y ↔ sig p q = sig x y := by
    dsimp only [w]
    rw [tail_shape n (rh c)]
    exact window_eq_iff_signature _ _ _ _ _ _ _ _ _ _ _
  have iffNo (p q : Bool) :
      (∀ S : Nat → Bool, (∀ i, i<n+5 → S (i+1) = c.testBit i) →
        dstep w p q ≠ winW (n+4) S 3) ↔
      ∀ x y : Bool, sig p q ≠ sig (rule (c.testBit (n+3)) (c.testBit (n+4)) x)
        (rule (c.testBit (n+4)) x y) := by
    rw [exact_one_step (n+3) c (fun z => dstep w p q ≠ z)]
    rw [← canon]
    constructor
    · intro all x y h
      exact all _ _ ((feasible_iff _ _ _ _).mpr ⟨x,y,rfl,rfl⟩) ((eq _ _ _ _).mpr h)
    · intro all x y hFe h
      obtain ⟨u,v,hu,hv⟩ := (feasible_iff _ _ _ _).mp hFe
      exact all u v (by rw [hu,hv]; exact (eq _ _ _ _).mp h)
  have cproof:=spurious_iff (c.testBit n) (c.testBit (n+1)) (c.testBit (n+2))
    (c.testBit (n+3)) (c.testBit (n+4))
  constructor
  · rintro ⟨p,q,impossible⟩
    exact cproof.mp ⟨p,q,(iffNo p q).mp impossible⟩
  · intro suffix
    obtain ⟨p,q,impossible⟩:=cproof.mpr suffix
    exact ⟨p,q,(iffNo p q).mpr impossible⟩

end Ruliology.CellularAutomata.Rule30LockFirstBoundary
