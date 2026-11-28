// K92.2.A, claudeM5 (M227): how far can one more black cell delay the first failed check on the bare white wall?
//
// The sparse tree of I320 (gptIntel, sparse_wall.py): the root is the row 1 (one black cell at depth 1); a node y
// fails at d, its first even tick whose wall reading (bit 0 of F^d(y), F(y) = (y >> 1) ^ (y | (y << 1))) is white;
// its children are y + 2^p for p from bitlength(y) to d. A row outside the tree has the first failure of the node it
// extends (kit #367: adding 2^p beyond a node's failure tick keeps the readings before p). [Corrected after the
// registration: the frozen text said every such row is a node. Comment only.]
// Here, written apart from I320's two programs:
//   * per weight: nodes, the deadline (largest d) and the maximizers, with their parents (are maximizers nested?);
//   * the delay of each child, delta = d(child) - d(parent), its maximum by the parent's d and by the weight;
//   * the same for the repairing child alone, p = d, which flips the failed reading (kit #367) and passes it.
// Rows are 256-bit; a failure below 250 ticks is exact, since a truncated bit moves inward one site per tick.
//
//   sparse_delay tree B THREADS        statistics for weights 1..B
//   sparse_delay digest B              the preorder SHA-256 input of sparse_wall.py, "y weight d\n" per node, on stdout
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <mutex>
#include <string>
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
static inline Row with_bit(Row y, int p) { y.w[p >> 6] |= 1ULL << (p & 63); return y; }
static int first_failure(Row y) {
    int t = 0;
    while (y.w[0] & 1) {
        y = F(F(y));
        t += 2;
        if (t >= 250) { std::fprintf(stderr, "failure beyond the exact range\n"); std::exit(1); }
    }
    return t;
}
static std::string decimal(Row y) {   // 256-bit to decimal
    std::string s;
    bool zero = true;
    for (u64 x : y.w) if (x) zero = false;
    if (zero) return "0";
    while (true) {
        bool nz = false;
        for (u64 x : y.w) if (x) nz = true;
        if (!nz) break;
        unsigned __int128 rem = 0;
        for (int i = 3; i >= 0; --i) {
            unsigned __int128 cur = (rem << 64) | y.w[i];
            y.w[i] = (u64)(cur / 10);
            rem = cur % 10;
        }
        s.push_back(char('0' + (int)rem));
    }
    std::reverse(s.begin(), s.end());
    return s;
}

struct Stats {
    std::vector<u64> nodes;                      // by weight
    std::vector<int> best;                       // deadline by weight
    std::vector<std::vector<std::pair<Row, Row>>> argbest;   // (maximizer, parent) by weight
    std::map<int, int> maxDeltaByParentD, maxRepairByParentD;
    std::map<int, std::pair<Row, int>> witnessByParentD;     // parent row, child position
    std::vector<int> maxDeltaByWeight;           // by the child's weight
    std::map<int, u64> deltaHist, repairHist;
    explicit Stats(int B) : nodes(B + 2, 0), best(B + 2, -1), argbest(B + 2), maxDeltaByWeight(B + 2, -1000) {}
    void merge(const Stats& o) {
        for (size_t w = 0; w < nodes.size(); ++w) {
            nodes[w] += o.nodes[w];
            if (o.best[w] > best[w]) { best[w] = o.best[w]; argbest[w] = o.argbest[w]; }
            else if (o.best[w] == best[w] && best[w] >= 0) argbest[w].insert(argbest[w].end(), o.argbest[w].begin(), o.argbest[w].end());
            maxDeltaByWeight[w] = std::max(maxDeltaByWeight[w], o.maxDeltaByWeight[w]);
        }
        for (auto& [d, v] : o.maxDeltaByParentD) {
            auto it = maxDeltaByParentD.find(d);
            if (it == maxDeltaByParentD.end() || v > it->second) { maxDeltaByParentD[d] = v; witnessByParentD[d] = o.witnessByParentD.at(d); }
        }
        for (auto& [d, v] : o.maxRepairByParentD) maxRepairByParentD[d] = std::max(maxRepairByParentD.count(d) ? maxRepairByParentD[d] : -1000, v);
        for (auto& [k, v] : o.deltaHist) deltaHist[k] += v;
        for (auto& [k, v] : o.repairHist) repairHist[k] += v;
    }
};

static void note(Stats& S, const Row& y, const Row& parent, int w, int d) {
    S.nodes[w]++;
    if (d > S.best[w]) { S.best[w] = d; S.argbest[w].clear(); }
    if (d == S.best[w] && S.argbest[w].size() < 64) S.argbest[w].push_back({y, parent});
}

