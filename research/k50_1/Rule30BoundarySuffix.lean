module

public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-!
# Suffix criterion for impossible free-boundary endpoints

After J double steps, some free endpoint is impossible exactly when it remains
impossible after replacing the black-time prefix by one with the same last 4J+1
bits and sufficient width. The choice of a particular target is separate.
The proof compares each free input history with each physical exterior,
propagating their common interior and a possible XOR at the leftmost tail cell.
-/

@[expose] public section
namespace Ruliology.CellularAutomata.Rule30BoundarySuffix

open Ruliology.CellularAutomata
open Rule30Jen Rule30StripCertificates Rule30SidewaysLocks

/-- Last n+1 cells share n trailing bits and differ at the first by the indicated XOR.
The two windows may have different widths and arbitrary unrelated interiors. -/
def Tail (flip : Bool) (n : Nat) (v w : List Bool) : Prop :=
  ∃ (a : Bool) (s u z : List Bool), s.length=n ∧ v=u++(a::s) ∧ w=z++((xor a flip)::s)

/-- Rule 30 on one shortened finite strip, admitting a chosen exterior suffix on this tick. -/
def crop (left : Bool) (v ext : List Bool) := lin3 (left :: (v++ext))

private theorem len_lin : ∀ (s : List Bool), (lin3 s).length=s.length-2
  | [] => rfl
  | [_] => rfl
  | [_,_] => rfl
  | a::b::c::s => by
    change (lin3 (b::c::s)).length+1 = _
    rw [len_lin (b::c::s)]
    simp

private theorem split_lin : ∀ (u : List Bool) (a b : Bool) (s : List Bool),
    lin3 (u++(a::b::s)) = lin3 (u++[a,b]) ++ lin3 (a::b::s)
  | [],_,_,_ => by simp [lin3]
  | [_],_,_,_ => rfl
  | [_,_],_,_,_ => rfl
  | d::e::f::xs,a,b,s => by
    change _ :: lin3 ((e::f::xs)++(a::b::s)) =
      _ :: (lin3 ((e::f::xs)++[a,b]) ++ lin3 (a::b::s))
    rw [split_lin (e::f::xs) a b s]

theorem append_tail {d n u v} (h : Tail d n u v) (e : List Bool) :
    Tail d (n+e.length) (u++e) (v++e) := by
  obtain ⟨a,s,p,q,sz,rfl,rfl⟩:=h
  exact ⟨a,s++e,p,q,by simp [sz],by simp,by simp⟩

private theorem xor_edge : ∀ a b c d : Bool,
    rule (xor a d) b c = xor (rule a b c) d := by decide +kernel

/-- A common boundary extension makes the last candidate cell of disagreement propagate one site
to the right, toggling it by the same bit. Two cells of the aligned suffix are consumed per tick. -/
theorem tick_tail {d n u v} (h : Tail d (n+2) u v) (l m : Bool) :
    Tail d n (lin3 (l::u)) (lin3 (m::v)) := by
  obtain ⟨a,s,p,q,sz,rfl,rfl⟩:=h
  cases s with
  | nil => simp at sz
  | cons b s =>
    cases s with
    | nil => simp at sz
    | cons c s =>
      rw [show l :: (p++(a::b::c::s)) = (l::p)++(a::b::c::s) by rfl,split_lin (l::p) a b (c::s)]
      rw [show m :: (q++((xor a d)::b::c::s)) = (m::q)++((xor a d)::b::c::s) by rfl,split_lin (m::q) (xor a d) b (c::s)]
      refine ⟨rule a b c,lin3 (b::c::s),lin3 ((l::p)++[a,b]),lin3 ((m::q)++[xor a d,b]),?_,rfl,?_⟩
      · rw [len_lin]; simp_all
      · change _ ++ (rule (xor a d) b c :: _) = _ ++ (xor (rule a b c) d :: _)
        rw [xor_edge]

theorem crop_tail {d n u v} (h : Tail d n u v) (l m : Bool) (e : List Bool)
    {k : Nat} (eqn : n+e.length=k+2) :
    Tail d k (crop l u e) (crop m v e) := by
  apply tick_tail
  rw [←eqn]
  exact append_tail h e

/-- One actual kit double-step can spend two bits of common suffix. Its two free exterior
values are coupled across the two compared histories but can change at every double step. -/
theorem dstep_tail {d n u v} (h : Tail d (n+2) u v) (a b : Bool) :
    Tail d n (dstep u a b) (dstep v a b) := by
  exact tick_tail (crop_tail h false false [a,b] (k:=n+2) (by simp)) true true

