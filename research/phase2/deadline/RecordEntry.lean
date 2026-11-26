import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! A 26-cell prefix forces first spatial trap entry eleven white samples later. -/
namespace RecordEntry

open Ruliology.CellularAutomata
open Rule30Ether (drv drv_col0 rowOf)
open Rule30Jen (rule)
open Rule30PeriodTwoCoupled (altCol)
open Rule30GateTrap (win trap decode win_mem_trap)

private abbrev Prefix := Nat × Nat -- width and site-1-first binary code
private def agrees (r : Nat → Bool) (a : Prefix) :=
  ∀ i : Fin a.1, r (i.val+1) = a.2.testBit i.val

private def readCell (a : Prefix) (wall east : Bool) (p : Nat) :=
  if p = 0 then wall else if p ≤ a.1 then a.2.testBit (p-1) else east

private def checks (wall : Bool) (a b : Prefix) : Bool :=
  decide (b.1 ≤ a.1 ∧ ∀ i : Fin b.1, ∀ east : Bool,
    rule (readCell a wall east i) (readCell a wall east (i+1))
      (readCell a wall east (i+2)) = b.2.testBit i)

private theorem read_eq {r : Nat → Bool} {a : Prefix} (h : agrees r a)
    (p : Nat) (hp : p ≤ a.1+1) :
    readCell a (r 0) (r (a.1+1)) p = r p := by
  unfold readCell
  split
  · rename_i hz; rw [hz]
  · split
    · rename_i hpos
      have e := h ⟨p-1, by omega⟩
      simpa [show p-1+1 = p by omega] using e.symm
    · congr 1; omega

private theorem checked_step {c x : Nat → Bool} {t : Nat} {a b : Prefix}
    (h : agrees (drv c x t) a) (hc : checks (c t) a b = true) :
    agrees (drv c x (t+1)) b := by
  obtain ⟨hlen, hall⟩ := of_decide_eq_true hc
  intro i
  have e := hall i (drv c x t (a.1+1))
  rw [← drv_col0 c x t] at e
  rw [read_eq h _ (by omega), read_eq h _ (by omega), read_eq h _ (by omega)] at e
  exact e

private def snapshots : List Prefix := [
  (26, 2549074), (25, 8011103), (24, 9127232), (24, 14249312),
  (24, 5186865), (23, 7470555), (23, 1705032), (22, 2821884),
  (22, 2724359), (22, 3079945), (22, 2228638), (22, 3605219),
  (22, 1148468), (21, 1755990), (21, 686418), (20, 757599),
  (20, 577856), (20, 875360), (20, 346417), (19, 360411),
  (19, 327752), (19, 360700), (19, 311559)]

private def snap (i : Nat) := snapshots.getD i (0, 0)
private theorem transitions : ∀ i : Fin 22,
    checks (i.val % 2 == 1) (snap i) (snap (i+1 : Nat)) = true := by decide +kernel

private theorem follow (R : Nat → Bool) (s : Nat)
    (h : agrees (drv altCol R (2*s+1)) (snap 0)) :
    ∀ n, n ≤ 22 → agrees (drv altCol R (2*s+1+n)) (snap n)
  | 0, _ => h
  | n+1, hn => by
    apply checked_step (follow R s h n (by omega))
    have e : altCol (2*s+1+n) = (n % 2 == 1) := by
      unfold altCol; apply Bool.eq_iff_iff.mpr; simp; omega
    rw [e]
    exact transitions ⟨n, by omega⟩

private theorem window {R : Nat → Bool} {t v : Nat} {a : Prefix}
    (h : agrees (drv altCol R t) a) (hs : 16 ≤ a.1)
    (same : ∀ i : Fin 16, a.2.testBit i = v.testBit i) : win R t = decode v := by
  apply Rule30SidewaysLocks.seg_congr
  intro i hi
  simpa only [Nat.zero_add] using (h ⟨i, by omega⟩).trans (same ⟨i, hi⟩)

/-- At any white sample with this 26-site prefix, the first trap sample of the
whole history is s+11. The hypothesis ranges over every eastern completion. -/
theorem first_entry (R : Nat → Bool) (s : Nat)
    (h : ∀ i : Fin 26, drv altCol R (2*s+1) (i.val+1) = (2549074 : Nat).testBit i) :
    (∀ j, j < s+11 → win R (2*j+1) ∉ trap) ∧
    win R (2*(s+11)+1) = decode 49415 ∧ win R (2*(s+11)+1) ∈ trap := by
  have prev := window (v := 72) (follow R s h 20 (by decide)) (by decide) (by decide)
  have last := window (v := 49415) (follow R s h 22 (by decide)) (by decide) (by decide)
  rw [show 2*s+1+22 = 2*(s+11)+1 by omega] at last
  refine ⟨?_, last, last.symm ▸ (by decide +kernel : decode 49415 ∈ trap)⟩
  intro j hj earlier
  have later := win_mem_trap R (by omega) earlier (s+10-j)
  rw [show 2*j+1+2*(s+10-j) = 2*s+1+20 by omega, prev] at later
  exact (by decide +kernel : decode 72 ∉ trap) later

#print axioms first_entry

end RecordEntry
