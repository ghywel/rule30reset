// K92.4, claudeM5 (M233), after the registered runs (addendum registered before these): Jen's full form.
//
// The kit's Rule30Jen.jen: no two DIFFERENT columns of the single seed are both eventually periodic. The registered
// program (claudeM5_any_period_strips.cpp) used adjacent pairs for the fall strips and only x1 at the white phases
// for the east strip. This program, built from that one's code, weakens both readings as Jen allows:
//   fall mode:  certified when every nontrivial component has TWO columns each constant on its cyclic classes
//               (two different singleton columns eventually periodic: Jen);
//   east mode:  certified when every nontrivial component has ONE rigid reading among x1 at the white phases (masked
//               Jen) and each strip column x1 .. xK at every phase (with an eventually periodic centre, a second
//               periodic column: Jen).
// Usage: jen_strips fall M WMAX THREADS | jen_strips east WORD KMIN KMAX | jen_strips eastcensus L KMAX THREADS
#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <numeric>
#include <set>
#include <string>
#include <thread>
#include <vector>

using u32 = std::uint32_t;
using i64 = std::int64_t;

static inline u32 stripStep(int K, u32 a, u32 z, u32 r) {
    const u32 M = (1u << K) - 1;
    return (((r << 1) | a) ^ (r | (r >> 1) | (z << (K - 1)))) & M;
}

// ---- generic exact test ------------------------------------------------------------------------------------------
struct Stats {
    bool cert = true;
    i64 cycleNodes = 0;     // nodes on nontrivial components
    int nontrivial = 0;     // nontrivial components
    int nonRigid = 0;       // nontrivial components with no rigid reading
    i64 bigSize = 0;        // the largest non-rigid component
    i64 bigPeriod = 0;
};

// G provides: N (nodes), D (successors per node), succ(v, k) -> node or -1,
// R (number of readings), reading(v, j) -> small int or -1 (not read at this node).
template <class G>
static Stats exactTest(const G& g) {   // certified: every nontrivial component has g.need rigid readings
    const i64 N = g.N;
    std::vector<int32_t> idx(N, -1), low(N, 0), comp(N, -1);
    std::vector<char> on(N, 0);
    std::vector<int32_t> st;
    std::vector<std::pair<int32_t, int>> cs;
    int32_t counter = 0, ncomp = 0;
    for (i64 s = 0; s < N; ++s) {
        if (idx[s] != -1) continue;
        idx[s] = low[s] = counter++; st.push_back((int32_t)s); on[s] = 1; cs.push_back({(int32_t)s, 0});
        while (!cs.empty()) {
            int32_t v = cs.back().first;
            int k = cs.back().second;
            if (k < g.D) {
                cs.back().second = k + 1;
                i64 w = g.succ(v, k);
                if (w < 0) continue;
                if (idx[w] == -1) {
                    idx[w] = low[w] = counter++; st.push_back((int32_t)w); on[w] = 1; cs.push_back({(int32_t)w, 0});
                } else if (on[w]) low[v] = std::min(low[v], idx[w]);
            } else {
                cs.pop_back();
                if (low[v] == idx[v]) {
                    int32_t x;
                    do { x = st.back(); st.pop_back(); on[x] = 0; comp[x] = ncomp; } while (x != v);
                    ++ncomp;
                }
                if (!cs.empty()) { int32_t u = cs.back().first; low[u] = std::min(low[u], low[v]); }
            }
        }
    }
    // group nodes by component
    std::vector<int32_t> start(ncomp + 1, 0), order(N);
    for (i64 v = 0; v < N; ++v) ++start[comp[v] + 1];
    for (int c = 0; c < ncomp; ++c) start[c + 1] += start[c];
    { std::vector<int32_t> pos(start.begin(), start.end() - 1); for (i64 v = 0; v < N; ++v) order[pos[comp[v]]++] = (int32_t)v; }
    std::vector<int32_t> level(N, -1);
    std::vector<int32_t> queue;
    Stats S;
    for (int c = 0; c < ncomp; ++c) {
        const int32_t b = start[c], e = start[c + 1];
        const i64 size = e - b;
        if (size == 1) {   // nontrivial only with a self-loop
            int32_t v = order[b]; bool loop = false;
            for (int k = 0; k < g.D; ++k) if (g.succ(v, k) == v) loop = true;
            if (!loop) continue;
        }
        // BFS levels and the period
        queue.clear(); queue.push_back(order[b]); level[order[b]] = 0;
        i64 d = 0;
        for (size_t qi = 0; qi < queue.size(); ++qi) {
            int32_t v = queue[qi];
            for (int k = 0; k < g.D; ++k) {
                i64 w = g.succ(v, k);
                if (w < 0 || comp[w] != c) continue;
                if (level[w] == -1) { level[w] = level[v] + 1; queue.push_back((int32_t)w); }
                else d = std::gcd(d, (i64)std::llabs((i64)level[v] + 1 - level[w]));
            }
        }
        if (d == 0) { std::fprintf(stderr, "component without a cycle\n"); std::exit(1); }
        ++S.nontrivial; S.cycleNodes += size;
        int nRigid = 0;
        std::vector<int> seen;
        for (int j = 0; j < g.R && nRigid < g.need; ++j) {
            seen.assign((size_t)d, -1);
            bool rigid = true, used = false;
            for (int32_t i = b; i < e && rigid; ++i) {
                int32_t v = order[i];
                int rd = g.reading(v, j);
                if (rd < 0) continue;
                used = true;
                int& s = seen[(size_t)(level[v] % d)];
                if (s == -1) s = rd; else if (s != rd) rigid = false;
            }
            if (rigid || !used) ++nRigid;   // a reading never taken in the component holds vacuously
        }
        if (nRigid < g.need) {
            S.cert = false; ++S.nonRigid;
            if (size > S.bigSize) { S.bigSize = size; S.bigPeriod = d; }
        }
    }
    return S;
}

