module
public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! A finite three-valued light cone certifies a target for every infinite completion of a black-time right prefix. -/
@[expose] public section
set_option Elab.async false
namespace Ruliology.CellularAutomata.Rule30LockCube
open Rule30StripCertificates Rule30Ether Rule30PeriodTwoCoupled Rule30SidewaysLocks

inductive Tri where | off | on | any deriving DecidableEq

def known : Bool → Tri | false => .off | true => .on

def Fits : Tri → Bool → Prop | .off, b => b=false | .on, b => b=true | .any, _ => True

def tor : Tri → Tri → Tri
  | .on,_ | _,.on => .on
  | .off,.off => .off
  | _,_ => .any

def txor : Tri → Tri → Tri
  | .off, b => b
  | .on,.off => .on
  | .on,.on => .off
  | _,_ => .any

private theorem known_fits (b : Bool) : Fits (known b) b := by cases b <;> rfl
private theorem or_sound {a b x y} (ha : Fits a x) (hb : Fits b y) : Fits (tor a b) (x || y) := by
  cases a <;> cases b <;> cases x <;> cases y <;> simp_all [Fits,tor]
private theorem xor_sound {a b x y} (ha : Fits a x) (hb : Fits b y) : Fits (txor a b) (xor x y) := by
  cases a <;> cases b <;> cases x <;> cases y <;> simp_all [Fits,txor]

inductive Matches : List Tri → List Bool → Prop where
  | nil : Matches [] []
  | cons {a b xs ys} (head : Fits a b) (tail : Matches xs ys) : Matches (a::xs) (b::ys)

def line : List Tri → List Tri
  | a::b::c::r => txor a (tor b c) :: line (b::c::r)
  | _ => []

private theorem line_sound : ∀ {u v}, Matches u v → Matches (line u) (lin3 v)
  | [], _, .nil => .nil
  | [_], _, .cons _ .nil => .nil
  | [_,_], _, .cons _ (.cons _ .nil) => .nil
  | _::_::_::_, _, .cons ha (.cons hb (.cons hc tail)) =>
    .cons (xor_sound ha (or_sound hb hc)) (line_sound (.cons hb (.cons hc tail)))

def run : Nat → Nat → List Tri → List Tri
  | _,0,row => row
  | t,n+1,row => run (t+1) n (line (known (altCol t)::row))

private theorem run_sound (n t : Nat) {u v} (h : Matches u v) :
    Matches (run t n u) (Rule30GateTrap.evolve t n v) := by
  induction n generalizing t u v with
  | zero => exact h
  | succ n ih => exact ih (t+1) (line_sound (.cons (known_fits _) h))

def slice (f : Nat → Tri) : Nat → List Tri
  | 0 => []
  | n+1 => f 0 :: slice (fun i => f (i+1)) n

private theorem slice_sound (n : Nat) (f : Nat → Tri) (g : Nat → Bool)
    (h : ∀ i,i<n → Fits (f i) (g i)) : Matches (slice f n) (seg g n) := by
  induction n generalizing f g with
  | zero => exact .nil
  | succ n ih => exact .cons (h 0 (by omega)) (ih _ _ (fun i hi => h (i+1) (by omega)))

def input (m c n : Nat) := slice (fun i => if i<m then known (c.testBit i) else .any) n

theorem driven_sound (R : Nat → Bool) (W t m c : Nat)
    (pref : ∀ i,i<m → R (i+1)=c.testBit i) :
    Matches (run 0 t (input m c (W+t))) (winW W R t) := by
  have eq := Rule30GateTrap.rowOf_evolve R t 0 W
  rw [Nat.zero_add] at eq
  unfold winW
  rw [eq]
  apply run_sound
  apply slice_sound
  intro i _
  by_cases hi : i<m
  · simp only [hi,ite_true,Nat.zero_add,drv_init _ _ _ (by omega : 0<i+1),pref i hi]
    exact known_fits _
  · simp [hi,Fits]

def choices : Tri → List Bool | .off => [false] | .on => [true] | .any => [false,true]

def expand : List Tri → List (List Bool)
  | [] => [[]]
  | a::r => (choices a).flatMap fun b => (expand r).map (b::·)

private theorem enumerated {u v} (fit : Matches u v) : v∈expand u := by
  induction fit with
  | nil => simp [expand]
  | @cons a b xs ys h _ ih =>
    apply List.mem_flatMap.mpr
    refine ⟨b, ?_, List.mem_map.mpr ⟨ys,ih,rfl⟩⟩
    cases a <;> cases b <;> simp_all [choices,Fits]

