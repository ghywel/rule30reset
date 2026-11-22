---
Template: ComputationalEssay
Name: Inverse Ticks without the White Wall: Hughes's Ages on the Line and Every k from Reset Capacity
Author: {AUTHORS}
Date: 2026-11-22
Description: Core Lean. The kit's inverse-tick theorems hold on the whole line, for every configuration with a leftmost black cell: Hughes's ages 8 and 24, with 8 sharp, and every number of ticks from reset capacity. No wall is needed. Reset capacity and the relaxed doubling lemma remain open.
Abstract: In core Lean 4.35.0 we prove the kit's inverse-tick theorems on the whole line, without the white wall. Let `x : Int → Bool` have a leftmost black cell at `lo`, evolved by rule 30 on the whole line. From age 8, every predecessor of `evol x t` has its leftmost black cell at `lo - t + 1` (`Rule30Submission.predecessor_edge_from_age_eight`), and age 7 does not suffice (`Rule30Submission.predecessor_edge_fails_at_age_seven`). From age 24, every two-step predecessor has it at `lo - t + 2` (`Rule30Submission.two_step_predecessor_edge_from_age_twenty_four`). For every k, the kit's reset capacity `CAP` gives an age from which every k-tick predecessor has it at `lo - t + k` (`Rule30Submission.every_k_line_of_cap`), and so does the relaxed doubling lemma (`Rule30Submission.every_k_line_of_dlMinusOne`). The kit proves these statements beside the white wall, for finite rows of the zero-boundary left half (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`, `Rule30EveryKInverse`). On the line the band of cells next to the edge is always full, so the narrow-row cases disappear, and the k-tick schedule needs only a different drive. Nothing is assumed of the predecessors. `CAP` and the relaxed lemma are open, and nothing here concerns the centre column.
Keywords: [rule 30, Rule 30 Prize, inverse ticks, predecessors, every k, leftmost black cell, left-finite configurations, white wall, reset capacity, Hughes's ages, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

**Configurations.** A configuration is `x : Int → Bool`, evolved by rule 30 on the whole line, `Rule30Realization.evol x t`. It has a leftmost black cell at `lo` when `x lo = true` and `x p = false` for every `p < lo`. Every nonzero finite configuration has one, and so does the single black cell. The leftmost black cell moves one place left at each tick (`Rule30FiniteConfigs.evol_left_edge`), so at time `t` it is at `lo - t`.

**Predecessors.** A predecessor of a configuration `y` is any `z : Int → Bool` with `rule (z (p - 1)) (z p) (z (p + 1)) = y p` for every `p`. A `k`-tick predecessor of `y` is any `V` with `evol V k = y`. Nothing else is assumed of them: a predecessor may be infinite in either direction, and may have no leftmost black cell at all.

**The theorems.** Let `x` have a leftmost black cell at `lo`.
- `Rule30Submission.predecessor_edge_from_age_eight`: if `t ≥ 8`, every predecessor `z` of `evol x t` has `z (lo - t + 1) = true` and is white below it.
- `Rule30Submission.predecessor_edge_fails_at_age_seven`: the configuration with black cells at 0 and 3 has, at age 7, a predecessor of its image that has black cells arbitrarily far to the left. So the age 8 cannot be lowered.
- `Rule30Submission.two_step_predecessor_edge_from_age_twenty_four`: if `t ≥ 24`, every two-step predecessor has its leftmost black cell at `lo - t + 2`.
- `Rule30Submission.kTick_edge_line`: if `0 < w` and `k ≤ K1 w`, then for every `t` from `2 ^ w` on, every `k`-tick predecessor of `evol x t` has its leftmost black cell at `lo - t + k`.
- `Rule30Submission.every_k_line_of_cap`: from `CAP`, for every `k` there is an age from which this holds.
- `Rule30Submission.every_k_line_of_dlMinusOne`: the same from the relaxed doubling lemma `DLMinusOne`.

In each case the leftmost black cell of the predecessor is the one of `evol x (t - k)`, the predecessor that the configuration's own history provides.

## 2. Where it sits

| | Beside the white wall (the kit) | On the line (this entry) |
|---|---|---|
| one tick | from age 8, for finite rows (`Rule30AgeEightInverse`); age 7 fails, by a control outside Lean | from age 8; age 7 fails, in Lean |
| two ticks | from age 24 (`Rule30AgeTwentyFourInverse`); age 23 fails, by a control outside Lean | from age 24 |
| every k | from `CAP`, age `w - 1 + 2 ^ w` (`Rule30EveryKInverse`) | from `CAP`, age `2 ^ w` |
| from `LInfinity`, from `DLMinusOne` | our entries R30-20261120-eb2bcc and R30-20261120-8dc0b3 | this entry |

So the chain from the relaxed doubling lemma, through closed runs and reset capacity, to every number of inverse ticks does not need the white wall. It holds for every configuration with a leftmost black cell.

## 3. Exploration

**The band at the edge.** The 8 cells next to the leftmost black cell, read as a binary number with the edge cell first, from twelve random starts at ages 7, 8, 9 and 30:

```wl
SeedRandom[30];
edgeBand[x_List, t_Integer, w_Integer] := FromDigits[CellularAutomaton[30, {x, 0}, t][[-1, 1 ;; w]], 2];
starts = Table[Join[{1}, RandomInteger[1, 39]], {12}];
tab = Table[edgeBand[x, t, 8], {x, starts}, {t, {7, 8, 9, 30}}];
{tab, Union[Flatten[tab[[All, 2 ;;]]]]}
```

From age 8 every band is 200 or 222, and the two alternate. At age 7 one start still shows 223. These are Hughes's two good bands, here on the line: the band moves out by one cell at each tick and updates by itself, whatever lies further in.

**Age 7 is not enough.** The configuration with black cells at 0 and 3, and a predecessor of its image at age 7 that is black on the left, black on the right, and has a word of 19 cells between:

```wl
x = {1, 0, 0, 1};
y7 = CellularAutomaton[30, {x, 0}, 7][[-1]];
yAt[p_Integer] := If[-7 <= p <= 10, y7[[p + 8]], 0];
mid = IntegerDigits[FromDigits["0100010010000011001", 2], 2, 19];
z[p_Integer] := Which[p <= -9, 1, p >= 11, 1, True, mid[[p + 9]]];
step[p_Integer] := BitXor[z[p - 1], BitOr[z[p], z[p + 1]]];
{AllTrue[Range[-60, 60], step[#] == yAt[#] &], Table[z[p], {p, -14, 14}]}
```

One tick of `z` gives the image at age 7 at every position checked, and beyond them both tails are black and map to white. So the image has a predecessor with no leftmost black cell. In Lean, `predecessor_edge_fails_at_age_seven` checks the 21 middle cells by kernel computation and the two tails by the left- and right-edge lemmas.

## 4. The proof

1. **The band updates by itself** (`band_step`). For a configuration white left of `f`, the `w` cells from `f`, one tick later, are the `w` cells from `f - 1`, and they are the kit's band map `Rule30LateTwins.R` of the `w` cells before. So the band at the edge at age `t` is `R` applied `t` times to the band at age 0.
2. **Good bands at ages 8 and 24** (`good8_of_age`, `good20_of_age`). Beside the wall the kit proves that the top 8 and top 20 cells of an aged row are among its good bands (`top8_from_age_eight`, `top20_from_age_twenty_four`). Applied to a single window, whose band is the line's band at age 0, they give the same for the line. Beside the wall, rows narrower than the band need their own finite check. On the line the band is always full, so that case does not arise.
3. **Below a good band, a predecessor resets** (`prun_reset8`, `prun_reset20`, `edge_of_reset`). A predecessor is fixed to the left by its image: `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))`. Run outward over a good band from any two cells, this inverse rule ends in two white cells. The tables, 2 × 4 cases for the 8-band and 6 × 4 for the 20-band, are checked by `decide`. Outward from two white cells over a white image, the predecessor is white, and the image's edge cell makes the next cell black.
4. **Two ticks** (`predecessor_of_good20`). Over a good 20-band the same run also shows that the predecessor's own 8 cells from its edge form a good band, so step 3 applies again.
5. **Every k** (`kTick_edge_line`). In the kit's every-k bit order the line's band evolves by the kit's `stepK` (`bandK_step`). Pigeonhole on its `2 ^ w` values puts it on a cycle by age `2 ^ w` (`on_cycle`), and the kit's `capacity_on_cycle` gives a period whose reset schedule reaches `K1 w`. The kit's cascade (`scheduled_layer`, `earlier_step`) then fixes the edge of every `k`-tick predecessor. The kit's `scheduled_edge` reads its layers as rows of the zero-boundary left half. Here `scheduled_edge_rows` takes any chain of rows each driven by the next. The layers of a predecessor on the line, read in depth from a point right of the band, are such a chain at every depth (`drives_line`).
6. **The chain** (`every_k_line_of_cap`, `every_k_line_of_dlMinusOne`). `CAP` supplies the width. The kit's `cap_of_unbounded_resets` and `lInfinity_of_dlMinusOne` give `CAP` from `LInfinity` and from `DLMinusOne`.

## 5. Prior art and credit

- **Hughes's inverse theorems** are the kit's `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse`, with `Rule30LateTwins`. They are stated for finite rows beside the white wall. Their good bands and tables are reused here unchanged, through their public theorems. The kit's inverse steps, such as `back_zero_from_top8`, are private and work on rows beside the wall, so the inverse run below a good band is restated here for the line. The kit's catalogue records Hughes's sharpness controls beside the wall, a cofinite predecessor at age 7 and a two-step ancestor at age 23. They are not among the kit's Lean theorems. `predecessor_edge_fails_at_age_seven` is a one-tick control on the line, proved in Lean. Quint and Gemini's entry R30-20261111-f8023c sharpens these results, also beside the wall.
- **The reset schedule and its cascade** are Lowry's (kit PR #60), in `Rule30EveryKCascade`. `K1`, `CAP` and the inverse-tick target are in `Rule30EveryKStatement`, and the conditional every-k theorem beside the wall is in `Rule30EveryKInverse` (our entry R30-20261119-ccc65f). `LInfinity ⇒ CAP` and `DLMinusOne ⇒ LInfinity` are our entries R30-20261120-eb2bcc and R30-20261120-8dc0b3.
- **Configurations with a leftmost black cell** are the setting of the kit's `Rule30FiniteConfigs` (Jen; Kopra; Condrey), whose edge lemmas are used here.
- **Search.** We searched the portal's list of 392 entries, the kit's catalogue and its open pull requests for a predecessor or inverse theorem stated for configurations of the line, or without the wall. We found none. Open kit PR #371 makes the every-k statement unconditional for k up to 25, beside the wall.

## 6. What is not proved

- `CAP`, `LInfinity` and `DLMinusOne` are not proved, so the every-k statements are conditional, as before.
- For small k there is a way round them that is not part of this entry. Open kit PR #371 proves `K1 300 = 25`. Applied to `kTick_edge_line`, it gives the line statement for every k ≤ 25 from age `2 ^ 300`, with no hypothesis. Our reader checked this combination in Lean (rule30reset ledger, R74). It waits on that pull request.
- The sharpness is shown for one tick only. Hughes's age-23 control beside the wall is not carried to the line, so whether 24 is sharp on the line is not settled here.
- Nothing here concerns the centre column. Problem 1 and `Q01` are not decided.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary`, `Rule30UniversalLeftSide`, `Rule30AgedLeftDiagonals`, `Rule30LeftUnbounded`, `Rule30FiniteConfigs` and `Rule30Prize`, all present at the verifier's kit revision. Eleven kit modules that the revision lacks are carried, as they stand at kit commit `40017e8`, each in its own namespace inside `Rule30Submission`:
- Hughes's three: `Rule30LateTwins`, `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`;
- the three every-k modules: `Rule30EveryKStatement`, `Rule30EveryKCascade`, `Rule30EveryKInverse`;
- the five behind reset capacity: `Rule30RootedWhiteReturns`, `Rule30ThreePhaseReturn`, `Rule30RecurrentStrip`, `Rule30ResetCompactness`, `Rule30RelaxedWindows`.

Two modules of ours follow: `Rule30TwoSidedInverse` (Hughes's ages on the line) and `Rule30EveryKLine` (every k on the line). The six headlines are in `Rule30Submission`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

```wl
rule30Submission = LeanImportString[(*Iconize["Lean source"]*)"import Ruliology.CellularAutomata.Rule30ZeroBoundary
import Ruliology.CellularAutomata.Rule30UniversalLeftSide
import Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
import Ruliology.CellularAutomata.Rule30LeftUnbounded
import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Ruliology.CellularAutomata.Rule30Prize

/-!
# Inverse ticks without the wall: Hughes's ages 8 and 24, and every k from reset capacity

One file. First eleven kit modules that the verifier's kit revision does not have, as they stand at kit commit
40017e8, with the module-system lines removed and their namespaces moved inside `Rule30Submission`: Hughes's three
(`Rule30LateTwins`, `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), the three every-k modules, and the five
that give reset capacity from closed runs and from the relaxed doubling lemma. Then two modules of ours: Hughes's two
inverse theorems for every configuration of the line with a leftmost black cell, and the every-k chain on the line.
The headlines are in `Rule30Submission` at the end.
-/

/-!
# Rule 30 beside a white wall: every late row has a twin

For every nonzero natural `y` and every `t ≥ 46`, the row `x = iter F (t - 2) y` of the
zero-boundary left half (`Rule30ZeroBoundary.IntegerForm`) has a **twin**: a natural `x' ≠ x` of
the same width, with the same cell at depth `1`, and with `F (F x') = F (F x)` (`late_twin`). If
`y` never reaches an even value under `G` and `t` is even, the twin never does either
(`late_twin_immortal`), and it is none of the rows `iter G j y` (`late_twin_off_orbit`). So one
immortal natural would force immortal naturals beyond its own orbit, at every even tick from `46` on.

**The top of a row is autonomous.** For every row `Y` and every cut `m`,
`F Y >>> (m + 1) = R (Y >>> m)` with `R u = (u >>> 2) ^^^ ((u >>> 1) ||| u)` (`F_shiftRight`,
`iter_F_shiftRight`). Rule 30 reads its left neighbour, so nothing below a cut reaches the cells above
it, and the cut moves out one cell per tick with the row's top.

**The top twenty cells settle.** From any start whose top cell is the twentieth, the top twenty cells
lie on one four-cycle `C20` after `26` ticks (`band_settles`); every row reaches width `20` by tick
`19`, so every row from tick `45` on has its band on `C20` (`band_late`). The kernel checks this in
two stages: all `4096` starts of the top thirteen cells reach the four-cycle `C13` in `14` ticks
(`stage13`), and from `C13` with any seven cells below, the top twenty reach `C20` in `12` more
(`stage20`). Some starts need all `26` ticks.

**Reset words.** The backward transducer `Rule30ZeroBoundary.back` forgets its starting state after
reading `0 1 0` or `0 1111 0` and one further bit (`reset0`, `reset1`): two runs reading the same
inputs from the start of such a word agree from the depth of that bit on (`sync`). In each phase of
`C20` the band carries one word in `F x` and one in `F (F x)`, stacked so that inverting twice with
the depth-`1` cell flipped one tick before gives a finitely supported row (`chains`,
`twin_of_factors`). Its width equals that of `x` because both have the same image two ticks later.

Nothing here bounds a death time or decides `Q01`. The immortal statements are conditional on an
immortal natural.
-/


open Ruliology.CellularAutomata
namespace Rule30Submission.Rule30LateTwins

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm

/-! ### The top of a row is autonomous -/

/-- The cells above a cut, one tick later and one cell further out: rule 30 with nothing above. -/
def R (u : Nat) : Nat := (u >>> 2) ^^^ ((u >>> 1) ||| u)

/-- `t` steps of `R`. -/
def iterR : Nat → Nat → Nat
  | 0, u => u
  | n + 1, u => iterR n (R u)

/-- **The top moves out by one and updates by itself.** For every row `Y` and every cut `m`. -/
theorem F_shiftRight (Y m : Nat) : F Y >>> (m + 1) = R (Y >>> m) := by
  apply Nat.eq_of_testBit_eq
  intro i
  simp only [F, R, Nat.testBit_shiftRight, Nat.testBit_xor, Nat.testBit_or, Nat.testBit_shiftLeft]
  rw [show 1 + (m + 1 + i) = m + (2 + i) by omega, show m + 1 + i - 1 = m + i by omega,
    show decide (m + 1 + i ≥ 1) = true from decide_eq_true (by omega),
    show m + 1 + i = m + (1 + i) by omega, Bool.true_and]

theorem R_shiftRight (u s : Nat) : R u >>> s = R (u >>> s) := by
  apply Nat.eq_of_testBit_eq
  intro i
  simp only [R, Nat.testBit_shiftRight, Nat.testBit_xor, Nat.testBit_or]
  have h1 : 2 + (s + i) = s + (2 + i) := by omega
  have h2 : 1 + (s + i) = s + (1 + i) := by omega
  rw [h1, h2]

theorem iterR_succ' (n u : Nat) : iterR (n + 1) u = R (iterR n u) := by
  induction n generalizing u with
  | zero => rfl
  | succ n ih => rw [iterR, ih (R u), iterR]

theorem iterR_add (a b u : Nat) : iterR (a + b) u = iterR b (iterR a u) := by
  induction a generalizing u with
  | zero => rw [Nat.zero_add]; rfl
  | succ a ih => rw [show a + 1 + b = (a + b) + 1 by omega, iterR, iterR, ih]

theorem iterR_shiftRight (n u s : Nat) : iterR n u >>> s = iterR n (u >>> s) := by
  induction n generalizing u with
  | zero => rfl
  | succ n ih => rw [iterR, iterR, ih, R_shiftRight]

/-- `t` ticks of the wall dynamics, read above a cut that moves out one cell per tick. -/
theorem iter_F_shiftRight (Y m : Nat) : ∀ t, iter F t Y >>> (m + t) = iterR t (Y >>> m)
  | 0 => rfl
  | t + 1 => by
      rw [show m + (t + 1) = (m + t) + 1 by omega, iter, F_shiftRight, iter_F_shiftRight Y m t,
        ← iterR_succ']

theorem R_lt {u n : Nat} (h : u < 2 ^ n) : R u < 2 ^ n := by
  apply Nat.lt_pow_two_of_testBit
  intro i hi
  have hb : ∀ j, n ≤ j → u.testBit j = false := fun j hj =>
    Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le h (Nat.pow_le_pow_right (by omega) hj))
  simp only [R, Nat.testBit_xor, Nat.testBit_or, Nat.testBit_shiftRight]
  rw [hb (2 + i) (by omega), hb (1 + i) (by omega), hb i hi]
  rfl

theorem iterR_lt {u n : Nat} (h : u < 2 ^ n) : ∀ t, iterR t u < 2 ^ n := by
  intro t
  induction t generalizing u with
  | zero => exact h
  | succ t ih => rw [iterR]; exact ih (R_lt h)

/-! ### The top twenty cells settle on one four-cycle within 26 ticks -/

/-- The four-cycle of the top thirteen cells. -/
def inC13 (v : Nat) : Bool := v == 6411 || v == 6428 || v == 7117 || v == 7129

/-- The four-cycle of the top twenty cells. -/
def inC20 (v : Nat) : Bool := v == 820683 || v == 822904 || v == 911005 || v == 912610

/-- Binary-split range check, so that the kernel never recurses deeply. -/
def chk (P : Nat → Bool) (lo : Nat) : Nat → Bool
  | 0 => P lo
  | d + 1 => chk P lo d && chk P (lo + 2 ^ d) d

theorem chk_sound (P : Nat → Bool) : ∀ (d lo : Nat), chk P lo d = true → ∀ i, i < 2 ^ d → P (lo + i) = true
  | 0, lo, h, i, hi => by
      have : i = 0 := by omega
      subst this; simpa [chk] using h
  | d + 1, lo, h, i, hi => by
      simp only [chk, Bool.and_eq_true] at h
      by_cases hl : i < 2 ^ d
      · exact chk_sound P d lo h.1 i hl
      · have := chk_sound P d (lo + 2 ^ d) h.2 (i - 2 ^ d) (by rw [Nat.pow_succ] at hi; omega)
        rwa [show lo + 2 ^ d + (i - 2 ^ d) = lo + i by omega] at this

/-- Stage one, exhaustive: every start of the top thirteen cells is on `C13` after 14 ticks. -/
theorem stage13 : chk (fun u => inC13 (iterR 14 u)) 4096 12 = true := by decide +kernel

/-- Stage two: from `C13` with any seven cells below, the top twenty are on `C20` after 12 ticks. -/
theorem stage20 : (chk (fun b => inC20 (iterR 12 (6411 * 128 + b))) 0 7 &&
    chk (fun b => inC20 (iterR 12 (6428 * 128 + b))) 0 7 &&
    chk (fun b => inC20 (iterR 12 (7117 * 128 + b))) 0 7 &&
    chk (fun b => inC20 (iterR 12 (7129 * 128 + b))) 0 7) = true := by decide +kernel

theorem C20_closed (v : Nat) (h : inC20 v = true) : inC20 (R v) = true := by
  simp only [inC20, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((rfl | rfl) | rfl) | rfl <;> decide

theorem C20_iterR (v : Nat) (h : inC20 v = true) : ∀ t, inC20 (iterR t v) = true := by
  intro t
  induction t generalizing v with
  | zero => exact h
  | succ t ih => rw [iterR]; exact ih _ (C20_closed v h)

theorem C13_cases (v : Nat) (h : inC13 v = true) : v = 6411 ∨ v = 6428 ∨ v = 7117 ∨ v = 7129 := by
  simp only [inC13, Bool.or_eq_true, beq_iff_eq] at h
  omega

/-- **The top twenty cells settle.** From any start whose top cell is cell 20, after at least 26
ticks the top twenty cells lie on the four-cycle `C20`. -/
theorem band_settles {u : Nat} (h1 : 2 ^ 19 ≤ u) (h2 : u < 2 ^ 20) {t : Nat} (ht : 26 ≤ t) :
    inC20 (iterR t u) = true := by
  have hs13 : inC13 (iterR 14 (u >>> 7)) = true := by
    have hlo : 4096 ≤ u >>> 7 := by rw [Nat.shiftRight_eq_div_pow]; omega
    have hhi : u >>> 7 < 4096 + 2 ^ 12 := by rw [Nat.shiftRight_eq_div_pow]; omega
    have := chk_sound _ 12 4096 stage13 (u >>> 7 - 4096) (by omega)
    rwa [show 4096 + (u >>> 7 - 4096) = u >>> 7 by omega] at this
  obtain ⟨v, hv⟩ : ∃ v, v = iterR 14 u := ⟨_, rfl⟩
  have hvlt : v < 2 ^ 20 := hv ▸ iterR_lt h2 14
  have hc : inC13 (v >>> 7) = true := by rw [hv, iterR_shiftRight]; exact hs13
  have hsplit : v = (v >>> 7) * 128 + v % 128 := by
    rw [Nat.shiftRight_eq_div_pow]; omega
  have hb : v % 128 < 2 ^ 7 := Nat.mod_lt _ (by decide)
  have h26 : inC20 (iterR 12 v) = true := by
    have st := stage20
    simp only [Bool.and_eq_true] at st
    obtain ⟨⟨⟨s1, s2⟩, s3⟩, s4⟩ := st
    rw [hsplit]
    rcases C13_cases _ hc with h | h | h | h <;> rw [h]
    · simpa using chk_sound _ 7 0 s1 (v % 128) hb
    · simpa using chk_sound _ 7 0 s2 (v % 128) hb
    · simpa using chk_sound _ 7 0 s3 (v % 128) hb
    · simpa using chk_sound _ 7 0 s4 (v % 128) hb
  have : iterR t u = iterR (t - 26) (iterR 12 v) := by
    rw [hv, ← iterR_add, ← iterR_add]; congr 1; omega
  rw [this]; exact C20_iterR _ h26 _

/-! ### Widths and the band of a row -/

/-- `m` is the top bit of `Y`: the row has width `m + 1`. -/
def Top (Y m : Nat) : Prop := Y.testBit m = true ∧ ∀ i, m < i → Y.testBit i = false

theorem top_log2 {Y : Nat} (h : Y ≠ 0) : Top Y Y.log2 :=
  ⟨Nat.testBit_log2 h, fun i hi => Nat.testBit_lt_two_pow
    (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) hi))⟩

theorem Top_F {Y m : Nat} (h : Top Y m) : Top (F Y) (m + 1) := by
  refine ⟨testBit_F_succ_of_top h.1 h.2, fun i hi => ?_⟩
  obtain ⟨j, rfl⟩ : ∃ j, i = j + 1 := ⟨i - 1, by omega⟩
  rw [testBit_F_succ, h.2 (j + 2) (by omega), h.2 (j + 1) (by omega), h.2 j (by omega)]
  rfl

theorem Top_iter {Y m : Nat} (h : Top Y m) : ∀ t, Top (iter F t Y) (m + t)
  | 0 => h
  | t + 1 => by
      rw [iter, show m + (t + 1) = (m + t) + 1 by omega]
      exact Top_F (Top_iter h t)

theorem Top_unique {Y m m' : Nat} (h : Top Y m) (h' : Top Y m') : m = m' := by
  rcases Nat.lt_trichotomy m m' with hl | he | hg
  · have := h.2 m' hl
    rw [h'.1] at this
    exact absurd this (by decide)
  · exact he
  · have := h'.2 m hg
    rw [h.1] at this
    exact absurd this (by decide)

theorem iter_add (f : Nat → Nat) (a b x : Nat) : iter f (a + b) x = iter f b (iter f a x) := by
  induction b with
  | zero => rfl
  | succ b ih => rw [show a + (b + 1) = (a + b) + 1 by omega, iter, iter, ih]

theorem band_bounds {X m : Nat} (h : Top X m) (hm : 19 ≤ m) :
    2 ^ 19 ≤ X >>> (m - 19) ∧ X >>> (m - 19) < 2 ^ 20 := by
  constructor
  · apply Nat.ge_two_pow_of_testBit
    rw [Nat.testBit_shiftRight, show m - 19 + 19 = m by omega]
    exact h.1
  · apply Nat.lt_pow_two_of_testBit
    intro i hi
    rw [Nat.testBit_shiftRight]
    exact h.2 _ (by omega)

/-- **Every late row's band is on `C20`.** For nonzero `y` and `t ≥ 45`, the top twenty cells of
`iter F t y` lie on the four-cycle. -/
theorem band_late {y : Nat} (hy : y ≠ 0) {t : Nat} (ht : 45 ≤ t) :
    inC20 (iter F t y >>> (y.log2 + t - 19)) = true := by
  have hT := top_log2 hy
  have hT0 := Top_iter hT (19 - y.log2)
  have hb := band_bounds hT0 (by omega)
  have hsplit : iter F t y = iter F (t - (19 - y.log2)) (iter F (19 - y.log2) y) := by
    rw [← iter_add]
    congr 1
    omega
  rw [hsplit, show y.log2 + t - 19 = (y.log2 + (19 - y.log2) - 19) + (t - (19 - y.log2)) by omega,
    iter_F_shiftRight]
  exact band_settles hb.1 hb.2 (by omega)

/-! ### Synchronization of the backward transducer (the reset words of G13) -/

theorem back_succ_succ (b : Bool) (y : Nat → Bool) (n : Nat) :
    back b y (n + 2) = xor (y (n + 1)) (back b y (n + 1) || back b y n) := rfl

/-- Two backward runs that agree at two consecutive depths, with equal inputs from there on, agree
from then on. -/
theorem back_agree_from {b b' : Bool} {y y' : Nat → Bool} {N : Nat}
    (hy : ∀ j, N ≤ j → y j = y' j)
    (h0 : back b y N = back b' y' N) (h1 : back b y (N + 1) = back b' y' (N + 1)) :
    ∀ n, N ≤ n → back b y n = back b' y' n := by
  have key : ∀ d, back b y (N + d) = back b' y' (N + d) ∧
      back b y (N + d + 1) = back b' y' (N + d + 1) := by
    intro d
    induction d with
    | zero => exact ⟨h0, h1⟩
    | succ d ih =>
      refine ⟨by rw [show N + (d + 1) = N + d + 1 by omega]; exact ih.2, ?_⟩
      rw [show N + (d + 1) + 1 = (N + d) + 2 by omega, back_succ_succ, back_succ_succ, ih.1, ih.2,
        hy (N + d + 1) (by omega)]
  intro n hn
  obtain ⟨d, rfl⟩ : ∃ d, n = N + d := ⟨n - N, by omega⟩
  exact (key d).1

/-- The reset word `0 1 0 z` read from input `q + 1` fixes the run from depth `q + 4`. -/
theorem reset0 (c : Bool) (z : Nat → Bool) (q : Nat)
    (g0 : z (q + 1) = false) (g1 : z (q + 2) = true) (g2 : z (q + 3) = false) :
    back c z (q + 4) = true ∧ back c z (q + 5) = !z (q + 4) := by
  have e4 : back c z (q + 4) = true := by
    simp only [back_succ_succ, g0, g1, g2]
    cases back c z (q + 1) <;> cases back c z q <;> rfl
  refine ⟨e4, ?_⟩
  rw [show q + 5 = (q + 3) + 2 by omega, back_succ_succ, show q + 3 + 1 = q + 4 from rfl, e4]
  cases z (q + 4) <;> rfl

/-- The reset word `0 1111 0 z` read from input `q + 1` fixes the run from depth `q + 7`. -/
theorem reset1 (c : Bool) (z : Nat → Bool) (q : Nat)
    (g0 : z (q + 1) = false) (g1 : z (q + 2) = true) (g2 : z (q + 3) = true)
    (g3 : z (q + 4) = true) (g4 : z (q + 5) = true) (g5 : z (q + 6) = false) :
    back c z (q + 7) = true ∧ back c z (q + 8) = !z (q + 7) := by
  have e7 : back c z (q + 7) = true := by
    simp only [back_succ_succ, g0, g1, g2, g3, g4, g5]
    cases back c z (q + 1) <;> cases back c z q <;> rfl
  refine ⟨e7, ?_⟩
  rw [show q + 8 = (q + 6) + 2 by omega, back_succ_succ, show q + 6 + 1 = q + 7 from rfl, e7]
  cases z (q + 7) <;> rfl

/-- The reset words: `0 1 0` (`k = 0`) and `0 1111 0` (`k = 1`), followed by a free bit. -/
def pat : Nat → Nat → Bool
  | 0, j => [false, true, false].getD j false
  | _, j => [false, true, true, true, true, false].getD j false

/-- A reset factor of `X` starting at bit `q`. -/
def Fac (X q k : Nat) : Prop := (k = 0 ∨ k = 1) ∧ ∀ j, j < 3 * k + 3 → X.testBit (q + j) = pat k j

/-- **G13's synchronization.** If two backward runs read inputs that agree from `q + 1` on, and
the second run's input carries a reset factor of `X` starting at bit `q`, the runs agree from depth
`q + 3k + 4`. -/
theorem sync {b b' : Bool} {y y' : Nat → Bool} {X q k : Nat} (hX : ∀ j, y' (j + 1) = X.testBit j)
    (hy : ∀ j, q + 1 ≤ j → y j = y' j) (hf : Fac X q k) :
    ∀ n, q + 3 * k + 4 ≤ n → back b y n = back b' y' n := by
  have v : ∀ j, j < 3 * k + 3 → y (q + j + 1) = pat k j ∧ y' (q + j + 1) = pat k j := by
    intro j hj
    have := hf.2 j hj
    rw [← hX] at this
    exact ⟨by rw [hy _ (by omega)]; exact this, this⟩
  rcases hf.1 with rfl | rfl
  · have g := fun j (hj : j < 3) => v j (by omega)
    have a := reset0 b y q (g 0 (by decide)).1 (g 1 (by decide)).1 (g 2 (by decide)).1
    have a' := reset0 b' y' q (g 0 (by decide)).2 (g 1 (by decide)).2 (g 2 (by decide)).2
    exact back_agree_from (N := q + 4) (fun j hj => hy j (by omega)) (by rw [a.1, a'.1])
      (by rw [a.2, a'.2, hy (q + 4) (by omega)])
  · have g := fun j (hj : j < 6) => v j (by omega)
    have a := reset1 b y q (g 0 (by decide)).1 (g 1 (by decide)).1 (g 2 (by decide)).1
      (g 3 (by decide)).1 (g 4 (by decide)).1 (g 5 (by decide)).1
    have a' := reset1 b' y' q (g 0 (by decide)).2 (g 1 (by decide)).2 (g 2 (by decide)).2
      (g 3 (by decide)).2 (g 4 (by decide)).2 (g 5 (by decide)).2
    exact back_agree_from (N := q + 7) (fun j hj => hy j (by omega)) (by rw [a.1, a'.1])
      (by rw [a.2, a'.2, hy (q + 7) (by omega)])

theorem fac_transfer {X C q i k : Nat} (hb : ∀ j, X.testBit (q + j) = C.testBit (i + j))
    (h : Fac C i k) : Fac X q k :=
  ⟨h.1, fun j hj => by rw [hb]; exact h.2 j hj⟩

/-! ### The twin -/

theorem rowOfNat_ext {A B : Nat} (h : ∀ k, rowOfNat A (k + 1) = rowOfNat B (k + 1)) : A = B :=
  Nat.eq_of_testBit_eq fun i => h i

theorem rowOfNat_eq_back (Y : Nat) : ∀ k, rowOfNat Y k = back (rowOfNat Y 1) (rowOfNat (F Y)) k := by
  intro k
  have := eq_back (L := rowOfNat Y) (y := rowOfNat (F Y)) (fun k _ => zrow_rowOfNat_one Y k) k
  rwa [zrow_zero_self (rfl : rowOfNat Y 0 = false)] at this

theorem rowOfNat_F_of_row {A : Nat} {L : Nat → Bool} (h : ∀ k, rowOfNat A k = L k) :
    ∀ k, rowOfNat (F A) k = zrow L 1 k := by
  intro k
  rw [← zrow_rowOfNat_one]
  have : rowOfNat A = L := funext h
  rw [this]

/-- **The twin from two reset factors.** If `F (F x)` has a reset factor at bit `q2` and `F x` one
at bit `q1`, with `q2 + 3 k2 + 4 ≤ q1 + 1`, then there is a natural `x' ≠ x` with the same bit 0
and `F (F x') = F (F x)`. -/
theorem twin_of_factors {x q1 k1 q2 k2 : Nat} (h2 : Fac (F (F x)) q2 k2) (h1 : Fac (F x) q1 k1)
    (hq : q2 + 3 * k2 + 4 ≤ q1 + 1) :
    ∃ x', x' ≠ x ∧ x'.testBit 0 = x.testBit 0 ∧ F (F x') = F (F x) := by
  have hx1 := rowOfNat_eq_back (F x)
  have hx0 := rowOfNat_eq_back x
  have s1 : ∀ n, q2 + 3 * k2 + 4 ≤ n →
      back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))) n = rowOfNat (F x) n := by
    intro n hn
    rw [hx1 n]
    exact sync (X := F (F x)) (fun _ => rfl) (fun _ _ => rfl) h2 n hn
  have s2 : ∀ n, q1 + 3 * k1 + 4 ≤ n →
      back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x)))) n = rowOfNat x n := by
    intro n hn
    rw [hx0 n]
    exact sync (X := F x) (fun _ => rfl) (fun j hj => s1 j (by omega)) h1 n hn
  let z0 := back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))))
  let N := q1 + 3 * k1 + 4 + x.log2 + 2
  have hW : ∀ k, N < k → z0 k = false := by
    intro k hk
    show back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x)))) k = false
    rw [s2 k (by omega)]
    obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    exact Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) (by omega)))
  have hrow : ∀ k, rowOfNat (natOfRow z0 N) k = z0 k := by
    intro k
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · rfl
    · exact rowOfNat_natOfRow hW k hk
  have hF1 : ∀ k, rowOfNat (F (natOfRow z0 N)) k =
      back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))) k := by
    intro k
    rw [rowOfNat_F_of_row hrow k]
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · rfl
    · exact zrow_back _ _ k hk
  refine ⟨natOfRow z0 N, ?_, ?_, ?_⟩
  · intro he
    have h1 := hF1 1
    rw [he] at h1
    have key : ∀ b : Bool, b ≠ !b := by decide
    exact key _ h1
  · have := hrow 1
    exact this
  · apply rowOfNat_ext
    intro k
    rw [rowOfNat_F_of_row hF1 (k + 1)]
    exact zrow_back _ _ (k + 1) (by omega)

