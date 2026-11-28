module
public import Ruliology.CellularAutomata.Rule30RunTransitionWindows
import all Ruliology.CellularAutomata.Rule30RunTransitionWindows
public import Ruliology.CellularAutomata.Rule30LongRunTails

/-! Exact forcing thresholds for two white ticks and persistence of a black readout. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30DoubleWhiteWindows

open Rule30Jen Rule30Realization Rule30RunTransitions Rule30RunTransitionWindows
open Rule30StripCertificates

def whites (g : Nat) := List.replicate g false

def doublePiece (a r : Nat) := ones a ++ whites 2 ++ ones r

def doubleAge (r : Nat) :=
  if r ≥ 9 then 0 else if r % 2 = 1 then 8 else 16

private theorem up : ∀ i : Fin 8,
    colConst 7 (applyWord 7 (doublePiece (doubleAge (i.val+1)) (i.val+1)) (fullSet 7)) false = true := by
  decide +kernel

theorem double_forces (a r : Nat) (pos : 1 ≤ r) (ha : doubleAge r ≤ a) :
    Force (doublePiece a r) false := by
  by_cases long : 9 ≤ r
  · have split : ones r = ones (r-9) ++ ones 9 := by
      simp only [ones, List.replicate_append_replicate,show r-9+9=r by omega]
    unfold doublePiece
    rw [split,← List.append_assoc]
    exact prefix_irrelevant (from_strip (by decide) long_table) _
  · let i : Fin 8 := ⟨r-1,by omega⟩
    have h := up i
    rw [show i.val+1=r by dsimp [i]; omega] at h
    have split : ones a = ones (a-doubleAge r) ++ ones (doubleAge r) := by
      simp [ones,show a-doubleAge r+doubleAge r=a by omega]
    unfold doublePiece
    rw [split,List.append_assoc,List.append_assoc]
    simpa [doublePiece,List.append_assoc] using prefix_irrelevant (from_strip (by decide) h) (ones (a-doubleAge r))

private def bottom (i : Fin 8) := doublePiece (doubleAge (i.val+1)-1) (i.val+1)
private def seeds (i : Fin 8) : Nat × Nat :=
  [(866,1299),(257556,747461),(4962,3347),(3403284,2844613),(29538,27923),
    (3403284,7038917),(62306,27923),(36957716,7038917)].getD i.val (0,0)
private def witness (i : Fin 8) (b : Bool) := if b then (seeds i).2 else (seeds i).1

private theorem lower_check : ∀ i : Fin 8, ∀ b : Bool,
    witness i b < 2 ^ (1 + (bottom i).length) ∧
    (run (1 + (bottom i).length) (fun t => (bottom i).getD t false)
      (fun _ => false) (witness i b) (bottom i).length).testBit 0 = b := by
  decide +kernel

/-- Realize a tested right-cone reading and clip it to a nonzero finite row. -/
private theorem finite_witness (w : List Bool) (bits : Nat) (b : Bool)
    (bound : bits < 2^(1+w.length))
    (test : (run (1+w.length) (fun t => w.getD t false) (fun _ => false)
      bits w.length).testBit 0 = b) :
    ∃ x : Int → Bool, Rule30PeriodTwoSideways.FinConfig x ∧
      x (-(w.length:Int)-1) = true ∧ (∀ k, k < -(w.length:Int)-1 → x k = false) ∧
      Driven x 0 0 w ∧ evol x w.length 1 = b := by
  let c := fun t => w.getD t false
  let R := fun j : Int => bits.testBit (j-1).toNat
  let y := conf R c
  have realized := realize R c
  have initial (i : Nat) (_ : i < 1+w.length) : bits.testBit i = y ((i:Int)+1) := by
    rw [show y ((i:Int)+1) = R ((i:Int)+1) from realized.1 _ (by omega)]
    simp [R]
  have read := (cone _ c (fun _ => false) bits y bound initial realized.2 w.length 0 (by omega)).symm.trans test
  let lo : Int := -(w.length:Int)-1
  let x : Int → Bool := fun j =>
    if -(w.length:Int) ≤ j ∧ j ≤ (w.length:Int)+1 then y j else decide (j=lo)
  have localEq : ∀ (t : Nat) (j : Int), -(w.length:Int)+t ≤ j → j+t ≤ (w.length:Int)+1 →
      evol x t j = evol y t j :=
    Rule30ZeroBoundaryBarriers.evol_local (by intro j h1 h2; simp [x,h1,h2])
  refine ⟨x,⟨w.length+1,?_⟩,?_,?_,?_,?_⟩
  · intro j hj
    have outside : ¬ (-(w.length:Int) ≤ j ∧ j ≤ (w.length:Int)+1) := by omega
    have ne : j ≠ lo := by dsimp [lo]; omega
    simp [x,outside,ne]
  · have outside : ¬ -(w.length:Int) ≤ lo := by dsimp [lo]; omega
    change x lo = true
    simp [x,outside]
  · intro j hj
    have outside : ¬ -(w.length:Int) ≤ j := by omega
    simp [x,lo,outside,show j ≠ -(w.length:Int)-1 by omega]
  · intro t ht
    rw [Nat.zero_add,localEq _ _ (by omega) (by omega)]
    exact realized.2 t
  · exact (localEq _ _ (by omega) (by omega)).trans (by simpa using read)

