"""Read, minimize and compare the full-factor and excursion automata for K52's Y.

Run: python3 gptM5_y_returns.py OUTPUT_DIRECTORY W40.dfa [W41.dfa ...]
Prints a compact summary; JSON files contain both exact all-length tables.
Macro (S,n) is 45 then n copies of 2; (L,n) is 4525 then n copies of 2.
The boundary machine observes the gap 4 which starts the next macro.
"""
import argparse
from collections import deque
from itertools import product
import json
from pathlib import Path


LETTERS = "245"


def minimize(rows, dead):
    """Moore refinement followed by canonical BFS numbering in alphabet order."""
    groups = [int(q != dead) for q in range(len(rows))]
    while True:
        ids = {}
        refined = []
        for q, row in enumerate(rows):
            signature = (groups[q], *(groups[r] for r in row))
            refined.append(ids.setdefault(signature, len(ids)))
        if len(ids) == len(set(groups)):
            break
        groups = refined
    cls = refined
    representatives = {v: q for q, v in enumerate(cls)}
    order = [cls[0]]
    ids = {order[0]: 0}
    result = []
    for state in order:
        targets = []
        for r in rows[representatives[state]]:
            c = cls[r]
            if c not in ids:
                ids[c] = len(order)
                order.append(c)
            targets.append(ids[c])
        result.append(targets)
    assert len(order) == len(representatives)
    for q, row in enumerate(rows):
        assert result[ids[cls[q]]] == [ids[cls[r]] for r in row]
    return result, ids[cls[dead]]


def read_gap(q, word, rows):
    for c in word:
        q = rows[q][LETTERS.index(c)]
    return q


def excursions(rows, dead):
    start = read_gap(0, '4', rows)
    assert start != dead
    nodes, intern = [start], {start: 0}
    maps = []
    max_silent = 0
    for q in nodes:
        # Explore every live non-4 path since a 4. A return to a state along
        # one such path would permit an infinite non-4 stream in the SCC.
        todo = [(q, '', frozenset({q}))]
        exits = {}
        while todo:
            now, prefix, seen = todo.pop()
            max_silent = max(max_silent, len(prefix))
            for c, r in zip(LETTERS, rows[now]):
                if r == dead:
                    continue
                if c != '4':
                    if r in seen:
                        raise ValueError('Y contains a cycle avoiding gap 4')
                    todo.append((r, prefix + c, seen | {r}))
                    continue
                # Content between consecutive 4s. The leading gap 4 has
                # already been consumed and the following one has just landed.
                if prefix.startswith('525'):
                    kind, tail = 'L', prefix[3:]
                elif prefix.startswith('5'):
                    kind, tail = 'S', prefix[1:]
                else:
                    raise ValueError(f'unexpected first return 4{prefix}4')
                assert all(c == '2' for c in tail)
                event = (kind, len(tail))
                assert event not in exits
                if r not in intern:
                    intern[r] = len(nodes)
                    nodes.append(r)
                exits[event] = intern[r]
        maps.append(exits)
    alphabet = sorted(set().union(*(x.keys() for x in maps)))
    sink = len(nodes)
    full = [[row.get(a, sink) for a in alphabet] for row in maps]
    full.append([sink] * len(alphabet))
    out, dead = minimize(full, sink)
    return alphabet, out, dead, max_silent


def comparable(rows1, d1, rows2, d2):
    """Shortest word on which a pair of complete gap DFAs accepts on left only."""
    start = (0, 0)
    prev = {start: None}
    todo = deque([start])
    while todo:
        v = todo.popleft()
        a, b = v
        if a != d1 and b == d2:
            w = []
            while prev[v] is not None:
                v, c = prev[v]
                w.append(c)
            return ''.join(reversed(w))
        for c, x, y in zip(LETTERS, rows1[a], rows2[b]):
            if x != d1 and (x, y) not in prev:
                prev[x, y] = (v, c)
                todo.append((x, y))
    return None


def macro_rules(letters, rows, dead):
    """Exact possible separators by neighbouring excursion types; test if freely composable."""
    kinds = [{a[0] for a, v in zip(letters, row) if v != dead} for row in rows]
    allowed = {(a, b): set() for a, b in product('SL', repeat=2)}
    for transitions in rows:
        for (kind, n), nxt in zip(letters, transitions):
            for kind2 in kinds[nxt]:
                allowed[kind, kind2].add(n)

    # BFS over actual residual state after consuming the leading 4, and
    # the kind of block just promised by the unrestricted one-spacing model.
    nxt_index = {a: i for i, a in enumerate(letters)}
    todo = deque((0, kind, []) for kind in sorted(kinds[0]))
    seen = {(q, kind) for q, kind, _ in todo}
    counter = None
    while todo and counter is None:
        q, kind, history = todo.popleft()
        for following in 'SL':
            for n in sorted(allowed[kind, following]):
                r = rows[q][nxt_index[kind, n]]
                if following not in kinds[r]:
                    counter = history + [(kind, n), (following, None)]
                    break
                if (r, following) not in seen:
                    seen.add((r, following))
                    todo.append((r, following, history + [(kind, n)]))
            if counter is not None:
                break
    return {a+b: sorted(ns) for (a,b),ns in allowed.items()}, counter


def inspect(path, out):
    with path.open() as f:
        magic, width, count, kicks = f.readline().split()
        assert magic == 'Y1'
        rows = [list(map(int, line.split())) for line in f]
    assert len(rows) == int(count) and all(len(row) == 3 for row in rows)
    rows, d = minimize(rows, 1)
    macro, boundary, md, silent = excursions(rows, d)
    pairs, counter = macro_rules(macro, boundary, md)
    # Consecutive 2s are unambiguously measured as gap symbols.
    q, stretch, seen = 0, 0, set()
    while rows[q][0] != d:
        assert q not in seen, "2-only cycle"
        seen.add(q)
        stretch += 1
        q = rows[q][0]

    # Word counts start at any kick. Distinct words are counted by their DFA path.
    counts, active = [1], {0: 1}
    for _ in range(16):
        new = {}
        for q, m in active.items():
            for t in rows[q]:
                if t != d:
                    new[t] = new.get(t, 0) + m
        active = new
        counts.append(sum(new.values()))
    summary = dict(width=int(width), kicks=int(kicks), full_subsets=int(count), gap_states=len(rows),
                   excursion_states=len(boundary), gap_words_length_16=counts[16], longest_run_of_2=stretch,
                   max_consecutive_non4_after_4=silent, pair_runs=pairs, pair_only_counterexample=counter)
    payload = dict(**summary, gap_alphabet=list(LETTERS), gap_rows=rows, gap_dead=d,
                   excursion_alphabet=macro, excursion_rows=boundary, excursion_dead=md)
    (out / f'Y{width}.json').write_text(json.dumps(payload, separators=(',', ':')) + '\n')
    print(json.dumps(summary, separators=(',', ':')), flush=True)
    return int(width), rows, d


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('files', type=Path, nargs='+')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    machines = [inspect(path, args.output) for path in args.files]
    for (a, x, dx), (b, y, dy) in zip(machines, machines[1:]):
        missing = comparable(x, dx, y, dy)
        addition = comparable(y, dy, x, dx)
        print(json.dumps(dict(lower=a, upper=b, lower_only=missing, upper_only=addition)), flush=True)
        assert a < b and addition is None, 'higher-width factor failed projection'


if __name__ == '__main__':
    main()
