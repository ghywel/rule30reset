# Where marked gaps come from

**THEOREM (Lean).** Every positive-width mark in the singleton Rule 30 spacetime descends from a black run read westward from site $-2$ to its first white neighbour. The update immediately after that run creates the white gap. Later quiet updates can record the same future black arrival again, at successively smaller widths. This gives an exact choice of which rows to count and a lower bound for the number of centre ticks of each colour. [Lean proofs](MarkLaunch.lean)

## Finding the birth

Write `Gap(s,l)` when row $s$ is black at $-l-1$ and white from $-l$ through $-1$. Lowry's `Mark(s,l)` additionally requires a black centre at $s+l$. Call the pair at $(-1,0)$ active when either cell is black. Write `Bar(t,l)` when this pair is active, $-l-2$ is white, and all $l$ cells from $-l-1$ through $-2$ are black.

For $l>0$, `next_gap_iff` gives precisely two ways to see `Gap(t+1,l)`. A quiet pair shortens an existing gap of width $l+1$ by one. An active pair creates a gap whose width equals the number of consecutive black cells read westward starting at $-2$. The cases specialize the kit's older/newborn white-run dichotomy to the fixed centre. Walking the quiet case backwards preserves the arrival time. It must terminate because the seed row has no black cap west of the centre. Thus a mark at $(s,l)$ has a most recent active tick $t<s$ with a bar of width $w\ge l$ and $t+1+w=s+l$. The gap at $t+1$ itself is marked. [Kit white-run dichotomy](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30SettledRepeats.lean) · [Lowry's marks](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30MarkedGaps.lean)

For the two width-22 marks at ages 34,429 and 2,125,919 in the existing census, the preceding rows therefore both have a white cell at $-24$, black cells at $-23,\ldots,-2$, and an active pair. An inherited mark would require an earlier width-23 mark, above the census maximum. This deduction uses the recorded census and `record_is_birth`. [Census](../marks/seed-results.md)

## Which births are marked?

On the bar row, retain the cells from $-1$ to $l+1$, continue black to their west, and compute the centre $l+1$ ticks later. The answer is exact because the entire western part of its light cone is the known bar. Thus unbounded marks are *equivalent* to arbitrarily wide bars on the singleton orbit whose eastern context passes this finite test. Combining this with Lowry's criterion gives `problem1_of_births`. This covers both edge-matching and other contexts. It still requires a full cone evaluation in general. M220's short edge prefix is a cheaper sufficient test for certain contexts. Neither supplies a proof that qualifying bars recur at unbounded widths. [M220's prefix test and limitations](../marks/claudeM5-edge-predictor.md)

## What a count would imply

* A bar at $t$ of width at least $2d$ excludes any other bar of width at least $2d$ through $t+d$. The first update clears an interval whose shrinking white interior contains site $-d-1$ at each intervening tick. A second bar would need that site black.
* If two distinct births share the arrival time and their widths in chronological order are $l,m$, then $l\ge 2m+3$. The older gap's black cap advances one cell per tick while protected by its white interior. At the younger birth it would occupy the required white flank if $l<2m+3$. In particular, birth-to-arrival times are injective among bars in any one band $[L,2L+2]$.
* Every bar of width at least six forces **both** centre colours in $[t,t+3]$, independently of the later arrival. The last black bar cell and the active pair force a black centre by $t+2$. Four consecutive black centre cells starting at $t$ require site $-3$ to be white at $t$, contrary to the bar. These four-tick windows are disjoint by the first result with $d=3$. [Kit black-triangle proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30CenterRuns.lean)

Consequently, if there are $B(N)$ distinct width-at-least-six births before $N$, the centre records at least $B(N)$ of **each** colour before $N+3$ (`birth_count_le`). A positive lower density $\delta$ of such births would bound the centre's lower black frequency below by $\delta$ and its upper black frequency above by $1-\delta$. The missing quantitative question is how often the singleton produces even this fixed western bar with an active pair. Unbounded widths alone give no rate in time. A proof of exact half density requires more.

**Disposition.** Retain the primitive-birth and counting lemmas for independent review. K92.4's recurrence question stays parked. No new census was run.
