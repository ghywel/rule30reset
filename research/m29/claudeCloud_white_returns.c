// claudeCloud_white_returns.c: how far a white excursion runs before the next white wheel, and how far each
// tick runs before its first closed reset (pull M29; K2). Random sources, no cutoff on the source space.
//
// Setting (R38-R44, M41-M43; kit Rule30TemporalProfiles). Wheels j = 0, 1, 2, ... from a permanently white
// anchor A = 0. D_j(t+1) = D_(j-2)(t) XOR (D_(j-1)(t) OR D_j(t)), on words of one temporal period Q (bit t =
// tick t). A source b = D_(-1) of least period p and the lift bit D_1(0) give D_1(t+1) = D_1(t) XOR b(t);
// D_2 = all black (the unique periodic child of the white anchor and D_1); every later wheel is the unique
// periodic child of the two before it, while the one before is not white (kit `child_unique`). The excursion
// ends at the first wheel B whose word is all white; its gap is B - A.
//   parity even: p = Q, even weight, so D_1 has period Q (no doubling);
//   parity odd:  p = Q/2, odd weight, so D_1 is antiperiodic at Q/2 (a doubling; least period of b is exactly p).
// Sources of least period below p, and the all-white source, are rejected and drawn again.
//
// Resets: in each tick's row, reading wheels A, A+1, ..., a closed black run of length 1 mod 3 (closed by a
// white cell) is a reset. A tick's resolution depth is the wheel of the white cell that closes its first reset;
// ticks unresolved at B are the reset-free ticks of the whole interval [A, B].
//
// usage: claudeCloud_white_returns Q PARITY N CAP SEED     (Q <= 64; CAP in wheels; output: one JSON object)
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static uint64_t rs;
static uint64_t rnd(void) {  // splitmix64
    uint64_t z = (rs += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}

static int Q;
static uint64_t M;

static inline int bit(uint64_t w, int t) { return (w >> t) & 1; }

static int least_period(uint64_t w, int p) {  // w has period p (bits 0..p-1)
    for (int d = 1; d < p; d++) {
        if (p % d) continue;
        int ok = 1;
        for (int t = 0; t < p && ok; t++) if (bit(w, t) != bit(w, (t + d) % p)) ok = 0;
        if (ok) return d;
    }
    return p;
}

// unique Q-periodic child c of (a, b), c(t+1) = a(t) ^ (b(t) | c(t)); requires b != 0
static uint64_t child(uint64_t a, uint64_t b) {
    int t0 = __builtin_ctzll(b);
    int t = (t0 + 1) % Q;
    int ct = !bit(a, t0);
    uint64_t c = (uint64_t)ct << t;
    for (int k = 1; k < Q; k++) {
        int nt = (t + 1) % Q;
        ct = bit(a, t) ^ (bit(b, t) | ct);
        c |= (uint64_t)ct << nt;
        t = nt;
    }
    return c;
}

#define HMAX 4096

static int cmp_long(const void *u, const void *v) { long a = *(const long *)u, b = *(const long *)v; return (a > b) - (a < b); }

int main(int argc, char **argv) {
    if (argc < 6) { fprintf(stderr, "usage: Q PARITY N CAP SEED\n"); return 2; }
    Q = atoi(argv[1]);
    int odd = !strcmp(argv[2], "odd");
    long N = atol(argv[3]);
    long cap = atol(argv[4]);
    rs = strtoull(argv[5], 0, 10);
    M = (Q == 64) ? ~0ULL : ((1ULL << Q) - 1);
    int p = odd ? Q / 2 : Q;
    if ((odd && Q % 2) || Q < 2 || Q > 64) { fprintf(stderr, "bad Q\n"); return 2; }
    static long hist[HMAX + 1];           // per-tick resolution depth (HMAX = beyond)
    long ret = 0, cens = 0, with_free = 0, free_ticks = 0;
    double sum = 0, sum2 = 0;
    long *gaps = malloc(sizeof(long) * N);
    long maxres = 0, maxgap = 0;
    for (long s = 0; s < N; s++) {
        uint64_t b;
        for (;;) {
            b = rnd() & ((p == 64) ? ~0ULL : ((1ULL << p) - 1));
            int w = __builtin_popcountll(b);
            if ((w & 1) != odd) b ^= 1;
            if (b && least_period(b, p) == p) break;
        }
        uint64_t bw = 0;                  // b extended to Q ticks
        for (int t = 0; t < Q; t++) bw |= (uint64_t)bit(b, t % p) << t;
        uint64_t d1 = 0;
        int x = rnd() & 1;
        for (int t = 0; t < Q; t++) { d1 |= (uint64_t)x << t; x ^= bit(bw, t); }
        // run-residue state per tick: W, R1, R2, R0 as masks
        uint64_t W = M, R1 = 0, R2 = 0, R0 = 0, res = 0;
        uint64_t prev2 = 0, prev1 = 0, c;
        long j, gap = -1;
        for (j = 1; j <= cap; j++) {
            if (j == 1) c = d1;
            else if (j == 2) c = M;
            else c = child(prev2, prev1);
            uint64_t black = c, white = ~c & M;
            uint64_t closed = R1 & white & ~res;
            if (closed) {
                int k = __builtin_popcountll(closed);
                hist[j < HMAX ? j : HMAX] += k;
                if (j > maxres) maxres = j;
                res |= closed;
            }
            uint64_t nR1 = black & (W | R0), nR2 = black & R1, nR0 = black & R2;
            W = white; R1 = nR1; R2 = nR2; R0 = nR0;
            if (c == 0) { gap = j; break; }
            prev2 = prev1; prev1 = c;
        }
        if (gap < 0) { cens++; continue; }
        gaps[ret++] = gap;
        sum += gap; sum2 += (double)gap * gap;
        if (gap > maxgap) maxgap = gap;
        long nf = __builtin_popcountll(~res & M);
        if (nf) { with_free++; free_ticks += nf; }
    }
    // median
    long med = 0;
    if (ret) {
        qsort(gaps, ret, sizeof(long), cmp_long);
        med = gaps[ret / 2];
    }
    double mean = ret ? sum / ret : 0, sd = ret > 1 ? sqrt((sum2 - sum * sum / ret) / (ret - 1)) : 0;
    double scale = ldexp(1.0, Q);
    printf("{\"Q\": %d, \"parity\": \"%s\", \"source_period\": %d, \"samples\": %ld, \"returned\": %ld, \"censored\": %ld,"
           " \"cap\": %ld, \"mean_gap\": %.3f, \"median_gap\": %ld, \"max_gap\": %ld, \"sd_gap\": %.3f,"
           " \"mean_over_2Q\": %.5f, \"median_over_2Q_ln2\": %.5f, \"cv\": %.5f,"
           " \"returns_with_reset_free_tick\": %ld, \"reset_free_ticks\": %ld, \"max_resolution_depth\": %ld,"
           " \"resolution_hist\": [", Q, odd ? "odd" : "even", p, N, ret, cens, cap, mean, med, maxgap, sd,
           mean / scale, med / (scale * log(2.0)), mean > 0 ? sd / mean : 0, with_free, free_ticks, maxres);
    int last = 0;
    for (int i = 0; i <= HMAX; i++) if (hist[i]) last = i;
    for (int i = 0; i <= last; i++) printf("%s%ld", i ? ", " : "", hist[i]);
    printf("]}\n");
    return 0;
}
