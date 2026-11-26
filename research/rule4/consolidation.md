# K83 and its child pulls, assessed and made one pull

claudeCloud, K90, 26 November 2026, at the owner's word: "assess the state of these related pulls, and if possible
consolidate them into 1 well defined pull, otherwise close or park them." Statuses as in METHOD §5.

**In short.** K83 asked what becomes of Rule 30 with the fair coin on the right of a finite left half. Its children asked
it three ways, and K84 a fourth. Everything asked *from above* is answered, and two submissions came of it. Everything
asked *from below* is open, and it is the same question each time. So one pull remains, K83, with that question.

## 1. Where each pull stands

| Pull | Asked | Answered | Posted | Still open |
|---|---|---|---|---|
| **K83.A**, the coin on the right | A1: almost surely no periodic centre. A2: do almost all right halves end in the trap or a lock? | **In Lean (Mathlib), read by the other model both ways:** a prescribed T-tick wall is met by right halves of mass exactly 2⁻ᵀ, with μ(S ∩ E) = 2⁻ᵀ μ(F⁻¹E); backward wall bits are fair; A1 reduces to purely periodic centre words. **COMPUTED with certificates:** the trap holds at least 62.85% of right halves beside an alternating column; immediate alternation has chance at most 7.2%. | nothing | A1, A2. For period two A1 would follow from L(B) < ∞ (K84). |
| **K83.B**, how fast the right is heard | B1 every flip heard, B2 positive speed, B3 entropy above one bit, B4 an upper bound | **B4 in Lean:** entropy is the growth of two-column words, below 1.232039 bits a tick (1.143992 by certificate; fair metric at most 1.124884). **By hand:** a flip reaches arbitrarily far west or escapes east (B1 in part); its westward record advances at most 0.272394 cells a tick (B2 from above). | **S20** (R30-20261126-3c2c76), kit PR #426 | B3; the lower half of B2; the escape half of B1. |
| **K83.C**, what one wall hears | the average (the entropy), the worst wall, one given period | **In Lean:** the entropy is the growth of OR-words; every rational upper rate has a finite certificate; a pair density of 1/7 at unbounded widths gives Problem 1. **COMPUTED:** the seed's largest census nears 1/2. | **S22** (R30-20261126-14e62a), in the kit; modules in S20 | abundance on the seed at every width, which is as strong as window normality. |
| **K84**, the coupled lifetime | is L(B) − B bounded? | **COMPUTED:** no, at every computable length (record 24 at B = 194); it follows log₂ of the gate-word count. **In Lean (core, kit form):** the finite-support equivalences. Floor of 7 from the 155-column ring. | nothing | parked 26 Nov (K89) on a geometric bound for the survivors. |
| **K83**, the parent | list C (candidate columns in measure) and list D (results whose natural form is a limit) | C went on as N6 (S19; S27 in preparation). Of D, S9's real pentagon is S26 (I72). | | D's other three are one-line corollaries, not pulls. |

## 2. The one question

**Do fresh cells on the right keep reaching the wall at a positive rate?** In its sharpest form: *is Rule 30's entropy
strictly above one bit*, that is, do the words on two neighbouring columns outnumber 2ⁿ by an exponential factor?

Every open end above is this, or a weaker or local form of it:
- **B3** is the statement itself, for the topological and the fair metric entropy.
- **B2 from below** (positive westward speed) and **B1's escape half** (no flip escapes east) say that single cells are
  heard.
- **A1** says that no periodic centre has an atom: fresh cells derail a prescribed gate. **A2** is its phase portrait.
- **K84** is the coupled case beside the alternating column: its excess grows at half the gate's entropy.
- **M181's successor** (every order of X and Y is read) would make that gate's entropy at least 0.044 bits a reading.
- **K83.C's seed side** is the same count on one row instead of all rows, and there it is as strong as Problem 1.

**What blocks it, every time.** A lower bound needs many right halves whose gates are known for ever. Short-memory pair
languages have zero entropy (I234). A cylinder that returns to itself cannot exist: a T-tick past has mass 2⁻ᵀ
(K83.A's own law; I239). The patterns periodic in space and time beside an alternating column are four, complete to
48 ticks (K87). What is left is an induction on forcing prefixes, with no reason known for a prefix to recur (I49).

## 3. What changed in NOW.md

- The rows K83, K83.A, K83.B and K83.C are **one row, K83**, with the question of §2, the history above in brief, and
  both submissions. The three child names are recorded under *Closed pulls* as merged.
- **K84 stays parked** as it is (K89), and M181 (K87). Both are named in K83's row as cases of its question.
- N6 and I72 are untouched: they took lists C and D on and have their own rows.

## 4. The next step, and when to park

**Toward a submission.** The family holds Lean that passed its reads and was never posted:

| File | Kind | Says | Read |
|---|---|---|---|
| [K83RightCoin.lean](K83RightCoin.lean) | Mathlib (measure); ten headlines at the pin | the exact past-wall law, closed ranges, null long pasts | [claudeIntel](claudeIntel-k83a-read.md) |
| [K83Feedback.lean](K83Feedback.lean) | Mathlib | the same for the wall a fixed left half makes; the reduction of A1 to pure periods | [gptIntel](gptIntel-n16-feedback-read.md) |
| [K84FiniteSupport.lean](k84/K84FiniteSupport.lean) | core, kit form | a west of support B works through T iff the decoded west is white on B + 1 to T; gate prefixes and west prefixes correspond | gptIntel's; no Claude read of the Lean yet (K88 checked both statements on the complete census) |

The first two state laws about fair measure, which core Lean cannot state, so by METHOD §12 rule 5 they are a portal
entry with `equivalents/` as the only kit route. The third is core and extends `Rule30PeriodTwoSideways`. `find_known`
finds nothing in the kit, the portal list or the prior-art files for the past-wall law. **Next: propose them as one
entry**, with the novelty check done in full and a Claude read of the third.

**Then park.** After that entry nothing in K83 is in reach. It comes back with a construction that gives exponentially
many extra two-column words: a language with hidden states, or a horseshoe.

**Not carried forward:** B1 and B2's hand proofs (sound and read, but a Lean form needs martingale convergence on the
kit's measure, a large port for a bound that S20's essay can cite); A3 and the category form E (never taken); list D's
three one-line corollaries.
