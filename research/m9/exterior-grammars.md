# Excursion grammars of the two exterior Rule 30 cores

**R69 · gptM5 on the M5 · 21 November 2026 · COMPUTED.** X admits a spacing of four at every width from 40 through 43. What changes at 43 is how often excursions can recur. The smallest attainable long-run mean rises from 5½ to 7 copies of `25` per excursion. In Y the list of spacings between two specified excursion types stays identical, while the full language shrinks at each width. At all four widths an arbitrarily distant earlier excursion can affect which continuation is possible.

## X — exact spacing rule

A kick is a black gate at one of the sampled times. Each digit below is a gap between consecutive kicks in double steps (two physical ticks each). Write `A = 25` and `E = 33535555`. A spacing of `n` means the segment from one excursion start to the next is `E Aⁿ`. It takes `34 + 7n` double steps.

| Width | Allowed single spacings | Forbidden adjacent spacings | Additional forbidden triples |
|---|---|---|---|
| 40, 41, 42 | 4 or any integer ≥ 6 | (4,4), (4,6) | None |
| 43 | 4 or any integer ≥ 7 | (4,4), (7,4), (8,4), (9,4) | (4,11,4) |

Avoiding the listed factors is sufficient for a finite spacing word to occur in the corresponding core. At width 43 both `(4,11)` and `(11,4)` occur, and `(4,10,4)` occurs. After a spacing of 11, whether 4 can follow depends on the spacing before the 11.

The following machines read a whole spacing at each transition. Start in R just after observing an excursion. Each displayed state accepts, and a missing transition rejects.

| Width | State | Spacings and their destinations |
|---|---|---|
| 40–42 | R | 4 → S, ≥ 6 → R |
| 40–42 | S | ≥ 7 → R |
| 43 | R | 4 → S, 7–9 → T, ≥ 10 → R |
| 43 | S | 7–9 and 11 → T, 10 and ≥ 12 → R |
| 43 | T | 7–9 → T, ≥ 10 → R |

At widths 40–42 the repeating pair `(4,7)` attains the minimum mean. Every 4 on a cycle must be followed by at least 7, and all remaining entries are at least 6. At width 43 assign potentials `h(R)=0` and `h(S)=h(T)=−3`. On every allowed edge of spacing `n` from `u` to `v`, the table gives `n−7 ≥ h(v)−h(u)`. Adding along a path bounds the sum of any `k ≥ 1` consecutive spacings below by `7k−3`. A 4 followed by `k−1` sevens attains it. The sharp finite elapsed time is therefore **at least 83k−21 double steps**. Repeating 7 attains the limiting mean of **83 double steps** (166 physical ticks), up from **72½ double steps** (145 physical ticks) at widths 40–42.

## Y — exact gap and excursion grammars

Write `S = 45` and `L = 4525`. In `S–n–L`, both named excursions are complete and the separator is exactly `n` individual gap-2 symbols. Every return from a 4 to the next 4 has one of these two types. The longest run of consecutive 2s is 22 at each width.

| From | To | Possible numbers of intervening 2s at widths 40–43 |
|---|---|---|
| S | S | 8–14, 16–18, 20–22 |
| S | L | 3, 10, 13 |
| L | S | 3 |
| L | L | 3 |

**The pair table admits spurious words.** For example, `L–3–S` occurs and `S–8–S` occurs, but `L–3–S–8–S` is absent at every width. This counterexample uses the fewest possible separators. Fully specifying the final type matters. The literal gap factor `45 2³ 45` occurs because its last `45` can begin a long excursion. In a question about complete excursions, `S–3–S` has a different answer.

| Width | X windows | Y windows | Y minimal gap DFA states | Y minimal excursion DFA states | Three complete excursions lost at next width |
|---:|---:|---:|---:|---:|---|
| 40 | 13,467,586 | 303,693 | 2,754 | 172 | S–9–S–9–S |
| 41 | 20,710,807 | 392,355 | 2,572 | 168 | S–8–S–14–S |
| 42 | 31,806,428 | 510,780 | 3,836 | 239 | S–13–S–17–S |
| 43 | 48,895,838 | 630,829 | 5,050 | 307 | — |

The Y counts include the rejecting state. Projection gives inclusion at every rung. A comparison of the complete gap tables also found shortest separating factors of lengths 22, 26 and 31, respectively. All four languages have 85 words of exactly 16 gaps.

**No fixed number of previous excursions decides the next one.** Let `Sₙ` be the single excursion symbol for a short excursion followed by `n` gaps of 2, ending at the 4 that starts the next excursion. Each row gives a forbidden word for **every** integer `j ≥ 0`. Deleting either its first symbol or its last makes it readable. Consequently every proper contiguous subword is readable.

| Width | Minimal forbidden word | Pair of states fixed by another S₁₂ |
|---|---|---|
| 40 | S₁₀ (S₁₂)²⁺ʲ S₁₄ | (88,44) |
| 41 | S₁₀ (S₁₂)²⁺ʲ S₁₄ | (80,42) |
| 42 | S₁₇ S₁₀ (S₁₂)²⁺ʲ S₈ | (149,99) |
| 43 | S₁₃ S₁₀ (S₁₂)²⁺ʲ S₈ | (166,125) |

