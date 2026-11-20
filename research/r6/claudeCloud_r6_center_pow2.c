// claudeCloud_r6_center_pow2.c: pull R6, first block (ledger K37). The centre column of rule 30 from one black cell,
// at every power of two up to 2^K, and at a few other times as controls.
//
// Rule 30: new cell = left xor (centre or right). One row is a bit array; bit OFFSET + x is the cell at position x.
// At tick t the pattern occupies |x| <= t, and a cell at (t, x) can reach the centre at tick N = 2^K only if
// |x| <= N - t. Only that diamond is computed, so the centre is exact at every tick up to N.
// usage: claudeCloud_r6_center_pow2 K [THREADS [DUMPFILE]]   prints "k c(2^k)" for k = 0..K; with DUMPFILE, writes
//        every centre cell c(0..2^K) there as a string of 0s and 1s (for the controls)
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifdef _OPENMP
#include <omp.h>
#endif

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: K [THREADS]\n"); return 2; }
    int K = atoi(argv[1]);
#ifdef _OPENMP
    if (argc > 2) omp_set_num_threads(atoi(argv[2]));
#endif
    uint64_t N = 1ULL << K;
    uint64_t half = N / 2 + 64;                     // the diamond is widest at tick N/2: |x| <= N/2
    uint64_t OFFSET = half + 64;
    uint64_t words = (2 * half + 256) / 64 + 4;
    uint64_t *a = calloc(words, 8), *b = calloc(words, 8);
    if (!a || !b) { fprintf(stderr, "no memory\n"); return 1; }
    a[OFFSET >> 6] |= 1ULL << (OFFSET & 63);
    uint64_t cw = OFFSET >> 6; int cb = OFFSET & 63;
    time_t t0 = time(NULL);
    uint64_t next_pow = 1; int k = 0;
    FILE *dump = argc > 3 ? fopen(argv[3], "w") : NULL;
    for (uint64_t t = 0; t <= N; t++) {
        int c = (a[cw] >> cb) & 1;
        if (dump) fputc('0' + c, dump);
        if (t == next_pow) { printf("%d %d  # tick %llu, %ld s\n", k, c, (unsigned long long)t, (long)(time(NULL) - t0)); fflush(stdout); k++; next_pow <<= 1; }
        if (t == N) break;
        // the row at tick t + 1 on |x| <= r, r = min(t + 1, N - (t + 1))
        uint64_t r = t + 1 < N - (t + 1) ? t + 1 : N - (t + 1);
        uint64_t lo = (OFFSET - r) >> 6, hi = (OFFSET + r) >> 6;
        #pragma omp parallel for schedule(static) if (hi - lo > 8192)
        for (uint64_t i = lo; i <= hi; i++) {
            uint64_t x = a[i];
            uint64_t L = (x << 1) | (a[i - 1] >> 63);   // the left neighbour of each cell
            uint64_t R = (x >> 1) | (a[i + 1] << 63);   // the right neighbour
            b[i] = L ^ (x | R);
        }
        // cells outside |x| <= r in the border words may be wrong; they are never read by a later needed cell,
        // because the needed region shrinks or grows by one cell a tick and each tick reads one cell further out
        // only while the pattern itself still fits. Clear the two words beyond, so stale data never enters.
        b[lo - 1] = 0; b[hi + 1] = 0;
        uint64_t *tmp = a; a = b; b = tmp;
    }
    if (dump) fclose(dump);
    return 0;
}
