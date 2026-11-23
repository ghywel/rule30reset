module
public import WheelPureThreeExit

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover

/-- Decode one gate reading per bit, with the first reading in the low bit. -/
def word (n bits : Nat) : List Bool := (List.range n).map bits.testBit

def decodeRows (width : Nat) : Nat → Nat → List Nat
  | 0, _ => []
  | n+1, bits => bits % 2^width :: decodeRows width n (bits >>> width)

def decodeGrid (width : Nat) (rows : List (Nat × Nat)) : PureThreeExit.Grid :=
  rows.map fun p => decodeRows width p.1 p.2

end Ruliology.CellularAutomata.WordCover
