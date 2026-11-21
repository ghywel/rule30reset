module
public import Ruliology.CellularAutomata.Rule30SourceArrivals

/-! Lowry's source-arrival channel (kit PR 374) is the observation. Jen's
adjacent-column theorem closes the argument once finite memory reconstructs
the right column. The temporal schedule below is a hypothesis on the
singleton, and imposes no conditions on its unobserved spatial cells. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30ArrivalMemory

open Rule30Jen Rule30SourceArrivals

abbrev center (t : Nat) := cell t 0
abbrev right (t : Nat) := cell t 1

/-- A length-n equality of two blocks, with their starts included. -/
def Match (f : Nat → Bool) (a b n : Nat) : Prop :=
  ∀ k, k < n → f (a+k) = f (b+k)

/-- The previous h right bits, h+1 observations and h+2 driver bits determine
one further right bit at any allowed time. -/
def MemoryLaw (h : Nat) (allow : Nat → Prop) (obs : Nat → Bool) : Prop :=
  ∀ a b, allow a → Match center a b (h+2) → Match obs a b (h+1) →
    Match right a b h → right (a+h) = right (b+h)

/-- The finite version can be applied to one common observation block,
without any hypothesis that the singleton center is periodic. -/
theorem recover_block {h a b n : Nat} {allow : Nat → Prop} {obs : Nat → Bool}
    (law : MemoryLaw h allow obs) (ok : ∀ s, s+h<n → allow (a+s))
    (cc : Match center a b (n+1)) (zz : Match obs a b n)
    (seed : Match right a b h) : Match right a b n := by
  intro k hk
  induction k using Nat.strongRecOn with
  | ind k ih =>
    by_cases small : k<h
    · exact seed k small
    · let s := k-h
      have eq : s+h=k := by dsimp [s]; omega
      have forward := law (a+s) (b+s) (ok s (by omega))
        (fun j hj => by simpa only [Nat.add_assoc] using cc (s+j) (by omega))
        (fun j hj => by simpa only [Nat.add_assoc] using zz (s+j) (by omega))
        (fun j hj => by simpa only [Nat.add_assoc] using ih (s+j) (by omega) (by omega))
      simpa only [Nat.add_assoc,eq] using forward

/-- For every finite memory law, a periodic singleton center satisfying its
schedule forces this observed channel to be aperiodic. -/
theorem obs_aperiodic_of_memory {h : Nat} {allow : Nat → Prop} {obs : Nat → Bool}
    (law : MemoryLaw h allow obs)
    (tail : ∃ W, ∀ t, W≤t → allow t) (hc : EventuallyPeriodic center) :
    ¬ EventuallyPeriodic obs := by
  intro hz
  obtain ⟨W,hw⟩ := tail
  obtain ⟨T,p,hp,pc,pz⟩ := common_period hc hz
  let start (i : Nat) := max T W + i*p
  let block (i : Nat) := (List.range h).map fun k => right (start i+k)
  obtain ⟨i,j,lt,_,seeds⟩ := pigeonhole h block (fun i => by simp [block])
  have sh : start j=start i+(j-i)*p := by
    dsimp [start]; rw [Nat.sub_mul]; have := Nat.mul_le_mul_right p (Nat.le_of_lt lt); omega
  have base : T ≤ start i := by dsimp [start]; omega
  have late : W ≤ start i := by dsimp [start]; omega
  have atShift (f : Nat → Bool) (per : ∀ t, T≤t → f (t+p)=f t) (k : Nat) :
      f (start i+k)=f (start j+k) := by
    rw [sh, show start i+(j-i)*p+k=start i+k+(j-i)*p by omega]
    exact (periodic_mul per (j-i) _ (by omega)).symm
  have seed : Match right (start i) (start j) h := by
    intro k hk
    have e := congrArg (fun xs : List Bool => xs[k]?) seeds
    simpa [block,List.getElem?_map,List.getElem?_range,hk] using e
  apply not_adjacent 0 hc
  refine ⟨start i,(j-i)*p,Nat.mul_pos (by omega) hp,fun t ht => ?_⟩
  have matchAt := recover_block (n:=t-start i+1) law
    (fun s _ => hw _ (by omega)) (fun k _ => atShift center pc k)
    (fun k _ => atShift obs pz k) seed (t-start i) (by omega)
  rw [sh] at matchAt
  rw [show start i + (t-start i) = t by omega, show start i+(j-i)*p+(t-start i) = t+(j-i)*p by omega] at matchAt
  exact matchAt.symm

end Ruliology.CellularAutomata.Rule30ArrivalMemory
