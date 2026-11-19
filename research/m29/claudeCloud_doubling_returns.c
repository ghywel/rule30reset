// claudeCloud_doubling_returns.c: every doubling white excursion of source period P that returns to white within
// CAP wheels, exhaustively (pull M29; K7). A control list for the cyclic-part method of M44 B.
//
// As claudeCloud_doubling_census.c (K4), with one change of stopping rule: an excursion is followed to its next
// white or to CAP wheels whatever its resets, so every return at a gap up to CAP is recorded, with the ticks that
// reach it reset-free. One Lyndon word per rotation class of odd-weight sources of least period P, one lift (the
// other lift is the same orbit shifted by P ticks). D_1 is antiperiodic at P, D_2 is all black, and every later
// wheel is the unique 2P-periodic child of the two before it.
// usage: claudeCloud_doubling_returns PMIN PMAX CAP     (P <= 32; one JSON object per P on stdout)
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static int Q;
static uint64_t M;

static inline int bit(uint64_t w, int t) { return (w >> t) & 1; }

static uint64_t child(uint64_t a, uint64_t b) {
    int t0 = __builtin_ctzll(b);
    int t = t0 + 1 == Q ? 0 : t0 + 1;
    int ct = !bit(a, t0);
    uint64_t c = (uint64_t)ct << t;
    for (int k = 1; k < Q; k++) {
        int nt = t + 1 == Q ? 0 : t + 1;
        ct = bit(a, t) ^ (bit(b, t) | ct);
        c |= (uint64_t)ct << nt;
        t = nt;
    }
    return c;
}

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: PMIN PMAX CAP\n"); return 2; }
    int pmin = atoi(argv[1]), pmax = atoi(argv[2]);
    long cap = atol(argv[3]);
    for (int P = pmin; P <= pmax; P++) {
        Q = 2 * P;
        M = (Q == 64) ? ~0ULL : ((1ULL << Q) - 1);
        long classes = 0, returned = 0;
        printf("{\"P\": %d, \"Q\": %d, \"cap\": %ld, \"returns\": [", P, Q, cap);
        int a[40] = {0};
        int n = P, i, p = 1;
        for (;;) {
            if (p == n) {
                uint64_t w = 0;
                int wt = 0;
                for (int t = 0; t < n; t++) { w |= (uint64_t)a[t + 1] << t; wt += a[t + 1]; }
                if (wt & 1) {
                    classes++;
                    uint64_t bw = 0;
                    for (int t = 0; t < Q; t++) bw |= (uint64_t)bit(w, t % P) << t;
                    uint64_t d1 = 0;
                    int x = 0;
                    for (int t = 0; t < Q; t++) { d1 |= (uint64_t)x << t; x ^= bit(bw, t); }
                    uint64_t W = M, R1 = 0, R2 = 0, R0 = 0, res = 0, prev2 = 0, prev1 = 0, c;
                    long j, gap = 0;
                    for (j = 1; j <= cap; j++) {
                        if (j == 1) c = d1;
                        else if (j == 2) c = M;
                        else c = child(prev2, prev1);
                        uint64_t white = ~c & M;
                        res |= R1 & white;
                        uint64_t nR1 = c & (W | R0), nR2 = c & R1, nR0 = c & R2;
                        W = white; R1 = nR1; R2 = nR2; R0 = nR0;
                        if (c == 0) { gap = j; break; }
                        prev2 = prev1; prev1 = c;
                    }
                    if (gap) {
                        printf("%s{\"word\": \"", returned ? ", " : "");
                        for (int t = 0; t < P; t++) putchar('0' + bit(w, t));
                        printf("\", \"gap\": %ld, \"reset_free_ticks\": %d}", gap, __builtin_popcountll(~res & M));
                        returned++;
                    }
                }
            }
            i = n;
            while (i >= 1 && a[i] == 1) i--;
            if (i == 0) break;
            a[i]++;
            for (int k = i + 1; k <= n; k++) a[k] = a[k - i];
            p = i;
        }
        printf("], \"classes\": %ld, \"returned\": %ld}\n", classes, returned);
        fflush(stdout);
    }
    return 0;
}
