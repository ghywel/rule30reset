module
public import Ruliology.CellularAutomata.Rule30DrivenPrefix
public import Ruliology.CellularAutomata.Rule30GateTrap
public import Ruliology.CellularAutomata.Rule30StripCertificates
@[expose] public section
namespace Ruliology.CellularAutomata.PureThreeExit
open Rule30DrivenPrefix Rule30GateTrap

abbrev Grid := List (List Nat)

def fits (w : Nat) (r : Nat → Nat) (t : Nat) : Grid → Prop
  | [] => True
  | s :: ss => r t % 2^w ∈ s ∧ fits w r (t+1) ss

def successors (w x : Nat) : List Nat :=
  [0,1,2,3].map fun hi => double (x + hi * 2^w) % 2^w

theorem prefix_lift (x w : Nat) : x % 2^(w+1) ∈ [x%2^w, x%2^w+2^w] := by
  have pos := Nat.two_pow_pos w
  rw [Nat.pow_succ]
  have h := Nat.mod_add_div (x % (2^w*2)) (2^w)
  have b := Nat.mod_lt x (by omega : 0<2^w*2)
  have eq : x % (2^w*2) % 2^w = x % 2^w := Nat.mod_mod_of_dvd x ⟨2,rfl⟩
  rw [eq] at h
  have bound : x % (2^w*2) / 2^w < 2 :=
    (Nat.div_lt_iff_lt_mul pos).2 (by omega)
  have mem : x%(2^w*2)/2^w ∈ [0,1] := List.mem_range.mpr bound
  simp only [List.mem_cons,List.not_mem_nil,or_false] at mem
  rcases mem with e|e
  · simp [e] at h
    exact List.mem_cons.mpr (Or.inl h.symm)
  · simp [e] at h
    exact List.mem_cons.mpr (Or.inr (List.mem_singleton.mpr h.symm))

def Linked (r : Nat → Nat) : Prop := ∀ w t, r (t+1) % 2^w ∈ successors w (r t % 2^w)

theorem link_double (r : Nat → Nat) (h : ∀ t, r (t+1) = double (r t)) : Linked r := by
  intro w t
  let x := r t
  have pos := Nat.two_pow_pos w
  have fac : 2^(w+2)=2^w*4 := by simp [Nat.pow_add]
  let z := x % (2^w*4)
  let d := z / 2^w
  have eq : z % 2^w = x%2^w := Nat.mod_mod_of_dvd x ⟨4,rfl⟩
  have hdiv := Nat.mod_add_div z (2^w)
  rw [eq,Nat.mul_comm] at hdiv
  have dz : d < 4 := (Nat.div_lt_iff_lt_mul pos).2 (by
    simpa [z,Nat.mul_comm] using Nat.mod_lt x (by omega : 0<2^w*4))
  have mem : d ∈ [0,1,2,3] := List.mem_range.mpr dz
  rw [h, double_prefix (r t) w, fac]
  exact List.mem_map.mpr ⟨d,mem,by change double (x%2^w + d*2^w)%2^w = double z % 2^w; rw [hdiv]⟩

/-- Collisions only retain additional candidates. The odd modulus includes high spatial bits. -/
def mark : List Nat → Nat
  | [] => 0
  | x :: xs => (1 <<< (x%8191)) ||| mark xs

theorem marked {x : Nat} {xs : List Nat} (m : x∈xs) : (mark xs).testBit (x%8191) = true := by
  induction xs with
  | nil => exact False.elim (List.not_mem_nil m)
  | cons h xs ih =>
    simp only [mark,Nat.testBit_or,Bool.or_eq_true]
    rcases List.mem_cons.mp m with rfl|inside
    · exact Or.inl (by simp)
    · exact Or.inr (ih inside)

def forward (w : Nat) (prev : List Nat) : Grid → Grid
  | [] => []
  | s::ss =>
    let dest := mark (prev.flatMap (successors w))
    let take := s.filter (fun y => dest.testBit (y%8191))
    take :: forward w take ss

theorem forward_sound {w r} (link : Linked r) {t} {prev} (hp : r t % 2^w ∈ prev)
    {ss} (h : fits w r (t+1) ss) : fits w r (t+1) (forward w prev ss) := by
  induction ss generalizing t prev with
  | nil => trivial
  | cons s ss ih =>
    obtain ⟨a,b⟩ := h
    have take : r (t+1)%2^w ∈ s.filter (fun y => (mark (prev.flatMap (successors w))).testBit (y%8191)) := by
      exact List.mem_filter.mpr ⟨a,marked (List.mem_flatMap.mpr ⟨_,hp,link w t⟩)⟩
    exact ⟨take,ih take b⟩

def right (w : Nat) : Grid → Grid
  | [] => []
  | s::ss => s :: forward w s ss

theorem right_sound {w r t ss} (link : Linked r) (h : fits w r t ss) : fits w r t (right w ss) := by
  cases ss with
  | nil => trivial
  | cons s ss => exact ⟨h.1,forward_sound link h.1 h.2⟩

def left (w : Nat) : Grid → Grid
  | [] => []
  | s::ss =>
    let rest := left w ss
    let allowed := match rest with
      | [] => s
      | v::_ => let hits := mark v; s.filter fun x => (successors w x).any (fun y => hits.testBit (y%8191))
    allowed :: rest

theorem left_sound {w r t ss} (link : Linked r) (h : fits w r t ss) : fits w r t (left w ss) := by
  induction ss generalizing t with
  | nil => trivial
  | cons s ss ih =>
    obtain ⟨a,b⟩ := h
    have tail := ih b
    unfold left
    cases e : left w ss with
    | nil => exact ⟨a,by simpa [e] using tail⟩
    | cons v vs =>
      rw [e] at tail
      exact ⟨List.mem_filter.mpr ⟨a,List.any_eq_true.mpr ⟨_,link w t,marked tail.1⟩⟩,tail⟩

def lift (w : Nat) (keep : Nat → Nat → Bool) (t : Nat) : Grid → Grid
  | [] => []
  | s::ss => ((s.flatMap (fun x => [x,x+2^w])).filter (keep t)) :: lift w keep (t+1) ss

theorem lift_sound {w r t ss} (keep : Nat → Nat → Bool)
    (ok : ∀ i, keep i (r i%2^(w+1)) = true) (h : fits w r t ss) :
    fits (w+1) r t (lift w keep t ss) := by
  induction ss generalizing t with
  | nil => trivial
  | cons s ss ih =>
    exact ⟨List.mem_filter.mpr ⟨List.mem_flatMap.mpr ⟨_,h.1,prefix_lift _ _⟩,ok t⟩,ih h.2⟩

def admit (outside : Bool) (n w t x : Nat) : Bool :=
  !(outside && (w == 16) && (t+1 == n)) || !trapCodes.contains x

def layers (word : List Bool) (outside : Bool) : Nat → Grid
  | 0 => word.map fun b => [b.toNat]
  | k+1 =>
    let g := lift (k+1) (admit outside word.length (k+2)) 0 (layers word outside k)
    left (k+2) (right (k+2) g)

theorem survives {word : List Bool} {outside : Bool} {r} (link : Linked r)
    (base : fits 1 r 0 (layers word outside 0))
    (last : outside = true → r (word.length-1) % 65536 ∉ trapCodes) :
    ∀ k, fits (k+1) r 0 (layers word outside k) := by
  intro k
  induction k with
  | zero => exact base
  | succ k ih =>
    apply left_sound link
    apply right_sound link
    apply lift_sound _ _ ih
    intro i
    unfold admit
    by_cases test : outside=true ∧ k+2=16 ∧ i+1=word.length
    · obtain ⟨o,eq,n⟩ := test
      have bad := last o
      have w : (k+1)+1=16 := by omega
      have t : word.length-1=i := by omega
      simpa [o,eq,n,w,t] using bad
    · cases outside <;> simp_all
      exact Or.inl (Classical.or_iff_not_imp_left.mpr (by simpa using test))

def gaps (g : List Nat) := true :: g.flatMap fun n => List.replicate (n-1) false ++ [true]
def forbidden := gaps (List.replicate 7 3 ++ [5,3])
def entering := gaps (List.replicate 8 3 ++ [5,5])

set_option maxRecDepth 100000
set_option maxHeartbeats 0

set_option Elab.async false

private def unpackLayer (w : Nat) : Nat → Nat → List Nat
  | 0, _ => []
  | n+1, code => code % 2^w :: unpackLayer w n (code >>> w)

-- Generated by build_pure_three_layers.py. Each spatial lift is checked here by the kernel.
private def forbiddenData1 : Grid := ([(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(2,0xd)] : List (Nat × Nat)).map (fun p => unpackLayer 2 p.1 p.2)
private theorem forbiddenLayer1 : layers forbidden false 1 = forbiddenData1 := by
  decide +kernel

private def forbiddenData2 : Grid := ([(2,0x3b),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(1,0x6),(1,0x4),(1,0x2),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(3,0x1e9)] : List (Nat × Nat)).map (fun p => unpackLayer 3 p.1 p.2)
private theorem forbiddenLayer2 : layers forbidden false 2 = forbiddenData2 := by
  rw [layers,forbiddenLayer1]
  decide +kernel

private def forbiddenData3 : Grid := ([(2,0xf7),(2,0xa2),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xe),(2,0xc4),(2,0xa2),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7)] : List (Nat × Nat)).map (fun p => unpackLayer 4 p.1 p.2)
private theorem forbiddenLayer3 : layers forbidden false 3 = forbiddenData3 := by
  rw [layers,forbiddenLayer2]
  decide +kernel

private def forbiddenData4 : Grid := ([(3,0x7df7),(2,0x342),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(2,0x308),(1,0x7),(2,0x3ce),(2,0x384),(2,0x342),(1,0x18),(1,0x17),(1,0x1a),(2,0x308),(2,0x2e7)] : List (Nat × Nat)).map (fun p => unpackLayer 5 p.1 p.2)
private theorem forbiddenLayer4 : layers forbidden false 4 = forbiddenData4 := by
  rw [layers,forbiddenLayer3]
  decide +kernel

private def forbiddenData5 : Grid := ([(4,0xfcfdd7),(3,0x3a682),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0x628),(1,0x27),(1,0xe),(1,0x1c),(1,0x3a),(2,0xe18),(2,0xdd7),(2,0xe9a),(3,0x38628),(3,0x375e7)] : List (Nat × Nat)).map (fun p => unpackLayer 6 p.1 p.2)
private theorem forbiddenLayer5 : layers forbidden false 5 = forbiddenData5 := by
  rw [layers,forbiddenLayer4]
  decide +kernel