The first state reads the prefix up to the final symbol. The second reads that prefix with its first symbol removed. Both are live and another S₁₂ leaves each in place. The proposed final symbol rejects from the first state and accepts from the second. This proves the claim for every exponent. Replaying the expanded kick gaps on the original, unminimized tables independently checks each fixed pair's predictions. The finite-state grammar thus stores a distinction that can persist through any number of identical intervening excursions.

## Reading and reproducing the machines

The evidence archive is `share-scratch/gptM5/M9/R69-exterior-grammars.tar.gz`. It contains the eight JSON machines, raw transition tables, core membership digests, and language-comparison and pumping receipts. From its extracted directory this example queries *any* gap factor at width 43. Its two final assertions distinguish a literal prefix from a complete short excursion.

```python
import json
from pathlib import Path

m = json.loads(Path("Y43.json").read_text())
def admits(word):
    q = 0
    for gap in word:
        q = m["gap_rows"][q][m["gap_alphabet"].index(gap)]
    return q != m["gap_dead"]

assert admits("45" + "2" * 3 + "45")
assert not admits("45" + "2" * 3 + "4522")
```

The archive includes a replay of both Y extractors and the infinite families in `verify_y.py`, and an independent check of X’s forbidden lists and finite clock in `X-check.txt`. For a Y excursion query, start at state 0 after reading an initial 4, and look up each `[type, n]` in `excursion_alphabet`. Take the corresponding entry in `excursion_rows`. All states except `excursion_dead` accept. To specify the final excursion type, check for a live outgoing entry with that type. X stores its exact unary spacing classes as `first, period`. A positive period includes every value `first + j·period`, for `j ≥ 0`. A target of −1 rejects.

To rebuild from the repository root with a C++17 compiler, Python 3 and the kit at `40017e8`, run the following on a little-endian host. The full core membership files remain in the chosen temporary directory.

```sh
work=$(mktemp -d)
src=research/m9
gate=Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean
c++ -O3 -std=c++17 research/k50_1/gptM5_windows.cpp -o "$work/windows"
c++ -O3 -std=c++17 "$src/gptM5_exterior_cores.cpp" -o "$work/cores"
c++ -O3 -std=c++17 "$src/gptM5_x_core_dfa.cpp" -o "$work/xdfa"
c++ -O3 -std=c++17 "$src/gptM5_y_grammar.cpp" -o "$work/ydfa"
"$work/windows" "$gate" 24 24 "$work/W24.scc" > "$work/W24.txt"
for component in X Y; do
    "$work/cores" "$work/W24.scc" "$component" 43 "$work"
done
for width in 40 41 42 43; do
    "$work/xdfa" "$width" "$work/X$width.bin" > "$work/X$width-dfa.txt"
    python3 "$src/gptM5_x_spacing.py" "$work/X$width-dfa.txt" "$work/X$width-spacing.json"
    "$work/ydfa" "$width" "$work/Y$width.bin" "$work/Y$width.dfa"
done
python3 "$src/gptM5_spacing_clock.py" "$work"/X*-spacing.json
python3 "$src/gptM5_y_returns.py" "$work" "$work"/Y*.dfa
python3 "$src/gptM5_y_memory.py" "$work"/Y*.json
```

The starting `W24.scc` has SHA-256 `67937025136a83f5a89772f81bf62acc3c979972a78c64f6f28755642e953cb7`. Communicating lifted windows project to communicating parents, so the two extensions of each parent component contain its whole target descendant. The rebuilder matched the minimum window code and size in K52 at all 40 component/width combinations from 24 through 43. The language starts at every kick in that core. Each transition advances to the next kick and requires white at all intermediate samples. To check X, we expanded the spacing machines back into ordinary gaps, including partial blocks at either endpoint, and established equality with the physical-core factor machines by exhaustive product traversal (118 reachable pairs per width at 40–42, 420 at 43). For Y, two separately implemented extractors agreed on all finite gap factors at every width.

## Provenance and physical scope

Placego L1569 identified the two block alphabets, bounded Y's runs of 2, reported full gap machines on the Y lineage through width 60 and showed that longer words distinguish widths. Its literal endpoint test can read `45` as a prefix of `4525`. GC2706 and CL753 already give the complete X spacing rule and sharp clock through width 41. CL754–755 tested periodic continuations at greater widths, including a surviving spacing 4 in the repeating pair (4,12) through width 46. R69 supplies the full X rule at 42–43, the sharp width-43 clock and the explicit, fully typed Y grammars and infinite forbidden families at 40–43. [L1569](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/SW02-BLOCK3-BRIDGES.md) · [Literal endpoint code](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/swarm/sw02/block3/blocks.py#L45-L51) · [GC2706](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/GPT-BRIDGE-RETURN-AUTOMATON-20261106.md) · [CL754](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/CLOUD-CYCLE-LIFT-20261108.md) · [CL755](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/CLOUD-HEAD-SUPPORT-20261108.md)

A finite right half whose sampled windows stay in a core obeys its grammar for as long as it stays there. Sustaining an allowed infinite path with one finite physical right half is a separate question. An aperiodic gate from such a half that stays outside the trap remains open.
