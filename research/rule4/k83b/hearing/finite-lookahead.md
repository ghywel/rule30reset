# Finite certificates for what a Rule 30 wall can hear

Fix a word $u$ of wall bits. Write Ω(u) for the number of distinct words read by taking the OR of the wall and its eastern neighbour, over all two-sided Rule 30 rows. Let $M_n$ be the largest Ω(u) among walls of length $n$. The physical worst-wall growth base is
$$
\rho=\inf_{n\ge1}M_n^{1/n}.
$$
A block restriction gives Ω(uv) ≤ Ω(u)Ω(v), since an actual trajectory splits at the seam and the two pieces recover the original word. Thus $M_n$ is submultiplicative and its nth roots converge to this infimum. Every word is possible as a wall by the kit's realization theorem. The maximum at each length may come from a different wall.

**A rational base strictly above ρ always has a finite integer certificate.** If $M_k q^k\le p^k$, use exactly $k$ eastern cells and a weight depending on just the next $k-1$ wall bits. The local inequalities at this one width certify an upper bound $C(p/q)^n$ at every length, for every wall. A rational $p/q>\rho$ has such a $k$ by the definition of the infimum. The certificate yields both the full-map entropy bound $h_{\rm top}\le\log(2p/q)$ and the periodic-centre bound $H(w)\le T+P\lfloor C(p/q)^w\rfloor$ on the single seed's horizontal vocabulary. Both consequences use existing theorems of M191 and Galindo. This gives a converse to the finite-strip search. Its use is to distinguish a target which the method can in principle reach from a limit imposed by the dynamics. [Exact physical strips](ExactHearingStrip.lean) · [Integer certificates](LookaheadHearing.lean) · [M191's entropy identity](PairHearing.lean)

## Why width k suffices

The state is a set $S$ of width-$k$ strips. For a wall bit $b$ and a heard bit $o$, retain each strip whose first cell OR $b$ is $o$, take both possibilities for the outer eastern input, and collect the successor strips in $S_o$. Count a word once even when several strips spell it. A genuine row follows a path at every width. Conversely, fix any entire continuation of the wall and a strip path lasting $k$ observations. Copy its initial eastern strip to an initial right half, extend the remainder arbitrarily, and apply the kit's realization theorem for the chosen wall. At time $t<k$ its first $k-t$ eastern cells still agree with the path. The far input cannot affect the last requested observation. This also works from a restricted initial set by selecting the first strip on the path.

For every positive horizon the resulting mask language from the full state at that width equals the physical language, even when the future wall is prescribed. Physical inclusion is valid at all horizons. A thin strip can give genuinely spurious words. At width one, beside wall 01100 it admits 11100, which no physical row reads. This observation is compatible with Galindo's nonextendible path construction at fixed width. [Kit realization](../../../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Realization.lean) · [Galindo, PR #429](https://github.com/WolframInstitute/Rule30PrizeKit/pull/429)

## The weight

Let $a_j(S,c)$ count distinct words over the next $j$ ticks of clock $c$. Put $a_0=1$ for a nonempty state and zero for the empty state. For $j=k-1$ assign the natural number
$$
V(S,c)=\sum_{i=0}^{k-1}p^{k-1-i}q^i a_i(S,c).
$$
There are finitely many subsets and $2^{k-1}$ futures. Empty subsets have weight zero. Every nonempty subset has weight at least $p^{k-1}$. Writing $c'$ for the shifted clock, the exact accounting identity is
$$
q\sum_{o=0,1} V(S_o,c')+p^k a_0(S,c)
=pV(S,c)+q^k a_k(S,c).
$$
It follows by expanding both sides using the first heard bit to split the language. A nonempty state's length-$k$ count is at most $M_k$. The empty state remains empty. The block cap therefore gives $q\sum_o V(S_o,c')\le pV(S,c)$, including either choice of the new last wall bit. Induction bounds every word count. A convenient common prefactor is $C=\sum_{i=0}^{k-1}p^{k-1-i}(2q)^i$. The construction permits integer equality at a finite horizon. It promises no practicable horizon for a nearly optimal target.

