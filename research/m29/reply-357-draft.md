Thank you, understood: we will not send further per-k covers. Here is what the covers show so far about why the ages
grow, as progress towards the statement for every k. All of it is computer-assisted and not yet in Lean.

**1. Closure is synchronisation.** Read a row from the wall outwards. Each of its 2^k wall histories keeps, on each
inverse layer, the last two cells of that layer's parent, and layer d + 1 reads layer d. For age ≥ k the row's own
orbit is one of these histories and closes. So every k-tick preimage is finite exactly when all 2^k trajectories have
merged by the edge. A cover's "every incoming register resets" is the band-level form of this.

**2. The edge band has one limit cycle.** The top w cells evolve on their own, by v ↦ 4v ⊕ (2v ∨ v) mod 2^w, as in
`Rule30FourLeftSides`. C20, the base of `band_from_age_twenty_six`, is exactly this map's limit cycle at width 20.
Through width 128 every row's top cells enter one cycle, of period 4 below width 30 and 8 from 30 on.

**3. Two functions of the width replace the per-k cover.**
- **Capacity:** K(w) is the number of inverse layers that every word of the width-w cycle resets, for every incoming
  register. It is 2 at widths 20–24, 3 at 25–61, 4 at 62–66, 5 at 67–80, 6 at 81–85, 7 at 86–90, 8 at 91–102, 9 at
  103–107, 10 at 108–122 and 11 at 123–128.
- **Convergence time:** g(w) is the first age by which every row's top w cells lie on the cycle, read from S1's
  moving cover, which holds every seed. It gives g(20) = 26, g(64) = 97, g(100) = 139 and g(128) = 178, about
  1.4 ticks per cell.
- **The bound:** with W(k) the least width with K(w) ≥ k, every k-tick preimage of every row of age ≥ g(W(k)) is
  finite. So f(k) ≤ g(W(k)), and k enters only through K.

**4. What this says about 8, 24, 80.** Each further inverse tick needs roughly 11–12 more cells of converged band,
and the band converges at about 1.4 ticks per cell. That is about 17 ticks of age per inverse tick. The uneven steps
come from the plateaus of K; for example, K = 3 on widths 25–61 separates three ticks from four. The age 80 belongs
to S1's cover: a cover started from the seed's top eight bits closes four ticks from 72, and three ticks from
exactly 31.

Bounds so far, with each lower bound given by an explicit failing seed one tick earlier: f(1) = 8, f(2) = 24,
f(3) = 31, 59 ≤ f(4) ≤ 72, 73 ≤ f(5) ≤ 78, 104 ≤ f(6) ≤ 108, f(7) ≤ 131, f(8) ≤ 132, f(9) ≤ 144, f(10) ≤ 157 and
f(11) ≤ 172.

**What is missing.** The statement for every k needs K(w) to grow without bound, uniformly over the edge band's
cycles. The simplest mechanism seems to be enough.
- **One-layer resets alone.** Use only the known one-layer reset words (0, then 3m + 1 ones, then 0 and one more bit),
  one layer at a time. Then the band closes 9 layers at width 128, 94 at 1024 and 383 at 4096 (worst phase), about
  one layer per 10.7 cells.
- **Coalescence is quick at every depth tested.** From every cell of every phase, one layer's four registers coalesce
  within 65 cells, to depth 4096.
- **Joint resets do somewhat better.** They give 11 layers at width 128, against 9; at width 91, a forced 010 in the
  previous parent supplies the extra layer.
- **A finite f(k) up to 383 ticks.** By `Rule30UniversalLeftSide`, the single seed's cycle is every row's limit
  through width 53,207. With a finite-state convergence time, f(k) is therefore finite for every k ≤ 383, though
  with a poor bound on the age.

For every k, what remains is a proof that one-layer coalescence happens within a bounded number of cells at every
depth of the edge band, a recurrence property of rule 30's left side. For f(k) = O(k), a linear convergence time is
needed too. We are working on these; if the argument holds, we will formalise it and update this pull request.

The programs and notes are in https://github.com/ghywel/rule30reset/tree/main/research/m29, with the discussion in the
repository's ledger (posts M30–M34 and R23–R33).
