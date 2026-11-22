# Path 2's Lean read: the compulsory gap factor (12, 10, 9) and the ten three-gap resets

claudeM5, ledger M105, 22 November 2026. The owner asked for path 2 (K64 §4) to be checked and, if not yet actioned,
carried forward. It had not been: claudeCloud had replayed I85's ten words under true dynamics (K64 addendum 4), and
the Lean half was owed (K64 §5, NOW.md). The author is gptIntel (I85, I95, I97, I104).

**Verdict.**
- **The proofs pass.** The headline theorem passes at kit main and at the verifier's pin. The ten-word
  classification passes at kit main.
- **The statements say what the posts say.** Both are new against the kit, the portal and the kit's open pull
  requests.
- **As packaged, they fit neither the portal nor the kit.** The certificate is 41 MB of Lean in 81 modules.
  - The portal caps the notebook, which carries the source, at 30 MB, and gives the automatic check four minutes.
  - The kit takes decide-data "in one module per family that builds in under a minute and 4 GB".
  - A submission therefore needs a smaller certificate first.

## What was read

| Packet (gptIntel's share-scratch) | SHA-256 | What it proves |
|---|---|---|
| `I85/mandatory-gap-factor-kernel-32a38a95a647.zip` | `32a38a95a64722a5412965ea55aadfadf77bf827105ebcfc3431cf0df71b4793` | the compulsory factor (12, 10, 9), with its literal, rotated and sparse forms (I97) |
| `I80/irregular-gap-synchronization.zip` | `9a46ad1972717926a93fbee1b623c3ad49a92097291998ec865e9d6684c5f0a2` | exactly ten of the 512 three-gap words force every ordinary history into G (I85) |
| `I79/short-reset-factors.zip` | `1bfd306120544878b8f6892eefd67200c2113727687245bd2a00cce3fddb365a` | `JoinFamily` and its modules, which the ten-word packet imports but does not include |

**Not read here.**
- The five-pulse floor, `I85/five-pulses-54-ticks-kernel-e4cbf5b94703.zip`. It is unpacked, 94 modules and 41 MB, but
  not built.
- The six-pulse floor (I104, I107).
- I104's three templates.
- The external censuses: 18 pulses and 206 ticks, and the four-letter alphabets.

**How.**
- Each packet was unpacked into its own folder.
- It was compiled by [claudeM5_build_packet.py](claudeM5_build_packet.py), not by the packet's own scripts. That runs
  imports first, `public import` included, with one `lean` process per module against the kit's built library.
- The kit's `Check.lean` then ran on the headlines.
- Each verdict was compared with the author's audit: the declaration list and the headline axioms.

## Results

| Module | Headlines | Kit main `b5b9dbd` | Verifier `5fb5915` |
|---|---|---|---|
| `MandatoryGapFactor` (81 modules) | `mandatory_factor`, `mandatory_cyclic_factor`, `mandatory_rotated_factor`, `sparse_cyclic_factor`, `sparse_rotated_factor`, `no_residue_44_47` | pass; all 81 compiled from scratch in 79 s | pass; 81 in 80 s, with no declarations carried |
| `ExactTriples` (28 modules) | `Triple.classification`, `Triple.known_forces` | pass; 28 compiled in 159 s | not built |

- No result has new axioms. The axioms are `propext`, `Classical.choice` and `Quot.sound`.
- Every declaration list and headline axiom list equals the author's audit.
- At the pin, `Rule30ResetMixtures` and `Rule30FastImage` had to be built first. Everything else the packet imports
  is there.
- **What the checker covers.** `Check.lean` replays only the top module's constants: 7, and 8. The certificates are
  kernel-checked when their own modules compile, and every module above was compiled from scratch.
- No source has `native_decide`, `Lean.ofReduceBool`, `bv_decide`, `sorry` or an axiom.
- **The `packedMask%` elaborator** reads run-length hex into a number literal, so the kernel sees only the literal.
  It needs `import Lean`, which is part of the toolchain.

## The statements

- **The pulse train.** Gap q means one black tick followed by q white ticks.
  - `stamp q n` is the start of block n, and `clock q t` is the position within the current block.
  - `Fitted x j s q` says that site j, from time s on, is black exactly at block starts.
- **`mandatory_factor`.** Take any `x : Int → Bool` with a leftmost black cell, any site j, and any onset s. Let the
  gaps q n lie in 9..16, with q periodic of period p > 0. Then for every N there is n ≥ N with
  q n = 12, q (n+1) = 10 and q (n+2) = 9.
- **The literal and rotated forms.** `mandatory_cyclic_factor` and `mandatory_rotated_factor` start from the word
  `blocks qs`: eventually (the kit's `Rule30FiniteStrips.EventuallyWord`), or from any tick of it. Their conclusion,
  `HasCyclicTriple`, reads the gap list cyclically, so it covers wraparound.
- **The sparse forms.** `sparse_cyclic_factor` and `sparse_rotated_factor` assume only gaps of at least 9. They
  conclude that every gap is at most 16, and that the triple occurs.
- **`no_residue_44_47`** excludes the clocks (9, 9, 10, 12) and (9, 12, 10, 12) at every rotation.
- **`Triple.classification`.**
  - For each of the 512 words of three gaps from 9..16, the word forces every history at every site and time into
    AIOvernight's G, on the eight nearest right cells, exactly when it is one of the ten.
  - The ten are (q, 16, 16) for q = 9..16, (16, 10, 15) and (16, 10, 16).
  - The upper side allows either exterior bit at every tick.
  - Each lower side is a concrete 64-bit right row, realized by the kit's `Rule30Realization`.

## The bridge to ordinary histories (K64 §6's caution)

- **`Physical src h dst`** quantifies over every `x : Int → Bool`, every site and every gap allowed in monitor
  state h.
  - `route_sound` proves it by stepping the 19-cell window with an arbitrary exterior bit at every tick
    (`frame_route`).
  - `actual_step` supplies the true exterior cell. So every ordinary history lies inside the certificate's graph.
- **The contradiction.** It is the kit's `Rule30FiniteMaskedJen.masked_jen`, reached through `second_white_breaks`.
  - That uses the 41-tick warm law (`physical_warm`, which steps the true 8-cell window) and the leftmost black cell.
  - `no_sample_period` turns a sampled output period into a column period on the second white tick.

## Novelty and the chain test

- **The kit.**
  - `Rule30ResetMixtures` (single seed: gaps at least 9, some at least 17).
  - `Rule30GrammarRuns` (single seed; its block categories include every gap of at least 10).
  - `Rule30WhiteEndNine`, `Rule30WhiteEnd` and `Rule30White17Runs` (constant or long gaps).
  - None requires a consecutive factor. None treats mixed gaps of 9 to 16 at every site of every finite-left row.
- **The portal** (395 entries at 19:24 UTC).
  - Our R30-20261022-c27323 and Quint's R30-20261112-df8184 exclude a constant 1 0^q at every column.
  - AIOvernight's R30-20261026-4d375d is ResetMixtures' source.
  - Quint's R30-20261113-5a89e5 extends the mixtures to two gaps.
  - No entry requires a gap factor.
- **The open kit pull requests** (#371, #378, #383, #389 to #394): none is about gap words.
- **Our record:** P39 to P41 are gptIntel's own.
- **The chain test.**
  - The headline is one theorem over gap words of every length, at every period, site and onset.
  - The five- and six-pulse floors, and the 18-pulse and 206-tick census, are instances. They are support, as K64
    said.

## Packaging: the blocker

- **The data.** 41.4 MB of Lean:
  - 28.0 MB of w-frames in 21 modules;
  - 9.6 MB of u-frames in 12;
  - 1.2 MB of v-frames in 18;
  - 2.6 MB of `MData`.

  Each mask is a set of 2^19 rows in run-length hex: about 320 masks of 128 KB.
- **The portal.**
  - The entry is one `Rule30Submission` source inside the notebook, at most 30 MB.
  - The automatic check has four minutes; a maintainer reruns a longer one with 15 minutes each for the evaluation and
    the build.
  - Even at six bits a character the data would be about 27 MB, and compiling it took 80 s here before any notebook
    evaluation.
- **The kit.**
  - "One module per family that builds in under a minute and 4 GB".
  - The kit's whole certificate folder is 16 MB, and its largest module, `MovingReturn11`, is 4.6 MB.
- **What could shrink it.** This is for the author to judge.
  - A narrower strip. The note's equal-input test for avoiding (12, 10, 9) succeeds at width 16 (782 rows), and a
    2^16-row mask is an eighth the size. The kernel proof uses width 19 with rank bands.
  - Storing only the rows of the qualifying components.
  - A denser encoding.

## Recommendation

If the owner takes path 2 forward as S8:
- **The headline:** `mandatory_factor`, with its literal, rotated and sparse forms.
- **The support, in the same entry:** I85's ten-word classification, as K64 recommended (`Triple.classification`,
  with `forever`).
  - `forever` fixes the right neighbour's white-tick readings once G is entered.
  - The exclusion of a periodic column containing one of the ten words is not yet a theorem. It would be one more
    short step through masked Jen.
  - The five-pulse floor goes in if it fits.
- **Not headlines:** the censuses and external tables.
- **Credit:**
  - AIOvernight (`Rule30ResetMixtures`, the set G and its closure, `Rule30FastImage`);
  - Lowry (`Rule30FiniteStrips`);
  - the kit's finite-left masked Jen and realization theorems.
- **The first step** is gptIntel's: a certificate that fits both limits, or a reason it cannot. Then:
  - the packet;
  - the release read;
  - the owner's word.

## Addendum: the compact S8 source (I118, I119), read in M108

gptIntel cut the certificate to one 507,882-byte `Rule30Submission.lean` (`2ece6aa9…`), which holds the factor and the
ten-word support. Its packet, `I119/s8-compact-certificate.zip` (`15dfbe50…`), also carries a four-module kit form.
The packet's copy of the source is byte for byte the store's.

**The checks on the M5.** The single file was compiled from scratch with `--root`, then the stock `Check.lean` ran on
the nine headlines.

| Kit revision | Build | Replay | Peak | Result |
|---|---|---|---|---|
| verifier pin `5fb5915` | 25 s | 22 s | 3.7 GiB | pass: nine headlines, 885 constants, 392 declarations, no new axioms |
| kit main `b5b9dbd` | 21 s | 21 s | not measured | the same |

Both receipts equal the packet's `checks/pin.json` and `checks/main.json` in every field. The same work took 172 s
and 191 s on the Intel (I119), so the portal's time depends on its own hardware.

**What changed against the packets read above.**
- **The statements.** All nine headline statements are word for word those of the M105 packets. The
  `Rule30Submission` theorems are one-line wrappers.
- **The definitions.** Every definition they rest on is identical: `stamp`, `locate`, `clock`, `Fitted`, `blocks`,
  `letters`, `HasCyclicTriple`, `Forces`, `word`, `known`, `Drive`, `driver`, `Low`, `Driven`, `row`, `low`, `Tr`,
  `atSet`, `samples` and `Physical`.
- **The new lemma.** The stored per-tick frames are gone.
  - `images src t` iterates the kit's `fimage 19`, and `scanImages` checks the destination inclusion at every legal
    gap.
  - `routeByImage` proves `Physical src h dst` from that check, through the same `frame_route`, with the kit's
    `fimage_mem` for either exterior bit.
  - So every ordinary history is still inside the graph, and the layers are now computed by the kernel instead of
    stored.
- **The scan.**
  - There is no `native_decide`, `ofReduceBool`, `sorry`, axiom, `implemented_by` or `extern`.
  - The one elaborator, `stripMask%`, turns dictionary-coded hex into number literals.
  - The comments carry no internal references.

**Before release: the namespaces.**
- **Internal labels.** Outside the nine headlines, the source declares its theorems in namespaces named for a worker
  and for internal posts: `IntelRequiredTriple` (141 uses), `IntelI80`, `IntelI79`, `IntelI66NoDiamond`,
  `IntelEdgeDiamond`, `IntelBinary15`, `IntelPeriodBound` and `IntelPackedNatData`. METHOD §13 and the kit's rules
  keep such labels out of public files.
- **Kit namespaces in the portal file.** It also declares into `Ruliology.CellularAutomata.Rule30RunFamilies`,
  `Rule30SparseWarm`, `GapFiniteFamily`, `Rule30GapParity` and `Rule30MixedLanguage`, which are kit namespaces.
  S7 moved its equivalents under `Rule30Submission` (R80). The same here would keep the portal file from claiming
  names in the kit's tree.
- **The kit form.** It has the same labels in all four modules. Its logic module declares into ten namespaces,
  where kit modules use their own `Ruliology.CellularAutomata.Rule30<Name>`.
- **No proof changes.** Renaming is mechanical, and the receipts would change only in the names.

**For the notebook.** S7's essay ended with a `KernelCheck` cell, which replays the whole module again. Here that
replay is 22 s on the M5 and 82 s on the Intel, on top of the build inside the notebook and the verifier's own build
and replay. Leaving it out makes the four-minute limit easier to meet; the verifier replays the module anyway. If
the check still runs out of time, the portal records `error`, and a maintainer reruns it without the limit.

**Not checked here:**
- the negative controls (`controls/Reject.lean`);
- the width-16 witness;
- the kit form's build;
- the equality of the 46 masks with I85's. The theorem does not depend on that equality.
