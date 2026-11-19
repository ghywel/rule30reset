# What an odd white gap forces at one tick

**Claim for review (I3, C2).** Let a recurrent whole interval have white
endpoints at 0 and g, with g ≥ 5 odd. Let T be the least temporal period
of its first-child word. Then T ≤ 2^((g−3)/2). In particular, if a source of
least period P doubles, 2P ≤ 2^((g−3)/2). For P = 2^m this says g ≥ 2m+5.
The estimate grows logarithmically in P. The proposed comparison with
reset resolution would need a much larger lower bound.

Write x_j for the row at one tick. After s ticks, the value at j, for
j−2s ≥ 1, has the form

    x_{j−2s} XOR H_s(x_{j−2s+1}, …, x_j).

At zero ticks the correction is zero. At the next step the expression at
j−2 contributes the unique leftmost bit, with coefficient one. The
expressions at j−1 and j contain only later bits. This proves the identity
inductively. The triangle stops at the original row; its internal updates
all have index at least 3, so no later free input at cell 1 enters it.

Take s = (g−1)/2 and j = g. The future endpoint is white. Thus x₁ is a
function of x₂,…,x_g on every extendible row. Moreover, from any current
row the local rule already fixes all cells from 2 to g at the next tick.
The same identity there fixes the remaining first bit. Consequently a
repeated complete row forces the same first-child sequence forever.
The T phases of a word of least period T therefore occupy distinct rows,
even in a graph that allows an arbitrary exterior input.

Apply the cone identity at j=g for **every** s=1,…,(g−1)/2, in that
order. Each right white solves for the next unknown x_{g−2s} from cells
already determined or supplied further right. Thus the even cells
x₂,x₄,…,x_{g−1} determine all odd cells of this row. The second cell is
latched black on the periodic excursion: its update is x₁ OR x₂ and x₁
has a black tick. This leaves (g−3)/2 free bits. For a doubling,
the temporal difference of the first child is the source, so its least
period is a multiple of P; the half-period complement and its return at
2P give least period exactly 2P. At g=5 the rows with interiors
0100 and 1111 alternate and attain the bound T=2.

**Where the block stops.** With even g the extreme path at (g−2)/2
ticks starts at bit 2. At g/2 ticks it starts at the fixed bit 0;
bit 1 is inside the nonlinear part of the cone. The coefficient-one
identity supplies no recovery of bit 1 there. The proof gives no bound
on even-gap doublings or the depth of a reset at a prescribed tick.
