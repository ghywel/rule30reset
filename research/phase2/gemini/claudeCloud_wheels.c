/* claudeCloud_wheels.c: the single seed's left wheels, their clocks, first losses, and the five-tick claim
 * (ledger K100, the carrying read of I321).
 *
 * Wheel i at tick t is the seed's cell at time t, position -t + i (the kit's Rule30AgedLeftDiagonals frame):
 *   d0 = black; d1(t+1) = d0(t) | d1(t); d(i+2)(t+1) = d(i)(t) ^ (d(i+1)(t) | d(i+2)(t)),
 * with every wheel white at tick 0 except wheel 0.  Computed wheel by wheel from the recurrence.
 *
 *   wheels M N        wheels 0..M over ticks 0..N-1.  For each wheel: least period P and preperiod found on the
 *                     second half (P a power of two up to N/4 is tried first, then any P up to N/4).
 *                     Then, aged past every preperiod through M: the least prefix clocks, every white wheel,
 *                     every first loss a (least clock 2^e through a, a white, a+1 anti-periodic at 2^e), its
 *                     next white wheel b, and over two full periods of the aged strip:
 *                       - the longest run of consecutive ticks with no isolated black (010) inside
 *                         [a, min(b, a+7)] (the five-tick theorem says at most 4);
 *                       - the same with no closed black run of length 1 mod 3 inside [a, b] (a Catch), i.e. the
 *                         longest stretch of ticks that DL would have to fill;
 *                       - the least w such that every 5 consecutive ticks have a singleton within [a, min(b,a+w)].
 * COMPUTED; nothing here is a proof.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned char **d;
static int M, N;

static int period_from(int i, int start, int P) {
    for (int t = start; t + P < N; t++) if (d[i][t] != d[i][t + P]) return 0;
    return 1;
}

int main(int argc, char **argv) {
    M = atoi(argv[1]); N = atoi(argv[2]);
    d = malloc((M + 1) * sizeof *d);
    for (int i = 0; i <= M; i++) d[i] = calloc(N, 1);
    for (int t = 0; t < N; t++) d[0][t] = 1;
    for (int t = 0; t + 1 < N; t++) d[1][t + 1] = d[0][t] | d[1][t];
    for (int i = 0; i + 2 <= M; i++)
        for (int t = 0; t + 1 < N; t++) d[i + 2][t + 1] = d[i][t] ^ (d[i + 1][t] | d[i + 2][t]);
    int *per = calloc(M + 1, sizeof(int)), *pre = calloc(M + 1, sizeof(int));
    int half = N / 2;
    for (int i = 0; i <= M; i++) {
        per[i] = 0;
        for (int P = 1; P <= N / 4 && !per[i]; P *= 2) if (period_from(i, half, P)) per[i] = P;   /* least periods divide a power of two (kit: dyadic_prefix_clock) */
        if (!per[i]) { printf("wheel %d: no period up to %d on the second half; stop at depth %d\n", i, N / 4, i - 1); M = i - 1; break; }
        int s = half;
        while (s > 0 && d[i][s - 1] == d[i][s - 1 + per[i]]) s--;
        pre[i] = s;
    }
    int T = 0;
    for (int i = 0; i <= M; i++) if (pre[i] > T) T = pre[i];
    printf("wheels 0..%d over %d ticks; aged from tick %d\n", M, N, T);
    if (M <= 60) {
        printf("wheel: period (preperiod)\n");
        for (int i = 0; i <= M; i++) printf("  %d: %d (%d)%s\n", i, per[i], pre[i], period_from(i, T, 1) && !d[i][T] ? "  WHITE" : "");
    }
    /* first losses */
    long clock = 1;
    long c = 1;
    for (int a = 0; a + 8 <= M; a++) {
        /* least common period through a: the largest period so far, all being powers of two */
        if (per[a] > c) c = per[a];
        clock = c;
        int white = 1;
        for (int t = T; t < N; t++) if (d[a][t]) { white = 0; break; }
        if (!white) continue;
        if ((c & (c - 1)) != 0) { printf("a=%d: clock %ld is not a power of two\n", a, c); continue; }
        int anti = 1;
        for (int t = T; t + c < N; t++) if (d[a + 1][t + c] == d[a + 1][t]) { anti = 0; break; }
        int b = -1;
        for (int j = a + 1; j <= M && b < 0; j++) {
            int w = 1;
            for (int t = T; t < N; t++) if (d[j][t]) { w = 0; break; }
            if (w) b = j;
        }
        int e = 0; while ((1L << e) < c) e++;
        printf("white wheel %d: least clock through it 2^%d; wheel %d anti-periodic at that clock: %s; next white wheel: %s",
               a, e, a + 1, anti ? "yes (a first loss)" : "no", b < 0 ? "beyond the depth computed" : "");
        if (b >= 0) printf("%d", b);
        printf("\n");
        if (!anti) continue;
        int hi = b < 0 ? a + 7 : (b < a + 7 ? b : a + 7);
        long span = 2 * c; if (T + span + 2 > N) span = N - T - 2;
        int runS = 0, bestS = 0, runC = 0, bestC = 0;
        int bestw = -1;
        for (int w = 3; w <= 7 && bestw < 0; w++) {
            int ok = 1, run = 0;
            int h2 = b < 0 ? a + w : (b < a + w ? b : a + w);
            for (long t = T; t < T + span; t++) {
                int hit = 0;
                for (int j = a; j + 2 <= h2; j++) if (!d[j][t] && d[j + 1][t] && !d[j + 2][t]) { hit = 1; break; }
                run = hit ? 0 : run + 1;
                if (run >= 5) { ok = 0; break; }
            }
            if (ok) bestw = w;
        }
        for (long t = T; t < T + span; t++) {
            int s = 0;
            for (int j = a; j + 2 <= hi; j++) if (!d[j][t] && d[j + 1][t] && !d[j + 2][t]) { s = 1; break; }
            runS = s ? 0 : runS + 1; if (runS > bestS) bestS = runS;
            int cc = 0;
            int top = b < 0 ? M : b;
            for (int j = a; j < top && !cc; j++) {
                if (d[j][t]) continue;
                int n = 0; while (j + 1 + n <= top && d[j + 1 + n][t]) n++;
                if (n > 0 && n % 3 == 1 && j + 1 + n <= top && !d[j + 1 + n][t]) cc = 1;
            }
            runC = cc ? 0 : runC + 1; if (runC > bestC) bestC = runC;
        }
        printf("   over %ld ticks: longest run with no singleton in [a, min(b,a+7)]: %d; with no reset of length 1 mod 3 in "
               "[a,b]: %d; least width w giving a singleton in every 5 ticks: %d\n", span, bestS, bestC, bestw);
    }
    return 0;
}
