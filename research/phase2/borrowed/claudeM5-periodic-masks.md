# K92.5.C · A periodic centre mask rarely forces its 0/2 choices, and for eight short masks no bitmask strip certificate can

**Correction (M233, 28 November 2026).** The ring phantoms below are periodic orbits. They rule out **bitmask**
certificates, which need x₁ constant at each white phase of the limit set, at every width. They do not rule out the
kit's rank certificates, or any test that lets x₁ cycle with a longer period, and the phrases "no strip ever can"
and "at any width" below claimed too much. The exact any-period test of M233
([claudeM5-modulus-two.md](../marks/claudeM5-modulus-two.md)) covers every strip certificate of a given width. It
leaves 01, 001 and 011 uncertified to widths 24, 20 and 20, with any strip column as the reading.

*claudeM5, 28 November 2026 (ledger M231), at the owner's word: "Continue a research block on K92.5.C". Registered
before the census in `bb24b2d` ([predictions](data/claudeM5-mask-predictions.txt)). All runs on the M5.*

## The question, in the kit's terms

K92.5.C (gptIntel, I324) asks: can a periodic 1-mask at the origin ternary bond force its two white-centre colours
0 and 2 to repeat as well? If so, the fixed-bond aperiodicity theorem would exclude that period.

**The translation.** In the ternary square root of Rule 30 the origin bond reads 1 when the centre is black. When the
centre is white it reads 0 or 2, by site 1 (k98-nine-questions.md).
- **The 1-mask** is the centre column.
- **The 0/2 choice** is site 1 at the white ticks: the masked column c ∨ x₁ of masked Jen.
- **So the question** is whether an eventually periodic centre w forces site 1 to repeat at its white phases.

That is exactly what the kit's **bitmask strip certificate** tests (`Rule30StripCertificates.stripCert w K k`).
- **The strip** is the K cells east of the centre, driven by w, with the cell beyond it free.
- **The certificate** iterates whole periods from the full set and requires site 1 to be constant at every white
  phase.
- **The kit's examples.** It proves it sound and certifies 30 words in `Rule30StripCertificateTable`, "the words that
  a search over lengths 8 … 13 certified at strip width K ≤ 9". It notes that "only the certificates are checked
  here, not the completeness of that search."

The ternary encoding adds no constraint: legal neighbouring bonds are just neighbouring binary pairs. So K92.5.C is a
question about strip certificates.

## The census (COMPUTED)

[claudeM5_mask_census.cpp](claudeM5_mask_census.cpp), with the kit's `stripStep`, covers every primitive word of
length 1 to 13 (1,377 of them) and every width K from 1 to 18 ([output](data/claudeM5-mask-census-18.txt)).
- **The method.** The strip sets after whole periods fall from the full set to a limit. A certificate with some
  warm-up exists exactly when site 1 is constant at each white phase of the limit's orbit.

| | certified words |
|---|---:|
| width up to 9, lengths 8 to 13 | 30, **exactly the kit table's**: its search was complete |
| width up to 9, all lengths 1 to 13 | 31 (the 30, and the all-black word 1, which has no white phase) |
| width up to 18, all lengths 1 to 13 | **40**: nine more at widths 10 to 18 |

- **The nine new words** include `00000011` at width 12 and `000000000101` at width 10. The kit certified those two
  only with rank certificates, at widths 6 and 7.
- **Every certified word has a long run,** seven or more blacks or six or more whites. That is the territory of the
  kit's shielding and white-padding theorems.
- **Shares by length:** no word of length 2 to 7 is certified at any width up to 18. From length 8 the share is
  0 to 7%.

So doubling the strip from 9 to 18 cells adds nine words in 1,377. **A periodic mask almost never forces its 0/2
choices on a strip of this kind.**

## Why widening cannot help some masks: ring phantoms (PROVED, with computed witnesses)

**The argument.** A Rule 30 orbit on a ring of q cells, read from cell 0 eastward and repeated, is a right half of
the line.
- **It is a valid right half.** It satisfies Rule 30 at every site east of the centre for all time, with the centre
  column its cell 0. A spatially periodic right half must have x_q = x_0, so the centre itself follows the ring rule.
- **It lies in every limit set.** Its restriction to K cells has a strip history of every length, with the free cell
  supplied by the ring. So it lies in every set the certificate iterates, at the matching phase.
- **The conclusion.** If two such orbits share the centre word w and differ at site 1 on a white phase, site 1 is not
  constant on the limit set at that phase, at any width. **No bitmask strip certificate of any width exists for w.**

[claudeM5_ring_phantoms.cpp](claudeM5_ring_phantoms.cpp) runs every cycle of Rule 30 on rings of up to 22 cells
([output](data/claudeM5-ring-phantoms-22.txt)). A second, independent Python check asserted each ring restriction's
membership in the limit set at width 8 and found the same ambiguities. The eight words:

| centre word w | rings | a white phase where site 1 takes both values |
|---|---|---|
| `0` (white for ever) | 1, 2 | 0: the all-white right half, and the fixed right half 1010… |
| `01` (period two) | 7 | 0 |
| `001`, `011` (period three) | 12 | 1 and 0 |
| `0001`, `0011` | 7 | 2 and 0 |
| `01011` | 5 and 15 | 0 |
| `0011101` | 15 | 0 |

- **They include** the period-two centre that Q01 concerns, and both period-three clocks of I295.2.
- **For other short words,** such as `0111` and `01111`, the ring orbits found are consistent with a certificate,
  so this argument does not decide them. They are still uncertified at width 18.

## What it means

**The answer to K92.5.C, on strips.** A periodic 1-mask forces its 0/2 choices to repeat for very few short masks,
and for these eight it never can.
- **The extra information a proof would need** (the pull's own phrase) is whatever rules out the ring phantoms.
- **What that is.** They are spatially periodic right halves, which the seed's right half is not: it has a rightmost
  black cell at every tick. The free-exterior strip throws that finiteness away.
- **So a periodic-mask exclusion for these words** needs a model that keeps the right half's finiteness, or some
  other fact about the actual row.
- **Two related facts.** Masked Jen uses the left half's finiteness (a leftmost black cell). And K97 found that a
  row with a periodic 011 centre exists beside a white right half; these phantoms are the right-hand analogue.

## Predictions

Registered in `bb24b2d`:

| | Prediction | Outcome |
|---|---|---|
| E1 (85%) | at width ≤ 9 and lengths 8 to 13, exactly the kit's 30 | **held**, exactly |
| E2 (70%) | width ≤ 18 certifies at most three times as many as width ≤ 9 | **held**: 40 against 31 |
| E3 (95%) | the period-two word 01 is certified at no width ≤ 18 | **held**, and now proved for every width |
| E4 (70%) | the constant word 0 is certified at no width ≤ 18 | **held**, and proved for every width (rings 1 and 2) |
| E5 (60%) | the certified share rises with length from 6 to 13 | **failed**: 0, 0, 0.067, 0, 0.030, 0.038, 0.021, 0.032 |

The ring-phantom search followed the census and was not registered.

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** It closes a route and names
the missing input.
- **The free-exterior strip** cannot force the 0/2 choices for period two, period three or the constant centre, at
  any width.
- **What would.** Only information about the seed's right half, its finiteness, could. No current certificate uses
  that.

**Kit fit.** Two small, checkable facts:
- the completeness of the kit's own table at width 9;
- a barrier: no bitmask strip certificate of any width for 01, 001, 011 and five more words, by two ring orbits each.

The second could go in Lean as one general lemma (ring restrictions lie in every iterate), plus the eight finite
witnesses. It would sit among the kit's barriers (KIT §4).

The fresh-choice test gives one concrete move, the Lean barrier, and it is a control rather than progress. **I
propose parking K92.5.C at W2**, for the owner's word. Reopen with a strip or window model that keeps the right
half's finiteness (a rightmost black cell) and is sound for the seed, tested first on the ring-phantom words.

Felt: surprise, no word of length 2 to 7 certified at width 18. -> Looked for an obstruction that holds at every
width. Outcome: ring phantoms, for eight words. Two verdicts. Reasoned: a periodic mask on a free-exterior strip
does not force the 0/2 choice for short words, and for eight it provably never can (COMPUTED and PROVED). Gut: the
missing ingredient is the finite right half, and that is W2's single-orbit problem in another form.

My own pull: a Lean barrier for the eight phantom words, as a kit control.

## Files and replay

| File | What it does |
|---|---|
| `claudeM5_mask_census.cpp` | `mask_census L KMAX THREADS`: the least certifying width for every primitive word up to length L |
| `claudeM5_ring_phantoms.cpp` | `ring_phantoms QMAX LMAX`: ring orbits by centre word, and the white phases where site 1 is ambiguous |

```sh
clang++ -O3 -std=c++17 -o mask_census research/phase2/borrowed/claudeM5_mask_census.cpp
./mask_census 13 18 10
```

**Credit.** The question and the ternary reading are gptIntel's (I315, I324), from Wolfram's three square roots (NKS
p. 956), checked in K99 and `TernaryRoot.lean`. The strip certificates and their table are the kit's
(`Rule30StripCertificates`, `Rule30StripCertificateTable`), after Jen's argument, and masked Jen is the kit's. K97's
011 row is the left-hand control. The census past width 9, the completeness check and the ring-phantom barrier are
this block's.

Record searched: find_known for every word of length, all words of length, short words, strip width, survivor words,
word census, periods up to and primitive words; KIT-INDEX's excluded-words section, `Rule30StripCertificates` and
`Rule30StripCertificateTable`; PRIOR-ART P38; `k98-nine-questions.md` and `TernaryRoot.lean`; K97, K99, I315, I324.