def check (target : List Bool → Bool) (W t m c : Nat) : Bool :=
  (expand (run 0 t (input m c (W+t)))).all target

theorem check_sound {target : List Bool → Bool} {W t m c : Nat} (checked : check target W t m c=true)
    (R : Nat → Bool) (pref : ∀ i,i<m → R (i+1)=c.testBit i) : target (winW W R t)=true :=
  List.all_eq_true.mp checked _ (enumerated (driven_sound R W t m c pref))

private theorem phase4_checked : check (fun w => (cls 30 lock7Codes 4).contains w) 30 13 31 1412908981=true := by decide +kernel

theorem entry_thirteen (R : Nat → Bool) (pref : ∀ i,i<31 → R (i+1)=(1412908981:Nat).testBit i) :
    winW 30 R 13 ∈ cls 30 lock7Codes 4 := by
  simpa using check_sound phase4_checked R pref

theorem zero_misses_eleven : ¬ ∃ k : Fin 7, winW 30 (rh 1412908981) 11 ∈ cls 30 lock7Codes k.val := by
  rw [winW_prefix (rh_prefix 1412908981 41)]
  decide +kernel

/-! ### Sound union of finite cubes at different odd ticks -/

def Forces (P : (Nat → Bool) → Prop) (m c : Nat) : Prop :=
  ∀ R, (∀ i,i<m → R (i+1)=c.testBit i) → P R

theorem split_forces {P m c} (size : c<2^m)
    (low : Forces P (m+1) c) (high : Forces P (m+1) (2^m+c)) : Forces P m c := by
  intro R pref
  have z := Nat.testBit_lt_two_pow size
  cases bit : R (m+1) with
  | false =>
    apply low R
    intro i hi
    by_cases lt : i<m
    · exact pref i lt
    · have eq : i=m := by omega
      simpa [eq,z] using bit
  | true =>
    apply high R
    intro i hi
    by_cases lt : i<m
    · simpa only [Nat.testBit_two_pow_add_gt lt] using pref i lt
    · have eq : i=m := by omega
      simpa [eq,Nat.testBit_two_pow_add_eq,z] using bit

def Phase (J k : Nat) (R : Nat → Bool) := winW 30 R (1+2*J) ∈ cls 30 lock7Codes k

def leafCheck (J k lag m c : Nat) :=
  decide (lag≤J) && check (fun row => (cls 30 lock7Codes ((k+7-lag%7)%7)).contains row)
    30 (1+2*(J-lag)) m c

private theorem leaf_sound (J k lag m c : Nat) (hk : k<7) (pass : leafCheck J k lag m c=true) :
    Forces (Phase J k) m c := by
  intro R pref
  simp only [leafCheck,Bool.and_eq_true] at pass
  have both := pass
  have hlag : lag≤J := of_decide_eq_true both.1
  have first : winW 30 R (1+2*(J-lag)) ∈ cls 30 lock7Codes ((k+7-lag%7)%7) := by
    simpa using check_sound both.2 R pref
  have forever := lock_forever lock7_ok (by decide) R (by omega : (1+2*(J-lag))%2=1)
    (Nat.mod_lt _ (by decide : 0<7)) first lag
  have clock : 1+2*(J-lag)+2*lag=1+2*J := by omega
  have phase : ((k+7-lag%7)%7+lag)%7=k := by omega
  simpa only [Phase,clock,phase] using forever

inductive Tree where | leaf (lag : Nat) | fork (left right : Tree)

def verify (J k : Nat) : Tree → Nat → Nat → Bool
  | .leaf lag,m,c => leafCheck J k lag m c
  | .fork l r,m,c => verify J k l (m+1) c && verify J k r (m+1) (2^m+c)

theorem verify_sound (J k : Nat) (tree : Tree) {m c : Nat} (size : c<2^m) (hk : k<7)
    (pass : verify J k tree m c=true) : Forces (Phase J k) m c := by
  induction tree generalizing m c with
  | leaf lag => exact leaf_sound J k lag m c hk pass
  | fork l r il ir =>
    simp only [verify,Bool.and_eq_true] at pass
    have both := pass
    exact split_forces size (il (by rw [Nat.pow_succ]; omega) both.1)
      (ir (by rw [Nat.pow_succ]; omega) both.2)

/-- Read a preorder tree; a zero hexadecimal digit is a fork and digit lag+1 is a leaf. -/
def readTree : Nat → Nat → Tree × Nat
  | 0,b => (.leaf (b%16-1),b/16)
  | n+1,b => if b%16=0 then
    let l := readTree n (b/16)
    let r := readTree n l.2
    (.fork l.1 r.1,r.2)
    else (.leaf (b%16-1),b/16)


