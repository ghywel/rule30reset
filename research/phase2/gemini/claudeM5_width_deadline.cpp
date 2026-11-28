// K92.2.A, claudeM5 (M227), after the registration: LD(W), the latest first failure among rows of width at most W
// with depth 1 black, from I320's sparse tree restricted to positions below W (a row outside the tree has its
// ancestor node's failure, so the nodes give the latest failure).
// Also m(d), the exact largest delay d(child) - d(parent) over every parent failing at d: such a parent has width at
// most d + 1 (a node's width never exceeds its failure tick plus one), so for d < WMAX all of them and all their
// children lie in the tree of width WMAX.
// Usage: width_deadline WMAX THREADS   prints, for each W up to WMAX, the nodes of width at most W and LD(W), then m(d)
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>
using u64 = std::uint64_t;
struct Row { std::array<u64, 4> w{}; };
static inline Row F(const Row& y) {
    Row r;
    for (int i = 0; i < 4; ++i) {
        u64 down = (y.w[i] >> 1) | (i + 1 < 4 ? y.w[i + 1] << 63 : 0);
        u64 up = (y.w[i] << 1) | (i > 0 ? y.w[i - 1] >> 63 : 0);
        r.w[i] = down ^ (y.w[i] | up);
    }
    return r;
}
static inline int bitlen(const Row& y) {
    for (int i = 3; i >= 0; --i) if (y.w[i]) return 64 * i + 64 - __builtin_clzll(y.w[i]);
    return 0;
}
static int first_failure(Row y) {
    int t = 0;
    while (y.w[0] & 1) { y = F(F(y)); t += 2; if (t >= 250) { std::fprintf(stderr, "beyond range\n"); std::exit(1); } }
    return t;
}
static int WMAX;
struct Acc { std::vector<u64> n; std::vector<int> ld, m, mr; Acc() : n(WMAX + 1, 0), ld(WMAX + 1, -1), m(256, -1000), mr(256, -1000) {} };
static void visit(Acc& A, const Row& y, int d) {
    int w = bitlen(y);
    A.n[w]++; A.ld[w] = std::max(A.ld[w], d);
    for (int p = w; p <= d && p < WMAX; ++p) {
        Row c = y; c.w[p >> 6] |= 1ULL << (p & 63); int dc = first_failure(c);
        A.m[d] = std::max(A.m[d], dc - d); if (p == d) A.mr[d] = std::max(A.mr[d], dc - d);
        visit(A, c, dc);
    }
}
int main(int argc, char** argv) {
    WMAX = std::atoi(argv[1]); const int T = std::atoi(argv[2]);
    // work items: all nodes of width at most 12
    std::vector<std::pair<Row, int>> items, stack;
    Acc top;
    Row root; root.w[0] = 1;
    stack.push_back({root, first_failure(root)});
    while (!stack.empty()) {
        auto [y, d] = stack.back(); stack.pop_back();
        int w = bitlen(y);
        if (w >= 12 || w >= WMAX) { items.push_back({y, d}); continue; }
        top.n[w]++; top.ld[w] = std::max(top.ld[w], d);
        for (int p = w; p <= d && p < WMAX; ++p) {
            Row c = y; c.w[p >> 6] |= 1ULL << (p & 63); int dc = first_failure(c);
            top.m[d] = std::max(top.m[d], dc - d); if (p == d) top.mr[d] = std::max(top.mr[d], dc - d);
            stack.push_back({c, dc});
        }
    }
    std::atomic<size_t> next{0};
    std::vector<Acc> part(T);
    std::vector<std::thread> pool;
    for (int k = 0; k < T; ++k) pool.emplace_back([&, k] { for (size_t i; (i = next.fetch_add(1)) < items.size();) visit(part[k], items[i].first, items[i].second); });
    for (auto& th : pool) th.join();
    for (auto& a : part) {
        for (int w = 0; w <= WMAX; ++w) { top.n[w] += a.n[w]; top.ld[w] = std::max(top.ld[w], a.ld[w]); }
        for (int d = 0; d < 256; ++d) { top.m[d] = std::max(top.m[d], a.m[d]); top.mr[d] = std::max(top.mr[d], a.mr[d]); }
    }
    u64 cum = 0; int ld = -1;
    for (int w = 1; w <= WMAX; ++w) { cum += top.n[w]; ld = std::max(ld, top.ld[w]); std::printf("W %d nodes %llu LD %d\n", w, (unsigned long long)cum, ld); }
    for (int d = 0; d < WMAX; d += 2) if (top.m[d] > -1000) std::printf("m %d %d repair %d\n", d, top.m[d], top.mr[d]);
    return 0;
}
