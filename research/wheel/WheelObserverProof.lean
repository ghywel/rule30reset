module
public import WheelObserverCheck
@[expose] public section
namespace Ruliology.CellularAutomata.WheelObserverProof
open WheelObserverCheck WheelObserverTransport

private theorem splits (x W : Nat) :
    x%2^(W+1)=x%2^W ∨ x%2^(W+1)=x%2^W+2^W := by
  rw [Nat.pow_succ]
  let z := x%(2^W*2)
  have small : z/(2^W)<2 := (Nat.div_lt_iff_lt_mul (Nat.two_pow_pos W)).mpr
    (by simpa [z,Nat.mul_comm] using Nat.mod_lt x (by have := Nat.two_pow_pos W; omega : 0<2^W*2))
  have eq : z%2^W=x%2^W := Nat.mod_mod_of_dvd x ⟨2,rfl⟩
  have sum := Nat.mod_add_div z (2^W)
  rw [eq] at sum
  have mem : z / (2^W) ∈ [0,1] := List.mem_range.mpr small
  simp only [List.mem_cons,List.not_mem_nil,or_false] at mem
  rcases mem with h|one
  · exact Or.inl (by simpa [h,z] using sum.symm)
  · exact Or.inr (by simpa [one,z] using sum.symm)

theorem cut_of_top (cert : ∀ u, u<65536 → top u = true) : Cut := by
  intro x obs
  let z := fun W t => sampleRow x t%2^W
  have descend (k W : Nat) (lower : 16≤W) (endAt : W+k=30)
      (ok : ∀ t, t<48 → (allowed W (z W t)).testBit t = true)
      (walk : ∀ t, t<48 → tree k W (z W t)=true) : False := by
    induction k generalizing W with
    | zero =>
      have final := layer_sound_path x W (by omega) (allowed W) (WheelObserverPlanes.front W) (B W)
        (fun t ht => walk t ht) ok 0 (by decide)
      have eq : W=30 := by omega
      simp [eq,B] at final
    | succ k ih =>
      have pair (t : Nat) (ht : t<48) := Bool.and_eq_true_iff.mp (walk t ht)
      have both := layer_sound_path x W (by omega) (allowed W) (WheelObserverPlanes.front W) (B W)
        (fun t ht => (pair t ht).1) ok
      apply ih (W+1) (by omega) (by omega)
      · intro t ht
        have eq : z (W+1) t % 2^W = z W t :=
          Nat.mod_mod_of_dvd _ ⟨2,Nat.pow_succ ..⟩
        simpa only [allowed,show W+1 ≠ 16 by omega,ite_false,Nat.add_sub_cancel,eq] using both t ht
      · intro t ht
        have nz : B W (z W t) ≠ 0 := by
          intro zero
          have one : (B W (z W t)).testBit t=true := both t ht
          simp [zero] at one
        have disj := Bool.or_eq_true_iff.mp (pair t ht).2
        have sides := Bool.and_eq_true_iff.mp (disj.resolve_left (fun h => nz (beq_iff_eq.mp h)))
        rcases splits (sampleRow x t) W with a|a
        · simpa only [z,a] using sides.1
        · simpa only [z,a] using sides.2
  have valid (t : Nat) (ht : t<48) : (baseMask (z 16 t)).testBit t=true := baseMask_on ht (obs t ht)
  apply descend 14 16 (by decide) (by decide) (fun t ht => valid t ht)
  intro t ht
  have good := cert (z 16 t) (Nat.mod_lt _ (by decide : 0<2^16))
  have nz : baseMask (z 16 t) ≠ 0 := by
    intro zero
    have h := valid t ht
    simp [zero] at h
  rcases Bool.or_eq_true_iff.mp good with a|a
  · exact False.elim (nz (beq_iff_eq.mp a))
  · exact a

end Ruliology.CellularAutomata.WheelObserverProof
