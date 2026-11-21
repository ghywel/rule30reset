"""First-event-return graph on the kit's GE2 kick-gap language.

One time unit here is a white-to-white double step. A state (d,j) is j
steps into a kick gap d, with 0 <= j < d and j=0 at the preceding kick.
The walk through unmarked states is iterated to exact subset recurrence.
"""
from itertools import product
from math import lcm
from pathlib import Path
import re


KIT = (Path(__file__).resolve().parents[2] / "Rule30PrizeKit" / "lean" /
       "Ruliology" / "CellularAutomata" / "Rule30Certificates" / "PeriodTwoWidth13.lean")


def kit_pairs():
    source = KIT.read_text()
    branch = re.search(r"def pairOK .*?if m == 1 then \[(.*?)\]\.contains", source, re.S)
    if branch is None:
        raise ValueError("Cannot read the kit's pairOK list")
    return {(int(a), int(b)) for a, b in re.findall(r"\((\d+),(\d+)\)", branch.group(1))}


def rule(left, middle, right):
    return left ^ (middle | right)


def local_check():
    # a,b,c,d are columns 1..4 at a white centre time. The rows below
    # evolve using successive centre bits 0,1. Only the first two output
    # columns matter, so the complete radius-two input has four free bits.
    for a, b, c, d in product((0, 1), repeat=4):
        p, q, r = rule(0, a, b), rule(a, b, c), rule(b, c, d)
        x, y = rule(1, p, q), rule(p, q, r)
        if a == 0:
            assert (x and b == 0) or (not x and y == 1 - b)


def marker(state):
    gap, offset = state
    return offset > 0 and (gap - offset) % 2 == 0


def graph(pairs):
    gaps = {d for edge in pairs for d in edge}
    return {(d, j): ([(d, j + 1)] if j + 1 < d else [(g, 0) for e, g in pairs if e == d])
            for d in gaps for j in range(d)}


def exact_relations(edges):
    marks = {s for s in edges if marker(s)}
    # The initial frontier may contain marks. After the first step it
    # contains only walks that have not returned to any mark yet.
    quiet = frozenset((s, s) for s in marks)
    seen = {}
    accepted = []
    while quiet not in seen:
        seen[quiet] = len(accepted)
        reached = {(start, target) for start, cur in quiet for target in edges[cur]}
        accepted.append({(a, b) for a, b in reached if b in marks})
        quiet = frozenset((a, b) for a, b in reached if b not in marks)
    return accepted, seen[quiet], len(accepted) - seen[quiet]


A, B, C, D = (3, 1), (4, 2), (5, 1), (5, 3)
NAMES = {A: "A", B: "B", C: "C", D: "D"}


def formula(n):
    if n == 2:
        return {(C, D)}
    if n == 3:
        return {(A, A), (A, C), (B, C), (D, A), (D, C)}
    if n >= 5:
        return {(D, C if n % 2 else B)}
    return set()


def main():
    local_check()
    pairs = kit_pairs()
    edges = graph(pairs)
    assert {s for s in edges if marker(s)} == set(NAMES)
    print("GE2 gap pairs:", sorted(pairs))
    print("event offsets:", {d: [j for j in range(d) if marker((d, j))] for d in range(2, 6)})

    rel, first, period = exact_relations(edges)
    # The list index is n-1. Check transient and one full common period
    # after both the exact relation and the proposed formula are periodic.
    def at(n):
        i = n - 1
        return rel[i if i < first else first + (i - first) % period]

    stop = max(first + 1, 5) + lcm(period, 2)
    for n in range(1, stop):
        assert at(n) == formula(n), (n, at(n), formula(n))
        print(f"n={n}", sorted(NAMES[a] + NAMES[b] for a, b in at(n)))
    print(f"exact recurrence at n={first + 1}, period={period}")

    # Every reachable return is represented by the finite prefix and its
    # recurrent parity classes. Joining at the intermediate mark gives
    # the exact allowed *consecutive* return lengths without losing phase.
    for n in (2, 3, 4, 5, 6, 7):
        ends = {b for a, b in at(n)}
        following = [m for m in (2, 3, 4, 5, 6, 7) if any(a in ends for a, b in at(m))]
        print(f"gap class {n} -> {following} (6,7 denote all even >=6, odd >=7)")

    even_edges = at(2) | at(6)
    states = set(NAMES)
    for _ in range(3):
        states = {b for a, b in even_edges if a in states}
    assert not states  # every four consecutive events visit both white phases

    example = (5, 2, 2, 5)
    assert all(pair in pairs for pair in zip(example, example[1:]))
    t = 0
    times = []
    for gap in example:
        times.extend(t + off for off in range(gap) if marker((gap, off)))
        t += gap
    assert times == [1, 3, 10, 12]
    print(f"kick gaps {example}: event times {times}, return gaps {[b-a for a,b in zip(times,times[1:])]}")


if __name__ == "__main__":
    main()
