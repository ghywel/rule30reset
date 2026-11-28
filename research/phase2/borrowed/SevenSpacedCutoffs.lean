module

public import Ruliology.CellularAutomata.Rule30MassCounterexamples
import all Ruliology.CellularAutomata.Rule30MassCounterexamples

@[expose] public section

/-! Exact first wall failures for cuts of AIOvernight's seven-spaced reference.
    The proof uses Galindo's moving strip and untouched-prefix lemmas at kit
    ea5d70e. `import all` gives the proof bodies access to those private lemmas. -/

namespace SevenSpacedCutoffs

open Ruliology.CellularAutomata
open Rule30MassCounterexamples Rule30PeriodTwoMass
open Rule30ZeroBoundary.IntegerForm (F iter)

set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option exponentiation.threshold 20000

def FirstFailure (f : Nat → Bool) (t : Nat) : Prop :=
  f t = false ∧ ∀ s, s < t → f s = true

/-- In physical time the pinned phase is odd. Restarting at tick one makes
    this the black-even clock. -/
def pinned (x t : Nat) : Bool := decide (t%2=0) || tr x t

theorem pinned_of_G {x t : Nat} (odd : t%2=1) (h : FirstFailure (gstep (tr x)) t) :
    FirstFailure (pinned x) t := by
  have he : ¬t%2=0 := by omega
  have bad := h.1
  simp only [gstep, ite_eq_right (by omega : t≠0), ite_eq_left odd] at bad
  refine ⟨by simp [pinned, he, bad], ?_⟩
  intro s hs
  rcases Nat.mod_two_eq_zero_or_one s with even | odd'
  · simp [pinned,even]
  · have ok := h.2 s hs
    simp only [gstep, ite_eq_right (by omega : s≠0), ite_eq_left odd'] at ok
    simp [pinned, show ¬s%2=0 by omega, ok]

/-- The published integers are ordinary cuts, with no additional suffix. -/
theorem literal_cuts :
    seed 11 = Y86 ∧ seed 27 = Y198 ∧ seed 43 = Y310 ∧
    Y86.log2+1=72 ∧ Y198.log2+1=184 ∧ Y310.log2+1=296 := by decide +kernel

theorem published_failures :
    FirstFailure (gstep (tr Y86)) 87 ∧ FirstFailure (pinned Y86) 87 ∧
    FirstFailure (gstep (tr Y198)) 199 ∧ FirstFailure (pinned Y198) 199 ∧
    FirstFailure (gstep (tr Y310)) 311 ∧ FirstFailure (pinned Y310) 311 := by
  have a : FirstFailure (gstep (tr Y86)) 87 := ⟨by decide +kernel, sharp_86.2.1⟩
  have b : FirstFailure (gstep (tr Y198)) 199 := ⟨by decide +kernel, sharp_198.2.1⟩
  have c : FirstFailure (gstep (tr Y310)) 311 := ⟨by decide +kernel, sharp_310.2.1⟩
  exact ⟨a,pinned_of_G (by decide) a,b,pinned_of_G (by decide) b,c,pinned_of_G (by decide) c⟩

theorem added_literal :
    Certificates.seed2635 = Suffix.row 2635 (2^17) ∧ Certificates.seed2635.log2+1=18464 := by
  decide +kernel

/-! ## A small kernel-replayable form of the moving strip -/

def mask (w : Nat) := (2^w-1) <<< 2
def advance (w t x : Nat) := ((x ^^^ ((x <<< 1) ||| (x <<< 2))) &&& mask w) ||| feed (t+1)

def strip (q w : Nat) : Nat → Nat
  | 0 => ((q <<< 2) &&& mask w) ||| feed 0
  | t+1 => advance w t (strip q w t)

private theorem mask_bit (w j : Nat) : (mask w).testBit j = decide (2 ≤ j ∧ j<w+2) := by
  rw [mask,Nat.testBit_shiftLeft,Nat.testBit_two_pow_sub_one]
  by_cases h : 2 ≤ j
  · simp only [h, decide_true, true_and]
    exact decide_eq_decide.mpr (by omega)
  · simp [h]

private theorem feed_small (t : Nat) : feed t < 4 := by
  have h : ∀ s : Fin 28, feedTable[s.val]! < 4 := by decide +kernel
  exact h ⟨t%28,by omega⟩

theorem strip_bit (q w t j : Nat) (hj : j<w+2) : (strip q w t).testBit j = Suffix.lanes q t j := by
  induction t generalizing j with
  | zero =>
    by_cases low : j < 2
    · simp [strip, Suffix.lanes, Nat.testBit_or,Nat.testBit_and,mask_bit,low,show ¬2≤j by omega]
    · have fd := Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (feed_small 0)
        (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) (by omega : 2 ≤ j)))
      simp [strip,Suffix.lanes,Nat.testBit_or,Nat.testBit_and,Nat.testBit_shiftLeft,mask_bit,
        show j≥2 by omega,hj,low,fd]
  | succ t ih =>
    by_cases low : j<2
    · have hm : (mask w).testBit j = false := by simp [mask_bit,show ¬2≤j by omega]
      rw [Suffix.low_lanes _ _ _ low]
      simp only [strip,advance,Nat.testBit_or,Nat.testBit_and,hm,Bool.and_false,Bool.false_or]
    · obtain ⟨i,rfl⟩ : ∃ i,j=i+2 := ⟨j-2,by omega⟩
      have fd : (feed (t+1)).testBit (i+2) = false := Nat.testBit_lt_two_pow
        (Nat.lt_of_lt_of_le (feed_small (t+1))
          (Nat.pow_le_pow_right (by decide : 0 < (2 : Nat)) (by omega : 2≤i+2)))
      have hm : (mask w).testBit (i+2) = true := by simp [mask_bit,hj]
      simp only [strip, advance, Nat.testBit_or,Nat.testBit_and,Nat.testBit_xor,Nat.testBit_shiftLeft,
        hm, decide_eq_true (by omega : 2≤i+2), decide_eq_true (by omega : 1≤i+2),
        Bool.true_and, Bool.and_true, fd, Bool.or_false, show i+2-1=i+1 by omega, show i+2-2=i by omega,
        ih (i+2) hj, ih (i+1) (by omega), ih i (by omega)]
      rfl

