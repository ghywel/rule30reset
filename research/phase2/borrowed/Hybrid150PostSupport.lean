import Hybrid150Merge

/-! Exact first white checks for infinitely many pairs of merged growing rows.
    A finite certificate gives a spacetime with period 12 in time and a period-9
    spatial tail. The local equation is checked directly in the physical frame. -/
namespace Hybrid150Edge.PostSupport

private def advance (east here : Nat) : Nat :=
  ((here >>> 1) ||| ((here % 2) <<< 11)) ^^^
    (((here ^^^ east) &&& 1365) ||| ((here ^^^ (here &&& east)) &&& 2730))

private def state : Nat → Nat × Nat
  | 0 => (0, 3551)
  | i+1 => let (east, here) := state i; (here, advance east here)

private def index (i : Nat) := if i < 81 then i else 81 + (i-81)%9
private def refRow (t : Nat) : Row := fun i => (state (index i)).2.testBit (t%12)

private theorem index_add (u k : Nat) : index (index u+k) = index (u+k) := by
  by_cases small : u < 81
  · rw [show index u = u by simp [index, small]]
  · have mid : index u = 81+(u-81)%9 := by simp [index, small]
    rw [mid]
    simp only [index, ite_eq_right (by omega : ¬81+(u-81)%9+k < 81), ite_eq_right (by omega : ¬u+k < 81),
      show 81+(u-81)%9+k-81=(u-81)%9+k by omega, show u+k-81=u-81+k by omega, Nat.mod_add_mod]

private theorem read_reduce (t u k : Nat) : refRow (t%12) (index u+k) = refRow t (u+k) := by
  simp [refRow, index_add]

private theorem read_next (t u k : Nat) : refRow (t%12+1) (index u+k) = refRow (t+1) (u+k) := by
  simp only [refRow, index_add, show (t%12+1)%12 = (t+1)%12 by omega]

private theorem table_step : ∀ t : Fin 12, ∀ i : Fin 91,
    refRow (t.val+1) i.val = tick (gate (decide (t.val%2=1))) (refRow t.val) i.val := by
  decide +kernel

private theorem physical_step (t : Nat) : tick (gate (decide (t%2=1))) (refRow t) = refRow (t+1) := by
  funext i
  have p : (t%12)%2 = t%2 := by omega
  cases i with
  | zero =>
    have eq := table_step ⟨t%12, by omega⟩ ⟨0, by decide⟩
    simpa only [tick, east, p, refRow, Nat.mod_mod, show (t%12+1)%12=(t+1)%12 by omega] using eq.symm
  | succ u =>
    have hi : index u + 1 < 91 := by unfold index; split <;> omega
    have eq := table_step ⟨t%12, by omega⟩ ⟨index u+1, hi⟩
    change refRow (t%12+1) (index u+1) =
      xor (refRow (t%12) (index u+2)) (gate (decide ((t%12)%2=1))
        (refRow (t%12) (index u+1)) (refRow (t%12) (index u+0))) at eq
    have near := read_reduce t u 0
    simp only [Nat.add_zero] at near
    simp only [p, read_next, read_reduce, Nat.add_zero, near] at eq
    exact eq.symm

private theorem physical (t k : Nat) :
    clock (decide (t%2=1)) (refRow t) k = refRow (t+k) := by
  induction k generalizing t with
  | zero => rfl
  | succ k ih =>
    have toggle : (!decide (t%2=1)) = decide ((t+1)%2=1) := by
      rcases Nat.mod_two_eq_zero_or_one t with e | o
      · simp [e, show (t+1)%2=1 by omega]
      · simp [o, show (t+1)%2=0 by omega]
    simp only [clock, physical_step, toggle, ih, show t+1+k=t+(k+1) by omega]

private theorem ref_black (r : Nat) : clock false (refRow 0) (2*r) 0 = true := by
  have ev : ∀ j : Fin 6, (3551 : Nat).testBit (2*j.val) = true := by decide +kernel
  have eq := congrFun (physical 0 (2*r)) 0
  change clock false (refRow 0) (2*r) 0 = refRow (0+2*r) 0 at eq
  rw [eq]
  change (3551 : Nat).testBit ((0+2*r)%12) = true
  simpa only [show (0+2*r)%12 = 2*(r%6) by omega] using ev ⟨r%6, by omega⟩

private def crop (w : Nat) : Row := fun i => if i < w then refRow 0 i else false

/-- Widths 92+18n give two distinct locked finite rows with exactly the same
    first failed even check, at physical tick W+2. All checks before it pass. -/
