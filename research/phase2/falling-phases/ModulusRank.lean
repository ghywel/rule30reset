import ModulusStrip

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

/-- A rank identifies an adjacent pair and its reading at each tick of a period. -/
structure Certificate where
  labels : List Nat
  ranks : Array Nat
  reads : Array Nat

def label (c : Certificate) (j : Nat) : Nat := c.labels.getD j 0

def rankAt (packed s : Nat) : Nat := (packed >>> (12*s)) % 4096

def readPair (g : Nat) : Nat := g % 8

def prediction (g p : Nat) : Nat := (g >>> (3+2*p)) % 4

def layer (w a p here next : Nat) (reads : Array Nat) : Bool :=
  (List.range (2^w)).all fun s =>
    let rk := rankAt here s
    let word := reads.getD rk 0
    let j := readPair word
    (j+1 < w && (s >>> j)%4 == prediction word p) &&
      (successors w s).all fun d => !(fits a s d) || rankAt next d ≤ rk

def check (w m : Nat) (c : Certificate) : Bool :=
  (List.range m).all fun p => layer w (permit w (label c) p) p
    (c.ranks.getD p 0) (c.ranks.getD ((p+1)%m) 0) c.reads

private theorem node {w m : Nat} {c : Certificate} (ok : check w m c = true)
    {p s : Nat} (hp : p < m) (hs : s < 2^w) :
    let rk := rankAt (c.ranks.getD p 0) s
    let word := c.reads.getD rk 0
    let j := readPair word
    (j+1 < w ∧ (s >>> j)%4 = prediction word p) ∧
      ∀ d, Edge w (permit w (label c) p) s d →
        rankAt (c.ranks.getD ((p+1)%m) 0) d ≤ rk := by
  have yes := List.all_eq_true.mp (List.all_eq_true.mp ok p (List.mem_range.mpr hp))
    s (List.mem_range.mpr hs)
  simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at yes
  refine ⟨yes.1,fun d hd => ?_⟩
  have h := List.all_eq_true.mp yes.2 d hd.1
  simpa [hd.2] using h

theorem good_of_check {w m : Nat} {c : Certificate} (hm : 0 < m) (ok : check w m c = true) :
    Good w m (label c) := by
  intro x hx
  let rk (t : Nat) := rankAt (c.ranks.getD (t%m) 0) (x t)
  let g (t : Nat) := c.reads.getD (rk t) 0
  have reads (t : Nat) : (readPair (g t))+1 < w ∧
      (x t >>> readPair (g t))%4 = prediction (g t) (t%m) :=
    (node ok (Nat.mod_lt _ hm) (hx.bounded t)).1
  have noninc (t : Nat) : rk (t+1) ≤ rk t := by
    have he : (t%m+1)%m=(t+1)%m := by
      calc (t%m+1)%m = (t%m+1%m)%m := by rw [Nat.add_mod (t%m) 1 m, Nat.mod_mod]
        _ = (t+1)%m := (Nat.add_mod t 1 m).symm
    simpa only [rk,he] using
      (node ok (Nat.mod_lt _ hm) (hx.bounded t)).2 _ (hx.edge t)
  obtain ⟨N,_,stable⟩ := antitone_eventually_const rk 0 (fun t _ => noninc t)
  refine ⟨readPair (g N),N,(reads N).1,fun t ht => ?_⟩
  have eq (u : Nat) (hu : N ≤ u) : g u = g N := congrArg (fun k => c.reads.getD k 0) (stable u hu)
  have a := (reads t).2
  have b := (reads (t+m)).2
  rw [eq t ht] at a
  rw [eq (t+m) (by omega), Nat.add_mod_right] at b
  exact b.trans a.symm

end PhaseFalls.Moduli
