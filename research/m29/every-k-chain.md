# The chain for every k: from the doubling lemma to the inverse-tick statement

**Stream B1 of K8.** Author claudeM5, 19 November 2026; reader gptIntel. This document turns the sketches of M34,
M35, M39 and M41 (on R44) into numbered steps. Each step states its hypotheses, its status and where it lives, so
that stream A can formalise it line by line. It adds nothing computed.

Statuses. **PROVED IN LEAN** names a Lean theorem that compiles. **CARRIED** is a hand proof that an independent read
has passed (the read is named). **PROOF-SKETCH** has had no such read, or only a read of its idea. **OPEN** is not
proved.

## 1. Objects

1.1 **Rows.** A row is x : ℤ → {0,1}. Rule 30 is F(x)(i) = x(i−1) ⊕ (x(i) ∨ x(i+1)). A finite nonzero row has a
leftmost black cell, its *edge* e.
- **F moves the edge one cell left.** F(x)(e−1) = 0 ⊕ (0 ∨ 1) = 1. Every cell further left has three white inputs,
  so it stays white.
- **Age.** The row F^a(x0) of a finite nonzero seed x0 has *age* a.

1.2 **Wheels.** Wheel j at tick t is the cell j places inward from the edge, written d j t. The wheels of any finite
nonzero orbit, and every limit of them, satisfy the kit's `Recurrence` (`Rule30AgedLeftDiagonals`):
- d 0 (t+1) = d 0 t;
- d 1 (t+1) = d 0 t ∨ d 1 t;
- d (i+2) (t+1) = d i t ⊕ (d (i+1) t ∨ d (i+2) t).

A **strip** is d : ℕ → ℕ → Bool with `Recurrence d` and d 0 0 = true (a black edge). The kit's `PeriodFrom x 0 p`
says x (t + p) = x t for all t.

1.3 **Pointed recurrent strips.** A strip is *pointed recurrent* when every prefix has a common period from tick 0:
∀ m, ∃ p > 0, ∀ i ≤ m, `PeriodFrom (d i) 0 p`. This is the hypothesis `clocks` of `unbounded_anchors`. M39 calls
these *consistent left sides*; R37 calls them pointed recurrent strips. They are the same objects, and stream A
should use one name.

1.4 **Phases.** The *phase word* of a strip at tick s is the infinite word (d 0 s, d 1 s, d 2 s, …).
- Wheel j depends only on s modulo its period. So the phases of one strip form a compact space, the 2-adic integers
  ℤ₂, once every prefix period is a power of 2 (step 9 below).
- A 2-adic phase ω of d is tick 0 of another pointed recurrent strip, d shifted by ω (Recurrence and the periods are
  shift-invariant).
- So "every phase of every strip" may be read with integer ticks throughout, provided "every strip" includes the
  shifted ones.

1.5 **Edge bands.** The width-w band of a row is its w cells from the edge inward: wheels 0 … w−1 at that tick.
- **Autonomy.** For a row of width at least w, the next row's band depends only on this band. The new band's
  rightmost cell reads three cells of the old band, and everything left of the edge is white. So the bands evolve by
  a map R_w on {0,1}^w (M33, M34).
