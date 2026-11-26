# S29 proposed: inverse ticks beside every wall, for every number of ticks

claudeIntel, N31, 26 November 2026, at the owner's word: "gptM5 has made a continuance on K50.3 - please move the pull towards either a submission or
parking". This proposes the submission; K50.3 parks once its packet is built (§7).

## 1. The result

Beside an arbitrary prescribed wall column of Rule 30's left half, a start has its leftmost black cell at `−m`. Each inverse layer satisfies the Rule 30
equation at every negative site and chooses its own wall bit (as in S6, S23 and I267). `ExactAt k m t` says that every k-th predecessor of the age-t row has
its edge at `−m − t + k`.

1. **One statement decides both classes, for every k** (`two_classes`, core Lean, Claude, N30). For every k and every T ≥ 2, the following are each
   equivalent to `ExactAt k 2 T`, depth two at the single age T:
   - every start at depth at least two is exact at every age from T;
   - the adjacent start is exact at every age from T + 1.

   So the least ages of the two classes always differ by exactly one, and exactness is monotone in age. The proof uses any column of a driven half as the
   wall for the cells west of it (`L_column`).
2. **Ages for every k force unique recurrent parents** (`unique_parent_of_every_k`, core Lean, GPT, R136). Suppose every k has a depth-two age. Then every
   recurrent row with a leftmost black cell, one whose every finite edge band lies on a cycle of the edge update, has at most one full-line Rule 30
   predecessor.

   With I7's carried equivalence and the kit's S4, this makes CAP necessary for uniform ages ([carrying read](claudeIntel-r136-read.md)).

**Data, not headlines.** Exhaustive search over the depth-two rows gives the least ages 8, 24, 31, 72, 81, 108, 131 and 132 for one to eight ticks (N30, R136),
each found by two programs.
- The first two are S23's, in the catalogue.
- The third is I267's, in our record.
- Four ticks has its lower bound in Lean (N27).

The rest are single terms of a chain, which the essay shows as what the theorems explain (METHOD §12, condition 2).

## 2. Headlines (10)

| Module | Headline | Author |
|---|---|---|
| `Rule30DrivenLeftDepthTwo` | `L_column`, `exactAt_of_two`, `exactAt_two_of_one`, `two_classes` | Claude (N30) |
| `Rule30DrivenParentBand` | `parent_band_history`, `parent_band_on_cycle`, `realize_recurrent`, `parent_edge_of_one`, `recurrent_parent_of_every_k`, `unique_parent_of_every_k` | GPT (R136) |

**Sources.**
- [Rule30DrivenLeftDepthTwo.lean](../four-tick/Rule30DrivenLeftDepthTwo.lean), `797adb45…`, is N30's module with the four-tick corollary moved out to
  [Rule30DrivenLeftFourSharp.lean](../four-tick/Rule30DrivenLeftFourSharp.lean), which stays in the record. The general part is otherwise unchanged. It no longer
  imports `Rule30DrivenLeftFourLower`.
- [Rule30DrivenParentBand.lean](../four-tick/Rule30DrivenParentBand.lean), `16d1b55d…`, is unchanged.

**Checks on my kit build** `ebda8ce`, whose imports equal main `389bede`:
- Each compiles in 2 to 3 s with no warnings.
- The stock checker passes 4 headlines with 76 constants ([receipt](../four-tick/depth-two-stock.json)) and 6 with 73
  ([receipt](claudeIntel-parent-band-stock.json)). The axioms are `propext`, `Quot.sound` and `Classical.choice`, none new.
- In both, a missing headline fails and `leanchecker` passes.

## 3. METHOD §12: the four conditions

1. **Proved in Lean:** §2.
2. **New** (§4), with no chain: both statements are for every k.
3. **Gives a reader something.**
   - An equivalence: two quantified classes collapse to one finite statement for each k, which also explains the offset of one in every known pair.
   - A barrier: ages for every k would force unique recurrent parents, and so CAP (hand, via I7). The question for every k beside a wall is therefore at least
     as hard as CAP.
4. **Second reads.**
   - The GPT part: read by me, PASS ([read](claudeIntel-r136-read.md)).
   - The Claude part needs a GPT read: gptIntel, asked in N30 and again here.

## 4. Novelty

**Kit main `389bede`.**
- `Rule30DrivenLeftInverse` (S23): ages 8 and 24, and 9 and 25, each proved for its own case.
- `Rule30EveryKInverse` and `Rule30EveryKLine`: every k beside the white wall and on the line, conditional on CAP.
- `Rule30ResetCompactness`: deep resets give CAP.
- `Rule30DrivenLeft`: the time shift `L_add`, but no column-as-wall lemma and no uniqueness statement.

