// Independent count for I229: gate words beside the alternating wall over all initial right prefixes (bit-sliced, 64 rows a word).
// usage: gate H first(1 black, 0 white)   -> number of words, largest bin, its word, total
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <unordered_map>
#include <vector>
#include <algorithm>
typedef uint64_t u64;
int main(int c, char **v) {
    int H = atoi(v[1]), first = atoi(v[2]);
    int W = first ? 2 * H : 2 * H - 1;            // cells in the light cone of the last reading
    int T = first ? 2 * H - 1 : 2 * H - 2;        // tick of the last reading
    static const u64 base[6] = {0xAAAAAAAAAAAAAAAAull, 0xCCCCCCCCCCCCCCCCull, 0xF0F0F0F0F0F0F0F0ull, 0xFF00FF00FF00FF00ull, 0xFFFF0000FFFF0000ull, 0xFFFFFFFF00000000ull};
    u64 outer = W > 6 ? 1ull << (W - 6) : 1;
    int nthreads = 11;
    std::vector<std::vector<uint32_t>> part(nthreads, std::vector<uint32_t>(1u << H, 0));
    #pragma omp parallel for schedule(static) num_threads(11)
    for (long long th = 0; th < nthreads; th++) {
        auto &cnt = part[th];
        for (u64 o = outer * th / nthreads; o < outer * (th + 1) / nthreads; o++) {
            u64 row[64], nx[64];
            for (int i = 0; i < W; i++) row[i] = i < 6 ? base[i] : ((o >> (i - 6)) & 1 ? ~0ull : 0ull);
            u64 read[32]; int nr = 0; int len = W;
            for (int t = 0; t <= T; t++) {
                int wall = (first + t) & 1;        // first=1: black at even ticks
                if (!wall) read[nr++] = row[0];
                if (t == T) break;
                for (int i = 0; i + 1 < len; i++) { u64 l = i ? row[i - 1] : (wall ? ~0ull : 0ull); nx[i] = l ^ (row[i] | row[i + 1]); }
                len--;
                for (int i = 0; i < len; i++) row[i] = nx[i];
            }
            for (int b = 0; b < 64; b++) { uint32_t w = 0; for (int k = 0; k < nr; k++) w = w << 1 | ((read[k] >> b) & 1); cnt[w]++; }
        }
    }
    std::vector<u64> cnt(1u << H, 0); u64 tot = 0, best = 0; uint32_t bw = 0; int nz = 0; bool eleven = false;
    for (auto &p : part) for (uint32_t i = 0; i < (1u << H); i++) cnt[i] += p[i];
    for (uint32_t i = 0; i < (1u << H); i++) if (cnt[i]) { nz++; tot += cnt[i]; if (cnt[i] > best) { best = cnt[i]; bw = i; } if (i & (i >> 1)) eleven = true; }
    printf("H=%d first=%s cells=%d words=%d total=2^%d:%s max=%llu word=", H, first ? "black" : "white", W, nz, W, tot == (1ull << W) ? "ok" : "BAD", (unsigned long long)best);
    for (int k = H - 1; k >= 0; k--) putchar('0' + ((bw >> k) & 1));
    printf(" prob=%.6f two-blacks=%d\n", (double)best / (double)(1ull << W), eleven);
}
