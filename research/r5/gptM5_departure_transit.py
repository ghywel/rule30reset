"""Time from the first site-1 mismatch to the closed 001 component at width 22.

Build only the forward closure of the two aligned ether cycles. After identifying
the closed component by SCC, discard it when searching for the first mismatch.
A longest-path calculation on the remaining transient vertices gives the bound.
"""
from collections import deque
import hashlib
import json

from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components

from claudeM5_r5_front import A001, DRIVE, ETHER, load, strip_step

WIDTH = 22
BASE = 1 << WIDTH


def ether_cycles():
    return sorted({tuple(sum(ETHER[(j0 + j) % 12][(s + p) % 3] << (j - 1)
                             for j in range(1, WIDTH + 1)) for p in range(3))
                   for j0, s in A001})


def adjacent(key):
    phase, row = divmod(key, BASE)
    offset = (phase + 1) % 3 * BASE
    return tuple(offset + strip_step(WIDTH, DRIVE[phase], b, row) for b in (0, 1))


def window_graph(cycles):
    pending = [p * BASE + row for seq in cycles for p, row in enumerate(seq)]
    graph = {}
    while pending:
        v = pending.pop()
        if v not in graph:
            graph[v] = adjacent(v)
            pending.extend(graph[v])
    vertices = sorted(graph)
    index = {v: i for i, v in enumerate(vertices)}
    neighbours = [index[u] for v in vertices for u in graph[v]]
    matrix = csr_matrix(([True] * len(neighbours), neighbours,
                         range(0, len(neighbours) + 1, 2)), shape=(len(vertices),) * 2)
    num, component = connected_components(matrix, directed=True, connection='strong')
    sinks = set(range(num))
    for i, v in enumerate(vertices):
        if any(component[index[u]] != component[i] for u in graph[v]):
            sinks.discard(component[i])
    assert len(sinks) == 1
    sink = sinks.pop()
    giant = {v for i, v in enumerate(vertices) if component[i] == sink}
    assert len(giant) == 123382
    return graph, giant


def analyse(seq, graph, giant):
    roots = {p * BASE + row for p, row in enumerate(seq)}
    seen = set(roots)
    queue = deque(sorted(roots))
    first = set()
    while queue:
        v = queue.popleft()
        phase, row = divmod(v, BASE)
        if (row ^ seq[phase]) & 1:
            first.add(v)
            continue
        for u in graph[v]:
            if u not in giant and u not in seen:
                seen.add(u)
                queue.append(u)

    # The exterior of the sink reachable after a mismatch has no directed cycle.
    # Detect a back edge explicitly; a reachable cycle would preclude the bound.
    depth = {}
    visiting = set()
    def remaining(v):
        if v in giant:
            return 0
        if v not in depth:
            assert v not in visiting and v not in roots
            visiting.add(v)
            depth[v] = 1 + max(remaining(u) for u in graph[v])
            visiting.remove(v)
        return depth[v]

    peak = max(map(remaining, first), default=0)
    extremal = sorted(v for v in first if depth[v] == peak)
    return {'first_mismatches_outside': len(first), 'max_ticks_to_giant': peak,
            'maximizers': extremal}


def measure_lift(width, seq, phase, giant, transient_count):
    """Allow every initial extension and both boundaries at every subsequent tick."""
    low_mask = BASE - 1
    def advance(words, p):
        dest = {strip_step(width, DRIVE[p], b, row) for row in words for b in (0, 1)}
        offset = ((p+1) % 3) * BASE
        return {row for row in dest if offset+(row & low_mask) not in giant}

    initial = {seq[phase] + high*BASE for high in range(1 << (width-WIDTH))}
    # Time zero is the last aligned 22-site word before departure. One can
    # start here because all extensions of that word are included initially.
    t = 1
    words = {row for row in advance(initial, phase)
             if row & low_mask != seq[(phase+1) % 3]}
    result = []
    while words:
        p = (phase+t) % 3
        off = {row for row in words if (row ^ seq[p]) & 1}
        if off:
            later = off
            lag = 0
            while later:
                later = advance(later, (p+lag) % 3)
                lag += 1
                assert lag <= transient_count
            result.append({'exit_phase': phase, 'departure_tick': t,
                           'possible_words': len(off), 'max_ticks_to_giant': lag})
        words = advance(words-off, p)
        t += 1
        assert t <= transient_count + 1
    return result


