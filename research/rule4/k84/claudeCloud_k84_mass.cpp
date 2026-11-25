// claudeCloud_k84_mass.cpp: the share of fair right halves that supply a given demand (ledger K84).
//
// Beside a centre black at even ticks, a right half reads cell 1 at ticks 1, 3, 5, ... For a demand word d of S
// readings, m(s) is the fair mass of right halves whose readings 0 .. s-1 equal d. Cell 1 at tick t depends on the
// cells 1 .. t+1 at tick 0, so a right half is drawn one cell at a time: after cell k the cells (j, t) with j + t = k
// (diagonal k) are known, from diagonals k-1 and k-2:
//     D_k[0] = the new cell;  D_k[t] = D_{k-2}[t-1] xor (D_{k-1}[t-1] or D_k[t-1]),  D_k[k-1] uses the centre at t-1,
// where D_k[t] is cell k-t at tick t. Reading s is D_{2s+2}[2s+1].
//
//   smc D N SEED        sequential Monte Carlo with N particles: extend every particle by one fair cell, keep those
//                       whose new reading matches, resample N from them; m(s) is the product of the kept shares.
//                       Unbiased for each m(s). Prints s, kept share, log2 m(s).
//   exact D SMAX        exact count of the cell prefixes 1 .. 2s+2 that read d's first s+1 readings, s < SMAX, by a
//                       pruned search: m(s) = count / 2^(2s+2). (SMAX <= 16.)
//
//   g++ -O3 -fopenmp -std=c++17 claudeCloud_k84_mass.cpp -o k84_mass
#include <cmath>
#include <functional>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <omp.h>
using namespace std;
typedef uint64_t u64;
static const int NW = 2;                      // diagonals up to 128 cells (S <= 63)
struct P { u64 a[NW], b[NW]; };               // a = D_{k-1}, b = D_{k-2}
static inline int gb(const u64 *d, int t) { return (d[t >> 6] >> (t & 63)) & 1; }
static inline void sb(u64 *d, int t, int v) { if (v) d[t >> 6] |= 1ULL << (t & 63); }
static inline int wallAt(int t) { return (t % 2 == 0) ? 1 : 0; }
static inline u64 splitmix(u64 &x) { u64 z = (x += 0x9E3779B97F4A7C15ULL); z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }

// build diagonal k (k >= 1) from a = D_{k-1}, b = D_{k-2} and the new cell; returns D_k in out
static inline void extend(const u64 *a, const u64 *b, int k, int cell, u64 *out) {
    for (int i = 0; i < NW; ++i) out[i] = 0;
    int prev = cell; sb(out, 0, cell);
    for (int t = 1; t <= k - 1; ++t) {
        int left = (t <= k - 2) ? gb(b, t - 1) : wallAt(t - 1);   // cell k-t-1 at tick t-1, or the centre
        int v = left ^ (gb(a, t - 1) | prev);
        sb(out, t, v); prev = v;
    }
}

static int smc(const string &d, long N, u64 seed) {
    int S = d.size();
    if (2 * S + 2 > 64 * NW) { fprintf(stderr, "demand too long\n"); return 1; }
    vector<P> cur(N), nxt(N);
    for (auto &p : cur) memset(&p, 0, sizeof p);
    double logm = 0; bool dead = false;
    printf("smc: %d readings, %ld particles, seed %llu\n", S, N, (unsigned long long)seed);
    printf("   s  kept-share  log2 m(s)\n");
    vector<char> keep(N);
    for (int k = 1; k <= 2 * S; ++k) {
        bool check = (k % 2 == 0);
        int s = k / 2 - 1;
        long kept = 0;
        #pragma omp parallel for reduction(+:kept) schedule(static)
        for (long i = 0; i < N; ++i) {
            u64 st = seed ^ (0x9E3779B97F4A7C15ULL * (u64)(k * 1000003LL + 7)) ^ ((u64)i * 0xD1B54A32D192ED03ULL);
            int cell = splitmix(st) & 1;
            u64 out[NW]; extend(cur[i].a, cur[i].b, k, cell, out);
            P q; memcpy(q.b, cur[i].a, sizeof q.b); memcpy(q.a, out, sizeof q.a);
            cur[i] = q;
            if (check) { int r = gb(out, k - 1); keep[i] = (r == d[s] - '0'); kept += keep[i]; }
        }
        if (!check) continue;
        if (kept == 0) { printf("  %2d  0           -inf (no particle kept)\n", s); dead = true; break; }
        double f = kept / (double)N; logm += log2(f);
        printf("  %2d  %.6f  %9.4f\n", s, f, logm);
        // resample N from the kept particles, uniformly (multinomial)
        vector<long> idx; idx.reserve(kept);
        for (long i = 0; i < N; ++i) if (keep[i]) idx.push_back(i);
        u64 st = seed * 31 + k;
        for (long i = 0; i < N; ++i) nxt[i] = cur[idx[splitmix(st) % idx.size()]];
        cur.swap(nxt);
    }
    if (!dead) printf("final log2 m(%d) = %.4f\n", S, logm);
    return 0;
}

static long long exactCount(const string &d, int SMAX, vector<long long> &cnt) {
    // depth-first over cells, pruning at each reading
    cnt.assign(SMAX, 0);
    struct Frame { u64 a[NW], b[NW]; };
    // recursive lambda
    std::function<void(int, const u64*, const u64*)> rec = [&](int k, const u64 *a, const u64 *b) {
        for (int cell = 0; cell < 2; ++cell) {
            u64 out[NW]; extend(a, b, k, cell, out);
            if (k % 2 == 0) {
                int s = k / 2 - 1;
                if (gb(out, k - 1) != d[s] - '0') continue;
                ++cnt[s];
                if (s + 1 >= SMAX) continue;
            }
            rec(k + 1, out, a);
        }
    };
    u64 z[NW] = {0, 0};
    rec(1, z, z);
    return 0;
}

#include <functional>
int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: k84_mass smc D N SEED | exact D SMAX\n"); return 1; }
    string mode = argv[1], d = argv[2];
    for (char c : d) if (c != '0' && c != '1') { fprintf(stderr, "demand must be 0/1\n"); return 1; }
    if (mode == "smc") return smc(d, atol(argv[3]), argc > 4 ? strtoull(argv[4], nullptr, 10) : 84);
    if (mode == "exact") {
        int SMAX = atoi(argv[3]); if (SMAX > 16 || SMAX > (int)d.size()) { fprintf(stderr, "SMAX <= 16 and <= |D|\n"); return 1; }
        vector<long long> cnt; exactCount(d, SMAX, cnt);
        printf("exact: first %d readings\n   s  count  log2 m(s)\n", SMAX);
        for (int s = 0; s < SMAX; ++s) printf("  %2d  %lld  %9.4f\n", s, cnt[s], cnt[s] ? log2((double)cnt[s]) - (2 * s + 2) : -INFINITY);
        return 0;
    }
    return 1;
}
