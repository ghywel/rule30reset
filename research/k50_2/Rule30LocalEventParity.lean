import Rule30EventGate

/-! Lowry's first-return parity certificate applied to an arbitrary rule-30 right half.
The seven phase masks are the permitted seven-column words in the kit's
Rule30EventReturns.allowed, encoded with bit x for word x. -/
namespace Ruliology.CellularAutomata.Rule30LocalEventParity

open Rule30Jen Rule30Ether Rule30EventGate

private def pack (a b c d e f g : Bool) : Fin 128 :=
  ⟨(a.toNat+2*b.toNat+4*c.toNat+8*d.toNat+16*e.toNat+32*f.toNat+64*g.toNat)%128, by omega⟩

private def tick (l : Bool) (x : Fin 128) (r : Bool) : Fin 128 :=
  let b := x.val.testBit
  pack (rule l (b 0) (b 1)) (rule (b 0) (b 1) (b 2)) (rule (b 1) (b 2) (b 3))
    (rule (b 2) (b 3) (b 4)) (rule (b 3) (b 4) (b 5)) (rule (b 4) (b 5) (b 6))
    (rule (b 5) (b 6) r)

private def strip (F : Nat → Nat → Bool) (t : Nat) :=
  pack (F t 1) (F t 2) (F t 3) (F t 4) (F t 5) (F t 6) (F t 7)

private theorem step {F : Nat → Nat → Bool} (hF : IsR30 F) (t : Nat) :
    strip F (t+1)=tick (F t 0) (strip F t) (F t 8) := by
  unfold strip
  rw [hF t 0, hF t 1, hF t 2, hF t 3, hF t 4, hF t 5, hF t 6]
  exact (by decide +kernel : ∀ l a b c d e f g r : Bool,
    pack (rule l a b) (rule a b c) (rule b c d) (rule c d e) (rule d e f) (rule e f g) (rule f g r) =
      tick l (pack a b c d e f g) r) _ _ _ _ _ _ _ _ _

private def hit (x : Fin 128) := decide (x.val%4=2)

private theorem hit_spec (F : Nat → Nat → Bool) (t : Nat) : hit (strip F t)=true ↔ Hit F t :=
  (by decide +kernel : ∀ a b c d e f g : Bool,
    hit (pack a b c d e f g)=true ↔ a=false ∧ b=true) _ _ _ _ _ _ _

private def stage (k : Nat) : Fin 7 :=
  ⟨if k<5 then k else 5+(k+1)%2, by split <;> omega⟩
private def next (s : Fin 7) : Fin 7 := ⟨if s.val=6 then 5 else s.val+1, by split <;> omega⟩
private theorem advance (k : Nat) : next (stage k)=stage (k+1) := by
  apply Fin.ext
  simp only [next, stage]
  split <;> split <;> split <;> omega

private def allowed (s : Fin 7) (x : Fin 128) :=
  match s.val with
  | 0 => hit x
  | 1 => (22679974312630952605558467726099415313 : Nat).testBit x.val
  | 2 => (664624298327450829173898273305403522 : Nat).testBit x.val
  | 3 => (88290680854566451623429394188468240 : Nat).testBit x.val
  | 4 => (659178931088698931504157277814912 : Nat).testBit x.val
  | 5 => (21272840308645351309506702563260497920 : Nat).testBit x.val
  | _ => (649037726286873096291633896357888 : Nat).testBit x.val

private theorem certificate : ∀ s : Fin 7, ∀ x : Fin 128, ∀ a b : Bool, allowed s x=true →
    let y := tick true (tick false x a) b
    (hit y=false → allowed (next s) y=true) ∧ (hit y=true → s.val≠0 ∧ s.val≠6) := by decide +kernel

/-- If the two right sites first return to 01 after n double steps over which the
driver alternates, n is even or is 3 or 5. No condition on the initial or exterior cells. -/
theorem hit_return_parity {F : Nat → Nat → Bool} (hF : IsR30 F) (t n : Nat) (pos : 0<n)
    (white : ∀ k, k<n → F (t+2*k) 0=false) (black : ∀ k, k<n → F (t+2*k+1) 0=true)
    (first : Hit F t) (last : Hit F (t+2*n)) (quiet : ∀ k, 0<k → k<n → ¬ Hit F (t+2*k)) :
    n%2=0 ∨ n=3 ∨ n=5 := by
  have link (k : Nat) (hk : k<n) : strip F (t+2*(k+1)) =
      tick true (tick false (strip F (t+2*k)) (F (t+2*k) 8)) (F (t+2*k+1) 8) := by
    rw [show t+2*(k+1)=t+2*k+1+1 by omega, step hF, step hF (t+2*k), white k hk, black k hk]
  have keep (k : Nat) (hk : k<n) : allowed (stage k) (strip F (t+2*k))=true := by
    induction k with
    | zero => simpa [stage, allowed] using (hit_spec F t).mpr first
    | succ k ih =>
      have h := (certificate _ _ (F (t+2*k) 8) (F (t+2*k+1) 8) (ih (by omega))).1
      rw [← link k (by omega), advance] at h
      apply h
      cases eq : hit (strip F (t+2*(k+1))) with
      | false => rfl
      | true => exact False.elim (quiet _ (by omega) hk ((hit_spec F _).mp eq))
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : n≠0)
  have h := (certificate _ _ (F (t+2*k) 8) (F (t+2*k+1) 8) (keep k (by omega))).2
  rw [← link k (by omega)] at h
  obtain ⟨h0,h6⟩ := h ((hit_spec F _).mpr last)
  simp only [stage] at h0 h6
  split at h0 <;> split at h6 <;> omega

end Ruliology.CellularAutomata.Rule30LocalEventParity
