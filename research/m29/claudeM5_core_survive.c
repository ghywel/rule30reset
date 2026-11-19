// Pull M29 (M44, exploratory; written and run while the frozen M44 probe ran, not frozen): how fast do the rows of
// G_n that survive k ticks forward and k ticks backward shrink? F_k: rows with a forward walk of length k; B_k:
// rows with a backward walk of length k; R_k = F_k & B_k. Reuses the frozen claudeM5_gap_audit.c (included, main
// renamed). One JSON line per gap: [k, |F_k|, |B_k|, |R_k|].
// Usage: claudeM5_core_survive NMIN NMAX KMAX
#define main audit_main
#include "claudeM5_gap_audit.c"
#undef main
static inline int getb(const uint64_t *a, u32 i) { return (a[i >> 6] >> (i & 63)) & 1; }
static inline void setb(uint64_t *a, u32 i) { a[i >> 6] |= 1ULL << (i & 63); }
int main(int argc, char **argv) {
    int nmin = atoi(argv[1]), nmax = atoi(argv[2]), kmax = atoi(argv[3]);
    for (n = nmin; n <= nmax; n++) {
        N = 1u << (n - 3);
        rowmask = (1ULL << (n + 1)) - 1;
        size_t W = (N + 63) / 64;
        uint64_t *F = malloc(W * 8), *F2 = malloc(W * 8), *B = malloc(W * 8), *B2 = malloc(W * 8);
        memset(F, 0xff, W * 8); memset(B, 0xff, W * 8);
        if (N & 63) { F[W - 1] &= (1ULL << (N & 63)) - 1; B[W - 1] &= (1ULL << (N & 63)) - 1; }
        printf("{\"gap\": %d, \"nodes\": %u, \"R\": [", n, N);
        for (int k = 1; k <= kmax; k++) {
            memset(F2, 0, W * 8); memset(B2, 0, W * 8);
            for (u32 v = 0; v < N; v++) {
                U out[2]; int m = succs(decode(v), out);
                for (int i = 0; i < m; i++) {
                    u32 x = encode(out[i]);
                    if (getb(F, x)) setb(F2, v);          // v has a successor that survives k-1 forward
                    if (getb(B, v)) setb(B2, x);          // x has a predecessor that survives k-1 backward
                }
            }
            uint64_t *t = F; F = F2; F2 = t; t = B; B = B2; B2 = t;
            u32 cf = 0, cb = 0, cr = 0;
            for (size_t i = 0; i < W; i++) { cf += __builtin_popcountll(F[i]); cb += __builtin_popcountll(B[i]);
                                             cr += __builtin_popcountll(F[i] & B[i]); }
            printf("%s[%d, %u, %u, %u]", k > 1 ? ", " : "", k, cf, cb, cr);
            fflush(stdout);
        }
        printf("]}\n");
        free(F); free(F2); free(B); free(B2);
    }
    return 0;
}
