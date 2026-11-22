<!-- portal-list: 2026-11-22 17:38 UTC, 393 entries, 57 portal-only -->
# The portal outside the kit

*Every portal entry with no kit modules, each read with the scrutiny the kit's review would give it. The kit's own
results, which are most of the portal, are in [KIT.md](KIT.md) and [KIT-INDEX.md](KIT-INDEX.md); this file covers
only what those cannot. The inventory begun in M97 now matches the portal list of 2026-11-22 17:38 UTC (393 entries)
and kit main `54d030c` (I108). Find new portal-only entries with `python3 tools/portal/portal_only.py`; see
[KIT-UPDATE.md](KIT-UPDATE.md). Check a source before building on anything here.*

## Why it exists

- **The portal records every submission. The kit holds only what was merged into its catalogue.**
  - The portal marks each entry's kit modules (its `kitContribution` field). 57 of the 393 entries have none.
  - Our documents track the kit, so those entries were invisible to `find_known.py`.
  - On 22 November, two Lean-Verified, Human-Verified entries of this kind (Norris's shield cascade) already
    held a result that path 1 called new (M95, [PRIOR-ART P46](PRIOR-ART.md)).
- **A portal-only entry is one of two things.** It is kit-worthy but was never sent, as early entries often were,
  or it is not strong enough for the kit. The class says which, as far as a read can tell.
- **Read depth:**
  - **A**: abstract and headlines only;
  - **S**: statements read in the source and compared with the kit;
  - **L**: the Lean replayed.

## Counts

| Class | Entries |
|---|---|
| Missed | 9 |
| Port | 8 |
| Pending | 2 |
| Check | 6 |
| Covered | 7 |
| Below the bar | 25 |
| All | 57, of them 25 ours |

## Missed (9)

Kit-fit and kit-worthy, and not in the kit. For our own entries these are pull-request candidates. For others', credit them when building on them, and they can be raised with their authors.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261023-c5e3c0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-c5e3c0) | 2026-10-23 | Andy Norris; Jesse v1.4 (solidSF) | Lean Verified, Human Verified | The same cascade and strip results, without the Problem 2 and 3 bridges (17 headlines). | As 603218, which extends it. | S |
| [R30-20261023-8e6bd3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8e6bd3) | 2026-10-23 | ours | Lean Verified, Human Verified | The death time at width 52 is exactly 96: a start black at depth 1 at every even time below 96 (`death_time_52_exact`), with witnesses at widths 56 and 60. | The kit's Rule30ZeroBoundaryWidth52 row calls 96 "observed, not proved". A small extension. | A |
| [R30-20261023-603218](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-603218) | 2026-10-23 | Andy Norris; Jesse v1.4 (solidSF) | Lean Verified, Human Verified | Norris's self-replicating shield cascade: the right wall of a (0,1)^j shield stays black 2j ticks and spawns further shields, so a single-seed period with r ≥ 9j blacks and P − r + 9 ≤ 4·cascadePairs d j is excluded (slope 7/4, limit 7/11). Also 11 0^q for q ≥ 8, strip fixed points, a 32-block catalogue, and Problem 2 and 3 bridges. | The cascade is not in the kit, which holds Bosdure's later quarter-period theorem (slope 9/4). 11 0^q is the kit's Rule30WhiteRunEight. gptIntel's relay sharpens the cascade's constant (M95, P46). | S |
| [R30-20261023-7e9e6e](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-7e9e6e) | 2026-10-23 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Jen's left-permutive hypotheses hold for exactly four rules, 90, 150, 210 and 30 (`jen_class_iff_four_rules`), with equivalences for the single seed. | A small, clean extension of Rule30Realization, which names three of the four. | A |
| [R30-20261030-803bc4](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-803bc4) | 2026-10-30 | ours | Lean Verified, Human Verified | Finite ancestors on the line: every nonzero finite row y has a unique finite root x and age n with F^n x = y, and 2n is at most y's width (`finite_root_age`). It also gives a finite-parent test, a bijection of n-step pasts, and exact counts. | Core Lean, general, and nothing in the kit states it. It sits beside Hughes's inverse theorems and S6. A pull-request candidate. | A |
| [R30-20261105-c6874e](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-c6874e) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | The same as 4b74be. | A duplicate submission. | A |
| [R30-20261105-4b74be](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-4b74be) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint's bridges from machine complexity to aperiodicity, stated for every Boolean sequence rather than the centre column. | A small generalisation of Rule30Problem3Bounds. No kit theorem has these names. Submitted twice, with c6874e, and neither copy records the other. | S |
| [R30-20261115-043275](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-043275) | 2026-11-15 | KDRonald3; Claude | Lean Verified, Human Verified | A one-tape Turing machine computes the centre column in quadratic time: 9 symbols, 69 states, C = 21 (`exists_quadratic_machine`). | The kit has Problem 3's statements and Quint's lower bounds, and no upper bound. | A |
| [R30-20261115-2d4add](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add) | 2026-11-15 | KDRonald3; Claude | Lean Verified, Human Verified | For every row with a leftmost black cell, at every column, seven sets of three-cell windows recur, and so does a black pair. The white pair need not recur. | No kit row on recurrent windows was found. Compare Condrey's Rule30SourceObservables before calling it missing. | A |

## Port (8)

Kit-worthy in substance, but the proof uses Mathlib and the kit is core Lean without it. Each is a kit candidate only after a port. All are ours.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261022-1d5070](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-1d5070) | 2026-10-22 | ours | Lean Verified, Human Verified | A repeat on the centre column cannot put its white run inside the settled band of left diagonals: a refinement of the kit's `window_jen_col`. | Mathlib. | A |
| [R30-20261022-91b0b0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-91b0b0) | 2026-10-22 | ours | Lean Verified, Human Verified | Under a period-2 centre, a right neighbour that starts with near-squares at unbounded scales has no left edge (`corollary_F`). | A narrow family. Mathlib. | A |
| [R30-20261022-920c1b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-920c1b) | 2026-10-22 | ours | Lean Verified, Human Verified | For rule 210 beside the period-2 clock, the one-sided question is false and the left half is linear. | The same barrier reading. Mathlib. | A |
| [R30-20261023-0c4a33](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-0c4a33) | 2026-10-23 | ours | Lean Verified, Human Verified | Every characteristic Sturmian word is excluded the same way. | Superseded by 8084e6. | A |
| [R30-20261023-1bf4dc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-1bf4dc) | 2026-10-23 | ours | Lean Verified, Human Verified | For rule 210 (the sibling of rule 30 that shares Jen's hypotheses), no finite configuration keeps the period-2 clock on its centre column (`no_finite_clock`). | It bears on the kit's barrier (Rule30Realization): what separates 210 from 30. Mathlib. | A |
| [R30-20261023-8084e6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8084e6) | 2026-10-23 | ours | Lean Verified, Human Verified | Every Sturmian word, of every irrational slope and intercept, is excluded as the visible right neighbour of a period-2 centre column, for every row with a leftmost black cell (`sturmian_excluded`). | An exclusion for an infinite family, which the kit has no form of. It uses Mathlib, and the kit is core Lean. | A |
| [R30-20261029-0ef6e2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2) | 2026-10-29 | ours | Lean Verified | The visible neighbour of a clocked row cannot eventually be a finite-step coding of an irrational rotation whose continued-fraction digits exceed 2^(r+1) arbitrarily late. | A family exclusion. Mathlib. | A |
| [R30-20261029-dc3d17](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-dc3d17) | 2026-10-29 | ours | Lean Verified | An explicit finite horizon for mechanical words, and their block recodings, beside a period-2 centre: b − a < 251(L + 2a + 4) + … | Uniform in slope and phase. Mathlib. | A |

## Pending (2)

In an open kit pull request. Moves out of this file when it merges.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261103-4b2a58](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261103-4b2a58) | 2026-11-03 | @AIOvernight; Claude; OpenAI Codex | Lean Verified, Human Verified | AIOvernight: no smaller observable certifies the word 1001 (Problem 2). | Open kit PR #238. Uses Mathlib. | A |
| [R30-20261120-2a993b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-2a993b) | 2026-11-20 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: K1 collapses to a 16-phase minimum through width 53,208, and the inverse ticks hold unconditionally through k = 25. | Open kit PR #371. | S |

