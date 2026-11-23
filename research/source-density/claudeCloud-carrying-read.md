# Path 3, the density polygon: the carrying read

*claudeCloud, 22 November 2026 (ledger K67). The author of the proofs is gptIntel (I72). This is the read by a
different worker that METHOD §12 asks for: the Lean replayed on another host with another build script, the
statements read against the claims, the finite content recomputed without Lean, and the novelty and chain tests.
One module is added by the reader and needs its own read: `Rule30DensityPolygon`, the converse that makes the
classification an equivalence.*

## 1. What was read

Two packets from the store, unpacked into their own folders. No script in them was run.

| Packet | SHA-256 | Modules |
|---|---|---|
| `share-scratch/gptIntel/I72/density-region.zip` | `7f2d55d7b3d5734eb54a4c09da6f52cef4704fd9707c1c16b3e9bd8070ecf092` | `Rule30SourceDensityRegion`, `Rule30SourceDensityCorners`, `Rule30DensitySharpness`, `Rule30SourceTransitions`, `Rule30DensityEscape`, `Rule30DensityMargin` |
| `share-scratch/gptIntel/I72/individual-density-polygon.zip` | `047dbf96ddc7330ab49f579bfc6970237a1db9062f221a25fefbc90e0e1abd01` | `Rule30DensityControl`, `Rule30DensityModes`, `Rule30DensityVertices`, `Rule30DensityOneHistory` |

- The six modules of the first packet are byte for byte the files already in this folder.
- The four of the second were not in the repository. They are added here unchanged, with the packet's own digests
  (`e6c259a7…`, `22dcaf9e…`, `1567d057…`, `dd4031d8…`).

## 2. The Lean replay

**How.** [claudeCloud_lean_replay.py](claudeCloud_lean_replay.py) compiles each module with the stock `lean` of
Lean 4.35.0, imports first, writing outside the source folder, and then runs the kit's own `Check.lean` on each
module with its headlines. The headline lists are in the three `claudeCloud-replay-plan-*.json` files. The kit
library was built by `lake` in a fresh clone at each revision.

**Where.** On the cloud host, which had no Lean until this read. The owner's ruling of 21 November allows any
software but Wolfram there. The install was tested first with known answers: the kit checker passes
`Rule30SourceObservables.density_bound`, and fails a module with a `sorry` (it names `sorryAx`) and a headline that
does not exist.

**Result: everything passes, at four kit revisions.**

| Kit revision | The six modules and the converse | The four companion modules |
|---|---|---|
| `40017e8`, the author's | 33 headlines, 341 constants, pass | 14 headlines, 156 constants, pass |
| `dd2a220`, main at the start of the read | pass | pass |
| `cf60d48`, main now | pass | pass |
| `5fb5915`, the portal verifier's | pass, **with the kit's `Rule30SourceObservables` carried** | pass, nothing carried |

- **Equal to the author's receipts.** For the author's ten modules, at every revision, the declarations, each
  headline's axioms, the replay counts (299 and 156) and the verdicts equal the `-check.json` files in the packets.
- **Axioms:** only `propext`, `Classical.choice` and `Quot.sound`. No `sorry`, `native_decide`, `axiom`, `unsafe`,
  `implemented_by` or `extern` occurs in any source.
- **Time:** all eleven modules compile and check in under a minute on four cores.
- **The verifier's commit** dates from 5 November and has no `Rule30SourceObservables` (Condrey's module of 11
  November, extended by Quint and Gemini on 12 November). A portal packet must carry that one module, 343 lines,
  unchanged. Everything else the proofs import is at the verifier's commit already.
- Receipts: `data/claudeCloud-lean-replay-region-<rev>.json` and `data/claudeCloud-lean-replay-individual-<rev>.json`.

## 3. What the statements say

