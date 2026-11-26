# Carrying read of I267, and four ticks from below

claudeIntel, N27, 26 November 2026. It answers I267's REVIEW flag and the owner's "continue pull K50.3 research and review". Packet
`share-scratch/gptIntel/K50.3/I267-three-or-more-wall.zip`, `e2c9799c…`, 90,034 bytes, read back. Its extension, replay, builder and note equal the committed
files. The kit form regenerates byte for byte from S23's sealed source (`0256092b…`).

## Verdict

**Three ticks: PASS.** The Lean says what [three-or-more-wall.md](three-or-more-wall.md) says, and the three points asked all hold: the quantifiers, the
restart, and the same-wall witnesses. My own computation, with no shared code, confirms the finite content.

**Four ticks, new (PROVED IN LEAN): the least ages are at least 72 and 73.** I267 computes 76 and 77 as upper bounds, so the answer lies in [72, 76] for starts at
least two sites from the wall and [73, 77] beside it. A physical search finds failures up to 71 and 72 and none after (COMPUTED). I predict that 72 and 73 are the
true values.

## 1. The three-tick theorem

**Quantifiers. Right.**
- `three_step_predecessor_edge` takes any wall `Nat → Bool`, any start with its leftmost black at −m, and any t ≥ `threshold m + 23`, which is 31 or 32.
- It also takes any three rows a, b, c that satisfy the Rule 30 equation at every negative site. Their values at site 0 are never constrained, so each
  predecessor chooses its own wall bit.
- The conclusion is the exact edge: c is black at f + 3 and white everywhere west of it, where f = −m − t (`edgePosition`). The wall convention matches S23:
  `L c s t 0 = c t`, so a predecessor of the age-t row has the age-(t − 1) wall bit at site 0.
- `three_tick_least_age_nonadjacent` and `…_adjacent` are stated as "iff 31 ≤ age" and "iff 32 ≤ age", uniform over every m in the class.

**Restart. Right.** The proof restarts at q = t − 23 ≥ `threshold m`, where S23's `good_band_of_age` gives one of the two good eight-cell bands (200 or 222) at
every such age. The stages then add 6 + 4 + 5 + 4 + 4 = 23 ticks, so the bound holds at every later age, not only at 31. The wall can enter a band during a stage
only while the depth is below the width, and the clamped check covers those depths. At the restart the depth m + q is at least 10 for every m and t allowed.

**Same-wall witnesses. Right.** For both witnesses:
- the predecessors' bits at site 0 equal the wall at ages t − 1, t − 2 and t − 3;
- all three equations hold at every negative site;
- the third predecessor is black at −33, west of f + 3 = −29.

The two images coincide at depth 32. The adjacent start is a one-tick delay of the other.

## 2. My own check (COMPUTED, no shared code)

[claudeIntel_three_tick_read.py](claudeIntel_three_tick_read.py), [output](data/claudeIntel-three-tick-read.txt).

- **The witnesses**, rebuilt with the literal rule. Both images match I267's constant, with edge −32. The three predecessors are exact at every negative site
  checked out to −150. Their wall bits are 0, 1, 1, as prescribed, and the third is black at −33.
- **The upper bound, by exact enumeration from the restart.**
  - At age q, take S23's good eight-cell band and leave 21 further bits free. If the wall is d ≤ 28 sites from the edge, those bits are the cells out to the wall
    and the wall bits that can still reach the final band. If d ≥ 29 they are the band's other cells, and the wall cannot reach it.
  - This fixes everything the 29-cell band at q + 23 depends on, so there is no relaxation beyond S23's two bands.
  - Over every depth from 10 to 28 and the interior, exactly **23 distinct bands** occur. All 23 give the exact edge f + 3 for all 64 starting registers.
  - They are a subset of I267's 29-word `cover29`. Later wall bits change nothing, as the light-cone argument says.
- **Control.** After 22 ticks (age 30) the same enumeration fails, as sharpness requires.
- **Not repeated: the Lean replay.** The module builds on S23's `Rule30DrivenLeftInverse`, which pulls in `Rule30TwoSidedInverse` and Hughes's large tables.
  That is too heavy for this host. I267's receipts stand: 4 headlines, 447 constants on `bd5ec59` and 952 at `5fb5915`, no new axioms, and the missing-headline
  control fails.

## 3. Four ticks: I267's computation, replayed

[claudeIntel_four_tick.py](claudeIntel_four_tick.py), [results](data/claudeIntel-four-tick.json).

