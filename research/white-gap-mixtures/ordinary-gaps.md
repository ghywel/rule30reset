# Ordinary one-gap transitions cut the growth rate of sparse clocks

A pulse is one black tick followed by q white ticks, with q from 9 through 16. I79 counted gap words that can recur while the right neighbor varies on the second white tick. Its strip allowed a fresh exterior bit at every tick. **Requiring each gap to come from an ordinary full-line history reduces the growth rate.** At width 27 the new rate lies between **2.8489 and 2.8490 per gap**. The old width-27 reader exceeded 2.951. [Previous strip construction](physical-padding.md).

## The physical condition

Given W initial right cells and the driver, the next H initial cells determine the entire W-cell movie over H ticks. Conversely every finite completion is realizable on an ordinary full-line configuration with the prescribed drive, by the kit’s left-permutive realization theorem. Taking H=q+1 gives the exact one-gap relation. For two consecutive gaps it suffices to retain W+B cells at their midpoint, where B is the second duration. The first gap must produce such a midpoint, and its ordinary evolution must give the prescribed endpoint. These equivalences pass Lean for arbitrary widths, durations and drives. [Kit realization](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30Realization.lean).

The evaluator splits the longest 17-tick cone at tick nine. For each distinct midpoint row it retains the union of exactly its possible eight-cell fringes. It then carries those fringes through the remaining ticks. At each width the reader keeps strongly connected components containing both second-white colors. Every nonsettling physical history eventually stays in one. For a periodic sparse column on a row with a leftmost black cell, finite-left masked Jen forces variation on that phase. All recurring input factors must therefore be readable. The lower growth rates below concern the finite reader. Existence of such a periodic column for the singleton remains open. [Cone evaluator](ordinary-cone.hpp) · [Reader](sparse-language.cpp) · [Finite-left masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean).

| Carried cells | Mixed rows | Distinct 12-gap words | Certified growth per gap |
|---:|---:|---:|---:|
| 23 | 18,929 | 14,276,699 | 3.0902–3.0903 |
| 24 | 31,169 | 11,925,161 | 3.0151–3.0152 |
| 25 | 51,079 | 10,586,416 | 2.9579–2.9580 |
| 26 | 82,756 | 9,474,016 | 2.9016–2.9017 |

The minimized width-26 reader has 311,909 states. Positive integer weights certify both endpoints of the interval, giving at most **4,730 × 2.9017ⁿ** candidate words of length n. An independent implementation enumerated the right completions directly and recovered every recurrent vertex and labeled edge at widths 10 through 19. Width 27 has 134,955 mixed rows and 1,274,279 edges. Its readable words match the old width-27 reader through length three. At length four it excludes seven of the old 1,253 words, namely (11,11,12,15), (11,15,16,d) for d in {10,15}, (16,15,12,12), and (16,15,16,d) for d in {10,12,15}. At length five it excludes 98 of 4,391. Any of the seven four-gap factors therefore excludes a periodic sparse column of arbitrary period on a finite-left row.

At width 27 a deterministic reader rooted at row 18,339,877 has 1,063,764 subset states. An integer potential h satisfies 28,489h ≤ 10,000·sum(children h) ≤ 28,490h in every state. Both inequalities were replayed directly from the archived transition table and weights. Rooted words are readable factors. Conversely, every n-gap factor can be preceded by exactly 21 letters from that root. These two inclusions give the same limiting growth rate for the entire language, between **2.8489 and 2.8490**. They also give the finite upper bound 84,583,675,468 × 2.8490ⁿ. The width-26 bound has a smaller prefactor and is useful for short words.

## What still passes this test

Start with right row 18,339,877, closest cell in the low bit. Repeat these 21 gaps.

```text
13 12 14 12 12 10 9 10 10 10 12 10 12 10 10 12 12 10 12 11 14
```

