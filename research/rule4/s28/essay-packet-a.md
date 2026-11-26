---
Template: ComputationalEssay
Name: {TITLE}
Author: {AUTHORS}
Date: {DATE}
Description: Lean with Mathlib. After T ticks of a prescribed or continuously chosen boundary, the right half of a fair Rule 30 row has the fair law conditioned on a closed set of mass 2⁻ᵀ, and almost-sure aperiodicity beside a finite left half reduces to purely periodic words.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, fair coin measure, random configurations, right half, boundary history, feedback, change of measure, eventual periodicity, Lean 4, Mathlib, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

A right half seen after $T$ Rule 30 ticks retains information about the $T$ bits that drove its western boundary. Under the fair-coin law, each prescribed past of length $T$ occupies a set of right halves of measure $2^{-T}$. We give the exact law of the driven update, including when the wall is determined by the initial right half, and reduce almost-sure aperiodicity of the centre beside a finite left half to purely periodic words.

## The law of a prescribed past

Write $\mu$ for independent fair bits on sites $1,2,\ldots$. Fix the centre bits $w(0),\ldots,w(T-1)$. Let $F_w$ send the initial right half to the one reached after $T$ physical ticks and let $S_w$ be its range. For every Borel set $E$ of right halves,

$$
\mu(S_w\cap E)=2^{-T}\,\mu(F_w^{-1}(E)).
$$

In particular $S_w$ is closed and has mass $2^{-T}$. The law of $F_w(r)$ for fair $r$ is the fair law conditioned on $S_w$. Different words of length $T$ have ranges whose intersections have measure zero. A fixed finite word specifies a past measured from the output time. For example, a fair current right half admits at least $k$ complete previous turns of a specified alternating phase with probability $4^{-k}$. This example uses the theorem at $T=2k$. A countable collection of prescribed infinite pasts has measure zero.

```wl
Grid[Prepend[Table[{k, 2 k, 4^-k}, {k, 0, 5}], {"Complete turns", "Past ticks", "Fair mass"}], Frame -> All]
```

To see the mechanism, take a full row of fair coins. The centre trace and the initial right half are independent fair sequences, and every full time slice is again fair. A word $010$ sufficiently far east pins a predecessor bit and permits leftward reconstruction. Almost surely every output row contains such words arbitrarily far east. Working back $T$ times recovers the earlier half and centre bit from each succeeding right half. The proof holds against every comparison row on one conull set. Thus membership in $S_w$ identifies the prescribed past almost surely, even if a comparison row is chosen only after seeing the output. Independence makes the probability of matching the $T$-bit wall exactly $2^{-T}$. [Kit fair trace and right half](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/equivalents/Rule30Equivalents/RandomConfigurations.lean) · [Kit time-slice law](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/equivalents/Rule30Equivalents/Mixing.lean) · [Kit inverse window](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/equivalents/Rule30Equivalents/Preimages.lean)

## Continuous feedback and fixed left halves

Allow a continuous rule $W$ to select the entire centre trace from the initial right half $r$. Let $G(r)=F_{W(r)}(r)$. The law becomes

$$
\mu(\operatorname{range}(G)\cap E)=2^{-T}\,\mu(G^{-1}(E)).
$$

For each fixed $r$, the first $T$ bits of the independent fair wall match those of $W(r)$ with probability $2^{-T}$. The backwards reconstruction identifies $r$ as well as its past wall: for almost every fair row, its right half at tick $T$ determines every earlier cell at and east of the boundary, against every other row. So the same event argument applies. Continuity makes the range compact and closed. In particular a null event for a fresh fair right half stays null when pulled back through $T$ ticks of feedback.

For a fixed left half including site $0$, the physical centre trace is one such continuous $W$. The left half may have infinite support for the mass law. The reduction to purely periodic words uses an additional hypothesis. Suppose that for every finitely supported left half containing a black cell, and every pure periodic centre word, the set of right halves reading that word from time zero is null. Then for each such left half the centre is almost surely aperiodic in the sense of having no eventual period. At a finite restart the left half still has finite nonempty support because the leftmost black cell advances left one place per tick. Take a countable union over all possible restart times, finite left halves and words, pulling each null set back by the feedback law. The pure-word nullity hypothesis is open, including the alternating case with unbounded left support width.

## Relation to prior work

The kit's full-row fair law and its two-sided trace theorem supply the probabilistic starting point. The result here identifies the law on one spatial half after conditioning on a finite past, with exact normalization under prescribed or continuous feedback. Its recovery proof uses the kit's $010$ predecessor window. Rowland's inverse analysis and Kopra's spatial reconstruction results are related. Kopra's Theorems 3.5 and 4.5 concern reconstruction from traces and exact recurrence of a right tail. Beside an alternating centre, the kit already gives the unique west for a given right half and the first tick at which a wrong west fails (`Rule30PeriodTwoSideways`), and the dependence of that west on the gate readings (`Rule30CoupledGerms`, by Quint and Gemini); the laws here allow any boundary. [Kit two-sided trace](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/equivalents/Rule30Equivalents/Invertibility.lean) · [Rowland](https://ericrowland.github.io/papers/Local_nested_structure_in_rule_30.pdf) · [Kopra](https://www.utupub.fi/server/api/core/bitstreams/eeb04919-9fa7-443b-998f-032fab664a41/content)

## Lean verification

The source uses Mathlib's product measure on Boolean sequences and imports the kit's `Rule30Equivalents.Mixing`, which is present at the verifier's kit revision.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

The nine headline theorems, as Lean prints them:

```wl
heads = {HEADS};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.RightHalfFeedback.driven_exact"]["KernelCheck"]
```
