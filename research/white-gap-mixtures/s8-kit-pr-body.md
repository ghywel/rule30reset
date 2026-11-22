# Sparse periodic columns require the gaps 12, 10, 9

This adds the kit form of Rule 30 Prize submission [R30-20261122-f1c87a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-f1c87a), Lean Verified at the verifier's `5fb5915`, in four modules.

**The statements.** At any site `j` of any configuration `x` with a leftmost black cell:
- `Rule30RequiredGapFactor.mandatory_factor`: suppose from time `s` the column is a train of isolated black pulses (`Fitted x j s q`) whose white gaps `q n` lie in 9..16 and repeat with a period `p > 0`. Then for every `N` some `n ≥ N` has `q n = 12`, `q (n+1) = 10` and `q (n+2) = 9`.
- `mandatory_cyclic_factor`, `mandatory_rotated_factor`: the same for a literal repeated word `blocks qs`, eventually or from any tick. The factor may cross the period's wrap.
- `sparse_cyclic_factor`, `sparse_rotated_factor`: assuming only gaps of at least 9, every gap is at most 16 and the factor occurs.
- `no_residue_44_47`: the clocks (9, 9, 10, 12) and (9, 12, 10, 12) are excluded at every rotation.
- `Rule30ThreeGapCapture.Triple.classification`, `Triple.known_forces`: exactly ten of the 512 three-gap words over 9..16 force every driven right half into AIOvernight's set G after the three blocks. They are (q, 16, 16) for each q, (16, 10, 15) and (16, 10, 16).
- `Rule30ThreeGapCapture.forever`: once in G, the right neighbour is white on the first two white ticks of each later gap and black on the rest.

The leftmost black cell is needed: without it, a constant gap of 9 is realized on a full-line row.

**The proof.**
- The certificate follows sets of 19-cell windows right of the site through each gap, admitting either exterior bit at every tick. A three-state monitor forbids completing 12, 10, 9.
- Forward-invariant rank bands and a six-class graph give equal readings on equal-input paths. So a periodic gap sequence would force a periodic masked reading, which `Rule30FiniteMaskedJen` excludes.
- The intermediate sets are computed with `Rule30FastImage.fimage` and checked by kernel decisions. The 46 stored sets are dictionary-coded and expand to kernel literals during elaboration, through a small elaborator: meta code, with `public meta import Lean.Elab.Term`.

**The modules.**
- `Rule30RequiredGapLogic`: the strip and periodic-word lemmas.
- `Rule30Certificates.RequiredGapFactor`: the data and kernel checks, 391 KB.
- `Rule30RequiredGapFactor`: the six theorems.
- `Rule30ThreeGapCapture`: the classification and `forever`.
- They are core Lean in the module form, on main `cf60d48`. Their declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes the six factor headlines (64 constants) and the three capture headlines (192 constants), with no new axioms.
- The certificate module builds in about 10 s on an M5, and in 41 s at 2.6 GiB on an older Intel. `lake build Ruliology` passes, and the count is 306. The certificate is listed under *Certificate data*.

**Credit and earlier results.**
- AIOvernight: `Rule30ResetMixtures` (the set G and its closure) and `Rule30FastImage`.
- Lowry: `Rule30FiniteStrips`.
- The kit: the finite-left masked Jen and realization theorems.
- The earlier family exclusions for sparse words are `Rule30ResetMixtures`, `Rule30GrammarRuns`, `Rule30WhiteEnd` and `Rule30WhiteEndNine`.

**Integration.** #397 changes the same count line, import list and table. Whichever merges first, we will rebase the other.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
