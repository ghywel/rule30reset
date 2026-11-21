module

public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! Smallest observation sets hitting a finite family of physical counterexamples.
Indices are positive spatial sites. The list of observations can include
arbitrarily distant sites and can be supplied in any order. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30MaskTransversals

def Hits (a : List Nat) (es : List (List Nat)) :=
  ∀ e, e ∈ es → ∃ i, i ∈ e ∧ i ∈ a

/-- Choose one observed site on the first missed support and remove all supports it hits. -/
def picks : Nat → List (List Nat) → List (List Nat)
  | 0, [] => [[]]
  | 0, _::_ => []
  | _+1, [] => [[]]
  | k+1, e::es => e.flatMap fun i =>
      (picks k (es.filter fun s => !s.contains i)).map (i :: ·)

/-- Every observation list of the given size contains one of the enumerated solutions.
The leftover list accounts for repeated observations and irrelevant or distant sites. -/
theorem picks_complete (k : Nat) (a : List Nat) (es : List (List Nat))
    (size : a.length ≤ k) (hit : Hits a es) :
    ∃ p, p ∈ picks k es ∧ ∃ rest, a.Perm (p ++ rest) := by
  induction k generalizing a es with
  | zero =>
    have eq : a=[] := List.length_eq_zero_iff.mp (by omega)
    subst a
    cases es with
    | nil => exact ⟨[],by simp [picks],[],List.Perm.refl _⟩
    | cons e es =>
      obtain ⟨i,_,hi⟩ := hit e (by simp)
      simp at hi
  | succ k ih =>
    cases es with
    | nil => exact ⟨[],by simp [picks],a,List.Perm.refl _⟩
    | cons e es =>
      obtain ⟨i,hie,hia⟩ := hit e (by simp)
      have small : (a.erase i).length ≤ k := by rw [List.length_erase_of_mem hia]; omega
      have remaining : Hits (a.erase i) (es.filter fun s => !s.contains i) := by
        intro s h
        obtain ⟨hs,no⟩ := List.mem_filter.mp h
        obtain ⟨j,hj,hja⟩ := hit s (List.mem_cons_of_mem _ hs)
        have ne : j ≠ i := by
          rintro rfl
          simp at no
          exact no hj
        exact ⟨j,hj,(List.mem_erase_of_ne ne).mpr hja⟩
      obtain ⟨p,hp,rest,hrest⟩ := ih (a.erase i) _ small remaining
      refine ⟨i::p, ?_,rest,(List.perm_cons_erase hia).trans (.cons i hrest)⟩
      exact List.mem_flatMap.mpr ⟨i,hie,List.mem_map.mpr ⟨p,hp,rfl⟩⟩

set_option maxRecDepth 16384
set_option maxHeartbeats 12000000

def disjointSupports : List (List Nat) := [[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [42], [43], [44], [45], [46], [47], [48], [50], [51], [54], [56], [58], [60], [61], [64, 65], [59, 68], [63, 67, 74], [57, 62, 66, 69, 70, 71, 75, 80, 81, 82, 86, 87, 88, 89, 90, 93, 96, 97, 98, 99, 100, 106, 107, 108, 109, 112, 117, 119, 120, 121, 123], [20, 73], [41, 72], [49, 79], [52, 76], [53, 77], [55, 85]]

def extraSupports : List (List Nat) := [[20, 78], [41, 73], [49, 72], [52, 72], [53, 72], [55, 72], [59, 66], [63, 66, 68, 76], [57, 64], [57, 62, 65, 68, 70], [59, 65], [62, 64, 71], [57, 62, 65, 66, 68, 69, 71, 72, 73, 74, 75, 76, 77, 78, 84, 94, 95, 97, 101, 105, 106, 116, 117, 120, 125]]

def edges : List (List Nat) := [[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [42], [43], [44], [45], [46], [47], [48], [50], [51], [54], [56], [58], [60], [61], [64, 65], [59, 68], [20, 73], [41, 72], [49, 79], [52, 76], [53, 77], [55, 85], [20, 78], [41, 73], [49, 72], [52, 72], [53, 72], [55, 72], [59, 66], [57, 64], [59, 65], [63, 67, 74], [62, 64, 71], [63, 66, 68, 76], [57, 62, 65, 68, 70], [57, 62, 65, 66, 68, 69, 71, 72, 73, 74, 75, 76, 77, 78, 84, 94, 95, 97, 101, 105, 106, 116, 117, 120, 125], [57, 62, 66, 69, 70, 71, 75, 80, 81, 82, 86, 87, 88, 89, 90, 93, 96, 97, 98, 99, 100, 106, 107, 108, 109, 112, 117, 119, 120, 121, 123]]

def mask57 : List Nat := (List.range' 1 64).erase 57

def mask62 : List Nat := (List.range' 1 64).erase 62

private theorem lengths : mask57.length=63 ∧ mask62.length=63 := by decide +kernel

/-- Enumerated in nondecreasing support size to eliminate the 53 forced singletons first. -/
private theorem finalists :
    (picks 63 edges).all (fun p => decide (p.Perm mask57 ∨ p.Perm mask62)) = true := by
  decide +kernel

theorem classification_of_hits (a : List Nat) (size : a.length≤63) (hit : Hits a edges) :
    a.Perm mask57 ∨ a.Perm mask62 := by
  obtain ⟨p,hp,r,perm⟩ := picks_complete 63 a edges size hit
  have good := (List.all_eq_true.mp finalists) p hp
  have alternatives : p.Perm mask57 ∨ p.Perm mask62 := of_decide_eq_true good
  have eq : p.length=63 := alternatives.elim
    (fun h => h.length_eq.trans lengths.1) (fun h => h.length_eq.trans lengths.2)
  have len := perm.length_eq
  rw [List.length_append,eq] at len
  have nil : r=[] := List.length_eq_zero_iff.mp (by omega)
  subst r
  rw [List.append_nil] at perm
  exact alternatives.imp (fun h => perm.trans h) (fun h => perm.trans h)

theorem minimum_of_hits (a : List Nat) (hit : Hits a edges) : 63≤a.length := by
  by_cases small : 63≤a.length
  · exact small
  rcases classification_of_hits a (by omega) hit with h | h
  · have := h.length_eq.trans lengths.1
    omega
  · have := h.length_eq.trans lengths.2
    omega

end Ruliology.CellularAutomata.Rule30MaskTransversals