/-! ### Every late row has a twin -/

/-- The chain in each phase of `C20`, as (bit of the factor in `F x`, its word; bit in `F (F x)`,
its word) relative to the band. -/
theorem chains (c : Nat) (hc : inC20 c = true) :
    ∃ i1 k1 i2 k2, Fac c i1 k1 ∧ Fac (R c) i2 k2 ∧ i2 + 3 * k2 + 4 ≤ i1 := by
  simp only [inC20, Bool.or_eq_true, beq_iff_eq] at hc
  rcases hc with ((rfl | rfl) | rfl) | rfl
  · exact ⟨14, 0, 6, 0, ⟨Or.inl rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩
  · exact ⟨14, 0, 0, 0, ⟨Or.inl rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩
  · exact ⟨12, 1, 2, 1, ⟨Or.inr rfl, by decide⟩, ⟨Or.inr rfl, by decide⟩, by decide⟩
  · exact ⟨12, 1, 2, 0, ⟨Or.inr rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩

theorem F_zero : F 0 = 0 := by decide

/-- **Every late row has a twin.** For every nonzero natural `y` and every `t ≥ 46`, the row
`x = iter F (t - 2) y` has a twin `x' ≠ x` of the same width, with the same bit 0 and the same
image two ticks later. -/
theorem late_twin {y : Nat} (hy : y ≠ 0) {t : Nat} (ht : 46 ≤ t) :
    ∃ x', x' ≠ iter F (t - 2) y ∧ x'.testBit 0 = (iter F (t - 2) y).testBit 0 ∧
      F (F x') = iter F t y ∧ Top x' (y.log2 + (t - 2)) := by
  have e1 : iter F (t - 1) y = F (iter F (t - 2) y) := by
    rw [show t - 1 = (t - 2) + 1 by omega]; rfl
  have e2 : iter F t y = F (F (iter F (t - 2) y)) := by
    rw [← e1, show t = (t - 1) + 1 by omega]; rfl
  obtain ⟨c, hc⟩ : ∃ c, iter F (t - 1) y >>> (y.log2 + (t - 1) - 19) = c := ⟨_, rfl⟩
  have hin : inC20 c = true := hc ▸ band_late hy (by omega)
  obtain ⟨i1, k1, i2, k2, f1, f2, hi⟩ := chains c hin
  have b1 : ∀ j, (iter F (t - 1) y).testBit ((y.log2 + (t - 1) - 19) + i1 + j) = c.testBit (i1 + j) := by
    intro j
    rw [← hc, Nat.testBit_shiftRight, Nat.add_assoc]
  have b2 : ∀ j, (F (iter F (t - 1) y)).testBit ((y.log2 + (t - 1) - 19) + 1 + i2 + j) =
      (R c).testBit (i2 + j) := by
    intro j
    rw [← hc, ← F_shiftRight, Nat.testBit_shiftRight, Nat.add_assoc, Nat.add_assoc]
  have g1 := fac_transfer b1 f1
  have g2 := fac_transfer b2 f2
  rw [e1] at g1 g2
  obtain ⟨x', hne, hb0, hF⟩ := twin_of_factors g2 g1 (by omega)
  refine ⟨x', hne, hb0, by rw [hF, e2], ?_⟩
  have hx'0 : x' ≠ 0 := by
    intro h0
    have hT := Top_iter (top_log2 hy) t
    rw [e2, ← hF, h0, F_zero, F_zero] at hT
    exact absurd hT.1 (by rw [Nat.zero_testBit]; decide)
  have hT' := Top_iter (top_log2 hx'0) 2
  have hT2 := Top_iter (top_log2 hy) t
  rw [e2, ← hF] at hT2
  have : x'.log2 + 2 = y.log2 + t := Top_unique hT' hT2
  rw [show y.log2 + (t - 2) = x'.log2 by omega]
  exact top_log2 hx'0

theorem iter_succ' (f : Nat → Nat) (n x : Nat) : iter f (n + 1) x = iter f n (f x) := by
  rw [show n + 1 = 1 + n by omega, iter_add]
  rfl

theorem odd_iff_testBit (x : Nat) : x % 2 = 1 ↔ x.testBit 0 = true := by
  rw [Nat.testBit_zero]
  simp

/-- **Immortality passes to the twin at even ticks.** If `y` never reaches an even value under `G`
and `t ≥ 46` is even, the twin of `iter F (t - 2) y` never does either, and `G x' = iter F t y`. -/
theorem late_twin_immortal {y : Nat} (hy : ∀ s, iter G s y % 2 = 1) {t : Nat} (ht : 46 ≤ t)
    (he : t % 2 = 0) :
    ∃ x', x' ≠ iter F (t - 2) y ∧ (∀ s, iter G s x' % 2 = 1) ∧ G x' = iter F t y ∧
      Top x' (y.log2 + (t - 2)) := by
  have hy0 : y ≠ 0 := by
    intro h
    have := hy 0
    rw [h] at this
    exact absurd this (by decide)
  obtain ⟨x', hne, hb0, hF, hT⟩ := late_twin hy0 ht
  refine ⟨x', hne, ?_, hF, hT⟩
  intro s
  cases s with
  | zero =>
    have h := hy ((t - 2) / 2)
    rw [iter_G_eq_iter_F_two_mul, show 2 * ((t - 2) / 2) = t - 2 by omega] at h
    show x' % 2 = 1
    rw [odd_iff_testBit, hb0, ← odd_iff_testBit]
    exact h
  | succ s =>
    rw [iter_succ']
    have hG : G x' = iter G (t / 2) y := by
      rw [iter_G_eq_iter_F_two_mul, show 2 * (t / 2) = t by omega]
      exact hF
    rw [hG, ← iter_add]
    exact hy _

/-- **The twin is off the orbit.** Under the same hypotheses the twin is none of the rows
`iter G j y`. So one immortal natural forces immortal naturals beyond its own orbit, at every even
tick from 46 on. -/
theorem late_twin_off_orbit {y : Nat} (hy : ∀ s, iter G s y % 2 = 1) {t : Nat} (ht : 46 ≤ t)
    (he : t % 2 = 0) :
    ∃ x', (∀ s, iter G s x' % 2 = 1) ∧ G x' = iter F t y ∧ ∀ j, x' ≠ iter G j y := by
  obtain ⟨x', hne, himm, hG, hT⟩ := late_twin_immortal hy ht he
  refine ⟨x', himm, hG, fun j hj => ?_⟩
  have hy0 : y ≠ 0 := by
    intro h
    have := hy 0
    rw [h] at this
    exact absurd this (by decide)
  have hTj := Top_iter (top_log2 hy0) (2 * j)
  rw [← iter_G_eq_iter_F_two_mul, ← hj] at hTj
  have : y.log2 + (t - 2) = y.log2 + 2 * j := Top_unique hT hTj
  apply hne
  rw [hj, iter_G_eq_iter_F_two_mul, show 2 * j = t - 2 by omega]

/-! ### Exact period-4 laws of `C13` and `C20`, 7-bit projection `C20 → C13`, and bit-1 / tick-1 wall-bit negation for twin pairs -/

/-- **`C13` is closed under `R` (`C13_closed`).** -/
theorem C13_closed (v : Nat) (h : inC13 v = true) : inC13 (R v) = true := by
  simp only [inC13, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((rfl | rfl) | rfl) | rfl <;> decide

/-- **Exact Minimal Period `4` of `C13` Under `R` (`C13_exact_period_four`):**
every `v` with `inC13 v = true` (`6411, 6428, 7117, 7129`) satisfies `R v ≠ v`,
`iterR 2 v ≠ v`, `iterR 3 v ≠ v`, and `iterR 4 v = v`. -/
theorem C13_exact_period_four (v : Nat) (h : inC13 v = true) :
    R v ≠ v ∧ iterR 2 v ≠ v ∧ iterR 3 v ≠ v ∧ iterR 4 v = v := by
  simp only [inC13, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((rfl | rfl) | rfl) | rfl <;> decide

/-- **Exact Minimal Period `4` of `C20` Under `R` (`C20_exact_period_four`):**
every `v` with `inC20 v = true` (`820683, 822904, 911005, 912610`) satisfies `R v ≠ v`,
`iterR 2 v ≠ v`, `iterR 3 v ≠ v`, and `iterR 4 v = v`. -/
theorem C20_exact_period_four (v : Nat) (h : inC20 v = true) :
    R v ≠ v ∧ iterR 2 v ≠ v ∧ iterR 3 v ≠ v ∧ iterR 4 v = v := by
  simp only [inC20, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((rfl | rfl) | rfl) | rfl <;> decide

/-- **Equivariant `7`-Bit Projection From `C20` Onto `C13` (`C20_projects_to_C13`):**
for every `v` with `inC20 v = true`, `inC13 (v >>> 7) = true` and `R v >>> 7 = R (v >>> 7)`. -/
theorem C20_projects_to_C13 (v : Nat) (h : inC20 v = true) :
    inC13 (v >>> 7) = true ∧ R v >>> 7 = R (v >>> 7) := by
  refine ⟨?_, R_shiftRight v 7⟩
  simp only [inC20, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((rfl | rfl) | rfl) | rfl <;> decide

/-- **Exact Wall-Bit Step Formula (`testBit_zero_F`):**
for every `x : Nat`, `(F x).testBit 0 = xor (x.testBit 1) (x.testBit 0)`. -/
theorem testBit_zero_F (x : Nat) :
    (F x).testBit 0 = xor (x.testBit 1) (x.testBit 0) := by
  simp only [F, Nat.testBit_shiftRight, Nat.testBit_xor, Nat.testBit_or, Nat.testBit_shiftLeft]
  simp

/-- **Equivalence of Tick-`1` Wall-Bit Negation and Depth-`2` (`bit 1`) Negation
(`F_testBit_zero_neg_iff_testBit_one_neg`):** for any `x, x' : Nat` with
`x'.testBit 0 = x.testBit 0`, `(F x').testBit 0 = !(F x).testBit 0` holds if and only if
`x'.testBit 1 = !x.testBit 1`. -/
theorem F_testBit_zero_neg_iff_testBit_one_neg {x x' : Nat}
    (hb0 : x'.testBit 0 = x.testBit 0) :
    (F x').testBit 0 = !(F x).testBit 0 ↔ x'.testBit 1 = !x.testBit 1 := by
  rw [testBit_zero_F x', testBit_zero_F x, hb0]
  cases x.testBit 0 <;> cases x.testBit 1 <;> cases x'.testBit 1 <;> decide

/-- **Refined Twin Theorem From Two Reset Factors With Opposite Tick-`1` and Depth-`2` Bits
(`twin_of_factors_with_flips`):** under the hypotheses of `twin_of_factors`, there exists `x' ≠ x`
with `x'.testBit 0 = x.testBit 0`, `x'.testBit 1 = !x.testBit 1`,
`(F x').testBit 0 = !(F x).testBit 0`, and `F (F x') = F (F x)`. -/
theorem twin_of_factors_with_flips {x q1 k1 q2 k2 : Nat}
    (h2 : Fac (F (F x)) q2 k2) (h1 : Fac (F x) q1 k1) (hq : q2 + 3 * k2 + 4 ≤ q1 + 1) :
    ∃ x', x' ≠ x ∧ x'.testBit 0 = x.testBit 0 ∧ x'.testBit 1 = !x.testBit 1 ∧
      (F x').testBit 0 = !(F x).testBit 0 ∧ F (F x') = F (F x) := by
  have hx1 := rowOfNat_eq_back (F x)
  have hx0 := rowOfNat_eq_back x
  have s1 : ∀ n, q2 + 3 * k2 + 4 ≤ n →
      back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))) n = rowOfNat (F x) n := by
    intro n hn
    rw [hx1 n]
    exact sync (X := F (F x)) (fun _ => rfl) (fun _ _ => rfl) h2 n hn
  have s2 : ∀ n, q1 + 3 * k1 + 4 ≤ n →
      back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x)))) n = rowOfNat x n := by
    intro n hn
    rw [hx0 n]
    exact sync (X := F x) (fun _ => rfl) (fun j hj => s1 j (by omega)) h1 n hn
  let z0 := back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))))
  let N := q1 + 3 * k1 + 4 + x.log2 + 2
  have hW : ∀ k, N < k → z0 k = false := by
    intro k hk
    show back (rowOfNat x 1) (back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x)))) k = false
    rw [s2 k (by omega)]
    obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    exact Nat.testBit_lt_two_pow
      (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) (by omega)))
  have hrow : ∀ k, rowOfNat (natOfRow z0 N) k = z0 k := by
    intro k
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · rfl
    · exact rowOfNat_natOfRow hW k hk
  have hF1 : ∀ k, rowOfNat (F (natOfRow z0 N)) k =
      back (!(rowOfNat (F x) 1)) (rowOfNat (F (F x))) k := by
    intro k
    rw [rowOfNat_F_of_row hrow k]
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · rfl
    · exact zrow_back _ _ k hk
  have hb0 : (natOfRow z0 N).testBit 0 = x.testBit 0 := hrow 1
  have hFb0 : (F (natOfRow z0 N)).testBit 0 = !(F x).testBit 0 := hF1 1
  have hb1 : (natOfRow z0 N).testBit 1 = !x.testBit 1 :=
    (F_testBit_zero_neg_iff_testBit_one_neg hb0).1 hFb0
  refine ⟨natOfRow z0 N, ?_, hb0, hb1, hFb0, ?_⟩
  · intro he
    rw [he] at hFb0
    have key : ∀ b : Bool, b ≠ !b := by decide
    exact key _ hFb0
  · apply rowOfNat_ext
    intro k
    rw [rowOfNat_F_of_row hF1 (k + 1)]
    exact zrow_back _ _ (k + 1) (by omega)

end Rule30Submission.Rule30LateTwins

/-! Age-eight top-band reset for the zero-wall left Rule 30 map. -/


namespace Rule30Submission.Rule30AgeEightInverse

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm Rule30LateTwins

def EdgeGood8 (u : Nat) : Bool := u == 200 || u == 222

private theorem good_iff {u : Nat} : EdgeGood8 u = true ↔ u = 200 ∨ u = 222 := by
  simp [EdgeGood8, Bool.or_eq_true, beq_iff_eq]

private theorem top8_base (u : Nat) (hlo : 128 ≤ u) (hhi : u < 256) : EdgeGood8 (iterR 8 u) = true := by
  have hc : chk (fun v => EdgeGood8 (iterR 8 v)) 128 7 = true := by decide +kernel
  have h := chk_sound (fun v => EdgeGood8 (iterR 8 v)) 7 128 hc (u - 128) (by omega)
  simpa only [show 128 + (u - 128) = u by omega] using h

private theorem small8_base (u : Nat) (hu : u ≠ 0) (hhi : u < 128) :
    EdgeGood8 ((iter F 8 u) >>> (u.log2 + 1)) = true := by
  have hc : chk (fun v => v == 0 || EdgeGood8 ((iter F 8 v) >>> (v.log2 + 1))) 0 7 = true := by
    decide +kernel
  have h := chk_sound (fun v => v == 0 || EdgeGood8 ((iter F 8 v) >>> (v.log2 + 1))) 7 0 hc u (by omega)
  simpa [EdgeGood8, hu] using h

private theorem EdgeGood8_R {u : Nat} (h : EdgeGood8 u = true) : EdgeGood8 (R u) = true := by
  rcases good_iff.mp h with rfl | rfl <;> decide

private theorem EdgeGood8_iterR {u : Nat} (h : EdgeGood8 u = true) : ∀ d, EdgeGood8 (iterR d u) = true := by
  intro d
  induction d generalizing u with
  | zero => exact h
  | succ d ih => exact ih (EdgeGood8_R h)

private theorem top8_at_age8 (Y : Nat) (hY : Y ≠ 0) :
    EdgeGood8 ((iter F 8 Y) >>> (Y.log2 + 1)) = true := by
  by_cases hsmall : Y < 128
  · exact small8_base Y hY hsmall
  · have h7 : 7 ≤ Y.log2 := (Nat.le_log2 hY).2 (by omega : 2 ^ 7 ≤ Y)
    let q := Y.log2 - 7
    have hq : Y.log2 = q + 7 := by dsimp [q]; omega
    have hp7 : 2 ^ Y.log2 = 128 * 2 ^ q := by
      rw [hq, Nat.pow_add, show (2 : Nat) ^ 7 = 128 by decide, Nat.mul_comm]
    have hp8 : 2 ^ (Y.log2 + 1) = 256 * 2 ^ q := by
      rw [show Y.log2 + 1 = q + 8 by omega, Nat.pow_add,
        show (2 : Nat) ^ 8 = 256 by decide, Nat.mul_comm]
    have hulo : 128 ≤ Y >>> q := by
      rw [Nat.shiftRight_eq_div_pow, Nat.le_div_iff_mul_le (Nat.pow_pos (by decide))]
      rw [← hp7]
      exact Nat.log2_self_le hY
    have huhi : Y >>> q < 256 := by
      rw [Nat.shiftRight_eq_div_pow, Nat.div_lt_iff_lt_mul (Nat.pow_pos (by decide))]
      rw [← hp8]
      exact Nat.lt_log2_self
    rw [show Y.log2 + 1 = q + 8 by omega, iter_F_shiftRight]
    exact top8_base (Y >>> q) hulo huhi

theorem top8_from_age_eight (Y t : Nat) (hY : Y ≠ 0) (ht : 8 ≤ t) :
    EdgeGood8 ((iter F t Y) >>> (Y.log2 + t - 7)) = true := by
  obtain ⟨d, rfl⟩ : ∃ d, t = 8 + d := ⟨t - 8, by omega⟩
  have htime : Y.log2 + (8 + d) - 7 = (Y.log2 + 1) + d := by omega
  rw [htime, Rule30LateTwins.iter_add F 8 d Y, iter_F_shiftRight]
  exact EdgeGood8_iterR (top8_at_age8 Y hY) d

private theorem image_suffix_bit (Z q i : Nat) :
    rowOfNat Z (q + 1 + i) = (Z >>> q).testBit i := by
  rw [show q + 1 + i = (q + i) + 1 by omega, rowOfNat, Nat.testBit_shiftRight]

theorem back_reset_at_top8 (Z q : Nat) (h : EdgeGood8 (Z >>> q) = true) (b : Bool) :
    back b (rowOfNat Z) (q + 8) = false ∧
    back b (rowOfNat Z) (q + 9) = false := by
  let y := rowOfNat Z
  have hy (i : Nat) : y (q + 1 + i) = (Z >>> q).testBit i := image_suffix_bit Z q i
  rcases good_iff.mp h with hw | hw
  · have h2 : y (q + 3) = false := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 2 = false by decide] using hy 2
    have h3 : y (q + 4) = true := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 3 = true by decide] using hy 3
    have h4 : y (q + 5) = false := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 4 = false by decide] using hy 4
    have h5 : y (q + 6) = false := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 5 = false by decide] using hy 5
    have h6 : y (q + 7) = true := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 6 = true by decide] using hy 6
    have h7 : y (q + 8) = true := by simpa [hw, Nat.add_assoc, show (200 : Nat).testBit 7 = true by decide] using hy 7
    have hr := reset0 b y (q + 2) (by simpa [Nat.add_assoc] using h2)
      (by simpa [Nat.add_assoc] using h3) (by simpa [Nat.add_assoc] using h4)
    have h6b : back b y (q + 6) = true := by simpa [Nat.add_assoc] using hr.1
    have h7b : back b y (q + 7) = true := by simpa [Nat.add_assoc, h5] using hr.2
    have h8b : back b y (q + 8) = false := by
      rw [show q + 8 = (q + 6) + 2 by omega, back_succ_succ]
      simp [show q + 6 + 1 = q + 7 by omega, h6, h6b, h7b]
    have h9b : back b y (q + 9) = false := by
      rw [show q + 9 = (q + 7) + 2 by omega, back_succ_succ]
      simp [show q + 7 + 1 = q + 8 by omega, h7, h7b, h8b]
    exact ⟨h8b, h9b⟩

  · have h0 : y (q + 1) = false := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 0 = false by decide] using hy 0
    have h1 : y (q + 2) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 1 = true by decide] using hy 1
    have h2 : y (q + 3) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 2 = true by decide] using hy 2
    have h3 : y (q + 4) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 3 = true by decide] using hy 3
    have h4 : y (q + 5) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 4 = true by decide] using hy 4
    have h5 : y (q + 6) = false := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 5 = false by decide] using hy 5
    have h6 : y (q + 7) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 6 = true by decide] using hy 6
    have h7 : y (q + 8) = true := by simpa [hw, Nat.add_assoc, show (222 : Nat).testBit 7 = true by decide] using hy 7
    have hr := reset1 b y q (by simpa [Nat.add_assoc] using h0)
      (by simpa [Nat.add_assoc] using h1) (by simpa [Nat.add_assoc] using h2)
      (by simpa [Nat.add_assoc] using h3) (by simpa [Nat.add_assoc] using h4)
      (by simpa [Nat.add_assoc] using h5)
    have h7b : back b y (q + 7) = true := by simpa [Nat.add_assoc] using hr.1
    have h8b : back b y (q + 8) = false := by simpa [Nat.add_assoc, h6] using hr.2
    have h9b : back b y (q + 9) = false := by
      rw [show q + 9 = (q + 7) + 2 by omega, back_succ_succ]
      simp [show q + 7 + 1 = q + 8 by omega, h7, h7b, h8b]
    exact ⟨h8b, h9b⟩

private theorem back_zero_from_top8 (b : Bool) (y : Nat → Bool) (q : Nat)
    (hwhite : ∀ k, q + 9 ≤ k → y k = false)
    (h0 : back b y (q + 8) = false) (h1 : back b y (q + 9) = false) :
    ∀ k, q + 8 ≤ k → back b y k = false := by
  have hp : ∀ d, back b y (q + 8 + d) = false ∧
      back b y (q + 8 + d + 1) = false := by
    intro d
    induction d with
    | zero => simpa using And.intro h0 h1
    | succ d ih =>
        refine ⟨by simpa [Nat.add_assoc] using ih.2, ?_⟩
        rw [show q + 8 + (d + 1) + 1 = (q + 8 + d) + 2 by omega,
          back_succ_succ,
          hwhite (q + 8 + d + 1) (by omega), ih.1, ih.2]
        rfl
  intro k hk
  have he : q + 8 + (k - (q + 8)) = k := by omega
  rw [← he]
  exact (hp (k - (q + 8))).1

/-- Every one-step predecessor of the age-`t` image of a nonzero finite
zero-wall row is finite once `t ≥ 8`. The predecessor is allowed to be an
arbitrary infinite Boolean row before the theorem is applied. -/
theorem aged_image_all_predecessors_finite (Y t : Nat) (hY : Y ≠ 0) (ht : 8 ≤ t)
    (X : Nat → Bool)
    (hpre : ∀ k, 1 ≤ k → zrow X 1 k = rowOfNat (iter F t Y) k) :
    FinSupp X := by
  let m := Y.log2
  let q := m + t - 7
  let Z := iter F t Y
  let y := rowOfNat Z
  have htop : Top Z (m + t) := Top_iter (top_log2 hY) t
  have hwhite : ∀ k, q + 9 ≤ k → y k = false := by
    intro k hk
    obtain ⟨i, rfl⟩ : ∃ i, k = i + 1 := ⟨k - 1, by omega⟩
    have hi : m + t < i := by dsimp [q] at hk; omega
    exact htop.2 i hi
  have hgood : EdgeGood8 (Z >>> q) = true := top8_from_age_eight Y t hY ht
  have hreset := back_reset_at_top8 Z q hgood (X 1)
  have hfinback : FinSupp (back (X 1) y) :=
    (back_fin_iff (X 1) (n := q + 9) (by omega) hwhite).2
      (by simpa only [show q + 9 - 1 = q + 8 by omega] using hreset)
  obtain ⟨W, hW⟩ := hfinback
  refine ⟨W, ?_⟩
  intro k hk
  have hrec := eq_back (L := X) (y := y) hpre k
  rw [zrow_zero_of_pos X (by omega)] at hrec
  rw [hrec]
  exact hW k hk

