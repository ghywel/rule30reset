# S34 carrying review

**PASS for the Lean result at M236.** S34 proves the modulus-two case as a standalone add-on to S32. Any 27 consecutive columns of the singleton contain one fixed column with arbitrarily late falls on each parity. The second headline proves the strip theorem for every assignment of permitted fall parities. A fall is indexed by its black tick. The two theorem types match the title, abstract and exact headline declarations. [Portal source](../modulus-two/addon/Rule30Submission.lean) · [Kit modules](../modulus-two/addon/kit/)

## The argument read

- The raw loops check all bounded phases and rows, and `four_spec` covers every physically possible pair of exterior bits. `permitFast_eq`, `fit_of_edge` and the packed-field equations connect those loops to the kit's actual `Run`. `ruledOutFast_eq` checks exactly the front and back extensions of the preceding unresolved calendars, with the suffix renormalized. The classification starts with every normalized two-cell assignment, so the empty width-27 list covers both global parity phases.
- `pairAny_of_records` first stabilizes a natural-valued rank. From that point the equal-rank edge clause gives a fixed nonzero class, and the node clause gives a valid pair and positive period. The position advances modulo that period. This proves a fixed lag on the whole tail of the run. Different runs can stabilize in different classes.
- `checkLag` certifies that argument everywhere on its strip. `checkEv` forces eventual membership in each half's listed rows by strict descent outside the eventual set. For `checkProd`, `slice_run` gives actual paths on the two halves. `listed_spec` identifies each live phase-row with its supplied index. The full row is recovered from quotient and remainder with matching phases. The product check covers the true next edge because both halves stay live and the full update satisfies the original calendar. Taking the maximum of the two half cutoffs supplies the common tail.
- The fifteen examples and the complete coverage chain replayed in the kernel. They cover eleven lag-two cases and four requiring longer cycle periods in the supplied proof. The headline uses Jen's theorem at that run's own period. Its common cutoff over the finitely many sites and residues is valid even if a column is assigned a parity before its recurrence is considered. The strip restart at a multiple of the modulus preserves physical phase.

## Independent replay on Windows

Core Lean 4.35.0. Both generators reproduce the three Git-normalized sources and the portal source byte for byte. The 160,050-byte portal source hashes to `d07215e43638d88e6a5c1382dd820715cd65148ca4c37c40a8eb76a02d1b617e`. Its only direct import is the kit's `Rule30StripCertificates`. The carried strip and two definitions come from S32's modules on kit main. The live portal listed pin `5fb591588cfa869bfdc47946799b5ddd70a903d1` during the read. Stock checks and standalone kernel replays passed as follows.

| Target | Replayed declarations | New axioms |
|---|---:|---|
| Portal add-on, both headlines at `5fb5915` | 568 | none |
| `FallParityLag` at kit `6289b3b` | 202 | none |
| `FallParityData` at kit `6289b3b` | 223 | none |
| `Rule30FallParities` at kit `6289b3b` | 18 | none |

The stock checker refused a fabricated missing headline. Each headline uses only the standard axioms. The notebook and aggregate kit patch are assembly deliverables and have their own release read. The source review here uses the files at M236.

## Wording for assembly

1. In §2 state the direction of the divisor rule explicitly. Distinct residues modulo 4 can both be even, so S32 at modulus 4 cannot by itself settle modulus 2. The two theorems do give the uniform 27-column bound for every modulus at least 2.
2. In §5 scope the width-26 control to the free-exterior graph and the eventual-periodicity argument. The survivor can occur in that graph. Its occurrence in the singleton is open. One possible wording is “The free-exterior strip criterion first succeeds at width 27. At width 26 an admissible calendar has a recurrent component with no rigid column.” Use `Cofinal` for the claim about actual singleton columns. [Independent survivor replay](../modulus-two/survivor_obligations.py)
3. Preserve the owner's standalone add-on route. Keep S32's entry ID and precise credit in the abstract or introduction. The module reuses S32's strip and definitions, and adapts its coverage and singleton bridge to arbitrary lags. The essay's later formal-proof section already distinguishes the carried strip and two definitions.

The fixed site −2 remains an open target. I343's four-update obstruction is an exact statement about the centre conditional on that site's fall. S34's existential column can be elsewhere in the strip. The follow-up strengthens the number of sites guaranteed in wider spatial windows. [I343](../gemini/unmarked-launch.md) · [S34 follow-up](s34-follow-up.md)
