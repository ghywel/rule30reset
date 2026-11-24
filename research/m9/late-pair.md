# Why the trapped gate loses the pair (5, 1)

**Decision, 24 November 2026 (I224). Park M9 with the K65 sieve.** We traced the sharp cutoff to two possible spatial prefixes with finite trapped histories. We also located the update that an apparent later occurrence violates. The step from the observed gaps to those prefixes still uses a finite classification. Reopen for a derivation of that step from the gaps themselves, or an argument that predicts which other lone-1 words must disappear. S10 is already in the kit. [K65 table](data/gptIntel-sieve-final-K65.txt) · [S10](compact/README.md)

Bosdure’s trap is the closed set of 829 windows on the first 16 sites east of an alternating column, observed when that column is white. One sample spans two physical ticks. Site 1 is the gate and the low bit in every spatial code. The pair means the nine gaps `355555353` between ten consecutive black gate readings. The first and last readings are 39 samples apart. K55, K56 and I66 established that the word can begin after 11 trapped samples and is impossible after 12. I70 found that a 36-column strip with a free exterior can keep it even after arbitrarily long histories. [Discovery, certificate and strip witness](../../archive/ledgers/CHAT-LEDGER.6.md)

## The two possible starts run out of past

Allow every exterior bit to be chosen afresh at every physical tick, and keep ordinary Rule 30 on sites 1 through 36. At delay 11 exactly three 36-site windows can start the word. Two agree through site 34. Every physical occurrence with at least 11 prior trapped samples must therefore have one of the following prefixes. To use the delay-11 classification at greater ages, take the last eleven samples before the word. Trap closure supplies the initial condition.

| Required prefix at the first black reading | Start windows in the strip at delay 11 | Longest physical history from the trap, with that prefix as target |
|---|---|---:|
| First 34 sites equal 5084300695 | 5084300695 or 56623908247 | 11 samples |
| First 36 sites equal 13674235287 | 13674235287 | 10 samples |

The last column is independent of the future gate word. Given an output bit `y` and the two input bits `b,c` east of the missing input `a`, Rule 30 gives `a = y XOR (b OR c)`. Choose the eastern pair in four ways, work west, and check the wall bit. Apply this twice per sample, in reverse phase order, then discard predecessors outside the trap. Each surviving row is two sites longer than the target and has a unique forward image. This counts all finite ancestors exactly.

- The 34-site prefix has **1,351,808** trapped ancestors eleven samples back. Every one starts with the same 17 sites, code **65180**. One step further back, each of the four possible intermediate rows forces its white predecessor to have low-four-site code 6, 1, 1 or 1 respectively. The trap contains neither residue. Dropping site 17 admits a trapped predecessor with low 16 sites equal to 28110. I66’s physical seed `3802889643133324895142591828659` attains the full word at delay 11.
- The 36-site prefix has **23,803,488** trapped ancestors ten samples back. They have only two possible 22-site prefixes. For code **646567**, every predecessor is 8 modulo 64. For **1236391**, every predecessor is 936 modulo 2048. Both residues are absent from the trap. This is the very window that I70 could reach from a strip cycle of length 15. Its real trapped history ends at ten.

These two cases give a second route to the sharp cutoff. Only the first line can support a physical occurrence at delay 11. At delay 12 neither prefix can be reached.

## The failed update at site 37

There is also a direct way to see what the free exterior does wrong. In the width-36 strip at delay 12, read the triple `(site 36 now, site 37 now, site 37 next tick)`. Read it once **one physical tick before the first kick**, and again **two physical ticks after**. These are all the possibilities. Each line has a strip witness.

| One tick before | Two ticks after |
|---|---|
| 010 | 010 |
| 010 | 100 |
| 010 | 110 |
| 011 | 010 |

Every line contains `010`. A white western neighbour and a black current cell give `0 XOR (1 OR c) = 1` for either eastern bit. The black cell must persist. Enforcing just this half of the update at those two times eliminates every apparent occurrence. Either time alone admits a witness. Although this explains the failure in two local moves, obtaining the four lines still requires the 36-column history.

At the gate there is a separate one-cell signature. For a word start `s` after at least 12 trapped samples, black readings at `s, s+3, s+28, s+31` already force **site 9 white at `s+31`**. The two-return theorem requires that site to be black for the following gaps `53`. The delay-11 physical witness has it black. This identifies which known gate signal fails eight samples before the missing terminal kick. [Two-return theorem and controls](../wheel/pulse-forecast.md)

## Test of transfer and evidence

For the other certified word `355535355553`, the runs (3, 1, 4), repeat the edge test at its sharp delay 9. A 29-column strip permits it. At site 30 it suffices to forbid `010` at physical offsets +13 and +14 and `111` at +15. Enforcing only persistence with a white western neighbour at all three times still allows a strip occurrence. The second word needs the opposite colour of the western neighbour as well. A lone 5-gap on its own therefore supplies no common explanation from these two tests. The other 67 entries in the sieve have finite survival witnesses, and the entropy question stays open.

The [Python replay](gptIntel_late_pair.py) writes six DIMACS instances, checks the sharpness seed and the inverse residues, and optionally enumerates and replays the positive strip paths. CaDiCaL produced LRAT proofs for all six. Both cake_lpr and lrat-check accepted each proof. The [independent ancestor counter](gptIntel_trapped_ancestors.cpp) uses the trap list and integer Rule 30 only. Run these commands from the repository root.

```text
python research/m9/gptIntel_late_pair.py --out proof --controls
g++ -std=c++17 -O3 research/m9/gptIntel_trapped_ancestors.cpp -o ancestors
ancestors proof/trap.txt
```

The positive strip search uses python-sat. The finite histories, replayed strip paths, six formulas, proofs and checker receipts are in the shared-store packet cited in I224.
