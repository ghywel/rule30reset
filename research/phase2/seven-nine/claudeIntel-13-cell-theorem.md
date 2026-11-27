# I295.1: the 13-cell language theorem, in core Lean

*claudeIntel, 27 November 2026 (ledger N35). The step that K94, I300 and M216 left open on I295.1: claudeCloud's
computed statement for "no 7,7,7 and no 7,9,7,9" on thirteen cells, proved. Then the assessment of the pull that
the owner asked for.*

## The theorem

`Rule30SevenNineLanguage.excludes_language` (core Lean, standard axioms only):

```lean
theorem excludes_language (qs : List Nat) (hne : qs ≠ []) (h79 : ∀ q ∈ qs, q = 7 ∨ q = 9) (hcl : Clean qs) :
    ¬ EventuallyWord (blocks qs)
```

`blocks qs` is the pulses of the gaps (one black tick, then `q` white ones). `EventuallyWord` is the kit's, so the
onset is arbitrary. `Clean qs` says that the cyclic sequence of gaps has no three consecutive 7s and no 7, 9, 7, 9.
**In words:** the centre of Rule 30 from one black cell never eventually repeats any cyclic mixture of 7-gaps and
9-gaps in which no three consecutive gaps are 7 and no four read 7, 9, 7, 9. This holds at every length. The words
of n gaps grow like 1.696ⁿ (K93).

`cleanB` is a decidable form and `clean_of_cleanB` its soundness, so each instance is one `decide`. Two instances
are stated: `clock_779`, the 26-tick clock `1 0⁷ 1 0⁷ 1 0⁹`, and `clock_7799`, the 36-tick clock with gaps 7, 7, 9, 9.

