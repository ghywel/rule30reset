module
public import Ruliology.CellularAutomata.Rule30MaskedJen
public import Ruliology.CellularAutomata.Rule30DrivenPrefix

/-! Locally detecting departures from both K81 pulse rhythms on an alternating
singleton segment. The short gap is aligned at samples zero and three. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelRhythmBreak
open Rule30Jen Rule30MaskedJen

abbrev Phase := Fin 46

def period (p : Phase) := if p.val < 18 then 18 else 28

def gate (p : Phase) (t : Nat) : Bool :=
  if p.val < 18 then
    let r := (p.val+t)%18
    decide (r=0 ∨ r=3 ∨ r=8 ∨ r=13)
  else
    let r := (p.val-18+t)%28
    decide (r=0 ∨ r=3 ∨ r=8 ∨ r=13 ∨ r=18 ∨ r=23)

def advance (p : Phase) (t : Nat) : Phase :=
  if p.val < 18 then ⟨(p.val+t)%18, by omega⟩
  else ⟨18+(p.val-18+t)%28, by omega⟩

theorem shifted (p : Phase) (x y : Nat) :
    gate (advance p x) y = gate p (x+y) := by
  by_cases h : p.val < 18
  · simp [gate,advance,h,show (p.val+x)%18<18 by omega,Nat.add_assoc]
  · simp [gate,advance,h,show ¬18+(p.val-18+x)%28<18 by omega,Nat.add_assoc]

theorem periodic (p : Phase) (i : Nat) : gate p (i+period p) = gate p i := by
  by_cases h : p.val < 18 <;>
    simp [gate,period,h,← Nat.add_assoc]

private def code (f : Nat → Bool) : Nat → Nat
  | 0 => 0
  | k+1 => 2*code f k + (if f k then 1 else 0)

private theorem code_eq {f g : Nat → Bool} (n : Nat)
    (h : ∀ i, i<n → f i=g i) : code f n=code g n := by
  induction n with
  | zero => rfl
  | succ k ih => rw [code,code,ih (fun i hi => h i (by omega)),h k (by omega)]

/-- Readings of length 39 fix both the rhythm and the phase. -/
theorem phase_unique (p q : Phase) (h : ∀ i, i<39 → gate p i=gate q i) : p=q := by
  set_option maxRecDepth 16384 in
  set_option maxHeartbeats 32000000 in
    have tab : ∀ p q : Phase, code (gate p) 39 = code (gate q) 39 → p=q := by
      decide +kernel
    exact tab p q (code_eq 39 h)

def Fits (f : Nat → Bool) (a w : Nat) : Prop :=
  ∃ p : Phase, ∀ j, j<w → f (a+j)=gate p j

/-- If every overlapping length-40 window fits, a single phase covers the
whole segment, despite the local choices of phase and rhythm. -/
theorem local_to_global (f : Nat → Bool) (n : Nat) (hn : 40≤n)
    (every : ∀ i, i+40≤n → Fits f i 40) : Fits f 0 n := by
  obtain ⟨p,hp⟩ := every 0 (by omega)
  have extend (k : Nat) (hk : k+40≤n) : ∀ j, j<k+40 → f j=gate p j := by
    induction k with
    | zero => simpa using hp
    | succ k ih =>
      obtain ⟨q,hq⟩ := every (k+1) hk
      have old := ih (by omega)
      have same : q=advance p (k+1) := by
        apply phase_unique
        intro i hi
        rw [shifted,← hq i (by omega),old (k+1+i) (by omega)]
      intro j hj
      by_cases below : j<k+40
      · exact old j below
      · have eq : j=k+1+39 := by omega
        simpa only [eq,same,shifted] using hq 39 (by decide)
  exact ⟨p, fun j hj => by simpa using extend (n-40) (by omega) j (by omega)⟩

/-- Align the 18-cycle and 28-cycle at a short gap. Splice the leftmost
bit of one to the other; both length-39 subwords fit, but the 40-word fails. -/
def splice (i : Nat) : Bool := if i=0 then gate 0 i else gate 28 i

theorem sharp_memory :
    Fits splice 0 39 ∧ Fits splice 1 39 ∧ ¬Fits splice 0 40 := by
  have left : ∀ i : Fin 39, splice i = gate 0 i := by decide +kernel
  refine ⟨⟨0, fun i hi => by simpa using left ⟨i,hi⟩⟩,
    ⟨advance 28 1, fun i _ => by rw [shifted]; simp [splice]⟩, ?_⟩
  rintro ⟨p,h⟩
  have same : p=0 := phase_unique p 0 (fun i hi =>
    (by simpa using (h i (by omega)).symm : gate p i=splice i).trans (left ⟨i,hi⟩))
  subst p
  have bad := h 39 (by decide)
  exact (by decide : splice (0+39) ≠ gate 0 39) bad

