/- Build this extension inside the sealed S23 namespace with build_three_step_wall.py. -/
/-! Three arbitrary inverse layers. The six-bit state stores two adjacent cells
of each of the three predecessor rows. They advance simultaneously west. -/

private structure InverseState where
  a : Bool
  aRight : Bool
  b : Bool
  bRight : Bool
  c : Bool
  cRight : Bool
  deriving DecidableEq

private def zeroState : InverseState := ⟨false,false,false,false,false,false⟩

private def stateAt (a b c : Int → Bool) (p : Int) : InverseState :=
  ⟨a p,a (p+1),b p,b (p+1),c p,c (p+1)⟩

private def inverseTick (pixel : Bool) (s : InverseState) : InverseState :=
  ⟨xor pixel (s.a || s.aRight),s.a,
   xor s.a (s.b || s.bRight),s.b,
   xor s.b (s.c || s.cRight),s.c⟩

private theorem inverseBit {src dst : Int → Bool}
    (eq : ∀ p, p < 0 → stepLine src p = dst p) {p : Int} (hp : p < 0) :
    src (p-1) = xor (dst p) (src p || src (p+1)) := by
  rw [← eq p hp]
  unfold stepLine rule
  cases src (p-1) <;> cases src p <;> cases src (p+1) <;> rfl

private theorem inv_state_step {a b c y : Int → Bool}
    (ha : ∀ p, p < 0 → stepLine a p = y p)
    (hb : ∀ p, p < 0 → stepLine b p = a p)
    (hc : ∀ p, p < 0 → stepLine c p = b p) {p : Int} (hp : p < 0) :
    stateAt a b c (p-1) = inverseTick (y p) (stateAt a b c p) := by
  simp only [stateAt, inverseTick, show p-1+1=p by omega,
    inverseBit ha hp, inverseBit hb hp, inverseBit hc hp]

private def inverseScan (v : Nat) (q : InverseState) : Nat → InverseState
  | 0 => q
  | n+1 => inverseTick (v.testBit (n+1)) (inverseScan v q n)

private theorem inv_scan_sound {a b c y : Int → Bool}
    (ha : ∀ p, p < 0 → stepLine a p = y p)
    (hb : ∀ p, p < 0 → stepLine b p = a p)
    (hc : ∀ p, p < 0 → stepLine c p = b p)
    (f : Int) (interior : f+27 < 0) (n : Nat) (hn : n≤28) :
    inverseScan (band y f 29) (stateAt a b c (f+27)) n =
    stateAt a b c (f+27-(n:Int)) := by
  induction n with
  | zero => simp [inverseScan]
  | succ n ih =>
    rw [inverseScan, ih (by omega), testBit_band_lt _ _ _ _ (by omega)]
    rw [show f+(29:Nat)-1-((n+1:Nat):Int)=f+27-(n:Int) by omega,
        show f+27-((n+1:Nat):Int)=f+27-(n:Int)-1 by omega]
    exact (inv_state_step ha hb hc (by omega)).symm

private def readsEdge (v : Nat) (q : InverseState) : Bool :=
  let s := inverseScan v q 24
  let s2 := inverseTick (v.testBit 25) s
  let s1 := inverseTick (v.testBit 26) s2
  let s0 := inverseTick (v.testBit 27) s1
  let west := inverseTick (v.testBit 28) s0
  s.c && !s2.c && !s1.c && !s0.c && decide (west = zeroState)

