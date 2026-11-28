/* claudeCloud_snapshots.c: when does a western snapshot of the single seed first repeat?  (ledger K104, pull I295.4)
 *
 * Rule 30 from one black cell at site 0, run to age T.  The snapshot S_t(w) is the word on sites 0, -1, ..., -w at age
 * t (bit i = site -i), as in Galindo's H(w).  Ages t >= w only, so that the strip lies inside the light cone.
 *
 *   snapshots T WMIN WMAX
 *     For every w: H(w) over ages w .. T; the first repeat (the least b with S_b = S_a for some w <= a < b) and its lag;
 *     the number O of ordered pairs of different ages with equal snapshots among the w^2 ages w .. w + w^2 - 1;
 *     the birthday scale sqrt(pi/2 * 2^(w+1)) for comparison.
 * COMPUTED; nothing here is a proof.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>

typedef struct { uint64_t key; uint32_t age; } item;
static int cmp(const void *x, const void *y) {
    const item *a = x, *b = y;
    if (a->key != b->key) return a->key < b->key ? -1 : 1;
    return a->age < b->age ? -1 : (a->age > b->age);
}

int main(int argc, char **argv) {
    long T = atol(argv[1]); int wmin = atoi(argv[2]), wmax = atoi(argv[3]);
    long OFF = T + 64, NB = 2 * OFF + 64, NW = NB / 64 + 2;
    uint64_t *x = calloc(NW, 8), *y = calloc(NW, 8);
    uint64_t *snap = malloc((T + 1) * 8);
    x[OFF / 64] |= 1ULL << (OFF % 64);
    for (long t = 0; t <= T; t++) {
        /* snapshot: sites 0, -1, ..., -63 -> bits 0..63 */
        uint64_t s = 0;
        for (int i = 0; i < 64; i++) { long p = OFF - i; s |= ((x[p / 64] >> (p % 64)) & 1ULL) << i; }
        snap[t] = s;
        if (t == T) break;
        long lo = (OFF - t - 2) / 64 - 1, hi = (OFF + t + 2) / 64 + 1;
        if (lo < 1) lo = 1;
        if (hi > NW - 2) hi = NW - 2;
        for (long j = lo; j <= hi; j++) {
            uint64_t c = x[j];
            uint64_t l = (c << 1) | (x[j - 1] >> 63);      /* bit p holds site p - OFF; left neighbour is p - 1 */
            uint64_t r = (c >> 1) | (x[j + 1] << 63);
            y[j] = l ^ (c | r);
        }
        for (long j = lo; j <= hi; j++) x[j] = y[j];
    }
    printf("ages to %ld; w | H(w) over ages w..T | 2^(w+1) | first repeat: age b, earlier age a, lag | birthday scale | "
           "O among the w^2 ages from w | distinct among them\n", T);
    item *it = malloc((T + 1) * sizeof(item));
    for (int w = wmin; w <= wmax; w++) {
        uint64_t mask = (w >= 63) ? ~0ULL : ((1ULL << (w + 1)) - 1);
        long n = 0;
        for (long t = w; t <= T; t++) { it[n].key = snap[t] & mask; it[n].age = (uint32_t)t; n++; }
        qsort(it, n, sizeof(item), cmp);
        long H = 0, firstb = -1, firsta = -1;
        for (long i = 0; i < n; i++) {
            if (i == 0 || it[i].key != it[i - 1].key) H++;
            else {
                /* it[i] repeats the class's earliest age it[k]; the class's second member gives its first repeat */
                long k = i; while (k > 0 && it[k - 1].key == it[i].key) k--;
                if (i == k + 1 && (firstb < 0 || (long)it[i].age < firstb)) { firstb = it[i].age; firsta = it[k].age; }
            }
        }
        long N = (long)w * w; if (w + N - 1 > T) N = T - w + 1;
        long O = 0, distinct = 0;
        /* O and distinct among ages w .. w+N-1 */
        long m = 0;
        for (long t = w; t < w + N; t++) { it[m].key = snap[t] & mask; it[m].age = t; m++; }
        qsort(it, m, sizeof(item), cmp);
        for (long i = 0; i < m; ) {
            long j = i; while (j < m && it[j].key == it[i].key) j++;
            long sz = j - i; O += sz * (sz - 1); distinct++; i = j;
        }
        double birthday = sqrt(M_PI / 2 * pow(2.0, w + 1));
        printf("%d | %ld | %.0f | %ld %ld %ld | %.0f | %ld | %ld\n", w, H, pow(2.0, w + 1), firstb, firsta,
               firstb >= 0 ? firstb - firsta : -1, birthday, O, distinct);
        fflush(stdout);
    }
    return 0;
}
