module
public import Ruliology.CellularAutomata.Rule30SidewaysLocks
public import Ruliology.CellularAutomata.Rule30PlantedSurvivor

/-! Uniform odd-time entry to the kit's 30-cell period-seven lock.
The finite prefix is held at black time 0. Site +1 is bit 0.
The diagonal lemma below is the kit's private argument in
Rule30ResetCompactness.lean (40017e8), carried unchanged here. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30Lock7Compactness
open Rule30SidewaysLocks Rule30PlantedSurvivor

private def Often (P : Nat → Prop) := ∀ bound, ∃ i, bound ≤ i ∧ P i

private theorem split_often {P : Nat → Prop} (h : Often P) (f : Nat → Bool) :
    ∃ b, Often (fun i => P i ∧ f i = b) := by
  classical
  by_cases ht : Often (fun i => P i ∧ f i = true)
  · exact ⟨true, ht⟩
  · simp only [Often, Classical.not_forall, not_exists, not_and] at ht
    obtain ⟨u, hu⟩ := ht
    refine ⟨false, fun bound => ?_⟩
    obtain ⟨i, hi, pi⟩ := h (max bound u)
    exact ⟨i, by omega, pi, Bool.eq_false_iff.mpr (hu i (by omega) pi)⟩

private structure Pool where
  pred : Nat → Prop
  often : Often pred

private noncomputable def pools (bits : Nat → Nat → Bool) : Nat → Pool
  | 0 => ⟨fun _ => True, fun n => ⟨n, Nat.le_refl _, trivial⟩⟩
  | n+1 =>
    let p := pools bits n
    let pick := split_often p.often (fun i => bits i n)
    ⟨_, pick.choose_spec⟩

private theorem limit_prefix (bits : Nat → Nat → Bool) :
    ∃ x : Nat → Bool, ∀ n, Often (fun i => ∀ j, j < n → bits i j = x j) := by
  let x := fun n => (split_often (pools bits n).often (fun i => bits i n)).choose
  have matchBits (n i) (h : (pools bits n).pred i) : ∀ j, j < n → bits i j = x j := by
    induction n with
    | zero => intro j hj; omega
    | succ n ih =>
      change (pools bits n).pred i ∧ bits i n = x n at h
      intro j hj
      by_cases eq : j = n
      · exact eq ▸ h.2
      · exact ih h.1 j (by omega)
  exact ⟨x, fun n bound => by
    obtain ⟨i,hi,h⟩ := (pools bits n).often bound
    exact ⟨i,hi,matchBits n i h⟩⟩

def HasPrefix (m c : Nat) (R : Nat → Bool) : Prop :=
  ∀ i, i < m → R (i+1) = c.testBit i

def Locked (R : Nat → Bool) (j : Nat) : Prop :=
  ∃ k : Fin 7, winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val

private theorem window_congr (R S : Nat → Bool) (W t : Nat)
    (same : ∀ i, i < W+t → R (i+1) = S (i+1)) :
    winW W R t = winW W S t := by
  let q := enc (W+t) (fun i => S (i+1))
  have digits (i : Nat) (hi : i < W+t) : S (i+1) = q.testBit i := by
    simp [q, testBit_enc, hi]
  exact (winW_prefix (R:=R) (W:=W) (c:=q) (t0:=t)
    (fun i hi => (same i hi).trans (digits i hi))).trans (winW_prefix (R:=S) digits).symm

theorem locked_later {R : Nat → Bool} {j J : Nat} (le : j ≤ J) (hit : Locked R j) : Locked R J := by
  obtain ⟨k, hk⟩ := hit
  have future := lock_forever lock7_ok (by decide) R (t0:=1+2*j) (by omega) k.isLt hk (J-j)
  exact ⟨⟨(k.val + (J-j))%7, by omega⟩,
    by simpa only [show 1+2*j+2*(J-j) = 1+2*J by omega] using future⟩

