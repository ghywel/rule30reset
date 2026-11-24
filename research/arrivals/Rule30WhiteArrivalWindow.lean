import Ruliology.CellularAutomata.Rule30SourceArrivals
import Ruliology.CellularAutomata.Rule30PeriodTwoWidth13

/-! A window of nine white-tick source parities. Bit zero of a strip row is
the cell immediately to the right of the centre. Each edge has two free
eastern inputs. The final four samples constrain the continuation in GE2. -/
namespace Ruliology.CellularAutomata.Rule30WhiteArrivalWindow

open Rule30Jen Rule30SourceArrivals
open Rule30PeriodTwoWidth13 (delta)

abbrev Row := BitVec 6

def pack (a b c d e f : Bool) : Row :=
  BitVec.ofBool f ++ BitVec.ofBool e ++ BitVec.ofBool d ++
  BitVec.ofBool c ++ BitVec.ofBool b ++ BitVec.ofBool a

def row (t : Nat) : Row :=
  pack (cell t 1) (cell t 2) (cell t 3) (cell t 4) (cell t 5) (cell t 6)

def gate (r : Row) := r.getLsbD 0
def reading (r : Row) := xor (gate r) (r.getLsbD 1)

def tick (r : Row) (wall east : Bool) : Row :=
  ((r <<< 1) ||| (BitVec.ofBool wall).zeroExtend 6) ^^^
    (r ||| (r >>> 1) ||| ((BitVec.ofBool east).zeroExtend 6 <<< 5))

private theorem tick_pack (a b c d e f l h : Bool) :
    tick (pack a b c d e f) l h =
      pack (rule l a b) (rule a b c) (rule b c d) (rule c d e) (rule d e f) (rule e f h) := by
  revert a b c d e f l h
  decide +kernel

theorem physical_tick (t : Nat) : row (t+1) = tick (row t) (cell t 0) (cell t 7) :=
  (tick_pack ..).symm

private theorem read_pack (a b c d e f : Bool) :
    gate (pack a b c d e f) = a ∧ reading (pack a b c d e f) = xor a b := by
  revert a b c d e f
  decide +kernel

theorem physical_gate (t : Nat) : gate (row t) = cell t 1 := (read_pack ..).1

theorem physical_reading (t : Nat) (w : cell t 0 = false) (b : cell (t+1) 0 = true) :
    reading (row t) = net t := by
  have eq : ∀ l c x y : Bool, c = false → rule l c x = true →
      xor x y = xor (l && !c) (xor (x && !y) (rule l c x && !rule c x y)) := by decide
  rw [show reading (row t) = xor (cell t 1) (cell t 2) from (read_pack ..).2]
  change xor (cell t 1) (cell t 2) = xor (cell t (-1) && !cell t 0)
    (xor (cell t 1 && !cell t 2) (rule (cell t (-1)) (cell t 0) (cell t 1) &&
      !rule (cell t 0) (cell t 1) (cell t 2)))
  apply eq _ _ _ _ w
  exact b

def edge (a b : Row) : Bool :=
  [false,true].any fun x => [false,true].any fun y => tick (tick a false x) true y == b

theorem physical_edge (t : Nat) (w : cell t 0 = false) (b : cell (t+1) 0 = true) :
    edge (row t) (row (t+2)) = true := by
  rw [show t+2=t+1+1 by omega, physical_tick (t+1), physical_tick t, w, b]
  cases cell t 7 <;> cases cell (t+1) 7 <;> simp [edge]

def readsWord (f : Nat → Bool) (s : Nat) : List Bool → Bool
  | [] => true
  | x :: rest => (f s == x) && readsWord f (s+1) rest

-- Digits in these lists are in reading order, from the earliest sample.
def digits (s : String) : List Bool := s.toList.map (· == '1')

def banned : List (List Bool) :=
  ["11","00000","101001","100101","10010001","1000101","10001001",
   "100010001","1000010001"].map digits

def clean (g : Nat → Bool) (n : Nat) : Bool :=
  banned.all fun w => (List.range (n+1-w.length)).all fun i => !readsWord g i w

def decode (f : Nat → Bool) : Bool :=
  ["001010010","001010100","001010101","010010010","101010010","101010101"].any
    fun s => readsWord f 0 (digits s)

def validEdges (r : Nat → Row) (n : Nat) : Bool :=
  (List.range n).all fun i => edge (r i) (r (i+1))

private def children (r : Row) : List Row :=
  [false,true].flatMap fun x => [false,true].map fun y => tick (tick r false x) true y

private def advance (rows : List Row) := (rows.flatMap children).eraseDups

private theorem child_of_edge {x y : Row} (step : edge x y = true) : y ∈ children x := by
  simp [edge] at step
  rcases step with (h|h)|(h|h) <;> subst y <;> simp [children]

private def allRows := (List.range 64).map (BitVec.ofNat 6)

private theorem has_row (x : Row) : x ∈ allRows :=
  List.mem_map.mpr ⟨x.toNat, List.mem_range.mpr x.isLt, by simp⟩

/-- Follow both possible source readings for this gate word. Each branch
carries the set of six-cell rows still possible; equal rows are merged. -/
private def inspect (gs : List Bool) (rows : List Row) (history : List Bool)
    (test : List Bool → Bool) : Bool :=
  match gs with
  | [] => test history
  | g :: tail => [false,true].all fun a =>
    let same := rows.filter (fun x => (gate x == g) && (reading x == a))
    same.isEmpty || inspect tail (advance same) (history ++ [a]) test

private def samples (f : Nat → Bool) (n : Nat) : List Bool :=
  List.ofFn (fun i : Fin n => f i.val)

