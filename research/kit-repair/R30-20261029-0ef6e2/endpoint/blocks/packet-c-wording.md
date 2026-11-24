# Author's wording for packet c

claudeIntel, N15 addendum 1 and N17, 24 November 2026. For claudeM5, who builds the packet. The owner, 24 November, on S11: "Say so in
S19". Nothing here has been read by a second worker. Link targets in `{…}` are claudeM5's to fill.

## The sentence on the golden entry (essay, *Earlier work*; PROVED in Lean)

> Our {golden half-circle theorem} has one angle and every phase. It says less about Rule 30 than its text suggests. Beside an
> alternating column the right neighbour is never black at two white ticks in a row, by two steps of the rule, and the golden
> half-circle word is black at two consecutive indices as late as wanted, at every phase. So that exclusion holds in every
> row, with or without a leftmost black cell, and does not need the repeats. What remains of that entry is its theorem on
> the word: the repeats it finds at every phase.

Check: [claudeIntel_S11_two_steps.lean](../claudeIntel_S11_two_steps.lean), 4 s against kit main, three standard axioms:
`no_two_black` (any row, any column), `two_black` (every `GoldenLine`, any start) and `golden_neighbour_from_two_steps`, which is
`no_eventual_golden_neighbour` without its hypotheses on the row. It stays beside the entry and is not part of it.

For the pull request text, *Beside the kit*, one clause: "`Rule30GoldenHalfCircle` has the half-circle words of one angle; their
exclusion needs only two steps of the rule".

## Title

> Two blocks set in the order of an irrational rotation do not stand beside an alternating column, in a Rule 30 row with a leftmost black cell

## Abstract

> Turn a circle by an irrational angle and ask at each step whether the point is in a fixed arc, starting on the orbit of an end of the arc. Let the two answers stand for two nonempty finite blocks of black and white readings, of any lengths, set in the order of the answers. Take a row of Rule 30 with a leftmost black cell and a column that alternates from some tick on. Then the column to its right, read at the white ticks, is not this concatenation from any tick on, for any irrational angle, any arc and any two blocks (`rotation_blocks_excluded`, over the real numbers; `blocks_excluded`, `gap_order_excluded`, in integers). The reason concerns words: the concatenation has repeats at unbounded lags, as late as wanted, short by at most a constant (`arc_long_squares`), and `corollary_F` of `Rule30ClockNearSquares` forbids this beside a clock. An example: gaps 3, 5, 5, 5 and 3, 5, 5, 5, 5, 5 between black readings, in the order of the parities of the floors of t√2 (`silver_blocks_excluded`). Not shown: that any right half reads such a word. Many orders are impossible for every right half, some only on wide strips; the example passes 44 columns, a finite test. The words of one arc themselves are not new here: two black readings in a row never occur, and known rules leave only block codes of Sturmian words. Core Lean; the real forms need Mathlib. Other starts stay open; nothing here excludes an alternating centre.

## What leaves packet b

- Headlines: `half_circle_near_squares`, `half_circle_block_excluded`, `half_circle_excluded`, `sturmian_excluded`,
  `one_arc_excluded`, `no_eventual_arc_neighbour`, `silver_excluded`, `rotation_excluded`.
- "Free starting phases … stay open" for the words of an arc, and the paragraph on three letters modulo 3.
- The section *The word repeats near its beginning* can stay if it says that it is about words. Its half-circle picture beside the
  clock should become the picture of the example (blocks of 18 and 28 readings).

## What enters

- Headlines, in this order: `rotation_blocks_excluded`, `blocks_excluded`, `gap_order_excluded`, `arc_long_squares`,
  `silver_blocks_excluded`, `arc_near_squares`, `arc_excluded`, `rotation_block_excluded`, `sqrt_line`, `irrationalLine_iff`,
  `phaseLine_iff`, `phaseLine_one_exception`.
- A section *What is not new*, from [README.md](README.md), before the theorem's proof.
- A short section *Not shown* (N17), before the example: no right half that reads one of these words is known. The strip figures from
  README, each marked as finite: N15's example dies at width 40, the present one (gptIntel's, I233) survives width 44 by two
  programs at 300 white ticks a width and 49 by one, and 15 of 21 other orders survive 42.
- In *Earlier work*, the sentence above, Lowry's bounds with the two figures of [claudeIntel_nearest.py](claudeIntel_nearest.py), and
  AIOvernight's nine pairs.
