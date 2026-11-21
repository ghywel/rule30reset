module
public import Rule30ArrivalMemory

/-! Finite-memory observations and the moving left edge. Lowry's PR 379
uses a finite form of Jen's argument for the masked right column. Here the
right column is reconstructed from an observed channel and h unknown bits. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30ArrivalMemory

open Rule30Jen

/-- The later left edge distinguishes two matched adjacent-column blocks
once the reconstructed triangle reaches it. Time zero is allowed. -/
theorem adjacent_match_bound {a b n : Nat} (lt : a<b)
    (cc : Match center a b (n+1)) (rr : Match right a b n) : n<b := by
  have triangle (d : Nat) :
      (∀ k, k+d≤n → cell (a+k) (-(d:Int))=cell (b+k) (-(d:Int))) ∧
      (∀ k, k+d<n → cell (a+k) (-(d:Int)+1)=cell (b+k) (-(d:Int)+1)) := by
    induction d with
    | zero => exact ⟨fun k hk => by simpa using cc k (by omega),
                     fun k hk => by simpa using rr k (by omega)⟩
    | succ d ih =>
      constructor
      · intro k hk
        rw [show -((d+1:Nat):Int) = -(d:Int)-1 by omega,
          cell_left (a+k) (-(d:Int)),cell_left (b+k) (-(d:Int))]
        rw [Nat.add_assoc, Nat.add_assoc, ih.1 (k+1) (by omega),
          ih.1 k (by omega), ih.2 k (by omega)]
      · intro k hk
        rw [show -((d+1:Nat):Int)+1 = -(d:Int) by omega]
        exact ih.1 k (by omega)
  apply Classical.byContradiction
  intro fail
  have agree := (triangle b).1 0 (by omega)
  simp only [Nat.add_zero] at agree
  rw [cell_eq_false_of_lt a _ (by omega),cell_left_edge b] at agree
  contradiction

/-- Given one fixed initial memory state, n matched observations using n+1
center bits can extend only to n < b, the later absolute start. -/
theorem repeat_bound {h a b n : Nat} {allow : Nat → Prop} {obs : Nat → Bool}
    (law : MemoryLaw h allow obs) (lt : a<b)
    (ok : ∀ s, s+h<n → allow (a+s))
    (cc : Match center a b (n+1)) (zz : Match obs a b n)
    (seed : Match right a b h) : n<b :=
  adjacent_match_bound lt cc (recover_block law ok cc zz seed)

/-- Among 2^h+1 occurrences of a common observed block, at least one later
start exceeds its length. The nondecreasing bound is in absolute singleton
ticks. Neither the center nor the observed channel need be periodic. -/
theorem many_repeats_bound {h n : Nat} {allow : Nat → Prop} {obs : Nat → Bool}
    (law : MemoryLaw h allow obs) (start : Nat → Nat) (incr : ∀ {i j}, i<j → start i < start j)
    (ok : ∀ i, i≤2^h → ∀ s, s+h<n → allow (start i+s))
    (cc : ∀ i j, i<j → j≤2^h → Match center (start i) (start j) (n+1))
    (zz : ∀ i j, i<j → j≤2^h → Match obs (start i) (start j) n) :
    n < start (2^h) := by
  let block (i : Nat) := (List.range h).map fun k => right (start i+k)
  obtain ⟨i,j,lt,jb,seeds⟩ := pigeonhole h block (fun k => by simp [block])
  have seed : Match right (start i) (start j) h := by
    intro k hk
    have e := congrArg (fun xs : List Bool => xs[k]?) seeds
    simpa [block,List.getElem?_map,List.getElem?_range,hk] using e
  exact Nat.lt_of_lt_of_le (repeat_bound law (incr lt) (ok i (by omega))
    (cc i j lt jb) (zz i j lt jb) seed) (by
      by_cases e : j=2^h
      · exact Nat.le_of_eq (congrArg start e)
      · exact Nat.le_of_lt (incr (by omega)))

end Ruliology.CellularAutomata.Rule30ArrivalMemory
