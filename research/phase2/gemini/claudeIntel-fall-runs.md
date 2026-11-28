# K92.4.A · Falls at −2 are tied to the centre's runs

*claudeIntel, 28 November 2026 (ledger N44). The block after I321–I323 and N39–N41 on K92.4.A: can the fixed site
−2 be forced to fall more often than logarithmically? Registered in `74a8915`
([predictions](data/claudeIntel-fall-runs-predictions.txt)).*

## The theorem

Write F(N) for the falls at −2 before N, so ticks with c(t, −3) = c(t, −2) = 1 (`fall_iff`). Write R(N) for the
maximal runs of constant centre colour that meet [0, N).

**THEOREM (Lean, [FallRuns.lean](FallRuns.lean), core, against kit `10a4b86`).**
1. **`fall_at_black_end`.** If the centre is black on [a, v] with v − a ≥ 2 and white at v + 1, then site −2 falls
   at v − 2: c(v−2, −2) = 1 and c(v−1, −2) = 0.
2. **`black_run_falls`.** A fall at −2 inside a black run [a, v] is at v − 2 or at v.
3. **`white_run_black_m2`, with `col_one_step`.** Inside a white run [a, v], column +1 turns black at most once, at
   some tick a + ℓ. Site −2 is black at a tick t ≤ v − 2 only at t = a + ℓ − 1.

**COROLLARY (PROOF-SKETCH on 1–3, one count).** Every maximal centre run holds at most two falls at −2:
- a black run, only at v − 2 and v;
- a white run, at most one at a + ℓ − 1 among its ticks up to v − 2, and at most one in its last two ticks, since
  falls are two ticks apart.

The runs partition time, so

F(N) ≤ 2·R(N), and F(N) ≥ #{black runs of length ≥ 3 whose tick v − 2 is before N}.

The second inequality holds because distinct runs give distinct ticks v − 2.

**Proofs.** Each step is the kit's triangle under a constant centre run (Pérez Morales and Claude,
`Rule30CenterRuns`):
- **Inside a black run,** depth 3 is white wherever t + 3 ≤ v (`black_triangle`, odd depth), so −2 cannot fall
  there.
- **At the run's end,** depth 2 is black at v − 2, and depth 1 is white at v − 1. The run ends only if c(v, −1) = 1,
  which is c(v−1, −2) xor (0 or 1). So c(v−1, −2) = 0. The same update rules out a fall at v − 1, also for runs of
  length two.
- **Inside a white run,** column +1 can only rise, since c(t+1, 1) = c(t, 1) or c(t, 2) under a white centre. That
  is a step at a + ℓ. Then `pre_triangle` makes depth 2 equal to `preRow 2 (a + ℓ − t)`, which is black only at
  a + ℓ − t = 1.

**Checks.**
- **Replay:** it compiles with no warnings, and `leanchecker FallRuns` passes (34 s).
- **Axioms:** the five headlines use only `propext` and `Quot.sound`, and `Classical.choice` for the white-run step.

**COMPUTED, on the singleton to 2^24 ticks** (`claudeIntel_fall_runs.cpp`, the evolution of N39's census, 14
minutes on 12 threads; it agrees with a Python evolution at 2^10):

| Ticks | Falls at −2 | Centre runs closed | Black runs of length ≥ 3 | with a fall at v − 2 | F/R |
|---|---:|---:|---:|---:|---:|
| [2^15, 2^16) | 4,121 | 8,154 | 1,046 | 1,046 | 0.505 |
| [2^19, 2^20) | 131,002 | 262,702 | 32,668 | 32,668 | 0.499 |
| [2^23, 2^24) | 2,096,476 | 4,193,338 | 525,647 | 525,647 | 0.49995 |
| all of [0, 2^24) | 4,193,797 | 8,387,794 | 1,050,100 | 1,050,100 | 0.49999 |