/-- The same predecessor has the exact last black depth `Y.log2 + t`.
This uses the true moving edge, rather than merely a support bound. -/
theorem aged_image_predecessor_true_edge (Y t : Nat) (hY : Y ≠ 0) (ht : 8 ≤ t)
    (X : Nat → Bool)
    (hpre : ∀ k, 1 ≤ k → zrow X 1 k = rowOfNat (iter F t Y) k) :
    X (Y.log2 + t) = true ∧
    ∀ k, Y.log2 + t < k → X k = false := by
  let m := Y.log2
  let q := m + t - 7
  let Z := iter F t Y
  let y := rowOfNat Z
  have htop : Top Z (m + t) := Top_iter (top_log2 hY) t
  have hwhite : ∀ k, q + 9 ≤ k → y k = false := by
    intro k hk
    obtain ⟨i, rfl⟩ : ∃ i, k = i + 1 := ⟨k - 1, by omega⟩
    have hi : m + t < i := by dsimp [q] at hk; omega
    exact htop.2 i hi
  have hgood : EdgeGood8 (Z >>> q) = true := top8_from_age_eight Y t hY ht
  obtain ⟨h0, h1⟩ := back_reset_at_top8 Z q hgood (X 1)
  have hbacktail := back_zero_from_top8 (X 1) y q hwhite h0 h1
  have hXtail : ∀ k, q + 8 ≤ k → X k = false := by
    intro k hk
    have hrec := eq_back (L := X) (y := y) hpre k
    rw [zrow_zero_of_pos X (by omega)] at hrec
    rw [hrec]
    exact hbacktail k hk
  have hq : q + 8 = m + t + 1 := by dsimp [q]; omega
  have hx1 : X (m + t + 1) = false := hXtail _ (by omega)
  have hx2 : X (m + t + 2) = false := hXtail _ (by omega)
  have hyTop : y (m + t + 1) = true := htop.1
  have hz2 : zrow X 0 (m + t + 2) = X (m + t + 2) :=
    zrow_zero_of_pos X (by omega)
  have hz1 : zrow X 0 (m + t + 1) = X (m + t + 1) :=
    zrow_zero_of_pos X (by omega)
  have hz0 : zrow X 0 (m + t) = X (m + t) :=
    zrow_zero_of_pos X (by omega)
  have hstep : zrow X 1 (m + t + 1) =
      xor (X (m + t + 2)) (X (m + t + 1) || X (m + t)) := by
    simpa only [Nat.zero_add, hz2, hz1, hz0] using zrow_succ X 0 (m + t)
  have hedge : X (m + t) = true := by
    have heq := hpre (m + t + 1) (by omega)
    rw [hstep, hx1, hx2] at heq
    have heq2 : X (m + t) = y (m + t + 1) := by simpa using heq
    rw [hyTop] at heq2
    exact heq2
  refine ⟨hedge, ?_⟩
  intro k hk
  exact hXtail k (by omega)

/-- Physical-row form: if `L` has actual last black depth `m`, then every
predecessor of its age-`t` image has actual last black depth `m+t-1` once
`t ≥ 8`. No finiteness assumption is made on the predecessor. -/
theorem finite_row_aged_image_all_predecessors_true_edge
    {L : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true)
    (hfin : ∀ k, m < k → L k = false) (ht : 8 ≤ t)
    (X : Nat → Bool) (hpre : ∀ k, 1 ≤ k → zrow X 1 k = zrow L t k) :
    X (m + t - 1) = true ∧ ∀ k, m + t - 1 < k → X k = false := by
  let Y := natOfRow L m
  have hbit : Y.testBit (m - 1) = true := by
    rw [testBit_natOfRow]
    simp [show m - 1 < m by omega, show m - 1 + 1 = m by omega, hedge]
  have hY : Y ≠ 0 := by
    intro hzero
    subst Y
    simp [hzero] at hbit
  have htop : Top Y (m - 1) := by
    refine ⟨hbit, ?_⟩
    intro i hi
    rw [testBit_natOfRow]
    have hge : m ≤ i := by omega
    simp [show ¬ i < m by omega]
  have hlog : Y.log2 = m - 1 := (Top_unique (top_log2 hY) htop)
  have hpreNat : ∀ k, 1 ≤ k → zrow X 1 k = rowOfNat (iter F t Y) k := by
    intro k hk
    have hrow : ∀ j, 1 ≤ j → L j = rowOfNat Y j :=
      fun j hj => (rowOfNat_natOfRow hfin j hj).symm
    calc
      zrow X 1 k = zrow L t k := hpre k hk
      _ = zrow (rowOfNat Y) t k := zrow_congr hrow t k
      _ = rowOfNat (iter F t Y) k := zrow_rowOfNat Y t k
  obtain ⟨he, htail⟩ := aged_image_predecessor_true_edge Y t hY ht X hpreNat
  have hclock : m + t - 1 = Y.log2 + t := by rw [hlog]; omega
  rw [hclock]
  exact ⟨he, htail⟩


/-! ### Constructive two-branch 1-step predecessors, exact two-branch equivalence, outer synchronization, and unique `InX` predecessor at age 8 -/

/-- **Constructive Two-Branch True-Edge Theorem at Age `8` (`back_aged_image_true_edge`):**
for any finite row `L` with last black cell `m ≥ 1`, any age `t ≥ 8`, and either initial wall bit
`b : Bool`, the backward transducer run `back b (zrow L t)` is a one-step predecessor of `zrow L t`
with exact last black depth `m + t - 1`. -/
theorem back_aged_image_true_edge {L : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true) (hfin : ∀ k, m < k → L k = false) (ht : 8 ≤ t) (b : Bool) :
    (∀ k, 1 ≤ k → zrow (back b (zrow L t)) 1 k = zrow L t k) ∧
    back b (zrow L t) (m + t - 1) = true ∧
    ∀ k, m + t - 1 < k → back b (zrow L t) k = false := by
  have hpre : ∀ k, 1 ≤ k → zrow (back b (zrow L t)) 1 k = zrow L t k :=
    fun k hk => zrow_back b (zrow L t) k hk
  exact ⟨hpre,
    finite_row_aged_image_all_predecessors_true_edge hm hedge hfin ht (back b (zrow L t)) hpre⟩

/-- **Exact Two-Branch Characterization of All One-Step Predecessors
(`predecessor_iff_eq_back_false_or_true`):** for any row `y : Nat → Bool` and any sequence
`X : Nat → Bool`, `zrow X 1` agrees with `y` on `k ≥ 1` if and only if `X` agrees on `k ≥ 1`
with either `back false y` or `back true y`. -/
theorem predecessor_iff_eq_back_false_or_true (y X : Nat → Bool) :
    (∀ k, 1 ≤ k → zrow X 1 k = y k) ↔
      (∀ k, 1 ≤ k → X k = back false y k) ∨ (∀ k, 1 ≤ k → X k = back true y k) := by
  constructor
  · intro hpre
    cases hb : X 1
    · left
      intro k hk
      have h := eq_back (L := X) (y := y) hpre k
      rwa [zrow_zero_of_pos X hk, hb] at h
    · right
      intro k hk
      have h := eq_back (L := X) (y := y) hpre k
      rwa [zrow_zero_of_pos X hk, hb] at h
  · rintro (hf | ht) k hk
    · rw [zrow_congr hf 1 k, zrow_back false y k hk]
    · rw [zrow_congr ht 1 k, zrow_back true y k hk]

/-- **Outer Synchronization of `back false` and `back true` From the True Edge Onward
(`back_false_eq_back_true_from_edge`):** for any finite row `L` with last black cell `m ≥ 1` and
age `t ≥ 8`, `back false (zrow L t)` and `back true (zrow L t)` agree at every depth
`k ≥ m + t - 1`. -/
theorem back_false_eq_back_true_from_edge {L : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true) (hfin : ∀ k, m < k → L k = false) (ht : 8 ≤ t)
    {k : Nat} (hk : m + t - 1 ≤ k) :
    back false (zrow L t) k = back true (zrow L t) k := by
  have hf := (back_aged_image_true_edge hm hedge hfin ht false).2
  have htr := (back_aged_image_true_edge hm hedge hfin ht true).2
  by_cases heq : k = m + t - 1
  · subst heq; rw [hf.1, htr.1]
  · rw [hf.2 k (by omega), htr.2 k (by omega)]

/-- **Unique `InX` One-Step Predecessor and Exact Edge at Age `8`
(`inX_predecessor_aged_image_unique_and_true_edge`):** if `X` is in `InX` and `zrow X 1` agrees
on `k ≥ 1` with `zrow L t` (`m ≥ 1, t ≥ 8`), then `X k = back true (zrow L t) k` for all `k ≥ 1`
and `X` has exact last black depth `m + t - 1`. -/
theorem inX_predecessor_aged_image_unique_and_true_edge {L X : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true) (hfin : ∀ k, m < k → L k = false) (ht : 8 ≤ t)
    (hX : InX X) (hpre : ∀ k, 1 ≤ k → zrow X 1 k = zrow L t k) :
    (∀ k, 1 ≤ k → X k = back true (zrow L t) k) ∧
    X (m + t - 1) = true ∧
    ∀ k, m + t - 1 < k → X k = false := by
  refine ⟨fun k hk => ?_,
    finite_row_aged_image_all_predecessors_true_edge hm hedge hfin ht X hpre⟩
  have h := eq_back (L := X) (y := zrow L t) hpre k
  have hX1 : X 1 = true := by
    have h0 := hX 0
    rwa [Nat.mul_zero, zrow_zero_of_pos X (Nat.le_refl 1)] at h0
  rwa [zrow_zero_of_pos X hk, hX1] at h

end Rule30Submission.Rule30AgeEightInverse

/-! A six-state top-band theorem at age 24 for the fixed-white-wall Rule 30 map.

The edge map, shift theorem, and backward transducer are imported from the
public Rule30LateTwins and pinned Rule30ZeroBoundary modules. The attributed
Rule30LateTwins source is pinned at commit 67283b1e66ca2d86a7c5e479cc2172e59845c96b.
The age-eight top-band result is imported from the separately checked local
Rule30AgeEightInverse module. -/


namespace Rule30Submission.Rule30AgeTwentyFourInverse

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm Rule30LateTwins Rule30AgeEightInverse

def EdgeGood20 (u : Nat) : Bool :=
  u == 820681 || u == 820683 || u == 822904 ||
  u == 911005 || u == 911007 || u == 912610

private theorem good20_iff {u : Nat} : EdgeGood20 u = true ↔
    u = 820681 ∨ u = 820683 ∨ u = 822904 ∨
    u = 911005 ∨ u = 911007 ∨ u = 912610 := by
  simp [EdgeGood20, Bool.or_eq_true, beq_iff_eq, or_assoc]

private theorem small24_base (Y : Nat) (hY : Y ≠ 0) (hsmall : Y < 2048) :
    EdgeGood20 ((iter F 24 Y) >>> (Y.log2 + 5)) = true := by
  have hc : chk (fun v => v == 0 ||
      EdgeGood20 ((iter F 24 v) >>> (v.log2 + 5))) 0 11 = true := by
    decide +kernel
  have h := chk_sound (fun v => v == 0 ||
    EdgeGood20 ((iter F 24 v) >>> (v.log2 + 5))) 11 0 hc Y (by omega)
  simpa [hY] using h

private theorem large24_base (u : Nat)
    (h8 : EdgeGood8 (u >>> 12) = true) : EdgeGood20 (iterR 16 u) = true := by
  have hc200 : chk (fun b => EdgeGood20 (iterR 16 (200 * 4096 + b))) 0 12 = true := by
    decide +kernel
  have hc222 : chk (fun b => EdgeGood20 (iterR 16 (222 * 4096 + b))) 0 12 = true := by
    decide +kernel
  have hsplit : u = (u >>> 12) * 4096 + u % 4096 := by
    rw [Nat.shiftRight_eq_div_pow]
    omega
  have hb : u % 4096 < 2 ^ 12 := Nat.mod_lt _ (by decide)
  rw [hsplit]
  simp only [EdgeGood8, Bool.or_eq_true, beq_iff_eq] at h8
  rcases h8 with h | h <;> rw [h]
  · simpa using chk_sound _ 12 0 hc200 (u % 4096) hb
  · simpa using chk_sound _ 12 0 hc222 (u % 4096) hb

private theorem EdgeGood20_R {u : Nat} (h : EdgeGood20 u = true) :
    EdgeGood20 (R u) = true := by
  rcases good20_iff.mp h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide

private theorem EdgeGood20_iterR {u : Nat} (h : EdgeGood20 u = true) :
    ∀ d, EdgeGood20 (iterR d u) = true := by
  intro d
  induction d generalizing u with
  | zero => exact h
  | succ d ih => exact ih (EdgeGood20_R h)

theorem top20_from_age_twenty_four (Y t : Nat) (hY : Y ≠ 0) (ht : 24 ≤ t) :
    EdgeGood20 ((iter F t Y) >>> (Y.log2 + t - 19)) = true := by
  have h24 : EdgeGood20 ((iter F 24 Y) >>> (Y.log2 + 5)) = true := by
    by_cases hsmall : Y < 2048
    · exact small24_base Y hY hsmall
    · have hm : 11 ≤ Y.log2 := (Nat.le_log2 hY).2 (by omega : 2 ^ 11 ≤ Y)
      let q := Y.log2 - 11
      have hq : q + 12 = Y.log2 + 1 := by dsimp [q]; omega
      let X := iter F 8 Y
      have h8 : EdgeGood8 ((X >>> q) >>> 12) = true := by
        rw [← Nat.shiftRight_add, hq]
        exact top8_from_age_eight Y 8 hY (by decide)
      have htime : Y.log2 + 5 = q + 16 := by dsimp [q]; omega
      rw [show (24 : Nat) = 8 + 16 from rfl, iter_add F 8 16 Y, htime,
        iter_F_shiftRight]
      exact large24_base (X >>> q) h8
  obtain ⟨d, rfl⟩ : ∃ d, t = 24 + d := ⟨t - 24, by omega⟩
  have htime : Y.log2 + (24 + d) - 19 = (Y.log2 + 5) + d := by omega
  rw [htime, iter_add F 24 d Y, iter_F_shiftRight]
  exact EdgeGood20_iterR h24 d

/-! The inverse rule, expressed as a four-state transducer on adjacent bits. -/

private def pairStep (bit : Bool) (p : Bool × Bool) : Bool × Bool :=
  (p.2, xor bit (p.1 || p.2))

private def pairRun (word : Nat) (p : Bool × Bool) : Nat → Bool × Bool
  | 0 => p
  | n + 1 => pairStep (word.testBit n) (pairRun word p n)

private def parentProfile (word : Nat) : Nat :=
  if word == 820681 || word == 820683 || word == 822904 then 222 else 200

private theorem parentProfile_good {word : Nat} (h : EdgeGood20 word = true) :
    EdgeGood8 (parentProfile word) = true := by
  rcases good20_iff.mp h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide

private theorem pairRun20_reset (word : Nat) (h : EdgeGood20 word = true)
    (a c : Bool) : pairRun word (a, c) 20 = (false, false) := by
  rcases good20_iff.mp h with rfl | rfl | rfl | rfl | rfl | rfl <;>
    cases a <;> cases c <;> decide

private theorem pairRun20_parentProfile (word : Nat) (h : EdgeGood20 word = true)
    (a c : Bool) (i : Nat) (hi : i < 8) :
    (pairRun word (a, c) (11 + i)).2 = (parentProfile word).testBit i := by
  have hc : chk (fun j =>
      (pairRun word (a, c) (11 + j)).2 == (parentProfile word).testBit j) 0 3 = true := by
    rcases good20_iff.mp h with rfl | rfl | rfl | rfl | rfl | rfl <;>
      cases a <;> cases c <;> decide +kernel
  have ht := chk_sound _ 3 0 hc i (by omega)
  simpa only [Nat.zero_add, beq_iff_eq] using ht

