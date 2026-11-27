import Ruliology.CellularAutomata.Rule30FiniteMaskedJen
import Ruliology.CellularAutomata.Rule30HorizontalWords

/-! Distinct late spatial snapshots from a finitary Morse–Hedlund argument and
the finite-left masked Jen theorem. Integer coordinates increase eastwards. -/
namespace LateVocabulary
open Ruliology.CellularAutomata Rule30Jen Rule30Realization

abbrev Row := Int → Bool
def Agree {α : Type} (s : Nat → α) (n a b : Nat) :=
  ∀ j < n, s (a+j) = s (b+j)

def Separated (T U n : Nat) (R : Nat → Nat → Prop) :=
  ∃ f : Fin n → Nat, (∀ i, T ≤ f i ∧ f i ≤ U) ∧ ∀ i j, R (f i) (f j) → i = j

private theorem weaken {α : Type} {s : Nat → α} {m n a b : Nat}
    (h : Agree s n a b) (le : m ≤ n) : Agree s m a b :=
  fun j hj => h j (by omega)

/-- One branching prefix at each length gives a new distinguishable word
at each extension. All witnesses occur in the same interval. -/
private theorem branches {α : Type} (s : Nat → α) {T U : Nat} (length : Nat) (ok : T ≤ U)
    (branch : ∀ j < length, ∃ a b, (T ≤ a ∧ a ≤ U) ∧ (T ≤ b ∧ b ≤ U) ∧
      Agree s j a b ∧ s (a+j) ≠ s (b+j)) :
    Separated T U (length+1) (Agree s length) := by
  induction length with
  | zero =>
    exact ⟨fun _ => T, fun _ => ⟨Nat.le_refl _,ok⟩,fun i j _ => Fin.ext (by omega)⟩
  | succ n ih =>
    obtain ⟨f, fit, sep⟩ := ih (fun j hj => branch j (by omega))
    obtain ⟨a,b,ha,hb,same,split⟩ := branch n (by omega)
    have newWord : ∃ c, (T ≤ c ∧ c ≤ U) ∧ ∀ i, ¬ Agree s (n+1) c (f i) := by
      by_cases aa : ∃ i, Agree s (n+1) a (f i)
      · obtain ⟨i, ai⟩ := aa
        refine ⟨b,hb,fun j bj => ?_⟩
        have eq := sep i j (fun t ht =>
          ((ai t (by omega)).symm.trans (same t ht)).trans (bj t (by omega)))
        subst j
        exact split ((ai n (by omega)).trans (bj n (by omega)).symm)
      · exact ⟨a,ha,fun i h => aa ⟨i,h⟩⟩
    obtain ⟨c,hc,fresh⟩ := newWord
    refine ⟨Fin.cases c f, ?_, ?_⟩
    · intro i
      exact Fin.cases hc fit i
    · intro i j
      refine Fin.cases ?_ (fun i => ?_) i <;> refine Fin.cases ?_ (fun j => ?_) j
      · intro _; rfl
      · intro h; exact False.elim (fresh j h)
      · intro h; exact False.elim (fresh i (fun _ ht => (h _ ht).symm))
      · intro h
        exact congrArg Fin.succ (sep i j (weaken h (by omega)))

/-- Two repeated length-n words that subsequently disagree furnish all the
branching prefixes required by the preceding lemma. -/
private theorem separated_of_break {α : Type} (s : Nat → α) {a b T U n q : Nat}
    (aT : T ≤ a) (ab : a < b) (endAt : b+q ≤ U) (long : n ≤ q)
    (same : Agree s q a b) (diff : s (a+q) ≠ s (b+q)) :
    Separated T U (n+1) (Agree s n) := by
  apply branches s n (by omega)
  intro j hj
  let d := q-j
  refine ⟨a+d,b+d,⟨by omega,by dsimp [d]; omega⟩,⟨by omega,by dsimp [d]; omega⟩,?_,?_⟩
  · intro k hk
    simpa [Nat.add_assoc] using same (d+k) (by dsimp [d]; omega)
  · simpa [Nat.add_assoc, show d+j=q by dsimp [d]; omega] using diff

def Bond (x : Row) (i : Int) (t : Nat) := (evol x t i, evol x t (i+1))

