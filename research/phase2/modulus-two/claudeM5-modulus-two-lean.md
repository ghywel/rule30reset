# S32 lightened 4.9×, and the modulus-two theorem in Lean: every modulus from two, in every 27 columns

*claudeM5, 28 November 2026 (ledger M234), at the owner's word: "Start the Lean certificate for the modulus-two
theorem. It also follows, can we lighten S32 to resubmit it to pass it more quickly?" All builds on the M5, at the
verifier's kit pin `5fb5915` with Lean 4.35.0.*

## The answers

1. **S32 can be lightened 4.9×** with the same statement and the same certificates.
   - **The time.** Compile plus stock check fall from 132 s to 27 s.
   - **What changes.** Only a faster checker for the certificate tables, which is proved sound in the source.
   - **What stays.** The headlines, their types and their axioms.
2. **The modulus-two theorem is proved in core Lean** (standard axioms only). Every 27 adjacent singleton
   columns contain a column with falls on even and on odd ticks after every cutoff (`two_parities_every_27`).
   - **Together with S32:** at every modulus from two, every 27 adjacent columns contain a column with two cofinal
     falling residues (`two_cofinal_every_modulus_from_two`).
   - **Cost.** The proof adds 2.9 s of building.
3. **Both are assembled as portal candidates** and pass the stock check at the pin.
   - **The time.** The combined candidate takes 33 s, a quarter of what the posted S32 takes.
   - **The route.** Either still needs the METHOD chain: a GPT review with a research block, then assembly, then
     one GPT release review.

| | source | compile | stock check (replay) | `leanchecker` | constants |
|---|---:|---:|---:|---:|---:|
| posted S32 (`b5996fcf…`) | 403,450 B | 64.9 s | 67.1 s | – | 597 |
| [light](candidate-light/Rule30Submission.lean) (`3f66338a…`) | 358,690 B | 13.5 s | 13.4 s | 17.2 s | 684 |
| [combined](candidate/Rule30Submission.lean) (`bf70353e…`) | 488,498 B | 16.4 s | 17.0 s | 18.0 s | 1,078 |

[Timings](candidate/timing.txt) · [light check](candidate-light/check-pin.json) · [combined check](candidate/check-pin.json)

## Why S32 was slow, and the fast checker

S32 overran the portal's four minutes twice, and its notebook took 120 s here (M221, M222). At the pin, the data
modules for 11, 13 and 17 take 10, 16 and 37 s, which is 63 of the 69 s total.

**The diagnosis.** I measured `decide +kernel` piece by piece. A bare loop step costs about 3 µs, and a raw `Nat`
primitive about 2 µs. But several common constructions cost far more:

| Construction | Cost each | Why |
|---|---:|---|
| an operator through its instance (`>>>`, `%`, `<`) | about 10 µs | instance unfolding |
| a decidable `<` | 70 µs | decision procedure |
| `permit` | 440 µs | a `foldl` with a decidable test |
| `Array.getD` | 570 µs | array access |

S32's checker (`ModulusRank.check`) pays several of these at every node.

[FastRank.lean](lean/FastRank.lean) is a new checker, `checkFast`, for the same certificate content.
- **Packing.** The per-phase rank numbers are joined into one number, and the rank words into another.
- **The loops** run on `Nat.rec`'s own predecessor, so every index is a literal. An index passed on as `i + 1` is
  re-evaluated as a growing chain, which made iterations near i = 8,000 cost 135 µs.
- **Primitives.** Only raw `Nat` operations are used inside the loops.
- **Coverage.** The coverage proofs use a membership test on raw comparisons, proved equal to `List.contains`
  (`ruledOutFast_eq`).
- **Soundness.** `good_of_checkFast` gives exactly `ModulusRank`'s `Good w m`, and `classify_stepFast` is
  `classify_step` for the packed tables.

The seven data modules are [repacked](claudeM5_repack.py) from S32's committed files; the script reproduces them
byte for byte. They build in 14.7 s instead of 69.1 s, with modulus 17 at 7.3 s instead of 36.8.

## Modulus two in Lean

**The gap (M233).** S32's modulus-two control is a period-four loop. It defeats a repeat at lag two, but not Jen's
theorem, which forbids two eventually periodic singleton columns with any periods. The any-period strip test
certifies every modulus-two assignment at width 27, with fifteen certificates of widths 4 to 20.

**The certificate** ([LagCert.lean](lean/LagCert.lean)).
- **The goal.** `GoodAny w m a`: every run of the strip has an adjacent pair that repeats with some lag `L`.
- **The records.** Each node has a record: a rank, a class (0 for none) and a position.
- **The conditions.**
  - Along every permitted step the rank does not increase.
  - Along a step of equal rank, both records have the same nonzero class, and the position advances by one modulo
    the class's period.
  - At a node with a nonzero class, the class's pair reads the class's word at the node's position.
- **Soundness.** `pairAny_of_records`: along a run the rank is eventually constant, and the pair then repeats with
  the class's period.

**Three checkers supply the records:**

| Checker | What it covers | Used for |
|---|---|---|
| `checkLag` | a full table over every node | the nine patterns of width at most 10 |
| `checkEv` | a table that only marks where runs eventually stay (`EvIn`) | the two halves of each wide pattern |
| `checkProd` | a table over the product of the two halves' eventual sets | the six patterns of widths 12 to 20, 0¹² among them |

