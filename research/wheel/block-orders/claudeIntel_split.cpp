// claudeIntel, N19: multilevel splitting on genuine initial right halves for a prescribed gate word beside the alternating wall (white first).
// A particle is the first M cells.  Score = readings matched before the first mismatch.  Kernel: redraw every cell from a random position x on,
// keep the change if the score is still at least the current level.  usage: ams WORDFILE NPART KSTEPS RMAX SEED REPORT [LO HI]
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>
#include <omp.h>
typedef uint64_t u64;
struct Rng { u64 s; u64 next() { s += 0x9E3779B97F4A7C15ull; u64 z = s; z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ull; z = (z ^ (z >> 27)) * 0x94D049BB133111EBull; return z ^ (z >> 31); } double u() { return (next() >> 11) * 0x1.0p-53; } };
static std::string w; static int RM, M, NW;
static int score(const u64 *row, u64 *a, int stop) {            // bit p-1 = cell p.  wall white at even ticks; reading s = cell 1 at tick 2s
    std::copy(row, row + NW, a);
    if ((int)(a[0] & 1) != w[0] - '0') return 0;
    for (int s = 1; s < stop; s++) {
        for (u64 wall = 0; wall < 2; wall++) {
            int n = std::min(NW, (2 * (stop - s) + 130) / 64 + 1); u64 c = wall;
            for (int k = 0; k < n; k++) { u64 x = a[k], l = (x << 1) | c, r = (x >> 1) | (k + 1 < NW ? a[k + 1] << 63 : 0); c = x >> 63; a[k] = l ^ (x | r); }
        }
        if ((int)(a[0] & 1) != w[s] - '0') return s;
    }
    return stop;
}
int main(int c, char **v) {
    std::ifstream(v[1]) >> w; int N = atoi(v[2]), K = atoi(v[3]); RM = atoi(v[4]); u64 seed = strtoull(v[5], 0, 10); int rep = atoi(v[6]);
    double lo = c > 7 ? atof(v[7]) : 0.2, hi = c > 8 ? atof(v[8]) : 1.1; if (RM > (int)w.size()) RM = w.size();
    M = 2 * RM + 66; NW = (M + 63) / 64; int nt = omp_get_max_threads(); std::vector<Rng> R(nt); for (int i = 0; i < nt; i++) R[i].s = seed * 1000003ull + i * 7919 + 1;
    std::vector<u64> P((size_t)N * NW); std::vector<int> sc(N);
    #pragma omp parallel
    { Rng &g = R[omp_get_thread_num()]; std::vector<u64> a(NW);
      #pragma omp for schedule(dynamic, 64)
      for (int i = 0; i < N; i++) { u64 *p = &P[(size_t)i * NW]; do { for (int k = 0; k < NW; k++) p[k] = g.next(); sc[i] = score(p, a.data(), RM); } while (sc[i] < 1); } }
    double lm = -1, seg = 0; std::vector<double> acc(12, 0), tot(12, 0);
    for (int L = 1; L <= RM; L++) {                              // require score >= L
        std::vector<int> ok; for (int i = 0; i < N; i++) if (sc[i] >= L) ok.push_back(i);
        double p = (double)ok.size() / N; if (ok.empty()) { printf("dead at level %d (no particle with %d readings), log2 mass %.2f\n", L, L, lm);
            for (int q = 0; q < 40 && q < N; q++) { int i = (int)((long long)q * N / 40); std::string t; for (int z = 0; z < M; z++) t += (char)(48 + ((P[(size_t)i * NW + (z >> 6)] >> (z & 63)) & 1)); printf("row %d %s\n", sc[i], t.c_str()); }
            return 0; }
        if (p < 1) {
            lm += log2(p); seg += log2(p); Rng &g = R[0];
            for (int i = 0; i < N; i++) if (sc[i] < L) { int j = ok[g.next() % ok.size()]; std::copy(&P[(size_t)j * NW], &P[(size_t)j * NW] + NW, &P[(size_t)i * NW]); sc[i] = sc[j]; }
            #pragma omp parallel
            { Rng &h = R[omp_get_thread_num()]; std::vector<u64> a(NW), q(NW); std::vector<double> A(12, 0), T(12, 0);
              #pragma omp for schedule(dynamic, 16)
              for (int i = 0; i < N; i++) for (int k = 0; k < K; k++) {
                  double f = lo + (hi - lo) * h.u(); int x = (int)(f * L); if (x >= M) x = M - 1; u64 *pp = &P[(size_t)i * NW]; std::copy(pp, pp + NW, q.begin());
                  int wd = x >> 6, b = x & 63; q[wd] = (q[wd] & ((1ull << b) - 1)) | (h.next() & ~((1ull << b) - 1)); for (int z = wd + 1; z < NW; z++) q[z] = h.next();
                  int s = score(q.data(), a.data(), RM); int bin = std::min(11, (int)(f * 10)); T[bin]++; if (s >= L) { A[bin]++; std::copy(q.begin(), q.end(), pp); sc[i] = s; }
              }
              #pragma omp critical
              for (int z = 0; z < 12; z++) { acc[z] += A[z]; tot[z] += T[z]; } }
        }
        if (L % rep == 0 || L == RM) {
            std::vector<std::string> h; for (int i = 0; i < N; i++) { std::string s; for (int z = 0; z < L / 4; z++) s += (char)('0' + ((P[(size_t)i * NW + (z >> 6)] >> (z & 63)) & 1)); h.push_back(s); } std::sort(h.begin(), h.end()); size_t uq = std::unique(h.begin(), h.end()) - h.begin();
            printf("level %d  segment %.2f (%.3f a reading)  total %.2f  distinct first L/4 cells %zu  accept by x/L:", L, seg, seg / rep, lm, uq); for (int z = 0; z < 12; z++) if (tot[z] > 0) printf(" %.1f:%.2f", z / 10.0, acc[z] / tot[z]); printf("\n"); fflush(stdout); seg = 0; std::fill(acc.begin(), acc.end(), 0); std::fill(tot.begin(), tot.end(), 0);
        }
    }
    printf("read all %d\n", RM); std::string s; for (int z = 0; z < M; z++) s += (char)('0' + ((P[z >> 6] >> (z & 63)) & 1)); printf("row %s\n", s.c_str());
}
