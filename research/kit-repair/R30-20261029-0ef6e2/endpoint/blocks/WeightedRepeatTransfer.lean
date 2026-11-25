import Ruliology.CellularAutomata.Rule30RotationBlocks

/-! A repeat of a letter word has two clocks. Its letter indices locate the
matching blocks, and the sums of their lengths give the actual readings.
The second theorem applies that transfer at any eventually alternating site. -/

namespace WeightedRepeatTransfer
open Ruliology.CellularAutomata Rule30RotationBlocks
open Rule30Realization (evol)

/-- Linear envelopes for the prefix clock transfer a scaled letter surplus
into a bounded slack in readings. The denominator is shared by the envelopes. -/
theorem slack_of_envelopes (w : Nat → Nat) {den low high err a b l : Nat}
    (positive : 0 < den)
    (lower : ∀ n, low * n ≤ den * total w n + err)
    (upper : ∀ n, den * total w n ≤ high * n + err)
    (margin : high * (a + b) ≤ low * (a + l)) :
    total w a + total w b ≤ total w (a + l) + 3 * err := by
  have gain : 3 * err ≤ den * (3 * err) := by
    simpa using Nat.mul_le_mul_right (3 * err) (show 1 ≤ den by omega)
  apply Nat.le_of_mul_le_mul_left _ positive
  simp only [Nat.mul_add] at margin ⊢
  have first := upper a
  have second := upper b
  have finish := lower (a+l)
  rw [Nat.mul_add] at finish
  omega

/-- In one window, two kinds of mismatch can each occur at most once.
Three trials for a repetition of length a + q + extra therefore suffice,
including when the first successful repetition starts after a mismatch. -/
theorem repeat_in_two_cut_window {α : Type} (c : Nat → α) (label : Nat → Bool)
    (H q extra : Nat) (positive : 0 < q)
    (isolated : ∀ u v, u < v → v < 8*H + 7*(q+extra) →
      c (u+q) ≠ c u → c (v+q) ≠ c v → label u ≠ label v) :
    ∃ a, H ≤ a ∧ 2*a+q+extra ≤ 8*H + 7*(q+extra) ∧
      ∀ s, s < a+q+extra → c (a+s) = c (a+q+s) := by
  classical
  apply Classical.byContradiction
  intro noRepeat
  have bad (a : Nat) (ha : H ≤ a) (aw : 2*a+q+extra ≤ 8*H + 7*(q+extra)) :
      ∃ t, a ≤ t ∧ t < 2*a+q+extra ∧ c (t+q) ≠ c t := by
    apply Classical.byContradiction
    intro noBreak
    apply noRepeat
    refine ⟨a,ha,aw,fun s hs => ?_⟩
    apply Classical.byContradiction
    intro h
    apply noBreak
    refine ⟨a+s,by omega,by omega,fun e => h ?_⟩
    rw [show a+q+s = a+s+q by omega]
    exact e.symm
  obtain ⟨t₀,h₀,b₀,e₀⟩ := bad H (by omega) (by omega)
  obtain ⟨t₁,h₁,b₁,e₁⟩ := bad (t₀+1) (by omega) (by omega)
  obtain ⟨t₂,h₂,b₂,e₂⟩ := bad (t₁+1) (by omega) (by omega)
  have ne₁ := isolated t₀ t₁ (by omega) (by omega) e₀ e₁
  have ne₂ := isolated t₀ t₂ (by omega) (by omega) e₀ e₂
  have ne₃ := isolated t₁ t₂ (by omega) (by omega) e₁ e₂
  cases a : label t₀ <;> cases b : label t₁ <;> cases d : label t₂ <;>
    simp [a,b,d] at ne₁ ne₂ ne₃

