// check_trap.cpp (ledger M153; M152's version used a fresh outer cell at every tick, which I205 corrects): independent check of the
// finite facts behind the period-three right-half theorem. No table, no masks, no shared code: cell arrays and plain sets.
// The images of a window of 14 cells are those of one row: 17 cells, three ticks, the row losing one cell on the right a tick.
// Usage: check_trap KFILE001 KFILE011 [SEED]; KFILE: the codes of the trap, one number a line, as printed in the Lean file.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <random>
#include <set>
#include <vector>
using namespace std;
typedef uint32_t u32;
struct Word { const char *name; int d[3]; };   // the drive over a period from the gate tick
static Word W[2] = {{"001", {0, 1, 0}}, {"011", {0, 1, 1}}};
// one tick; the row loses its last cell
static void tick(vector<int> &c, int wall) {
    vector<int> e(c.size() - 1);
    for (size_t i = 0; i + 1 < c.size(); i++) e[i] = (i ? c[i - 1] : wall) != (c[i] || c[i + 1]);
    c = e;
}
static u32 pack(const vector<int> &c) { u32 x = 0; for (int i = 0; i < 14; i++) if (c[i]) x |= 1u << i; return x; }
static set<u32> images(const Word &w, u32 x) {
    set<u32> out;
    for (int e = 0; e < 8; e++) {
        vector<int> c(17);
        for (int i = 0; i < 14; i++) c[i] = (x >> i) & 1;
        for (int i = 0; i < 3; i++) c[14 + i] = (e >> i) & 1;
        for (int k = 0; k < 3; k++) tick(c, w.d[k]);
        out.insert(pack(c));
    }
    return out;
}
static set<u32> reach(const map<u32, set<u32>> &g, u32 a) {
    set<u32> R{a}; vector<u32> st{a};
    while (!st.empty()) { u32 x = st.back(); st.pop_back(); auto it = g.find(x); if (it != g.end()) for (u32 y : it->second) if (R.insert(y).second) st.push_back(y); }
    return R;
}
int main(int ac, char **av) {
    for (int wi = 0; wi < 2; wi++) {
        Word &w = W[wi];
        set<u32> K; FILE *f = fopen(av[1 + wi], "r"); unsigned v;
        while (fscanf(f, "%u", &v) == 1) K.insert(v);
        fclose(f);
        map<u32, set<u32>> g, back;
        for (u32 x = 0; x < (1u << 14); x++) { g[x] = images(w, x); for (u32 y : g[x]) back[y].insert(x); }
        bool closed = true;
        for (u32 x : K) for (u32 y : g[x]) closed &= K.count(y) > 0;
        set<u32> ahead = reach(g, *K.begin()), behind = reach(back, *K.begin());
        size_t in = 0; for (u32 x : K) in += behind.count(x);
        printf("%s: trap of %zu windows; closed %d; reached from one of them %zu; leading to it, of the trap %zu and of all 16384 windows %zu\n",
               w.name, K.size(), closed, ahead.size(), in, behind.size());
        for (int c = 0; c < 2; c++) {
            printf("   complete runs of %s readings on paths in the trap:", c ? "black" : "white");
            set<u32> B;
            for (u32 x : K) if ((int)(x & 1) != c) for (u32 y : g[x]) if ((int)(y & 1) == c) B.insert(y);
            for (int r = 1; r <= 24 && !B.empty(); r++) {
                bool end = false; set<u32> D;
                for (u32 x : B) for (u32 y : g[x]) if ((int)(y & 1) != c) end = true; else D.insert(y);
                if (end) printf(" %d", r);
                B = D;
                if (r == 24 && !B.empty()) printf(" ...");
            }
            printf("\n");
        }
        mt19937_64 rng(ac > 3 ? atoi(av[3]) : 1);
        long worst = 0, out = 0, N = 400000;
        for (long it = 0; it < N; it++) {
            vector<int> c(300); int kind = it % 4;
            for (int i = 0; i < 300; i++)
                c[i] = kind == 0 ? rng() & 1 : kind == 1 ? (rng() % 5 == 0) : kind == 2 ? (rng() % 5 != 0) : (i < 14 ? (it >> 2 >> i) & 1 : (int)(rng() & 1));
            long t;
            for (t = 0; t < 90; t++) { if (K.count(pack(c))) break; for (int k = 0; k < 3; k++) tick(c, w.d[k]); }
            if (t == 90) out++; else if (t > worst) worst = t;
        }
        printf("   %ld rows of 300 cells (random, sparse, dense, every 14-cell start): latest entry after %ld periods; not in after 90: %ld\n", N, worst, out);
    }
    return 0;
}
