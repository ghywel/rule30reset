import ModulusRank
import ModulusSlice

/-! A failure of the adjacent-pair conclusion on a strip forces failure on
its two immediate substrips. Generate just the compatible extensions. -/
namespace PhaseFalls.Moduli

def labelsOf (w : Nat) (a : Nat → Nat) := (List.range w).map a

def norm (m : Nat) (xs : List Nat) : List Nat :=
  xs.map (rotate m (xs.headD 0))

def extend (m : Nat) (bad : List (List Nat)) : List (List Nat) :=
  bad.flatMap fun xs => (List.range m).filterMap fun p =>
    let ys := xs ++ [p]
    if bad.contains (norm m ys.tail) then some ys else none

def ruledOut (m : Nat) (previous remaining : List (List Nat)) : List (List Nat) :=
  (extend m previous).filter (fun xs => !(remaining.contains xs))

def pairs (m : Nat) := (List.range m).map fun q => [0,q]

abbrev Valid (w m : Nat) (a : Nat → Nat) := ∀ j, j < w → a j < m

def Classifies (w m : Nat) (bad : List (List Nat)) : Prop :=
  ∀ a, Valid w m a → a 0 = 0 → Good w m a ∨ labelsOf w a ∈ bad

theorem pairs_classify (m : Nat) : Classifies 2 m (pairs m) := by
  intro a ha zero
  exact Or.inr (List.mem_map.mpr ⟨a 1,List.mem_range.mpr (ha 1 (by decide)),by
    simp [labelsOf, zero, show List.range 2 = [0,1] by decide]⟩)

theorem good_congr {w m : Nat} {a b : Nat → Nat}
    (h : ∀ j, j < w → a j = b j) (good : Good w m a) : Good w m b := by
  intro x hx
  apply good x
  refine ⟨hx.bounded,fun t => ?_⟩
  have eq : permit w a (t%m) = permit w b (t%m) := by
    apply Nat.eq_of_testBit_eq
    intro j
    rw [permit_bit,permit_bit]
    by_cases hj : j < w
    · rw [h j hj]
    · simp [hj]
  rw [eq]
  exact hx.edge t

private theorem sound_label {c : Certificate} {w : Nat} {a : Nat → Nat} (h : c.labels = labelsOf w a)
    (j : Nat) (hj : j < w) : label c j = a j := by
  unfold label
  rw [h,List.getD_eq_getElem?_getD]
  have bound : j < (List.range w).length := by simpa using hj
  simp only [labelsOf,List.getElem?_map,List.getElem?_eq_getElem bound,List.getElem_range,Option.map_some,Option.getD_some]

private theorem phase_extend {w m : Nat} {a : Nat → Nat} {bad : List (List Nat)} (hw : 0 < w)
    (leftWord : labelsOf w a ∈ bad)
    (rightWord : labelsOf w (fun j => rotate m (a 1) (a (j+1))) ∈ bad) (last : a w < m) :
    labelsOf (w+1) a ∈ extend m bad := by
  have endWord : labelsOf w a ++ [a w] = labelsOf (w+1) a := by
    simp only [labelsOf,List.range_succ (n:=w),List.map_append,List.map_cons,List.map_nil]
  have tailWord : norm m (labelsOf (w+1) a).tail =
      labelsOf w (fun j => rotate m (a 1) (a (j+1))) := by
    have head : ((List.range w).map (fun j => a (j+1))).headD 0 = a 1 := by
      obtain ⟨v,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : w ≠ 0)
      simp [List.range_succ_eq_map]
    simp only [labelsOf,List.range_succ_eq_map (n:=w),List.map_cons,List.tail_cons,
      List.map_map,Function.comp_def,Nat.succ_eq_add_one,norm,head]
  apply List.mem_flatMap.mpr
  refine ⟨labelsOf w a,leftWord,List.mem_filterMap.mpr ⟨a w,List.mem_range.mpr last,?_⟩⟩
  simp [endWord,tailWord,rightWord]

theorem classify_step {w m : Nat} {previous remaining : List (List Nat)} {cs : List Certificate}
    (hw : 0 < w) (hm : 0 < m)
    (prev : Classifies w m previous)
    (certs : cs.all (check (w+1) m) = true)
    (complete : ruledOut m previous remaining = cs.map Certificate.labels) :
    Classifies (w+1) m remaining := by
  intro a ha zero
  rcases prev a (fun j h => ha j (by omega)) zero with good | leftWord
  · exact Or.inl (good_of_slice (k:=0) (v:=w) (w:=w+1) (by omega) (by simpa using good))
  have ha1 := ha 1 (by omega)
  let b (j : Nat) := rotate m (a 1) (a (j+1))
  have hb : Valid w m b := fun j hj => rotate_lt ha1 (ha (j+1) (by omega))
  have b0 : b 0 = 0 := by simp [b,rotate]
  rcases prev b hb b0 with good | rightWord
  · have good' := good_of_rotated ha1 (fun j hj => ha (1+j) (by omega))
      (show Good w m (fun j => rotate m (a 1) (a (1+j))) by simpa [b,Nat.add_comm] using good)
    exact Or.inl (good_of_slice (k:=1) (w:=w+1) (by omega) good')
  by_cases bad : labelsOf (w+1) a ∈ remaining
  · exact Or.inr bad
  have h := phase_extend hw leftWord rightWord (ha w (by omega))
  have member : labelsOf (w+1) a ∈ ruledOut m previous remaining := by
    unfold ruledOut
    exact List.mem_filter.mpr ⟨h,by simp [List.contains_eq_mem,bad]⟩
  rw [complete] at member
  obtain ⟨c,hc,eq⟩ := List.mem_map.mp member
  exact Or.inl (good_congr (sound_label eq) (good_of_check hm (List.all_eq_true.mp certs c hc)))

theorem of_empty {m : Nat} (classified : Classifies 6 m []) {a : Nat → Nat} (ha : Valid 6 m a) : Good 6 m a := by
  have h0 := ha 0 (by decide)
  apply good_of_rotated h0 ha
  have e := classified (fun j => rotate m (a 0) (a j))
    (fun j hj => rotate_lt h0 (ha j hj)) (by simp [rotate])
  simpa only [List.not_mem_nil, or_false] using e

end PhaseFalls.Moduli
