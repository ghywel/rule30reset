// claudeCloud_k84_wests.cpp: the longest-lived wests beside a black-first alternating centre (ledger K84).
//
// A west is a finite left half, depth k = cell -k, coded as a natural number with bit k-1 = depth k (the kit's
// `toFun`, Rule30ZeroBoundarySmall). Beside an alternating centre that is black at even ticks, the centre stays
// alternating while depth 1 is black at every even tick, and while it does the west evolves exactly as beside a
// white wall (claudeIntel, N16 section 4): the kit's zero-boundary left half, one step (r >> 1) ^ (r | (r << 1)).
// The DEATH time of a west is the first even tick at which depth 1 is white (the kit's convention: every west of
// support at most 52 dies by tick 96, `q01_width_le_52`; `w52`, `w56`, `w60` die at 96, 100 and 114).
//
// Depth k at time 0 enters depth 1 at time k-1 linearly (left permutivity), so the check at an even tick t fixes
// depth t+1. A search over the free depths (the even ones) with the forced depths computed gives every west of
// support at most W exactly once. Cells (d, t) with d + t = k form diagonal k, computed from diagonals k-1 and k-2:
//     E_k[t] = E_k[0] xor (E_{k-1}[0] | E_{k-2}[0]) xor ... xor (E_{k-1}[t-1] | E_{k-2}[t-1]),   E_k[t] = depth k-t at t,
// a prefix xor, with E_{k-2}[k-2] = 0 for the white wall. Depth 1 at time k-1 is E_k[k-1].
//
//   g++ -O3 -fopenmp -std=c++17 claudeCloud_k84_wests.cpp -o k84_wests
//   k84_wests W TMIN [MAXLIST]    every west of support <= W; prints the histogram of death times, the largest, and
//                                 the wests (hex) whose death time is at least TMIN (at most MAXLIST, default 2000)
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>
#include <omp.h>
using namespace std;
typedef uint64_t u64;
static const int NW = 4;                       // 256 bits: diagonals up to length 256
struct Diag { u64 w[NW]; };
static int W, TMIN; static long MAXLIST;

static inline void exclPrefixXor(const Diag &o, Diag &p, int len) {
    // p[t] = xor of o[0..t-1], for t < len
    u64 carry = 0;                              // parity of all earlier words, as 0 or ~0
    u64 q[NW];
    for (int i = 0; i < NW; ++i) {
        u64 x = o.w[i];
        x ^= x << 1; x ^= x << 2; x ^= x << 4; x ^= x << 8; x ^= x << 16; x ^= x << 32;
        q[i] = x ^ carry;
        carry = (q[i] >> 63) ? ~0ULL : 0ULL;
    }
    // exclusive: shift the inclusive prefix up by one bit
    u64 in = 0;
    for (int i = 0; i < NW; ++i) { u64 v = q[i]; p.w[i] = (v << 1) | in; in = v >> 63; }
    // mask to len bits
    for (int i = 0; i < NW; ++i) {
        int lo = i * 64;
        if (len <= lo) p.w[i] = 0;
        else if (len < lo + 64) p.w[i] &= (1ULL << (len - lo)) - 1;
    }
}
static inline int getb(const Diag &d, int t) { return (d.w[t >> 6] >> (t & 63)) & 1; }

struct Out { vector<long> hist; int best = 0; vector<pair<int, string>> list; long leaves = 0; };

static string hexOf(const vector<int> &bits) {      // bits[k-1] = depth k
    int n = bits.size(); while (n > 0 && !bits[n - 1]) --n;
    if (n == 0) return "0";
    string s; int nd = (n + 3) / 4;
    for (int d = nd - 1; d >= 0; --d) { int v = 0; for (int b = 0; b < 4; ++b) { int k = 4 * d + b; if (k < n && bits[k]) v |= 1 << b; }
        s += "0123456789abcdef"[v]; }
    return s;
}

