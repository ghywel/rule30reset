# A light proof of I66's three streams, and the closed set behind it

claudeM5, ledger M156, 24 November 2026. gptIntel's result is I203; this is a second proof for every right half, built at the owner's word.

**The statement.** Beside an alternating column, sample at the white ticks. The kick is the first cell, the net the first cell xor the
second, and the black net the first cell without the second at the next black tick. Then:
1. **The local law.** The net is complemented at every white tick that is not a kick, and it was white just before a kick. So the net of
   a kick is black exactly when its next kick is an even number of white ticks later. Two successive nets are equal exactly at an odd kick.
   This holds for every right half, from the first white tick, with no hypothesis beyond the alternation. (`law_of_alt`, `odd_of_equal_nets`,
   `net_of_return`)
2. **A closed set.** 777 windows of twelve cells at a white tick; a half in it stays in it. There its gate reads none of ten words, which say
   that gaps are 2 to 5, seven of the sixteen pairs do not occur, and 2, 2, 5 does not occur. (`stays`, `clean_of_set`)
3. **Entry.** Every right half enters it, or its kicks come once in four for ever. (`every_half`, `enters_or_four`)
4. **The decoders.** After entry, nine consecutive white nets give the kick at index 6 (counting from 0). The black nets at indices
   k+1 and k+5 give the odd-kick marker at k+1. They are four black samples, or eight Rule 30 updates, apart. In the set the next kick
   after an odd kick is three or five white samples later. (`kick_of_white_nets`, `odd_of_black_nets`, `odd_iff`)
5. **Periodicity.** In the set the gate, the white net and the odd kicks are eventually periodic together, and so is the gate when the
   black net is. (`periodic_together`)
6. **The single cell.** If its centre alternates from some time onward, masked Jen puts it in the set, and each of these streams is
   aperiodic. Lowry's net and shell agree on white samples and are complements on black samples. Each phase of each observable is
   therefore aperiodic. (`both_phases`, `odd_kicks_aperiodic`, `lowry_odd_return`)

The [S17 path review](gptIntel-s17-path.md) and [Lean companion](Rule30ArrivalsPeriodicity.lean) extend point 5 to every alternating
right half and give two finite initial rows showing why the nine-reading test in point 4 needs a restriction.

**What is new, and what is not.** The gate language, and "every right half is eventually in it or reads pure fours", is the width-13
certificate of AIOvernight (`Rule30PeriodTwoWidth13.path_run`, 16,384 nodes, any right half). The three streams on the single cell, the
marker tests and the decoders are gptIntel's (I203). What is added is the closed set and its entry dichotomy, a local law of six cells in
place of the six-cell strip search, and the cost. (An earlier reading in M155 and §7 of [claudeM5-i66-read.md](../claudeM5-i66-read.md)
called the every-half form stronger. The content was already in the kit's certificate.)

**Cost.** The whole file is 99,328 bytes and builds in **9 s** on the M5 against the pin `5fb5915`, where I203's chain takes about 62 s.
The table has 207 time sets and 810 branches, and its walk closes in 5,860 steps.

| Check | Result |
|---|---|
| Compile at the pin, and stock `Check.lean` | pass; 14 headlines, 279 declared, 513 constants replayed, no new axioms |
| `leanchecker` (4.35) | pass |
| Tamper controls | changing a kick word, dropping the word for 2, 2, 5, and reversing the clock each fail to compile |
| [make_table.py](make_table.py) | regenerates the table byte for byte; the Lean's walk is the proof |
| 300 random finite halves of up to 40 cells | all in the set by white tick 21, and stay (a check on the definitions, not evidence for the dichotomy) |

**Not claimed.** That the single cell's centre alternates. A bound on the time of entry: the 47 windows outside can be left late. That a half
that reads `1000` for ever exists. That the 777 is the least closed set.

## Reproduce

```text
python3 research/arrivals/light/make_table.py t.json
python3 research/arrivals/light/build_light.py t.json Rule30ArrivalsLight.lean
python3 research/arrivals/light/check.py                real halves and the windows of the closed set
```

The portable file is `Rule30ArrivalsLight.lean`, with namespace `Rule30ArrivalsLight`. Rename it to `Rule30Submission` for the stock
checker, with headlines every_half enters_or_four stays clean_of_set kick_of_white_nets odd_of_equal_nets odd_iff net_of_return
odd_of_black_nets periodic_together both_phases odd_kicks_aperiodic lowry_odd_return single_enters.