theorem double_both_below (a r : Nat) (pos : 1 ≤ r) (ha : a < doubleAge r) (b : Bool) :
    ∃ x : Int → Bool, Rule30PeriodTwoSideways.FinConfig x ∧
      (∃ lo, x lo = true ∧ ∀ k, k < lo → x k = false) ∧
      ∃ s, Driven x 0 s (doublePiece a r) ∧ evol x (s+(doublePiece a r).length) 1 = b := by
  have small : r ≤ 8 := by
    by_cases he : 9 ≤ r
    · simp [doubleAge,he] at ha
    · omega
  let i : Fin 8 := ⟨r-1,by omega⟩
  have hr : i.val+1=r := by dsimp [i]; omega
  have test := lower_check i b
  obtain ⟨x,fin,black,left,drive,read⟩ := finite_witness _ _ _ test.1 test.2
  have split : bottom i = ones (doubleAge r-1-a) ++ doublePiece a r := by
    have ages : ones (doubleAge r-1) = ones (doubleAge r-1-a) ++ ones a := by
      simp [ones,show doubleAge r-1-a+a=doubleAge r-1 by omega]
    simp [bottom,hr,doublePiece,ages,List.append_assoc]
  rw [split] at drive read
  exact ⟨x,fin,⟨_,black,left⟩,_,suffix_drive drive,by simpa using read⟩

theorem exact_double (a r : Nat) (pos : 1 ≤ r) :
    (∃ b, Force (doublePiece a r) b) ↔ doubleAge r ≤ a := by
  constructor
  · rintro ⟨b,f⟩
    apply Classical.byContradiction
    intro h
    obtain ⟨x,_,_,s,drive,reading⟩ := double_both_below a r pos (by omega) (!b)
    have fixed : evol x (s+(doublePiece a r).length) 1 = b := f x 0 _ drive
    rw [fixed] at reading
    cases b <;> contradiction
  · exact fun enough => ⟨false,double_forces a r pos enough⟩

/-- The black reading survives every further white boundary tick. -/
theorem black_through_whites {w : List Bool} (force : Force w true) (g : Nat) :
    Force (w ++ whites g) true := by
  induction g with
  | zero => simpa [whites] using force
  | succ g ih =>
    have split : w ++ whites (g+1) = (w ++ whites g) ++ [false] := by
      unfold whites
      rw [List.append_assoc,← List.replicate_one, List.replicate_append_replicate]
    rw [split]
    intro x j s h
    let t := s+(w++whites g).length
    have right : evol x t (j+1) = true := ih x j s (prefix_drive h)
    have wall : evol x t j = false := by
      have hh := suffix_drive h 0 (by decide)
      simpa [t] using hh
    have step : evol x (t+1) (j+1) =
        rule (evol x t ((j+1)-1)) (evol x t (j+1)) (evol x t ((j+1)+1)) := rfl
    rw [show j+1-1=j by omega,right,wall] at step
    simpa [List.length_append,Nat.add_assoc,t,rule] using step

/-- The key all-length extension of the two-run black windows from S24. -/
theorem black_after_two_runs (a r g : Nat) (cut : age r ≤ a) (hr : r = 2 ∨ r = 4 ∨ r = 6) :
    Force (piece a r ++ whites g) true := by
  apply black_through_whites _ g
  have toneOne : tone r = true := by simp [tone,hr]
  simpa [toneOne] using pair_forces a r (by omega) cut

/-- An arbitrary nonempty white gap after eight blacks selects the white
readout after any odd subsequent black run. -/
theorem odd_after_white_gap (a g n : Nat) (ha : 8 ≤ a) (hg : 1 ≤ g) :
    Force (ones a ++ whites g ++ ones (2*n+1)) false := by
  have first : Force a8 true := from_strip (W:=5) (by decide) (by decide +kernel)
  have hold := black_through_whites first (g-1)
  have block : Force (ones a ++ whites g) true := by
    have rest : [false] ++ whites (g-1) = whites g := by
      simp only [whites,← List.replicate_one,List.replicate_append_replicate,show 1+(g-1)=g by omega]
    have split : ones a = ones (a-8) ++ ones 8 := by
      simp only [ones,List.replicate_append_replicate,show a-8+8=a by omega]
    rw [split,List.append_assoc,← rest,← List.append_assoc]
    simpa only [a8,List.append_assoc] using prefix_irrelevant hold (ones (a-8))
  intro x j s h
  let t := s+(ones a ++ whites g).length
  have black : evol x t (j+1) = true := block x j s (prefix_drive h)
  have result := pp_odd (j:=j) n t (drive_ones (suffix_drive h)) (by simp [black])
  simpa [List.length_append,ones,t,Nat.add_assoc] using result

def period (a r q : Nat) := piece a r ++ whites q

