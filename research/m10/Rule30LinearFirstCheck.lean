import Ruliology.CellularAutomata.Rule30FirstCheckDegree
import Ruliology.CellularAutomata.Rule30HybridWall
import Ruliology.CellularAutomata.Rule30WallDeadlines

/-! Physical first checks for the three linear controls, with black even wall observations. -/
namespace Rule30LinearFirstCheck

open Ruliology.CellularAutomata
open Rule30WallDeadlines Rule30HybridWall
open Rule30ZeroBoundary (alt)

/-- The rule 90 physical first check is independent of the odd wall observations. -/
theorem check90 {x : Row} (n : Nat)
    (trace : ∀ s, 2*s ≤ 2*n → zr h90 x (2*s) 1 = true) :
    x (2*n+1) = decide ((2*n+1) % 3 ≠ 0) :=
  (odd90 trace (2*n+1) 0 (by omega) (by omega)).trans (fib2_mod _)

/-- The rule 150 physical first check is always black. -/
theorem check150 {x : Row} (n : Nat)
    (trace : ∀ s, 2*s ≤ 2*n → zr h150 x (2*s) 1 = true) : x (2*n+1) = true :=
  odd150 trace n 0 (by omega)

/-- Reconstruct the hybrid's spacetime from the wall trace `a`, depth first. -/
def restore (a : Row) : Nat → Nat → Bool
  | 0, _ => false
  | 1, t => a t
  | k+2, t => xor (restore a (k+1) (t+1))
      (xor (restore a k t) (if (k+1)%2 = 1 then restore a (k+1) t else false))

private theorem step_restore (a : Row) (t : Nat) :
    H (fun k => restore a k t) = fun k => restore a k (t+1) := by
  rw [← HE_of_wall (x := fun k => restore a k t) rfl]
  funext k
  cases k with
  | zero => rfl
  | succ k =>
    change xor (restore a k t)
      (xor (restore a (k+2) t) (if (k+1)%2 = 1 then restore a (k+1) t else false)) = _
    rw [restore]
    generalize restore a k t = p
    generalize restore a (k+1) (t+1) = q
    generalize (if (k+1)%2 = 1 then restore a (k+1) t else false) = r
    cases p <;> cases q <;> cases r <;> rfl

theorem trace_restore (a : Row) (t : Nat) : col (fun k => restore a k 0) t = a t := by
  have orbit : ∀ s, iter H s (fun k => restore a k 0) = fun k => restore a k s := by
    intro s
    induction s with
    | zero => rfl
    | succ s ih => rw [iter_add H s 1, ih]; exact step_restore a s
  exact congrFun (orbit t) 1

private theorem agree_of_trace {x y : Row} (h : ∀ t, col x t = col y t)
    {k : Nat} (hk : 1 ≤ k) : x k = y k := by
  have zero : ∀ t, col (xorS x y) t = false := fun t => by rw [col_xor, h, Bool.xor_self]
  exact eq_of_xor_false (col_inj _ zero k hk)

/-- The main phase fixes the even wall observations and freely specifies the odd ones. -/
def hybridCheck (n : Nat) (f : Row) : Bool := restore (alt f) (2*n+1) 0

theorem check_from_trace (n : Nat) {x f : Row} (h : ∀ t, col x t = alt f t) :
    hybridCheck n f = x (2*n+1) :=
  agree_of_trace (x := fun k => restore (alt f) k 0)
    (fun t => (trace_restore _ t).trans (h t).symm) (by omega)

private theorem restore_cone {a b : Row} : ∀ k t, (∀ s, s < k+t → a s = b s) →
    restore a k t = restore b k t
  | 0, _, _ => rfl
  | 1, t, h => h t (by omega)
  | k+2, t, h => by
    rw [restore, restore, restore_cone (k+1) (t+1) (fun s hs => h s (by omega)),
      restore_cone k t (fun s hs => h s (by omega)),
      restore_cone (k+1) t (fun s hs => h s (by omega))]

/-- Agreement on the first n free bits suffices for agreement at depth 2n+1. -/
theorem check_congr (n : Nat) {f g : Row} (h : ∀ s, s < n → f s = g s) :
    hybridCheck n f = hybridCheck n g := by
  apply restore_cone
  intro t ht
  unfold alt
  split
  · rfl
  · exact h _ (by omega)

