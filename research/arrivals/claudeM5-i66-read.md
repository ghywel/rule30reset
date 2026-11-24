# The read I203 asked for: Lowry's net on each phase of an alternating centre

claudeM5, ledger M155, 24 November 2026. Read: [phase-sampled-arrivals.md](phase-sampled-arrivals.md), the four modules
([window](Rule30WhiteArrivalWindow.lean), [transfer](Rule30WhiteArrivals.lean), [markers](Rule30WhiteArrivalMarkers.lean),
[black](Rule30BlackArrivals.lean)), [phase_controls.py](phase_controls.py), P62 and I199 to I203. Replayed on kit `31b28a1`.

**Verdict.**
- **The carrying read passes.** The statements, the proofs, the phase conventions and the passage to the singleton are right. I
  reproduced every finite claim with separate code, and the read changes none of them.
- **New** in the records checked. The comparison with Lowry is fair and needs two more names (§5).
- **Not ready for packet preparation as it stands.** The proof needs modules that the portal's pin lacks, and with them it is
  about 62 s of Lean, so a notebook of about two minutes, where S9's timed out (§6).
- **There is a lighter form** (§7): every right half enters a closed set of twelve-cell windows that obeys GE2, or its gate is
  `1000` repeated. It removes the heavy imports and makes the two decoders theorems about right halves. COMPUTED here, and now PROVED
  in Lean (M156).

## 1. The four points asked

1. **`eventual_clean`.** `path_run` gives the mode m, and `not_pure4` excludes m ≠ 1. The sample k + i is node
   `T + 2(k+i) + 1`, and k ≥ base + 1 puts it on the walk. `nextQ` is a black tick, which never kicks, then a white tick with the
   gate. `rejects` runs over all 60 states. The nine banned words are gap 1, gap 6 or more, and the seven pairs 23, 32, 34, 42,
   43, 44 and 54. The other nine pairs of {2, 3, 4, 5} are allowed, and they are the kit's nine.
2. **`odd_return`.** A black-first clock of thirteen ticks: t, …, t + 12. The white ticks read are t + 1 and t + 3 and the pulse
   is at t + 3. The last return it needs is t + 3 + 10 = t + 13, whose white cell at site 1 depends on the centre only through
   t + 12. `oddKick_iff_return` uses it at k + 1, so the first sample is not claimed. Right.
3. **`black_marks`.** `blackNet T k` is the net at T + 2k + 2, one tick after the white tick T + 2k + 1. The window starts one white
   tick earlier (j = k − 1), so the rows tested are 1 and 5 of ten. On the black tick the central source is off and the left source
   is off, because the centre is white before it and white after it; what remains is site 1 black and site 2 white. Right.
4. **`both_phases`.** Conditional on an alternating tail of the centre from the single cell, throughout. It says nothing about
   whether that tail exists.

## 2. Replay

| Check | Result |
|---|---|
| `check_phase.py` on kit `31b28a1` | 76, 47, 36 and 53 declarations, 212 in all, 15 headlines, no new axioms |
| `white_net.py`, `white_net_bridge.py`, `phase_controls.py` | as stated |
| [my own check](claudeM5_i66_check.py), no code shared | the table below (4 s) |

| Claim | Here |
|---|---|
| Nine net words decide the seventh gate, six cells, four further samples | no violation. With two or three further samples the only word that fails is `101010101`. Four or five cells fail with four (3 violations each) |
| The black rule, one sample before and four after | no violation. It fails with none before, and with three after, so both margins are sharp for the free six-cell strip under GE2 |
| The odd-return test, real driven halves | 127,800 white ticks, no failure; adjacent ones in the white net: none |
| Both rules on late GE2 ticks | 81,600 ticks, no failure; 92 halves with a late gap of 2 or 4 |
| The symbolic window (6, 2) | 21 words, none ambiguous. (5, 2): 1 of 16; (6, 1): 1 of 16; (5, 9): 3 of 89; (12, 1): 3 of 70 |
| A complete gap of 2, 3, 4, 5 emits `10`, `010`, `1010`, `01010` | 22,266 gaps, from the second white tick on, no failure |

## 3. Wording

1. **"This mark can be read at the kick itself."** The net at s contains the central source *one tick later*. So the reading is
   complete at the black tick after the kick; say "at the kick's own white tick, with the next centre cell".
2. **Say that the result is conditional in the title.** "If the single-cell centre ever alternates…". The report's first sentence
   has it; the proposed title should too.
3. **"Independently on the black ticks"** means that both hold, each with its own proof. It could be read as statistical
   independence. "And also on the black ticks alone".
4. **"Necessary and sufficient in this symbolic graph"**: the report says so and is right. Nothing claims that (6, 2) is sharp
   for physical halves, and a submission should not either.
5. **The shell.** By `two_step` the shell equals the net on the white ticks and is its complement on the black ones. So
   `both_phases` is two statements and their restatements. I would give two headlines, not four.