private theorem inverse_edge_of_band {a b c y : Int → Bool}
    (ha : ∀ p, p < 0 → stepLine a p = y p)
    (hb : ∀ p, p < 0 → stepLine b p = a p)
    (hc : ∀ p, p < 0 → stepLine c p = b p)
    (f : Int) (interior : f+27 < 0) (white : ∀ p, p<f → y p=false)
    (accept : ∀ q, readsEdge (band y f 29) q = true) :
    c (f+3)=true ∧ ∀ p, p<f+3 → c p=false := by
  let q := stateAt a b c (f+27)
  have check := accept q
  change ((inverseScan (band y f 29) q 24).c &&
      !(inverseScan (band y f 29) q 25).c &&
      !(inverseScan (band y f 29) q 26).c &&
      !(inverseScan (band y f 29) q 27).c &&
      decide (inverseScan (band y f 29) q 28 = zeroState)) = true at check
  simp only [q, inv_scan_sound ha hb hc f interior _ (by decide : 24≤28),
    inv_scan_sound ha hb hc f interior _ (by decide : 25≤28),
    inv_scan_sound ha hb hc f interior _ (by decide : 26≤28),
    inv_scan_sound ha hb hc f interior _ (by decide : 27≤28),
    inv_scan_sound ha hb hc f interior _ (by decide : 28≤28)] at check
  simp only [Bool.and_eq_true, decide_eq_true_eq,
    show f+27-(24:Nat)=f+3 by omega, show f+27-(25:Nat)=f+2 by omega,
    show f+27-(26:Nat)=f+1 by omega, show f+27-(27:Nat)=f by omega,
    show f+27-(28:Nat)=f-1 by omega] at check
  obtain ⟨⟨⟨⟨black,h2⟩,h1⟩,h0⟩,west⟩ := check
  have farther (n : Nat) : stateAt a b c (f-1-(n:Int)) = zeroState := by
    induction n with
    | zero => simpa using west
    | succ n ih =>
      rw [show f-1-((n+1:Nat):Int)=f-1-(n:Int)-1 by omega,
          inv_state_step ha hb hc (by omega), ih, white _ (by omega)]
      rfl
  refine ⟨black,fun p hp => ?_⟩
  by_cases h : p<f
  · have e : f-1-(((f-1-p).toNat:Nat):Int)=p := by omega
    exact congrArg InverseState.c (e ▸ farther (f-1-p).toNat)
  · have ix : p=f ∨ p=f+1 ∨ p=f+2 := by omega
    rcases ix with rfl | rfl | rfl
    · simpa [stateAt] using h0
    · simpa [stateAt] using h1
    · simpa [stateAt] using h2

private theorem apply_cover (width depth extra ticks : Nat) (old new : List Nat)
    (valid : ∀ d : Fin (width+1-depth),
      old.all (fun head => checkStage new.contains width (d.val+depth) head extra ticks) = true)
    (fits : depth ≤ width) (d u : Nat) (hd : depth ≤ d) (hc : old.contains (u >>> extra) = true) :
    new.contains (runFast width d u ticks) = true := by
  rw [clamp_depth]
  have hmin : depth ≤ min d width := Nat.le_min.mpr ⟨hd,fits⟩
  let i : Fin (width+1-depth) := ⟨min d width-depth, by have := Nat.min_le_right d width; omega⟩
  have eig : i.val+depth=min d width := by dsimp [i]; omega
  have good := List.all_eq_true.mp (valid i) (u >>> extra) (List.contains_iff_mem.mp hc)
  rw [eig] at good
  exact apply_check _ _ _ _ _ _ _ rfl good

private def cover13 : List Nat := [6411, 6428, 7117, 7129]

private def cover20 : List Nat := [820676, 820677, 820678, 820679, 820680, 820681, 820683, 820686,
 820687, 822880, 822881, 822883, 822886, 822887, 822892, 822893,
 822894, 822895, 822904, 822905, 822906, 822908, 822909, 822911,
 910992, 910993, 910995, 910998, 910999, 911004, 911005, 911006,
 911007, 912608, 912609, 912610, 912611, 912612, 912613, 912616,
 912617, 912619, 912622]

private theorem certify20 : ∀ d : Fin 5,
    cover13.all (fun head => checkStage (cover20.contains) 20 (d.val+16) head 7 4) = true := by
  decide +kernel

