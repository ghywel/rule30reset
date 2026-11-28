/* claudeCloud_affine_two_check.c: exhaustive check of the two-coordinate theorem in ledger K108 (pull K92.5.A).
 *
 * The rows 3, 13, 27, 55, 111 under the white-wall double step G = F o F, F(y) = (y >> 1) ^ (y | (y << 1)).
 * A two-coordinate interpretation: letter b acts by x -> A_b x + c_b on pairs of naturals, from a start vector v.
 * "Wall first" applies bit 0 first (the convention of PrefixRank.value on edge-first words); "edge first" applies
 * the top bit first.  For every interpretation with entries in 0..E (v = 0 allowed) the program checks:
 *   (a) both readings:   state(111) >= state(27) in both coordinates;
 *   (b) wall first:      state(55) >= state(13) in both coordinates;
 *   (c) edge first:      state(55) >= state(13) in both coordinates, or state(55) == state(3);
 * and, for every 2x2 matrix with entries in 0..M: A^2 != 0 implies A^3 >= A entrywise, and A^4 >= A^2 entrywise.
 *   usage: affine_two_check E M      (prints counts and any failure) */
#include <stdio.h>
#include <stdlib.h>
typedef unsigned long long u64;
static u64 F(u64 y) { return (y >> 1) ^ (y | (y << 1)); }
static void state(const int *p, u64 y, int edge_first, u64 out[2]) {
    u64 x0 = p[12], x1 = p[13]; int top = 63 - __builtin_clzll(y);
    for (int i = 0; i <= top; i++) {
        int k = edge_first ? top - i : i, b = (y >> k) & 1;
        const int *A = p + 4 * b, *c = p + 8 + 2 * b;
        u64 n0 = A[0] * x0 + A[1] * x1 + c[0], n1 = A[2] * x0 + A[3] * x1 + c[1]; x0 = n0; x1 = n1;
    }
    out[0] = x0; out[1] = x1;
}
static int ge(const u64 *a, const u64 *b) { return a[0] >= b[0] && a[1] >= b[1]; }
static void mul(const long *a, const long *b, long *c) {
    c[0] = a[0]*b[0] + a[1]*b[2]; c[1] = a[0]*b[1] + a[1]*b[3]; c[2] = a[2]*b[0] + a[3]*b[2]; c[3] = a[2]*b[1] + a[3]*b[3];
}
int main(int argc, char **argv) {
    int E = atoi(argv[1]), M = atoi(argv[2]);
    /* the steps */
    u64 r[5] = {3, 13, 27, 55, 111};
    for (int i = 0; i < 5; i++) printf("G(%llu) = %llu, %llu mod 4 = %llu\n", r[i], F(F(r[i])), r[i], r[i] % 4);
    long n = 1, fail = 0, nilp = 0; for (int i = 0; i < 14; i++) n *= E + 1;
    int p[14];
    for (long code = 0; code < n; code++) {
        long c = code; for (int i = 0; i < 14; i++) { p[i] = c % (E + 1); c /= E + 1; }
        u64 s3[2], s13[2], s27[2], s55[2], s111[2];
        for (int ef = 0; ef < 2; ef++) {
            state(p, 3, ef, s3); state(p, 13, ef, s13); state(p, 27, ef, s27); state(p, 55, ef, s55); state(p, 111, ef, s111);
            if (!ge(s111, s27)) { fail++; if (fail < 5) printf("(a) fails, reading %d, code %ld\n", ef, code); }
            if (!ef && !ge(s55, s13)) { fail++; if (fail < 5) printf("(b) fails, code %ld\n", code); }
            if (ef) {
                int eq = s55[0] == s3[0] && s55[1] == s3[1];
                if (!ge(s55, s13) && !eq) { fail++; if (fail < 5) printf("(c) fails, code %ld\n", code); }
                if (!ge(s55, s13)) nilp++;
            }
        }
    }
    printf("interpretations with entries 0..%d: %ld; failures of (a)-(c): %ld; edge-first cases settled by state(55) = state(3): %ld\n",
           E, n, fail, nilp);
    long mfail = 0, mn = 0;
    for (long code = 0; code < (long)(M + 1) * (M + 1) * (M + 1) * (M + 1); code++) {
        long a[4], c = code; for (int i = 0; i < 4; i++) { a[i] = c % (M + 1); c /= M + 1; }
        long a2[4], a3[4], a4[4]; mul(a, a, a2); mul(a2, a, a3); mul(a2, a2, a4); mn++;
        int nz = a2[0] || a2[1] || a2[2] || a2[3];
        for (int i = 0; i < 4; i++) {
            if (nz && a3[i] < a[i]) mfail++;
            if (a4[i] < a2[i]) mfail++;
        }
    }
    printf("2x2 matrices with entries 0..%d: %ld; failures of the two matrix lemmas: %ld\n", M, mn, mfail);
    return fail || mfail;
}
