"""Localise the R31 width-91 discrepancy at its 3+3 cut; preserve leading exterior zeros."""
import json
from gptM5_reset_blocks import block
from twin_past import scan

PHASE = 0x6f671619da217f6c637c9ac


def outputs(word, width, layers):
    rows = set()
    for initial in range(4**layers):
        state = initial
        row = 0
        for i in range(width):
            row |= ((state >> (2*layers-2)) & 1) << i
            state = scan((word >> i) & 1, state, layers)
        assert state == 0
        rows.add(row)
    return rows


def bad(word, width):
    states = []
    for initial in range(16):
        state = initial
        for i in range(width):
            state = scan((word >> i) & 1, state, 2)
        if state:
            states.append(initial)
    return states


def extra_bits(rows, width, common):
    trials = []
    for extra in range(width-common+1):
        size = common + extra
        prefixes = {row >> (width-size) for row in rows}
        failures = sum(bool(bad(word,size)) for word in prefixes)
        trials.append([extra,len(prefixes),failures])
        if not failures:
            break
    return trials


if __name__ == '__main__':
    first, n = block(PHASE,91,3)
    suffix, m = block(first,n,3)
    assert (n,m) == (68,17)
    forbidden = bad(suffix,m)
    # Prefix-only calculation on all eight joint layers; includes every entrance.
    states = set(range(4**8))
    for i in range(91-m):
        states = {scan((PHASE >> i) & 1, s, 8) for s in states}
    reachable = sorted({s >> 12 for s in states})
    assert set(forbidden).isdisjoint(reachable)
    full = outputs(PHASE,91,6)
    relaxed = outputs(first,n,3)
    assert {r >> (91-m) for r in full} == {r >> (n-m) for r in relaxed} == {suffix}
    print(json.dumps(dict(phase=hex(PHASE), cut=91-m, common_width=m,
                          common=hex(suffix), failing=forbidden, reachable=reachable,
                          full=extra_bits(full,91,m), middle_only=extra_bits(relaxed,n,m))))
