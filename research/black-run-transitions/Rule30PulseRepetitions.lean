import Rule30PulseRelay
import Ruliology.CellularAutomata.Rule30GapRepetitions
namespace Ruliology.CellularAutomata.ShieldCascade
open Rule30Jen Rule30Realization Rule30GapRepetitions

/-- If a qualifying singleton center word repeats for N complete comparisons,
its masked observation repeats for the entire finite stretch. The later edge
bound from the independently submitted PR 379 then gives N*P < a+P. -/
theorem finite_center_repeats {H} (build : Builds H) {r j} (chain : Relays H r j)
    (a P N : Nat) (age : 0<a) (short : r<P) (span : P-r≤4*j)
    (run : ∀ d, d<r → cell (a+d) 0=true) (white : cell (a+r) 0=false)
    (repDrive : ∀ s, s≤N*P → cell (a+s) 0=cell (a+P+s) 0) :
    N*P<a+P := by
  have hp : 0<P := by omega
  have copy (k : Nat) (hk : k≤N) (d : Nat) (hd : d<P) :
      cell (a+k*P+d) 0=cell (a+d) 0 := by
    induction k with
    | zero => simp
    | succ k ih =>
      have size := Nat.mul_le_mul_right P hk
      rw [Nat.succ_mul] at size ⊢
      have e := repDrive (k*P+d) (by omega)
      rw [show a+P+(k*P+d)=a+(k*P+P)+d by omega,show a+(k*P+d)=a+k*P+d by omega] at e
      exact e.symm.trans (ih (by omega))
  have pulse (k : Nat) (hk : k≤N) : Pulse seed (a+k*P+r) 0 r := by
    refine ⟨by omega,?_,?_⟩
    · intro d hd;rw [evol_seed,show a+k*P+r-r+d=a+k*P+d by omega,copy k hk d (by omega),run d hd]
    · rw [evol_seed,copy k hk r short,white]
  apply singleton_mask_window age (show a<a+P by omega) repDrive
  intro s hs
  let k:=s/P
  let b:=s%P
  have hb : b<P := Nat.mod_lt _ hp
  have rep : s=k*P+b := by
    have z:=Nat.div_add_mod s P
    simpa only [k,b,Nat.mul_comm P (s/P)] using z.symm
  have hk : k<N := by
    apply Classical.byContradiction; intro notlt
    have h : N≤k := by omega
    have z:=Nat.mul_le_mul_right P h
    omega
  have room:=Nat.mul_le_mul_right P (show k+1≤N by omega)
  rw [Nat.succ_mul] at room
  have same := repDrive s (by omega)
  simp only [freeRight,same]
  by_cases early : b<r
  · have z:= (copy k (by omega) b hb).trans (run b early)
    rw [← show a+s=a+k*P+b by omega,same] at z
    rw [z];rfl
  · have driver : ∀v, v<P-r →
        evol seed (a+k*P+r+v) 0=evol seed (a+(k+1)*P+r+v) 0 := by
      intro v hv
      rw [evol_seed,evol_seed,Nat.succ_mul]
      have z:=repDrive (k*P+r+v) (by omega)
      simpa only [show a+(k*P+r+v)=a+k*P+r+v by omega,
        show a+P+(k*P+r+v)=a+(k*P+P)+r+v by omega] using z
    have z:=finite_relay build chain (pulse k (by omega)) (pulse (k+1) (by omega)) driver
      (b-r) (by omega) (by omega)
    rw [evol_seed,evol_seed,Nat.succ_mul,show a+k*P+r+(b-r)=a+s by omega,
      show a+(k*P+P)+r+(b-r)=a+P+s by omega] at z
    rw [z]
end Ruliology.CellularAutomata.ShieldCascade