private theorem advance20 (d u : Nat) (hd : 16 ≤ d) :
    cover13.contains (u >>> 7) = true →
    cover20.contains (runFast 20 d u 4) = true :=
  apply_cover 20 16 7 4 cover13 cover20 certify20 (by decide) d u hd

private def cover22 : List Nat := [3282726, 3282732, 3282733, 3282734, 3282735, 3291616, 3291617, 3291618,
 3291619, 3644020, 3644021, 3644030, 3650437, 3650438, 3650439, 3650440,
 3650441, 3650443, 3650446, 3650447]

private theorem certify22 : ∀ d : Fin 3,
    cover20.all (fun head => checkStage (cover22.contains) 22 (d.val+20) head 2 5) = true := by
  decide +kernel

private theorem advance22 (d u : Nat) (hd : 20 ≤ d) :
    cover20.contains (u >>> 2) = true →
    cover22.contains (runFast 22 d u 5) = true :=
  apply_cover 22 20 2 5 cover20 cover22 certify22 (by decide) d u hd

private def cover26 : List Nat := [52523730, 52523731, 52523732, 52523733, 52523735, 52523750, 52523757, 52665905,
 52665907, 52665910, 52665911, 52665916, 52665917, 52665918, 52665919, 58304324,
 58304325, 58304330, 58304331, 58304334, 58304335, 58407046, 58407047, 58407052,
 58407088, 58407089, 58407090, 58407092, 58407093, 58407094, 58407095]

private theorem certify26 : ∀ d : Fin 2,
    cover22.all (fun head => checkStage (cover26.contains) 26 (d.val+25) head 4 4) = true := by
  decide +kernel

private theorem advance26 (d u : Nat) (hd : 25 ≤ d) :
    cover22.contains (u >>> 4) = true →
    cover26.contains (runFast 26 d u 4) = true :=
  apply_cover 26 25 4 4 cover22 cover26 certify26 (by decide) d u hd

private def cover29 : List Nat := [420189862, 420189863, 420189868, 420189869, 420189870, 420189871, 420189884, 421327328,
 421327329, 421327336, 421327337, 421327338, 421327339, 421327340, 421327341, 466434640,
 466434641, 466434644, 466434645, 466434654, 467256708, 467256709, 467256710, 467256711,
 467256712, 467256713, 467256715, 467256718, 467256720]

private theorem certify29 : ∀ d : Fin 1,
    cover26.all (fun head => checkStage (cover29.contains) 29 (d.val+29) head 3 4) = true := by
  decide +kernel

private theorem advance29 (d u : Nat) (hd : 29 ≤ d) :
    cover26.contains (u >>> 3) = true →
    cover29.contains (runFast 29 d u 4) = true :=
  apply_cover 29 29 3 4 cover26 cover29 certify29 (by decide) d u hd

private theorem inverseCover : ∀ a ar b br c cr : Bool,
    cover29.all (fun band => readsEdge band ⟨a,ar,b,br,c,cr⟩) = true := by
  decide +kernel

/-- A sufficient age for three inverse layers, with the same adjacent-site offset as S23. -/
def threeTickThreshold (m : Nat) : Nat := threshold m + 23

