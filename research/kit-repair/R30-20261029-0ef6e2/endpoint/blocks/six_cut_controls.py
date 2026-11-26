"""Check all pairs of cuts at three all-six scales, then test the sharpness construction.

A cut's lag-q crossing pattern is constant from each phase event -t*alpha
(inclusive) to the next event (exclusive). An arc mismatch is the XOR of
the two cut crossings. Integers index the events and pack the mismatch sets.
"""
from math import isqrt


def floor_multiple(n, digit=6):
    """Exact floor of n times the positive root of x² + digit*x = 1."""
    if n < 0:
        return -floor_multiple(-n, digit)-1
    return (isqrt((digit*digit+4)*n*n)-digit*n)//2


def cut_masks(q, p, width):
    scale = 1 << 52
    def phase_key(t):
        return floor_multiple(-t*scale)-scale*floor_multiple(-t)
    events = sorted(range(width+q), key=phase_key)
    assert len({phase_key(t) for t in events}) == len(events)
    assert events[0] == 0
    mask = sum(1 << t for t in range(width)
               if floor_multiple(t+q)-floor_multiple(t) != p)
    masks = {mask: 0}
    for t in events[1:]:
        if t < width:
            mask ^= 1 << t
        if t >= q:
            mask ^= 1 << (t-q)
        masks.setdefault(mask, t)
    return masks


def failures(mask, q, extra):
    start = 0
    failed = []
    for _ in range(3):
        remaining = mask >> start
        if not remaining:
            break
        first = (remaining & -remaining).bit_length()-1+start
        if first >= 2*start+q+extra:
            break
        failed.append(first)
        start = first+1
    return failed


def check(p, q):
    Q = 6*q+p
    certified = (Q-1)//6-q
    max_extra = q//2+2
    width = 7*(q+max_extra)
    masks = cut_masks(q,p,width)
    options = list(masks)
    def counterexample(extra):
        for j,m in enumerate(options):
            for n in options[:j]:
                bad = failures(m ^ n,q,extra)
                if len(bad) == 3:
                    return masks[m],masks[n],bad
        return None
    low, high = certified,max_extra
    assert counterexample(low) is None and counterexample(high) is not None
    while high-low > 1:
        middle = (low+high)//2
        if counterexample(middle) is None:
            low = middle
        else:
            high = middle
    x,y,bad = counterexample(high)
    # Direct membership for the two actual phases at the reported endpoints.
    # Normalizing the difference by an integer gives arc indicators up to a fixed offset.
    def indicator(n):
        return floor_multiple(n-x)-floor_multiple(n-y)
    physical = sum(1 << n for n in range(width) if indicator(n+q) != indicator(n))
    assert failures(physical,q,high) == bad
    print(f"q={q}, Q={Q}, cut masks={len(masks)}, certified E={certified}, "
          f"last universal E={low}, first failure E={high} at cuts -({x},{y})*alpha, mismatches={bad}")


def check_construction():
    checked = 0
    for digit in range(3, 10):
        p, q = 1, digit
        for _ in range(3):
            P, Q = q, digit*q+p
            for H in sorted({0, 1, q//8}):
                extra = max(0, (Q+5)//6-H-q)
                S = q+extra
                if not 3*(H+S) <= Q <= 6*(H+S):
                    continue
                u, v = 2*H+S-1, 4*H+3*S-1
                z = u+Q
                # The phase at u is -(delta+Delta)/2 and at v it is -delta/2.
                # For each cut below, twice its offset is k*alpha+c.
                offsets = [(-2*u-q-Q, p+P), (-2*v-q, p)]
                for (k,c), expected in zip(offsets, ([u,z], [v])):
                    def level(t):
                        return (floor_multiple(2*t+k, digit)+c)//2
                    hits = [t for t in range(H,z+1) if level(t+q)-level(t) != p]
                    assert hits == expected, (digit,q,H,extra,hits,expected)
                assert u < 2*H+S and v < 2*(u+1)+S and z < 2*(v+1)+S
                checked += 1
            p, q = q, Q
    print(f"Explicit two-cut construction: {checked} cases passed (digits 3 through 9).")


if __name__ == "__main__":
    for p,q in [(1,6),(6,37),(37,228)]:
        check(p,q)
    check_construction()
