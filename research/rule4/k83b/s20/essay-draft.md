---
Template: ComputationalEssay
Name: Rule 30's topological entropy is the growth rate of the words of two adjacent columns, and is below 1.232039 bits a tick
Author: {AUTHORS}
Date: 2026-11-25
Description: The topological entropy of Rule 30 is the growth rate of the words two adjacent columns can read. A table of 140 states on five sites gives an upper bound below 1.232039 bits a tick.
Abstract: {ABSTRACT}
Keywords: [Rule 30, topological entropy, column words, transfer automaton, Lean]
Sources: ["[Rule30Equivalents.Mixing, the kit](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/equivalents/Rule30Equivalents/Mixing.lean)", "[P. di Lena and L. Margara, Row subshifts and topological entropy of cellular automata, J. Cellular Automata 2 (2007)](https://www.cs.unibo.it/~margara/page14/assets/01-JCA07.pdf)", "[S. Wolfram, Random sequence generation by cellular automata, Adv. Appl. Math. 7 (1986)](https://content.wolfram.com/sw-publications/2020/07/random-sequence-generation-cellular-automata.pdf)", "[Tables of cellular automaton properties (1986), with P. Grassberger's Table 6](https://content.wolfram.com/sw-publications/2020/07/cellular-automaton-properties.pdf)", "[S. Wolfram, A New Kind of Science, notes to page 960](https://files.wolframcdn.com/pub/www.wolframscience.com/nks/nks-nts-ch6.pdf#page=15)"]
---

## The question

Rule 30 acts on all rows of black and white cells. How much information does its map produce per tick, measured by *topological entropy*? The kit's `Mixing` proves that it is at least one bit, since the centre trace of a random row is a fair coin, and at most log₂ 3. Its catalogue says that the entropy is exactly the growth rate of the words two adjacent columns can read, and reads log 2 from counts. We prove the identity on Mathlib's cover entropy, and an upper bound below 1.232039 bits a tick.

This is about the whole map on two-sided rows. It is not about the centre column of one black cell, and it does not decide any of the three problems.

## Two columns carry everything

Read columns a and a + 1 for n ticks, and let N(n) be the number of words that occur over all initial rows. Rule 30 is left-permutive. From two neighbouring columns for n + O(k) ticks every cell of a k-cell window to their west follows for n ticks. Spatial translation lets us place that pair at the eastern edge of each window without changing N(n). `entropy_eq_pair_growth` says that **the entropy is the growth rate of N(n)**, with the pair and its spatial position fixed. Submultiplicativity, N(m + n) ≤ N(m) N(n), then gives the upper bound log N(k) / k from any single length k (`entropy_le_block_root`).

Here are N(1) to N(11), counted from every wall word of n − 1 ticks and every initial right prefix of n cells, with two choices for the final wall bit, and the bound each length gives, in bits.

```wl
count[n_] := Module[{m = 2^n - 1, x0 = Range[0, 2^n - 1], x, g}, 2 Total[Table[x = x0; g = BitAnd[x, 1];
   Do[x = BitAnd[BitXor[BitOr[BitShiftLeft[x, 1], BitAnd[BitShiftRight[s, t], 1]], BitOr[x, BitShiftRight[x, 1]]], m]; g = BitOr[g, BitShiftLeft[BitAnd[x, 1], t + 1]], {t, 0, n - 2}];
   Length[Union[g]], {s, 0, 2^(n - 1) - 1}]]];
Table[{n, count[n], N[Log2[count[n]]/n, 5]}, {n, 1, 11}]
```

The bound from length 11 is 1.3852 bits, and it falls slowly. Exact counts to length 23 (718,268,824 words) were made with a program outside this entry. Each terminal letter accounts for N(23)/4 words. The maximum number of 22 preceding letters at a fixed terminal letter therefore gives the sharper upper bound log₂(718,268,824/4)/22 < 1.2464 bits per tick.

## A table that reads backwards

Read the pair backwards one tick at a time. Store possible strips on sites a + 1 through a + w, starting with all strips at the last tick. For a previous letter (b, g), the bit at a must be b and the first strip bit must be g. Keep each such strip that can step into S for at least one choice of the bit at a + w + 1. Here S is the current set. The physical history of every row is a path in this table, so N(n) is at most the number of its paths of length n. Two letters that lead to the same set still count twice. Give every set a positive weight. If the weights of the four successors of each set add to at most p/q times its own, the number of paths grows by at most p/q. `ReverseCover.entropy_le` then bounds the entropy by log(p/q), and a table on a finite strip needs only the local rule (`StripTable.cover`, with `physical_strip_step`).

This rebuilds the table on w cells by computer, with its growth rate. It has 6 sets at two cells and 140 at five. Integer weights give a little more than the growth rate: at five cells 1679211/714866 = 2.34899, against a growth of 2.34662.

