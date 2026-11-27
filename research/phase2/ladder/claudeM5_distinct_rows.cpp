// K92.2, claudeM5: the distinct rows at the end of the support, D(n) = E(n, n, 2n), and the shape of their set.
//
// A seed y < 4^n beside the white wall is in the even-pin cube when its trace (bit 0 under the zero-wall map
// F(y) = (y >> 1) ^ (y | (y << 1)), bit d-1 = depth d) is black at ticks 0, 2, ..., 2n-2. The trace prefix of
// length 2n determines the seed (left permutivity), so the cube has 2^n seeds, one per choice of the odd readings.
// D(n) counts the distinct rows F^{2n}(y) over the cube.
//
// This program is written apart from claudeIntel_coalesce.cpp: its own decoder, 128-bit rows, chunked sorting
// and a sorted global merge, so that n up to 32 fits in memory.
//
//   distinct_rows count n THREADS CHUNKLOG [OUT.bin]    D(n), and D(n, W) by the width W of the row at tick 2n;
//                                                       OUT.bin gets the sorted distinct rows (16 bytes each)
//   distinct_rows levels FILE.bin L                     level widths of the minimal acyclic DFA of the set, as
//                                                       words of length L read from the wall and from depth L
//   distinct_rows cube n                                the same level widths for the cube itself (tick 0, L = 2n)
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

using u64 = std::uint64_t;
using u128 = unsigned __int128;

struct H128 {
    size_t operator()(u128 x) const {
        u64 a = (u64)x * 0x9E3779B97F4A7C15ULL, b = (u64)(x >> 64) * 0xC2B2AE3D27D4EB4FULL;
        return (size_t)(a ^ (b >> 29) ^ (b << 7));
    }
};
struct HPair {
    size_t operator()(const std::pair<uint32_t, uint32_t>& p) const { return ((size_t)p.first << 32 | p.second) * 0x9E3779B97F4A7C15ULL; }
};

static inline u128 F(u128 y) { return (y >> 1) ^ (y | (y << 1)); }

static inline int width_of(u128 y) {
    u64 hi = (u64)(y >> 64), lo = (u64)y;
    if (hi) return 128 - __builtin_clzll(hi);
    if (lo) return 64 - __builtin_clzll(lo);
    return 0;
}

// The seed whose trace prefix of length 2n is `tr` (bit t = reading at tick t). Column d of the space-time,
// as a mask over ticks, gives the next one by col[d+1] = (col[d] >> 1) ^ (col[d] | col[d-1]); the seed's
// depth d is bit 0 of col[d]. Only ticks below 2n matter for depths up to 2n.
static inline u64 decode(u64 tr, int n) {
    u64 a = tr, b = 0, y = 0;
    for (int d = 0; d < 2 * n; ++d) {
        y |= (a & 1) << d;
        u64 c = (a >> 1) ^ (a | b);
        b = a;
        a = c;
    }
    return y;
}

static inline u64 spread_odd(u64 f, int n) {     // free reading i goes to tick 2i + 1
    u64 t = 0;
    for (int i = 0; i < n; ++i) t |= ((f >> i) & 1) << (2 * i + 1);
    return t;
}

static u128 image(u64 f, int n, u64 pins) {
    const u64 tr = pins | spread_odd(f, n);
    u128 y = decode(tr, n);
    for (int t = 0; t < 2 * n; ++t) {
        if ((u64)(y & 1) != ((tr >> t) & 1)) { std::fprintf(stderr, "trace mismatch at f=%llu t=%d\n", (unsigned long long)f, t); std::exit(1); }
        y = F(y);
    }
    return y;
}

static void sort_unique(std::vector<u128>& v) {
    std::sort(v.begin(), v.end());
    v.erase(std::unique(v.begin(), v.end()), v.end());
}

static int count_main(int n, int threads, int chunklog, const char* out) {
    if (n < 1 || n > 32) { std::fprintf(stderr, "n must be 1..32\n"); return 2; }
    if (chunklog > n) chunklog = n;
    u64 pins = 0;
    for (int i = 0; i < n; ++i) pins |= 1ULL << (2 * i);
    const u64 nchunks = 1ULL << (n - chunklog), csize = 1ULL << chunklog;
    std::vector<u128> global;
    for (u64 c0 = 0; c0 < nchunks; c0 += threads) {
        const int k = (int)std::min<u64>(threads, nchunks - c0);
        std::vector<std::vector<u128>> part(k);
        std::vector<std::thread> pool;
        for (int i = 0; i < k; ++i) pool.emplace_back([&, i] {
            auto& v = part[i];
            v.resize(csize);
            const u64 base = (c0 + i) * csize;
            for (u64 j = 0; j < csize; ++j) v[j] = image(base + j, n, pins);
            sort_unique(v);
        });
        for (auto& th : pool) th.join();
        for (int i = 0; i < k; ++i) {
            std::vector<u128> merged;
            merged.reserve(global.size() + part[i].size());
            std::merge(global.begin(), global.end(), part[i].begin(), part[i].end(), std::back_inserter(merged));
            merged.erase(std::unique(merged.begin(), merged.end()), merged.end());
            global.swap(merged);
            std::vector<u128>().swap(part[i]);
        }
    }
    std::map<int, u64> byw;
    for (auto& r : global) byw[width_of(r)]++;
    std::printf("n %d D %zu\n", n, global.size());
    std::printf("widths");
    for (auto& [w, c] : byw) std::printf(" %d:%llu", w, (unsigned long long)c);
    std::printf("\n");
    if (out) {
        FILE* f = std::fopen(out, "wb");
        if (!f) return 3;
        std::fwrite(global.data(), sizeof(u128), global.size(), f);
        std::fclose(f);
    }
    return 0;
}