/-- Affine maps over GF(2) preserve ternary sums. -/
theorem check_affine (n : Nat) (f g h : Row) :
    hybridCheck n (xorS (xorS f g) h) =
      xor (xor (hybridCheck n f) (hybridCheck n g)) (hybridCheck n h) := by
  apply check_from_trace (x := xorS (xorS (fun k => restore (alt f) k 0)
    (fun k => restore (alt g) k 0)) (fun k => restore (alt h) k 0))
  intro t
  rw [col_xor, col_xor, trace_restore, trace_restore, trace_restore]
  unfold alt xorS
  split <;> rfl

/-- Each output colour is realized by a finite immortal row in the kit's parameter family. -/
theorem check_both (n : Nat) (hn : 1 ≤ n) (b : Bool) :
    ∃ x f : Row, WidthLE (4*n+6) x ∧ Immortal x ∧
      (∀ t, col x t = alt f t) ∧ hybridCheck n f = b := by
  let j := (n-1)/2
  let v : Row := fun i => if i = 2*j+1 then b else false
  let x := paramRow v
  have finiteV : Supp ((4*n+6)/2-1) v := by
    intro i hi
    have h : i ≠ 2*j+1 := by dsimp [j]; omega
    simp [v, h]
  have finite : WidthLE (4*n+6) x := paramRow_width (by omega) finiteV
  have wall : x 0 = false := rfl
  have immortal := (immortal_iff_param (by omega : 2 ≤ 4*n+6) finite wall).2 ⟨v, finiteV, rfl⟩
  let f : Row := fun s => col x (2*s+1)
  have trace : ∀ t, col x t = alt f t := by
    intro t
    unfold alt
    split
    · rename_i even
      simpa only [show 2*(t/2) = t by omega] using immortal (t/2)
    · dsimp [f]; congr 1; omega
  have atFive : x (4*j+5) = b := by
    rw [show 4*j+5 = 4*(j+1)+1 by omega]
    exact (paramRow_odd v j).trans (by simp [v])
  have bitFam := (immortal_iff_bitFam finite wall).mp immortal
  have k : 2*n+1 = 4*j+3 ∨ 2*n+1 = 4*j+5 := by dsimp [j]; omega
  refine ⟨x, f, finite, immortal, trace, (check_from_trace n trace).trans ?_⟩
  rcases k with first | second
  · rw [first, (bitFam.2 j).1, atFive]
  · rw [second, atFive]

open Rule30FirstChecks (word)
open Rule30FirstCheckDegree (IsDegree coeff coeff_xor anf_expansion)

/-- The hybrid first check as a function on the same Boolean lists as the kit degree. -/
def listCheck (n : Nat) (l : List Bool) := hybridCheck n (word l)

private theorem head_derivative (n : Nat) (p l : List Bool) :
    xor (listCheck n (p ++ false :: l)) (listCheck n (p ++ true :: l)) =
    xor (listCheck n (p ++ [false])) (listCheck n (p ++ [true])) := by
  have rows : xorS (xorS (word (p ++ false :: l)) (word (p ++ [false])))
      (word (p ++ [true])) = word (p ++ true :: l) := by
    funext i
    induction p generalizing i with
    | nil =>
      cases i with
      | zero => rfl
      | succ i =>
        change xor (xor (word l i) false) false = word l i
        simp
    | cons v p ih =>
      cases i with
      | zero => cases v <;> rfl
      | succ i => exact ih i
  have affine := check_affine n (word (p ++ false :: l)) (word (p ++ [false])) (word (p ++ [true]))
  rw [rows] at affine
  unfold listCheck
  rw [affine]
  generalize hybridCheck n (word (p ++ false :: l)) = a
  generalize hybridCheck n (word (p ++ [false])) = b
  generalize hybridCheck n (word (p ++ [true])) = c
  cases a <;> cases b <;> cases c <;> rfl

