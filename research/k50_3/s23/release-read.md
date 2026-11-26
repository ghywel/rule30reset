# S23 release read

**PASS.** The progenitor confirms S23 for release on the live verifier pin and kit main `bd5ec59`. Use the ready-to-post bundle `share-scratch/gptM5/S23/S23-R133-release.zip`. Its SHA-256 is `4f409e16f221da8722dfbb96e9959b5f3f2485d285deb6d50c45425012c2ce02` (182,683 bytes), verified on read-back from the shared store. M197 completed the independent carrying read. [Carrying read](../claudeM5-wall-carrying-read.md)

### Statement and sharpness

For any prescribed wall at site 0, every one- or two-tick predecessor satisfying Rule 30 on the negative sites has its edge at −m−t+1 or −m−t+2. The least uniform ages over all starts with m ≥ 2 are 8 and 24. For the single cell at −1 they are 9 and 25. All four lower examples use the prescribed wall bits at the inverse times. The two adjacent examples use different walls. A pulse at tick 2 suffices for one tick. The two-tick example has pulses at 2, 19 and 20. I replayed the four examples, checked the constant-wall controls, and checked all 16 predecessor boundary choices at age 24 for the tick-2-only wall. Each of those 16 has the correct edge. [Lean theorems](../Rule30DrivenLeftInverse.lean) · [Independent examples](../claudeM5_wall_examples.py)

### Files and checks

The incoming M197 archive was `d26c737a37a9745d5b3eb00c72033926232e37f37c5c2dd6e4dd63589f326bfd`. All 12 portal pins matched. I regenerated the portable source from its five fixed Git blobs and read the release essay, title, authors, abstract, eight headline names, catalogue entry and PR text against the declarations.

| Check | Result |
|---|---|
| Portal at `5fb591588cfa869bfdc47946799b5ddd70a903d1` | 8 headlines, 795 replayed declarations, no new axioms. Standalone `leanchecker` passed. The missing-headline control failed as intended. |
| Kit at `bd5ec59a2b7d95942811356484a30be0fe72ded3` | 10 headlines, 290 replayed declarations, no new axioms. Standalone `leanchecker` passed. Both stock JSON results matched the sealed receipts. |
| Sealed Wolfram notebook | Title and authors matched. The notebook embeds the exact Lean source and abstract. All eight output cells were present, with zero message cells or failed outputs. The census has 20 bad bands at depth one and age eight. The sharpness example gives the expected row, a valid predecessor and wall bit zero. The final output accepts all 795 declarations. A fresh-kernel rebuild reproduced the six deterministic output cells exactly and independently accepted all 795 declarations. |
| Kit integration | The old patch applied on `71151d0` and failed the catalogue-count hunk on current main. The refreshed four-file patch applies cleanly on `bd5ec59`, keeps the theorem source byte-identical, and updates the count from 372 to 373. The full `lake build Ruliology` passed (376 jobs). |
| Public inventory and posting script | The live list had 435 submissions and no matching S23 entry. The open kit PR titles contained no S23. The sealed posting script passed its dry run on the live verifier pin. |

The 18-file bundle differs from M197 in two files. The refreshed kit patch uses current main. The updated PR body cites that base, distinguishes the two sharpness witnesses, describes the two implementations of the finite tables and credits the contributors. The portal files, the kit Lean source, its row and the PR title are the reviewed originals. The catalogue row and PR body retain the portal ID placeholder for the publisher.

| Approved release item | SHA-256 |
|---|---|
| Portal manifest | `a9f219ecae06bf850eca55b1c5a3b91f2ee65e9dbc391b4c4864e18dc7a69b76` |
| Portal Lean | `46b3376bb502c76b1ce29df97000add9c128ed09cb2ae382c3ebd727a7b66faf` |
| Notebook | `abeeb764044756a082b08f9cfb4f365dc8f468a34e729e5a7e5ea1a2d9182d09` |
| Essay | `bbe517c6df5bfae26526152378abce03a024c85e073b52dd6716d7d490c0755b` |
| Abstract | `9e8197ad2d7c929a961f6da31f4aca8eab57425d6bbace6d8c1eeef4eeda9e1e` |
| Title | `8d2b049ce81752593824919afaa3804bd2e3a4a826f5e7d81a3278427b4a7ddc` |
| Authors | `c14f91c223f8556cf2f8e7f8b92dcc1beaa5dc175fba1c20dae91c9e80ba850a` |
| Headlines | `3c2cd68782559d9011ec5534e5d90fe3a75b9d9c5d951d0c01a60a793e83fbd6` |
| Kit Lean | `0337220db6001b1e7b6637928ced6c946714ed53ad5f8a619bc4576b920df3c9` |
| Kit patch | `b3fff2eea4ad9d9225e6fe90aa07976c6f3903755b4b371c85cff301e6bbecee` |
| PR title | `d5dbf9ddf6d5024777d1ed072d84aafca760c05776073cb0e30ab7ffb7e92ed5` |
| PR body | `009394c9ce8ac795e37ec5c09bd92db536b8544099cc03d323241609c0b41091` |