private def forbiddenData6 : Grid := ([(7,0x1fdf8feedeb97),(4,0xf4ead42),(3,0x1e1c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(2,0x3b97),(2,0x3d1a),(2,0xc68),(1,0x67),(1,0x4e),(1,0x1c),(2,0x3d3a),(2,0x3c58),(3,0x1deb97),(4,0xf4ead1a),(5,0x78b063428),(5,0x77ae5f3a7)] : List (Nat × Nat)).map (fun p => unpackLayer 7 p.1 p.2)
private theorem forbiddenLayer6 : layers forbidden false 6 = forbiddenData6 := by
  rw [layers,forbiddenLayer5]
  decide +kernel

private def forbiddenData7 : Grid := ([(10,0x7fbf8f0ff77737d75717),(5,0xba3ada5ac2),(5,0xf878b838d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(2,0x7797),(2,0xfa1a),(3,0x18e868),(2,0xe767),(2,0xce4e),(2,0x9c1c),(3,0x7aba3a),(3,0xf878d8),(5,0xf777d79717),(7,0xfaba3ada5a9a1a),(9,0xf878d89818e868a828),(9,0xf777d79717e767a727)] : List (Nat × Nat)).map (fun p => unpackLayer 8 p.1 p.2)
private theorem forbiddenLayer7 : layers forbidden false 7 = forbiddenData7 := by
  rw [layers,forbiddenLayer6]
  decide +kernel

private def forbiddenData8 : Grid := ([(15,0x1ff7ebfc7a3c1ff77bdde6e37ebb5cae17),(8,0xdd4e875da6d16b84c2),(6,0x3f078dc2e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(4,0xfbf5dae17),(5,0x3aed36ab45a),(2,0x1f178),(1,0x197),(1,0x1a),(2,0x3d168),(2,0x3cf67),(3,0x73a9c4e),(4,0xce272381c),(4,0x3d2ea743a),(6,0x3f0f8bc1e3b0d8),(8,0xfbbdeefd76be5e2e17),(10,0x3753a1d769b55a2d26a341a),(11,0x7e1f1783c761b1e8b41a15028),(14,0x3eef7bbf5daf978b85fcf6733e9d4f27)] : List (Nat × Nat)).map (fun p => unpackLayer 9 p.1 p.2)
private theorem forbiddenLayer8 : layers forbidden false 8 = forbiddenData8 := by
  rw [layers,forbiddenLayer7]
  decide +kernel

private def forbiddenData9 : Grid := ([(23,0x7fefdbfafcbf63e8f23e0f03ff77def73df775df370dfd775c5785c17),(9,0x3ba6eb3a0e9dab6a5a70ac2),(6,0xfe078ee3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(8,0xee9bace83a76ada9685a),(5,0x3f89e078762d8),(6,0xfdfd775ed735c17),(7,0x23a0ebda36b5a5685a),(3,0xf8de178),(1,0x197),(1,0x21a),(1,0x1e8),(1,0x367),(2,0xf39ce),(3,0x39ca709c),(4,0xce93a8e83a),(6,0xfe2f83e1789e078),(9,0x3d775ed735f9765f1785c17),(13,0x3da76ada36b5a56a5a16a9a26b1a46a1a),(12,0xfe2f83e3785e2781e1e8aa0a88a028),(15,0x3d775ed735f9765f1785c17d9e67e9ea729d27)] : List (Nat × Nat)).map (fun p => unpackLayer 10 p.1 p.2)
private theorem forbiddenLayer9 : layers forbidden false 9 = forbiddenData9 := by
  rw [layers,forbiddenLayer8]
  decide +kernel

private def forbiddenData10 : Grid := ([(31,0x11fc3ffbf37fafd5f8bf31fa3d4788fc1e83c07ff77ef3dc7bf776ef5dcbbf3766e0ddebdd78af85d0b817),(12,0xf74eeadd1ba87476b6d65a4b470b612c2),(9,0x7f87f01e3dc3b8fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(7,0x1fe1fc078fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(7,0x1fe1fc078fb07636c2d8),(6,0x3fbbf71ef75f0b817),(7,0x1ee9dd5ba87476b6d65a),(5,0x7f87f01e3ec5d8),(6,0x37bcf71ef75f0b817),(7,0x1ee8dd73a67476b6d65a),(7,0x1fe33c4780f07636c2d8),(7,0x1fddfbfd73aeb5e6b817),(7,0x18e81d7da7b5368ad05a),(2,0x27c178),(1,0x197),(2,0x30d21a),(1,0x1e8),(2,0x3b3b67),(3,0x1f39e75ce),(3,0x1a724e09c),(4,0xc748ea1d03a),(6,0x1fc6f89f03e2bc178),(8,0xf2ee5ecb997e2ec5f0bc17),(11,0x1768ed35ad34a6a4d71aa3446b0d21a),(14,0x3fc3f8df1de2bc5e83d1aa1544a81518a114028),(17,0x79772f65f8bb17c2f05c0bf676cf99f53aa794e29e93927)] : List (Nat × Nat)).map (fun p => unpackLayer 11 p.1 p.2)
private theorem forbiddenLayer10 : layers forbidden false 10 = forbiddenData10 := by
  rw [layers,forbiddenLayer9]
  decide +kernel

private def forbiddenData11 : Grid := ([(9,0xe0f60f8f70f7f77377d77577177),(3,0x3badba5ba),(2,0xfd87d8),(2,0x8f70f7),(2,0x3ba5ba),(2,0xfd87d8),(2,0x8f70f7),(2,0x3ba5ba),(2,0xfd87d8),(2,0x8f70f7),(3,0xbba3ba5ba),(3,0xfd87d8dd8),(4,0xef76f7cf70f7),(5,0xfba9ba1ba73ab3a),(6,0xe789d81d8ed86d82d8),(4,0xff73f7cd74d7),(4,0x63a03a95a15a),(3,0xcf8978178),(2,0x997197),(3,0x61aa1a21a),(2,0x9e81e8),(4,0xf67767b67367),(5,0xfcebce3cedce5ce),(5,0xe9c69cc9c89c09c),(7,0xe3a63aa3a23a43a83a03a),(9,0x3f86f8cf88f80f8d78578978178),(11,0xf97b97397d97597997197f17b17e17617),(15,0xdda5da9dae9aa9a29af1a71ad1a91a11ae1a61aa1a21a),(18,0x3f8ef86f8de85e89e81e8ea8aa82a8ca84a88a80a8e28628a28228),(22,0xf17717b17e17617f67767b67367e67667ea76a7aa72a74a78a70a7d27527927127)] : List (Nat × Nat)).map (fun p => unpackLayer 12 p.1 p.2)
private theorem forbiddenLayer11 : layers forbidden false 11 = forbiddenData11 := by
  rw [layers,forbiddenLayer10]
  decide +kernel

private def forbiddenData12 : Grid := ([(14,0x3c1ee0fb07e3dd1ee0f7fbbcddc6efd776bbd5dcaee177),(5,0x3baedd36eab745ba),(3,0x7f61fb17d8),(2,0x31ee0f7),(3,0xeeab745ba),(3,0x7f61fb17d8),(2,0x31ee0f7),(3,0xeeab745ba),(3,0x7f61fb17d8),(2,0x31ee0f7),(4,0xddd4ee87745ba),(5,0x1fd87ec1f63bb0dd8),(4,0xf7bf3dd9ef0f7),(4,0x7dd66e937473a),(4,0xf3c39e33b02d8),(4,0x9fbf35e9ae4d7),(3,0x18eb2b515a),(3,0x65e12f1178),(3,0x265e32e197),(3,0x186943421a),(3,0x67a13d11e8),(3,0x2d9e6ce367),(5,0xfceee7373ab9c5ce),(6,0x3d38e9cb4e1a7313909c),(8,0xf1d38eac7463ad1d28ea87443a),(7,0x4fe07f1d78abc15e32f0978),(10,0x3b2ed97acb965e32e197f0bb85ec2e617),(13,0x1ddaaed176b3b49daf8d3c6ae3471af0d5868c34a1a),(16,0x9fc0fe3df0ef8b7c1be3bd15e82f467a13d1ea87546aa25502a8),(22,0x3e2f71738bec5d62fe1770bd85cc2f3671b3f99dccf667333fa9ed4e6a7d53aa9e54e2a7)] : List (Nat × Nat)).map (fun p => unpackLayer 13 p.1 p.2)
private theorem forbiddenLayer12 : layers forbidden false 12 = forbiddenData12 := by
  rw [layers,forbiddenLayer11]
  decide +kernel

private def forbiddenData13 : Grid := ([(26,0xf83de0fb83ce0fd83d60fe3dd8f723dc0f7fdddf77cddd3778ddc377f5ddd77b5dcd77d5dd57795dc57785dc177),(9,0x23ba0eebdba76eadba36eb5ba56e85ba),(4,0xff60fd8df617d8),(3,0x38f763dc0f7),(4,0x8ee83bad6e95ba),(4,0xff60fd8df617d8),(3,0x38f763dc0f7),(4,0x8ee83bad6e95ba),(4,0xff60fd8df617d8),(3,0x18f783dc0f7),(4,0x6eeb3ba0eea5ba),(3,0x2fd81f62dd8),(4,0xfbdfcf773df0f7),(5,0xfbaa6e89ba9ce873a),(7,0x3e7879e2e7839e39d867622d8),(5,0x33f74fddcd7d35c4d7),(5,0x263a18eb95ac56915a),(5,0x397865e0978c5e1178),(5,0x2997265f197465c197),(6,0x986861aa868a1a886821a),(5,0x39e867a29e827a11e8),(5,0xb67cd9d3678d9c367),(8,0xbf38fcef73adce37395ce97385ce),(10,0xfa72e9c3a7369c5a7269c1a7389c627309c),(14,0xf8e9e3ab8e8e3ad8ea63a18eba3a68eaa3a28eb43a50ea43a),(12,0xcfe13f80fe3d7875e357895e0578e5e1978a5e0978),(16,0xf65ed97365f597565e597165f197465e197065fe17b85ce17985c617),(22,0xf769ddad76a5da176b9da676a9da276bf1abc68f1adc6971a9c6871a786b61a986861aa868a1a),(28,0xcfe13f88fe03f8fbe2ef83be36f85be26f81be3de877a35e897a39e867a29e827a3ea87aa2ea83aa3aa86aa32a88aa02a8),(37,0x3f177c5f7179c5c717ec5db17ac5cb17f85ee17385d617985c617cd9d3678d9c367f99ee67399f667599c667fa9dea7da9e6a71a9faa76a9eaa72a9d2a78a9c2a7)] : List (Nat × Nat)).map (fun p => unpackLayer 14 p.1 p.2)
private theorem forbiddenLayer13 : layers forbidden false 13 = forbiddenData13 := by
  rw [layers,forbiddenLayer12]
  decide +kernel

private def forbiddenData14 : Grid := ([(39,0x1f83cf07ee0f5c1f383c707f60f6c1e583fc7bb8f7b1ef23dc07bff777eef7ddc9bbe37746ee0ddfebbbd77baee75df6bbcd771aefd5ddabbd5772aef95dd2bb8577c2ee85de0bb8177),(12,0xc7740eebedd1dbadb7536e86dd75ba6b7556e8add05ba),(6,0x3fec0fd8efb0df62bec17d8),(3,0xe3dec7b80f7),(2,0x1dd75ba),(3,0x3f63bec37d8),(1,0x78f7),(1,0x15ba),(1,0x17d8),(1,0x18f7),(2,0x32dd25ba),(1,0x7d8),(2,0x3e7bdcf7),(2,0x34dd09ba),(2,0x316c22d8),(1,0x13f7),(1,0x63a),(2,0x3cbc5978),(3,0x1c65e8cb9197),(4,0xd434a86a50d0a1a),(4,0xd3d0a7a24f409e8),(4,0xc6ce8d9e1b38367),(6,0x1ee76dce9b9c373aae715ce),(8,0xfd38fa7374e4e9ced38da72b4e169c),(9,0x7e3a7c7578e8f1d763a6c7598ea31d063a),(14,0x3ebc3d78baf1d5e1abc65788af015e3cbc597832f0a5e24bc0978),(17,0x6d979b2e365facbb597ab2e565d2cbc5970b2fc65e8cb9197c32e865e0cb8197),(18,0x3f8d3f1aee34dc6ab8d171a4e341c6af0d1e1a6c35986a30d061ad434a86a50d0a1a),(23,0x1f7a2ef475e86bd197a3cf459e833d1a7a14f449e813d1faa2f541ea81d51eaa1d545aa835518aa215402a8),(33,0x7367a6ce4d9f1b3a36786ce0d9f733ce671ccfd99db33d6678cce199ff53bea7bd4fda9db53e6a78d4e1a9fd53baa7b54e6a9f553aaa7954e2a9e95392a7)] : List (Nat × Nat)).map (fun p => unpackLayer 15 p.1 p.2)
private theorem forbiddenLayer14 : layers forbidden false 14 = forbiddenData14 := by
  rw [layers,forbiddenLayer13]
  decide +kernel

private def forbiddenData15 : Grid := ([(62,0xfe0f9e0f1e0fee0f6e0fae0f2e0fce0f4e0f0e0f760fb60f960ff8f778f7b8f738f7d8f758f7c8f748f780f700f7ff773f77df775f779377e3776377a377237783770377fd777d77bd773d77dd775d771d77ed776d77cd774d778d770d77f5777577b5773577d5775577957715772577857705772177c17741770177),(20,0xe3ba63ba03bafdba7dba1dbaedba6dbacdba8dba0dbaf5ba75bab5ba35bad5ba55ba95ba15ba05ba),(8,0xffd88fd80fd8f7d837d8d7d857d817d8),(4,0x38f7d8f758f700f7),(3,0x3baf5ba75ba),(2,0xfd8b7d8),(1,0xf8f7),(1,0x95ba),(1,0x17d8),(1,0x98f7),(1,0x25ba),(1,0x7d8),(1,0xdcf7),(2,0xe9ba69ba),(2,0x62d8a2d8),(1,0x93f7),(1,0x63a),(1,0xd978),(2,0xf1977197),(3,0xea1aaa1a2a1a),(4,0xe9e869e8a9e829e8),(4,0xe3676367a3672367),(4,0xd5ce55ce95ce15ce),(4,0xd69c569c969c169c),(4,0xde3a5e3a9e3a1e3a),(6,0xf5787578b5783578e5786578),(8,0xf597b5973597d5975597c59745978597),(8,0xf71a771ab71a371ad71a571aa71a271a),(7,0x8ea80ea8faa8baa83aa8daa85aa8),(9,0xfea7bea73ea75ea7faa77aa7daa79aa71aa7)] : List (Nat × Nat)).map (fun p => unpackLayer 16 p.1 p.2)
private theorem forbiddenLayer15 : layers forbidden false 15 = forbiddenData15 := by
  rw [layers,forbiddenLayer14]
  decide +kernel

private def forbiddenData16 : Grid := ([(100,0xff07bf83f3c1e9e0f0f07fb83ddc1f6e0f3707eb83e5c1e2e0f2707c383cec1fb60f5b07e583d2c1ff8f77c7bde3dcf1efb8f75c7bce3dc71efd8f76c7b963dd91ef48f7247be03dc01efff771fbbf7dddbeef5f772fbbe4ddd26efe37771bbd8ddcc6efa37751bbc8ddc46ef837701bbff5ddfaef7d771ebbf75ddbaef5d772ebb875dfdaeeed77b6bbf35dd9aee4d77c6bba35de1aee0d77fabbbd5deeaee7577dabbad5de6aee3577eabbb55deaaee5577cabba55de2aee157792bb895df0aee857782bb815de42efc17760bbd05dc82ee0177),(27,0x78ee9c77563ba01dd7f6e9fb757dba0edd3b6eadb758dba06dd7d6e9eb7475badadd4d6e86b75d5ba6add556e8ab7595ba4add056ea0b7405ba),(11,0x7ff631fb00fd8fbec4df606fb1d7d86bec55f60afb017d8),(6,0x71efd8f76c7bd63dcb1ee00f7),(3,0xee9eb7575ba),(2,0x21fb1b7d8),(1,0xf8f7),(1,0x195ba),(1,0x117d8),(1,0x98f7),(1,0x25ba),(1,0x107d8),(1,0xdcf7),(1,0x1e9ba),(1,0x62d8),(1,0x193f7),(1,0x1063a),(1,0xd978),(2,0x3e32f7197),(3,0x6a86a54342a1a),(4,0xd4f42a7a253d029e8),(4,0xd1b3a8d9e46ce2367),(4,0xcae72573a2b9c15ce),(6,0x3ad39569c2b4e25a722d38169c),(6,0x3bc74de3aaf1d178e93c741e3a),(8,0xfabc5d5e0eaf03578f2bc395e2caf06578),(13,0x1f5977acbed65e6b2e3597eacbb565eab2fc597a2cb9165f0b2e8597),(15,0x7dc69ee35771a3b8d6dc6a6e34371aeb8d35c6aae34571ad38d29c6a4e34271a),(13,0x18ea8475443aa01d51faa87d546eaa275503aa8ed5436aa2b5505aa8),(15,0x3fa9f7d4f3ea71f53d7a9cbd4ffaa77d53dea9cf54fdaa76d53e6a9e354e1aa7)] : List (Nat × Nat)).map (fun p => unpackLayer 17 p.1 p.2)
private theorem forbiddenLayer16 : layers forbidden false 16 = forbiddenData16 := by
  rw [layers,forbiddenLayer15]
  decide +kernel

theorem forbidden_empty : (layers forbidden false 17).head? = some [] := by
  rw [layers,forbiddenLayer16]
  decide +kernel

private def enteringData1 : Grid := ([(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x2),(1,0x0),(1,0x3),(1,0x2),(1,0x0),(1,0x2),(1,0x0),(2,0xd)] : List (Nat × Nat)).map (fun p => unpackLayer 2 p.1 p.2)
private theorem enteringLayer1 : layers entering true 1 = enteringData1 := by
  decide +kernel

private def enteringData2 : Grid := ([(2,0x3b),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(2,0x32),(1,0x0),(1,0x7),(1,0x6),(1,0x4),(1,0x2),(1,0x0),(1,0x7),(1,0x6),(1,0x4),(1,0x2),(1,0x0),(3,0x1e9)] : List (Nat × Nat)).map (fun p => unpackLayer 3 p.1 p.2)
private theorem enteringLayer2 : layers entering true 2 = enteringData2 := by
  rw [layers,enteringLayer1]
  decide +kernel

private def enteringData3 : Grid := ([(2,0xf7),(2,0xa2),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xa),(1,0x8),(1,0x7),(1,0xe),(2,0xc4),(2,0xa2),(1,0x8),(1,0x7),(1,0xe),(2,0xc4),(2,0xa2),(2,0x80),(4,0x7d91)] : List (Nat × Nat)).map (fun p => unpackLayer 4 p.1 p.2)
private theorem enteringLayer3 : layers entering true 3 = enteringData3 := by
  rw [layers,enteringLayer2]
  decide +kernel

private def enteringData4 : Grid := ([(3,0x7df7),(2,0x342),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(1,0x18),(1,0x17),(1,0x1a),(2,0x308),(1,0x7),(2,0x3ce),(2,0x384),(3,0x6942),(2,0x308),(1,0x7),(2,0x3ce),(3,0x7284),(4,0xd2a42),(4,0xc2200),(6,0x2e76e621)] : List (Nat × Nat)).map (fun p => unpackLayer 5 p.1 p.2)
private theorem enteringLayer4 : layers entering true 4 = enteringData4 := by
  rw [layers,enteringLayer3]
  decide +kernel

private def enteringData5 : Grid := ([(4,0xfcfdd7),(3,0x3a682),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0xe18),(2,0xdd7),(2,0xe9a),(2,0x628),(1,0x27),(1,0xe),(2,0xf1c),(3,0x3aa8a),(3,0x18a08),(2,0x9c7),(4,0xf9eb8e),(5,0x3c734904),(7,0x3aa8ac92882),(7,0x38628210800),(9,0x375e71cd671841)] : List (Nat × Nat)).map (fun p => unpackLayer 6 p.1 p.2)
private theorem enteringLayer5 : layers entering true 5 = enteringData5 := by
  rw [layers,enteringLayer4]
  decide +kernel

private def enteringData6 : Grid := ([(7,0x1fdf8feedeb97),(4,0xf4ead42),(3,0x1e1c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(3,0x1deb97),(3,0x1e9d5a),(2,0x3c58),(2,0x3b97),(2,0x3d1a),(3,0x63428),(2,0x33a7),(2,0x270e),(4,0xf8f2e1c),(4,0xf5aa50a),(5,0x18d0a2408),(4,0xce9e387),(6,0x3f5e3cba70e),(9,0x7c7970e746992204),(12,0xf4eb54a15c9952248a102),(13,0x787160c685120410c082000),(15,0x1deb97ce9e3879a36c996386081)] : List (Nat × Nat)).map (fun p => unpackLayer 7 p.1 p.2)
private theorem enteringLayer6 : layers entering true 6 = enteringData6 := by
  rw [layers,enteringLayer5]
  decide +kernel

private def enteringData7 : Grid := ([(10,0x7fbf8f0ff77737d75717),(5,0xba3ada5ac2),(5,0xf878b838d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(4,0xf777d717),(4,0xba3ada5a),(3,0xf878d8),(3,0x779717),(3,0xfa9a1a),(6,0x9818e868a828),(4,0xe767a727),(4,0xce4e8e0e),(5,0xfcbc3c5c1c),(7,0xfa7aea6aca8a0a),(9,0x9818e868a828488808),(6,0xe767a7274707),(8,0xde9e1e2ece4e8e0e),(12,0xfcbc3c5c9c1cf474b434e464),(17,0xfa7aba3aea6aca8a0af2b232d252c24282),(19,0xf878b838d89818e868a828488808e0a020c040),(17,0xf777d79717e767a7274707d9599919b131)] : List (Nat × Nat)).map (fun p => unpackLayer 8 p.1 p.2)
private theorem enteringLayer7 : layers entering true 7 = enteringData7 := by
  rw [layers,enteringLayer6]
  decide +kernel

private def enteringData8 : Grid := ([(15,0x1ff7ebfc7a3c1ff77bdde6e37ebb5cae17),(8,0xdd4e875da6d16b84c2),(6,0x3f078dc2e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(6,0x3eef7bbf5dae17),(6,0x3753a1d769b45a),(4,0xfc1e3b0d8),(4,0xfbf5dae17),(5,0x3aed36ab45a),(3,0x7e1f178),(2,0x32f17),(3,0x26a341a),(5,0x1e8b41a15028),(5,0x1e733e9d4f27),(4,0x276391c0e),(6,0x3793c1e570b81c),(8,0xfd5ebd4eab51ab94ca),(11,0x6623018f45a0d1a8546211108),(10,0x3cee7b399f4ea79389e8e47),(9,0x12e1773a9c4ec723a1c0e),(14,0x1f9bc9e0f2b85cce272381cda2d26834),(20,0xfd5e8f4ba9d0ebd4eab51ab94cac542be4f2e934aa452),(27,0x7e1f1783c761b1988c063d0e8b41a350a8a41231088846824020e03028040),(28,0xfbbdeefd76be5e2e17f3b9ece67d3a9e4e27a391e0e07cca663219d8ac66231)] : List (Nat × Nat)).map (fun p => unpackLayer 9 p.1 p.2)
private theorem enteringLayer8 : layers entering true 8 = enteringData8 := by
  rw [layers,enteringLayer7]
  decide +kernel

private def enteringData9 : Grid := ([(23,0x7fefdbfafcbf63e8f23e0f03ff77def73df775df370dfd775c5785c17),(9,0x3ba6eb3a0e9dab6a5a70ac2),(6,0xfe078ee3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(7,0x3ba6eb3a0e9dab6a5a),(5,0x3f81e3d8762d8),(7,0x3f7bdcf7f5dd785c17),(8,0xee9bace83a76ada9685a),(5,0x3f89e078762d8),(7,0x3f7f5dd7b5cd785c17),(8,0x8e83af69da36b5a5685a),(4,0xbe0f8de178),(3,0x39765f17),(5,0x29a26b1a46a1a),(5,0x1e8aa0a88a028),(5,0x267e9ea729d27),(5,0x38e63a8e2380e),(7,0x33c8f03cd715c9705c),(7,0x3eaba8eada96a9a86a),(9,0x3e87a3689a068ea1a8aa0a8),(9,0x3e779f6799c67e9da7a9ca7),(9,0x3ce73b4e9384ee398ea388e),(11,0x35c5725c1739ca709cc711c8701c),(14,0x7eb7a9e87aae8bace93a8e83ada96a9a86a),(20,0xfe2f83e1789e078f61d8b60d8e6198c6218fa1e8ea1a8aa0a8),(25,0x3f7bdcf7ddd77f5dd7b5cd7e5d97c5e1705de7d9e6719fa769ea729f2749e27)] : List (Nat × Nat)).map (fun p => unpackLayer 10 p.1 p.2)
private theorem enteringLayer9 : layers entering true 9 = enteringData9 := by
  rw [layers,enteringLayer8]
  decide +kernel

private def enteringData10 : Grid := ([(31,0x11fc3ffbf37fafd5f8bf31fa3d4788fc1e83c07ff77ef3dc7bf776ef5dcbbf3766e0ddebdd78af85d0b817),(12,0xf74eeadd1ba87476b6d65a4b470b612c2),(9,0x7f87f01e3dc3b8fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(7,0x1fe1fc078fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(7,0x1fe1fc078fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(7,0x1fe1fc078fb07636c2d8),(7,0x1fddfbcf71ef75f0b817),(8,0xf74eeadd1ba87476b6d65a),(8,0xff0fe03c7d8bb07636c2d8),(8,0xfeefdf7bcf71ef75f0b817),(9,0x7ba375ce99d43a3b5b6b2d45a),(9,0x7f87f19e13c4780f07636c2d8),(10,0x3fbbf7fae75d6bcd71af85e0b817),(12,0xc740ebed3dabb53686d75a6b5568ad05a),(7,0x1be27c0f8ef0de2bc178),(6,0x3cbb97b2e65f8bb17),(7,0x1a694d49ae354688d61a),(8,0xbd1aa1544a81518a114028),(7,0x199f53aa794e29e93927),(6,0x34728e91c23a0700e),(8,0x6798f21e03ccb89722e05c),(11,0xfab754ea1d5daab516acd49aa3506a),(14,0x3f43e8bd07a3b4368cd11a3d45a8350aa2540a8),(15,0x1f9df3de7eced9f33c670cfe9ed39a7d4ea9e538a7),(13,0x7ce79d73b2744e09de3ac718ed1ca3a4708e),(16,0xeb9570ae65c4b91702e69c9382738e51c2388720e01c),(20,0x3f4deb3d47a0f5ae95d4ba1758e91d43a075da9b556a2d49aa3506a),(26,0x1fc6f89f03e2bc178fb1760ec6d85b13606c798b31c618c7e87d17a0f47a8b506a1540a8),(31,0x1fddfbef79ee3dfbbb77aee5dfcbb97b2e65f8bb17c2f05fb3b67ccf19c33fa7b4e69f53aa794fc9e93927)] : List (Nat × Nat)).map (fun p => unpackLayer 11 p.1 p.2)
private theorem enteringLayer10 : layers entering true 10 = enteringData10 := by
  rw [layers,enteringLayer9]
  decide +kernel

private def enteringData11 : Grid := ([(22,0xe0f60fa0f20f00f7f7bf7cf74f78f70f7f77777b77377d77577977177617a17217),(8,0xfba3badba5ba9ba1bac3a9da),(8,0x3f8fd87d81d8ed86d8ad82d8),(6,0x7f7bf7cf78f70f7617),(7,0xfba3ba5ba9ba1bac3a9da),(8,0x3f8fd87d81d8ed86d8ad82d8),(6,0x7f7bf7cf78f70f7617),(7,0xfba3ba5ba9ba1bac3a9da),(8,0x3f8fd87d81d8ed86d8ad82d8),(6,0x7f7bf7cf78f70f7617),(7,0xfba3ba5ba9ba1bac3a9da),(8,0x3f8fd87d81d8ed86d8ad82d8),(6,0x7f7bf7cf78f70f7617),(8,0xfbabba3ba5ba9ba1bac3a9da),(9,0x3f8fd87d8dd81d8ed86d8ad82d8),(7,0x7f7bf7ef76f7cf70f7617),(8,0xfba9ba1baf3a73ab3ac3a9da),(10,0xbf83f8e78a782789d81d8ed86d82d8),(10,0xff77f73f7cd74d78d70d7e17617c17),(12,0xe3a63a83a03adda5daf5ab5a35a55a95a15a),(12,0xef86f8cf88f80f8f78b78378d78578978178),(9,0xf97b97397d97597197f17717b17),(10,0xe9aa9a29af1a71ad1a91a11ae1a61a),(13,0xde85e8ea8aa82a8ca84a88a80a8e28628a28228),(13,0xe67667ea76a7aa72a74a78a70a7d27527927127),(12,0xe8e68ea8e28ec8e48e88e08ec0e40e80e00e),(13,0xb3c33c63cc3c83c03ce5c65ca5c25c45c85c05c),(16,0xbea3ea6eacea8ea0ea76ad6a96a16ae6a26ac6a46a86a06a),(22,0xfe8be83e8de85e89e81e8f68b68e68668c687a8da89a81a8aa82a8ca84a88a80a8),(24,0xfe7be73e7f67767b67367e67667c67867067fa77a7da79a7ea76a7aa72a7ca74a78a70a7),(23,0xfcebce3cedce5cee4e64ec4e84e04ef8e78ed8e98e18ee8e68ea8e28ec8e48e88e08e),(26,0xf5c75cd5c95c15ce5c65ca5c25c45c85c05ce9c69cc9c89c09c71cd1c91c11ca1c21cc1c41c81c),(31,0x9fa1fab7a37a67aebaabacba4ba8ba0bae3a63aa3a23a43a83a03af6a76ab6a36ad6a56a96a16a26ac6a46a86a06a),(39,0x3f86f8cf88f80f8d78578978178ed86d8ad82d8cd84d88d80d8f98d98598f18718b18318fe8be83e8de85e89e81e87a8da89a81a8aa82a88a80a8),(44,0xff77f7bf73f7f77b77377577977177f97b97397d97597997197f17b17e17617f67767b67367e67667c67867067fa77a7da79a7ea76a7aa72a7ca74a7f27727927127)] : List (Nat × Nat)).map (fun p => unpackLayer 12 p.1 p.2)
private theorem enteringLayer11 : layers entering true 11 = enteringData11 := by
  rw [layers,enteringLayer10]
  decide +kernel

private def enteringData12 : Grid := ([(38,0x3c1ee0fb07983f41ea0f907883e01e7f7dfbafdf9eecf7a7b93df1ee8f787b83dfeeef773bbeddd6ef3771bbf5ddaef5772bbe5dd2ef1770bb985f42e217),(14,0x3f74fba9dd0eebb74dbaadd16eb3749ba8dd06e98759da),(11,0x4fe3fb0fd8bec1f623b01d8f6c1b615b02d8),(9,0x7f7dfbafdf9eecf7c7bc3dc1ee617),(10,0x1f753ba1dd56e8b759ba4dd46e98759da),(8,0x9fc7f61fb17d83ec47615b02d8),(8,0xdfbafdf9eecf7c7bc3dc1ee617),(10,0x1f753ba1dd56e8b759ba4dd46e98759da),(8,0x9fc7f61fb17d83ec47615b02d8),(8,0xdfbafdf9eecf7c7bc3dc1ee617),(10,0x1f753ba1dd56e8b759ba4dd46e98759da),(8,0x9fc7f61fb17d83ec47615b02d8),(8,0xdfbafdf9eecf7c7bc3dc1ee617),(10,0x1f75bba9dd0ee8b759ba4dd46e98759da),(9,0x13f8fec3f60fb1dd86ec47615b02d8),(9,0x1bf75fbfbdddef6f7e7bb3de1ee617),(10,0x1f759ba4dd7ceae7473ae1d30eb3b49da),(11,0x6fe17f03f8f3c39e34f127813c67625b02d8),(14,0x27ee3f7e6bd35c9af8d746bc35c1afe1770bd85f82ec17),(18,0x3c74e3ab1d18ebbb55da2ed3d6b6b4b5a9ad0d6aab455acad256a2b415a),(15,0x7be1df16f837c7de1ef1b789bc75e1af15782bc65e12f0178),(15,0x7e5df2fb979cb8e5fb2ed97acb965c32ff17b8b9c5f62eb17),(16,0xf4d3a6b53529a14d7c69e3571a38d7469a3591a88d046bc3561a),(22,0x3bd15e82f47aa1d51aa89540aa3950ca8a5412a11510a805478a2c50628d1428a2450228),(24,0xf33b99ecce667f53ba9ed4e6a7d53aa9e54e2a7253e29d14f0a7053f49ea4e527c93a49e24e127),(22,0x3d1ce8eb471a3b51ca8e9470a3b91d48e247623911d08e047703981d40e207203a01c00e),(23,0x6cf167933c19e18f187983c81e00f3cb8e5cb2e19734b8a5c92e09728b845cc2e21720b805c),(27,0x6faa7d56ea37533ab1d50ea0755da8ed4d6acb525aa2d416af3539aa4d426ae3531aa8d446ac3521aa0d406a),(35,0x7fa1fd1be89f40fa3bd15e82f467a13d11e80f47da36d0b6833471a18d17a83d436a33511a80d46aa15512a815472a29504a8c5422a21500a8),(38,0x3fcefe79f38f9fecf7673b3ad9e6ce367f33b99ecce667e33b19f0cf067033fe9ef4fda76d3e69fd4eea7b539a9f54eaa79538a9e94e4a7c53a29e14e0a7),(39,0x7f39f9dbce9e70f3bb9cdceae7173bc9ce4eb27193b09d04e0277e39f1d78e3c7363b31d18e0c77a39d1d68e3476a3951d28e147723a91c48ec47223a11c08e),(41,0x1f5cbae7571ab995c8ae0573cb8e5cb2e19734b8a5c92e09728b845cc2e21720b805cf4e3a72d3869ce4e327313909c04e5c70e38d1cc8e4470239c1ca0e107303881c),(50,0x36f4b7a9bd0deacf467af5d3aeb575cbaa5d12e91750ba05d78e9c7563a31d68e947523a11d50e887583a41d40eaed476adb54da86d5d6a6b555a8ad596a4b545a82d526a13571aa8d446ac3521aa0d406a),(56,0x9fc0fe2df06f867c75e2af0578cbc25e22f0178f6c3b62db06d8d6c2b625b02d8e6c13631b08d886c0363f30f98ecc3662b30598ff43fa37d1de86f457a0bd09e88f407a2f507a86d466a23501a8d542aa25502a8c5422a21500a8),(68,0xffbdfdcfefbf75fbcfdc7eef77dbbcddc6ef5772bbe5dd2ef1770bbf65db2f5972cbe65d32f1970cbfc5f62eb17f0bb85ec2e617fb3dd9ceceb671b3f99dccf667333f19d8cf867833819ff4f7a7ed3b69f34fea7753da9cd4faa7553ca9c54f4a7253fc9de4f727393e49e24e127)] : List (Nat × Nat)).map (fun p => unpackLayer 13 p.1 p.2)
private theorem enteringLayer12 : layers entering true 12 = enteringData12 := by
  rw [layers,enteringLayer11]
  decide +kernel

private def enteringData13 : Grid := ([(60,0xf83de0fb83ce0fd83d60f983ca0fc83d20f883c20fc03d00f9fdcbf7f3dccf7d3dd4f793dc4f7e3dd8f7a3dc8f7c3dc0f7fdddf77bddc777edddb77addcb77cddd3778ddc377f5ddd77b5dcd77d5dd57795dc577e5dd977a5dc977c5dd17785dc177185fa17685c217),(22,0xfee9fbabeeb3ba8ee83baf6e9dbab6e8dbad6e95ba96e85ba26eb1ba46ea1ba06e8c3ae7699da),(15,0x33f84fe3fd8bf60fd8df617d89f607d8c7601d87b626d82b602d8),(9,0x27f72fdfcf733df8f763df0f703dc617),(13,0x2fbaceea3ba0eeb5ba56ea5ba26eb1ba46e8c3ae7699da),(12,0xcfe13f8ff62fd83f637d85f627d81f631d82b602d8),(8,0x2fdfcf733df8f763df0f703dc617),(13,0x2fbaceea3ba0eeb5ba56ea5ba26eb1ba46e8c3ae7699da),(12,0xcfe13f8ff62fd83f637d85f627d81f631d82b602d8),(8,0x2fdfcf733df8f763df0f703dc617),(13,0x2fbaceea3ba0eeb5ba56ea5ba26eb1ba46e8c3ae7699da),(12,0xcfe13f8ff62fd83f637d85f627d81f631d82b602d8),(8,0x2fdfcf733dd8f7c3de0f703dc617),(11,0x2fba6eeb3ba0eea5ba26eb1ba46e8c3ae7699da),(10,0xcfe13f8bf607d8f762dd8c762ad82b602d8),(12,0xefdebf72fdfef7bbdcef7f3ddcf7b3df0f7985c617),(15,0xfbae6ea9ba26ebf3a7ceb73a9ce873af0e9c3ab0e99daa7689da),(19,0x3bf8afe0bf88fe03f8f9e1e78b9e0e78e9e1a78c9e227809e39d867632d84b622d8),(24,0xcfdd3f78fdc3f7f35dcd7d35e4d7135f8d7635e8d7235d0d7835c0d7f85ee17385d617f05dc17b05cc17),(30,0xf8eae3a38e963a98e863af769ddad76a5da1768f5aed69b5aad68b5acd6935a8d6835ad56955a956855aa56895ac56915a856815a),(26,0xfbe2ef83be36f85be26f81be3f787de2f783de3b786de3d7875e2d7835e357855e257815e1978a5e097885e0178),(27,0x3f977e5ef97ee5db97ce5e3970e5fd97765ed97365f597565e597165e197065ff177c5f7179c5c717ec5db17ac5cb17),(24,0xfa69e9aba68e9aea69a9aca6a29a0a6bf1abc68f1adc6971a9c6871af469d1ab46b11a846811a786b61a),(34,0xf7a1de8d7a25e8faa1ea8baa0ea8eaa1aa8caa22a80aa3ca872a2ca832a34a892a04a8a2a08a8f8a1e28d8a262818a3a2868a2a2828a122888a0228),(38,0xf99ee67399f667599c667fa9dea7da9e6a71a9faa76a9eaa72a9d2a78a9c2a7929c4a7e29e8a7229f0a7429e0a7029fd27749f527949c527e49d927a49c927449c127),(40,0xfa39e8eba38e8eda3a68e1a3ba8e6a3aa8e2a3b28e4a3a28e0a3bc8e723b48e523a48e123b88e623a88ec23908e823808ef03ac0e303b40e503a40e103880ec03900e803800e),(40,0xecf2b3c2cf333c4cf233c0cf263c18f2c3c30f183cc0f203c00f3e5c7972e5c397365c997065ce971a5ca970a5cc97125c897025cd17145c917385ca17085cc17105c817005c),(46,0xefab3ea4fab6ea9baacea33a98eac3aa0ea03ab76a5daa76a1daad6a35ab96a65aa96a25ab16a85a816af9a9e6ab9a8e6ac9a926a09abc6a71aac6a31ab46a51aa46a11ab86a61aa86a21a906a81a806a),(55,0x3fe87fa2fe83fa3be86fa33e88fa03e8f7a1de8d7a15e897a05e8e7a29e827a31e847a21e807a3f687da0b6899a0668f1a1c68dea17a89ea07a836a19a8c6a21a806a3aa8aaa0aa8caa12a88aa02a8f2a1ca8d2a24a812a38a8a2a08a882a00a8),(62,0xbf9cfe7cf9e3e70f9df67dd9e7671d9eb672d9f3674d9e3670d9fe67b99ce67d99d667999c667f19dc67b19f867619f067819c067de9d7a7f69dda7b69cda7e69d9a77a9f6a79a9c6a7ea9daa7aa9caa7ca9d2a78a9c2a7d29d4a7929c4a7e29d8a7a29c8a7c29d0a7829c0a7),(64,0xff39fcebf38fceef39bcecf3a3cef73adce37395ce97385cef93ae4e393964e993864ee13984ec13bf8ebe38f8ede3978e9e3ad8e363b98e663b18e863818efa39e8eba38e8eda3a68eea39a8eaa38a8eca3928e8a3828ef239c8ed23948e923848ee23988ea23888ec23908e823808e),(64,0xfd7375c5d70d5ce57195cc57215c0573e5c7972e5c397365c997065ce971a5ca970a5cc97125c897025cd17145c917045ce17285c217305c417205c0173e9cba70e9cda7169c9a7069cf271c9cb27389c627309c827009cdc7171c9c72d1c3473c1c707341c907041ce07181ca07081c),(75,0x3b7aade8b7acde937a8de837ad9e967a99e867a3aebaba6aebcbad2e94baf8e9e3ab8e8e3ad8ea63a18eba3a68eaa3a28eb23a88e823ad0e943a90eb83aa0e883adda976a9da876aeda9b6a8da836a75aad6a35ab56a55aa56a15a996aa5a896ac5a916a85a816ac9a926a89a826af1a9c6ad1aa46a11ab86a61aa86a21a906a81a806a),(83,0x33f84fe03f8dbe16f89be06f8f5e1d78d5e257815e397865e297825e117885e0178fb61ed8eb61ad8ab63cd873638d863628d823630d84363f987e62f983e63d98b660d9856625981663fe87fa2fe83fa3be86fa3de877a2de837a35e857a25e817a29e827a31e887a01e8dea17a89ea07a836a19a8c6a21a806a3aa8aaa0aa8caa12a88aa02a8e2a28a822a10a882a00a8),(99,0x37f79fdc7f7efddbf7afdef773ddf57755de57715df977a5dc977f65dd97b65cd97d65d597965c597265f197465e197065ff177c5fb176c5eb172c5fe17b85ce17985c6177d9f7679d9c767ad9cb678d9c367f99ee67399f667599e667199fc67719ec67e19d867c19e067019f7a75e9fda7769eda7369f9a7669dea73a9f6a79a9c6a7ea9daa7aa9caa7ca9d2a78a9c2a7d29d4a7929c4a7fc9ef273c9f7275c9e7271c9f927649f127849c127)] : List (Nat × Nat)).map (fun p => unpackLayer 14 p.1 p.2)
private theorem enteringLayer13 : layers entering true 13 = enteringData13 := by
  rw [layers,enteringLayer12]
  decide +kernel

private def enteringData14 : Grid := ([(94,0x3f07be0fbc1e783f707ae0f9c1e383fb07b60f2c1f983c507f20f641e483f107a20f041ec03e807900fcfee2fdfe7bbcf799ee33dfa7bb4f7a9ee53df27ba4f709efe3ddc7bd8f731efa3dd47bc8f711ef03dc07bff777eef7ddcfbbef775eee1ddddbbdb77e6eecdde9bb9377c6ee8dde1bb8377faeef5deebb9d77daeeb5de6bb8d77eaeed5deabb9577caee95de2bb8577f2eee5dccbbe97792ee25dd8bbd17722ef85dd0bbc17702ee185dd0bda17),(28,0xff75cee99dd63ba87740eebedd3dba3b75b6ea6dd0dbaeb74d6eaadd15bacb7496ea2dd05ba9374c6ea8dd11bac37406ea61d79da),(17,0x13f8ffb0ff627ec0fd8efb0df62bec17d8cfb09f603ec01d8bdb19b6256c02d8),(12,0xcfee2fdfe7bccf719efe3ddc7bd8f731ef03dc07b8617),(15,0xceeb1dd43ba0775d6eaadd15bacb7496ea4dd31baa37446ea61d79da),(12,0x27f0ff627ec0fd8efb0df62bec17d8cfb01f6256c02d8),(10,0x5fbfcf799ee33dfc7bb8f7b1ee63de07b8617),(11,0xceebadd15bacb7496ea4dd31baa37446ea61d79da),(8,0x27f1df61bec17d8cfb01f6256c02d8),(7,0x2fdfe7bccf719efe3dcc7b8617),(9,0x15bacb7496ea4dd31baa37446ea61d79da),(6,0x9fc17d80fb12b6056c02d8),(5,0x4bf717eff3dcc7b8617),(8,0xcb7496ea4dd09ba987430ebced59da),(8,0xe7f0cfe29fc13f88fb01f6216c02d8),(11,0xefdf5fb8bf7f9ef73dce7bacf7cc2e985e30b8617),(12,0xf374e6eb4dd09baf87570eb61d2c3a33b4a76a4ed09da),(14,0x3dfc3bf8d7f12fe05fc63f847f10fe01fc72d8a5b04b6316c22d8),(19,0x14fdc9fbe3f747ef0fdc1fbbe17dc2f385c70bd6172c2ff05ee0b9c17d82eb05e60b8c17),(25,0x3e3adc7538e871d563a2c7518e831d7dda7bb57768eed75da6bb5976a2ed7b5a76b5ad6a5ad0b5ae6b4cd6a9ad135a),(30,0x3f7c3ef8ddf13be077c76f86df15be137c46f80df1fde2fbc1f78def0bde27bc0f78faf0f5e2ebc1d78eaf0d5e32bc25788af015e0cbc2978),(37,0x7b97772f6e5cdcbf397672f8e5e1cb8397fb2ef65f6cbcd971b2fd65dacbd5972b2e965e2cb8597c32e865ff8bbf17be2e7c5fb8bb717ce2f1c5c38bfb17b62e6c5d58b8b17),(35,0x1fa6af4d1e9add34ba6a74d0e9af534ea6ad4d729a65358a6a14d029afe34fc6b78d4f1a1e35dc69b8d571a2e359c6938d471a0e35f46ae8d1d1ada34b46af0d1e1a),(44,0xebd0d7a32f47ea8bd507aa17544ea81d51eaa1d545aa83551caa195462a885500aa3e543ca8d95132a06547e287c5178a0f1476286c5198a23140628f450e8a2d141a28d45128a05145228245188a11144228),(56,0xecced99eb33c6670ccffa9df53dea73d4fda9db53e6a78d4e1a9fd53baa7b54e6a9f553aaa7954e2a9e95392a7c54e8a9e153f8a7714fa29e45388a7e14ec29e85390a7fa4ef49ee93f5276a4f949e2938527f24ee49ec939927d24ea49e4938927a24e449e0938127),(58,0x3f473e8ebd1dba397474e8e1d1dda39b47668e8d1c1a3bd473a8eb51c6a3b5472a8e951c2a3a947128e851c0a3be473c8eb91dd23aa47148ec91c923a247048ef11d6238c47288ed81d3038607740e681d5038a07640e481d1038207480e101dc03a807100ec01c803a007000e),(57,0x7b3c7679ccf199e533c26788cf219e033ccc7898f231e063cd878b0f261e0c3cb07860f181e603c807800f3f2e3e5cbcb87973b2e365cccb9197032e7a5c74b96970d2e6a5c54b9297052e425c04b9d172a2e145cc8b8917342e485c10b9c17182e505c20b8817202e005c),(65,0x7bea77d5cfa99f553ea27d5dbab37526ead9d533aac7518ea61d583aa07500eaced49daa3b5076adad4b5aa6b50d6af2d565a8cb5296a92d425a98b5616a82d405abf355e6a3cd5c9a9935526a24d509a81357c6a78d571ab6354c6a18d5d1a9a35146ac8d491aa235046af0d4e1aac35186ad0d4a1aa435086a),(79,0x1ffa2ff41fe8dfd0bfa27f40fe8b7d06fa19f463e887d00fa3ef43de8bbd077a3af435e8abd057a32f425e88bd017a3cf439e8d3d127a38f451e823d187a10f441e803d1fda1fb44b6816d199a133446680cd1f1a2e341c68ef515ea0bd467a84f511ea03d47aa87551aaa25540aa8e550caa295412a845510aa015474a8695192a225404a87151a2a245408a8c15082a205400a8),(91,0x1bf9d7f3cfe71fcf8f9e1f383e7bece7d9dbb3e7678ece1d9f5b3ab6796ce2d9f9b3d36726cf8d9d1b38367fccef99f733ce671ccfd99db33d6672ccf999d333c6670ccff19f633ac67f0cee19ec339867e0cec19f033c06700cff69eed39da75b4f369c6d3f9a7734f669ccd3faa7754f6a9cd53eaa7554f2a9c553b2a7254f8a9d153c2a7054fd29ea53e4a7494f129c253f8a7b14e629d453c8a7114fc29d853d0a7214e829e05380a7),(98,0x3fe75fce3f9dbf397e74fce1f9def3ade773ce679d8f3b6e74dce1b9d5738ae765ce4b9d17382e73e4edc9d3938727564e2c9de139c27584e309dc1398277f8e7f1dbe3a7c70f8eef1cde3abc7178ecf1c9e3b6c72d8e9b1d6638cc7318ec31d06380c76e8e5d1d3a387477a8e751d6a38d476a8e551d2a38547728e651d4a38947628e451d0a381477c8e791d7238e47748e691d5238a47648e491d1238247788eb11c6239447488e111dc239847508e211c823a047008e),(100,0xfeb8fd70bae4d5c1ab9e571cae595c32b9c5718ae615c82b80573f2e3e5cbcb8797372e2e5c9cb83973b2e365cccb9197032e7a5c74b96970d2e6a5c54b9297052e725c64b9497092e625c44b9097012e745ca8b8517322e245c88b81173c2e385cd0b9217042e705c60b9417082e205c80b80173f4e3e9ced38da72b4e169ccd389a7234e069cf9397270e4e789c71396270c4e709c6139827204e009cee395c70b8e671c4e39b47168e4d1cf838f072e0e1c1ce838d07320e441c),(117,0x7b7a76f5adea5bd0b7ae6f4cdea9bd237a86f40dea75d0ebaf574eaead5d1abaf974f2e8a5d7e3a7c7578e8f1d6e3a5c7538eb31d463a0c75e8ead1d1a3a547528e851d323ac47508e811d743aa87450eb21d243af074e0eb41d483a1075ddaabb5176aced49daa3b5076ab6d46dab1b5436a06d575a8eb56d6a5ad535a86b5756a6ad555a8ab5656a8ad415a8cb5696a52d525ab8b5316aa2d445ab0b5216a82d405ab935326aa4d449a9135426a04d5f1a9e355c6a38d5d1a9a35646a88d411abc35386ab0d461ab435286a90d421aa835106ac0d481aa035006a),(129,0x73f867f14fe09fc43f807f1dbe2b7c16f8cdf09be237c06f83af1d5e1abc65788af015e3cbc3978b2f065e34bc297892f025e28bc1178c2f105e3f6c3ed8bdb07b63d6c5ad835b1ab6156c68d891b0236286c10d8ff317e60fcc6f985f313e607cc3d98db3136606cc1598cb3096622cc7fe8bfd07fa37f42fe89fd03fa3df43be8b7d06fa3ef43de8bbd077a36f44de81bd1d7a1af455e82bd197a12f445e80bd1a7a14f449e813d187a10f401e8ef515ea0bd467a84f511ea03d44da81b5166a0cd431a8c35106a00d47aa87551aaa25540aa8e550caa295412a845510aa015438a8d15122a045410a8c15082a205400a8),(152,0xefeedfdf3fbc7f70fefefdedfb9bf7d7eeafde7bb8f77caee95de2bb8577fb2ef65eecb9d97eb2ed65eacb95974b2f165c2cbc997132fc65e8cb9197c32e865e0cb8197fe2efc5ef8b9f17f62f6c5cd8bab17962e2c5df0bee179c2e385f30ba6178c2e185efb39f67cecf1d9c3b3e36746cf0d9c1b3fe677ccfb99e7338e67ecced99eb3396674ccf199c333fc67b8ce719f633ac67f0cee19ec339867e0cec19f033c06700cfde9dbd3d7a72f4ff69eed39da75b4f369c6d3f9a7734f669ccd3dea73d4f3a9c753b6a7cd4f1a9c353faa7754f6a9cd53eaa7554f2a9c553f2a7654e4a9f153a2a7854e0a9fa53d4a7c94e929e25384a7fe4efc9f793cf27ee4edc9eb9397274e4f1c9c393f927724f649cc93f127624f849e0938127)] : List (Nat × Nat)).map (fun p => unpackLayer 15 p.1 p.2)
private theorem enteringLayer14 : layers entering true 14 = enteringData14 := by
  rw [layers,enteringLayer13]
  decide +kernel

private def enteringData15 : Grid := ([(87,0xfe0f7e0fbe0f3e0fde0f5e0f1e0fee0f6e0fce0f4e0f0e0ff60f760fb60f960ff8f778f738f7d8f758f798f718f7e8f768f7a8f728f7c8f748f788f708f7c0f780f700f7ff777f77bf773f77df775f771f77ef776f77af772f77f37773773377d3775377937713776377a3772377c37783770377fd777d77bd773d77dd775d771d77ed776d77ad772d77cd774d770d777577b57795771577e5776577a5772577c577457785770577217781770177),(25,0xf3ba73bab3ba63bac3ba03bafdba7dbabdba1dbaedba6dbacdba0dbaf5ba75ba95ba15ba65baa5ba25bac5ba45ba85ba05ba),(12,0xffd87fd8bfd8cfd80fd877d8b7d897d817d8e7d827d887d8),(10,0x7cf7ccf74cf70cf7f8f798f718f7c0f780f700f7),(12,0xb3ba63bac3ba03ba95ba15ba65baa5ba25bac9ba31ba11ba),(8,0xbfd8cfd897d817d8e7d887d8cad802d8),(7,0x8bf77cf7ccf74cf798f718f7c0f7),(7,0xb3ba65baa5ba25bac9ba11ba4c3a),(5,0x13f8e7d887d8cad802d8),(5,0x8bf77cf7ccf74cf78617),(4,0xc9ba11ba4c3a79da),(5,0x93f813f8cad88ad802d8),(5,0xcbf74bf78bf786170617),(5,0x4c3a8c3a0c3a79dad9da),(8,0xf3f873f8b3f833f8d3f853f893f813f8),(6,0xe617a6172617c61746170617),(8,0x99da19daa9da29dac9da49da89da09da),(7,0xe3f863f8a3f823f843f883f803f8),(9,0x3e176e17ce178e170e17d617561796171617),(8,0xfddabdda3ddaddda5dda1ddaf5da65da),(8,0xfef87ef8eef86ef8cef80ef8b6f886f8),(8,0xff171f17f7177717b717871707177b17),(9,0x7e9ade9afa9a3a9af29a729ab29a829a029a),(12,0x6628c628fa287a289a281a286a28ca280a28e228a2282228),(12,0x99271927e9276927a927292789270927d127512791271127),(8,0xc80e480e080ee00e600ea00e200e400e),(10,0xe63ca63c263c863c063cd83c583c983c183c303c),(13,0xf6ea76eae6ea66eaa6ea26eaccea4cea796ad96ac96a496a896a),(14,0xf1e8d1e891e811e841e881e801e8ff68bf683f68cb684b688b680b68),(21,0xefe7afe72fe74fe78fe70fe7e3e763e7c3e783e703e737676767c767876707672b67cb674b678b670b67),(27,0x7fce9fce2fcecfce4fce8fce0fcedbce5bcebe4e3e4e6e4ece4e8e4e0e4ed64e564e964ef84eb84e384e584e184ef04e704eb04e304e),(36,0xfc9c7c9cf89cb89c389c589c989c189c309cc09c809cf71c771cd71c971c171ce71c671ca71ced1cad1c2d1ccd1c4d1cfc1cbc1c3c1cdc1c5c1c9c1c1c1cf41cb41ce41c641cc41c),(49,0xfb7a7b7abb7a3b7aeb7a6b7acb7a8b7a0b7af37ab37a337aa37a237ac37a437a837aceba4eba8ebafabababa3abadaba5aba9aba1abafcba7cbabcba3cba94ba14bace3a4e3ab23a623af43a743ad43a943a143ae43a643aa43a243ac83a883a083a),(65,0xf3f8b3f833f8d3f853f893f813f8c3f843f883f803f8e6f8a6f826f846f886f806f89d781d78d1789178e1785ed89ed81ed8fad87ad8dad89ad81ad8ead86ad8aad82ad8e8d868d8c8d888d808d8d0d850d890d810d8ff987f98df989f981f98ef986f98af982f984f988f980f98bd983d986d9895981598e598a5982598c5984598),(85,0xf7f777f7b7f737f767f7fbf77bf7dbf79bf71bf7ebf76bf7abf72bf7cf774f778f770f77e5776577a5772577457785770577fd977d97bd973d97dd975d97c997499709977b17db179b171b172b17cb174b178b170b17be173e176e17ce178e170e17e617a6172617c617461786170617ff27bf27ef276f27cf27d727572797271727a7272727c727472787270727f927b927392759271927f1277127b1273127e1276127c12781270127)] : List (Nat × Nat)).map (fun p => unpackLayer 16 p.1 p.2)
private theorem enteringLayer15 : layers entering true 15 = enteringData15 := by
  rw [layers,enteringLayer14]
  decide +kernel

private def enteringData16 : Grid := ([(53,0xfe0fbf078783fdc1eee0f6707d383c9c1f0e0f3b07ed83d6c1f960f4b078e3dfb1eed8f7ac7b963df91eec8f7807b803dffeee7f77dfbbafdde26ef837741bb80ddffaef3d771ebbf75ddbaef5d772ebb875dddaef6d7786bb9d5df6aeeb57732bbe95dd4aee2577c2bbc85dc42ee0177),(16,0xe1dd30ee80775fdba7edd476e83b75edba76dd5b6e8db740dba7add5d6eb0b7485ba),(8,0xffec5ff60ffb1bfd85fec43f60efb1b7d8),(7,0x7e3ddf1efc0f7607be03de01ee00f7),(6,0x3677463ba61dd40eeb2b7515ba),(6,0x37fb0cfd8cbec25f622fb1e7d8),(7,0x133df31ee98f78c7b863df81eec0f7),(6,0x36774b3ba32dd296e84b7411ba),(5,0x1e7d873ec61f610fb1cad8),(5,0x18bf745fb9f3de99ee4cf7),(5,0xc9ba88dd046ea98744c3a),(4,0x89fc72b6115b102d8),(5,0xcbf725fbe2fdd17ee8617),(5,0x4c3ac61d430e8187479da),(9,0xf3f8d9fc4cfe067f1d3f869fc54fe0a7f013f8),(6,0x3cc2f2617e30bb185e8c2e4617),(6,0x353b4a9da94ed0a76893b409da),(5,0x1a3f851fc48fe047f003f8),(6,0x31c2f0e17070be585d2c2e1617),(8,0x7eed6f76a7bb43ddaeeed57768bbb41dda),(7,0x5fbe3ddf0eef8b77c1bbe19df10ef8),(7,0x3fc5e3e2ff7173b8bedc5d6e2f8717),(7,0x1fa6bf534fa9a1d4d2ca6b0535029a),(12,0xe314318a3f450fa28bd14668a234501a28b5141a8a19450e228),(14,0x3324f19270c93fa49ed24e6927d493aa49e524e2927c493c249fa24f5127),(13,0x1c80e64075203bc01ce00eb0071803b401ca00e90070803a801c400e),(12,0xc31e218f20c79d83cac1e160f33078983c8c1e060f26078303c),(17,0x1f6ea7b755dba8edd5e6eab37519ba94dd526ea1375733a999d54cea26755e5a8f2d4d96a),(19,0x7c7a3a3d0d1e8c8f4247a223d011e8ffb43fda37ed13f681fb472da296d04b68c5b422da216d00b68),(27,0x3bf9f5fcf2fe717f3d3f9c9fcf8fe747f3c3f9c1fcfe3e771f3d8f9cc7cfc3e761f3e0f9e07ce03e795b38ad9f96cecb67a5b392d9d16ce0b67),(35,0x4bf385f9c4fcec7e723f3a1f9c0fcedf272f93a7c9d6e4e37273393b1c9d0e4e07277593aac9c564ecb2725939f09db84e9c270e13ab09c584e8c270613be09d704ed8272c13a609c304e),(48,0x7c4e6e2727138389cac4e162723138189c984e0c273ee38f71cbb8e1dc73ae38d71ccb8e45c73ce39671c338e29c73da38ed1cd68e4b4705a39cd1c668e534709a38fc1cde0e4f0707839dc1c6e0e57070b8399c1c8e0e07073e839b41c5a0e190738838c41c),(66,0x3f6f57b7a3dbd2edea76f43b7af5bd3adead6f46b7ae5bd32deb16f50b7af9bd3cdea66f4337ad1bd28dea46f5837a41bd73aea9d744ebac75d23aebf574fabadd5d4eae87575daba6d5d56ae935751aba0d5d7f2eaf9747cbade5d2f2ea79743cbaca5d252ea297414bae71d338ea9c744e3afa1d3d0eae874743aea1d350eb2875143af21d590e8c874a43a),(87,0x7cfe1e7f1b3f899fc0cfe3a7f0d3f8a9fc24fe227f013f8e1fc50fe087f183f841fc675e13af11d780ebc57b60bdb19ed84f6c47b603db1fad87d6c5eb60f5b1dad86d6c66b6235b01ad8f56c5ab60d5b0aad8156c7a361d1b168d8346c7236191b188d8846c02363a1b150d8286c2436221b010d8ffcc3fe62ff307f98efcc37e633f311f980fcc7be61df316f9837cc6be615f314f9827cc63e611f310f98b6cc1b6632b3095980acc696624b302598e2cc316628b304598),(101,0x1f7f7bbfb9dfdd6fef37f71bfbd9fdccfeffbf77dfbdefdfb7eedbf7cdfbc6fdc37efebf7b5fb9afdf57eeabf795fb8afdf9eeecf77a7bb93ddd1eee0f77f2bbb95decaee6577d2bba95de4aee2577a2bb915df0aee857782bbff65efb2e7d975ecbcf65c7b2fbe175f0bcf85c7c2f6e17370bf985dcc2fa617930b8985f8c2ec617a30b9185d0c2e0617ff93efc9d7e4fd727ab9395c9e2e4e1727d393a9c9e4e4e2727c393a1c9e0e4e07277c93d649cb24f19270c93fc49ee24e7127d893ac49e624e3127f093b849ec24fc1276093e049e024e0127)] : List (Nat × Nat)).map (fun p => unpackLayer 17 p.1 p.2)
private theorem enteringLayer16 : layers entering true 16 = enteringData16 := by
  rw [layers,enteringLayer15]
  decide +kernel

private def enteringData17 : Grid := ([(80,0x3f83f7e0f5f83c1e0f7b83eee0f3383f4e0f5383e4e0f1383f0e0f1d83fb60f6d83eb60f2d83f960f6583e960f2583e38f70e3dfd8f7363df58f7563dc58f7f23ddc8f7c03dc00f7ffddc7f77efdddbf77afddcbf77c4ddd1377e0ddd8377a0ddc837700ddffd777f5df3d774f5de3d770f5dfdd77775dedd77375df5d77575de5d77175de1d773b5df6d775b5df0d77435de75772d5de6577195dfa577695dea577295dc2577e15dd8577c85dd2177885de0177),(24,0xf0ee9c3bab0ee803ba7f6eafdbac76e91dba876e81dbafb6eaedba3b6eb6dba5b6ea6dba1b6ea0dba3d6eb75ba5d6e985baa16e885ba),(13,0x3ffd87ff637fd81ff63bfd86ff62bfd82ff630fd89df6077d8edf61b7d8),(8,0x7e3def8f73e3ddc0f7b03dd80f7c03dc00f7),(7,0x3b3ba98eeac3bac0eeb95ba656eb15ba),(6,0xeff60cfd825f6317d845f63e7d8),(7,0x4cf7263df18f7463dc18f7f03ddc0f7),(9,0x3b3baacee8b3ba996e865baa96e8a5ba096ea11ba),(7,0x3e7d879f62e7d861f6287d821f61cad8),(4,0xe2fde7cf7d33dc4cf7),(6,0x326eb11ba446ea11bad30e94c3a),(7,0x313f844fe1cad8a2b608ad8c0b6102d8),(7,0x2cbf732fde4bf712fde8bf7a185c8617),(7,0x24c3ae30eb0c3a830e80c3a9e76879da),(12,0xbcfe1b3f8ccfe233f80cfe3d3f874fe2d3f834fe353f854fe013f8),(8,0xf985f2617f185cc617d185d46179185c4617),(8,0x2a76b29da4a76a29da0a76a49da1276809da),(6,0x28fe323f848fe023f880fe003f8),(6,0x6385f0e170385c96178585c1617),(9,0x2fddacf76a3dda0f769dddad776a5dda177681dda),(8,0xdfbe3eef83bbe36ef85bbe26ef81bbe30ef8),(11,0x2ff173fc5ff7177dc5e77171dc5fb7176dc5eb7172dc5d8717),(10,0x9fa6bfa9a7ea6afa9a3ea6a3a9a0ea6b829a60a6b029a),(15,0xc628fe8a2fa283e8a17a28e68a19a28c68a21a28068a36a285a8a26a28b28a0ca28),(18,0xe649d9927c649e19270649fe9277a49f69279a49c6927aa49ca927ca49d29278a49f8927c249d0927),(17,0x3e00e7803ae00e3803b600e98038600ee8039a00ea8038a00ec8039200e88038200ed0039400e),(14,0xf60f1d83cd60f2583c160f3983c660f2983c260f1183c860f0183ccc0f1303c),(18,0xfdbaaf6ea3dbab76ea5dbaa76ea1dba9e6ead9baa66ea19ba8a6eac9ba926ea89ba826ea933a84cea),(24,0xc47a111e8847a011e8ffda1ff68bfda0ff68efda1bf68cfda23f680fda3cb6872da34b6892da38b6862da28b6822da10b6882da00b68),(35,0xefe76bf9f2fe78bf9c2fe7d3f9d4fe793f9c4fe7e3f9e8fe723f9f0fe743f9c0fe7f8f9ee3e738f9d63e798f9c63e7f0f9dc3e7b0f9f83e760f9f03e780f9c03e772d9f4b6792d9c4b67a2d9c8b67),(50,0x93f384fcee3f3a8fcec3f390fce83f380fceef93abe4e2f93b6e4e5b93a6e4eb3938ce4e6393b0e4e839380e4ef5939d64ed593a564e1593b964e6593a964e2593af84e3e13b384e8e138384ed6139584e96138584ec6139184e86138184efc139f04eec13ab04e2c139304e8c138304e),(66,0xbe270f89c6e273389c8e270389cd6271589c96273189c46272189c06273f71cbdc70f71cddc71771c9dc70771ce5c71971cc5c71e71cd9c72671c19c72a71c29c73ed1c7b472ed1c3b4732d1c8b4702d1cf3472cd1c334714d1c13472fc1c3f071bc1ccf0723c1c0f073dc1cb7070dc1cd70715c1c970705c1ce70731c1c470721c1c07073f41c7d070b41cf1071c41cb1070c41c),(87,0x1fb7adedea7b7a1edeabb7a2edeb3b7a4edebeb7abade8eb7adade96b7a9ade86b7af2deacb7ae2de98b7ac2deaf37a3cdeb337a8cde8337ae8deaa37a28deb237a48debceba73aeb4eba93aeb8eba63aea8eba23aebfaba7eaeafaba3eaebbaba6eaeb3aba8eae83abaa6ae89abac6ae91aba86aebfcba7f2eb7cba9f2e87cbaef2eabcba2f2e93cba8f2e83cbae52ea94ba252eb14ba452ea14bafd0eaf43a3d0eb743a5d0ea743a1d0ebd43ab50eb943a650eb143a790eb643a990e8643aa90e8a43a),(117,0x3f3f87cfe2f3f83cfe3b3f86cfe333f88cfe033f8f4fe2d3f834fe293f824fe313f844fe213f8f0fe1c3f8d0fe243f8e0fe183f8a0fe083f8d7b615ed897b605ed8e7b629ed827b631ed847b601ed8feb62fad83eb617ad89eb607ad8f6b61dad8b6b639ad866b631ad886b601ad87ab62aad82ab622ad80ab63e8d8ba360e8d85a36068d8f2361c8d8b2360c8d8e236188d8c236208d802361d0d8a436090d8c436110d88436010d89fe607f98f7e61df98b7e60df98e7e619f98c7e621f98fbe61ef98bbe60ef98dbe626f981be63af986be62af982be634f9853e624f98e3e628f9823e63959865662959825662159805663a598696632598f1662c598316614598916604598),(144,0xddfde77f71dfdeb7f72dfdf37f74dfde37f70dfdf67f759fde67f719fdffbf7befdcfbf7f6fdddbf7b6fdcdbf7e6fdd9bf7c6fde1bf706fddebf7dafde6bf71afdfabf7aafdcabf7cafdd2bf78afdfcf7773ddecf77d3dde4f7713dde8f7723dde0f7703ddfe577795dee577395df6577995dc6577e95dda577a95df2577895dc2577d15dd4577915df8577a15dc8577c15dd0577ef85ebe172f85f3e174f85c3e17db85d6e179b85c6e17f985de617b985fa6176985f26178985c2617f185dc617b185cc617d185d46179185c4617a185c86178185c061775c9f572795c9c5727c5c9d172785c9c1727e9c9ea72729c9f272749c9e272709c9f872761c9e872781c9c0727d649d59279649c5927c649d19270649ff1277c49f71279c49c7127ec49db127ac49cb127cc49d31278c49fe127b849ce127d849d6127f049dc127b049cc127)] : List (Nat × Nat)).map (fun p => unpackLayer 18 p.1 p.2)
private theorem enteringLayer17 : layers entering true 17 = enteringData17 := by
  rw [layers,enteringLayer16]
  decide +kernel

private def enteringData18 : Grid := ([(87,0x13f83cbf07c1e0f3dc1fbb83d7707c4e0fe1c1ec383e3b078760ff6c1e6d83f5b07ab60f16c1e6583f4b07a960f12c1f8e3dd1c7b838f7fb1eef63de6c7b8d8f7eb1eed63dcac7b858f7f91eef23dee47b800f7ffeeeffddf89bbb1377a26ee44ddfc1bbb8377b06ee00dddfebbdfd77c7aee8f5dc1ebbfdd777baef375dc6ebbf5d776baee575dc2ebbe1d7743aef3b5dcb6bbb0d77a1aee435df3abba757796aee2d5df32bba65778caee195dfd2bb9a577d4aeea95de52bb8a57704aefe15ddc2bbd8577e42eec85df00bba0177),(22,0x201dd1fdbadfb74bf6eb0edd21dba9db743b6ebb6dd36dba2db75836ea7add0f5baeeb74dd6e8badd185bad0b74a16ea42dd085ba),(11,0x1fff61ffec1ffd8e1fb0c3f633bec277d88efb01df63dbec1b7d8),(7,0x7e3df7c7baf8f71f1efc03dd807bc00f7),(6,0x361dd2c3ba60775e56e9cadd315ba),(6,0x3dfec3bfd899fb125f628bec117d8),(6,0x24c7b918f7031eff03dee07b9c0f7),(9,0x7b3ba76775acee859dd665ba0cb75296e852dd025ba),(7,0x1f9f60f3ec6e7d85cfb061f6343ec087d8),(4,0xcf9efd33dda67b84cf7),(5,0x4c9bae2374c46ea88dd111ba),(4,0xd15b122b60456c102d8),(3,0x32fdf25fb84bf7),(3,0x1c30e9861d40c3a),(3,0x1bcfe179fc333f8),(2,0x1930bc4617),(2,0x114ed409da),(2,0x191fc123f8),(3,0x18585e0b0b81617),(5,0x1ddda6bbb59776a2eed05dda),(8,0xfddf0fbbe3b77c56ef82ddf09bbe2377c06ef8),(11,0x1fdc5dfb8bdf717cee2f1dc5c3b8bfb717b6e2e6dc5d5b8b8b717),(10,0x3fd4d5fa9a3f535bea697d4d4fa9a1f5358ea6a1d4d03a9a),(15,0xfe8a37d144fa281f4515e8a0bd1479a2873451668a0cd1471a2863451868a20d1401a28),(22,0x3cc93b9927b324e6649f8c93b1927c324f0649ef4939e9276d24f9a49e349386927d524eaa49e5493f2927a524e4a49f1493a2927),(20,0xfc01d78038f0077600e6c01d9803bd0075a00e3401da803950074a00e1401dc803a90071200ec401c8803a10070200e),(22,0x3ec1e3d83cbb079d60f1ac1e6583c8b078160f3cc1e3983cb3078660f34c1e2983c93078260f28c1e1183cc3078860f20c1e0183c),(25,0x6f6ea9edd43dbabbb75376eaaedd45dba93b75476ea0edd579ba8f375366eaccdd519ba833754a6ea14dd5c9baa9375126eac4dd489baa1375026ea),(30,0x3ffb45ff683fed0bfda07fb47bf6877ed16fda0dfb473f6867ed1f2da2e5b474b68696d192da3c5b438b68b16d062da345b428b68916d022da285b410b68c16d082da205b400b68),(39,0x13bf9c77f3dafe735fcecbf9f17f3c2fe705fcfd3f9ea7f394fe7c9fce93f9e27f384fe7d1fcf23f9c47f3f0fe761fcf43f9e07f380fe7cc7ce98f9e31f3fc3e7b87ce70f9f61f3ac3e7f07cee0f9ec1f3f03e7607cf80f9e01f3803e7),(52,0xf7c9cef93b5f274be4e17c9ddb93ab72716e4ed9c9cb393a672758e4e31c9cc393b072740e4e01c9ca593a4b270964edf09cbe13a7c273384ec709d0e1381c276584e4b09d161382c277184e6309d461388c272184e8309c0613bf8273f04ebe09c7c13bd8273b04ed609cac13a58270b04ea609c4c13b18274304e),(69,0x3f71cdee393dc707b8e7771caee385dc733b8e2771c8ee381dc70cb8e7171c62e3879c71b38e6671c8ce3819c73538e2a71c94e3829c73f68e5ed1c3da39bb471768e4ed1c1da39cb471968e62d1c85a380b471e68e54d1c29a3913470268e6fc1c9f8396f070de0e33c1cc78390f0701e0e75c1ccb83897073ce0e39c1c23839870710e0e41c1c03839fd071fa0e5f41c3e839f1072e20e1c41cd8838b1072620e0c41c),(96,0xbf6f47ede9bdbd67b7a8f6f41edea5dbd0bb7ae76f54ede89dbd3eb7add6f53ade875bd76b7a6d6f55ade8b5bd66b7a8d6f41adebe5bd6cb7a596f462deb85bd30b7ae66f4ccdeb19bd4337a066f5e8de9d1bd6a37a946f428deb91bd3237aa46f448debe75d5cebae9d74d3aebc75d58eba31d75a3ae9475d48eba11d75feaeafd5d1faba5f5753eae87d5d7baba775756eae8dd5d73aba675758eaea1d5d69aba5357526aeb0d5d21abaff974ff2eafe5d1fcbaef974df2eb3e5d47cba0f974ef2eb5e5d4bcba179754f2e89e5d63cba479750f2eb4a5d494bae2975452e88a5d214ba),(125,0x75ed8abdb057b632f6c25ed88bdb017b634f6c49ed813db1c7b618f6c51ed87f5b15eb60bd6c67ad84f5b11eb63ed6c5dad83b5b1b6b616d6c79ad8735b166b60cd6c71ad8635b186b620d6c01ad8bd5b07ab63156c22ad8055b0fa362b46c168d88d1b01a363e46c5c8d8391b1b2361646c4c8d8191b1e2361c46c588d8e11b0c2363046c408d8011b074363486c290d8921b024363086c210d8021b19fe613fcc47f980ff31f7e62efcc1df98dbf30b7e626fcc0df98f3f3167e638fcc31f98c3f31fbe61f7cc5ef983df31bbe6177cc4ef98edf30dbe6337cc46f98f5f316be60d7cc2af9895f302be6327cc24f98f1f30e3e6247cc08f98f2b3165660cacc6959852b31256604acc6159842b31056600acc3c598d8b313166062cc5459828b319166122cc44598),(147,0x1adfdd5bfbcb7f7c6fee8dfde1bfb837f7ecfeed9fdeb3fb967f74cfef19fdc33fbffbf77f7efbefde7dfb8fbf75b7ef36fdc6dfbd9bf7337ef86fde0dfbdebf73d7efdafddb5fbe6bf78d7ee1afdf55fbaabf7957ee2afdf95fbd2bf7257ef8afdd15fbfcf7779eef73ddce7bbe4f7789eee13ddf07bba0f7781eee03ddef2bb9e577dcaeeb95de72bbe65778caefe95ded2bb9a57754aeec95df12bbc257704aefd15dea2bb94577f0aeee15df42bbc857710aefc15dd82bbd057720aef75c9ceb93b5727cae4f15c9c2b93f1727a2e4e45c9f0b93a172782e4e05c9fd393ba727d4e4f29c9f9393b2727a4e4e49c9d1393c272704e4fd649eac9395927cb24e9649e2c93859278324e0649ff893bf127be24e7c49fb893b7127ce24f1c49c3893fb127b624e6c49f5893ab1279624e2c49f9893d31272624ff849df093ee1279c24e3849fb093b6127ac24e5849fe093dc1273824eb049e60938c127)] : List (Nat × Nat)).map (fun p => unpackLayer 19 p.1 p.2)
private theorem enteringLayer18 : layers entering true 18 = enteringData18 := by
  rw [layers,enteringLayer17]
  decide +kernel

private def enteringData19 : Grid := ([(103,0xcfe0f17e0fc1e0f1ee0feee0f6ee0faee0f2ee0fc4e0f44e0f70e0fb0e0f0760ffb60f1b60feb60f6b60f0b60f9960f2960f0960f238f7038f7fd8f77d8f7bd8f7cd8f74d8f70d8f7f58f7758f7958f7858f7058f7fc8f77c8f7bc8f7f137731377d1377513779137711377f83777837738377d837758377803773fd77dfd775fd7763d77a3d7723d7703d77fdd777dd77bdd77cdd770dd7775d77b5d7715d7785d7705d7721d77ced774ed7796d7730d77d0d7790d7710d77e75776757727577cb5774b577e657766577a657726577c65774657706577fa5777a5779a5772a577ca5774a5778a5770a57702577f857738577d857758577f217760177a017720177),(21,0x1fdbaefdba6fdba21dbacedba0edbaf6dba76dba96dba60dbacf5ba0f5ba775bab75ba175ba985ba285bac85ba485ba885ba085ba),(8,0xbffd81ffd8f0fd8277d8477d8077d8fb7d89b7d8),(7,0x9f8f72f8f70f8f7f00f7700f7b00f7c00f7),(7,0xec3baac3ba2c3ba303baf95bab95ba315ba),(10,0xfbfd87bfd8bbfd83bfd8ccfd84cfd8c97d8497d8d17d8117d8),(9,0xc98f7498f7918f7118f7018f7fc0f7dc0f79c0f71c0f7),(11,0xfb3ba3b3baeb3ba6b3ba0b3ba065baca5ba4a5ba0a5ba825ba025ba),(9,0xfe7d87e7d81e7d8ee7d86e7d8187d8e87d8687d8087d8),(6,0xe7cf767cf7f4cf774cf784cf704cf7),(4,0xcc9ba711bab11ba911ba),(3,0xe8ad808ad8902d8),(3,0xcbf7e4bf764bf7),(3,0xf0c3ac0c3a40c3a),(2,0x2f3f8333f8),(3,0x32617c461744617),(4,0xa29da229dac09da409da),(3,0x323f8923f8123f8),(4,0xc1617416178161701617),(6,0xb5dda35dda65ddac5dda85dda05dda),(9,0xf6ef876ef8d6ef856ef816ef8a6ef826ef8c6ef886ef8),(10,0xff717bf7173f717df7175f7177b717ab7172b7178b7170b717),(11,0xdfa9a9fa9aefa9aafa9a2fa9a4fa9ae3a9a63a9ac3a9a83a9a03a9a),(16,0xbfa283fa286fa28cfa288fa280fa28d7a2857a2897a2819a28f1a2871a28b1a2831a28e1a2861a28),(23,0xf9927b992739927d9927599279992719927f1927b1927e192761927c1927de9275e9279e927ea927aa9272a927ca9274a927e292762927a2927),(23,0xde00e5e00e9e00eb600e3600ee600e6600eea00e6a00eaa00e2a00e8a00e0a00ef200e7200ed200e5200e9200e1200ee200e6200ea200e2200e),(24,0xfd83cdd83c5d83c3583ce583c6583ce983c6983ca983c2983cc983c4983c8983cd183c5183c9183c1183ce183ca183c2183cc183c4183c8183c0183c),(30,0xef6ea6f6ea8f6ea0f6ead76ea576eac76ea476ea876eade6ea5e6ea9e6ea1e6eab66ea366ea666eac66ea866ea066eaca6ea4a6ea8a6ea0a6eae26ea626eaa26ea226ea426ea826ea026ea),(37,0x7ff68aff682ff68fbf68bbf683bf68dbf685bf68f3f6873f68b3f68fcb68dcb685cb68f4b6874b68b4b6834b68e4b6864b6878b6838b68d8b6898b6818b68e8b6868b68a8b6828b68c8b6848b6888b6808b68d0b6850b6890b6810b68),(39,0xcefe74efe78efe70efe7f4fe774fe7d4fe794fe7e4fe764fe7a4fe724fe744fe784fe704fe7e8fe768fe788fe708fe7f0fe7b0fe730fe7d0fe750fe7c0fe740fe780fe7e63e7a63e7263e7fc3e77c3e7dc3e79c3e71c3e7b03e7303e7c03e7803e7),(51,0xfbe4e7be4ebbe4e3be4eebe4e6be4ecbe4e8be4e0be4eece4ecce4e4ce4eb0e4e30e4e60e4ec964e4964e8964e0964eef84eaf84e2f84ecf84e4f84eb384e3384e6384ee584e6584ea584e2584e4584ef184e7184eb184e3184ed184e5184e9184e1184e2184ec184e4184e8184e0184eff04ebf04e3f04e5f04e9f04e1f04e),(65,0xd771c9771ce771c2771cc771c4771c8771c0771c9971c1971cf171c7171cb171c3171c9e71c1e71cb671c3671c6671cc671c8671c0671cea71caa71c2a71cca71c4a71c8a71c0a71cf2d1c72d1cb2d1c32d1ce2d1c62d1cc2d1c82d1c02d1cefc1ccfc1c4fc1cdbc1c9bc1cf9c1c79c1c91c1c11c1ce1c1ca1c1c21c1c41c1c81c1c01c1cfc41c7c41cdc41c9c41c1c41cec41c6c41cac41c2c41c4c41c8c41c0c41c),(92,0xdfb7a5fb7a9fb7a1fb7a37b7a67b7ac7b7a87b7a07b7acbb7a4bb7a8bb7a0bb7ad3b7a93b7a13b7afcb7a7cb7a2cb7a98b7a18b7af0b7a70b7afa37a7a37aba37a3a37aea37a6a37aca37a8a37a0a37af237ab237a3237a5237a1237afcebadceba5cebaf4eba74ebab4eba34eba78ebad8eba98eba18ebae8eba68ebaa8eba28ebac8eba48eba88eba08eba7fabadfaba9faba1fabaafaba2fabacfaba4faba8faba0fabadbaba5baba1babae9abaa9aba29abac9aba49abae1aba61abaa1aba21ababbcba3bcba6bcbacbcba8bcba0bcbad3cba53cba93cbae3cbaa3cba23cbac3cba43cba),(120,0xf5ed875ed8d5ed895ed8e5ed865ed8a5ed825ed845ed885ed805ed8e9ed869ed889ed809ed8f1ed8b1ed831ed8d1ed851ed8fdad87dad8edad86dad8adad8f9ad8b9ad839ad859ad899ad819ad8f1ad871ad8b1ad831ad8e1ad861ad8c1ad881ad8dead85ead89ead81ead8e2ad862ad8a2ad822ad882ad802ad8be8d83e8d8d68d8568d8968d8168d8c68d8468d8068d8fc8d87c8d8dc8d8ec8d8ac8d82c8d84c8d88c8d80c8d8c7f9847f9887f9807f987df98ddf989df981df98edf98adf982df98cdf984df988df980df98d9f9859f98f1f9871f98b1f9831f98e1f9861f98eef98aef982ef98e4f9864f98a4f9824f98b8f9838f98c8f9888f9808f98f959879598d95989959819598e959869598a959829598495988959809598e1598a159821598c15984159881598),(147,0xeb7f7ab7f72b7f7cb7f74b7f7e37f7637f7a37f7237f7437f7f67f7767f7b67f7367f7d67f7567f7967f7167f7267f7c67f7467f7867f7067f7ffbf77fbf7bfbf7cfbf78fbf70fbf7debf75ebf79ebf7f6bf776bf7b6bf736bf7e6bf766bf7eabf76abf7aabf72abf7cabf74abf78abf70abf7f2bf772bf7d2bf752bf792bf712bf7e2bf762bf7a2bf722bf7de5775e5779e5771e577e657766577c6577da5779a5771a577aa5772a577f857778577b857738577e857768577c85778857708577f0577b0577305775057710577dd7275d7279d7271d727b57273572765727f172771727d17279172711727e172761727a1727217274172701727f592775927d5927e5927a592725927459278592705927c1927419278192701927df1275f1279f127f712777127b712737127eb127ab1272b127cb1274b127f312773127fe1277e127be1273e127ee1276e127ce1278e127f6127b6127361275612796127161277c127dc1279c1271c127ac1272c127)] : List (Nat × Nat)).map (fun p => unpackLayer 20 p.1 p.2)
private theorem enteringLayer19 : layers entering true 19 = enteringData19 := by
  rw [layers,enteringLayer18]
  decide +kernel

private def enteringData20 : Grid := ([(111,0x70783d83c1f1ee0f0f707fbb83cddc1faee0f577078bb83d89c1f44e0f227079c383f61c1eb0e0f03b07fed83c36c1feb60f75b07c2d83f32c1e9960f94b078a583c12c1e238f781c7b80e3dffb1eefd8f73ec7bef63dd7b1eecd8f7a6c7b9363dc1b1eef58f7bac7be563df0b1ee858f702c7bbf23def91ef31377289bbc44ddc226eef8377bc1bb8e0ddfb06eed8377ac1bb960ddf006ee803779febb97f5dcc7aefa3d7751ebb88f5de07aee03d77feebb9f75df7baeebdd77e6ebbb375de1baee75d77daebbad75de2baef85d7702ebbc875dc9daef96d774b6bb8c35dfa1aeed0d77c86bb8435ddceaef6757713abbb2d5de96aee4b577f32bb9995df4caeea6577132bbf295dd94aef8a577452bb8095dff0aeef85779c2bb9615dfe42eef2177),(22,0x3fb74efdbab7edd4876e843b74cedba076dd3db6eaedb7596dba4b6dd1836eb9eb74cf5ba87add1dd6eb6eb74b75ba8badd1216eb10b74885ba),(9,0x1bffd88ffec07ff63e1fb0477d803bec3edf6336fb09b7d8),(7,0x67e3dc5f1eff00f7b807b9c03dd601eec00f7),(7,0x7b0ee9d8775ac3ba961dd0b0eea60775315ba),(8,0xfdfec5eff60f7fb1bbfd85dfec0eff6099fb0497d8),(8,0x8c7b8063dff81eefc0f7ee07bb703df381ee1c0f7),(8,0xfd9dd0ecee9d67756b3ba859dd0196ea94b744a5ba),(8,0xff3ec3f9f62fcfb01e7d8f73ec3b9f6030fb1087d8),(5,0xe7cf7b3e7bdd33df099ee04cf7),(4,0xe64dd1c46eb62375911ba),(3,0x3a2b62115b1902d8),(3,0x432fdfc97eee4bf7),(3,0x3c30ea8187440c3a),(3,0x4bcfe2667f0333f8),(5,0x32617e230bb1185e88c2e44617),(6,0x3453b4a29da914ed08a769813b5409da),(5,0x1323f8c91fc248fe2247f0123f8),(6,0x382c2f4161720b0ba0585e02c2e01617),(9,0x1b5dda5aeed4d77686bbb465dda62eed61776a0bbb405dda),(13,0x1f6ef87b77c5dbbe0eddf1d6ef86b77c55bbe0addf016ef8d377c49bbe30ddf086ef8),(14,0x3fee2eff717dfb8bcfdc5c7ee2fdf7176fb8bd7dc5cbee2f7b7173db8be2dc5d16e2e0b717),(17,0x1dfa9a6fd4d67ea6b5f5352fa9a17d4d53ea689f535e3a9a71d4d58ea68c7535c3a9a61d4d60ea6a0753403a9a),(23,0x6fe8a17f4513fa28b7d141be8a19f4518fa2887d1403e8a3af45157a282bd1465e8a12f45119a280cd146c68a16345131a2818d147868a1c345161a28),(30,0x1f324fb99279cc938e649fb324ed9927acc9396649f3324f199270cc93fc649f6324eb192730c93f0649d8324fde927af49397a49fd524eea927e5493b2a49e9524e4a927f1493d8a49cc524ea2927),(36,0xcf00727803b6c01cb600e9b007798039cc01d6600e330077a8039d401d6a00e350074a80385401d8a00e450074280381401df200e790075c8038e401dd200e69007548038a401d9200e4900744803bc401d6200e3100728803a4401c2200e),(37,0x1fd83c7ec1e1760f26b0783583cf4c1e3a60f2d30786983cd4c1e2a60f2530782983ce4c1e5260f0930798983c44c1e7460f2a30785183cc8c1e2460f2230781183cf0c1e3860f3430792183c10c1e7060f1830794183c20c1e2060f2030780183c),(45,0x16f6ea37b7563dbaa1edd40f6eaebb7535dbaaaedd4576eaef375579ba8bcdd59e6ea4f375479ba83cdd5b66ea5b3754d9ba86cdd4666ea63375619baa0cdd4066eae5375329baa94dd44a6ea45375429ba814dd5e26eab1375189bab44dd4a26ea91375089baa84dd4426eac1375209baa04dd4026ea),(54,0x1f7ed1bbf689dfb40efda3b7ed0dbf68adfb416fda3e7ed1b3f6859fb47f2da1f96d1dcb686e5b4572da0b96d1f4b68ba5b41d2da1696d134b681a5b4792da1c96d164b68325b45e2da0f16d138b681c5b4362da3316d118b680c5b43a2da2d16d068b68d45b44a2da0516d0c8b68245b4622da1116d108b68045b4742da2a16d050b68c85b4242da2216d010b68),(60,0xe77f3b3bf9e9dfce4efe7477f3c3bf9c1dfcff4fe77a7f3dd3f9ce9fcfd4fe76a7f3e53f9fc9fcee4fe7b27f3993f9f49fcea4fe7927f3893f9e89fce44fe7c27f3c13f9c09fcfe8fe7747f3da3f9cd1fcf88fe7847f3823f9fe1fcef0fe7d87f3cc3f9c61fcfd0fe7687f3d43f9ca1fcfc0fe7a07f3903f9f01fce80fe7f31f3b98f9e4c7ce263e7fe1f3bf0f9ef87ce7c3e7ee1f3b70f9f387cf1c3e7),(74,0x177c9d3be4e1df277af939d7c9d6be4ee5f2732f93b17c9d0be4e05f2772593a92c9c4964ec4b2722593a12c9c0964ef7c273be13b5f09d2f84e17c2773e1399f09d4f84e27c276ce1396709d3384e19c2758e138c709de584e72c27596138cb09da584e52c274961384b09d4584e22c277c6139e309d7184e38c276c613a6309c3184ee8c2734613aa309d9184e88c2704613a4309c2184ee0c275061388309d8184e40c274061380309cff04edf8274fc1387e09c5f04ecf82727c13a3e09c1f04e),(93,0x1d771ccbb8e25dc73cee38e771c93b8e09dc738ee38c771ca3b8e11dc730ee388771c83b8e01dc7332e389971c8cb8e065c73e2e397171c38b8e6c5c7162e393171c18b8e679c713ce391e71c0f38e6d9c716ce393671c1b38e599c70cce38c671cc338e419c700ce39ea71c7538e6a9c7254e382a71ce538e329c7294e384a71c4538e429c7014e39f2d1cb968e1cb47165a3932d1c1968e78b471c5a3962d1c3168e70b47185a3982d1c8168e3870734383921c1c10e0e5070708383981c1c40e0e40707003839fc41c7e20e5f1070f8838dc41cf620e3b1072d88386c41cd620e4b1070588394c41c2620e631071188390c41c),(121,0x1dfb7aafdbd67ede93f6f51fb7a0fdbd4dede86f6f567b7a33dbd31edeb0f6f507b7a03dbd7e8deaf46f47a37add1bd2e8dea746f43a37af51bd5a8deb946f4ca37ac51bd428de8146f4f237aa91bd148dea246f41237afe75d3f3aebb9d74dcebaae75d173aebe9d7574eba3a75d2d3aea69d7434ebabc75d1e3ae9b1d7598eba8c75d063aebd1d74e8ebab475d1a3aeb51d74a8eba9475d0a3aeb91d7448ebac475d223aea11d7408ebabfd5d1feae9bf5759faba8fd5d07eaeb5f574afaba97d5d0beaeb9f5754faba27d5d63eae91f5750faba07d5d76eae9b75751baba0dd5d7a6ae9d3575a9aba94d5d0a6aeb93574c9abaa4d5d126aebc357561aba30d5d286aea4357421abadde5d2ef2ea779756bcba35e5d32f2eba797553cba29e5d64f2e927975e3cba71e5d68f2ea4797423cbae1e5d30f2ea8797443cba),(158,0x3ebdb175ed8eaf6c357b632bdb1e5ed872f6c597b60cbdb1a5ed852f6c497b604bdb145ed822f6c617b610bdb105ed802f6c7a7b61d3db169ed834f6c627b6213db009ed8f8f6c3c7b6363db131ed818f6c747b61a3db151ed828f6c7f6b61fb5b17dad8f6d6c5b6b60db5b0adad87cd6c6e6b62735b039ad8acd6c166b63335b099ad88cd6c066b63e35b171ad838d6c6c6b61635b131ad818d6c786b62c35b1c1ad860d6c606b63bd5b15ead82f56c67ab613d5b11ead80f56c78ab62c55b062ad8d156c28ab62455b022ad8c156c20ab62055b002ad8df46c2fa3627d1b03e8d8eb46c55a360ad1b1968d84b46c45a3602d1b1c68d86346c51a3608d1b1068d80346c1f2363b91b0dc8d8f646c6b2361591b18c8d88646c5f7e60fbf30ddf98cefcc477e603bf31adf9896fcc737e631bf308df98ecfcc367e62b3f3059f98f8fcc5c7e60e3f30b1f9898fcc0c7e63c3f30e1f98b0fcc7e5661f2b31795983cacc765661b2b31995988cacc065663d2b30e9598b4acc1a566352b312959814acc52566092b318959844acc42566342b3121598e0acc50566082b3081598),(186,0x3d6feeeb7f7d5bfbcadfdc56fefcb7f765bfbd2dfdc96fefe37f771bfbd8dfdcc6fefa37f751bfbc8dfdc46fef437f721bfbdd9fdcecfefb67f79b3fb8d9fdfacfeed67f7ab3fbe59fde2cfee167f7933fb899fdf8cfef467f7233fbe19fdd0cfef067f7033fbffefdeff7ee7fbf7dfdfbafefdf1f7ef0fbf707dfbf7afdebd7ee5ebf7fb5fbddafdced7efb6bf75b5fbcdafdc6d7efe6bf7735fbd9afdccd7efeabf7755fbdaafdcd57efaabf7955fb8aafdf957eecabf7a55fb92afdf157ef0abf7055fbfcafdde57ef72bf7395fbf4afdda57ef52bf7295fbe4afdd257ef12bf7095fbf8afdec57ee62bf7515fbc8afdc457efde5776f2bbd795dcbcaee9e5778f2bb8795dfccaeee6577b32bb9995df8caeec65776d2bbe695de34aee1a577d52bbaa95de54aee2a577bc2bb9e15df70aeeb8577f42bbba15ded0aefc8577642bbbc15dea0aee50577ceb93a75c9c3ae4fb57275ab93cd5c9c6ae4e65727f8b93bc5c9ee2e4fd172768b93e45c9e22e4e11727f0b93b85c9ec2e4e61727d0b93a85c9e42e4e21727a0b93905c9e02e4e01727ef893d7c49cbe24feb12775893eac49e5624e2b127e5893b2c49e9624e4b127f9893bcc49ee624e73127ff093df849cfc24fbe1275f093cf849c7c24fee127b7093f3849d9c24f8e127ab09395849f2c24e96127)] : List (Nat × Nat)).map (fun p => unpackLayer 21 p.1 p.2)
private theorem enteringLayer20 : layers entering true 20 = enteringData20 := by
  rw [layers,enteringLayer19]
  decide +kernel

private def enteringData21 : Grid := ([(63,0x3c1e0fc7b83d1ee0f07b83feee0f7bb83e6ee0f2bb83c2ee0f31383f44e0f51383c44e0fe6583d9960fa6583c9960fca583e2960f02583c038f77f63defd8f76163de858f72163df313774c4dde51377044ddcf8377de0ddd7837798f5dc63d77e8f5dda3d7728f5dc23d77c0f5dd03d779f75dcbdd77f375ddcdd77b375df15d774575de05d77e435dd90d7789d5dccb577d2d5dd4b57712d5dfe65772295df385771615dff21777c85def2177),(12,0xc876e921dba8876e8cedbae5b6e996dba25b6eb0f5ba43d6ea775ba2dd6e8485ba),(5,0x31ffd847ff601ffd881df60fb7d8),(5,0x39f8f767e3dc700f7ac03dcb00f7),(3,0x1ec3babb0eeb315ba),(2,0xdeff62497d8),(2,0x63dd9c0f7),(2,0x8ecee8065ba),(2,0x5f9f60187d8),(2,0xd9f3dd84cf7),(2,0x7326ea711ba),(2,0x3a2b63902d8),(3,0x30cbf7f92fdde4bf7),(4,0xbc30eb40c3a9030e840c3a),(5,0x32f3f8cccfe1333f88ccfe0333f8),(8,0x8c985c32617f1185ec461731185d4461791185c44617),(9,0x3a29daa8a768a29dac8a769229da88a768229da302769409da),(9,0x3323f84c8fe3923f8648fe2923f8248fe1123f8848fe0123f8),(9,0x1c1617d0585e4161710585c81617c0585d0161780585c01617),(13,0x3b5ddaad776b35dda4d776a35dda0d776a65dda19776ac5dda31776985ddac1776805dda),(20,0xfdbbe1f6ef8bdbbe376ef89dbbe3d6ef8b5bbe0d6ef855bbe256ef815bbe216ef805bbe3a6ef8c9bbe126ef8e1bbe186ef8a1bbe086ef8),(22,0x3fdc5fbf7176fdc5f3f7178fdc5c3f717f7dc5ddf717b7dc5cdf717d7dc5d5f71797dc5c5f717dedc5d7b7179edc5c7b717e2dc5d8b71782dc5c0b717),(25,0x3dfa9a77ea6adfa9a37ea6b9fa9a67ea69afa9acbea6a2fa9a0bea6b4fa9a53ea6a4fa9af8ea6ae3a9a38ea6b63a9a58ea6a63a9a18ea6bc3a9a70ea6ac3a9ae0ea6983a9a),(30,0xefe8a2bfa282fe8a36fa285be8a26fa28f5e8a1d7a28d5e8a257a2815e8a397a2865e8a297a2825e8a319a284668a019a28ec68a2b1a282c68a331a284c68a231a280c68a3e1a28b868a0e1a28d868a161a28),(38,0xf6649ed992736649f5992756649e5992716649f1992746649e1992706649ff19277c649cb1927f0649dc1927b0649cc1927f7a49dde927d7a49e5e92717a49fea9277aa49eea9273aa49fca927b2a49cca92752a49e4a92712a49f6292798a49c62927a8a49ca2927),(48,0xed803ab600e2d803b3600e4d803be600eb98038e600ed980396600e9980386600efa8039ea00eba8038ea00eda803a6a00e1a803b2a00e8a80382a00ee2803a8a00e22803b0a00e42803a0a00e02803bf200ebc8038f200edc80397200e9c80387200ef48039d200ee480399200ea480389200e78803b6200e9880386200ea88038a200e),(55,0x3fd83c7f60f2fd83c3f60f25d83c1760f3e983c7a60f2e983c3a60f36983c9a60f06983cea60f1a983caa60f0a983cca60f12983c8a60f02983cf260f1c983cd260f14983c9260f04983ce260f18983ca260f08983cf460f1d183cd460f25183ce460f19183ca460f09183cf860f1e183cb860f0e183ce860f1a183cc860f22183c0860f3c183cb060f0c183cc060f10183c8060f00183c),(65,0x36f6ea5bdbaa6f6ea1bdbab8f6ea63dbab0f6ea83dba80f6eaf79ba9de6ead79baa5e6ea179bab9e6ea679baa9e6ea279ba91e6ea879ba81e6eaed9baab66ea2d9bab366ea4d9baac66ea319ba9866eac19baa066ea019babca6eab29ba8ca6ead29ba94a6ea129bab0a6ea429baa0a6ea029babe26ea789bab626ea989ba8626eae89ba9a26eaa89ba8a26ea489baa226ea089bab426ea509baa426ea109bab826eaa09ba8826eac09ba9026ea809ba8026ea),(82,0xbefda0fbf686efda33bf688efda03bf68d6fda15bf6896fda3f3f687cfda3b3f686cfda2b3f682cfda3fcb687f2da2fcb683f2da25cb68172da1f4b68dd2da274b681d2da0b4b68cd2da134b688d2da034b68f92da2e4b68392da364b68592da264b68192da378b689e2da338b684e2da238b680e2da2d8b68362da198b68c62da218b68062da2e8b683a2da368b685a2da268b681a2da3a8b686a2da328b684a2da228b680a2da2c8b68322da388b68622da288b68222da308b68422da208b68022da3d0b68742da350b68942da050b68e42da190b68a42da090b68442da010b68),(95,0x3cefe7b3bf9ccefe7d3bf9d4efe793bf9c4efe723bf9f0efe743bf9e0efe703bf9ff4fe7bd3f9cf4fe7dd3f9d74fe79d3f9c74fe7353f9f94fe7653f9fe4fe7793f9ee4fe7393f9f64fe7993f9c64fe7e93f9da4fe7a93f9ca4fe7c93f9d24fe7893f9c24fe7d13f9d44fe7913f9c44fe7e13f9f04fe7413f9f68fe75a3f9e68fe71a3f9f88fe7623f9f08fe7823f9c08fe7fc3f9df0fe7bc3f9cf0fe7ec3f9db0fe7cc3f9e30fe7f43f9ed0fe7343f9d50fe7943f9c50fe7f03f9dc0fe7d03f9e40fe7103f9f80fe7603f9e80fe7203f9fe63e7798f9ee63e7398f9f263e7898f9c263e7ff0f9efc3e73f0f9f7c3e75f0f9e7c3e71f0f9fdc3e7b70f9f9c3e7670f9f1c3e7),(117,0x2bbe4e2ef93b3be4e4ef93a3be4efaf93aebe4e3af93bcbe4e72f93acbe4e32f93b8be4e62f93b0be4e82f9380be4ef25939c964ed2593a4964e12593b8964ea259388964e42593a0964e02593bef84e7be13aef84eebe139af84ecbe13a2f84e0be13bcf84eb3e138cf84ed3e1394f84e93e1384f84eece13ab384e2ce13b3384e4ce13a3384e0ce13b6384e58e13a6384e18e13be584e79613ae584e39613ba584e69613aa584e29613b2584e8961382584ed161394584e91613bf184e7c613af184e3c613b7184e5c613bb184e6c613b3184e8c61383184eb46138d184ed461395184ec461391184e84613b2184e48613a2184e08613bc184e70613b4184e9061384184ee061398184ea061388184e40613a0184e00613aff04e3fc139bf04ecfc13a3f04e0fc13a5f04e17c13b9f04ea7c1389f04ec7c1391f04e87c1381f04e),(147,0x3d771c75dc739771c65dc729771c25dc73e771c79dc72e771c39dc732771c49dc702771cf1dc71c771cb1dc70c771cd1dc714771c91dc704771ce1dc718771ca1dc708771c41dc720771c01dc739971ca65c709971cc65c711971c865c701971cdc5c727171c1c5c73b171c6c5c72b171c2c5c713171c8c5c703171ce79c729e71c279c711e71c879c701e71ced9c72b671c2d9c733671c4d9c723671c0d9c736671c599c726671c199c70c671c619c730671c819c700671cfa9c71ea71cba9c73aa71c6a9c732a71c8a9c702a71cf29c71ca71cb29c70ca71cd29c714a71c929c704a71ca29c708a71c7cb47372d1c9cb47072d1cacb470b2d1cccb47132d1c8cb47032d1cf8b472e2d1c38b47362d1c58b47262d1c18b473c2d1cb0b47382d1c60b47302d1c387071a1c1cc8707221c1c08707341c1c50707241c1c10707381c1ca0707081c1cc0707101c1c80707001c1c5f10727c41c1f1072dc41c371073ec41c7b1072ec41c3b10736c41c9b10706c41c6b10732c41c8b10702c41cd310714c41c9310738c41ca310708c41cc310710c41c),(188,0xf7ede9dfb7ae7ede99fb7aa7ede89fb7a47edea1fb7a07edeb37b7a4dedea37b7a0dedeb67b7a59edea67b7a19edeac7b7a31ede987b7ac1edea07b7a01edebfa37a7e8deb7a37a9e8de87a37aee8de9ba37aae8de8ba37a4e8dea3a37a0e8debea37ada8de96a37af28de9ca37ab28de8ca37a628deaf237a3c8deb5237a548dea5237a148deb1237a448de81237aff3ae9fcebabf3ae8fcebaf73aeadceba373ae95ceba973ae85ceba7d3aeb74eba9d3ae874eba2d3aeb34eba4d3aea34eba0d3aeb78eba9e3aead8eba363ae998ebac63aea18eba063aeb68eba9a3ae868ebaea3ae9a8ebaaa3ae8a8ebaca3ae928eba8a3ae828ebaf23ae9c8eba923ae848ebae23ae988ebaa23ae888ebac23ae908eba823ae808ebadfeae97faba9feae87faba37eaeb9faba67eaeb1faba87eae81fabaebeaeaafaba2beaeb2faba4beaea2faba0beaebcfaba73eaeb4faba93eae84fabae3eaea8faba23eaea0faba03eaebdbabab6eae8dbabac6eae91baba86eae81babafa6ae9e9ababa6ae8e9abaea6ae9a9abaf26aeac9aba326ae949aba126ae9e1abad86aea61aba186aeaa1aba286aeb21aba486aea21aba086aebbbcbaaef2e8bbcbadaf2e96bcba9af2eacbcba32f2ebd3cba74f2eb53cba94f2e853cbae4f2e993cbaa4f2e893cbaf8f2e9e3cbab8f2e8e3cbae8f2e9a3cbac8f2ea23cbaf0f2eac3cba30f2e943cba90f2e843cba),(238,0xfd7b6375ed85d7b60d5ed8e57b6195ed8f97b61e5ed8b97b60e5ed8d97b6265ed8197b63a5ed8697b62a5ed8297b6325ed8497b6225ed8097b6345ed8517b6245ed8117b6385ed8a17b6085ed8c17b6105ed8817b6005ed8fa7b62e9ed83a7b6369ed85a7b6269ed81a7b6389ed8627b6309ed8827b6009ed8fc7b61f1ed8bc7b60f1ed8ec7b61b1ed8cc7b6231ed8f47b62d1ed8347b6151ed8947b6051ed8ff6b62fdad83f6b637dad85f6b61edad8db6b626dad81b6b62adad82b6b61b9ad8ce6b6239ad80e6b6359ad8566b6259ad8166b6399ad8a66b6099ad8c66b6119ad8866b6019ad87c6b6371ad89c6b6071ad8ec6b61b1ad8ac6b60b1ad8cc6b6131ad88c6b6031ad8d86b6161ad8f06b61c1ad8b06b60c1ad8e06b6181ad8f7ab61dead8d7ab625ead8e7ab619ead8a7ab609ead847ab621ead807ab63e2ad878ab6362ad898ab6062ad8e8ab61a2ad8a8ab6382ad8a0ab6082ad8c0ab6102ad880ab63be8d8afa360be8d8cfa3613e8d88fa3603e8d8f5a361d68d8d5a362568d815a363968d865a362968d845a362168d805a363c68d8b1a360c68d8d1a361468d891a360468d8c1a361068d881a360068d8f72361dc8d8b72360dc8d8fb2361ec8d82b23638c8d8c323610c8d8df7e627df98b77e60ddf98677e631df98877e601df98eb7e632df984b7e63cdf98737e638df98637e628df98237e63d9f98b67e60d9f98567e6259f98167e61f1f98dc7e6171f989c7e6071f982c7e6331f984c7e6231f980c7e63e1f98b87e60e1f98fe5662f95983e5661795981e5663d9598765662d9598365663995986656631959886566019598fa5661e95989a566069598d2566249598e256628959822566309598425663a159868566321598d056614159890566041598a0566081598),(287,0x3eb7f77adfdeeb7f7eadfddab7f7cadfde2b7f70adfdfcb7f7b2dfdccb7f7d2dfdd4b7f792dfdc4b7f7f8dfdde37f7b8dfdce37f7d8dfde637f718dfdfa37f768dfdea37f728dfdf237f788dfdc237f7d0dfdd437f790dfdf767f75d9fde767f71d9fdfb67f76d9fde367f70d9fded67f7359fdf567f7559fdd967f7c59fdd167f7859fdc167f7c99fdd267f7899fdc267f7f19fddc67f7d19fde467f7119fdf867f7619fde867f7219fdd067f7819fdc067f7ffefddffbf7dfefde7fbf7efefddbfbf7afefdcbfbf7e3efdd8fbf7c3efde0fbf703efdfdebf777afddf6bf7ddafde76bf71dafdfb6bf7adafdcb6bf7cdafdd36bf78dafdc36bf7f9afdee6bf739afdf66bf759afde66bf719afdfeabf77aafdeeabf73aafdf6abf75aafde6abf71aafdfaabf76aafdf2abf78aafdfcabf7b2afdccabf752afde4abf712afdd8abf7fcafdef2bf73cafdf72bf75cafde72bf71cafdfd2bf774afded2bf7d4afde52bf714afdf92bf764afde92bf724afdde2bf7d8afde62bf718afdea2bf728afdf22bf748afde22bf708afdfde5777795dede5773795df5e5775795de5e5771795dc9e577c795dd1e5778795dfe6577b995dce65775995de665771995dfc65777195dec65773195deda5773695dd9a577c695de1a5770695dfaa577aa95dcaa577ca95dd2a5778a95dc2a577de15de785771e15deb85772e15dfe8577ba15dce8577da15dd68577bc15dcf0577d415dd50577e75c9d9d727a75c9e1d727075c9f357274d5c9e357270d5c9e65727195c9ff1727bc5c9cf1727dc5c9d71727f45c9dd1727b45c9f91727645c9f11727845c9c11727785c9ee1727385c9f61727985c9c61727e85c9da1727a85c9ca1727c85c9d21727885c9f41727505c9e41727105c9f01727405c9c01727f7c49ddf127d7c49e5f12717c49feb1277ac49eeb1273ac49fab1276ac49f2b1278ac49fcb127b2c49ccb12752c49e4b12712c49ff3127bcc49cf3127dcc49d731279cc49c731277f849f7e1279f849c7e127ef849dbe127af849cbe127cf849e3e1270f849fee127db849d6e12733849f8e12763849f5612755849e5612715849f96127a5849c96127)] : List (Nat × Nat)).map (fun p => unpackLayer 22 p.1 p.2)
private theorem enteringLayer21 : layers entering true 21 = enteringData21 := by
  rw [layers,enteringLayer20]
  decide +kernel

theorem entering_empty : (layers entering true 22).head? = some [] := by
  rw [layers,enteringLayer21]
  decide +kernel


theorem blocked {word : List Bool} {outside : Bool} {r} (link : Linked r)
    (base : fits 1 r 0 (layers word outside 0))
    (last : outside = true → r (word.length-1) % 65536 ∉ trapCodes)
    {w} (cut : (layers word outside w).head? = some []) : False := by
  have survive := survives link base last w
  generalize eq : layers word outside w = grid at survive cut
  cases grid with
  | nil => simp at cut
  | cons a tail =>
    simp at cut
    subst a
    exact List.not_mem_nil survive.1

theorem no_seven_then_five_three {r} (h : ∀ t, r (t+1) = double (r t))
    (trace : fits 1 r 0 (layers forbidden false 0)) : False :=
  blocked (link_double r h) trace (by simp) forbidden_empty

theorem eight_then_two_fives_enters {r} (h : ∀ t, r (t+1) = double (r t))
    (trace : fits 1 r 0 (layers entering true 0)) :
    r (entering.length-1) % 65536 ∈ trapCodes := by
  by_cases mem : r (entering.length-1) % 65536 ∈ trapCodes
  · exact mem
  · exact False.elim (blocked (link_double r h) trace (by intro _; exact mem) entering_empty)


-- The packed finite-cone bridge follows the kit’s Rule30TrappedRuns proof.
open Rule30Ether Rule30StripCertificates Rule30PeriodTwoCoupled
private theorem cone (R : Nat → Bool) (b x W : Nat)
    (start : ∀ j, j < W → x.testBit j = drv altCol R b (j+1)) :
    ∀ t j, j+t < W →
      (packed (fun k => altCol (b+k)) x t).testBit j = drv altCol R (b+t) (j+1) := by
  intro t
  induction t with
  | zero => exact start
  | succ t ih =>
    intro j hj
    rw [packed,step_bit,show b+(t+1) = b+t+1 by omega, drv_isR30 altCol R (b+t) j]
    unfold Rule30Jen.rule
    rw [ih j (by omega), ih (j+1) (by omega)]
    cases j with
    | zero => simp [drv_col0]
    | succ j => simp [ih j (by omega)]

private theorem packed_twice (b x : Nat) (hb : b%2=1) :
    ∀ i, iterate x i = packed (fun k => altCol (b+k)) x (2*i) := by
  intro i
  induction i with
  | zero => rfl
  | succ i ih =>
    have ho : altCol (b+2*i) = false := by unfold altCol; simp; omega
    have he : altCol (b+(2*i+1)) = true := by unfold altCol; simp; omega
    rw [iterate,ih,show 2*(i+1)=2*i+1+1 by omega, packed,packed,ho,he,double]

private theorem prefix_bit : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), j < n →
    (encList (seg f n)).testBit j = f j
  | 0, _, _, h => absurd h (by omega)
  | _+1, f, 0, _ => by
    rw [Nat.testBit_zero]
    simp only [seg, encList]
    cases f 0 <;> simp <;> omega
  | n+1, f, j+1, h => by
    rw [Nat.testBit_succ]
    change (((if f 0 then 1 else 0) + 2 * encList (seg (fun i => f (i+1)) n)) / 2).testBit j = _
    have e (a : Nat) : ((if f 0 then 1 else 0) + 2*a) / 2 = a := by cases f 0 <;> simp <;> omega
    rw [e]
    exact prefix_bit n _ j (by omega)


private theorem firsts {r : Nat → Nat} (t : Nat) (word : List Bool)
    (h : ∀ i, i<word.length → (r (t+i)).testBit 0 = word.getD i false) :
    fits 1 r t (word.map fun b => [b.toNat]) := by
  induction word generalizing t with
  | nil => trivial
  | cons b ds ih =>
    constructor
    · have e := h 0 (by simp)
      simp only [Nat.add_zero, List.getD_cons_zero] at e
      have lt := Nat.mod_lt (r t) (by decide : 0<2)
      cases b <;> simp_all [Nat.testBit_zero] <;> omega
    · apply ih
      intro i hi
      exact (by simpa [Nat.add_assoc, Nat.add_comm 1 i] using h (i+1) (by simpa using hi))

def Reads (R : Nat → Bool) (s : Nat) (word : List Bool) :=
  ∀ i, i<word.length → Rule30PeriodTwoSideways.u R (s+i) = word.getD i false

private theorem realization (R : Nat → Bool) (s : Nat) (word : List Bool) (read : Reads R s word) :
    ∃ a, fits 1 (iterate a) 0 (word.map fun b => [b.toNat]) ∧
      ∀ j, j<16 → (iterate a (word.length-1)).testBit j =
        drv altCol R (2*(s+(word.length-1))+1) (j+1) := by
  let b := 2*s+1
  let W := 16 + 2*word.length
  let f := fun j => drv altCol R b (j+1)
  let a := encList (seg f W)
  have agree (i j : Nat) (hi : j+2*i<W) :
      (iterate a i).testBit j = drv altCol R (2*(s+i)+1) (j+1) := by
    rw [packed_twice b a (by dsimp [b]; omega)]
    rw [show 2*(s+i)+1=b+2*i by dsimp [b]; omega]
    exact cone R b a W (prefix_bit W f) _ _ hi
  refine ⟨a,firsts 0 word (fun i hi => ?_),fun j hj => agree _ j (by dsimp [W]; omega)⟩
  simpa [Rule30PeriodTwoSideways.u] using (agree i 0 (by dsimp [W]; omega)).trans (read i hi)

/-- Seven successive short gaps and then one long gap exclude a short next gap. -/
theorem physical_no_seven_then_five_three (R : Nat → Bool) (s : Nat) : ¬ Reads R s forbidden := by
  intro h
  obtain ⟨a,base,_⟩ := realization R s forbidden h
  exact no_seven_then_five_three (r:=iterate a) (fun _ => rfl) base

/-- Eight successive short gaps and then two long gaps force trap entry by the final pulse. -/
theorem physical_eight_then_two_fives_enters (R : Nat → Bool) (s : Nat) (h : Reads R s entering) :
    win R (2*(s+34)+1) ∈ trap := by
  obtain ⟨a,base,agree⟩ := realization R s entering h
  have mem := eight_then_two_fives_enters (r:=iterate a) (fun _ => rfl) base
  change (iterate a 34) % 65536 ∈ trapCodes at mem
  apply List.mem_map.mpr
  refine ⟨_,mem,?_⟩
  unfold decode win rowOf
  apply seg_congr
  intro i hi
  change (((iterate a 34) % 2^16).testBit i) = _
  rw [Nat.testBit_mod_two_pow]
  rw [show entering.length-1=34 by decide] at agree
  simpa [hi] using agree i hi
end Ruliology.CellularAutomata.PureThreeExit
