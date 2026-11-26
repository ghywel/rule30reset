# The largest terminal census on the actual seed

claudeIntel, N26, 26 November 2026. This answers the owner's "continue with research block as in I257 - the seed-side pair density". I257 left it as gptIntel's
pull: "a mean at a terminal width must count disjoint, transported pairs in Galindo's precise sense." I255 had recorded "We do not have actual abundance on the
seed." Everything here is **COMPUTED** unless it says otherwise.

## The question

Galindo's census ([`Rule30TerminalCensus`](https://github.com/WolframInstitute/Rule30PrizeKit/blob/bd5ec59/lean/Ruliology/CellularAutomata/Rule30TerminalCensus.lean))
works at a terminal width s over N ages. At each depth r < s it takes a list of pairs of ages (t, u) with the following properties:
- the endpoints at one depth are disjoint, and t + r and u + r are less than N;
- the singleton rows at t and u agree on sites 0, −1, …, −(s − 1) and differ at site −s (`Fork s t u`);
- the centre cells agree at ticks t + i and u + i for 0 < i ≤ r.

With M pairs in all, 4^M ≤ H(s)^N. S22 (`Rule30TerminalHearing`) turns this into a test for Problem 1: a density M/(sN) of at least 1/7 at unbounded widths
suffices. With M191's seven-cell estimate, 1/8 would suffice, and Galindo's own test used 3/20.

## The exact maximum

At one depth, the ages that can be paired fall into classes keyed by the s west cells at t and the r centre cells after t. A pair joins the two values of cell −s
inside one class, so each class is a complete bipartite graph, and the most disjoint pairs is the sum over classes of min(n₀, n₁). The total over depths is
therefore the **largest census density D(s, N)** the seed allows, with nothing chosen by hand.

[claudeIntel_seed_census.py](claudeIntel_seed_census.py) evolves the singleton bit-packed for 2^22 ticks and keeps cells 0 to −24 at every age.

| Control | Result |
|---|---|
| A separate big-integer simulation | agrees on all 25 cells for the first 3,000 ages |
| The centre column | starts 1101110011000101100100111, OEIS A051023 |
| The census graph built from Galindo's definitions, solved by a general maximum matching (networkx) | equals the min-sum in all 68 cases: N = 40, 90, 160 and 300, widths 2, 3, 5 and 7, every depth |

## Results

The largest census density D(s, N) on the seed, N = 2^k ages:

| N | s = 2 | s = 4 | s = 6 | s = 8 | s = 10 | s = 12 | s = 14 | s = 16 | s = 18 | s = 20 | s = 22 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2^8 | 0.439 | 0.366 | 0.232 | 0.097 | 0.030 | 0.006 | 0.004 | 0.000 | 0.000 | 0.000 | 0.000 |
| 2^10 | 0.470 | 0.436 | 0.341 | 0.229 | 0.092 | 0.026 | 0.005 | 0.000 | 0.000 | 0.000 | 0.000 |
| 2^12 | 0.488 | 0.473 | 0.434 | 0.348 | 0.205 | 0.080 | 0.021 | 0.005 | 0.001 | 0.000 | 0.000 |
| 2^14 | 0.490 | 0.479 | 0.461 | 0.421 | 0.334 | 0.193 | 0.077 | 0.022 | 0.006 | 0.001 | 0.000 |
| 2^16 | 0.496 | 0.490 | 0.481 | 0.461 | 0.412 | 0.318 | 0.182 | 0.071 | 0.020 | 0.005 | 0.001 |
| 2^18 | 0.498 | 0.497 | 0.492 | 0.480 | 0.455 | 0.404 | 0.306 | 0.173 | 0.066 | 0.018 | 0.005 |
| 2^20 | 0.499 | 0.498 | 0.496 | 0.490 | 0.478 | 0.451 | 0.395 | 0.294 | 0.163 | 0.062 | 0.017 |
| 2^22 | 0.499 | 0.499 | 0.498 | 0.495 | 0.489 | 0.475 | 0.447 | 0.388 | 0.283 | 0.155 | 0.058 |

Only powers of two were tried. From width 10 to width 20 the density first reaches 1/7 at exactly N = 2^(s+2), four ages per possible west word:

| s | least 2^k with D ≥ 1/8 | least 2^k with D ≥ 1/7 | least 2^k with D ≥ 3/20 | D at 2^22 |
|---:|---|---|---|---|
| 8 | 2^9 = 2^(s+1) | 2^9 = 2^(s+1) | 2^9 = 2^(s+1) | 0.495 |
| 9 | 2^10 = 2^(s+1) | 2^10 = 2^(s+1) | 2^11 = 2^(s+2) | 0.493 |
| 10 | 2^11 = 2^(s+1) | 2^12 = 2^(s+2) | 2^12 = 2^(s+2) | 0.489 |
| 11 | 2^12 = 2^(s+1) | 2^13 = 2^(s+2) | 2^13 = 2^(s+2) | 0.483 |
| 12 | 2^13 = 2^(s+1) | 2^14 = 2^(s+2) | 2^14 = 2^(s+2) | 0.475 |
| 13 | 2^14 = 2^(s+1) | 2^15 = 2^(s+2) | 2^15 = 2^(s+2) | 0.464 |
| 14 | 2^15 = 2^(s+1) | 2^16 = 2^(s+2) | 2^16 = 2^(s+2) | 0.447 |
| 15 | 2^17 = 2^(s+2) | 2^17 = 2^(s+2) | 2^17 = 2^(s+2) | 0.422 |
| 16 | 2^18 = 2^(s+2) | 2^18 = 2^(s+2) | 2^18 = 2^(s+2) | 0.388 |
| 17 | 2^19 = 2^(s+2) | 2^19 = 2^(s+2) | 2^19 = 2^(s+2) | 0.341 |
| 18 | 2^20 = 2^(s+2) | 2^20 = 2^(s+2) | 2^20 = 2^(s+2) | 0.283 |
| 19 | 2^21 = 2^(s+2) | 2^21 = 2^(s+2) | 2^21 = 2^(s+2) | 0.219 |
| 20 | 2^22 = 2^(s+2) | 2^22 = 2^(s+2) | 2^22 = 2^(s+2) | 0.155 |
| 21 | beyond 2^22 | beyond 2^22 | beyond 2^22 | 0.099 |
| 22 | beyond 2^22 | beyond 2^22 | beyond 2^22 | 0.058 |

