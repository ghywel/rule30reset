# Four ticks beside a prescribed wall: the least ages are 72 and 73, and one rule for every k

claudeIntel, N30, 26 November 2026. It answers the owner's "Continue with the K50.3 four-tick upper gap and the four surviving age-75 words", and the owner's
question during the work: is there a more general rule behind the advance from two to three to four ticks?

## Verdict

- **The least uniform four-tick ages are 72 for starts at depth at least two and 73 for the adjacent start.** N27 proved them lower bounds in Lean. The upper side is a
  reduction, PROVED IN LEAN for every number of ticks, plus one finite check, COMPUTED exhaustively by two programs that share no code. This confirms N27's
  prediction.
- **I267's four surviving age-75 words are not physical.** No start at depth 1, 2, 3 or 4 reaches any of them under any wall (COMPUTED).
- **A correction to N27.** I said a sharper cover would have to track the inverse register with the band. That is wrong. On the exact physical bands, I267's own
  test, with any register at the band's east end, already passes from age 72. The gap came from the band cover, which over-counts the bands.
- **The general rule (PROVED IN LEAN, every k).** For any number k of inverse ticks, both uniform statements reduce to one statement: every start at depth two
  passes at age T. The adjacent class is then always exactly one tick later, which is why the pairs are 8/9, 24/25, 31/32 and 72/73. The rule fixes the structure but
  not the numbers: no formula for the depth-two age is known, and the kit's route to every k still needs the open capacity hypothesis (CAP).
- **Five and six ticks, by the same search (COMPUTED): 81 and 82, and 108 and 109.**

## 1. The rule for every k (PROVED IN LEAN)

**Any column is a wall.** The wall is arbitrary, and the cells west of any column `j ≤ 0` of a driven half form a driven half with that column as their wall
(`L_column`). A start at depth `m` at age `t ≥ T` therefore contains a depth-two start at age `T`:
- restart at time `a = t − T`, when the leftmost black is at `−(m + a)`;
- take the column two sites east of it as the wall.

The rows west of that column, and every chain of predecessors read there, are those of a depth-two start at age `T`. The edge of the k-th predecessor lies in
that region. This needs `m + t ≥ T + 2`.

**The adjacent start.**
- After one tick the depth-one start is black at −2 and −1, a depth-two start.
- At age two, the depth-two start with −1 white gives the same rows as the one with −1 black, once the second wall bit becomes `!c 0 || c 1`.

So for `T ≥ 2` the adjacent start at age `T + 1` covers every depth-two start at age `T`.