/-- The phase at the common deadline is allowed to depend on the completion. -/
theorem uniform_lock_iff (m c : Nat) :
    (∀ R, HasPrefix m c R → ∃ j, Locked R j) ↔
    ∃ J, ∀ R, HasPrefix m c R → Locked R J := by
  constructor
  · intro each
    classical
    apply Classical.byContradiction
    intro bad
    simp only [not_exists, Classical.not_forall] at bad
    let rows := fun j => (bad j).choose
    have avoid (j : Nat) : HasPrefix m c (rows j) ∧ ¬Locked (rows j) j := ⟨(bad j).choose_spec.choose, (bad j).choose_spec.choose_spec⟩
    obtain ⟨R, often⟩ := limit_prefix rows
    have pref : HasPrefix m c R := by
      obtain ⟨s, _, agree⟩ := often (m+1) 0
      intro i hi
      exact (agree (i+1) (by omega)).symm.trans ((avoid s).1 i hi)
    obtain ⟨j, hit⟩ := each R pref
    obtain ⟨s, hs, agree⟩ := often (30+(1+2*j)+1) j
    have same : winW 30 R (1+2*j) = winW 30 (rows s) (1+2*j) :=
      window_congr _ _ _ _ (fun i hi => (agree (i+1) (by omega)).symm)
    obtain ⟨k, hk⟩ := hit
    exact (avoid s).2 (locked_later hs ⟨k, same ▸ hk⟩)
  · rintro ⟨J,h⟩ R hR
    exact ⟨J,h R hR⟩

/-- A finite search for *one deadline*. Black-time codes use positive sites only;
at odd tick 1+2J, the first 30 cells use at most 31+2J positive input bits. -/
def lockCover (m c J : Nat) : Prop :=
  ∀ q, q < 2^(max m (31+2*J)) →
    (∀ i, i < m → q.testBit i = c.testBit i) → Locked (rh q) J

theorem all_completions_iff_finite_cover (m c : Nat) :
    (∀ R, HasPrefix m c R → ∃ j, Locked R j) ↔ ∃ J, lockCover m c J := by
  rw [uniform_lock_iff]
  constructor
  · rintro ⟨J,uniform⟩
    refine ⟨J,fun q _ shared => uniform (rh q) ?_⟩
    exact fun i hi => ((rh_prefix q m) i hi).trans (shared i hi)
  · rintro ⟨J,cover⟩
    refine ⟨J,fun R pref => ?_⟩
    let L := max m (31+2*J)
    let q := enc L (fun i => R (i+1))
    have digits (i : Nat) (hi : i<L) : R (i+1) = q.testBit i := by
      simp [q, testBit_enc, hi]
    have above : m ≤ L := Nat.le_max_left _ _
    have light : 31+2*J ≤ L := Nat.le_max_right _ _
    obtain ⟨k,hk⟩ := cover q (enc_lt _ _)
      (fun i hi => (digits i (by omega)).symm.trans (pref i hi))
    have same : winW 30 R (1+2*J) = winW 30 (rh q) (1+2*J) :=
      window_congr _ _ _ _ (fun i hi => (digits i (by omega)).trans ((rh_prefix q L) i (by omega)).symm)
    exact ⟨k, same.symm ▸ hk⟩

/-- Site zero is the imposed driver. Positive cells below m are the fixed prefix;
the free suffix is read least-significant-bit first and zero-filled beyond q. -/
def joinBits (m c q : Nat) : Nat → Bool
  | 0 => false
  | i+1 => if i<m then c.testBit i else q.testBit (i-m)

/-- Executable check of the 2^(31+2J-m) assignments of free light-cone bits,
using natural subtraction. Fixed bits are never enumerated. -/
def checkCover (m c J : Nat) : Bool :=
  (List.range (2^(31+2*J-m))).all fun q =>
    decide (∃ k : Fin 7, winW 30 (joinBits m c q) (1+2*J) ∈ cls 30 lock7Codes k.val)

