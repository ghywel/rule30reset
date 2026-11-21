module

public import Ruliology.CellularAutomata.Rule30Blocks
public import Ruliology.CellularAutomata.Rule30SidewaysLocks
public import Ruliology.CellularAutomata.Rule30PlantedSurvivor

/-!
# Finite prefixes forcing the period-seven lock and its moving-edge obstruction

For a black-even driven right half, a certificate that every boundary continuation
reaches the width-30 period-seven lock yields a deadline for every completion of
the given initial prefix. Three 25-cell prefixes force lock entry at tick 11.

Every odd entry in any of the seven classes aligns the compatible left half with
one cyclic ring. At any positive absolute singleton age its moving outermost cell
must disagree at least once in nine consecutive physical ticks. At odd ages at
least seven, all white-time comparisons already disagree within seven spatial cells.

Troy Lowry with Codex supplied the ring, its inverse recurrence and the odd-age
singleton edge in Rule30PrizeKit PR #378 (0aa79bef). The ring and edge lemmas
below reuse that code. The merged kit supplies the lock and its time evolution.
Universal predecessor ranks were previously used for ether-family entry by
lhallee (rule30-open, a3b4a64f). The results here let the lock class, initial
prefix, subsequent comparison time and absolute singleton age vary.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30Lock7Prefixes

open Rule30SidewaysLocks Rule30PeriodTwoSideways BusyBeaverLifetimes
open Rule30ZeroBoundary (zrow zrow_inv zrow_wall)

private theorem seed_eq (t : Nat) : Rule30Jen.cell t = TwoColor.cell 30 1 t := by
  induction t with
  | zero => rfl
  | succ t ih =>
    rw [Rule30Blocks.cell_succ]
    funext j
    change Rule30Jen.rule (Rule30Jen.cell t (j-1)) (Rule30Jen.cell t j) (Rule30Jen.cell t (j+1)) = _
    rw [ih]
    rfl

def ringStep (r : Nat) : Nat :=
  let left := (r >>> 1) ||| ((r % 2) <<< 727)
  let right := ((r <<< 1) % 2^728) ||| (r >>> 727)
  left ^^^ (r ||| right)

def ringRow : Nat → Nat
  | 0 => 0x4a843e23d80b43315d28d22c4c8cbcb1c91d493e121ef07d82ace05d4af8cbd0613b58bbe5fa2a2c4fdca7049d4be6351f8a790202b9d3453633dc8a5b09704a8212362ae02b4013e0e9dda36caa799b42cd23359e17d53731864a
  | t+1 => ringStep (ringRow t)

def planes : Array Nat := ((List.range 14).map ringRow).toArray

def tile (t d : Nat) : Bool := (planes.getD (t%14) 0).testBit (d%728)

private theorem tile_inv (t d : Nat) :
    tile t (d+2) = xor (tile (t+1) (d+1)) (tile t (d+1) || tile t d) := by
  have check : ∀ i : Fin 14, ∀ j : Fin 728,
      tile i (j.val+2) = xor (tile (i.val+1) (j.val+1)) (tile i (j.val+1) || tile i j) := by
    decide +kernel
  have h := check ⟨t%14,by omega⟩ ⟨d%728,by omega⟩
  simpa only [tile,Nat.mod_add_mod,Nat.mod_mod] using h

private theorem wall_inv (t : Nat) :
    tile t 2 = xor (tile (t+1) 1) (tile t 1 || false) := by
  have check : ∀ i : Fin 14, tile i 2 = xor (tile (i.val+1) 1) (tile i 1 || false) := by decide +kernel
  simpa only [tile,Nat.mod_add_mod,Nat.mod_mod] using check ⟨t%14,by omega⟩

private theorem tile_even (q : Nat) : tile (2*q) 1 = !word7.getD ((6+q)%7) false := by
  have check : ∀ i : Fin 7, tile (2*i.val) 1 = !word7.getD ((6+i.val)%7) false := by decide +kernel
  have h := check ⟨q%7,by omega⟩
  change tile (2*(q%7)) 1 = !word7.getD ((6+q%7)%7) false at h
  unfold tile at h ⊢
  simpa only [show (2*(q%7))%14 = (2*q)%14 by omega, Nat.add_mod_mod] using h