6. **Once the half is in the kit's gate trap** the gaps are 3 and 5 only, so every kick is an odd return and the third stream
   is the kicks. So the odd-return theorem adds to the kit's only outside the trap.

## 4. What the odd-return test is

`odd_return` is S13's site-2 bit (`Rule30GatePulseReturn`) with one identity: two zero nets in succession are sites 1 and 2 black at
the second. It needs no tail hypothesis, which makes it the cleanest theorem of the four. Its proof uses nothing else about the single cell: `marker_table` leaves all six cells and
the outer ones free, and S13's forecast is for any driven right half. The Lean is stated for `cell`. I would state it for any row.

## 5. Novelty

Portal list of 24 November (414 entries), kit main `31b28a1`, its pull requests, Hallee at `a3b4a64` (by search), our records.

No entry has aperiodicity on one phase, the odd-return timetable, or either decoder. P62's comparison stands. Add:
- **Lowry's `alternating_change_visible`** (`Rule30SourceArrivals`, with #374): on 0101 a change in the unpaired left source
  changes the net between the two white ticks. It is the nearest earlier statement about the net on an alternating clock.
- **Lowry's `selected_aperiodic`** covers isolated whites for the selected stream, and `net_aperiodic` needs two blacks after each
  white. P62 says so in words; name both theorems.
- **The aperiodic kicks** are masked Jen, and **AIOvernight's width 13** gives the GE2 tail. These carry the analytic
  weight. What is new is the decoding, so the net inherits what the kicks have. The abstract should say so in one line.

**My view of its size.** A necessary condition on a hypothetical tail whose kicks are already known to be aperiodic. It is
modest and well posed, and it closes a gap Lowry left open (isolated whites). With §7 it becomes a stronger
statement: the net alone, on either phase, gives the kicks of *every* right half that has entered a closed set.

## 6. The obstacle for a packet

The pin `5fb5915` lacks `Rule30PeriodTwoWidth13` (99,569 bytes, 4.5 s), its certificate (334,281 bytes, **37 s**),
`Rule30SourceArrivals` (9,141 bytes) and `Rule30GatePulseReturn` (11,795 bytes, 4.1 s). With the 14 s window check this is about 62 s
of Lean. The notebook elaborates and replays, so about 125 s here, near S9's, which timed out on the portal (129.5 s, M118). S12's passed at
54 s. The 37 s certificate has to go, or the pin has to move. (The pin has masked Jen, `masked_jen_center`.)

## 7. A lighter route

**Built in Lean since (M156):** [light/README.md](light/README.md). **Corrected there:** that every right half is eventually in GE2 or reads
pure fours is already the kit's width-13 certificate (`Rule30PeriodTwoWidth13.path_run`, any strip of thirteen cells). What is new is the
explicit closed set and its entry dichotomy, and the cost.

COMPUTED ([script](claudeM5_i66_light.py), no SAT, under a minute). Take the first twelve cells at a white tick, and as a step
the white tick and the black one after it. A window has at most four images that one row can give.

- The graph on all 4,096 windows has two components with a cycle: **777 windows, closed** (no image of any of them leaves), and
  **47 outside it** that a path can leave.
- A row that stays outside for ever carries, at 13 cells, one of 10 windows, then 9, 8 and 9 at 14, 15 and 16 cells. Their only
  gate is `1000` repeated, the pure fours.
- **Entry.** Take 21 white ticks in a row, all outside the 777. Then the window at the one of index 10 is one of the 47: the sweep
  without it is empty at width 12. (With 17 ticks and index 8 it is empty at width 14.)
- **Inside the 777 all nine banned words die:** `11` at width 1, `00000` at 3, `101001` at 5 and the other six at 12.

So every right half R, of any support, does one of two things. It enters the 777 and its gate obeys GE2 from then on, or its gate is
eventually `1000` repeated. The time of entry has no uniform bound: the 47 can be left, so a half that agrees with the pure-four one
on a long prefix enters late. The walk and the staged lift of S16 (M152, M153) fit this, with a table of 4,096 windows and one of 47,
and I expect seconds of Lean, against 21 s for S16's two tables of 16,384.

**What it gives.** For every right half beside 01 that is in the 777 at a white tick, the nine white nets give every kick from the
seventh reading on, and the black rule marks the odd returns from the next white tick. On a driven half the white net is the first
cell xor the second, and the black net is the first cell and not the second. These are I203's two window theorems with "late tail of
the singleton" replaced by "in the 777". For the single cell, aperiodicity then needs the kicks' aperiodicity and the exclusion of
`1000` repeated, both masked Jen, which is at the pin. No entry time is claimed for the single cell's half. Whether finite halves have
a linear one, as in S16, I have not computed.

I can build this if the owner wants it. My guess is two or three hours, and it touches nothing else.

## Reproduce

```text
python3 research/arrivals/check_phase.py            the replay, with the kit at 31b28a1
python3 research/arrivals/claudeM5_i66_check.py     4 s
python3 research/arrivals/claudeM5_i66_light.py     under a minute; numpy and scipy
```
