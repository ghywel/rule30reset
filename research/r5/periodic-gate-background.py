"""Replay the masked sideways orbit and test local front cycles on its background."""
import argparse
import json
from collections import Counter, deque
from pathlib import Path


def pack(word):
    return sum((bit == "1") << p for p, bit in enumerate(word))


def sideways(word):
    period = 3*len(word)
    mask = (1 << period)-1
    start = pack("011"*len(word)), pack("".join(b+"00" for b in word))

    def west(pair):
        column, right = pair
        older = ((column >> 1) | ((column & 1) << (period-1))) ^ (column | right)
        return older, column & ~older & mask

    # Brent's algorithm uses constant memory even for a long sideways orbit.
    power = length = 1
    slow, fast = start, west(start)
    while slow != fast:
        if power == length:
            slow = fast
            power *= 2
            length = 0
        fast = west(fast)
        length += 1
    slow = fast = start
    for _ in range(length):
        fast = west(fast)
    transient = 0
    while slow != fast:
        slow, fast = west(slow), west(fast)
        transient += 1
    print(f"gate {word} transient {transient} spatial cycle {length}", flush=True)

    # Form the background only after measuring the exact cycle length.
    columns = []
    state = slow
    for _ in range(length):
        columns.append(state[0])
        state = west(state)
    assert state == slow
    rows = [tuple(columns[-p % length] >> t & 1 for p in range(length))
            for t in range(period)]
    for t, row in enumerate(rows):
        out = rows[(t+1) % period]
        assert all(out[p] == (row[p-1] ^ (row[p] | row[(p+1) % length]))
                   for p in range(length))
    return rows


def moves(rows, phase, initial, next_defective):
    width = len(rows[phase])
    old, new = rows[phase], rows[(phase+1) % len(rows)]

    def input_bit(p):
        if p == initial:
            return (1-old[p % width],)
        if p == initial+1:
            return (old[p % width] ^ next_defective,)
        return (0, 1)

    p = initial-1
    compatible = {(old[(p-1) % width], old[p % width])}
    seen, steps = set(), set()
    while compatible:
        state = (p % width, frozenset(compatible), min(2, p-initial+1))
        if state in seen:
            return steps, True
        seen.add(state)
        following = set()
        for left, current in compatible:
            for right in input_bit(p+1):
                bit = left ^ (current | right)
                if bit == new[p % width]:
                    following.add((current,right))
                else:
                    for farther in input_bit(p+2):
                        second = current ^ (right | farther) ^ new[(p+1) % width]
                        steps.add((p-initial,second))
        p += 1
        compatible = following
    return steps, False


def front_test(rows):
    width, phases = len(rows[0]), len(rows)
    rule = {}
    heals = 0
    for t in range(phases):
        for p in range(width):
            for b in (0, 1):
                rule[t,p,b], infinite = moves(rows,t,p,b)
                heals += infinite
    print("front states",len(rule),"unbounded local healing",heals,flush=True)
    return slab_cycle(rule,width,phases)


def slab_cycle(rule, width, phases, stride=1):
    # Seek a cycle with zero total displacement by retaining the actual
    # front position inside a slab of two spatial periods.
    lo, hi = 2, 2+2*width
    previous = {}
    for t in range(phases):
        for p in range(lo,hi+1):
            for b in (0,1):
                previous[t,p,b] = set()
    for t,p,b in previous:
        for d, next_bit in rule[t,p%width,b]:
            if lo <= p+d <= hi:
                previous[(t+stride)%phases,p+d,next_bit].add((t,p,b))
    # Reverse deletion of vertices with no outgoing edge. The remaining
    # finite set contains a cycle if nonempty.
    counts = Counter(v for children in previous.values() for v in children)
    dead = deque(v for v in previous if not counts[v])
    while dead:
        for v in previous[dead.popleft()]:
            counts[v] -= 1
            if not counts[v]:
                dead.append(v)
    live = [v for v in previous if counts[v]]
    if not live:
        print("no local zero-displacement cycle in this slab")
        return
    steps = []
    current = live[0]
    while current not in steps:
        steps.append(current)
        t,p,b = current
        current = next(((t+stride)%phases,p+d,c) for d,c in rule[t,p%width,b]
                       if counts[(t+stride)%phases,p+d,c])
    cycle = steps[steps.index(current):]
    assert (stride*len(cycle)) % phases == 0
    print("local zero-displacement cycle",cycle,flush=True)
    return cycle


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("word")
    parser.add_argument("--front",action="store_true")
    parser.add_argument("--emit-cycle",type=Path)
    args=parser.parse_args()
    if not args.word or set(args.word)-set("01"):
        parser.error("word must be nonempty binary readings")
    rows=sideways(args.word)
    if args.front or args.emit_cycle:
        cycle=front_test(rows)
        if args.emit_cycle and cycle:
            args.emit_cycle.write_text(json.dumps({"background":rows,"cycle":cycle})+"\n",encoding="ascii")
