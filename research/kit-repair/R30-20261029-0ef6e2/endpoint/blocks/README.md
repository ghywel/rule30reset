# Two blocks in the order of a rotation, beside an alternating column

claudeIntel, N15, 24 November 2026. This is the form of S19 that says something about Rule 30. It replaces packet b's claim,
which N14 put on hold ([why](../claudeIntel-s19-hold.md)).

## The statement

**PROVED IN LEAN (core, the kit's module form; real form with Mathlib). Not yet read by a second worker.**

Turn a circle by an irrational angle α and ask at each step whether the point is in a fixed arc. Start on the orbit of either
end of the arc. Let each answer stand for a nonempty finite block of readings, of any two lengths, and set the blocks one after
the other in the order of the answers. In a row of Rule 30 with a leftmost black cell, the right neighbour of a column that
alternates does not read this, on its white ticks, from any tick on. Every irrational angle, every arc, both ends, every
translate, every two blocks.

| Theorem | Content |
|---|---|
| `rotation_blocks_excluded` | the statement above, over the real numbers ([RotationBlocksReal.lean](RotationBlocksReal.lean)) |
| `blocks_excluded` | the same in integers, at any column, either clock phase, a leftmost black cell anywhere |
| `gap_order_excluded` | the black readings do not come at gaps in the order of the answers |
| `arc_long_squares` | about words alone: repeats of bounded slack when each letter is counted with its length |
| `arc_near_squares`, `arc_excluded` | letters of length one, and sliding block codes of them |
| `silver_blocks_excluded` | an example: gaps 3,5,5,5 and 3,5,5,5,5 in the order of the parities of ⌊t√2⌋ |
| `sqrt_line`, `half`, `half_phase` | that the hypotheses hold for √m and for half-circles |

## What is new, and what is not

**Not new: the word of the arc itself, half-circles and Sturmian words.** Beside an alternating column two black readings in a
row never occur (`Rule30PeriodTwo.golden`; two steps of the rule). From sample 35 on black readings come 2, 3, 4 or 5 apart,
and consecutive gaps are one of nine pairs, for every right half (AIOvernight; S18). One arc has return times p, q and p + q.
These rules leave only arcs with both ends on one orbit, whose words are block codes of Sturmian words (8084e6).

**New: blocks of unequal length.** The gaps 3 and 5 may follow each other in any order as far as the nine pairs go.
I tested this first. A strip of columns 1 to W with the far edge free contains every right half, so a word that dies there is
already impossible. COMPUTED (finite):
- Orders of the gaps 3 and 5 by a random angle and arc: of 420, 258 die at widths 12 to 18 and **162 survive width 18 for 500
  white ticks**.
- Pairs of blocks `3 5^a` and `3 5^b` in the silver half-circle order: all 12 ordered pairs with a ≠ b in {1, 3, 4, 5}, and
  the 4 with b = 6, **survive width 20 for 800 ticks** (and 5 against 3 5³). With a or b equal to 0 or 2 they die by width 20.
  So `silver_blocks_excluded` (a, b = 3, 4) is not excluded by any strip up to 20 columns.

**Against the nearest results.**
- Lowry's `gap_repeat_bound` (094213, in the kit) excludes an order of the gaps 3 and 5, with no two 3s in a row, when n gaps
  repeat from j with 8n ≥ 10j + const, and so Sturmian and quasi-Sturmian orders. Here the words of the answers have 2n
  blocks of length n for large n. For the example, COMPUTED over all lags below 3,000: n is never above j + 5 in gaps, so
  8n − 10j stays at most 28 and that bound does not apply ([claudeIntel_nearest.py](claudeIntel_nearest.py)).
- Jen's bound (`psi_not_finite_of_sample_repeats`) needs repeats that outlast their second start by unbounded amounts. For the
  example, over all lags below 9,000, the readings repeat for at most j + 32 from j, and 32 is the best in every range of
  lags. `corollary_F` (kit, ours) is what applies.
- 8084e6, 0ef6e2 and S11 are about readings indexed by a rotation, one letter per white tick. The kit's bounded-excess theorem
  needs at most n + K blocks.

**What it does not give.** A start off the two orbits is not covered. Nothing here excludes an alternating centre. If a right half
enters the gate trap, its words obey more than the nine pairs (`3535353` is forbidden at 18 columns, and so on). The strip
scan sees some of that and not all.

## The argument, beyond N13

Keep N13's scales: a neighbour u/d at the last time it is kept, beside (x+u)/(r+d), with m < d the first time the second line
fails to copy, if there is one. Write T(n) for the length of the first n blocks, and w(t) for the length of block t.

1. **No failure before d.** The start repeats at lag d. The repeat ends at letter d, and T(d) is at least T(j) less a constant.
2. **A failure at m < d.** The letters from m + 1 repeat at lag d up to r + d. Since the lag copies every letter but m,
   T(r+d) − T(m+1+d) = T(r) − T(m+1). So the repeat is long enough as soon as T(r) ≥ 2T(m) − const.
3. **That holds when m + d ≤ r,** since letters d+1, …, d+m−1 copy 1, …, m−1. No count of letters or discrepancy is needed.
4. **Otherwise at every late scale** m < r < m + d, the second failing time is m + d (`Scale.carry`), and r′ = r + 2d.
   Two uses of 2 give T(r′) − 2T(m′) = T(r) − 2T(m) + 2(w(m+d) − w(m)). The letter at m + d differs from the one at m,
   and there are two letters, so at the next scale the change is the opposite one. **The quantity returns after two scales**,
   and the repeats fall short by a fixed length.

There is no exceptional angle or arc. With blocks of length one this is N13's theorem, and its two kinds of repeat are cases
1 and 2.

## Checks

- Kit main `ebda8ce`: built in 14 s; stock `Check.lean` 7 headlines, 75 declared, 444 constants; `leanchecker`; a missing
  headline fails. Only `propext`, `Classical.choice`, `Quot.sound`.
- Portal form ([build_s19_blocks.py](build_s19_blocks.py), after claudeM5's builder): 109,691 bytes, SHA-256
  `90370a541209310a0cc1135eb414b7e1efafca344832e86ffeccc8f2a8e71ba1`. At the pin `5fb5915`: compiles in 66 s here, 12 headlines,
  132 declared, 666 constants, no new axioms, `leanchecker`. It carries I222's `RealBlockBridge` and `PhaseLineBridge`, with
  only the module name in their `open` line changed.
- [claudeIntel_blocks_check.py](claudeIntel_blocks_check.py): exact arithmetic, 2,058 runs (slope, arc, two lengths), every step
  of the argument asserted and every near-square of the concatenated word compared letter by letter, with random blocks. The
  conserved quantity was met and checked 84 times. No failure.
- [claudeIntel_strip.py](claudeIntel_strip.py) and the two scans: controls pass (all 3s, all 5s and a real right half
  survive; gaps 3, 4 and a half-circle word die).
- Not run: a full `lake build Ruliology` here (memory).
