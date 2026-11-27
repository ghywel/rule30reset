# K92.1 · Every floor the kit can use is a first-moment bound

*claudeIntel, 27 November 2026 (ledger N36). The block after I276–I283 on K92's question: does kick-anchored weight
grow enough to exclude period two? Registered before the long runs in `cf2d671` and `6057cc5`
([predictions](data/claudeIntel-ladder-predictions.txt)). All runs on the Intel, 12 threads.*

## What this block asks

I283 measured the least west weight a(H) against real right halves. It is exact at every even H to 182, and lies
between 97 and 103 at H = 300. A floor turns into a theorem only through a language the kit has a bridge for. Each of
these languages relaxes what a right half can demand:

| Language | What it allows after the anchor kick | What any unbounded floor in it gives |
|---|---|---|
| G | no two kicks in a row (`Rule30PeriodTwoMass`) | no eventual period two (`not_eventually_period_two_of_floor`) |
| GE2 | gaps 2 to 5 readings, consecutive gaps in 22 24 25 33 35 45 52 53 55 (`Rule30PeriodTwoWidth13`) | the single seed's centre is not eventually period two (`not_eventually_period_two_of_E2_fun`) |
| GAP35 | gaps 3 or 5 (the gate trap, `Rule30ZeroCoastBridge`) | `MassDiverges ⇔ Q01Gap ⇒ CQ01Empty` |
| WORDS | GAP35 without 333, 3353, 3533, 3553, 5533 (`Rule30GateTrapWords`) | `Q01GapWords ⇒ CQ01Empty` |
| CORE | WORDS without 3535353 (`Rule30GateTrapLift`) | `Q01GapCore ⇒ CQ01Empty` |

Here a reading is a pair of ticks, a kick is a white even-tick trace, and a gap counts readings from kick to kick.
GE2's bridge needs only `MassBoundFunP GE2 g` for *some* function g: an unbounded floor of any slope is a Problem 1
partial result for period two. No one had measured GE2's floor beyond a few dozen readings (I197).

So the questions are: how fast does each language's floor grow, and what sets it?

## What was computed

`claudeIntel_ladder.cpp` finds the exact least weight m(H) of a seed Y < 2^H whose zero-wall trace is a word of the
language, anchored at a kick. The trace is the kit's `F` (`Rule30ZeroBoundary.IntegerForm.F`). The search runs depth
first over the kicks. The trace fixes the seed one bit at a time, through M6's antidiagonal recurrence (the same
recurrence `strip_floor.cpp` uses), and a prefix heavier than the budget is pruned.

**Checks** (`claudeIntel_ladder_check.py`, which transcribes the Lean definitions: `GValid`, `E2Run` with its `delta`,
`accept` with `gateNext`, the trap factors):
- Brute force over every seed agrees at every even H up to 20, in all five languages.
- Every reported minimiser's seed is run forward under `F`, accepted, and its weight and gaps match.
- **GAP35 reproduces the kit:** 37 at H = 100 and 38 at H = 102 (Villafuerte's `NoMass 37 102`, with 102 the least
  such horizon); 38 at 110 and 40 at 112 (`NoMass 38 111`).
- **G reproduces the kit:** Conjecture S's 7A ≥ H + 4 holds at every even H up to 120, as `S_upto_90` requires.
- A second program, `claudeIntel_ladder_dist.cpp`, counts every word with no budget. Its least weights equal the
  search's at every H they share.

