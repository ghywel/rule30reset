/* claudeCloud_settled_windows.c: how much of an early western snapshot lies on the seed's settled left side
 * (ledger K106, pull I295.4).
 *
 * Wheel j at tick t is the seed's cell at time t, position -t + j (the kit's Rule30AgedLeftDiagonals frame), computed
 * by the left-edge recurrence.  F(j) is the first tick from which wheel j repeats with period 16 to the horizon (the
 * kit's four left sides have least period 16 through wheel 87,866).  The snapshot S_t(w) on sites 0 .. -w is wheels
 * t-w .. t at tick t; its settled part is the wheels j in that range with F(j) <= t.
 *
 *   settled_windows J T WMIN WMAX STEP [SPAN]     ages w .. SPAN*w (default 5)
 * Prints F(j)/j at sample wheels; then for each w: over ages w .. 5w, the settled length at each age, the last age
 * with a settled part, and whether the settled parts alone (with t mod 16) already separate every pair of ages.
 * COMPUTED.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    int J = atoi(argv[1]), T = atoi(argv[2]), wmin = atoi(argv[3]), wmax = atoi(argv[4]), step = atoi(argv[5]);
    double span = argc > 6 ? atof(argv[6]) : 5.0;     /* ages w .. span*w */
    unsigned char **d = malloc((J + 1) * sizeof *d);
    for (int j = 0; j <= J; j++) d[j] = calloc(T + 1, 1);
    for (int t = 0; t <= T; t++) d[0][t] = 1;
    for (int t = 0; t < T; t++) d[1][t + 1] = d[0][t] | d[1][t];
    for (int j = 0; j + 2 <= J; j++)
        for (int t = 0; t < T; t++) d[j + 2][t + 1] = d[j][t] ^ (d[j + 1][t] | d[j + 2][t]);
    int *F = malloc((J + 1) * sizeof(int));
    for (int j = 0; j <= J; j++) {
        int t0 = T - 16;
        while (t0 > 0 && d[j][t0 - 1] == d[j][t0 - 1 + 16]) t0--;
        F[j] = t0;
    }
    printf("settling tick F(j) (period 16): j : F(j) : F(j)/j\n");
    for (int j = 16; j <= J; j *= 2) printf("  %d : %d : %.3f\n", j, F[j], (double)F[j] / j);
    for (int lo = 64; lo * 2 <= J; lo *= 2) {
        double mx = 0; int arg = 0;
        for (int j = lo; j < 2 * lo; j++) if ((double)F[j] / j > mx) { mx = (double)F[j] / j; arg = j; }
        printf("  wheels %d..%d: largest F(j)/j %.3f at j = %d; largest F(j) - j %d\n", lo, 2 * lo - 1, mx, arg,
               ({ int m = 0; for (int j = lo; j < 2 * lo; j++) if (F[j] - j > m) m = F[j] - j; m; }));
    }
    int monotone_breaks = 0;
    for (int j = 1; j <= J; j++) if (F[j] + 3 < F[j - 1]) monotone_breaks++;
    printf("wheels whose settling tick is more than 3 below the previous wheel's: %d\n", monotone_breaks);
    printf("\nw | last age with a settled part | settled length at age w, 2w, 3w | ages w..%.1fw separated by settled parts alone?\n", span);
    for (int w = wmin; w <= wmax; w += step) {
        int last = -1;
        int len[6] = {0};
        int A = (int)(span * w); if (A > T) A = T;
        int nages = A - w + 1;
        /* settled part as (phase, start wheel, length, bits) */
        int *L = calloc(nages, sizeof(int));
        for (int t = w; t <= A; t++) {
            int l = 0;
            for (int j = t - w; j <= t && j <= J; j++) { if (F[j] <= t) l++; else break; }
            L[t - w] = l;
            if (l > 0) last = t;
        }
        for (int k = 1; k <= 3; k++) len[k] = (k * w <= A) ? L[k * w - w] : -1;
        /* separated: for every pair a<b both with settled parts, the settled words (common prefix length) differ, or the
           phases mod 16 differ and both have a settled part (different rows need not differ: compare the actual bits) */
        int unseparated = 0, pairs = 0;
        for (int a = w; a <= A; a++) {
            if (!L[a - w]) continue;
            for (int b = a + 1; b <= A; b++) {
                if (!L[b - w]) continue;
                pairs++;
                int m = L[a - w] < L[b - w] ? L[a - w] : L[b - w];
                int differ = 0;
                for (int i = 0; i < m && !differ; i++) if (d[a - w + i][a] != d[b - w + i][b]) differ = 1;
                if (!differ) unseparated++;
            }
        }
        printf("%d | %d (%.2f w) | %d, %d, %d | %d of %d pairs not separated\n", w, last, (double)last / w, len[1], len[2], len[3],
               unseparated, pairs);
        free(L);
    }
    return 0;
}
