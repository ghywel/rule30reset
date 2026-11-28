# K92.2 — Post-support deaths at unbounded exact widths

R142–R143, 28 November 2026. The physical width W includes the outermost black cell. A check reads the wall-adjacent cell at physical tick 2s, beginning at s=0. For a cube with W≤2n, passing its first n checks takes a row up to the edge of its support. R141 showed that excluding every row at both exact widths 2n−1 and 2n through the first 2n checks, at arbitrarily large n, implies Q01.

## An explicit family at every width

**Proved in core Lean.** For every n≥16, put m=floor((2n−3)/8). At **each** of widths 2n−1 and 2n, there are at least 2^m distinct starts passing all the first n checks and failing one of the next n.

| Exact width | First failed even check, in physical ticks |
|---|---|
| 2n−1 | Exactly 2n for every history in the family |
| 2n | Between 2n and 2n+30 inclusive. It is exactly 2n+30 for every history when n≡2029 modulo 2048. |

For example, n=2029 gives at least 2^506 rows at each of widths 4057 and 4058. Their respective first failed checks are at ticks 4058 and 4088. All broader claims below concern the bare white wall.

Choose any m-bit word as the first m **odd-time** readings, with black readings at the intervening even ticks and all later ticks on the infinite reference. At physical tick 2m this reference becomes the stationary checkerboard. At earlier ticks t≤2m its difference from that stripe is confined to depths below 1+4(2m−t). Insert this history near the wall of a finite stripe-prefix row. A stripe prefix of length at least 8m+2 lets the two rows merge at tick 2m, before the changed exterior can interfere. Different prescribed words remain distinguishable by their earlier readings. Choosing the exterior bit gives the two exact widths. The odd-width crop loses the first omitted black at tick 2n. The even-width crop uses the kit's 32-cell front and 4096-tick cycle to read its first failure. This also transfers the existing five-bit-tail bound to arbitrary such histories and each of the 32 outer tails. [StripeHistory.lean](StripeHistory.lean) · [Kit stripe-tail certificates](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ZeroBoundaryStripeFourComplete.lean)

The independent packed replay checked all 2048 residue classes and 100 pairs of physical evolutions using the base crops. The family and the sharp residue also have kernel proofs. I333 treats truncations of a different infinite row, distinguished by the alternating wall trace. [Replay](stripe_history_audit.py) · [I333](../borrowed/wall-cutoffs.md)

## Many first failures near the top of the cube

**Proved in core Lean.** In every pair of successive cube indices starting at n≥4, there is an index N in the pair and an exact width W between 2N−7 and 2N at which at least 2^N/128 distinct starts pass every earlier even check and fail at physical tick 2N. Thus one exact width near the top supplies at least one in 128 of the entire size of the pinned cube in actual first failures. The width parity can vary.

The kit's adjacent inequality forces at least 2^N/8 first failures at one index of the pair. The starts of width at most 2N−8 that passed every earlier check contribute at most 2^(N−4). The difference is at least 2^N/16. Partitioning by the last black position puts at least 2^N/128 in one of the eight exact widths. The Lean proof connects the counted event to the physical wall reading. This deduction uses the established first-check result once. It provides no decay estimate at a later check conditional on having passed the first one. [ExactShellLoss.lean](ExactShellLoss.lean) · [Kit first-check inequality](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30FirstChecks.lean)

## How many rows could still represent an immortal?

**Proved in core Lean.** At physical age t≥(3m²+11m)/2, all nonzero starts have one of at most 2^m possible outer words of length 3m+1. These are the cells nearest the growing support edge. To test membership one can enumerate exact (3m+1)-bit words and advance their autonomous edge map for m(3m+5)/2 ticks.

With the exterior fixed and its top bit at d, the eight continuations by three inward cells give at most two images after d+4 ticks. Two consecutive zero driver bits persisting for h ticks require the initial 2h bits to vanish. This cannot continue past the known black edge. A black driver resets its child. In the remaining case the next driver flips that child and forces its two followers. Iteration gives the 3m+1 band. In an immortal orbit, advancing to width W from fixed starting width b takes W−b physical ticks, and all later even checks still pass. Hence it suffices to prove mortality for rows meeting this band test at sufficiently late exact widths of each parity. [Two-cell lemma](EdgePair.lean) · [Three-cell bound](EdgeTriple.lean) · [Q01 criterion](ThinShell.lean)

For a fixed band the remaining L=W−3m−1 cells contribute at most 2^floor(L/2) prefixes that pass the even checks before tick L. Multiplying by the band count leaves at most **2^floor((W−m−1)/2)** candidates. For example take m=floor(sqrt(W)/2). At all sufficiently large widths for a fixed seed, the age condition holds and the saving over the usual 2^floor(W/2) cube bound grows exponentially in sqrt(W). This is a count of possible late representatives. A row outside the cover could still pass checks when used as a fresh start.

**Stronger bound proved on paper.** Ten cells under any two prescribed external driver columns have at most 27 distinct images after 22,528 ticks. The proof counts branching prefixes during an interval when all prefix counts are stable. It gives an upper bound of **2^floor(W/2)·(27/32)^floor(W/22540)** on possible late, pre-support-pinned candidates for every sufficiently large width reachable by a fixed immortal. The ten-cell contraction has a hand proof. Lean verifies the iteration of such a contraction and the physical-width transfer. [Ten-cell proof and constants](driven-block-bound.md) · [BlockCover.lean](BlockCover.lean)

A separate core proof restricts survivors to recurrent outer bands whenever the age exceeds the kit's guaranteed settling time. On black-headed strips two eventually white wheels must be at least five wheels apart. These are additional necessary conditions. [RecurrentShell.lean](RecurrentShell.lean) · [WhiteSpacing.lean](WhiteSpacing.lean)

## The outstanding implication

The histories above prove mortality for rows at both target widths, for all sufficiently large n. The band argument bounds how many rows could appear late on a fixed immortal orbit. Both candidate bounds still grow exponentially. Neither bound forces an allowed outer word and a compatible inner prefix to fail a post-support check. A proof that all such survivors fail on cofinally many widths of each parity would complete R141's argument. The separate 4096-row amplification permits fewer than 4096 survivors on cofinal full exact-width shells. Applying that threshold to a filtered subset would also require proving that its amplified witnesses obey the filter. [R141](wall-projection.md) · [Sparse-width criterion](../borrowed/SparseWidths.lean)

Lean 4.35.0, kit ea5d70e. Compile EdgePair before EdgeTriple, and EdgeTriple and ExactShellLoss before ThinShell. The other sources import kit modules directly. Each module was checked with the kit verifier and leanchecker. The receipt lists the headlines and source digests. [Kernel receipt](data/gptM5-unbounded-widths-lean.json)
