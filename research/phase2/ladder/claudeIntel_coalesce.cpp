// K92.2, ledger N38 (claudeIntel). Do survivors past the support come in clusters of merged orbits?
//
// The 2^n seeds of the even-pin free cube at width 2n (gptIntel's free_cube.cpp, whose inverse is copied below)
// are run forward under the zero-wall F (Rule30ZeroBoundary.IntegerForm.F), which has up to two preimages
// (kit #369), so different seeds' orbits can merge. Check k past the support reads the row at tick 2n + 2(k-1).
// For each k: the seeds still alive (survivors of k-1 checks), the distinct rows among them at that tick,
// how many seeds pass check k, and how many distinct rows pass it.
//
// usage: coalesce n K
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>

using U = std::uint64_t;
constexpr U odd_depth = 0x5555555555555555ULL;
using Row = std::array<U, 3>;  // bit 0 of limb 0 is depth 1; 192 cells

// gptIntel's free_cube.cpp, rule 30 branch: the W initial cells from the free wall bits and the pin phase
static U inverse(unsigned free_bits, int width, int pin) {
    U even = free_bits;
    even = (even | (even << 16)) & 0x0000ffff0000ffffULL;
    even = (even | (even << 8)) & 0x00ff00ff00ff00ffULL;
    even = (even | (even << 4)) & 0x0f0f0f0f0f0f0f0fULL;
    even = (even | (even << 2)) & 0x3333333333333333ULL;
    even = (even | (even << 1)) & odd_depth;
    U a = (even << (1 - pin)) | (odd_depth << pin), b = 0, row = 0;
    for (int d = 1; d <= width; ++d) {
        row |= (a & 1) << (d - 1);
        U side = b | a;
        U c = (a >> 1) ^ side;
        b = a;
        a = c;
    }
    return row;
}

static inline Row F(const Row& y) {
    Row r;
    for (int i = 0; i < 3; ++i) {
        const U down = (y[i] >> 1) | (i + 1 < 3 ? y[i + 1] << 63 : 0);
        const U up = (y[i] << 1) | (i > 0 ? y[i - 1] >> 63 : 0);
        r[i] = down ^ (y[i] | up);
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::fprintf(stderr, "usage: coalesce n K\n"); return 2; }
    const int n = std::stoi(argv[1]), K = std::stoi(argv[2]);
    if (n < 1 || n > 30 || K < 1 || 4 * n + 2 * K > 190) { std::fprintf(stderr, "bad arguments\n"); return 2; }
    const int width = 2 * n;
    std::vector<std::pair<Row, uint32_t>> cur;
    cur.reserve(size_t(1) << n);
    for (unsigned f = 0; f < (1u << n); ++f) {
        Row y{inverse(f, width, 0), 0, 0};
        for (int t = 0; t < width; ++t) {
            if (t % 2 == 0 && !(y[0] & 1)) { std::fprintf(stderr, "pin failed\n"); return 1; }
            y = F(y);
        }
        cur.push_back({y, 1});
    }
    std::printf("# coalesce n %d: check k reads tick 2n+2(k-1)\n# k alive_seeds distinct_rows seeds_passing rows_passing z_seeds z_rows max_cluster\n", n);
    for (int k = 1; k <= K && !cur.empty(); ++k) {
        std::sort(cur.begin(), cur.end(), [](const auto& a, const auto& b) { return a.first < b.first; });
        std::vector<std::pair<Row, uint32_t>> d;
        for (auto& e : cur) {
            if (!d.empty() && d.back().first == e.first) d.back().second += e.second;
            else d.push_back(e);
        }
        uint64_t alive = 0, pass = 0, dpass = 0; uint32_t mx = 0;
        std::vector<std::pair<Row, uint32_t>> nxt;
        for (auto& e : d) {
            alive += e.second; mx = std::max(mx, e.second);
            if (e.first[0] & 1) {
                pass += e.second; ++dpass;
                nxt.push_back({F(F(e.first)), e.second});
            }
        }
        const double zs = (pass - alive / 2.0) / std::sqrt(alive / 4.0);
        const double zr = (dpass - d.size() / 2.0) / std::sqrt(d.size() / 4.0);
        std::printf("%d %llu %zu %llu %llu %.2f %.2f %u\n", k, (unsigned long long)alive, d.size(),
                    (unsigned long long)pass, (unsigned long long)dpass, zs, zr, mx);
        std::fflush(stdout);
        cur.swap(nxt);
    }
    return 0;
}