static void dfs(int k, const Diag &e1, const Diag &e2, vector<int> &bits, Out &out) {
    // e1 = E_{k-1}, e2 = E_{k-2}; build E_k
    Diag o, p;
    for (int i = 0; i < NW; ++i) o.w[i] = e1.w[i] | e2.w[i];
    if (k > 256) { fprintf(stderr, "diagonal overflow\n"); exit(2); }
    exclPrefixXor(o, p, k);
    int pk = getb(p, k - 1);                 // depth 1 at time k-1 if the new depth is white
    auto withNew = [&](int nb, Diag &e) { for (int i = 0; i < NW; ++i) e.w[i] = nb ? ~p.w[i] : p.w[i];
        for (int i = 0; i < NW; ++i) { int lo = i * 64; if (k <= lo) e.w[i] = 0; else if (k < lo + 64) e.w[i] &= (1ULL << (k - lo)) - 1; } };
    bool check = ((k - 1) % 2 == 0);         // an even tick
    if (k <= W) {
        if (check) {                         // forced: depth 1 must be black at time k-1
            int nb = pk ? 0 : 1; Diag e; withNew(nb, e);
            bits.push_back(nb); dfs(k + 1, e, e1, bits, out); bits.pop_back();
        } else {
            for (int nb = 0; nb < 2; ++nb) { Diag e; withNew(nb, e); bits.push_back(nb); dfs(k + 1, e, e1, bits, out); bits.pop_back(); }
        }
        return;
    }
    // beyond the support: the new depth is white
    if (check && !pk) {                      // death at the even tick k-1
        int T = k - 1; ++out.leaves;
        if ((int)out.hist.size() <= T) out.hist.resize(T + 1, 0);
        ++out.hist[T];
        if (T > out.best) out.best = T;
        if (T >= TMIN && (long)out.list.size() < MAXLIST) out.list.push_back({T, hexOf(bits)});
        return;
    }
    Diag e; withNew(0, e); bits.push_back(0); dfs(k + 1, e, e1, bits, out); bits.pop_back();
}

int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "usage: k84_wests W TMIN [MAXLIST]\n"); return 1; }
    W = atoi(argv[1]); TMIN = atoi(argv[2]); MAXLIST = argc > 3 ? atol(argv[3]) : 2000;
    if (W < 4 || W > 80) { fprintf(stderr, "W must be 4..80\n"); return 1; }
    // split the search on the first F free depths (2, 4, ..., 2F) into 2^F tasks
    int F = min(10, W / 2 - 1);
    vector<Out> outs(1 << F);
    #pragma omp parallel for schedule(dynamic, 1)
    for (int task = 0; task < (1 << F); ++task) {
        // walk the forced/free prefix up to depth 2F+... by hand, then dfs
        Diag e2{}, e1{};                      // E_{-1}, E_0: empty
        vector<int> bits; Out &out = outs[task];
        int k = 1, freeUsed = 0; Diag a = e1, b = e2;
        bool ok = true;
        while (freeUsed < F) {
            Diag o, p; for (int i = 0; i < NW; ++i) o.w[i] = a.w[i] | b.w[i];
            exclPrefixXor(o, p, k);
            int pk = getb(p, k - 1); int nb;
            if ((k - 1) % 2 == 0) nb = pk ? 0 : 1; else { nb = (task >> freeUsed) & 1; ++freeUsed; }
            Diag e; for (int i = 0; i < NW; ++i) e.w[i] = nb ? ~p.w[i] : p.w[i];
            for (int i = 0; i < NW; ++i) { int lo = i * 64; if (k <= lo) e.w[i] = 0; else if (k < lo + 64) e.w[i] &= (1ULL << (k - lo)) - 1; }
            bits.push_back(nb); b = a; a = e; ++k;
        }
        if (ok) dfs(k, a, b, bits, out);
    }
    Out all; for (auto &o : outs) { all.leaves += o.leaves; if ((int)all.hist.size() < (int)o.hist.size()) all.hist.resize(o.hist.size(), 0);
        for (size_t i = 0; i < o.hist.size(); ++i) all.hist[i] += o.hist[i]; all.best = max(all.best, o.best);
        for (auto &x : o.list) all.list.push_back(x); }
    sort(all.list.begin(), all.list.end(), [](const pair<int,string> &x, const pair<int,string> &y) { return x.first != y.first ? x.first > y.first : x.second < y.second; });
    printf("wests of support <= %d beside a black-first alternating centre: %ld (every free choice), last death tick %d\n", W, all.leaves, all.best);
    printf("death tick: number of wests\n");
    for (size_t T = 0; T < all.hist.size(); ++T) if (all.hist[T]) printf("  %3zu %12ld\n", T, all.hist[T]);
    printf("wests dying at tick >= %d (%zu listed):\n", TMIN, all.list.size());
    for (auto &x : all.list) printf("  %d %s\n", x.first, x.second.c_str());
    return 0;
}
