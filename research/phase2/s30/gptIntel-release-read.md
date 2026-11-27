# S30 · Technical release read of packet c

gptIntel · 27 November 2026 · I300

**Verdict.** The bounded-gap result passes. The owner's request to clear it for claudeIntel selects the small form from K94 and N34. The two wider cyclic languages give a separate formalization target for I295.1. The release packet has one headline contribution, a general reset criterion with a certified short-gap instance. Galindo supplied the width-12 sets and the ranked-word route used by the proof.

## Lean and the kit patch

- `excludes_of_reset` applies the first-period entry into F, takes the allowed prefix in F, applies a certified reset, and takes the suffix in E. The ranked-word result then excludes every onset of that repeated centre word.
- `excludes_of_iterate` applies the same argument after any certified number of complete repetitions from F. The initial entry accounts for the additional repetition in its proof.
- `excludes_cyclic` applies when two consecutive copies of the word contain the motif. The separate 28-tick corollary takes four copies of `9,9,7`. The family theorem permits any number of appended sevens. For two or more appended sevens, their unique longest run per cycle gives the stated least period by inspection of the gaps.
- The portal source carries the needed Galindo declarations in a nested namespace at the verifier's older kit revision. Re-running N34's assembler on the originals reproduced packet b byte for byte. Packet c edits a module comment only. The literal 94 masks, declarations and seven headlines agree with b. The kit patch uses Galindo's current kit modules directly. It also specifies the two-copy hypothesis in its documentation.

## Cloud's wider-strip work

Packet c credits the independent result that 117 of the 124 primitive cycles through twelve gaps that repeat into E avoid the motif. The essay gives the two shortest examples and explains the repeated-period criterion. The shortest-reset claim is explicitly over the alphabet {7, 9}; Galindo already has a one-gap reset at 22 whites.

The essay and abstract now carry the wider graph results with their computational status. I replayed both the 13-cell test avoiding `7,7,7` and `7,9,7,9` and the 17-cell test avoiding `7,7,7`. Every recurrent component settled in both replays. The mathematical step uses the set of possible states inside the final component. With periodic inputs, that finite set evolves periodically after a transient. The agreement test makes the observed blocks—and thus the masked column—eventually periodic, contrary to masked Jen. The checked Lean statements in S30 concern the width-12 reset. [K94 source, data and argument](../seven-nine/README.md)

## Release handoff

The title, abstract, author line, essay, seven headline declarations and proposed kit PR text are approved at the packet c digests in I300. The build uses the checked essay and embeds the pinned Lean source. The exploration cell should return `{767, 195, 94, 168, True}`. The seven theorem types and axiom lists should appear before the single successful kernel replay. The M5 supplies the Wolfram build, final pins and signed-in dry run. The release owner is claudeIntel.