// Level widths of the minimal acyclic DFA of a set of words of length L. Words are given as integers whose
// bit i (i = 0..L-1) is letter i, read in the order the DFA reads. State of a prefix = the pair of states of its
// two one-letter extensions (0 if absent), merged bottom-up: the number of distinct states at level i is the
// number of distinct right languages after i letters.
static std::vector<u64> level_widths(const std::vector<u128>& words, int L) {
    // key at level i: the first i letters, as the low i bits
    std::vector<u64> width(L + 1, 0);
    std::unordered_map<u128, uint32_t, H128> cur, nxt;
    for (auto& w : words) cur[w] = 1;                        // level L: accepting
    width[L] = 1;
    for (int i = L - 1; i >= 0; --i) {
        const u128 mask = i == 0 ? (u128)0 : (((u128)1 << i) - 1);
        std::unordered_map<u128, std::pair<uint32_t, uint32_t>, H128> kids;
        kids.reserve(cur.size());
        for (auto& [p, s] : cur) {
            u128 q = p & mask;
            int bit = (int)((p >> i) & 1);
            auto& e = kids[q];
            if (bit) e.second = s; else e.first = s;
        }
        std::unordered_map<std::pair<uint32_t, uint32_t>, uint32_t, HPair> ids;
        nxt.clear();
        nxt.reserve(kids.size());
        for (auto& [q, pr] : kids) {
            auto it = ids.find(pr);
            uint32_t id;
            if (it == ids.end()) { id = (uint32_t)ids.size() + 1; ids.emplace(pr, id); } else id = it->second;
            nxt[q] = id;
        }
        width[i] = ids.size();
        cur.swap(nxt);
    }
    return width;
}

static u128 reverse_bits(u128 w, int L) {
    u128 r = 0;
    for (int i = 0; i < L; ++i) if ((w >> i) & 1) r |= (u128)1 << (L - 1 - i);
    return r;
}

static void print_levels(const char* tag, const std::vector<u128>& words, int L) {
    for (int dir = 0; dir < 2; ++dir) {
        std::vector<u128> w = words;
        if (dir == 1) for (auto& x : w) x = reverse_bits(x, L);
        auto lw = level_widths(w, L);
        u64 mx = 0, tot = 0; int at = 0;
        for (int i = 0; i <= L; ++i) { tot += lw[i]; if (lw[i] > mx) { mx = lw[i]; at = i; } }
        std::printf("%s %s L %d words %zu states %llu max_level %llu at %d levels", tag, dir ? "from_depth_L" : "from_wall",
                    L, words.size(), (unsigned long long)tot, (unsigned long long)mx, at);
        for (int i = 0; i <= L; ++i) std::printf(" %llu", (unsigned long long)lw[i]);
        std::printf("\n");
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::fprintf(stderr, "usage: see the header\n"); return 2; }
    std::string mode = argv[1];
    if (mode == "count" && argc >= 5) return count_main(std::atoi(argv[2]), std::atoi(argv[3]), std::atoi(argv[4]), argc > 5 ? argv[5] : nullptr);
    if (mode == "levels" && argc >= 4) {
        FILE* f = std::fopen(argv[2], "rb");
        if (!f) return 3;
        std::vector<u128> v;
        u128 x;
        while (std::fread(&x, sizeof x, 1, f) == 1) v.push_back(x);
        std::fclose(f);
        print_levels("rows", v, std::atoi(argv[3]));
        return 0;
    }
    if (mode == "cube") {
        const int n = std::atoi(argv[2]);
        u64 pins = 0;
        for (int i = 0; i < n; ++i) pins |= 1ULL << (2 * i);
        std::vector<u128> v;
        for (u64 f0 = 0; f0 < (1ULL << n); ++f0) v.push_back(decode(pins | spread_odd(f0, n), n));
        sort_unique(v);
        print_levels("cube", v, 2 * n);
        return 0;
    }
    std::fprintf(stderr, "usage: see the header\n");
    return 2;
}
