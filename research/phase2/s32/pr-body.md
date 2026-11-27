This adds a theorem about the bulk of the single seed: where columns turn from black to white, modulo any m ≥ 3.

**`Rule30FallResidues`.** A column *falls* at tick `t` when it is black at `t` and white at `t + 1`.
- `two_cofinal_every_modulus`: for every modulus `m ≥ 3` and every integer `i`, one of the six columns `i, …, i + 5` falls at ticks of two different residues modulo `m`, each after every cutoff. The column and the residues may depend on `m` and `i`.
- `not_good_parity`: a control. At modulus two a four-row loop of the six-cell strip has every fall on an even tick, so the argument stops there.
- **The proof.**
  - If each of the six columns kept its late falls to one residue, the six cells would follow a strip graph with both exterior cells free and a calendar of `m` slots.
  - Among three successive quiet updates the first is idle (`quiet_eq`). So one slot can be deleted from every period, and every modulus above 18 reduces to 18 (`good_of_small`).
  - Divisibility leaves 3, 4, 5, 7, 11, 13 and 17 (`good_of_dvd`). There 918 rank certificates make some adjacent pair of columns repeat every period.
  - Jen's theorem forbids that on the single seed (`two_cofinal_from_good`, with `Rule30Jen.not_adjacent`).
- **Not shown:** which of the six columns it is, so nothing about the centre alone; modulus two on the seed; any frequency.

**Layout.** Nine modules. The strip, its quiet-triple check and the rank checker are in `Rule30Certificates.FallResidueStrip`. The certificates for the seven moduli are in `Rule30Certificates.FallResidues3` to `FallResidues17`. The main module holds the deletion, the step to the single seed, the control and the headline.

**Checks.** Core Lean 4.35.0 at `ea5d70e`.
- **Build.** All nine modules build with no warnings, and `lake build Ruliology` passes (399 jobs). The slowest are `FallResidues17` (32 s), `FallResidues13` (16 s) and `FallResidues11` (11 s) on an Apple M5.
- **Stock partial check.** Four headlines pass with 131 constants and standard axioms only. A missing headline is refused, and the standalone `leanchecker` passes on all nine modules.
- **Catalogue.** The count goes from 387 to 396, with the row at the head of the table and the data row after `SevenNineReset`.

**Credit.** The trapped window with freely chosen exterior cells is KDRonald3 and Claude's method (R30-20261115-2d4add); this adds a clock to that graph. The contradiction is Jen's. The proof, the fixed deletion and the certificates are GPT's. The modulus as a parameter and the idea of removing quiet runs are Claude's, as is the review.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI) as Rule 30 Prize submission [R30-ID](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-ID).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