## A given wall and the mean over walls

For a periodic clock of period $P>0$, replace $M_n$ by the maximum over its $P$ starting phases. That sequence is submultiplicative even when the cut falls inside the period. A block clearing the target at those $P$ phases supplies the same one-tick weights and a bound for every duration and starting time along this clock. A particular phase may be expensive at short horizons. Taking only that phase in a one-tick test would omit its successors. The proof also gives a phase-specific left-word bound for the singleton by applying Galindo's phase decoder separately to each of its $P$ phases and adding the first $T$ rows.

For the total $A_n=\sum_{|u|=n}\Omega(u)$, allow both wall bits as well as both observed bits as branches. The same balance identity counts pairs of words, with a sum over the three possible wall/OR letters. Use the root test $A_k q^k\le p^k$ to bound total growth, then M191 identifies its log rate with the full-map entropy. Dividing $A_n$ by $2^n$ gives the mean. This is a separate application of the counting argument in prose. K83.B already gave convergence for the total count. A worst-wall bound can be looser than a direct bound for this sum. [Earlier strip convergence](../README.md) · [Mean identity](PairHearing.lean)

## Galindo's disjoint-pair test for Problem 1

Kit #428, merged during this block, gives a way to use the wall bound on the single seed. Galindo pairs ages whose rows agree on a western segment and disagree at the next cell, with disjoint ages at each depth and the centre agreement required by his transport argument. If his census has terminal width $s$, horizon $N>0$ and total pair count $M$, he proves $4^M\le H(s)^N$. Each level uses the same terminal width. [Galindo's definition and product bound](https://github.com/WolframInstitute/Rule30PrizeKit/blob/86864e4/lean/Ruliology/CellularAutomata/Rule30TerminalCensus.lean)

Take a rational wall bound $p/q\ge1$. If, for arbitrarily large $s$, some census satisfies $M/(sN)\ge a/b$, it forces $H(s)^b\ge(4^a)^s$. Thus **any density with $4^a q^b>p^b$ suffices for Problem 1**. An eventual period would give $H(s)q^s\le (T+PK)p^s$ at every width. The strict gap between the two bases eventually exceeds the fixed prefactor. This uses exactly Galindo's census and adds the free threshold parameter. The Lean proof of the density criterion uses only the core kit. Its horizontal-bound hypothesis is the second conclusion of the finite certificate theorem. [TerminalHearing.lean](TerminalHearing.lean)

