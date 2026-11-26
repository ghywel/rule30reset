import Ruliology.CellularAutomata.Rule30FiniteMaskedJen
import Ruliology.CellularAutomata.Rule30RotationBlocks

/-! Transfer a block repeat with unbounded additive surplus to the finite window of Jen. -/
namespace JenBlockWindow
open Ruliology.CellularAutomata Rule30RotationBlocks
open Rule30Realization (evol)

theorem visible_window (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start a b l : Nat) (ab : a < b)
    (clock : ∀ t, evol x (start+t) i = decide (t%2=1))
    (reachable : 0 ≤ i-lo+((start+2*b:Nat):Int))
    (long : i-lo+((start+2*b:Nat):Int) ≤ 2*(l:Int))
    (same : ∀ s, s < l → evol x (start+2*(a+s)) (i+1) = evol x (start+2*(b+s)) (i+1)) : False := by
  let m := (i-lo+((start+2*b:Nat):Int)).toNat
  have edge : (m:Int) = i-lo+((start+2*b:Nat):Int) := Int.toNat_of_nonneg reachable
  apply Rule30FiniteMaskedJen.window_jen_col leftBlack leftWhite (t₁ := start+2*a)
    (t₂ := start+2*b) (i := i) m (by omega) (by omega)
  · intro s _
    rw [Nat.add_assoc,Nat.add_assoc,clock,clock]
    have parity : (2*a+s)%2 = (2*b+s)%2 := by omega
    rw [parity]
  · intro s hs
    unfold Rule30FiniteMaskedJen.orCol
    simp only [Nat.add_assoc,clock]
    by_cases parity : s%2=0
    · have ha : (2*a+s)%2=0 := by omega
      have hb : (2*b+s)%2=0 := by omega
      simp only [ha,hb, Nat.reduceEqDiff, decide_false, Bool.false_or]
      have e := same (s/2) (by omega)
      rwa [show 2*(a+s/2)=2*a+s by omega, show 2*(b+s/2)=2*b+s by omega] at e
    · have ha : (2*a+s)%2=1 := by omega
      have hb : (2*b+s)%2=1 := by omega
      simp [ha,hb]

theorem excludes_blocks {α : Type} (c : Nat → α) (len : α → Nat) (positive : ∀ v, 1 ≤ len v)
    (bits : α → Nat → Bool)
    (reps : ∀ H C : Nat, ∃ a b l, H ≤ a ∧ a < b ∧ C ≤ b-a ∧
      (∀ s, s < l → c (a+s) = c (b+s)) ∧
      total (fun t => len (c t)) a + total (fun t => len (c t)) b + C ≤ total (fun t => len (c t)) (a+l))
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start+t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (c n) → cutoff ≤ total (fun t => len (c t)) n+y →
      evol x (start+2*(total (fun t => len (c t)) n+y)) (i+1) = bits (c n) y) : False := by
  let w := fun t => len (c t)
  have pos : ∀ t, 1 ≤ w t := fun t => positive _
  let C := (lo-i).toNat + (i-lo+(start:Int)).toNat + 1
  obtain ⟨a,b,l,late,ab,lag,agree,room⟩ := reps cutoff C
  have bound (t : Nat) : t ≤ total w t := by simpa [total] using le_total w pos 0 t
  have grows := le_total w pos a (b-a)
  rw [Nat.add_sub_of_le (Nat.le_of_lt ab)] at grows
  change total w a + total w b + C ≤ total w (a+l) at room
  apply visible_window x lo i leftBlack leftWhite start (total w a) (total w b)
    (total w (a+l)-total w a) (by omega) clock
  · have hb := bound b
    dsimp [C] at lag
    omega
  · dsimp [C] at room
    omega
  · intro s hs
    obtain ⟨j,hj,y,hy,offset⟩ := locate w a s l (by omega)
    have eqw (e : Nat) (h : e < l) : w (a+e) = w (b+e) := congrArg len (agree e h)
    have hy' : y < w (b+j) := eqw j hj ▸ hy
    have shift := total_shift w a b j (fun e he => eqw e (by omega))
    have other : total w b+s = total w (b+j)+y := by omega
    have cut := bound a
    rw [offset,other,reads _ _ hy (by change cutoff ≤ total w (a+j)+y; omega),
      reads _ _ hy' (by change cutoff ≤ total w (b+j)+y; omega),agree j hj]

end JenBlockWindow