Throughout, a history is `u : Nat → Int → Bool` with `u (t+1) i = rule (u t (i-1)) (u t i) (u t (i+1))` at every
tick and site, where `rule a b c = xor a (b || c)`. For a site `j`, a start `s` and a length `n`, `black u j s n`
counts the black cells of `j` in ticks `s … s+n−1`, and `ends u j s n` counts the ticks where `j` is black and
`j+1` is white. Write C, A and T for these and for `n`.

**The six modules.**

| Theorem | In words | Matches the claim? |
|---|---|---|
| `region` (with `middle_face`, `high_face`) | Every history, site and interval has 3C ≤ T + 5A + 3, 2C ≤ T + 2A + 1 and 6C ≤ 5T + A + 5. The first is the kit's `density_bound`. | Yes. No finiteness or onset is assumed. |
| `singleton_region` | The same on the single seed. | Yes |
| `corner0` … `corner4` | Five histories, each periodic in time, with (T, C, A) per period equal to (1, 0, 0), (3, 1, 0), (4, 3, 1), (10, 9, 4), (1, 1, 1). | Yes. Each is given as a film periodic in space too, of widths 1, 12, 7, 155, 2. Lean checks the rule at every cell and seam. |
| `optimal_startup` | On the fourth film, 3C − 5A − T = 3 on [2, 5), 2C − 2A − T = 1 on [8, 17), and 6C − A − 5T = 5 on [4, 13). | Yes: each additive constant is attained, on one history. |
| `polygon_necessary` (with `finite_corner_bound`, `repeated_corner`) | If αC + βA ≤ γT + K for every nonzero finite seed and every n, at site 0 from tick 0, then the inequality without K holds at the five corners. | Yes. Seeds are arbitrary, so every site and start is covered. This is one direction only: see section 6. |
| `fall_count`, `middle_identity` | C − A is the number of black-to-white steps of column j+1, and T − 2(C − A) is the number of unchanged steps of that column plus its last bit minus its first. | Yes. The identity is prior work at the centre: see section 5. |
| `bounded_iff_alternates`, `singleton_middle_bounded_iff_period_two` | T − 2(C − A) is bounded above along a history exactly when column j+1 eventually alternates. On the single seed that is eventual period two of column j+1. | Yes |
| `band_edge`, `tight_repeat`, `tight_columns`, `range_potential`, `accumulated_step` | A potential on six cells. Each tick loses a nonnegative amount against 5C ≤ 2T + 7A or 8C ≤ 6T + 3A. Six, or twelve, ticks with no loss make both observed columns repeat after 4, or 10, ticks. | Yes |
| `loss_in_interval` | On the single seed, at site j and any age s ≥ \|j\|, a strict loss occurs before age 2s + \|j\| + 2p + 3, with p = 4 or 10. | Yes |
| `margin_three_quarters`, `margin_nine_tenths` | On the single seed, with d₀ = \|j\| and dₖ₊₁ = 2dₖ + \|j\| + 2p + 3: for T ≥ dₖ, 2T + 7A − 5C ≥ k − 4 (p = 4) and 6T + 3A − 8C ≥ k − 6 (p = 10), on [0, T). | Yes. It bounds the counts, not the ratios: the ratios may still converge to a corner. |

**The four companion modules.**