/-- The finite-left clock exclusion from repeated letter blocks and their
prefix clock. Both the column and agreement with the blocks can have a transient. -/
theorem no_clock_of_weighted_repeats {α : Type} (c : Nat → α)
    (len : α → Nat) (positive : ∀ v, 1 ≤ len v) (bits : α → Nat → Bool)
    (repeats : ∀ H, ∃ K, ∀ N, ∃ a b l : Nat,
      H ≤ a ∧ a < b ∧ N ≤ b - a ∧
      (∀ s, s < l → c (a+s) = c (b+s)) ∧
      total (fun t => len (c t)) a + total (fun t => len (c t)) b ≤
        total (fun t => len (c t)) (a+l) + K)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reads : ∀ n y, y < len (c n) → cutoff ≤ total (fun t => len (c t)) n + y →
      evol x (start + 2 * (total (fun t => len (c t)) n + y)) (i+1) = bits (c n) y) :
    False := by
  let w := fun t => len (c t)
  have pos : ∀ t, 1 ≤ w t := fun t => positive (c t)
  let sampled := fun t => if evol x (start+2*t) (i+1) then (1 : Int) else 0
  refine no_near_squares x lo i leftBlack leftWhite sampled ?_ start 0 1
    (fun v => decide (v 0 = 1)) ?_ clock ?_
  · intro H
    obtain ⟨K, rep⟩ := repeats (max H cutoff)
    refine ⟨K, fun N => ?_⟩
    obtain ⟨a,b,l,ha,hab,hN,same,slack⟩ := rep (N+1)
    change total w a + total w b ≤ total w (a+l) + K at slack
    have left : a ≤ total w a := by simpa [total] using le_total w pos 0 a
    have dif := le_total w pos a (b-a)
    rw [Nat.add_sub_of_le (Nat.le_of_lt hab)] at dif
    refine ⟨total w a, total w b, by omega, by omega, fun s hs => ?_⟩
    obtain ⟨j,hj,y,hy,offset⟩ := locate w a s l (by omega)
    have wsame (e : Nat) (he : e < l) : w (a+e) = w (b+e) :=
      congrArg len (same e he)
    have hy' : y < w (b+j) := wsame j hj ▸ hy
    have shift := total_shift w a b j (fun e he => wsame e (by omega))
    have offset' : total w b + s = total w (b+j) + y := by omega
    have cut : cutoff ≤ total w a := by omega
    have r₁ := reads (a+j) y hy (show cutoff ≤ total w (a+j) + y by omega)
    have r₂ := reads (b+j) y hy' (show cutoff ≤ total w (b+j) + y by omega)
    change evol x (start+2*(total w (a+j)+y)) (i+1) = _ at r₁
    change evol x (start+2*(total w (b+j)+y)) (i+1) = _ at r₂
    change sampled (total w a + s) = sampled (total w b + s)
    rw [offset, offset']
    simp only [sampled, r₁, r₂, same j hj]
  · intro v v' h
    rw [h 0 (by decide)]
  · intro t
    simp [sampled]

/-- Convert the isolated-cut windows into the physical clock exclusion.
The final inequality in windows pays for the difference between the two
linear envelopes for the block clock. -/
theorem no_clock_of_two_cut_windows {α : Type} (c : Nat → α)
    (len : α → Nat) (positive : ∀ v, 1 ≤ len v) (bits : α → Nat → Bool)
    {den low high err : Nat} (denPos : 0 < den) (slopeOrder : low ≤ high)
    (lower : ∀ n, low*n ≤ den*total (fun t => len (c t)) n + err)
    (upper : ∀ n, den*total (fun t => len (c t)) n ≤ high*n + err)
    (windows : ∀ H N, ∃ q extra : Nat, 0 < q ∧ N ≤ q ∧
      (∃ lab : Nat → Bool, ∀ u v, u < v → v < 8*H + 7*(q+extra) →
        c (u+q) ≠ c u → c (v+q) ≠ c v → lab u ≠ lab v) ∧
      (high-low)*(8*H + 7*(q+extra)) ≤ low*extra)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (c n) → cutoff ≤ total (fun t => len (c t)) n + y →
      evol x (start+2*(total (fun t => len (c t)) n + y)) (i+1) = bits (c n) y) :
    False := by
  apply no_clock_of_weighted_repeats c len positive bits ?_ x lo i leftBlack leftWhite start cutoff clock reads
  intro H
  refine ⟨3*err, fun N => ?_⟩
  obtain ⟨q,extra,hq,hN,⟨lab,iso⟩,gain⟩ := windows H N
  obtain ⟨a,ha,bound,agreement⟩ := repeat_in_two_cut_window c lab H q extra hq iso
  refine ⟨a,a+q,a+q+extra,ha,by omega,by omega,agreement,?_⟩
  apply slack_of_envelopes _ denPos lower upper
  have fits : a+(a+q) ≤ 8*H+7*(q+extra) := by omega
  have penalty := Nat.le_trans (Nat.mul_le_mul_left (high-low) fits) gain
  have split : high * (a+(a+q)) =
      (high-low)*(a+(a+q)) + low*(a+(a+q)) := by
    rw [← Nat.add_mul, Nat.sub_add_cancel slopeOrder]
  calc
    high*(a+(a+q)) ≤ low*(a+(a+q)) + low*extra := by rw [split]; omega
    _ = low*(a+(a+q+extra)) := by rw [← Nat.mul_add, Nat.add_assoc]

/-- Prefix squares of unbounded period survive any positive block lengths.
The available weighted slack after a cutoff H is at most twice its length. -/
theorem prefix_squares_weighted {α : Type} (c : Nat → α) (len : α → Nat)
    (prefixes : ∀ N, ∃ q, N ≤ q ∧ ∀ s, s < q → c s = c (q+s)) (H : Nat) :
    ∃ K, ∀ N, ∃ a b l : Nat, H ≤ a ∧ a < b ∧ N ≤ b-a ∧
      (∀ s, s < l → c (a+s) = c (b+s)) ∧
      total (fun t => len (c t)) a + total (fun t => len (c t)) b ≤
        total (fun t => len (c t)) (a+l) + K := by
  let w := fun t => len (c t)
  refine ⟨2*total w H,fun N => ?_⟩
  obtain ⟨q,large,same⟩ := prefixes (H+N+1)
  refine ⟨H,q+H,q-H,by omega,by omega,by omega,fun s hs => ?_,?_⟩
  · rw [Nat.add_assoc]
    exact same _ (by omega)
  · have shift := total_shift w 0 q H (fun j hj => by simpa [w] using congrArg len (same j (by omega)))
    simp only [Nat.zero_add, total] at shift
    change total w H + total w (q+H) ≤ total w (H+(q-H)) + 2*total w H
    rw [show H+(q-H)=q by omega]
    omega

end WeightedRepeatTransfer