// ---- fall mode ---------------------------------------------------------------------------------------------------
struct FallGraph {
    int W, m; std::vector<int> phase; i64 N; int D = 4, R, need = 2;
    std::vector<u32> permit;   // permit[p]: cells allowed to fall at phase p
    FallGraph(int W_, int m_, const std::vector<int>& ph) : W(W_), m(m_), phase(ph) {
        N = ((i64)1 << W) * m; R = W;
        permit.assign(m, 0);
        for (int j = 0; j < W; ++j) permit[phase[j]] |= 1u << j;
    }
    i64 succ(i64 v, int k) const {
        u32 r = (u32)(v / m); int p = (int)(v % m);
        u32 d = stripStep(W, (u32)(k >> 1), (u32)(k & 1), r);
        u32 fall = r & (r ^ d);
        if (fall & ~permit[p]) return -1;
        return (i64)d * m + (p + 1) % m;
    }
    int reading(i64 v, int j) const { return (int)(((u32)(v / m) >> j) & 1); }   // column j alone
};

static i64 encode(const std::vector<int>& a, int m) { i64 x = 0; for (int i = (int)a.size() - 1; i >= 0; --i) x = x * m + a[i]; return x; }
static std::vector<int> normalized(std::vector<int> a, int m) { int s = a[0]; for (int& x : a) x = (x - s + m) % m; return a; }
static std::string show(const std::vector<int>& a) { std::string s; for (int x : a) s.push_back('0' + x); return s; }

static void fallMode(int m, int WMAX, int T) {
    std::set<i64> unc;   // uncertified assignments at the previous width
    for (int W = 1; W <= WMAX; ++W) {
        std::vector<std::vector<int>> cand;
        i64 total = 1; for (int j = 1; j < W; ++j) total *= m;
        for (i64 x = 0; x < total; ++x) {
            std::vector<int> a(W, 0); i64 y = x;
            for (int j = 1; j < W; ++j) { a[j] = (int)(y % m); y /= m; }
            if (W > 1) {
                std::vector<int> pre(a.begin(), a.end() - 1), suf(a.begin() + 1, a.end());
                if (!unc.count(encode(normalized(pre, m), m)) || !unc.count(encode(normalized(suf, m), m))) continue;
            }
            cand.push_back(a);
        }
        std::vector<Stats> res(cand.size());
        std::atomic<size_t> next{0};
        std::vector<std::thread> pool;
        for (int t = 0; t < T; ++t) pool.emplace_back([&] {
            for (size_t i; (i = next.fetch_add(1)) < cand.size();) res[i] = exactTest(FallGraph(W, m, cand[i]));
        });
        for (auto& th : pool) th.join();
        std::set<i64> now;
        size_t nu = 0;
        for (size_t i = 0; i < cand.size(); ++i) if (!res[i].cert) { now.insert(encode(cand[i], m)); ++nu; }
        std::printf("two columns, width %d modulus %d: %lld normalized, %zu tested, %zu uncertified\n", W, m, (long long)total, cand.size(), nu);
        if (nu <= 64)
            for (size_t i = 0; i < cand.size(); ++i) if (!res[i].cert)
                std::printf("  uncertified %s  components %d non-rigid %d largest %lld period %lld cycle-nodes %lld\n",
                            show(cand[i]).c_str(), res[i].nontrivial, res[i].nonRigid, (long long)res[i].bigSize,
                            (long long)res[i].bigPeriod, (long long)res[i].cycleNodes);
        std::fflush(stdout);
        unc.swap(now);
        if (unc.empty()) { std::printf("every assignment certified at width %d\n", W); return; }
    }
}

