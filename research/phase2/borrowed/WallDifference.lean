import Hybrid150Edge

/-! Two adjacent diagonals of the difference between any two white-wall runs
    of the same time-dependent, west-permutive rule. Indices start at the cell
    next to the wall. -/
namespace WallDifference

open Hybrid150Edge

abbrev Field := Nat → Row
abbrev Gate := Nat → Bool → Bool → Bool

def Valid (g : Gate) (u : Field) : Prop := ∀ t, u (t+1) = tick (g t) (u t)

def evolve (g : Gate) (x : Row) : Field
  | 0 => x
  | t+1 => tick (g t) (evolve g x t)

theorem evolve_valid (g : Gate) (x : Row) : Valid g (evolve g x) := fun _ => rfl

/-- Reconstruct a space-time field from its entire wall-adjacent trace.
    Column zero of this recursion is the clamped wall. -/
def traceColumn (g : Gate) (trace : Nat → Bool) : Nat → Nat → Bool
  | 0, _ => false
  | 1, t => trace t
  | i+2, t => xor (traceColumn g trace (i+1) (t+1))
      (g t (traceColumn g trace (i+1) t) (traceColumn g trace i t))

def fromTrace (g : Gate) (trace : Nat → Bool) : Field := fun t i => traceColumn g trace (i+1) t

theorem fromTrace_valid (g : Gate) (trace : Nat → Bool) : Valid g (fromTrace g trace) := by
  intro t
  funext i
  have wall : east (fromTrace g trace t) i = traceColumn g trace i t := by
    cases i <;> rfl
  have undo : ∀ a b : Bool, xor (xor a b) b = a := by decide
  simp only [fromTrace, tick, wall, traceColumn, undo]

def parity (f : Nat → Bool) : Nat → Bool
  | 0 => false
  | t+1 => xor (parity f t) (f t)

theorem parity_congr {f h : Nat → Bool} (n : Nat) (same : ∀ t < n, f t = h t) :
    parity f n = parity h n := by
  induction n with
  | zero => rfl
  | succ n ih => rw [parity, parity, ih (fun t ht => same t (by omega)), same n (by omega)]

theorem parity_append (f : Nat → Bool) (m n : Nat) :
    parity f (m+n) = xor (parity f m) (parity (fun t => f (m+t)) n) := by
  induction n with
  | zero => cases parity f m <;> rfl
  | succ n ih => rw [Nat.add_succ, parity, ih, parity, Bool.xor_assoc]

def effect (g : Gate) (u : Field) (first t : Nat) : Bool :=
  let r := east (u t) (first-t)
  xor (g t false r) (g t true r)

def correction (g : Gate) (u : Field) (first : Nat) : Bool := parity (effect g u first) (first+1)

/-- When the reference and rule repeat in time and the reference has a periodic
    outer region, the correction for an adjacent wall arrival repeats in depth.
    The common period `p` can double, since each added period XORs one bit. -/
theorem correction_period (g : Gate) (u : Field) (p start : Nat)
    (time : ∀ t, u (t+p) = u t) (rule : ∀ t, g (t+p) = g t)
    (space : ∀ t i, start ≤ i → u t (i+p) = u t i) (n : Nat) (h : start ≤ n) :
    correction g u (n+p+p) = correction g u n := by
  let head := fun j => parity (effect g u j) p
  have extend (j : Nat) : correction g u (j+p) = xor (head (j+p)) (correction g u j) := by
    unfold correction
    rw [show j+p+1=p+(j+1) by omega, parity_append]
    apply congrArg (xor (head (j+p)))
    apply parity_congr
    intro t _
    have shift : east (u (p+t)) (j+p-(p+t)) = east (u t) (j-t) := by
      rw [show u (p+t)=u t by rw [Nat.add_comm p t, time], show j+p-(p+t)=j-t by omega]
    simp only [effect, shift, show g (p+t)=g t by rw [Nat.add_comm p t, rule]]
  have sameHead : head (n+p+p) = head (n+p) := by
    apply parity_congr
    intro t ht
    let i := n+p-t-1
    have a : n+p-t=i+1 := by dsimp [i]; omega
    have b : n+p+p-t=i+p+1 := by dsimp [i]; omega
    have sameEast : east (u t) (n+p+p-t) = east (u t) (n+p-t) := by
      calc
        east (u t) (n+p+p-t) = u t (i+p) := by rw [b]; rfl
        _ = u t i := space t i (by dsimp [i]; omega)
        _ = east (u t) (n+p-t) := by rw [a]; rfl
    simp only [effect, sameEast]
  rw [extend (n+p), sameHead, extend n]
  cases head (n+p) <;> cases correction g u n <;> rfl

