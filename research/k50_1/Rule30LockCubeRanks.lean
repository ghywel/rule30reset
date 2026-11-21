module
public import Rule30LockCube

/-! An earlier universal entry would persist to the witnessed missed time. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LockCube
open Rule30SidewaysLocks

def ExactRank (m c J k : Nat) : Prop := Forces (Phase J k) m c ∧
  ∀ j,j<J → ¬ Forces (fun R => ∃ phase : Fin 7, Phase j phase.val R) m c

theorem earlier_fails {J m c : Nat} {R : Nat → Bool} (pref : ∀ i,i<m → R (i+1)=c.testBit i)
    (miss : ¬ ∃ k : Fin 7, Phase J k.val R) (j : Nat) (hj : j≤J) :
    ¬ Forces (fun row => ∃ k : Fin 7, Phase j k.val row) m c := by
  intro forces
  obtain ⟨k,hit⟩ := forces R pref
  have stay := lock_forever lock7_ok (by decide) R (by omega : (1+2*j)%2=1) k.isLt hit (J-j)
  apply miss
  refine ⟨⟨(k.val+(J-j))%7,Nat.mod_lt _ (by decide)⟩, ?_⟩
  simpa only [Phase,show 1+2*j+2*(J-j)=1+2*J by omega] using stay

private theorem make_rank {m c j k : Nat} (entry : Forces (Phase (j+1) k) m c) {R : Nat → Bool}
    (pref : ∀ i,i<m → R (i+1)=c.testBit i) (miss : ¬ ∃ k : Fin 7, Phase j k.val R) :
    ExactRank m c (j+1) k :=
  ⟨entry,fun q h => earlier_fails pref miss q (by omega)⟩

theorem exact_ranks :
    ExactRank 31 1412908981 6 4 ∧ ExactRank 31 544326917 8 6 ∧
    ExactRank 31 772373429 6 4 ∧ ExactRank 30 772373429 6 4 ∧
    ExactRank 31 2108003337 4 1 ∧ ExactRank 30 1034261513 10 0 := by
  refine ⟨?_,?_,?_,?_,?_,?_⟩
  · exact make_rank (j:=5) entry_thirteen (rh_prefix 1412908981 31) zero_misses_eleven
  · exact make_rank (j:=7) entry_seventeen miss_before_seventeen.1 miss_before_seventeen.2
  · exact make_rank (j:=5) entry_thirteen_wider_31 (rh_prefix 772373429 31) miss_before_thirteen_wider.2
  · exact make_rank (j:=5) entry_thirteen_wider miss_before_thirteen_wider.1 miss_before_thirteen_wider.2
  · exact make_rank (j:=3) entry_nine miss_before_nine.1 miss_before_nine.2
  · exact make_rank (j:=9) entry_twentyone miss_before_twentyone.1 miss_before_twentyone.2

/-! The finite split test is complete at every fixed phase and deadline. -/
private theorem tor_known (a b : Bool) : tor (known a) (known b)=known (a || b) := by cases a <;> cases b <;> rfl
private theorem txor_known (a b : Bool) : txor (known a) (known b)=known (xor a b) := by cases a <;> cases b <;> rfl

private theorem line_known : ∀ v : List Bool, line (v.map known)=(Rule30StripCertificates.lin3 v).map known
  | [] | [_] | [_,_] => rfl
  | a::b::c::r => by
    change txor (known a) (tor (known b) (known c)) :: line ((b::c::r).map known) = _
    rw [tor_known,txor_known,line_known (b::c::r)]
    rfl

private theorem run_known (t n : Nat) (v : List Bool) : run t n (v.map known)=(Rule30GateTrap.evolve t n v).map known := by
  induction n generalizing t v with
  | zero => rfl
  | succ n ih =>
    show run (t+1) n (line ((Rule30PeriodTwoCoupled.altCol t::v).map known))=_
    rw [line_known,ih]
    rfl

private theorem slice_known (n : Nat) (f : Nat → Tri) (g : Nat → Bool)
    (h : ∀ i,i<n → f i=known (g i)) : slice f n=(Rule30StripCertificates.seg g n).map known := by
  induction n generalizing f g with
  | zero => rfl
  | succ n ih =>
    change f 0 :: slice (fun i => f (i+1)) n = known (g 0) :: _
    rw [h 0 (by omega),ih _ (fun i => g (i+1)) (fun i hi => h (i+1) (by omega))]

private theorem expand_known : ∀ v : List Bool, expand (v.map known)=[v]
  | [] => rfl
  | b::r => by cases b <;> simp [expand,known,choices,expand_known r]

theorem check_fully_known (target : List Bool → Bool) (W t m c : Nat) (wide : W+t≤m) :
    check target W t m c = target (winW W (rh c) t) := by
  have inp : input m c (W+t)=(decodeW (W+t) c).map known := by
    apply slice_known
    intro i hi
    simp [show i<m by omega]
  rw [winW_prefix (rh_prefix c (W+t))]
  simp [check,inp,run_known,expand_known]

def completeTree : Nat → Tree | 0 => .leaf 0 | n+1 => .fork (completeTree n) (completeTree n)

private theorem complete_tree_passes (J k n m c : Nat) (hk : k<7) (wide : 30+(1+2*J)≤m+n)
    (h : Forces (Phase J k) m c) : verify J k (completeTree n) m c=true := by
  induction n generalizing m c with
  | zero =>
    have entry := h (rh c) (rh_prefix c m)
    have phase : (k+7-0%7)%7=k := by omega
    simp only [completeTree,verify,leafCheck,phase,Nat.sub_zero,show decide (0≤J)=true by simp,Bool.true_and]
    rw [check_fully_known _ _ _ _ _ (by omega)]
    simpa [Phase] using entry
  | succ n ih =>
    simp only [completeTree,verify,Bool.and_eq_true]
    refine ⟨ih (m+1) c (by omega) (fun R pref => h R (fun i hi => pref i (by omega))), ?_⟩
    apply ih (m+1) (2^m+c) (by omega)
    intro R pref
    apply h R
    intro i hi
    simpa only [Nat.testBit_two_pow_add_gt hi] using pref i (by omega)

/-- The adaptive ternary certificate is sound and complete for the specified phase at a fixed odd tick.
A complete binary tree to the light cone always suffices; successful shallower leaves may be retained. -/
theorem finite_certificate_iff {J k m c : Nat} (hk : k<7) (size : c<2^m) :
    Forces (Phase J k) m c ↔ ∃ tree,verify J k tree m c=true := by
  constructor
  · intro h
    exact ⟨completeTree (31+2*J-m),complete_tree_passes J k _ m c hk (by omega) h⟩
  · rintro ⟨tree,pass⟩
    exact verify_sound J k tree size hk pass


end Ruliology.CellularAutomata.Rule30LockCube
