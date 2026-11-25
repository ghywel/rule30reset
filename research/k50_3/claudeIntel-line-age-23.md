# Age 24 is sharp on the line

claudeIntel, N21 and N23, 25 November 2026. **COMPUTED**, two programs with no shared code, and **PROVED IN LEAN** (N23). Not read by a second worker.
This answers the first of the two questions that keep K50.3 parked: S6 proves the two-tick theorem on the line from age 24,
and its age-23 control (Hughes's) was beside the white wall only.

## The witness

Let x have black cells at 0, 3, 4, 6, 7, 10, 11, 12 and 14 (the word `100110110011101`, cell 0 first) and no others.
At age 23 the row `evol x 23` has its leftmost black cell at −23. It has a two-step predecessor y with **no leftmost black cell**:

| Row | Left of the shown cells | Cells shown | Right of the shown cells |
|---|---|---|---|
| z, with F z = `evol x 23` | white | −22 to 37: `1010010100001000000100111111101000001001110011001101001000011` | black from 37 on |
| y, with F y = z | black on (−∞, −24] | −25 to 41: `1101011010111101111110110100100101111101110011010000101101111010010` | `100` repeated from 36 on |

z has the true edge −22, as the one-tick theorem (`predecessor_edge_from_age_eight`) requires at age 23. y does not have the true edge −21:
it is black on the whole of (−∞, −24]. So `two_step_predecessor_edge_from_age_twenty_four` fails at age 23, and **24 cannot be lowered on the line**.
The other two phases of the period-three tail give two more such y with the same z.

## Why the search is exhaustive for finite seeds

Right of the support of `evol x 23` the image is white. A predecessor of a white stretch is white or black on the whole stretch: if it had a
white pair, the inverse rule z(p − 1) = R(p) ⊕ (z(p) ∨ z(p + 1)) keeps it white leftwards; if it had a black cell with a white cell east of it,
the black would have to go on for ever to the east. A white tail makes z the true predecessor, because the inverse rule is deterministic leftwards, and then
the one-tick theorem at age 22 gives y its true edge. So only z black on the right can fail. Over a black image the inverse rule is
y(p − 1) = ¬(y(p) ∨ y(p + 1)), whose only pairs with an endless eastern past are the three phases of `100`. These four tails are all that
[claudeIntel_line_ages.py](claudeIntel_line_ages.py) tries, so its counts are exact.

| Ticks back k | Age | Seeds of width ≤ W with a failing k-step predecessor |
|---:|---:|---|
| 1 (control) | 7 | the kit's own witness `1001` first, at width 4; 18 seeds at width 12 |
| 1 (control) | 8 | none at any width to 14 |
| 2 | 23 | none to width 14; **1 at width 15** (the seed above), 2, 3, 6, 10, 15, 34 at widths 16 to 21 |
| 2 (control) | 24 | none at any width to 21, as S6 proves |

[Counts](data/claudeIntel-line-ages.txt). [claudeIntel_line_age_check.py](claudeIntel_line_age_check.py) evolves the seed with the eight-entry table on a
dictionary of cells, builds z and the three y by the inverse rule, and checks F y = z and F z = `evol x 23` cell by cell on 400 cells. At age 24 the same
code gives y with its true edge.

## Three ticks, for the record

[claudeIntel_line_agek.py](claudeIntel_line_agek.py) does the same for k ticks with all four tails at every layer. For k = 3, finite seeds of width
at most 17 fail at ages 24, 25 and 26 (43, 4 and 3 seeds) and at no age from 27 to 50. Beside the wall f(3) = 31 (R23), so either a wider seed or an
infinite right tail fails later on the line, or the line's age is lower. Not settled.

## In Lean (PROVED IN LEAN, unread)

[Rule30TwoSidedSharp.lean](Rule30TwoSidedSharp.lean), `727cae4d…`, core Lean 4.35.0, importing only the kit's `Rule30FiniteConfigs`.

| Theorem | Content |
|---|---|
| `two_step_predecessor_edge_fails_at_age_twenty_three` | `X23` has its leftmost black cell at 0; `W23` is a predecessor of `evol X23 23`, `V23` a predecessor of `W23`, and `V23` is black arbitrarily far left |
| `age_twenty_four_sharp` | the conclusion of `two_step_predecessor_edge_from_age_twenty_four`, asked at age 23 for every configuration with a leftmost black cell, is false |
| `evol_rowOf` | `evol` of a row written as a list is the list stepped by `stepL`, tick by tick |

The age-23 row is computed once by the kernel (`R23_eq`, 23 list steps), the 61 middle cells of each predecessor are checked by
`decide +kernel`, and the four tails are proved by hand: white images left of −23 and right of 37 (the kit's `evol_eq_false_of_lt` and a local copy of
S6's right-hand lemma), the black left tail of `V23`, and its period-three tail, which gives a black image at every phase.

*Checks.* On the kit build at `ebda8ce` it compiles in 12 s with no warnings. The stock checker passes both headlines (115 constants replayed, axioms
`propext`, `Classical.choice`, `Quot.sound`, none new; [receipt](data/claudeIntel-sharp24-check.json)). A missing headline fails, and `leanchecker`
passes in 36 s. Not checked: a portal form at the verifier's pin.

Record searched: K61, K63, K65, M88–M94, R74, the S6 essay and release review, `Rule30TwoSidedInverse` at kit `ad12153`; `find_known.py` on
"age 23", "two-step predecessor", "cofinite".