/-! Each bounded reduction checks at most eight certificate leaves. Splitting is exhaustive at each node. -/
set_option maxRecDepth 12000
set_option maxHeartbeats 32000000
private theorem part_nine_1 : Forces (Phase 4 1) 31 2108003337 :=
  verify_sound 4 1 (readTree 3 4848620032).1 (by decide) (by decide) (by decide +kernel)

private theorem family_nine : Forces (Phase 4 1) 31 2108003337 :=
  part_nine_1

theorem entry_nine (R : Nat → Bool) (pref : ∀ i,i<31 → R (i+1)=(2108003337:Nat).testBit i) :
    winW 30 R 9 ∈ cls 30 lock7Codes 1 := family_nine R pref

theorem miss_before_nine :
    (∀ i,i<31 → rh 6402970633 (i+1)=(2108003337:Nat).testBit i) ∧
    ¬ ∃ k : Fin 7, winW 30 (rh 6402970633) 7 ∈ cls 30 lock7Codes k.val := by
  constructor
  · have digits : ∀ i : Fin 31, (6402970633:Nat).testBit i.val=(2108003337:Nat).testBit i.val := by decide +kernel
    exact fun i hi => (rh_prefix 6402970633 31 i hi).trans (digits ⟨i,hi⟩)
  · rw [winW_prefix (rh_prefix 6402970633 37)]
    decide +kernel

private theorem part_thirteen_wider_1 : Forces (Phase 6 4) 32 772373429 :=
  verify_sound 6 4 (readTree 6 300244537442304).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_2 : Forces (Phase 6 4) 33 2919857077 :=
  verify_sound 6 4 (readTree 5 81645339995672576).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_3 : Forces (Phase 6 4) 33 7214824373 :=
  verify_sound 6 4 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_4 : Forces (Phase 6 4) 34 1846115253 :=
  verify_sound 6 4 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_5 : Forces (Phase 6 4) 34 10436049845 :=
  verify_sound 6 4 (readTree 4 600333903593472).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_6 : Forces (Phase 6 4) 33 6141082549 :=
  verify_sound 6 4 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_7 : Forces (Phase 6 4) 33 3993598901 :=
  verify_sound 6 4 (readTree 1 528).1 (by decide) (by decide) (by decide +kernel)

private theorem part_thirteen_wider_8 : Forces (Phase 6 4) 33 8288566197 :=
  verify_sound 6 4 (readTree 4 300166976381440).1 (by decide) (by decide) (by decide +kernel)

private theorem family_thirteen_wider : Forces (Phase 6 4) 30 772373429 :=
  (split_forces (by decide) (split_forces (by decide) part_thirteen_wider_1 (split_forces (by decide) part_thirteen_wider_2 part_thirteen_wider_3)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_thirteen_wider_4 part_thirteen_wider_5) part_thirteen_wider_6) (split_forces (by decide) part_thirteen_wider_7 part_thirteen_wider_8)))

theorem entry_thirteen_wider (R : Nat → Bool) (pref : ∀ i,i<30 → R (i+1)=(772373429:Nat).testBit i) :
    winW 30 R 13 ∈ cls 30 lock7Codes 4 := family_thirteen_wider R pref

theorem miss_before_thirteen_wider :
    (∀ i,i<30 → rh 772373429 (i+1)=(772373429:Nat).testBit i) ∧
    ¬ ∃ k : Fin 7, winW 30 (rh 772373429) 11 ∈ cls 30 lock7Codes k.val := by
  constructor
  · have digits : ∀ i : Fin 30, (772373429:Nat).testBit i.val=(772373429:Nat).testBit i.val := by decide +kernel
    exact fun i hi => (rh_prefix 772373429 30 i hi).trans (digits ⟨i,hi⟩)
  · rw [winW_prefix (rh_prefix 772373429 41)]
    decide +kernel

