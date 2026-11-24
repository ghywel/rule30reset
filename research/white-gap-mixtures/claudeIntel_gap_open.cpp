// claudeIntel, N12 addendum 3 (I77).  One lane, open strip, all starting rows.
//
// Strip of W cells right of the driven site; the cell beyond it is arbitrary at every tick (so every ordinary history
// is included).  S(w) is the set of rows possible at the pulse that ends the gap word w, starting from ANY row at the
// first pulse.  The second-white sample after w is FIXED when every row of S(w) gives the same colour.  A periodic
// drive all of whose phases have fixed left contexts has an eventually periodic right neighbour, and finite-left
// masked Jen excludes it.  This lists, depth by depth, the words that are not fixed (each extends one a gap shorter).
//
// Usage: open W KMAX THREADS [LIST]
#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <functional>
#include <string>
#include <thread>
#include <vector>
using namespace std;
typedef uint32_t u32;
typedef uint64_t u64;
typedef vector<u32> V;
static int W, THREADS;
static int colour(u32 r) { return (r & 1) == 0 || (r & 6) == 0; }
static thread_local vector<u64> seen;
static V tick(const V &s, int d) {
    u32 top = 1u << (W - 1), mask = (u32)((1ull << W) - 1);
    V o;
    o.reserve(s.size());
    for (u32 r : s) {
        u32 y = (((r << 1) | d) ^ (r | (r >> 1))) & mask;      // exterior cell 0
        if (!(seen[y >> 6] >> (y & 63) & 1)) { seen[y >> 6] |= 1ull << (y & 63); o.push_back(y); }
        if (!(r & top)) {                                     // exterior cell 1 changes the last cell only
            y ^= top;
            if (!(seen[y >> 6] >> (y & 63) & 1)) { seen[y >> 6] |= 1ull << (y & 63); o.push_back(y); }
        }
    }
    for (u32 y : o) seen[y >> 6] &= ~(1ull << (y & 63));
    return o;
}
static V gap(V s, int q) { s = tick(s, 1); for (int i = 0; i < q; i++) s = tick(s, 0); return s; }
static void par(size_t n, const function<void(size_t)> &f) {
    atomic<size_t> nx(0);
    vector<thread> t;
    for (int i = 0; i < THREADS; i++) t.emplace_back([&] { seen.assign((1ull << W) / 64 + 1, 0); for (size_t k; (k = nx++) < n;) f(k); });
    for (auto &x : t) x.join();
}
int main(int argc, char **argv) {
    W = atoi(argv[1]);
    int K = atoi(argv[2]);
    THREADS = atoi(argv[3]);
    size_t list = argc > 4 ? atoi(argv[4]) : 12;
    V S1[8];
    par(8, [&](size_t a) {                                    // S(a) from all rows, in blocks
        u64 n = 1ull << W;
        vector<u64> acc((1ull << W) / 64 + 1, 0);
        for (u64 lo = 0; lo < n; lo += 1 << 20) {
            V b;
            for (u64 r = lo; r < min(n, lo + (1 << 20)); r++) b.push_back((u32)r);
            for (u32 y : gap(b, 9 + (int)a)) acc[y >> 6] |= 1ull << (y & 63);
        }
        for (u64 r = 0; r < n; r++) if (acc[r >> 6] >> (r & 63) & 1) S1[a].push_back((u32)r);
    });
    printf("W=%d  |S(q)|:", W);
    for (auto &s : S1) printf(" %zu", s.size());
    printf("\n");
    vector<vector<int>> cur;                                  // unfixed words, letters as indices, first letter first
    for (int a = 0; a < 8; a++) {
        bool b = false, w = false;
        for (u32 r : S1[a]) (colour(r) ? b : w) = true;
        if (b && w) cur.push_back({a});
    }
    size_t tested = 8;
    for (int k = 1; k <= K; k++) {
        printf("  length %d: unfixed %zu", k, cur.size());
        size_t t13 = 0, t14 = 0, t9 = 0;
        for (auto &w : cur) {
            size_t n = w.size();
            bool e = n >= 5 && w[n - 1] == 0 && w[n - 2] == 1 && w[n - 3] == 3 && w[n - 4] == 3;
            if (e && w[n - 5] == 4) t13++;
            else if (e && w[n - 5] == 5) t14++;
            else { bool run = true; for (size_t i = 1; i < n; i++) if (w[i]) run = false; if (run) t9++; }
        }
        printf("   (13-branch %zu, 14-branch %zu, x 9...9 %zu, other %zu)\n", t13, t14, t9, cur.size() - t13 - t14 - t9);
        if (cur.size() <= list) for (auto &w : cur) { printf("     "); for (int a : w) printf(" %d", 9 + a); printf("\n"); }
        fflush(stdout);
        if (cur.empty() || cur.size() > 3000) break;
        vector<vector<int>> cand, nxt;
        for (auto &w : cur) for (int a = 0; a < 8; a++) { vector<int> x{a}; x.insert(x.end(), w.begin(), w.end()); cand.push_back(x); }
        vector<char> un(cand.size(), 0);
        par(cand.size(), [&](size_t i) {
            V s = S1[cand[i][0]];
            for (size_t j = 1; j < cand[i].size(); j++) s = gap(s, 9 + cand[i][j]);
            bool b = false, w = false;
            for (u32 r : s) (colour(r) ? b : w) = true;
            un[i] = b && w;
        });
        tested += cand.size();
        for (size_t i = 0; i < cand.size(); i++) if (un[i]) nxt.push_back(cand[i]);
        cur.swap(nxt);
    }
    printf("  words tested %zu\n", tested);
}