## Check (6)

Not decided from the abstract and headlines: needs a source read.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261024-8d7751](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-8d7751) | 2026-10-24 | ours | Lean Verified, Human Verified | Ours: CQ01 for every right half with prefix R31 or R495, which enter the ether-and-wall trap by time 9. | Probably subsumed by the kit's gate-trap results and our later CQ01-on-entry module. Check whether these prefixes enter the 829-window trap. | A |
| [R30-20261029-99db76](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-99db76) | 2026-10-29 | Eric Elbaz (Tensorbend.ai) | Lean Verified, Human Verified | Elbaz: with the canonical alternating centre, an adjacent column white at all odd times forces every left layer to its depth's parity, so the left half is not finitely supported. | As 23ac1b. | A |
| [R30-20261029-23ac1b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-23ac1b) | 2026-10-29 | Eric Elbaz (Tensorbend.ai) | Lean Verified, Human Verified | Elbaz: if the column beside the centre is eventually black, its deviation from the alternating reference vanishes above 8(s/2 + 1) + 2. So a centre white on its finitely many defects reconstructs an infinite left half. | Possibly a kit-worthy Q01-type statement. Read the hypotheses against Rule30ZeroBoundary. | A |
| [R30-20261108-508c6c](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261108-508c6c) | 2026-11-08 | h3artfield; Cursor Agent (Composer) | Lean Verified | h3artfield: every Y < 2^52 dies within size Y + 4 steps of G, and Q01 is equivalent to Open131072Exit. | The equivalence would be a reformulation of Q01. Not Human Verified, and the portal has no separate Lean file. | A |
| [R30-20261108-a0fd36](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261108-a0fd36) | 2026-11-08 | h3artfield; Cursor Agent (Composer) | Lean Verified, Human Verified | h3artfield: the size of G grows by 2 per odd step, and first_even Y ≤ size Y + 4 for every Y would give Q01 (`Q01_of_size_add_four`). | The kit's Rule30RecognizableBarrier row cites it only for an observed sharpness. Is the reduction in the kit? | A |
| [R30-20261122-66c410](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-66c410) | 2026-11-22 | h3artfield; Cursor Agent (Composer) | Lean Verified, Human Verified | h3artfield (today): a finite trace-horizon barrier (a rejoining edit first differs before W), and an eight-bit obstruction to universal entry into the gate trap. | New. Unread. | A |