Galindo used $3/20$ with his five-cell base $39/32$. **One per seven suffices with that same five-cell theorem** because $4\cdot32^7-39^7=207{,}946{,}793>0$. One per eight fails this particular test. M191's reported seven-cell estimate of 0.2425 bits would make one per eight sufficient once its numerical certificate is checked in the desired formal setting. The exact five-cell consequence stands independently. Establishing the required frequency of disjoint pairs on the actual single seed remains open. [Galindo's five-cell certificate](https://github.com/WolframInstitute/Rule30PrizeKit/blob/86864e4/lean/Ruliology/CellularAutomata/Rule30HorizontalDiversityBounds.lean)

## Endpoint and evidence

An asymptotic growth base need not itself admit a constant prefactor. Beside a permanently white wall the first eastern black stays black, since its next bit is its own OR its eastern neighbour. A black initially at position $j+1$, with the $j$ intervening cells white, reaches position one for the first time at tick $j$. Until that arrival its left edge moves one site per tick. The all-white right half supplies the remaining prefix. Hence the exact count is $n+1$ at every length, with base one and no constant upper bound. This disproves the implication from a bare rate to the critical prefactor in this periodic example. Existence of a certificate exactly at the **global** worst-wall rate remains open.

The independent integer test compares the entire languages on all 126 wall words of lengths 1 through 6 to direct shrinking light cones. At those lengths the worst counts are 2, 3, 4, 5, 7 and 9. For $k=3$, all 256 subsets and eight possible three-bit futures satisfy the balance identity. At 17/10 all 2,048 inequalities pass. At one, 1,570 fail. Run `py check-lookahead.py` in this directory. [Independent controls](check-lookahead.py)

Gaubert and Stott give a convergent finite-memory hierarchy for the joint spectral radius of nonnegative matrices at fixed dimension. Their Theorem 4 gives a quantitative estimate under positive irreducibility. The Rule 30 contribution here identifies a concrete width with a physical horizon, constructs integer weights directly from physical block counts, and connects those weights to entropy and horizontal vocabulary. The per-wall observers and the left-word criterion are due to Lowry, Kurtuluş, Galindo and Quint. The local converse supplies neither a value of ρ nor an exponential lower bound for the single seed. [Gaubert and Stott, Theorems 3–4](https://www.cmap.polytechnique.fr/~gaubert/PAPERS/MTNS2018-0181.pdf) · [Quint's six-cell result](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261125-f6ca26)

## Independent read and reproduction

M191's five original headlines pass the independent read. At $n$ ticks a wall, its OR readings and the next wall bit determine its western pair word. Conversely an $(n+1)$-tick western pair word determines the first $n$ wall and OR readings. These bounds, with submultiplicativity of the pair counts, give equality of the growth rates. The separate finite identity with factor four is recorded in the earlier physical enumeration. The five-headline Lean check establishes the rate identity. A numeric exit status from the strip-weight script now also distinguishes a rejected table.

The kit's stock checker passed all four modules on the Intel. PairHearing has five selected statements and 39 replayed constants, ExactHearingStrip two and 59, LookaheadHearing six and 78, and TerminalHearing two and 12. All four have zero new axioms. PairHearing imports the S20 Lean files from PR #426 at `4140469`. TerminalHearing requires kit main `86864e4` or later with Galindo's terminal census. Its only import is a core kit module. The strip convergence proof for the total count and the phase-specific horizontal application in the text have hand arguments. The other two files formalize the physical worst-wall threshold and the periodic OR-word bound.

For a kit-native replay, use a clean kit at `86864e4` with the two S20 Lean files from `4140469` in `equivalents/Rule30Equivalents/`. In a Lake environment with the pinned Mathlib cache, build `Rule30Equivalents.PairTraceEntropy`, `Ruliology.CellularAutomata.Rule30HorizontalDiversity` and `Ruliology.CellularAutomata.Rule30TerminalCensus`. Copy the four files from this directory to an empty directory, prepend that directory to the Lake environment's `LEAN_PATH`, and compile PairHearing, ExactHearingStrip, LookaheadHearing and TerminalHearing in that order with `lean --root=DIR -o DIR/Name.olean DIR/Name.lean`. For example, pass `LookaheadHearing --claim partial --headline LookaheadHearing.strict_rate_has_certificate` to the kit's `lean --run Check.lean`. The downstream use of the two modules is short.

```lean
import LookaheadHearing
import TerminalHearing

example {d j K p q a b : Nat} (hq : 0 < q) (hpq : q ≤ p)
    (C : LookaheadHearing.Certificate d j K p q) (gap : p^b < 4^a * q^b)
    (pairs : TerminalHearing.PairDensity a b) :
    Ruliology.CellularAutomata.Rule30Prize.Problem1 :=
  TerminalHearing.problem1_of_hearing_and_pairs hq hpq
    (LookaheadHearing.both_of_certificate hq C).2 gap pairs

example : (39 : Nat)^7 < 4 * 32^7 := by decide
example : ¬ ((39 : Nat)^8 < 4 * 32^8) := by decide
```

The M191 bridge can enter S20's open PR. The additions in this block are proposed for a separate carrying read before packaging with that amendment. The stock checks used the kit checkout and its dependencies. The portal's older pinned environment still needs a self-contained build for any superseding entry.
