"""Exhaust the one-step pair shifts that can always supply the next eastern column."""
from collections import Counter, deque
from itertools import product


def letters(letter):
    return divmod(letter, 2)  # west column, observed gate


def compatible(x, y):
    a, b = letters(x)
    _, b1 = letters(y)
    return not b or b1 == 1-a


def trim(edges):
    """Discard edges with no extension to a bi-infinite temporal path."""
    while True:
        vertices = {x for x, _ in edges} & {y for _, y in edges}
        keep = frozenset((x, y) for x, y in edges if x in vertices and y in vertices)
        if keep == edges:
            return keep
        edges = keep


def lift(edges):
    """Return a shortest legal word that has no eastern lift, or None."""
    starts = sorted({x for x, _ in edges})
    pending = deque((x, 3, (x,)) for x in starts)
    visited = set()
    while pending:
        x, candidates, word = pending.popleft()
        if (x, candidates) in visited:
            continue
        visited.add((x, candidates))
        a, b = letters(x)
        for y in starts:
            if (x, y) not in edges:
                continue
            _, b1 = letters(y)
            choices = 0
            for c, c1 in product(range(2), repeat=2):
                if (candidates >> c & 1 and a ^ (b | c) == b1
                        and (2*b+c, 2*b1+c1) in edges):
                    choices |= 1 << c1
            if not choices:
                return word + (y,)
            pending.append((y, choices, word + (y,)))
    return None


def brute_lifts(word, edges):
    """Independent literal search over the complete hidden temporal column."""
    pairs = list(map(letters, word))
    for hidden in product(range(2), repeat=len(word)):
        if all((a ^ (b | hidden[i])) == b1 and (2*b+hidden[i], 2*b1+hidden[i+1]) in edges
               for i, ((a,b), (_,b1)) in enumerate(zip(pairs, pairs[1:]))):
            return True
    return False


def analyze():
    from sympy import Matrix, Poly, Rational
    base = [(x,y) for x,y in product(range(4),repeat=2) if compatible(x,y)]
    assert len(base) == 12
    graphs = {trim({edge for i,edge in enumerate(base) if mask >> i & 1})
              for mask in range(1 << len(base))}
    # Every possible unbounded entropy is carried by a nonempty graph.
    graphs.discard(frozenset())
    kept = Counter()
    misses = Counter()
    examples = []
    for edges in graphs:
        bad = lift(edges)
        if bad:
            assert not brute_lifts(bad,edges)
            misses[len(bad)] += 1
            continue
        m = Matrix(4,4,lambda i,j:int((i,j) in edges))
        polynomial = Poly(m.charpoly().as_expr())
        # Intervals isolate every real root with rational endpoints. Nonnegative
        # matrices have their spectral radius as their largest real eigenvalue.
        last = polynomial.intervals(eps=Rational(1,2**40))[-1][0]
        kept[str(last)] += 1
        examples.append(sorted(edges))
    print("distinct trimmed nonempty graphs",len(graphs))
    print("rejected by shortest forbidden length",sorted(misses.items()))
    print("closed under eastern lifts", sum(kept.values()),sorted(kept.items()))
    print("all east-closed graphs", sorted(examples))


if __name__=="__main__":
    analyze()
