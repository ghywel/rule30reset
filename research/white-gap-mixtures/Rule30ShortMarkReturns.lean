import Ruliology.CellularAutomata.Rule30ThreeGapCapture

/-! Two occurrences of the I77 nine-gap factor at offsets 7, 8 or 9 force capture
in the kit's eight-cell set G. The driver is prescribed only during the two
occurrences. The initial row and the site are arbitrary. -/

namespace Rule30ShortMarkReturns
open Ruliology.CellularAutomata Rule30Realization Rule30ResetMixtures Rule30StripCertificates
open Rule30ThreeGapCapture.Driven Rule30ThreeGapCapture.Pos

set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0

def alphabet : List Nat := [9,10,11,12,13,14,15,16]

/-- Allowed lengths of the nine successive white gaps. -/
def factor : List (List Nat) := [[10,14],[12],[14],[12],[12],[10],[9],[10],[10,12]]

private def slot (start i : Nat) : List Nat :=
  if start ≤ i then factor[i-start]?.getD alphabet else alphabet

/-- Gaps in the overlap must satisfy both occurrences. -/
def twoFactors (distance : Nat) : List (List Nat) :=
  (List.range (distance + 9)).map fun i =>
    (slot 0 i).filter fun q => q ∈ slot distance i

/-- One chosen gap from each slot, in order. -/
inductive Matches : List (List Nat) → List Nat → Prop
  | nil : Matches [] []
  | cons {letters q rest qs} : q ∈ letters → Matches rest qs → Matches (letters :: rest) (q :: qs)

private def alternatives (W src : Nat) : List Nat → Nat
  | [] => 0
  | q :: qs => push W (driver q) src ||| alternatives W src qs

private theorem alt_mem {W src q} {qs : List Nat} (hq : q ∈ qs) {x j t}
    (h : Bit W (push W (driver q) src) x j t) : Bit W (alternatives W src qs) x j t := by
  induction qs with
  | nil => simp at hq
  | cons a as ih =>
    rcases List.mem_cons.mp hq with rfl | ha
    · simp [Bit, alternatives, Nat.testBit_or, show (push W (driver q) src).testBit (Frow x t j W) = true from h]
    · have h' := ih ha
      simp [Bit, alternatives, Nat.testBit_or, show (alternatives W src as).testBit (Frow x t j W) = true from h']

private def envelope (W : Nat) : List (List Nat) → Nat → Nat
  | [], s => s
  | qs :: rest, s => envelope W rest (alternatives W s qs)

private theorem envelope_mem {choices gaps} (matched : Matches choices gaps) {W x j t s}
    (start : Bit W s x j t) (drive : Drive x j t (blocks gaps)) :
    Bit W (envelope W choices s) x j (t + (blocks gaps).length) := by
  induction matched generalizing t s with
  | nil => simpa [blocks, envelope] using start
  | @cons letters q remaining qs hq _ ih =>
    rw [blocks_cons] at drive ⊢
    have endGap := push_mem (driver q) t s (drivePrefix drive) start
    have next := ih (alt_mem hq endGap) (driveSuffix drive)
    simpa only [envelope, List.length_append, Nat.add_assoc] using next

private def checked (W distance : Nat) : Bool :=
  chunks (2^(W-8)) (envelope W (twoFactors distance) (fullSet W))

private theorem sound {W distance} (wide : 8 ≤ W) (ok : checked W distance = true)
    {gaps} (matched : Matches (twoFactors distance) gaps) {x j t}
    (drive : Drive x j t (blocks gaps)) : Low x j G (t + (blocks gaps).length) := by
  apply finish ok _ wide (envelope_mem matched (all_rows rfl x j t) drive)
  rw [show 256 = 2^8 by decide, ← Nat.pow_add, Nat.add_sub_of_le wide]
  exact Nat.le_refl _

private theorem checked7 : checked 16 7 = true := by decide +kernel
private theorem checked8 : checked 17 8 = true := by decide +kernel
private theorem checked9 : checked 17 9 = true := by decide +kernel

/-- After these two possibly overlapping occurrences the right strip lies in G.
Every later sparse gap preserves G by Rule30ResetMixtures.stageG. -/
theorem capture_two_factors {distance : Nat} (hd : 7 ≤ distance ∧ distance ≤ 9)
    {gaps : List Nat} (matched : Matches (twoFactors distance) gaps)
    {x : Int → Bool} {j : Int} {t : Nat} (drive : Drive x j t (blocks gaps)) :
    Low x j G (t + (blocks gaps).length) := by
  have cases_ : distance = 7 ∨ distance = 8 ∨ distance = 9 := by omega
  rcases cases_ with rfl | rfl | rfl
  · exact sound (by decide) checked7 matched drive
  · exact sound (by decide) checked8 matched drive
  · exact sound (by decide) checked9 matched drive

/-- Every subsequent sparse gap has the same two-site observation at each
within-gap phase, even when those later gap lengths vary without a period. -/
theorem locked_after_return {distance : Nat} (hd : 7 ≤ distance ∧ distance ≤ 9)
    {gaps : List Nat} (matched : Matches (twoFactors distance) gaps)
    {x : Int → Bool} {j : Int} {t : Nat} (drive : Drive x j t (blocks gaps))
    {T q : Nat → Nat} (align : T 0 = t + (blocks gaps).length)
    (clock : ∀ n, T (n+1) = T n + (q n+1)) (sparse : ∀ n, 9 ≤ q n)
    (read : ∀ n, Drive x j (T n) (driver (q n))) :
    ∀ n k, k ≤ q n → Rule30FiniteMaskedJen.orCol x j (T n+k) = decide (k=0 ∨ 3≤k) := by
  have captured : Low x j G (T 0) := align ▸ capture_two_factors hd matched drive
  intro n
  exact Rule30ThreeGapCapture.forever j T q clock sparse read captured n (Nat.zero_le n)

end Rule30ShortMarkReturns