theorem checkCover_spec (m c J : Nat) : checkCover m c J = true ↔
    ∀ R, HasPrefix m c R → Locked R J := by
  simp only [checkCover, List.all_eq_true, List.mem_range, decide_eq_true_eq]
  constructor
  · intro check R pref
    let q := enc (31+2*J-m) (fun i => R (m+i+1))
    obtain ⟨k,hk⟩ := check q (enc_lt _ _)
    have same : winW 30 R (1+2*J) = winW 30 (joinBits m c q) (1+2*J) := by
      apply window_congr
      intro i hi
      by_cases small : i<m
      · simpa [joinBits,small] using pref i small
      · have hsub : i-m<31+2*J-m := by omega
        simp [joinBits,small,q,testBit_enc,hsub,show m+(i-m)=i by omega]
    exact ⟨k,same.symm ▸ hk⟩
  · intro uniform q _
    exact uniform (joinBits m c q) (fun i hi => by simp [joinBits,hi])

theorem all_completions_iff_check (m c : Nat) :
    (∀ R, HasPrefix m c R → ∃ j, Locked R j) ↔ ∃ J, checkCover m c J = true := by
  simp only [checkCover_spec]
  exact uniform_lock_iff m c

/-! ## Scattered observations, including infinite sets of observed sites -/

/-- Spatial sites are positive. Site zero belongs to the prescribed driver. -/
def AgreesOn (obs R₀ R : Nat → Bool) : Prop :=
  ∀ i, obs (i+1) = true → R (i+1) = R₀ (i+1)

/-- Only observed sites in the past cone of the deadline are required. -/
def ConeAgrees (obs R₀ : Nat → Bool) (J : Nat) (R : Nat → Bool) : Prop :=
  ∀ i, i < 31+2*J → obs (i+1) = true → R (i+1) = R₀ (i+1)

/-- Even infinitely many prescribed sites force eventual lock entry only if
finitely many of them already force entry by one common odd deadline. -/
theorem observed_uniform_iff (obs R₀ : Nat → Bool) :
    (∀ R, AgreesOn obs R₀ R → ∃ j, Locked R j) ↔
    ∃ J, ∀ R, ConeAgrees obs R₀ J R → Locked R J := by
  constructor
  · intro each
    classical
    apply Classical.byContradiction
    intro bad
    simp only [not_exists, Classical.not_forall] at bad
    let rows := fun j => (bad j).choose
    have avoid (j : Nat) : ConeAgrees obs R₀ j (rows j) ∧ ¬Locked (rows j) j :=
      ⟨(bad j).choose_spec.choose, (bad j).choose_spec.choose_spec⟩
    obtain ⟨R,often⟩ := limit_prefix rows
    have agrees : AgreesOn obs R₀ R := by
      intro i watched
      obtain ⟨s,late,agree⟩ := often (i+2) i
      exact (agree (i+1) (by omega)).symm.trans ((avoid s).1 i (by omega) watched)
    obtain ⟨j, entered⟩ := each R agrees
    obtain ⟨s,late,agree⟩ := often (30+(1+2*j)+1) j
    have same : winW 30 R (1+2*j) = winW 30 (rows s) (1+2*j) :=
      window_congr _ _ _ _ (fun i hi => (agree (i+1) (by omega)).symm)
    obtain ⟨k,hk⟩ := entered
    exact (avoid s).2 (locked_later late ⟨k,same ▸ hk⟩)
  · rintro ⟨J,h⟩ R hr
    exact ⟨J,h R (fun i _ watched => hr i watched)⟩

/-- Zero-based indices of the free positive cells in this finite cone. -/
def freeSites (obs : Nat → Bool) (J : Nat) : List Nat :=
  (List.range (31+2*J)).filter fun i => !obs (i+1)

def fillObserved (obs R₀ : Nat → Bool) (J q : Nat) : Nat → Bool
  | 0 => false
  | i+1 => if obs (i+1) then R₀ (i+1) else q.testBit ((freeSites obs J).idxOf i)