private theorem tile_odd (q : Nat) : tile (2*q+1) 1 = true := by
  have check : ∀ i : Fin 7, tile (2*i.val+1) 1 = true := by decide +kernel
  have h := check ⟨q%7,by omega⟩
  change tile (2*(q%7)+1) 1 = true at h
  unfold tile at h ⊢
  simpa only [show (2*(q%7)+1)%14 = (2*q+1)%14 by omega] using h

private def edge7 (j : Nat) := (123 : Nat).testBit j

private theorem low (x : Nat) :
    Rule30Blocks.F x % 2^8 = Rule30Blocks.F (x%2^8) % 2^8 := by
  simp only [Rule30Blocks.F, Nat.xor_mod_two_pow, Nat.or_mod_two_pow,
    Nat.shiftLeft_eq, Nat.mod_mul_mod, Nat.mod_mod]

private theorem odd_plane (n : Nat) : Rule30Blocks.plane (3+2*n) % 256 = 246 := by
  induction n with
  | zero => decide +kernel
  | succ n ih =>
    change Rule30Blocks.plane (3+2*(n+1)) % 256 = 246
    rw [show 3+2*(n+1) = (3+2*n)+1+1 by omega, Rule30Blocks.plane, Rule30Blocks.plane]
    have inner := low (Rule30Blocks.plane (3+2*n))
    change Rule30Blocks.F _ % 256 = Rule30Blocks.F (_ % 256) % 256 at inner
    rw [ih] at inner
    exact (low (Rule30Blocks.F (Rule30Blocks.plane (3+2*n)))).trans (by
      change Rule30Blocks.F (Rule30Blocks.F (Rule30Blocks.plane (3+2*n)) % 256) % 256 = 246
      rw [inner]
      decide +kernel)



private theorem near_all (R : Nat → Bool) {s0 k : Nat} (hk : k < 7)
    (entry : winW 30 R (2*s0+1) ∈ cls 30 lock7Codes k) (t : Nat) :
    zrow (Psi R) (2*s0+1+t) 1 = tile (2*(k+1)+t) 1 := by
  rw [Psi_col]
  by_cases h : t % 2 = 0
  · obtain ⟨q,rfl⟩ : ∃ q,t=2*q := ⟨t/2,by omega⟩
    rw [show 2*s0+1+2*q=2*(s0+q)+1 by omega, alt_odd,
        u_of_lock (V:=29) lock7_ok (by decide) R (s0:=s0) hk entry,
        show 2*(k+1)+2*q=2*((k+1)+q) by omega, tile_even]
    rw [show (6+(k+1+q))%7=(k+q)%7 by omega]
  · obtain ⟨q,rfl⟩ : ∃ q,t=2*q+1 := ⟨t/2,by omega⟩
    rw [show 2*s0+1+(2*q+1)=2*(s0+q+1) by omega, alt_even,
        show 2*(k+1)+(2*q+1)=2*(k+1+q)+1 by omega, tile_odd]

theorem all_locked_tile (R : Nat → Bool) {s0 k : Nat} (hk : k < 7)
    (entry : winW 30 R (2*s0+1) ∈ cls 30 lock7Codes k) (d t : Nat) :
    zrow (Psi R) (2*s0+1+t) (d+1) = tile (2*(k+1)+t) (d+1) := by
  have pair : ∀ j, (∀ s, zrow (Psi R) (2*s0+1+s) (j+1) = tile (2*(k+1)+s) (j+1)) ∧
      (∀ s, zrow (Psi R) (2*s0+1+s) (j+2) = tile (2*(k+1)+s) (j+2)) := by
    intro j
    induction j with
    | zero =>
      refine ⟨near_all R hk entry,fun s => ?_⟩
      rw [zrow_inv (Psi R) (2*s0+1+s) 0, zrow_wall]
      simp only [Nat.zero_add,show 2*s0+1+s+1=2*s0+1+(s+1) by omega, near_all R hk entry,
        show 2*(k+1)+(s+1)=2*(k+1)+s+1 by omega,wall_inv]
    | succ j ih =>
      refine ⟨ih.2,fun s => ?_⟩
      rw [zrow_inv (Psi R) (2*s0+1+s) (j+1), show 2*s0+1+s+1=2*s0+1+(s+1) by omega,
          ih.2,ih.2,ih.1, show 2*(k+1)+(s+1)=2*(k+1)+s+1 by omega, tile_inv (2*(k+1)+s) (j+1)]
  exact (pair d).1 t