private theorem band29_of_age (c : Nat → Bool) (s : Int → Bool) {m t : Nat}
    (hm : 0<m) (h₀ : ∀ p, p < -(m:Int) → s p=false) (h₁ : s (-(m:Int))=true)
    (ht : threeTickThreshold m≤t) :
    cover29.contains (band (L c s t) (edgePosition m t) 29) = true := by
  let q := t-23
  have base : threshold m ≤ q := by unfold threeTickThreshold at ht; dsimp [q]; omega
  have depth : 10 ≤ m+q := by unfold threshold at base; split at base <;> omega
  have h8 := good_band_of_age c s hm h₀ h₁ q base
  have h13 := band_after_restart 8 5 EdgeGood8 inC13 c s hm h₀ h₁ (by omega) 6 (by omega)
    (fun u => restart_table13 _ u depth) h8
  have eq13 (u : Nat) : cover13.contains u = inC13 u := by
    simp only [cover13, List.contains_cons, List.contains_nil, Bool.or_false, Bool.or_assoc, inC13]
  rw [← eq13] at h13
  have h20 := band_after_restart 13 7 cover13.contains cover20.contains c s hm h₀ h₁
    (by omega) 4 (by omega) (fun u => advance20 _ u (by omega)) h13
  have h22 := band_after_restart 20 2 cover20.contains cover22.contains c s hm h₀ h₁
    (by omega) 5 (by omega) (fun u => advance22 _ u (by omega)) h20
  have h26 := band_after_restart 22 4 cover22.contains cover26.contains c s hm h₀ h₁
    (by omega) 4 (by omega) (fun u => advance26 _ u (by omega)) h22
  have h29 := band_after_restart 26 3 cover26.contains cover29.contains c s hm h₀ h₁
    (by omega) 4 (by omega) (fun u => advance29 _ u (by omega)) h26
  have time : 23 ≤ t := by unfold threeTickThreshold at ht; omega
  have finish : q+6+4+5+4+4=t := by dsimp [q]; omega
  rwa [finish] at h29

/-- Three inverse ticks beside any prescribed wall. Every predecessor layer may
choose its own wall bit. The edge becomes exact at age 31 for m≥2 and at 32 for m=1. -/
theorem three_step_predecessor_edge (wall : Nat → Bool) (s a b c : Int → Bool) {m t : Nat}
    (hm : 0<m) (h₀ : ∀ p, p < -(m:Int) → s p=false) (h₁ : s (-(m:Int))=true)
    (ht : threeTickThreshold m≤t)
    (ha : ∀ p, p<0 → stepLine a p = L wall s t p)
    (hb : ∀ p, p<0 → stepLine b p = a p)
    (hc : ∀ p, p<0 → stepLine c p = b p) :
    c (edgePosition m t+3)=true ∧ ∀ p, p<edgePosition m t+3 → c p=false := by
  have depth : 33 ≤ m+t := by unfold threeTickThreshold threshold at ht; split at ht <;> omega
  have known := band29_of_age wall s hm h₀ h₁ ht
  apply inverse_edge_of_band ha hb hc (edgePosition m t) (by unfold edgePosition; omega)
    (edge_at wall s hm h₀ h₁ t).1
  intro q
  cases q with
  | mk a ar b br c cr =>
    exact List.all_eq_true.mp (inverseCover a ar b br c cr) _
      (List.contains_iff_mem.mp known)

/-! Two starts give the same image at depth 32. The adjacent start is a
one-tick delay of the other. The third predecessor has a black west tail. -/

def threeExampleDepth (adjacent : Bool) : Nat := if adjacent then 1 else 2
def threeExampleAge (adjacent : Bool) : Nat := if adjacent then 31 else 30

private def wall3 (adjacent : Bool) (t : Nat) : Bool :=
  (if adjacent then (0x325fb326 : Nat) else 0x192fd993).testBit t

private def seed3 (adjacent : Bool) (p : Int) : Bool :=
  decide (-((threeExampleDepth adjacent : Nat) : Int) ≤ p ∧ p < 0)

private def atDepth (u : Nat) (p : Int) : Bool := u.testBit (-p).toNat
private def knownImage (p : Int) : Bool := atDepth 6741236716 p
private def earlier1 (p : Int) : Bool := atDepth 3732015686 p
private def earlier2 (p : Int) : Bool := atDepth 1402727289 p
private def earlier3 (p : Int) : Bool :=
  if p≤-32 then true else atDepth 1557213517 p

private theorem depthWhite {u : Nat} (hu : u < 2^33) {p : Int} (hp : p≤-33) :
    atDepth u p = false := by
  apply Nat.testBit_lt_two_pow
  exact Nat.lt_of_lt_of_le hu (Nat.pow_le_pow_right (by decide) (by omega))

