module
public import Ruliology.CellularAutomata.Rule30SourceObservables

/-! Compress the three run-end signals of Condrey's four-cell band by keeping
the position of the leftmost or rightmost active signal (zero for none).
The fifth cell is retained in the evolution so overlapping steps agree. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30SourcePriority
open Rule30Jen
abbrev Window := Fin 32
def mk5 (a b c d e : Bool) : Window :=
  Fin.ofNat 32 (a.toNat+2*b.toNat+4*c.toNat+8*d.toNat+16*e.toNat)
def bit (s : Window) (i : Nat) := s.val.testBit i
def step (s : Window) (l r : Bool) := mk5 (rule l (bit s 0) (bit s 1))
  (rule (bit s 0) (bit s 1) (bit s 2)) (rule (bit s 1) (bit s 2) (bit s 3))
  (rule (bit s 2) (bit s 3) (bit s 4)) (rule (bit s 3) (bit s 4) r)
def tag (rightmost : Bool) (s : Window) : Nat :=
  let a := Rule30SourceObservables.source (bit s 0) (bit s 1)
  let b := Rule30SourceObservables.source (bit s 1) (bit s 2)
  let c := Rule30SourceObservables.source (bit s 2) (bit s 3)
  if rightmost then (if c then 3 else if b then 2 else if a then 1 else 0)
  else (if a then 1 else if b then 2 else if c then 3 else 0)
def Walk (x : Nat → Window) := ∀ t, ∃ l r, x (t+1)=step (x t) l r

private def member (a : Array Nat) (x y : Window) := (a.getD x.val 0).testBit y.val
private def forward0 : Array Nat := #[869216463, 869216463, 4294963455, 4294963455, 4294770684, 4294770684, 4294918143, 4294918143, 4294954992, 4294954992, 4294954992, 4294954992, 4294963455, 4294963455, 4294967100, 4294967100, 4291821519, 4291821519, 4294967295, 4294967295, 4294770684, 4294770684, 4294967295, 4294967295, 4294967295, 4294967295, 4294967292, 4294967292, 4294967295, 4294967295, 4294967292, 4294967292]
private def back0 : Array (Array Nat) := #[
  #[4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295],
  #[3506557185, 572662306, 202116108, 202116108, 13631696, 572662306, 13631696, 13631696, 3506557185, 572662306, 202116108, 202116108, 3506557185, 572662306, 3506557185, 3506557185, 3506557185, 572662306, 202116108, 202116108, 13631696, 572662306, 13631696, 13631696, 3506557185, 572662306, 202116108, 202116108, 3506557185, 572662306, 3506557185, 3506557185],
  #[2164359425, 131074, 12, 134744076, 8388752, 572531232, 4194368, 8388752, 2164359425, 33554976, 67109888, 135006216, 268439552, 538976288, 1073758208, 2164359425, 2164359425, 131074, 135006208, 135006216, 1048576, 538976288, 4194368, 8388752, 2164359425, 33554976, 67109888, 135006216, 268439552, 538976288, 1073758208, 2164359425],
  #[2147581953, 131074, 12, 134744076, 8388752, 538976288, 4194368, 8388752, 16777472, 33554944, 67109888, 134481928, 268439552, 538976288, 1073758208, 2147581953, 2147581953, 131074, 134481920, 524296, 1048576, 538976288, 4194368, 8388752, 16777472, 33554944, 67109888, 134481928, 268439552, 538976288, 1073758208, 2147581953],
  #[2147516417, 131074, 12, 524300, 8388624, 538976288, 4194368, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417, 65536, 131074, 262144, 524296, 1048576, 538976288, 4194368, 8388624, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417],
  #[2147516417, 2, 12, 524300, 16, 538976288, 64, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417, 65536, 131072, 262144, 524296, 1048576, 538976288, 4194304, 8388608, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417],
  #[2147516417, 2, 4, 524296, 16, 538976288, 64, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417, 65536, 131072, 262144, 524296, 1048576, 538976288, 4194304, 8388608, 16777472, 33554944, 67109888, 134219776, 268439552, 538976288, 1073758208, 2147516417]]
private def forward1 : Array Nat := #[869216463, 869216463, 4294963455, 4294963455, 4294758396, 4294758396, 4294918143, 4294918143, 4294967280, 4294967280, 4294967280, 4294967280, 4294967247, 4294967247, 4294967100, 4294967100, 4294967247, 4294967247, 4294967295, 4294967295, 4294967292, 4294967292, 4294967295, 4294967295, 4294967295, 4294967295, 4294967292, 4294967292, 4294967295, 4294967295, 4294967292, 4294967292]
private def back1 : Array (Array Nat) := #[
  #[4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295],
  #[3506557185, 570565122, 202116108, 202116108, 15728880, 15728880, 15728880, 15728880, 3506557185, 570565122, 202116108, 202116108, 3506557185, 570565122, 3506557185, 3506557185, 3506557185, 570565122, 202116108, 202116108, 15728880, 15728880, 15728880, 15728880, 3506557185, 570565122, 202116108, 202116108, 3506557185, 570565122, 3506557185, 3506557185],
  #[2164359425, 131074, 12, 12, 8388784, 8388784, 4194368, 8388784, 2164359425, 33554944, 67109888, 135006208, 268439552, 536879104, 1073758208, 2164359425, 2164359425, 131074, 135006208, 135006208, 3145728, 3145728, 4194368, 8388784, 2164359425, 33554944, 67109888, 135006208, 268439552, 536879104, 1073758208, 2164359425],
  #[2147581953, 131074, 12, 12, 8388752, 32, 4194368, 8388752, 16777472, 33554944, 67109888, 134481920, 268439552, 536879104, 1073758208, 2147581953, 2147581953, 131074, 134481920, 524288, 1048576, 2097152, 4194368, 8388752, 16777472, 33554944, 67109888, 134481920, 268439552, 536879104, 1073758208, 2147581953],
  #[2147516417, 131074, 12, 12, 8388624, 32, 4194368, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417, 65536, 131074, 262144, 524288, 1048576, 2097152, 4194368, 8388624, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417],
  #[2147516417, 2, 12, 12, 16, 32, 64, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417],
  #[2147516417, 2, 4, 8, 16, 32, 64, 128, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777472, 33554944, 67109888, 134219776, 268439552, 536879104, 1073758208, 2147516417]]