set_option maxRecDepth 8192 in
set_option maxHeartbeats 20000000 in
private theorem uniform_table : ∀ e : Fin 7, ∀ a : Fin 364, ∃ j : Fin 7,
    tile (2*e.val) (7+2*a.val-j.val) ≠ edge7 j.val := by decide +kernel

private theorem any_odd_alignment (e a : Nat) : ∃ j : Fin 7,
    tile (2*e) (7+2*a-j.val) ≠ edge7 j.val := by
  obtain ⟨j,h⟩ := uniform_table ⟨e%7,by omega⟩ ⟨a%364,by omega⟩
  refine ⟨j,?_⟩
  have hj:=j.isLt
  change tile (2*(e%7)) (7+2*(a%364)-j.val) ≠ edge7 j.val at h
  unfold tile at h ⊢
  simpa only [show (2*(e%7))%14=(2*e)%14 by omega,
    show (7+2*(a%364)-j.val)%728=(7+2*a-j.val)%728 by omega] using h

private theorem actual_edge (a : Nat) (j : Fin 7) :
    Rule30Jen.cell (7+2*a) ((j.val : Int) - ((7+2*a : Nat) : Int)) = edge7 j.val := by
  rw [seed_eq, Rule30Blocks.cell_eq _ _ (by omega)]
  have addr : (((j.val : Int) - ((7+2*a : Nat) : Int)) + ((7+2*a : Nat) : Int)+1).toNat = j.val+1 := by omega
  rw [addr]
  have lowbit := Nat.testBit_mod_two_pow (Rule30Blocks.plane (7+2*a)) 8 (j.val+1)
  have bb : j.val+1 < 8 := by have := j.isLt; omega
  simp [bb] at lowbit
  have p := odd_plane (2+a)
  rw [show 3+2*(2+a)=7+2*a by omega] at p
  have actual : (Rule30Blocks.plane (7+2*a) % 256).testBit (j.val+1) = (246 : Nat).testBit (j.val+1) :=
    congrArg (fun z : Nat => z.testBit (j.val+1)) p
  have table : ∀ i : Fin 7, (246 : Nat).testBit (i.val+1) = edge7 i.val := by decide
  exact lowbit.symm.trans (actual.trans (table j))

theorem all_lock7_miss_seven {R : Nat → Bool} {s0 k : Nat} (hk : k < 7)
    (entry : winW 30 R (2*s0+1) ∈ cls 30 lock7Codes k) (n a : Nat) :
    ∃ j : Fin 7, zrow (Psi R) (2*s0+1+2*n) (7+2*a-j.val) ≠
      Rule30Jen.cell (7+2*a) ((j.val : Int) - ((7+2*a : Nat) : Int)) := by
  obtain ⟨j,miss⟩ := any_odd_alignment (k+1+n) a
  refine ⟨j,?_⟩
  have hj:=j.isLt
  have eq:=all_locked_tile R hk entry (7+2*a-j.val-1) (2*n)
  rw [show 7+2*a-j.val-1+1 = 7+2*a-j.val by omega,
      show 2*(k+1)+2*n=2*(k+1+n) by omega] at eq
  rw [eq,actual_edge]
  exact miss

open Rule30SidewaysLocks Rule30PlantedSurvivor Rule30StripCertificates

def forcesWithin (target : List Bool → Prop) : Nat → List Bool → Prop
  | 0, w => target w
  | n+1, w => target w ∨ ∀ a b : Bool, forcesWithin target n (dstep w a b)

theorem forcesWithin_reaches (R : Nat → Bool) (W : Nat) (target : List Bool → Prop)
    (n t : Nat) (odd : t%2=1) (h : forcesWithin target n (winW W R t)) :
    ∃ j ≤ n, target (winW W R (t+2*j)) := by
  induction n generalizing t with
  | zero => exact ⟨0, by omega, by simpa [forcesWithin] using h⟩
  | succ n ih =>
    rcases h with now | next
    · exact ⟨0, by omega, by simpa using now⟩
    · have step : forcesWithin target n (winW W R (t+2)) := by
        rw [winW_dstep W R t odd]
        exact next _ _
      obtain ⟨j, hj, hit⟩ := ih (t+2) (by omega) step
      exact ⟨j+1, by omega, by simpa only [show t+2*(j+1)=t+2+2*j by omega] using hit⟩