private theorem threeSeedBlack (ad : Bool) : seed3 ad (-(threeExampleDepth ad : Int))=true := by
  cases ad <;> decide

private theorem threeSeedWhite (ad : Bool) (p : Int) (hp : p < -(threeExampleDepth ad : Int)) :
    seed3 ad p=false := by
  simp [seed3,show ¬-(threeExampleDepth ad : Int)≤p by omega]

private theorem imthreeExampleAge_band (ad : Bool) :
    band (L (wall3 ad) (seed3 ad) (threeExampleAge ad)) (edgePosition (threeExampleDepth ad) (threeExampleAge ad)) 32
      = 3370618358 := by
  have fit : 32≤threeExampleDepth ad+threeExampleAge ad := by cases ad <;> decide
  have nz : 0<threeExampleDepth ad := by cases ad <;> decide
  rw [← fast_spec _ _ nz (threeSeedWhite ad) (threeSeedBlack ad) _ _ fit]
  cases ad <;> decide +kernel

private theorem example3_edge (ad : Bool) : edgePosition (threeExampleDepth ad) (threeExampleAge ad)=-32 := by
  cases ad <;> decide

private theorem imthreeExampleAge (ad : Bool) (p : Int) (hp : p<0) :
    L (wall3 ad) (seed3 ad) (threeExampleAge ad) p = knownImage p := by
  by_cases west : p < -32
  · rw [show knownImage p=false from depthWhite (u := 6741236716) (by decide) (by omega)]
    exact (edge_at _ _ (by cases ad <;> decide) (threeSeedWhite ad) (threeSeedBlack ad) _).1 _
      (by rw [example3_edge];exact west)
  · have hd : (-p-1).toNat < 32 := by omega
    have bit := testBit_band_lt (L (wall3 ad) (seed3 ad) (threeExampleAge ad))
      (edgePosition (threeExampleDepth ad) (threeExampleAge ad)) 32 (-p-1).toNat hd
    rw [imthreeExampleAge_band,example3_edge] at bit
    have e : -32+(32:Nat)-1-(((-p-1).toNat:Nat):Int)=p := by omega
    rw [e] at bit
    rw [← bit]
    change _ = (3370618358 <<< 1 : Nat).testBit (-p).toNat
    rw [Nat.testBit_shiftLeft]
    have he : 1 ≤ (-p).toNat := by omega
    simp only [he, decide_true, Bool.true_and]
    congr 1
    omega

private theorem inv3_middle : ∀ q : Fin 34,
    let p := -((q.val+1:Nat):Int)
    stepLine earlier1 p=knownImage p ∧ stepLine earlier2 p=earlier1 p ∧
    stepLine earlier3 p=earlier2 p := by decide +kernel

private theorem inv3_physical (p : Int) (hp : p<0) :
    stepLine earlier1 p=knownImage p ∧ stepLine earlier2 p=earlier1 p ∧
    stepLine earlier3 p=earlier2 p := by
  by_cases deep : p≤-35
  · have wY : knownImage p=false := depthWhite (by decide) (by omega)
    have wA (q : Int) (hq : q≤-33) : earlier1 q=false := depthWhite (by decide) hq
    have wB (q : Int) (hq : q≤-33) : earlier2 q=false := depthWhite (by decide) hq
    have bC (q : Int) (hq : q≤-32) : earlier3 q=true := by simp [earlier3,hq]
    simp [stepLine,wY,wA p (by omega),wA (p-1) (by omega),wA (p+1) (by omega),
      wB p (by omega),wB (p-1) (by omega),wB (p+1) (by omega),
      bC p (by omega),bC (p-1) (by omega),bC (p+1) (by omega),rule]
  · let j : Fin 34 := ⟨(-p-1).toNat,by omega⟩
    have e : -((j.val+1:Nat):Int)=p := by dsimp [j];omega
    simpa only [e] using inv3_middle j