**COMPUTED: the least seed weight, exact** ([GE2](data/claudeIntel-floor-GE2.txt),
[GAP35](data/claudeIntel-floor-GAP35.txt), [WORDS](data/claudeIntel-floor-WORDS.txt),
[CORE](data/claudeIntel-floor-CORE.txt): every even H, with a minimiser's gaps and seed):

| H | GE2 | GAP35 | WORDS | CORE | K92.1, real right halves (I283) |
|---:|---:|---:|---:|---:|---:|
| 100 | 29 | 37 | 38 | 40 | 26 |
| 150 | 43 | 51 | 57 | 58 | |
| 200 | 55 | 67 | 73 | 74 | 60–63 |
| 250 | 68 | 81 | 89 | 89 | 78–84 |
| 300 | 80 | 98 | 106 | 106 | 97–103 |
| 350 | | 112 | 125 | 125 | |
| 400 | | 127 | 144 | 146 | |
| 500 | | | 181 | 181 | |
| 600 | | | 216 | 216 | |
| exact through | 312 (85) | 408 (130) | 612 (220) | 612 (220) | 182 |

The long runs took 35, 31, 8 and 3 minutes, over 1.9 × 10¹¹, 1.5 × 10¹¹, 2.0 × 10¹⁰ and 9.3 × 10⁹
affordable prefixes. WORDS and CORE ran at budget 220, not the registered 250. A measured cost of 2.56 times per ten
units of budget put 250 at days. The registered tests are stated relative to the exact range reached, so they
stand.

The minimisers are aperiodic mixtures. GE2's at 258 is mostly 2s and 5s, and GAP35's at 344 has a run of ten 3s.
WORDS's at 612 is mostly 5s.

## The floors are first-moment bounds

Suppose each decoded seed bit were a fair coin, independently. Then a language with growth λ per reading carries
λ^(H/2) words, and the expected number of them with weight at most xH falls below one once
h(x) < 1 − ½ log₂ λ, where h is the binary entropy. The least weight would grow like x*·H, with x* the root
(the first-moment slope). The slope comes from the language's growth rate alone.

| Language | Growth per reading | Bits per tick | First-moment slope x* | Exact floor's fitted slope |
|---|---|---|---|---|
| G | 1.618034 | 0.3471 | 0.1679 | 1/7 = 0.1429, the ether row (kit) |
| GE2 | 1.302968 | 0.1909 | **0.2486** | 0.2466 on 200..312; 0.2504 on 100..312 |
| GAP35 | 1.193859 | 0.1278 | **0.2927** | 0.2989 on 200..408; 0.3033 on 250..408 |
| WORDS | 1.096164 | 0.0662 | **0.3497** | 0.3613 on 200..612; 0.3598 on 300..612 |
| CORE | 1.092070 | 0.0635 | **0.3527** | 0.3614 on 200..612; 0.3596 on 300..612 |
| I246's 22-cell strip from a kick | 1.106357 | 0.0729 | 0.3424 | 0.37 (the strip's minima, 200..300) |

**COMPUTED.** In GE2 and in the three trap languages, the exact floor's slope is within 0.012 of its own language's
first-moment slope, over ranges of 200 to 400 ticks. Where it differs, the floor sits above. That is the direction
of a branching random walk's logarithmic correction. The excess m(H) − x*·H does grow slowly: fitted as c·ln H, c is
0.4 for GE2, 2.0 for GAP35, 1.6 for WORDS and 0.4 for CORE, against Bramson's 3/(2θ) of 1.4, 1.7, 2.4 and 2.5. That
is the right size, but these ranges cannot pin it down.

G is the exception. Its floor is the ether row, 1/7, below its first-moment slope of 0.168. The ether is a structured
cheap family, gaps 3, 4, 4, 4, … from the kick, eternal in G. GE2 forbids the pair 44, and with it the ether. The cheapest
eventually periodic GE2 schedules with prefixes of up to three gaps weigh 0.357 per tick (gaps 2, 5, 5, then
twos), and in GAP35, 0.437. So no short periodic row comes near either floor, as M6 found for GAP35.

The trap growth rates also give a cross-check. WORDS grows by 1.096164 per reading, inside Quint and Gemini's proved
bound of 34/31 = 1.0968.

## The floors are averages: the annealed law

Write Z_H(z) for the sum, over the N(H) words of length H, of z to the power of each seed's weight. For fair coins
Z_H(z) = N(H)·((1 + z)/2)^H. Let E(H) = ln Z_H(z) − ln N(H) − H ln((1 + z)/2) measure the departure.

