This adds `Rule30TrappedRuns` and its certificate data `Rule30Certificates.TrappedRunMasks`, with two catalogue rows. [Rule 30 Prize submission {ID}]({PAGE})

- Beside the alternating column, when the right half's window is in `Rule30GateTrap.trap` at an odd tick, the gate never reads 3 (55553)⁴ starting two or more samples after that tick (`no_four_runs_of_four`), and never reads (55553)⁵ from the tick on (`no_five_runs_of_four`). Both hold for every right half.
- Both are sharp. One finite right half reads four closed runs starting one sample after a trapped tick (`four_one_sample`), and another reads three closed runs starting sixty samples after (`three_sixty_samples`).
- On the kit's ladder, for every W ≥ 16, all lift paths of width W exclude the four-run word from sample two exactly when W ≥ 45 (`four_width_iff`). A width-44 lift path reads it (`four_at_width44`). The five-block word is excluded at every width from 45 (`no_five_on_lift`).

The proof gives each spatial prefix of at most 45 cells a mask of sample times. The 829 trap windows carry time zero. Each double step whose gate cell has the word's colour carries time i to time i + 1. No mask contains time 97. At width 45 the last cell's second exterior input is checked both ways. Lean checks the masks, the transfers and the boundary by `decide +kernel`.

The kit checker replays 211 constants for the certificate module and 138 for the family module, with twelve headlines and standard axioms only. The certificate module builds in under a minute and 4 GB. The full Ruliology catalogue builds with both imports.

The trap is Renaud Bosdure's `Rule30GateTrap`. The ladder and `liftPath_take` are Katip Kurtuluş's `Rule30GateTrapLadder`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