At every width the density climbs toward 1/2, which is the most any census can have (each age is in at most one pair per depth). Each doubling of N moves the
curve about one width out.

## Why so few ages suffice

The classes are few. At depth r there are exactly 2^s·m_r classes, where m_r is the average number of centre futures that one west word allows:

| r | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m_r | 1 | 1.5 | 2 | 2.5 | 3.125 | 3.875 | 4.719 | 5.695 | 6.801 | 8.045 | 9.428 | 10.967 | 12.668 |
| m_r / m_(r−1) | | 1.5 | 1.333 | 1.25 | 1.25 | 1.24 | 1.218 | 1.207 | 1.194 | 1.183 | 1.172 | 1.163 | 1.155 |

m_r depends only on the cells within r of the centre. It is the exact count of pairs (west cells 0 to −r, the next r centre cells) over all 2^(2r+1) windows,
divided by 2^(r+1). On the seed at width 8 with 2^20 ages, the class counts at depths 0 to 7 are 256, 384, 512, 640, 800, 992, 1,208 and 1,458. That is
2^8·m_r exactly, so the seed shows every class there can be at that width. At width 12 and depth 11, 2^20 ages show 44,110 of the 44,922.

The centre's next bit is forced whenever the centre is black, and otherwise it takes one bit from the east. The ratio starts at 1.5 and falls slowly, to 1.155
at r = 12. It is nowhere near 2. A census at depth r near s therefore needs a few times 2^s·m_s ages, not 2^(2s).

## Is cell −s ever predictable?

Inside each class, compare the observed imbalance Σ|n₀ − n₁| with its expectation if cell −s were a fair coin:

| s | r | classes | observed / fair coin |
|---:|---:|---:|---:|
| 6 | 0 | 64 | 0.981 |
| 6 | 1 | 96 | 0.996 |
| 6 | 2 | 128 | 1.027 |
| 6 | 3 | 160 | 1.034 |
| 6 | 4 | 200 | 1.007 |
| 6 | 5 | 248 | 1.020 |
| 8 | 0 | 256 | 0.959 |
| 8 | 2 | 512 | 0.959 |
| 8 | 4 | 800 | 1.001 |
| 8 | 6 | 1,208 | 0.970 |
| 10 | 0 | 1,024 | 0.984 |
| 10 | 2 | 2,048 | 0.995 |
| 10 | 4 | 3,200 | 0.982 |
| 10 | 6 | 4,832 | 0.982 |
| 10 | 8 | 6,964 | 0.988 |
| 12 | 0 | 4,096 | 0.993 |
| 12 | 3 | 10,240 | 1.002 |
| 12 | 6 | 19,328 | 1.005 |
| 12 | 9 | 32,947 | 1.004 |

With 2^22 ages the ratio lies between 0.96 and 1.04 in every case, which is what a fair coin gives. (With 2^20 ages it was 0.84 to 1.00, a little more
balanced than a coin at width 6.) There is no sign that cell −s is predicted by the nearer west cells and the centre's future.
[Balance data](data/balance.json).

## What this shows, and what it does not

- **It is not a proof.** The test needs unbounded widths. A census at one width only gives H(s) ≥ 4^(M/N) = 2^(2 D s). That is weaker than what the same rows
  show directly: all 2^s west words occur for s ≤ 16 within 2^20 ages.
- **The margin is large.** The seed gives densities near 1/2 where the test needs 1/7. So the obstacle is entirely in proving abundance, not in the hearing
  constant. A better hearing base, for example M191's 1/8, changes nothing on the seed's side.
- **Where the hypothesis sits (PROOF-SKETCH).** Suppose the (2s + 1)-cell windows of the seed's rows around the centre had uniform limiting frequencies along the
  ages. Then cell −s would be independent of every key, since the centre's future up to r < s does not reach it. Every depth would give 1/2, and D(s, N) would
  tend to 1/2 at every width. That is abundance at every density below 1/2. But window uniformity proves Problem 1 by itself: the centre cell P ticks later is
  the cell at −P XOR a function of the others, so under uniformity it agrees with the present centre half the time, and a period P would make it agree always.
  So window normality implies abundance, which implies Problem 1 by S22, but normality reaches Problem 1 without the census. The census earns its place only
  if abundance is proved some other way, through the transported pairs themselves.
- **The census can be nearly lossless.** At density 1/2 its bound reads H(s) ≥ 2^s, the true vocabulary. So the method is not where precision is lost.

## Replay

```
python -I claudeIntel_seed_census.py simulate 22 OUTDIR    # 18 minutes on the Intel
python -I claudeIntel_seed_census.py census OUTDIR 22      # 3 minutes
python -I claudeIntel_seed_census.py classes
python -I claudeIntel_seed_census.py balance OUTDIR
python -I claudeIntel_seed_census.py control
```

The full tables are in [data](data/).
