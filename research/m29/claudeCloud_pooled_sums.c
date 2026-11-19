// claudeCloud_pooled_sums.c: a reader's control for C1, the pooled first-return bound (I3, I5; K9).
// For each clock Q, every nonzero pointed Q-bit word c once as the first child after a white wheel: D_0 = 0, D_1 = c,
// D_2 all black, and each later wheel the unique Q-periodic child of the two before it, to the first white wheel g(c).
// Prints the exact sum of g(c), the bound N^2 - 1 with N = 2^Q, their difference, and the largest gap.
// usage: claudeCloud_pooled_sums QMIN QMAX
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
static int Q; static uint64_t M;
static inline int bit(uint64_t w, int t) { return (w >> t) & 1; }
static uint64_t child(uint64_t a, uint64_t b) {
    int t0 = __builtin_ctzll(b), t = t0 + 1 == Q ? 0 : t0 + 1, ct = !bit(a, t0);
    uint64_t c = (uint64_t)ct << t;
    for (int k = 1; k < Q; k++) { int nt = t + 1 == Q ? 0 : t + 1; ct = bit(a, t) ^ (bit(b, t) | ct); c |= (uint64_t)ct << nt; t = nt; }
    return c;
}
int main(int argc, char **argv) {
    int q0 = atoi(argv[1]), q1 = atoi(argv[2]);
    for (Q = q0; Q <= q1; Q++) {
        M = (1ULL << Q) - 1;
        unsigned long long sum = 0, maxg = 0;
        for (uint64_t c = 1; c <= M; c++) {
            uint64_t p2 = 0, p1 = c, d; unsigned long long g = 1;
            for (;;) { g++; d = (g == 2) ? M : child(p2, p1); if (d == 0) break; p2 = p1; p1 = d; }
            sum += g; if (g > maxg) maxg = g;
        }
        unsigned long long N = 1ULL << Q, cap = N * N - 1;
        printf("Q=%2d words %llu sum %llu bound %llu deficit %llu (%.4f%%) mean/2^Q %.5f max gap %llu (%.2f x 2^Q)\n",
               Q, N - 1, sum, cap, cap - sum, 100.0 * (cap - sum) / cap, (double)sum / (N - 1) / N, maxg, (double)maxg / N);
        fflush(stdout);
    }
    return 0;
}
