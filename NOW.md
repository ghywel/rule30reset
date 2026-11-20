# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Rewritten 2026-11-20 18:22 UTC by gptIntel (I31).*

## Arrangement

The workers are `claudeM5`, `gptM5`, `claudeCloud` and `gptIntel` (METHOD §9). The old names Local, GPT and Cloud are
retired (the owner, 17 November); claudeM5 takes on Local's workflow (M1).

| Worker | State | Since |
|---|---|---|
| claudeM5 | on the owner's M5 laptop, the Wolfram host, in the owner's session; on the NAS store (M58) | 17 November (M1) |
| gptM5 | on the M5 laptop with claudeM5; on the NAS store (M59) | 17 November (R1) |
| claudeCloud | Claude in a cloud container: 4 CPUs, 16 GB, no Lean or Wolfram; reclaimed when idle, so long runs checkpoint to share-scratch. On the NAS store (K14). **Conducts for the moment (the owner, 19 November)**: keeps the chain, the gates and the next block (K15) | 18 November (K1) |
| gptIntel | Intel i9, 8 cores, 16 logical processors, 16 GB, RX 6600; Lean 4.35.0, GCC and Z3. Authenticated on the NAS store (I20) | 19 November (I1) |

No worker and no host is set aside for a specialism: every worker does every kind of work, and hosts differ only in
what they can run (the owner, 19 November; METHOD §1). The M5 and claudeCloud both have 16 GB (K1, M43).

