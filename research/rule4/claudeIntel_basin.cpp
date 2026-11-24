// Independent lower bound for the trap's basin (claudeIntel): three-valued evolution of every W-cell prefix, all further cells unknown.
// usage: basin TRAPFILE W      TRAPFILE: the kit's 829 windows, whitespace separated
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <fstream>
typedef uint64_t u64;
int main(int c, char **v) {
    std::vector<unsigned char> trap(1 << 16, 0); std::ifstream f(v[1]); int x, n = 0; while (f >> x) { if (!trap[x]) n++; trap[x] = 1; }
    // closure under two ticks with two free bits from column 17
    int bad = 0, gaps[8] = {0};
    for (int w = 0; w < 65536; w++) if (trap[w]) for (int e1 = 0; e1 < 2; e1++) for (int e2 = 0; e2 < 2; e2++) {
        unsigned r = w | (e1 << 16), o = (r | (r >> 1)) & 0xFFFF, l = ((unsigned)w << 1) & 0xFFFF, y = l ^ o;      // white wall
        unsigned r2 = y | (e2 << 16), o2 = (r2 | (r2 >> 1)) & 0xFFFF, l2 = ((y << 1) | 1) & 0xFFFF, z = l2 ^ o2;     // black wall
        if (!trap[z]) bad++;
    }
    printf("trap windows %d, transitions leaving it %d\n", n, bad);
    int W = atoi(v[2]); u64 N = 1ull << W, hit = 0; int lastS = 0;
    #pragma omp parallel for reduction(+:hit) reduction(max:lastS) schedule(dynamic, 65536) num_threads(11)
    for (long long p = 0; p < (long long)N; p++) {
        u64 k1 = p, k0 = ~(u64)p & (N - 1);
        // tick 0: wall black; samples at odd ticks
        int t = 0;
        for (int s = 0; s < 128; s++) {
            // one tick with black wall (even tick t) then we are at odd tick 2s+1
            u64 o1 = k1 | (k1 >> 1), o0 = k0 & (k0 >> 1), l1 = (k1 << 1) | 1, l0 = k0 << 1;
            u64 a1 = (l1 & o0) | (l0 & o1), a0 = (l1 & o1) | (l0 & o0); k1 = a1; k0 = a0;
            unsigned kn = (unsigned)((k1 | k0) & 0xFFFF);
            if (__builtin_popcount(kn) < 8 && (kn & 0xFF) == 0) break;
            unsigned un = ~kn & 0xFFFF, base = (unsigned)(k1 & 0xFFFF), sub = 0; bool all = true;
            do { if (!trap[base | sub]) { all = false; break; } sub = (sub - un) & un; } while (sub);
            if (all) { hit++; if (s > lastS) lastS = s; break; }
            o1 = k1 | (k1 >> 1); o0 = k0 & (k0 >> 1); l1 = k1 << 1; l0 = (k0 << 1) | 1;
            a1 = (l1 & o0) | (l0 & o1); a0 = (l1 & o1) | (l0 & o0); k1 = a1; k0 = a0;
        }
    }
    printf("W=%d certified trap %llu of %llu = %.6f, last sample %d\n", W, (unsigned long long)hit, (unsigned long long)N, (double)hit / N, lastS);
}