| Theorem | Content |
|---|---|
| `L_column` | West of column `j ≤ 0`, the driven half from time `a` on is the half driven by that column |
| `exactAt_of_two` | Depth two at age `T` gives every start at depth `m ≥ 1`, at every age `t ≥ T` with `m + t ≥ T + 2` |
| `exactAt_two_of_one` | The adjacent start at age `T + 1` gives depth two at age `T`, for `T ≥ 2` |
| `two_classes` | For every `k` and `T ≥ 2`: "depth at least two, from age `T`" and "adjacent, from age `T + 1`" are each equivalent to depth two at age `T` |
| `four_tick_least_ages` | Given the depth-two check at age 72: the four-tick statement holds from 72 and 73, and no smaller uniform ages work (N27's witnesses) |

`ExactAt k m t` lets each predecessor choose its own bit at site 0, as in S6, S23 and I267. Exactness is monotone in age as a consequence.

**What this explains, and what it does not.** The depth-two rows are the same for every k, and they form a single tree: deleting the cell next to the wall from a row at
age `q + 1` gives a row at age `q`. Only the number of inverse registers changes with k, which is 4^k. The rule turns each k into one finite search, but it says
nothing about how fast the depth-two age grows. The kit's every-k route (Lowry's cascade, I267's sketch) still needs the open capacity hypothesis.

| k | Depth ≥ 2 | Adjacent | Rows at that age | Status |
|---:|---:|---:|---:|---|
| 1 | 8 | 9 | 7 | Hughes, S23 (Lean) |
| 2 | 24 | 25 | 91 | Hughes, S23 (Lean) |
| 3 | 31 | 32 | 168 | I267 (Lean) |
| 4 | **72** | **73** | 10,582 | lower N27 (Lean); upper here |
| 5 | **81** | **82** | 23,254 | here (COMPUTED, two programs) |
| 6 | **108** | **109** | 185,272 | here (COMPUTED, one program) |

The exact method reproduces the first three rows from scratch. That validates it against three theorems already proved in Lean.
- **Five ticks** ([claudeIntel_k_tick_exact.py](claudeIntel_k_tick_exact.py), [output](data/claudeIntel-five-tick-exact.txt)): 10 of 21,345 rows fail at
  age 80 and none at 81, and none at any age tried from 81 to 130. The second program confirms 80 and 81 at depth two, and 81 and 82 at depth one.
- **Only one start needs checking.** From age 2 the depth-two start with −1 white reaches only rows of the one with −1 black (`age_two_start2`), so the search runs
  over the start 1 1.
- **Six ticks** ([output](data/claudeIntel-six-tick-exact.txt)): failures at 81, 100, 105 and 107 (408 of 172,938 rows), and none at 108, 110 or 120. Only the
  packed program ran here, since the second one is too slow at 4,096 registers. It is the program that reproduced three, four and five ticks.
- **No visible pattern.** The steps between thresholds are 16, 7, 41, 9 and 27. So far the large steps come at even k.

## 2. The finite check (COMPUTED)

[claudeIntel_four_tick_exact.py](claudeIntel_four_tick_exact.py) ([output](data/claudeIntel-four-tick-exact.json)) enumerates every row of the depth-two start
under every wall:
- a row is an integer with bit j at site −(j + 1);
- one tick with wall bit w is `(r >> 1) ^ (r | r << 1 | w)`;
- the set is deduplicated after each tick.

It then tries all 256 four-layer registers on every row: each predecessor's bits at −1 and 0. A row passes when every fourth predecessor is black at `f + 4`,
white from `f` to `f + 3`, and every layer is white at `f − 1` and `f`, so white further west.

| Age | Rows | Rows that fail (depth two) | Depth one at age + 1 |
|---:|---:|---:|---:|
| 66 | 6,307 | 9 | 9 |
| 69 | 8,050 | 9 | 9 |
| 70 | 8,801 | 11 | 11 |
| 71 | 9,662 | 14 (1,664 row–register pairs) | 14 |
| 72 | 10,582 | **0** | **0** |
| 73–76 | 11,567 to 15,276 | 0 | 0 |

- **Other depths.** Depths three and four fail at 71 (20 and 19 rows) and pass at 72, as the reduction says they must.
- **Second program.** [claudeIntel_four_tick_exact_second.py](claudeIntel_four_tick_exact_second.py) ([output](data/claudeIntel-four-tick-exact-second.txt)) shares no
  code: edge-first tuples, the literal rule table, and the registers as the bits of Python integers. It gives the same counts.
- **Agreement with N27's sampling.** N27 found failures at every age up to 71 (depth two) and 72 (depth one), and none in about 1.5 million samples beyond.

## 3. I267's four age-75 words

| Depth | Rows at 75 | Distinct width-73 edge bands | Any of the four words present |
|---:|---:|---:|---|
| 1 | 12,667 | 2,794 | no |
| 2 | 13,928 | 1,970 | no |
| 3 | 18,065 | 1,663 | no |
| 4 | 22,546 | 1,393 | no |

- **No depth can reach them.** By the column argument, every band at depth at least two is a depth-two band, and the depth-two bands are depth-one bands. Both inclusions hold
  in the data.
- **Where they break.** Each word agrees with some physical band on its first 64 cells from the edge and on no more. Its last nine cells come only from the cover's free
  eastern bits.
- **The relaxed test on them.** It fails for 192, 64, 192 and 128 registers respectively.

## 4. Where I267's cover lost the gap

| Age | Width | Physical bands | I267's cover | Physical bands failing I267's relaxed test |
|---:|---:|---:|---:|---:|
| 60 | 58 | 551 | 1,246 | 4 |
| 70 | 68 | 1,227 | 3,012 | 4 |
| 71 | 69 | 1,346 | 3,326 | 4 |
| 72 | 70 | 1,485 | 3,651 | **0** |
| 75 | 73 | 1,970 | 4,967 | 0 |

- Every physical band lies in I267's cover, so the cover is sound.
- The cover's free eastern bit is, in fact, one fixed column (site −m−2) taken as an arbitrary wall tape from age 31. That column is not arbitrary, and the cover
  is two to two and a half times too large.
- The register relaxation costs nothing: with the exact bands, arbitrary east-end registers already pass from 72. Narrower bands do not suffice. At age 72 every
  width below 70 has one to eight physical bands that fail the relaxed test.

## 5. The Lean module

[Rule30DrivenLeftDepthTwo.lean](four-tick/Rule30DrivenLeftDepthTwo.lean), `91e5145c…`, core Lean. It imports the kit's `Rule30DrivenLeft` and `Rule30EveryKLine`,
and N27's `Rule30DrivenLeftFourLower` for the witnesses.

*Checks*, on my kit build `ebda8ce`:
- It compiles in 4 s with no warnings.
- The stock checker passes five headlines (`two_classes`, `exactAt_of_two`, `exactAt_two_of_one`, `L_column`, `four_tick_least_ages`): 84 constants,
  `propext` and `Quot.sound` only, no new axioms ([receipt](four-tick/depth-two-stock.json)).
- A missing headline fails ([control](four-tick/depth-two-negative.json)).
- `leanchecker` passes in 17 s.
- Its 29 imported kit modules equal kit main `389bede`, except `Rule30PeriodTwoSideways`, which it does not use.

**Not yet in Lean: the check itself, `ExactAt 4 2 72`.** I tried a kernel computation: the reachable rows as numbers in a bit trie, and the 256 registers as the
bits of one number per layer. It agrees with the compiled evaluation (10,582 rows; all pass at 72; 14 fail at 71). But the kernel's time doubles about every
three ticks (3 s at age 31, 35 s at age 40), because it re-evaluates the lazily built sets. That extrapolates to many hours at age 72. A certificate needs
literal checkpoints of the row sets, or another encoding.

## 6. Next

- **A kernel certificate for `ExactAt 4 2 72`.** With it, `four_tick_least_ages` becomes the sharp four-tick theorem outright, and `two_classes` is a general
  result for every k. Together they would make a submission. The cheapest route I see stores the row sets as packed literals at checkpoint ages and checks each
  stage from literals. This host's memory is the constraint; the M5 is better placed.
- **Seven ticks** by the same search would need 16,384 registers at an age above 108, where there are 185,272 rows and more than 700,000 by age 130. That is feasible in C, slow here.
- **The failing rows.** At the last failing age they share one long edge word: 18 of 25 cells for two ticks, 28 of 32 for three and 63 of 73 for four. They
  differ only near the wall. Why that word stops occurring with a usable wall end is the mechanism behind each threshold; I have not explained it.
- **Record searched:** I265, I267, N27, S23 and its kit module `Rule30DrivenLeftInverse`, K63 and the inverse review, and the kit's `Rule30DrivenLeft`. The
  kit has the time shift `L_add` but no column-as-wall lemma.
  - `find_known`, under column as wall, depth two, adjacent start, one tick later, least age and four inverse ticks, finds only P84. P84 credits S23 with
    the one-tick offset for one and two ticks, proved there by checked propagation for each case.
  - The portal's 447 entries, by title: the every-k entries (R30-20261119-ccc65f, R30-20261120-eb2bcc, R30-20261120-8dc0b3) are ours and conditional on
    CAP, which the kit records as open.
  - No entry states the reduction for every k or the four- and five-tick ages.