// ---- east mode: x1 at the white phases (reading 0) and every column at every phase (readings 1 .. K) ----------
struct EastGraph {
    int K, L; std::vector<int> w; i64 N; int D = 2, R, need = 1;
    EastGraph(int K_, const std::vector<int>& w_) : K(K_), L((int)w_.size()), w(w_) { N = ((i64)1 << K) * L; R = K + 1; }
    i64 succ(i64 v, int k) const {
        u32 r = (u32)(v / L); int p = (int)(v % L);
        return (i64)stripStep(K, (u32)w[p], (u32)k, r) * L + (p + 1) % L;
    }
    int reading(i64 v, int j) const {
        int p = (int)(v % L); u32 r = (u32)(v / L);
        if (j == 0) { if (w[p] != 0) return -1; return (int)(r & 1); }
        return (int)((r >> (j - 1)) & 1);
    }
};

static std::vector<int> parse(const char* s) { std::vector<int> w; for (; *s; ++s) w.push_back(*s - '0'); return w; }

static void eastMode(const char* word, int KMIN, int KMAX) {
    auto w = parse(word);
    for (int K = KMIN; K <= KMAX; ++K) {
        Stats S = exactTest(EastGraph(K, w));
        std::printf("%s K %d: components %d cycle-nodes %lld non-rigid %d largest %lld period %lld | %s\n", word, K,
                    S.nontrivial, (long long)S.cycleNodes, S.nonRigid, (long long)S.bigSize, (long long)S.bigPeriod,
                    S.cert ? "CERTIFIED: x1 eventually periodic at the white phases" : "not certified");
        std::fflush(stdout);
    }
}

static void eastCensus(int Lmax, int KMAX, int T) {
    std::vector<std::vector<int>> words;
    for (int n = 1; n <= Lmax; ++n)
        for (u32 x = 0; x < (1u << n); ++x) {
            std::vector<int> w(n);
            for (int i = 0; i < n; ++i) w[i] = (x >> (n - 1 - i)) & 1;
            bool ly = true;
            for (int s = 1; s < n && ly; ++s) {
                std::vector<int> r(w.begin() + s, w.end()); r.insert(r.end(), w.begin(), w.begin() + s);
                if (!(w < r)) ly = false;
            }
            if (ly) words.push_back(w);
        }
    std::vector<std::string> out(words.size());
    std::atomic<size_t> next{0};
    std::vector<std::thread> pool;
    for (int t = 0; t < T; ++t) pool.emplace_back([&] {
        for (size_t i; (i = next.fetch_add(1)) < words.size();) {
            int least = -1; Stats last;
            for (int K = 1; K <= KMAX; ++K) { last = exactTest(EastGraph(K, words[i])); if (last.cert) { least = K; break; } }
            char buf[256];
            if (least > 0) std::snprintf(buf, sizeof buf, "%s %zu %d", show(words[i]).c_str(), words[i].size(), least);
            else std::snprintf(buf, sizeof buf, "%s %zu - non-rigid %d largest %lld period %lld", show(words[i]).c_str(),
                               words[i].size(), last.nonRigid, (long long)last.bigSize, (long long)last.bigPeriod);
            out[i] = buf;
        }
    });
    for (auto& th : pool) th.join();
    for (auto& s : out) std::printf("%s\n", s.c_str());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::fprintf(stderr, "usage: see the header\n"); return 1; }
    std::string mode = argv[1];
    if (mode == "fall" && argc == 5) fallMode(std::atoi(argv[2]), std::atoi(argv[3]), std::atoi(argv[4]));
    else if (mode == "east" && argc == 5) eastMode(argv[2], std::atoi(argv[3]), std::atoi(argv[4]));
    else if (mode == "eastcensus" && argc == 5) eastCensus(std::atoi(argv[2]), std::atoi(argv[3]), std::atoi(argv[4]));
    else { std::fprintf(stderr, "usage: see the header\n"); return 1; }
    return 0;
}
