// claudeIntel, N19: physical rows for every order of the blocks A = 3 5^a and B = 3 5^b up to DEPTH blocks, by splitting along the binary tree of orders.
// Every node keeps N initial rows that read the order and the next block's first 1001.  usage: tree10 N K DEPTH SEED OUT [a b | --isolated-wheel]
// With --isolated-wheel, the output labels A and B denote the macro-blocks A and AB.
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <omp.h>
typedef uint64_t u64;
struct Rng { u64 s; u64 next() { s += 0x9E3779B97F4A7C15ull; u64 z = s; z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ull; z = (z ^ (z >> 27)) * 0x94D049BB133111EBull; return z ^ (z >> 31); } double u() { return (next() >> 11) * 0x1.0p-53; } };
static int N, K, DEPTH, NW, M, ra = 3, rb = 5; static bool isolatedWheel = false; static std::vector<Rng> R; static FILE *out; static long done = 0, fail = 0;
static int score(const u64 *row, u64 *a, const std::string &w) {
    int stop = (int)w.size(); int nw = std::min(NW, (2 * stop + 190) / 64); std::copy(row, row + nw, a);
    if ((int)(a[0] & 1) != w[0] - '0') return 0;
    for (int s = 1; s < stop; s++) {
        for (u64 wall = 0; wall < 2; wall++) { int n = std::min(nw, (2 * (stop - s) + 130) / 64 + 1); u64 c = wall;
            for (int k = 0; k < n; k++) { u64 x = a[k], l = (x << 1) | c, r = (x >> 1) | (k + 1 < nw ? a[k + 1] << 63 : 0); c = x >> 63; a[k] = l ^ (x | r); } }
        if ((int)(a[0] & 1) != w[s] - '0') return s;
    }
    return stop;
}
static std::string blk(char c) {
    std::string block = "100";
    for (int i = 0; i < (c == 'A' ? ra : rb); i++) block += "10000";
    if (isolatedWheel && c == 'B') return blk('A') + block;
    return block;
}
// raise population P (all reading w up to level L) to level w.size(); returns false if it dies
static bool raise(std::vector<u64> &P, const std::string &w, int L, double &cost) {
    int n = (int)(P.size() / NW), T = (int)w.size(); std::vector<int> sc(n);
    #pragma omp parallel
    { std::vector<u64> a(NW);
      #pragma omp for schedule(dynamic, 64)
      for (int i = 0; i < n; i++) sc[i] = score(&P[(size_t)i * NW], a.data(), w); }
    for (int l = L + 1; l <= T; l++) {
        std::vector<int> ok; for (int i = 0; i < n; i++) if (sc[i] >= l) ok.push_back(i); if (ok.empty()) return false;
        if ((int)ok.size() == n) continue; cost -= log2((double)ok.size() / n); Rng &g = R[0];
        for (int i = 0; i < n; i++) if (sc[i] < l) { int j = ok[g.next() % ok.size()]; std::copy(&P[(size_t)j * NW], &P[(size_t)j * NW] + NW, &P[(size_t)i * NW]); sc[i] = sc[j]; }
        #pragma omp parallel
        { Rng &h = R[omp_get_thread_num()]; std::vector<u64> a(NW), q(NW);
          #pragma omp for schedule(dynamic, 16)
          for (int i = 0; i < n; i++) for (int k = 0; k < K; k++) {
              int x = (int)((0.25 + 0.6 * h.u()) * l); u64 *pp = &P[(size_t)i * NW]; std::copy(pp, pp + NW, q.begin()); int wd = x >> 6, b = x & 63;
              q[wd] = (q[wd] & ((1ull << b) - 1)) | (h.next() & ~((1ull << b) - 1)); for (int z = wd + 1; z < NW; z++) q[z] = h.next();
              int s = score(q.data(), a.data(), w); if (s >= l) { std::copy(q.begin(), q.end(), pp); sc[i] = s; } } }
    }
    return true;
}
static void visit(const std::vector<u64> &P, const std::string &ord, const std::string &w, double cost) {
    if ((int)ord.size() == DEPTH) return;
    for (char c : {'A', 'B'}) {
        std::string w2 = w.substr(0, w.size() - 4) + blk(c) + "1001"; double cc = cost; bool ok = false; std::vector<u64> Q;
        for (int mult = 1; mult <= 16 && !ok; mult *= 4) {        // more copies if the branch dies
            Q.clear(); for (int m = 0; m < mult; m++) Q.insert(Q.end(), P.begin(), P.end()); cc = cost; ok = raise(Q, w2, (int)w.size(), cc); }
        if (!ok) { fail++; printf("FAILED %s%c\n", ord.c_str(), c); fflush(stdout); continue; }
        if ((int)Q.size() > N * NW) Q.resize((size_t)N * NW);
        std::string s; for (int z = 0; z < 2 * (int)w2.size() - 1; z++) s += (char)(48 + ((Q[z >> 6] >> (z & 63)) & 1));
        fprintf(out, "%s%c %.2f %s\n", ord.c_str(), c, cc, s.c_str()); fflush(out); done++;
        if (done % 100 == 0) { printf("%ld orders, at %s%c, cost %.1f\n", done, ord.c_str(), c, cc); fflush(stdout); }
        visit(Q, ord + c, w2, cc);
    }
}
int main(int c, char **v) {
    N = atoi(v[1]); K = atoi(v[2]); DEPTH = atoi(v[3]); u64 seed = strtoull(v[4], 0, 10); out = fopen(v[5], "w"); if (c > 7) { ra = atoi(v[6]); rb = atoi(v[7]); }
    isolatedWheel = c == 7 && std::string(v[6]) == "--isolated-wheel";
    const int blockLength = static_cast<int>(std::max(blk('A').size(), blk('B').size()));
    M = 2 * (DEPTH * blockLength + 4) + 66; NW = (M + 63) / 64; int nt = omp_get_max_threads(); R.resize(nt); for (int i = 0; i < nt; i++) R[i].s = seed * 1000003ull + i * 7919 + 1;
    std::vector<u64> P((size_t)N * NW); std::string w = "1001";
    #pragma omp parallel
    { Rng &g = R[omp_get_thread_num()]; std::vector<u64> a(NW);
      #pragma omp for schedule(dynamic, 64)
      for (int i = 0; i < N; i++) { u64 *p = &P[(size_t)i * NW]; do { for (int k = 0; k < NW; k++) p[k] = g.next(); } while (score(p, a.data(), w) < 4); } }
    visit(P, "", w, 0); printf("orders %ld, failed branches %ld\n", done, fail);
}
