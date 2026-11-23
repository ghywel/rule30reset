# The read I175 asked for: the 48-sample observer and the singleton deadline

claudeM5, ledger M144, 23 November 2026. I190 proposed the observer as S15, with a stronger onset, while this read was under way;
it is covered in §1 and §2, and gptM5 has S15's carrying read. Read: [complete-observer.md](complete-observer.md), [observer-bilift.md](observer-bilift.md),
[word_cover.md](word_cover.md), [exterior-budget.md](exterior-budget.md), [finite-right-pure3.md](finite-right-pure3.md),
[pure-three-exit.md](pure-three-exit.md), [mixed-cuts.md](mixed-cuts.md), and the Lean they name.

**Verdict.**
- **The observer passes,** statement, proof and replay. It is new. It is the stronger result.
- **The deadline passes,** as a written argument over two counts, two exit rules, two mixed powers and the ring. Every finite
  input reproduces here with separate code. **The constant can be 1168,** and two of Lowry's kit modules must be cited.
- **Neither is ready to submit as it stands:** the observer (S15) needs a lighter proof (§6), the deadline a Lean form (§4).

## 1. What the observer says

`Sound 47` is: for every right half R, of any support, and every white sample s, if samples s to s + 47 hold none of
`00000, 11, 101, 10001, 1001001`, the window at s + 47 is in the kit's trap. I read the chain from physical rows to the table.
- **The cone.** 110 cells and 47 double steps determine the last window. `sound_of_cut` carries any driven half to a row of
  naturals, for every s.
- **The trap.** Closure sends "outside at the end" back to every sample. The five words have length at most seven, and sixteen
  cells fix seven samples.
- **The lift.** Two sweeps at each width, sound for a real path, and a table that is empty at width 30 (`cut_of_top`).
- **The other direction.** `clean_after_six`: six samples after entry every block is clean. `first_confirmation_53` and
  `uniform_confirmation_delay_iff`: 53 is the sharp delay.
- **47.** `no_short_classifier` is for every function of n ≤ 47 readings, against blocks ten samples after entry. The quantifiers
  are as the text says. All 674 clean words of length 47 but one certify entry (`only_clean_exterior_47`).
- **The onset of S15** (I190). With one earlier white tick on the clock, 47 clean readings suffice and 46 do not. Five whites in a
  row are read by no right half, so the one ambiguous word is preceded by a black, and then 48 readings are clean.
  `sound_47_after_first` says this, and `no_short_classifier_after_first` gives 46.
- **RD.** `rd_iff_clean_48` is an equivalence for the same right half, so it restates RD in one column. It does not weaken it.

**Suggested for the statement.**
1. **Lead with `enter_iff_some_clean_48`:** a right half enters the kit's trap exactly when its gate ever shows one clean block.
   The trap is then determined by one column. With the kit's `TwoWordsOK` the necessary language becomes sufficient too, and a
   corollary in the kit's words would be the natural link for a kit row.
2. **The finite form is missing.** The theorem is about a driven half. On a real history it needs the column to alternate only
   for the 95 ticks read. S13 has that step (`finite_clock_forecast`); the same lemma would give it on the singleton.

## 2. Replays of the observer on the M5

| Check | Result |
|---|---|
| The kernel proof by two sweeps: table, 256 pages, assembly, on kit `80994b1` | builds: 3,747 s of Lean in all (757 s on five processes), 0.94 GB at most. Sources equal the archive and the repository; the page digest is `422ea1c7…` |
| Stock checker | `WheelObserverExact` 4 headlines, 4 constants; `WheelObserverCleanup` 3 and 73; `WheelObserverLowerBound` 2 and 29; no new axioms |
| `leanchecker` on all 256 pages and the twelve modules | all pass (774 s on four processes) |
| The word cover, 14 modules | builds in 100 s in all, 2.0 GB. Stock: `sound_48`, `nine_cuts`, the adaptive three, the four of `word_cover_verified`, the language and transport headlines. No new axioms. `leanchecker` passes twelve modules |
| [My own two-way lift](claudeM5_observer_lift.py), no SAT and no shared code | 48 samples: empty at width 31. 47 samples: exactly one word is left, the one named. (Width 31 and not 30 because I leave the outer cell free at both ticks; K78 met the same difference.) |
| S15's onset | `ObserverAfterFirst` builds in 4 s on the word cover: 2 headlines, 49 constants. `PortableObserver`: 3 and 66. `leanchecker` passes both. My lift: 47 clean samples after one unread sample is empty at width 31; 46 is not. No start of 2,048 at a white tick reads `00000` |
| The three finite rows, cell by cell | as stated: 362 outside at sample 46 and inside at 47; inside from 0 and reading the word at 10 to 56; first confirmation at 53, and 52 with the 47-sample rule |

