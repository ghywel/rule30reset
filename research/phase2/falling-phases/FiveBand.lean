import Ruliology.CellularAutomata.Rule30Prize

/-! Two quiet ticks on five adjacent columns prevent a new white observation
at either of two interior sites unless that site was white throughout the
preceding three-tick block. Chaining backward gives a single white column. -/
namespace PhaseFalls.FiveBand
open Ruliology.CellularAutomata.Rule30Jen

private def cone (f : Nat → Bool) : Nat → Nat → Bool
  | 0, j => f j
  | n+1, j => rule (cone f n j) (cone f n (j+1)) (cone f n (j+2))

private theorem cone_cell (j : Int) (t n k : Nat) :
    cone (fun l : Nat => cell t (j+l)) n k = cell (t+n) (j+k+n) := by
  induction n generalizing k with
  | zero => simp [cone]
  | succ n ih =>
    simp only [cone, ih, cell]
    congr 1 <;> congr 1 <;> omega

private def up (a b : Bool) := !a || b

/-- Enumerate the nine input cells from j−2 through j+6. At offsets 2 and 3
inside the five-column strip, a white terminal value forces a white block. -/
private theorem table (f : Nat → Bool)
    (quiet : ∀ n : Nat, n < 2 → ∀ k : Nat, k < 5 →
      up (cone f n (2+k-n)) (cone f (n+1) (2+k-(n+1))) = true) :
    ∀ i : Nat, i=2 ∨ i=3 → cone f 3 (2+i-3)=false →
      ∀ n : Nat, n ≤ 3 → cone f n (2+i-n)=false := by
  have ten : ([0,1] : List Nat).all (fun n => ([0,1,2,3,4] : List Nat).all
      (fun k => up (cone f n (2+k-n)) (cone f (n+1) (2+k-(n+1))))) = true := by
    apply List.all_eq_true.mpr
    intro n hn
    apply List.all_eq_true.mpr
    intro k hk
    simp at hn hk
    exact quiet n (by omega) k (by omega)
  simp only [List.all_cons, List.all_nil, Bool.and_true] at ten
  clear quiet
  intro i hi
  rcases hi with rfl | rfl <;>
    simp only [cone, Nat.reduceSub, Nat.reduceAdd] at ten ⊢ <;>
    intro terminal n bound <;>
    rcases (show n=0 ∨ n=1 ∨ n=2 ∨ n=3 by omega) with rfl | rfl | rfl | rfl <;>
    simp only [cone, Nat.reduceSub, Nat.reduceAdd] at * <;>
    generalize f 0 = a, f 1 = b, f 2 = c, f 3 = d, f 4 = e, f 5 = g,
      f 6 = h, f 7 = p, f 8 = q at * <;> clear f <;>
    revert a b c d e g h p q <;> decide +kernel

theorem white_block (t : Nat) (j : Int)
    (quiet : ∀ n : Nat, n < 2 → ∀ k : Nat, k < 5 →
      ¬ (cell (t+n) (j+k)=true ∧ cell (t+n+1) (j+k)=false)) :
    ∀ i : Nat, i=2 ∨ i=3 → cell (t+3) (j+i)=false →
      ∀ n : Nat, n ≤ 3 → cell (t+n) (j+i)=false := by
  let f (l : Nat) := cell t ((j-2)+l)
  have matchCell (n k : Nat) (hk : n ≤ 2+k) :
      cone f n (2+k-n)=cell (t+n) (j+k) := by
    dsimp [f]
    rw [cone_cell]
    congr 1
    omega
  intro i hi last n hn
  have qs (m : Nat) (hm : m < 2) (k : Nat) (hk : k < 5) :
      up (cone f m (2+k-m)) (cone f (m+1) (2+k-(m+1))) = true := by
    rw [matchCell _ _ (by omega), matchCell _ _ (by omega)]
    have h := quiet m hm k hk
    change ¬ (cell (t+m) (j+k)=true ∧ cell (t+(m+1)) (j+k)=false) at h
    cases a : cell (t+m) (j+k) <;> cases b : cell (t+(m+1)) (j+k) <;> simp_all [up]
  have finalCell := (matchCell 3 i (by omega)).trans last
  exact (matchCell n i (by omega)).symm.trans (table f qs i hi finalCell n hn)

