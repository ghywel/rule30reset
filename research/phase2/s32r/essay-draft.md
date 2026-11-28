---
Template: ComputationalEssay
Name: Two falling phases at every modulus in single-seed Rule 30: six columns from three, 27 columns at two
Author: {AUTHORS}
Date: 2026-11-28
Description: Core Lean. For every modulus m ≥ 2, any 27 consecutive columns of Rule 30 from a single black cell contain one column that turns from black to white at ticks of two different residues modulo m, each arbitrarily late; six columns suffice from m = 3.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, single seed, columns, falling edges, residues, parity, trapped window, strip certificate, Jen's theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)", "[KDRonald3 and Claude: Windows That Always Return](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

`cell t i` is the colour of column `i` at tick `t` in Rule 30 from a single black cell. Column `i` *falls* at tick `t` when it is black at `t` and white at `t + 1` (`Fall i t`). For a modulus `m` and a residue `r`, `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

**The theorems**, in `Rule30Submission.PhaseFalls.Moduli`:
- `two_cofinal_every_modulus_from_two`: for every `m ≥ 2` and every integer `i`, there are a column among `i, …, i + 26` and two different residues `r` and `q` modulo `m` with `Cofinal` at both.
- `two_parities_every_27`: the case `m = 2`. Among any 27 consecutive columns, one falls on even ticks and on odd ticks, each after every cutoff.
- `two_cofinal_every_modulus`: for every `m ≥ 3`, six consecutive columns suffice.
- `not_good_parity`: why `m = 2` needs more. In the six-cell strip with free exterior cells, a loop of four rows has every fall on an even tick, and every adjacent pair of its cells changes under a shift by two ticks.

The column and the residues may depend on `m` and `i`. This entry supersedes R30-20261127-157e8c, whose theorem is `two_cofinal_every_modulus`.

## 2. Where it sits

| | About | What is proved |
|---|---|---|
| Jen's theorem (kit, `Rule30Jen`) | two different columns | they are never both eventually periodic, with any periods |
| *Windows That Always Return* (KDRonald3 and Claude, R30-20261115-2d4add) | two and three adjacent columns | a window that avoids a set of rows is trapped in a finite graph; each black pair recurs |
| `Rule30SettledBarrierEffective` (Quint and Gemini, kit; R30-20261106-2b31c4) | the centre | a fall in `[a, a + L)` under explicit conditions, with no residue specified |
| `Rule30FallResidues` (kit, from R30-20261127-157e8c) | any six consecutive columns | for each `m ≥ 3`, one column falls arbitrarily late on two residues |
| this entry | any 27 consecutive columns | the same at `m = 2`, hence at every modulus from two |

A column whose falls keep to one residue modulo `m` keeps to one residue modulo every divisor of `m`. So the statement at `m = 2` is not implied by the others: it is the one modulus that no other divides.

## 3. Exploration

**What the seed does.** The falls of the 27 columns `−13, …, 13` over the first 4,000 ticks, counted by parity:

```wl
rows = CellularAutomaton[30, {{1}, 0}, {4000, {-13, 13}}];
falls[c_] := Flatten[Position[Partition[c, 2, 1], {1, 0}]] - 1;
Grid[Prepend[Table[With[{f = falls[rows[[All, j]]]}, {j - 14, Count[Mod[f, 2], 0], Count[Mod[f, 2], 1]}], {j, 1, 27}], {"column", "even", "odd"}], Frame -> All]
```

In this sample every column falls on both parities. The theorem gives one column in the 27 at which both continue after every cutoff.

**The strip.** Read six cells as a number whose bit `k` is the cell `k` sites east of the first. One update with exterior cells `w` and `e` is Rule 30 on those six. An update is *quiet* when no cell falls. The lemma behind the reduction for `m ≥ 3`: if a quiet update changes the strip, the strip cannot make two more quiet updates, whatever the exterior does.

```wl
step[s_, w_, e_] := Module[{b = Join[{w}, Reverse[IntegerDigits[s, 2, 6]], {e}]}, FromDigits[Reverse[Table[BitXor[b[[k]], BitOr[b[[k + 1]], b[[k + 2]]]], {k, 6}]], 2]];
succ[s_] := Union[Flatten[Table[step[s, w, e], {w, 0, 1}, {e, 0, 1}]]];
fallMask[s_, d_] := BitAnd[s, BitXor[s, d]];
quiet[s_] := Select[succ[s], fallMask[s, #] == 0 &];
AllTrue[Range[0, 63], Function[s, AllTrue[DeleteCases[quiet[s], s], Function[d, AllTrue[quiet[d], Function[e, quiet[e] === {}]]]]]]
```

**The loop at modulus two.** The rows 3, 36, 63, 1 form a loop of the strip, and every fall on it is on an even tick. Below: each row is a successor of the one before; the cells falling at each update; and the loop's period. Every cell repeats after four ticks, while every adjacent pair changes under a shift by two.

```wl
loop = {3, 36, 63, 1};
bits = Table[Reverse[IntegerDigits[loop[[Mod[t, 4] + 1]], 2, 6]], {t, 0, 7}];
{AllTrue[Range[4], MemberQ[succ[loop[[#]]], loop[[Mod[#, 4] + 1]]] &], Table[Reverse[IntegerDigits[fallMask[loop[[t]], loop[[Mod[t, 4] + 1]]], 2, 6]], {t, 4}], AllTrue[Range[4], bits[[#]] == bits[[# + 4]] &], Table[AnyTrue[Range[4], bits[[#, {j, j + 1}]] != bits[[# + 2, {j, j + 1}]] &], {j, 5}]}
```

So the loop defeats a repeat at lag two, but not Jen's theorem, which needs only some period.

**The moduli that need a certificate from three.** Deletion brings every modulus above 18 down to 18. Each modulus from 3 to 18 has a divisor among seven:

```wl
Grid[{Range[3, 18], Table[SelectFirst[{3, 4, 5, 7, 11, 13, 17}, Divisible[m, #] &], {m, 3, 18}]}, Frame -> All]
```

## 4. The proof

**From three** (unchanged from the superseded entry).
1. **One residue each** (`two_cofinal_from_good`). Suppose that no column of the six has two cofinal residues. Then past some tick every column keeps its falls to one residue: an *assignment* of a residue to each site.
2. **The strip** (`Run`, `Good`). From then on the six cells are a path in a finite graph. A node is a row of six cells. An edge is one Rule 30 update with both exterior cells free, in which only the sites assigned to the current slot of the calendar may fall. An assignment is `Good` when every such path has an adjacent pair of cells that eventually repeats every `m` ticks.
3. **Quiet triples** (`quiet_eq`). If three successive updates are quiet, the first leaves the row unchanged.
4. **Deletion** (`good_of_small`). For `m > 18`, a free triple of slots lets one update be deleted from every period, so every modulus reduces to one from 3 to 18.
5. **Divisors** (`good_of_dvd`). That leaves 3, 4, 5, 7, 11, 13 and 17.
6. **The certificates** (`good3`, …, `good17`). 918 rank certificates; no assignment survives at width six. They are the superseded entry's tables, repacked. The checker that reads them (`checkFast`) uses only raw `Nat` operations and is proved sound in the source (`good_of_checkFast`), so the kernel checks them about five times faster.
7. **Jen.** A `Good` assignment makes two adjacent columns of the single seed eventually periodic, which Jen's theorem forbids (`not_adjacent`).

**At two.**
1. **Any lag** (`GoodAny`). Jen's theorem needs only that some adjacent pair repeats with some lag `L`. So an assignment of parities to the cells of a strip is good when every path of the strip graph has such a pair.
2. **Records** (`pairAny_of_records`). A certificate gives each node a rank, a class (or none) and a position. Along every edge the rank does not increase. Along an edge of equal rank both nodes have the same class, and the position advances by one modulo the class's period. At a node with a class, the class's pair reads the class's word at the node's position. On a path the rank is eventually constant, and the pair then repeats with the class's period.
3. **Three ways to check them.**
   - `checkLag`: a table over every node, for nine assignments of widths 4 to 10.
   - `checkEv`: a table that marks where the paths of a strip eventually stay.
   - `checkProd`: a table over pairs of such states. A strip is cut in two, a path of the strip restricts to a path of each half, and each half eventually stays where its table says. This is used for six assignments of widths 12 to 20. The halves' eventual sets hold 24 to 61 nodes, so the products have at most 2,867 pairs, where the full graphs have up to 2²¹ nodes.
4. **The fifteen certificates.** Eleven of them repeat at lag two. Four need cycles of length 4, 8 or 10.
5. **Every assignment of 27 cells** (`goodAny27`). As from three, every assignment on two sites is listed with the first parity even. At each wider strip only those whose two narrower restrictions both survive are kept. The fifteen certificates rule out the rest, and nothing survives at width 27.
6. **Jen** (`two_cofinal_from_goodAny`). As in step 7, with rows of 27 cells and the path's own lag.

## 5. What is not shown

- **Which column.** The column may differ with the modulus and with the columns chosen. Nothing is proved about the centre or about the site −2.
- **Period two.** An eventually alternating centre puts the late falls of columns −4 to +1 on single parities, black, black, white, black, black and black ticks in turn, and that assignment is not ruled out by the strip at width six. Nothing here excludes an eventual period two.
- **Fewer columns at two.** By computation in the rule30reset record, the method needs exactly 27 cells: one assignment of 26 cells survives.
- **Three residues, or both residues close together**, and frequencies.
- **Problem 1.**

## 6. Prior art and credit

- **KDRonald3 and Claude**, *Windows That Always Return* (R30-20261115-2d4add): the trapped window with freely chosen exterior cells, and the use of Jen's theorem against its recurrent parts.
- **Erica Jen**: no two columns are both eventually periodic (the kit's `Rule30Jen`).
- **The kit**: the strip encoding and its step (`Rule30StripCertificates`), and `encRow` for rows of any width.
- **Authorship.** From three: the proof, the fixed deletion and the certificates are GPT's; the modulus as a parameter, the computed profiles and the idea of removing quiet runs are Claude's, as is the review of the proof. At two, and the faster checker: Claude's. That includes the any-lag certificates, the product certificates, the classification to width 27 and the census behind it.
- **Search.** We searched the kit's catalogue at `0f41bf3`, the portal's 469 entries (28 November, 18:09 UTC) and the kit's open pull requests. The terms were falling edges, residues, parities and phases of columns, trapped windows and strips with free exterior cells. We found the entries above, and none that fixes the parities of falls.

## The formal proof

The source imports the kit's `Rule30StripCertificates`, present at the verifier's kit revision, and carries no kit code. It is twenty-two modules in their build order, inside `Rule30Submission`. The seven data modules for `m ≥ 3` sit in nested namespaces `Data3` to `Data17`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The four headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.PhaseFalls.Moduli.two_cofinal_every_modulus_from_two", "Rule30Submission.PhaseFalls.Moduli.two_parities_every_27", "Rule30Submission.PhaseFalls.Moduli.two_cofinal_every_modulus", "Rule30Submission.PhaseFalls.Moduli.not_good_parity"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel replays every declaration of the module. This check comes last because it resets LeanLink's elaboration state.

```wl
rule30Submission["Rule30Submission.PhaseFalls.Moduli.two_cofinal_every_modulus_from_two"]["KernelCheck"]
```