private theorem part_seventeen_1 : Forces (Phase 8 6) 37 544326917 :=
  verify_sound 8 6 (readTree 1 544).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_2 : Forces (Phase 8 6) 40 69263803653 :=
  verify_sound 8 6 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_3 : Forces (Phase 8 6) 40 619019617541 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_4 : Forces (Phase 8 6) 39 344141710597 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_5 : Forces (Phase 8 6) 38 206702757125 :=
  verify_sound 8 6 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_6 : Forces (Phase 8 6) 36 34904065285 :=
  verify_sound 8 6 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_7 : Forces (Phase 8 6) 38 17724196101 :=
  verify_sound 8 6 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_8 : Forces (Phase 8 6) 38 155163149573 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_9 : Forces (Phase 8 6) 37 86443672837 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_10 : Forces (Phase 8 6) 36 52083934469 :=
  verify_sound 8 6 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_11 : Forces (Phase 8 6) 37 9134261509 :=
  verify_sound 8 6 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_12 : Forces (Phase 8 6) 37 77853738245 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_13 : Forces (Phase 8 6) 36 43493999877 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_14 : Forces (Phase 8 6) 37 26314130693 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_15 : Forces (Phase 8 6) 38 95033607429 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_16 : Forces (Phase 8 6) 38 232472560901 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_17 : Forces (Phase 8 6) 37 60673869061 :=
  verify_sound 8 6 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_18 : Forces (Phase 8 6) 37 129393345797 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_19 : Forces (Phase 8 6) 36 4839294213 :=
  verify_sound 8 6 (readTree 4 76842741657571328).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_20 : Forces (Phase 8 6) 36 39199032581 :=
  verify_sound 8 6 (readTree 4 301266741886976).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_21 : Forces (Phase 8 6) 36 22019163397 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_22 : Forces (Phase 8 6) 36 56378901765 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_23 : Forces (Phase 8 6) 36 13429228805 :=
  verify_sound 8 6 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_24 : Forces (Phase 8 6) 37 47788967173 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_25 : Forces (Phase 8 6) 38 116508443909 :=
  verify_sound 8 6 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_26 : Forces (Phase 8 6) 38 253947397381 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_27 : Forces (Phase 8 6) 38 30609097989 :=
  verify_sound 8 6 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_28 : Forces (Phase 8 6) 38 168048051461 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_29 : Forces (Phase 8 6) 37 99328574725 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_30 : Forces (Phase 8 6) 36 64968836357 :=
  verify_sound 8 6 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_31 : Forces (Phase 8 6) 36 2691810565 :=
  verify_sound 8 6 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_32 : Forces (Phase 8 6) 39 37051548933 :=
  verify_sound 8 6 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_33 : Forces (Phase 8 6) 39 311929455877 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_34 : Forces (Phase 8 6) 38 174490502405 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_35 : Forces (Phase 8 6) 39 105771025669 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_36 : Forces (Phase 8 6) 40 380648932613 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_37 : Forces (Phase 8 6) 40 930404746501 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_38 : Forces (Phase 8 6) 39 243209979141 :=
  verify_sound 8 6 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_39 : Forces (Phase 8 6) 39 518087886085 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_40 : Forces (Phase 8 6) 35 19871679749 :=
  verify_sound 8 6 (readTree 3 9160368640).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_41 : Forces (Phase 8 6) 34 11281745157 :=
  verify_sound 8 6 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_42 : Forces (Phase 8 6) 35 6986777861 :=
  verify_sound 8 6 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_43 : Forces (Phase 8 6) 37 24166647045 :=
  verify_sound 8 6 (readTree 6 300239974039552).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_44 : Forces (Phase 8 6) 38 92886123781 :=
  verify_sound 8 6 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_45 : Forces (Phase 8 6) 38 230325077253 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_46 : Forces (Phase 8 6) 39 58526385413 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_47 : Forces (Phase 8 6) 39 333404292357 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_48 : Forces (Phase 8 6) 38 195965338885 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_49 : Forces (Phase 8 6) 38 127245862149 :=
  verify_sound 8 6 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_50 : Forces (Phase 8 6) 39 264684815621 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_51 : Forces (Phase 8 6) 39 539562722565 :=
  verify_sound 8 6 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_52 : Forces (Phase 8 6) 39 15576712453 :=
  verify_sound 8 6 (readTree 4 76842741657571328).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_53 : Forces (Phase 8 6) 39 290454619397 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_54 : Forces (Phase 8 6) 38 153015665925 :=
  verify_sound 8 6 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_55 : Forces (Phase 8 6) 37 84296189189 :=
  verify_sound 8 6 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_56 : Forces (Phase 8 6) 37 49936450821 :=
  verify_sound 8 6 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_57 : Forces (Phase 8 6) 37 118655927557 :=
  verify_sound 8 6 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_seventeen_58 : Forces (Phase 8 6) 35 32756581637 :=
  verify_sound 8 6 (readTree 6 599307136794624).1 (by decide) (by decide) (by decide +kernel)

