import SixTables
import SixPhysical

namespace PhaseFalls.Six

/-- A table entry stores a topological rank and a prediction tag. The tag
selects adjacent sites and gives their two bits at each absolute time phase. -/
def rk (x : Nat) := x / 512
def tag (x : Nat) := x % 512
def idx (g : Nat) := g % 8
def bit0 (g t : Nat) := (g / 8).testBit (2*t)
def bit1 (g t : Nat) := (g / 8).testBit (2*t+1)

def entry (a t s : Nat) : Nat :=
  let shift := a % 3
  let phase := (t+3-shift) % 3
  let packed := packedTables[3*tableIndex[a]! + phase]!
  let x := (packed >>> (17*s)) % 131072
  let bits := tag x / 8
  let rotated := ((bits <<< (2*shift)) ||| (bits >>> (6-2*shift))) % 64
  rk x * 512 + rotated * 8 + idx (tag x)

theorem rank_lt (a t s : Nat) : rk (entry a t s) < 256 := by
  unfold entry
  simp only [rk,idx]
  omega

def ReadsPair (a t s : Nat) : Prop :=
  let g := tag (entry a t s)
  idx g < 5 ∧ s.testBit (idx g) = bit0 g t ∧ s.testBit (idx g+1) = bit1 g t
instance (a t s : Nat) : Decidable (ReadsPair a t s) := by unfold ReadsPair; infer_instance

def Progress (a t s : Nat) (w e : Bool) : Prop :=
  let d := step s w e
  let x := entry a t s
  let y := entry a ((t+1)%3) d
  allowed a t s d = true → rk y < rk x ∨ (rk y = rk x ∧ tag y = tag x)
instance (a t s : Nat) (w e : Bool) : Decidable (Progress a t s w e) := by
  unfold Progress
  infer_instance

def checkNode (a t s : Nat) : Bool :=
  (decide (rk (entry a t s) < 11) && decide (ReadsPair a t s)) &&
    (decide (Progress a t s false false) && decide (Progress a t s false true) &&
     decide (Progress a t s true false) && decide (Progress a t s true true))

def checkAssignment (a : Nat) : Bool :=
  (List.range 3).all fun t => (List.range 64).all fun s => checkNode a t s

end PhaseFalls.Six