def join (n : Nat) := cut n-16

def window (n q w : Nat) := enc (ether (join n)) 16 ||| ((strip q w (join n) >>> 2) <<< 16)

private theorem join_add (n : Nat) (hn : 3≤n) : join n+16=cut n := by unfold join cut; omega

theorem wall_read (n q w u : Nat) (hn : 3≤n) (hu : u<16+w) :
    tr (Suffix.row n q) (join n+u) = tr (window n q w) u := by
  have same (d : Nat) (hd : d<16+w) :
      Suffix.read (Suffix.row n q) (join n) d = Suffix.read (window n q w) 0 d := by
    have j := join_add n hn
    change Suffix.read (Suffix.row n q) (join n) d = (window n q w).testBit d
    by_cases h : d<16
    · simpa [window,testBit_enc,h,show ¬16≤d by omega] using
        Suffix.untouched n q (join n) d (by omega) (by omega)
    · have p := Suffix.lanes_match n q (by omega) (join n) (by omega) (2+(d-16))
      rw [show cut n-join n-2+(2+(d-16))=d by omega] at p
      simpa [window,testBit_enc,h,show 16≤d by omega] using
        p.trans (strip_bit q w _ _ (by omega)).symm
  simpa only [Nat.zero_add, tr, Suffix.read] using Suffix.propagate _ _ _ _ _ same u 0 (by omega)

private theorem shift_strip (q w p : Nat) (hp : p%28=0) (same : strip q w p=strip q w 0) :
    ∀ t, strip q w (t+p)=strip q w t := by
  intro t
  induction t with
  | zero => simpa only [Nat.zero_add] using same
  | succ t ih =>
    rw [show t+1+p=t+p+1 by omega]
    simp only [strip,advance,ih,feed,show (t+p+1)%28=(t+1)%28 by omega]

theorem window_period (n q w m : Nat) (hn : 3≤n) (ht : (7*m)%28=0) (hr : (7*m)%8=0)
    (same : strip q w (7*m)=strip q w 0) : window (n+m) q w = window n q w := by
  have time : join (n+m)=join n+7*m := by unfold join cut; omega
  have hp : phase (join n+7*m)=phase (join n) := by
    have pos : 0<join n := by unfold join cut; omega
    unfold phase
    rw [ite_eq_right (by omega : join n+7*m≠0),ite_eq_right (by omega : join n≠0)]
    omega
  simp only [window,time,shift_strip q w (7*m) ht same]
  congr 1
  congr 1
  funext d
  simp only [ether,hp]