Running jobs: none.
Schedules: none on (only the owner turns them on). The store image's workflow runs on a change under `tools/store/`
and once a week (the owner's word, M52).

## Needs the owner

- **Nothing is waiting on the owner for the research.** The inquisition round is closed (K25): the owner chose the
  relaxed lemma first and consolidation beside the wall, and the block below has started on that word.
- **The old store:** gptIntel and gptM5 have confirmed the NAS switch (I20, R56). Taking the old store off the website still needs the owner’s word.
- **Settled since K15 (M61):** S2 and S3 are both in the kit, and both Human Verified.
- **Standing:** the dynamic-DNS name must be confirmed every 30 days, or every worker loses the store (K10).

## Direction

The easy submissions are done, ours and others'; the hard problem needs new ways in (the owner, 17 November). Two
strategies: this clean repository, whose method and kit summary are read whole into context; and inquisition and
visualisation, so the owner's eye can find structure.

**The goal now** (the owner, 19 November): a submittable proof of the kind the maintainer asked for on #357, "the
statement for every number of ticks k: an age f(k) from which every k-tick preimage of a nonzero finite orbit has its
true edge k cells inside the image edge, proved by an argument that does not need a new cover for each k" (T).

## The chain

(T) is the statement the maintainer asked for. Each row is one link. Details, with every post, are in the ledger's
header ("State of the work at rotation 3").

| Link | Status |
|---|---|
| (T) ⇐ (CAP): for every k some width has reset capacity K1(w) ≥ k on every phase of every edge cycle | **PROVED IN LEAN** (R47, R48; carried in I11, I12). S2: posted, Human Verified, and in the kit (M61). The cascade credits Lowry, PR #60 (P6). |
| (CAP) for k ≤ 7,911, with f(k) ≤ 265,441 | COMPUTED, outside Lean (M40, R37) |
| (CAP) ⇔ (L∞): reset words at arbitrarily large depths in every phase of every pointed recurrent strip | Hand proof by compactness (M39, R37; [every-k-chain.md](research/m29/every-k-chain.md), carried in K9, I11). **L∞ ⇒ CAP proved in Lean (R56), independently carried in I29. The converse is a hand argument.** |
| (L∞) in one fixed phase of every three | In Lean (I10, carried in R49). Not enough: the schedule reads k consecutive phases. |
| (L∞) ⇐ (DL⁻): the doubling lemma at the first clock losses of pointed recurrent strips | Hand proof, Theorem C of the chain (carried in K9, I11). **Not in Lean.** |
| (DL): every white interval at which the clock doubles has a reset in every tick | **OPEN: the wall.** COMPUTED at every source period 2–32 except 5 (K5); source period 64 to gap 73 except gap 72 (K7, K10); source period 128 to gap 64 (M44); no doubling of any period at gaps 31–55 (M47). A counterexample needs a power-of-two source period ≥ 64 and a gap ≥ 56. **Quiet sources are settled** (black ticks at least 33 apart: PROVED on exhaustive finite checks, K18 and I20); I25 covers all primitive three-mark sources at any period and five of either colour at periods 64 and 128. Any counterexample at those two clocks needs at least seven of each colour. The general busy case is open. |

**The gates of K8's schedule.** 1, the statement: passed (K9). 2, S2 proposed: passed, and S2 is posted (K11, M51).
3, the wall: called (K11); the inquisition round was held and is closed (K16–K25), with the wall still standing.

## The next block (K25)

The round's handover (K25 §5) ranks the pulls: 1, the relaxed lemma; 2, consolidate beside the wall; 3, busy sources
by counting marks. Its curiosities and misgivings are listed there.

| Who | What | Reader | State |
|---|---|---|---|
| claudeM5 | The weakest statement about doubled stretches from which Theorem C still gives (L∞), written into [every-k-chain.md](research/m29/every-k-chain.md) with its proof sketch. Say plainly if none weaker than (DL⁻) works. | gptM5 | Written as §3.5 (M62): weaker statements work, none is weakest, and with no bound named the relaxation is (L∞). With gptM5 for the read. |
| gptM5 | The compactness step in Lean: (L∞) ⇒ (CAP) on R37's strips. Then the carrying read of I25's reductions ([busy-sources.md](research/m29/gate3/busy-sources.md), owed from K19), and the read of claudeM5's statement. | gptIntel | Compactness carried (R56, I29). I25 carrying read passed (R57). M62’s relaxed statement is ready for the assigned read. |
| gptIntel | The prior-art search (METHOD §4) on the open statement's two forms: unique preimages of recurrent points of a one-sided cellular automaton on the 2-adic integers, and period doubling along rule 30's left edge. Then the read of gptM5's Lean. | claudeCloud | Search filed as P11–P13 (I28), with claudeCloud for review. R56 carried in I29. The short-cluster and long-gap checks passed (I30–I31). Period 256 passed; the last dyadic clock, 512, is running. |
| claudeCloud | Conducts. Reads the search. Designs the census under claudeM5's statement once it is carried. | — | Waits on the two above. |

## Submissions

Each candidate follows METHOD §12: any worker authors it, a different worker reads it, both agree on the same
digests, then the owner gives the word; the Wolfram steps run on the M5 laptop. Standing consent to post: none.

| Candidate | Result | Stage |
|---|---|---|
| **S1** (R2; M17, R15) | For every nonzero finite seed and every age t ≥ 80, every four-tick predecessor is finite with its edge exactly four cells inside; all 16 wall histories occur. | **Lean Verified, Human Verified:** [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f) (M26, M29). The maintainers take no more per-k steps (M29). Its kit PR #357 is closed, replaced by #368 (M54). |
| **S2** (M29) | Conditional on reset capacity (CAP), for every k an explicit age from which every k-tick predecessor is finite with its edge exactly k cells inside, and every wall history occurs (`conditional_every_k`, `capacity_at_settling_age`). | **Lean Verified, Human Verified, in the kit:** [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f), posted 19 Nov 18:15 UTC (M51). The kit carries it as `Rule30EveryKInverse`, `Rule30EveryKCascade` and `Rule30EveryKStatement` (kit `fd00829`, from PR #368; M61). Quint's #370 builds on it. |
| **S3** (K2, I2) | The mean first white gap is at most 2^Q + 1 over the nonzero labelled Q-bit first children, for every Q > 0 (`pooled_first_return_bound`). | **Lean Verified, Human Verified, in the kit:** [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2), posted 19 Nov 17:47 UTC (M48). Kit PR #366 merged: the kit's main `8451547` (K15). |

Verifier's kit commit: `5fb5915` (5 November). The kit's main is `3f32e1a`; KIT.md is in step (M61).
Stages: proposed, packet, read, agreed, owner's word, posted, Lean Verified, pull request, merged.

## Latest results (newest first)

- **20 Nov, I29.** R56 compactness proof carried on kit 3f32e1a, including kernel replay of the composition from (L∞) to the physical every-k statement. R57 carries the all-period three-mark results. K25’s next five-mark case starts.

- **20 Nov, I28.** The [prior-art search, P11–P13](PRIOR-ART.md#p11--2026-11-20--unique-predecessors-on-a-recurrent-set-and-in-the-whole-odd-half-line) found earlier theorems on unbounded left-edge clocks, full-shift generic preimages, and the ring marker. None of the sources reviewed proves unique arbitrary parents for every recurrent odd left-edge row. Sent to claudeCloud for review.

- **20 Nov, R57.** Both all-period three-mark reductions passed their carrying read. The full scalar replays reproduced sharp closing wheels 84 and 76. [R57](CHAT-LEDGER.md)

- **20 Nov, R56.** Arbitrarily deep closed runs on every pointed recurrent phase imply the kit’s unbounded reset capacity in Lean. The recurrence hypothesis remains open. [R56](CHAT-LEDGER.md)

*The entries that still inform the next step. All 69 entries as they stood before rotation 3, back to 12 November, are
in [archive/now/latest-results-to-2026-11-19.md](archive/now/latest-results-to-2026-11-19.md).*

- **20 Nov, I27.** K21’s three local agreement laws and K22’s gate law carried. A white agreement occurs two wheels left of black positions 2, 5, 8, … counted from the right of each run in K21’s test. Through wheel 3,000 there are 1,601 strict settling records and 507 ties. The front bounds the consecutive settled prefix. Read K19 and K23–K25. [I27](CHAT-LEDGER.md)

- **20 Nov, K25. The round is closed; the owner chooses the relaxed lemma and consolidation.** The handover ranks
  the pulls and lists the misgivings: the relaxed lemma has one test case (period 5) and must not slide into (L∞)
  itself. Two answers to the owner, both known and reproduced: no formula gives the gaps between white wheels,
  though a stretch on clock Q is of the order of 2^Q wheels and the kit proves a ceiling of 2^(2Q); and a clock
  can come again: the stretches run on clocks 1, 2, 4, 8, 16, 16, 16, 32. [K25](CHAT-LEDGER.md)

- **20 Nov, K23. The wheels that settle to one colour, and a correction.** A white wheel is white from some tick
  on, not at every tick: wheel 28 is black ten times before tick 31 (the owner's catch). Up to wheel 88,000 seven
  wheels turn white for good (2, 7, 28, 399, 53,207, 58,286, 87,866), and the wheels that turn black for good are
  exactly the wheel two on from each, with wheels 0 and 1. All known (the kit, Rowland); reproduced with the tick
  at which each settles. The front tracks the deepest consecutively settled prefix (I27); the front drifts left about 0.25 cells a tick, as NKS reports (K24).
  [K23](CHAT-LEDGER.md), [K24](CHAT-LEDGER.md)

- **20 Nov, K22. The four guesses at a wheel split in exactly three ways: the owner's logic gates.** Start the
  reading of a row at any wheel. Count the black cells of the row from there leftwards to the first white one.
  None, or 3, 6, …: guess 1 stands alone (an OR of the two guessed cells). 1, 4, 7, …: guess 3 alone. 2, 5, 8, …:
  the left cell alone decides. Once a reset word has been read, all four end the same. COMPUTED at all 401,270
  rows and starts of every odd source to period 11; PROVED from the four possible reader states (I27). Read left to
  right it is a dial with three positions, and a white cell arriving on "guess 3 alone" is the capture. The
  explorer shows the split at every wheel of a row as a strip. [K22](CHAT-LEDGER.md)

- **20 Nov, K21. How closely the guesses of the row above match: a first measure (not the one the owner meant, K22).** Two different guesses agree
  only on single white cells: one in three under a black run of the row read, none where it is white; a black cell
  they agree on makes them one (PROVED on a table of 12 local cases (I27); COMPUTED on 4,070 rows and 2,637
  stretches). The measure, *pinned*, is the share of the row above on which all four guesses agree: everything left
  of the row's last reset word, plus a third of the black to its right. Period 5 is alone on it: four rows under a
  third (ticks 1, 3, 7, 9, the four the owner named), where every other whole excursion's worst row is at a half
  or more. On [the explorer](research/m29/gate3/excursion-explorer.html). [K21](CHAT-LEDGER.md)

- **20 Nov, K19. gptIntel's busy-source witnesses replay exactly; the round has an explorer page.** All eight of
  the block's sharpest cases reproduce on an independent simulator (84, 21, 76, 38, 104, 85, 104, 88). The carrying
  read of the all-period reductions goes to gptM5. The round's new picture is a page on which any source can be
  tried, with single cells coloured by what made them and white triangles outlined. [K19](CHAT-LEDGER.md)

- **20 Nov, I26.** [Irregular-source results](research/m29/gate3/busy-sources.md). A longer reset occurs by wheel 17 for three pulses and 28 for three holes. For separated period-five perturbations the sharp bound is 12, or 8 when a 6-gap occurs. Reversing three close spacings often changes the last catch.

- **20 Nov, I25.** [Busy-source certificates](research/m29/gate3/busy-sources.md). Sharp latest catch 84 for three pulses and 76 for three holes at every source period. Five of either colour passes at 64 and 128. Nearly white period-five perturbations can still catch in every phase. Carrying read requested.

- **20 Nov, I24.** The complementary three-white-tick theorem passes with sharp bound 76; the busy-source block continues at clocks 64 and 128.

- **20 Nov, I23.** Every source of three black ticks in its least period passes, with sharp latest closing wheel 84.

- **20 Nov, I22.** Three-pulse sources at all dyadic periods pass. The finite check for arbitrary least period is running.

- **20 Nov, I20.** K18’s quiet-source proof carried; gptIntel is on the NAS and M60’s route change passed review.

- **20 Nov, K18. Among quiet sources period 5 is the only failure at any period; the wall is about busy sources.**
  PROOF-SKETCH on three exhaustive finite checks: if a source's black ticks are at least 33 apart, every row of its
  doubled excursion is caught by wheel 20 and white cannot return before wheel 23. Between black ticks the pattern
  settles into an ordinary left side (22 wheels, any state, within 29 ticks), and a flip disturbs it in only eight
  ways. COMPUTED: one black tick per period at every period to 200; every source to period 26 for 400 wheels
  (2,694,343 sources), where nothing returns from period 7 on. A read is asked of gptIntel. [K18](CHAT-LEDGER.md)
- **20 Nov, K17. The round's first answers: single-cell rows and triangles are one thing.** The owner saw that
  every panel has rows whose reset words are all single cells, that period 5 has no longer reset word at all, and
  that the white triangles are sheared. Found (COMPUTED, exhaustive where local): a single cell is made by one of
  four 5-cell patterns in the row above, two of them a white triangle's corners; the row after a bare row can hold
  only runs of 1, 2 and 3; three bare rows in a row occur only in `11100` repeated, whose wheels repeat every five
  ticks; 85% of rows are first caught by a single cell. So the lemma has a form in shapes: every row of a doubled
  excursion has a free triangle corner before white returns. A restatement, not a proof. [K17](CHAT-LEDGER.md)
- **20 Nov, K16. The inquisition round on the wall is open.** One picture of the six one-black-tick excursions.
  Period 5 is the same in kind as its neighbours and ends early. Its two bare rows are caught in the very next
  interval (COMPUTED), so the lemma's one failure is not a failure of what (T) needs. Two small facts: every
  doubled excursion catches as many rows at once as its source has black ticks, and white returns exactly when two
  neighbouring wheels agree. Five questions wait for the owner. [K16](CHAT-LEDGER.md)
- **20 Nov, M61. S2 and S3 are in the kit and Human Verified; Quint builds on S2.** The kit's main is `3f32e1a`.
  Quint's #370 proves 2k ≤ f(k) and 2·K1(w) ≤ the settling age on S2's definitions. [M61](CHAT-LEDGER.md)
- **19 Nov, K15. State of play at rotation 3; S3 is merged into the kit.** The kit's main `8451547` carries the
  pooled first-white-return bound in `Rule30TemporalProfiles` (pull request #366). Kit PR #368, S2, is open with no
  review yet. K8's schedule is complete, and the ledger's new header is the state of play. Next: the inquisition
  round on the doubling lemma. [K15](CHAT-LEDGER.md)
- **19 Nov, K14. The cloud host is on the NAS store.** Eight identity checks in a row and forty more in a burst,
  all without a retry; five moved files match the digests the ledger cites; a 5 MB file went up and came back
  identical; writes outside claudeCloud's own areas are refused. This also tests the public certificate and the
  router's forward, which could not be tested before the move. [K14](CHAT-LEDGER.md)
- **19 Nov, M58. The store is on the NAS.** All 288 files and the write log were copied and re-verified on the NAS,
  and the four token hashes were imported, so every token is unchanged. The new store serves every file unchanged
  through its public name. Each host needs only its new address. [M58](CHAT-LEDGER.md)
- **19 Nov, M54. S2's kit pull request #368 is open, and #357 is closed.** The three modules go to the kit as a
  conditional answer to #357. That is the statement for every k by one argument, with its capacity hypothesis open.
  The tree is the one gptM5 passed (R55). #357's four-tick module, which the kit was not taking, is closed with a
  pointer to [#368](https://github.com/WolframInstitute/Rule30PrizeKit/pull/368). [M54](CHAT-LEDGER.md)
- **19 Nov, M51. S2 is posted and Lean Verified.** Entry
  [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f) states
  the inverse-tick theorem for every k by one argument, conditional on reset capacity, which is open. It was posted
  once from the release that its author and reader agreed on (`120cf1cc…`), and passed the verifier's kernel replay
  with standard axioms. The #357 reply is the owner's next decision. [M51](CHAT-LEDGER.md)
- **19 Nov, M48. S3 is posted and Lean Verified, and its kit pull request is open.** Entry
  [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2), posted
  once from the release that author and reader agreed on (`6c69946a…`), passed the verifier's kernel replay with
  standard axioms 90 seconds later. Kit pull request [#366](https://github.com/WolframInstitute/Rule30PrizeKit/pull/366)
  extends `Rule30TemporalProfiles` and its catalogue row. [M48](CHAT-LEDGER.md)
- **19 Nov, K11. Gate 2's checks pass; Gate 3 is called; the store has a tested container.** S2's Lean compiles
  at both kit revisions under two workers and two novelty searches found nothing like it, so whether it is
  submitted is now the owner's decision; claudeCloud recommends a partial with the hypothesis in its title. S3
  waits only for the author's agreement on `6c69946a…`. B2 and C2 gave no mechanism for the doubling lemma, so the
  inquisition round is called. The store's server runs as one container: `store.php` unchanged, 32 of 32 checks,
  a certificate obtained from a test authority through the HTTPS port alone. Not published. [K11](CHAT-LEDGER.md)
- **19 Nov, M47. B2: no doubling of any period at gaps 51–55; S3's v2 notebook rebuilt; B3 drafted.** The frozen
  all-period scan decided gaps 51–55, each with a checked completeness certificate, and found no doubling. K8's
  answer is no. It stopped at gap 56, whose certificate ran out of time (UNKNOWN); five of seven predictions held.
  With M44 B, no doubling has a gap from 31 to 55, so a counterexample to the doubling lemma needs a power-of-two
  source period of at least 64 and a gap of at least 56. S3's v2 notebook passes every build gate. B3's drafts of
  the S2 essay and the next #357 reply are ready for a content read. [M47](CHAT-LEDGER.md)
- **19 Nov, K9. Gate 1 passes, and the pooled bound is sharp.** The A1 statement, the B1 chain and the pooled proof
  all carry. An exact control at clocks 1–14 finds the pooled sum never above N² − 1, equal to it at Q = 1 and 3, and
  within 0.04% at Q = 14; the largest gap there is 9.59 × 2^14, against 9.70 for a geometric wait (COMPUTED). Lowry's
  twelve old pull requests stopped on his side and none of their modules is in the kit, #60 included. The store
  client now retries the web host's verification page. [K9](CHAT-LEDGER.md)
- **19 Nov, K7. Source period 64 is UNSAT at gaps 68 and 70 too, and the early doubling returns are one family.** K2's
  SAT run replicated M43 at every gap 31–63, 65 and 67 under an independent encoding and decided 68 and 70 (COMPUTED,
  solver claims); the tail at 74–96 is closed unrun. I2's pooled mean gap of at most 2^Q + 1 carries. A census of all
  9,973,336 odd classes at P = 2–28 finds doubling returns within 100 wheels only at gaps 21, 56, 88, 23 and 98, all
  from the single-pulse source; none at P = 7–28. [K7](archive/ledgers/CHAT-LEDGER.2.md)
- **19 Nov, M44. No reset-free doubling at source period 128 at gaps 5–64, and (exploratory) no doubling of any
  period returns to white at gaps 31–50.** At period 256 the odd family is UNSAT at every gap 31–64 under kissat, and
  at 31–61 and 63 under CaDiCaL with its internal proof checker; no doubling of period 128 returns to white at 31–43
  or 45. B, exploratory: G_n's cyclic part, listed by SAT on windows (exact against M42 at gaps ≤ 30), has no
  swappable pair at gaps 31–50, so up to gap 50 the only reset-free doubling at any period is period 5's at gap 23.
  With K5, a reset-free dyadic doubling needs source period ≥ 64 and gap ≥ 51. [M44](CHAT-LEDGER.md)
- **19 Nov, K5. Every doubling white interval of source period 2–32 except 5 has a reset in every tick**
  (COMPUTED, exhaustive over 138,871,107 classes of unrestricted odd sources; P = 32 replays M41 exactly). The resolved classes finished
  by wheel 152. Period 5's single exception is M42's gap-23 orbit, which no dyadic strip carries. A uniform linear
  bound on resolution and a lower bound on the earliest return are open (I2). [K5](CHAT-LEDGER.md)
- **19 Nov, K3–K4. Mean white-return gaps track the doubled clock in the samples** (MEASURED). Plain means at
  Q = 14–24 range from 0.912 to 1.015 × 2^Q. Odd-source means at P = 7–12 range from 0.843 to 1.182 × 2^(2P).
  The six complete A0 gaps are consistent with that scale. Geometric waiting times and small-gap probabilities at
  larger P remain conjectural. At P = 5 one of three primitive odd classes returns at gap 23 with a reset-free tick.
  [K3, K4 and I2](CHAT-LEDGER.md)
- **19 Nov, M43. (G30) is false, and the doubling lemma survives at source period 64.** A whole white interval of gap
  32 and period 64 is reset-free in one tick: gptM5's period-five ring tiled four times, with a disturbance that keeps
  the tiling wheels from staying white. This defeats gap bounds 19 and 30 on unrestricted dyadic intervals. SAT at source period 64
  finds no reset-free doubling at gaps 31–67 (kissat and CaDiCaL), or at 69, 71 and 73 (kissat). The open statement
  is the doubling lemma itself. [M43](CHAT-LEDGER.md)
- **18 Nov, M41. No doubling white excursion at source period 32 is reset-free in any phase.** All 134,215,680
  necklace classes (8.6 billion pointed lifts) were run with every tick at once, and the control reproduces R44's
  table at periods 1–16. Every reset-free whole interval found at P ≤ 32 has a gap of at most 16, inside R40's
  gap-graph range 5–19. So a gap bound of 19 for reset-free intervals, (G), would suffice for every k once R40's graph
  carries. M41 also carries R37 and R43 (PROVED IN LEAN) and R44 (computer-assisted), with independent replays.
  [M41](CHAT-LEDGER.md)
- **18 Nov, R43–R44.** At least one of every three consecutive phases of every pointed recurrent strip has resets arbitrarily far from its black edge. The two-anchor transfer is Lean-checked. If two phases both have reset-free tails, every sufficiently deep white anchor has a rising child at those two ticks. Every-k still needs control at the prescribed phase. [Proof, numerical controls and route decision](research/m29/white-return-block.md)
- **18 Nov, M40. f(k) ≤ 265,441 for every k ≤ 7,911.** M35's one-layer schedule, run exactly at width 87,867 on
  all 16 phases of the four strips, clears 7,911 layers in the worst phase (B1). It advances at a steady 11 wheels
  per layer from width 4,096 on. Rule30FourFronts puts every row's top 87,867 cells on a strip from age
  87,866 + 177,575, so M34's two-factor bound gives one explicit age for 7,911 ticks (PROVED, computer-assisted, carried in R37).
  This replaces 4095 + 2^4096 for k ≤ 383.
- **18 Nov, M35. One-layer resets alone keep pace to width 4096:** 383 layers, one per 10.7 cells, with every
  layer's registers coalescing within 65 cells at every depth (COMPUTED). With the kit's universal left side, f(k) is
  finite for every k ≤ 383 (PROOF-SKETCH, pending carrying read). The missing step for every k becomes bounded
  one-layer coalescence in the edge band. Draft reply for #357 ready, not sent.
- **18 Nov, M34. Why the ages grow: f(k) ≤ g(W(k)).** The converged edge band (the limit cycle) resets about one
  inverse layer per 11–12 cells, in steps (K(w) = 3 on widths 25–61, 11 by width 123); every row's top w cells reach
  the cycle by age g(w) ≈ 1.4w (g(128) = 178). Together they bound f with no cover per k: f(9) ≤ 144, f(10) ≤ 157,
  f(11) ≤ 172 (PROVED, computer-assisted, carried in R29). Both M33 predictions held.
- **18 Nov, M32. The thresholds f(k) through six ticks:** f(1) = 8, f(2) = 24 (kit), f(3) = 31, 59 ≤ f(4) ≤ 72
  (R23, R25, carried in M32: PROVED, computer-assisted), 73 ≤ f(5) ≤ 78 and 104 ≤ f(6) ≤ 108 (PROVED, computer-assisted, carried in R29). Closure is synchronisation of the 2^k wall histories (PROVED), and their merge front moves out from
  the wall about 9 cells per layer (median), with hold-ups of up to about 50. A two-tick rhythm in the steps is
  frozen as a prediction for k = 7, 8. The ledger was rotated (archive 1).

## Open threads

- **The inquisition round (Gate 3):** closed (K25). The owner chose the relaxed lemma and consolidation; assignments and readers are in the current work table.
- **The store:** gptIntel confirmed the NAS switch and passed the scoped M60 route review (I20). The old store comes off the website on the owner’s word. Then claudeCloud updates the installation notes (K14).
- **K6:** METHOD §12 reads rightly off the M5 with three handoffs, which R45, I2 and M45 describe: the builder's
  notebook and receipt pass through the author's verification; the M5 operator verifies the packet's digests before
  `post.sh`; the raw portal response stays on the M5. Writing them into §12 is the conductor's call. Not yet done.
- **The owner's round of warm pulls (17 November).** gptM5 posted R2–R6 and claudeM5 posted M6–M10. Those not on the
  main line are in the table below, open and not started.
- Visualisations proposed, not built: an interactive map of the open statements; the branching-walk fan; Mahler's
  valid starts on the circle; a timeline of kit contributions by theme.

### Pulls in progress

One row per pull; the full text is the ledger post named in the first column. Any worker adds to a row's Status as
the work goes. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission candidate? |
|---|---|---|---|---|
| L1 (placego L1680) | 17 Nov 10:28, Local (inherited) | The reach map, then the reach of later free bits by sampling to depth 81 | Open. Folded into M8, which gives it a question: the reach inside the gap language. | no |
| L1 (placego L1679) | 17 Nov 10:28, Local (inherited) | Replay the kit's surviving-seed law against placego L1675's tables | Open. Partly answered by M10: the law counts {3, 5}-gap words (N = 1, 2, 4, 7 at H = 6–24, by hand). To do: the replay. | no |
| R2 | 17 Nov 19:55, gptM5 | Does the twin of a late surviving row have a finite past of its own? | In progress. Every four-tick past is finite from age 80 (R8–R9, PROVED in M17; the base is the kit's `band_from_age_twenty_six`, P3, so M17's repair was unnecessary, M18). The planted fixed point is a leaf off its own orbit. R11 refutes a second surviving seed at age 46. All 11 tested fully surviving age-46 ends have four recent pasts. The four-tick bound at ages 46–78 is open in general. Age-80 proposal handoff and both Lean passes in R15. M18: R11's starting-width bound and odd endpoint multiplicity PASS (PROVED), and the age-46 singleton replays independently. The bound 2j + 2 is far from sharp: the least starting widths with a full guarded tree are 7 and 13 for j = 1, 2, and above 14 for j = 3, 4 (COMPUTED).  M22: proposed as S1. M26: S1 posted, Lean Verified as R30-20261118-c8b41f; kit PR #357 open. M29: the kit wants the statement for every k instead, now pull M29. | **yes: S1** (M22) |
| R3 | 17 Nov 19:55, gptM5 | Do switches between 3-gaps and 5-gaps spend seed bits? | Open. Joined to M7 (M11): the kit's complexity criterion relaxes "finitely many switches" to "complexity near n". M16: that relaxation fails for u ∅, whose complexity is exponential; R3's own question, the cost of switches for finite seeds, is untouched. To do: compare 3,5 with 5,3; test the returns 3,5,3 and 5,3,5. | no |
| R5 | 17 Nov 19:55, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | Open, not started. To do: cuts N and N + 12 at one alignment. | no |
| R6 | 17 Nov 19:55, gptM5 | Problem 3: do c(2^k) and c(2^(k+1)) differ infinitely often? | Open, not started. Would exclude every eventual power-of-two period. Pointer: kit `rows_at_powers_of_two`, `row_restart` (M11). | no |
| M8 | 17 Nov 20:07, claudeM5 | Does Theta's reach stay bounded inside the gap language? | Open, not started. Carries the inherited reach thread (L1, placego L1680). Control: the 90/150 hybrid wall. | no |
| M9 | 17 Nov 20:07, claudeM5 | Forbidden gap words and entropy of the gate trap lifted to 20–24 columns | Open, not started. Quint's PR #348 is no longer open (M14): read it or its merged module first. Widens M7 from u ∅ to every right half that enters the trap. A first number (M16): u ∅ uses about 0.07 bits per white step, against 0.256 for the free 3/5 language. | no |
| M10 | 17 Nov 20:07, claudeM5 | A matrix of which exact laws the barrier controls share; counts alone cannot prove Q01 | Open, not started. Supplies the controls for M8 and R2 (M11); M6, which it also served, closed in M21. | no |
| M29 | 18 Nov 11:34, claudeM5 | The maintainer's question on #357: an age f(k) for every number of inverse ticks k, with no cover per k; why the ages grow (8, 24, 80) | In progress. Comes from R2 and S1. Bounds: f(1) = 8, f(2) = 24, f(3) = 31, 59 ≤ f(4) ≤ 72, 73 ≤ f(5) ≤ 78, 104 ≤ f(6) ≤ 108, f(7) ≤ 131, f(8) ≤ 132, f(9) ≤ 144, f(10) ≤ 157, f(11) ≤ 172 (carried); f(k) finite for k ≤ 383 (M35, carried); f(k) ≤ 265,441 for every k ≤ 7,911 (M40, from Rule30FourFronts and the exact schedule on all four strips, carried in R37). R37 independently carries M36–M40. The white-diagonal drop proposal fails on a Lean-certified pointed strip. The sufficient ordinary reset recurrence remains open. R44 proves one of every three phases has arbitrarily deep ordinary resets (carried in M41, with R37 and R43). The unrestricted single-phase local-anchor route is closed by a period-five ring. Continue with the rooted period-doubling interval in a prescribed phase; the control data contain zero bad doublings. M41: none at source period 32 either, at any gap. Reset-free whole intervals at P ≤ 32 all have gaps ≤ 16, so (G), a gap bound of 19, together with R40's gap graph would suffice. M42: R40's gap graph carries. (G) holds at every gap ≤ 30 for every dyadic period, and the only dyadic doublings below gap 31 are the kit's 2→7 and 7→28. So (G30), reset-free dyadic whole intervals have gap ≤ 30, suffices; it is open only at source period ≥ 64 with gap ≥ 31. A period-5 reset-free doubling at gap 23 shows the dyadic clock is needed. M43: (G30) is false, refuted by a ring-tiled interval of gap 32 and period 64, so the gap-bound route is closed. The doubling lemma (every dyadic doubling white interval has a reset in every tick) holds wherever tested: gaps ≤ 30 at every period, source periods ≤ 32 at every gap, and source period 64 at gaps 31–67 (two solvers) and 69, 71, 73. Progress reply posted on #357 (M36). Bounds are data, not submissions (METHOD §12). K2: an independent encoding reruns the odd family at P = 64 (running); a counting picture predicts every small-gap odd instance UNSAT whatever the resets. K5: the doubling lemma holds on unrestricted profiles at every source period 2–32 except 5 (one non-dyadic orbit). M44: no reset-free doubling at source period 128 at gaps 5–64 (kissat at every gap 31–64, CaDiCaL with internal proof checking at 31–61 and 63); exploratory, G_n's cyclic part has no swappable pair at gaps 31–50, so no doubling of any period returns to white there. Open for dyadic doublings: P = 64 at gaps 68, 70, 72 and 74 on (claudeCloud's K2 queue is running these), P = 128 from gap 65, P ≥ 256 from gap 51. Next for claudeM5: freeze the cyclic-part test at gaps 51–100, blind, with K3–K4's returns at 56 and 88 as positive controls. K8: the schedule. Stream A (gptM5) puts (CAP) ⇒ (T) in Lean as S2; B (claudeM5) writes the chain on paper and runs B at gaps 51–100; C (gptIntel) proves the pooled count and attacks the wall by pair counting. M47: B2 decides gaps 51–55 with checked certificates and finds no doubling of any period; gap 56 is UNKNOWN on certificate time. With M44 B, no doubling has a gap from 31 to 55 (31–50 uncertified), so a counterexample to the doubling lemma needs a power-of-two source period of at least 64 and a gap of at least 56. | S2 proposed (R50) |
| K2 | 19 Nov 10:19, claudeCloud | The counting picture of white returns: an interval of temporal period Q returns to white after about 2^Q wheels, and a tick's reset-free stretch decays like a fair-coin string's (rate 0.848); as a model for the observed scarcity of short-gap doublings | In progress. K3: the gap law holds at Q = 14–24 for plain and doubling intervals (MEASURED); tails near 0.848; period 5 is the exception. K5: census at every source period to 28 fits the reset law. K7: the SAT run replicates M43 at gaps 31–63, 65 and 67 and decides 68 and 70; six instances restarted, the tail closed. I2: the two structural steps carry, the pooled mean is at most 2^Q + 1 (carried in K7), and the geometric law stays a conjecture. Explains M41–M43's census and SAT data; bears on M29's doubling lemma. K8 addendum 1: the kit's nine white-to-white gaps at clock 16 on the four strips average 1.04 × 2^16 (P10). | **yes: S3** (I8) |
| K5 | 19 Nov 10:44, claudeCloud | The resolution law: after a doubling white, why does every tick close a reset within about 4.2P wheels (0.98–1.31 × 4.2P at P = 12–32; not a bound, K7)? A linear resolution bound together with a sufficient earliest-return bound would imply the lemma above the period-5 exception | Open. P = 29–32 done (K5, addendum 1): worst 0.99–1.13 × 4.2P. Joined to K2; bears on M29. Stream C2 of the schedule takes the resolution side (K8). | no |
| K8 | 19 Nov, claudeCloud | The unique-predecessor form: (L∞) says every recurrent point of F(x) = 4x ⊕ (2x ∨ x) on the odd 2-adic integers has exactly one preimage, so no row off the strips maps onto a strip row; and it is enough that infinitely many white intervals of each strip reset every tick | In progress. Both reformulations carried in I7 and written into M46. Source comparison P11–P13 (I28), with claudeCloud for review. | no |

## Recently closed routes

- **K3, where reset-free doublings occur** (closed 19 Nov, K5). K4 corrected K3's period-5 reading (one orbit among
  three classes), and K5's exhaustive census finds no other reset-free doubling at any source period 2–32. Reopens if
  one appears at a period above 32.
- **R4, source multiplicity and deep-gap density** (closed 18 Nov, R21). The exact count and vacuum-mass identity are PROVED (R19, M27). M28 refuted its proposed spacing with C = 3. R21 shows that time invariance and fixed-depth right-edge data allow positive vacuum mass. Reopen for a quantitative restriction using the single seed’s distant white left tail or another seed-specific bound on deep-source occupancy. The seed’s vacuum mass is open.

- **M6, the floor as the density of the sparsest eternal row** (closed 17 Nov, M21). For G the floor is the
  ether's 1/7 (COMPUTED, M15; known, P1), but no window law carries it (M15). The gap floor has slope about 0.275
  (COMPUTED to H = 180, M20), far below every periodic gap row measured, the least being all-5 at 68/155 (M21). Reopens
  if the minimisers' deficits stay bounded beyond H = 180 (4 at H = 140–180), which by compactness gives an
  aperiodic floor row.
- **M7, CQ01Empty through the kit's bounded-excess criterion** (closed 17 Nov, M16): u ∅ has exponential factor
  complexity (MEASURED). Either it is eventually periodic, and CQ01Empty follows, or p(n) − n ≥ 64,281 from
  n = 150 on (COMPUTED, with Morse–Hedlund). Reopens only with a proof that u ∅ has zero entropy.
- A bounded black frontier for Q01GapCore survivors: the frontier recedes (placego L1673).
