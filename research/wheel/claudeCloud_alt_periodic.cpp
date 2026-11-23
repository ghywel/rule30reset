// claudeCloud_alt_periodic.cpp: every Rule 30 pattern that is periodic in time and in space and has an alternating
// column, for a given time period (ledger K79, addendum 1).
//
// Rule 30: new(x) = left xor (centre or right). So a pair of neighbouring columns (a, b) = (column j, column j + 1),
// each given on a time circle of N ticks, determines column j - 1:
//     left(t) = a(t + 1) xor (a(t) or b(t)).
// PHI(a, b) = (left, a) is a map on the 4^N pairs. If every column of a pattern has time period N, the pattern is
// periodic in space exactly when its pairs lie on a cycle of PHI, and any pattern on a right half-plane whose
// columns all have time period N is of this kind (an endless backward orbit of a map on a finite set stays on a
// cycle). So the patterns with time period dividing N that contain the alternating column ALT (black at odd ticks)
// are exactly the columns b for which (ALT, b) returns to itself under PHI. This program tries every b.
//
//   g++ -O3 -std=c++17 claudeCloud_alt_periodic.cpp -o alt_periodic
//   alt_periodic N [CAP]      N even, 2..30; CAP = steps allowed per start (default 2^33)
// One line per solution: the column beside the alternating one (tick 0 first; even ticks are the samples), its gate
// (the even ticks), the period in space, and the least time period of the whole pattern.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
typedef uint64_t u64;

static int N;
static u64 MASK;
static inline u64 ror1(u64 a) { return ((a >> 1) | (a << (N - 1))) & MASK; }     // bit t <- bit t + 1
static inline void phi(u64 &a, u64 &b) { u64 left = ror1(a) ^ (a | b); b = a; a = left; }

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: alt_periodic N [CAP]\n"); return 1; }
    N = atoi(argv[1]);
    if (N < 2 || N > 30 || (N & 1)) { fprintf(stderr, "N must be even, 2..30\n"); return 1; }
    u64 CAP = argc > 2 ? strtoull(argv[2], nullptr, 10) : (1ULL << 33);
    MASK = (1ULL << N) - 1;
    u64 ALT = 0; for (int t = 1; t < N; t += 2) ALT |= 1ULL << t;
    u64 solutions = 0, capped = 0, longestTail = 0, longestCycle = 0;
    for (u64 b0 = 0; b0 <= MASK; ++b0) {
        // Brent: cycle length lambda of the orbit of (ALT, b0)
        u64 ta = ALT, tb = b0, ha = ALT, hb = b0; phi(ha, hb);
        u64 power = 1, lambda = 1, steps = 1; bool ok = true;
        while (ta != ha || tb != hb) {
            if (power == lambda) { ta = ha; tb = hb; power <<= 1; lambda = 0; }
            phi(ha, hb); ++lambda;
            if (++steps > CAP) { ok = false; break; }
        }
        if (!ok) { ++capped; continue; }
        // on the cycle exactly when lambda steps from the start return to it
        u64 a = ALT, b = b0;
        for (u64 i = 0; i < lambda; ++i) phi(a, b);
        if (lambda > longestCycle) longestCycle = lambda;
        if (a != ALT || b != b0) {
            // tail length, for the record of how long the search had to run
            u64 xa = ALT, xb = b0, ya = a, yb = b, mu = 0;
            while (xa != ya || xb != yb) { phi(xa, xb); phi(ya, yb); ++mu; }
            if (mu > longestTail) longestTail = mu;
            continue;
        }
        ++solutions;
        // least time period of the whole pattern: the least even d dividing N with every column d-periodic
        int least = N;
        for (int d = 2; d < N; d += 2) {
            if (N % d) continue;
            bool all = true; a = ALT; b = b0;
            for (u64 i = 0; i < lambda && all; ++i) {
                for (int t = 0; t < N && all; ++t) if (((b >> t) & 1) != ((b >> ((t + d) % N)) & 1)) all = false;
                phi(a, b);
            }
            if (all) { least = d; break; }
        }
        printf("N %d column ", N);
        for (int t = 0; t < N; ++t) putchar('0' + int((b0 >> t) & 1));
        printf(" gate ");
        for (int t = 0; t < N; t += 2) putchar('0' + int((b0 >> t) & 1));
        printf(" space %llu time %d\n", (unsigned long long)lambda, least);
    }
    printf("N %d: %llu columns tried, %llu solutions, %llu not decided within the cap; longest tail %llu, longest cycle met %llu\n",
           N, (unsigned long long)(MASK + 1), (unsigned long long)solutions, (unsigned long long)capped,
           (unsigned long long)longestTail, (unsigned long long)longestCycle);
    return 0;
}