private theorem coeff_const_pos (S : List Bool) (c : Bool) (h : 0 < S.count true) :
    coeff S (fun _ => c) = false := by
  induction S with
  | nil => simp at h
  | cons v S ih =>
    cases v with
    | false => exact ih (by simpa using h)
    | true => exact Bool.xor_self _

private theorem coeff_above_one (n : Nat) (S p : List Bool) (h : 1 < S.count true) :
    coeff S (fun l => listCheck n (p ++ l)) = false := by
  induction S generalizing p with
  | nil => simp at h
  | cons v S ih =>
    cases v with
    | false =>
      change coeff S (fun l => listCheck n (p ++ false :: l)) = false
      simpa only [List.append_assoc, List.singleton_append] using ih (p ++ [false]) (by simpa using h)
    | true =>
      change xor (coeff S _) (coeff S _) = false
      rw [← coeff_xor]
      have eqF : (fun l => xor (listCheck n (p ++ false :: l)) (listCheck n (p ++ true :: l))) =
          (fun _ => xor (listCheck n (p ++ [false])) (listCheck n (p ++ [true]))) :=
        funext (head_derivative n p)
      rw [eqF]
      exact coeff_const_pos S _ (by simpa using h)

private theorem coeff_no_bits (S : List Bool) (F : List Bool → Bool) (h : S.count true = 0) :
    coeff S F = F (List.replicate S.length false) := by
  induction S generalizing F with
  | nil => rfl
  | cons v S ih =>
    cases v with
    | false =>
      exact (ih (fun l => F (false :: l)) (by simpa using h)).trans (by simp [List.replicate_succ])
    | true => simp at h

private theorem coeff_on_cube (S : List Bool) (F G : List Bool → Bool)
    (h : ∀ l, l.length = S.length → F l = G l) : coeff S F = coeff S G := by
  induction S generalizing F G with
  | nil => exact h [] rfl
  | cons v S ih =>
    have agree (b : Bool) := ih (fun l => F (b :: l)) (fun l => G (b :: l))
      (fun l hl => h (b :: l) (by simp [hl]))
    cases v with
    | false => exact agree false
    | true => simp only [coeff, agree false, agree true]

private theorem list_check_both (n : Nat) (hn : 1 ≤ n) (b : Bool) :
    ∃ l : List Bool, l.length = n ∧ listCheck n l = b := by
  obtain ⟨_, f, _, _, _, check⟩ := check_both n hn b
  let l := List.ofFn (fun i : Fin n => f i)
  refine ⟨l, List.length_ofFn, (check_congr n (f := word l) (g := f) ?_).trans check⟩
  intro i hi
  simp [word, l, List.getD_eq_getElem?_getD, hi]

/-- The physical hybrid first check has ANF degree exactly one in the kit's formal predicate. -/
theorem hybrid_check_degree (n : Nat) (hn : 1 ≤ n) : IsDegree n (listCheck n) 1 := by
  have upper (S : List Bool) (h : 1 < S.count true) : coeff S (listCheck n) = false := by
    simpa using coeff_above_one n S [] h
  refine ⟨fun S _ => upper S, ?_⟩
  classical
  apply Classical.byContradiction
  intro noWitness
  let c := listCheck n (List.replicate n false)
  have constant (l : List Bool) (hl : l.length = n) : listCheck n l = c := by
    rw [anf_expansion l (listCheck n), ← show coeff l (fun S => coeff S (fun _ => c)) = c from
      (anf_expansion l (fun _ => c)).symm]
    apply coeff_on_cube
    intro S hS
    have len : S.length = n := hS.trans hl
    by_cases empty : S.count true = 0
    · rw [coeff_no_bits S _ empty, coeff_no_bits S _ empty, len]
    · rw [coeff_const_pos S c (by omega)]
      by_cases large : 1 < S.count true
      · exact upper S large
      · cases eq : coeff S (listCheck n) with
        | false => rfl
        | true => exact False.elim (noWitness ⟨S, len, by omega, eq⟩)
  obtain ⟨l, hl, out⟩ := list_check_both n hn (!c)
  have bad := (constant l hl).symm.trans out
  exact (show ∀ a : Bool, a ≠ !a by decide) c bad

end Rule30LinearFirstCheck
