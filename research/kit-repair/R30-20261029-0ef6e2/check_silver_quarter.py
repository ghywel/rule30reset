"""Finite controls for the first mismatch of the quarter-phase silver word."""

from math import isqrt


def rounded(t):
    """Return floor(t*sqrt(2) + 1/2) exactly for t >= 0."""
    return (isqrt(8 * t * t) + 1) // 2


def check():
    lag, even_displacement = 7, 10
    first, odd_numerator = 11, 31
    for s in range(65):
        assert even_displacement % 2 == 0 and odd_numerator % 2 == 1
        assert rounded(first - 1 + lag) - rounded(first - 1) == even_displacement
        assert rounded(first + lag) - rounded(first) == even_displacement - 1
        if s <= 6:
            for t in range(first):
                assert rounded(t + lag) - rounded(t) == even_displacement, (s, t)
            print(f"s={s}: lag {lag}, first mismatch {first}, prefix excess {first - 1 - lag}")
        lag, even_displacement = 3 * lag + 2 * even_displacement, 4 * lag + 3 * even_displacement
        first, odd_numerator = 3 * first + odd_numerator, 8 * first + 3 * odd_numerator
    print("Both flank differences verified through s=64.")


if __name__ == "__main__":
    check()