/-- Check exactly one assignment per filling of the unobserved cone sites.
The phase may depend on the filling. -/
def checkObserved (obs R₀ : Nat → Bool) (J : Nat) : Bool :=
  (List.range (2^(freeSites obs J).length)).all fun q =>
    decide (∃ k : Fin 7, winW 30 (fillObserved obs R₀ J q) (1+2*J) ∈ cls 30 lock7Codes k.val)

theorem checkObserved_spec (obs R₀ : Nat → Bool) (J : Nat) :
    checkObserved obs R₀ J = true ↔ ∀ R, ConeAgrees obs R₀ J R → Locked R J := by
  simp only [checkObserved,List.all_eq_true,List.mem_range,decide_eq_true_eq]
  constructor
  · intro check R agrees
    let xs := freeSites obs J
    let q := enc xs.length (fun k => R (xs.getD k 0+1))
    obtain ⟨phase,hp⟩ := check q (enc_lt _ _)
    have equal : winW 30 R (1+2*J) = winW 30 (fillObserved obs R₀ J q) (1+2*J) := by
      apply window_congr
      intro i hi
      by_cases on : obs (i+1)=true
      · simpa [fillObserved,on] using agrees i (by omega) on
      · have off : obs (i+1)=false := Bool.eq_false_iff.mpr on
        have mem : i∈xs := by simp [xs,freeSites,off]; omega
        have idx := List.idxOf_lt_length_iff.mpr mem
        have atIndex : xs.getD (xs.idxOf i) 0=i := by
          simp [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem idx, List.getElem_idxOf idx]
        simp only [fillObserved, off, Bool.false_eq_true, ite_false]
        change R (i+1) = q.testBit (xs.idxOf i)
        simp only [q,testBit_enc,decide_eq_true idx,Bool.true_and,atIndex]
    exact ⟨phase,equal.symm ▸ hp⟩
  · intro uniform q _
    exact uniform (fillObserved obs R₀ J q) (fun i _ h => by simp [fillObserved,h])

/-- A positive semidecision for arbitrary observations, with no prescribed horizon. -/
theorem observed_eventual_iff_check (obs R₀ : Nat → Bool) :
    (∀ R, AgreesOn obs R₀ R → ∃ j, Locked R j) ↔ ∃ J, checkObserved obs R₀ J = true := by
  simp only [checkObserved_spec]
  exact observed_uniform_iff obs R₀


/-- The observed sites must hit the discrepancy set of every rejected finite cone.
Different observed families at this deadline can reuse the same rejected words. -/
def MeetsRejects (obs R₀ : Nat → Bool) (J : Nat) : Prop :=
  ∀ q, q < 2^(31+2*J) → ¬Locked (rh q) J →
    ∃ i, i < 31+2*J ∧ obs (i+1)=true ∧ q.testBit i≠R₀ (i+1)

theorem cone_iff_meets_rejects (obs R₀ : Nat → Bool) (J : Nat) :
    (∀ R, ConeAgrees obs R₀ J R → Locked R J) ↔ MeetsRejects obs R₀ J := by
  constructor
  · intro allRows q _ rejected
    classical
    apply Classical.byContradiction
    intro fail
    apply rejected
    apply allRows
    intro i hi on
    rw [rh_prefix q _ i hi]
    exact Classical.byContradiction (fun ne => fail ⟨i,hi,on,ne⟩)
  · intro hits R pref
    classical
    let L := 31+2*J
    let q := enc L (fun i => R (i+1))
    have digits (i : Nat) (hi : i<L) : R (i+1)=q.testBit i := by simp [q,testBit_enc,hi]
    have same : winW 30 R (1+2*J)=winW 30 (rh q) (1+2*J) :=
      window_congr _ _ _ _ (fun i hi =>
        (digits i (by dsimp [L]; omega)).trans ((rh_prefix q L) i (by dsimp [L]; omega)).symm)
    apply Classical.byContradiction
    intro missed
    have reject : ¬Locked (rh q) J := by
      rintro ⟨k,entry⟩
      exact missed ⟨k,same.symm ▸ entry⟩
    obtain ⟨i,hl,on,diff⟩ := hits q (enc_lt _ _) reject
    exact diff ((digits i hl).symm.trans (pref i hl on))