theorem exact_post_support (n : Nat) :
    let w := 92+18*n
    ∃ x y : Row, x ≠ y ∧ Locked x (w-2) ∧ Locked y (w-2) ∧ round x = round y ∧
      (∀ j, 2*j < w+2 → run j x 0 = true ∧ run j y 0 = true) ∧
      run ((w+2)/2) x 0 = false ∧ run ((w+2)/2) y 0 = false := by
  let w := 92+18*n
  let x := crop w
  let y := replace12 159 x
  have tail (k : Nat) : refRow 0 (w-2+k) = refRow 0 (90+k) := by
    have idx : index (w-2+k) = index (90+k) := by
      have lo : ¬w-2+k<81 := by dsimp [w]; omega
      simp only [index, ite_eq_right lo, ite_eq_right (by omega : ¬90+k<81),
        show w-2+k-81=18*n+(9+k) by dsimp [w]; omega, show 90+k-81=9+k by omega]
      rw [Nat.add_mod (18*n) (9+k) 9, Nat.mul_mod 18 n 9]
      simp
    simp only [refRow, idx]
  have word : refRow 0 (w-2) = true ∧ refRow 0 (w-1) = true ∧
      refRow 0 w = false ∧ refRow 0 (w+1) = false ∧ refRow 0 (w+2) = true := by
    have a := tail 0
    have b := tail 1
    have c := tail 2
    have d := tail 3
    have e := tail 4
    have hw : 2 ≤ w := by dsimp [w]; omega
    refine ⟨a.trans (by decide +kernel), ?_, ?_, ?_, ?_⟩
    · simpa only [show w-2+1=w-1 by omega] using b.trans (by decide +kernel : refRow 0 91 = true)
    · simpa only [show w-2+2=w by omega] using c.trans (by decide +kernel : refRow 0 92 = false)
    · simpa only [show w-2+3=w+1 by omega] using d.trans (by decide +kernel : refRow 0 93 = false)
    · simpa only [show w-2+4=w+2 by omega] using e.trans (by decide +kernel : refRow 0 94 = true)
  have hw : 14 ≤ w := by dsimp [w]; omega
  have low (i : Nat) (hi : i < 12) : x i = packed 125 i := by
    have cert : ∀ k : Fin 12, refRow 0 k.val = packed 125 k.val := by decide +kernel
    simpa [x, crop, show i<w by omega] using cert ⟨i, hi⟩
  have repl : replace12 125 x = x := by
    funext i
    by_cases hi : i<12
    · simp [replace12, hi, low i hi]
    · simp [replace12, hi]
  have merged : round x = round y := by simpa only [repl] using merge_125_159 x
  have later (j : Nat) (hj : 0 < j) : run j x = run j y := by
    cases j with
    | zero => omega
    | succ j => simp only [run, merged]
  have locked : Locked x (w-2) := by
    refine ⟨⟨fun i hi => by simp [x, crop, show ¬i<w by omega], ?_⟩, ?_⟩
    · simpa [x, crop, show w-2+1=w-1 by omega, show w-1<w by omega] using word.2.1
    · simpa [x, crop, show w-2<w by omega] using word.1
  have outer (i : Nat) (hi : 12 ≤ i) : y i = x i := by simp [y, replace12, show ¬i<12 by omega]
  have lockedY : Locked y (w-2) := ⟨⟨fun i hi => (outer i (by omega)).trans (locked.1.1 _ hi),
    (outer _ (by omega)).trans locked.1.2⟩, (outer _ (by omega)).trans locked.2⟩
  have ne : x ≠ y := fun eq => by
    have a : x 1 = false := low 1 (by decide)
    have b : y 1 = true := rfl
    rw [eq, b] at a
    contradiction
  have diff := first_difference (w+2) false x (refRow 0) (fun i hi => by
    by_cases inner : i<w
    · simp [x, crop, inner]
    · rcases (by omega : i=w ∨ i=w+1) with rfl | rfl <;> simp [x, crop, word.2.2.1, word.2.2.2.1])
    (by simp [x, crop, word.2.2.2.2])
  refine ⟨x, y, ne, locked, lockedY, merged, ?_, ?_⟩
  · intro j hj
    have black : run j x 0 = true := by simpa only [clock_even] using (diff.1 (2*j) hj).trans (ref_black j)
    refine ⟨black, ?_⟩
    cases j with
    | zero => rfl
    | succ j => rwa [← later (j+1) (by omega)]
  · have even : 2*((w+2)/2)=w+2 := by dsimp [w]; omega
    have fw := diff.2
    rw [← even, ref_black, clock_even] at fw
    have white : run ((w+2)/2) x 0 = false := by
      cases bit : run ((w+2)/2) x 0 with
      | false => rfl
      | true => exact False.elim (fw bit)
    exact ⟨white, by rwa [← later ((w+2)/2) (by omega)]⟩

end Hybrid150Edge.PostSupport