private def F (m : Bool) (x y : Window) := member (if m then forward1 else forward0) x y
private def B (m : Bool) (k : Nat) (x y : Window) :=
  member ((if m then back1 else back0).getD k #[]) x y

set_option maxRecDepth 30000
set_option maxHeartbeats 0
private theorem beginF : ∀ (m : Bool) (x y : Window) (l r u v : Bool),
    tag m x=tag m y → F m (step x l r) (step y u v)=true := by decide +kernel
private theorem beginB : ∀ (m : Bool) (x y : Window), B m 0 x y=true := by decide +kernel
private theorem prevB : ∀ (m : Bool) (x y : Window), tag m x=tag m y →
    ∀ (l r u v : Bool) (k : Fin 6), B m k (step x l r) (step y u v)=true →
    B m (k.val+1) x y=true := by decide +kernel

private theorem back_sound (m : Bool) {x y : Nat → Window} (wx : Walk x) (wy : Walk y)
    (k : Nat) (hk : k≤6) (t : Nat) (eq : ∀ i, i<k → tag m (x (t+i))=tag m (y (t+i))) :
    B m k (x t) (y t)=true := by
  induction k generalizing t with
  | zero => exact beginB _ _ _
  | succ k ih =>
    obtain ⟨l,r,hx⟩ := wx t
    obtain ⟨u,v,hy⟩ := wy t
    have next := ih (by omega) (t+1) (fun i hi => by
      simpa only [show t+1+i=t+(i+1) by omega] using eq (i+1) (by omega))
    rw [hx,hy] at next
    exact prevB m _ _ (eq 0 (by omega)) l r u v ⟨k,by omega⟩ next

private theorem kernel_test (m : Bool) {x y : Nat → Window} (wx : Walk x) (wy : Walk y)
    (k : Nat) (hk : k≤6) (eq : ∀ i, i<k+1 → tag m (x i)=tag m (y i)) :
    F m (x 1) (y 1)=true ∧ B m k (x 1) (y 1)=true := by
  obtain ⟨l,r,hx⟩ := wx 0
  obtain ⟨u,v,hy⟩ := wy 0
  constructor
  · rw [show 1=0+1 by rfl,hx,hy]
    exact beginF m _ _ _ _ _ _ (eq 0 (by omega))
  · exact back_sound m wx wy k hk 1 (fun i hi => eq (1+i) (by omega))

/-- Five right-priority observations recover the two rightmost band cells at time one. -/
theorem right_pair {x y} (wx : Walk x) (wy : Walk y)
    (obs : ∀ i, i<5 → tag true (x i)=tag true (y i)) :
    bit (x 1) 2=bit (y 1) 2 ∧ bit (x 1) 3=bit (y 1) 3 := by
  obtain ⟨f,b⟩ := kernel_test true wx wy 4 (by decide) obs
  exact (by decide +kernel : ∀ a c : Window, F true a c=true → B true 4 a c=true →
    bit a 2=bit c 2 ∧ bit a 3=bit c 3) _ _ f b

/-- Six readings of either priority recover the middle pair. -/
theorem middle_pair (m : Bool) {x y} (wx : Walk x) (wy : Walk y)
    (obs : ∀ i, i<6 → tag m (x i)=tag m (y i)) :
    bit (x 1) 1=bit (y 1) 1 ∧ bit (x 1) 2=bit (y 1) 2 := by
  obtain ⟨f,b⟩ := kernel_test m wx wy 5 (by decide) obs
  exact (by decide +kernel : ∀ (o : Bool) (a c : Window), F o a c=true → B o 5 a c=true →
    bit a 1=bit c 1 ∧ bit a 2=bit c 2) m _ _ f b

/-- Seven right-priority observations recover the entire four-cell band. -/
theorem right_four {x y} (wx : Walk x) (wy : Walk y)
    (obs : ∀ i, i<7 → tag true (x i)=tag true (y i)) :
    (x 1).val%16=(y 1).val%16 := by
  obtain ⟨f,b⟩ := kernel_test true wx wy 6 (by decide) obs
  exact (by decide +kernel : ∀ a c : Window, F true a c=true → B true 6 a c=true →
    a.val%16=c.val%16) _ _ f b

end Ruliology.CellularAutomata.Rule30SourcePriority