- **Cycles.** A word on a cycle of R_w, read over the ticks of its cycle, is the width-w prefix of a pointed
  recurrent strip. Conversely, every cycle extends to an infinite pointed recurrent strip: iterate the return map on
  the finitely many periodic extensions and choose a periodic point (R37's read of M39, step 4; König).
- **Convergence age.** g(w) is the least age a such that, for every finite nonzero seed, every row of age ≥ a has its
  width-w band on a cycle of R_w. A row of age a has at least a + 1 cells, and R_w has 2^w states. So
  **g(w) ≤ w − 1 + 2^w** (M35, step 1; CARRIED in R35).

1.6 **Resets.** A *reset word* in a phase word is a closed black run 0 1^(3m+1) 0 (m ≥ 0).
- **Its two ends.** Its *deep end* is the wheel of its deeper 0, and its *shallow end* the wheel of the other 0.
- **It sits between whites.** Its black cells cannot lie on a permanently white wheel. So a reset lies between two
  consecutive white wheels, its ends included.

1.7 **White intervals and doublings.**
- A wheel A is *white* when d A t = 0 for all t. Then wheel A + 2 is black for all t (the kit's "black diagonal two
  above"; `unbounded_anchors` returns both facts).
- A *white interval* is [A, B] with A and B white and no white wheel strictly between: in M42–M44's word, *whole*.
- Its *source* is column A − 1, and its *first child* is column A + 1, with
  d (A+1) (t+1) = d (A−1) t ⊕ d (A+1) t.
- If the source has least period P, the first child is antiperiodic at P exactly when the source has an odd number
  of black ticks in P. Then the interval is a *doubling*, and it is *dyadic* when P is a power of 2.

1.8 **Inverse layers and the one-layer schedule.**
- **Layers.** A k-tick preimage of a row r is x with F^k(x) = r, read as a history of k rows: layer i inverts one
  tick. One layer reads the output row from a start depth towards the edge. Its register holds two preimage bits
  (four states).
- **Coalescence.** The layer *coalesces* at a depth when every one of the four registers allowed at the start gives
  the same preimage bits from that depth to the edge.
- **The schedule** (R28; M35). Layer 1 starts at depth w − 1 of the band with all four registers free. Each later
  layer starts where the previous one coalesced, one wheel further in (the edge retreats by one per layer, R37's read
  of M40), again with all four registers free, and reads the previous phase.
- **Capacity.** K1(w) is the least, over all cycle words of R_w and all their phases, of the number of layers this
  schedule closes before it reaches the edge.
- **Not used here.** The joint capacity K(w) ≥ K1(w) of M34 keeps cross-layer information. It is not needed for
  unboundedness (M35).

## 2. The target

**(T)**, in the maintainer's words on kit PR #357 (18 November): "the statement for every number of ticks k: an age
f(k) from which every k-tick preimage of a nonzero finite orbit has its true edge k cells inside the image edge,
proved by an argument that does not need a new cover for each k."
- **Formal instances in the kit:** `finite_row_aged_image_two_step_predecessor_true_edge` (k = 2).
- **In S1:** `aged_four_step_predecessor` and `all_four_tick_histories` (k = 4 at age 80).
- **Stating (T) for every k** in that form is A1 (gptM5). The steps below use only its informal content: for a row r
  of age ≥ f(k), all k-tick preimages agree with the true ancestors near the edge, and their edges sit 1, 2, …, k
  cells inside r's edge.

## 3. The chain

The chain is (DL) ⇒ (L∞) ⇒ (CAP) ⇒ (T).
- **(L∞)** says every phase word of every pointed recurrent strip contains reset words at arbitrarily large depths.
- **(CAP)** says for every k there is a width w with K1(w) ≥ k.
- **(DL)** is the doubling lemma (§3.3).

### 3.1 (CAP) ⇒ (T)

**Step 1, the reset rule.** One layer started at depth s, with all four registers free, coalesces one cell after
the shallow 0 of the first reset word whose deep 0 it has read, reading from s towards the edge.
- **Status:** PROVED as a finite automaton (M39, checked at 65,536 starts on A0); CARRIED in R37. Known: kit PR #60's
  `run_resets` (Lowry), G13's exact one-layer language, P6.
- **Why:** in the subset automaton, after any 0 the subset is {A, E} in R29's classes (A = 00, C = 10,
  E = {01, 11}). A 1 rotates A → E → C → A. A 0 sends A to A and C, E to E. So the subset collapses exactly after a
  0 that ends a black run of length 1 mod 3, and one more bit fixes the pair.
- **For Lean:** a small automaton; A2 may import or reprove `run_resets`.

**Step 2, monotonicity.** By step 1, a layer started deeper never coalesces shallower. *Immediate from step 1.*

**Step 3, the band reaches a cycle.** Every row of age ≥ g(w) has its width-w band on a cycle of R_w, and by 1.5 that
cycle is the prefix of a pointed recurrent strip. Its k true ancestors are that strip's phases at the k previous
ticks.
- **Status:** CARRIED (M35 step 1 in R35; R37's read of M39).
- **For Lean:** A3 (the kit's `Ld_uniform_period`, or a pigeonhole on the 2^w band states).

**Step 4, capacity closes the history** (M34's argument). Let r have age a ≥ g(w), so that its width-w band lies on
a cycle of R_w. Suppose every phase of that cycle admits k layers under the schedule. Then every k-tick preimage of r
agrees with r's true ancestors on the coalesced parts, and its edge is k cells inside r's edge.
- **Why:** each layer's start allows all four registers, so it covers every possible deeper part of every preimage,
  infinite black tails included (M36: an unclosed history is a cut). Coalescence fixes the preimage bits from the
  coalescence depth to the edge, to those of the true ancestor. That ancestor's edge is one cell further in.
- **The references are cycle phases.** The schedule reads layer d against the cycle's phase −d. If a < g(w) + d, the
  true ancestor's band may still be transient, but this does not matter.
  - The cycle's phase −1 is a preimage band of phase 0 under R_w.
  - Coalescence makes every preimage agree on the coalesced bits. So every preimage agrees there with phase −1, the
    true ancestor included.
  - Layer 2 then reads bits that are known for every preimage, and so on.
  - So no extra width beyond w is needed. An earlier draft of this step asked for w + k cells, from M36's φ form. A1
    rightly needs only the settled band (`Settled`), and A3's proof must make this point.
- **Status:** CARRIED (M34 in R29: "f(k) ≤ g(W(k)) holds whenever the stated cycle covers all seeds and W(k)
  exists"; M39 steps 1, 2 and 5 in R37).
- **For Lean:** A2 and A3. The edge condition is exactly where the kit's k = 1, 2 statements and S1's k = 4 statement
  serve as templates.

**Theorem B** ((CAP) ⇒ (T)). Let W(k) be the least w with K1(w) ≥ k. Then (T) holds with
f(k) ≤ g(W(k)) ≤ W(k) − 1 + 2^(W(k)). This is steps 3 and 4.
- **Status:** CARRIED by hand, not in Lean. This is S2's main theorem.
- **Its Lean statement is A1** (R45, `Rule30EveryKStatement.lean`, SHA-256 `76d64433…`):
  - `ConditionalEveryK` with `settlingBound (widthFor capacity k)`;
  - the sharper `CapacityAtSettlingAge`, for any established settling age.
- **Not explicit yet.** The bound is explicit given W(k). (CAP) gives existence, not a value: an explicit W(k) needs a
  rate. For k ≤ 7,911, M40 gives f(k) ≤ 265,441 from the kit's `forced_front_four_uniform` (CARRIED in R37; replayed
  in I2).

### 3.2 (L∞) ⇒ (CAP)

**Step 5, one strip and one phase** (M39 step 2). Suppose phases s − k + 1, …, s of a strip each have reset words at
arbitrarily large depths.
- **Choose resets.** Choose ρ_k, ρ_(k−1), …, ρ_1, a reset of phase s − k + 1, s − k + 2, …, s respectively. Each
  ρ_j has its shallow end more than two wheels deeper than the deep end of ρ_(j+1). ρ_k can be any reset of its
  phase, for example the one inside wheels 2–7 that every phase has (§4.2).
- **The schedule closes k layers.** Start at any width w deeper than ρ_1's deep end.
  - Layer 1 reads ρ_1 whole, so it coalesces at depth ≥ (shallow end of ρ_1) − 1, by steps 1 and 2.
  - Layer 2 starts one wheel further in, still deeper than ρ_2's deep end. So it coalesces at depth ≥ (shallow end of
    ρ_2) − 1.
  - The same holds for every layer, k in all.
- **Status:** CARRIED (R37's read of M39). The margin of two wheels covers the retreat of one wheel per layer and the
  coalescence lag of one cell.
- **A1's exact constants.** A complete factor `0 1^(3m+1) 0 z` must lie inside the available bits, z included. The
  next layer then has the j bits 0 … j − 1, where j is z's wheel (`firstReset`, `schedule`). This margin is smaller
  than the two wheels above, and correct.

**Step 6, one width for every phase** (M39 step 3).
- The event "the schedule closes k layers at width w, from phase s" depends on finitely many wheels. So it is a
  finite union of residue classes of s, open and closed in ℤ₂.
- By step 5 every phase lies in one such event for some w. The events grow with w by step 2.
- By compactness of ℤ₂, one w serves every phase of the strip.
- **Status:** CARRIED (R37).

**Step 7, one width for every strip** (M39 step 4).
- Width-w cycle words are finitely many.
- The pointed recurrent strips form a compact space: the inverse limit of the finite sets of cycle prefixes.
- The event of step 6 is open in it. A finite subcover gives one w for all strips and all phases.
- **Status:** CARRIED (R37: "These histories form a compact inverse limit of finite cycle sets… A finite subcover
  gives one width for all phases and strips.")

**Theorem A** ((L∞) ⇒ (CAP)) is steps 5–7. **Status:** CARRIED (R37), not in Lean.

**Step 8, the converse** ((CAP) ⇒ (L∞); reasoned, not needed for the chain). Suppose phase q of some strip has no
reset deeper than d0.
- **Start the schedule at phase q itself.** By step 1, layer 1 coalesces at a reset of phase q, shallower than d0,
  whatever the width.
- Each later layer coalesces at least one wheel nearer the edge than the one before. So at most d0 + 1 layers close.
- So K1(w) ≤ d0 + 1 at every width on that strip's cycle words, and (CAP) fails.
- So (L∞) is also necessary for this route. A route through the joint capacity K(w) could need less.

### 3.3 (DL) ⇒ (L∞)

**(DL), the doubling lemma.** Every dyadic doubling white interval has a reset in every tick: for every tick s there
is a reset word of phase s with both ends in [A, B].
- **Status:** OPEN. Its computed evidence is in the ledger header of rotation 2 and in M44–B2.
- **What step 10 uses is weaker:** (DL⁻), the same statement only for the intervals that start at a first clock loss
  of a pointed recurrent strip.

**Step 9, clocks.** Let d be a pointed recurrent strip.
- (a) `escapes_clock`: for every p > 0, some wheel j ≤ 2^p·2^p + 1 has ¬`PeriodFrom (d j) 0 p`.
- (b) `first_clock_loss`: past any prefix [0, m] with common period p, there is a white wheel j ≥ m such that the
  prefix [0, j] still has period p, and column j + 1 is antiperiodic at p.
- (c) `unbounded_anchors`: past any depth there is a white wheel whose wheel two places on is black.
- (d) The least common period of every prefix is a power of 2.
  - Wheel 0 has period 1. By (b), the clock is first lost just after a white, where the next column is
    antiperiodic at the old clock p, so its period is 2p.
  - Every column up to the next loss inherits the clock from a nonwhite driver (R44's note, "Which doubling remains
    open"). Induction on the losses gives 1, 2, 4, ….
- **Status:** (a)–(c) PROVED IN LEAN (`Rule30RootedWhiteReturns.lean`, compiled at the kit's `ac3d144` in M41 and at
  `a8072e7` in I2). (d) CARRIED by hand (R44's note, M41); A4 should put it in Lean.

**Step 10, a doubling interval past every depth.** Fix a depth d0.
- Take m > d0 and the period p of the prefix [0, m], a power of 2 by step 9(d).
- Step 9(b) gives a white A ≥ m with prefix [0, A] of period p and column A + 1 antiperiodic at p.
- The source, column A − 1, has period dividing p. Its first child is antiperiodic at p, so its weight over p is odd.
  So its least period P has p/P odd, hence P = p.
- Let B be the next white past A, which exists by step 9(c). Then [A, B] is a dyadic doubling white interval with
  A > d0.
- **Status:** PROOF-SKETCH. Hand steps on Lean facts; this is M41's sketch of R44's argument, written out.

**Theorem C** ((DL⁻) ⇒ (L∞)).
- **Argument.** Suppose phase s of a pointed recurrent strip has no reset deeper than d0. Step 10 gives a doubling
  interval [A, B] with A > d0. (DL⁻) gives a reset of phase s in [A, B], deeper than d0: a contradiction.
- **Status:** PROOF-SKETCH, short. It needs (DL⁻) only at first clock losses, at the clock of the strip.
- **The chain.** Theorems C, A and B give (DL⁻) ⇒ (T).

### 3.4 What is proved of (L∞)

- **R43** (PROVED IN LEAN; CARRIED in M41): on every pointed recurrent strip, for every s, one fixed phase among
  s, …, s + 4 has resets at arbitrarily large depths (`white_five_by_eight`, `one_of_five_unbounded`,
  `unbounded_anchors`).
- **R44** (computer-assisted; CARRIED in M41 and I2): the same with three phases.
  - It is a Lean automaton theorem, `three_phase_return`, plus a hand transfer from the automaton to the strip.
  - The fixed choice among the three phases is by hand (I2). A4 is to bring it into Lean.
- **Neither gives (L∞).** Step 5 needs resets in the k consecutive prescribed phases s − k + 1, …, s. A fixed phase
  among three cannot be chosen to match a prescribed one (R44's note).

## 4. K8's two reformulations, read

### 4.1 Finite intersection: survives, and it weakens what (L∞) needs

K8 §5: on a strip with white wheels w_1 < w_2 < …, let Bad_i be the ticks with no reset inside [w_i, w_(i+1)].
- **The read.**
  - Resets lie between consecutive whites (1.6). So phase s has a reset-free tail exactly when s ∈ Bad_i for all
    large i.
  - Each Bad_i depends on finitely many wheels, so it is open and closed in ℤ₂.
  - By compactness, ∩_(i≥i0) Bad_i is empty exactly when some finite intersection Bad_i0 ∩ … ∩ Bad_i1 is.
  - So (L∞) on the strip ⇔ for every i0 some finite intersection from i0 is empty. This is right with 2-adic phases
    (1.4). With integer ticks only, the ⇐ direction holds and ⇒ needs the 2-adic reading. Since 1.4 identifies the
    two readings across strips, nothing is lost.
- **Consequence 1.** If infinitely many white intervals of a strip each reset in every tick, (L∞) holds on it. This
  is Theorem C again, with the doubling intervals of step 10 as the infinite family. Any other infinite family would
  do as well.
- **Consequence 2, new.** It is enough that infinitely many *runs of consecutive intervals* jointly leave no
  reset-free tick: Bad_i ∩ Bad_(i+1) ∩ … ∩ Bad_j = ∅. A tick may survive one interval and die in the next. So (L∞)
  is strictly weaker than "every doubling interval resets every tick". It admits multi-interval arguments of R44's
  kind, run across consecutive whites.

### 4.2 Unique predecessor: the forward half survives; the backward half needs one more lemma

K8 §5: write F(x) = 4x ⊕ (2x ∨ x) on the odd 2-adic integers, bit j for wheel j.
- **The map.** Bit j of F(x) is x_(j−2) ⊕ (x_(j−1) ∨ x_j): the band map of 1.5, read on the infinite left side. Phase
  words of pointed recurrent strips are the points x whose residue mod 2^w is F-periodic for every w. Call these
  recurrent.
- **⇒ (survives).** Let y be recurrent and have resets at arbitrarily large depths. Bit j of F(x) depends only on
  bits ≤ j of x. So by step 1, every preimage x of y agrees below each reset with any other, and y has at most one
  preimage. It has one, the strip's previous phase. So (L∞) ⇒ every recurrent point has exactly one preimage.
- **Distinct recurrent preimages are impossible anyway.** Two recurrent preimages x ≠ x′ of y would be two periodic
  points of F mod 2^w mapping to one periodic point, for large w. On cycles F is injective, so x ≡ x′ mod 2^w for
  every w, and x = x′. So any second preimage is off the strips, as K8 says.
- **⇐ (needs a lemma).** Suppose y is recurrent with no reset deeper than d0. K8 argues that two candidates survive
  from every depth and merge with the true predecessor before the edge, so both are preimages.
  - **The merging is right.** Every phase has a reset inside wheels 2–7. Wheels 0–7 are the same on every strip, and
    [2, 7] is A0's first doubling interval, which resets in every tick (M41, M43).
  - **The surviving is the gap.** For each depth D the subset automaton keeps two states. So y has at least two
    preimages *mod 2^D* that differ above d0.
  - **To conclude:** these partial preimages must extend to genuine ones. The sets S_D = {x mod 2^D : F(x) ≡ y
    mod 2^D} form an inverse system of finite sets. A partial preimage can die one wheel deeper: if x_D = 1, bit D + 1
    of y constrains x_(D−1).
  - **The lemma, supplied by I7** ([gptIntel's read](k8-reformulation-review.md)). Fix a cut c beyond the last
    reset.
    - The sets of parent pairs at c, reached by starting at greater depths, shrink as the depth grows. Each has at
      least two elements, so they stabilise on at least two pairs.
    - Each stable pair has extensions of every length with finite branching. König's lemma gives an infinite outer
      extension for each, still distinct at c.
    - The inward scan from c is deterministic. The resets at wheels 2–7 (the words 001000 and 011110 in the two
      phases) merge both branches with the true predecessor before the edge.
  - I have read this and agree.
- **Verdict.** "(L∞) ⇔ every recurrent point of F has exactly one preimage" holds in both directions (⇐ CARRIED in
  I7). Whether every recurrent point has a unique preimage is (L∞) itself, and open. As a target, it is a clean
  restatement of (L∞).

## 5. For stream A: what to pin

A1 (R45) settles items 2–4 below for the conditional theorem. Its definitions match this document, with A1's
constants preferred (step 5) and the age of Theorem B.

1. **One name and one definition** for pointed recurrent strips (1.3). State `clocks` as the hypothesis, and derive
   dyadic clocks (step 9(d)) as a lemma. This is needed for Theorem C, not for S2.
2. **The phase convention:** A1 reads layer d against phase −d of the same cycle, which is integer ticks on the cycle
   (1.4).
3. **K1(w) exactly:** A1's `firstReset`, `schedule` and `K1`, over every recurrent odd band.
4. **The edge condition of step 4:** A1's `PhysicalEdge`, `FinitePredecessor` and `AllHistories`, which I4 read
   against the kit's k = 2 theorem and both S1 headlines.
   - **For A3's proof:** the point in step 4 that the references are cycle phases, which agree with every preimage
     on the coalesced bits even while the true ancestors' bands are transient.
5. **What is already in Lean:**
   - step 9(a)–(c) (`Rule30RootedWhiteReturns.lean`);
   - R43's theorem (`Rule30WhiteResetBox.lean`);
   - R44's automaton (`Rule30ThreePhaseReturn.lean`);
   - the kit's `Recurrence`, `PeriodFrom` and `forced_front_four_uniform`;
   - #60's `run_resets` and `scheduled_cascade_closes`, open and unmerged (P6).
6. **What S2 needs:** steps 1–7 and Theorems A and B, with (CAP) or (L∞) as the named hypothesis. Theorem C and
   step 10 are the bridge to (DL). They belong to the unconditional theorem, not to S2.
