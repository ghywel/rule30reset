// Which finite west halves can stand beside an alternating centre, whatever the right half?  (claudeIntel)
// At a black centre tick the next centre is white, so column -1 must be black there: a condition on the west alone.
// usage: left B first(1 black)   -> for each depth b <= B, the last tick T such that some west of depth exactly b passes every black tick <= T
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>
typedef unsigned __int128 u128;
int main(int c, char **v) {
    int B = atoi(v[1]), first = atoi(v[2]);
    int best = 0;
    for (int b = 0; b <= B; b++) {
        long long lo = b ? 1ll << (b - 1) : 0, hi = b ? 1ll << b : 1;
        int mx = -1; long long arg = 0, alive30 = 0;
        #pragma omp parallel num_threads(11)
        {
            int m = -1; long long a = 0, al = 0;
            #pragma omp for schedule(dynamic, 4096)
            for (long long x = lo; x < hi; x++) {
                u128 r = x; int t = 0;
                for (;; t++) {
                    int ce = (first + t) & 1;
                    if (ce && !(int)(r & 1)) break;                 // fails at black tick t
                    if (b + t > 125) break;
                    r = (r >> 1) ^ (r | ((r << 1) | (u128)ce));
                }
                // passes ticks 0..t-1: the centre can alternate through tick t (the failure shows at t+1)
                if (t > m) { m = t; a = x; }
                if (t >= 30) al++;
            }
            #pragma omp critical
            { if (m > mx) { mx = m; arg = a; } alive30 += al; }
        }
        if (mx > best) best = mx;
        printf("depth %2d: longest alternation through tick %3d (west %lld), wests alive at tick 30: %lld%s\n", b, mx, arg, alive30, b + mx > 124 ? "  [cut by 128 bits]" : "");
        fflush(stdout);
    }
}