def localPin (n x i : Nat) : Bool := decide ((cut n+i)%2=0) || tr x (16+i)
def localG (n x i : Nat) : Bool := if (cut n+i)%2=1 then tr x (16+i)
    else tr x (14+i) || tr x (16+i)

/-- A return of the packed strip at a common clock period makes every
    local test repeat when the spike count increases by that period / 7. -/
theorem local_period (n q w m : Nat) (hn : 3≤n) (ht : (7*m)%28=0) (hr : (7*m)%8=0)
    (same : strip q w (7*m)=strip q w 0) :
    (localPin (n+m) (window (n+m) q w) = localPin n (window n q w)) ∧
    (localG (n+m) (window (n+m) q w) = localG n (window n q w)) := by
  have cycle := window_period n q w m hn ht hr same
  have parity (i : Nat) : (cut (n+m)+i)%2 = (cut n+i)%2 := by unfold cut; omega
  constructor
  · funext i
    simp only [localPin,cycle,parity]
  · funext i
    simp only [localG,cycle,parity]

theorem localPin_sound (n q w i : Nat) (hn : 3≤n) (hi : i<w) :
    pinned (Suffix.row n q) (cut n+i) = localPin n (window n q w) i := by
  have h := wall_read n q w (16+i) hn (by omega)
  rw [show join n+(16+i)=cut n+i by have := join_add n hn; omega] at h
  simp only [pinned,localPin,h]

theorem localG_sound (n q w i : Nat) (hn : 3≤n) (hi : i<w) :
    gstep (tr (Suffix.row n q)) (cut n+i) = localG n (window n q w) i := by
  have a := wall_read n q w (16+i) hn (by omega)
  have b := wall_read n q w (14+i) hn (by omega)
  have j := join_add n hn
  rw [show join n+(16+i)=cut n+i by omega] at a
  rw [show join n+(14+i)=cut n+i-2 by omega] at b
  simp only [gstep,ite_eq_right (by unfold cut; omega : cut n+i≠0),localG,a,b]

theorem firstG_of_local (n q w d : Nat) (hn : 3≤n) (hd : d<w)
    (h : FirstFailure (localG n (window n q w)) d) :
    FirstFailure (gstep (tr (Suffix.row n q))) (cut n+d) := by
  refine ⟨by rw [localG_sound n q w d hn hd, h.1], ?_⟩
  intro t ht
  by_cases hb : t<cut n
  · exact Suffix.initial_checks n q t (by omega) hb
  · rw [show t=cut n+(t-cut n) by omega,localG_sound n q w _ hn (by omega)]
    exact h.2 _ (by omega)

theorem firstPin_of_local (n q w d : Nat) (hn : 3≤n) (hd : d<w)
    (h : FirstFailure (localPin n (window n q w)) d) :
    FirstFailure (pinned (Suffix.row n q)) (cut n+d) := by
  refine ⟨by rw [localPin_sound n q w d hn hd, h.1], ?_⟩
  intro t ht
  by_cases hb : t<cut n
  · rcases Nat.mod_two_eq_zero_or_one t with even | odd
    · simp [pinned,even]
    · have ok := Suffix.initial_checks n q t (by omega) hb
      simp only [gstep,ite_eq_right (by omega : t≠0),ite_eq_left odd] at ok
      simp [pinned,show ¬t%2=0 by omega,ok]
  · rw [show t=cut n+(t-cut n) by omega,localPin_sound n q w _ hn (by omega)]
    exact h.2 _ (by omega)

theorem added_literal_failure : FirstFailure (gstep (tr Certificates.seed2635)) 18475 ∧
    FirstFailure (pinned Certificates.seed2635) 18475 := by
  have last : gstep (tr (Suffix.row 2635 (2^17))) 18475 = false := by
    change gstep (tr (Suffix.row 2635 (2^17))) (cut 2635+29) = false
    rw [localG_sound 2635 (2^17) 30 29 (by decide) (by decide)]
    decide +kernel
  rw [←added_literal.1] at last
  have h : FirstFailure (gstep (tr Certificates.seed2635)) 18475 := ⟨last, Certificates.counterexample2635.1⟩
  exact ⟨h,pinned_of_G (by decide) h⟩

end SevenSpacedCutoffs