private theorem family_seventeen : Forces (Phase 8 6) 31 544326917 :=
  (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_1 (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_2 part_seventeen_3) part_seventeen_4) part_seventeen_5)) part_seventeen_6) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_7 part_seventeen_8) part_seventeen_9) part_seventeen_10)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_11 part_seventeen_12) part_seventeen_13) (split_forces (by decide) (split_forces (by decide) part_seventeen_14 (split_forces (by decide) part_seventeen_15 part_seventeen_16)) (split_forces (by decide) part_seventeen_17 part_seventeen_18)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_19 part_seventeen_20) (split_forces (by decide) part_seventeen_21 part_seventeen_22)) (split_forces (by decide) (split_forces (by decide) part_seventeen_23 (split_forces (by decide) part_seventeen_24 (split_forces (by decide) part_seventeen_25 part_seventeen_26))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_27 part_seventeen_28) part_seventeen_29) part_seventeen_30)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_31 (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_32 part_seventeen_33) part_seventeen_34) (split_forces (by decide) (split_forces (by decide) part_seventeen_35 (split_forces (by decide) part_seventeen_36 part_seventeen_37)) (split_forces (by decide) part_seventeen_38 part_seventeen_39)))) part_seventeen_40) part_seventeen_41) (split_forces (by decide) (split_forces (by decide) part_seventeen_42 (split_forces (by decide) (split_forces (by decide) part_seventeen_43 (split_forces (by decide) part_seventeen_44 part_seventeen_45)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_46 part_seventeen_47) part_seventeen_48) (split_forces (by decide) part_seventeen_49 (split_forces (by decide) part_seventeen_50 part_seventeen_51))))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_seventeen_52 part_seventeen_53) part_seventeen_54) part_seventeen_55) (split_forces (by decide) part_seventeen_56 part_seventeen_57)) part_seventeen_58))))

theorem entry_seventeen (R : Nat → Bool) (pref : ∀ i,i<31 → R (i+1)=(544326917:Nat).testBit i) :
    winW 30 R 17 ∈ cls 30 lock7Codes 6 := family_seventeen R pref

theorem miss_before_seventeen :
    (∀ i,i<31 → rh 69263803653 (i+1)=(544326917:Nat).testBit i) ∧
    ¬ ∃ k : Fin 7, winW 30 (rh 69263803653) 15 ∈ cls 30 lock7Codes k.val := by
  constructor
  · have digits : ∀ i : Fin 31, (69263803653:Nat).testBit i.val=(544326917:Nat).testBit i.val := by decide +kernel
    exact fun i hi => (rh_prefix 69263803653 31 i hi).trans (digits ⟨i,hi⟩)
  · rw [winW_prefix (rh_prefix 69263803653 45)]
    decide +kernel