private theorem take_seg : ∀ k W, k ≤ W → ∀ f : Nat → Bool, (seg f W).take k = seg f k
  | 0, _, _, _ => rfl
  | k+1, W+1, hk, f => by
    change f 0 :: (seg (fun i => f (i+1)) W).take k = f 0 :: seg (fun i => f (i+1)) k
    rw [take_seg k W (by omega)]

theorem winW_take (R : Nat → Bool) (t k W : Nat) (hk : k ≤ W) :
    (winW W R t).take k = winW k R t := take_seg k W hk _

def lockTarget (w : List Bool) : Prop := ∃ k : Fin 7, w.take 30 ∈ cls 30 lock7Codes k.val

/-- Check all W+1-bit completions of a black-time m-bit prefix at a chosen W≥30.
Rank n bounds lock entry by physical tick 1+2*n. -/
theorem prefix_forces_lock {W m c n : Nat} (hW : 30 ≤ W) (hm : m ≤ W+1)
    (cert : ∀ q, q < 2^(W+1) → (∀ i, i<m → q.testBit i = c.testBit i) →
      forcesWithin lockTarget n (Rule30GateTrap.evolve 0 1 (decodeW (W+1) q)))
    (R : Nat → Bool) (hPrefix : ∀ i, i<m → R (i+1) = c.testBit i) :
    ∃ j ≤ n, ∃ k : Fin 7, winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val := by
  let q := enc (W+1) (fun i => R (i+1))
  have bit : ∀ i, i < W+1 → R (i+1) = q.testBit i := by
    intro i hi
    simp [q,testBit_enc,hi]
  have init := winW_prefix (R:=R) (W:=W) (t0:=1) bit
  have good := cert q (enc_lt _ _) (fun i hi => (bit i (by omega)).symm.trans (hPrefix i hi))
  rw [←init] at good
  obtain ⟨j,hj,k,hit⟩ := forcesWithin_reaches R W lockTarget n 1 (by decide) good
  exact ⟨j,hj,k,by rwa [winW_take R (1+2*j) 30 W hW] at hit⟩

open Rule30SidewaysLocks Rule30PlantedSurvivor
/-- Any succession of window sets closed under all four physical double steps forces entry at the deadline. -/
theorem reach_layers (R : Nat → Bool) (W t n : Nat) (odd : t%2=1)
    (layers : Nat → List (List Bool)) (start : winW W R t ∈ layers 0)
    (check : ∀ i, i<n → (layers i).all (succIn (layers (i+1))) = true) :
    winW W R (t+2*n) ∈ layers n := by
  have go : ∀ i, i≤n → winW W R (t+2*i) ∈ layers i := by
    intro i
    induction i with
    | zero => intro; simpa using start
    | succ i ih =>
      intro hi
      have here := ih (by omega)
      have step := List.all_eq_true.mp (check i (by omega)) _ here
      rw [show t+2*(i+1)=(t+2*i)+2 by omega,winW_dstep W R (t+2*i) (by omega)]
      exact succIn_spec step _ _
  exact go n (by omega)

