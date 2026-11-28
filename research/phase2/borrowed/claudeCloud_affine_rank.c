/* claudeCloud_affine_rank.c: a screen of two-coordinate affine ranks for Q01 (ledger K107, pull K92.5.A).
 *
 * The kit's white wall in integer form: F(y) = (y >> 1) ^ (y | (y << 1)), depth 1 in bit 0, G = F o F.  A surviving
 * double step is y -> G(y) with y and G(y) odd.  A rank reads the row's word from its outer edge toward the wall:
 *     R(y) = T_{b_W}( T_{b_{W-1}}( ... T_{b_1}(v) ... ) ),   T_b(x) = A_b x + c_b,
 * with b_1 the wall cell, v a nonzero terminal vector, and nonnegative integer entries.  It certifies Q01 if its first
 * coordinate never rises on a surviving double step and falls strictly on every one from a row = 3 mod 4: an immortal
 * row visits that class cofinally (the kit's free_not_eventuallyPeriodic, PrefixRank.lean).  The stronger form asks
 * both coordinates never to rise.
 *
 *   affine_rank WMAX EMAX
 * Every interpretation with all twelve entries of A_0, A_1, c_0, c_1 in 0..EMAX and v in 0..EMAX^2 minus 0 is tested on
 * every surviving step from a row below 2^W, for W = 4, 6, ..., WMAX; the steps are taken in order of the row.
 * Prints the number of interpretations still standing at each W, for both forms, and the first few survivors.
 * COMPUTED; a survivor is only a candidate, and a proof must hold at every width.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef unsigned long long u64;
static u64 F(u64 y) { return (y >> 1) ^ (y | (y << 1)); }

typedef struct { u64 y, z; int strict; } step;

static int E;
static u64 val(const int *p, u64 y, int coord, int *ovf) {
    /* p: A0 (4), A1 (4), c0 (2), c1 (2), v (2).  Apply from the wall (bit 0) outward to the top black bit. */
    u64 x0 = p[12], x1 = p[13];
    int top = 63 - __builtin_clzll(y);
    for (int k = 0; k <= top; k++) {
        int b = (y >> k) & 1;
        const int *A = p + 4 * b, *c = p + 8 + 2 * b;
        u64 n0 = A[0] * x0 + A[1] * x1 + c[0], n1 = A[2] * x0 + A[3] * x1 + c[1];
        x0 = n0; x1 = n1;
        if (x0 > (1ULL << 60) || x1 > (1ULL << 60)) { *ovf = 1; return 0; }
    }
    return coord ? x1 : x0;
}

int main(int argc, char **argv) {
    int WMAX = atoi(argv[1]); E = atoi(argv[2]);
    int nst = 0; step *st = malloc(sizeof(step) * (1 << WMAX));
    int bound_index[64] = {0};
    for (u64 y = 1; y < (1ULL << WMAX); y += 2) {
        u64 z = F(F(y));
        if (z & 1) { st[nst].y = y; st[nst].z = z; st[nst].strict = (y & 3) == 3; nst++; }
        for (int W = 1; W <= WMAX; W++) if (y + 1 == (1ULL << W)) bound_index[W] = nst;
    }
    printf("surviving double steps from rows below 2^W: ");
    for (int W = 4; W <= WMAX; W += 2) printf("W=%d: %d  ", W, bound_index[W]);
    printf("\n");
    long total = 0, alive[2][64] = {{0}};
    int p[14];
    long nvals = 1; for (int i = 0; i < 12; i++) nvals *= (E + 1);
    long shown = 0;
    for (long code = 0; code < nvals; code++) {
        long c = code;
        for (int i = 0; i < 12; i++) { p[i] = c % (E + 1); c /= (E + 1); }
        for (int v0 = 0; v0 <= E; v0++) for (int v1 = 0; v1 <= E; v1++) {
            if (!v0 && !v1) continue;
            p[12] = v0; p[13] = v1;
            total++;
            for (int form = 0; form < 2; form++) {
                int ok = 1, reached = 0;
                for (int i = 0; i < nst && ok; i++) {
                    int ovf = 0;
                    u64 a = val(p, st[i].y, 0, &ovf), b = val(p, st[i].z, 0, &ovf);
                    if (ovf || b > a || (st[i].strict && b == a)) ok = 0;
                    if (ok && form == 1) {
                        u64 a1 = val(p, st[i].y, 1, &ovf), b1 = val(p, st[i].z, 1, &ovf);
                        if (ovf || b1 > a1) ok = 0;
                    }
                    if (ok) reached = i + 1;
                }
                for (int W = 4; W <= WMAX; W += 2) if (reached >= bound_index[W]) alive[form][W]++;
                if (ok && form == 0 && shown < 5) {
                    shown++;
                    printf("survivor (first-coordinate form): A0=[%d %d;%d %d] A1=[%d %d;%d %d] c0=(%d,%d) c1=(%d,%d) v=(%d,%d)\n",
                           p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13]);
                }
            }
        }
    }
    printf("interpretations tested: %ld (entries 0..%d)\n", total, E);
    printf("W | standing, first coordinate weak everywhere and strict at 3 mod 4 | standing, both coordinates weak\n");
    for (int W = 4; W <= WMAX; W += 2) printf("%d | %ld | %ld\n", W, alive[0][W], alive[1][W]);
    return 0;
}