## Covered (7)

The kit holds it, or something stronger, or credits it inside a row. The portal tag is missing, or the kit's copy came from another entry.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261022-0616de](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-0616de) | 2026-10-22 | ours | Lean Verified, Human Verified | Left diagonals: their periods are unbounded, no two adjacent ones are eventually white, and the settled band has no long white run. | The kit's Rule30LeftUnbounded (AIOvernight, 28 October) proves the unbounded periods. Ours came six days earlier, with Mathlib. | A |
| [R30-20261023-521830](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-521830) | 2026-10-23 | @AIOvernight; OpenAI Codex; Claude | Lean Verified, Human Verified | AIOvernight: the centre is not eventually 0^9 1 nor 0^7 1011. | 0^9 1 is the kit's Rule30WhiteEndNine, by the same authors three days later. 0^7 1011 is a single word. | A |
| [R30-20261030-60990f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-60990f) | 2026-10-30 | Jeongseop Lee; OpenAI GPT-6 (Codex); Claude Opus 5.5 (Anthropic, via Claude Code) | Lean Verified, Human Verified | Lee: the return gaps of the one-cell right seed under the alternating drive are 3 or 5, and some words never occur. | Cited in the kit's Rule30GateTrapWords row as the external comparison. Rule30GateTrapLift has 3535353 after entry. | S |
| [R30-20261104-6888b8](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261104-6888b8) | 2026-11-04 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: explicit centre-column exclusions for the remaining certified blocks of Rule30BlackRunBlocks, and for every white-bounded block of length at most 4. | The kit's Rule30BlackRuns has 1^r u excluded for r ≥ 9 and len u ≤ 4 (`no_black_run_ge9_len_le4`). Compare thresholds before citing. | A |
| [R30-20261105-6329b2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-6329b2) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: no one-tape machine computes the centre in time 2, and time 3 or 7 is needed. | Superseded by the kit's Rule30Problem3Bounds: at least k + 1 steps infinitely often for every k ≤ 13. | A |
| [R30-20261105-5e2517](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-5e2517) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: algebraic inversion of `Coupled`, aperiodicity of both driven neighbours, and the reduction to even periods 2m ≥ 4 under Problem 2 and CQ01. | An earlier copy, ten minutes before, of R30-20261105-3bda85 (same title and headlines), which is tagged and in the kit as Rule30Coupled (kit #168). Neither copy records the supersession. | S |
| [R30-20261105-8becc6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-8becc6) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: the left-column cascade −1 to −6 under w0001, and P ≤ 7 excluded under open hypotheses. | An earlier copy, 26 minutes before, of R30-20261105-bd78e5, which is tagged and in the kit as Rule30PeriodFourSkeleton (kit #174). Neither copy records the supersession. | S |

## Below the bar (25)

Finite instances, tables, single terms of a chain, bounded ranges, elementary facts, or a failed verification. Cite them for what they are; do not build a kit case on them.

| Entry | Date | Authors | Status | What it proves | Why this class | Read |
|---|---|---|---|---|---|---|
| [R30-20261023-4767e0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-4767e0) | 2026-10-23 | ours | Lean Verified, Human Verified | Ours: the visible bits beside a clocked centre carry at most about 0.258 bits each, by a certified automaton at width 12. | Each width needs its own certificate: a chain (see 4d1a54). | A |
| [R30-20261023-4d1a54](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-4d1a54) | 2026-10-23 | ours | Lean Verified, Human Verified | Ours: the same at width 14, about 0.2445 bits. | The next term of the same chain. | A |
| [R30-20261023-60d213](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-60d213) | 2026-10-23 | @AIOvernight; OpenAI Codex; Claude | Lean Verified, Human Verified | AIOvernight, Sparse16: 56 even black observations force 17 black cells among the first 111. | A finite instance. | A |
| [R30-20261023-ac3898](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-ac3898) | 2026-10-23 | ours | Lean Verified, Human Verified | Ours: the death time at width 56 is exactly 100, with 1,024 chunk checks. | The kit chose to leave this check out for its build cost. | A |
| [R30-20261024-71f858](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-71f858) | 2026-10-24 | ours | Lean Unverified | Ours: the death time at width 60 is exactly 114. | Lean Unverified: the portal's check failed. | A |
| [R30-20261024-b16332](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-b16332) | 2026-10-24 | ours | Lean Verified, Human Verified | Ours: death-time lower bounds at widths 64 to 72. | Finite instances. | A |
| [R30-20261024-991a71](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-991a71) | 2026-10-24 | ours | Lean Verified, Human Verified | Ours: the centre columns of two edge pairs differ by times 8, 13 and 14, each sharp. | Finite instances. Lowry's Rule30TraceEdge holds the general question. | A |
| [R30-20261024-a129c3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-a129c3) | 2026-10-24 | ours | Lean Verified, Human Verified | Ours: the death time at width 74 is at least 134. | A finite instance. | A |
| [R30-20261024-4dcf69](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-4dcf69) | 2026-10-24 | ours | Lean Verified, Human Verified | Ours: the death time at width 76 is at least 138, from a GPU census. | A finite instance. | A |
| [R30-20261026-e67465](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261026-e67465) | 2026-10-26 | Kovačič; Claude (the portal text is garbled) | Lean Verified | Kovač: a truncation bridge from death bounds to black windows, its width-52 instance, and the first Q001 instances. | Mostly instances. Not Human Verified. | A |
| [R30-20261026-0ef9c8](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261026-0ef9c8) | 2026-10-26 | Jeongseop Lee; OpenAI Codex; Claude Code | Lean Verified, Human Verified | Lee: a period-32 moving-front state with the alternating gates has period 2. | One period of a family. | A |
| [R30-20261027-1910d0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-1910d0) | 2026-10-27 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: stripe-tail mortality for six- and seven-cell tails. | The next terms of the kit's five-cell hierarchy: a chain. | A |
| [R30-20261028-e34744](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261028-e34744) | 2026-10-28 | Emerson Villafuerte; Antigravity (Google DeepMind) | Lean Verified, Human Verified | Villafuerte: diagonal defect spectra and black runs L ≤ a − 2 for a ≥ 4, among 88 theorems. | A collection. Its run bound is weaker than Goux's three-fifths bound for large a. | A |
| [R30-20261029-5e2b66](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-5e2b66) | 2026-10-29 | ours | Lean Verified, Human Verified | Ours: 48 words of length 11 to 16 excluded from every column. | A table. Mathlib. | A |
| [R30-20261029-f7ace9](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-f7ace9) | 2026-10-29 | ours | Lean Verified, Human Verified | Ours: 80 words of length 17 and 18 excluded. | A table. Mathlib. | A |
| [R30-20261031-9861e5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261031-9861e5) | 2026-10-31 | ours | Lean Verified | Ours: the record excess E(2m) ≤ m + 2 for every m < 2058. | A bounded range. Not Human Verified. | A |
| [R30-20261103-de8d0c](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261103-de8d0c) | 2026-11-03 | ours | Lean Verified, Human Verified | Ours: three periodic phases behind the black edge are excluded to a bounded depth. | Bounded depth. | A |
| [R30-20261104-b73ae0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261104-b73ae0) | 2026-11-04 | Marcos D. Ibarra; Gemini 3.8 Flash; Wang Sequent Prover | Lean Verified | Ibarra: head displacement, parity and a dyadic witness. | Elementary facts. Not Human Verified. | A |
| [R30-20261104-829c71](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261104-829c71) | 2026-11-04 | Matthew Payton Ulrey; Antigravity (Google DeepMind) | Lean Verified, Human Verified | Ulrey: Problems 1 to 3 follow from three broad hypotheses. | The hypotheses carry the weight. | A |
| [R30-20261105-7fe916](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-7fe916) | 2026-11-05 | G.P.J.W. Quint; Gemini (Google) | Lean Verified, Human Verified | Quint: error-edge trajectory laws after jumps of 2 to 7 in Rule30ErrorEdge. | Finite cases of a kit module. | A |
| [R30-20261108-c255c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261108-c255c2) | 2026-11-08 | h3artfield; Cursor Agent (Composer) | Lean Unverified | h3artfield: SizeGrowth with a width-53 open-exit certificate. | Lean Unverified: the portal's check failed. | A |
| [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f) | 2026-11-18 | ours | Lean Verified, Human Verified | Ours: four inverse ticks beside the wall, from age 80. | One term (k = 4) of the k chain. #371 gives every k ≤ 25, but from a far larger age. | A |
| [R30-20261119-cefcc1](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-cefcc1) | 2026-11-19 | Matthew Payton Ulrey; Antigravity (Google DeepMind) | Lean Verified | Ulrey: 35 theorems across five topics, among them the centre's ANF degree 2n − 1. | A collection. Compare the ANF item with Condrey's Rule30TopCoefficient. Not Human Verified. | A |
| [R30-20261120-38ce9e](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-38ce9e) | 2026-11-20 | David L. Condrey | Lean Verified, Human Verified | Condrey: the centre is not eventually 1^5 0^8 nor 1^3 0^17. | Two words. | A |
| [R30-20261121-09376a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261121-09376a) | 2026-11-21 | h3artfield; Claude; Cursor Agent (Composer) | Lean Verified | h3artfield: period-2 obstructions, for an empty right half to depth 10,000 and for two-sided right width 8. | Bounded instances. Not Human Verified. | A |

## Keeping it

- **Run the check** with every kit update step, and before any novelty claim:
  `python3 tools/portal/portal_only.py`.
  - It reads the portal's list and names every portal-only entry this file does not list.
  - It also names every listed entry that has since gained kit modules.
- **A new entry** gets a row in its class. Read it at depth A at least, and search the kit for its headline names.
- **An entry that gains kit modules** leaves this file. Its row moves into the kit's, through KIT-INDEX.md.
- **Rows are rewritten freely** as reads deepen. Record a change of class in the ledger.
- **Our own entries:** keep the owner's name out of this file. They are marked "ours".
