module
public import WheelObserverCheck
@[expose] public section
namespace Ruliology.CellularAutomata.WheelObserverCheck
open WheelObserverPlanes WheelObserverTransport

def roots : Nat → Nat → Bool
  | 0, u => top u
  | d+1, u => roots d u && roots d (u + 2^d)

theorem roots_join (d u : Nat) (left : roots d u = true) (right : roots d (u+2^d) = true) :
    roots (d+1) u = true := by simp [roots, left, right]

theorem children (k W u : Nat) (r : rowOK W (allowed W) (front W) (B W) u = true)
    (left : tree k (W+1) u = true) (right : tree k (W+1) (u+2^W) = true) :
    tree (k+1) W u = true := by simp [tree, r, left, right]

theorem root0 (u : Nat) (h : tree 14 16 u = true) : roots 0 u = true := by
  simp [roots, top, h]

theorem top_of_roots {n a p : Nat} (h : roots n a = true) (hp : p < 2^n) : top (a+p) = true := by
  induction n generalizing a p with
  | zero => simp only [Nat.pow_zero, Nat.lt_one_iff] at hp; simpa [hp,roots] using h
  | succ n ih =>
    have branches : roots n a = true ∧ roots n (a+2^n) = true := by simpa only [roots, Bool.and_eq_true] using h
    by_cases less : p<2^n
    · exact ih branches.1 less
    · have sub : p-2^n<2^n := by rw [Nat.pow_succ] at hp; omega
      simpa only [show a+2^n+(p-2^n)=a+p by omega] using ih branches.2 sub

end Ruliology.CellularAutomata.WheelObserverCheck
