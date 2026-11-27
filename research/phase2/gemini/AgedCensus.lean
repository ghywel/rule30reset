import Ruliology.CellularAutomata.Rule30LateTwins

/-!
I317 counted starts with the help of 4096 inverse histories and grouped
their physical tick-24 images using a bounded preimage multiplicity.
Here the witnesses are forward iterates of one hypothetical immortal.
They start at different widths and their top bits continue to move at
unit speed. Consequently their images stay different at every common
physical age. The unit slope counts one witness per two bit positions.
The finite-horizon image deficit needed to contradict this is open.
-/

namespace PhaseTwo.AgedCensus

open Ruliology.CellularAutomata Rule30ZeroBoundary IntegerForm Rule30LateTwins

/-- The first k even-time checks begin at physical tick 0. -/
def starts (n k : Nat) : List Nat :=
  (List.range (4^n)).filter fun y =>
    (List.range k).all fun s => iter G s y % 2 == 1

/-- Distinct physical tick-h rows of those starts, even if h > 2k. -/
def endpoints (n k h : Nat) : List Nat :=
  ((starts n k).map (iter F h)).eraseDups

/-- One immortal orbit supplies one persistent image per eligible pair of
    top-bit positions, uniformly in the check horizon and image age. -/
theorem lower_of_immortal {y : Nat} (immortal : ∀ s, iter G s y % 2 = 1)
    (n k h : Nat) : n - y.log2/2 ≤ (endpoints n k h).length := by
  have nz : y ≠ 0 := by
    have := immortal 0
    change y % 2 = 1 at this
    omega
  let m := y.log2
  let count := n - m/2
  let row (q : Fin count) := iter G q.val y
  let image (q : Fin count) := iter F h (row q)
  have orbitTop (q : Fin count) : Top (row q) (m+2*q.val) := by
    dsimp [row]
    rw [iter_G_eq_iter_F_two_mul]
    exact Top_iter (top_log2 nz) _
  have imgTop (q : Fin count) : Top (image q) (m+2*q.val+h) :=
    Top_iter (orbitTop q) h
  have injective {a b : Fin count} (eq : image a = image b) : a=b := by
    have top := imgTop a
    rw [eq] at top
    have := Top_unique top (imgTop b)
    exact Fin.ext (by omega)
  have incl : (List.finRange count).map image ⊆ endpoints n k h := by
    intro z hz
    obtain ⟨q, _, rfl⟩ := List.mem_map.mp hz
    apply List.mem_eraseDups.mpr
    apply List.mem_map.mpr
    refine ⟨row q, ?_, rfl⟩
    have qlt := q.isLt
    change q.val < n-m/2 at qlt
    have top := orbitTop q
    have rnz : row q ≠ 0 := by
      intro eq
      have bit := top.1
      simp [eq] at bit
    have log := Top_unique (top_log2 rnz) top
    have below : row q < 4^n := by
      rw [show 4 = 2^2 by decide, ← Nat.pow_mul]
      exact Nat.lt_of_lt_of_le Nat.lt_log2_self
        (Nat.pow_le_pow_right (by decide : 0<2) (by omega))
    simp [starts, below]
    intro s _
    simpa only [iter_add, row] using immortal (q.val+s)
  have nodup : ((List.finRange count).map image).Nodup :=
    (List.nodup_finRange count).map image (fun _ _ ne eq => ne (injective eq))
  simpa [count,m] using nodup.length_le_of_subset incl

private theorem empty_after (hq : Q01) (n : Nat) : ∃ k, starts n k = [] := by
  have bounded (M : Nat) : ∃ k, ∀ y < M, ∃ s < k, iter G s y % 2 = 0 := by
    induction M with
    | zero => exact ⟨0,fun _ impossible => by omega⟩
    | succ M ih =>
      obtain ⟨k,deaths⟩ := ih
      obtain ⟨s,death⟩ := Q01_iff_integer.mp hq M
      refine ⟨max k (s+1),fun y hy => ?_⟩
      by_cases h : y=M
      · exact ⟨s,by omega,h ▸ death⟩
      · obtain ⟨r,hr,hz⟩ := deaths y (by omega)
        exact ⟨r,by omega,hz⟩
  obtain ⟨k,deaths⟩ := bounded (4^n)
  refine ⟨k,List.eq_nil_iff_forall_not_mem.mpr ?_⟩
  intro y mem
  simp [starts] at mem
  obtain ⟨s,hs,white⟩ := deaths y mem.1
  have black := mem.2 s hs
  omega

/-- The image age may vary with both the width and the check horizon. -/
theorem q01_iff_endpoint_deficit :
    Q01 ↔ ∀ d : Nat, ∃ n k h, (endpoints n k h).length + d < n := by
  constructor
  · intro q01 d
    obtain ⟨k,dead⟩ := empty_after q01 (d+1)
    exact ⟨d+1,k,0, by simp [endpoints,dead]⟩
  · intro sparse
    apply Q01_iff_integer.mpr
    intro y
    apply Classical.byContradiction
    intro no
    have alive (s : Nat) : iter G s y % 2 = 1 := by
      have := not_exists.mp no s
      omega
    obtain ⟨n,k,h,small⟩ := sparse (y.log2/2)
    have := lower_of_immortal alive n k h
    omega

/-- The same equivalence holds for any prescribed image-age schedule. -/
theorem q01_iff_scheduled_deficit (age : Nat → Nat → Nat) :
    Q01 ↔ ∀ d : Nat, ∃ n k, (endpoints n k (age n k)).length + d < n := by
  constructor
  · intro q01 d
    obtain ⟨k,dead⟩ := empty_after q01 (d+1)
    exact ⟨d+1,k,by simp [endpoints,dead]⟩
  · exact fun small => q01_iff_endpoint_deficit.mpr fun d => by
      obtain ⟨n,k,h⟩ := small d
      exact ⟨n,k,age n k,h⟩

end PhaseTwo.AgedCensus