| Check | Result |
|---|---|
| Regrowing from `cover29` with my own code | The width-74 cover at age 76 equals I267's `band74.txt` word for word (5,539 words); at age 75 there are 4,967 words, as I267 says |
| Relaxed four-layer test, I267's start | Passes at 76 with all 256 registers; 4 failing words at 75 |
| Same, from my exact 23-band set | Slightly smaller covers (5,379 at 76) but the same failures at every age from 60 to 75, so the cover method cannot go below 76 |

## 4. Four ticks from below (PROVED IN LEAN)

[claudeIntel_four_tick_witness.py](claudeIntel_four_tick_witness.py) searches physically. It takes a random start and a random wall, and evolves the driven half
with the literal rule. It then tries every predecessor register at the wall: four layers, two bits each, 256 in all. Given the image, each predecessor is determined
westward from its two bits at −1 and 0, so nothing is relaxed and every failure is a genuine witness. The searcher reproduces I267's three-tick witnesses (48
failing registers each, none at 31) and S23's one-tick witnesses at ages 7 and 8.

| Start | Ages with failures | Ages searched with none |
|---|---|---|
| m = 2 | every age tried from 50 to 71 (730 of 200,000 at 71) | 72, 73, 74 and 75 (200,000 each) |
| m = 3, 4, 6, 10 | 70 and 71 | 72 (100,000 each) |
| m = 20 | none found at 70 to 72 | 70 to 72 (100,000 each) |
| m = 1 | 71 and 72 (611 of 200,000 at 72) | 73 (200,000) |

Some failures keep all four predecessor wall bits equal to the prescribed wall, at 71 for m = 2 and at 72 for m = 1. None of either kind turned up at 72 or 73.
[Sampling](data/claudeIntel-four-tick-sampling.json).

**[Rule30DrivenLeftFourLower.lean](four-tick/Rule30DrivenLeftFourLower.lean)**, `2e7243db…`, core Lean, importing only the kit's `Rule30DrivenLeft` and
`Rule30EveryKLine`.

| Theorem | Content |
|---|---|
| `sharp_four_step_examples` | For a start at −2 at age 71, and a start at −1 at age 72: a wall, and four predecessors exact at every negative site with the prescribed wall bits, the fourth black on all of (−∞, −72] |
| `four_tick_age_nonadjacent` | any uniform four-tick age for starts at depth at least two is at least 72 |
| `four_tick_age_adjacent` | for the adjacent start it is at least 73 |
| `L_rowD` | the driven half equals a list computation (`stepD`, with the wall bit as the last input), at every negative site and age |

Both images have edge f = −73. The first three predecessors have their exact edges at f + 1, f + 2 and f + 3, and the fourth fails as in I267's witnesses, with a
black west tail.

*Checks.* On my kit build (`ebda8ce`) it compiles in 16 s with no warnings.
- The stock checker passes all four headlines: 117 constants, standard axioms only, none new ([receipt](four-tick/stock.json)).
- A missing headline fails ([control](four-tick/negative.json)).
- `leanchecker` passes in 28 s.
- The 29 kit modules it imports equal kit main `aaaefdd` except `Rule30PeriodTwoSideways`, which #433 extended. Built with main's version of that file, it still
  passes with 117 constants.
- [build_four_lower.py](four-tick/build_four_lower.py) writes the module from the [witnesses](data/claudeIntel-four-tick-witnesses.json). The two witnesses are
  rechecked by scalar code in `claudeIntel_four_tick_witness.py verify`.

## 5. Where four ticks stands, and the next step

The answer lies in [72, 76] for m ≥ 2 and in [73, 77] for m = 1. The pattern 8/9, 24/25, 31/32 suggests the same offset of one between the classes, which
both ends respect. **Prediction (0.8):** the true ages are 72 and 73. Two routes:
- Finding a single physical witness at age 72 to 75 would move the lower end. None turned up in about 1.5 million samples beyond 71 (1.3 million for m ≥ 2, 400,000 for m = 1 at 73).
- An upper proof needs a sharper cover than one free cell per tick: I267's growth and mine agree on every failing word from 60 to 75. A cover that tracks the
  inverse register together with the band might close the gap.

Beside the white wall, random starts fail at age 60 but not at 64 to 72. R25's computed 72 for that wall is consistent with this, and S1 proves 80.

Record searched: I265, I267, P84, S23 and S1's age-80 module, R25's seed-anchored covers, K63 and the earlier inverse review.
