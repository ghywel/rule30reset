# Certifying the 48-sample gate observer in the Lean kernel

The finite problem is whether 48 clean white-time readings can end with the sixteen-cell right window outside the trap. The kit’s closure theorem forces every earlier sampled window of a counterexample to be outside too. Because the longest forbidden word has length seven, its occurrence starting now depends on the next six double steps. The current sixteen cells determine those seven gate samples for every eastern completion.

## A finite strip with both endpoints fixed in time

Use time layers numbered 0 through 47. At width 16, each layer starts with every exterior window for which none of the forbidden words starts there and finishes by layer 47. Read the lowest bit as the gate. At width W, for every row u and e in 0, 1, 2, 3, the two-step successor is the low W bits of the kit’s double step on u + e·2^W. These four edges contain every true physical update.

First sweep forward and remove any window without an incoming edge from the preceding surviving layer. Then sweep backward and keep only windows with an edge into the next surviving layer. To widen, try both one-bit extensions of each window left at that same time in the narrower strip. An actual counterexample retains a path through every sweep and every width. At width 29 paths remain. At width 30 the forward sweep reaches an empty layer. A physical counterexample would survive that sweep. [Bidirectional lift](observer_bilift.py) · [Transport to the physical statement](WheelObserverTransport.lean).

The last obstruction can be seen in two updates. The width-30 forward sweep starts from 25,314 windows. At sample indices 18 through 22 it retains 10, 5, 2, 1 and 0 windows. Its sole window at index 21 is `0x0cb07127`. All four eastern inputs send it to the same 29-bit prefix `0x10ede80e` at index 22. This prefix survived the width-29 forward sweep but failed its backward sweep. Indeed, from that prefix all four eastern inputs give the 28-bit prefix `0x0ffe663c` at index 23, which the width-28 forward sweep already excluded. The rest of the table establishes that every possible start leads to this obstruction or dies earlier.

## What the kernel checks

A row has two 48-bit membership labels, F after the forward sweep and B after the backward sweep. At width 16 its allowed mask A comes from the trap and five forbidden factors. At a larger width A is its parent’s B mask. An edge u→v must carry into F(v) every allowed time immediately following a time in F(u). It must carry back into B(u) every time in F(u) immediately preceding a time in B(v). The checker separately checks the starting and ending bits. Thus along a physical counterexample every required B bit is set. At width 30 B is identically zero.

The producer compresses the F/B pairs by sharing equal subtrees of the spatial lookup table. The verification examines both children of each nonempty B, starting at every one of the 65,536 sixteen-bit root windows. This visits 310,192 spatial states across widths 16–30. Each terminal kernel reduction handles at most 128 estimated row checks. Larger subtrees combine already checked facts. The 256 independently checkpointed root pages cover all roots without gaps. [Table generator](make_observer_planes.py) · [Inductive checks](WheelObserverCheck.lean) · [Page rules](WheelObserverScan.lean) · [Page generator](make_observer_pages.py).

The generated table source has SHA-256 `17e6a32484f1b688c5daa03c662c0721eee685ba0f21993078882b1138c7cb96`. Concatenating the sources of pages 000 to 255 in ascending order gives SHA-256 `422ea1c7c29d9df1a6467cb97164acc914135534e6d86c55f85045b84226190c`. All page sources reproduced byte for byte. The payload and proof pages can be generated locally. The two independent physical LRAT proofs are described in the [main result](complete-observer.md).

Use Lean 4.35.0 and kit f41bb49. For a clean build, put the compiled research dependencies `WheelGateObserver` and `WheelObserverTransport` in a directory named `support`, with the kit library on the Lean search path. Generate the table into a fresh directory `check`. Compile the generated `WheelObserverPlanes.lean`, then the repository’s `WheelObserverCheck.lean` and `WheelObserverScan.lean`, in that order, writing the three object files into `check`. The page runner compiles all 256 modules, then builds the theorem `Ruliology.CellularAutomata.WheelObserverCheck.top_pass` in module `WheelObserverAllPages`.

```text
python research/wheel/make_observer_planes.py Rule30PrizeKit check/WheelObserverPlanes.lean
python research/wheel/make_observer_pages.py Rule30PrizeKit check support --generate-only
python research/wheel/make_observer_pages.py Rule30PrizeKit check support --jobs 4
```

The replay checkpoint for each page includes the Lean version, its generated source hash, the supporting source hashes and the hashes of the public, server and private objects in Lean’s resolved import closure. A cache hit also requires the current page objects to match the checkpoint. The combined theorem binds the inputs and outputs of all 256 pages. The runner can resume after interruption. Keep the build directory and its dependencies stable during a single invocation.

All 256 pages passed kernel reduction under Lean 4.35.0. The final module assembled `top_pass` in 2.039 seconds after the page checks. Stock `Check.lean` also replayed page 066 directly, with 11 declarations and no new axioms. All 141 kit object parts used for the comparison matched the pinned f41bb49 build byte for byte after upstream added its independent doubling-lanes result. The exact generated sources and per-page receipts are in `share-scratch/gptIntel/I172/observer-kernel-f41bb49.zip`, 533,443 bytes, SHA-256 `bb5514a4ef34106f8352927d59501c644002a46f720917100816cf1e19e885a8`. [Kernel receipt](data/observer-bilift-kernel.json).

The kit’s stock checker then passed all four physical headlines, including `sound_48` and the equivalence between RD and eventual clean observations for aperiodic gates. Its axiom audit found no new axioms. [Physical theorems](WheelObserverExact.lean) · [Stock receipt](data/observer-exact-stock.json).

Run the complete bidirectional replay with `rule30-python research/wheel/replay.py /path/to/kit-f41bb49 /path/to/build --exact-observer`.