/-- An exact physical double-step without appending exterior cells consumes four bits. -/
def shrink2 (v : List Bool) := lin3 (true :: lin3 (false :: v))

theorem shrink2_tail {d n u v} (h : Tail d (n+4) u v) :
    Tail d n (shrink2 u) (shrink2 v) :=
  tick_tail (tick_tail h false false) true true

open Ruliology.CellularAutomata Rule30Jen Rule30StripCertificates Rule30SidewaysLocks

def game : List (Bool × Bool) → List Bool → List Bool
  | [],w => w
  | (a,b)::xs,w => game xs (dstep w a b)

def phys : Nat → List Bool → List Bool
  | 0,w => w
  | j+1,w => phys j (shrink2 w)

def freeEnd (p : List Bool) (z : List (Bool × Bool)) := game z (lin3 (true::p))
def realEnd (p e : List Bool) (j : Nat) := phys j (lin3 (true::(p++e)))

private theorem game_tail (z : List (Bool×Bool)) (n : Nat) {u v d}
    (h : Tail d (n+2*z.length) u v) : Tail d n (game z u) (game z v) := by
  induction z generalizing u v with
  | nil => simpa [game] using h
  | cons t z ih =>
    obtain ⟨a,b⟩:=t
    apply ih
    apply dstep_tail
    simpa [Nat.mul_add,Nat.add_assoc] using h

private theorem phys_tail (j n : Nat) {u v d}
    (h : Tail d (n+4*j) u v) : Tail d n (phys j u) (phys j v) := by
  induction j generalizing u v with
  | zero => simpa [phys] using h
  | succ j ih =>
    apply ih
    apply shrink2_tail
    simpa [Nat.mul_add,Nat.add_assoc] using h

/-- Starting from a common 4J+1 suffix with an arbitrary preceding fringe bit, paired
free histories give equal last 2J cells up to that same fringe XOR. -/
theorem free_tail {p q d j} (hj : 0<j) (h : Tail d (4*j+1) p q)
    (z : List (Bool×Bool)) (hz : z.length=j) :
    Tail d (2*j-1) (freeEnd p z) (freeEnd q z) := by
  apply game_tail
  apply tick_tail
  rw [hz,show 2*j-1+2*j+2=4*j+1 by omega]
  exact h

/-- The identical paired-tail statement for physical completions, with 2J extra initial cells. -/
theorem real_tail {p q d j} (hj : 0<j) (h : Tail d (4*j+1) p q)
    (e : List Bool) (he : e.length=2*j) :
    Tail d (2*j-1) (realEnd p e j) (realEnd q e j) := by
  apply phys_tail
  apply tick_tail
  have h':=append_tail h e
  rw [he] at h'
  rw [show 2*j-1+4*j+2=4*j+1+2*j by omega]
  exact h'

def Shared (n : Nat) (u v : List Bool) : Prop :=
  ∃ s : List Bool, s.length=n ∧ s <+: u ∧ s <+: v

private theorem lin_mono : ∀ x z : List Bool, lin3 x <+: lin3 (x++z)
  | [],_ => by simp [lin3]
  | [_],_ => by simp [lin3]
  | [_,_],_ => by simp [lin3]
  | a::b::c::xs,z => by
    change _ :: lin3 (b::c::xs) <+: _ :: lin3 ((b::c::xs)++z)
    exact (List.prefix_cons_inj _).mpr (lin_mono (b::c::xs) z)

private theorem size_lin : ∀ (s : List Bool), (lin3 s).length=s.length-2
  | [] => rfl
  | [_] => rfl
  | [_,_] => rfl
  | a::b::c::s => by
    change (lin3 (b::c::s)).length+1 = _
    rw [size_lin (b::c::s)]
    simp

theorem shared_crop {n u v} (h : Shared (n+1) u v) (l : Bool) (e f : List Bool) :
    Shared n (crop l u e) (crop l v f) := by
  obtain ⟨s,sz,⟨su,rfl⟩,⟨sv,rfl⟩⟩:=h
  refine ⟨lin3 (l::s),by rw [size_lin];simp [sz],?_,?_⟩
  · simpa [crop,List.append_assoc] using lin_mono (l::s) (su++e)
  · simpa [crop,List.append_assoc] using lin_mono (l::s) (sv++f)