/-- The initially empty, black-first driven half actually realizes the
splice, at physical ticks 417, 419, ..., 495. -/
theorem empty_splice (i : Fin 40) :
    Rule30Ether.drv Rule30PeriodTwoCoupled.altCol Rule30PeriodTwoSideways.empty
      (417+2*i.val) 1 = splice i := by
  set_option maxRecDepth 16384 in
  set_option maxHeartbeats 32000000 in
    have tab : ∀ j : Fin 40, (Rule30DrivenPrefix.white (208+j.val)).testBit 0 = splice j := by
      decide +kernel
    rw [show 417+2*i.val=2*(208+i.val)+1 by omega,← Rule30DrivenPrefix.white_sound (208+i.val) 0]
    exact tab i

/-- For an alternating singleton segment starting white at physical age A,
the first ceiling(A/2)+56 white samples contain forty consecutive samples
that fit neither K81 rhythm in any phase. The centre is needed through the
inclusive physical time 2A+112. -/
theorem singleton_joint_break (A : Nat)
    (wall : ∀ t, A≤t → t≤2*A+112 → cell t 0 = decide ((t-A)%2=1)) :
    ∃ i, i+40≤(A+1)/2+56 ∧
      ¬Fits (fun j => cell (A+2*j) 1) i 40 := by
  apply Classical.byContradiction
  intro no
  let n := (A+1)/2+56
  let f := fun j => cell (A+2*j) 1
  have every (i : Nat) (hi : i+40≤n) : Fits f i 40 :=
    Classical.byContradiction fun bad => no ⟨i,hi,bad⟩
  obtain ⟨p,hp⟩ := local_to_global f n (by dsimp [n]; omega) every
  let P := 2 * period p
  have pp : period p=18 ∨ period p=28 := by unfold period; split <;> simp
  have small : 0<P ∧ P≤56 := by dsimp [P]; omega
  apply finitary_jen (P:=P) (n:=A+P) (by omega) (by omega)
  · intro x hx hi
    rw [wall _ (by omega) (by omega),wall _ (by omega) (by omega)]
    rw [show (x+P-A)%2=(x-A)%2 by dsimp [P]; omega]
  · intro x hx hi
    have w := wall x (by omega) (by omega)
    have wp := wall (x+P) (by omega) (by omega)
    have par : (x+P-A)%2=(x-A)%2 := by dsimp [P]; omega
    unfold orCol
    rw [wp,w,par]
    by_cases odd : (x-A)%2=1
    · simp [odd]
    · let j := (x-A)/2
      have xj : x=A+2*j := by dsimp [j]; omega
      have later : x+P=A+2*(j+period p) := by dsimp [P]; omega
      have hj : j+period p<n := by dsimp [n,j,P] at *; omega
      have h1 : cell x 1=gate p j := by simpa [f,xj] using hp j (by omega)
      have h2 : cell (x+P) 1=gate p (j+period p) := by
        simpa only [f,Nat.zero_add,later] using hp (j+period p) hj
      simp [odd,h2,h1,periodic]

/-- Successive disjoint physical intervals; their starts keep the white
parity of the initial tick. -/
def start (a : Nat) : Nat → Nat
  | 0 => a
  | k+1 => 2*start a k+112+a%2

private theorem start_parity (a k : Nat) : start a k % 2 = a%2 := by
  cases k <;> simp only [start] <;> omega

private theorem start_ge (a k : Nat) : a ≤ start a k := by
  induction k with
  | zero => simp [start]
  | succ k ih => simp only [start]; omega

theorem start_formula (a k : Nat) :
    start a k + (112+a%2) = 2^k*(a+(112+a%2)) := by
  induction k with
  | zero => simp [start]
  | succ k ih =>
    rw [start,Nat.pow_succ,Nat.mul_right_comm (2^k) 2 (a+(112+a%2)),← ih]
    omega

/-- On eternal alternation every one of the disjoint intervals contains a
complete length-40 witness. The same statement for one interval only requires
alternation through its right endpoint (singleton_joint_break). -/
theorem disjoint_joint_breaks (a : Nat)
    (wall : ∀ t, a≤t → cell t 0 = decide ((t-a)%2=1)) (k : Nat) :
    ∃ t, start a k ≤ t ∧ t+78 < start a (k+1) ∧ cell t 0=false ∧
      ¬Fits (fun j => cell (t+2*j) 1) 0 40 := by
  let s := start a k
  have late : a≤s := start_ge a k
  have par : s%2=a%2 := start_parity a k
  have localWall (t : Nat) (lo : s≤t) (_ : t≤2*s+112) :
      cell t 0=decide ((t-s)%2=1) := by
    rw [wall t (by omega),show (t-a)%2=(t-s)%2 by omega]
  obtain ⟨i,hi,bad⟩ := singleton_joint_break s localWall
  refine ⟨s+2*i,by dsimp [s];omega,?_,?_,?_⟩
  · change s+2*i+78 < 2*s+112+a%2
    omega
  · rw [wall _ (by omega),show (s+2*i-a)%2=0 by omega]
    rfl
  · rintro ⟨p,h⟩
    apply bad
    refine ⟨p,?_⟩
    intro j hj
    simpa only [Nat.zero_add,show s+2*(i+j)=s+2*i+2*j by omega] using h j hj

end Ruliology.CellularAutomata.WheelRhythmBreak
