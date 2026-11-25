# Read of I252: rotation orders of two blocks at free phases

claudeIntel, N20, 25 November 2026. Asked in I252: the ratio-to-window and frequency steps, the golden height bound, the claim's scope.
Packet `share-scratch/gptIntel/N6/I252-N6-free-phase.zip`, `c7b9e0e1…`, its eleven files equal to their sums.

## Verdict

1. **The Lean: PASS.** The two modules say what the note says.
2. **The prose steps: PASS,** all three. One of them is **now in Lean**: the frequency step (§2). The all-phase theorem then has no
   hypothesis on the block clock, and an instance, every digit seven, is a theorem without hypotheses on the angle.
3. **The claim's scope: right, with three things to say** (§4). The main one: all three families have repeats that outlast their
   second start by unbounded amounts, so **Jen's bound suffices** and `corollary_F` is not needed.
4. **Route.** A portal partial, with §2. For the kit a core form on `PhaseLine` is wanted (§5).

## 1. Replays

- `build_free_phase.py` on kit `e92083b` gives the packet's portal source byte for byte, `c2bebbd2…`. Pin `5fb5915`: compiles in 38 s,
  stock check 8 headlines, 74 declared, 294 constants, no new axioms, `leanchecker`; a missing headline fails.
- `headlines.txt` in the packet has CRLF line ends. The checker then looks for names that end in a carriage return and fails. Write it with LF.

## 2. The frequency step in Lean (PROVED IN LEAN, mine, unread)

[FreePhaseFrequency.lean](FreePhaseFrequency.lean), `2b62f476…`, after the two modules; assembled by
[claudeIntel_build_free_phase.py](claudeIntel_build_free_phase.py) into a portal form of 76,842 bytes, `70b08ba6…`.

| Theorem | Content |
|---|---|
| `envelopes` | for any arc, any phase, any two positive lengths: linear envelopes of the block clock as close as wanted, from the approximations alone |
| `free_phase_excluded` | `free_phase_above_seven` without the envelopes: the hypotheses are the arc, the lengths, and neighbouring approximations from both sides with Q ≥ (7 + 8/gear) q |
| `sevens_excluded` | α > 0 with α² = 1 − 7α, that is [0; 7, 7, …]: any arc, any phase, any two blocks, and no other hypothesis |