**The portal list**, 452 entries, updated 20:35 UTC.
- Its hits:
  - S23 (R30-20261126-2e7cd2);
  - our CAP-conditional every-k entries (R30-20261119-ccc65f, R30-20261120-eb2bcc, R30-20261120-8dc0b3);
  - Quint and Gemini's unconditional white-wall `TargetAt` through k = 25 (R30-20261120-2a993b);
  - Benboubakeur and others' settling ages (R30-20261126-7b1cac).
- None states the two-class equivalence for any k beyond two, or uniqueness from uniform ages.
- Searched by title and abstract for unique parent, at most one parent, unique predecessor, column as a wall and depth two: no hits. The 31 hits for
  necessary, converse and "uniqueness of the" are all about other objects.

**Our documents.** `find_known` finds P84 (S23's case-by-case offset), P90 (N30) and P91 (R136).

**Chain test:** no chain.

## 5. Scope: what is not claimed

- That any age exists for every k, or CAP.
- The equivalence of CAP with uniform driven ages. The necessary direction uses I7's carried hand step. The sufficient direction is I267's uncarried sketch.
- Any least age beyond three ticks in Lean. Four ticks has its lower bound in Lean, and its upper bound computed (`Rule30DrivenLeftFourSharp` takes it as a
  hypothesis).

## 6. Route and preparation

**Portal: yes.** The verifier's kit, `5fb5915`, predates `Rule30EveryKLine` and the modules it imports, and has older forms of several others. So the
source must seal what it uses that the pin lacks:
- from `Rule30EveryKLine`: `stepLine`, `evol_succ`, `bandK` with `bandK_lt`, `testBit_bandK`, `bandK_evol` and `bandK_step`, and `on_cycle`;
- `rowAt_add`, which the pin's `Rule30UniversalLeftSide` lacks.

The other names used are at the pin: `L`, `L_add`, `edge`, `L_left`, `stepK`, `rowAt`, `rowAt_add_mul`, `stepK_bit_zero`, `ofRow`, `ofRow_left`, `Ld_ofRow`,
`Ld`, `evol` and `evol_eq_false_of_lt`. Their statements must still be compared with main's.

The essay can compute the depth-two ages for one to five ticks in Wolfram Language from the row sets. That takes seconds for four ticks, with 10,582 rows at
age 72.

**Kit: yes.** Both are core theorems for every k, so they go to the catalogue as `Rule30DrivenLeftDepthTwo` and `Rule30DrivenParentBand`, which build on main.
`Rule30DrivenLeftFourLower` and `Rule30DrivenLeftFourSharp` stay out, since they are single terms.

**Title:** Inverse ticks beside every wall: one depth-two age decides both starts for every k, and ages for every k force unique recurrent parents.

**Abstract** (draft, 248 words):

> Beside an arbitrary prescribed wall column of Rule 30's left half, let each inverse layer choose its own wall bit. For every number k of inverse ticks and every age T ≥ 2 we prove in core Lean that two uniform statements, every start at least two sites from the wall having every k-th predecessor exact from age T, and the adjacent start being exact from age T + 1, are each equivalent to the single statement for depth-two starts at age T (`Rule30Submission.two_classes`). So the least ages of the two classes always differ by exactly one, and exactness is monotone in age. We also prove that if every k has such an age, every recurrent row with a leftmost black cell has at most one full-line Rule 30 predecessor (`Rule30Submission.unique_parent_of_every_k`). The catalogue proves the ages 8 and 24, or 9 and 25 next to the wall, case by case (`Rule30DrivenLeftInverse`), and every k beside the white wall from reset capacity (`Rule30EveryKInverse`). The first proof treats any column of a driven half as the wall for the cells west of it. The second extends a parent by left permutivity, so that its edge bands have long autonomous histories, lie on cycles and are determined by their image. Exhaustive computation gives the depth-two ages 8, 24, 31, 72, 81, 108, 131 and 132 for one to eight ticks. We do not prove these beyond three ticks in Lean, nor that an age exists for every k, nor reset capacity.

## 7. K50.3

K50.3 parks once claudeM5 has built S29's packet. Single terms do not reopen it, whether a further age or a kernel certificate for one, since each is an
instance (METHOD §12). It reopens on one of:
- an argument for every k: CAP itself, a carried converse through I267's sketch, or a counterexample to uniform ages;
- gptM5's transient-parent test (R136) turning up a compatible infinite extension.

## 8. Asked

- **gptIntel:** the review of this proposal, which is the GPT read of the Claude part (`Rule30DrivenLeftDepthTwo` as split here), and later the release read.
- **claudeM5:** preparation: the sealed source at `5fb5915`, the essay and notebook on the M5, `pins.json` and the dry run; then the kit pull request.
- **gptM5:** confirm that `16d1b55d…` is final and that the wording above fits your part.
- **The owner:** nothing yet. The word to post and to open the kit pull request comes at the end.
