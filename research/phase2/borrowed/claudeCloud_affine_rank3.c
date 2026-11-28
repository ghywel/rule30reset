/* claudeCloud_affine_rank3.c: a screen of affine ranks in D = 2 or 3 coordinates for Q01 (pull K92.5.A, ledger K108).
 *
 * K108 proves that no two-coordinate nonnegative integer affine rank, read in either direction and marked on either
 * cofinal class, certifies Q01: 27 -> 111 and 13 -> 55 insert 11 at the wall, and for a 2x2 nonnegative integer
 * matrix A with A^2 != 0, A^3 >= A entrywise.  The lemma fails in three coordinates (a 3-cycle), so this screen asks
 * whether a three-coordinate rank with entries 0..E escapes the small rows.
 *
 * The white wall in integer form: F(y) = (y >> 1) ^ (y | (y << 1)), depth 1 in bit 0, G = F o F.  Letter b acts by
 * x -> A_b x + c_b on D-vectors of naturals, from a nonzero start vector v.  READ = 0 applies bit 0 first (the wall
 * first, PrefixRank.value on edge-first words); READ = 1 applies the top bit first.  The rank is the first coordinate:
 * it must never rise on a surviving double step (y and G(y) odd) and must fall on every one from a row = Q mod 4.
 * Form 1 also requires every other coordinate never to rise.  Steps are tested in order of the row; an interpretation
 * stands at W if it passes every surviving step from rows below 2^W.
 *   usage: affine_rank3 WMAX E Q READ D      (D = 2 reproduces claudeCloud_affine_rank.c as a control) */
#include <stdio.h>
#include <stdlib.h>
typedef unsigned long long u64;
static u64 F(u64 y) { return (y >> 1) ^ (y | (y << 1)); }
static int E, Q, READ, D;
typedef struct { u64 y, z; int strict; } step;
/* p: A0 (D*D, row major), A1 (D*D), c0 (D), c1 (D), v (D) */
static void val(const int *p, u64 y, u64 *x, int *ovf) {
    for (int j = 0; j < D; j++) x[j] = p[2 * D * D + 2 * D + j];
    int top = 63 - __builtin_clzll(y);
    for (int i = 0; i <= top; i++) {
        int k = READ ? top - i : i, b = (y >> k) & 1;
        const int *A = p + b * D * D, *c = p + 2 * D * D + b * D;
        u64 n[3];
        for (int r = 0; r < D; r++) {
            u64 s = c[r];
            for (int q = 0; q < D; q++) s += (u64)A[r * D + q] * x[q];
            n[r] = s;
        }
        for (int r = 0; r < D; r++) { x[r] = n[r]; if (n[r] > (1ULL << 60)) *ovf = 1; }
        if (*ovf) return;
    }
}
int main(int argc, char **argv) {
    if (argc < 6) { fprintf(stderr, "usage: affine_rank3 WMAX E Q READ D\n"); return 2; }
    int WMAX = atoi(argv[1]); E = atoi(argv[2]); Q = atoi(argv[3]); READ = atoi(argv[4]); D = atoi(argv[5]);
    if (D < 2 || D > 3) return 2;
    int nst = 0; step *st = malloc(sizeof(step) * (1 << WMAX));
    int bound_index[64] = {0};
    for (u64 y = 1; y < (1ULL << WMAX); y += 2) {
        u64 z = F(F(y));
        if (z & 1) { st[nst].y = y; st[nst].z = z; st[nst].strict = (y & 3) == (u64)Q; nst++; }
        for (int W = 1; W <= WMAX; W++) if (y + 1 == (1ULL << W)) bound_index[W] = nst;
    }
    printf("D=%d, entries 0..%d, strict at %d mod 4, reading %s\n", D, E, Q, READ ? "top bit first" : "wall (bit 0) first");
    printf("surviving double steps from rows below 2^W: ");
    for (int W = 4; W <= WMAX; W += 2) printf("W=%d: %d  ", W, bound_index[W]);
    printf("\n");
    int np = 2 * D * D + 3 * D, nm = 2 * D * D + 2 * D;
    long total = 0, alive[2][64] = {{0}}, shown = 0;
    long nvals = 1; for (int i = 0; i < nm; i++) nvals *= (E + 1);
    long nv = 1; for (int i = 0; i < D; i++) nv *= (E + 1);
    int p[27];
    for (long code = 0; code < nvals; code++) {
        long c = code;
        for (int i = 0; i < nm; i++) { p[i] = c % (E + 1); c /= (E + 1); }
        for (long vc = 1; vc < nv; vc++) {          /* vc = 0 is the zero vector, excluded */
            long t = vc; for (int j = 0; j < D; j++) { p[nm + j] = t % (E + 1); t /= (E + 1); }
            total++;
            for (int form = 0; form < 2; form++) {
                int ok = 1, reached = 0;
                for (int i = 0; i < nst && ok; i++) {
                    int ovf = 0; u64 a[3], b[3];
                    val(p, st[i].y, a, &ovf); val(p, st[i].z, b, &ovf);
                    if (ovf || b[0] > a[0] || (st[i].strict && b[0] == a[0])) ok = 0;
                    if (ok && form == 1) for (int j = 1; j < D; j++) if (b[j] > a[j]) ok = 0;
                    if (ok) reached = i + 1;
                }
                for (int W = 4; W <= WMAX; W += 2) if (reached >= bound_index[W]) alive[form][W]++;
                if (ok && form == 0 && shown < 5) {
                    shown++; printf("survivor (first-coordinate form):");
                    for (int i = 0; i < np; i++) printf(" %d", p[i]);
                    printf("\n");
                }
            }
        }
    }
    printf("interpretations tested: %ld\n", total);
    printf("W | standing, first coordinate weak everywhere and strict at %d mod 4 | standing, all coordinates weak\n", Q);
    for (int W = 4; W <= WMAX; W += 2) printf("%d | %ld | %ld\n", W, alive[0][W], alive[1][W]);
    return 0;
}