private theorem samples_succ (f : Nat → Bool) (n : Nat) :
    samples f (n+1) = f 0 :: samples (fun i => f (i+1)) n := by
  simp [samples, List.ofFn_succ]

private theorem get_sample (f : Nat → Bool) {n i : Nat} (h : i<n) :
    (samples f n).getD i false = f i := by
  simp [samples, List.getD_eq_getElem?_getD, h]

private theorem inspect_sound (r : Nat → Row) (n : Nat) (rows : List Row) (h : List Bool)
    (test : List Bool → Bool) (start : 0<n → r 0 ∈ rows)
    (edges : ∀ i, i+1<n → edge (r i) (r (i+1)) = true)
    (all : inspect (samples (fun i => gate (r i)) n) rows h test = true) :
    test (h ++ samples (fun i => reading (r i)) n) = true := by
  induction n generalizing r rows h with
  | zero => simpa [inspect, samples] using all
  | succ n ih =>
    rw [samples_succ, inspect] at all
    let a := reading (r 0)
    have chosen := List.all_eq_true.mp all a (by cases a <;> simp)
    let same := rows.filter (fun x => (gate x == gate (r 0)) && (reading x == a))
    have mem : r 0 ∈ same := List.mem_filter.mpr ⟨start (by omega), by simp [a]⟩
    have nonempty : same.isEmpty = false := List.isEmpty_eq_false_iff.mpr (List.ne_nil_of_mem mem)
    change same.isEmpty || inspect _ (advance same) _ test = true at chosen
    rw [nonempty, Bool.false_or] at chosen
    have later : 0<n → r 1 ∈ advance same := by
      intro pos
      apply List.mem_eraseDups.mpr
      exact List.mem_flatMap.mpr ⟨_,mem,child_of_edge (edges 0 (by omega))⟩
    have result := ih (fun i => r (i+1)) (advance same) (h++[a]) later
      (fun i hi => edges (i+1) (by omega)) chosen
    simpa [samples_succ, a, List.append_assoc] using result

private def agrees (gs obs : List Bool) : Bool :=
  gs.getD 6 false == decode (fun i => obs.getD i false)

private def grade (gs : List Bool) : Bool :=
  !clean (fun i => gs.getD i false) 13 || inspect gs allRows [] (agrees gs)

set_option maxRecDepth 16000 in
set_option maxHeartbeats 0 in
private theorem exhaustive : (allLists 13).all grade = true := by decide +kernel

private theorem reads_ext {f h : Nat → Bool} (i : Nat) (w : List Bool)
    (eq : ∀ j, i ≤ j → j<i+w.length → f j = h j) :
    readsWord f i w = readsWord h i w := by
  induction w generalizing i with
  | nil => rfl
  | cons b w ih =>
    simp only [readsWord, eq i (by omega) (by simp)]
    rw [ih (i+1) (fun j hj hl => eq j (by omega) (by simp; omega))]

private theorem all_mem {α : Type} {p q : α → Bool} (l : List α)
    (agree : ∀ x ∈ l, p x = q x) : l.all p = l.all q := by
  induction l with
  | nil => rfl
  | cons x l ih =>
    simp only [List.all_cons, agree x (List.mem_cons_self ..),
      ih (fun y hy => agree y (List.mem_cons_of_mem x hy))]

private theorem any_mem {α : Type} {p q : α → Bool} (l : List α)
    (agree : ∀ x ∈ l, p x = q x) : l.any p = l.any q := by
  induction l with
  | nil => rfl
  | cons x l ih =>
    simp only [List.any_cons, agree x (List.mem_cons_self ..),
      ih (fun y hy => agree y (List.mem_cons_of_mem x hy))]

private theorem clean_ext {f h : Nat → Bool} (n : Nat) (eq : ∀ i, i<n → f i = h i) :
    clean f n = clean h n := by
  unfold clean
  apply all_mem
  intro w _
  apply all_mem
  intro i hi
  have bound := List.mem_range.mp hi
  rw [reads_ext i w (fun j _ hj => eq j (by omega))]

private theorem decode_ext {f h : Nat → Bool} (eq : ∀ i, i<9 → f i=h i) :
    decode f = decode h := by
  unfold decode
  apply any_mem
  intro s hs
  have len : (digits s).length = 9 := by
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hs
    rcases hs with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  rw [reads_ext 0 _ (fun j _ hj => eq j (by omega))]

/-- The gate at index six is determined by the nine observed parities in
indices zero through eight, on any six-cell strip admitting the four further
white samples in the finite GE2 factor test. -/
theorem window (r : Nat → Row) (edges : validEdges r 12 = true)
    (ge : clean (fun i => gate (r i)) 13 = true) :
    gate (r 6) = decode (fun i => reading (r i)) := by
  let gs := samples (fun i => gate (r i)) 13
  have len : gs.length=13 := by simp [gs,samples]
  have possible := List.all_eq_true.mp exhaustive gs (len ▸ mem_allLists gs)
  have cl : clean (fun i => gs.getD i false) 13 = true :=
    (clean_ext 13 (fun i hi => get_sample _ hi)).trans ge
  simp only [grade, cl, Bool.not_true, Bool.false_or] at possible
  have eq := inspect_sound r 13 allRows [] (agrees gs) (fun _ => has_row _)
    (fun i hi => List.all_eq_true.mp edges i (List.mem_range.mpr (by omega))) possible
  have hit := get_sample (fun i => gate (r i)) (n:=13) (i:=6) (by decide)
  simpa only [List.nil_append, agrees, beq_iff_eq, gs, hit,
    decode_ext (f := fun i => (samples (fun j => reading (r j)) 13).getD i false)
      (fun i hi => get_sample _ (by omega))] using eq

end Ruliology.CellularAutomata.Rule30WhiteArrivalWindow
