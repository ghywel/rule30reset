# K92.5.B: the 150/180 block read, and what a front argument can decide

*claudeCloud, 28 November 2026 (ledger K101), at the owner's word: "Review and continue K92.5.B." The read I330
asked for (gptIntel's I325, I326, I328–I330, [note](edge150.md)), then a block of my own.*

## 1. Carrying read of I326–I330: PASS

| Check | Result |
|---|---|
| `Hybrid150Edge`, `Hybrid150Merge`, `Hybrid150PostSupport` (SHA-256 `979d06be…`, `0bf8f897…`, `660443ef…`, as I330 gives them) compile with core Lean 4.35.0, standard library only | yes: 40 s, 1 s, 2 s |
| `leanchecker` on all three | passes |
| Axioms of `bounded_iff`, `launch_budget`, `packed_launch`, `odd_vocabulary_floor`, `low_vocabulary_deadline`, `packed_low_deadline`, `arbitrary_odd_prefix`, `merge_125_159`, `merged_survivors`, `exact_post_support` | `propext`, `Quot.sound`, with `Classical.choice` for some; `wall_round` none |

**The width-at-launch accounting** (I330's first request).
- `Launched x B` is a time t and an index d with t + 2d ≤ B, the row at round t having black cells at d and d + 1
  and nothing farther. So its width at launch is K = d + 2.
- `launch_budget` gives B = 2n + 3 for a row of width W = n + 3. With K = d + 2 that is **T + 2K ≤ 2W + 1**, as the
  note says. The induction charges one round to a retreat (`101`) and two to a stall (`1000`). A `1001` edge
  launches after one round at the same width, where the bound is tight.
- `low_vocabulary_deadline` takes m = K. `odd_vocabulary_floor` then lists 2m − d = K + 2 distinct words of length K,
  and needs the even checks through round t + 2K + 1 ≤ B + 5. So a row whose first B + 5 = 2W + 2 odd readings have at
  most m + 1 factors of every length m fails an even check by round 2W + 2, **physical tick 4W + 4**, as stated.
- The floor's count is right. Two equal words at rounds i < j would rebuild equal prefixes through index 2m.
  The later row is black at d + j + 1 and the earlier one white there, a contradiction whenever d + j + 1 ≤ 2m. That
  leaves 2m + 2 − K pairwise different starting rounds.

**The first-failure convention** (I330's second request).
- `exact_post_support` gives two different rows, each with the pair at w − 2 and w − 1, so of width w = 92 + 18n.
  They have equal round images, pass the even check at round j whenever 2j < w + 2 (physical ticks 0 to w), and fail
  at round (w + 2)/2, physical tick w + 2.
- The step that carries it is `first_difference`: a first spatial difference at index n is first heard at tick n.
  The truncation and the reference agree below w + 2 and differ at w + 2, which is even.
- Tick w is the first even check that hears a cell beyond the support, and both rows pass it. So the family passes
  exactly one post-support check, which is what I330 claims.

**`merged_survivors`** says what I329 says. Rows of width 2m + 3, already locked, pass every check through tick 2m,
and their odd readings at ticks 13 to 2m − 1 are prescribed.

**Kit fit, beside I315.**
- The vocabulary deadline is the hybrid's form of a method the kit already uses for rule 30 (Villafuerte's
  difference front, Condrey's driven-left windows, as edge150.md says). The edge moves one site per round, so the
  coefficient is two.
- The merge family is a control on injectivity past the support.
- Neither is a wall theorem for the hybrid. On its own I would not send this to the kit. Section 3 gives the setting
  in which these results and I315's would fit as one module.

## 2. The wall readings are not linear

`wall_round` (round x 0 = x 2) is exactly linear, and I had wondered whether every wall reading of the hybrid might
be. It is not. The algebraic degree of the wall cell at tick t, over the initial cells it can see, is
([`claudeCloud_wall_degree.py`](claudeCloud_wall_degree.py), [output](data/claudeCloud-wall-degree.txt); COMPUTED):

| System | ticks 0 to 16 |
|---|---|
| rule 30 | 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11, 13, 14, 15 |
| time (150, 180) | 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 |
| time (30, 180), proved mortal | 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11, 13, 14, 15 |
| rule 150 | 1 at every tick |

The hybrid's degree runs one round behind rule 30's and grows as fast. So it has no hidden linear structure at the
wall, and it belongs in the hard class. The 30/180 row shows that degree alone cannot tell mortal from hard.

## 3. What a front argument decides

K92.5.B asks which local front conditions give white-wall mortality. For the whole atlas there is a uniform answer
([`claudeCloud_front_criterion.py`](claudeCloud_front_criterion.py), [output](data/claudeCloud-front-criterion.txt);
COMPUTED, development runs, not registered).

**The criterion.**
1. *Front lemma at c.* Take every site west of L white and the cells L to L + 2c arbitrary. Two c ticks later every
   site up to L must be white. The cone of site L in 2c ticks reaches only L + 2c, so the lemma holds with any east,
   and at the wall while L + 2c ≤ −1. It is a check of 2^(2c+1) windows, at both parities of L for space hybrids.
2. *Terminal map.* Once the front is within 2c of the wall, the row lies on the last 2c sites. Run each of those
   2^(2c) rows with the wall until it fails an even check or repeats.
3. If the lemma holds and every terminal row fails, every finite west fails, by tick 2c(W − 2c) plus the terminal
   maximum. If a terminal row repeats, it is an immortal row. I315's theorem is the instance time (30, 180) with
   c = 2 and the three-cell map [0, 0, 2, 1, 5, 3, 3, 2].

**The result.** With c up to 5 (6 adds nothing), the criterion decides **26 of the 128 relatives** and agrees with
the atlas on every one:

| | Mortal at every width | Immortal row at the wall |
|---|---|---|
| time | (240,240), (240,60), (240,120), (240,180), (60,240), (120,240), (180,240), **(30,180)** c = 2 | (120,120), (120,180), (180,120), (180,180), **(180,30)** c = 4 |
| space | (240,240), (240,180), (60,150), (60,210), (210,60), (180,210) c = 5 | (150,60), (120,120), (120,180), (180,240), (180,120), (180,180), (210,180) c = 5 |

The other **102 have no eroding front** at any c up to 6. Among them are rule 30, time (150, 180), rules 45 and 75,
and the whole hard class of K99. So an erosion condition decides exactly the relatives whose front erodes. Rule 30's
front grows by a site at every tick, and no condition of this kind reaches it.

**What this means for K92.5.B.** The pull's question has two halves.
- *The eroding half* is answered: one finite lemma and one finite map, for every such relative at once. As a Lean
  statement it would be one theorem over the rule tables, with each instance a `decide`. HybridWallFront is its first
  instance. Together with the reversed-order immortals it would make one control module, *what a front argument
  decides*. That is the form in which I315's theorem and the hybrid controls would fit the kit.
- *The growing half* is the real target, and time (150, 180) is its nearest member. gptIntel has proved three things
  there:
  - every row but 0, 1 and 2 locks into a growing edge;
  - a growing survivor needs nearly 2m distinct odd words of length m;
  - merged pairs survive past the support.

  No member of the growing half has a wall theorem.

## 4. I330's next test: the first missing black on an odd tick

**gptIntel got here first.** It registered the test in I331 before my run and proved the law in Lean in I332
(`Hybrid150ExactCuts`, `WallDifference`). For every cut W ≥ 83 of the reference, the first failed even check is the
first missing black's arrival rounded up to an even tick. The largest lag after the cut is five, at W = 95 + 18n.
My run was made without knowing that, so it is an independent replay. It agrees.

[`claudeCloud_odd_arrival.py`](claudeCloud_odd_arrival.py), [output](data/claudeCloud-odd-arrival.txt); COMPUTED,
development. Truncate the reference at every width W from 14 to 260. Let d be the first black index at or beyond W,
and F the first failed even tick:

| | Delay F − d |
|---|---|
| d even, every W | 0 |
| d odd, W ≥ 78 | **1**: the next even tick |
| d odd, W < 78 (the reference's transient) | 1, 3, 5, 9 or 17; 17 at W = 45 (d = 45, F = 62) |

- **The same law, a little earlier.** F − W is at most 5 for W ≥ 78, with 5 first at W = 95 and again every 18, as
  I332 says. The rounding law already holds at W = 78 to 82, below I332's bound of 83.
- **Checks.** A truncation of the reference at width 760 passes every even check through tick 660. A slow simulation
  from the eight-entry rule tables gives the same F at four widths.
- **The family is exact but fragile.** Its rows die within one tick of hearing their first difference.

## 5. Verdict

- **Reasoned.**
  - I326 to I330 are right as stated (PASS).
  - The front question of K92.5.B is answered for the eroding half by the criterion in section 3. The criterion is
    PROOF-SKETCH, with finite checks COMPUTED; its Lean form generalizes HybridWallFront.
  - The open half is a white-tail theorem for one growing relative, (150, 180) first.
  - I would keep K92.5.B in progress on that half. If the owner wants a submission from the pull, it is the uniform
    criterion with its 26 instances, as a control module.
- **Gut.** The eroding/growing split is the useful thing here. Rule 30 lives in the growing half, where the only tools
  are vocabulary and counting. A proof for (150, 180) would have to beat the fair-coin law past the support, as Q01
  does.

## Files

| File | What it is |
|---|---|
| `claudeCloud_wall_degree.py`, `data/claudeCloud-wall-degree.txt` | the wall cell's algebraic degree by truth tables |
| `claudeCloud_front_criterion.py`, `data/claudeCloud-front-criterion.txt` | the front lemma and terminal map for all 128 relatives, against the atlas |
| `claudeCloud_odd_arrival.py`, `data/claudeCloud-odd-arrival.txt` | truncations of I330's reference at every width to 260 |

## Addendum, 28 November (K102): the believed truth for (150, 180) is W1 itself

The owner: "my presumption is the 'a row' would be the counterexample and all rows is the believed truth. I think we
should stop looking for counterexamples to the walls, expecting there to be none, and focus on the believed truth
first and foremost." So K92.5.B's open half is one statement: **every finite row of time (150, 180) dies at the white
wall.** Is it any easier than rule 30's `Q01`?

**The decoding.** A surviving row has its wall readings black at even ticks and free bits U₀, U₁, … at odd ticks.
- Both systems are permutive in the western input, so the wall column decodes the row column by column. The
  initial row is a map Θ of the free word, the hybrid's form of the kit's `Theta`.
- A row survives for ever exactly when its own Θ is finite.
- [`claudeCloud_theta.py`](claudeCloud_theta.py), [output](data/claudeCloud-theta.txt); COMPUTED, exact Boolean
  functions in 12 free bits.

| | (150, 180) | rule 30 (the kit's zero wall) |
|---|---|---|
| x₀ … x₄ | 1, 1 + U₀, 1, U₁, U₀ ∨ U₁ | 1, 1 + U₀, U₀, 1 + U₁, U₀ |
| algebraic degree of x_k, k = 12, 16, 20, 24 | 6, 8, 10, 12 | 5, 7, 9, 11 |
| rows of width ≤ K passing every even check through tick 24, K = 24, 22, 20, 18, 16 | 2,027; 478; 103; 29; 12 | 2,008; 522; 120; 43; 16 |

- **The hybrid has no structure rule 30 lacks.** Its decoded row grows in degree at rule 30's rate, about k/2.
- **The survivors halve alike.** With each extra white cell demanded past the support, the survivors halve, as fair
  coins would give, in both systems.
- **The hand-derived start does not continue.** The hybrid's column 2 has column 0's form, with V = ΔU as its odd
  word. Column 4 breaks it (x₄ = U₀ ∨ U₁).
- **So proving that every row of (150, 180) dies is the same kind of statement as Q01:** the fair-coin law past the
  support, unproved, for a triangular map of the same complexity. The hybrid is a second instance of W1, not a
  stepping stone to it.

**Consequence for the pull.** Under the owner's direction the target is the believed truth, and for the growing half
that is W1 itself, better attacked on rule 30. I propose parking K92.5.B's growing half at W1, with this reopen
condition: a property of the hybrid's decoding Θ that rule 30's lacks. The front half stays answered (section 3),
and the possible control module is the owner's decision.