```wl
table[w_] := Module[{full = 2^(2^w) - 1, up, pre, todo, index, edges = <||>, n, A},
  up[u_, b_, e_] := BitAnd[BitXor[BitOr[2 u, b], BitOr[u, BitShiftRight[u, 1], e 2^(w - 1)]], 2^w - 1];
  pre[s_, b_, g_] := Total[2^Select[Range[g, 2^w - 1, 2], BitGet[s, up[#, b, 0]] + BitGet[s, up[#, b, 1]] > 0 &]];
  todo = {full}; index = <|full -> 1|>;
  While[todo =!= {}, With[{s = First[todo]}, todo = Rest[todo];
    edges[s] = Flatten[Table[With[{t = pre[s, b, g]}, If[t != 0 && ! KeyExistsQ[index, t], index[t] = Length[index] + 1; AppendTo[todo, t]]; t], {b, 0, 1}, {g, 0, 1}]]]];
  n = Length[index]; A = ConstantArray[0, {n, n}]; KeyValueMap[Function[{s, e}, Scan[(A[[index[s], index[#]]]++) &, DeleteCases[e, 0]]], edges];
  {n, N[Max[Abs[Eigenvalues[N[A]]]], 8]}];
{table[2], table[5]}
```

```wl
{N[53/21, 8], N[Log2[53/21], 6], N[1679211/714866, 8], N[Log2[1679211/714866], 8]}
```

`FiveSite.entropy_width_5` has the integer table and weights for five cells: the entropy is at most log(1679211/714866) in natural units. The multiplier is below 47/20, giving entropy strictly below log(47/20) (`FiveSite.entropy_lt_log_forty_seven_twentieths`). Lean checks all 17,920 cases of a set, two outer cells and a strip, and all 140 weight inequalities.

Wider strips give better bounds, and no Lean here checks them. They were found by a program, and checked with a second one, for the certificate rather than the search: a file of sets and weights, read and tested case by case.

```wl
bounds = {{2, 2.52137971}, {4, 2.39201729}, {6, 2.30792199}, {8, 2.25549196}, {10, 2.22673371}, {11, 2.22116998}, {12, 2.21451979}, {13, 2.21402011}, {14, 2.20991531}};
ListLinePlot[{#[[1]], Log2[#[[2]]]} & /@ bounds, Mesh -> All, PlotRange -> {{0, 15}, {1, 1.4}}, GridLines -> {None, {1, Log2[1679211/714866]}}, AxesLabel -> {"strip width", "bits a tick"}, ImageSize -> 480]
```

The last point is 1.143992 bits a tick, from 2,868,932 sets on a strip of fourteen cells. The line at 1.232 is the Lean bound and the line at 1 is the lower bound. The exact strip bounds decrease to the entropy as the strip widens, with no rate.

## Is the entropy above one bit?

The kit's catalogue reads log 2 from its counts: to length 15 a word of one column has at most about n²/4 partners in the next. Exact counts pass n²/4 at length 17 (73 partners), and have 177 at length 23, where n²/4 is 132.25. An exact calculation of the fair measure entropy gives increments above one bit at lengths to 21. They decrease.

```wl
incr = {{10, 0.1890356785}, {11, 0.1788235938}, {12, 0.1690311183}, {13, 0.1614661853}, {14, 0.1543637805}, {15, 0.1486271230}, {16, 0.1434279834}, {17, 0.1389372130}, {18, 0.1349303601}, {19, 0.1312655041}, {20, 0.1279754285}, {21, 0.1248832816}};
ListLinePlot[incr, Mesh -> All, PlotRange -> {0, 0.2}, AxesLabel -> {"length n", "fair increment minus 1 bit"}, ImageSize -> 480]
```

A sequence that decreases to an entropy rate bounds it from above and not from below. The last value bounds the fair measure entropy by 1.124884 bits a tick. Wolfram's *A New Kind of Science* gives less than 1.155 for the measure entropy and says that some evidence points to 1. Whether the topological entropy is above one bit is open. Nothing here decides it.

## Earlier work

`Mixing` proves log 2 ≤ h ≤ log 3 and describes the two-column identity. Its cover argument is what we use, with the number of pair words made visible (`coverMincard_le_card_pairWords`, carried here since the verifier's kit has it only inside a proof). Di Lena and Margara (2007, Corollary 4.6) prove that the entropy of a permutive automaton of radius r is that of its width 2r + 1 column trace, which is three columns for Rule 30. Guillon's thesis (2008, Proposition 4.8.5) relates the entropy to that of a trace. One column alone does not determine the cells to its west, and two do. Our notes of October 2026 had the two-column form for Rule 30 by hand, with the counts to length 17 and the bound 1.3189 bits. For the measure entropy, Wolfram (1986) has about 1.20 bits and Grassberger (1986) less than 1.15436; for the topological entropy the general bound is 2 bits. The tables and the count past 17 are from November. The general idea of bounding a language by a weighted automaton is standard.

## What is not claimed

Nothing about the centre column of one black cell, or about Problems 1 to 3. The wider tables and the fair measure entropy are outside the Lean. Whether the entropy is above one bit is open.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission." <> #) & /@ {"entropy_eq_pair_growth", "entropy_le_block_root", "ReverseCover.entropy_le", "ReverseCover.pair_count", "FiveSite.entropy_width_5", "FiveSite.entropy_lt_log_forty_seven_twentieths", "pairWords_translate", "card_pairWords_add_le"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
