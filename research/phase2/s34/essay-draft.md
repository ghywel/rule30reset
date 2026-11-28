---
Template: ComputationalEssay
Name: Falls on both parities in every 27 columns of single-seed Rule 30
Author: {AUTHORS}
Date: 2026-11-28
Description: Core Lean. Any 27 consecutive columns of Rule 30 from a single black cell contain one column that turns from black to white on even ticks and on odd ticks, each arbitrarily late: the modulus two that an earlier entry's strip argument left open.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, single seed, columns, falling edges, parity, trapped window, strip certificate, Jen's theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)", "[Two falling phases in every six columns, at every modulus from three](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261127-157e8c)", "[KDRonald3 and Claude: Windows That Always Return](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

`cell t i` is the colour of column `i` at tick `t` in Rule 30 from a single black cell. Column `i` *falls* at tick `t` when it is black at `t` and white at `t + 1` (`Fall i t`). For a modulus `m` and a residue `r`, `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff. These are the definitions of the kit's `Rule30FallResidues`.

**The theorems**, in `Rule30Submission.FallParities`:
- `two_parities_every_27`: for every integer `i`, there is a column among `i, …, i + 26` with `Cofinal` at both residues modulo 2. That is, it falls on even ticks and on odd ticks, each after every cutoff. The column may depend on `i`.
- `goodAny27`: the strip statement behind it. Let each of 27 cells be allowed to fall at one tick parity only, and let both exterior cells vary freely. Then every path of the strip has an adjacent pair of cells that eventually repeats with some lag (`GoodAny`).

## 2. Where it sits

| | About | What is proved |
|---|---|---|
| Jen's theorem (kit, `Rule30Jen`) | two different columns | they are never both eventually periodic, with any periods |
| *Windows That Always Return* (KDRonald3 and Claude, R30-20261115-2d4add) | two and three adjacent columns | a window that avoids a set of rows is trapped in a finite graph; each black pair recurs |
| *Two falling phases in every six columns* (R30-20261127-157e8c; kit `Rule30FallResidues`) | any six consecutive columns | for each modulus `m ≥ 3`, one column falls arbitrarily late at two residues; at `m = 2`, a four-row loop of the strip has every fall on an even tick |
| this entry | any 27 consecutive columns | the same at `m = 2` |

A column whose falls keep to one residue modulo `m` keeps to one residue modulo every divisor of `m`. So two is the one modulus that the earlier entry cannot reach through another. Together, the two entries give two cofinal falling residues at every modulus from two, in every 27 adjacent columns.

## 3. Exploration

**What the seed does.** The falls of the 27 columns `−13, …, 13` over the first 4,000 ticks, counted by parity:

```wl
rows = CellularAutomaton[30, {{1}, 0}, {4000, {-13, 13}}];
falls[c_] := Flatten[Position[Partition[c, 2, 1], {1, 0}]] - 1;
Grid[Prepend[Table[With[{f = falls[rows[[All, j]]]}, {j - 14, Count[Mod[f, 2], 0], Count[Mod[f, 2], 1]}], {j, 1, 27}], {"column", "even", "odd"}], Frame -> All]
```

In this sample every column falls on both parities. The theorem gives one column in the 27 at which both continue after every cutoff.

**The earlier entry's loop.** Read six cells as a number whose bit `k` is the cell `k` sites east of the first. One update with exterior cells `w` and `e` is Rule 30 on those six. The rows 3, 36, 63, 1 form a loop of this strip, and every fall on it is on an even tick. Below:
- each row is a successor of the one before;
- the cells falling at each update;
- every cell repeats after four ticks;
- every adjacent pair changes under a shift by two ticks.

```wl
step[s_, w_, e_] := Module[{b = Join[{w}, Reverse[IntegerDigits[s, 2, 6]], {e}]}, FromDigits[Reverse[Table[BitXor[b[[k]], BitOr[b[[k + 1]], b[[k + 2]]]], {k, 6}]], 2]];
succ[s_] := Union[Flatten[Table[step[s, w, e], {w, 0, 1}, {e, 0, 1}]]];
fallMask[s_, d_] := BitAnd[s, BitXor[s, d]];
loop = {3, 36, 63, 1};
bits = Table[Reverse[IntegerDigits[loop[[Mod[t, 4] + 1]], 2, 6]], {t, 0, 7}];
{AllTrue[Range[4], MemberQ[succ[loop[[#]]], loop[[Mod[#, 4] + 1]]] &], Table[Reverse[IntegerDigits[fallMask[loop[[t]], loop[[Mod[t, 4] + 1]]], 2, 6]], {t, 4}], AllTrue[Range[4], bits[[#]] == bits[[# + 4]] &], Table[AnyTrue[Range[4], bits[[#, {j, j + 1}]] != bits[[# + 2, {j, j + 1}]] &], {j, 5}]}
```

So the loop defeats a repeat at lag two, but not Jen's theorem, which needs only some period. On wider strips, with any lag allowed, such loops no longer suffice.

## 4. The proof

1. **One parity each.** Suppose that no column of the 27 has both parities cofinally. Then past some tick every column keeps its falls to one parity: an *assignment* of a parity to each cell.
2. **The strip** (the kit's `Run`). From then on the 27 cells are a path in a finite graph. A node is a row of cells and a tick parity. An edge is one Rule 30 update with both exterior cells free, in which only the cells assigned to the current parity may fall.
3. **Any lag** (`GoodAny`). An assignment is good when every such path has an adjacent pair of cells that eventually repeats with some lag `L`. A good assignment makes two adjacent singleton columns eventually periodic, which Jen's theorem forbids (`two_cofinal_from_goodAny`, with rows of any width from the kit's `encRow`).
4. **Records** (`pairAny_of_records`). A certificate gives each node a rank, a class (or none) and a position.
   - Along every edge the rank does not increase.
   - Along an edge of equal rank, both nodes have the same class, and the position advances by one modulo the class's period.
   - At a node with a class, the class's pair reads the class's word at the node's position.

   On a path the rank is eventually constant, and the pair then repeats with the class's period.
5. **Three ways to check them.**
   - `checkLag`: a table over every node, for nine assignments of widths 4 to 10.
   - `checkEv`: a table that marks where the paths of a strip eventually stay (`EvIn`).
   - `checkProd`: a table over pairs of such states. A strip is cut in two, and a path of the strip restricts to a path of each half (the kit's `slice_run`). Each half eventually stays where its table says. This serves for six assignments of widths 12 to 20: the halves' eventual sets hold 24 to 61 nodes, so the products have at most 2,867 pairs, where the whole graphs have up to 2²¹ nodes.
6. **The fifteen certificates.** Eleven of them repeat at lag two. Four need cycles of length 4, 8 or 10.
7. **Every assignment of 27 cells** (`goodAny27`). As in the earlier entry, the assignments are settled by width. Every assignment on two cells is listed with the first parity even. At each wider strip only those whose two narrower restrictions both survive are kept. The fifteen certificates rule out the rest, and nothing survives at width 27 (`classify_stepAny`, `of_emptyAny`).

The checks use only raw `Nat` operations and loops on `Nat.rec`'s predecessor, so that the kernel evaluates them quickly; each checker is proved sound in the source.

## 5. What is not shown

- **Which column.** The column may differ with `i`. Nothing is proved about the centre or about the site −2. Two falls at −2 an odd distance apart after every cutoff would exclude an eventual period two of the centre.
- **Period two.** An eventually alternating centre puts the late falls of the six columns −4 to +1 on single parities: black, black, white, black, black and black ticks in turn. That assignment is not ruled out by the strip at width six. Nothing here excludes an eventual period two.
- **Fewer columns.** By computation in the rule30reset record, this method needs exactly 27 cells: one assignment of 26 cells survives.
- **Frequencies**, and two parities close together.
- **Problem 1.**

## 6. Prior art and credit

- **The earlier entry**, *Two falling phases in every six columns of single-seed Rule 30, at every modulus from three* (R30-20261127-157e8c; the kit's `Rule30FallResidues`). The strip, its paths, the coverage by substrips and the step to the single seed are that entry's, and they are carried from the kit here. This entry adds the modulus that its control showed out of reach.
- **KDRonald3 and Claude**, *Windows That Always Return* (R30-20261115-2d4add): the trapped window with freely chosen exterior cells, and the use of Jen's theorem against its recurrent parts.
- **Erica Jen**: no two columns are both eventually periodic (the kit's `Rule30Jen`).
- **Authorship.** The earlier entry's proof and certificates are GPT's, with Claude's modulus parameter and review. Here the any-period census, the any-lag and product certificates, the faster checks and the classification to width 27 are Claude's. The census was replayed by two further programs, a separate C program and a Python one.
- **Search.** We searched:
  - the kit's catalogue at `0f41bf3`;
  - the portal's 469 entries (28 November, 18:09 UTC);
  - the kit's 20 open pull requests.

  The terms were falling edges, residues, parities and phases of columns, trapped windows and strips with free exterior cells. We found the entries above, and none that fixes the parities of falls.

## The formal proof

The source imports the kit's `Rule30StripCertificates`, present at the verifier's kit revision. The two modules of the earlier entry that the proof uses reached the kit after that revision. They are carried in `Rule30Submission.KitFallResidues`: `Rule30Certificates.FallResidueStrip` whole, and the definitions `Fall` and `Cofinal` of `Rule30FallResidues`. The proof follows in three parts, as in the kit:
- `FallParityLag`: the any-lag certificates and their checkers;
- `FallParityData`: the fifteen certificates and the classification;
- `Rule30FallParities`: the step to the seed.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The two headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.FallParities.two_parities_every_27", "Rule30Submission.FallParities.goodAny27"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel replays every declaration of the module. This check comes last because it resets LeanLink's elaboration state.

```wl
rule30Submission["Rule30Submission.FallParities.two_parities_every_27"]["KernelCheck"]
```