private theorem pairRun8_reset (word : Nat) (h : EdgeGood8 word = true)
    (a c : Bool) : pairRun word (a, c) 8 = (false, false) := by
  simp only [EdgeGood8, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with rfl | rfl <;> cases a <;> cases c <;> decide

private theorem pairRun_back (word q n : Nat) (b : Bool) (y : Nat → Bool)
    (hbits : ∀ i, i < n → y (q + 1 + i) = word.testBit i) :
    pairRun word (back b y q, back b y (q + 1)) n =
      (back b y (q + n), back b y (q + n + 1)) := by
  induction n with
  | zero => simp [pairRun]
  | succ n ih =>
      have hn : ∀ i, i < n → y (q + 1 + i) = word.testBit i :=
        fun i hi => hbits i (by omega)
      rw [pairRun, ih hn]
      have hb : word.testBit n = y (q + n + 1) := by
        simpa only [show q + 1 + n = q + n + 1 by omega] using
          (hbits n (by omega)).symm
      rw [hb]
      simp only [pairStep, show q + (n + 1) = q + n + 1 by omega,
        back_succ_succ]
      rw [Bool.or_comm (back b y (q + n)) (back b y (q + n + 1))]

private theorem image_word_bit (Z q i : Nat) :
    rowOfNat Z (q + 1 + i) = (Z >>> q).testBit i := by
  rw [show q + 1 + i = (q + i) + 1 by omega, rowOfNat,
    Nat.testBit_shiftRight]

private theorem zrow_one_eq (X : Nat → Bool) (k : Nat) (hk : 1 ≤ k) :
    zrow X 1 (k + 1) = xor (X (k + 2)) (X (k + 1) || X k) := by
  have h := zrow_succ X 0 k
  simpa only [Nat.zero_add, zrow_zero_of_pos X (show 1 ≤ k + 2 by omega),
    zrow_zero_of_pos X (show 1 ≤ k + 1 by omega),
    zrow_zero_of_pos X hk] using h

private theorem predecessor_edge_from_reset
    (y X : Nat → Bool) (e : Nat) (he : 2 ≤ e)
    (hpre : ∀ k, 1 ≤ k → zrow X 1 k = y k)
    (hyedge : y e = true) (hywhite : ∀ k, e < k → y k = false)
    (h0 : X e = false) (h1 : X (e + 1) = false) :
    X (e - 1) = true ∧ ∀ k, e - 1 < k → X k = false := by
  have hp : ∀ d, X (e + d) = false ∧ X (e + d + 1) = false := by
    intro d
    induction d with
    | zero => simpa using And.intro h0 h1
    | succ d ih =>
        refine ⟨by simpa [Nat.add_assoc] using ih.2, ?_⟩
        have hstep := hpre (e + d + 1) (by omega)
        rw [show e + d + 1 = (e + d) + 1 by omega,
          zrow_one_eq X (e + d) (by omega), ih.1, ih.2,
          hywhite (e + d + 1) (by omega)] at hstep
        simpa [Nat.add_assoc] using hstep
  have htail : ∀ k, e ≤ k → X k = false := by
    intro k hk
    have heq : e + (k - e) = k := by omega
    rw [← heq]
    exact (hp (k - e)).1
  have hstep : y e = xor (X (e + 1)) (X e || X (e - 1)) := by
    have h := hpre e (by omega)
    rw [show e = (e - 1) + 1 by omega,
      zrow_one_eq X (e - 1) (by omega)] at h
    simpa only [show e - 1 + 2 = e + 1 by omega,
      show e - 1 + 1 = e by omega] using h.symm
  have hedge : X (e - 1) = true := by
    rw [h0, h1, hyedge] at hstep
    simpa using hstep.symm
  exact ⟨hedge, fun k hk => htail k (by omega)⟩

/-- Every two-step predecessor of the age-`t` image of a nonzero finite
zero-wall row has the exact edge two cells behind the image edge, once
`t ≥ 24`. Both intermediate rows may initially be infinite. -/
theorem aged_image_two_step_predecessor_true_edge
    (Y t : Nat) (hY : Y ≠ 0) (ht : 24 ≤ t)
    (X V : Nat → Bool)
    (hX : ∀ k, 1 ≤ k → zrow X 1 k = rowOfNat (iter F t Y) k)
    (hV : ∀ k, 1 ≤ k → zrow V 1 k = X k) :
    V (Y.log2 + t - 1) = true ∧
    ∀ k, Y.log2 + t - 1 < k → V k = false := by
  let m := Y.log2
  let Z := iter F t Y
  let y := rowOfNat Z
  let q := m + t - 19
  let e := m + t + 1
  let word := Z >>> q
  let r := q + 11
  let profile := parentProfile word
  have hq : q + 20 = e := by dsimp [q, e, m]; omega
  have hr : r + 8 = e - 1 := by dsimp [r, q, e, m]; omega
  have he : 2 ≤ e := by dsimp [e, m]; omega
  have he2 : 2 ≤ e - 1 := by omega
  have hgood : EdgeGood20 word = true :=
    top20_from_age_twenty_four Y t hY ht
  have hprofile : EdgeGood8 profile = true := parentProfile_good hgood
  have hbit (i : Nat) : y (q + 1 + i) = word.testBit i :=
    image_word_bit Z q i
  have hXback : ∀ k, 1 ≤ k → X k = back (X 1) y k := by
    intro k hk
    have h := eq_back (L := X) (y := y) hX k
    rwa [zrow_zero_of_pos X hk] at h
  have hVback : ∀ k, 1 ≤ k → V k = back (V 1) X k := by
    intro k hk
    have h := eq_back (L := V) (y := X) hV k
    rwa [zrow_zero_of_pos V hk] at h
  have hpair20 := pairRun20_reset word hgood
    (back (X 1) y q) (back (X 1) y (q + 1))
  have hrun20 := pairRun_back word q 20 (X 1) y
    (fun i _ => hbit i)
  rw [hrun20] at hpair20
  have hXreset : X e = false ∧ X (e + 1) = false := by
    have h0 : back (X 1) y (q + 20) = false := by
      simpa using congrArg Prod.fst hpair20
    have h1 : back (X 1) y (q + 21) = false := by
      simpa using congrArg Prod.snd hpair20
    constructor
    · rw [← hq, hXback (q + 20) (by omega)]
      exact h0
    · rw [show e + 1 = q + 21 by omega, hXback (q + 21) (by omega)]
      exact h1
  have htop : Top Z (m + t) := Top_iter (top_log2 hY) t
  have hyedge : y e = true := by
    simpa only [y, e, m, rowOfNat] using htop.1
  have hywhite : ∀ k, e < k → y k = false := by
    intro k hk
    obtain ⟨i, rfl⟩ : ∃ i, k = i + 1 := ⟨k - 1, by omega⟩
    have hi : m + t < i := by dsimp [e] at hk; omega
    exact htop.2 i hi
  have hXedge := predecessor_edge_from_reset y X e he hX hyedge hywhite
    hXreset.1 hXreset.2
  have hparentbit : ∀ i, i < 8 → X (r + 1 + i) = profile.testBit i := by
    intro i hi
    have htable := pairRun20_parentProfile word hgood
      (back (X 1) y q) (back (X 1) y (q + 1)) i hi
    have hrun := pairRun_back word q (11 + i) (X 1) y
      (fun j _ => hbit j)
    rw [hrun] at htable
    have hindex : r + 1 + i = q + (11 + i) + 1 := by
      dsimp [r]; omega
    rw [hindex, hXback (q + (11 + i) + 1) (by omega)]
    exact htable
  have hpair8 := pairRun8_reset profile hprofile
    (back (V 1) X r) (back (V 1) X (r + 1))
  have hrun8 := pairRun_back profile r 8 (V 1) X
    (fun i hi => hparentbit i hi)
  rw [hrun8] at hpair8
  have hVreset : V (e - 1) = false ∧ V e = false := by
    constructor
    · rw [← hr, hVback (r + 8) (by omega)]
      simpa using congrArg Prod.fst hpair8
    · rw [show e = r + 9 by omega, hVback (r + 9) (by omega)]
      simpa using congrArg Prod.snd hpair8
  have hVedge := predecessor_edge_from_reset X V (e - 1) he2 hV
    hXedge.1 hXedge.2 hVreset.1 hVreset.2
  have hclock : e - 1 - 1 = m + t - 1 := by dsimp [e, m] <;> omega
  rw [hclock] at hVedge
  exact hVedge

/-- Physical-row version with the original fixed white wall and actual
last black site `m`; the predecessor is arbitrary before the theorem. -/
theorem finite_row_aged_image_two_step_predecessor_true_edge
    {L : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true)
    (hfin : ∀ k, m < k → L k = false) (ht : 24 ≤ t)
    (V : Nat → Bool)
    (hpre : ∀ k, 1 ≤ k → zrow V 2 k = zrow L t k) :
    V (m + t - 2) = true ∧
    ∀ k, m + t - 2 < k → V k = false := by
  let Y := natOfRow L m
  have hbit : Y.testBit (m - 1) = true := by
    rw [testBit_natOfRow]
    simp [show m - 1 < m by omega, show m - 1 + 1 = m by omega, hedge]
  have hY : Y ≠ 0 := by
    intro hzero
    subst Y
    simp [hzero] at hbit
  have htop : Top Y (m - 1) := by
    refine ⟨hbit, ?_⟩
    intro i hi
    rw [testBit_natOfRow]
    have hge : m ≤ i := by omega
    simp [show ¬ i < m by omega]
  have hlog : Y.log2 = m - 1 := Top_unique (top_log2 hY) htop
  let X := zrow V 1
  have hX : ∀ k, 1 ≤ k → zrow X 1 k = rowOfNat (iter F t Y) k := by
    intro k hk
    have hrow : ∀ j, 1 ≤ j → L j = rowOfNat Y j :=
      fun j hj => (rowOfNat_natOfRow hfin j hj).symm
    calc
      zrow X 1 k = zrow V 2 k := by
        simpa only [X] using (zrow_shift V 1 1 k).symm
      _ = zrow L t k := hpre k hk
      _ = zrow (rowOfNat Y) t k := zrow_congr hrow t k
      _ = rowOfNat (iter F t Y) k := zrow_rowOfNat Y t k
  have hV : ∀ k, 1 ≤ k → zrow V 1 k = X k := by
    intro k _
    rfl
  have hNat := aged_image_two_step_predecessor_true_edge Y t hY ht X V hX hV
  have hclock : m + t - 2 = Y.log2 + t - 1 := by rw [hlog]; omega
  rw [hclock]
  exact hNat


/-! ### Top-band cycle structure, sharpening `band_late` to age 26 and `late_twin` to age 25, 2-bit predecessor dichotomy, and backward finite-edge inheritance for `Theta` -/

/-- **Strict Period-`2` Oscillation of `EdgeGood8` Under `R` (`EdgeGood8_period_two`):**
every state `u` with `EdgeGood8 u = true` (`u ∈ {200, 222}`) satisfies `R u ≠ u` and
`iterR 2 u = u`. -/
theorem EdgeGood8_period_two {u : Nat} (h : EdgeGood8 u = true) :
    R u ≠ u ∧ iterR 2 u = u := by
  simp only [EdgeGood8, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with rfl | rfl <;> decide

/-- **Two-Step Entry of `EdgeGood20` Into the Four-Cycle `C20` (`EdgeGood20_two_step_inC20`):**
for every `u` with `EdgeGood20 u = true`, two steps `iterR 2 u` lie in the four-cycle `inC20`
(`820683, 822904, 911005, 912610`) and satisfy `R (iterR 2 u) ≠ iterR 2 u` and
`iterR 6 u = iterR 2 u`. -/
theorem EdgeGood20_two_step_inC20 {u : Nat} (h : EdgeGood20 u = true) :
    inC20 (iterR 2 u) = true ∧ R (iterR 2 u) ≠ iterR 2 u ∧ iterR 6 u = iterR 2 u := by
  rcases good20_iff.mp h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide

/-- **Sharpened Top-`20` Four-Cycle Settling at Age `26` (`band_from_age_twenty_six`):**
for every nonzero `y` and every `t ≥ 26` (sharpening `Rule30LateTwins.band_late` from `45` down
to `26`), the top twenty cells of `iter F t y` lie on `C20`. -/
theorem band_from_age_twenty_six {y : Nat} (hy : y ≠ 0) {t : Nat} (ht : 26 ≤ t) :
    inC20 (iter F t y >>> (y.log2 + t - 19)) = true := by
  obtain ⟨d, rfl⟩ : ∃ d, t = (24 + d) + 2 := ⟨t - 26, by omega⟩
  have hgood := top20_from_age_twenty_four y (24 + d) hy (by omega)
  have hshift : iter F ((24 + d) + 2) y >>> (y.log2 + ((24 + d) + 2) - 19) =
      iterR 2 (iter F (24 + d) y >>> (y.log2 + (24 + d) - 19)) := by
    rw [iter_add F (24 + d) 2 y,
      show y.log2 + ((24 + d) + 2) - 19 = (y.log2 + (24 + d) - 19) + 2 by omega,
      iter_F_shiftRight]
  rw [hshift]
  exact (EdgeGood20_two_step_inC20 hgood).1

/-- **Stacked Reset Factors Across All Six States of `EdgeGood20` (`chains_edgeGood20`):**
every state `c` with `EdgeGood20 c = true` carries a reset factor in `c` and a deeper reset
factor in `R c`. -/
theorem chains_edgeGood20 (c : Nat) (hc : EdgeGood20 c = true) :
    ∃ i1 k1 i2 k2, Fac c i1 k1 ∧ Fac (R c) i2 k2 ∧ i2 + 3 * k2 + 4 ≤ i1 := by
  rcases good20_iff.mp hc with rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨14, 0, 6, 0, ⟨Or.inl rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩
  · exact ⟨14, 0, 6, 0, ⟨Or.inl rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩
  · exact ⟨14, 0, 0, 0, ⟨Or.inl rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩
  · exact ⟨12, 1, 2, 1, ⟨Or.inr rfl, by decide⟩, ⟨Or.inr rfl, by decide⟩, by decide⟩
  · exact ⟨12, 1, 2, 1, ⟨Or.inr rfl, by decide⟩, ⟨Or.inr rfl, by decide⟩, by decide⟩
  · exact ⟨12, 1, 2, 0, ⟨Or.inr rfl, by decide⟩, ⟨Or.inl rfl, by decide⟩, by decide⟩

/-- **Sharpened Late Twin Existence From Age `25` (`twin_from_age_twenty_five`):**
for every nonzero natural `y` and every `t ≥ 25` (sharpening `Rule30LateTwins.late_twin` from
`46` down to `25`), the row `x = iter F (t - 2) y` has a twin `x' ≠ x` of the same width, with
the same bit `0` and `F (F x') = iter F t y`. -/
theorem twin_from_age_twenty_five {y : Nat} (hy : y ≠ 0) {t : Nat} (ht : 25 ≤ t) :
    ∃ x', x' ≠ iter F (t - 2) y ∧ x'.testBit 0 = (iter F (t - 2) y).testBit 0 ∧
      F (F x') = iter F t y ∧ Top x' (y.log2 + (t - 2)) := by
  have e1 : iter F (t - 1) y = F (iter F (t - 2) y) := by
    rw [show t - 1 = (t - 2) + 1 by omega]; rfl
  have e2 : iter F t y = F (F (iter F (t - 2) y)) := by
    rw [← e1, show t = (t - 1) + 1 by omega]; rfl
  obtain ⟨c, hc⟩ : ∃ c, iter F (t - 1) y >>> (y.log2 + (t - 1) - 19) = c := ⟨_, rfl⟩
  have hin : EdgeGood20 c = true := hc ▸ top20_from_age_twenty_four y (t - 1) hy (by omega)
  obtain ⟨i1, k1, i2, k2, f1, f2, hi⟩ := chains_edgeGood20 c hin
  have b1 : ∀ j, (iter F (t - 1) y).testBit ((y.log2 + (t - 1) - 19) + i1 + j) = c.testBit (i1 + j) := by
    intro j
    rw [← hc, Nat.testBit_shiftRight, Nat.add_assoc]
  have b2 : ∀ j, (F (iter F (t - 1) y)).testBit ((y.log2 + (t - 1) - 19) + 1 + i2 + j) =
      (R c).testBit (i2 + j) := by
    intro j
    rw [← hc, ← F_shiftRight, Nat.testBit_shiftRight, Nat.add_assoc, Nat.add_assoc]
  have g1 := fac_transfer b1 f1
  have g2 := fac_transfer b2 f2
  rw [e1] at g1 g2
  obtain ⟨x', hne, hb0, hF⟩ := twin_of_factors g2 g1 (by omega)
  refine ⟨x', hne, hb0, by rw [hF, e2], ?_⟩
  have hx'0 : x' ≠ 0 := by
    intro h0
    have hT := Top_iter (top_log2 hy) t
    rw [e2, ← hF, h0, IntegerForm.F_zero, IntegerForm.F_zero] at hT
    exact absurd hT.1 (by rw [Nat.zero_testBit]; decide)
  have hT' := Top_iter (top_log2 hx'0) 2
  have hT2 := Top_iter (top_log2 hy) t
  rw [e2, ← hF] at hT2
  have : x'.log2 + 2 = y.log2 + t := Top_unique hT' hT2
  rw [show y.log2 + (t - 2) = x'.log2 by omega]
  exact top_log2 hx'0

/-- **Sharpened Off-Orbit Immortal Twins From Even Age `26` (`twin_off_orbit_from_age_twenty_six`):**
if `y` never reaches an even value under `G` and `t ≥ 26` is even (sharpening
`Rule30LateTwins.late_twin_off_orbit` from `46` down to `26`), there exists `x'` off the `G`-orbit
of `y` (`∀ j, x' ≠ iter G j y`) such that `G x' = iter F t y` and `∀ s, iter G s x' % 2 = 1`. -/
theorem twin_off_orbit_from_age_twenty_six {y : Nat} (hy : ∀ s, iter G s y % 2 = 1)
    {t : Nat} (ht : 26 ≤ t) (he : t % 2 = 0) :
    ∃ x', (∀ s, iter G s x' % 2 = 1) ∧ G x' = iter F t y ∧ ∀ j, x' ≠ iter G j y := by
  have hy0 : y ≠ 0 := by
    intro h
    have := hy 0
    rw [h] at this
    exact absurd this (by decide)
  obtain ⟨x', hne, hb0, hF, hT⟩ := twin_from_age_twenty_five (t := t) hy0 (by omega)
  refine ⟨x', ?_, hF, fun j hj => ?_⟩
  · intro s
    cases s with
    | zero =>
      have h := hy ((t - 2) / 2)
      rw [iter_G_eq_iter_F_two_mul, show 2 * ((t - 2) / 2) = t - 2 by omega] at h
      show x' % 2 = 1
      rw [odd_iff_testBit, hb0, ← odd_iff_testBit]
      exact h
    | succ s =>
      rw [iter_succ']
      have hG : G x' = iter G (t / 2) y := by
        rw [iter_G_eq_iter_F_two_mul, show 2 * (t / 2) = t by omega]
        exact hF
      rw [hG, ← iter_add]
      exact hy _
  · have hTj := Top_iter (top_log2 hy0) (2 * j)
    rw [← iter_G_eq_iter_F_two_mul, ← hj] at hTj
    have : y.log2 + (t - 2) = y.log2 + 2 * j := Top_unique hT hTj
    apply hne
    rw [hj, iter_G_eq_iter_F_two_mul, show 2 * j = t - 2 by omega]

/-- **Unique 1-Bit Parameterization of One-Step Predecessors (`predecessor_unique_of_bit1`):**
if `X` and `X'` are one-step predecessors of the same row `y` on `k ≥ 1` and agree at depth `1`
(`X 1 = X' 1`), then `X k = X' k` for all `k ≥ 1`. -/
theorem predecessor_unique_of_bit1 {y X X' : Nat → Bool}
    (hX : ∀ k, 1 ≤ k → zrow X 1 k = y k)
    (hX' : ∀ k, 1 ≤ k → zrow X' 1 k = y k)
    (h1 : X 1 = X' 1) :
    ∀ k, 1 ≤ k → X k = X' k := by
  intro k hk
  have e1 := eq_back (L := X) (y := y) hX k
  have e2 := eq_back (L := X') (y := y) hX' k
  rw [zrow_zero_of_pos X hk] at e1
  rw [zrow_zero_of_pos X' hk] at e2
  rw [e1, e2, h1]

/-- **Unique 2-Bit Parameterization of Two-Step Predecessors (`two_step_predecessor_unique_of_bits`):**
if `V` and `V'` are two-step predecessors of the same row `y` on `k ≥ 1` (`zrow V 2 k = y k` and
`zrow V' 2 k = y k`) with `V 1 = V' 1` and `zrow V 1 1 = zrow V' 1 1`, then `V k = V' k` for
all `k ≥ 1`. -/
theorem two_step_predecessor_unique_of_bits {y V V' : Nat → Bool}
    (hV : ∀ k, 1 ≤ k → zrow V 2 k = y k)
    (hV' : ∀ k, 1 ≤ k → zrow V' 2 k = y k)
    (h0 : V 1 = V' 1)
    (h1 : zrow V 1 1 = zrow V' 1 1) :
    ∀ k, 1 ≤ k → V k = V' k := by
  have hmid : ∀ k, 1 ≤ k → zrow V 1 k = zrow V' 1 k := by
    refine predecessor_unique_of_bit1 (y := y)
      (fun k hk => ?_) (fun k hk => ?_) h1
    · rw [← zrow_shift V 1 1 k]; exact hV k hk
    · rw [← zrow_shift V' 1 1 k]; exact hV' k hk
  exact predecessor_unique_of_bit1 (y := zrow V' 1) hmid (fun _ _ => rfl) h0

/-- **Backward True-Edge Inheritance for `Theta f` From Any Age-`24` Finite Image
(`theta_true_edge_of_shift_eq_aged_image`):** if `L` has last black cell `m ≥ 1` and for some
`t ≥ 24` the shifted reconstruction `Theta (fun s => f (s + 1))` agrees on `k ≥ 1` with `zrow L t`,
then `Theta f` itself has exact last black cell `m + t - 2` and is finitely supported. -/
theorem theta_true_edge_of_shift_eq_aged_image {L f : Nat → Bool} {m t : Nat}
    (hm : 1 ≤ m) (hedge : L m = true) (hfin : ∀ k, m < k → L k = false) (ht : 24 ≤ t)
    (hshift : ∀ k, 1 ≤ k → Theta (fun s => f (s + 1)) k = zrow L t k) :
    Theta f (m + t - 2) = true ∧
    (∀ k, m + t - 2 < k → Theta f k = false) ∧
    FinSupp (Theta f) := by
  have hpre : ∀ k, 1 ≤ k → zrow (Theta f) 2 k = zrow L t k := by
    intro k hk
    rw [congrFun (two_step_shift f) k]
    exact hshift k hk
  obtain ⟨htrue, htail⟩ :=
    finite_row_aged_image_two_step_predecessor_true_edge hm hedge hfin ht (Theta f) hpre
  exact ⟨htrue, htail, ⟨m + t - 2, htail⟩⟩

/-- **Disjointness of Infinite `Theta f` Starts From Shifted Age-`24` Finite Images
(`not_theta_shift_eq_aged_image_of_not_finSupp`):** if `¬ FinSupp (Theta f)`, then for every
finite row `L` with last black cell `m ≥ 1` and every age `t ≥ 24`, `Theta (fun s => f (s + 1))`
cannot agree with `zrow L t` on `k ≥ 1`. -/
theorem not_theta_shift_eq_aged_image_of_not_finSupp {L f : Nat → Bool} {m t : Nat}
    (hinf : ¬ FinSupp (Theta f)) (hm : 1 ≤ m) (hedge : L m = true)
    (hfin : ∀ k, m < k → L k = false) (ht : 24 ≤ t) :
    ¬ ∀ k, 1 ≤ k → Theta (fun s => f (s + 1)) k = zrow L t k := by
  intro hshift
  exact hinf (theta_true_edge_of_shift_eq_aged_image hm hedge hfin ht hshift).2.2

end Rule30Submission.Rule30AgeTwentyFourInverse

/-!
# Inverse ticks for every k: the statement

The kit numbers physical cells from the white wall, with cell 1 beside it.
In a band, bit 0 is the last black cell, and bit j is j cells towards the wall.
The band and the integer encoding of a physical row therefore read in opposite
directions. This module states the target and its hypothesis; `Rule30EveryKInverse` proves the implication.
-/


namespace Rule30Submission.Rule30EveryKStatement

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm

abbrev bandStep := Rule30UniversalLeftSide.stepK
abbrev bandAt := Rule30UniversalLeftSide.rowAt

/-- Odd residues are exactly the width-w words with a black outer edge. -/
def OddBand (w v : Nat) : Prop := v < 2 ^ w ∧ v.testBit 0 = true

/-- Closed black run of length 3m+1. Bit j is the unconstrained symbol
read immediately after the shallow zero to finish agreement of the pair. -/
def resetAt (v j m : Nat) : Bool :=
  !(v.testBit (j + 1)) && !(v.testBit (j + 3*m + 3)) &&
    (List.range (3*m + 1)).all (fun i => v.testBit (j + 2 + i))

/-- First complete factor, scanning from the deepest available bit towards
the edge. Its two zeros, black run and following symbol all lie in the band. -/
def firstReset (v available : Nat) : Option Nat :=
  (List.range available).reverse.find? fun j =>
    (List.range (available / 3 + 1)).any fun m =>
      decide (j + 3*m + 4 ≤ available) && resetAt v j m

/-- The reference at layer d is d ticks *earlier* on the same cycle. Agreement
from wheel j outwards leaves j bits (0 through j-1) after the edge retreats.
Width w supplies sufficient fuel since a complete factor strictly spends width. -/
def schedule (w v period : Nat) : Nat → Nat → Nat → Nat
  | 0, _, _ => 0
  | fuel + 1, d, available =>
    let phase := (period - d % period) % period
    match firstReset (bandAt w v phase) available with
    | none => 0
    | some j => 1 + schedule w v period fuel (d + 1) j

def phaseCapacity (w v period : Nat) : Nat := schedule w v period w 0 w

/-- Find the first positive return. At positive width there are 2^(w-1)
odd residues, so failure within that many steps excludes exactly transients. -/
def returnPeriod (w v : Nat) : Option Nat :=
  let rec walk : Nat → Nat → Nat → Option Nat
    | 0, _, _ => none
    | fuel + 1, current, elapsed =>
      let next := bandStep w current
      if next = v then some (elapsed + 1) else walk fuel next (elapsed + 1)
  walk (2 ^ (w - 1)) v 0

/-- Worst one-layer schedule across every cycle and every phase. Enumerating
all odd initial words includes each periodic phase separately. Width zero is
excluded from CAP. This finite specification favours clarity over runtime. -/
def K1 : Nat → Nat
  | 0 => 0
  | n + 1 =>
    (List.range (2 ^ n)).foldl (fun worst i =>
      let v := 2*i + 1
      match returnPeriod (n + 1) v with
      | none => worst
      | some period => min worst (phaseCapacity (n + 1) v period)) (n + 1)

def CAP : Prop := ∀ k : Nat, ∃ w : Nat, 0 < w ∧ k ≤ K1 w

/-- The target in the kit's physical-row convention, with arbitrary
predecessor V and equality only on positive cells. -/
def PhysicalEdge (k age : Nat) : Prop :=
  ∀ (L : Nat → Bool) (m t : Nat), 1 ≤ m → L m = true →
    (∀ i, m < i → L i = false) → age ≤ t →
    ∀ V : Nat → Bool, (∀ i, 1 ≤ i → zrow V k i = zrow L t i) →
      V (m + t - k) = true ∧ ∀ i, m + t - k < i → V i = false

/-- Definitionally the kit's `Rule30LateTwins.Top`, spelled out here
on the same bits. -/
def Top (Y m : Nat) : Prop :=
  Y.testBit m = true ∧ ∀ i, m < i → Y.testBit i = false

/-- Every predecessor has a finite representative: a natural number whose row agrees with it. -/
def FinitePredecessor (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ L : Nat → Bool,
    (∀ i, 1 ≤ i → zrow L k i = rowOfNat (iter F t Y) i) →
      ∃ A : Nat, (∀ i, 1 ≤ i → rowOfNat A i = L i) ∧
        iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k)

/-- Every wall history occurs. Histories are specified in forward time at cell 1. -/
def AllHistories (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ bits : Fin k → Bool,
    ∃ A : Nat, iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k) ∧
      ∀ i : Fin k, rowOfNat (iter F i.val A) 1 = bits i

def TargetAt (k age : Nat) : Prop :=
  PhysicalEdge k age ∧ FinitePredecessor k age ∧ AllHistories k age

def EveryK (age : Nat → Nat) : Prop := ∀ k, TargetAt k (age k)

/-- Read an integer row's outer band in wheel order. Only full bands of
nonzero rows are used in the convergence statement below. -/
def topBand (w Y : Nat) : Nat :=
  (List.range w).foldl (fun word j =>
    if j ≤ Y.log2 ∧ Y.testBit (Y.log2 - j) = true then word + 2^j else word) 0

def Settled (w age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t →
    let output := iter F t Y
    let v := topBand w output
    w ≤ output.log2 + 1 ∧ OddBand w v ∧ ∃ q : Nat, 0 < q ∧ bandAt w v q = v

/-- The sharper form: any established uniform settling age at a witness
width may be used. First reset starts with free registers at the deep end. -/
def CapacityAtSettlingAge : Prop :=
  ∀ (k w age : Nat), 0 < w → k ≤ K1 w → Settled w age → TargetAt k age

/-- After w-1 ticks every nonzero seed has a full band. A further 2^w
ticks suffice by a finite-state bound. No unique cycle is assumed. -/
def settlingBound (w : Nat) : Nat := w - 1 + 2^w

/-- The least positive witness at or below any supplied witness. The fallback
is the supplied witness itself. CAP provides the endpoint of the finite search. -/
noncomputable def widthFor (capacity : CAP) (k : Nat) : Nat :=
  let witness := Classical.choose (capacity k)
  ((List.range witness).find? (fun w => decide (0 < w ∧ k ≤ K1 w))).getD witness

/-- The conditional every-k statement. Its age depends only on k through the
least capacity witness. CAP remains the open mathematical hypothesis. -/
def ConditionalEveryK : Prop :=
  ∀ capacity : CAP, EveryK (fun k => settlingBound (widthFor capacity k))

/-! ## Zero-allocation `fastFirstReset`, strict cut bound, unconditional `TargetAt 0 0`, and age monotonicity -/

/-- Zero-list-allocation scan for a valid `3*m' + 1` black run starting at `m' ≥ m`,
assuming `v.testBit (j + 1) = false` and `∀ i < 3 * m, v.testBit (j + 2 + i) = true`. -/
def scanResetM (v available j m : Nat) : Nat → Bool
  | 0 => false
  | fuel + 1 =>
    if j + 3 * m + 4 ≤ available then
      if v.testBit (j + 3 * m + 2) then
        if !(v.testBit (j + 3 * m + 3)) then true
        else if v.testBit (j + 3 * m + 4) then scanResetM v available j (m + 1) fuel
        else false
      else false
    else false

def fastHasResetAt (v available j : Nat) : Bool :=
  if j + 4 ≤ available then
    if v.testBit (j + 1) then false
    else scanResetM v available j 0 ((available - j) / 3 + 1)
  else false

def scanResetJ (v available : Nat) : Nat → Option Nat
  | 0 => none
  | rem + 1 =>
    if fastHasResetAt v available rem then some rem
    else scanResetJ v available rem

def fastFirstReset (v available : Nat) : Option Nat :=
  scanResetJ v available available

theorem scanResetM_iff (v available j m fuel : Nat)
    (hfuel : available < j + 3 * (m + fuel) + 4)
    (hb1 : v.testBit (j + 1) = false)
    (hpref : ∀ i : Nat, i < 3 * m → v.testBit (j + 2 + i) = true) :
    scanResetM v available j m fuel = true ↔
      ∃ m' : Nat, m ≤ m' ∧ j + 3 * m' + 4 ≤ available ∧ resetAt v j m' = true := by
  induction fuel generalizing m with
  | zero =>
    simp only [scanResetM, Bool.false_eq_true, false_iff]
    rintro ⟨m', hm', hle, _⟩
    omega
  | succ fuel ih =>
    unfold scanResetM
    by_cases hbound : j + 3 * m + 4 ≤ available
    · rw [ite_eq_left hbound]
      by_cases hb2 : v.testBit (j + 3 * m + 2) = true
      · rw [ite_eq_left hb2]
        by_cases hb3 : (!(v.testBit (j + 3 * m + 3))) = true
        · rw [ite_eq_left hb3]
          simp only [true_iff]
          refine ⟨m, Nat.le_refl m, hbound, ?_⟩
          unfold resetAt
          rw [hb1, hb3]
          simp only [Bool.not_false, Bool.true_and, List.all_eq_true, List.mem_range]
          intro i hi
          by_cases him : i < 3 * m
          · exact hpref i him
          · have hieq : i = 3 * m := by omega
            subst hieq
            simpa [show j + 2 + 3 * m = j + 3 * m + 2 by omega] using hb2
        · rw [ite_eq_right hb3]
          have hb3_true : v.testBit (j + 3 * m + 3) = true := by
            revert hb3; cases v.testBit (j + 3 * m + 3) <;> decide
          have hnot_m : resetAt v j m = false := by
            unfold resetAt; rw [hb3_true]; simp
          by_cases hb4 : v.testBit (j + 3 * m + 4) = true
          · rw [ite_eq_left hb4]
            have hpref' : ∀ i : Nat, i < 3 * (m + 1) → v.testBit (j + 2 + i) = true := by
              intro i hi
              by_cases him : i < 3 * m
              · exact hpref i him
              · have hcases : i = 3 * m ∨ i = 3 * m + 1 ∨ i = 3 * m + 2 := by omega
                rcases hcases with rfl | rfl | rfl
                · simpa [show j + 2 + 3 * m = j + 3 * m + 2 by omega] using hb2
                · simpa [show j + 2 + (3 * m + 1) = j + 3 * m + 3 by omega] using hb3_true
                · simpa [show j + 2 + (3 * m + 2) = j + 3 * m + 4 by omega] using hb4
            rw [ih (m + 1) (by omega) hpref']
            constructor
            · rintro ⟨m', hm', hle, hr⟩
              exact ⟨m', by omega, hle, hr⟩
            · rintro ⟨m', hm', hle, hr⟩
              have hne : m' ≠ m := by rintro rfl; rw [hnot_m] at hr; cases hr
              exact ⟨m', by omega, hle, hr⟩
          · rw [ite_eq_right hb4]
            simp only [Bool.false_eq_true, false_iff]
            rintro ⟨m', hm', _, hr⟩
            by_cases heq : m' = m
            · subst heq; rw [hnot_m] at hr; cases hr
            · have _hgt : m + 1 ≤ m' := by omega
              unfold resetAt at hr
              obtain ⟨_, hall⟩ := Bool.and_eq_true_iff.mp hr
              have hit := List.all_eq_true.mp hall (3 * m + 2) (List.mem_range.mpr (by omega))
              rw [show j + 2 + (3 * m + 2) = j + 3 * m + 4 by omega] at hit
              exact hb4 hit
      · rw [ite_eq_right hb2]
        simp only [Bool.false_eq_true, false_iff]
        rintro ⟨m', hm', _, hr⟩
        unfold resetAt at hr
        obtain ⟨_, hall⟩ := Bool.and_eq_true_iff.mp hr
        have hit := List.all_eq_true.mp hall (3 * m) (List.mem_range.mpr (by omega))
        rw [show j + 2 + 3 * m = j + 3 * m + 2 by omega] at hit
        exact hb2 hit
    · rw [ite_eq_right hbound]
      simp only [Bool.false_eq_true, false_iff]
      rintro ⟨m', hm', hle, _⟩
      omega

theorem fastHasResetAt_eq (v available j : Nat) :
    fastHasResetAt v available j =
      ((List.range (available / 3 + 1)).any fun m =>
        decide (j + 3 * m + 4 ≤ available) && resetAt v j m) := by
  apply Bool.eq_iff_iff.mpr
  rw [List.any_eq_true]
  unfold fastHasResetAt
  by_cases hj4 : j + 4 ≤ available
  · rw [ite_eq_left hj4]
    by_cases hb1 : v.testBit (j + 1) = true
    · rw [ite_eq_left hb1]
      simp only [Bool.false_eq_true, false_iff]
      rintro ⟨m, _, hm⟩
      obtain ⟨_, hr⟩ := Bool.and_eq_true_iff.mp hm
      unfold resetAt at hr; rw [hb1] at hr; simp at hr
    · rw [ite_eq_right hb1]
      have hb1_false : v.testBit (j + 1) = false := by
        revert hb1; cases v.testBit (j + 1) <;> decide
      rw [scanResetM_iff v available j 0 ((available - j) / 3 + 1) (by omega) hb1_false
        (fun i hi => by omega)]
      constructor
      · rintro ⟨m, _, hle, hr⟩
        exact ⟨m, List.mem_range.mpr (by omega), Bool.and_eq_true_iff.mpr ⟨decide_eq_true hle, hr⟩⟩
      · rintro ⟨m, _, hm⟩
        obtain ⟨hle, hr⟩ := Bool.and_eq_true_iff.mp hm
        exact ⟨m, Nat.zero_le m, of_decide_eq_true hle, hr⟩
  · rw [ite_eq_right hj4]
    simp only [Bool.false_eq_true, false_iff]
    rintro ⟨m, _, hm⟩
    have hle := of_decide_eq_true (Bool.and_eq_true_iff.mp hm).1
    omega

theorem scanResetJ_eq_find (v available rem : Nat) :
    scanResetJ v available rem =
      (List.range rem).reverse.find? fun j =>
        (List.range (available / 3 + 1)).any fun m =>
          decide (j + 3 * m + 4 ≤ available) && resetAt v j m := by
  induction rem with
  | zero => simp [scanResetJ]
  | succ rem ih =>
    rw [List.range_succ (n := rem), List.reverse_append, List.reverse_singleton,
      List.singleton_append, List.find?_cons]
    unfold scanResetJ
    rw [fastHasResetAt_eq, ih]
    cases ((List.range (available / 3 + 1)).any fun m =>
      decide (rem + 3 * m + 4 ≤ available) && resetAt v rem m) <;> rfl

/-- **Zero-Allocation `fastFirstReset` Equivalence and Strict 4-Bit Width Contraction (`fastFirstReset_eq_and_bound`).** -/
theorem fastFirstReset_eq_and_bound :
    (∀ v available : Nat, fastFirstReset v available = firstReset v available) ∧
    (∀ v available j : Nat, firstReset v available = some j → j + 4 ≤ available) := by
  refine ⟨fun v available => scanResetJ_eq_find v available available, fun v available j h => ?_⟩
  unfold firstReset at h
  have hh := List.find?_some h
  obtain ⟨m, _, hm⟩ := List.any_eq_true.mp hh
  have hle := of_decide_eq_true (Bool.and_eq_true_iff.mp hm).1
  omega

private theorem top_of_nonzero {X : Nat} (hX : X ≠ 0) : Top X X.log2 := by
  refine ⟨Nat.testBit_log2 hX, fun i hi => ?_⟩
  exact Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le Nat.lt_log2_self
    (Nat.pow_le_pow_right (by decide) (by omega)))

private theorem F_top_step {X : Nat} (hX : X ≠ 0) :
    F X ≠ 0 ∧ (F X).log2 = X.log2 + 1 := by
  have htop := top_of_nonzero hX
  have hbit : (F X).testBit (X.log2 + 1) = true := by
    rw [testBit_F_succ, htop.2 (X.log2 + 2) (by omega), htop.2 (X.log2 + 1) (by omega), htop.1]
    rfl
  have hhigh : ∀ i, X.log2 + 1 < i → (F X).testBit i = false := by
    intro i hi
    obtain ⟨d, rfl⟩ : ∃ d, i = d + 1 := ⟨i - 1, by omega⟩
    rw [testBit_F_succ, htop.2 (d + 2) (by omega), htop.2 (d + 1) (by omega), htop.2 d (by omega)]
    rfl
  have hne : F X ≠ 0 := by
    intro h0; rw [h0, Nat.zero_testBit] at hbit; cases hbit
  have hlt1 : F X < 2 ^ (X.log2 + 2) := by
    apply Classical.byContradiction
    intro hge
    have hge' : 2 ^ (X.log2 + 2) ≤ F X := Nat.not_lt.mp hge
    have hle_log : X.log2 + 2 ≤ (F X).log2 := (Nat.le_log2 hne).mpr hge'
    have htb := Nat.testBit_log2 hne
    rw [hhigh (F X).log2 (by omega)] at htb
    cases htb
  have hge1 : 2 ^ (X.log2 + 1) ≤ F X := Nat.ge_two_pow_of_testBit hbit
  exact ⟨hne, Nat.le_antisymm (Nat.lt_succ_iff.mp ((Nat.log2_lt hne).mpr hlt1))
    ((Nat.le_log2 hne).mpr hge1)⟩

private theorem iter_step_out (t x : Nat) : iter F (t + 1) x = F (iter F t x) := rfl

private theorem iter_F_top (Y t : Nat) (hY : Y ≠ 0) :
    iter F t Y ≠ 0 ∧ (iter F t Y).log2 = Y.log2 + t := by
  induction t with
  | zero => exact ⟨hY, rfl⟩
  | succ t ih =>
    have hstep := F_top_step ih.1
    rw [iter_step_out]
    exact ⟨hstep.1, by rw [hstep.2, ih.2]; omega⟩

/-- **Unconditional `TargetAt 0 0` and Age Monotonicity of `TargetAt` (`targetAt_zero_and_mono_age`).** -/
theorem targetAt_zero_and_mono_age :
    TargetAt 0 0 ∧
    ∀ (k age₁ age₂ : Nat), age₁ ≤ age₂ → TargetAt k age₁ → TargetAt k age₂ := by
  refine ⟨⟨?_, ?_, ?_⟩, fun k age₁ age₂ hle ⟨hp, hf, ha⟩ => ⟨?_, ?_, ?_⟩⟩
  · intro L m t hm hLm hLfin _ht V hV
    have hedge := zrow_edge hm hLm hLfin t
    refine ⟨?_, fun i hi => ?_⟩
    · have h1 := hV (m + t) (by omega)
      rw [zrow_zero_of_pos V (by omega)] at h1
      simpa [Nat.sub_zero, h1] using hedge.1
    · have h1 := hV i (by omega)
      rw [zrow_zero_of_pos V (by omega)] at h1
      simpa [Nat.sub_zero, h1] using hedge.2 i (by omega)
  · intro Y t hY _ht L hL
    obtain ⟨hne, hlog⟩ := iter_F_top Y t hY
    refine ⟨iter F t Y, fun i hi => ?_, rfl, ?_⟩
    · have h1 := hL i hi
      rw [zrow_zero_of_pos L hi] at h1
      exact h1.symm
    · rw [Nat.sub_zero, ← hlog]
      exact top_of_nonzero hne
  · intro Y t hY _ht bits
    obtain ⟨hne, hlog⟩ := iter_F_top Y t hY
    refine ⟨iter F t Y, rfl, ?_, fun i => Fin.elim0 i⟩
    rw [Nat.sub_zero, ← hlog]
    exact top_of_nonzero hne
  · intro L m t hm hLm hfin ht2 V hV
    exact hp L m t hm hLm hfin (by omega) V hV
  · intro Y t hY ht2 L hL
    exact hf Y t hY (by omega) L hL
  · intro Y t hY ht2 bits
    exact ha Y t hY (by omega) bits

end Rule30Submission.Rule30EveryKStatement

/-!
# Scheduled inverse layers at a finite Rule 30 edge

Troy Lowry's Rule30PrizeKit PR #60 gives the reset-word and scheduled-cascade
argument. Here the driver is the preceding phase of an odd edge cycle and the
cut is the one computed by Rule30EveryKStatement.firstReset.
-/


namespace Rule30Submission.Rule30EveryKCascade

open Rule30EveryKStatement Rule30ZeroBoundary Rule30UniversalLeftSide

abbrev Row := Nat → Bool
abbrev Pair := Bool × Bool

/-- Advance the inverse register one physical cell towards the exterior. -/
def advance (b : Bool) (s : Pair) : Pair := (s.2, xor b (s.2 || s.1))

def pair (P : Row) (x : Nat) : Pair := (P x, P (x+1))

private theorem black_cycle (s : Pair) :
    advance true (advance true (advance true (advance true s))) = advance true s := by
  obtain ⟨a,b⟩ := s
  cases a <;> cases b <;> rfl

private theorem black_run (r : Nat → Pair) (start m : Nat)
    (h : ∀ i, i < 3*m+1 → r (start+i+1) = advance true (r (start+i))) :
    r (start+(3*m+1)) = advance true (r start) := by
  induction m with
  | zero => simpa using h 0 (by decide)
  | succ m ih =>
    let n := 3*m+1
    have h1 := h n (by dsimp [n]; omega)
    have h2 := h (n+1) (by dsimp [n]; omega)
    have h3 := h (n+2) (by dsimp [n]; omega)
    have prev := ih (fun i hi => h i (by omega))
    rw [show start+(3*(m+1)+1) = start+(n+2)+1 by dsimp [n]; omega,
      h3, show start+(n+2) = start+(n+1)+1 by omega, h2,
      show start+(n+1) = start+n+1 by omega, h1, prev, black_cycle]

private theorem finish_reset (b : Bool) (s : Pair) :
    advance b (advance false (advance true (advance false s))) = (true, !b) := by
  obtain ⟨a,c⟩ := s
  cases a <;> cases c <;> cases b <;> rfl

/-- After reading 0, 3m+1 black cells, 0 and a free symbol, the pair is
independent of its entrance state. The free symbol is read at depth base+3m+4. -/
theorem reset_closes (P O : Row) (base m : Nat)
    (h : ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n))
    (a : O (base+1) = false)
    (bs : ∀ i, i < 3*m+1 → O (base+2+i) = true)
    (c : O (base+3*m+3) = false) :
    pair P (base+3*m+4) = (true, !(O (base+3*m+4))) := by
  have run := black_run (pair P) (base+1) m (by
    intro i hi
    rw [h _ (by omega), show base+1+i+1 = base+2+i by omega, bs i hi])
  have last := h (base+3*m+3) (by omega)
  rw [last, h (base+3*m+2) (by omega), c,
    show base+3*m+2 = base+1+(3*m+1) by omega, run, h base (by omega), a, finish_reset]

/-- A word placed with its low bit at physical depth e, white outside. -/
def reference (e v x : Nat) : Bool := if x ≤ e then v.testBit (e-x) else false

/-- The cell rule inverted at physical depth n+1. -/
def Drives (O P : Row) (base : Nat) : Prop :=
  ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n)

theorem physical_drives (P : Row) (t : Nat) :
    Drives (zrow P (t+1)) (zrow P t) 0 := by
  intro n _
  exact Prod.ext rfl (zrow_inv P t n)

/-- The previous phase is a valid reference parent on the available band and
the white exterior. This does not require that the actual seed's earlier band
was already recurrent. -/
theorem reference_drives (w u e base : Nat) (he : 0 < e) (hw : e ≤ base+w) :
    Drives (reference e (bandStep w u)) (reference (e-1) u) base := by
  intro n hn
  refine Prod.ext rfl ?_
  change reference (e-1) u (n+2) = xor (reference e (bandStep w u) (n+1))
    (reference (e-1) u (n+1) || reference (e-1) u n)
  by_cases h0 : e ≤ n
  · simp [reference, show ¬ n+1 ≤ e by omega, show ¬ n+2 ≤ e-1 by omega,
      show ¬ n+1 ≤ e-1 by omega, show ¬ n ≤ e-1 by omega]
  by_cases h1 : e = n+1
  · subst e
    simp [reference, show ¬ n+2 ≤ n by omega, show ¬ n+1 ≤ n by omega, stepK_bit_zero (by omega : 0 < w)]
  by_cases h2 : e = n+2
  · subst e
    simp [reference, stepK_bit_one (by omega : 1 < w)]
  let j := e-(n+3)
  have hj : j+2 < w := by dsimp [j]; omega
  simp only [reference, ite_eq_left (show n+2 ≤ e-1 by omega), ite_eq_left (show n+1 ≤ e by omega),
    ite_eq_left (show n+1 ≤ e-1 by omega), ite_eq_left (show n ≤ e-1 by omega)]
  rw [show e-1-(n+2) = j by dsimp [j]; omega, show e-(n+1) = j+2 by dsimp [j]; omega,
    show e-1-(n+1) = j+1 by dsimp [j]; omega, show e-1-n = j+2 by dsimp [j]; omega,
    stepK_bit_step hj]
  cases u.testBit j <;> cases (u.testBit (j+1) || u.testBit (j+2)) <;> rfl


/-- The actual edge is black even if no bits remain available to the next
scan. Agreement covers every exterior cell, including an infinite tail. -/
def Matches (P : Row) (e v available : Nat) : Prop :=
  P e = true ∧ ∀ x, e < x+available → P x = reference e v x

theorem firstReset_spec {v available j : Nat} (h : firstReset v available = some j) :
    ∃ m, j+3*m+4 ≤ available ∧ resetAt v j m = true := by
  unfold firstReset at h
  have hh := List.find?_some h
  obtain ⟨m, _, hm⟩ := List.any_eq_true.mp hh
  exact ⟨m, of_decide_eq_true (Bool.and_eq_true_iff.mp hm).1, (Bool.and_eq_true_iff.mp hm).2⟩

/-- Common output from base+1 onwards propagates agreement of an inverse
pair at cut to the whole exterior. -/
private theorem agree_after {O P Q : Row} {base cut : Nat}
    (hp : Drives O P base) (hq : Drives O Q base) (hc : base ≤ cut)
    (eq : pair P cut = pair Q cut) : ∀ x, cut ≤ x → P x = Q x := by
  intro x hx
  obtain ⟨i,rfl⟩ := Nat.exists_eq_add_of_le hx
  suffices z : pair P (cut+i) = pair Q (cut+i) by exact congrArg Prod.fst z
  clear hx
  induction i with
  | zero => exact eq
  | succ i ih => rw [← Nat.add_assoc, hp _ (by omega), hq _ (by omega), ih]

/-- One successful cut of `firstReset`'s actual search fixes the next band and the
previous physical edge, including the cut j=0. -/
theorem scheduled_layer {P O : Row} {w u e available j : Nat}
    (full : available ≤ e) (width : available ≤ w)
    (drive : Drives O P 0)
    (matchOut : Matches O e (bandStep w u) available)
    (cut : firstReset (bandStep w u) available = some j) :
    Matches P (e-1) u j := by
  obtain ⟨m, bound, reset⟩ := firstReset_spec cut
  let v := bandStep w u
  let b := e-(j+3*m+4)
  have eb : e = b+j+3*m+4 := by dsimp [b]; omega
  let D := reference e v
  let Q := reference (e-1) u
  have dp : Drives D P b := by
    intro n hn
    dsimp [D, v]
    rw [← matchOut.2 (n+1) (by omega)]
    exact drive n (Nat.zero_le _)
  have dq : Drives D Q b := reference_drives w u e b (by omega) (by omega)
  obtain ⟨zeros, ones⟩ := Bool.and_eq_true_iff.mp reset
  obtain ⟨z1,z2⟩ := Bool.and_eq_true_iff.mp zeros
  have low : v.testBit (j+1) = false := by simpa using z1
  have high : v.testBit (j+3*m+3) = false := by simpa using z2
  have deep : D (b+1) = false := by
    simpa [D, reference, show b+1 ≤ e by omega, show e-(b+1) = j+3*m+3 by omega] using high
  have shallow : D (b+3*m+3) = false := by
    simpa [D, reference, show b+3*m+3 ≤ e by omega, show e-(b+3*m+3) = j+1 by omega] using low
  have run (i) (hi : i < 3*m+1) : D (b+2+i) = true := by
    have h := List.all_eq_true.mp ones (3*m-i) (List.mem_range.mpr (by omega))
    simpa [D, reference, show b+2+i ≤ e by omega,
      show e-(b+2+i) = j+2+(3*m-i) by omega] using h
  have same := (reset_closes P D b m dp deep run shallow).trans
    (reset_closes Q D b m dq deep run shallow).symm
  have tail := agree_after dp dq (by omega) same
  have exterior (x) (hx : e ≤ x) : P x = false := by
    rw [tail x (by omega)]
    simp [Q, reference, show ¬ x ≤ e-1 by omega]
  constructor
  · have h := congrArg Prod.snd (drive (e-1) (Nat.zero_le _))
    have he : e-1+1 = e := by omega
    change P (e-1+1+1) = xor (O (e-1+1)) (P (e-1+1) || P (e-1)) at h
    rw [he, matchOut.1, exterior e (by omega), exterior (e+1) (by omega)] at h
    cases hbit : P (e-1) <;> simp [hbit] at h ⊢
  · intro x hx
    exact tail x (by omega)


/-- Phase of the reference strip d inverse ticks from v. -/
def earlier (w v q d : Nat) := bandAt w v ((q - d%q)%q)

theorem earlier_step {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v) (d : Nat) :
    bandStep w (earlier w v q (d+1)) = earlier w v q d := by
  let r := d%q
  have hr : r < q := Nat.mod_lt _ hq
  have succmod : (d+1)%q = (r+1)%q := Nat.mod_add_mod .. |>.symm
  unfold earlier
  rw [succmod]
  change bandStep w (bandAt w v ((q-(r+1)%q)%q)) = bandAt w v ((q-r)%q)
  by_cases last : r+1 = q
  · rw [last]
    simp only [Nat.mod_self, Nat.sub_zero, rowAt]
    rw [show q-r = 1 by omega]
    by_cases one : q = 1
    · rw [one] at cycle ⊢
      simpa [rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : 1 < q)]
      rfl
  · rw [Nat.mod_eq_of_lt (by omega : r+1 < q), Nat.mod_eq_of_lt (by omega : q-(r+1) < q)]
    change bandAt w v (q-(r+1)+1) = _
    rw [show q-(r+1)+1 = q-r by omega]
    by_cases zero : r = 0
    · simpa [zero, rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : q-r < q)]

/-- From every physical k-tick preimage the computed schedule fixes the
edge at depth e-k and all cells beyond it. No support or trace condition is
imposed on the entrance row. -/
theorem scheduled_edge {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v)
    (fuel d a k e : Nat) (P : Row) (width : a ≤ w) (full : a ≤ e)
    (matched : Matches (zrow P k) e (earlier w v q d) a)
    (closed : k ≤ schedule w v q fuel d a) :
    zrow P 0 (e-k) = true ∧ ∀ x, e-k < x → zrow P 0 x = false := by
  induction fuel generalizing d a k e with
  | zero =>
    have hk : k = 0 := by simpa [schedule] using closed
    subst k
    exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
      (by simp [reference, show ¬ x ≤ e by omega])⟩
  | succ fuel ih =>
    cases k with
    | zero => exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
        (by simp [reference, show ¬ x ≤ e by omega])⟩
    | succ k =>
      simp only [schedule] at closed
      cases h : firstReset (earlier w v q d) a with
      | none =>
        unfold earlier at h
        simp only [h] at closed
        omega
      | some j =>
        have fj := h
        unfold earlier at h
        simp only [h] at closed
        obtain ⟨m, bound, _⟩ := firstReset_spec fj
        rw [← earlier_step hq cycle d] at fj matched
        have next := scheduled_layer full width (physical_drives P k) matched fj
        have result := ih (d+1) j k (e-1) (by omega) (by omega) next (by omega)
        simpa [show e-(k+1) = e-1-k by omega] using result

/-! ## Period-multiple invariance of `earlier`, `schedule`, and `phaseCapacity` -/

private theorem bandAt_eq_mod {w v q : Nat} (cycle : bandAt w v q = v) (x : Nat) :
    bandAt w v x = bandAt w v (x % q) := by
  have hdiv : x = x % q + (x / q) * q := by
    rw [Nat.mul_comm]; exact (Nat.mod_add_div x q).symm
  conv => lhs; rw [hdiv]
  exact rowAt_add_mul cycle (x % q) (x / q)

private theorem sub_mul_mod_eq (m q c r : Nat) (hq : 0 < q) (hc : c < m) (hr : r < q) :
    ((m * q - (r + q * c)) % (m * q)) % q = ((q - r) % q) % q := by
  have hqc : q * c = c * q := Nat.mul_comm q c
  by_cases hr0 : r = 0
  · subst hr0
    by_cases hc0 : c = 0
    · subst hc0
      simp
    · have hm_split : m * q = (m - c) * q + c * q := by
        rw [← Nat.add_mul, show m - c + c = m by omega]
      have hsub : m * q - (0 + q * c) = (m - c) * q := by omega
      have hlt_mq : (m - c) * q < m * q := (Nat.mul_lt_mul_right hq).mpr (by omega)
      rw [hsub, Nat.mod_eq_of_lt hlt_mq, Nat.mul_mod_left, Nat.sub_zero, Nat.mod_self, Nat.zero_mod]
  · have hm_split : m * q = (m - 1 - c) * q + q + c * q := by
      conv => lhs; rw [show m = (m - 1 - c) + 1 + c by omega, Nat.add_mul, Nat.add_mul, Nat.one_mul]
    have hsub : m * q - (r + q * c) = (q - r) + (m - 1 - c) * q := by omega
    have hlt_mq : (q - r) + (m - 1 - c) * q < m * q := by
      have hle : (m - 1 - c) * q ≤ (m - 1 - c) * q + c * q := Nat.le_add_right _ _
      omega
    have hqr_lt : q - r < q := by omega
    rw [hsub, Nat.mod_eq_of_lt hlt_mq, Nat.add_mul_mod_self_right,
      Nat.mod_eq_of_lt hqr_lt, Nat.mod_eq_of_lt hqr_lt]

private theorem phase_mod_mul_eq {m q : Nat} (hm : 0 < m) (hq : 0 < q) (d : Nat) :
    ((m * q - d % (m * q)) % (m * q)) % q = ((q - d % q) % q) % q := by
  have hmq : 0 < m * q := Nat.mul_pos hm hq
  have hrem_lt : d % (m * q) < m * q := Nat.mod_lt d hmq
  have hd_mod : d % q = (d % (m * q)) % q :=
    (Nat.mod_mod_of_dvd d ⟨m, Nat.mul_comm m q⟩).symm
  have hc_lt : (d % (m * q)) / q < m := by
    apply Classical.byContradiction
    intro hge
    have hbig : m * q ≤ q * ((d % (m * q)) / q) := by
      rw [Nat.mul_comm q _]
      exact Nat.mul_le_mul_right q (Nat.not_lt.mp hge)
    have hdiv := Nat.mod_add_div (d % (m * q)) q
    omega
  have hr_lt : (d % (m * q)) % q < q := Nat.mod_lt (d % (m * q)) hq
  have hdecomp : d % (m * q) = (d % (m * q)) % q + q * ((d % (m * q)) / q) :=
    (Nat.mod_add_div (d % (m * q)) q).symm
  rw [hd_mod]
  conv => lhs; rw [hdecomp]
  exact sub_mul_mod_eq m q ((d % (m * q)) / q) ((d % (m * q)) % q) hq hc_lt hr_lt

/-- **Period-Multiple Invariance of `earlier`, `schedule`, and `phaseCapacity` (`earlier_and_phaseCapacity_mul_period`):**
for any cycle period `q > 0` (`bandAt w v q = v`) and positive multiplier `m > 0`, evaluating `earlier`,
`schedule`, or `phaseCapacity` at period `m * q` is identically equal to evaluating at `q`. -/
theorem earlier_and_phaseCapacity_mul_period {w v q m : Nat}
    (hq : 0 < q) (hm : 0 < m) (cycle : bandAt w v q = v) :
    (∀ d : Nat, earlier w v (m * q) d = earlier w v q d) ∧
    (∀ fuel d avail : Nat, schedule w v (m * q) fuel d avail = schedule w v q fuel d avail) ∧
    phaseCapacity w v (m * q) = phaseCapacity w v q := by
  have hearlier : ∀ d : Nat, earlier w v (m * q) d = earlier w v q d := by
    intro d
    unfold earlier
    rw [bandAt_eq_mod cycle ((m * q - d % (m * q)) % (m * q)),
      bandAt_eq_mod cycle ((q - d % q) % q), phase_mod_mul_eq hm hq d]
  have hsched : ∀ fuel d avail : Nat,
      schedule w v (m * q) fuel d avail = schedule w v q fuel d avail := by
    intro fuel
    induction fuel with
    | zero => intros; rfl
    | succ fuel ih =>
      intro d avail
      simp only [schedule]
      change (match firstReset (earlier w v (m * q) d) avail with
        | none => 0 | some j => 1 + schedule w v (m * q) fuel (d + 1) j) =
        (match firstReset (earlier w v q d) avail with
        | none => 0 | some j => 1 + schedule w v q fuel (d + 1) j)
      rw [hearlier d]
      cases firstReset (earlier w v q d) avail with
      | none => rfl
      | some j => dsimp only; rw [ih (d + 1) j]
  exact ⟨hearlier, hsched, hsched w 0 w⟩

end Rule30Submission.Rule30EveryKCascade

/-!
# The conditional inverse-tick theorem at a uniform age

Attach the minimum over edge cycles to the physical cascade and to
finite rows at a fixed white wall. All widths and tick counts are natural numbers.
-/


namespace Rule30Submission.Rule30EveryKInverse

open Rule30EveryKStatement Rule30EveryKCascade Rule30ZeroBoundary
open Rule30ZeroBoundary.IntegerForm Rule30UniversalLeftSide

private theorem top_log {Y : Nat} (h : Y ≠ 0) : Top Y Y.log2 :=
  ⟨Nat.testBit_log2 h, fun i hi => Nat.testBit_lt_two_pow
    (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) hi))⟩

private theorem log_of_top {Y i : Nat} (h : Top Y i) : Y.log2 = i := by
  have nz : Y ≠ 0 := by intro e; simpa [e] using h.1
  have t := top_log nz
  rcases Nat.lt_trichotomy Y.log2 i with hl | he | hg
  · exact absurd h.1 (by rw [t.2 i hl]; decide)
  · exact he
  · exact absurd t.1 (by rw [h.2 _ hg]; decide)

private theorem forward_top {Y m : Nat} (h : Top Y m) : Top (F Y) (m+1) := by
  refine ⟨testBit_F_succ_of_top h.1 h.2, fun i hi => ?_⟩
  obtain ⟨j,rfl⟩ : ∃ j, i = j+1 := ⟨i-1, by omega⟩
  rw [testBit_F_succ, h.2 (j+2) (by omega), h.2 (j+1) (by omega), h.2 j (by omega)]
  rfl

private theorem orbit_top {Y : Nat} (h : Y ≠ 0) (t : Nat) :
    Top (iter F t Y) (Y.log2+t) := by
  induction t with
  | zero => exact top_log h
  | succ t ih => exact forward_top ih

private theorem band_succ (w Y : Nat) :
    topBand (w+1) Y = if w ≤ Y.log2 ∧ Y.testBit (Y.log2-w) = true
      then topBand w Y + 2^w else topBand w Y := by
  simp [topBand, List.range_succ, List.foldl_append]

theorem band_lt (w Y : Nat) : topBand w Y < 2^w := by
  induction w with
  | zero => simp [topBand]
  | succ w ih => rw [band_succ, Nat.pow_succ]; split <;> omega

theorem band_bit (w Y i : Nat) :
    (topBand w Y).testBit i = (decide (i < w ∧ i ≤ Y.log2) && Y.testBit (Y.log2-i)) := by
  induction w with
  | zero => simp [topBand]
  | succ w ih =>
    rw [band_succ]
    split <;> rename_i h
    · rw [← Nat.or_two_pow_eq_add_of_lt (band_lt w Y), Nat.testBit_or, Nat.testBit_two_pow, ih]
      by_cases eq : i = w
      · subst i; simp [h]
      · simp [Ne.symm eq, show (i < w+1) = (i < w) by apply propext; omega]
    · by_cases eq : i = w
      · subst i; simp [ih]; grind
      · simpa [show (i < w+1) = (i < w) by apply propext; omega] using ih

private theorem band_evolves {Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1) :
    topBand w (F Y) = bandStep w (topBand w Y) := by
  let m := Y.log2
  have top := top_log nz
  have log := log_of_top (forward_top top)
  apply Nat.eq_of_testBit_eq
  intro i
  by_cases inside : i < w
  · have fit : i ≤ m := by omega
    rw [band_bit, log]
    simp only [inside, show i ≤ Y.log2+1 by omega, and_self, decide_true, Bool.true_and]
    cases i with
    | zero =>
      rw [stepK_bit_zero (by omega), band_bit]
      simp [inside, top.1, (forward_top top).1]
    | succ i =>
      cases i with
      | zero =>
        rw [stepK_bit_one (by omega), band_bit, band_bit]
        have hm : 1 ≤ m := by omega
        let z := m-1
        have hz : m = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-1) = _
        rw [show m+1-1 = z+1 by omega, testBit_F_succ,
          top.2 (z+2) (by omega), show z+1 = Y.log2 by omega]
        simp [inside, show 0 < w by omega, show 1 ≤ Y.log2 by omega, top.1]
      | succ i =>
        rw [stepK_bit_step inside, band_bit, band_bit, band_bit]
        let z := m-(i+2)
        have idx : m+1-(i+2) = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-(i+2)) = _
        rw [idx, testBit_F_succ]
        simp [inside, show i < w by omega, show i+1 < w by omega, show i ≤ Y.log2 by omega,
          show i+1 ≤ Y.log2 by omega, show i+2 ≤ Y.log2 by omega,
          show z+2 = Y.log2-i by dsimp [z]; omega,
          show z+1 = Y.log2-(i+1) by dsimp [z]; omega, z, m]
  · have h1 := Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (band_lt w (F Y))
        (Nat.pow_le_pow_right (by decide : 0 < 2) (by omega : w ≤ i)))
    have h2 : bandStep w (topBand w Y) < 2^w := Nat.mod_lt _ (Nat.two_pow_pos _)
    rw [h1, Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le h2 (Nat.pow_le_pow_right (by decide) (by omega : w ≤ i)))]


private theorem collision (N : Nat) (a : Nat → Nat) (h : ∀ t, a t < N) :
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

private theorem orbit_add (w v i n : Nat) :
    bandAt w v (i+n) = bandAt w (bandAt w v i) n := by
  induction n with
  | zero => rfl
  | succ n ih => change bandStep w (bandAt w v (i+n)) = bandStep w (bandAt w (bandAt w v i) n); rw [ih]

private theorem push_eq {w v i j : Nat} (eq : bandAt w v i = bandAt w v j) (n : Nat) :
    bandAt w v (i+n) = bandAt w v (j+n) := by rw [orbit_add, orbit_add w v j, eq]

private theorem band_at_odd {n v : Nat} (odd : OddBand (n+1) v) (t : Nat) :
    OddBand (n+1) (bandAt (n+1) v t) := by
  induction t with
  | zero => exact odd
  | succ t ih => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _), (stepK_bit_zero (by omega) _).trans ih.2⟩

/-- A periodic odd word returns within the exact fuel used by `returnPeriod`'s search.
Dividing an odd word by two codes the 2^n words at width n+1 injectively. -/
private theorem short_return {n v q : Nat} (odd : OddBand (n+1) v) (hq : 0 < q)
    (cycle : bandAt (n+1) v q = v) :
    ∃ p, 0 < p ∧ p ≤ 2^n ∧ bandAt (n+1) v p = v := by
  let a := bandAt (n+1) v
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^n) (fun t => a t / 2) (by
    intro t
    have h := (band_at_odd odd t).1
    rw [Nat.pow_succ] at h
    dsimp [a]; omega)
  have parity (t) : a t % 2 = 1 := by simpa [a, Nat.testBit_zero] using (band_at_odd odd t).2
  have same : a i = a j := by have := parity i; have := parity j; omega
  let b := (i+1)*q
  have le : i ≤ b := Nat.le_trans (by omega : i ≤ i+1) (Nat.le_mul_of_pos_right _ hq)
  have translated := push_eq same (b-i)
  have ix : i+(b-i) = 0+(i+1)*q := by dsimp [b]; omega
  have jx : j+(b-i) = (j-i)+(i+1)*q := by dsimp [b] at *; omega
  rw [ix, jx] at translated
  unfold bandAt at translated
  rw [rowAt_add_mul cycle, rowAt_add_mul cycle] at translated
  exact ⟨j-i,by omega,by omega,translated.symm⟩

private theorem walk_finds (w v fuel elapsed : Nat)
    (h : ∃ p, elapsed < p ∧ p ≤ elapsed+fuel ∧ bandAt w v p = v) :
    ∃ q, returnPeriod.walk w v fuel (bandAt w v elapsed) elapsed = some q ∧
      0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing elapsed with
  | zero => obtain ⟨_,_,_,_⟩ := h; omega
  | succ fuel ih =>
    rw [returnPeriod.walk]
    split <;> rename_i eq
    · exact ⟨elapsed+1,rfl,by omega,eq⟩
    · apply ih (elapsed+1)
      obtain ⟨p,lo,hi,hp⟩ := h
      have ne : p ≠ elapsed+1 := by rintro rfl; exact eq hp
      exact ⟨p,by omega,by omega,hp⟩


private theorem fold_bound (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    (xs : List Nat) (b : Nat) : xs.foldl step b ≤ b := by
  induction xs generalizing b with
  | nil => exact Nat.le_refl _
  | cons a xs ih => exact Nat.le_trans (ih _) (lower b a)

private theorem fold_hit (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    {i limit : Nat} (hit : ∀ a, step a i ≤ limit) (xs : List Nat) (b : Nat) (mem : i ∈ xs) :
    xs.foldl step b ≤ limit := by
  induction xs generalizing b with
  | nil => simp at mem
  | cons a xs ih =>
    rcases List.mem_cons.mp mem with rfl | hm
    · exact Nat.le_trans (fold_bound step lower xs _) (hit b)
    · exact ih _ hm

private def entry (w b i : Nat) := match returnPeriod w (2*i+1) with
  | none => b
  | some p => min b (phaseCapacity w (2*i+1) p)

private theorem entry_le (w b i : Nat) : entry w b i ≤ b := by
  unfold entry; split
  · exact Nat.le_refl _
  · exact Nat.min_le_left ..

theorem capacity_on_cycle {w v : Nat} (hw : 0 < w) (odd : OddBand w v)
    (cycle : ∃ q, 0 < q ∧ bandAt w v q = v) :
    ∃ q, 0 < q ∧ bandAt w v q = v ∧ K1 w ≤ phaseCapacity w v q := by
  obtain ⟨n,rfl⟩ : ∃ n, w = n+1 := ⟨w-1,by omega⟩
  obtain ⟨q,hq,period⟩ := cycle
  obtain ⟨p,hp,bound,ret⟩ := short_return odd hq period
  obtain ⟨q',got,pos,period'⟩ := walk_finds (n+1) v (2^n) 0 ⟨p,hp,by omega,ret⟩
  have found : returnPeriod (n+1) v = some q' := got
  have lo := odd.1
  rw [Nat.pow_succ] at lo
  have parity : v%2 = 1 := by simpa [Nat.testBit_zero] using odd.2
  have eq : 2*(v/2)+1 = v := by omega
  refine ⟨q',pos,period',fold_hit (entry (n+1)) (entry_le _) (i := v/2) ?_ _ _ ?_⟩
  · intro a; simp only [entry,eq,found]; exact Nat.min_le_right ..
  · apply List.mem_range.mpr; omega

/-- A full physical band evolves autonomously from age w-1. Finite-state
pigeonhole gives the seed-independent age in the statement. -/
theorem uniform_settling {w : Nat} (hw : 0 < w) : Settled w (settlingBound w) := by
  intro Y t nz aged
  let s := w-1
  let a (i : Nat) := topBand w (iter F (s+i) Y)
  have log (i : Nat) := log_of_top (orbit_top nz i)
  have positive (i : Nat) : iter F i Y ≠ 0 := by
    intro z; simpa [z] using (orbit_top nz i).1
  have step (i : Nat) : a (i+1) = bandStep w (a i) := by
    dsimp only [a]
    rw [← Nat.add_assoc, iter]
    exact band_evolves (w := w) (positive (s+i)) (by rw [log]; dsimp [s]; omega)
  have advanceOrbit (i n : Nat) : bandAt w (a i) n = a (i+n) := by
    induction n with
    | zero => rfl
    | succ n ih => exact (congrArg (bandStep w) ih).trans (step (i+n)).symm
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^w) a fun _ => band_lt _ _
  have st : s+2^w ≤ t := aged
  let l := t-s
  have li : i ≤ l := by dsimp [l]; omega
  have cyc := congrArg (fun x => bandAt w x (l-i)) eq
  change bandAt w (a i) (l-i) = bandAt w (a j) (l-i) at cyc
  rw [advanceOrbit, advanceOrbit, show i+(l-i) = l by omega,
    show j+(l-i) = l+(j-i) by omega] at cyc
  have tl : s+l = t := by dsimp [l]; omega
  have per : bandAt w (a l) (j-i) = a l := (advanceOrbit l _).trans cyc.symm
  dsimp only [a] at per
  rw [tl] at per
  refine ⟨by rw [log]; dsimp [s] at st; omega, ⟨band_lt _ _, ?_⟩, j-i, by omega, per⟩
  rw [band_bit]; simp [hw, Nat.testBit_log2 (positive t)]


private theorem matches_band {P : Row} {t Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1)
    (hpre : ∀ x, 1 ≤ x → zrow P t x = rowOfNat Y x) :
    Matches (zrow P t) (Y.log2+1) (topBand w Y) w := by
  constructor
  · simpa only [hpre _ (by omega : 1 ≤ Y.log2+1), rowOfNat] using (top_log nz).1
  · intro x hx
    obtain ⟨i,rfl⟩ : ∃ i, x = i+1 := ⟨x-1,by omega⟩
    rw [hpre _ (by omega)]
    change Y.testBit i = reference (Y.log2+1) (topBand w Y) (i+1)
    by_cases hi : i ≤ Y.log2
    · have idx : Y.log2+1-(i+1) = Y.log2-i := by omega
      simp [reference,hi,band_bit,idx,show Y.log2-i < w by omega,
        show Y.log2-(Y.log2-i) = i by omega]
    · rw [(top_log nz).2 i (by omega)]
      simp [reference,hi]

private theorem integer_edge {k w age Y t : Nat} {P : Row} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) (nz : Y ≠ 0) (aged : age ≤ t)
    (pre : ∀ x, 1 ≤ x → zrow P k x = rowOfNat (iter F t Y) x) :
    0 < Y.log2+t+1-k ∧ P (Y.log2+t+1-k) = true ∧ ∀ x, Y.log2+t+1-k < x → P x = false := by
  let Z := iter F t Y
  have top := orbit_top nz t
  have zn : Z ≠ 0 := by intro h; have z : Z.testBit (Y.log2+t) = true := top.1; simp [h] at z
  obtain ⟨full,odd,cycle⟩ := settled Y t nz aged
  obtain ⟨q,pos,ret,bound⟩ := capacity_on_cycle hw odd cycle
  have ma := matches_band zn full pre
  have ed := scheduled_edge pos ret w 0 w k (Z.log2+1) P (Nat.le_refl _) full
    (by simpa [earlier, rowAt] using ma) (Nat.le_trans cap bound)
  have log : Z.log2 = Y.log2+t := log_of_top top
  rw [log] at ed
  have posEdge : 1 ≤ Y.log2+t+1-k := by
    apply Classical.byContradiction
    intro h
    have z : Y.log2+t+1-k = 0 := by omega
    have bad := ed.1
    rw [z,zrow_wall] at bad
    contradiction
  exact ⟨posEdge,(zrow_zero_of_pos P posEdge).symm.trans ed.1, fun x hx =>
    (zrow_zero_of_pos P (by omega : 1 ≤ x)).symm.trans (ed.2 x hx)⟩

private theorem physical_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : PhysicalEdge k age := by
  intro L m t hm edge finite aged P pre
  let Y := natOfRow L m
  have top : Top Y (m-1) := by
    constructor
    · simpa [Y,testBit_natOfRow,show m-1 < m by omega,show m-1+1=m by omega] using edge
    · intro i hi; simp [Y,testBit_natOfRow,show ¬ i<m by omega]
  have nz : Y ≠ 0 := by intro z; simpa [z] using top.1
  have log := log_of_top top
  have rep := rowOfNat_natOfRow finite
  have ed := integer_edge hw cap settled nz aged (P := P) (fun x hx =>
    (pre x hx).trans ((zrow_congr (fun j hj => (rep j hj).symm) t x).trans (zrow_rowOfNat Y t x)))
  simpa only [log,show m-1+t+1 = m+t by omega] using ed.2

private theorem finite_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : FinitePredecessor k age := by
  intro Y t nz aged L pre
  obtain ⟨positive,edge,tail⟩ := integer_edge hw cap settled nz aged pre
  let e := Y.log2+t+1-k
  let A := natOfRow L e
  have rep : ∀ x, 1 ≤ x → rowOfNat A x = L x := rowOfNat_natOfRow tail
  have image : iter F k A = iter F t Y := by
    apply Nat.eq_of_testBit_eq
    intro i
    exact (zrow_rowOfNat A k (i+1)).symm.trans ((zrow_congr rep k _).trans (pre _ (by omega)))
  refine ⟨A,rep,image,?_,?_⟩
  · have ha := rep e positive
    obtain ⟨i,hi⟩ : ∃ i, e = i+1 := ⟨e-1,by omega⟩
    rw [hi] at ha
    change A.testBit i = L (i+1) at ha
    have eq : Y.log2+t-k = i := by dsimp [e] at hi; omega
    rw [eq, ha, ← hi]; exact edge
  · intro i hi
    have ht : e < i+1 := by dsimp [e]; omega
    exact (rep (i+1) (by omega)).trans (tail _ ht)

/-- Build a physical history with prescribed cell-1 bits in forward order,
allowing arbitrary support until the physical edge theorem is applied. -/
private theorem history (k : Nat) (E : Row) (bits : Fin k → Bool) :
    ∃ L : Row, (∀ x, 1 ≤ x → zrow L k x = E x) ∧
      ∀ i : Fin k, zrow L i.val 1 = bits i := by
  induction k with
  | zero => exact ⟨E,fun _ => zrow_zero_of_pos E,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨P,endP,wall⟩ := ih (fun i => bits i.succ)
    let L := back (bits 0) P
    have shift (i x : Nat) : zrow L (i+1) x = zrow P i x := by
      rw [Nat.add_comm i 1,zrow_shift]
      exact zrow_congr (zrow_back (bits 0) P) i x
    refine ⟨L,fun x hx => (shift k x).trans (endP x hx),?_⟩
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · rfl
    · exact (shift j.val 1).trans (wall j)

theorem capacity_at_settling_age : CapacityAtSettlingAge := by
  intro k w age hw cap settled
  have finite := finite_clause hw cap settled
  refine ⟨physical_clause hw cap settled,finite,?_⟩
  intro Y t nz aged bits
  obtain ⟨L,pre,trace⟩ := history k (rowOfNat (iter F t Y)) bits
  obtain ⟨A,rep,image,top⟩ := finite Y t nz aged L pre
  exact ⟨A,image,top,fun i => (zrow_rowOfNat A i.val 1).symm.trans
    ((zrow_congr rep i.val 1).trans (trace i))⟩

theorem conditional_every_k : ConditionalEveryK := by
  intro capacity k
  have spec : 0 < widthFor capacity k ∧ k ≤ K1 (widthFor capacity k) := by
    unfold widthFor
    dsimp only
    cases h : (List.range (capacity k).choose).find? (fun w => decide (0 < w ∧ k ≤ K1 w)) with
    | none => exact (capacity k).choose_spec
    | some w =>
      have found := List.find?_some h
      exact of_decide_eq_true found
  exact capacity_at_settling_age k _ _ spec.1 spec.2 (uniform_settling spec.1)

end Rule30Submission.Rule30EveryKInverse

/-! Backward spatial determinism pins a periodic pair to its depth. The white
interface bound counts one temporal word per white, and applies to every
pointed recurrent strip with a black edge. -/

namespace Rule30Submission.Rule30RootedWhiteReturns
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
open Ruliology.CellularAutomata.Rule30LeftUnbounded (code code_lt code_inj pigeonhole)

abbrev Column := Nat → Bool
abbrev ProfilePair := Column × Column
private def z : Column := fun _ => false
private def sig (d : Nat → Column) : Nat → ProfilePair
  | 0 => (z,z)
  | 1 => (z,d 0)
  | n+2 => (d n,d (n+1))

private def back (v : ProfilePair) : ProfilePair :=
  (fun t => xor (v.2 (t+1)) (v.1 t || v.2 t), v.1)

private theorem back_zero : back (z,z) = (z,z) := rfl

private theorem back_sig {d : Nat → Column} (hd : Recurrence d) (i : Nat) :
    back (sig d (i+1)) = sig d i := by
  apply Prod.ext
  · funext t
    match i with
    | 0 => change xor (d 0 (t+1)) (false || d 0 t) = false
           rw [hd.1]; cases d 0 t <;> rfl
    | 1 => change xor (d 1 (t+1)) (d 0 t || d 1 t) = false
           rw [hd.2.1]; cases d 0 t <;> cases d 1 t <;> rfl
    | n+2 =>
      change xor (d (n+2) (t+1)) (d (n+1) t || d (n+2) t) = d n t
      rw [hd.2.2]; cases d n t <;> cases d (n+1) t <;> cases d (n+2) t <;> rfl
  · cases i with
    | zero => rfl
    | succ i => cases i <;> rfl

private theorem sig_pos {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true) :
    ∀ n, sig d (n+1) ≠ (z,z) := by
  intro n
  induction n with
  | zero =>
    intro e
    have h := congrArg (fun v : ProfilePair => v.2 0) e
    change d 0 0 = false at h
    rw [h0] at h; contradiction
  | succ n ih =>
    intro h
    apply ih
    rw [← back_sig hd (n+1),h,back_zero]

private theorem distinct {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true) :
    ∀ i j, i<j → sig d i ≠ sig d j := by
  intro i
  induction i with
  | zero =>
    intro j hj h
    cases j with
    | zero => omega
    | succ j => exact sig_pos hd h0 j h.symm
  | succ i ih =>
    intro j hj h
    cases j with
    | zero => omega
    | succ j => exact ih j (by omega) (by rw [← back_sig hd i, ← back_sig hd j,h])

private theorem period_code {a b : Column} {p : Nat} (hp : 0<p)
    (ha : PeriodFrom a 0 p) (hb : PeriodFrom b 0 p) (hc : code a p = code b p) : a=b := by
  funext t
  have decomp : t%p + (t/p)*p = t := by simpa [Nat.mul_comm] using Nat.mod_add_div t p
  calc a t = a (t%p) := by
         simpa [decomp] using period_mul ha (t/p) (t%p) (Nat.zero_le _)
       _ = b (t%p) := code_inj _ _ _ hc _ (Nat.mod_lt _ hp)
       _ = b t := by simpa [decomp] using (period_mul hb (t/p) (t%p) (Nat.zero_le _)).symm

/-- Distinct white interfaces with a common clock have distinct preceding
words. No physical path can visit infinitely many white interfaces at this clock. -/
theorem rooted_white_count {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) (n : Nat) (atWheel : Nat → Nat)
    (ordered : ∀ i j, i<j → j<n → atWheel i < atWheel j)
    (white : ∀ i, i<n → ∀ t, d (atWheel i+1) t=false)
    (clock : ∀ i, i<n → PeriodFrom (d (atWheel i)) 0 p) : n ≤ 2^p := by
  apply pigeonhole (2^p) n (fun i => code (d (atWheel i)) p)
  · exact fun i _ => code_lt _ _
  · intro i j hi hj eqcode
    have hpair : sig d (atWheel i+2) = sig d (atWheel j+2) := by
      apply Prod.ext
      · exact period_code hp (clock i hi) (clock j hj) eqcode
      · exact funext (fun t => (white i hi t).trans (white j hj t).symm)
    by_cases lt : i<j
    · have lt' := ordered i j lt hj
      exact False.elim (distinct hd h0 _ _ (by omega) hpair)
    by_cases gt : j<i
    · have gt' := ordered j i gt hi
      exact False.elim (distinct hd h0 _ _ (by omega) hpair.symm)
    omega

private theorem two_code {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) (m : Nat) (periods : ∀ i, i≤m+1 → PeriodFrom (d i) 0 p) :
    m+1 ≤ 2^p * 2^p := by
  let num := fun i => code (d (i+1)) p + 2^p * code (d i) p
  have base : 0 < 2^p := Nat.two_pow_pos _
  apply pigeonhole (2^p*2^p) (m+1) num
  · intro i _
    have h := code_lt (d i) p
    have h' := code_lt (d (i+1)) p
    have h'' := Nat.mul_le_mul_right (2^p) (show code (d i) p + 1 ≤ 2^p by omega)
    dsimp [num]; rw [Nat.mul_comm (2^p) (code (d i) p)]; rw [Nat.add_mul,Nat.one_mul] at h''; omega
  · intro i j hi hj h
    have high := congrArg (fun v => v / 2^p) h
    have low := congrArg (fun v => v % 2^p) h
    simp [num, Nat.add_mul_div_left _ _ base, Nat.div_eq_of_lt (code_lt _ _),
          Nat.mod_eq_of_lt (code_lt _ _)] at high low
    have e : sig d (i+2) = sig d (j+2) :=
      Prod.ext (period_code hp (periods _ (by omega)) (periods _ (by omega)) high)
               (period_code hp (periods _ (by omega)) (periods _ (by omega)) low)
    by_cases lt : i<j
    · exact False.elim (distinct hd h0 _ _ (by omega) e)
    by_cases gt : j<i
    · exact False.elim (distinct hd h0 _ _ (by omega) e.symm)
    omega

/-- Every black-edged strip eventually leaves any prescribed common clock. -/
theorem escapes_clock {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) : ∃ j, j ≤ 2^p*2^p+1 ∧ ¬PeriodFrom (d j) 0 p := by
  classical
  apply Classical.byContradiction
  intro h
  have hall : ∀ i, i ≤ 2^p*2^p+1 → PeriodFrom (d i) 0 p := by
    intro i hi
    apply Classical.byContradiction
    intro bad
    exact h ⟨i,hi,bad⟩
  have hbad := two_code hd h0 hp _ hall
  omega

private theorem first_at (pred : Nat → Prop) (n : Nat) (hn : pred n) :
    ∃ m, m ≤ n ∧ pred m ∧ ∀ i, i<m → ¬pred i := by
  classical
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases e : ∃ i, i<n ∧ pred i
    · obtain ⟨i, hin, hi⟩ := e
      obtain ⟨m, hm, hp, hfirst⟩ := ih i hin hi
      exact ⟨m, by omega, hp, hfirst⟩
    · exact ⟨n, by omega, hn, fun i hi h => e ⟨i,hi,h⟩⟩

private theorem white_flip {a x : Column} {p : Nat} (ha : PeriodFrom a 0 p)
    (step : ∀ t, x (t+1) = xor (a t) (x t)) (loss : ¬PeriodFrom x 0 p) :
    ∀ t, x (t+p) = !(x t) := by
  have same : x p ≠ x 0 := by
    intro e
    apply loss
    intro t _
    induction t with
    | zero => simpa using e
    | succ t ih =>
      rw [show t+1+p=(t+p)+1 by omega, step (t+p), step t,ha t (by omega),ih (by omega)]
  intro t
  induction t with
  | zero => cases hp : x p <;> cases h : x 0 <;> simp_all
  | succ t ih =>
    rw [show t+1+p=(t+p)+1 by omega,step (t+p),step t,ha t (by omega),ih]
    cases a t <;> cases x t <;> rfl

/-- Beyond any already settled pointed prefix, the first loss of its common
clock occurs immediately after a permanently white wheel. The next column
is antiperiodic at that clock, at every tick including the marked phase. -/
theorem first_clock_loss {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (recurrent : ∀ j, ∃ q, 0<q ∧ PeriodFrom (d j) 0 q)
    {p m : Nat} (hp : 0<p) (hm : 1≤m)
    (hprefix : ∀ i, i≤m → PeriodFrom (d i) 0 p) :
    ∃ j, m≤j ∧ j+1 ≤ 2^p*2^p+1 ∧
      (∀ i, i≤j → PeriodFrom (d i) 0 p) ∧
      (∀ t, d j t=false) ∧ (∀ t, d (j+1) (t+p) = !(d (j+1) t)) := by
  classical
  obtain ⟨n, hn, bad⟩ := escapes_clock hd h0 hp
  obtain ⟨k, hkn, hk, first⟩ := first_at (fun i => ¬PeriodFrom (d i) 0 p) n bad
  have good : ∀ i, i<k → PeriodFrom (d i) 0 p := fun i hi => Classical.not_not.mp (first i hi)
  have hmk : m<k := by
    by_cases h : k≤m
    · exact False.elim (hk (hprefix k h))
    · omega
  obtain ⟨i, rfl⟩ : ∃ i, k=i+2 := ⟨k-2, by omega⟩
  have white : ∀ t, d (i+1) t=false := by
    intro t
    cases h : d (i+1) t with
    | false => rfl
    | true =>
      obtain ⟨q,hq,hperiod⟩ := recurrent (i+2)
      exact False.elim (hk (reset_inherits (hd.2.2 i) (good i (by omega))
        (good (i+1) (by omega)) hperiod hq (Nat.zero_le t) h))
  refine ⟨i+1,by omega,by omega,fun j hj => good j (by omega),white,?_⟩
  apply white_flip (good i (by omega)) _ hk
  intro t
  simpa only [white,Bool.false_or] using hd.2.2 i t

/-- A white wheel and a black wheel two places deeper occur beyond any cutoff.
The common-prefix clock hypothesis is satisfied by the pointed cycle systems. -/
theorem unbounded_anchors {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (clocks : ∀ m, ∃ p, 0<p ∧ ∀ i, i≤m → PeriodFrom (d i) 0 p) (lo : Nat) :
    ∃ j, lo≤j ∧ (∀ t, d j t=false) ∧ (∀ t, d (j+2) t=true) := by
  have recurrent : ∀ j, ∃ p, 0<p ∧ PeriodFrom (d j) 0 p := by
    intro j
    obtain ⟨p,hp,h⟩ := clocks j
    exact ⟨p,hp,h j (by omega)⟩
  obtain ⟨p,hp,hprefix⟩ := clocks (lo+1)
  obtain ⟨j,hj,_,_,hw,anti⟩ := first_clock_loss hd h0 recurrent hp (by omega : 1≤lo+1) hprefix
  have blackTick : ∃ t, d (j+1) t=true := by
    cases h : d (j+1) 0 with
    | true => exact ⟨0,h⟩
    | false => exact ⟨0+p,by rw [anti 0,h]; rfl⟩
  obtain ⟨t,ht⟩ := blackTick
  have latch : ∀ k, d (j+2) (t+1+k)=true := by
    intro k
    induction k with
    | zero => simp [hd.2.2,hw,ht]
    | succ k ih =>
      rw [show t+1+(k+1)=(t+1+k)+1 by omega,hd.2.2,hw,ih]; simp
  obtain ⟨q,hq,hper⟩ := recurrent (j+2)
  refine ⟨j,by omega,hw,?_⟩
  intro u
  have le : t+1 ≤ (t+1)*q := by
    simpa using Nat.mul_le_mul_left (t+1) (show 1≤q by omega)
  have e := latch (u+(t+1)*q-(t+1))
  rw [show t+1+(u+(t+1)*q-(t+1))=u+(t+1)*q by omega, period_mul hper _ u (by omega)] at e
  exact e

end Rule30Submission.Rule30RootedWhiteReturns

/-! Three temporal bits of two adjacent wheels, followed by two bit masks
recording open runs of lengths one and two modulo three at the three ticks.
Bit zero is the earliest tick. -/

namespace Rule30Submission.Rule30ThreePhaseReturn
abbrev C := BitVec 3
structure State where
  prev : C
  cur : C
  one : C
  two : C
  deriving DecidableEq, Repr

def start (x : C) : State := ⟨x,7,~~~x,x⟩

def step (z : State) (c : C) : Option State :=
  if ((c >>> 1) &&& 3) != ((z.prev ^^^ (z.cur ||| c)) &&& 3) then none
  else if (z.one &&& ~~~c) != 0 then none
  else some ⟨z.cur,c,c &&& ~~~(z.one ||| z.two),c &&& z.one⟩

def scan (z : State) : List C → Option State
  | [] => some z
  | c::cs => (step z c).bind (fun w => scan w cs)

private def states : List State := [
  ⟨0,2,2,0⟩,
  ⟨0,5,5,0⟩,
  ⟨0,7,7,0⟩,
  ⟨1,4,4,0⟩,
  ⟨1,5,5,0⟩,
  ⟨1,7,6,1⟩,
  ⟨2,7,5,2⟩,
  ⟨3,0,0,0⟩,
  ⟨3,1,0,0⟩,
  ⟨3,7,4,3⟩,
  ⟨4,6,2,4⟩,
  ⟨4,7,3,4⟩,
  ⟨5,7,2,5⟩,
  ⟨6,7,1,2⟩,
  ⟨6,7,1,6⟩,
  ⟨7,0,0,0⟩,
  ⟨7,1,0,0⟩,
  ⟨7,3,0,1⟩,
  ⟨7,7,0,3⟩,
  ⟨7,7,0,7⟩]

private theorem starts : ∀ x : C, start x ∈ states := by decide +kernel

private theorem stable : ∀ z ∈ states, ∀ c : C,
    (step z c).all (fun w => decide (w ∈ states)) = true := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem zero_trap : ∀ z ∈ states, ∀ a b c : C, scan z [0,a,b,c] = none := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem trap_after (xs : List C) (z : State) (hz : z ∈ states) (a b c : C) :
    scan z (xs ++ [0,a,b,c]) = none := by
  induction xs generalizing z with
  | nil => exact zero_trap z hz a b c
  | cons x xs ih =>
    simp only [List.cons_append,scan]
    cases he : step z x with
    | none => rfl
    | some w =>
      have h := stable z hz x
      simp [he] at h
      exact ih w h

/-- No reset-free recurrence path in three simultaneous phases from the first
white/black anchor can pass a second white column and three more wheels. -/
theorem three_phase_return (x : C) (between : List C) (a b c : C) :
    scan (start x) (between ++ [0,a,b,c]) = none :=
  trap_after between _ (starts x) a b c

end Rule30Submission.Rule30ThreePhaseReturn

/-! Least prefix clocks and unbounded resets in three successive phases of a pointed strip. -/

namespace Rule30Submission.Rule30RecurrentStrip
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
open Rule30Submission.Rule30RootedWhiteReturns

def Clock (d : Nat → Column) (m p : Nat) := ∀ i, i ≤ m → PeriodFrom (d i) 0 p

private theorem divides_clock {d m p q} (hp : 0 < p) (h : Clock d m p)
    (least : ∀ r, 0 < r → Clock d m r → p ≤ r) (other : Clock d m q) : p ∣ q := by
  apply Nat.dvd_of_mod_eq_zero
  by_cases hz : q%p = 0
  · exact hz
  have hr : Clock d m (q%p) := by
    intro i hi t ht
    have e := period_mul (h i hi) (q/p) (t + q%p) (by omega)
    have split : q%p + q/p*p = q := by simpa [Nat.mul_comm] using Nat.mod_add_div q p
    rw [Nat.add_assoc, split] at e
    exact e.symm.trans (other i hi t ht)
  have := least (q%p) (by omega) hr
  have := Nat.mod_lt q hp
  omega

/-- The least positive common period through each wheel is a power of two. -/
theorem dyadic_prefix_clock {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true)
    (recurrent : ∀ i, ∃ q, 0 < q ∧ PeriodFrom (d i) 0 q) (m : Nat) :
    ∃ e, Clock d m (2^e) ∧ ∀ q, 0 < q → Clock d m q → 2^e ≤ q := by
  have edge (t : Nat) : d 0 t = true := by
    induction t with
    | zero => exact h0
    | succ t ih => exact (hd.1 t).trans ih
  have front (t : Nat) : d 1 t = true := by
    obtain ⟨q,hq,per⟩ := recurrent 1
    obtain ⟨u, hu⟩ : ∃ u, t+q=u+1 := ⟨t+q-1, by omega⟩
    rw [← per t (by omega), hu, hd.2.1, edge, Bool.true_or]
  induction m with
  | zero =>
    refine ⟨0, ?_, fun _ hq _ => hq⟩
    intro i hi t _
    have h : i=0 := by omega
    simp [h, edge]
  | succ m ih =>
    by_cases hm : m=0
    · subst m
      refine ⟨0, ?_, fun _ hq _ => hq⟩
      intro i hi t _
      rcases (show i = 0 ∨ i = 1 by omega) with rfl | rfl <;> simp [edge, front]
    obtain ⟨e, cp, least⟩ := ih
    let p := 2^e
    have hp : 0 < p := Nat.two_pow_pos _
    by_cases inherit : PeriodFrom (d (m+1)) 0 p
    · refine ⟨e, ?_, fun q hq cq => least q hq (fun i hi => cq i (by omega))⟩
      intro i hi
      by_cases h : i=m+1
      · exact h ▸ inherit
      · exact cp i (by omega)
    obtain ⟨j,hmj,_,cj,_,anti⟩ := first_clock_loss hd h0 recurrent hp (by omega : 1≤m) cp
    have hj : j=m := by
      by_cases hu : m+1≤j
      · exact (inherit (cj _ hu)).elim
      · omega
    subst j
    refine ⟨e+1, ?_, ?_⟩
    · intro i hi t ht
      change d i (t + 2^(e+1)) = d i t
      rw [Nat.pow_succ, ← show p = 2^e from rfl, show t+p*2=t+p+p by omega]
      by_cases last : i=m+1
      · simp [last, anti]
      · rw [cp i (by omega) (t+p) (by omega), cp i (by omega) t ht]
    · intro q hq cq
      have dq := divides_clock hp cp least (fun i hi => cq i (by omega))
      obtain ⟨k,hk⟩ := dq
      have hne : q ≠ p := by
        rintro rfl
        exact inherit (cq _ (by omega))
      have hk2 : 2 ≤ k := by
        by_cases k0 : k=0
        · simp [k0] at hk; omega
        by_cases k1 : k=1
        · simp [k1] at hk; contradiction
        omega
      rw [Nat.pow_succ, hk]
      exact Nat.mul_le_mul_left p hk2

open Rule30Submission.Rule30ThreePhaseReturn

/-- A closed run at a single tick, including both white endpoints. -/
def Reset (r : Nat → Bool) (j n : Nat) : Prop :=
  n % 3 = 1 ∧ r j = false ∧ (∀ k, k < n → r (j+1+k) = true) ∧ r (j+1+n) = false

private def trailing (r : Nat → Bool) : Nat → Nat
  | 0 => 0
  | i+1 => if r (i+1) then trailing r i + 1 else 0

private theorem trailing_spec (r : Nat → Bool) (hw : r 0 = false) (i : Nat) :
    ∃ j, j + trailing r i = i ∧ r j = false ∧
      ∀ k, k < trailing r i → r (j+1+k) = true := by
  induction i with
  | zero => exact ⟨0,rfl,hw,fun k h => by simp [trailing] at h⟩
  | succ i ih =>
    obtain ⟨j,hj,hz,hb⟩ := ih
    cases h : r (i+1) with
    | false => exact ⟨i+1,by simp [trailing,h],h,fun k hk => by simp [trailing,h] at hk⟩
    | true =>
      simp only [trailing,h, ↓reduceIte]
      refine ⟨j, by omega, hz, ?_⟩
      intro k hk
      by_cases lt : k < trailing r i
      · exact hb k lt
      · rwa [show j+1+k=i+1 by omega]

private def pack (a b c : Bool) : C := BitVec.ofBool c ++ BitVec.ofBool b ++ BitVec.ofBool a
private def bits (f : Nat → Bool) := pack (f 0) (f 1) (f 2)

private theorem read_pack : ∀ a b c : Bool,
    (pack a b c).getLsbD 0 = a ∧ (pack a b c).getLsbD 1 = b ∧ (pack a b c).getLsbD 2 = c := by
  decide +kernel

private theorem read_bits (f : Nat → Bool) (i : Fin 3) : (bits f).getLsbD i.val = f i.val := by
  obtain ⟨a,b,c⟩ := read_pack (f 0) (f 1) (f 2)
  rcases (show i.val=0 ∨ i.val=1 ∨ i.val=2 by omega) with h|h|h <;> simp only [h,bits] <;> assumption

private theorem eq_bits : ∀ a b : C,
    (∀ i : Fin 3, a.getLsbD i.val = b.getLsbD i.val) → a = b := by decide +kernel

private theorem guard_clock : ∀ a b c : C,
    c.getLsbD 1 = xor (a.getLsbD 0) (b.getLsbD 0 || c.getLsbD 0) →
    c.getLsbD 2 = xor (a.getLsbD 1) (b.getLsbD 1 || c.getLsbD 1) →
    (c >>> 1) &&& 3 = (a ^^^ (b ||| c)) &&& 3 := by decide +kernel

private def col (r : Nat → Nat → Bool) (i : Nat) := bits (fun t => r t i)
private def mask (r : Nat → Nat → Bool) (i k : Nat) := bits (fun t => decide (trailing (r t) i % 3 = k))
private def state (r : Nat → Nat → Bool) (u : Nat) : State :=
  ⟨col r (u+1), col r (u+2), mask r (u+2) 1, mask r (u+2) 2⟩

private theorem state_start (r : Nat → Nat → Bool) (h : ∀ t, r t 2 = true) :
    state r 0 = start (col r 1) := by
  have startBits (t : Nat) : trailing (r t) 2 = (if r t 1 then 2 else 1) := by
    cases e : r t 1 <;> simp [trailing,h,e]
  simp only [state,start,State.mk.injEq,true_and]
  refine ⟨eq_bits _ _ (fun i => ?_), eq_bits _ _ (fun i => ?_), eq_bits _ _ (fun i => ?_)⟩
  · rw [col,read_bits,h]
    rcases (show i.val=0 ∨ i.val=1 ∨ i.val=2 by omega) with h|h|h <;> rw [h] <;> rfl
  · simp only [mask,col,read_bits,BitVec.getLsbD_not, i.isLt, decide_true, Bool.true_and, startBits]
    cases r i.val 1 <;> decide
  · simp only [mask,col,read_bits,startBits]
    cases r i.val 1 <;> decide

private theorem state_step (r : Nat → Nat → Bool) (hw : ∀ t, r t 0 = false)
    (law : ∀ t j, r (t+1) (j+2) = xor (r t j) (r t (j+1) || r t (j+2)))
    (safe : ∀ t, t < 3 → ∀ j n, ¬ Reset (r t) j n) (u : Nat) :
    step (state r u) (col r (u+3)) = some (state r (u+1)) := by
  have clk := guard_clock (col r (u+1)) (col r (u+2)) (col r (u+3))
  have bit (i k : Nat) (h : k<3) : (col r i).getLsbD k = r k i := read_bits _ ⟨k,h⟩
  have hclk := clk (by simpa only [bit _ _ (by decide : 0<3),bit _ _ (by decide : 1<3)] using law 0 (u+1))
    (by simpa only [bit _ _ (by decide : 1<3),bit _ _ (by decide : 2<3)] using law 1 (u+1))
  have hsafe (i : Fin 3) (ho : trailing (r i.val) (u+2) % 3 = 1) : r i.val (u+3) = true := by
    cases hc : r i.val (u+3) with
    | true => rfl
    | false =>
      obtain ⟨j,hj,hz,hb⟩ := trailing_spec _ (hw _) (u+2)
      exact (safe _ i.isLt j _ ⟨ho,hz,hb, by rwa [show j+1+trailing (r i.val) (u+2)=u+3 by omega]⟩).elim
  have noClose : mask r (u+2) 1 &&& ~~~(col r (u+3)) = 0 := by
    apply eq_bits
    intro i
    simp only [mask,col,BitVec.getLsbD_and,BitVec.getLsbD_not,read_bits,i.isLt,decide_true,Bool.true_and]
    by_cases ho : trailing (r i.val) (u+2)%3=1
    · simp [ho,hsafe i ho]
    · simp [ho]
  have extend (i : Fin 3) : trailing (r i.val) (u+3) =
      (if r i.val (u+3) then trailing (r i.val) (u+2) + 1 else 0) := rfl
  simp only [step,state,hclk,noClose]
  simp [State.mk.injEq,Nat.add_assoc]
  constructor <;> apply eq_bits <;> intro i <;>
    simp only [mask,col,BitVec.getLsbD_and,BitVec.getLsbD_not,BitVec.getLsbD_or,read_bits,
      i.isLt,decide_true,Bool.true_and, extend] <;>
    cases r i.val (u+3) <;> simp <;> try omega
  by_cases h1 : trailing (r i.val) (u+2)%3=1 <;>
    by_cases h2 : trailing (r i.val) (u+2)%3=2 <;> simp [h1,h2] <;> omega

private def segment (f : Nat → C) (u : Nat) : Nat → List C
  | 0 => []
  | k+1 => f u :: segment f (u+1) k

private theorem scan_segment (r : Nat → Nat → Bool)
    (ok : ∀ u, step (state r u) (col r (u+3)) = some (state r (u+1))) (u k : Nat)
    (tail : List C) : scan (state r u) (segment (col r) (u+3) k ++ tail) =
      scan (state r (u+k)) tail := by
  induction k generalizing u with
  | zero => rfl
  | succ k ih =>
    simp only [segment,List.cons_append,scan,ok,Option.bind_some]
    exact (ih (u+1)).trans (by rw [show u+1+k=u+(k+1) by omega])

private theorem beyond {d : Nat → Column} (hd : Recurrence d)
    (anchors : ∀ lo, ∃ j, lo≤j ∧ (∀ t, d j t=false) ∧ (∀ t, d (j+2) t=true)) (s lo : Nat) :
    ∃ t j n, t<3 ∧ lo≤j ∧ Reset (fun i => d i (s+t)) j n := by
  apply Classical.byContradiction
  intro missing
  obtain ⟨a,ha,white,black⟩ := anchors lo
  obtain ⟨b,hb,whiteB,_⟩ := anchors (a+3)
  let r := fun t i => d (a+i) (s+t)
  have hw (t) : r t 0=false := white _
  have hblack (t) : r t 2=true := black _
  have law (t j) : r (t+1) (j+2) = xor (r t j) (r t (j+1) || r t (j+2)) := by
    simpa [r,Nat.add_assoc] using hd.2.2 (a+j) (s+t)
  have safe (t) (ht : t<3) (j n) (hit : Reset (r t) j n) : False := by
    apply missing
    refine ⟨t,a+j,n,ht,by omega,?_⟩
    simpa [Reset,r,Nat.add_assoc] using hit
  have ok := state_step r hw law safe
  let k := b-(a+3)
  have hz : col r (k+3) = 0 := by
    apply eq_bits
    intro i
    have h : a+(k+3)=b := by dsimp [k]; omega
    rw [col,read_bits]
    simp [r,h,whiteB]
  have trap := three_phase_return (col r 1) (segment (col r) 3 k)
    (col r (k+4)) (col r (k+5)) (col r (k+6))
  rw [← state_start r hblack, ← hz, ← show 0+3=3 from rfl, scan_segment r ok, Nat.zero_add] at trap
  simp only [scan,ok,Option.bind_some] at trap
  contradiction

/-- One fixed member of any three successive ticks contains closed runs of
length one modulo three at arbitrarily great depths on the same strip. -/
theorem one_of_three_unbounded {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (clocks : ∀ m, ∃ p, 0<p ∧ Clock d m p) (s : Nat) :
    ∃ t, t<3 ∧ ∀ lo, ∃ j n, lo≤j ∧ Reset (fun i => d i (s+t)) j n := by
  classical
  apply Classical.byContradiction
  intro absent
  have cap (t) (ht : t<3) : ∃ lo, ∀ j n, lo≤j → ¬Reset (fun i => d i (s+t)) j n := by
    apply Classical.byContradiction
    intro h
    apply absent
    refine ⟨t,ht,fun lo => Classical.byContradiction fun hn => h ?_⟩
    exact ⟨lo, fun j n hj hr => hn ⟨j,n,hj,hr⟩⟩
  obtain ⟨a,ha⟩ := cap 0 (by decide)
  obtain ⟨b,hb⟩ := cap 1 (by decide)
  obtain ⟨c,hc⟩ := cap 2 (by decide)
  obtain ⟨t,j,n,ht,hj,h⟩ := beyond hd (unbounded_anchors hd h0 clocks) s (max a (max b c))
  rcases (show t=0 ∨ t=1 ∨ t=2 by omega) with rfl|rfl|rfl
  · exact ha j n (by omega) h
  · exact hb j n (by omega) h
  · exact hc j n (by omega) h

end Rule30Submission.Rule30RecurrentStrip

/-! Uniform reset depth on periodic finite bands, from unbounded closed runs on
each pointed recurrent strip. All widths count wheels starting at wheel zero. -/

namespace Rule30Submission.Rule30ResetCompactness
open Ruliology.CellularAutomata
open Rule30AgedLeftDiagonals Rule30UniversalLeftSide Rule30EveryKStatement
open Rule30Submission.Rule30RecurrentStrip (Clock Reset)

/-- The strip and clock hypotheses are those of the three-phase theorem.
Here the prescribed phase itself must have arbitrarily deep closed runs. -/
def LInfinity : Prop := ∀ (d : Nat → Nat → Bool), Recurrence d → d 0 0 = true →
  (∀ m, ∃ p, 0 < p ∧ Clock d m p) →
  ∀ s lo, ∃ j n, lo ≤ j ∧ Reset (fun i => d i s) j n

private def Often (P : Nat → Prop) := ∀ bound, ∃ i, bound ≤ i ∧ P i

private theorem split_often {P : Nat → Prop} (h : Often P) (f : Nat → Bool) :
    ∃ b, Often (fun i => P i ∧ f i = b) := by
  classical
  by_cases ht : Often (fun i => P i ∧ f i = true)
  · exact ⟨true, ht⟩
  · simp only [Often, Classical.not_forall, not_exists, not_and] at ht
    obtain ⟨u, hu⟩ := ht
    refine ⟨false, fun bound => ?_⟩
    obtain ⟨i, hi, pi⟩ := h (max bound u)
    exact ⟨i, by omega, pi, Bool.eq_false_iff.mpr (hu i (by omega) pi)⟩

private structure Pool where
  pred : Nat → Prop
  often : Often pred

private noncomputable def pools (bits : Nat → Nat → Bool) : Nat → Pool
  | 0 => ⟨fun _ => True, fun n => ⟨n, Nat.le_refl _, trivial⟩⟩
  | n+1 =>
    let p := pools bits n
    let pick := split_often p.often (fun i => bits i n)
    ⟨_, pick.choose_spec⟩

private theorem limit_prefix (bits : Nat → Nat → Bool) :
    ∃ x : Nat → Bool, ∀ n, Often (fun i => ∀ j, j < n → bits i j = x j) := by
  let x := fun n => (split_often (pools bits n).often (fun i => bits i n)).choose
  have matchBits (n i) (h : (pools bits n).pred i) : ∀ j, j < n → bits i j = x j := by
    induction n with
    | zero => intro j hj; omega
    | succ n ih =>
      change (pools bits n).pred i ∧ bits i n = x n at h
      intro j hj
      by_cases eq : j = n
      · exact eq ▸ h.2
      · exact ih h.1 j (by omega)
  exact ⟨x, fun n bound => by
    obtain ⟨i,hi,h⟩ := (pools bits n).often bound
    exact ⟨i,hi,matchBits n i h⟩⟩

private def orbit (x : Nat → Bool) : Nat → Nat → Bool
  | 0 => x
  | t+1 => fun | 0 => orbit x t 0
               | 1 => orbit x t 0 || orbit x t 1
               | j+2 => xor (orbit x t j) (orbit x t (j+1) || orbit x t (j+2))

private theorem orbit_prefix {x v w n} (hn : n ≤ w)
    (bits : ∀ j, j < n → v.testBit j = x j) (t : Nat) :
    ∀ j, j < n → (bandAt w v t).testBit j = orbit x t j := by
  induction t with
  | zero => exact bits
  | succ t ih =>
    intro j hj
    cases j with
    | zero => exact (stepK_bit_zero (by omega) _).trans (ih 0 hj)
    | succ j =>
      cases j with
      | zero => rw [bandAt, rowAt, stepK_bit_one (by omega), ih 0 (by omega), ih 1 hj]; rfl
      | succ j => rw [bandAt, rowAt, stepK_bit_step (by omega), ih j (by omega), ih (j+1) (by omega), ih (j+2) hj]; rfl

/-- At each desired cut depth there is one window containing a complete
factor for every periodic odd band of at least that width. -/
theorem uniform_factor (deep : LInfinity) (lo : Nat) :
    ∃ b, ∀ w v p, b ≤ w → OddBand w v → 0 < p → bandAt w v p = v →
      ∃ j m, lo ≤ j ∧ j + 3*m + 4 ≤ b ∧ resetAt v j m = true := by
  classical
  apply Classical.byContradiction
  intro fail
  simp only [not_exists, Classical.not_forall] at fail
  let w := fun i => (fail i).choose
  let vs := fun i => (fail i).choose_spec
  let v := fun i => (vs i).choose
  let ps := fun i => (vs i).choose_spec
  let p := fun i => (ps i).choose
  let data := fun i => (ps i).choose_spec
  have wide (i) : i ≤ w i := (data i).1
  have odd (i) : OddBand (w i) (v i) := (data i).2.1
  have pos (i) : 0 < p i := (data i).2.2.1
  have cyc (i) : bandAt (w i) (v i) (p i) = v i := (data i).2.2.2.1
  have bad := fun i => (data i).2.2.2.2
  obtain ⟨x, approx⟩ := limit_prefix (fun i j => (v i).testBit j)
  let d := fun j t => orbit x t j
  have recurrence : Recurrence d := ⟨fun _ => rfl, fun _ => rfl, fun _ _ => rfl⟩
  have edge : d 0 0 = true := by
    obtain ⟨i, _, hx⟩ := approx 1 1
    exact (hx 0 (by decide)).symm.trans (odd i).2
  have clocks (m) : ∃ q, 0 < q ∧ Clock d m q := by
    obtain ⟨i,hi,hx⟩ := approx (m+1) (m+1)
    have agree := orbit_prefix (Nat.le_trans hi (wide i)) hx
    refine ⟨p i, pos i, fun j hj t _ => ?_⟩
    change orbit x (t+p i) j = orbit x t j
    rw [← agree _ j (by omega), ← agree _ j (by omega), bandAt, rowAt_add_period (cyc i)]
  obtain ⟨a,n,ha,hn,hleft,hones,hright⟩ := deep d recurrence edge clocks 0 (lo+1)
  let m := n / 3
  have len : n = 3*m + 1 := by dsimp [m]; omega
  let j := a-1
  have start : j+1 = a := by dsimp [j]; omega
  let b := j+3*m+4
  obtain ⟨i,hi,hx⟩ := approx b b
  have bit (l) (hl : l < b) : (v i).testBit l = d l 0 := hx l hl
  have reset : resetAt (v i) j m = true := by
    simp only [resetAt, Bool.and_eq_true, Bool.not_eq_true', List.all_eq_true, List.mem_range]
    refine ⟨⟨(bit _ (by dsimp [b]; omega)).trans (start.symm ▸ hleft), ?_⟩, ?_⟩
    · rw [bit _ (by dsimp [b]; omega), show j+3*m+3 = a+1+n by omega]; exact hright
    · intro k hk
      rw [bit _ (by dsimp [b]; omega), show j+2+k = a+1+k by omega]; exact hones k (by omega)
  exact bad i j m ⟨by omega,hi,reset⟩


/-- Searching in descending depth returns a cut at least as deep as any
given witness. The predicate is fixed even as the search list shrinks. -/
private theorem descending_find (test : Nat → Bool) {j : Nat} (ok : test j = true)
    (n : Nat) (inside : j < n) :
    ∃ cut, (List.range n).reverse.find? test = some cut ∧ j ≤ cut := by
  induction n with
  | zero => omega
  | succ n ih =>
    simp only [List.range_succ, List.reverse_append, List.reverse_singleton,
      List.singleton_append, List.find?_cons]
    split <;> rename_i h
    · exact ⟨n, rfl, by omega⟩
    · exact ih (by apply Nat.lt_of_le_of_ne (by omega); intro eq; subst j; simp [h] at ok)

private theorem find_cut {v j m a : Nat} (fits : j+3*m+4 ≤ a) (reset : resetAt v j m = true) :
    ∃ cut, firstReset v a = some cut ∧ j ≤ cut := by
  apply descending_find _ _ a (by omega)
  apply List.any_eq_true.mpr
  exact ⟨m, List.mem_range.mpr (by omega), by simp [fits, reset]⟩

private theorem advance (w v t q : Nat) :
    bandAt w (bandAt w v t) q = bandAt w v (q+t) := by
  induction q with
  | zero => simp [bandAt, rowAt]
  | succ q ih => rw [Nat.succ_add]; exact congrArg (bandStep w) ih

private theorem phase_odd {w v} (odd : OddBand w v) (hw : 0 < w) (t : Nat) :
    OddBand w (bandAt w v t) := by
  induction t with
  | zero => exact odd
  | succ t ih => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _), (stepK_bit_zero hw _).trans ih.2⟩

/-- Any free entrance and any starting layer are allowed. A window for k+1
layers leaves at least the entire k-layer window after the first cut. -/
private theorem uniform_schedule (deep : LInfinity) (k : Nat) :
    ∃ u, ∀ w v p fuel d a, u ≤ a → a ≤ w → k ≤ fuel → 0 < w →
      OddBand w v → 0 < p → bandAt w v p = v → k ≤ schedule w v p fuel d a := by
  induction k with
  | zero => exact ⟨0, by intros; exact Nat.zero_le _⟩
  | succ k ih =>
    obtain ⟨u, smaller⟩ := ih
    obtain ⟨b, window⟩ := uniform_factor deep u
    refine ⟨b, ?_⟩
    intro w v p fuel d a ba aw kf hw odd hp cyc
    cases fuel with
    | zero => omega
    | succ fuel =>
      let t := (p - d%p)%p
      have returns : bandAt w (bandAt w v t) p = bandAt w v t := by
        rw [advance, Nat.add_comm p t]; exact rowAt_add_period cyc t
      obtain ⟨j,m,uj,fit,reset⟩ := window w _ p (by omega) (phase_odd odd hw t) hp returns
      obtain ⟨cut,hcut,jcut⟩ := find_cut (a := a) (by omega : j+3*m+4 ≤ a) reset
      obtain ⟨n, bound, _⟩ := Rule30EveryKCascade.firstReset_spec hcut
      have next := smaller w v p fuel (d+1) cut (by omega) (by omega) (by omega) hw odd hp cyc
      rw [schedule, hcut]
      change k+1 ≤ 1 + schedule w v p fuel (d+1) cut
      omega

private theorem walk_sound (w v fuel t q : Nat)
    (h : returnPeriod.walk w v fuel (bandAt w v t) t = some q) :
    0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing t with
  | zero => simp [returnPeriod.walk] at h
  | succ fuel ih =>
    rw [returnPeriod.walk] at h
    split at h <;> rename_i eq
    · cases h; exact ⟨by omega, eq⟩
    · exact ih (t+1) h

private theorem fold_floor (step : Nat → Nat → Nat) (xs : List Nat) {k : Nat}
    (preserves : ∀ i ∈ xs, ∀ acc, k ≤ acc → k ≤ step acc i) (acc : Nat) (h : k ≤ acc) :
    k ≤ xs.foldl step acc := by
  induction xs generalizing acc with
  | nil => exact h
  | cons i xs ih =>
    exact ih (fun j hj => preserves j (by simp [hj])) _ (preserves i (by simp) acc h)

/-- Unbounded resets in every phase of every pointed recurrent strip suffice
for the kit's worst-phase, worst-cycle capacity to reach every depth. -/
theorem cap_of_unbounded_resets (deep : LInfinity) : CAP := by
  intro k
  obtain ⟨u, bound⟩ := uniform_schedule deep k
  let n := max k u
  refine ⟨n+1, by omega, ?_⟩
  unfold K1
  apply fold_floor
  · intro i hi acc hacc
    have small := List.mem_range.mp hi
    dsimp only
    split <;> rename_i h
    · exact hacc
    · rename_i p
      obtain ⟨hp,cyc⟩ := walk_sound (n+1) (2*i+1) (2^n) 0 p h
      apply Nat.le_min.mpr
      refine ⟨hacc, bound (n+1) (2*i+1) p (n+1) 0 (n+1) (by dsimp [n]; omega)
        (by omega) (by dsimp [n]; omega) (by omega) ?_ hp cyc⟩
      constructor
      · rw [Nat.pow_succ]; omega
      · simp [Nat.testBit_zero]
  · dsimp [n]; omega

/-- With the kit's conditional every-k theorem, the same hypothesis gives the inverse-tick target for every k. -/
theorem every_k_of_unbounded_resets (deep : LInfinity) : ∀ k, ∃ age, TargetAt k age :=
  fun k => ⟨_, Rule30EveryKInverse.conditional_every_k (cap_of_unbounded_resets deep) k⟩

end Rule30Submission.Rule30ResetCompactness

/-! Windows that catch every tick, and the relaxed doubling lemma, on pointed recurrent
strips. The open reset hypothesis is confined to a first clock loss and exactly the two
white intervals starting there. -/

namespace Rule30Submission.Rule30RelaxedWindows

open Ruliology.CellularAutomata
open Rule30AgedLeftDiagonals Rule30EveryKStatement
open Rule30Submission.Rule30RecurrentStrip (Clock Reset dyadic_prefix_clock)
open Rule30Submission.Rule30RootedWhiteReturns (Column first_clock_loss unbounded_anchors)
open Rule30Submission.Rule30ResetCompactness (LInfinity cap_of_unbounded_resets)

abbrev PrefixClocks (d : Nat → Column) := ∀ m, ∃ p, 0 < p ∧ Clock d m p
def White (d : Nat → Column) (a : Nat) := ∀ t, d a t = false

/-- The least prefix clock is p = 2^e through a. The next column flips at p,
so a + 1 is the first wheel at which that clock fails. -/
structure FirstLoss (d : Nat → Column) (a e : Nat) : Prop where
  clock : Clock d a (2^e)
  least : ∀ q, 0 < q → Clock d a q → 2^e ≤ q
  white : White d a
  flip : ∀ t, d (a+1) (t+2^e) = !(d (a+1) t)

def NextWhite (d : Nat → Column) (a b : Nat) :=
  a < b ∧ White d b ∧ ∀ i, a < i → i < b → ¬ White d i

/-- Both ends of the closed run belong to the window at the same tick s. -/
def Catch (d : Nat → Column) (a c s : Nat) :=
  ∃ j n, a ≤ j ∧ j+1+n ≤ c ∧ Reset (fun i => d i s) j n

/-- A white middle wheel cannot be strictly inside the black run. Thus a
catch in the combined window occurs wholly in one of its two stretches. -/
theorem catch_split {d : Nat → Column} {a b c s : Nat} (hab : a ≤ b) (hbc : b ≤ c)
    (white : d b s = false) : Catch d a c s ↔ Catch d a b s ∨ Catch d b c s := by
  constructor
  · rintro ⟨j, n, ha, hc, reset⟩
    by_cases left : j+1+n ≤ b
    · exact Or.inl ⟨j, n, ha, left, reset⟩
    by_cases right : b ≤ j
    · exact Or.inr ⟨j, n, right, hc, reset⟩
    have black := reset.2.2.1 (b-(j+1)) (by omega)
    rw [show j+1+(b-(j+1)) = b by omega] at black
    exact absurd (white.symm.trans black) (by decide)
  · rintro (⟨j, n, ha, hb, reset⟩ | ⟨j, n, hb, hc, reset⟩)
    · exact ⟨j, n, ha, Nat.le_trans hb hbc, reset⟩
    · exact ⟨j, n, Nat.le_trans hab hb, hc, reset⟩

/-- The first relaxation of the doubling lemma, in its rooted strip form. -/
def DLMinusOne : Prop := ∀ (d : Nat → Column), Recurrence d → d 0 0 = true →
  PrefixClocks d → ∀ a e b c, FirstLoss d a e → NextWhite d a b →
    NextWhite d b c → ∀ s, Catch d a c s

theorem unbounded_first_losses {d : Nat → Column} (hd : Recurrence d)
    (h0 : d 0 0 = true) (clocks : PrefixClocks d) (lo : Nat) :
    ∃ a e, lo ≤ a ∧ FirstLoss d a e := by
  have recurrent : ∀ i, ∃ p, 0 < p ∧ PeriodFrom (d i) 0 p := by
    intro i
    obtain ⟨p, hp, hclock⟩ := clocks i
    exact ⟨p, hp, hclock i (by omega)⟩
  obtain ⟨e, clock, least⟩ := dyadic_prefix_clock hd h0 recurrent (lo+1)
  obtain ⟨a, ha, _, clockA, white, flip⟩ :=
    first_clock_loss hd h0 recurrent (Nat.two_pow_pos e) (by omega : 1 ≤ lo+1) clock
  exact ⟨a, e, by omega, clockA,
    fun q hq hclock => least q hq (fun i hi => hclock i (by omega)), white, flip⟩

theorem exists_next_white {d : Nat → Column} (hd : Recurrence d)
    (h0 : d 0 0 = true) (clocks : PrefixClocks d) (a : Nat) :
    ∃ b, NextWhite d a b := by
  obtain ⟨b, hab, white, black⟩ := unbounded_anchors hd h0 clocks (a+1)
  clear black
  change White d b at white
  classical
  induction b using Nat.strongRecOn with
  | ind b ih =>
    by_cases earlier : ∃ i, a < i ∧ i < b ∧ White d i
    · obtain ⟨i, hai, hib, hi⟩ := earlier
      exact ih i hib hai hi
    · exact ⟨b, hab, white, fun i hai hib hi => earlier ⟨i, hai, hib, hi⟩⟩

/-- The window argument only uses unbounded starts and a catch in the
prescribed phase. Window choices can depend on the strip and the cutoff. -/
theorem lInfinity_of_windows
    (windows : ∀ (d : Nat → Column), Recurrence d → d 0 0 = true → PrefixClocks d →
      ∀ lo, ∃ a c, lo ≤ a ∧ ∀ s, Catch d a c s) : LInfinity := by
  intro d hd h0 clocks s lo
  obtain ⟨a, c, ha, catches⟩ := windows d hd h0 clocks lo
  obtain ⟨j, n, hj, _, reset⟩ := catches s
  exact ⟨j, n, Nat.le_trans ha hj, reset⟩

theorem lInfinity_of_dlMinusOne (h : DLMinusOne) : LInfinity := by
  apply lInfinity_of_windows
  intro d hd h0 clocks lo
  obtain ⟨a, e, ha, loss⟩ := unbounded_first_losses hd h0 clocks lo
  obtain ⟨b, hab⟩ := exists_next_white hd h0 clocks a
  obtain ⟨c, hbc⟩ := exists_next_white hd h0 clocks b
  exact ⟨a, c, ha, h d hd h0 clocks a e b c loss hab hbc⟩

/-- The kit's explicit settling-age witness for the physical every-k target. -/
theorem everyK_of_dlMinusOne (h : DLMinusOne) :
    EveryK (fun k => settlingBound (widthFor (cap_of_unbounded_resets
      (lInfinity_of_dlMinusOne h)) k)) :=
  Rule30EveryKInverse.conditional_every_k _

end Rule30Submission.Rule30RelaxedWindows

/-!
# Hughes's two inverse theorems without the wall

For every configuration `x : Int → Bool` of the line with a leftmost black cell at `lo`, under rule 30
(`Rule30Realization.evol`):

* `predecessor_edge_from_age_eight`: if `t ≥ 8`, every predecessor of `evol x t` has its leftmost black
  cell at `lo - t + 1`, the edge of `evol x (t - 1)`.
* `two_step_predecessor_edge_from_age_twenty_four`: if `t ≥ 24`, every two-step predecessor of
  `evol x t` has its leftmost black cell at `lo - t + 2`.

Nothing is assumed of the predecessors: each is an arbitrary configuration, and each is shown to have a
leftmost black cell, at the place of the true one. No wall appears.

* `predecessor_edge_fails_at_age_seven`: the age 8 cannot be lowered. The configuration with black cells
  at `0` and `3` has, at age 7, a predecessor black on `(-∞, -9]` and on `[11, ∞)`: it has no leftmost
  black cell.

**The proof is Hughes's** (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), read on the line.
The outer cells of a configuration with a leftmost black cell move out by one and update by themselves:
the `w` cells from the edge at time `t + 1` are the kit's band map `R` of the `w` cells from the edge at
time `t` (`band_step`). So the 8 and the 20 cells from the edge are, at ages 8 and 24, among the kit's
good bands (`EdgeGood8`, `EdgeGood20`). This comes from the kit's public `top8_from_age_eight` and
`top20_from_age_twenty_four`, applied to one window through `iter_F_shiftRight`. Beside the white
wall, rows narrower than the band need a separate finite check; on the line there is always a full
band, so there is no such case. Below a good band, the inverse rule `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))`,
run outward from any two cells, ends in two white cells (`prun_reset8`, `prun_reset20`). This is the
kit's pair transducer, restated here because the kit's copy is private, with its tables checked by
`decide`. Outward from two white cells over a white image, the predecessor is white.
-/


namespace Rule30Submission.Rule30TwoSidedInverse

open Rule30Jen Rule30Realization Rule30FiniteConfigs Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm
  Rule30LateTwins Rule30AgeEightInverse Rule30AgeTwentyFourInverse

/-! ## Bands -/

/-- The `w` cells of `c` from position `f`, as a number: cell `f + j` is bit `w - 1 - j`. -/
def band (c : Int → Bool) (f : Int) : Nat → Nat
  | 0 => 0
  | w + 1 => 2 * band c f w + (if c (f + w) then 1 else 0)

theorem band_lt (c : Int → Bool) (f : Int) : ∀ w, band c f w < 2 ^ w
  | 0 => by simp [band]
  | w + 1 => by
    have := band_lt c f w
    simp only [band, Nat.pow_succ]
    split <;> omega

theorem testBit_band_ge (c : Int → Bool) (f : Int) (w i : Nat) (h : w ≤ i) :
    (band c f w).testBit i = false :=
  Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (band_lt c f w) (Nat.pow_le_pow_right (by decide) h))

theorem testBit_band_lt (c : Int → Bool) (f : Int) : ∀ (w i : Nat), i < w →
    (band c f w).testBit i = c (f + (w : Int) - 1 - (i : Int))
  | 0, i, h => absurd h (by omega)
  | w + 1, 0, _ => by
    rw [show f + ((w + 1 : Nat) : Int) - 1 - ((0 : Nat) : Int) = f + (w : Int) by push_cast; omega]
    simp only [band, Nat.testBit_zero]
    cases hc : c (f + (w : Int))
    · exact decide_eq_false (by simp)
    · exact decide_eq_true (by simp)
  | w + 1, i + 1, h => by
    rw [Nat.testBit_succ]
    have : (band c f (w + 1)) / 2 = band c f w := by simp only [band]; split <;> omega
    rw [this, testBit_band_lt c f w i (by omega)]
    congr 1
    push_cast; omega

theorem band_top (c : Int → Bool) (f : Int) (hf : c f = true) (w : Nat) : 2 ^ w ≤ band c f (w + 1) := by
  apply Nat.le_of_not_lt
  intro hlt
  have h := Nat.testBit_lt_two_pow hlt
  rw [testBit_band_lt c f (w + 1) w (by omega),
    show f + ((w + 1 : Nat) : Int) - 1 - (w : Int) = f by push_cast; omega, hf] at h
  exact absurd h (by decide)

/-- A band reads only its own cells. -/
theorem band_congr {c d : Int → Bool} {f g : Int} : ∀ w, (∀ j : Nat, j < w → c (f + j) = d (g + j)) →
    band c f w = band d g w
  | 0, _ => rfl
  | w + 1, h => by
    simp only [band]
    rw [band_congr w (fun j hj => h j (by omega)), h w (by omega)]

/-! ## The outer cells update by themselves -/

/-- One step of rule 30 on the line. -/
def stepLine (c : Int → Bool) : Int → Bool := fun p => rule (c (p - 1)) (c p) (c (p + 1))

theorem evol_succ (x : Int → Bool) (t : Nat) : evol x (t + 1) = stepLine (evol x t) := rfl

/-- **The band moves out by one and updates by `R`**, for any configuration white to the left of `f`. -/
theorem band_step (c : Int → Bool) (f : Int) (w : Nat) (hw : ∀ p, p < f → c p = false) :
    band (stepLine c) (f - 1) w = R (band c f w) := by
  apply Nat.eq_of_testBit_eq
  intro i
  simp only [R, Nat.testBit_xor, Nat.testBit_or, Nat.testBit_shiftRight]
  by_cases hi : i < w
  · rw [testBit_band_lt _ _ _ _ hi, testBit_band_lt _ _ _ _ hi]
    simp only [stepLine, rule]
    have e1 : (f - 1 + (w : Int) - 1 - (i : Int)) - 1 = f + (w : Int) - 1 - ((2 + i : Nat) : Int) := by
      push_cast; omega
    have e2 : f - 1 + (w : Int) - 1 - (i : Int) = f + (w : Int) - 1 - ((1 + i : Nat) : Int) := by
      push_cast; omega
    have e3 : f - 1 + (w : Int) - 1 - (i : Int) + 1 = f + (w : Int) - 1 - (i : Int) := by omega
    rw [e3, e1, e2]
    congr 1
    · by_cases h2 : 2 + i < w
      · rw [testBit_band_lt _ _ _ _ h2]
      · rw [testBit_band_ge _ _ _ _ (by omega)]
        exact hw _ (by push_cast; omega)
    · congr 1
      by_cases h1 : 1 + i < w
      · rw [testBit_band_lt _ _ _ _ h1]
      · rw [testBit_band_ge _ _ _ _ (by omega)]
        exact hw _ (by push_cast; omega)
  · rw [testBit_band_ge _ _ _ _ (by omega), testBit_band_ge _ _ _ _ (by omega),
      testBit_band_ge _ _ _ _ (by omega), testBit_band_ge _ _ _ _ (by omega)]
    rfl

theorem iterR_succ' : ∀ (n u : Nat), iterR (n + 1) u = R (iterR n u)
  | 0, _ => rfl
  | n + 1, u => by
    show iterR (n + 1) (R u) = R (iterR (n + 1) u)
    rw [iterR_succ' n (R u)]
    rfl

section Edge

variable {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
include hlo hzero

omit hlo in
/-- The `w` cells from the edge at time `t` are `R` applied `t` times to the `w` cells from the edge at time `0`. -/
theorem band_evol (w : Nat) : ∀ t : Nat, band (evol x t) (lo - t) w = iterR t (band x lo w)
  | 0 => by simp [evol, iterR]
  | t + 1 => by
    rw [evol_succ, show lo - ((t + 1 : Nat) : Int) = lo - t - 1 by push_cast; omega,
      band_step _ _ _ (fun p hp => evol_eq_false_of_lt hzero t p hp), band_evol w t, iterR_succ']

theorem good8_of_age (t : Nat) (ht : 8 ≤ t) : EdgeGood8 (band (evol x t) (lo - t) 8) = true := by
  rw [band_evol hzero]
  have hu : 2 ^ 7 ≤ band x lo 8 := band_top x lo hlo 7
  have hu' := band_lt x lo 8
  have hne : band x lo 8 ≠ 0 := by omega
  have hlog : (band x lo 8).log2 = 7 := (Nat.log2_eq_iff hne).2 ⟨hu, hu'⟩
  have h := top8_from_age_eight (band x lo 8) t hne ht
  rw [hlog, show 7 + t - 7 = 0 + t by omega, iter_F_shiftRight] at h
  simpa using h

theorem good20_of_age (t : Nat) (ht : 24 ≤ t) : EdgeGood20 (band (evol x t) (lo - t) 20) = true := by
  rw [band_evol hzero]
  have hu : 2 ^ 19 ≤ band x lo 20 := band_top x lo hlo 19
  have hu' := band_lt x lo 20
  have hne : band x lo 20 ≠ 0 := by omega
  have hlog : (band x lo 20).log2 = 19 := (Nat.log2_eq_iff hne).2 ⟨hu, hu'⟩
  have h := top20_from_age_twenty_four (band x lo 20) t hne ht
  rw [hlog, show 19 + t - 19 = 0 + t by omega, iter_F_shiftRight] at h
  simpa using h

end Edge

/-! ## Below a good band, a predecessor resets -/

/-- One outward step of the inverse rule on two adjacent cells: `(z p, z (p + 1)) ↦ (z (p - 1), z p)`. -/
def pstep (bit : Bool) (s : Bool × Bool) : Bool × Bool := (xor bit (s.1 || s.2), s.1)

/-- The inverse rule run over the bits `0, 1, …` of `u` (from the inner end of the band outward). -/
def prun (u : Nat) (s : Bool × Bool) : Nat → Bool × Bool
  | 0 => s
  | n + 1 => pstep (u.testBit n) (prun u s n)

/-- Under rule 30, a predecessor is fixed leftward by its image: `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))`. -/
theorem left_of (y z : Int → Bool) (hz : ∀ p, stepLine z p = y p) (p : Int) :
    z (p - 1) = xor (y p) (z p || z (p + 1)) := by
  rw [← hz p]
  simp only [stepLine, rule]
  cases z (p - 1) <;> cases z p <;> cases z (p + 1) <;> rfl

theorem prun_spec (y z : Int → Bool) (hz : ∀ p, stepLine z p = y p) (f : Int) (w : Nat) :
    ∀ n, n ≤ w → prun (band y f w) (z (f + w - 1), z (f + w)) n =
      (z (f + (w : Int) - 1 - (n : Int)), z (f + (w : Int) - (n : Int)))
  | 0, _ => by simp [prun]
  | n + 1, hn => by
    rw [prun, prun_spec y z hz f w n (by omega), testBit_band_lt _ _ _ _ (by omega)]
    simp only [pstep]
    have e := left_of y z hz (f + (w : Int) - 1 - (n : Int))
    rw [show f + (w : Int) - 1 - (n : Int) + 1 = f + (w : Int) - (n : Int) by omega] at e
    rw [← e]
    congr 1 <;> congr 1 <;> push_cast <;> omega

theorem prun_reset8 (u : Nat) (h : EdgeGood8 u = true) (a b : Bool) : prun u (a, b) 8 = (false, false) := by
  simp only [EdgeGood8, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with rfl | rfl <;> cases a <;> cases b <;> decide

/-- The predecessor's own band, from the cell after the edge: positions `f + 1 + j` are reached after
`18 - j` steps of a run over a 20-cell band. -/
def parentBand (u : Nat) (s : Bool × Bool) : Nat :=
  band (fun q => (prun u s (19 - q.toNat)).1) 1 8

theorem prun_reset20 (u : Nat) (h : EdgeGood20 u = true) (a b : Bool) :
    prun u (a, b) 20 = (false, false) ∧ EdgeGood8 (parentBand u (a, b)) = true := by
  simp only [EdgeGood20, Bool.or_eq_true, beq_iff_eq, or_assoc] at h
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl <;> cases a <;> cases b <;> decide +kernel

/-- Outward from two white cells over a white image, a predecessor is white; and the image's edge cell
makes the next cell black. -/
theorem edge_of_reset (y z : Int → Bool) (hz : ∀ p, stepLine z p = y p) (f : Int)
    (hy : y f = true) (hw : ∀ p, p < f → y p = false) (h0 : z (f - 1) = false) (h1 : z f = false) :
    z (f + 1) = true ∧ ∀ p, p < f + 1 → z p = false := by
  have hd : ∀ n : Nat, z (f - n) = false ∧ z (f - 1 - n) = false := by
    intro n
    induction n with
    | zero => simpa using And.intro h1 h0
    | succ n ih =>
      refine ⟨by rw [show f - ((n + 1 : Nat) : Int) = f - 1 - n by push_cast; omega]; exact ih.2, ?_⟩
      have e := left_of y z hz (f - 1 - n)
      rw [show f - 1 - (n : Int) - 1 = f - 1 - ((n + 1 : Nat) : Int) by push_cast; omega,
        show f - 1 - (n : Int) + 1 = f - n by omega, ih.1, ih.2, hw _ (by omega)] at e
      simpa using e
  have hle : ∀ p, p ≤ f → z p = false := fun p hp => by
    have := (hd (f - p).toNat).1
    rwa [show f - ((f - p).toNat : Int) = p by omega] at this
  refine ⟨?_, fun p hp => hle p (by omega)⟩
  have e := hz f
  simp only [stepLine, rule, hle (f - 1) (by omega), hle f (Int.le_refl _), hy, Bool.false_xor,
    Bool.false_or] at e
  exact e

/-- **One step.** Below an image whose 8 cells from its edge `f` are good, every predecessor has its
leftmost black cell at `f + 1`. -/
theorem predecessor_edge_of_good8 (y z : Int → Bool) (hz : ∀ p, stepLine z p = y p) (f : Int)
    (hy : y f = true) (hw : ∀ p, p < f → y p = false) (hg : EdgeGood8 (band y f 8) = true) :
    z (f + 1) = true ∧ ∀ p, p < f + 1 → z p = false := by
  have hr := prun_spec y z hz f 8 8 (Nat.le_refl _)
  rw [prun_reset8 _ hg] at hr
  simp only [Prod.mk.injEq] at hr
  refine edge_of_reset y z hz f hy hw ?_ ?_
  · rw [show f - 1 = f + ((8 : Nat) : Int) - 1 - ((8 : Nat) : Int) by push_cast; omega]; exact hr.1.symm
  · rw [show f = f + ((8 : Nat) : Int) - ((8 : Nat) : Int) by push_cast; omega]; exact hr.2.symm

/-- **One step, from a good 20-cell band.** The predecessor's edge is at `f + 1`, and its own 8 cells from
there are good. -/
theorem predecessor_of_good20 (y z : Int → Bool) (hz : ∀ p, stepLine z p = y p) (f : Int)
    (hy : y f = true) (hw : ∀ p, p < f → y p = false) (hg : EdgeGood20 (band y f 20) = true) :
    (z (f + 1) = true ∧ ∀ p, p < f + 1 → z p = false) ∧ EdgeGood8 (band z (f + 1) 8) = true := by
  have hr := fun n hn => prun_spec y z hz f 20 n hn
  obtain ⟨hres, hpar⟩ := prun_reset20 _ hg (z (f + (20 : Nat) - 1)) (z (f + (20 : Nat)))
  have h20 := hr 20 (Nat.le_refl _)
  rw [hres] at h20
  simp only [Prod.mk.injEq] at h20
  refine ⟨edge_of_reset y z hz f hy hw ?_ ?_, ?_⟩
  · rw [show f - 1 = f + ((20 : Nat) : Int) - 1 - ((20 : Nat) : Int) by push_cast; omega]; exact h20.1.symm
  · rw [show f = f + ((20 : Nat) : Int) - ((20 : Nat) : Int) by push_cast; omega]; exact h20.2.symm
  · have e : band z (f + 1) 8 = parentBand (band y f 20) (z (f + (20 : Nat) - 1), z (f + (20 : Nat))) := by
      unfold parentBand
      refine band_congr 8 (fun j hj => ?_)
      have := hr (18 - j) (by omega)
      rw [show ((1 : Int) + (j : Int)).toNat = 1 + j by omega, show 19 - (1 + j) = 18 - j by omega, this]
      congr 1
      push_cast
      omega
    rw [e]
    exact hpar

/-! ## The two theorems -/

section Edge

variable {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
include hlo hzero

/-- **Hughes's age-8 inverse, without the wall.** For a configuration with a leftmost black cell at `lo`
and `t ≥ 8`, every predecessor of its image at time `t` has its leftmost black cell at `lo - t + 1`. -/
theorem predecessor_edge_from_age_eight (t : Nat) (ht : 8 ≤ t) (z : Int → Bool)
    (hz : ∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x t p) :
    z (lo - t + 1) = true ∧ ∀ p, p < lo - t + 1 → z p = false :=
  predecessor_edge_of_good8 (evol x t) z hz (lo - t) (evol_left_edge hlo hzero t)
    (fun p hp => evol_eq_false_of_lt hzero t p hp) (good8_of_age hlo hzero t ht)

/-- **Hughes's age-24 inverse, without the wall.** For a configuration with a leftmost black cell at
`lo` and `t ≥ 24`, every two-step predecessor of its image at time `t` has its leftmost black cell at
`lo - t + 2`. -/
theorem two_step_predecessor_edge_from_age_twenty_four (t : Nat) (ht : 24 ≤ t) (w v : Int → Bool)
    (hw : ∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x t p)
    (hv : ∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) :
    v (lo - t + 2) = true ∧ ∀ p, p < lo - t + 2 → v p = false := by
  obtain ⟨⟨hw1, hw0⟩, hg⟩ := predecessor_of_good20 (evol x t) w hw (lo - t) (evol_left_edge hlo hzero t)
    (fun p hp => evol_eq_false_of_lt hzero t p hp) (good20_of_age hlo hzero t ht)
  have h := predecessor_edge_of_good8 w v hv (lo - t + 1) hw1 hw0 hg
  rw [show lo - t + 1 + 1 = lo - t + 2 by omega] at h
  exact h

end Edge

/-! ## Age 8 is sharp -/

/-- On the right, a configuration white beyond `hi` stays white beyond `hi + t`. -/
theorem evol_eq_false_of_gt {x : Int → Bool} {hi : Int} (hz : ∀ p, hi < p → x p = false) :
    ∀ (t : Nat) (p : Int), hi + t < p → evol x t p = false
  | 0, p, h => hz p (by omega)
  | t + 1, p, h => by
    show rule (evol x t (p - 1)) (evol x t p) (evol x t (p + 1)) = false
    rw [evol_eq_false_of_gt hz t (p - 1) (by push_cast at h; omega), evol_eq_false_of_gt hz t p (by push_cast at h; omega),
      evol_eq_false_of_gt hz t (p + 1) (by push_cast at h; omega)]
    rfl

/-- Two black cells, at `0` and `3`. -/
def sharpX (p : Int) : Bool := p == 0 || p == 3

/-- The middle of the witness, on the positions `-8, …, 10`. -/
def sharpMid : List Bool :=
  [false, true, false, false, false, true, false, false, true, false, false, false, false, false, true, true,
    false, false, true]

/-- A predecessor of `evol sharpX 7` that is black on `(-∞, -9]` and on `[11, ∞)`. -/
def sharpZ (p : Int) : Bool := if p ≤ -9 then true else if 11 ≤ p then true else sharpMid.getD (p + 8).toNat false

theorem sharp_middle : ∀ k : Nat, k < 21 →
    rule (sharpZ (-9 + k - 1)) (sharpZ (-9 + k)) (sharpZ (-9 + k + 1)) = evol sharpX 7 (-9 + k) := by
  decide +kernel

/-- **The age 8 is sharp.** At age 7, some configuration with a leftmost black cell has a predecessor of its
image with no leftmost black cell at all. -/
theorem predecessor_edge_fails_at_age_seven :
    sharpX 0 = true ∧ (∀ p, p < 0 → sharpX p = false) ∧
    (∀ p, rule (sharpZ (p - 1)) (sharpZ p) (sharpZ (p + 1)) = evol sharpX 7 p) ∧
    ∀ q : Int, ∃ p, p < q ∧ sharpZ p = true := by
  have hl : ∀ p, p < 0 → sharpX p = false := fun p hp => by
    simp only [sharpX, Bool.or_eq_false_iff, beq_eq_false_iff_ne]; omega
  have hr : ∀ p, (3 : Int) < p → sharpX p = false := fun p hp => by
    simp only [sharpX, Bool.or_eq_false_iff, beq_eq_false_iff_ne]; omega
  refine ⟨by decide, hl, fun p => ?_, fun q => ⟨min (q - 1) (-9), by omega, ?_⟩⟩
  · by_cases h1 : p ≤ -10
    · rw [evol_eq_false_of_lt hl 7 p (by omega)]
      simp only [sharpZ, show p - 1 ≤ -9 by omega, show p ≤ -9 by omega, show p + 1 ≤ -9 by omega,
        ↓reduceIte]
      rfl
    · by_cases h2 : 12 ≤ p
      · rw [evol_eq_false_of_gt hr 7 p (by push_cast; omega)]
        simp only [sharpZ, show ¬ (p - 1 ≤ -9) by omega, show ¬ (p ≤ -9) by omega, show ¬ (p + 1 ≤ -9) by omega,
          show 11 ≤ p - 1 by omega, show 11 ≤ p by omega, show 11 ≤ p + 1 by omega, ↓reduceIte]
        rfl
      · have := sharp_middle (p + 9).toNat (by omega)
        rwa [show -9 + (((p + 9).toNat : Nat) : Int) = p by omega] at this
  · simp only [sharpZ, show min (q - 1) (-9) ≤ -9 by omega, ↓reduceIte]

end Rule30Submission.Rule30TwoSidedInverse

/-!
# Inverse ticks for every k, without the wall

The kit's every-k chain is stated beside the white wall (`Rule30EveryKStatement.PhysicalEdge`, for finite rows
of the zero-boundary left half). Its argument lives at the edge: a full band of `w` cells from the last black
cell settles onto a cycle of `bandStep w`, and the reset schedule of `Rule30EveryKCascade` (Lowry's PR #60)
fixes the edge of every `k`-tick predecessor once `k ≤ K1 w`. This module states and proves it on the line,
for every configuration `x : Int → Bool` with a leftmost black cell (`Rule30Realization.evol`):

* `kTick_edge_line`: if `0 < w` and `k ≤ K1 w`, then from age `2 ^ w` every `k`-tick predecessor `V` of the
  image (`evol V k = evol x t`) has its leftmost black cell at `lo - t + k`, the edge of `evol x (t - k)`.
* `every_k_line_of_cap`: `CAP` gives, for every `k`, an age from which this holds.
* `every_k_line_of_lInfinity`, `every_k_line_of_dlMinusOne`: the same from `LInfinity` (S4) and from the
  relaxed doubling lemma `DLMinusOne` (S5), through the kit's `cap_of_unbounded_resets` and
  `lInfinity_of_dlMinusOne`.

Nothing is assumed of the predecessors. On the line the band is full from age 0, so the settling age is the
finite-state bound `2 ^ w` alone, where the wall's version needs `w - 1 + 2 ^ w`.

**What changes from the wall.** Only the drive. `Rule30EveryKCascade.scheduled_edge` reads the layers as
`zrow P k`; here `scheduled_edge_rows` takes any chain of rows each driven by the next (`Drives`), and the
layers of a predecessor on the line, read in depth from an anchor right of the band, are such a chain
(`drives_line`). The band of the line evolves by the kit's `stepK` (`bandK_step`); pigeonhole on its `2 ^ w`
values puts it on a cycle by age `2 ^ w` (`on_cycle`, restating the kit's private `collision`); and the kit's
public `capacity_on_cycle` gives the capacity. Credit: the reset schedule and its cascade are Lowry's
(`Rule30EveryKCascade`, PR #60); `K1`, `CAP` and the statement are the kit's (`Rule30EveryKStatement`).
-/


namespace Rule30Submission.Rule30EveryKLine

open Rule30Jen Rule30Realization Rule30FiniteConfigs Rule30EveryKStatement Rule30EveryKCascade
  Rule30EveryKInverse Rule30UniversalLeftSide

/-! ## The band of the line, in the kit's every-k order: bit `j` is the cell `j` places in from the edge -/

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

/-! ## On a cycle by age `2 ^ w` -/

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

/-! ## The schedule, for any chain of driven rows -/

/-- `Rule30EveryKCascade.scheduled_edge`, with the layers given as any chain of rows each driven by the next. -/
theorem scheduled_edge_rows {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v)
    (Ps : Nat → Row) (drive : ∀ i, Drives (Ps (i + 1)) (Ps i) 0)
    (fuel d a k e : Nat) (width : a ≤ w) (full : a ≤ e)
    (matched : Matches (Ps k) e (earlier w v q d) a)
    (closed : k ≤ schedule w v q fuel d a) :
    Ps 0 (e - k) = true ∧ ∀ x, e - k < x → Ps 0 x = false := by
  induction fuel generalizing d a k e with
  | zero =>
    have hk : k = 0 := by simpa [schedule] using closed
    subst k
    exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
      (by simp [reference, show ¬ x ≤ e by omega])⟩
  | succ fuel ih =>
    cases k with
    | zero => exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
        (by simp [reference, show ¬ x ≤ e by omega])⟩
    | succ k =>
      simp only [schedule] at closed
      cases h : firstReset (earlier w v q d) a with
      | none =>
        unfold earlier at h
        simp only [h] at closed
        omega
      | some j =>
        have fj := h
        unfold earlier at h
        simp only [h] at closed
        obtain ⟨m, bound, _⟩ := firstReset_spec fj
        rw [← earlier_step hq cycle d] at fj matched
        have next := scheduled_layer full width (drive k) matched fj
        have result := ih (d+1) j k (e-1) (by omega) (by omega) next (by omega)
        simpa [show e-(k+1) = e-1-k by omega] using result

/-! ## The line, read in depth from an anchor -/

/-- The cells of `z` at depth `d` from the anchor `c`: position `c - d`. -/
def depthRow (c : Int) (z : Int → Bool) : Row := fun d => z (c - d)

/-- Under rule 30, a predecessor is fixed leftward by its image: `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))`. -/
theorem left_of (z : Int → Bool) (p : Int) : z (p - 1) = xor (stepLine z p) (z p || z (p + 1)) := by
  simp only [stepLine, rule]
  cases z (p - 1) <;> cases z p <;> cases z (p + 1) <;> rfl

/-- **On the line, every layer is driven by the next at every depth.** -/
theorem drives_line (c : Int) (z : Int → Bool) : Drives (depthRow c (stepLine z)) (depthRow c z) 0 := by
  intro n _
  refine Prod.ext rfl ?_
  show z (c - ((n + 1 + 1 : Nat) : Int)) = xor (stepLine z (c - ((n + 1 : Nat) : Int)))
    (z (c - ((n + 1 : Nat) : Int)) || z (c - (n : Int)))
  have h := left_of z (c - ((n + 1 : Nat) : Int))
  rw [show c - ((n + 1 : Nat) : Int) - 1 = c - ((n + 1 + 1 : Nat) : Int) by push_cast; omega,
    show c - ((n + 1 : Nat) : Int) + 1 = c - (n : Int) by push_cast; omega] at h
  exact h

/-! ## Inverse ticks for every k on the line -/

section Edge

variable {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
include hlo hzero

/-- **The `k`-tick edge on the line.** If `0 < w` and `k ≤ K1 w`, then from age `2 ^ w` every `k`-tick
predecessor of the image of `x` has its leftmost black cell at `lo - t + k`. -/
theorem kTick_edge_line (k w : Nat) (hw : 0 < w) (cap : k ≤ K1 w) (t : Nat) (ht : 2 ^ w ≤ t)
    (V : Int → Bool) (hV : ∀ p, evol V k p = evol x t p) :
    V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false := by
  let f : Int := lo - t
  let v := bandK (evol x t) f w
  have hband : v = rowAt w (bandK x lo w) t := bandK_evol hzero w t
  have odd : OddBand w v := by
    refine ⟨bandK_lt _ _ w, ?_⟩
    rw [testBit_bandK]
    simp only [hw, decide_true, Bool.true_and, Int.natCast_zero, Int.add_zero]
    exact evol_left_edge hlo hzero t
  obtain ⟨q0, hq0, per0⟩ := on_cycle w (bandK x lo w) (bandK_lt _ _ w) t ht
  rw [← hband] at per0
  obtain ⟨q, hq, per, capq⟩ := capacity_on_cycle hw odd ⟨q0, hq0, per0⟩
  -- the anchor `c`, `w + k` cells right of the image's edge
  let c : Int := f + w + k
  let e : Nat := w + k
  let Ps : Nat → Row := fun i => depthRow c (evol V i)
  have drive : ∀ i, Drives (Ps (i + 1)) (Ps i) 0 := fun i => by
    show Drives (depthRow c (evol V (i + 1))) (depthRow c (evol V i)) 0
    rw [evol_succ]
    exact drives_line c (evol V i)
  have e0 : earlier w v q 0 = v := by
    unfold earlier
    rw [Nat.zero_mod, Nat.sub_zero, Nat.mod_self]
    rfl
  have matched : Matches (Ps k) e (earlier w v q 0) w := by
    rw [e0]
    refine ⟨?_, fun d hd => ?_⟩
    · show evol V k (c - (e : Int)) = true
      rw [hV, show c - (e : Int) = lo - t by simp only [c, e, f]; push_cast; omega]
      exact evol_left_edge hlo hzero t
    · show evol V k (c - (d : Int)) = reference e v d
      rw [hV]
      unfold reference
      split
      · rename_i hde
        rw [testBit_bandK]
        simp only [show e - d < w by omega, decide_true, Bool.true_and]
        congr 1
        simp only [c, e, f]; push_cast; omega
      · exact evol_eq_false_of_lt hzero t _ (by simp only [c]; push_cast; omega)
  have closed : k ≤ schedule w v q w 0 w := Nat.le_trans cap capq
  obtain ⟨hedge, hwhite⟩ := scheduled_edge_rows hq per Ps drive w 0 w k e (Nat.le_refl _) (by omega) matched closed
  refine ⟨?_, fun p hp => ?_⟩
  · have : Ps 0 (e - k) = V (lo - t + k) := by
      show V (c - ((e - k : Nat) : Int)) = V (lo - t + k)
      congr 1; simp only [c, e, f]; push_cast; omega
    rw [← this]; exact hedge
  · have h := hwhite (c - p).toNat (by simp only [c, e, f] at *; omega)
    have : Ps 0 (c - p).toNat = V p := by
      show V (c - (((c - p).toNat : Nat) : Int)) = V p
      congr 1; omega
    rwa [this] at h

end Edge

/-- **Every k on the line, from `CAP`.** -/
theorem every_k_line_of_cap (capacity : CAP) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false := by
  obtain ⟨w, hw, hk⟩ := capacity k
  exact ⟨2 ^ w, fun x lo hlo hzero t ht V hV => kTick_edge_line hlo hzero k w hw hk t ht V hV⟩

/-- **Every k on the line, from `LInfinity`** (S4's hypothesis). -/
theorem every_k_line_of_lInfinity (deep : Rule30ResetCompactness.LInfinity) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  every_k_line_of_cap (Rule30ResetCompactness.cap_of_unbounded_resets deep) k

/-- **Every k on the line, from the relaxed doubling lemma** (S5's hypothesis). -/
theorem every_k_line_of_dlMinusOne (h : Rule30RelaxedWindows.DLMinusOne) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  every_k_line_of_lInfinity (Rule30RelaxedWindows.lInfinity_of_dlMinusOne h) k

end Rule30Submission.Rule30EveryKLine

namespace Rule30Submission

open Ruliology.CellularAutomata Rule30Jen Rule30Realization Rule30EveryKStatement

/-- From age 8, every predecessor of the image of a configuration with a leftmost black cell at `lo` has its
leftmost black cell at `lo - t + 1`. -/
theorem predecessor_edge_from_age_eight {x : Int → Bool} {lo : Int} (hlo : x lo = true)
    (hzero : ∀ p, p < lo → x p = false) (t : Nat) (ht : 8 ≤ t) (z : Int → Bool)
    (hz : ∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x t p) :
    z (lo - t + 1) = true ∧ ∀ p, p < lo - t + 1 → z p = false :=
  Rule30TwoSidedInverse.predecessor_edge_from_age_eight hlo hzero t ht z hz

/-- From age 24, every two-step predecessor has its leftmost black cell at `lo - t + 2`. -/
theorem two_step_predecessor_edge_from_age_twenty_four {x : Int → Bool} {lo : Int} (hlo : x lo = true)
    (hzero : ∀ p, p < lo → x p = false) (t : Nat) (ht : 24 ≤ t) (w v : Int → Bool)
    (hw : ∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x t p)
    (hv : ∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) :
    v (lo - t + 2) = true ∧ ∀ p, p < lo - t + 2 → v p = false :=
  Rule30TwoSidedInverse.two_step_predecessor_edge_from_age_twenty_four hlo hzero t ht w v hw hv

/-- The age 8 is sharp: at age 7 some configuration with a leftmost black cell has a predecessor of its image with
no leftmost black cell at all. -/
theorem predecessor_edge_fails_at_age_seven :
    ∃ x : Int → Bool, x 0 = true ∧ (∀ p, p < 0 → x p = false) ∧
      ∃ z : Int → Bool, (∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x 7 p) ∧
        ∀ q : Int, ∃ p, p < q ∧ z p = true :=
  let h := Rule30TwoSidedInverse.predecessor_edge_fails_at_age_seven
  ⟨_, h.1, h.2.1, _, h.2.2.1, h.2.2.2⟩

/-- If `0 < w` and `k ≤ K1 w`, then from age `2 ^ w` every `k`-tick predecessor of the image of a configuration
with a leftmost black cell at `lo` has its leftmost black cell at `lo - t + k`. -/
theorem kTick_edge_line {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (k w : Nat) (hw : 0 < w) (cap : k ≤ K1 w) (t : Nat) (ht : 2 ^ w ≤ t)
    (V : Int → Bool) (hV : ∀ p, evol V k p = evol x t p) :
    V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.kTick_edge_line hlo hzero k w hw cap t ht V hV

/-- The kit's reset capacity `CAP` gives, for every `k`, an age from which every `k`-tick predecessor of the image
of every configuration with a leftmost black cell has its leftmost black cell `k` places in. -/
theorem every_k_line_of_cap (capacity : CAP) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.every_k_line_of_cap capacity k

/-- The same from the relaxed doubling lemma. -/
theorem every_k_line_of_dlMinusOne (h : Rule30RelaxedWindows.DLMinusOne) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.every_k_line_of_dlMinusOne h k

end Rule30Submission
", "ProjectDir" -> $Rule30PrizeKit]
```

## The formal checks

The six headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.predecessor_edge_from_age_eight", "Rule30Submission.predecessor_edge_fails_at_age_seven", "Rule30Submission.two_step_predecessor_edge_from_age_twenty_four", "Rule30Submission.kTick_edge_line", "Rule30Submission.every_k_line_of_cap", "Rule30Submission.every_k_line_of_dlMinusOne"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

Hughes's good 8-bands, as Lean holds them; the step that makes the band at the edge update by itself; the band is good from age 8; and below a good band the inverse rule ends in two white cells, from any two cells:

```wl
{rule30Submission["Rule30Submission.Rule30AgeEightInverse.EdgeGood8"]["TermForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.band_step"]["TypeForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.good8_of_age"]["TypeForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.prun_reset8"]["TypeForm"]}
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.every_k_line_of_dlMinusOne"]["KernelCheck"]
```
