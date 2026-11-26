---
Template: ComputationalEssay
Name: Inverse ticks beside every wall: one depth-two age decides both starts for every k, and ages for every k force unique recurrent parents
Author: Gareth Herbert; Claude (Anthropic); GPT (OpenAI)
Date: 2026-11-26
Description: Core Lean. Beside an arbitrary prescribed wall of Rule 30's left half, for every number k of inverse ticks, depth-two exactness at age T ≥ 2 decides the two uniform cutoffs T and T + 1. If every k has such an age, every recurrent row with a leftmost black cell has at most one full-line predecessor.
Abstract: For this Problem 1 partial result, prescribe any wall column for Rule 30's left half and let each inverse layer choose its own wall bit. For every inverse depth k and every age T ≥ 2, two uniform cutoffs are each equivalent to exactness for depth-two starts at age T: age T for all starts at least two sites from the wall and age T + 1 for adjacent starts (`Rule30Submission.two_classes`). Exactness places the k-th predecessor's left edge k cells inside the image edge. If every k has such an age, every row with a leftmost black cell whose finite edge bands all lie on cycles has at most one full-line Rule 30 predecessor (`Rule30Submission.unique_parent_of_every_k`). The catalogue proves the ages 8 and 24, or 9 and 25 next to the wall, case by case (`Rule30DrivenLeftInverse`). It gives ages for every k beside a white wall conditional on reset capacity (`Rule30EveryKInverse`). The first proof uses any column as the wall for the cells west of it. The second extends a parent by left permutivity to give its edge bands long autonomous histories. These bands lie on cycles, where their images determine them. Exhaustive computation gives the depth-two ages 8, 24, 31, 72, 81, 108, 131 and 132 for one to eight ticks. The ages beyond three are computational here. Existence of ages for every k and reset capacity remain open.
Keywords: [rule 30, Rule 30 Prize, inverse ticks, predecessors, driven left half, prescribed wall, left permutivity, exact edge, reset capacity, recurrent rows, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)", "[Hughes's inverse ticks beside every wall: ages 8 and 24, or 9 and 25 next to the wall, all sharp](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-2e7cd2)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

The kit's driven half `Rule30DrivenLeft.L wall s` runs Rule 30 on the negative sites, with an arbitrary prescribed column `wall` at site 0 and a start `s`. A start at depth `m` has its leftmost black cell at `−m`. Go back `k` inverse ticks from the row at age `t`. Each predecessor satisfies the Rule 30 equation at every negative site and chooses its own bit at site 0. `ExactAt k m t` says that, under every wall, every such `k`-th predecessor has its leftmost black cell at `−m − t + k`, the edge of the row `k` ticks earlier.

**The theorems**, in `Rule30Submission`:
- `two_classes`: for every `k` and every `T ≥ 2`, two uniform statements are each equivalent to `ExactAt k 2 T`, depth two at the single age `T`:
  - every start at depth at least two is exact at every age from `T`;
  - the adjacent start, at depth one, is exact at every age from `T + 1`.

  Exactness is monotone in age within each class. The one-tick offset applies to the cutoffs in the stated range. At zero inverse ticks both unrestricted least ages are zero. Its three steps are `L_column`, `exactAt_of_two` and `exactAt_two_of_one`.
- `unique_parent_of_every_k`: suppose every `k` has a depth-two age. Then every recurrent row with a leftmost black cell has at most one full-line Rule 30 predecessor. Here recurrent means that every finite band at its edge lies on a cycle of the band map. The steps are `parent_band_history`, `parent_band_on_cycle`, `realize_recurrent`, `parent_edge_of_one` and `recurrent_parent_of_every_k`.

**By hand, outside Lean.** A full-line predecessor whose edge is at site 1, read from its edge, is an odd preimage of the row read from its edge. For a recurrent row, a unique odd preimage is the same as arbitrarily deep complete resets; that equivalence is argued by hand and read in the rule30reset record. Arbitrarily deep resets at every recurrent row are the kit's `Rule30ResetCompactness.LInfinity`, which gives the reset capacity `CAP` (`cap_of_unbounded_resets`). So a depth-two age for every `k` would give `CAP`. The converse is not shown.

## 2. Where it sits

| | Wall | Inverse ticks | What is proved |
|---|---|---|---|
| `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse` (Scott Hughes, in the kit) | white | 1 and 2 | exact edges from ages 8 and 24 |
| `Rule30DrivenLeftInverse` (R30-20261126-2e7cd2, ours, in the kit) | any | 1 and 2 | ages 8 and 24, and 9 and 25 beside the wall, each case by itself |
| `Rule30EveryKInverse`, `Rule30EveryKLine` (ours, in the kit) | white, or none | every k | an age for every k, from `CAP` |
| this entry | any | every k | the two classes reduce to one statement; ages for every k force unique recurrent parents |

Quint and Gemini prove the white-wall target unconditionally through `k = 25` (R30-20261120-2a993b). Nothing in the kit or on the portal relates the two start classes for any `k` beyond two, or derives uniqueness of parents from uniform ages.

## 3. Exploration

**The least ages, computed.** A start at depth two under every wall reaches few rows: a row is a number whose bit `j` is site `−(j + 1)`, and one tick with wall bit `c` sends `r` to `(r >> 1) XOR (r OR (r << 1) OR c)`. A row passes if, for all `4^k` choices of the predecessors' bits at sites `−1` and `0`, the `k`-th predecessor has the exact edge and white beyond it. The least passing age, for one to three inverse ticks, at depth two and at depth one:

```wl
step[r_, w_] := BitXor[BitShiftRight[r, 1], BitOr[r, BitShiftLeft[r, 1], w]];
passQ[k_, row_, width_] := Module[{img = Reverse[IntegerDigits[row, 2, width]], cur, nxt, new, deep, off},
   If[width < k, Return[False]];
   Catch[Do[
     cur = Table[BitGet[reg, 2 i], {i, 0, k - 1}]; nxt = Table[BitGet[reg, 2 i + 1], {i, 0, k - 1}];
     deep = <|width -> nxt[[k]], (width - 1) -> cur[[k]]|>;
     Do[new = BitXor[Prepend[Most[cur], img[[col + 1]]], BitOr[cur, nxt]]; nxt = cur; cur = new;
      off = width - (col + 2); If[off <= k, deep[off] = cur[[k]]], {col, 0, width - 1}];
     If[! (deep[k] == 1 && AllTrue[Range[0, k - 1], deep[#] == 0 &] && Total[cur] == 0 && Total[nxt] == 0),
      Throw[False]], {reg, 0, 4^k - 1}]; True]];
leastAge[k_, m_] := Module[{rows = Table[BitOr[2^(m - 1), j], {j, 0, 2^(m - 1) - 1}], age = 0},
   While[! AllTrue[rows, passQ[k, #, m + age] &], rows = Union[Flatten[Outer[step, rows, {0, 1}]]]; age++]; age];
Grid[Prepend[Table[{k, leastAge[k, 2], leastAge[k, 1]}, {k, 1, 3}], {"inverse ticks k", "depth two", "adjacent start"}], Frame -> All]
```

The adjacent start is exactly one tick later each time, as `two_classes` says it must be. The first two rows are Hughes's ages, which the kit proves beside any wall case by case.

**Further ages.** The same search at depth two, run by two independent programs in the rule30reset record, gives these least ages. Neither theorem here computes them; they are what the first theorem reduces to.

```wl
Dataset[MapThread[<|"inverse ticks k" -> #1, "least depth-two age" -> #2, "adjacent start" -> #2 + 1|> &, {Range[8], {8, 24, 31, 72, 81, 108, 131, 132}}]]
```

At four ticks, 14 of the 9,662 rows at age 71 fail, and all 10,582 rows at age 72 pass. The failing rows share one 63-cell word at the edge, and at age 72 neither of its two needed extensions is reachable.

## 4. The proof

1. **A column as a wall** (`L_column`). West of any column `j ≤ 0`, the driven half from time `a` on is the half driven by that column, started from the row at time `a`. Since the wall is arbitrary, any column of a driven half is itself a wall.
2. **Depth two decides** (`exactAt_of_two`). A start at depth `m ≥ 1`, aged `t ≥ T` with `m + t ≥ T + 2`, is restarted at time `t − T`. The column two sites east of its leftmost black cell is the new wall, and the row at that time is a depth-two start.
3. **The adjacent start** (`exactAt_two_of_one`). After one tick the depth-one start is the depth-two start with `−1` black. At age two the depth-two start with `−1` white gives the same rows as the one with `−1` black, under a changed second wall bit. So depth two at age `T ≥ 2` is depth one at age `T + 1`.
4. **Finite histories** (`parent_band_history`, `parent_band_on_cycle`). Any predecessor on the negative half has a further predecessor there, solved westward from white bits at `−1` and `0` by left permutivity. If depth two is exact for `n + 1` ticks, the deepest layer is white west of its edge. Its band of width `w` then runs forward `n` steps under the autonomous band map to the first predecessor's band, as long as `w + n ≤ t`. For `n ≥ 2^w` that band lies on a cycle (`on_cycle`, by pigeonhole).
5. **Realization** (`realize_recurrent`). Go `t` steps back along the cycle of a recurrent row's band of width `t + 2`, and start a full-line row with those bits. The column two sites in is a wall, and the driven half at age `t` is the target row, from a depth-two start. The age is chosen after the width, so the room `w + n ≤ t` of step 4 is always there.
6. **Uniqueness** (`parent_edge_of_one`, `recurrent_parent_of_every_k`, `unique_parent_of_every_k`). The one-tick age puts every full-line predecessor's edge at site 1. Step 4 at `k = 2^w + 1` makes every band of every predecessor periodic. Two periodic bands with the same image are equal, and both predecessors are white west of the edge, so they are equal.

## 5. What is not shown

- **That an age exists for every k**, or `CAP`.
- **The converse**, from `CAP` to ages beside every wall. The kit's every-k theorem for the line does not transfer directly, because each inverse layer's bit at site 0 is free.
- **Any least age beyond three ticks in Lean.** The ages in §3 for four to eight ticks are computed. The lower bounds 72 and 73 at four ticks are proved in Lean in the rule30reset record, not here.

## 6. Prior art and credit

- **Scott Hughes**, with OpenAI Codex: the white-wall ages 8 and 24 and their twins (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`, in the kit).
- **Our entries:** R30-20261126-2e7cd2, the same ages beside any wall (`Rule30DrivenLeftInverse`); R30-20261119-ccc65f and R30-20261126-523aad, every `k` from `CAP` beside the white wall and on the line (`Rule30EveryKInverse`, `Rule30EveryKLine`, whose band lemmas are carried here); R30-20261120-eb2bcc, deep resets give `CAP` (`Rule30ResetCompactness`).
- **Troy Lowry**: the reset schedule and cascade behind every `k` (`Rule30EveryKCascade`, kit pull request #60). `K1`, `CAP` and the every-k statement are the kit's (`Rule30EveryKStatement`).
- **G.P.J.W. Quint and Gemini**: the white-wall target through `k = 25` (R30-20261120-2a993b).
- **Authorship.** The two-class theorem is Claude's and the uniqueness theorem GPT's, each read by the other model.
- **Search.** We searched the kit's catalogue at `389bede` and the portal's 452 entries for unique parents and predecessors, columns as walls, depth two and inverse ages. We found the entries above and none with either statement.

## The formal proof

The source imports the kit's `Rule30DrivenLeft`, `Rule30UniversalLeftSide`, `Rule30FiniteConfigs` and `Rule30FiniteDiagonals`, all present at the verifier's kit revision. That revision predates the kit's `Rule30EveryKLine`, so the band lemmas used from it are carried first, unchanged, in their own namespace `Rule30Submission.KitEveryKLine`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

```wl
rule30Submission = LeanImportString[(*Iconize["Lean source"]*)"import Ruliology.CellularAutomata.Rule30DrivenLeft
import Ruliology.CellularAutomata.Rule30UniversalLeftSide
import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Ruliology.CellularAutomata.Rule30FiniteDiagonals

/-!
# Inverse ticks beside every wall, for every number of ticks

The driven half `Rule30DrivenLeft.L wall s` of the kit has its wall at site 0 and an arbitrary wall column.
`ExactAt k m t` says: whatever the wall, every start whose leftmost black cell is at `-m` has, at age `t`,
every `k`-th predecessor exact. Each of `k` successive rows satisfies the Rule 30 equation at every negative
site, with its own bit at site 0 free, and the `k`-th has its leftmost black cell at `-m - t + k`.

* `L_column`: west of any column `j ≤ 0`, the driven half from time `a` on is the half driven by that
  column. Since the wall is arbitrary, any column of a driven half is itself a wall.
* `exactAt_of_two`, `exactAt_two_of_one`, `two_classes`: for every `k` and every `T ≥ 2`, “every start at
  depth at least two passes at every age from `T`” and “the adjacent start passes at every age from `T + 1`”
  are each equivalent to `ExactAt k 2 T`.
* `parent_band_history`, `parent_band_on_cycle`: a one-step parent of the aged row has, at its edge, a band
  with an actual `n`-step history under the autonomous band map when `ExactAt (n + 1) 2 t` holds and the
  cone stays inside the wall; for `n ≥ 2 ^ w` the band is on a cycle.
* `realize_recurrent`: a periodic output band of width `t + 2` is realized at depth two at age `t`.
* `parent_edge_of_one`, `recurrent_parent_of_every_k`, `unique_parent_of_every_k`: if every `k` has a
  depth-two age, every recurrent row with a leftmost black cell has at most one full-line Rule 30 parent.

The verifier's kit revision predates the kit's `Rule30EveryKLine`. The band lemmas used from it are carried
first, in their own namespace.
-/

/-! ## Carried from the kit's `Rule30EveryKLine`

The band of a configuration read from its edge, one step of Rule 30 on the line, the band's update by
`stepK`, and the pigeonhole that puts a band on a cycle by step `2 ^ w`. Copied unchanged from the kit's
`Rule30EveryKLine` (`389bede`), apart from this namespace. -/

namespace Rule30Submission.KitEveryKLine

open Ruliology.CellularAutomata
open Rule30Jen Rule30Realization Rule30FiniteConfigs Rule30UniversalLeftSide

def bandK (c : Int → Bool) (f : Int) : Nat → Nat
  | 0 => 0
  | w + 1 => (if c (f + w) then 2 ^ w else 0) + bandK c f w

theorem bandK_lt (c : Int → Bool) (f : Int) : ∀ w, bandK c f w < 2 ^ w
  | 0 => by simp [bandK]
  | w + 1 => by
    have := bandK_lt c f w
    simp only [bandK, Nat.pow_succ]
    split <;> omega

theorem testBit_bandK (c : Int → Bool) (f : Int) : ∀ (w j : Nat),
    (bandK c f w).testBit j = (decide (j < w) && c (f + j))
  | 0, j => by simp [bandK]
  | w + 1, j => by
    have hlt := bandK_lt c f w
    rcases Nat.lt_trichotomy j w with h | rfl | h
    · have ih := testBit_bandK c f w j
      simp only [bandK]
      split
      · rw [Nat.testBit_two_pow_add_gt h, ih]; simp [h, show j < w + 1 by omega]
      · rw [Nat.zero_add, ih]; simp [h, show j < w + 1 by omega]
    · simp only [bandK]
      split <;> rename_i hc
      · rw [Nat.testBit_two_pow_add_eq, Nat.testBit_lt_two_pow hlt]; simp [hc]
      · rw [Nat.zero_add, Nat.testBit_lt_two_pow hlt]
        simp only [Bool.not_eq_true] at hc; simp [hc]
    · have hb := bandK_lt c f (w + 1)
      rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le hb (Nat.pow_le_pow_right (by decide) h))]
      simp [show ¬ j < w + 1 by omega]

/-- One step of rule 30 on the line. -/
def stepLine (c : Int → Bool) : Int → Bool := fun p => rule (c (p - 1)) (c p) (c (p + 1))

theorem evol_succ (x : Int → Bool) (t : Nat) : evol x (t + 1) = stepLine (evol x t) := rfl

/-- **The band moves out by one and updates by the kit's `stepK`**, for a configuration white left of `f`. -/
theorem bandK_step (c : Int → Bool) (f : Int) (w : Nat) (hw : ∀ p, p < f → c p = false) :
    bandK (stepLine c) (f - 1) w = stepK w (bandK c f w) := by
  apply Nat.eq_of_testBit_eq
  intro j
  rw [testBit_bandK]
  simp only [stepK, Nat.testBit_mod_two_pow, Nat.testBit_xor, Nat.testBit_or, Nat.testBit_shiftLeft,
    testBit_bandK]
  by_cases hj : j < w
  · simp only [hj, decide_true, Bool.true_and, stepLine, rule]
    by_cases h2 : 2 ≤ j
    · have p1 : f - 1 + (j : Int) - 1 = f + ((j - 2 : Nat) : Int) := by omega
      have p2 : f - 1 + (j : Int) = f + ((j - 1 : Nat) : Int) := by omega
      have p3 : f - 1 + (j : Int) + 1 = f + (j : Int) := by omega
      rw [p3, p1, p2]
      simp [show j ≥ 2 by omega, show j ≥ 1 by omega, show j - 2 < w by omega, show j - 1 < w by omega]
    · by_cases h1 : j = 1
      · subst h1
        rw [show f - 1 + ((1 : Nat) : Int) + 1 = f + ((1 : Nat) : Int) by omega,
          show f - 1 + ((1 : Nat) : Int) - 1 = f - 1 by omega, show f - 1 + ((1 : Nat) : Int) = f + ((0 : Nat) : Int) by omega,
          hw (f - 1) (by omega)]
        simp [show (0 : Nat) < w by omega]
      · have h0 : j = 0 := by omega
        subst h0
        rw [show f - 1 + ((0 : Nat) : Int) + 1 = f + ((0 : Nat) : Int) by omega,
          show f - 1 + ((0 : Nat) : Int) - 1 = f - 2 by omega, show f - 1 + ((0 : Nat) : Int) = f - 1 by omega,
          hw (f - 2) (by omega), hw (f - 1) (by omega)]
        simp
  · simp [hj]

section Edge

variable {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)

include hzero in
theorem bandK_evol (w : Nat) : ∀ t : Nat, bandK (evol x t) (lo - t) w = rowAt w (bandK x lo w) t
  | 0 => by simp [evol, rowAt]
  | t + 1 => by
    rw [evol_succ, show lo - ((t + 1 : Nat) : Int) = lo - t - 1 by push_cast; omega,
      bandK_step _ _ _ (fun p hp => evol_eq_false_of_lt hzero t p hp), bandK_evol w t]
    rfl

end Edge

/-- Pigeonhole, as the kit's private `Rule30EveryKInverse.collision`. -/
theorem collision (N : Nat) (a : Nat → Nat) (h : ∀ t, a t < N) :
    ∃ i j, i < j ∧ j ≤ N ∧ a i = a j := by
  apply Classical.byContradiction
  intro hn
  have nd := Rule30Jen.nodup_map_of_inj a (List.nodup_range (n := N+1)) (by
    intro i hi j hj e
    simp only [List.mem_range] at hi hj
    rcases Nat.lt_trichotomy i j with lt | eq | gt
    · exact (hn ⟨i,j,lt,by omega,e⟩).elim
    · exact eq
    · exact (hn ⟨j,i,gt,by omega,e.symm⟩).elim)
  have size := Rule30Jen.length_le_of_subset (l₂ := List.range N) nd (by
    intro x hx
    obtain ⟨t,_,rfl⟩ := List.mem_map.mp hx
    exact List.mem_range.mpr (h t))
  simp at size
  omega

theorem rowAt_add (w v i n : Nat) : rowAt w v (i + n) = rowAt w (rowAt w v i) n := by
  induction n with
  | zero => rfl
  | succ n ih => show stepK w (rowAt w v (i + n)) = stepK w (rowAt w (rowAt w v i) n); rw [ih]

theorem stepK_lt (w v : Nat) : stepK w v < 2 ^ w := Nat.mod_lt _ (Nat.pow_pos (by decide))

theorem rowAt_lt (w v : Nat) (hv : v < 2 ^ w) : ∀ t, rowAt w v t < 2 ^ w
  | 0 => hv
  | _ + 1 => stepK_lt w _

/-- From step `2 ^ w` on, an orbit of `stepK w` is on a cycle. -/
theorem on_cycle (w v : Nat) (hv : v < 2 ^ w) (t : Nat) (ht : 2 ^ w ≤ t) :
    ∃ q, 0 < q ∧ rowAt w (rowAt w v t) q = rowAt w v t := by
  obtain ⟨i, j, hij, hj, e⟩ := collision (2 ^ w) (fun s => rowAt w v s) (rowAt_lt w v hv)
  refine ⟨j - i, by omega, ?_⟩
  rw [← rowAt_add]
  have shift : ∀ n, rowAt w v (i + n) = rowAt w v (j + n) := fun n => by
    rw [rowAt_add, rowAt_add w v j, show rowAt w v i = rowAt w v j from e]
  rw [show t + (j - i) = j + (t - i) by omega, ← shift (t - i), show i + (t - i) = t by omega]

end Rule30Submission.KitEveryKLine

namespace Rule30Submission

open Ruliology.CellularAutomata

/-! ## Depth two decides every start -/

section DepthTwo

open Rule30Jen Rule30DrivenLeft KitEveryKLine

/-- **A column as the wall.** West of column `j ≤ 0`, the driven half from time `a` on is the half
driven by that column, from the row at time `a` read with site `p` at `p + j`. -/
theorem L_column (c : Nat → Bool) (s : Int → Bool) (a : Nat) {j : Int} (hj : j ≤ 0) :
    ∀ (τ : Nat) (p : Int), p ≤ 0 →
      L (fun τ => L c s (a + τ) j) (fun p => L c s a (p + j)) τ p = L c s (a + τ) (p + j) := by
  intro τ
  induction τ with
  | zero =>
    intro p hp
    by_cases h : p < 0
    · rw [L_zero h, Nat.add_zero]
    · rw [show p = 0 by omega, L_col0, Nat.add_zero, Int.zero_add]
  | succ τ ih =>
    intro p hp
    by_cases h : p < 0
    · rw [L_succ h, ih (p - 1) (by omega), ih p (by omega), ih (p + 1) (by omega),
        show a + (τ + 1) = (a + τ) + 1 by omega, L_succ (show p + j < 0 by omega),
        show p - 1 + j = p + j - 1 by omega, show p + 1 + j = p + j + 1 by omega]
    · rw [show p = 0 by omega, L_col0, Int.zero_add]

/-- The driven half sees its start only at negative sites. -/
theorem L_congr_start (c : Nat → Bool) {s s' : Int → Bool} (h : ∀ p, p < 0 → s p = s' p) :
    ∀ (t : Nat) (p : Int), L c s t p = L c s' t p := by
  intro t
  induction t with
  | zero =>
    intro p
    by_cases hp : p < 0
    · rw [L_zero hp, L_zero hp, h p hp]
    · simp [L, hp]
  | succ t ih =>
    intro p
    by_cases hp : p < 0
    · rw [L_succ hp, L_succ hp, ih, ih, ih]
    · simp [L, hp]

/-- The driven half sees its wall only up to the current time. -/
theorem L_congr_wall {c c' : Nat → Bool} (s : Int → Bool) {T : Nat} (h : ∀ τ, τ ≤ T → c τ = c' τ) :
    ∀ (t : Nat), t ≤ T → ∀ p, L c s t p = L c' s t p := by
  intro t
  induction t with
  | zero =>
    intro _ p
    by_cases hp : p < 0
    · rw [L_zero hp, L_zero hp]
    · simp only [L, hp, ↓reduceIte]; exact h 0 (by omega)
  | succ t ih =>
    intro ht p
    by_cases hp : p < 0
    · rw [L_succ hp, L_succ hp, ih (by omega), ih (by omega), ih (by omega)]
    · simp only [L, hp, ↓reduceIte]; exact h (t + 1) ht

/-- Every `k`-th predecessor of the age-`t` row of a start at depth `m` has its leftmost black cell
at `-m - t + k`, whatever the wall. Each predecessor satisfies the Rule 30 equation at every
negative site; its bit at site `0` is free. -/
def ExactAt (k m t : Nat) : Prop :=
  ∀ (wall : Nat → Bool) (s : Int → Bool) (x : Nat → Int → Bool),
    s (-(m : Int)) = true → (∀ p, p < -(m : Int) → s p = false) →
    (∀ p, p < 0 → x 0 p = L wall s t p) →
    (∀ i, i < k → ∀ p, p < 0 → stepLine (x (i + 1)) p = x i p) →
    x k (-(m : Int) - t + k) = true ∧ ∀ p, p < -(m : Int) - t + k → x k p = false

/-- **Depth two at age `T` gives every start from age `T`.** If every start at depth two passes at
age `T`, then every start at depth `m ≥ 1` passes at every age `t ≥ T` with `m + t ≥ T + 2`. -/
theorem exactAt_of_two {k T : Nat} (h : ExactAt k 2 T) {m t : Nat} (hm : 1 ≤ m) (ht : T ≤ t)
    (hmt : T + 2 ≤ m + t) : ExactAt k m t := by
  intro wall s x hs1 hs0 hx0 hx
  obtain ⟨a, rfl⟩ : ∃ a, t = T + a := ⟨t - T, by omega⟩
  have hedge := edge (c := wall) hs0 hs1 (by omega) a
  let j : Int := -((m + a : Nat) : Int) + 2
  have hj : j ≤ 0 := by simp only [j]; omega
  have key := h (fun τ => L wall s (a + τ) j) (fun p => L wall s a (p + j)) (fun i p => x i (p + j))
    (by
      show L wall s a (-((2 : Nat) : Int) + j) = true
      rw [show -((2 : Nat) : Int) + j = -((m + a : Nat) : Int) by simp only [j]; omega]
      exact hedge.2)
    (fun p hp => by
      show L wall s a (p + j) = false
      exact hedge.1 _ (by simp only [j] at *; omega))
    (fun p hp => by
      show x 0 (p + j) = L (fun τ => L wall s (a + τ) j) (fun p => L wall s a (p + j)) T p
      rw [L_column wall s a hj T p (by omega), hx0 (p + j) (by omega), Nat.add_comm a T])
    (fun i hi p hp => by
      show rule (x (i + 1) (p - 1 + j)) (x (i + 1) (p + j)) (x (i + 1) (p + 1 + j)) = x i (p + j)
      rw [← hx i hi (p + j) (by omega)]
      simp only [stepLine]
      rw [show p - 1 + j = p + j - 1 by omega, show p + 1 + j = p + j + 1 by omega])
  obtain ⟨k1, k2⟩ := key
  refine ⟨?_, fun p hp => ?_⟩
  · have e : -((2 : Nat) : Int) - (T : Int) + (k : Int) + j = -(m : Int) - ((T + a : Nat) : Int) + k := by
      simp only [j]; omega
    rw [← e]; exact k1
  · have := k2 (p - j) (by simp only [j] at *; omega)
    simpa [show p - j + j = p by omega] using this

/-- The canonical start at depth two: black at `-2`, `b` at `-1`, white elsewhere at negative sites. -/
def start2 (b : Bool) (p : Int) : Bool := decide (p = -2) || (b && decide (p = -1))

/-- The canonical start at depth one. -/
def start1 (p : Int) : Bool := decide (p = -1)

theorem start2_cells (b : Bool) : start2 b (-2) = true ∧ start2 b (-1) = b ∧
    ∀ p, p < -2 → start2 b p = false := by
  refine ⟨by simp [start2], by cases b <;> simp [start2], fun p hp => ?_⟩
  simp [start2, show p ≠ -2 by omega, show p ≠ -1 by omega]

/-- A start at depth two is, on the negative sites, the canonical one with its own bit at `-1`. -/
theorem start_eq_start2 {s : Int → Bool} (hs1 : s (-2) = true) (hs0 : ∀ p, p < -2 → s p = false) :
    ∀ p, p < 0 → s p = start2 (s (-1)) p := by
  intro p hp
  by_cases h2 : p = -2
  · subst h2; simp [start2, hs1]
  by_cases h1 : p = -1
  · subst h1; cases h : s (-1) <;> simp [start2]
  · rw [hs0 p (by omega)]; simp [start2, h2, h1]

/-- After one tick, the start at depth one is the start at depth two with `-1` black. -/
theorem one_tick_start1 (c : Nat → Bool) : ∀ p, p < 0 → L c start1 1 p = start2 true p := by
  intro p hp
  rw [show (1 : Nat) = 0 + 1 from rfl, L_succ hp]
  by_cases h1 : p = -1
  · subst h1
    rw [L_zero (by omega), L_zero (by omega), show (-1 : Int) + 1 = 0 by rfl, L_col0]
    simp [start1, start2, rule]
  by_cases h2 : p = -2
  · subst h2
    rw [L_zero (by omega), L_zero (by omega), L_zero (by omega)]
    simp [start1, start2, rule]
  · rw [L_zero (by omega), L_zero hp]
    by_cases h3 : p + 1 < 0
    · rw [L_zero h3]
      simp [start1, start2, rule, show p - 1 ≠ -1 by omega, h1, show p + 1 ≠ -1 by omega, h2]
    · omega

/-- At age two, the depth-two start with `-1` white equals the one with `-1` black under a
modified wall: the second wall bit becomes `!c 0 || c 1`. -/
def wallB (c : Nat → Bool) (τ : Nat) : Bool := if τ = 1 then (!c 0 || c 1) else c τ

theorem age_two_start2 (c : Nat → Bool) :
    ∀ p, p < 0 → L c (start2 false) 2 p = L (wallB c) (start2 true) 2 p := by
  have r1 : ∀ (d : Nat → Bool) (b : Bool) (q : Int), q < 0 →
      L d (start2 b) 1 q = rule (start2 b (q - 1)) (start2 b q) (if q + 1 = 0 then d 0 else start2 b (q + 1)) := by
    intro d b q hq
    rw [show (1 : Nat) = 0 + 1 from rfl, L_succ hq, L_zero (by omega), L_zero hq]
    by_cases h : q + 1 = 0
    · simp only [h, ↓reduceIte, L_col0]
    · simp only [h, ↓reduceIte]; rw [L_zero (by omega)]
  have r2 : ∀ (d : Nat → Bool) (b : Bool) (q : Int), q < 0 →
      L d (start2 b) 2 q = rule (L d (start2 b) 1 (q - 1)) (L d (start2 b) 1 q)
        (if q + 1 = 0 then d 1 else L d (start2 b) 1 (q + 1)) := by
    intro d b q hq
    rw [show (2 : Nat) = 1 + 1 from rfl, L_succ hq]
    by_cases h : q + 1 = 0
    · simp only [h, ↓reduceIte, L_col0]
    · simp only [h, ↓reduceIte]
  have w0 : wallB c 0 = c 0 := by simp [wallB]
  have w1 : wallB c 1 = (!c 0 || c 1) := by simp [wallB]
  intro p hp
  rw [r2 c false p hp, r2 (wallB c) true p hp, r1 c false (p - 1) (by omega), r1 c false p hp,
    r1 (wallB c) true (p - 1) (by omega), r1 (wallB c) true p hp, w0]
  by_cases h1 : p = -1
  · subst h1
    simp only [show (-1 : Int) + 1 = 0 by rfl, ↓reduceIte, w1]
    cases c 0 <;> cases c 1 <;> simp [start2, rule]
  · have hp1 : p + 1 < 0 := by omega
    have e : ¬ (p + 1 = 0) := by omega
    simp only [e, ↓reduceIte]
    rw [r1 c false (p + 1) hp1, r1 (wallB c) true (p + 1) hp1, w0]
    by_cases h2 : p = -2
    · subst h2; cases c 0 <;> simp [start2, rule]
    by_cases h3 : p = -3
    · subst h3; simp [start2, rule]
    by_cases h4 : p = -4
    · subst h4; simp [start2, rule]
    · have e1 : ¬ (p - 1 + 1 = 0) := by omega
      have e3 : ¬ (p + 1 + 1 = 0) := by omega
      simp only [e1, e3, ↓reduceIte]
      simp [start2, rule, show p - 1 - 1 ≠ -2 by omega, show p - 1 - 1 ≠ -1 by omega,
        show p - 1 ≠ -2 by omega, show p - 1 ≠ -1 by omega, h2, h1, show p + 1 ≠ -2 by omega,
        show p + 1 ≠ -1 by omega, show p + 1 + 1 ≠ -2 by omega, show p + 1 + 1 ≠ -1 by omega]

/-- The shifted wall of a time shift. -/
theorem L_shift (c : Nat → Bool) (s : Int → Bool) (a t : Nat) :
    ∀ p, p ≤ 0 → L c s (a + t) p = L (fun τ => c (a + τ)) (L c s a) t p :=
  L_add c s a t

/-- **The adjacent start at age `T + 1` covers depth two at age `T ≥ 2`.** -/
theorem exactAt_two_of_one {k T : Nat} (hT : 2 ≤ T) (h : ExactAt k 1 (T + 1)) : ExactAt k 2 T := by
  intro wall s x hs1 hs0 hx0 hx
  have hs := start_eq_start2 hs1 hs0
  -- the depth-two row under `wall`, as the depth-one row under a delayed wall
  let w1 : Nat → Bool := fun τ => if s (-1) then wall τ else wallB wall τ
  let c1 : Nat → Bool := fun τ => if τ = 0 then false else w1 (τ - 1)
  have row : ∀ p, p < 0 → L wall s T p = L c1 start1 (1 + T) p := by
    intro p hp
    rw [L_shift c1 start1 1 T p (by omega)]
    have hc1 : (fun τ => c1 (1 + τ)) = w1 := by
      funext τ; simp only [c1, show 1 + τ ≠ 0 by omega, ↓reduceIte, show 1 + τ - 1 = τ by omega]
    rw [hc1, L_congr_start w1 (one_tick_start1 c1) T p, L_congr_start wall hs T p]
    cases hb : s (-1)
    · -- `-1` white: pass through age two
      have hw : w1 = wallB wall := by funext τ; simp [w1, hb]
      rw [hw]
      obtain ⟨u, rfl⟩ : ∃ u, T = 2 + u := ⟨T - 2, by omega⟩
      rw [L_shift wall _ 2 u p (by omega), L_shift (wallB wall) _ 2 u p (by omega)]
      have hwall : (fun τ => wall (2 + τ)) = (fun τ => wallB wall (2 + τ)) := by
        funext τ; simp [wallB, show 2 + τ ≠ 1 by omega]
      rw [hwall]
      exact L_congr_start _ (age_two_start2 wall) u p
    · have hw : w1 = wall := by funext τ; simp [w1, hb]
      rw [hw]
  have key := h c1 start1 x (by simp [start1]) (fun p hp => by simp [start1, show p ≠ -1 by omega])
    (fun p hp => by rw [hx0 p hp, row p hp, Nat.add_comm]) hx
  obtain ⟨k1, k2⟩ := key
  refine ⟨?_, fun p hp => k2 p (by push_cast at *; omega)⟩
  rw [show -((2 : Nat) : Int) - (T : Int) + (k : Int) = -((1 : Nat) : Int) - ((T + 1 : Nat) : Int) + k by
    push_cast; omega]
  exact k1

/-- **Two classes, one statement.** For every number `k` of inverse ticks and every `T ≥ 2`, each of
“every start at depth at least two passes at every age from `T`” and “the adjacent start passes
at every age from `T + 1`” is equivalent to the single statement at depth two and age `T`. -/
theorem two_classes (k T : Nat) (hT : 2 ≤ T) :
    ((∀ m t, 2 ≤ m → T ≤ t → ExactAt k m t) ↔ ExactAt k 2 T) ∧
    ((∀ t, T + 1 ≤ t → ExactAt k 1 t) ↔ ExactAt k 2 T) :=
  ⟨⟨fun h => h 2 T (Nat.le_refl _) (Nat.le_refl _), fun h m t hm ht => exactAt_of_two h (by omega) ht (by omega)⟩,
   ⟨fun h => exactAt_two_of_one hT (h (T + 1) (Nat.le_refl _)),
    fun h t ht => exactAt_of_two h (Nat.le_refl _) (by omega) (by omega)⟩⟩

end DepthTwo

/-! ## Ages for every k force unique recurrent parents -/

section ParentBand

open Rule30Jen Rule30DrivenLeft KitEveryKLine Rule30UniversalLeftSide

private def backBits (y : Int → Bool) : Nat → Bool
  | 0 => false
  | 1 => false
  | n + 2 => xor (y (-(n : Int) - 1)) (backBits y (n + 1) || backBits y n)

private def back (y : Int → Bool) (p : Int) := backBits y (-p).toNat

private theorem step_back (y : Int → Bool) (p : Int) (hp : p < 0) : stepLine (back y) p = y p := by
  let n := (-p - 1).toNat
  have hn : (n : Int) = -p-1 := by change (((-p-1).toNat : Nat) : Int) = _; omega
  have a : (-(p-1)).toNat = n+2 := by omega
  have b : (-p).toNat = n+1 := by omega
  have c : (-(p+1)).toNat = n := by omega
  simp only [stepLine, back, a, b, c, backBits, show -(n : Int)-1 = p by omega, rule]
  cases y p <;> cases backBits y (n+1) <;> cases backBits y n <;> rfl

private def past (z : Int → Bool) : Nat → Int → Bool
  | 0 => z
  | i+1 => back (past z i)

private theorem cone (z : Int → Bool) (n : Nat) : ∀ j ≤ n, ∀ p : Int, p+j < 0 →
    Rule30Realization.evol (past z n) j p = past z (n-j) p := by
  intro j
  induction j with
  | zero => intro hj p hp; rfl
  | succ j ih =>
    intro hj p hp
    rw [evol_succ]
    unfold stepLine
    rw [ih (by omega) (p-1) (by omega), ih (by omega) p (by omega),
      ih (by omega) (p+1) (by omega), show n-j = (n-(j+1))+1 by omega]
    exact step_back _ p (by omega)

/-- Any one-step parent of the aged row has a band with an actual n-step autonomous history. -/
theorem parent_band_history {n w t : Nat} (h : ExactAt (n+1) 2 t) (room : w+n ≤ t)
    (wall : Nat → Bool) (s z : Int → Bool) (black : s (-2) = true)
    (white : ∀ p, p < -2 → s p = false)
    (parent : ∀ p, p < 0 → stepLine z p = L wall s t p) :
    ∃ v < 2^w, bandK z (-1-(t : Int)) w = rowAt w v n := by
  let chain : Nat → Int → Bool
    | 0 => L wall s t
    | i+1 => past z i
  have steps : ∀ i, i < n+1 → ∀ p, p < 0 → stepLine (chain (i+1)) p = chain i p := by
    intro i _ p hp
    cases i with
    | zero => exact parent p hp
    | succ i => exact step_back _ p hp
  obtain ⟨_, hz⟩ := h wall s chain black (by simpa using white) (fun _ _ => rfl) steps
  let lo : Int := -1-(t : Int)+n
  have outside : ∀ p, p < lo → past z n p = false := by
    intro p hp
    exact hz p (by dsimp [lo] at hp; omega)
  refine ⟨bandK (past z n) lo w, bandK_lt _ _ _, ?_⟩
  rw [← bandK_evol outside w n]
  apply Nat.eq_of_testBit_eq
  intro j
  rw [testBit_bandK, testBit_bandK]
  by_cases hj : j < w
  · simp only [hj, decide_true, Bool.true_and]
    rw [show lo - (n : Int) + j = -1-(t : Int)+j by dsimp [lo]; omega,
      cone z n n (Nat.le_refl _) _ (by omega), Nat.sub_self]
    rfl
  · simp [hj]

/-- If n ≥ 2^w, every one-step parent band in the stated cone already lies on a cycle. -/
theorem parent_band_on_cycle {n w t : Nat} (h : ExactAt (n+1) 2 t) (room : w+n ≤ t)
    (long : 2^w ≤ n) (wall : Nat → Bool) (s z : Int → Bool) (black : s (-2) = true)
    (white : ∀ p, p < -2 → s p = false)
    (parent : ∀ p, p < 0 → stepLine z p = L wall s t p) :
    ∃ q, 0 < q ∧ rowAt w (bandK z (-1-(t : Int)) w) q = bandK z (-1-(t : Int)) w := by
  obtain ⟨v,hv,history⟩ := parent_band_history h room wall s z black white parent
  rw [history]
  exact on_cycle w v hv n long

open Rule30Realization Rule30FiniteConfigs Rule30FiniteDiagonals

/-- Every finite edge band is on a cycle. The periods may depend on the width. -/
def RecurrentAt (y : Int → Bool) (edge : Int) : Prop :=
  ∀ w, ∃ q, 0 < q ∧ rowAt w (bandK y edge w) q = bandK y edge w

private theorem restrict_line (x : Int → Bool) : ∀ (t : Nat) (p : Int), p ≤ 0 →
    L (fun i => evol x i 2) (fun j => x (j+2)) t p = evol x t (p+2) := by
  intro t
  induction t with
  | zero =>
    intro p hp
    by_cases he : p = 0
    · subst p; rw [L_col0]; rfl
    · rw [L_zero (by omega)]; rfl
  | succ t ih =>
    intro p hp
    by_cases he : p = 0
    · subst p; rw [L_col0]; rfl
    · rw [L_succ (by omega), ih (p-1) (by omega), ih p hp, ih (p+1) (by omega), evol_succ]
      unfold stepLine
      rw [show p-1+2 = p+2-1 by omega, show p+1+2 = p+2+1 by omega]

/-- A periodic width-(t+2) band gives a depth-two realization of the whole negative half at age t. -/
theorem realize_recurrent (y : Int → Bool) (black : y 0 = true) (white : ∀ p, p < 0 → y p = false)
    (t : Nat) (per : ∃ q, 0 < q ∧ rowAt (t+2) (bandK y 0 (t+2)) q = bandK y 0 (t+2)) :
    ∃ wall s, s (-2) = true ∧ (∀ p, p < -2 → s p = false) ∧
      ∀ p, p < 0 → L wall s t p = y (p+2+t) := by
  obtain ⟨q,hq,cycle⟩ := per
  let v := bandK y 0 (t+2)
  let a := t*q-t
  let u := rowAt (t+2) v a
  have backTo : rowAt (t+2) u t = v := by
    change rowAt (t+2) (rowAt (t+2) v a) t = v
    rw [← rowAt_add]
    have hmul : t ≤ t*q := Nat.le_mul_of_pos_right t hq
    rw [show a+t = t*q by dsimp [a]; omega]
    simpa [rowAt] using rowAt_add_mul cycle 0 t
  have bit0 : ∀ i, (rowAt (t+2) u i).testBit 0 = u.testBit 0 := by
    intro i; induction i with
    | zero => rfl
    | succ i ih => rw [rowAt, stepK_bit_zero (by omega), ih]
  have ub : u.testBit 0 = true := by
    rw [← bit0 t, backTo]
    change (bandK y 0 (t+2)).testBit 0 = true
    rw [testBit_bandK]
    simp [black]
  refine ⟨fun i => evol (ofRow u) i 2, fun p => ofRow u (p+2), ?_, ?_, ?_⟩
  · simpa [ofRow] using ub
  · intro p hp; exact ofRow_left u (p+2) (by omega)
  · intro p hp
    rw [restrict_line _ _ _ (by omega)]
    by_cases h : p+2+t < 0
    · rw [white _ h]
      exact evol_eq_false_of_lt (ofRow_left u) t _ (by omega)
    · let j := (p+2+t).toNat
      have hj : (j : Int) = p+2+t := by dsimp [j]; omega
      have hj' : j < t+2 := by omega
      have e := Ld_ofRow (K := t+2) (by omega) u t j hj'
      rw [backTo] at e
      simp only [Ld, v, testBit_bandK, hj', decide_true, Bool.true_and, Int.zero_add] at e
      rwa [hj, show 0-(t : Int)+(p+2+t) = p+2 by omega] at e

/-- If every inverse depth has an exact age, every full-line parent of a recurrent black-edged
row has periodic bands at the retreating edge. -/
theorem recurrent_parent_of_every_k (uniform : ∀ k, ∃ T, ExactAt k 2 T)
    (y z : Int → Bool) (black : y 0 = true) (white : ∀ p, p < 0 → y p = false)
    (recur : RecurrentAt y 0) (parent : stepLine z = y) : RecurrentAt z 1 := by
  intro w
  obtain ⟨T,h⟩ := uniform (2^w+1)
  let t := T+w+2^w
  have ht : T ≤ t := Nat.le_trans (Nat.le_add_right T w) (Nat.le_add_right _ _)
  have later : ExactAt (2^w+1) 2 t := exactAt_of_two h (m := 2) (t := t) (by decide) ht (by omega)
  obtain ⟨wall,s,hs,hw,matchRow⟩ := realize_recurrent y black white t (recur (t+2))
  let z' := fun (p : Int) => z (p+2+t)
  have hp : ∀ p, p < 0 → stepLine z' p = L wall s t p := by
    intro p hn
    rw [matchRow p hn, ← parent]
    simp only [stepLine, z', show p-1+2+(t : Int) = p+2+t-1 by omega,
      show p+1+2+(t : Int) = p+2+t+1 by omega]
  have cyc := parent_band_on_cycle later (w := w) (by dsimp [t]; omega)
    (Nat.le_refl _) wall s z' hs hw hp
  have eq : bandK z' (-1-(t : Int)) w = bandK z 1 w := by
    apply Nat.eq_of_testBit_eq
    intro j
    simp only [testBit_bandK, z', show -1-(t : Int)+j+2+t = 1+(j : Int) by omega]
  rwa [eq] at cyc

/-- The one-tick threshold alone forces the true parent edge for any recurrent output. -/
theorem parent_edge_of_one {T : Nat} (h : ExactAt 1 2 T) (y z : Int → Bool)
    (black : y 0 = true) (white : ∀ p, p < 0 → y p = false)
    (recur : RecurrentAt y 0) (parent : stepLine z = y) :
    z 1 = true ∧ ∀ p, p < 1 → z p = false := by
  obtain ⟨wall,s,hs,hw,matchRow⟩ := realize_recurrent y black white T (recur (T+2))
  let chain : Nat → Int → Bool
    | 0 => L wall s T
    | _+1 => fun p => z (p+2+T)
  have steps : ∀ i, i < 1 → ∀ p, p < 0 → stepLine (chain (i+1)) p = chain i p := by
    intro i hi p hp
    obtain rfl : i = 0 := by omega
    change stepLine (fun j => z (j+2+T)) p = L wall s T p
    rw [matchRow p hp, ← parent]
    simp only [stepLine, show p-1+2+(T : Int) = p+2+T-1 by omega,
      show p+1+2+(T : Int) = p+2+T+1 by omega]
  obtain ⟨hit,clear⟩ := h wall s chain hs (by simpa using hw) (fun _ _ => rfl) steps
  constructor
  · change z (-2-(T : Int)+1+2+T) = true at hit
    simpa only [show -2-(T : Int)+1+2+T = 1 by omega] using hit
  · intro p hp
    have e := clear (p-2-T) (by omega)
    change z (p-2-T+2+T) = false at e
    simpa only [show p-2-(T : Int)+2+T = p by omega] using e

private theorem cycle_cancel {w a b : Nat} (pa : ∃ q, 0 < q ∧ rowAt w a q = a)
    (pb : ∃ q, 0 < q ∧ rowAt w b q = b) (eq : stepK w a = stepK w b) : a = b := by
  obtain ⟨p,hp,ap⟩ := pa
  obtain ⟨q,hq,bq⟩ := pb
  have e : rowAt w a (p*q) = rowAt w b (p*q) := by
    have pos := Nat.mul_pos hp hq
    rw [show p*q = 1+(p*q-1) by omega, rowAt_add, rowAt_add w b]
    exact congrArg (fun v => rowAt w v (p*q-1)) eq
  have ea : rowAt w a (p*q) = a := by simpa [Nat.mul_comm, rowAt] using rowAt_add_mul ap 0 q
  have eb : rowAt w b (p*q) = b := by simpa [rowAt] using rowAt_add_mul bq 0 p
  exact ea.symm.trans (e.trans eb)

/-- If every inverse depth has a depth-two threshold, a recurrent black-edged output has
at most one full-line Rule 30 parent. Both candidate parents are arbitrary configurations. -/
theorem unique_parent_of_every_k (uniform : ∀ k, ∃ T, ExactAt k 2 T)
    (y a b : Int → Bool) (black : y 0 = true) (white : ∀ p, p < 0 → y p = false)
    (recur : RecurrentAt y 0) (pa : stepLine a = y) (pb : stepLine b = y) : a = b := by
  obtain ⟨T,h⟩ := uniform 1
  have wa := (parent_edge_of_one h y a black white recur pa).2
  have wb := (parent_edge_of_one h y b black white recur pb).2
  have ra := recurrent_parent_of_every_k uniform y a black white recur pa
  have rb := recurrent_parent_of_every_k uniform y b black white recur pb
  have bands (w : Nat) : bandK a 1 w = bandK b 1 w := by
    apply cycle_cancel (ra w) (rb w)
    rw [← bandK_step a 1 w wa, ← bandK_step b 1 w wb, pa, pb]
  funext p
  by_cases hp : p < 1
  · rw [wa p hp, wb p hp]
  · let j := (p-1).toNat
    have hj : 1+(j : Int) = p := by dsimp [j]; omega
    have e := congrArg (fun v : Nat => v.testBit j) (bands (j+1))
    simpa only [testBit_bandK, Nat.lt_succ_self, decide_true, Bool.true_and, hj] using e

end ParentBand

end Rule30Submission
", "ProjectDir" -> $Rule30PrizeKit]
```

## The formal checks

The ten headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.L_column", "Rule30Submission.exactAt_of_two", "Rule30Submission.exactAt_two_of_one", "Rule30Submission.two_classes", "Rule30Submission.parent_band_history", "Rule30Submission.parent_band_on_cycle", "Rule30Submission.realize_recurrent", "Rule30Submission.parent_edge_of_one", "Rule30Submission.recurrent_parent_of_every_k", "Rule30Submission.unique_parent_of_every_k"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.unique_parent_of_every_k"]["KernelCheck"]
```
