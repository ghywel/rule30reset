"""Independent reverse-state check of M32–34, and sequential one-layer reset schedules."""
from bisect import bisect_left
from functools import cache
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "r2"))
from twin_past import C20, edge_step, scan, step
from gptM5_three_tick import aged, failure, grow


class ReverseScan:
    """Decision tree on entrance pairs, shared between identical subtrees. 0/1 are leaves."""
    def __init__(self):
        self.nodes = [None, None]

    @cache
    def node(self, children):
        if all(x == 0 for x in children):
            return 0
        if all(x == 1 for x in children):
            return 1
        self.nodes.append(children)
        return len(self.nodes) - 1

    def target(self, k):
        root = 1
        for _ in range(k):
            root = self.node((root, 0, 0, 0))
        return root

    @cache
    def back(self, root, bit):
        if root < 2:
            return root
        choices = self.nodes[root]
        children = []
        for prev, cur in ((0, 0), (0, 1), (1, 0), (1, 1)):
            q = 2*cur + (bit ^ (prev | cur))
            children.append(self.back(choices[q], cur))
        return self.node(tuple(children))

    def start(self, word, depth):
        root = self.target(depth)
        for bit in format(word, 'b'):
            root = self.back(root, int(bit))
        return root

    def accepts(self, root, register):
        while root >= 2:
            root = self.nodes[root][register & 3]
            register >>= 2
        return root == 1

    def failed_words(self, words, width, depth):
        ordered = sorted(words)

        def count(prefix, length, lo, hi, root):
            if root == 1 or lo == hi:
                return 0
            if root == 0 or length == width:
                return hi - lo
            pivot = (2*prefix + 1) << (width-length-1)
            cut = bisect_left(ordered, pivot, lo, hi)
            return (count(2*prefix, length+1, lo, cut, self.back(root, 0))
                    + count(2*prefix+1, length+1, cut, hi, self.back(root, 1)))

        return count(1, 1, 0, len(ordered), self.back(self.target(depth), 1))


def cycle(width):
    # Highest bit is the moving edge. Reverse the kit's starting odd value 1.
    word = 1 << (width-1)
    seen = set()
    while word not in seen:
        seen.add(word)
        word = edge_step(word)
    periodic = set()
    while word not in periodic:
        periodic.add(word)
        word = edge_step(word)
    return periodic


def controls(scanner):
    for k in (1, 2, 3):
        for p in range(1, 128):
            root = scanner.start(p, k)
            for r in range(4**k):
                s = r
                for i in range(p.bit_length()):
                    s = scan((p >> i) & 1, s, k)
                assert scanner.accepts(root, r) == (s == 0)


def check_covers(scanner, kind, receipts):
    if kind == 'seed':
        words = set(range(128, 256))
        for _ in range(2):
            words = {edge_step(p) for p in words}
        age, width = 2, 8
    else:
        words = set(C20)
        age, width = 26, 20
    plan = {}
    for k in ((5, 6) if kind == 'seed' else (5, 6, 7, 8)):
        rows = json.loads((receipts / f'ck-{kind}-k{k}').read_text())['rows']
        for r in rows:
            plan.setdefault(r['age'], []).append((k, r))
    out = []
    for t in range(age, max(plan)+1):
        for k, reported in plan.get(t, []):
            count = scanner.failed_words(words, width, k)
            assert (len(words), width, count) == (reported['words'], reported['width'], reported['failing_words'])
            if kind == 'seed' and count == 0:
                assert all(failure(aged(y,t), k) is None for y in range(1,128))
            out.append([t, k, len(words), count])
        if t != max(plan):
            words = grow(words)
            width += 1
    return out


def greedy(word, mode):
    # Input order is wall to edge. Carry the common parent suffix only.
    bits = [int(x) for x in reversed(format(word, 'b'))]
    layers = 0
    while len(bits) >= 2:
        states = set(range(4))
        first = None
        parent = []
        # positions of actual recognized reset factors 0 1^(3m+1) 0 b
        z = -1
        pending = False
        for j, b in enumerate(bits):
            states = {2*(s & 1) + (b ^ int(s != 0)) for s in states}
            if first is None and ((mode == 'pair' and len(states) == 1) or
                                  (mode == 'run' and pending)):
                first = j
                assert len(states) == 1
            if first is not None:
                parent.append(next(iter(states)) >> 1)  # P(j) after reading b(j)
            pending = b == 0 and z >= 0 and (j-z-1) % 3 == 1
            if b == 0:
                z = j
        if states != {0} or first is None:
            break
        assert len(parent) < len(bits)
        layers += 1
        bits = parent
    return layers


def strip(scanner, receipts):
    capacity = json.loads((receipts/'strip-all').read_text())['by_width']
    times = json.loads((receipts/'convergence-128').read_text())['g']
    band = set(C20)
    rows = []
    for w in range(20, 129):
        cyc = cycle(w)
        t, current = w+6, band
        while not current <= cyc:
            current = {edge_step(p) for p in current}
            t += 1
            assert t <= 2000
        assert t == times[str(w)]['g']
        # Projection from width w+1 preserves the eventual orbit from the seed.
        k = capacity[str(w)]['K']
        assert scanner.failed_words(cyc, w, k) == 0
        assert scanner.failed_words(cyc, w, k+1) > 0
        assert len(cyc) == capacity[str(w)]['cycle_words']
        rows.append([w, k, t, min(greedy(p,'pair') for p in cyc),
                     min(greedy(p,'run') for p in cyc)])
        if w < 128:
            band = grow(band)
    return rows


if __name__ == '__main__':
    receipts = Path(sys.argv[1])
    scanner = ReverseScan()
    controls(scanner)
    print(json.dumps({'early_two': [w for w in range(1,20)
                                     if scanner.failed_words(cycle(w),w,2) == 0]}), flush=True)
    for kind in ('s1','seed'):
        print(json.dumps({kind:check_covers(scanner, kind, receipts)}), flush=True)
    print(json.dumps({'strip':strip(scanner, receipts)}), flush=True)