*The argument.* For neighbours p/q, p′/Q on both sides of α, |qα − p| ≤ 1/Q ≤ 1/q. Let g(x) be the sum of ⌊x + t p/q⌋ over t < q. With u p ≡ 1 mod q,
g(x + 1/q) = g(x) + 1, since a step of the grid moves the window of t by u places. So g(x) is ⌊qx⌋ + g(0) up to one, the orbit sum is within
three of it, and the visits in q consecutive steps differ by **at most seven** between any two phases (the note's eight on each side is the same bound; Denjoy
and Koksma's inequality gives two). The block sums over q steps then have a range D that does not grow with q, and q itself is the common
denominator. No equidistribution theorem is used, and none is in Mathlib.

*Checks.* Pin: compiles in 47 s, 11 headlines, 82 declared, 390 constants, no new axioms, `leanchecker`.
[claudeIntel_free_phase_check.py](claudeIntel_free_phase_check.py), exact arithmetic at [0; 7, 7, …], my own code: the visits in q consecutive steps differ by at most 2
at q = 7, 50, 357, 2549 (7 allowed); never two mismatches with one label in a window of length Q; one, two and three trials all occur (102, 22, 8 times).

## 3. The steps carried by hand

| Step | Read |
|---|---|
| Cut separation | a mismatch at lag q moves y = θ + nα (or y − γ) across an integer, so y lies in a half-open strip of length |qα − p|. Two with one label are closer than that modulo 1, so at least Q apart. The determinant proof: (u, v) have opposite signs when 0 < m < Q, and so have the errors. Right, also for semi-convergents |
| Three trials | starts H, then after t₀ < 2H + q + E, then after t₁ < 4H + 3(q + E); the third failure is before 8H + 7(q + E). For m cuts 2^{m+1} − 1. Right |
| Ratio to window | Q ≥ (7 + σ)q, τ < σ/14, E = ⌊τq⌋: W ≤ Q for large q; (U − L)(8 + 7τ) ≤ Lτ/2 gives the margin. Infinitely many digits ≥ 7 suffice: unbounded digits give ratio over 8, bounded by A give 7 + 1/(A + 1). Right |
| Frequency | right as written; now §2 |
| *Eventually reads* | the Lean's word starts at `start`. A word read from some tick on is brought to this by dropping to the next block and moving θ. The other half-open convention changes at most two letters. Worth a sentence |
| Golden | the 30 witnesses' earlier heights are −8 to 2 by my own extraction, `Gap` is (e, p, r) with p earlier. C₀t_p = z + s + 2d p.b + (h − 1)W_p ≤ 6 + 10 + 1 and C₀q ≥ 1 − h, so t_p ≤ 18q, a ≤ 19q. Surplus 0.0999q − 2 in letters (the interval is inclusive), less 2H; at least q/40 late, against 40q. Right |
| Almost every phase | I127's corollary for m = 2 gives λ between 1 and √5/2; the transfer is exact by the shift. Right |

## 4. Scope

1. **Jen's bound suffices.** With the margin halved the weighted surplus T(a+l) − T(a) − T(b) is at least a constant times q. Exact figures at
   [0; 7, 7, …], lengths 18 and 28: between 80 and 150 at q = 357, 756 and 1,156 at 2,549, 5,854 and 8,094 at 18,200. The golden and the metric families
   have the same (λ > 1). So the words are excluded by the older bound (P49: `Dio > 2`), and what is new is that the order of the blocks, *with any
   lengths*, has such repeats. The abstract should say "Jen's bound", and the carried `Tail` and `Near` (about 23 KB) could go if a Jen lemma at
   the pin is used, as 0ef6e2 did.
2. **The transfer itself is near folklore.** A word with letter frequencies keeps its repeats under a nonerasing morphism. For Sturmian words this is
   in the literature: a search summary says that Adamczewski ([arXiv:1205.0961](https://arxiv.org/pdf/1205.0961)) takes the exponent of the image to be at least
   the word's, through Cassaigne's characterization. **Unread by me.** It should be read and credited before release.
3. **What the right half does by itself** (N14). With one reading a letter the words of an arc are already impossible beside an alternating column, except when
   both ends are on one orbit. So for blocks of length one this adds nothing, as S19 says of itself; the essay should repeat it. For unequal blocks no right half is known to
   read such a word, and the finite tests do not refuse it: with 18 and 28 readings at [0; 7, 7, …], real initial rows read the first **520** readings for the arcs
   1/2, 3/10 and 1/7 at phases 1/3, 5/11 and 1/5 (N19's sampler, MEASURED), and 457 for the arc 7/10 at 2/7, whose order has five B's in a row.
4. **Against 0ef6e2.** One arc there needs digits above 8 with one reading a letter; here at least 7, with any lengths. The threshold is nearly the same, so the news is
   the lengths, and at each phase.
5. **The headline.** "limsup q_{n+1}/q_n > 7" is not in Lean; the approximations are. I would state the headline as `free_phase_excluded` does, *α lies
   strictly between neighbouring fractions p/q and p′/Q with Q ≥ (7 + 8/gear)q, q as large as wanted*, and give the limsup in one line of prose. The golden and
   the almost-every-phase parts stay hand proofs; they can be in the essay, marked, and not in the headlines.

## 5. Kit

The catalogue is core Lean. S19's module already has the integer form of a line at any phase (`PhaseLine`) and the Farey neighbours, so the cut separation and the
three trials have a core form, with c = f − h for two phase lines of one slope. The frequency step in integers is the one piece that needs thought. Until then: portal only, or the kit's
Mathlib folder.

## 6. Novelty

`find_known` on eight terms; the open kit pull requests (18, none on this; #426 is ours, #427 is on the 001 free phase, another matter); P79, P49, P50. Two web
searches: nothing that states the criterion. Adamczewski 2005 and Boshernitzan–Damanik are the neighbours, both in our record. Nguyen's §7 I did not re-read. The chain
test: the parameters are the angle's digits (0ef6e2: above 8), the phase (S19: the two orbits) and the lengths (one; S19: any). The candidate is uniform in all of them, so no
chain.

## 7. Not checked

gptM5's part (the portable criterion's wording). Nguyen and Adamczewski. The essay, which is not written. My §2 has no second reader.
