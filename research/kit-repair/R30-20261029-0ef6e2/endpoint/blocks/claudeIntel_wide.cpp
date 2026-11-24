// Can a right half read this gate word?  All rows of W cells compatible so far, east input free; W grows by one every DW samples.  (claudeIntel)
// usage: wide WORDFILE W0 W1 DW [MAXROWS]     WORDFILE: 0/1 string of readings at white ticks.  Prints rows left at the end of each width.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <fstream>
#include <algorithm>
#include <omp.h>
typedef uint64_t u64;
int main(int c, char **v) {
    std::string w; std::ifstream(v[1]) >> w; int W = atoi(v[2]), W1 = atoi(v[3]), DW = atoi(v[4]); size_t cap = c > 5 ? strtoull(v[5], 0, 10) : 200000000;
    const int P = 64; int nt = 11; omp_set_num_threads(nt);
    std::vector<u64> s; for (u64 i = 0; i < (1ull << W); i++) if ((i & 1) == (u64)(w[0] - '0')) s.push_back(i);
    size_t t = 0; size_t peak = s.size();
    for (;;) {
        for (int k = 0; k < DW && t + 1 < w.size(); k++, t++) {
            u64 m = (1ull << W) - 1, need = w[t + 1] - '0';
            std::vector<std::vector<std::vector<u64>>> buck(nt, std::vector<std::vector<u64>>(P));
            #pragma omp parallel for schedule(static)
            for (long long i = 0; i < (long long)s.size(); i++) {
                int th = omp_get_thread_num(); u64 x = s[i];
                for (u64 e1 = 0; e1 < 2; e1++) {
                    u64 y = ((x << 1) & m) ^ (x | (x >> 1) | (e1 << (W - 1)));
                    for (u64 e2 = 0; e2 < 2; e2++) {
                        u64 z = (((y << 1) & m) | 1) ^ (y | (y >> 1) | (e2 << (W - 1)));
                        if ((z & 1) == need) buck[th][(z * 0x9E3779B97F4A7C15ull) >> 58].push_back(z);
                    }
                }
            }
            std::vector<std::vector<u64>> out(P);
            #pragma omp parallel for schedule(dynamic, 1)
            for (int p = 0; p < P; p++) {
                auto &o = out[p]; for (int th = 0; th < nt; th++) { o.insert(o.end(), buck[th][p].begin(), buck[th][p].end()); std::vector<u64>().swap(buck[th][p]); }
                std::sort(o.begin(), o.end()); o.erase(std::unique(o.begin(), o.end()), o.end());
            }
            size_t n = 0; for (auto &o : out) n += o.size();
            s.clear(); s.reserve(n); for (auto &o : out) s.insert(s.end(), o.begin(), o.end());
            if (n > peak) peak = n;
            if (!n) { printf("dies at width %d: reading %zu cannot be continued\n", W, t + 1); return 0; }
            if (n > cap) { printf("stopped: %zu rows at width %d, reading %zu\n", n, W, t + 1); return 0; }
        }
        printf("width %d done at reading %zu: %zu rows\n", W, t, s.size()); fflush(stdout);
        if (W == W1 || t + 1 >= w.size()) { printf("survives to width %d, reading %zu, %zu rows, peak %zu\n", W, t, s.size(), peak); return 0; }
        size_t n = s.size(); s.resize(2 * n); for (size_t i = 0; i < n; i++) s[n + i] = s[i] | (1ull << W); W++;
    }
}
