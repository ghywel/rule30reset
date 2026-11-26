// claudeCloud_m181_rings.cpp: the ring census by distinguished points (ledger K86).
//
// Same objects as claudeCloud_m181_rho.cpp: for a cyclic gap word, the forced pair p = (column -1, wall) of N-tick
// words, and the westward map F(b,c) = (D(b,c), b), D(b,c)(t) = b(t+1) xor (b(t) or c(t)).  The gate has a ring
// (a right half of bounded column periods reads it for ever) if and only if p lies on a cycle of F.
//
// Brent's walk costs about tail + 3 * cycle for every word.  Many words of one time period N fall into the same few
// cycles, so this program walks each cycle once.  A pair is *distinguished* if a fixed 64-bit mix of it has its low
// K bits zero.  For each word it finds the first distinguished pair y1 after p and the distance d1.  The
// distinguished pairs form a graph (each to the next one met); its cycles are found once.  Then p is on a cycle
// exactly when y1 is, and the pair d1 steps before y1 along that cycle is p (checked by walking from the
// distinguished pair before y1).  A walk that meets no distinguished pair in 64 * 2^K steps is on a short cycle with
// none: that word is done by Brent, exactly, and so is every word whose distinguished pairs lead to such a cycle.
//
//   g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_m181_rings.cpp -o m181_rings
//   m181_rings K < words.txt        words as for m181_rho; they may have different N (each N is handled apart)
// Output, one line per word:   word N ring|tail LAMBDA how
//   ring = p on a cycle of LAMBDA columns; tail = p not on a cycle, its orbit ends in a cycle of LAMBDA columns;
//   how = dp (distinguished points) or brent.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>
typedef unsigned __int128 u128;
typedef uint64_t u64;
struct Pair { u128 b, c; bool operator==(const Pair &o) const { return b == o.b && c == o.c; } };
static inline u64 mix64(u64 x) { x ^= x >> 33; x *= 0xff51afd7ed558ccdULL; x ^= x >> 33; x *= 0xc4ceb9fe1a85ec53ULL; x ^= x >> 33; return x; }
static inline u64 hashPair(const Pair &p) {
    u64 h = mix64((u64)p.b ^ 0x9e3779b97f4a7c15ULL); h = mix64(h ^ (u64)(p.b >> 64)); h = mix64(h ^ (u64)p.c); h = mix64(h ^ (u64)(p.c >> 64)); return h;
}
struct PairHash { size_t operator()(const Pair &p) const { return (size_t)hashPair(p); } };
struct Sys {
    int N; u128 MASK; u64 dpmask;
    inline Pair F(const Pair &p) const { u128 b1 = ((p.b >> 1) | (p.b << (N - 1))) & MASK; return Pair{ (b1 ^ (p.b | p.c)) & MASK, p.b }; }
    inline bool dp(const Pair &p) const { return (hashPair(p) & dpmask) == 0; }
    // first distinguished pair strictly after x; false if none within cap steps
    bool nextDP(Pair x, u64 cap, Pair &y, u64 &d) const { for (d = 1; d <= cap; ++d) { x = F(x); if (dp(x)) { y = x; return true; } } return false; }
};
static void brent(const Sys &S, const Pair &x0, u64 &mu, u64 &lam) {
    u64 power = 1; lam = 1; Pair tort = x0, hare = S.F(x0);
    while (!(tort == hare)) { if (power == lam) { tort = hare; power <<= 1; lam = 0; } hare = S.F(hare); ++lam; }
    mu = 0; tort = hare = x0; for (u64 k = 0; k < lam; ++k) hare = S.F(hare);
    while (!(tort == hare)) { tort = S.F(tort); hare = S.F(hare); ++mu; }
}
struct Node { Pair next; u64 gap; int state; int cyc; Pair prev; u64 prevgap; };   // state 1 on walk, 2 tail, 3 cycle, 4 ends in a cycle with no distinguished pair
int main(int argc, char **argv) {
    int K = argc > 1 ? atoi(argv[1]) : 18;
    std::vector<std::string> words; std::string w; while (std::cin >> w) words.push_back(w);
    size_t W = words.size();
    std::vector<int> Ns(W); std::vector<Pair> P(W); std::vector<std::string> out(W);
    for (size_t i = 0; i < W; ++i) {
        const std::string &g = words[i]; std::vector<int> gaps;
        if (g.find(',') == std::string::npos) { for (char ch : g) gaps.push_back(ch - '0'); }
        else { size_t p = 0; while (p < g.size()) { size_t q = g.find(',', p); if (q == std::string::npos) q = g.size(); gaps.push_back(atoi(g.substr(p, q - p).c_str())); p = q + 1; } }
        int n = 0; for (int d : gaps) n += d; int N = 2 * n; Ns[i] = N;
        if (N < 2 || N > 126) { fprintf(stderr, "word %s: N out of range\n", g.c_str()); return 1; }
        u128 wall = 0, west = 0; for (int t = 1; t < N; t += 2) { wall |= (u128)1 << t; west |= (u128)1 << t; }
        int s = 0; std::vector<int> kick(n, 0); for (int d : gaps) { kick[s] = 1; s += d; }
        for (s = 0; s < n; ++s) if (!kick[s]) west |= (u128)1 << (2 * s);
        P[i] = Pair{west, wall};
    }
    std::map<int, std::vector<size_t>> byN; for (size_t i = 0; i < W; ++i) byN[Ns[i]].push_back(i);
    std::vector<int> NsList; for (auto &kv : byN) NsList.push_back(kv.first);
    #pragma omp parallel for schedule(dynamic, 1)
    for (size_t gi = 0; gi < NsList.size(); ++gi) {
        int N = NsList[gi]; const std::vector<size_t> &idx = byN[N];
        Sys S; S.N = N; S.MASK = ((u128)1 << N) - 1; S.dpmask = (1ULL << K) - 1; u64 cap = 64ULL << K;
        std::unordered_map<Pair, Node, PairHash> G; std::vector<u64> cycLen;
        std::vector<Pair> y1(idx.size()); std::vector<u64> d1(idx.size()); std::vector<char> viaBrent(idx.size(), 0);
        char buf[320];
        for (size_t j = 0; j < idx.size(); ++j) {
            size_t i = idx[j];
            if (!S.nextDP(P[i], cap, y1[j], d1[j])) {
                u64 mu, lam; brent(S, P[i], mu, lam); viaBrent[j] = 1;
                snprintf(buf, sizeof buf, "%s %d %s %llu brent", words[i].c_str(), N, mu == 0 ? "ring" : "tail", (unsigned long long)lam); out[i] = buf;
            }
        }
        // resolve the graph of distinguished pairs from every y1
        for (size_t j = 0; j < idx.size(); ++j) {
            if (viaBrent[j]) continue;
            std::vector<Pair> walk; Pair x = y1[j];
            for (;;) {
                auto it = G.find(x);
                if (it == G.end()) {
                    Node nd; nd.state = 1; nd.cyc = -1; nd.prevgap = 0; nd.prev = x;
                    if (!S.nextDP(x, cap, nd.next, nd.gap)) { nd.state = 4; G.emplace(x, nd); break; }   // its orbit ends in a short cycle without one
                    G.emplace(x, nd); walk.push_back(x); x = nd.next; continue;
                }
                if (it->second.state == 1) {                       // closed a new cycle at x
                    int id = (int)cycLen.size(); u64 len = 0; Pair z = x;
                    do { Node &nz = G[z]; nz.state = 3; nz.cyc = id; len += nz.gap; Node &nn = G[nz.next]; nn.prev = z; nn.prevgap = nz.gap; z = nz.next; } while (!(z == x));
                    cycLen.push_back(len);
                }
                break;
            }
            for (const Pair &z : walk) { Node &nz = G[z]; if (nz.state == 1) nz.state = 2; }
            // tails inherit the cycle they end in, or the mark 4
            for (size_t k = walk.size(); k-- > 0;) { Node &nz = G[walk[k]]; if (nz.state == 2) { const Node &nn = G[nz.next]; if (nn.state == 4) nz.state = 4; else nz.cyc = nn.cyc; } }
        }
        for (size_t j = 0; j < idx.size(); ++j) {
            if (viaBrent[j]) continue;
            size_t i = idx[j]; const Node &nd = G[y1[j]]; bool ring = false;
            if (nd.state == 4) {
                u64 mu, lam; brent(S, P[i], mu, lam);
                snprintf(buf, sizeof buf, "%s %d %s %llu brent", words[i].c_str(), N, mu == 0 ? "ring" : "tail", (unsigned long long)lam); out[i] = buf; continue;
            }
            if (nd.state == 3) {
                if (d1[j] <= nd.prevgap) { Pair z = nd.prev; for (u64 k = 0; k < nd.prevgap - d1[j]; ++k) z = S.F(z); ring = (z == P[i]); }
            }
            snprintf(buf, sizeof buf, "%s %d %s %llu dp", words[i].c_str(), N, ring ? "ring" : "tail", (unsigned long long)cycLen[nd.cyc]); out[i] = buf;
        }
        #pragma omp critical
        { fprintf(stderr, "N %d done: %zu words, %zu cycles by distinguished points, %zu distinguished pairs\n", N, idx.size(), cycLen.size(), G.size()); }
    }
    for (auto &s : out) puts(s.c_str());
    return 0;
}