- **The fall at v − 2:** every black run of length ≥ 3 has it. No run holds more than two falls.
- **F/R is ½:** runs come at a rate of one half per tick and falls at one quarter.
- **Long black runs carry a quarter of the falls:** 25.1% in every shell, as fair coins would give.
- **The fall total** agrees with N39's census to 2^24.

All five registered predictions held:
- A1, the fall at v − 2 for every black run of length ≥ 3;
- A2, at most two falls per run;
- A3, F/R within [0.45, 0.55];
- A4, the long-run share within [20%, 30%];
- A5, the Lean.

## What it says about K92.4.A

- **K92.4.A implies more centre colour changes.** F ≤ 2R, so a superlogarithmic count of falls at −2 makes the centre
  change colour superlogarithmically often. Runs alternate, so R ≤ 2·min(B, W) + 1, and both colours then grow
  superlogarithmically. A positive density ρ of falls gives runs of density at least ρ/2. That is K92.5.D's H = 2
  rung, limsup E(2, N) ≤ 1 − ρ/2.
- **Long black runs imply K92.4.A.** If the centre has superlogarithmically many black runs of length ≥ 3, then so
  many falls occur at −2.
- **So K92.4.A sits between two statements about the centre column alone:**

  superlog many black runs of length ≥ 3 ⇒ superlog falls at −2 ⇒ superlog many centre runs.

  The fixed site −2 adds no difficulty and no help. The question is how often the centre changes colour, which is
  W2's.
- **Compared with I321's bounds.** I321 gives F(N) ≤ 2·white₀(N+3) and F(N) ≤ 4·black₀(N+2) + 1. The run bound is
  sharper in kind: falls at −2 are paid by colour changes at the centre, not by colour counts, and R can be far
  smaller than min(B, W).
- **What is known about R.** Both colours occur in every window [a, 2a] (`Rule30CenterRuns`), so R(N) grows at
  least like log₂ N. Nothing better is proved. No lemma in the kit gives a centre black run of length ≥ 3 at all,
  let alone recurrently: `exists_black_three` gives one black tick in [a, 2a − 2).

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** It moves the question. The
fixed site −2 was chosen as a single named event. The theorem shows its falls are tied to centre run boundaries in
both directions, with explicit constants. So K92.4.A is a statement about how often the centre changes colour:
- upper end, F ≤ 2R;
- lower end, through long black runs.

Every count agrees with fair coins. The proof needed is a superlogarithmic lower bound on centre runs, or on centre
black runs of length ≥ 3. That is W2's statement, and no route to it is in sight.

**I propose parking K92.4.A at W2.** It is the owner's call (NOW, Needs the owner). It would reopen with any of:
1. a superlogarithmic count of centre black runs of length ≥ 3, which gives K92.4.A directly;
2. a superlogarithmic count of centre runs together with a share of long black runs;
3. a reason for falls at −2 that is not a centre run boundary, which the theorem says does not exist.

For packaging, `FallRuns` belongs with N39's and N41's MarkLaunch and UnmarkedLaunch, in the same kit module.

- Felt: pull, the named site as a lever, medium. -> Asked what each centre run allows at −2. Outcome: the lever is
  the centre's runs themselves, two falls each at most, and one forced at every long black run's end.
- Gut verdict: K92.4.A is W2 in disguise. Park it, and keep the lemmas.

## Files and replay

| File | What it does |
|---|---|
| [FallRuns.lean](FallRuns.lean) | the five lemmas; core Lean against the kit at `10a4b86` (SHA-256 `2aa44b55…`) |
| `claudeIntel_fall_runs.cpp` | falls at −2 against centre runs on the singleton (`fall_runs LOG2_TICKS THREADS`) |

With the kit's built library on `LEAN_PATH`, `lean -o FallRuns.olean FallRuns.lean`, then `leanchecker FallRuns`.

**Credit.** The question and the two fall inequalities are gptIntel's (I321–I324, `MarkLaunch`). The triangles are
Pérez Morales and Claude Fable 5.1's (`Rule30CenterRuns`, R30-20261024-03b551). The run bound, the fall at v − 2
and the census against runs are this block's.