private theorem shared_double {n u v} (h : Shared (n+2) u v) (a b : Bool) :
    Shared n (dstep u a b) (shrink2 v) := by
  have f:=shared_crop h false [a,b] []
  have g:=shared_crop f true [] []
  simpa [crop,shrink2,dstep] using g

private theorem shared_loop (z : List (Bool × Bool)) (n : Nat) {u v}
    (h : Shared (n+2*z.length) u v) : Shared n (game z u) (phys z.length v) := by
  induction z generalizing u v with
  | nil => simpa [game,phys] using h
  | cons t z ih =>
    obtain ⟨a,b⟩:=t
    apply ih
    apply shared_double
    simpa [Nat.mul_add,Nat.add_assoc] using h

/-- For each individual prefix all free and physical outcomes share their first W−2J cells. -/
theorem common_interior (p e : List Bool) (z : List (Bool × Bool)) (n : Nat)
    (len : p.length=n+2*z.length+1) :
    Shared n (freeEnd p z) (realEnd p e z.length) := by
  apply shared_loop
  have base : Shared (n+2*z.length+1) p p := ⟨p,len,by simp,by simp⟩
  simpa [crop] using shared_crop base true [] e

private theorem size_dstep (s : List Bool) (a b : Bool) :
    (dstep s a b).length=s.length := by simp [dstep,size_lin] <;> omega

private theorem size_shrink (s : List Bool) : (shrink2 s).length=s.length-2 := by
  simp [shrink2,size_lin] <;> omega

theorem size_free (p : List Bool) (z : List (Bool × Bool)) :
    (freeEnd p z).length=p.length-1 := by
  have h (z : List (Bool×Bool)) (s : List Bool) : (game z s).length=s.length := by
    induction z generalizing s with
    | nil => rfl
    | cons t z ih => obtain ⟨a,b⟩:=t; rw [game,ih,size_dstep]
  simp [freeEnd,h,size_lin] <;> omega

theorem size_real (p e : List Bool) (j : Nat) (he : e.length=2*j) :
    (realEnd p e j).length=p.length-1 := by
  have h (i : Nat) (s : List Bool) : (phys i s).length=s.length-2*i := by
    induction i generalizing s with
    | zero => simp [phys]
    | succ i ih => rw [phys,ih,size_shrink] <;> omega
  simp [realEnd,h,size_lin,he] <;> omega

private theorem fixed_parts {n a b x y} (h : Shared n (a++x) (b++y))
    (ha : a.length=n) (hb : b.length=n) : a=b := by
  obtain ⟨s,hs,⟨u,hu⟩,⟨v,hv⟩⟩:=h
  exact (List.append_inj_left hu (hs.trans ha.symm)).symm.trans
    (List.append_inj_left hv (hs.trans hb.symm))

private theorem equal_join {d n w v u u' t t'} (hu : Tail d n u t) (hv : Tail d n u' t')
    (sc : Shared w u u') (tc : Shared v t t') (ul : u.length=w+n+1)
    (ul' : u'.length=w+n+1) (tl : t.length=v+n+1) (tl' : t'.length=v+n+1) :
    u=u' ↔ t=t' := by
  obtain ⟨a,s,p,q,hs,rfl,rfl⟩:=hu
  obtain ⟨b,r,i,k,hr,rfl,rfl⟩:=hv
  simp [hs,hr] at ul ul' tl tl'
  have pi:=fixed_parts sc (by omega) (by omega)
  have qk:=fixed_parts tc (by omega) (by omega)
  subst i; subst k
  simp

private theorem lower {d n u v} (h : Tail d n u v) : n+1≤u.length ∧ n+1≤v.length := by
  obtain ⟨a,s,p,q,hs,rfl,rfl⟩:=h
  simp [hs] <;> omega

/-- For fixed guesses and fixed initial exterior, full endpoint equality is invariant under
changing the prefix interior, its width, and its bit just before the common 4J+1 suffix. -/
theorem endpoint_correspondence {p q d j} (hj : 0<j) (h : Tail d (4*j+1) p q)
    (z : List (Bool×Bool)) (hz : z.length=j) (e : List Bool) (he : e.length=2*j) :
    freeEnd p z=realEnd p e j ↔ freeEnd q z=realEnd q e j := by
  obtain ⟨lo,lo'⟩:=lower h
  let w:=p.length-1-2*j
  let v:=q.length-1-2*j
  have hp:=common_interior p e z w (by dsimp [w]; omega)
  have hq:=common_interior q e z v (by dsimp [v]; omega)
  rw [hz] at hp hq
  apply equal_join (free_tail hj h z hz) (real_tail hj h e he) hp hq
  · rw [size_free]; dsimp [w]; omega
  · rw [size_real _ _ _ he]; dsimp [w]; omega
  · rw [size_free]; dsimp [v]; omega
  · rw [size_real _ _ _ he]; dsimp [v]; omega

