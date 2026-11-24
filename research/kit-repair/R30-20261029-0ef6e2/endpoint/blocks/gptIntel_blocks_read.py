"""N15 carrying control: exact quadratic cuts, full weighted repeats and real translates."""

import sys
from bisect import bisect_right
from collections import Counter
from itertools import accumulate
from math import isqrt
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from gptIntel_scale_read import scales


def check_slope(D, a, b, counts):
    """The slope is (a + b sqrt(D))/2. All arc coordinates have denominator 12."""
    def floor(A, B):
        root = isqrt(B * B * D)
        return (A + (root if B >= 0 else -root - 1)) // 12

    def g(n):
        return floor(6 * n * a, 6 * n * b)

    sequence = scales(g, 1200)
    horizon = max(r + 2*d for (_, r), (_, d) in sequence) + 1
    cuts = [(6, 0), (4, 0), (1, 1)] + [(6*j*a, 6*j*b) for j in (1, -11, 7)]
    for p0, p1 in cuts:
        p = p0 - 12 * floor(p0, p1)
        for endpoint in (False, True):
            sign = 1 if endpoint else -1

            def at(t):
                A, B = 6*t*a + endpoint*p, 6*t*b + endpoint*p1
                # Compare the actual fractional part with gamma, including equality.
                return floor(A - 12*floor(A, B) - p, B - p1) < 0

            def f(t):
                return floor(6*t*a + sign*p, 6*t*b + sign*p1)

            letters = [at(t) for t in range(horizon)]
            assert all(v == (f(t) - g(t) == sign) for t, v in enumerate(letters))
            for lengths in ((3, 17), (18, 23), (41, 1)):
                blocks = tuple(bytes((5*j + j//3 + i) % 2 for j in range(w))
                               for i, w in enumerate(lengths))
                T = list(accumulate((len(blocks[v]) for v in letters), initial=0))
                stream = b"".join(blocks[v] for v in letters)
                for shift in (-19, -3, 0, 2, 17):
                    k = abs(shift)
                    q = k + shift
                    moved = [at(shift+n) for n in range(k+17)]
                    assert moved[k:] == letters[q:q+17]
                    moved_stream = b"".join(blocks[v] for v in moved)
                    skip = sum(len(blocks[v]) for v in moved[:k])
                    assert moved_stream[skip:] == stream[T[q]:T[q+17]]
                    counts['real shift checks'] += 1

                past = []
                M = max(lengths)
                for (_, r), (u, d) in sequence:
                    failures = [t for t in range(1, r+d) if f(t+d)-f(t) != u]
                    assert len(failures) <= 1
                    m = failures[0] if failures and failures[0] < d else None
                    delta = None if m is None else T[r] - 2*T[m]
                    if m is not None:
                        assert all(letters[t] == letters[t+d] for t in range(1, r+d) if t != m)
                        if m+d <= r:
                            assert 2*T[m] <= T[r] + M
                        if m < r:
                            for end in (m+1, r, r+d):
                                assert T[end+d]-T[m+1+d] == T[end]-T[m+1]
                    if len(past) >= 2 and m is not None:
                        r0, d0, m0, delta0 = past[-2]
                        r1, d1, m1, _ = past[-1]
                        if (m0 is not None and m1 is not None and m0 < r0 and m1 < r1
                                and r1 == r0+2*d0 and r == r1+2*d1):
                            assert delta0 == delta
                            counts['two-step equalities'] += 1
                    past.append((r, d, m, delta))

                    for H in (0, 2, 7):
                        if H+1 > d or H > r:
                            continue
                        if m is None:
                            i, end, K = H+1, d, 4*M*(H+1)
                        elif m < r:
                            i, end, K = m+1+H, r+d, max(0, -delta)+2*M+2*M*H
                        else:
                            continue
                        j = i+d
                        assert T[j] <= T[end]-T[i]+K
                        assert stream[T[i]:T[end]] == stream[T[j]:T[end+d]]
                        counts['full matched bits'] += T[end]-T[i]
                        counts['full repeat comparisons'] += 1
                        q = min(i-1, H)
                        for offset in {0, max(0, T[j]-T[q]-K-1)}:
                            if offset+K >= T[j]-T[q]:
                                continue
                            loc = bisect_right(T, T[i]+offset)-1
                            assert i <= loc < end
                            assert T[i]+offset-T[loc] == T[j]+offset-T[loc+d]
                            assert stream[T[i]+offset] == stream[T[j]+offset]
                            counts['tail/inside checks'] += 1


if __name__ == '__main__':
    counts = Counter()
    for slope in ((2, 0, 1), (2, 0, -1), (5, -1, 1), (13, 1, 1), (13, -1, -1)):
        check_slope(*slope, counts)
    print(dict(counts))
