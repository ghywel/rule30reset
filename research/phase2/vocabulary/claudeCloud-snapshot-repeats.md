# I295.4: when a western snapshot of the single seed first repeats

*claudeCloud, 28 November 2026 (ledger K104, K105), at the owner's word: "Continue a research block on I295.4." Under
METHOD §3 the block aims at the believed truth: the seed's western vocabulary grows fast.*

## The statement aimed at

Let S_t be the word on sites 0, −1, …, −w at age t, for ages t ≥ w, so that the strip lies inside the light cone. Let
R(w) be the first age at which some snapshot repeats an earlier one. The snapshots at ages w to R(w) − 1 are then
pairwise distinct, so H(w) ≥ R(w) − w, where H is Galindo's vocabulary.
- **The quadratic rung.** R(w) ≥ w + w² would give I295.4's quadratic rung.
- **Problem 1.** R(w)/(39/32)ʷ unbounded would give Problem 1, through the kit's sampling form
  `problem1_of_five_cell_samples`.
- **The believed truth.** Snapshots behave like fresh random words, so R(w) sits at the birthday scale,
  about 1.25·2^((w+1)/2).

## What the seed does (COMPUTED; registered in K104)

[`claudeCloud_snapshots.c`](claudeCloud_snapshots.c) (frozen `05be7442…`) ran ages to 2²⁰ and widths 8 to 48
([output](data/claudeCloud-snapshots.txt), [margins](data/claudeCloud-snapshot-margins.txt)).

| w | first repeat R(w) (ages a, b) | R / birthday | R / (39/32)ʷ | the w² ages from w distinct? |
|---|---|---|---|---|
| 16 | 220 (18, 220) | 0.48 | 9 | no: the one edge pair |
| 17 | 855 (641, 855) | 1.33 | 30 | yes |
| 20 | 1,887 | 1.04 | 36 | yes |
| 24 | 15,471 | 2.13 | 134 | yes |
| 28 | 29,848 | 1.03 | 117 | yes |
| 32 | 164,175 | 1.41 | 292 | yes |
| 36 | 351,294 | 0.76 | 284 | yes |
| 37 | 526,415 | 0.80 | 349 | yes |
| 39 to 48 | none before age 2²⁰ | | | yes |

- **V1, failed at one width.** For every w from 17 to 48 the first w² snapshots are pairwise distinct. At w = 16 one
  edge pair (ages 18 and 220) collides; below 17 the only early collisions are such edge pairs.
- **V2, held.** The first repeat stays at the birthday scale, at 0.5 to 2.2 times it from w = 16 to 38.
- **V3, held.** Every word of width up to 16 occurs, to w = 15.
- **V4, failed.** Only w = 16's first repeat starts near the edge. The others pair two random-looking late ages.
- **The repeated words are ordinary**
  ([`claudeCloud_collision_words.py`](claudeCloud_collision_words.py), [output](data/claudeCloud-collision-words.txt);
  development). From w = 17 to 30 their black counts and longest runs lie inside the 5–95% range of all snapshots,
  and their lags run from hundreds to tens of thousands of ticks. They are not white triangles, stripes or
  time-periodic patches.

**So the believed truth holds here with a wide margin.** The birthday scale grows like √2 per cell, and Galindo's
criterion needs only more than 39/32. The ratio R/(39/32)ʷ climbs from about 30 at w = 17 to about 350 at w = 37.

## Correction to K104: the census route is consistent with the believed truth

K104 said I322's census route conflicts with the believed truth. That is wrong.
- **What the census needs.** At width s = 2ʲ it needs, at each depth r < s, endpoint-disjoint pairs of ages that
  agree on the first s cells, differ at the next, and read the same centre for r ticks. Their total J must reach jN.
- **Why N rescues it.** The number of ages N is free. Once N is of order 2^(2s), random-like snapshots supply such
  pairs at every depth, about N/2 of them. Then J ≈ sN/2 ≥ jN.
- **So both routes are believed true,** and they ask for opposite things:
  - the collision route asks that coincidences be **absent** among the first w² ages, an injectivity statement;
  - the census asks that they be **abundant** among exponentially many ages, a mixing statement close to W4.

## What a proof needs

Two snapshots equal at ages a < b agree on a whole space-time triangle of height w/2, but nothing in the kit forbids
that before age w². The finite masked Jen theorem only says their agreement ends once the left edge's information
arrives, which gives linear bounds. The kit's `Rule30HalfAgeOrigin` says the whole right half at age h determines h.
**The missing statement is a finite-window form of it: the w + 1 cells at [−w, 0] determine the age among ages
below g(w).** That is R(w) > g(w).
- g(w) = w² gives the quadratic rung.
- g(w) = A·(39/32)ʷ for every A gives Problem 1.

The data say the windows carry the age up to about 2^(w/2), and that no special pattern is what makes them repeat.

## Verdict

- **Reasoned.** The block measured the believed truth and found it at its strongest form: early snapshots are
  pairwise distinct out to the birthday scale, and that scale clears Galindo's criterion by a factor that grows
  exponentially. Nothing is proved. The statement to prove is the finite-window age statement above, at g(w) = w²
  first. I would keep I295.4 open on it, as one W2 statement among those its reopen conditions already name.
- **Gut.** The age has to be written in the window somewhere, and a counting proof will not find where. Look at how
  the left edge's dyadic clock reaches the strip in the first 4w ages, where part of the strip is still settled.

## Files

| File | What it is |
|---|---|
| `claudeCloud_snapshots.c` | the frozen run: H(w), first repeats, O among the w² ages from w |
| `claudeCloud_collision_words.py` | the repeated words against typical snapshots |
| `data/claudeCloud-snapshot-*.txt`, `data/claudeCloud-collision-words.txt` | predictions and outputs |