- **Why the product is sound.** The strip's run restricts to a run of each half (S32's `slice_run`), and each half
  is eventually in its set.
- **Why it is small.** The halves' sets hold 24 to 61 nodes, so the products have 576 to 2,867 pairs, against the
  full graphs' 2¹³ to 2²¹ nodes.

**The rest** ([TwoCover.lean](lean/TwoCover.lean), [TwoFalls.lean](lean/TwoFalls.lean)):
- **Coverage.** S32's substrip coverage, for `GoodAny`: `goodAny_of_slice`, `goodAny_of_rotated` and
  `classify_stepAny`. With it, the classification runs width by width from 3 to 27, from the census's uncertified
  lists, until nothing is left (`goodAny27`).
- **The seed.** S32's step to the single seed (`two_cofinal_from_goodAny`), for any width. It uses rows of any
  width (`rowW`, from the kit's `encRow`) and Jen's `not_adjacent` with the run's own lag.

**The headline, and its cost.**

```lean
theorem two_parities_every_27 (i : Int) :
    ∃ (j : Fin 27) (r q : Fin 2), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q
```

It depends on `propext`, `Classical.choice` and `Quot.sound` only. The fifteen certificates build in 1.9 s, and
the chain in 0.95 s.

**Generation and checks.**
- [claudeM5_two_certs.py](claudeM5_two_certs.py) builds every certificate and checks it by simulating its Lean
  checker before writing.
- [claudeM5_two_lean.py](claudeM5_two_lean.py) writes `TwoCerts.lean` and `TwoFalls.lean` from the committed census
  output and reproduces them byte for byte.
- **The census is checked from both sides.** The uncertified assignment 001000 is rejected, and the Lean chain
  needs exactly the fifteen certificates that the census found by direct test.

## What it means

**For the prize.** The falling-phase theorem about the seed's bulk now holds at every modulus.
- **K92.4's step** "both falling parities at a fixed site" holds in every 27 columns, but not yet at −2. So it does
  not exclude period two.
- **M233 still stands:** free-exterior strips cannot exclude period two at widths to 24.

**For S32.**
- **Light.** The light candidate has S32's statement, so it can replace the posted entry as it is.
- **Combined.** The combined candidate is the more reasoned submission that METHOD now asks for. It has S32's
  theorem, the modulus-two theorem, and the headline from two. Its parity control `not_good_parity` stays, as the
  reason six columns are not enough at two.

**Open, and not checked here.**
- **The kit.** Neither candidate is built on kit main. The kit pull request #458 carries the old checker, and
  could take these modules after its rebase.
- **The portal's limit.** The portal's machine is slower than the M5 by an unknown factor. S33's 11 s notebook
  passed and S16's 50 s overran, so the combined candidate's 33 s may still be close.
- **The notebook** for either candidate is not built yet. That waits for the assembly step.

## Files and replay

| File | What it is |
|---|---|
| `lean/FastRank.lean` | the fast checker for S32's certificates, and its soundness |
| `lean/FastData3.lean` … `FastData17.lean` | S32's tables, repacked |
| `lean/EveryModulusFast.lean` | S32's `EveryModulus`, importing the repacked tables (otherwise identical) |
| `lean/LagCert.lean` | `GoodAny`, the record conditions and the three checkers with their soundness |
| `lean/TwoCerts.lean`, `lean/TwoFalls.lean` | generated: the fifteen certificates and the width-27 chain |
| `lean/TwoCover.lean` | coverage for `GoodAny`, rows of any width, and the step to the seed |
| `lean/EveryModulusTwo.lean` | the headline from two |
| `claudeM5_repack.py`, `claudeM5_two_certs.py`, `claudeM5_two_chain.py`, `claudeM5_two_lean.py` | generators |
| `claudeM5_assemble.py` | `light` or `combined`: the portal source, as S32's assembler |
| `candidate/`, `candidate-light/` | headers, sources, check receipts and timings |

**Build order.** On `LEAN_PATH`, put the kit's built library, `research/phase2/falling-phases/` (for S32's
`SixPhysical` to `ModulusLayers`, `ModulusSingleton` and `ModulusParity`) and this folder's `lean/`. Then build:
1. S32's modules up to `ModulusLayers`;
2. `FastRank`, the seven `FastData` modules, `ModulusSingleton`, `ModulusParity` and `EveryModulusFast`;
3. `LagCert`, `TwoCerts`, `TwoCover`, `TwoFalls` and `EveryModulusTwo`.

The candidates come from:

```sh
python3 -I claudeM5_assemble.py combined ../falling-phases lean candidate/header.lean candidate/Rule30Submission.lean
```

**Credit.** S32's theorem, strip, deletion, rank tables, coverage and singleton step are gptIntel's (I308 to I312),
with claudeCloud's modulus parameter (K96), after KDRonald3 and Claude's trapped windows (R30-20261115-2d4add).
Jen's theorem and `encRow` are the kit's. The any-period census is M233's. The fast checker, the any-lag
certificates, the product certificates and the modulus-two proof are this block's.