/-- The two middle candidates are j+2 and j+3. If the final sample has no
fall at its latter site, at least one of them was white over the entire run. -/
theorem white_column (s N : Nat) (j : Int)
    (quiet : ∀ k, k < N → ∀ n : Nat, n < 2 → ∀ i : Nat, i < 5 →
        ¬ (cell (s+3*k+n) (j+i)=true ∧ cell (s+3*k+n+1) (j+i)=false))
    (last : ¬ (cell (s+3*N) (j+3)=true ∧ cell (s+3*N+1) (j+3)=false)) :
    ∃ i : Nat, (i=2 ∨ i=3) ∧ ∀ k, k ≤ 3*N → cell (s+k) (j+i)=false := by
  have white : cell (s+3*N) (j+2)=false ∨ cell (s+3*N) (j+3)=false := by
    cases h2 : cell (s+3*N) (j+2) <;> cases h3 : cell (s+3*N) (j+3) <;>
      simp_all [cell, rule, show j+3-1=j+2 by omega]
  obtain ⟨i,hi,tail⟩ : ∃ i : Nat, (i=2 ∨ i=3) ∧ cell (s+3*N) (j+i)=false := by
    rcases white with h | h
    · exact ⟨2, Or.inl rfl, h⟩
    · exact ⟨3, Or.inr rfl, h⟩
  refine ⟨i,hi,?_⟩
  clear last white
  induction N with
  | zero => simpa using tail
  | succ N ih =>
    have block := white_block (s+3*N) j (quiet N (by omega)) i hi
      (by simpa only [show s+3*N+3=s+3*(N+1) by omega] using tail)
    have prev := ih (fun k hk => quiet k (by omega)) (by simpa using block 0 (by decide))
    intro k bound
    by_cases inPrefix : k ≤ 3*N
    · exact prev k inPrefix
    · simpa only [show s+3*N+(k-3*N)=s+k by omega] using block (k-3*N) (by omega)

/-- Any two black observations at the two interior sites, at possibly different
times in the interval, witness failure of the proposed shared falling phase. -/
theorem escape_of_hits (s N p q : Nat) (j : Int) (hp : p ≤ 3*N) (hq : q ≤ 3*N)
    (black₂ : cell (s+p) (j+2)=true) (black₃ : cell (s+q) (j+3)=true) :
    ∃ t : Nat, ∃ i : Nat, t ≤ 3*N ∧ t%3 ≠ 2 ∧ i<5 ∧
      cell (s+t) (j+i)=true ∧ cell (s+t+1) (j+i)=false := by
  apply Classical.byContradiction
  intro none
  have quiet (k : Nat) (hk : k < N) (n : Nat) (hn : n<2) (i : Nat) (hi : i<5) :
      ¬ (cell (s+3*k+n) (j+i)=true ∧ cell (s+3*k+n+1) (j+i)=false) := by
    intro pair
    exact none ⟨3*k+n,i,by omega,by omega,hi,by simpa [Nat.add_assoc] using pair⟩
  have last : ¬ (cell (s+3*N) (j+3)=true ∧ cell (s+3*N+1) (j+3)=false) := by
    intro pair
    exact none ⟨3*N,3,by omega,by omega,by decide,pair⟩
  obtain ⟨i,hi,off⟩ := white_column s N j quiet last
  rcases hi with rfl | rfl
  · exact Bool.noConfusion ((off p hp).symm.trans black₂)
  · exact Bool.noConfusion ((off q hq).symm.trans black₃)

/-- In every tail, any prescribed pair of consecutive time residues contains
a fall in any fixed band of five singleton columns. -/
theorem escape_on_tail (s : Nat) (j : Int) :
    ∃ t : Nat, ∃ i : Nat, t%3 ≠ 2 ∧ i<5 ∧
      cell (s+t) (j+i)=true ∧ cell (s+t+1) (j+i)=false := by
  have hit (x : Int) : ∃ n, cell (s+n) x = true := by
    apply Classical.byContradiction
    intro none
    apply Ruliology.CellularAutomata.Rule30Prize.no_column_eventually_constant x
    refine ⟨s,false,fun t ht => ?_⟩
    cases h : cell t x with
    | false => rfl
    | true => exact (none ⟨t-s, by simpa only [show s+(t-s)=t by omega] using h⟩).elim
  obtain ⟨p,hp⟩ := hit (j+2)
  obtain ⟨q,hq⟩ := hit (j+3)
  obtain ⟨t,i,_,phase,inside,down⟩ := escape_of_hits s (p+q) p q j (by omega) (by omega) hp hq
  exact ⟨t,i,phase,inside,down⟩

end PhaseFalls.FiveBand
