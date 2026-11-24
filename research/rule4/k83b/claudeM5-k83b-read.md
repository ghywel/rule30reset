# Review of K83.B (I234): the entropy bounds, the hearing dichotomy and the speed bound

claudeM5, M178, 24 November 2026, at the owner's request. I read README.md, lower.md, count-pairs.md, lean-entropy.md and both
Lean sources whole, and checked the certificates and tables with programs of my own (files `claudeM5_*` here). No code is shared
with gptIntel's, except where I say "regenerated".

**Verdict: PASS on the mathematics of B1, B2 and B4 and on the two B3 obstructions. Three repairs, all to credit and wording.
The main one is prior art of our own (§3).**

## 1. What I checked, and how

| Claim | My check | Result |
|---|---|---|
| Lean, `LeanK83B` (13 headlines, 69 declared, 112 constants) and `LeanK83BCover` (8, 78, 131) | compiled at the pin `5fb5915` with Mathlib, stock `Check.lean`, `leanchecker`, a missing headline fails; both sources read; `entropy_eq_pair_growth` and `entropy_width_5` state what the notes say | PASS; standard three axioms |
| N(n) and the partner counts | forward: every wall of n − 1 bits and every right half of n cells, n ≤ 19 | equal, both alternating phases and the maximum too; H(n) as well |
| the multiplicity histograms | mine to n = 18 against gptIntel's at n = 14 to 18 | equal, all lines |
| H(21) − H(20) = 1.1248832816444 | recomputed from gptIntel's histogram at 60 digits; the histogram's total is 4²¹ and its count 143,901,720 | in the stated interval |
| "every terminal pair ends N(n)/4 words"; a_k submultiplicative, attained at suffix (0,1)^m | all 4ⁿ cones to n = 8, k ≤ 4 | holds |
| width-13 certificate, 1,139,394 states, 221402011/10⁸ | my own bit-parallel checker, 8,693,376,056 local cases; the two corrupted controls rejected; width 12 (merged), 8 and 6 too | VERIFIED |
| the same certificate against the language | number of its labelled paths of length n equals N(n) for n ≤ 16, and is above it after (5,615,080 against 5,615,036 at 17); 20,000 random physical words of 60 ticks, read backwards, are all paths | as it must be |
| log₂(221402011/10⁸) < 1.146669 | 221402011¹⁰⁰⁰⁰⁰⁰ < 2¹¹⁴⁶⁶⁶⁹ · 10⁸⁰⁰⁰⁰⁰⁰ in exact integers | true |
| temporal overlap at order 12, 1.218164067 | my words and power iteration | 1.2181640672 (order 10: 1.237790) |
| B2, all potentials of widths 2 to 8 | my own evaluation of the inequality, from the text of lower.md; the width-2 table by hand values too | 2/5, …, 1,142,503/4,194,304, all equal |
| B2 against a simulation | 200 fair rows, one flip, 4,000 ticks | west record 0.2446 ± 0.0164 cells a tick, under 0.2724 |
| B1, hearing probabilities to tick 16 | 2³² pairs (right half, wall), four masks | 112,323,972, 746,026,588, 2,344,497,864 and 106,423,066 silent, equal |
| the kit's silent pair `1,0,0,…` and `1,1,0,…` beside a white centre | 3,000 random wests, 60 ticks | no difference |
| B3, the 4,096 one-step languages | my own exhaustion | 1,657 trimmed graphs; three pass, the same three |
| B3, the two-step certificate | my own checker: triples from the rule, forward lifting, my own trimming and component test | 1,491 of the 1,492 nodes; the other is the empty graph; 1,354 refuted, 138 close |

**One step further.** gptIntel's builder at width 14 with a cap of 400,000 gives 2,868,932 states and 220991531/10⁸, and my checker
verifies it: **h_top < 1.143992 bits a tick.** (Raw file 1,698,424,172 bytes, SHA-256
`aaeeeb525b9c3c0a4bed305c6a4f3749b1fcc533faa577f04e2e5fb2505808bd`; regenerate with `strip-cover 14 400000`.) I did not run gptIntel's checker on it.

## 2. The hand proofs

- **B1, PASS.** The first difference at the observer is at t + 1 exactly when the driven gates differ at t and the wall is white (one
  application of the rule). The factor 2^N I is a martingale with the filtration of the wall given the right pair, since the gate at t
  depends on the wall strictly before t. The passage to the whole front is sound: the events are countable, the fair law is invariant, a
  difference cannot jump a site, and at a restart the mask takes a value among countably many. The rightmost difference moves right
  one cell a tick, so the set never empties. The escape dichotomy and the limit of P_d follow.
- **B2, PASS.** The two exposures are the consecutive fresh cells b − 1 and b − 2, each entering with coefficient one, and neither
  decision looks at an unread bit. The advance is c = 0 with unequal cells at the record. On an advance the low bits are u xor the old
  low bits, and the other cells use a white west. The drift inequality, bounded oscillation (8,785,531/1,048,576 at width 8) and
  Azuma–Hoeffding give the limsup and the tail as stated. The 3/7 argument by hand is also right: each type-1 failure heals both
  cells and makes the next tick inactive, and the frequencies follow.
- **B4, PASS.** The path-inclusion argument is the general theorem `ReverseCover.pair_count`, in Lean. The two numbers that are not in
  Lean (the width-13 and the metric bound) rest on exact integer checks that two programs agree on. The hand link "exact strips
  decrease to the physical entropy" is right; it gives no rate, as said.
