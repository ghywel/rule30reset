import Rule30PulseRelay
import Rule30FastBlackShield
namespace Ruliology.CellularAutomata.ShieldCascade
open Rule30Jen Rule30Realization
def fiveClock (j : Nat) := 9*j-j/5
theorem fiveBuilds : Builds fiveClock := fun x m j t h => BlackShieldSpeed.faster_shield j x m t h

/-- Repeating the ten-cell block uses 34 black ticks per group of five
pairs plus a fixed ten-tick correction, and gives twenty ticks of agreement
per group. -/
theorem groups_of_five (q r : Nat) (enough : 34*q+10 ≤ r) : Relays fiveClock r (5*q) :=
  repeat_block 5 q r (by decide) (by decide +kernel) enough

/-- Every finite-left periodic column with r blacks followed by white must
violate at least one of these two inequalities, for every q. -/
theorem black_five {x : Int→Bool} {lo : Int} (m : Int)
    (left : x lo=true) (below : ∀i,i<lo→x i=false)
    (T P r t q : Nat) (per : ∀ n, T≤n → evol x (n+P) m=evol x n m)
    (ht : T≤t) (fit : r<P) (run : ∀a,a<r→evol x (t+a) m=true)
    (white : evol x (t+r) m=false) (black : 34*q+10≤r) (tail : P-r≤20*q) : False :=
  black_period _ fiveBuilds m left below T P r t per ht fit run white _ (groups_of_five q r black) (by omega)
end Ruliology.CellularAutomata.ShieldCascade
