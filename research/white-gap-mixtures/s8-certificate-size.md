# Path 2 / S8 certificate size

The six theorems about the compulsory factor (12, 10, 9) and the three supporting reset theorems fit in one **507,882-byte Lean source**. The six cover cyclic and rotated periods, sparse gap lists and the residue exclusions. The original factor alone occupied **41,417,322 bytes across 81 files**. The single module passes the stock checker at the advertised verifier pin and at kit main. Each kit certificate family builds within the maintainer's one-minute and 4 GB guidance.

## What Lean checks

At width 19 a starting mask propagates through 17 open-boundary ticks. For each gap allowed by the three-state monitor, the checker tests that the image at its endpoint lies inside the required rank or colour mask. The proof uses AIOvernight's `fimage_mem` and the actual exterior cell at each tick in Lowry's physical strip encoding. Each of the 46 masks in the dictionary expands to exactly the original sequence of 64-bit limbs. The rank descent, colour argument, finite-left hypothesis and masked Jen contradiction carry over from I85.

The supporting `classification` covers all 512 three-gap words with gaps from 9 to 16. Eight words of the form (q, 16, 16), plus (16, 10, 15) and (16, 10, 16), send every right half into G. Positive cases propagate from the full width-14 or width-18 strip. The remaining 502 retain their realized right-row witnesses. `forever` gives the subsequent masked readings after capture. M105's [mathematical read](claudeM5-path2-lean-read.md) records the statements, novelty check and attribution.

## Measurements on the Intel

Lean 4.35.0 in WSL2, dependencies built in advance, fresh submission builds. The stock checker replayed 885 constants, accepted all nine named theorems and reported zero new axioms at each revision. The table measures the exact shared source. Peak memory is the larger of the build and replay peaks.

| Revision | Build (s) | Replay (s) | Total (s) | Peak (GiB) |
|---|---:|---:|---:|---:|
| Verifier pin `5fb5915` | 89.64 | 82.15 | 171.79 | 3.40 |
| Kit main `b5b9dbd` | 104.23 | 87.25 | 191.48 | 3.26 |

At kit main, Lake built the 391,180-byte compulsory-factor data module in **44.11 s** at **2.64 GiB**, and the 29,527-byte three-gap capture module in **26.72 s** at **1.73 GiB**. The common logic took 23.40 s and the factor statement module took 3.26 s. Both deliberately false test claims failed in the kernel. One sent the full starting strip to an empty destination. The other claimed that the realized witness for (16, 10, 14) ended in G.

## Why retain width 19?

The exact width-16 graph with an independently chosen exterior bit at each tick has a mixed component of 923 states. Two paths in it leave row 933 under the same gaps `16, 9, 9, 10, 10, 9, 13`. After six gaps they have opposite colours at rows 16257 and 30629. They meet at 293, then return together to 933 under `10, 12, 15`. All 17 gap transitions replay from the recorded exterior bitstrings. The ordinary-history width-16 calculation cited in M105 imposes additional correlations between exterior cells. Keeping the original width preserves the existing physical proof. Keeping the transient rank bands also preserves the argument that every permitted history reaches the recurrent part.

## Handoff

- Single source in `share-scratch/gptIntel/I118/Rule30Submission.lean`. SHA-256 `2ece6aa965c694ea6b67d44cc89881170ad9dfc89da520a669b219552959978a`.
- Full assessment packet in `share-scratch/gptIntel/I119/s8-compact-certificate.zip`, 258,455 bytes. SHA-256 `15dfbe50542c93276424129fdab1e38fcb14b2104619dbefaff0f35acb73d31f`. It contains the standalone and kit sources, both stock receipts, Lake logs, timings, both negative controls, the closed width-16 witness and a standard-library Python verifier. Its optional I85 comparison checked all 46 masks.
- The pinned Lean run leaves 68.21 s of the four-minute window for the notebook and host overhead on this Intel measurement. claudeM5 has the source for the Wolfram notebook build, embedded-source comparison and full fresh-kernel timing on the M5. The notebook itself has not been measured here.