/-- Some free sequence produces a full window that no completion of this black prefix produces. -/
def Spurious (p : List Bool) (j : Nat) : Prop :=
  ∃ z : List (Bool×Bool), z.length=j ∧ ∀ e : List Bool, e.length=2*j →
    freeEnd p z ≠ realEnd p e j

theorem spurious_zero (p : List Bool) : ¬Spurious p 0 := by
  rintro ⟨z,hz,h⟩
  have ze : z=[] := List.length_eq_zero_iff.mp hz
  subst z
  apply h [] rfl
  simp [freeEnd,realEnd,game,phys]

theorem spurious_invariant {p q d j} (h : Tail d (4*j+1) p q) :
    Spurious p j ↔ Spurious q j := by
  by_cases hj : 0<j
  · constructor
    · rintro ⟨z,hz,hz'⟩
      exact ⟨z,hz,fun e he eqn => hz' e he ((endpoint_correspondence hj h z hz e he).mpr eqn)⟩
    · rintro ⟨z,hz,hz'⟩
      exact ⟨z,hz,fun e he eqn => hz' e he ((endpoint_correspondence hj h z hz e he).mp eqn)⟩
  · have je : j=0 := by omega
    simp [je,spurious_zero]

/-- For W≥4J+1, changing all but the last 4J+1 black-prefix bits, even changing
the width itself, preserves existence of an impossible free endpoint. -/
theorem spurious_of_suffix (j : Nat) (s u v : List Bool) (a b : Bool) (hs : s.length=4*j+1) :
    Spurious (u++(a::s)) j ↔ Spurious (v++(b::s)) j := by
  apply spurious_invariant (d:=xor a b)
  exact ⟨a,s,u,v,hs,rfl,by cases a <;> cases b <;> rfl⟩

open Ruliology.CellularAutomata Rule30StripCertificates Rule30Ether Rule30SidewaysLocks
open Rule30PeriodTwoCoupled Rule30Jen

private theorem win_add (R : Nat → Bool) (w n t : Nat) :
    winW (w+n) R t = winW w R t ++ seg (fun i => drv altCol R t (w+i+1)) n := by
  unfold winW rowOf
  induction n with
  | zero => simp [seg]
  | succ n ih =>
    rw [show w+(n+1)=(w+n)+1 by omega,seg_succ,ih,seg_succ n]
    simp [List.append_assoc]

private theorem first_real (R : Nat → Bool) (W : Nat) :
    lin3 (true::winW (W+1) R 0) = winW W R 1 := by
  have h:=rowOf_succ (drv_isR30 altCol R) 0 0 W
  rw [drv_col0] at h
  have e : winW (W+1) R 0=winW W R 0 ++ [drv altCol R 0 (0+W+1)] := by
    unfold winW rowOf; rw [seg_succ]
  rw [e]
  exact h.symm

-- The kit predecessor calculation, now stated for the suffix-cone operator.
private theorem shrink_real (R : Nat → Bool) (W t : Nat) (odd : t%2=1) :
    shrink2 (winW (W+2) R t) = winW W R (t+2) := by
  rw [winW_dstep W R t odd]
  unfold dstep shrink2
  have cols : winW (W+2) R t = winW W R t ++
      [drv altCol R t (W+1), drv altCol R t (W+2)] := by
    unfold winW rowOf
    rw [seg_succ,seg_succ]
    simp [List.append_assoc]
  rw [cols]

private theorem phys_real (R : Nat → Bool) (j W t : Nat) (odd : t%2=1) :
    phys j (winW (W+2*j) R t) = winW W R (t+2*j) := by
  induction j generalizing t with
  | zero => simp [phys]
  | succ j ih =>
    rw [phys,show W+2*(j+1)=(W+2*j)+2 by omega,shrink_real R _ _ odd,
      ih (t+2) (by omega),show t+2+2*j=t+2*(j+1) by omega]

