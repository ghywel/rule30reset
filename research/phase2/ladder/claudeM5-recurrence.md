# K92.2 · D(n) has no recurrence and its rows are not a regular set; the wall half fixes the row

*claudeM5, 28 November 2026 (ledger M224), at the owner's word: "Update and continue a research block on K92.2 – The
next step is an exact recurrence for the distinct-row counts D(1..26), using Wolfram on the M5." Registered before
the runs in `462d261` ([predictions](data/claudeM5-recurrence-predictions.txt)). All runs on the M5.*

> **Follow-up, R141.** The saved wall-half sweep skipped n = 5 and 6. The even-pinned cubes at both
> widths have a collision between distinct full images. The full-image census and recurrence tests
> here are unaffected. [Counterexamples and exact-width reduction](wall-projection.md).

## The question

claudeIntel's N38 ([note](claudeIntel-survival-coalescence.md)) found that the seeds of the even-pin cube merge.
- **The cube.** The 2^n seeds y < 4^n beside the white wall whose trace is black at ticks 0, 2, …, 2n − 2.
- **D(n) = E(n, n, 2n).** The number of distinct rows F^{2n}(y) at the end of the support. It grows by about 1.762
  per n.
- **What it governs.** On distinct rows the checks past the support behave like fair coins, and the last survivor
  dies near log₂ D(n).

The next step N38 named: an exact recurrence for D(n). If one existed, the rows reachable at the end of the support
would plausibly form a regular set, and I320's deficit would become a question about a finite automaton.

## What was computed

[claudeM5_distinct_rows.cpp](claudeM5_distinct_rows.cpp) is written apart from claudeIntel's program:
- its own decoder;
- 128-bit rows;
- chunked sorting into a sorted global set, which reaches n = 32 in 16 GB;
- a check of the trace against the pins at every tick of every seed.

n = 32 took six minutes on ten threads. [claudeM5_recurrence.wl](claudeM5_recurrence.wl) runs the Wolfram searches.

**D(1..32) (COMPUTED,** [table](data/claudeM5-distinct-rows-32.txt) **with every count by row width).** The first 26
terms are N38's, term for term. The next six are new:

| n | 27 | 28 | 29 | 30 | 31 | 32 |
|---|---:|---:|---:|---:|---:|---:|
| D(n) | 6,648,797 | 11,709,691 | 20,615,574 | 36,284,450 | 63,851,999 | 112,339,762 |
| D(n)/D(n − 1) | 1.76189 | 1.76117 | 1.76056 | 1.76005 | 1.75976 | 1.75938 |

The ratio falls slowly and steadily from n = 26 on.

## No recurrence (COMPUTED)

[Output](data/claudeM5-recurrence-output.txt).
- **Constant coefficients.** `FindLinearRecurrence` finds no linear recurrence for D(1..N) at any N from 8 to 32.
  None of order up to 14 fits all 32 terms.
- **Subsequences and parts.** None for the even or the odd terms alone. None for the counts of rows of each width
  4n − e, for e = 0 to 3.
- **Other closed forms.** `FindSequenceFunction` finds no holonomic or closed form, and `FindGeneratingFunction` no
  rational or algebraic one.
- **A fit, not a law (MEASURED).** On n = 10 to 32, log D(n) = n log λ + β log n + c fits with λ = 1.739 and
  β = 0.32, with a largest residual of 0.011. With β = 0 the best λ is 1.768, and the largest residual 0.046. The
  slowly falling ratio looks like a power of n on top of an exponential. A constant-coefficient recurrence cannot
  produce that.

## Not a regular set (COMPUTED)

A test of regularity that does not depend on fitting:
- **The measure.** For each n, the minimal acyclic DFA of the set S_n of rows at tick 2n, as words of length 4n read
  from the wall or from depth 4n. Its level i has one state for each distinct set of continuations after i letters.
- **What a regular set would give.** If S_n were the length-4n slice of one fixed regular language, every level
  would be bounded by that language's number of states, for every n.

[Levels](data/claudeM5-dfa-levels.txt), n = 8 to 22:

| n | 8 | 12 | 16 | 18 | 20 | 22 |
|---|---:|---:|---:|---:|---:|---:|
| D(n) | 127 | 1,270 | 12,807 | 40,237 | 125,401 | 390,421 |
| widest level, from the wall | 97 | 820 | 7,651 | 23,919 | 72,425 | 222,064 |
| widest level, from depth 4n | 93 | 800 | 7,430 | 22,413 | 68,667 | 206,367 |
| the cube at tick 0, from the wall | 16 | 122 | 1,231 | 3,762 | 10,430 | 22,981 |

- **The rows.** From n = 16 the widest level is 0.53 to 0.6 of the whole set, and it grows by 1.74 per n from either
  end, as D(n) does. A random set of that size looks the same. Read from either end, the widest level falls about
  0.9n letters from the wall, inside the wall half.
- **The cube itself** is not regular either: from the wall its widest level grows by 1.68 per n over 8 to 22, and
  by 1.63 over 16 to 22.

**So the rows at the end of the support form no regular set, in the sense the recurrence would have needed.** I320's
deficit does not become a question about a fixed finite automaton.

## A structural fact: the wall half fixes the row (COMPUTED)

Development checks after the registration, by
[claudeM5_wall_half.cpp](claudeM5_wall_half.cpp) ([output](data/claudeM5-wall-half.txt)).

- **On the cube, the row at tick 2n is fixed by its wall half, depths 1 to 2n.** This holds at every n tested: to
  n = 28 with even pins and to n = 24 with odd pins.
  - The wall half determines the next 2n readings c(2n), …, c(4n − 1), and is determined by them. So
    **D(n) = |V(n)|, the number of distinct 2n-letter words that can follow the support**: a vocabulary count of the
    trace.
  - The n checks past the support are the even letters of that word.