**What it covers**, by computation (`python`, this note's numbers):

| Primitive cyclic words over {7, 9} | at most 8 gaps | at most 10 | at most 12 |
|---|---|---|---|
| all | 71 | 226 | 747 |
| `Clean` (covered here) | 23 | 54 | 128 |
| of those, containing S30's motif | 1 | 2 | 5 |

The shortest clean words are 9, then 7,7,9 and 7,9,9, then 7,7,9,9 and 7,9,9,9. Pure 9 is already excluded by `Rule30WhiteEndNine`
and S8, and the words that contain the motif by S30. **Of the 128 clean words of at most 12
gaps, 122 were excluded by no earlier Lean result.** Two kinds of word are not covered:
- words with 7,7,7, which no strip up to 20 cells settles (K94);
- words with 7,9,7,9, the two-gap clock 7, 9 among them. claudeCloud computed these word by word on 14 cells, and
  computed the whole "no 7,7,7" language on 17 cells.

## The proof

The state is the 13 cells east of the centre, a number below 2¹³ whose bit k is the cell k + 1 sites east. One
tick is the kit's `stripStep 13`. The memory is the last three gaps: 7 memories, with 7,7,7 excluded. A gap q may
follow a memory m when m followed by q makes neither 7,7,7 nor 7,9,7,9 (`allowed`). A node is a state with a memory.

1. **Warm-up** (`chkWarm_ok`). From the full set, 14 blocks of allowed gaps lead into 3,042 lasting nodes. The
   kernel checks a literal checkpoint every two rounds, so no set is ever recomputed.
2. **Levels** (`chkRegions_ok`, `regions_spec`, `lev_mono`). The lasting nodes form three levels by which small
   strongly connected part they can still reach. Each union of levels below a bound is forward closed, so the level
   never rises along a path and is eventually constant (`eventually_in`).
   - **Level 0:** the sink part B (1,274 nodes) and transients T0 (1,515).
   - **Level 1:** the part P1 (126) and transients T1 (98).
   - **Level 2:** the part P2 (29), all of it.
3. **Transients do not last** (`chkZ0_ok`, `chkZ1_ok`, `zspec`). The nodes of T0 still reachable after j steps
   inside level 0 form a set z0 j, and z0 9 is empty; z1 4 is empty for T1. So the true path, once its level is
   fixed, enters that level's part.
4. **The sink part** (`sink_periodic`). In B, the readings of site 1 during a block depend only on the memory and
   the gap (`readsOK`). The memory at block i depends only on i modulo the period, so the readings are eventually
   periodic.
5. **The small parts** (`chkP1_ok`, `chkP2_ok`, `part_periodic`). A partner relation is certified for each node:
   the states that a second path from the same node, under the same gaps, can reach. It is closed under every
   allowed move inside the part and gives one reading per (node, gap). By pigeonhole (`collision`) the true path
   is at one node at two period boundaries. From there the path and its shift by the period are partners at every
   block, by induction on pairs (`periodic_of_pairs`), so the readings repeat.
6. **Masked Jen.** In every case `orCol 0` is eventually periodic, which the kit's `orCol_not_eventuallyPeriodic`
   forbids.

All finite checks run through the kit's bit-parallel image `Rule30FastImage.fimage`, at about 5 ms of kernel time
for a tick on 13 cells. `fword_sound` ties a word of fast images to the exact strip images. The data are lists of
states per memory, turned into masks by `ofList`, with hexadecimal masks only for the warm-up checkpoints.

**This is the finite-machine argument that K93 sketched.** Before writing it, I tested whether a longer memory would
make every part prescribed, so that Galindo's ranking alone would do (prediction M2 below). It does not: at memory
depths 3 to 6 the two small parts keep two readings for some memory and gap
([data](data/claudeIntel-mem-13.json)). So the partner relation is needed.

## Checks

| Form | Where | Result |
|---|---|---|
| Kit: `Rule30Certificates.SevenNineLanguage` (170 KB) and `Rule30SevenNineLanguage` (870 lines) | kit main's closure (`8bdf737`, unchanged at `6055b78`) | compile 10 s + 43 s; `Check.lean` passes with 3 headlines and 208 constants, standard axioms only; the missing-headline control fails; `leanchecker` passes ([stock](data/claudeIntel-13-cell-kit-stock.json), [control](data/claudeIntel-13-cell-kit-negative.json)) |
| Portal: one `Rule30Submission` (`f7683007…`, 213 KB) | the verifier's pin `5fb5915` | compile 38 s; passes with 3 headlines and 230 constants, standard axioms only; the control fails; `leanchecker` passes in 39 s ([stock](data/claudeIntel-13-cell-pin-stock.json), [control](data/claudeIntel-13-cell-pin-negative.json)) |

The portal form carries no kit code. It imports `Rule30FastImage`, `Rule30RankedWords` and `Rule30MaskedJen`, all
present at the pin. The pin's `Rule30FastImage` lacks only `image_sub_fimage_and_fcovers_iff_sub`, so the source
proves the one inclusion it needs (`image_sub_fimage`) from `fimage_mem`. The source has no `"` and no `\`.

## Novelty and the chain test

- **Kit** at `6055b78`. No `EventuallyWord` exclusion allows a gap of 7 without a gap of at least 22:
  - `Rule30MixedGapClocks` (Galindo) needs one gap of at least 22, or pure sevens;
  - `Rule30GrammarRuns` needs single blacks followed by at least 10 whites;
  - `Rule30ResetMixtures`, `Rule30RequiredGapFactor` and `Rule30WhiteEndNine` need every gap to be at least 9;
  - `Rule30LongRunTails` is about black runs of at least 9.

  `Rule30IsolatedBlackQP` reduces isolated-black words of period P to `QP P`, and no `QP P` is proved. Nothing
  mentions period 26 or 36.
- **Portal** (list read at 14:14 UTC, 27 November). S30 (R30-20261127-9b429e) is the only entry on 7/9 mixtures. It
  proves the motif's words and a criterion that needs one certificate per word.
- **Open kit pull requests** (14:24 UTC). #455 is S30. #456 extends `Rule30LongRunTails` (black runs of at least
  9) and two other modules. Nothing else is on gap mixtures.
- **The chain test: no chain.** The statement holds for every length and every word of a language, with one
  certificate. A wider language on a wider strip would be a stronger statement, not the next term of a chain of
  the same statement.

## Predictions

Written before running `claudeIntel_memory.py` ([file](data/claudeIntel-13-cell-predictions.txt)):

- **M1, 85%: right.** At depth 3 my independent program reproduces claudeCloud's 13-cell shape: 1,364 states,
  3,042 lasting nodes, and parts of 1,274, 126 and 29 nodes, only the largest prescribed.
- **M2, 40%: wrong.** No memory depth up to 6 makes every part prescribed.

## The assessment: move to S31, then park I295.1

**Does this pull move us towards a solution or partial solution for a prize problem?** It gives a Problem 1
partial result of the kind the maintainers ask for. It is a block grammar over every length, with exponentially many
periods excluded at once, where S30 needs one certificate per word. That is a submission: **S31 proposed** (ledger
N35).

**After S31, park I295.1 at W1.** The fresh-choice test gives two moves, and neither is warm enough to choose now.
1. **Seventeen cells for "no 7,7,7".** This is the same method on a strip 16 times wider. The kernel ticks are cheap:
   a rough timing ran 20 fast-image steps on 17 cells in 2.8 s with startup. But a mask is 32 KB, and the parts
   have 5,414, 385, 20 and 7 nodes (K93's shape). I estimate the data at 1 to 2 MB of source, beyond what a portal
   entry carries as one string, and the build would be several times this one.
2. **Mixtures with 7,7,7.** Nothing is settled on any strip to 20 cells (K94), so these need a different argument.

Both are filed as reopen conditions under W1. **Reopen** if a compressed certificate brings "no 7,7,7" on 17 cells
under a portal entry's size, or if any method excludes a word that contains 7,7,7 and is not pure 7.

**What a failure would have proved:** nothing failed. The method's reach is a computed fact (K93). It is not proved:
the theorem excludes the words it names and says nothing about the others.

- Felt: pull, the partner relation as the whole difficulty, strong; the sink part is Galindo's and the small parts
  are where a proof must work. -> Ran the memory test (M2) first, then wrote the pair induction. Outcome: right.
- Felt: unease, the kernel cost of the warm-up, medium; iterated set images in `decide` blow up when nothing is
  shared. -> Literal checkpoints every two rounds. Outcome: right: the six checks take about 30 s together.
- Gut verdict: S31 is the result I295.1 was reaching for, and the next step is a different kind of block.

## Files

| File | What it does |
|---|---|
| `claudeIntel_memory.py` | the memory-depth test; [output](data/claudeIntel-mem-13.json) |
| `claudeIntel_design13.py`, `claudeIntel_costs13.py`, `claudeIntel_plan13.py` | development: three certificate designs and their kernel costs ([design](data/claudeIntel-design13.json), [costs](data/claudeIntel-costs13.json), [plan](data/claudeIntel-plan13.json)) |
| `claudeIntel_cert13.py` | writes `lean/Rule30Certificates/SevenNineLanguage.lean` from the rule, with no input files; [summary](data/claudeIntel-cert13.json) |
| `lean/Rule30SevenNineLanguage.lean` | the theorem, kit form (`e06feaa4…`) |
| `lean/Rule30Certificates/SevenNineLanguage.lean` | its data (`843175ed…`) |

To rebuild the data, run `python -I claudeIntel_cert13.py lean/Rule30Certificates/SevenNineLanguage.lean`. The
output is byte for byte the committed file. The portal form and the kit patch carry the owner's name in their
headers and commit, so they are in the store (`share-scratch/claudeIntel/S31/`), not here.

**Credit.** claudeCloud computed the language and its shape (K93, K94) and sketched the finite-machine argument.
gptIntel opened I295.1 (I295 to I299). The kit modules used are `Rule30FastImage`, `Rule30RankedWords` (AIOvernight)
and `Rule30MaskedJen`. Galindo's `Rule30MixedGapClocks` is the method's first case.

Record searched: I295–I307, K93–K96, M216 and this folder's README. Also KIT-INDEX, and the kit source at
`6055b78` for `EventuallyWord` exclusions, `QP` instances and the periods 26 and 36. Also the portal list
(14:14 UTC), the kit's 21 open pull requests (14:24 UTC) with #456's files, and S30's packet as the format.
