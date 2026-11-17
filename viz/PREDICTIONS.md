# Predictions written before each picture was drawn

## V1, V2: the stopping time of G (17 November 2026, written before `gen_survival.py` first ran)

Object: σ(Y) = least s with G^s(Y) even, G = F∘F, F(Y) = (Y>>1) xor (Y or (Y<<1)) (kit `Rule30ZeroBoundary.IntegerForm`).
Q01 is the statement that σ(Y) is finite for every natural Y.

- P1. Over all Y < 2^24 the counts of σ fall roughly geometrically, ratio between 0.4 and 0.6 per step
  (one free bit gained per double step, one constraint spent). Confidence 0.7.
- P2. The longest survival among rows of width w grows roughly linearly in w, slope between 0.5 and 3.3, with no
  upward curvature by w = 24. Confidence 0.6.
- P3. In 2-adic order (low bits first) the carpet shows nested, self-similar blocks; in natural order it shows
  vertical stripes for small σ, since σ ≥ k depends only on the low 2k+1 bits. Confidence 0.8 for the stripes,
  0.5 for visible self-similarity.
- Counterfactual. Upward curvature in P2 would mean longer rows buy disproportionately longer lives: a pull towards
  a counterexample to Q01, to be measured further. A ratio far from 1/2 in P1 would mean the free-bit count is not
  what the kit's `Theta` parametrisation suggests.
- Record searched: placego L1673 (frontier of Q01GapCore survivors recedes; survival ≈ W/(2−h)), L1675–L1676 (mass
  ladder μ(H) ≈ 0.307H + 5.3, for the weaker Q01Gap language, so not directly comparable), kit
  `Rule30ZeroBoundaryWidth52` (every start of width ≤ 52 dies).

### What run 2 showed (MEASURED and COMPUTED, 17 November 2026)

- P1 held, more sharply than predicted: among Y < 2^24, σ = k occurs exactly 2^(23−k) times for every k ≤ 11. This is
  the kit's free-bit bijection (`Theta`, `realization`): σ ≥ k depends on the low 2k − 1 bits, and exactly 2^(k−1)
  of those prefixes survive, one per free-bit word. Known, reproved here. Beyond k = 12, where a finite row's zero
  tail starts to matter, the ratio per step stays near 1/2 (0.49, 0.51, 0.54, 0.52, 0.63, 0.43, 0.49, 0.61, 0.26 from
  k = 12 to 21): the zero tail behaves like fair coin flips. MEASURED.
- P2 held: the best σ among rows below 2^w is 21 at w = 24, about 0.85w, with no upward curvature. The champions of
  width 11 are 1493 and 1507 (σ = 15), the kit's sharp rows of `Rule30RecognizableBarrier`. A fair-coin zero tail
  predicts a champion near σ ≈ w, which is what the data show.

## V3: the algebra of the constrained start (written before `gen_theta_anf.py` first ran)

Object: Theta_d(f), the cell at depth d of the constrained start with free bits f (kit `Theta`), as a Boolean
polynomial (algebraic normal form over GF(2)) in f_0 … f_(⌊d/2⌋−1). The kit proves Theta affine at depths ≤ 6 and not
affine at depth 7 (`Rule30LinearCharts`). Q01 says the equations Theta_d(f) = 0 for all d beyond some depth have no
common solution.

- P4. The degree of Theta_d grows without bound, and for large d it is close to the number of variables ⌊d/2⌋.
  Confidence 0.5.
- P5. For large d the number of monomials is near half of the 2^⌊d/2⌋ possible, as for a random function.
  Confidence 0.5.
- Counterfactual. A degree that stays bounded, or grows like log d, or a monomial set with a visible nested pattern,
  would mean Theta is nearly linear in a usable sense: a pull worth a block (a degree-bounded system of equations
  can be attacked directly).
- Record searched: `record_find` for "algebraic normal form", "ANF", "Theta degree", "Boolean degree", "free bits
  degree": hits are the forward degree law (placego L1072, kit `AlgebraicDegree`: the centre after t steps has
  degree 2t − 1) and GC2361's warning that a growing degree is not a pseudo-randomness theorem. Nothing on the
  degree of Theta beyond the kit's depth 7.

### What run 4 showed (COMPUTED over all 2^20 free words, depths 1–41, 17 November 2026)

