import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! The periodic-gate witnesses for the 58 outstanding right halves in the L1612 sample.
Seeds encode columns 1, 2, ... starting at bit zero. `tick` is a physical tick.
Each certificate is checked against the kit's packed orbit and its literal invariant. -/
namespace Ruliology.CellularAutomata.K50Sample

open Rule30Jen Rule30Ether Rule30PeriodTwoCoupled Rule30PeriodTwoSideways
open Rule30DrivenPrefix Rule30SidewaysLocks Rule30StripCertificates

set_option maxRecDepth 10000
set_option maxHeartbeats 10000000

/-- The literal cells of a physical strip, extracted from the kit's packed finite orbit. -/
private theorem strip_eq (seed t k w : Nat) :
    rowOf (drv altCol (rh seed)) t k w =
      seg (fun i => (packed altCol seed t).testBit (k + i)) w := by
  apply Rule30Ether.seg_congr
  intro i _
  exact (packed_sound altCol (rh seed) seed (fun _ => rfl) t (k+i)).symm

structure EtherEntry where
  seed : Nat
  tick : Nat
  k : Nat
  offset : Nat

private def etherOK (e : EtherEntry) : Bool :=
  let row := packed altCol e.seed e.tick
  let phase := (e.tick + e.offset) % 4
  decide (e.k ≥ 1 ∧ (3 + e.k) % 7 = 2 ∧ (e.offset = 1 ∨ e.offset = 3) ∧
    (∀ i : Fin e.k, row.testBit i = ether (3 + (i.val + 1)) (e.tick + e.offset)) ∧
    (phase, seg (fun i => row.testBit (e.k + i)) 13) ∈ wallStates)

private theorem ether_sound {e : EtherEntry} (ok : etherOK e = true) :
    EventuallyPeriodic (u (rh e.seed)) := by
  obtain ⟨positive, modseven, offset, core, wall⟩ := of_decide_eq_true ok
  have hboundary : ∀ t, e.tick ≤ t → drv altCol (rh e.seed) t 0 = ether 3 (t + e.offset) := by
    intro t _
    rw [drv_col0, altCol, ether_mod, ether_check.2.1 _ (Nat.mod_lt _ (by decide))]
    apply Bool.eq_iff_iff.mpr
    simp
    omega
  have hedge : ∀ p, 1 ≤ p → p ≤ e.k →
      drv altCol (rh e.seed) e.tick p = ether (3 + p) (e.tick + e.offset) := by
    intro p hp hpk
    obtain ⟨i, rfl⟩ : ∃ i, p = i + 1 := ⟨p - 1, by omega⟩
    rw [← packed_sound altCol (rh e.seed) e.seed (fun _ => rfl)]
    exact core ⟨i, by omega⟩
  rw [← strip_eq] at wall
  have persists := trap_invariant (drv_isR30 altCol (rh e.seed)) 3 e.offset e.k e.tick
    modseven hboundary hedge wall
  have gate (s : Nat) (hs : e.tick ≤ 2*s+1) :
      u (rh e.seed) s = ether 4 (2*s+1+e.offset) := by
    have h := (persists (2*s+1-e.tick)).1 1 positive
    simpa only [show e.tick + (2*s+1-e.tick) = 2*s+1 by omega, u] using h
  refine ⟨e.tick, 2, by decide, fun s hs => ?_⟩
  rw [gate (s+2) (by omega), gate s (by omega)]
  exact ether_congr rfl (by omega)

structure SevenEntry where
  seed : Nat
  tick : Nat
  phase : Nat

private def sevenOK (e : SevenEntry) : Bool :=
  decide (e.tick % 2 = 1 ∧ e.phase < 7 ∧
    decodeW 30 (packed altCol e.seed e.tick) ∈ cls 30 lock7Codes e.phase)

private theorem seven_sound {e : SevenEntry} (ok : sevenOK e = true) :
    EventuallyPeriodic (u (rh e.seed)) := by
  obtain ⟨odd, phase, window⟩ := of_decide_eq_true ok
  apply u_eventuallyPeriodic_of_lock (V := 29) lock7_ok (by decide) (rh e.seed)
    (s0 := e.tick / 2) phase
  rw [show 2 * (e.tick / 2) + 1 = e.tick by omega]
  unfold winW
  rw [strip_eq]
  exact window

