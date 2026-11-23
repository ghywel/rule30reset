---
Template: ComputationalEssay
Name: Which right prefixes force entry into the width-30 seven-phase lock?
Author: {AUTHORS}
Date: 2026-11-23
Description: A finite branching certificate characterizes entry for every completion of a right prefix and bounds alternation of the single-seed centre.
Abstract: {ABSTRACT}
Keywords: [Rule 30, finite prefixes, period seven, alternating centre, compactness, Lean]
Sources: ["[Troy Lowry’s age-364 construction](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378)", "[The maintainer’s family question](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041)", "[The width-30 seven-phase lock](https://github.com/WolframInstitute/Rule30PrizeKit/pull/227)", "[L. Hallee’s earlier seven-lock](https://github.com/lhallee/rule30-open/blob/f877f5af/Rule30Open/PeriodTwo/SevenLock.lean)"]
---

## Lowry’s construction and the family question

Troy Lowry, working with OpenAI Codex, proved that the first 80 cells to the right of the single-seed centre at age 364 force phase 6 at local tick 95 when the centre is driven to alternate from black. He reconstructed the compatible left side with a 728-cell periodic ring and proved a mismatch within seven moving-edge sites. Six sites can agree. We owe the starting construction, the ring and that sharp conclusion to Lowry. His construction led the kit maintainer to ask which finite right prefixes force entry. [Lowry’s construction](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378) · [Maintainer’s question](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041)

A right prefix prescribes sites 1 through m at the initial black tick. All later sites are free. At each white tick we inspect sites 1 through 30. The lock consists of seven classes of such windows. Once the window belongs to class k, its class two ticks later is k + 1 modulo seven for every exterior. The width-30 classes and this closure theorem were established in the kit. L. Hallee had previously proved a related width-32 seven-lock. [Kit lock and closure](https://github.com/WolframInstitute/Rule30PrizeKit/pull/227) · [Hallee’s seven-lock](https://github.com/lhallee/rule30-open/blob/f877f5af/Rule30Open/PeriodTwo/SevenLock.lean)

## The finite certificate

Each fork of a certificate reads the next unspecified initial cell and covers both values. A leaf names a white sample j and a phase k. At local tick 1 + 2j the window uses at most 31 + 2j initial positive cells. With a full cone the checker evolves the bits exactly. With a shorter prefix it propagates known zeros, known ones and unknowns, and accepts the leaf only if every possible output window belongs to k. Every completion reaches a labelled phase at its labelled time. Different leaves can name different times and phases.

At a fixed deadline J, splitting through the entire cone yields a finite complete test. If every infinite completion eventually enters, compactness gives one deadline for all of them. Otherwise one could choose completions still outside at successively later samples and take a limit agreeing on each successive initial segment. Any entry by the limit depends on finitely many cells and persists thereafter, contradicting the choice of completions. These two facts give both directions of the criterion. A rejected tree leaves open whether another tree passes. [Kit compactness argument](https://github.com/WolframInstitute/Rule30PrizeKit/blob/05c9c73665a118eb34c85a737274d3d51eb6a483/lean/Ruliology/CellularAutomata/Rule30ResetCompactness.lean)

## A two-leaf example

Prescribe the 29-bit code 157190921, with its least significant bit at site 1. The first update needs 31 positive cells. The four assignments to sites 30 and 31 produce three different output windows, all in phase 4. This cell computes the window codes in the order 00, 10, 01, 11, reading site 30 first.

```wl
prefix = 157190921;
inputs = Table[prefix + q 2^29, {q, 0, 3}];
oneStep[n_] := Mod[BitXor[2 n + 1, BitOr[n, BitShiftRight[n, 1]]], 2^30];
oneStep /@ inputs
```

The outputs are 524474782, 792910238, 1061345694 and 792910238. A single unsplit leaf admits a fourth, spurious possibility in the calculation with unknowns. Split on site 30 and each leaf certifies class 4 at tick 1, whatever follows. In Lean, `example29_check` checks the two leaves and the failed unsplit leaf. With only 28 prescribed cells the finite-support completion encoded by 150212610825 reaches the ordinary width-16 trap at tick 83. That trap cannot contain a seven-lock window, as the two require incompatible spacings of neighbour pulses. Closure then excludes entry at every time. Lean proves both sides in `sharp_for_eventual_entry`.

As a comparison on Lowry’s example, an eleven-leaf tree on the first 77 of his 80 cells gives the same phase 6 at tick 95 (`lowry_77_phase`). Lowry’s moving-edge argument supplies the sharp seven-site conclusion after that entry. [Lowry’s theorem](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378)

## What follows for the actual centre

Suppose the singleton at age A displays a certified right prefix. Let E be the largest physical entry tick named in the certificate. If the actual centre followed black-first alternation long enough, sideways reconstruction would make part of its true left side match Lowry’s ring. Across all seven lock phases and all 728 residues of A + E, a comparison with the singleton’s moving edge supplies a disagreement within nine sites once A + E is at least nine. The finitely many shorter starts are checked directly. Consequently some centre bit disagrees with the proposed alternation by absolute tick 2(A + E). For the worked example the deadline is 2(A + 1).

If certified right prefixes occur at arbitrarily late actual ages with a black centre, this deadline contradicts any eventual period-two tail. The prefix and its tree may vary at each age. Establishing those arbitrarily late occurrences remains open. The result is a conditional partial for Problem 1.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission." <> #) & /@ {"accepts_hit", "deadline_iff", "eventual_iff", "centre_bound_of_certificate", "no_period_two_of_cofinal_certificates"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[Last[heads]]["KernelCheck"]
```