def replay(row, seq, phase, giant):
    """Scalar truth-table evolution of a finite half; site 1 is the low bit."""
    width = max(row.bit_length(), WIDTH) + 75
    cells = [(row >> j) & 1 for j in range(width)]
    departure = entry = first_exit = flag = None
    history = []
    for t in range(75):
        p = (phase+t) % 3
        word = sum(b << j for j, b in enumerate(cells[:WIDTH]))
        if first_exit is None and word != seq[p]:
            first_exit = t
        if t == 1:
            flag = cells[22]
        if departure is None and cells[0] != (seq[p] & 1):
            departure = t
        inside = p*BASE+word in giant
        if entry is None and inside:
            entry = t
        if departure is not None and (entry is None or t <= entry):
            history.append({'t': t, 'phase': p, 'word': word, 'in_giant': inside})
        if entry is not None and departure is not None:
            break
        padded = [DRIVE[p], *cells, 0]
        cells = [(30 >> (4*a + 2*b + c)) & 1 for a, b, c in zip(padded, padded[1:], padded[2:])]
    assert first_exit == 1 and departure == (52 if flag else 49)
    assert entry is not None
    return {'row_hex': hex(row), 'initial_phase': phase, 'site23_at_exit': flag,
            'departure': departure, 'first_giant_entry': entry, 'history': history}


def verify_component_from_trap(seed, graph, giant):
    """Verify the component by reachability in both directions from a kit state."""
    seen = {seed}
    stack = [seed]
    reverse = {}
    while stack:
        v = stack.pop()
        for u in graph[v]:
            reverse.setdefault(u, []).append(v)
            if u not in seen:
                seen.add(u)
                stack.append(u)
    assert seen == giant  # proves closure and paths from the seed to every word
    back = {seed}
    stack = [seed]
    while stack:
        for v in reverse[stack.pop()]:
            if v not in back:
                back.add(v)
                stack.append(v)
    assert back == seen


def local_controls(seq, giant):
    """All choices at sites 23 and 24, for each possible last aligned phase."""
    controls = []
    for p in range(3):
        for high in range(4):
            row = seq[p] + high*BASE
            if strip_step(24, DRIVE[p], 0, row) % BASE == seq[(p+1) % 3]:
                continue
            result = replay(row, seq, p, giant)
            expected = 52 if seq[0] == 2040306 or high & 2 else 49
            assert result['departure'] == expected
            controls.append({'phase': p, 'site23': high & 1, 'site24': high >> 1,
                             'first_departure': result['departure']})
    return controls


def main():
    cycles = ether_cycles()
    graph, giant = window_graph(cycles)
    trap = load('t001')
    projections = {(p % 3)*BASE+(r % BASE) for p,r in zip(trap['lab'],trap['st'],strict=True)}
    assert projections <= giant
    verify_component_from_trap(min(projections), graph, giant)
    results = []
    for seq, (phase, row) in zip(cycles, ((0,0xe2f2292481552df21f2), (1,0x7fffff33011e03e43e)), strict=True):
        rough = analyse(seq, graph, giant)
        lifts = {str(w): [record for p in range(3) for record in measure_lift(w, seq, p, giant, len(graph)-len(giant))]
                 for w in range(22,27)}
        assert max(r['max_ticks_to_giant'] for r in lifts['22']) == rough['max_ticks_to_giant']
        witness = replay(row, seq, phase, giant)
        sharp = max(r['max_ticks_to_giant'] for r in lifts['26'])
        assert witness['first_giant_entry'] - witness['departure'] == sharp
        results.append({'ether': seq, 'width22': rough, 'lifts': lifts,
                        'physical_sharp_delay': sharp, 'finite_witness': witness,
                        'local_controls': local_controls(seq, giant)})
    print(json.dumps({'width': WIDTH, 'reachable_from_either': len(graph), 'closed_size': len(giant),
                      'closed_sha256_u32le': hashlib.sha256(b''.join(
                          v.to_bytes(4, 'little') for v in sorted(giant))).hexdigest(),
                      'kit_t001_projected_words_inside': len(projections),
                      'alignments': results}, indent=2))


if __name__ == '__main__':
    main()