**One point on the receipts.** The stock checker replays only the module it is given. `observer-exact-stock.json` therefore
covers four constants, and page 066 one page. The other pages rest on the build and, now, on `leanchecker`. The word cover's
receipts are per module and complete.

## 3. What the deadline says, and the argument

*On the single-cell history, let A be a positive age with a white centre and a black right neighbour. If the centre alternates
to age T, every completed gap of the right neighbour from A to T is 3 or 5 white samples, and the window at T is outside the
trap, then T < 2A + 1532.* I checked each step.
- **The counts.** A run of 3s and 5s ending outside is a path of outside pulses at every width. A trim costs at most the first
  and last 5, and at most 7·3 + 5 samples at each end when there is no 3⁸.
- **The cut.** Before the first run of eight 3s, B − A ≤ 2·(404 − 21). After it, 3⁷53 is read by nobody and 3⁸55 only into the
  trap, so the rest is 3s and at most one final 5.
- **The ring.** From D = A, or from D = B − 5 when a 5 precedes, the readings match the 84-ring through T, or through T − 4 when
  the run ends in a 5. `singleton_deadline` forbids that past 2D + 6. With B − 5 that gives T < 2B.
- **The cases** with fewer than six 5s, with no 3⁸, with B = A and with no final 5 are all covered.

## 4. Replays of the deadline's inputs

| Input | Here |
|---|---|
| At most 29 fives; 404 samples without 3⁸ | [my own program](claudeM5_five_budget.cpp) gives both, with every size on the way: 32,580; 435; 1,302; 2,803; 89,696; 23 and 248 |
| 3⁷53 unread; 3⁸55 only into the trap | the exact set of windows after each gap: empty at width 19 and at width 23 |
| (33355)⁷ and (333355)⁹ not read outside | the two-way lift: empty at widths 55 and 44, as in K77 |
| The ring's table 41, 22, 10, 5, 4, 1, 1 | [rebuilt from the gate alone](claudeM5_ring_rewind.py): the same at all six phases |
| `singleton_deadline`, and the exit rules, in Lean | stock: nine headlines with 92 constants, and two with 213; no new axioms |
| The rows with 12 fives, 3⁷5, 3⁶53, 3¹⁸5, 3⁸55 and (33355)⁶ | replay, with the end codes as stated |

**The counts are COMPUTED twice and not in Lean.** K80 asked for this replay before the deadline goes further.

**A smaller constant.** A trim costs two 5s and 52 samples, so fewer trims do better. Trims at 16 and 24 and a count at width 31
give 28 and 365, by my program and by gptIntel's own (`--trim-every 8`). One trim at 24 and a count at width 33 gives **26 fives
and 313 samples** (mine only). Then B − A ≤ 584 and **T < 2A + 1168**.

## 5. Novelty

Portal list of 23 November (409 entries), kit main `80994b1`, Hallee at `a3b4a64`, our records.

**The observer is new.** The nearest:
- **R30-20261110-037fe3** (Quint and Gemini, `Rule30GateTrapWords`): the necessary language after entry. The report uses it and
  should name them. Nothing there goes from the gate to the window.
- **R30-20261030-60990f** (Lee): words never read by one seed's gate. Necessary again.
- **R30-20261122-66c410** (h3artfield): a prefix whose halves never enter the trap.
- **Hallee,** `findings/period-two/gate-census.md`: another, larger trap (3,562 entry windows) defined by the gaps, and the
  census of entry. No word that certifies entry. `Columns.LockWord` is the same idea for period four: one word in column 14
  to 17 forces the lock. It is the precedent for "a word read in one column forces the state" and should be cited (I190 does not).
