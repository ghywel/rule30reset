# Singleton gap launches through 2²² birth ticks

There were 787,329 launches of width at least two on ticks 0,…,4,194,303. Of these, 376,457 led to a black centre at the marked arrival. There were 49,123 launches of width at least six. The widest marked birth had width 22 and occurred twice, at ticks 34,428 and 2,125,918. The gaps appeared one tick later, reproducing the two existing mark onsets.

| Birth ticks [start, end) | Falls at −2 | Width ≥2 launches | Width ≥6 launches | Width ≥2 with black arrival |
|---|---:|---:|---:|---:|
| 262,144–524,288 | 65,680 | 49,259 | 3,053 | 23,427 |
| 524,288–1,048,576 | 131,002 | 98,064 | 5,955 | 46,887 |
| 1,048,576–2,097,152 | 262,380 | 197,291 | 12,279 | 94,363 |
| 2,097,152–4,194,304 | 524,346 | 393,534 | 24,688 | 188,130 |
| Entire observation, 0–4,194,304 | 1,048,953 | 787,329 | 49,123 | 376,457 |

In the four registered shells, width-at-least-two launch rates ranged from 18.7042% to 18.8151%. Width-at-least-six rates ranged from 1.1358% to 1.1772%. Both registered predictions passed. The overall fall rate at −2 was 25.0090%. The whole-line fair spatial law would give 3/16 and 3/256 for the two launch observables. Those numbers serve as benchmarks. The measured singleton fractions establish finite counts only. [Registration I322](https://github.com/ghywel/rule30reset/commit/1b45d94)

The input was the K92.4 singleton archive, with its original SHA-256 checked before reading. At a tick with an active (−1,0) pair, the gap recorded at the next tick equals the launch width. To check the four-cell interpretation independently, solve the physical update at −1 for the bit at −2 at two successive ticks. A width-at-least-two launch coincided exactly with a fall at −2 and an active pair on every row. A separate packed whole-line evolution checked the reconstructed west bit, the fall and the active launch widths through the first 8,192 updates. [Frozen census program](birth_census.py) · [Observation layout and archive](../marks/seed-results.md)

Run `python birth_census.py observations.u32le` using that archive. The LF stdout SHA-256 is `64a89c72ed9a71cde2e96cb20f6743fa0441c7a932d229e41b5ce8b66b6e1e92`. The corresponding proof target is a positive lower rate, or even a superlogarithmic count, at arbitrarily large cutoffs. [Count inequalities](launch.md)
