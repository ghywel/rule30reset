module
public import word_cover_base
public import WheelGateObserver

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open WheelGateObserver Rule30GateTrapWords

/-- Nine complete gate factors force spatial entry. -/
def markers : List (List Bool) :=
  [word 20 0x12121, word 23 0x484842, word 26 0x484242, word 29 0x12108421,
   word 30 0x24210908, word 30 0x24210909, word 31 0x10842108,
   word 33 0x21084842, word 38 0x212108424]

def extra : List Bool := word 29 0x2108424

/-- The only clean 47-sample reading that can end outside. -/
def exceptional : List Bool := word 47 0x84842109090

private def hits (patterns : List (List Bool)) (suffix : List Bool) := patterns.any (·.isPrefixOf suffix)

/-- Grow the word towards its beginning and stop at the first recognized factor. -/
private def search (patterns : List (List Bool)) : Nat → List Bool → Bool
  | 0, suffix => hits patterns suffix
  | n+1, suffix => hits patterns suffix || (search patterns n (false::suffix) && search patterns n (true::suffix))

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
private theorem cover : search (forbidden ++ markers) 48 [] = true := by decide +kernel

private def readings (g : Nat → Bool) (s : Nat) : Nat → List Bool
  | 0 => []
  | n+1 => g s :: readings g (s+1) n

private theorem readings_len (g s n) : (readings g s n).length = n := by
  induction n generalizing s with
  | zero => rfl
  | succ n ih => simpa only [readings,List.length_cons] using congrArg Nat.succ (ih (s+1))

private theorem read_index (g s n i) (h : i<n) :
    (readings g s n).getD i false = g (s+i) := by
  induction n generalizing s i with
  | zero => omega
  | succ n ih =>
    cases i with
    | zero => rfl
    | succ i =>
      change (readings g (s+1) n).getD i false = _
      simpa only [show s+1+i=s+(i+1) by omega] using ih (s+1) i (by omega)

private theorem hit_sound (patterns : List (List Bool)) (g s n) (hit : hits patterns (readings g s n) = true) :
    ∃ w ∈ patterns, w.length ≤ n ∧ Reads g s w := by
  obtain ⟨w,mem,h⟩ := List.any_eq_true.mp hit
  obtain ⟨rest,eq⟩ := List.isPrefixOf_iff_prefix.mp h
  have len := congrArg List.length eq
  simp only [List.length_append,readings_len] at len
  refine ⟨w,mem,by omega,?_⟩
  intro j bound
  have h := congrArg (fun l : List Bool => l.getD j false) eq
  rw [read_index g s n j (by omega)] at h
  simpa only [List.getD_eq_getElem?_getD,List.getElem?_append_left bound] using h.symm

private theorem search_sound (patterns : List (List Bool)) (g : Nat → Bool) (s n tail : Nat)
    (checked : search patterns n (readings g (s+n) tail) = true) :
    ∃ off w, w ∈ patterns ∧ off+w.length ≤ n+tail ∧ Reads g (s+off) w := by
  have here (yes : hits patterns (readings g (s+n) tail) = true) :
      ∃ off w, w ∈ patterns ∧ off+w.length ≤ n+tail ∧ Reads g (s+off) w := by
    obtain ⟨w,mem,bound,r⟩ := hit_sound patterns _ _ _ yes
    exact ⟨n,w,mem,by omega,r⟩
  induction n generalizing tail with
  | zero => exact here checked
  | succ n ih =>
    rcases Bool.or_eq_true_iff.mp checked with done | both
    · exact here done
    · have branches := Bool.and_eq_true_iff.mp both
      have sub : search patterns n (readings g (s+n) (tail+1)) = true := by
        change search patterns n (g (s+n) :: readings g (s+n+1) tail) = true
        cases g (s+n) <;> first | exact branches.1 | exact branches.2
      obtain ⟨off,w,mem,size,matchW⟩ := ih (tail+1) sub (by
        intro found
        obtain ⟨w,mem,bound,r⟩ := hit_sound patterns _ _ _ found
        exact ⟨n,w,mem,by omega,r⟩)
      exact ⟨off,w,mem,by omega,matchW⟩

/-- A clean 48-sample window contains at least one of the nine markers. -/
theorem clean_contains_marker (g s) (clean : Clean g s 48) :
    ∃ off w, w ∈ markers ∧ off+w.length≤48 ∧ Reads g (s+off) w := by
  obtain ⟨off,w,mem,size,r⟩ := search_sound _ g s 48 0 cover
  rcases List.mem_append.mp mem with bad|marked
  · exact False.elim (clean off w bad size r)
  · exact ⟨off,w,marked,size,r⟩
set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
private theorem cover47 : search (forbidden ++ (exceptional :: extra :: markers)) 47 [] = true := by
  decide +kernel

/-- Every clean 47-sample string is the exceptional word or contains a forcing marker. -/
theorem clean_47_cases (g s) (clean : Clean g s 47) :
    Reads g s exceptional ∨
    ∃ off w, w ∈ extra :: markers ∧ off+w.length≤47 ∧ Reads g (s+off) w := by
  obtain ⟨off,w,mem,size,r⟩ := search_sound _ g s 47 0 cover47
  rcases List.mem_append.mp mem with bad|left
  · exact False.elim (clean off w bad size r)
  · rcases List.mem_cons.mp left with rfl|yes
    · have length : exceptional.length = 47 := by decide
      have z : off = 0 := by omega
      exact Or.inl (by simpa [z] using r)
    · exact Or.inr ⟨off,w,yes,size,r⟩

end Ruliology.CellularAutomata.WordCover