def Window (x : Row) (i : Int) (k a b : Nat) := ∀ p,
  i-(k:Int) ≤ p → p ≤ i+1+k → evol x a p = evol x b p

private theorem tick {x : Row} {i : Int} {k a b : Nat}
    (h : Window x i (k+1) a b) : Window x i k (a+1) (b+1) := by
  intro p hp hq
  simp only [evol, h (p-1) (by omega) (by omega), h p (by omega) (by omega),
    h (p+1) (by omega) (by omega)]

private theorem cone {x : Row} {i : Int} (k a b : Nat) (h : Window x i k a b) :
    Agree (Bond x i) (k+1) a b := by
  induction k generalizing a b with
  | zero =>
    intro j hj
    have : j = 0 := by omega
    subst j
    exact Prod.ext (h i (by omega) (by omega)) (h (i+1) (by omega) (by omega))
  | succ k ih =>
    intro j hj
    cases j with
    | zero => exact Prod.ext (h i (by omega) (by omega)) (h (i+1) (by omega) (by omega))
    | succ j =>
      simpa only [show a+(j+1)=(a+1)+j by omega, show b+(j+1)=(b+1)+j by omega] using
        ih (a+1) (b+1) (tick h) j (by omega)

private theorem least_break {α : Type} (s : Nat → α) {a b M : Nat}
    (ne : ∃ j ≤ M, s (a+j) ≠ s (b+j)) :
    ∃ q ≤ M, Agree s q a b ∧ s (a+q) ≠ s (b+q) := by
  induction M with
  | zero =>
    obtain ⟨j,hj,d⟩ := ne
    exact ⟨0,by omega,fun _ h => by omega, by simpa [show j=0 by omega] using d⟩
  | succ M ih =>
    by_cases earlier : ∃ j ≤ M, s (a+j) ≠ s (b+j)
    · obtain ⟨q,h,g,d⟩ := ih earlier
      exact ⟨q,by omega,g,d⟩
    · obtain ⟨j,hj,d⟩ := ne
      have last : j=M+1 := by
        apply Classical.byContradiction
        intro no
        exact earlier ⟨j,by omega,d⟩
      exact ⟨M+1,by omega,fun k hk => Classical.byContradiction (fun no => earlier ⟨k,by omega,no⟩),
        by simpa [last] using d⟩

/-- From any late starting age T there are k+2 different snapshots on
[i-k, i+1+k], before the stated deadline. The eastern half may be infinite. -/
theorem late_snapshots {x : Row} {lo : Int} (black : x lo = true)
    (west : ∀ p, p < lo → x p = false) (i : Int) (k T : Nat) (reached : lo ≤ i+T) :
    Separated T (T+k+1+(i-lo+(T+k+1 : Nat)).toNat) (k+2) (Window x i k) := by
  let f : Fin (k+2) → Nat := fun j => T+j.val
  by_cases dup : ∃ a b : Fin (k+2), a.val < b.val ∧ Window x i k (f a) (f b)
  · obtain ⟨a,b,ab,equal⟩ := dup
    let M := (i-lo+(f b : Int)).toNat
    have hM : i-(M:Int)=lo-(f b:Int) := by dsimp [M,f]; omega
    have ordered : f a < f b := by dsimp [f]; omega
    have mismatch : ∃ j ≤ M, Bond x i (f a+j) ≠ Bond x i (f b+j) := by
      apply Classical.byContradiction
      intro no
      have agree (j : Nat) (hj : j ≤ M) : Bond x i (f a+j) = Bond x i (f b+j) :=
        Classical.byContradiction (fun d => no ⟨j,hj,d⟩)
      apply Rule30FiniteMaskedJen.window_jen_col black west M ordered hM
      · intro j hj
        exact congrArg Prod.fst (agree j hj)
      · intro j hj
        exact congrArg (fun z : Bool × Bool => z.1 || z.2) (agree j (by omega))
    obtain ⟨q, qmax, same, diff⟩ := least_break _ mismatch
    have len : k+1 ≤ q := by
      apply Classical.byContradiction
      intro short
      exact diff (cone k (f a) (f b) equal q (by omega))
    obtain ⟨g,gt,hg⟩ := separated_of_break (Bond x i) (T:=T) (n:=k+1)
      (U:=T+k+1+(i-lo+(T+k+1 : Nat)).toNat)
      (a:=f a) (b:=f b) (q:=q) (by dsimp [f]; omega) ordered
      (by dsimp [M,f] at *; omega) len same diff
    exact ⟨g,gt, fun u v h => hg u v (cone k _ _ h)⟩
  · refine ⟨f,fun j => ⟨by dsimp [f]; omega, by dsimp [f]; omega⟩,?_⟩
    intro a b h
    by_cases lt : a.val < b.val
    · exact False.elim (dup ⟨a,b,lt,h⟩)
    by_cases gt : b.val < a.val
    · exact False.elim (dup ⟨b,a,gt,fun _ l r => (h _ l r).symm⟩)
    exact Fin.ext (by omega)