def pattern (p : Fin 3) : Nat := [22371903, 22398427, 22373728].getD p.val 0
def lockPhase (p : Fin 3) : Nat := [5, 0, 6].getD p.val 0
private def codes : List (List (List Nat)) := [[[22364992, 55919424, 89473856, 156582720, 223691584, 257246016, 290800448, 357909312, 425018176, 458572608, 492127040, 525681472, 559235904, 592790336, 626344768, 693453632, 760562496, 794116928, 827671360, 861225792, 894780224, 961889088, 995443520, 1028997952, 1062552384], [22363441, 55917873, 89472305, 156581169, 223690033, 290798897, 357907761, 458571057, 492125489, 525679921, 559234353, 592788785, 626343217, 693452081, 760560945, 794115377, 827669809, 861224241, 894778673, 995441969, 1028996401, 1062550833], [22309960, 55864392, 89418824, 156527688, 223636552, 357854280, 492072008, 525626440, 559180872, 592735304, 626289736, 693398600, 760507464, 794061896, 861170760, 894725192, 1028942920, 1062497352], [22198791, 55753223, 89307655, 223525383, 357743111, 491960839, 559069703, 592624135, 626178567, 760396295, 861059591, 894614023, 1028831751], [88267166, 222484894, 356702622, 490920350, 625138078, 759355806, 893573534, 1027791262], [87814708, 222032436, 356250164, 624685620, 758903348, 893121076, 1027338804]], [[22309960, 55864392, 89418824, 156527688, 223636552, 257190984, 290745416, 357854280, 424963144, 458517576, 492072008, 525626440, 559180872, 592735304, 626289736, 693398600, 760507464, 794061896, 827616328, 861170760, 894725192, 961834056, 995388488, 1028942920, 1062497352], [22198791, 55753223, 89307655, 156416519, 223525383, 290634247, 357743111, 458406407, 491960839, 525515271, 559069703, 592624135, 626178567, 693287431, 760396295, 793950727, 827505159, 861059591, 894614023, 995277319, 1028831751, 1062386183], [21158302, 54712734, 88267166, 155376030, 222484894, 356702622, 490920350, 524474782, 558029214, 591583646, 625138078, 692246942, 759355806, 792910238, 860019102, 893573534, 1027791262, 1061345694], [20705844, 54260276, 87814708, 222032436, 356250164, 490467892, 557576756, 591131188, 624685620, 758903348, 859566644, 893121076, 1027338804], [75243858, 209461586, 343679314, 477897042, 612114770, 746332498, 880550226, 1014767954], [46898496, 181116224, 315333952, 583769408, 717987136, 852204864, 986422592]], [[22363441, 55917873, 89472305, 156581169, 223690033, 257244465, 290798897, 357907761, 425016625, 458571057, 492125489, 525679921, 559234353, 592788785, 626343217, 693452081, 760560945, 794115377, 827669809, 861224241, 894778673, 961887537, 995441969, 1028996401, 1062550833], [22309960, 55864392, 89418824, 156527688, 223636552, 290745416, 357854280, 458517576, 492072008, 525626440, 559180872, 592735304, 626289736, 693398600, 760507464, 794061896, 827616328, 861170760, 894725192, 995388488, 1028942920, 1062497352], [22198791, 55753223, 89307655, 156416519, 223525383, 357743111, 491960839, 525515271, 559069703, 592624135, 626178567, 693287431, 760396295, 793950727, 861059591, 894614023, 1028831751, 1062386183], [21158302, 54712734, 88267166, 222484894, 356702622, 490920350, 558029214, 591583646, 625138078, 759355806, 860019102, 893573534, 1027791262], [87814708, 222032436, 356250164, 490467892, 624685620, 758903348, 893121076, 1027338804], [75243858, 209461586, 343679314, 612114770, 746332498, 880550226, 1014767954]]]
private def layer (p : Fin 3) (i : Nat) : List (List Bool) :=
  ((codes.getD p.val []).getD i []).map (decodeW 30)
set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
private theorem first_checked : ∀ p : Fin 3, ∀ hi : Fin 64,
    Rule30GateTrap.evolve 0 1 (decodeW 31 (pattern p + 2^25*hi.val)) ∈ layer p 0 := by decide +kernel

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
private theorem steps_checked : ∀ p : Fin 3, ∀ i : Fin 5,
    (layer p i.val).all (succIn (layer p (i.val+1))) = true := by decide +kernel

private theorem final_checked : ∀ p : Fin 3,
    (layer p 5).all (fun w => (cls 30 lock7Codes (lockPhase p)).contains w) = true := by decide +kernel