- **The outer half takes few values:** 27, 141, 645 and 1,086 at n = 8, 16, 24 and 28, rising by about 107 per n
  at the end. So the outer half carries almost no information, and the wall half carries all of it.
- **It is particular to the pinned cube.** Over all 4^n seeds of width at most 2n, a few percent of wall halves at
  tick 2n come with more than one row: 1 of 3 at n = 1, and 211 of 10,773 at n = 9. It also fails at other ages.

I have no proof. It reads as though the pins at every even tick leave no freedom outside the wall's light cone
beyond the little that the outer edge carries.

## What it means for K92.2

- **The recurrence route is closed.** There is no linear recurrence, constant or holonomic, on 32 terms, and the
  rows form no fixed regular set. D(n) needs another explanation than a finite automaton's spectral radius.
- **The structural bound has a cleaner target.** Since D(n) = |V(n)|, a bound on distinct aged rows at the end of
  the support is a bound on the vocabulary of 2n-letter trace windows after a pinned support, |V(n)| ≤ C·λ^n with
  λ < 2.
  - **What it would not give alone.** The diagonal needs the stronger statement that no word of V(n) has all n even
    letters black, which is A(n, n) = 0, and for infinitely many n that is Q01 itself (I316, I320).
  - **The gap between the two.** The data say the words of V(n) pass their even letters like fair coins (N38). A
    vocabulary bound with λ < 2, together with that fairness, would give extinction at about log₂ |V(n)| checks.
    Fairness is W1's statement.
- **A route to the vocabulary bound, untried.** The wall half is fixed by the trace window. The kit's error edge
  (`Rule30ErrorEdge`: the first difference between two rows never moves outward and heals one diagonal when its
  parent is black) is the mechanism of merging. Two cube seeds merge only if they share their outermost black cell,
  since the outer edge moves out one cell per tick, and their error edge catches the wall. A bound on how often it
  fails to catch up would bound |V(n)| below 2^n.

## Predictions

Registered in `462d261`:

| | Prediction | Outcome |
|---|---|---|
| R1 (90%) | D(1..26) equals N38's | **held** |
| R2 (85%) | no linear recurrence: the shortest fit to D(1..N) has order about N/2 and mispredicts D(N + 1) | **held in substance**: `FindLinearRecurrence` returned none at any N, rather than a fit at the data limit |
| R3 (60%) | D(n+1)/D(n) keeps falling from n = 26 and lies in [1.750, 1.762] for n = 26..29 | **held**: 1.76189, 1.76117, 1.76056, 1.76005 |
| R4 (75%) | the widest DFA level grows by at least 1.3 per n over n = 8..22, from either end | **held**: 1.74 from each end |
| R5 (55%) | read from the wall, the cube's widest level grows more slowly than the rows' | **held**: 1.68 against 1.74. From depth 4n the cube grows faster, 1.83, which the prediction did not cover |

The wall-half fact was found after the registration and is not a registered result.

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?**
- **This block closes a route.** D(n) has no finite-automaton law, so I320's deficit is not a regular-language
  question.
- **It sharpens another.** The distinct rows at the end of the support are exactly the distinct trace windows after
  it, so the structural bound N38 and I320 ask for is a vocabulary bound on one trace window.
- **It does not cross W1.** Even a proved vocabulary bound needs fairness on those words to reach the diagonal, and
  that is W1's statement.

Felt: surprise, every wall half distinct, strong. -> Tested all seeds, the odd cube and n to 28. Outcome: right,
and particular to the pinned cube. Two verdicts. Reasoned: the recurrence and the regular set are refuted on 32
terms and 15 widths (COMPUTED); the wall-half fact is COMPUTED, unproved. Gut: the vocabulary form is the useful
residue; the error edge is where a bound would come from.

My own pull: a proof that the wall half fixes the row on the cube. It looks like a short lemma about the outer edge
under pins, and it would make |V(n)| the official object.

**Next for K92.2:**
1. prove, or refute at larger n, that on the cube the wall half at tick 2n fixes the row;
2. a vocabulary bound |V(n)| ≤ C·λ^n with λ < 2, through the error edge catching the wall;
3. K92.2.A, gptIntel's sparse deadlines, stays open.

## Files and replay

| File | What it does |
|---|---|
| `claudeM5_distinct_rows.cpp` | `count n THREADS CHUNKLOG [OUT.bin]`: D(n) and D(n, W); `levels FILE L` and `cube n`: DFA level widths |
| `claudeM5_recurrence.wl` | the Wolfram searches on `D32.m` (the counts as an association) |
| `claudeM5_wall_half.cpp` | `wall_half n THREADS [PIN]`: distinct rows, wall halves and outer halves |

```sh
clang++ -O3 -std=c++17 -o distinct_rows research/phase2/ladder/claudeM5_distinct_rows.cpp
./distinct_rows count 32 10 22
```

**Credit.** The question is claudeCloud's (K92). D(n), the merging and the sequence D(1..26) are claudeIntel's (N38).
E, the deficit criterion and the request for a structural bound are gptIntel's (I320). The error edge is in the kit
(`Rule30ErrorEdge`), and F's two preimages are kit #369. D(27..32), the recurrence search, the regularity test and
the wall-half fact are this block's.

Record searched: find_known for distinct rows, merging, preimage, regular set, FindLinearRecurrence, linear
recurrence, coalesce, finite automaton and image of F; KIT-INDEX's `Rule30ZeroCoastBridge` (#367, #369; its survivor
recurrence is for another count), `Rule30PeriodTwoMass` and `Rule30ErrorEdge`; PRIOR-ART P97; N38 and its note; I316,
I320 and `research/phase2/gemini/sparse.md`.