private theorem at_split (u v tail : List Bool) : EndsWith (u++v++tail) (u.length+v.length) v := by
  intro k hk
  have lt : u.length+k < (u++v++tail).length := by simp; omega
  unfold cyc
  rw [show u.length+v.length+v.length*(u++v++tail).length-v.length+k =
      u.length+k+v.length*(u++v++tail).length by omega,
      Nat.add_mul_mod_self_right,Nat.mod_eq_of_lt lt]
  simp only [List.getD_eq_getElem?_getD,List.getElem?_append_left (show u.length+k < (u++v).length by simp; omega),
    List.getElem?_append_right (show u.length ≤ u.length+k by omega),Nat.add_sub_cancel_left]

/-- Every column of a leftmost-black row excludes a periodic pair of
unequal black runs with a singleton white gap and an arbitrary final gap. -/
theorem excludes_period (a r q : Nat) (ha : 9 ≤ a) (cut : age r ≤ a)
    (hr : r = 2 ∨ r = 4 ∨ r = 6)
    {x : Int → Bool} {lo : Int} (black : x lo = true) (left : ∀ k, k < lo → x k = false)
    (i : Int) : ¬ Rule30FiniteStrips.EventuallyWord x i (period a r q) := by
  let w := period a r q
  have wLength : w.length = a+1+r+q := by simp [w,period,piece,whites,ones]; omega
  apply exclude_of_windows (w:=w) (by intro e; simp [e] at wLength; omega) (B:=w.length) _ black left i
  intro j lt white
  by_cases low : j < a
  · have atBlack : w.getD j false = true := by
      unfold w period piece
      rw [List.append_assoc,List.append_assoc,List.getD_eq_getElem?_getD,
        List.getElem?_append_left (by simpa [ones] using low)]
      simp [ones,low]
    exact Bool.noConfusion (white.symm.trans atBlack)
  by_cases start : j = a
  · subst j
    have split : ones a = ones (a-9) ++ ones 9 := by
      simp only [ones,List.replicate_append_replicate,show a-9+9=a by omega]
    have hw : w = ones (a-9) ++ ones 9 ++ ([false] ++ ones r ++ whites q) := by
      simpa [w,period,piece,List.append_assoc] using congrArg (fun u => u ++ ([false] ++ ones r ++ whites q)) split
    refine ⟨ones 9,false,?_,by simp [ones]; omega,from_strip (by decide) long_table⟩
    have e : (ones (a-9)).length + (ones 9).length = a := by simp [ones]; omega
    rw [hw]
    simpa only [e] using at_split (ones (a-9)) (ones 9) ([false] ++ ones r ++ whites q)
  have endRun : a+1+r ≤ j := by
    apply Classical.byContradiction
    intro h
    have atBlack : w.getD j false = true := by
      unfold w period piece
      rw [List.append_assoc,List.append_assoc,← List.append_assoc [false],
        List.getD_eq_getElem?_getD,List.getElem?_append_right (by simp [ones]; omega)]
      have j0 : j-(ones a).length = 1+(j-(a+1)) := by simp [ones]; omega
      rw [j0,List.append_assoc,Nat.add_comm 1 (j-(a+1))]
      change (ones r ++ whites q)[j-(a+1)]?.getD false = true
      rw [List.getElem?_append_left (by simp [ones]; omega)]
      simp [ones, show j-(a+1)<r by omega]
    exact Bool.noConfusion (white.symm.trans atBlack)
  let g := j-(a+1+r)
  have hg : g ≤ q := by dsimp [g]; omega
  have split : whites q = whites g ++ whites (q-g) := by
    simp only [whites,List.replicate_append_replicate,show g+(q-g)=q by omega]
  have e : w = [] ++ (piece a r ++ whites g) ++ whites (q-g) := by
    change piece a r ++ whites q = _
    rw [split]
    simp [List.append_assoc]
  refine ⟨piece a r ++ whites g,true,?_,by simp [piece,ones,whites]; dsimp [g]; omega,
    black_after_two_runs a r g cut hr⟩
  rw [e,show j = ([] : List Bool).length + (piece a r ++ whites g).length by
    simp [piece,ones,whites]; dsimp [g]; omega]
  exact at_split _ _ _

/-- The published five-cell tail test rejects the first post-short-run
white letter, even if the opening black run is lengthened. -/
theorem five_cell_misses (a r : Nat) (long : 10 ≤ a) (hr : r = 4 ∨ r = 6) :
    Rule30LongRunTails.tailOK 5 (Rule30LongRunTails.longSet 5 a) ([false] ++ ones r ++ [false]) = false := by
  have fixed := (Rule30LongRunTails.longSet5_ten_stabilizes (a-10)).2
  rw [show 10+(a-10)=a by omega] at fixed
  rw [fixed]
  rcases hr with h | h <;> subst r <;> decide +kernel

/-- Two primitive examples with a white phase missed by S24's original menu. -/
theorem two_separating_periods : ¬ Combined (period 15 4 2) ∧ ¬ Combined (period 16 6 2) := by
  decide +kernel

end Ruliology.CellularAutomata.Rule30DoubleWhiteWindows