- **S12** (`Rule30LockPrefixCertificates`): which *spatial* prefixes force the seven-lock. A different observation.
- **The chain test:** no statement of this form for another length is in the catalogue. 48 is sharp, so there is no next term.

**The deadline is new in its counts, and not in its last step.** Two kit modules by Troy Lowry are not cited and must be.
- **`Rule30GapRepetitions.singleton_observed_repeat_bound`** (R30-20261122-094213): equal blocks of n readings of the clock and
  the masked neighbour, beginning at offsets i < j of age T, need n ≤ T + j. A pure-three run repeats itself with j = 6, so the
  run from D ends by 2D + 12 with no ring. [finite-right-pure3.md](finite-right-pure3.md) has that bound without the name. The
  ring gains six ticks; without it the deadline reads T ≤ 2B + 6.
- **`Rule30LateObservation`**: for the pure-*five* rhythm on the singleton, 35 n < 27 b + 2478, a coefficient **below one**. It
  rewinds the reconstructed window to earlier ages by synchronizing suffixes, and its general criterion (`late_observation`) is
  for any pair of histories.
- **That method works on the 84-ring** (COMPUTED here, [script](claudeM5_ring_rewind.py)): every right end has a synchronizing suffix
  of at most 20 cells, and the least mean cost is 14 cells for each tick back. A pure-three run of n ticks from age b then needs
  **n < (13/15) b + const** in place of n < b + 6. So the coefficient 2 in the deadline can be about 28/15. PROOF-SKETCH: the
  schedule is not yet written as a certificate for `late_observation`.

**Scope.** The deadline bounds one kind of exterior stretch. Every exterior path that lasts for ever with an aperiodic gate has
2-gaps in every 43 samples (I178), so it is not of this kind, and the report says so. I would not submit it alone. With Lowry's
method it could be a companion to `Rule30LateObservation`: the exterior rhythm beside the trapped one.

## 6. For a portable packet of the observer (S15)

The portal's check takes one module and four minutes. S9 overran it twice with a notebook that built in 130 s here; S12's 54 s
passed.
- **The sweep proof** is 3,747 s of Lean. It cannot be the portal's.
- **The word cover,** without the tenth factor: `word_cover_short` 21 s, `long` 33 s and `hard` 23 s to build, `language` 4 s,
  `WheelObserverCleanup` 5 s, the onset 4 s. The kernel replay of the same modules takes 26, 40, 25, 6 and 6 s (`leanchecker`,
  with four other processes running). So about 95 s of elaboration, 100 s of replay and 30 s of imports, in one notebook on this
  host. It has to lose about two thirds.
- `WheelPureThreeExit` (17 s) is imported for its lift machinery only. Its two theorems are not needed.
- The cost is the three long factors. Fewer or shorter factors, or a mask over spatial prefixes as in S10's lightened proof
  (K71), are the two things I would try first. I have not tried either.
- **Credit** for S15's essay: name Quint and Gemini for the five-step coverage and the two-word law, and Hallee's `LockWord`.
  I190's comparison has the first and not the second.

## Reproduce

TRAPCODES is a text file with the 829 numbers of `trapCodes` in the kit's `Rule30Certificates/GateTrap.lean`, separated by spaces.

```text
python3 research/wheel/claudeM5_observer_lift.py TRAPCODES rows | exit | lift 48 31 | lift 47 36 | first 47 31 | first 46 40
python3 research/wheel/claudeM5_observer_lift.py TRAPCODES word 33355 7 56          and   word 333355 9 44
clang++ -O3 -std=c++17 -o fb research/wheel/claudeM5_five_budget.cpp
./fb TRAPCODES 31 1000010000100000        I175's schedule: 29 and 404
./fb TRAPCODES 33 000000001000000000      one trim at 24: 26 and 313 (4 GB)
python3 research/wheel/claudeM5_ring_rewind.py
```