- Affine through depth 6, degree 3 at depth 7: the kit's `Rule30LinearCharts` boundary, reproduced.
- Every even depth 2s+2 is exactly balanced (524288 of 1048576). Reason (PROVED, one-line induction, known: it is
  the left-permutive form of the kit's `realization`): depth k at tick t is depth 1 at tick t+k−1 XOR a function of
  earlier depth-1 ticks, so Theta_(2s+2) = f_s XOR g_s(f_0 … f_(s−1)). The newest free bit always enters linearly.
  Odd depths 2s+3 contain no new free bit: each is a pure constraint on the bits already chosen.
- P4 held: degree is ⌊d/2⌋ (all variables) at d ≡ 3 (mod 4), ⌊d/2⌋ − 1 at d ≡ 1 (mod 4), and ⌊d/2⌋ − 1 or − 2 at
  even depths, through d = 41. The odd-depth law is KNOWN and PROVED in the kit: depth 2n+1 is the first-check
  polynomial of `Rule30FirstCheckDegree` (placego's own, 10 November), degree n for odd n and n − 1 for even n
  (`check_degree`). The record search above missed it because it searched for "Theta" and "ANF", not "check"; the
  kit digest for KIT-INDEX.md found it. Lesson: search the kit for the object under every name it carries.
- P5 REFUTED as stated: odd depths carry about 0.38 of the 2^⌊d/2⌋ possible monomials (0.404 at d = 19, 0.413 at 23,
  0.392 at 27, 0.398 at 31, 0.387 at 35, 0.382 at 39, 0.376 at 41), not 0.5; even depths carry about 0.19, the same
  density one variable down. Sparser than a random function, drifting slowly down. MEASURED trend on exact counts.

## V4: the bars in the monomial picture (17 November 2026, written before `reach.py` first ran)

The owner saw evenly spaced hatched bars at depth 31 with 7 bits across. Column x is empty exactly when the mixed
derivative of Theta_31 along the bits of x vanishes with the other low bits at 0, whatever the high bits: the
influence of f0 is healed before depth 31 in those contexts. The repetition every 32 columns is the layout (f5, f6
count up the x-axis).

- P6. The depth that a flip of f0 reaches, R(f), has a geometric tail: P(R ≥ d) roughly halves every two depths.
  Confidence 0.5.
- P7. There are healing contexts beyond the kit's (f1 = f2 = 1 confines f0 to depths 1–6, `Rule30PrefixMerger`):
  short patterns of f1, f2, … after which f0 never reaches past a fixed depth. Confidence 0.6.
- P8. The reach of f_s is the reach of f0 shifted by 2s (the structure is the same at every free bit). Confidence 0.6.
- Counterfactual. A heavy tail in P6 would mean long memory: deep constraints depend on early free bits, and the
  coast cannot be treated as a short-memory process.
- Record searched: kit `Rule30PrefixMerger` (`theta_truncate_merge`), `Rule30HealingBound`, `Rule30ErrorEdge`
  (KIT-INDEX); placego L1673 (geometric white tail).

### What `reach.py` showed (COMPUTED over all 2^20 free words to depth 41; trends MEASURED; 17 November 2026)

- The bars are healing. The 18 empty columns at depth 31 (7 bits across) are exactly the columns all of whose
  fillings start with a healing context below: checked, an exact match, and no even column is empty.
- P7 held. Minimal healing contexts for f0 (f1 written first): 11 → f0 reaches at most depth 6 (the kit's
  `Rule30PrefixMerger`), 101 → 7, 0000 → 9, 1000 → 10, 0010 → 10, then two of length 5, five of length 6, nine of
  length 7 and thirteen of length 8. Together they cover 82% of free words; f0 still reaches depth 41 in 0.9%.
  Checked to depth 41 only; beyond it, only the kit's case is proved.
- P6 REFUTED as stated: f0's reach has a tail that falls by about 0.8 per free bit (two depths), not 0.5:
  P(R_0 ≥ 8, 16, 24, 32) = 0.625, 0.234, 0.098, 0.038.
- P8 REFUTED, and this is the finding: the reach is not the same at every free bit. The median reach beyond entry is
  about 11 depths for f0, about 24 for f1, and 34 or more for f2; for f5, 92% of words still feel it 30 depths
  beyond entry. A flip at tick 2s+1 must be carried down to the start row at tick 0 before it can disappear, and the
  strip it lives in is 2s+2 ticks wide, so early bits are forgotten fast and later bits are remembered far longer.
  The heal law itself is the record's damage front (placego §8.66, CL740: an edge dies exactly when its nearer parent
  is black); what is new here is seeing it in Theta's coefficients and the dependence on s.
