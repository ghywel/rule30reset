# What a wall hears: the entropy of S20 and the left-word criterion are one count

claudeM5, M191, 25 November 2026. The owner asked what Quint's R30-20261125-f6ca26 gives us beside S20.

## One count

Fix a wall word u of length n (a column's readings) and let Ω(u) be the number of different OR words beside it, the
readings *wall or first cell to the east*, over all rows. The column to the west is the wall a tick later plus the OR
reading, so a pair word of the two western columns is a wall word with an OR word.

- **On average:** the topological entropy is the growth rate of the sum of Ω(u) over all 2ⁿ walls, so one bit plus the
  growth rate of the mean of Ω. *PROVED IN LEAN here* (`entropy_eq_mask_growth`, `card_maskWords_eq_sum`), on S20's
  identity. Exactly, N(n + 1) = 4 Σ Ω(u), which is the a_n of [count-pairs.md](../count-pairs.md).
- **At worst:** let λ be the growth rate of the largest Ω(u). A centre of period P from T on allows at most T + P C
  λ^w different left words of width w (Kurtuluş, `Rule30LeftRichness`; Galindo, `Rule30HorizontalDiversity`). So
  Problem 1 follows if the single cell's left words grow faster than λ^w.
- **The bridge:** a bound K (p/q)ⁿ on Ω(u), uniform in the wall, gives entropy at most log (2p/q). *PROVED IN LEAN
  here* (`entropy_le_of_mask`), with the kit's two certificates as instances (`entropy_galindo`,
  `entropy_galindo_four`).

[PairHearing.lean](PairHearing.lean): S20's module, the kit's `Rule30HorizontalDiversity`, 211 lines. Stock
`Check.lean` on kit main `ad12153` with S20's patch: pass, five headlines, no new axioms; `leanchecker` passes. Unread
by another worker.

## The bounds, in bits a tick

| | Worst wall | Entropy it gives | Where |
|---|---:|---:|---|
| Lowry, `Rule30MaskedForkRate` | 1/2 | 1.5 | kit, 22 November |
| Galindo, four cells, 5/4 | 0.3219 | 1.3219 | kit, 25 November |
| Galindo, five cells, 39/32 | 0.2854 | 1.2854 | kit, 25 November |
| Quint, six cells, (21/2)^(1/12) | 0.2827 | 1.2827 | portal, 25 November 22:20 |
| **S20**, five sites, by the mean over walls | | **1.2320** | portal and #426; found 24 November (I234) |
| width 14, the mean, outside Lean | | 1.1440 | M178 |

**A gap in S20's comparison.** S20 sets its bound against `Mixing`'s log 3, 1.585 bits. With S20's own identity the
kit's per-wall counts already gave 1.5 and 1.2854. S20's number is still the best in Lean, and nothing in it is false,
but those modules should have been named. The search was for entropy and pair words, and they speak of masked futures
and horizontal words.

## What the strips can reach (COMPUTED)

[claudeM5_cert.py](claudeM5_cert.py), checked in integers for every state, every known future and every next wall bit.
The design is Galindo's: weights that know the next few wall bits. Quint's weights do not, and use blocks of twelve
ticks instead.

| Cells | States | Wall bits ahead | Worst wall, bits | Multiplier in 12 ticks |
|---:|---:|---:|---:|---:|
| 4 | 100 | 4 | 0.3196 | 14.28 |
| 5 | 598 | 10 | 0.2804 | 10.30 |
| 6 | 4,594 | 4 | 0.2792 | 10.20 |
| 6 | 4,594 | 10 | 0.2570 | 8.48 |
| 7 | 65,798 | 10 | **0.2425** | 7.51 |

Quint's is 10.5 in 12 ticks, so five cells with look-ahead are already below it. Twelve-tick blocks with one weight
reach 10.4608 on six cells and no less (floating point, the eigenvalue from both sides), so Quint's form is nearly
used up. From below, the wall 00011100101 repeated hears 0.2337 bits on seven cells, so no weights on seven cells go
under that; on ten cells the same wall hears 0.189.

Control: on seven cells the counts for n ≤ 7 equal the exact ones, sum and largest.
[claudeM5_exact.cpp](claudeM5_exact.cpp) gives them to n = 22: the mean of Ω is 42.8 and the largest 144, and both
grow by about 12% a tick there (11.6% and 12.5%), about 0.17 bits. That suggests a true worst wall well below the
table; it does not prove it.

**One wall.** Beside one periodic wall only a few hundred sets occur, so the strip can be wide
([claudeM5_walls.cpp](claudeM5_walls.cpp), floating point): alternating 0.189, 0.161, 0.143, 0.129 bits on 7, 9, 11,
12 cells, and below 0.0755 by K84's gate count (I246). A given period has a much lower threshold than the uniform one.

## What it does not give

- **Problem 1.** The single cell's left words are known to number at least w + ⌊w/39⌋ + 1 (Galindo). All 2^w occur for
  w ≤ 17 (Kurtuluş, computed). Any exponential lower bound above the worst wall's rate would do, and none is known at
  any rate. A better constant does not change that.
- **B3.** The entropy is above one bit exactly when the mean of Ω grows exponentially. Open.
- A strip's rate is an upper bound only. Galindo (R30-20261125-0c0abf) has a free strip of 32 cells that carries any bit
  stream, which no whole row can.
- Another constant from a wider strip is one more term of a chain (METHOD §12, condition 2).

## What would be new

One theorem for every strip width and look-ahead, with both consequences (the left-word bound and the entropy bound),
and the mean form. The Lean here is its entropy half. Quint's and Kurtuluş's controls belong in it: for rules 90, 150
and 210 the single cell's left words number at most 4w, so any proof that the left side is rich must use the OR.
