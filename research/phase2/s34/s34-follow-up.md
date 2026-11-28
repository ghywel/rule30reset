# S34 follow-up on physical exterior cells and the spacing of falls

**COMPUTED.** Every 23 consecutive columns of the singleton contain a column whose falls recur arbitrarily late on both parities. Evolving one physical site beyond the 26-cell control already excludes it by Jen's theorem. Evolving up to five physical sites to the east eliminates all remaining calendars of widths 23 through 26. These are finite graph exclusions for infinite tails. The reviewed S34 source proves the one-in-27 bound in Lean. [S34 carrying review](gptIntel-carrying-read.md)

## Why the 26-cell control disappears

A column with only one cofinal falling parity has a cutoff beyond which it falls only on that parity. A column that falls only finitely often can be assigned either parity. Take a common cutoff over the strip and shift the time index to normalize the first column's parity. The width lists in S34 classify every such assignment. If a calendar were certified by its width's `GoodAny`, the physical strip would give two eventually periodic adjacent columns, against Jen. Therefore its normalized word must occur in S34's unresolved list for that width. [S34 coverage data](../modulus-two/addon/kit/Rule30Certificates/FallParityData.lean)

The single word left at width 26 is $0^6 1 0^7 1 0^{11}$, read west to east. Halve the strip. Each half is an infinite path of a finite graph and eventually stays inside one cyclic strongly connected component. To obtain a superset of its eventual rows, retain all vertices in cyclic components of each half. Join those row sets with their common parity and check actual Rule 30 edges on all 26 cells. Cuts after cells 12 and 13 give 2,326 and 2,902 candidate rows with phase respectively. Both give identical cyclic components. Two are constant, three force two periodic columns, and the remaining component has 94 nodes and no rigid column. It allows every adjacent black pair, each of KDRonald3 and Claude's seven required window sets, and the necessary six-column test from S32 at modulus four. [Half-strip and window replay](../modulus-two/survivor_obligations.py)

The 94 nodes describe possible observations in a strip with two freely chosen exterior inputs. To turn the eastern input into a physical cell, add its old state to each node, give the expanded strip two exterior inputs, then apply Rule 30 to the added site just as to its neighbours. The added site can fall on either parity. The 188 candidate nodes leave just one cyclic component, with 11 nodes. All 26 original columns read a fixed bit on each cyclic class of that component. Each would consequently be eventually periodic, which Jen rules out for any two of them. The former free input could supply histories that its own Rule 30 update cannot sustain.

Repeat this extension with S34's other unresolved calendars. The rule for discarding components is sound on the singleton for two reasons.

- Rule 30 makes a fall exactly when both the site and its western neighbour were black. No singleton column is eventually constant, so every specified adjacent black pair recurs arbitrarily late. Each eventual component must support all those black pairs.
- For a component of period $d$, every edge moves one cyclic class forward modulo $d$. A column that is constant within each cyclic class repeats with period (d) on a path in that component. Two such columns contradict Jen.

| Constrained columns | Normalized calendars left by S34 | Least east padding that rules out each calendar |
|---:|---:|---|
| 26 | 1 | 1 |
| 25 | 2 | 1, 3 |
| 24 | 4 | 1, 1, 3, 4 |
| 23 | 6 | 1, 1, 1, 3, 4, 5 |
| 22 | 7 | 1, 1, 1, 3, 4, 5, one unresolved |

The width-22 word $0^6 1 0^7 1 0^7$ survives nine added cells on either side separately. This is a surviving case of the finite graph test. Its occurrence on the singleton remains open. The result applies to a translated strip at any integer position. The specified site −2 remains open. [Physical extension replay](../modulus-two/survivor_extensions.py)

## Two columns in every 27

**COMPUTED.** Every 27 consecutive columns contain two distinct columns, each with cofinal falls on both parities. The lower spatial density is at least $2/27$ by partition into disjoint bands of that length. S34 alone gives $1/27$. These bounds measure the distribution of qualifying columns across space.

If a band of length $n$ contains only one qualifying column at offset $j$, and each band of length $b$ must contain one, then $n-b \le j \le b-1$. Start with $b=27$ from S34. The physical extension lowers it to $b=23$. Its two flanks are entirely one-parity calendars and must be on the appropriate S34 lists. Work out the cyclic components available to each side. Shift either calendar to match its absolute parity. A physical strip must give a path in the joined state space, with the middle site free to fall on either phase. Require that the eventual component support both phases of a middle fall and every black pair. When used on a full-width component, Jen additionally excludes two rigid readings anywhere in the band.

- At width 53 there is only one normalized calendar on either flank. The two relative phase choices have 9,032 and 8,640 nodes. The joined graphs are acyclic even when membership in the two 94-node sets supplies the only calendar constraint. Their longest paths are six and five updates. The central nine-cell restriction independently gives acyclic graphs for both phase choices.
- The frame check projects each side onto its $k$ sites next to the middle. It gives every possible local input at the ends of this $2k+1$-cell strip. A physical path projects to a path here. With recurrence obligations and $k=6$ all 5,084 distinct frame products at width 38 fail. At width 37 two products survive, in the two absolute phases of one relative arrangement. Lifting both to the full width leaves only a small cyclic component missing mandatory black pairs and with no middle falls.
- Exact lifting clears widths 37 through 33 without using Jen in the joined components. At width 32 the two remaining six-node components force periodic columns and are excluded by Jen. With the stronger one-in-23 bound and the padding test on each flank, the computation clears widths 32 through 28. The width-28 check lifts 24 full products.
- At width 27, 312 projected cases require 390 full products. Exactly two full components remain, one per global phase shift. Up to swapping parities the split is $0^6 1 0^7 1 0^7$, a free middle site, and $0^4$. The sole component for that relative choice has 530 nodes. It allows the required black pairs, both middle fall parities and all seven window sets. Evolve one more site east with its own falls unrestricted. The full join has no cyclic component compatible with black-pair recurrence, the two middle fall parities and Jen. This closes the last possible case of a single qualifying column in 27.

## Reproduction and scope

Run from `research/phase2/modulus-two` using standard Python. The scripts share S34's checked width lists, and use the fifteen S34 certificates only through those lists. The component audit uses two cuts and the bridge check uses both sink stripping and cyclic components. The lifted replay uses a different half cut, checks cellwise transitions and computes components with two DFS passes. A second run with the original half cuts and Tarjan traversal independently reproduced all four successful padding widths and the width-22 survivor. The measured bounds are graph statements and need no extrapolation on time.

```sh
python survivor_obligations.py
python bridge_survivors.py
python survivor_frames.py
python survivor_joint_obligations.py 44 33 6
python survivor_joint_replay.py 38 33 6
python survivor_joint_replay.py 32 31 6 --jen
python survivor_extensions.py 26 22 9
python survivor_extensions.py --joint 27 27 5
python survivor_extensions.py --east-join 0000001000000010000000 0000
```

I345–I351 record the registered thresholds. Combining the padding and join tests through width 27 was exploratory. The formal work remaining is to check the new physical extensions and joined graph exclusions in core Lean. The current results support a separate K92.4 carrying read and can be packaged after certification. The named-site question would need information tying a two-parity column to the seed's geometry. [Existing fixed-site criterion](../gemini/unmarked-launch.md) · [S34 add-on](../modulus-two/addon/Rule30Submission.lean)