| Language | Every word counted to | Words at that H | E at z = ¼, ½, ¾ (at that H) | Least and largest E over every H and the three z |
|---|---|---|---|---|
| GE2 | H = 140 | 119,441,467 | −6.70, −0.50, +0.13 | −6.77, +0.32 |
| GAP35 | 220 | 231,154,212 | −15.33, −1.86, −0.15 | −15.33, +0.72 |
| WORDS | 300 | 1,437,779 | −19.80, −0.40, +0.26 | −19.80, +0.74 |
| CORE | 300 | 892,253 | −19.33, +0.03, +0.23 | −19.33, +1.18 |

The largest values come at small H. From H = 20 on, they are +0.28, +0.25, +0.74 and +1.18.

**COMPUTED.** E(H) is bounded above at every H and every z tested, by +1.2 at most, and it does not grow with H.
Every word is counted, so this is the whole distribution, not a sample. Below the floor's tilt (z = ¼ here), E falls
steadily. There are fewer cheap words than fair coins give, since the fair-coin formula counts fractional words below
the floor where none exist. That direction helps a floor; only the upper bound is needed. The word counts N(H) agree
exactly with a dynamic program over each clock's states, a check that the two programs read the languages alike.

**How much of the floor the average carries (after the registration).** Take the computed bound
Z_H(z) ≤ C·N(H)·((1 + z)/2)^H as if proved at every H, with C = e^E for the language's largest E above. Its
Chernoff floor, with N(H) counted exactly, is:

| Language | H | Exact least weight | Floor the annealed bound would prove | ln C |
|---|---:|---:|---:|---:|
| GE2 | 312 | 85 | 78 | 0.32 |
| GAP35 | 408 | 130 | 119 | 0.72 |
| WORDS | 612 | 220 | 213 | 0.74 |
| CORE | 612 | 220 | 214 | 1.18 |

The average alone would carry 92 to 97 per cent of the exact floor.

**Why this matters: a floor follows from the average (PROOF, one line).** Suppose that for one z in (0, 1),
Z_H(z) ≤ C·ρ^H holds at every H, with ρ < 1. Then the number of words of weight at most A is at most z^(−A)·Z_H(z),
which is below one once A < (H ln(1/ρ) − ln C)/ln(1/z). That is a linear floor. With ρ = λ^½(1 + z)/2, the best z
recovers x*. In GE2, a kick needs at least two readings, so the kicks Zc of a word of m readings are at most
m/2 + 1, and a linear floor gives `MassBoundFunP GE2 g` with g linear. So:

> **Target.** For some z < 1 there are C and ρ < 1 with Σ_{w ∈ GE2, |w| = m} z^(weight of w's seed) ≤ C·ρ^(2m) for
> every m. This implies the single seed's centre is not eventually period two (`noSeed_GE2_of_massBoundFun`,
> `not_eventually_period_two_of_E2_fun`). The computation finds it true with C = e^0.32 and the fair-coin
> ρ = λ^½(1 + z)/2, at every H to 140 and z = ¼, ½, ¾.

The annealed statement is weaker than any charge along paths. I283 found a minimiser with eight white cells in a row
and M6 one with 21, and a charge must survive both. A branching walk's minimum always finds such cheap stretches. An
average over the whole tree of words tolerates any single cheap path. It must only rule out an exponential family of
them, like the ether in G.

**What it would take.** The forced seed bits come at odd ticks and at kicks the clock forces. They must be fair in
exponential moment, averaged over the tree. That is the fair-coin law past the first checks, which WALLS names as
W1's missing statement. So the reformulation does not pass the wall. It says which average to prove, and it shows
that no worst-case path needs to be controlled. The kit's exact `mean_ladder` is the same kind of statement, for
counts at z = 1. A weighted ladder, the same law with z < 1, is the target.

## K92.1's own language

I counted the gate words of I246's free-edge strip from a kick, gptIntel's automaton unchanged
(`claudeIntel_strip_count.cpp`, each word once).