/-- The computed physical endpoint is exactly the kit's actual odd-time window when the black
right half starts with p followed by e. No restriction is placed on its later cells. -/
theorem realEnd_eq_win (R : Nat → Bool) {p e : List Bool} (j W : Nat)
    (h : winW (W+2*j+1) R 0=p++e) :
    realEnd p e j=winW W R (1+2*j) := by
  unfold realEnd
  rw [←h,first_real,phys_real R _ _ _ (by decide)]

private theorem seg_get (s : List Bool) :
    seg (fun i => s.getD i false) s.length=s := by
  induction s with
  | nil => rfl
  | cons a s ih =>
    change a :: seg (fun i => s.getD i false) s.length = a :: s
    rw [ih]

private def prefixRow (s : List Bool) (k : Nat) : Bool := s.getD (k-1) false

private theorem realizes (s : List Bool) : winW s.length (prefixRow s) 0=s := by
  unfold winW rowOf
  simpa [drv,prefixRow] using seg_get s

/-- All and only the physical endpoints of all infinite right halves sharing p arise by
appending exactly 2J arbitrary initial bits. -/
theorem exact_physical_endpoints (p : List Bool) (j W : Nat) (hp : p.length=W+1)
    (y : List Bool) :
    (∃ e : List Bool, e.length=2*j ∧ realEnd p e j=y) ↔
    ∃ R : Nat → Bool, winW (W+1) R 0=p ∧ winW W R (1+2*j)=y := by
  constructor
  · rintro ⟨e,he,ey⟩
    let R:=prefixRow (p++e)
    have h : winW (W+2*j+1) R 0=p++e := by
      have h':=realizes (p++e)
      simpa [R,hp,he,show W+1+2*j=W+2*j+1 by omega] using h'
    have pref : winW (W+1) R 0=p := by
      rw [show W+2*j+1=(W+1)+2*j by omega,win_add] at h
      apply List.append_inj_left h
      exact (length_seg _ _).trans hp.symm
    exact ⟨R,pref,(realEnd_eq_win R j W h).symm.trans ey⟩
  · rintro ⟨R,pref,wy⟩
    let e:=seg (fun i=>drv altCol R 0 (W+1+i+1)) (2*j)
    have h : winW (W+2*j+1) R 0=p++e := by
      rw [show W+2*j+1=(W+1)+2*j by omega,win_add,pref]
    exact ⟨e,length_seg _ _,(realEnd_eq_win R j W h).trans wy⟩

/-- A free endpoint at horizon J from prefix p is not realized by any physical infinite completion. -/
def KitSpurious (p : List Bool) (W j : Nat) : Prop :=
  ∃ z : List (Bool×Bool), z.length=j ∧ ∀ R : Nat → Bool, winW (W+1) R 0=p →
    game z (winW W R 1)≠winW W R (1+2*j)

theorem kit_iff_spurious (p : List Bool) (W j : Nat) (hp : p.length=W+1) :
    KitSpurious p W j ↔ Spurious p j := by
  have first (R : Nat → Bool) (hr : winW (W+1) R 0=p) :
      winW W R 1=lin3 (true::p) := by rw [←hr,first_real]
  constructor
  · rintro ⟨z,hz,im⟩
    refine ⟨z,hz,?_⟩
    intro e he eqn
    obtain ⟨R,pr,eqR⟩:=(exact_physical_endpoints p j W hp (freeEnd p z)).mp ⟨e,he,eqn.symm⟩
    exact im R pr (by rw [first R pr];exact eqR.symm)
  · rintro ⟨z,hz,im⟩
    refine ⟨z,hz,?_⟩
    intro R pr eqn
    rw [first R pr] at eqn
    obtain ⟨e,he,eqe⟩:=(exact_physical_endpoints p j W hp (freeEnd p z)).mpr ⟨R,pr,eqn.symm⟩
    exact im e he eqe.symm

/-- In the alternating-driven right half itself, existence of an impossible full W-window
depends only on the last 4J+1 known black-time bits, for possibly different widths ≥4J+1. -/
theorem kit_spurious_of_suffix (j : Nat) (s u v : List Bool) (a b : Bool)
    (hs : s.length=4*j+1) :
    KitSpurious (u++(a::s)) (u.length+s.length) j ↔
      KitSpurious (v++(b::s)) (v.length+s.length) j := by
  rw [kit_iff_spurious _ _ _ (by simp; omega),kit_iff_spurious _ _ _ (by simp; omega)]
  exact spurious_of_suffix j s u v a b hs

end Ruliology.CellularAutomata.Rule30BoundarySuffix
