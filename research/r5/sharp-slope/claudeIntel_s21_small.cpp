// claudeIntel, N18: exact latest gate tick outside the S16 trap over all right halves of support exactly D, each drive and phase.  usage: small LEANFILE DMAX
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <omp.h>
typedef uint64_t u64;
static std::vector<char> trap(const std::string &s, const char *name) {
    std::vector<char> t(1 << 14, 0); size_t i = s.find(std::string("def ") + name + " : List Nat := ["); size_t j = s.find(']', i); i = s.find('[', i) + 1;
    std::stringstream ss(s.substr(i, j - i)); std::string w; while (std::getline(ss, w, ',')) t[atoi(w.c_str())] = 1; return t;
}
int main(int c, char **v) {
    std::ifstream f(v[1]); std::stringstream b; b << f.rdbuf(); int DM = atoi(v[2]);
    std::vector<char> T[2] = {trap(b.str(), "trap001"), trap(b.str(), "trap011")}; int W[2][3] = {{0, 0, 1}, {0, 1, 1}}, G[2] = {1, 0};
    for (int d = 0; d < 2; d++) for (int D = 1; D <= DM; D++) {
        int best[3] = {-1, -1, -1}; u64 arg[3] = {0, 0, 0}; long bad = 0;
        for (int ph = 0; ph < 3; ph++) {
            #pragma omp parallel for schedule(dynamic, 4096) reduction(+:bad)
            for (long long r = 1ll << (D - 1); r < (1ll << D); r++) {
                u64 x[8] = {(u64)r, 0, 0, 0, 0, 0, 0, 0}; int last = -1, n = (D + 63) / 64;
                int t = 0;
                for (; t < 440; t++) {
                    if ((t + ph) % 3 == G[d]) { if (T[d][x[0] & 0x3fff]) break; last = t; }
                    n = (D + t + 64) / 64; if (n > 8) n = 8;
                    u64 y[8]; u64 carry = W[d][(t + ph) % 3];
                    for (int k = 0; k < n; k++) { u64 l = (x[k] << 1) | carry; carry = x[k] >> 63; u64 rr = (x[k] >> 1) | (k + 1 < 8 ? x[k + 1] << 63 : 0); y[k] = l ^ (x[k] | rr); }
                    for (int k = 0; k < n; k++) x[k] = y[k];
                }
                if (t == 440) bad++;
                if (last > best[ph]) {
                    #pragma omp critical
                    if (last > best[ph]) { best[ph] = last; arg[ph] = r; }
                }
            }
        }
        printf("%s D %2d latest outside by phase %4d %4d %4d   3D-latest %4d   rows not in by 440: %ld   witness %llx\n", d ? "011" : "001", D, best[0], best[1], best[2],
               3 * D - (best[0] > best[1] ? (best[0] > best[2] ? best[0] : best[2]) : (best[1] > best[2] ? best[1] : best[2])), bad, (unsigned long long)arg[0]); fflush(stdout);
    }
}