static void visit(Stats& S, const Row& y, int w, int d, int B) {
    if (w >= B) return;
    const int width = bitlen(y);
    for (int p = width; p <= d; ++p) {
        Row c = with_bit(y, p);
        int dc = first_failure(c);
        if (p % 2 == 0 && p < d && dc != p) { std::fprintf(stderr, "kit #367 fails: an even p < d should fail at p\n"); std::exit(1); }
        note(S, c, y, w + 1, dc);
        int delta = dc - d;
        S.deltaHist[delta]++;
        S.maxDeltaByWeight[w + 1] = std::max(S.maxDeltaByWeight[w + 1], delta);
        auto it = S.maxDeltaByParentD.find(d);
        if (it == S.maxDeltaByParentD.end() || delta > it->second) { S.maxDeltaByParentD[d] = delta; S.witnessByParentD[d] = {y, p}; }
        if (p == d) {
            S.repairHist[delta]++;
            auto jt = S.maxRepairByParentD.find(d);
            if (jt == S.maxRepairByParentD.end() || delta > jt->second) S.maxRepairByParentD[d] = delta;
        }
        visit(S, c, w + 1, dc, B);
    }
}

static void digest_visit(const Row& y, int w, int d, int B) {
    std::printf("%s %d %d\n", decimal(y).c_str(), w, d);
    if (w >= B) return;
    for (int p = bitlen(y); p <= d; ++p) { Row c = with_bit(y, p); digest_visit(c, w + 1, first_failure(c), B); }
}

int main(int argc, char** argv) {
    if (argc < 3) return 2;
    std::string mode = argv[1];
    const int B = std::atoi(argv[2]);
    Row root; root.w[0] = 1;
    const int d0 = first_failure(root);
    if (mode == "digest") { digest_visit(root, 1, d0, B); return 0; }
    const int T = argc > 3 ? std::atoi(argv[3]) : 1;
    // split: the nodes of weight 3 below the root are the work items
    std::vector<std::pair<Row, int>> items;
    Stats top(B);
    Row nobody;
    note(top, root, nobody, 1, d0);
    for (int p = bitlen(root); p <= d0; ++p) {
        Row c = with_bit(root, p); int dc = first_failure(c);
        note(top, c, root, 2, dc);
        top.deltaHist[dc - d0]++; top.maxDeltaByWeight[2] = std::max(top.maxDeltaByWeight[2], dc - d0);
        if (!top.maxDeltaByParentD.count(d0) || dc - d0 > top.maxDeltaByParentD[d0]) { top.maxDeltaByParentD[d0] = dc - d0; top.witnessByParentD[d0] = {root, p}; }
        if (p == d0) { top.repairHist[dc - d0]++; top.maxRepairByParentD[d0] = std::max(top.maxRepairByParentD.count(d0) ? top.maxRepairByParentD[d0] : -1000, dc - d0); }
        items.push_back({c, dc});
    }
    std::atomic<size_t> next{0};
    std::vector<Stats> part(T, Stats(B));
    std::vector<std::thread> pool;
    for (int k = 0; k < T; ++k) pool.emplace_back([&, k] {
        for (size_t i; (i = next.fetch_add(1)) < items.size();) visit(part[k], items[i].first, 2, items[i].second, B);
    });
    for (auto& th : pool) th.join();
    for (auto& s : part) top.merge(s);
    u64 total = 0;
    std::printf("weight nodes deadline maximizers maximizer_has_maximal_parent\n");
    for (int w = 1; w <= B; ++w) {
        total += top.nodes[w];
        bool nested = false;
        for (auto& [m, par] : top.argbest[w]) {
            if (w == 1) break;
            for (auto& [m2, par2] : top.argbest[w - 1]) if (m2.w == par.w) nested = true;
        }
        std::printf("%d %llu %d %zu %s\n", w, (unsigned long long)top.nodes[w], top.best[w], top.argbest[w].size(), w == 1 ? "-" : (nested ? "yes" : "no"));
    }
    std::printf("total nodes %llu\n", (unsigned long long)total);
    for (int w = 1; w <= B; ++w) {
        std::printf("maximizers at weight %d:", w);
        for (auto& [m, par] : top.argbest[w]) std::printf(" %s(parent %s)", decimal(m).c_str(), decimal(par).c_str());
        std::printf("\n");
    }
    std::printf("max delay of a child, by the child's weight:");
    for (int w = 2; w <= B; ++w) std::printf(" %d:%d", w, top.maxDeltaByWeight[w]);
    std::printf("\nmax delay by the parent's failure d (all children | the repairing child p = d):\n");
    for (auto& [d, v] : top.maxDeltaByParentD) {
        auto& [par, p] = top.witnessByParentD[d];
        std::printf("d %d: %d | %d   witness parent %s + 2^%d\n", d, v, top.maxRepairByParentD.count(d) ? top.maxRepairByParentD[d] : -1, decimal(par).c_str(), p);
    }
    std::printf("delay histogram, all children:");
    for (auto& [k, v] : top.deltaHist) std::printf(" %d:%llu", k, (unsigned long long)v);
    std::printf("\ndelay histogram, repairing children:");
    for (auto& [k, v] : top.repairHist) std::printf(" %d:%llu", k, (unsigned long long)v);
    std::printf("\n");
    return 0;
}