private theorem equal_east {u v : Row} (k : Nat) (h : ∀ i < k, u i = v i) :
    east u k = east v k := by
  cases k with
  | zero => rfl
  | succ k => exact h k (by omega)

/-- The initial lead index gives a diagonal on the edge of the common cone. -/
theorem before {g : Gate} {u v : Field} (hu : Valid g u) (hv : Valid g v)
    {first : Nat} (h : ∀ k < first, u 0 k = v 0 k) (t k : Nat) (hk : t+k < first) :
    u t k = v t k := by
  induction t generalizing k with
  | zero => exact h k (by omega)
  | succ t ih =>
    have right := equal_east k (fun i hi => ih i (by omega))
    rw [hu, hv]
    simp only [tick, ih (k+1) (by omega), ih k (by omega), right]

theorem leading {g : Gate} {u v : Field} (hu : Valid g u) (hv : Valid g v)
    {first : Nat} (h : ∀ i < first, u 0 i = v 0 i) (t k : Nat) (hk : t+k = first) :
    xor (u t k) (v t k) = xor (u 0 first) (v 0 first) := by
  induction t generalizing k with
  | zero => rw [show k=first by omega]
  | succ t ih =>
    have right := equal_east k (fun i hi => before hu hv h t i (by omega))
    have centre := before hu hv h t k (by omega)
    rw [hu, hv]
    simp only [tick, right, centre]
    have cancel : ∀ a b c : Bool, xor (xor a c) (xor b c) = xor a b := by decide
    rw [cancel]
    exact ih (k+1) (by omega)

private theorem xor_update (g : Bool → Bool) (a b c d : Bool) (hd : xor c d = true) :
    xor (xor a (g c)) (xor b (g d)) = xor (xor a b) (xor (g false) (g true)) := by
  cases c <;> cases d <;> simp at hd
  · cases a <;> cases b <;> cases g false <;> cases g true <;> decide
  · cases a <;> cases b <;> cases g false <;> cases g true <;> decide

/-- A disagreement on the leading diagonal adds the centre-bit derivative
    to the next diagonal, along which the other initial difference is carried. -/
theorem adjacent {g : Gate} {u v : Field} (hu : Valid g u) (hv : Valid g v)
    {first : Nat} (h : ∀ i < first, u 0 i = v 0 i) (hd : xor (u 0 first) (v 0 first) = true)
    (t k : Nat) (hk : t+k=first+1) :
    xor (u t k) (v t k) = xor (xor (u 0 (first+1)) (v 0 (first+1))) (parity (effect g u first) t) := by
  induction t generalizing k with
  | zero =>
    rw [show k=first+1 by omega]
    simp [parity]
  | succ t ih =>
    have right := equal_east k (fun i hi => before hu hv h t i (by omega))
    have centre : xor (u t k) (v t k) = true := (leading hu hv h t k (by omega)).trans hd
    rw [hu, hv]
    simp only [tick, ← right]
    rw [xor_update (fun b => g t b (east (u t) k)) _ _ _ _ centre, ih (k+1) (by omega), parity,
      Bool.xor_assoc]
    simp only [effect, show first-t=k by omega]

end WallDifference
