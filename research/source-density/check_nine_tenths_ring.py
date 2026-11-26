"""Independent bit-by-bit replay of the extremal graph and the ring against S9."""
import ast
from itertools import product
from pathlib import Path
import re

KIT = Path(__file__).resolve().parents[2] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata"


def rule(left, center, right):
    return left ^ (center | right)


def array_literal(text, name):
    match = re.search(rf"private def {name} : Array Nat := #(\[[^\]]+\])", text)
    return ast.literal_eval(match.group(1))


def tight_graph():
    text = (KIT / "Rule30DensityEscape.lean").read_text(encoding="utf-8")
    pot = ast.literal_eval(re.search(r"def highPot : Array Nat := #(\[[^\]]+\])", text).group(1))
    graph = {i: set() for i in range(64)}
    for cells in product(range(2), repeat=8):
        center, right = cells[1:3]
        old = sum(x << j for j, x in enumerate(cells[1:-1]))
        new = sum(rule(*cells[j:j+3]) << j for j in range(6))
        loss = pot[old] - pot[new] + 6 + 3*center*(1-right) - 8*center
        assert loss >= 0
        if loss == 0:
            graph[old].add(new)
    live = set(graph)
    sizes = [len(live)]
    while True:
        survivors = {v for v in live if graph[v] & live} & {w for v in live for w in graph[v]}
        if live == survivors:
            break
        live = survivors
        sizes.append(len(live))
    assert sizes == [64, 20, 17, 15, 14]
    start, = (v for v in live if v % 4 == 0)
    phase = {start: 9}
    pending = [start]
    while pending:
        v = pending.pop()
        for w in graph[v] & live:
            nxt = (phase[v]+1) % 10
            if w in phase:
                assert phase[w] == nxt
            else:
                phase[w] = nxt
                pending.append(w)
    assert set(phase) == live
    assert all(v % 4 == (p < 9) + 2*(p % 2 == 0) for v, p in phase.items())
    return sizes


def check_ring():
    c = tuple(int(t < 9) for t in range(10))
    r = tuple(int(t % 2 == 0) for t in range(10))
    pair = (c, r)
    pairs = []
    seen = set()
    while pair not in seen:
        seen.add(pair)
        pairs.append(pair)
        c, r = pair
        pair = (tuple(c[(t+1) % 10] ^ (c[t] | r[t]) for t in range(10)), c)
    assert len(pairs) == 155 and pair == pairs[0]
    f = lambda t, j: pairs[-j % 155][0][t % 10]
    assert all(f(t+1, j) == rule(f(t,j-1), f(t,j), f(t,j+1))
               for t in range(10) for j in range(155))
    text = (KIT / "Rule30SourceDensityCorners.lean").read_text(encoding="utf-8")
    rows = array_literal(text, "rows3")
    # Fix the S9 observing site at zero. Its unique white tick fixes the time shift.
    start, = (s for s in range(10) if not rows[(s+9) % 10] & 1)
    assert all(f(t,j) == (rows[(t+start) % 10] >> j) & 1 for t in range(10) for j in range(155))
    assert (sum(f(t,0) for t in range(10)), sum(f(t,0)*(1-f(t,1)) for t in range(10))) == (9,4)
    return start


if __name__ == "__main__":
    print("Surviving six-cell words:", tight_graph())
    print("First return 155. All 1550 forward equations and S9 cells agree at time shift", check_ring())