- **The Fano link (last part of lower.md), PASS.** Σp² ≤ max p, the shared prefix has T + q bits, and the tail bound holds for two
  east halves with infinitely many differences. It gives pair entropy at most 1 + v bits a tick, weaker than the counts.
- **B3.** The obstruction is for east-extending languages with one or two letters of memory. It says nothing of the physical language.
  The text says so. The witness branching is complete: a language containing every triple of a witness contains the witness word.

## 3. Repairs

1. **Prior art of ours: the identity and the first counts are from October.** placego's RULE30-PRIZE §8.77 (claudeCloud, 9 October
   2026, [section](https://github.com/ghywel/placego/blob/main/archived/reports/rule30-prize/RULE30-PRIZE-8.2.md)) proves by hand
   that the topological entropy of Rule 30 is the growth rate of the words of two adjacent columns. It gives N₂(14) = 476,596 and
   N₂(17) = 5,615,036, the same numbers as I234, and the bounds 1.347 and then 1.3189 bits. The route is Guillon's thesis (Paris-Est 2008,
   Proposition 4.8.5), with the width corrected from 1 to 2; GC814 (our archive, 9 October) checked the sandwich
   N₂(n) ≤ N_w(n) ≤ N₂(n + w − 2) separately. Milnor 1988 and Kopra 2023 (width 2, left expansivity) are beside it. P71 does not name any of these.
   PRIOR-ART-ARCHIVE has Guillon, GC814 and, in the kit comparison, "§8.77, entropy (our 1.347-bit bound is sharper)", and a search
   for *entropy* finds the first and the third. I have added them to P71. What is new in I234: the Lean proof of the identity on the kit's
   entropy, the weighted reverse covers, the bounds 1.1467 and 1.2320, the counts past 17, the metric bound, B1 and B2. The sentence
   in the README that "Lean identifies …" is right and should say that the identity was known.
2. **The left speed.** The archive gives 0.2428 ± **0.0003** (Grassberger, in Wolfram 1986, cited in our quantum-gates entry) and
   NKS p. 949 gives 0.2428. I234 prints ± 0.0002, from a table I could not open (the PDF is over the reader's limit). Check the table.
   The NKS note on p. 960 I did read: `h^μ_tx < 1.155` for rule 30 "and there is some evidence that its true value may actually be 1".
   It is for the measure entropy, as I234 says.
3. **Names.** lean-entropy.md cites `K83B-entropy-proof.zip` and `K83B-reverse-cover.zip`; the store and the README call the same files
   `lean-entropy.zip` and `lean-reverse-cover.zip` (the digests agree). Not an error in the result; a reader cannot find the files by the first
   names.

Also worth a line: our archive (the quantum-gates entry) records from Wolfram 1986 that on average 0.26 + 0.19 T right cells affect a column of
length T. K83's 0.045 bits a tick is far below that count, and the pair makes the difference between "heard" and "information" visible. P72 does not cite it.

## 4. What the evidence says about B3, and one route

**MEASURED, not a bound.** The exact increments above one bit, e(n) = H(n) − H(n − 1) − 1, have n·e(n) = 2.3619, 2.4287, 2.4940, 2.5595, 2.6225 for n = 17 to 21.
Their differences are 0.0668, 0.0653, 0.0655 and 0.0630, nearly constant, as for e(n) = c + a/n with c near 0.063. That agrees with
K83's 0.045 in size and is evidence for an entropy strictly above one bit. Wolfram's "evidence that it may be 1" was from shorter counts.
A finite sequence decreasing to a limit cannot show the limit is positive, so I agree that it stays open.

**A route that fails.** Condition on every right cell but one, at distance j: the increment is at least P(τ_j = t), the chance that the
first time the flip of cell j is seen at site 1 is t. So H(n) − n ≥ Σ_t max_j P(τ_j = t), exactly. In a Monte Carlo run (200,000 fair pairs,
24 cells) the maximum over j is 0.150, 0.075, 0.038, 0.020 at t = 5, 10, 20, 40, like 0.8/t. So one cell at a time gives a logarithm and
nothing linear. A block of cells, with the rest conditioned on, is the next rung, and is a finite table at each width.

**A route I would try.** By the triangular bijection the entropy excess h − 1 of the fair full map is the rate of H(A | L), what the right half tells the
centre when the left half is given, and the same for a fair left half L. For each L the collision probability of A is the chance that two independent right
halves give the same centre column, and averaging over L gives, with B1's change of measure, exactly
Q_T = E_forced[2^(−N_T)] for two independent right halves (wall black at each gate mismatch, fair otherwise). Shannon entropy is at least
collision entropy, so **h − 1 ≥ lim inf −(1/T) log₂ Q_T, and B3 follows if Q_T decays exponentially.** MEASURED, 400 runs: N_T/T is 0.2956 ± 0.0171 at T = 4,096,
and its spread falls like T^(−1/2). So N_T is linear for typical rows, and what is missing is its lower tail (the sample mean of 2^(−N_T) is
set by the few smallest values and does not settle). K83's slopes of 0.041 to 0.045 a tick are estimates of neighbouring quantities. A renewal
structure for the first difference of the two halves is where I would look for that tail.

**On the kit.** I agree that no prize partial is proposed. If the owner wants a contribution, the small Lean file is right for
`equivalents/` (supporting results beside `Mixing`): the general cover theorem, `entropy_le_block_root` and one instance. The only pull request
of its kind from outside since 28 October, #238, has no comment, so I would not expect a quick merge.
