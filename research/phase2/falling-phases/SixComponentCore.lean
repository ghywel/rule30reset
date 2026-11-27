import SixComponentTables
import SixCheckCore

/-! Each component annotation stores its level in the high nibble and its
height in the low nibble. Active (odd-level) components retain the pair tag
from the six-column certificate. -/
namespace PhaseFalls.Six

def componentEntry (a t s : Nat) : Nat :=
  let phase := (t+3-a%3)%3
  let packed := componentTables[3*tableIndex[a]! + phase]!
  (packed >>> (8*s)) % 256

def level (a t s : Nat) := componentEntry a t s / 16
def height (a t s : Nat) := componentEntry a t s % 16

def ComponentEdge (a t s : Nat) (w e : Bool) : Prop :=
  let d := step s w e
  let u := (t+1)%3
  allowed a t s d = true →
    level a u d < level a t s ∨ (level a u d = level a t s ∧
      (if level a t s % 2 = 0 then height a u d < height a t s
       else tag (entry a u d) = tag (entry a t s)))

instance (a t s : Nat) (w e : Bool) : Decidable (ComponentEdge a t s w e) := by
  unfold ComponentEdge
  infer_instance

def checkComponentNode (a t s : Nat) : Bool :=
  (decide (level a t s ≤ 6) && decide (height a t s ≤ 11)) &&
    (decide (ComponentEdge a t s false false) && decide (ComponentEdge a t s false true) &&
     decide (ComponentEdge a t s true false) && decide (ComponentEdge a t s true true))

def checkComponentAssignment (a : Nat) : Bool :=
  (List.range 3).all fun t => (List.range 64).all fun s => checkComponentNode a t s

end PhaseFalls.Six