/-- The exact vocabulary observed by Galindo on [−(2k+1),0].
The bound restarts at any T ≥ k+1. -/
theorem singleton_deadline (k T : Nat) (late : k+1 ≤ T) :
    Separated T (2*T+k+1) (k+2) (fun a b =>
      Rule30HorizontalDiversity.row (2*k+1) a = Rule30HorizontalDiversity.row (2*k+1) b) := by
  have west (p : Int) (hp : p<0) : seed p = false := by simp [seed,Int.ne_of_lt hp]
  obtain ⟨f,fit,sep⟩ := late_snapshots (x:=seed) (lo:=0) (by decide) west
    (-(k:Int)-1) k T (by omega)
  refine ⟨f, fun j => ⟨(fit j).1, by have := (fit j).2; omega⟩, ?_⟩
  intro a b h
  apply sep a b
  intro p hp hq
  have read : ∀ j : Nat, j < 2*k+1+1 →
      cell (f a) (-(j:Int)) = cell (f b) (-(j:Int)) := by
    simpa [Rule30HorizontalDiversity.row,List.map_inj_left] using h
  rw [evol_seed,evol_seed]
  have index : -(((-p).toNat:Nat):Int)=p := by omega
  simpa only [index] using read (-p).toNat (by omega)

private theorem remove_transients {α : Type} (s : Nat → α) (L : List α) :
    ∃ T, ∀ t ≥ T, s t ∈ L → ∀ B : Nat, ∃ u ≥ B, s u = s t := by
  induction L with
  | nil => exact ⟨0,fun _ _ h => (List.not_mem_nil h).elim⟩
  | cons z L ih =>
    obtain ⟨T,hT⟩ := ih
    by_cases cofinal : ∀ B : Nat, ∃ u ≥ B, s u = z
    · refine ⟨T,fun t ht mem => ?_⟩
      rcases List.mem_cons.mp mem with ez | old
      · simpa only [ez] using cofinal
      · exact hT t ht old
    · have stops : ∃ B : Nat, ¬∃ u ≥ B, s u = z := by
        apply Classical.byContradiction
        intro no
        exact cofinal (fun B => Classical.byContradiction (fun h => no ⟨B,h⟩))
      obtain ⟨B,stop⟩ := stops
      refine ⟨max T B,fun t ht mem => ?_⟩
      rcases List.mem_cons.mp mem with ez | old
      · exact (stop ⟨t,by omega,ez⟩).elim
      · exact hT t (by omega) old

/-- A single family of k+2 distinct words, each of which recurs at
arbitrarily large ages in the anchored singleton strip. -/
theorem singleton_cofinal (k : Nat) :
    ∃ words : Fin (k+2) → List Bool, (∀ i j, words i = words j → i = j) ∧
      ∀ i B, ∃ t ≥ B, Rule30HorizontalDiversity.row (2*k+1) t = words i := by
  let s := Rule30HorizontalDiversity.row (2*k+1)
  obtain ⟨T,hT⟩ := remove_transients s (Rule30HorizontalDiversity.language (2*k+1))
  obtain ⟨f,fit,sep⟩ := singleton_deadline k (max T (k+1)) (by omega)
  refine ⟨s ∘ f, sep,fun i => ?_⟩
  exact hT (f i) (by have := (fit i).1; omega)
    (Rule30HorizontalDiversity.mem_language.mpr ⟨f i,rfl⟩)

end LateVocabulary