Two 258-tick readings return to the same row and differ at tick 91. Every one of the 42 transitions has an ordinary full-line witness. Either entire reading can be selected at each traversal if the exterior is refreshed between gaps. Both values at tick 91 also occur on continuous histories with the same initial 27 cells and the same periodic drive. The respective right seeds are `0xffffffffffffffff917d825` and `0xffffffffc7f9e484917d825`. [Witness data](ordinary-diamond.json).

Ten of the first reading’s 21 cyclic two-gap segments and six of the second’s are impossible on continuous histories. One five-gap segment is impossible although both four-gap sides have ordinary witnesses. All 24 minimal failures tested through length five have LRAT certificates verified by lrat-check and cake_lpr. Every positive segment has a directly replayed seed.

Thirteen consecutive copies of this word force every ordinary history into AIOvernight’s absorbing set G. The width-35 open strip retains recurrent non-G paths. Width 36 gives a sufficient bound of 263 gap intervals from any phase, and thirteen traversals supply 273. After entry, arbitrary gaps of at least nine preserve G. Every width-27 mixed row is reachable from the specified anchor in exactly 21 gaps and can return in exactly 13. Consequently **each readable n-gap word embeds at a fixed offset in a physically excluded, ambiguous clock of length n+307**. Put the 21-gap connector first, the readable word next, the 13-gap return after that, then thirteen copies of the displayed word. The injection gives these false positives the full growth rate of the stricter reader. The concrete graph, radii and capture bounds are finite calculations. The general padding inference and the independent choices have kernel proofs. [Padding argument](physical-padding.md) · [Stock G](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean).

## One hidden cell carries memory indefinitely

At width 14, use a constant gap of twelve. For a visible edge, record the fifteenth bit before and after one ordinary gap. The edge 7461→1317 forces (0,0), the loop 1317→1317 permits exactly (0,0) and (1,1), and the exit 1317→7205 forces (1,1). The entrance, any number of loops, and the exit together have no width-15 lift. Every proper contiguous piece extends inside the recurrent width-15 graph. Explicit return paths close both the zero and the one versions. Thus no test of a fixed number of consecutive visible **row-and-gap** edges recovers this projected recurrent language. The distinction uses the visible rows as well as the input letters. The ordinary seven-transition exclusion table was independently enumerated. The native and stock Lean checkers accepted the unbounded proper-factor inference conditional on this table, replaying 101 declarations with no new axioms. The read-back packet is `I81/persistent-seams.zip`, SHA-256 `fda6bf4e78d5705d8dd5ba67be031b8d2f61a6775091a2cbfafed91464a38d5a`.

## Replay

Compile the C++20 reader and run it with `16 --ordinary` in an empty directory for a small replay. Default mode reproduces I79. Source, receipts and certificates are in the private store under `share-scratch/gptIntel/I81/`. The file `ordinary-gap-kernel-7b3815469278.zip` proves the one-gap criterion. The file `gap-gluing-mixed-count-kernel-9efb64b2d5c2.zip` proves two-gap gluing and the physical word-count transfer. Filed against I79 while the ledger awaits the owner’s K57 rotation decision.

The primary read-back packet is `I81/ordinary-gap-language.zip`, SHA-256 `a279bf2d5b2da5503f874a9c3b61e8c54e27d6436c776e953f5207c540577bdb`. The independently replayable finite-alphabet simulation theorem is `I81/finite-alphabet-gap-reader-80da03b1ab0d.zip`. The two concrete Lean modules passed five stock headlines and native replay of 82 declarations with no new axioms. [Cellwise replay](check-ordinary.py).


The width-27 transition table, integer weights and verification script are in `I81/anchored-growth.zip`, read back at SHA-256 `bd1a91da56c03a8578c089ef0c16b26ddccfbc836d34b78f1963b9cad1442766`. The physical upper/lower radius analysis is in `I81/gap-radius-sharp-kernel-c8c328b1b3b4.zip`.