| Theorem | In words |
|---|---|
| `steer_prefix`, `realize_segment`, `install` | From any row on the sites j ≥ 0, W ticks of freely chosen site-0 bits can write any W cells. |
| `realize_stream` | A stream of such rows that obeys the rule at every site j ≥ 1 is the right half of one ordinary full-line history (the kit's `Rule30Realization.realize`). |
| `zero_policy`, `oneThird_policy`, `threeQuarters_policy`, `nineTenths_policy`, `one_policy` | Five finite controllers, of widths 2, 6, 21, 37, 3. Each chooses the next site-0 bit from its window before it sees the cell beyond, stays inside its table for both values of that cell, and carries two bounded potentials. |
| `discrepancy`, `block_bounds`, `run_fit`, `run_open` | While a controller runs, D·C − c·T and D·A − a·T stay within its cap, for D, c, a, cap = (1, 0, 0, 0), (3, 1, 0, 3), (4, 3, 1, 3), (10, 9, 4, 12), (1, 1, 1, 0). |
| `physical_mode` | For each controller and **any prescribed row on the sites j ≥ 0**, some full-line configuration has that right half, and from tick W on its counts obey those bounds for ever. |

So each corner is reached, with bounded error and not only in the limit, by a history whose right half is
arbitrary. The left half does the steering.

**Not Lean theorems.** These are claims of the notes, sound as far as I can read them, and they rest on hand
arguments:
- that the limits of (C/T, A/T) lie in the polygon: immediate from `region` on dividing by T;
- that every point of the polygon is the limit pair of one history: by visiting the five controllers in epochs,
  the m-th epoch spending ⌊m λᵢ⌋ ticks in controller i. Each epoch costs 69 ticks of steering (2 + 6 + 21 + 37 +
  3) and at most 77 of error, so the error after N ticks is O(√N). The pieces it needs are all in Lean
  (`install`, `block_bounds`, `realize_stream`); the schedule and the limit are not.

## 4. The finite content, without Lean

- K64 addendum 3 ([claudeCloud_polygon_read.py](claudeCloud_polygon_read.py)): the local identity; the three
  bounds on every interval of 232,760 evolutions; the five corners found independently, the last by SAT; 155 is the
  least ring width with time period 10 and counts (9, 4).
- Now ([claudeCloud_polygon_spot.py](claudeCloud_polygon_spot.py),
  [output](data/claudeCloud-polygon-spot.txt)):
  - the five films of the Lean file, read as data, are Rule 30 histories with the stated counts;
  - the three sharp constants are attained on the stated intervals;
  - on the single seed, at sites −3 to 3 and every T up to 2^16, both margins hold. The least slack is 3 to 24.
    The deficits themselves grow linearly, as 1.25 T and 2.75 T, because the seed sits near
    (C/T, A/T) = (0.50, 0.25), the middle of the polygon;
  - the multipliers of the converse (section 6) are nonnegative and exact on 5,488 integer triples.

## 5. Novelty, and one credit that is missing

**Searched.** The portal's list of 22 November 21:35 UTC (396 entries: titles and abstracts) for density, run
ends, sources, frequencies, polygons, corners, the fractions 3/4, 9/10 and 2/5, five-column bounds and
black-to-white steps. KIT-INDEX at `cf60d48`. PORTAL.md. Two web searches for published bounds on the density of a
Rule 30 column.

**Found.**
- **Condrey**, [R30-20261110-21dc25](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-21dc25)
  (kit #253): 3C ≤ T + 5A + 3 for arbitrary streams, and 3C ≤ T + 3 with no source. **Quint and Gemini**,
  [R30-20261111-15cfcd](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261111-15cfcd) (kit
  #297): every interval, and source lower bounds. Both are credited by I72. They give the first sloping face.
- **Not credited yet: the identity behind the middle face.** Ulrey's
  [R30-20261106-2b2509](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261106-2b2509) proves
  that a black-to-white step of the centre is exactly a black centre with a black left neighbour
  (`center_block_10_eq_left_black`). Quint and Gemini's
  [R30-20261112-8b6538](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261112-8b6538) counts
  them: `count10 center n = spatial11Left n`. Both are in the kit's `Rule30TwoBlockCounts`. That is `fall_count`
  at the centre of the single seed. I72 states it for every history, site and interval, which is the same
  one-line argument. **Any proposal must credit them for it.** With it, the middle face says only that a column
  cannot fall on two consecutive ticks.
- **Related, not the same:** our `Rule30FiveColumnBound` (five adjacent columns hold at most 3T + 2 black cells),
  with extensions by Quint and by Ulrey. It bounds a sum over five columns and says nothing about one.
- **Nothing** has the face 6C ≤ 5T + A + 5, the corners (3/4, 1/4) or (9/10, 2/5), the classification of linear
  bounds, a margin on the single seed, or a corner reached from an arbitrary right half. The web searches found no
  published inequality for the density of one column.

**The chain test.** The parameter would be the set of observables. The kit has one inequality for the pair (C, A).
This closes that pair: every uniform linear inequality, with the extremal histories. It is the whole family for
the pair, not a further term. A region for other observables would be a next question, and this would be its first
complete case.

**What it gives a reader.**
- An exact trade-off between how often a site is black and how often its black runs end beside it, valid in every
  Rule 30 history, with five explicit periodic histories at the corners.
- One new inequality with a physical reason: each black run pays for at most five neighbouring 11s, by the kit's
  nine-black shield.
- On the single seed: the two high-density corners are missed by an error that grows at least like log T, and
  bounded error on the middle face at site j is exactly eventual period two of column j + 1. For j = −1 that is the
  open period-two question for the centre.
- It does not bound the density of the centre. Problem 2 is untouched.

## 6. The converse, added by the reader

`polygon_necessary` gives one direction. The notes say the bounds "describe the polygon exactly", and no theorem
said so. [Rule30DensityPolygon.lean](Rule30DensityPolygon.lean) adds it.

| Theorem | Statement |
|---|---|
| `polygon_sufficient` | If 0 ≤ γ, α ≤ 3γ, 3α + β ≤ 4γ, 9α + 4β ≤ 10γ and α + β ≤ γ, then αC + βA ≤ γT + 9\|α\| + 4\|β\| on every interval at every site of every history. |
| `uniform_bound_iff` | Some K makes αC + βA ≤ γT + K hold for every history, site and interval **if and only if** those five inequalities hold. |
| `finite_bound_iff` | The same with "every nonzero finite seed" in place of "every history". |
| `finite_bound_iff_uniform` | So the two notions of a uniform bound agree. |

- **The proof.** The five inequalities say that (α, β, γ) is at most γ at each corner. The pair (α, β) lies in the
  normal cone of one corner, and is a nonnegative combination of the two faces that meet there: A ≥ 0, the three
  faces of `region`, and A ≤ C. The five cases are closed by `Int.mul_nonneg` and `grind`.
- **Checked** at the same four kit revisions: 7 headlines, 42 constants, standard axioms.
- **It is mine, so it needs a read by another worker.**

## 7. For a submission

- **Shape.** One portal entry, a partial result for Problem 2, and one family of kit modules.
- **Headlines I would choose:** `region`; the five corners and `optimal_startup`; `uniform_bound_iff` and
  `finite_bound_iff`; the two margins; `singleton_middle_bounded_iff_period_two`; and `physical_mode` with the five
  policies, stated with their numbers.
- **To credit:** Condrey; Quint and Gemini (both the interval form and the two-block count); Ulrey; the kit's
  nine-black shield and realization theorem; `Rule30SidewaysLocks`' period-five lock and the ether, which two of
  the controllers use.
- **To say plainly in the text:** the limit statement for interior points is a hand corollary; the densities of
  the single seed are not determined; least width 155 is computed, not proved.
- **The verifier's commit** needs `Rule30SourceObservables` carried. The source is about 75 KB and checks in well
  under the four-minute limit.

## 8. Added for the packet (K68)

- **`Rule30DensityPolygon.lean` changed in a comment only.** Two quotation marks in its docstring were removed,
  because the notebook carries the source inside a string. No declaration changed. Its digest is now `b081c42e…`
  (it was `6f7b3822…` in K67).
- **[Rule30DensityCornerHistories.lean](Rule30DensityCornerHistories.lean)** (`f50cabc3…`), mine. It restates
  `physical_mode` and the five controllers in the counts `black` and `ends`, with their numbers written out:
  `corners_from_any_right_half`. Two headlines, four constants, standard axioms. It needs a read with the converse.
- **All twelve modules** pass at `40017e8`, `cf60d48` and the verifier's `5fb5915` (with `Rule30SourceObservables`
  carried): 49 headlines, 501 constants. Receipts: `data/claudeCloud-lean-replay-all-<rev>.json`.
- **The single file.** [claudeCloud_s9_assemble.py](claudeCloud_s9_assemble.py) joins the carried kit module and
  the twelve, each read by an asserted digest, and restates ten headlines in `Rule30Submission`. The result is
  `Rule30Submission.lean`, `a70b08b46c832b7e7e217be76dc75ce2c8b57dfcfaa5d4e6fed7f1da3b59b9a7`, 1,808 lines and
  84,349 bytes.
- **At a clean checkout of the verifier's commit** (only `Rule30Prize` and `Rule30Realization` built) it compiles
  in 30 seconds, and the kit's `Check.lean` passes all ten headlines: 593 constants, no new axioms. Receipt:
  `data/claudeCloud-s9-check-pin.json`.
- **gptIntel's read (I124)** passed the converse at its first digest, corrected the credit (Ulrey proved the
  identity for one tick and as a count; Quint and Gemini's package has the count too) and asked for the explicit
  constant as a headline. Both are in the text and the source: `linear_bound_constant` is the tenth headline.

## 9. Added in K69: every rational point of the pentagon, in Lean

Section 5 left one claim of I72 as a hand argument: one history can make the two densities converge to any point
inside the pentagon. [Rule30DensityMixtures.lean](Rule30DensityMixtures.lean) (`cb15c8dd…`, mine, **unread**) proves
it for every rational point. The idea of the schedule and its estimate, 69 steering ticks and a bounded error in
each round, are gptIntel's (I72). The Lean is new.

**The two statements.**
- `schedule`: for any sequence of certified controllers `m k` and any durations `L k`, every right half belongs to a
  full-line configuration that spends `(m k).width` steering ticks and then `L k` controlled ticks in phase `k`, for
  every `k`. Throughout each controlled stretch both counts are within that controller's cap (`Near`).
- `mixtures_from_any_right_half`: give the corners the weights `w 0, …, w 4` with sum `K > 0`. Every right half
  belongs to a configuration with, for every `n`, counting from tick 0 at sites 0 and 1,
  `(60*K*C - P*n)^2 ≤ 2*(K*(60*K+4317))^2*(n+1)` for `P = 20*w 1+45*w 2+54*w 3+60*w 4`, and the same for `A` with
  `P = 15*w 2+24*w 3+60*w 4` (`RootClose`). So `C/n` and `A/n` converge to the weighted average of the corners.

**How the proof goes, for a reader.**
1. `mode_stream` is the half of gptIntel's `physical_mode` that comes before the realization, with its proof: from
   any row, `width` steering ticks and then the controller for ever, as a stream of rows.
2. `glue` joins phases. `stage k` follows phases `0 … k` and then stays in phase `k`. Stages agree on the ticks
   before the next phase starts (`stage_stable`), so `s t = stage t t` is one stream, and it obeys the interior rule.
3. `schedule` picks each phase's stream with `Classical.choose` on `mode_stream`, glues, and realizes the stream
   with the kit's `realize_stream`. This is where choice enters; the axioms are the standard three.
4. One phase, in its own units (`near_phase`): the `W` steering ticks change `D*C` by between 0 and `D*W`, and the
   controlled ticks by `c*L` up to the cap.
5. One round (`epoch_step`): the five phases `5e … 5e+4`, where corner `i` gets `w i * e` controlled ticks. In
   sixtieths, `-177 ≤ 60*ΔC - e*P ≤ 4317`, and the round lasts `69 + K*e` ticks.
   - 69 = 2 + 6 + 21 + 37 + 3, the five widths.
   - 177 = 20·3 + 15·3 + 6·12, the caps of the three middle controllers.
   - 4317 = 60·2 + 20·21 + 15·87 + 6·382 + 60·3, the steering ticks and the caps together.
6. Over rounds (`epochs`): at the start of round `e`, `|60*K*C - P*T| ≤ 4317*K*e`.
7. Inside a round (`inside_arith`): each tick moves `60*K*C - P*T` by at most `60*K`, which gives
   `K*(60*K+4317)*(e+1)`. And `(e+1)^2 ≤ 2*T+2` (`root_bound`), because round `e` lasts at least `69 + e` ticks.

**What a read should check.** The statement first: the weights and the two values of `P` against the corners
`(0,0)`, `(1/3,0)`, `(3/4,1/4)`, `(9/10,2/5)`, `(1,1)`; that the counts start at tick 0; the right-half clause. Then
the start tick of `Near` in `schedule`; the use of choice; and that `cornerMode` lists the five certified
controllers in that order.

**Checks run** (the cloud host, Lean 4.35.0, the kit's `Check.lean`).
- The thirteen modules pass at `40017e8`, `cf60d48`, `127ebed` and the verifier's `5fb5915` (with
  `Rule30SourceObservables` carried): 52 headlines, 642 constants. Receipts:
  `data/claudeCloud-lean-replay-all13-<rev>.json`. The new module alone: three headlines, 141 constants.
- The single file, now with thirteen modules and eleven headlines, is
  `8a769d21ba55bca3fecf0bce58142121bc39c10c4afea57277f31434101505dc`, 2,296 lines and 110,373 bytes. At a clean
  checkout of `5fb5915` it compiles in 32 seconds and passes all eleven headlines: 731 constants, no new axioms.
  Receipt: `data/claudeCloud-s9-check-pin-v3.json`.

**What it does not prove.** Limits at points of the pentagon with an irrational coordinate. Nothing about the
single seed.

## 10. After the last read (K70)

- **I139 passed the mixtures module** (`cb15c8dd…`). All thirteen modules are read: I124 (the converse), I126 (the
  corner histories), I139 (the mixtures), and K67 for gptIntel's ten. The rational-mixture theorem is PROVED.
- **The essay changed in three places** ([draft](s9-essay-draft.md), now `e042484e…`).
  - "This settles which limits are possible" became "So the possible rational limits are exactly the rational points
    of the pentagon" (I139: the old wording covered irrational targets, which are open).
  - The last cell applies `KernelCheck` to all eleven headlines (I139).
  - One sentence on how slow the convergence is, from the control of K69 addendum 2.
- **The kit route.** [claudeCloud_s9_kit_form.py](claudeCloud_s9_kit_form.py) (`4c9ffca4…`) makes the kit form in a
  clean checkout of kit main: the thirteen modules with only their import lines changed (and one CRLF line end made
  LF), their imports in `lean/Ruliology.lean`, the module count 310 → 323, and the four rows of
  [s9-kit-rows.md](s9-kit-rows.md) (`6aee9f5f…`). The rows carry `{DATE}`, `{AUTHORS}`, `{ID}` and `{PAGE}`.
  - At kit main `ac88b68`, `lake build` builds the thirteen in 36 seconds, and the stock `Check.lean`, run on each
    module inside the kit's own build, passes 52 headlines and 642 constants with no new axioms. Receipt:
    `data/claudeCloud-s9-kit-check-ac88b68.json`.
  - The patch is `S9-kit-on-ac88b68.patch`, SHA-256
    `098a0a30373d85d69e354c5be944362c0de0e002ceec872f54f1b7d8789f1db5`, 121,397 bytes, on the store. It applies to a
    fresh checkout of `ac88b68` and reproduces the same module bytes.
  - Not done here: a build of the whole catalogue with the thirteen imports added. It takes hours on this host.
  - The modules keep their three family namespaces (`Rule30SourceDensityRegion`, `Rule30DensityEscape`,
    `Rule30DensityControl`), as fifteen of the kit's modules do. The two table modules (`Rule30SourceDensityCorners`,
    `Rule30DensityVertices`) are small and build in seconds; if the maintainers want them under
    `Rule30Certificates/`, that is a rename.
