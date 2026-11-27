import ModulusStrip

namespace PhaseFalls.Moduli

private def parityRow (t : Nat) : Nat := [3,36,63,1].getD (t%4) 0

private def parityEdges : Bool := (List.range 4).all fun t =>
  parityRow t < 64 &&
  (successors 6 (parityRow t)).contains (parityRow (t+1)) &&
  fits (permit 6 (fun _ => 0) (t%2)) (parityRow t) (parityRow (t+1))

private theorem parityEdges_ok : parityEdges = true := by decide +kernel

private theorem parity_run : Run 6 2 (fun _ => 0) parityRow := by
  have verify (p : Nat) (hp : p < 4) :=
    List.all_eq_true.mp parityEdges_ok p (List.mem_range.mpr hp)
  have data (t : Nat) :=
    verify (t%4) (Nat.mod_lt _ (by decide))
  refine ⟨fun t => ?_,fun t => ?_⟩
  · have fact := data t
    simp only [Bool.and_eq_true, decide_eq_true_eq] at fact
    simpa only [parityRow, Nat.mod_mod] using fact.1.1
  · have fact := data t
    simp only [Bool.and_eq_true, List.contains_iff_mem] at fact
    have here : parityRow (t%4) = parityRow t := by simp [parityRow]
    have next : parityRow (t%4+1) = parityRow (t+1) := by
      unfold parityRow
      rw [show (t%4+1)%4=(t+1)%4 by omega]
    have phase : t%4%2=t%2 := by omega
    exact ⟨by simpa only [here,next] using fact.1.2,
      by simpa only [here,next,phase] using fact.2⟩

private theorem parity_bad : (List.range 5).all (fun j =>
    (parityRow ((if j=0 then 1 else 0)+2) >>> j)%4 !=
      (parityRow (if j=0 then 1 else 0) >>> j)%4) = true := by decide +kernel

/-- The four-row loop is an admissible free-exterior strip whose falls all
start on even ticks. Every adjacent pair changes under the lag-two shift. -/
theorem not_good_parity : ¬ Good 6 2 (fun _ => 0) := by
  intro h
  obtain ⟨j,N,hj,per⟩ := h parityRow parity_run
  let r := if j=0 then 1 else 0
  have bad := List.all_eq_true.mp parity_bad j (List.mem_range.mpr (by omega))
  have eq := per (4*N+r) (by omega)
  have here : parityRow (4*N+r) = parityRow r := by
    unfold parityRow
    rw [show (4*N+r)%4=r%4 by omega]
  have next : parityRow (4*N+r+2) = parityRow (r+2) := by
    unfold parityRow
    rw [show (4*N+r+2)%4=(r+2)%4 by omega]
  rw [here,next] at eq
  change ((parityRow (r+2) >>> j)%4 != (parityRow r >>> j)%4) = true at bad
  simp [eq] at bad

end PhaseFalls.Moduli
