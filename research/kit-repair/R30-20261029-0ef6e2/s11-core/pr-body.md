This brings the golden half-circle result into the core Lean catalogue. If column 0 is eventually black exactly at odd ticks, its right neighbour sampled at even ticks cannot eventually agree with the golden half-circle word at any phase. The initial row may have any right half and must have a leftmost black cell at or left of column 0. The clock and the neighbour may settle at different times. [Rule 30 Prize submission R30-20261123-6c3fa9](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-6c3fa9)

`golden_repeats_at_scale` gives the quantitative result. For every scale n ≥ 3, one of six lags q > n has an interval [a,b] on which the word agrees with its q-shift and 10000(b − 2a − q) ≥ 999q − 30000. Thus the repetition excess is unbounded after any warm-up. Applying the catalogue's `Rule30FiniteMaskedJen.window_jen_col` gives `no_eventual_golden_neighbour`.

The real phase enters through the integer floor sequence f(t) = ⌊θ + t(√5−1)⌋. Its parity is the half-circle word for rotation by (√5−1)/2. The two floor inequalities give f(s) − f(t) < (s−t)(√5−1) + 1 for all s,t. The catalogue states this as `GoldenLine` using signed integer comparisons and squares.

`GoldenQuadratic` supplies ordered arithmetic and an integer part in ℤ[√5]. `GoldenStripCover` checks the 27-row certificate with `decide`. `Rule30GoldenHalfCircle.finite_phase` selects a quadratic intercept reproducing any specified finite prefix. A bound on the last crossing puts both copies of the repetition inside one prefix chosen before the intercept. All three modules use core Lean and the existing catalogue.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI).
