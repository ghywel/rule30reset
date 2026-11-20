// claudeCloud_resolution_ticks.c: for every doubled excursion of source period P, the wheel at which each tick's row
// first closes a reset word (pull K5, the resolution law; ledger K29). The excursions and the reset rule are those of
// claudeCloud_doubling_census.c (K4, K5), which recorded only each excursion's last such wheel. Here every tick is
// counted, so that the whole distribution can be set against the chance model of claudeCloud_row_chain.py.
//
// One Lyndon word per rotation class of odd-weight sources of least period P; the 2P ticks of its excursion are 2P
// different rows. hist[j] counts the rows whose first reset word closes at wheel j.
// usage: claudeCloud_resolution_ticks PMIN PMAX CAP [LATE]   (P <= 32; one JSON object per P on stdout;
//        with LATE, every source with a row first caught at wheel LATE or later is listed on stderr)
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

#define HMAX 1024
static long hist[HMAX + 1];

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: PMIN PMAX CAP\n"); return 2; }
    int pmin = atoi(argv[1]), pmax = atoi(argv[2]);
    long cap = atol(argv[3]);
    long late = argc > 4 ? atol(argv[4]) : 0;
    for (int P = pmin; P <= pmax; P++) {
        Q = 2 * P;
        M = (Q == 64) ? ~0ULL : ((1ULL << Q) - 1);
        for (int i = 0; i <= HMAX; i++) hist[i] = 0;
        long classes = 0, never = 0;
        int a[40] = {0};
        int n = P, i = 1, p = 1;
        for (;;) {
            if (p == n) {
                uint64_t w = 0;
                int wt = 0;
                for (int t = 0; t < n; t++) { w |= (uint64_t)a[t + 1] << t; wt += a[t + 1]; }
                if (wt & 1) {
                    classes++;
                    uint64_t d1 = 0;
                    int x = 0;
                    for (int t = 0; t < Q; t++) { d1 |= (uint64_t)x << t; x ^= bit(w, t % P); }
                    uint64_t W = M, R1 = 0, R2 = 0, R0 = 0, res = 0, prev2 = 0, prev1 = 0, c;
                    long j;
                    for (j = 1; j <= cap; j++) {
                        if (j == 1) c = d1;
                        else if (j == 2) c = M;
                        else c = child(prev2, prev1);
                        uint64_t white = ~c & M;
                        uint64_t newly = R1 & white & ~res;
                        if (newly) { hist[j < HMAX ? j : HMAX] += __builtin_popcountll(newly); res |= newly; }
                        uint64_t nR1 = c & (W | R0), nR2 = c & R1, nR0 = c & R2;
                        W = white; R1 = nR1; R2 = nR2; R0 = nR0;
                        if (c == 0 || res == M) break;
                        prev2 = prev1; prev1 = c;
                    }
                    never += __builtin_popcountll(~res & M);
                    if (late && j >= late) {
                        fprintf(stderr, "P=%d last=%ld weight=%d word=", P, j, wt);
                        for (int t = 0; t < P; t++) fputc('0' + bit(w, t), stderr);
                        fputc('\n', stderr);
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
        printf("{\"P\": %d, \"classes\": %ld, \"rows\": %ld, \"never_caught\": %ld, \"hist\": [", P, classes, classes * Q, never);
        int last = 0;
        for (int k = 0; k <= HMAX; k++) if (hist[k]) last = k;
        for (int k = 0; k <= last; k++) printf("%s%ld", k ? ", " : "", hist[k]);
        printf("]}\n");
        fflush(stdout);
    }
    return 0;
}