/-- The ages just below the universal bounds fail even with all three wall bits fixed. -/
theorem sharp_three_step_examples (adjacent : Bool) :
    ∃ (wall : Nat → Bool) (s a b c : Int → Bool),
      s (-(threeExampleDepth adjacent : Int))=true ∧ (∀ p, p < -(threeExampleDepth adjacent : Int) → s p=false) ∧
      (∀ p, p<0 → stepLine a p=L wall s (threeExampleAge adjacent) p) ∧
      (∀ p, p<0 → stepLine b p=a p) ∧ (∀ p, p<0 → stepLine c p=b p) ∧
      a 0=wall (threeExampleAge adjacent-1) ∧ b 0=wall (threeExampleAge adjacent-2) ∧
      c 0=wall (threeExampleAge adjacent-3) ∧ c (-33)=true := by
  exact ⟨wall3 adjacent, seed3 adjacent, earlier1, earlier2, earlier3, threeSeedBlack adjacent,
    threeSeedWhite adjacent, fun p hp => (inv3_physical p hp).1.trans (imthreeExampleAge adjacent p hp).symm,
    fun p hp => (inv3_physical p hp).2.1,fun p hp => (inv3_physical p hp).2.2,
    by cases adjacent <;> decide,by cases adjacent <;> decide,
    by cases adjacent <;> decide,by decide⟩

/-- Uniform nonadjacent ages admit exactly the ages at least 31. -/
theorem three_tick_least_age_nonadjacent (age : Nat) :
    (∀ m : Nat, 2≤m → ∀ t, age≤t → ∀ (wall : Nat → Bool) (s a b c : Int → Bool),
      s (-(m:Int))=true → (∀ p, p < -(m:Int) → s p=false) →
      (∀ p, p<0 → stepLine a p=L wall s t p) →
      (∀ p, p<0 → stepLine b p=a p) → (∀ p, p<0 → stepLine c p=b p) →
      c (edgePosition m t+3)=true ∧ ∀ p, p<edgePosition m t+3 → c p=false) ↔ 31≤age := by
  constructor
  · intro h
    by_cases hAge : 31≤age
    · exact hAge
    · obtain ⟨wall,s,a,b,c,black,white,ha,hb,hc,_,_,_,bad⟩ := sharp_three_step_examples false
      have pos : (-33 : Int)<edgePosition 2 30+3 := by decide
      have eq := (h 2 (by decide) 30 (by omega) wall s a b c black white ha hb hc).2 _ pos
      rw [bad] at eq
      contradiction
  · intro h m hm t ht wall s a b c black white ha hb hc
    exact three_step_predecessor_edge wall s a b c (by omega) white black
      (by unfold threeTickThreshold threshold; simp [show m≠1 by omega];omega) ha hb hc

/-- With a seed next to the wall the least uniform age is 32. -/
theorem three_tick_least_age_adjacent (age : Nat) :
    (∀ t, age≤t → ∀ (wall : Nat → Bool) (s a b c : Int → Bool),
      s (-1)=true → (∀ p, p<(-1:Int) → s p=false) →
      (∀ p, p<0 → stepLine a p=L wall s t p) →
      (∀ p, p<0 → stepLine b p=a p) → (∀ p, p<0 → stepLine c p=b p) →
      c (edgePosition 1 t+3)=true ∧ ∀ p, p<edgePosition 1 t+3 → c p=false) ↔ 32≤age := by
  constructor
  · intro h
    by_cases hAge : 32≤age
    · exact hAge
    · obtain ⟨wall,s,a,b,c,black,white,ha,hb,hc,_,_,_,bad⟩ := sharp_three_step_examples true
      have pos : (-33 : Int)<edgePosition 1 31+3 := by decide
      have eq := (h 31 (by omega) wall s a b c black white ha hb hc).2 _ pos
      rw [bad] at eq
      contradiction
  · intro h t ht wall s a b c black white ha hb hc
    exact three_step_predecessor_edge wall s a b c (by decide) white black
      (by change 32≤t;omega) ha hb hc