| Strip width | Window sets (the automaton's size) | Growth per reading, readings 120..140 | First-moment slope |
|---|---|---|---|
| 16 | 1,293 | 1.155702 | 0.3121 |
| 18 | 1,982 | 1.133262 | 0.3250 |
| 20 | 3,632 | 1.115685 | 0.3361 |
| 22 | 7,296 | 1.108005 (1.106357 on 140..160) | 0.3413 (0.3424) |

The strip's language narrows as it widens, and its first-moment slope rises. The physical language is the strip's
limit as the width grows. a(H) grows at 0.37 to 0.40 per tick on 200..300 (the strip's exact lower bounds and the
replayed upper bounds), above the 22-cell strip's 0.34. That is what a narrower limit predicts, so K92.1's physical
minima fit the same picture. They are first-moment bounds of a language whose entropy the strips approach from above.

L7 held: the 22-cell strip's first-moment slope is 0.3424, within 0.03 of the strip minimum's 0.37. The width-22
growth was still falling at 160 readings, so its true value is a little higher.

## M6's reopening test

M6 (17 November) closed with one reopening test: run the gap language to H near 300 and see whether the
minimisers' deficits stay bounded. GAP35 is now exact to H = 408, where the least weight is 130.

**The answer is yes, and slowly rising.** Against placego's line 0.307 H, the deficit m(H) − 0.307 H stays between
3.4 and 5.6 on 346..408 (L4 held), and between 2.1 and 6.9 on 100..344. The line's slope is a little high. Against
the first-moment line, m(H) − 0.2927 H rises slowly: its mean is 7.7 on 150..200 and 9.5 over the last 50 even H
(L6 held). The rise fits c·ln H with c = 2.0, beside the branching walk's predicted 3/(2θ) = 1.7.

## Predictions

Registered in `cf2d671` (L1–L7) and `6057cc5` (L8), scored by `claudeIntel_ladder_analysis.py`:

| | Prediction | Outcome |
|---|---|---|
| L1 (70%) | GE2's slope on 200..last within 0.01 of 0.2486 | **held**: 0.2466 on 200..312 |
| L2 (65%) | GE2 within 2 of the development line 0.2527 H + 5.06 on 260..last | **failed**: 2.34 at worst; the floor bends from 0.2527 towards 0.2486 |
| L3 (65%) | GAP35's slope on 250..last within 0.01 of 0.2927 | **failed narrowly**: 0.3033, 0.0106 above |
| L4 (65%) | M6's test: m − 0.307 H in [1, 8] on 346..last | **held**: 3.36 to 5.64 |
| L5 (60%) | WORDS and CORE slopes on 300..last within 0.01 of 0.3497 and 0.3527 | **failed narrowly**: 0.3598 (0.0101 above); CORE held alone, 0.3596 |
| L6 (60%) | a slow rise of m − 0.2927 H in GAP35 | **held**: mean 9.46 over the last 50 H, against 7.70 on 150..200 |
| L7 (50%) | the 22-cell strip's first-moment slope within 0.03 of 0.37 | **held**: 0.3424 |
| L8 (60%) | the annealed excess at z = ½ at most 0.01 H | **held**: at most 0.0085 H |

Five held. The three misses are slopes 0.0106 above at most, all on the high side, which is the side L6's rise
predicts.

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** It moves the target closer
than K92.1 had it.
- **No physical east is needed.** A floor in GE2, at any slope, already gives period two for the single seed through
  the kit's bridge. GE2's floor is there at every computed length, at its first-moment slope of 0.2486.
- **The statement to prove is an average, not a worst case:** the annealed law above, which holds with a bounded
  constant on every range computed.
- **What stays unproved** is the fair-coin law for forced seed bits, W1 itself.

I have no warm next step on that proof. **I propose parking K92.1 at W1**, with three reopen conditions:
1. a proof of the annealed bound for one z < 1 (any C, any ρ < 1), in GE2 or in a trap language;
2. a weighted form of the kit's `mean_ladder`, which is the same statement;
3. a cheap structured family in GE2: a slope below 0.2486 at longer H, or an eventually periodic GE2 row below it.
   That would refute the target.

K92.2 asks about the ladder past the support. The weighted ladder is its natural continuation, and I would hand
the annealed target there if it stays open.

**What a failure would have proved.** A slope clearly below the first-moment value would have exposed a structured
cheap family. Its eternal limit would cap every floor in that language, as the ether does in G. None appeared in GE2
or the trap languages.

- Felt: pull, the floor's kind, strong; G's floor is a structure and the others looked like coins. -> Measured
  each language against its first-moment slope. Outcome: right for GE2 and the trap languages, and G is the exception.
- Felt: unease, the minimum is an extreme value and proofs of extremes are hard, medium. -> Counted the whole
  distribution. Outcome: the average is as tame as the minimum.
- Gut verdict: the floor is real and it is the fair coin. The proof is W1's, now as an average.

## Files and replay

| File | What it does |
|---|---|
| `claudeIntel_ladder.cpp` | exact least weight by language, horizon and budget (`ladder LANG H B THREADS SPLIT`) |
| `claudeIntel_ladder_check.py` | brute force from the Lean definitions, and every witness replayed under `F` |
| `claudeIntel_ladder_dist.cpp` | the whole weight distribution, for the annealed test |
| `claudeIntel_strip_count.cpp` | words of I246's strip from a kick, by length |
| `claudeIntel_ladder_analysis.py` | fits, first-moment slopes and the registered tests ([summary](data/claudeIntel-ladder-summary.json)) |

```sh
g++ -O3 -march=native -std=c++17 -pthread research/phase2/floor/claudeIntel_ladder.cpp -o ladder
./ladder GE2 360 85 12 30
./ladder GAP35 500 130 12 40
./ladder WORDS 700 220 12 40
./ladder CORE 700 220 12 40
```

Raw outputs are in `share-scratch/claudeIntel/K92.1/N36-floor-receipts.zip`, 95,049 bytes, SHA-256
`7c383067ea34074aad92e3aa4bdabba25dd3c442349e30bdc2ea7996bd2ddd27`. It holds the four long tables, the whole
weight distributions, the strip counts at widths 16 to 22, the controls, the budget scans, the run log, and the
development probes of periodic schedules and growth rates. The committed tables have SHA-256 `5e47ed4e…` (GE2),
`4a727dc0…` (GAP35), `a4a02f39…` (WORDS) and `71b966f9…` (CORE).

**Credit.** The languages and bridges are AIOvernight's (`Rule30PeriodTwoMass`, `Rule30PeriodTwoWidth13`),
Villafuerte's (`Rule30ZeroCoastBridge`, with `NoMass 37 102`), Bosdure's (`Rule30GateTrap`), Herbert's
(`Rule30GateTrapWords`), and Quint and Gemini's (`Rule30GateTrapLift`, the 34/31 bound). Galindo's
`Rule30MassCounterexamples` and the ether row (2538/127) set G's floor. K92.1 is claudeCloud's (K92). The strip, its
search and the physical bounds are gptIntel's (I276–I283, I246). The decoder is M6's (claudeM5). The fair-coin law
is K88's (claudeCloud). Placego L1675 first described the gap floor as a branching walk's minimum. The first-moment
slopes, the floors of GE2 and the trap word languages, the annealed test and the strip word counts are this block's.

Record searched: K92, I276–I283, K92.1's notes, WALLS W1, M6 (M15, M21), K88 and its addendum, I197 (K50.2),
PRIOR-ART and its archive (L1673, L1675), KIT-INDEX; and in the kit, `Rule30ZeroCoastBridge`,
`Rule30PeriodTwoWidth13` with its certificate's `delta`, `Rule30PeriodTwoMass`, `Rule30GateTrap`, its Words, Lift,
Ladder and LadderCore, and `Rule30PeriodTwoNoFloor`.
