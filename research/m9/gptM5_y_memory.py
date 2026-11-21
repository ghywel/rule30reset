"""Decide finite memory for each complete Y excursion language computed by gptM5_y_returns.py.

A pair tracks a readable prefix and that prefix with the first symbol removed. A final
symbol rejected only by the former completes a minimal forbidden word. Restrict to
pairs with a path to such a symbol, then look for a cycle; without one compute the
longest possible minimal forbidden word by the exact longest path on the resulting DAG.
"""
from collections import deque
import json
from pathlib import Path
import sys


def memory(path):
    data = json.loads(path.read_text())
    rows = data['excursion_rows']
    alphabet = data['excursion_alphabet']
    dead = data['excursion_dead']
    labels = [kind + str(n) for kind, n in alphabet]
    start = {(r, 0): j for j, r in enumerate(rows[0]) if r != dead and r != 0}
    parent = {s: (None, a) for s, a in start.items()}
    depth = {s: 1 for s in start}
    order = list(start)
    edges, reverse, terminal = {}, {}, {}
    for v in order:
        if len(order) > 100000:
            raise RuntimeError('100,000 pair cap; incomplete')
        p, s = v
        edges[v] = []
        for j, (r, t) in enumerate(zip(rows[p], rows[s])):
            if r == dead and t != dead:
                terminal.setdefault(v, j)
            if r == t or r == dead or t == dead:
                continue
            w = (r, t)
            edges[v].append((j, w))
            reverse.setdefault(w, []).append((j, v))
            if w not in parent:
                parent[w] = (v, j)
                depth[w] = depth[v] + 1
                order.append(w)
    future = {v: (a, None) for v, a in terminal.items()}
    distance = {v: 1 for v in terminal}
    queue = list(terminal)
    for v in queue:
        for a, u in reverse.get(v, ()):
            if u not in future:
                future[u] = (a, v)
                distance[u] = distance[v] + 1
                queue.append(u)

    def prefix(v):
        result = []
        while v is not None:
            v, a = parent[v]
            result.append(a)
        return result[::-1]

    def suffix(v):
        result = []
        while v is not None:
            a, v = future[v]
            result.append(a)
        return result

    def test(word):
        def run(ws):
            q = 0
            for a in ws:
                q = rows[q][a]
            return q
        assert run(word) == dead and run(word[:-1]) != dead and run(word[1:]) != dead

    def printword(ws):
        return [labels[j] for j in ws]

    report = dict(width=data['width'], reachable_pairs=len(parent), productive_pairs=len(future))

    # Single-symbol pumps give compact direct certificates, including every loop iteration.
    choice = None
    for v in future:
        for a, w in edges[v]:
            if v == w:
                key = (depth[v] + distance[v], a, v)
                if choice is None or key < choice:
                    choice = key
    if choice is not None:
        _, a, v = choice
        pre, cycle, end = prefix(v), [a], suffix(v)
    else:
        # Topologically peel; an unpeeled subgraph contains a nonempty loop.
        indegree = dict.fromkeys(future, 0)
        for v in future:
            for _, w in edges[v]:
                if w in future:
                    indegree[w] += 1
        todo = deque(v for v in future if not indegree[v])
        longest = {v: 1 for v in start if v in future}
        prev = {v: (None, a) for v, a in start.items() if v in future}
        while todo:
            v = todo.popleft()
            for a, w in edges[v]:
                if w not in future:
                    continue
                if longest.get(w, 0) < longest[v] + 1:
                    longest[w] = longest[v] + 1
                    prev[w] = (v, a)
                indegree[w] -= 1
                if not indegree[w]:
                    todo.append(w)
        remaining = {v for v in future if indegree[v]}
        if not remaining:
            if not terminal:
                return dict(**report, maximum_minimal_forbidden_length=0)
            v = max(terminal, key=lambda x: longest[x])
            rev = [terminal[v]]
            while v is not None:
                v, a = prev[v]
                rev.append(a)
            word = rev[::-1]
            test(word)
            return dict(**report, maximum_minimal_forbidden_length=len(word), example=printword(word))
        # Each unpeeled vertex has a predecessor in the unpeeled graph. A backward
        # walk therefore repeats even if it began strictly downstream of the cycle.
        v = min(remaining)
        since, backward = {}, []
        while v not in since:
            since[v] = len(backward)
            a, u = next((a, u) for a, u in reverse[v] if u in remaining)
            backward.append(a)
            v = u
        cycle = backward[since[v]:][::-1]
        pre, end = prefix(v), suffix(v)
    p, s = v
    for a in cycle:
        p, s = rows[p][a], rows[s][a]
    assert (p, s) == v
    for n in (0, 1, 2):
        test(pre + cycle*n + end)
    return dict(**report, prefix=printword(pre), pump=printword(cycle),
                suffix=printword(end), fixed_pair=v, unbounded_minimal_forbidden_lengths=True)


if __name__ == '__main__':
    for filename in sys.argv[1:]:
        print(json.dumps(memory(Path(filename)), separators=(',', ':')), flush=True)