def etherEntries : List EtherEntry := [
  ⟨931991791, 12, 6, 3⟩, ⟨748146697, 11, 6, 1⟩, ⟨658534734, 27, 6, 1⟩,
  ⟨963231197, 49, 6, 1⟩, ⟨1068373947, 54, 6, 1⟩, ⟨832957007, 31, 6, 1⟩,
  ⟨619256739, 19, 6, 3⟩, ⟨891650509, 27, 6, 3⟩, ⟨815123645, 29, 6, 3⟩,
  ⟨836418102, 41, 6, 3⟩, ⟨904391599, 10, 6, 3⟩, ⟨686516769, 19, 6, 1⟩,
  ⟨743433482, 35, 6, 1⟩, ⟨794463054, 8, 6, 1⟩, ⟨733464432, 2, 6, 1⟩,
  ⟨733624880, 24, 6, 3⟩, ⟨702374535, 34, 6, 1⟩, ⟨953127165, 73, 6, 3⟩,
  ⟨650692850, 24, 6, 1⟩, ⟨985697986, 16, 6, 3⟩, ⟨902063164, 33, 6, 3⟩,
  ⟨896967587, 28, 6, 3⟩, ⟨1057023017, 29, 6, 1⟩, ⟨713417493, 18, 6, 3⟩,
  ⟨1006347453, 67, 6, 3⟩, ⟨695150591, 31, 6, 3⟩, ⟨675374334, 28, 6, 3⟩,
  ⟨683455054, 33, 6, 1⟩, ⟨832471920, 33, 6, 1⟩, ⟨871065647, 17, 6, 3⟩,
  ⟨773488571, 33, 6, 1⟩, ⟨541373103, 14, 6, 3⟩, ⟨746202847, 48, 6, 3⟩,
  ⟨864686845, 47, 6, 3⟩, ⟨999813040, 4, 6, 1⟩, ⟨993653359, 5, 6, 3⟩,
  ⟨827937904, 13, 6, 1⟩, ⟨1050750064, 13, 6, 1⟩, ⟨790692680, 26, 6, 3⟩,
  ⟨553307264, 23, 6, 1⟩, ⟨985413526, 20, 6, 1⟩, ⟨1002965596, 15, 6, 3⟩,
  ⟨777212110, 8, 6, 1⟩, ⟨876797993, 21, 6, 1⟩, ⟨852653743, 17, 6, 3⟩,
  ⟨716672183, 49, 6, 1⟩, ⟨882665144, 52, 6, 3⟩, ⟨600973308, 31, 6, 3⟩,
  ⟨818665016, 63, 6, 3⟩, ⟨828677767, 15, 6, 1⟩, ⟨565767460, 20, 6, 1⟩,
  ⟨723760365, 20, 6, 1⟩, ⟨878250864, 3, 6, 1⟩]

def lock7Entries : List SevenEntry := [
  ⟨610890985, 967, 4⟩, ⟨944691036, 423, 4⟩, ⟨751758925, 557, 3⟩,
  ⟨737010498, 443, 4⟩, ⟨1025683196, 617, 3⟩]

private theorem ether_checked : etherEntries.all etherOK = true := by decide +kernel
private theorem seven_checked : lock7Entries.all sevenOK = true := by decide +kernel

/-- Every listed seed fulfils the periodic branch of the kit's RD, at every future horizon. -/
theorem periodic_for_all_outstanding (seed : Nat)
    (member : seed ∈ etherEntries.map EtherEntry.seed ++ lock7Entries.map SevenEntry.seed) :
    EventuallyPeriodic (u (rh seed)) := by
  rcases List.mem_append.mp member with a | b
  · obtain ⟨e, he, rfl⟩ := List.mem_map.mp a
    exact ether_sound (List.all_eq_true.mp ether_checked e he)
  · obtain ⟨e, he, rfl⟩ := List.mem_map.mp b
    exact seven_sound (List.all_eq_true.mp seven_checked e he)

theorem sample_sizes : etherEntries.length = 53 ∧ lock7Entries.length = 5 := by decide

end Ruliology.CellularAutomata.K50Sample
