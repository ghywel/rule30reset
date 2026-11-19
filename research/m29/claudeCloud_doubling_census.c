// claudeCloud_doubling_census.c: every doubling white excursion of source period P, exhaustively (pull M29; K4).
// Written from the definitions, independently of claudeM5_doubling_census.c (M41), and for every P, not only dyadic.
//
// A source b of least period P and odd weight, beside a permanently white wheel A = 0, makes the first child D_1
// antiperiodic at P: the interval's clock doubles to Q = 2P. One Lyndon word per rotation class suffices, with one
// lift: the other lift is the same orbit shifted by P ticks. D_2 = all black; every later wheel is the unique
// Q-periodic child of the two before it (kit `child_unique`), all 2P ticks at once in a 64-bit word.
// A tick's row gets a reset when a closed black run of length 1 mod 3 ends (run-residue automaton, as in K2).
// Each excursion stops when
//   resolved:   every tick has closed a reset (no later white can make the interval reset-free in any tick);
//   returned:   a wheel is all white (the next white B): ticks still without a reset are reset-free ticks of the
//               whole doubling interval [A, B], each one a counterexample to the doubling lemma at period P;
//   unknown:    neither by CAP wheels.
// usage: claudeCloud_doubling_census PMIN PMAX CAP    (P <= 32; one JSON object per P on stdout)
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
static long hres[HMAX + 1];

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: PMIN PMAX CAP\n"); return 2; }
    int pmin = atoi(argv[1]), pmax = atoi(argv[2]);
    long cap = atol(argv[3]);
    for (int P = pmin; P <= pmax; P++) {
        Q = 2 * P;
        M = (Q == 64) ? ~0ULL : ((1ULL << Q) - 1);
        for (int i = 0; i <= HMAX; i++) hres[i] = 0;
        long classes = 0, resolved = 0, returned = 0, ret_free = 0, unknown = 0, maxres = 0, maxret = 0;
        printf("{\"P\": %d, \"Q\": %d, \"cap\": %ld, \"reset_free_doublings\": [", P, Q, cap);
        int nfree_printed = 0;
        // FKM: Lyndon words of length exactly P over {0,1}
        int a[40] = {0};
        int n = P, i = 1;
        a[0] = 0;
        for (int k = 1; k <= n; k++) a[k] = 0;
        // standard iterative generation of prenecklaces; keep those with p == n (Lyndon of length n)
        int p = 1;
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
                    long j, outcome = 0;   // 1 resolved, 2 returned, 0 unknown
                    for (j = 1; j <= cap; j++) {
                        if (j == 1) c = d1;
                        else if (j == 2) c = M;
                        else c = child(prev2, prev1);
                        uint64_t white = ~c & M;
                        res |= R1 & white;
                        uint64_t nR1 = c & (W | R0), nR2 = c & R1, nR0 = c & R2;
                        W = white; R1 = nR1; R2 = nR2; R0 = nR0;
                        if (c == 0) { outcome = 2; break; }
                        if (res == M) { outcome = 1; break; }
                        prev2 = prev1; prev1 = c;
                    }
                    if (outcome == 1) {
                        resolved++;
                        hres[j < HMAX ? j : HMAX]++;
                        if (j > maxres) maxres = j;
                    } else if (outcome == 2) {
                        returned++;
                        if (j > maxret) maxret = j;
                        uint64_t freet = ~res & M;
                        if (freet) {
                            ret_free++;
                            if (nfree_printed < 200) {
                                printf("%s{\"word\": \"", nfree_printed ? ", " : "");
                                for (int t = 0; t < P; t++) putchar('0' + bit(w, t));
                                printf("\", \"gap\": %ld, \"reset_free_ticks\": [", j);
                                int first = 1;
                                for (int t = 0; t < Q; t++) if (bit(freet, t)) { printf("%s%d", first ? "" : ", ", t); first = 0; }
                                printf("]}");
                                nfree_printed++;
                            }
                        }
                    } else unknown++;
                }
            }
            // next prenecklace (FKM)
            i = n;
            while (i >= 1 && a[i] == 1) i--;
            if (i == 0) break;
            a[i]++;
            for (int k = i + 1; k <= n; k++) a[k] = a[k - i];
            p = i;
        }
        printf("], \"classes\": %ld, \"resolved\": %ld, \"returned\": %ld, \"returned_with_reset_free_tick\": %ld,"
               " \"unknown\": %ld, \"max_resolution_wheel\": %ld, \"max_return_wheel_before_resolution\": %ld,"
               " \"resolution_hist\": [", classes, resolved, returned, ret_free, unknown, maxres, maxret);
        int last = 0;
        for (int k = 0; k <= HMAX; k++) if (hres[k]) last = k;
        for (int k = 0; k <= last; k++) printf("%s%ld", k ? ", " : "", hres[k]);
        printf("]}\n");
        fflush(stdout);
    }
    return 0;
}