private theorem part_twentyone_1 : Forces (Phase 10 0) 40 1034261513 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_2 : Forces (Phase 10 0) 40 550790075401 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_3 : Forces (Phase 10 0) 39 275912168457 :=
  verify_sound 10 0 (readTree 3 9160368640).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_4 : Forces (Phase 10 0) 41 138473214985 :=
  verify_sound 10 0 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_5 : Forces (Phase 10 0) 41 1237984842761 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_6 : Forces (Phase 10 0) 41 688229028873 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_7 : Forces (Phase 10 0) 41 1787740656649 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_8 : Forces (Phase 10 0) 42 413351121929 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_9 : Forces (Phase 10 0) 42 2612374377481 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_10 : Forces (Phase 10 0) 41 1512862749705 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_11 : Forces (Phase 10 0) 40 963106935817 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_12 : Forces (Phase 10 0) 37 69753738249 :=
  verify_sound 10 0 (readTree 3 4596965888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_13 : Forces (Phase 10 0) 37 35393999881 :=
  verify_sound 10 0 (readTree 1 544).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_14 : Forces (Phase 10 0) 39 104113476617 :=
  verify_sound 10 0 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_15 : Forces (Phase 10 0) 40 378991383561 :=
  verify_sound 10 0 (readTree 3 35790848).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_16 : Forces (Phase 10 0) 40 928747197449 :=
  verify_sound 10 0 (readTree 4 600333919199744).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_17 : Forces (Phase 10 0) 39 241552430089 :=
  verify_sound 10 0 (readTree 5 2345624666112).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_18 : Forces (Phase 10 0) 39 516430337033 :=
  verify_sound 10 0 (readTree 4 599234122355200).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_19 : Forces (Phase 10 0) 40 18214130697 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_20 : Forces (Phase 10 0) 40 567969944585 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_21 : Forces (Phase 10 0) 39 293092037641 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_22 : Forces (Phase 10 0) 38 155653084169 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_23 : Forces (Phase 10 0) 40 86933607433 :=
  verify_sound 10 0 (readTree 4 1172527185936).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_24 : Forces (Phase 10 0) 40 636689421321 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_25 : Forces (Phase 10 0) 39 361811514377 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_26 : Forces (Phase 10 0) 40 224372560905 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_27 : Forces (Phase 10 0) 41 774128374793 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_28 : Forces (Phase 10 0) 41 1873640002569 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_29 : Forces (Phase 10 0) 40 499250467849 :=
  verify_sound 10 0 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_30 : Forces (Phase 10 0) 40 1049006281737 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_31 : Forces (Phase 10 0) 39 52573869065 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_32 : Forces (Phase 10 0) 40 327451776009 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_33 : Forces (Phase 10 0) 40 877207589897 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_34 : Forces (Phase 10 0) 38 190012822537 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_35 : Forces (Phase 10 0) 38 121293345801 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_36 : Forces (Phase 10 0) 38 258732299273 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_37 : Forces (Phase 10 0) 38 9624196105 :=
  verify_sound 10 0 (readTree 2 139776).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_38 : Forces (Phase 10 0) 41 147063149577 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_39 : Forces (Phase 10 0) 41 1246574777353 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_40 : Forces (Phase 10 0) 40 696818963465 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_41 : Forces (Phase 10 0) 41 421941056521 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_42 : Forces (Phase 10 0) 42 1521452684297 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_43 : Forces (Phase 10 0) 42 3720475939849 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_44 : Forces (Phase 10 0) 41 971696870409 :=
  verify_sound 10 0 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_45 : Forces (Phase 10 0) 41 2071208498185 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_46 : Forces (Phase 10 0) 40 78343672841 :=
  verify_sound 10 0 (readTree 4 1172527185936).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_47 : Forces (Phase 10 0) 40 628099486729 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_48 : Forces (Phase 10 0) 39 353221579785 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_49 : Forces (Phase 10 0) 38 215782626313 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_50 : Forces (Phase 10 0) 37 43983934473 :=
  verify_sound 10 0 (readTree 3 35790848).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_51 : Forces (Phase 10 0) 37 112703411209 :=
  verify_sound 10 0 (readTree 4 600333919199744).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_52 : Forces (Phase 10 0) 37 26804065289 :=
  verify_sound 10 0 (readTree 4 9162588160).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_53 : Forces (Phase 10 0) 38 95523542025 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_54 : Forces (Phase 10 0) 38 232962495497 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_55 : Forces (Phase 10 0) 37 61163803657 :=
  verify_sound 10 0 (readTree 5 1172812333056).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_56 : Forces (Phase 10 0) 38 129883280393 :=
  verify_sound 10 0 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_57 : Forces (Phase 10 0) 40 267322233865 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_58 : Forces (Phase 10 0) 40 817078047753 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_59 : Forces (Phase 10 0) 39 542200140809 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_60 : Forces (Phase 10 0) 39 5329228809 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_61 : Forces (Phase 10 0) 39 280207135753 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_62 : Forces (Phase 10 0) 38 142768182281 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_63 : Forces (Phase 10 0) 37 74048705545 :=
  verify_sound 10 0 (readTree 4 600333921419264).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_64 : Forces (Phase 10 0) 39 39688967177 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_65 : Forces (Phase 10 0) 40 314566874121 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_66 : Forces (Phase 10 0) 40 864322688009 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_67 : Forces (Phase 10 0) 39 177127920649 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_68 : Forces (Phase 10 0) 39 452005827593 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_69 : Forces (Phase 10 0) 38 108408443913 :=
  verify_sound 10 0 (readTree 5 2272323960832).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_70 : Forces (Phase 10 0) 40 245847397385 :=
  verify_sound 10 0 (readTree 0 2).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_71 : Forces (Phase 10 0) 41 795603211273 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_72 : Forces (Phase 10 0) 41 1895114839049 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_73 : Forces (Phase 10 0) 41 520725304329 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_74 : Forces (Phase 10 0) 41 1620236932105 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_75 : Forces (Phase 10 0) 41 1070481118217 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_76 : Forces (Phase 10 0) 42 2169992745993 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_77 : Forces (Phase 10 0) 43 4369016001545 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_78 : Forces (Phase 10 0) 43 8767062512649 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_79 : Forces (Phase 10 0) 40 22509097993 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_80 : Forces (Phase 10 0) 40 572264911881 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_81 : Forces (Phase 10 0) 39 297387004937 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_82 : Forces (Phase 10 0) 38 159948051465 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_83 : Forces (Phase 10 0) 38 91228574729 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_84 : Forces (Phase 10 0) 39 228667528201 :=
  verify_sound 10 0 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_85 : Forces (Phase 10 0) 39 503545435145 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_86 : Forces (Phase 10 0) 39 56868836361 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_87 : Forces (Phase 10 0) 39 331746743305 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_88 : Forces (Phase 10 0) 38 194307789833 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_89 : Forces (Phase 10 0) 38 125588313097 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_90 : Forces (Phase 10 0) 39 263027266569 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_91 : Forces (Phase 10 0) 40 537905173513 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_92 : Forces (Phase 10 0) 40 1087660987401 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_93 : Forces (Phase 10 0) 38 13919163401 :=
  verify_sound 10 0 (readTree 6 300239974039552).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_94 : Forces (Phase 10 0) 38 151358116873 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_95 : Forces (Phase 10 0) 38 82638640137 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_96 : Forces (Phase 10 0) 38 220077593609 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_97 : Forces (Phase 10 0) 39 48278901769 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_98 : Forces (Phase 10 0) 41 323156808713 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_99 : Forces (Phase 10 0) 42 1422668436489 :=
  verify_sound 10 0 (readTree 3 17895424).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_100 : Forces (Phase 10 0) 42 3621691692041 :=
  verify_sound 10 0 (readTree 4 300166959599872).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_101 : Forces (Phase 10 0) 40 872912622601 :=
  verify_sound 10 0 (readTree 6 300239974039552).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_102 : Forces (Phase 10 0) 38 185717855241 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_103 : Forces (Phase 10 0) 39 116998378505 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_104 : Forces (Phase 10 0) 40 391876285449 :=
  verify_sound 10 0 (readTree 5 76860265391525888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_105 : Forces (Phase 10 0) 40 941632099337 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_106 : Forces (Phase 10 0) 41 254437331977 :=
  verify_sound 10 0 (readTree 1 272).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_107 : Forces (Phase 10 0) 41 1353948959753 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_108 : Forces (Phase 10 0) 40 804193145865 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_109 : Forces (Phase 10 0) 39 529315238921 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_110 : Forces (Phase 10 0) 40 31099032585 :=
  verify_sound 10 0 (readTree 4 1172527185936).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_111 : Forces (Phase 10 0) 40 580854846473 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_112 : Forces (Phase 10 0) 39 305976939529 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_113 : Forces (Phase 10 0) 41 168537986057 :=
  verify_sound 10 0 (readTree 4 1172527185936).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_114 : Forces (Phase 10 0) 41 1268049613833 :=
  verify_sound 10 0 (readTree 3 4580184320).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_115 : Forces (Phase 10 0) 40 718293799945 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_116 : Forces (Phase 10 0) 39 443415893001 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_117 : Forces (Phase 10 0) 37 99818509321 :=
  verify_sound 10 0 (readTree 0 1).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_118 : Forces (Phase 10 0) 37 65458770953 :=
  verify_sound 10 0 (readTree 5 76842741941665808).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_119 : Forces (Phase 10 0) 39 134178247689 :=
  verify_sound 10 0 (readTree 2 69888).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_120 : Forces (Phase 10 0) 39 409056154633 :=
  verify_sound 10 0 (readTree 4 300166960709632).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_121 : Forces (Phase 10 0) 38 271617201161 :=
  verify_sound 10 0 (readTree 4 4581294080).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_122 : Forces (Phase 10 0) 32 3181745161 :=
  verify_sound 10 0 (readTree 0 8).1 (by decide) (by decide) (by decide +kernel)

private theorem part_twentyone_123 : Forces (Phase 10 0) 31 2108003337 :=
  verify_sound 10 0 (readTree 3 32329725952).1 (by decide) (by decide) (by decide +kernel)

private theorem family_twentyone : Forces (Phase 10 0) 30 1034261513 :=
  (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_1 part_twentyone_2) part_twentyone_3) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_4 part_twentyone_5) (split_forces (by decide) part_twentyone_6 part_twentyone_7)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_8 part_twentyone_9) part_twentyone_10) part_twentyone_11))) part_twentyone_12) (split_forces (by decide) part_twentyone_13 (split_forces (by decide) (split_forces (by decide) part_twentyone_14 (split_forces (by decide) part_twentyone_15 part_twentyone_16)) (split_forces (by decide) part_twentyone_17 part_twentyone_18)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_19 part_twentyone_20) part_twentyone_21) part_twentyone_22) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_23 part_twentyone_24) part_twentyone_25) (split_forces (by decide) (split_forces (by decide) part_twentyone_26 (split_forces (by decide) part_twentyone_27 part_twentyone_28)) (split_forces (by decide) part_twentyone_29 part_twentyone_30)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_31 (split_forces (by decide) part_twentyone_32 part_twentyone_33)) part_twentyone_34) (split_forces (by decide) part_twentyone_35 part_twentyone_36)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_37 (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_38 part_twentyone_39) part_twentyone_40) (split_forces (by decide) (split_forces (by decide) part_twentyone_41 (split_forces (by decide) part_twentyone_42 part_twentyone_43)) (split_forces (by decide) part_twentyone_44 part_twentyone_45)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_46 part_twentyone_47) part_twentyone_48) part_twentyone_49)) (split_forces (by decide) part_twentyone_50 part_twentyone_51)) (split_forces (by decide) (split_forces (by decide) part_twentyone_52 (split_forces (by decide) part_twentyone_53 part_twentyone_54)) (split_forces (by decide) part_twentyone_55 (split_forces (by decide) part_twentyone_56 (split_forces (by decide) (split_forces (by decide) part_twentyone_57 part_twentyone_58) part_twentyone_59)))))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_60 part_twentyone_61) part_twentyone_62) part_twentyone_63) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_64 (split_forces (by decide) part_twentyone_65 part_twentyone_66)) (split_forces (by decide) part_twentyone_67 part_twentyone_68)) (split_forces (by decide) part_twentyone_69 (split_forces (by decide) (split_forces (by decide) part_twentyone_70 (split_forces (by decide) part_twentyone_71 part_twentyone_72)) (split_forces (by decide) (split_forces (by decide) part_twentyone_73 part_twentyone_74) (split_forces (by decide) part_twentyone_75 (split_forces (by decide) part_twentyone_76 (split_forces (by decide) part_twentyone_77 part_twentyone_78)))))))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_79 part_twentyone_80) part_twentyone_81) part_twentyone_82) (split_forces (by decide) part_twentyone_83 (split_forces (by decide) part_twentyone_84 part_twentyone_85))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_86 part_twentyone_87) part_twentyone_88) (split_forces (by decide) part_twentyone_89 (split_forces (by decide) part_twentyone_90 (split_forces (by decide) part_twentyone_91 part_twentyone_92)))))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_93 part_twentyone_94) (split_forces (by decide) part_twentyone_95 part_twentyone_96)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_97 (split_forces (by decide) (split_forces (by decide) part_twentyone_98 (split_forces (by decide) part_twentyone_99 part_twentyone_100)) part_twentyone_101)) part_twentyone_102) (split_forces (by decide) (split_forces (by decide) part_twentyone_103 (split_forces (by decide) part_twentyone_104 part_twentyone_105)) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_106 part_twentyone_107) part_twentyone_108) part_twentyone_109)))) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_110 part_twentyone_111) part_twentyone_112) (split_forces (by decide) (split_forces (by decide) (split_forces (by decide) part_twentyone_113 part_twentyone_114) part_twentyone_115) part_twentyone_116)) part_twentyone_117) (split_forces (by decide) part_twentyone_118 (split_forces (by decide) (split_forces (by decide) part_twentyone_119 part_twentyone_120) part_twentyone_121)))))) part_twentyone_122) part_twentyone_123)

