module
public import WheelObserverTransport
public import WheelObserverPlanes
@[expose] public section
namespace Ruliology.CellularAutomata.WheelObserverCheck
open WheelObserverTransport WheelObserverPlanes

def B (W u : Nat) : Nat := if W = 30 then 0 else both W u

def allowed (W u : Nat) : Nat :=
  if W = 16 then baseMask u else B (W-1) (u%2^(W-1))

def tree : Nat → Nat → Nat → Bool
  | 0,W,u => rowOK W (allowed W) (front W) (B W) u
  | k+1,W,u => rowOK W (allowed W) (front W) (B W) u &&
     (B W u == 0 || (tree k (W+1) u && tree k (W+1) (u+2^W)))

def top (u : Nat) : Bool := baseMask u == 0 || tree 14 16 u

def page (k : Nat) : Bool := (List.range 256).all fun i => top (256*k+i)

end Ruliology.CellularAutomata.WheelObserverCheck
