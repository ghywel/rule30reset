/* K92.4, claudeM5: the single seed's rows near the centre, for every age up to N + 64.
 *
 * Rule 30, new = left XOR (centre OR right), on a bit row. Site x is bit x + OFF, OFF a multiple of 64, so the 64
 * sites east of and including the centre are one word (bit i = site i) and the 64 sites west of it are the word
 * before (bit 63 = site -1). Each age writes those two words: west, east.
 * Build: cc -O3 -o seed_windows claudeM5_seed_windows.c     Run: ./seed_windows N OUT.u64le
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc < 3) return 2;
    long N = atol(argv[1]);
    long T = N + 64;                              /* last age written */
    long half = (T + 2 + 63) / 64 + 1;            /* words on each side */
    long W = 2 * half + 2, C = half + 1;          /* centre word index; OFF = 64 * C */
    uint64_t *a = calloc(W, 8), *b = calloc(W, 8);
    FILE *f = fopen(argv[2], "wb");
    if (!a || !b || !f) return 3;
    a[C] = 1;
    uint64_t out[2];
    for (long t = 0; t <= T; t++) {
        out[0] = a[C - 1]; out[1] = a[C];
        fwrite(out, 8, 2, f);
        long r = (t + 1) / 64 + 1;                /* words touched on each side at age t + 1 */
        long lo = C - r, hi = C + r;
        for (long i = lo; i <= hi; i++) {
            uint64_t w = a[i];
            uint64_t L = (w << 1) | (a[i - 1] >> 63);
            uint64_t R = (w >> 1) | (a[i + 1] << 63);
            b[i] = L ^ (w | R);
        }
        uint64_t *s = a; a = b; b = s;
    }
    fclose(f);
    return 0;
}
