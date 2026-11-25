// claudeIntel, N19: the same event on a strip of W cells whose east bit is a fair coin at every tick: exact masses turn by turn for a periodic word.
// With FULL = 0: every row of the W cells starts equally likely.   usage: qs WORDFILE W PERIOD TURNS
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>
#include <omp.h>
typedef uint64_t u64; struct E { u64 k; float w; };
int main(int c, char **v) {
    std::string w; std::ifstream(v[1]) >> w; int W = atoi(v[2]), P = atoi(v[3]), T = atoi(v[4]); u64 m = (1ull << W) - 1; const int Z = 256; int nt = omp_get_max_threads();
    // grow the width gradually so that the start is the set of rows compatible with a few turns: start at width 16 uniform, add a fair cell every PERIOD readings
    int W0 = 14; std::vector<E> s; for (u64 i = 0; i < (1ull << W0); i++) if ((int)(i & 1) == w[0] - '0') s.push_back({i, 1.0f}); int cur = W0; size_t t = 0; double seg = 0, tot = 0; int turn = 0; int full = 0;
    { double z = 0; for (auto &e : s) z += e.w; for (auto &e : s) e.w /= z; }
    while (turn < T) {
        u64 mc = (1ull << cur) - 1; u64 need = w[(t + 1) % w.size()] - '0';
        std::vector<std::vector<std::vector<E>>> b(nt, std::vector<std::vector<E>>(Z));
        #pragma omp parallel for schedule(static)
        for (long long i = 0; i < (long long)s.size(); i++) { int th = omp_get_thread_num(); u64 x = s[i].k;
            for (u64 e1 = 0; e1 < 2; e1++) { u64 y = ((x << 1) & mc) ^ (x | (x >> 1) | (e1 << (cur - 1)));
                for (u64 e2 = 0; e2 < 2; e2++) { u64 q = (((y << 1) & mc) | 1) ^ (y | (y >> 1) | (e2 << (cur - 1))); if ((q & 1) == need) b[th][(q * 0x9E3779B97F4A7C15ull) >> 56].push_back({q, s[i].w * 0.25f}); } } }
        std::vector<std::vector<E>> o(Z);
        #pragma omp parallel for schedule(dynamic, 1)
        for (int z = 0; z < Z; z++) { auto &r = o[z]; for (int th = 0; th < nt; th++) { r.insert(r.end(), b[th][z].begin(), b[th][z].end()); std::vector<E>().swap(b[th][z]); } std::sort(r.begin(), r.end(), [](const E &a, const E &d) { return a.k < d.k; });
            size_t n = 0; for (size_t i = 0; i < r.size(); i++) { if (n && r[n - 1].k == r[i].k) r[n - 1].w += r[i].w; else r[n++] = r[i]; } r.resize(n); }
        double z = 0; size_t n = 0; for (auto &r : o) { n += r.size(); for (auto &e : r) z += e.w; }
        if (z <= 0) { printf("W %d dead at reading %zu\n", cur, t + 1); return 0; }
        s.clear(); s.reserve(n); for (auto &r : o) for (auto &e : r) s.push_back({e.k, (float)(e.w / z)}); seg += log2(z); t++;
        if (cur < W && t % (P / 4 ? P / 4 : 1) == 0) { size_t k = s.size(); s.resize(2 * k); for (size_t i = 0; i < k; i++) { s[i].w *= 0.5f; s[k + i] = {s[i].k | (1ull << cur), s[i].w}; } cur++; if (cur == W) { full = 1; seg = 0; } }
        else if (full && t % P == 0) { turn++; tot += seg; printf("W %d turn %d after full width: cost %.3f bits, states %zu\n", W, turn, -seg, s.size()); fflush(stdout); seg = 0; }
    }
}
