/* claudeCloud_seven_direct.c: direct first failures of the seven-spaced cuts (ledger K106, the carrying read of I338).
 *
 * The kit's white wall: bit j is depth j+1, one tick is y -> (y >> 1) ^ (y | (y << 1)), and the wall reads bit 0.
 * Y(n, q) has black bits 2, 4, 1+7i (i < n) and the bits of q shifted to c = 1+7n.  Only the cells inside the wall's
 * light cone up to the horizon are kept, so a cut of width W costs about W^2/128 word operations.
 *
 *   seven_direct range NLO NHI Q DMAX       every n in NLO..NHI
 *   seven_direct one N Q DMAX               a single n
 * Prints n, c, P (first white odd physical tick) and G (first failure of the kit's G word: white at 0, black at odd
 * ticks, no two successive even ticks white), each as an offset from c, or 'none' within c + DMAX.  COMPUTED.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static void run(long n, unsigned long long q, int dmax) {
    long c = 1 + 7 * n, T = c + dmax, nw = T / 64 + 2;
    uint64_t *x = calloc(nw + 1, 8), *y = calloc(nw + 1, 8);
    #define SET(b) x[(b) / 64] |= 1ULL << ((b) % 64)
    SET(2); SET(4);
    for (long i = 0; i < n; i++) SET(1 + 7 * i);
    for (int b = 0; b < 64; b++) if ((q >> b) & 1ULL) { long p = c + b; if (p <= T) SET(p); }
    int prev_even = -1;            /* reading at the last even tick */
    long P = -1, G = -1;
    for (long t = 0; t <= T; t++) {
        int r = x[0] & 1;
        if (t == 0 && r) { if (G < 0) G = 0; }
        if (t % 2 == 1 && !r) { if (P < 0) P = t; if (G < 0) G = t; }
        if (t % 2 == 0 && t >= 2 && !r && prev_even == 0 && G < 0) G = t;
        if (t % 2 == 0) prev_even = r;
        if (P >= 0 && G >= 0) break;
        long top = (T - t) / 64 + 1; if (top > nw) top = nw;     /* the cone: bits above T - t no longer matter */
        for (long j = 0; j <= top; j++) {
            uint64_t a = x[j];
            uint64_t west = (a >> 1) | (j + 1 <= nw ? (x[j + 1] << 63) : 0);
            uint64_t east = (a << 1) | (j ? (x[j - 1] >> 63) : 0);
            y[j] = west ^ (a | east);
        }
        for (long j = 0; j <= top; j++) x[j] = y[j];
        for (long j = top + 1; j <= nw; j++) x[j] = 0;
    }
    printf("%ld %ld ", n, c);
    if (P >= 0) printf("%ld ", P - c); else printf("none ");
    if (G >= 0) printf("%ld\n", G - c); else printf("none\n");
    fflush(stdout);
    free(x); free(y);
}

int main(int argc, char **argv) {
    if (!strcmp(argv[1], "range")) {
        long lo = atol(argv[2]), hi = atol(argv[3]); unsigned long long q = strtoull(argv[4], 0, 10); int d = atoi(argv[5]);
        for (long n = lo; n <= hi; n++) run(n, q, d);
    } else run(atol(argv[2]), strtoull(argv[3], 0, 10), atoi(argv[4]));
    return 0;
}