theorem entry_twentyone (R : Nat → Bool) (pref : ∀ i,i<30 → R (i+1)=(1034261513:Nat).testBit i) :
    winW 30 R 21 ∈ cls 30 lock7Codes 0 := family_twentyone R pref

theorem miss_before_twentyone :
    (∀ i,i<30 → rh 1034261513 (i+1)=(1034261513:Nat).testBit i) ∧
    ¬ ∃ k : Fin 7, winW 30 (rh 1034261513) 19 ∈ cls 30 lock7Codes k.val := by
  constructor
  · have digits : ∀ i : Fin 30, (1034261513:Nat).testBit i.val=(1034261513:Nat).testBit i.val := by decide +kernel
    exact fun i hi => (rh_prefix 1034261513 30 i hi).trans (digits ⟨i,hi⟩)
  · rw [winW_prefix (rh_prefix 1034261513 49)]
    decide +kernel

/-- The 30-cell input cylinder also contains its named 31-cell subcylinder. -/
theorem entry_thirteen_wider_31 (R : Nat → Bool) (pref : ∀ i,i<31 → R (i+1)=(772373429:Nat).testBit i) :
    winW 30 R 13 ∈ cls 30 lock7Codes 4 :=
  entry_thirteen_wider R (fun i hi => pref i (by omega))

end Ruliology.CellularAutomata.Rule30LockCube