theorem prefix25_enters {R : Nat → Bool} (p : Fin 3)
    (hPrefix : ∀ i,i<25 → R (i+1) = (pattern p).testBit i) :
    winW 30 R 11 ∈ cls 30 lock7Codes (lockPhase p) := by
  let bits := fun i => R (i+1)
  let c := enc 31 bits
  have bound := enc_lt 31 bits
  have lo : c % 2^25 = pattern p := by
    apply Nat.eq_of_testBit_eq
    intro i
    rw [Nat.testBit_mod_two_pow]
    by_cases h : i<25
    · simp only [h,decide_true,Bool.true_and,c,testBit_enc,show i<31 by omega,decide_true,Bool.true_and]
      exact hPrefix i h
    · have h2 : pattern p < 2^25 := (by decide : ∀ z : Fin 3,pattern z < 2^25) p
      have pow : 2^25 ≤ 2^i := Nat.pow_le_pow_right (by decide) (by omega)
      simp [h,Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le h2 pow)]
  have e : winW 30 R 1 = Rule30GateTrap.evolve 0 1 (decodeW 31 c) := by
    apply winW_prefix
    intro i hi
    simp only [bits,c,testBit_enc, show i<31 by omega,decide_true,Bool.true_and]
  let h : Fin 64 := ⟨c/2^25,by dsimp [c];omega⟩
  have eq : pattern p + 2^25*h.val=c := by dsimp [h];omega
  have z := first_checked p h
  rw [eq,←e] at z
  have r := reach_layers R 30 1 5 (by decide) (layer p) z
    (fun i hi => steps_checked p ⟨i,hi⟩)
  exact List.contains_iff_mem.mp (List.all_eq_true.mp (final_checked p) _ r)

theorem prefix25_miss {R : Nat → Bool} (p : Fin 3)
    (hPrefix : ∀ i,i<25 → R (i+1) = (pattern p).testBit i) (n a : Nat) :
    ∃ j : Fin 7, Rule30ZeroBoundary.zrow (Rule30PeriodTwoSideways.Psi R) (11+2*n) (7+2*a-j.val) ≠
      Rule30Jen.cell (7+2*a) ((j.val : Int) - ((7+2*a : Nat) : Int)) :=
  all_lock7_miss_seven (s0:=5) ((by decide : ∀ z : Fin 3, lockPhase z < 7) p)
    (prefix25_enters p hPrefix) n a

open Rule30SidewaysLocks Rule30PeriodTwoSideways Rule30ZeroBoundary
set_option maxRecDepth 20000 in
set_option maxHeartbeats 80000000 in
private theorem edge_deadline_table : ∀ e : Fin 14, ∀ a : Fin 728,
    ∃ j : Fin 9, tile (e.val+j.val) (a.val+j.val) = false := by decide +kernel

private theorem edge_deadline_at (e a : Nat) :
    ∃ j : Fin 9, tile (e+j.val) (a+j.val) = false := by
  obtain ⟨j, hit⟩ := edge_deadline_table ⟨e%14, by omega⟩ ⟨a%728, by omega⟩
  exact ⟨j, by simpa only [tile, Nat.mod_add_mod] using hit⟩

/-- After entry in any lock class, the outermost moving singleton cell alone
detects a mismatch in nine consecutive physical ticks, starting at any later
tick and at any positive absolute age. Both parities are covered. -/
theorem one_cell_within_nine {R : Nat → Bool} {s0 k : Nat} (hk : k < 7)
    (entry : winW 30 R (2*s0+1) ∈ cls 30 lock7Codes k) (t A : Nat) (age : 0 < A) :
    ∃ j : Fin 9, zrow (Psi R) (2*s0+1+t+j.val) (A+j.val) ≠
      Rule30Jen.cell (A+j.val) (-((A+j.val : Nat) : Int)) := by
  obtain ⟨j, hit⟩ := edge_deadline_at (2*(k+1)+t) A
  refine ⟨j, ?_⟩
  have row := all_locked_tile R hk entry (A+j.val-1) (t+j.val)
  rw [show A+j.val-1+1 = A+j.val by omega] at row
  rw [Nat.add_assoc (2*s0+1) t j.val, row, ← Nat.add_assoc (2*(k+1)) t j.val,
      hit, Rule30Jen.cell_left_edge]
  decide

/-- Eight successive agreements occur for an explicit ring phase and edge depth. -/
theorem eight_agreements_on_tile :
    (∀ j : Fin 8, tile j.val (196+j.val) = true) ∧ tile 8 204 = false := by decide +kernel

end Ruliology.CellularAutomata.Rule30Lock7Prefixes