theorem observed_iff_meets_rejects (obs R₀ : Nat → Bool) :
    (∀ R, AgreesOn obs R₀ R → ∃ j, Locked R j) ↔ ∃ J, MeetsRejects obs R₀ J := by
  simp only [←cone_iff_meets_rejects]
  exact observed_uniform_iff obs R₀


/-! The same check finds a sharp one-bit threshold at the reanchored kit seed 1891. -/
open Rule30SidewaysLocks Rule30GateTrap
set_option maxRecDepth 30000
set_option maxHeartbeats 32000000

/-- The lock's phases 1 and 3 are both kicks, two samples apart.
The trap excludes this after every kick. -/
theorem locked_outside_trap {R : Nat → Bool} {j : Nat} (hit : Locked R j) :
    win R (1+2*j) ∉ trap := by
  intro inside
  obtain ⟨k,hk⟩ := hit
  have hh : winW 30 R (2*j+1) ∈ cls 30 lock7Codes k.val := by
    rwa [Nat.add_comm 1] at hk
  let n := 8-k.val
  have t1 : (k.val+n)%7 = 1 := by dsimp [n]; have := k.isLt; omega
  have t3 : (k.val+(n+2))%7 = 3 := by dsimp [n]; have := k.isLt; omega
  have u1 := u_of_lock (V:=29) lock7_ok (by decide) R k.isLt hh n
  have u3 := u_of_lock (V:=29) lock7_ok (by decide) R k.isLt hh (n+2)
  rw [t1] at u1
  rw [t3] at u3
  change Rule30PeriodTwoSideways.u R (j+(n+2)) = true at u3
  have u1' : Rule30PeriodTwoSideways.u R (j+n) = true := u1
  have u3' : Rule30PeriodTwoSideways.u R (j+n+2) = true := by simpa only [Nat.add_assoc] using u3
  rcases gaps_of_entry R (by omega : (1+2*j)%2=1) inside (j+n) (by omega) u1' with q | q
  · exact Bool.noConfusion (q.2.1.symm.trans u3')
  · exact Bool.noConfusion (q.2.1.symm.trans u3')
def avoidSeed : Nat := 150212610825

theorem avoidSeed_trap_at83 : win (rh avoidSeed) 83 ∈ trap := by
  have eq : winW 16 (rh avoidSeed) 83 = decode entryCode := by
    rw [winW_prefix (rh_prefix avoidSeed 99)]
    decide +kernel
  change winW 16 (rh avoidSeed) 83 ∈ trap
  rw [eq]
  exact entry_mem

theorem avoidSeed_no_lock : ¬ ∃ j, Locked (rh avoidSeed) j := by
  rintro ⟨j,h⟩
  let s := max j 41
  have hj : j ≤ s := Nat.le_max_left _ _
  have ht : 41 ≤ s := Nat.le_max_right _ _
  have t := win_mem_trap (rh avoidSeed) (by decide : 83%2=1) avoidSeed_trap_at83 (s-41)
  have no := locked_outside_trap (locked_later hj h)
  exact no (by simpa only [show 83+2*(s-41)=1+2*s by omega] using t)

theorem sharp_for_eventual_entry :
    (∀ R, HasPrefix 29 157190921 R → Locked R 0) ∧
    (HasPrefix 28 157190921 (rh avoidSeed) ∧ ¬ ∃ j, Locked (rh avoidSeed) j) := by
  refine ⟨(checkCover_spec 29 157190921 0).mp (by decide +kernel), ?_, avoidSeed_no_lock⟩
  have bits : ∀ i : Fin 28, avoidSeed.testBit i.val = (157190921 : Nat).testBit i.val := by
    decide +kernel
  exact fun i hi => (rh_prefix avoidSeed 28 i hi).trans (bits ⟨i,hi⟩)

end Ruliology.CellularAutomata.Rule30Lock7Compactness
