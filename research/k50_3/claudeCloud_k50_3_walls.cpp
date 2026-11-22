// claudeCloud_k50_3_walls.cpp: pull K50.3 (ledger K61), first test. Hughes's two inverse ages beside other walls.
//
// Setting (the kit's Rule30ZeroBoundary, with the wall no longer fixed white). Cells sit at depths 1, 2, 3, ...
// The wall is the cell at depth 0; at tick s it has the value w(s). One tick:
//     new(x) = old(x + 1) xor (old(x) or old(x - 1))            for x >= 1, with old(0) = w(s).
// A row is an integer Y, bit i = the cell at depth i + 1 (the kit's IntegerForm). So
//     F_c(Y) = (Y >> 1) xor (Y or (Y << 1) or c).                With c = 0 this is the kit's F.
//
// A one-step predecessor of a row Z is a row V, of any support, with F_c(V) = Z on every cell. It is fixed by its
// cell 1 (b) and the wall cell c beside it: v(2) = z(1) xor (b or c), v(x + 2) = z(x + 1) xor (v(x + 1) or v(x)).
// Past Z's last black cell (depth e) the recursion is v(x + 2) = v(x + 1) or v(x): V is finite exactly when
// v(e + 1) = v(e + 2) = 0, and then its last black cell is at depth e - 1 (checked on every finite predecessor).
//
// TREE(Z, k): every predecessor of Z is finite, and so is every predecessor of those, to height k. Two readings:
//     driven: the wall cell beside a predecessor is the wall's own value at that tick (Hughes's setting when w = 0);
//     free:   the wall cell beside a predecessor is either value (a two-sided configuration: the cell is not ours).
// The AGE f(k) beside a wall is 1 + the last age t at which TREE(F^t(Y), k) fails for some nonzero finite row Y.
// Hughes (kit: Rule30AgeEightInverse, Rule30AgeTwentyFourInverse): beside the white wall f(1) = 8 and f(2) = 24.
//
// Sections:
//   A  the named walls (white as the control, black, 01, 001, 011, every phase): rows of up to 14 cells, ages to 48.
//   B  every word of length 1 to 8 as a periodic wall: rows of up to 12 cells, ages to 48.
//   C  3,000 random walls (black with chance 1/2, 1/8, 7/8): rows of up to 12 cells, ages to 48.
//   D  EVERY wall sequence, by depth-first search over the wall's bits. The wall's bit changes the next row only
//      when cell 1 is white, so the search branches only then, and keeps for each row the wall bits that lead to it.
//      k = 1: rows of up to 14 cells, to age 20, nothing pruned.
//      k = 2: rows of up to 12 cells, to age 40; a branch stops once the outer 20 cells are one of Hughes's six
//             states (EdgeGood20), where the kit proves the tree finite whatever enters and the band closed.
//      A, B and C count failures that occur while the outer band is good: that number must be 0 (it tests D's rule).
//
//     g++ -O2 -o k50_3_walls claudeCloud_k50_3_walls.cpp && ./k50_3_walls            (everything)
//     ./k50_3_walls control                 (the white wall alone: the known answers, used while writing this file)
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>
typedef unsigned __int128 u128;

static inline u128 stepw(u128 Y, int c) { return (Y >> 1) ^ (Y | (Y << 1) | (u128)c); }
static inline int edge(u128 Y) {                       // depth of the last black cell; 0 for the empty row
    uint64_t hi = (uint64_t)(Y >> 64), lo = (uint64_t)Y;
    if (hi) return 128 - __builtin_clzll(hi);
    if (lo) return 64 - __builtin_clzll(lo);
    return 0;
}
static long long edge_violations = 0;
static inline bool pred(u128 Z, int b, int c, u128 &V) {
    int e = edge(Z), p = c, q = b;                     // (p, q) = (v(x), v(x + 1)), starting at x = 0
    u128 v = (u128)b;
    for (int x = 0; x <= e; x++) {
        int n = (int)((Z >> x) & 1) ^ (q | p);         // v(x + 2)
        v |= (u128)n << (x + 1);
        p = q; q = n;
    }
    if (p | q) return false;                           // v(e + 1) or v(e + 2) black: cofinite
    if (e >= 2 && edge(v) != e - 1) edge_violations++;
    V = v; return true;
}
// cs[0], cs[1]: the wall cells beside the first and second predecessors (driven); freewall: both values at each level
static bool tree(u128 Z, int k, const int *cs, bool freewall) {
    if (k == 0) return true;
    for (int c = 0; c < 2; c++) {
        if (!freewall && c != cs[0]) continue;
        for (int b = 0; b < 2; b++) {
            u128 V;
            if (!pred(Z, b, c, V)) return false;
            if (!tree(V, k - 1, cs + 1, freewall)) return false;
        }
    }
    return true;
}
static inline bool good8(u128 Z) { int e = edge(Z); if (e < 8) return false; uint64_t u = (uint64_t)(Z >> (e - 8)); return u == 200 || u == 222; }
static inline bool good20(u128 Z) {
    int e = edge(Z); if (e < 20) return false; uint64_t u = (uint64_t)(Z >> (e - 20));
    return u == 820681 || u == 820683 || u == 822904 || u == 911005 || u == 911007 || u == 912610;
}
static std::string bits(u128 Y) { std::string s; int e = edge(Y); for (int i = 0; i < e; i++) s += (char)('0' + (int)((Y >> i) & 1)); return s.empty() ? "(empty)" : s; }

static long long fail_good8 = 0, fail_good20 = 0;
struct Res {                                           // last failing ages; -1 = never
    int last[2][2][15];                                // [driven/free][k - 1][cells m]
    int bad8[15], bad20[15];                           // last age at which the outer band is not good
    u128 wit[2][2]; int witage[2][2];
    Res() { memset(last, -1, sizeof last); memset(bad8, -1, sizeof bad8); memset(bad20, -1, sizeof bad20); memset(witage, -1, sizeof witage); }
    int f(int v, int k) const { int m = -1; for (int i = 1; i < 15; i++) m = std::max(m, last[v][k][i]); return m + 1; }
    int f(int v, int k, int lo, int hi) const { int m = -1; for (int i = lo; i <= hi; i++) m = std::max(m, last[v][k][i]); return m + 1; }
    int band(const int *b) const { int m = -1; for (int i = 1; i < 15; i++) m = std::max(m, b[i]); return m + 1; }
};
static void run_wall(const std::vector<int> &w, int maxcells, int H, Res &R) {     // w: the wall's values at ticks 0 .. H - 1
    for (uint32_t Y = 1; Y < (1u << maxcells); Y++) {
        int m = 32 - __builtin_clz(Y);
        u128 Z = Y;
        for (int t = 1; t <= H; t++) {
            Z = stepw(Z, w[t - 1]);
            bool g8 = good8(Z), g20 = good20(Z);
            if (!g8) R.bad8[m] = std::max(R.bad8[m], t);
            if (!g20) R.bad20[m] = std::max(R.bad20[m], t);
            int cs[2] = { w[t - 1], t >= 2 ? w[t - 2] : 0 };
            for (int v = 0; v < 2; v++) {
                bool ok1 = tree(Z, 1, cs, v == 1);
                if (!ok1) { if (g8) fail_good8++; if (t > R.last[v][0][m]) R.last[v][0][m] = t; if (t > R.witage[v][0]) { R.witage[v][0] = t; R.wit[v][0] = Y; } }
                if (t >= 2) {
                    bool ok2 = ok1 && tree(Z, 2, cs, v == 1);
                    if (!ok2) { if (g20) fail_good20++; if (t > R.last[v][1][m]) R.last[v][1][m] = t; if (t > R.witage[v][1]) { R.witage[v][1] = t; R.wit[v][1] = Y; } }
                }
            }
        }
    }
}
static uint64_t sm_state;
static uint64_t splitmix() { uint64_t z = (sm_state += 0x9E3779B97F4A7C15ULL); z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL; z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }

// ---- section D: every wall sequence
static int Dlast[2][2][15]; static std::string Dwit[2][2]; static int Dwitage[2][2]; static u128 Dwitrow[2][2];
static long long Dnodes[2], Dunresolved = 0;
static char path[64]; static u128 rootY; static int rootm;
static void note(int v, int k, int t) {
    if (t > Dlast[v][k][rootm]) Dlast[v][k][rootm] = t;
    if (t > Dwitage[v][k]) { Dwitage[v][k] = t; Dwitrow[v][k] = rootY; Dwit[v][k] = std::string(path, path + t); }
}
static void dfs1(u128 Z, int t, int mask1, int T) {
    Dnodes[0]++;
    if (t >= 1) {
        int cs[2] = { 0, 0 };
        if (!tree(Z, 1, cs, true)) {
            note(1, 0, t);
            for (int c = 0; c < 2; c++) if (mask1 >> c & 1) { cs[0] = c; if (!tree(Z, 1, cs, false)) { note(0, 0, t); break; } }
        }
    }
    if (t == T) return;
    if (Z & 1) { path[t] = 'x'; dfs1(stepw(Z, 0), t + 1, 3, T); }
    else { path[t] = '0'; dfs1(stepw(Z, 0), t + 1, 1, T); path[t] = '1'; dfs1(stepw(Z, 1), t + 1, 2, T); }
}
static void dfs2(u128 Z, int t, int mask1, int mask2, int T) {
    Dnodes[1]++;
    if (t >= 2) {
        if (good20(Z)) return;                         // the kit's reset: finite whatever enters, and the band is closed
        int cs[2] = { 0, 0 };
        if (!tree(Z, 2, cs, true)) {
            note(1, 1, t);
            bool bad = false;
            for (int c1 = 0; c1 < 2 && !bad; c1++) if (mask1 >> c1 & 1)
                for (int c2 = 0; c2 < 2 && !bad; c2++) if (mask2 >> c2 & 1) { cs[0] = c1; cs[1] = c2; if (!tree(Z, 2, cs, false)) bad = true; }
            if (bad) note(0, 1, t);
        }
    }
    if (t == T) { Dunresolved++; return; }
    if (Z & 1) { path[t] = 'x'; dfs2(stepw(Z, 0), t + 1, 3, mask1, T); }
    else { path[t] = '0'; dfs2(stepw(Z, 0), t + 1, 1, mask1, T); path[t] = '1'; dfs2(stepw(Z, 1), t + 1, 2, mask1, T); }
}

static void print_res(const char *name, const Res &R, int maxcells) {
    printf("%-14s driven f(1) = %2d, f(2) = %2d | free f(1) = %2d, f(2) = %2d | outer band good from age: 8 cells %2d, 20 cells %2d\n",
           name, R.f(0, 0), R.f(0, 1), R.f(1, 0), R.f(1, 1), R.band(R.bad8), R.band(R.bad20));
    for (int v = 0; v < 2; v++) for (int k = 0; k < 2; k++) {
        printf("      %s k = %d, last failing age by cells m = 1..%d:", v ? "free  " : "driven", k + 1, maxcells);
        for (int m = 1; m <= maxcells; m++) printf(" %d", R.last[v][k][m]);
        if (R.witage[v][k] >= 0) printf("   [row %s at age %d]", bits(R.wit[v][k]).c_str(), R.witage[v][k]);
        printf("\n");
    }
}

int main(int argc, char **argv) {
    const int H = 48;
    if (argc > 1 && !strcmp(argv[1], "control")) {
        std::vector<int> w(H, 0); Res R; run_wall(w, 14, H, R); print_res("0 (white):", R, 14);
        printf("CONTROL (Hughes, white wall): driven f(1) = 8 and f(2) = 24: %s\n", (R.f(0, 0) == 8 && R.f(0, 1) == 24) ? "REPRODUCED" : "NOT REPRODUCED");
        printf("failures with a good band: %lld, %lld; edge violations: %lld\n", fail_good8, fail_good20, edge_violations);
        return 0;
    }
    printf("SECTION A. Named walls, every nonzero row of up to 14 cells, ages 1 to %d. -1 = no failure.\n", H);
    const char *named[5] = { "0", "1", "01", "001", "011" };
    for (int i = 0; i < 5; i++) {
        int p = (int)strlen(named[i]);
        for (int ph = 0; ph < p; ph++) {
            std::vector<int> w(H); for (int s = 0; s < H; s++) w[s] = named[i][(s + ph) % p] - '0';
            Res R; run_wall(w, 14, H, R);
            char nm[32]; snprintf(nm, sizeof nm, "%s phase %d:", named[i], ph);
            print_res(nm, R, 14);
            if (i == 0) printf("      CONTROL (Hughes, white wall): driven f(1) = 8 and f(2) = 24: %s\n", (R.f(0, 0) == 8 && R.f(0, 1) == 24) ? "REPRODUCED" : "NOT REPRODUCED");
            printf("      narrow and wide rows (driven; free): k = 1, m <= 7: %d; %d, m >= 8: %d; %d.  k = 2, m <= 11: %d; %d, m >= 12: %d; %d\n",
                   R.f(0, 0, 1, 7), R.f(1, 0, 1, 7), R.f(0, 0, 8, 14), R.f(1, 0, 8, 14), R.f(0, 1, 1, 11), R.f(1, 1, 1, 11), R.f(0, 1, 12, 14), R.f(1, 1, 12, 14));
        }
    }
    fflush(stdout);

    printf("\nSECTION B. Every word of length 1 to 8 as a periodic wall, rows of up to 12 cells, ages 1 to %d.\n", H);
    for (int p = 1; p <= 8; p++) {
        int hist[2][2][64]; memset(hist, 0, sizeof hist); int mx[2][2] = { { 0, 0 }, { 0, 0 } }; uint32_t arg[2][2] = { { 0, 0 }, { 0, 0 } };
        int wide[2][2] = { { 0, 0 }, { 0, 0 } };
        for (uint32_t word = 0; word < (1u << p); word++) {
            std::vector<int> w(H); for (int s = 0; s < H; s++) w[s] = (word >> (s % p)) & 1;
            Res R; run_wall(w, 12, H, R);
            for (int v = 0; v < 2; v++) for (int k = 0; k < 2; k++) {
                int f = R.f(v, k); hist[v][k][f]++; if (f > mx[v][k]) { mx[v][k] = f; arg[v][k] = word; }
                wide[v][k] = std::max(wide[v][k], k == 0 ? R.f(v, 0, 8, 12) : R.f(v, 1, 12, 12));
            }
        }
        for (int v = 0; v < 2; v++) for (int k = 0; k < 2; k++) {
            printf("length %d, %s k = %d: largest age %2d (first at word ", p, v ? "free  " : "driven", k + 1, mx[v][k]);
            for (int s = 0; s < p; s++) printf("%d", (arg[v][k] >> s) & 1);
            printf("); wide rows alone: %2d; walls by age:", wide[v][k]);
            for (int f = 0; f < 64; f++) if (hist[v][k][f]) printf(" %d:%d", f, hist[v][k][f]);
            printf("\n");
        }
        fflush(stdout);
    }

    printf("\nSECTION C. Random walls, rows of up to 12 cells, ages 1 to %d.\n", H);
    for (int d = 0; d < 3; d++) {
        const char *dn[3] = { "1/2", "1/8", "7/8" };
        int hist[2][2][64]; memset(hist, 0, sizeof hist);
        sm_state = 20261122ULL + d;
        for (int n = 0; n < 1000; n++) {
            std::vector<int> w(H);
            for (int s = 0; s < H; s++) { uint64_t r = splitmix() & 7; w[s] = d == 0 ? (int)(r & 1) : d == 1 ? (r == 0) : (r != 0); }
            Res R; run_wall(w, 12, H, R);
            for (int v = 0; v < 2; v++) for (int k = 0; k < 2; k++) hist[v][k][R.f(v, k)]++;
        }
        for (int v = 0; v < 2; v++) for (int k = 0; k < 2; k++) {
            printf("black with chance %s, %s k = %d: walls by age:", dn[d], v ? "free  " : "driven", k + 1);
            for (int f = 0; f < 64; f++) if (hist[v][k][f]) printf(" %d:%d", f, hist[v][k][f]);
            printf("\n");
        }
        fflush(stdout);
    }
    printf("\nfailures while the outer 8 cells were 200 or 222 (k = 1): %lld; while the outer 20 were EdgeGood20 (k = 2): %lld  [both must be 0]\n", fail_good8, fail_good20);
    printf("finite predecessors whose last black cell was not one depth behind: %lld  [must be 0]\n", edge_violations);
    fflush(stdout);

    printf("\nSECTION D. Every wall sequence.\n");
    memset(Dlast, -1, sizeof Dlast); memset(Dwitage, -1, sizeof Dwitage);
    for (uint32_t Y = 1; Y < (1u << 14); Y++) { rootY = Y; rootm = 32 - __builtin_clz(Y); dfs1(Y, 0, 3, 20); }
    for (int v = 0; v < 2; v++) {
        printf("k = 1, %s, rows of up to 14 cells, every wall to age 20 (%lld nodes): last failing age by cells:", v ? "free  " : "driven", Dnodes[0]);
        int mx = -1; for (int m = 1; m <= 14; m++) { printf(" %d", Dlast[v][0][m]); mx = std::max(mx, Dlast[v][0][m]); }
        printf("  => f(1) over every wall = %d", mx + 1);
        if (Dwitage[v][0] >= 0) printf("   [row %s, wall %s (x: either), age %d]", bits(Dwitrow[v][0]).c_str(), Dwit[v][0].c_str(), Dwitage[v][0]);
        printf("\n");
    }
    fflush(stdout);
    for (uint32_t Y = 1; Y < (1u << 12); Y++) { rootY = Y; rootm = 32 - __builtin_clz(Y); dfs2(Y, 0, 3, 3, 40); }
    for (int v = 0; v < 2; v++) {
        printf("k = 2, %s, rows of up to 12 cells, every wall to age 40, cut at EdgeGood20 (%lld nodes): last failing age by cells:", v ? "free  " : "driven", Dnodes[1]);
        int mx = -1; for (int m = 1; m <= 12; m++) { printf(" %d", Dlast[v][1][m]); mx = std::max(mx, Dlast[v][1][m]); }
        printf("  => f(2) over every wall = %d", mx + 1);
        if (Dwitage[v][1] >= 0) printf("   [row %s, wall %s (x: either), age %d]", bits(Dwitrow[v][1]).c_str(), Dwit[v][1].c_str(), Dwitage[v][1]);
        printf("\n");
    }
    printf("branches of the k = 2 search still not EdgeGood20 at age 40: %lld  [0 means every wall reaches Hughes's six states]\n", Dunresolved);
    printf("finite predecessors whose last black cell was not one depth behind, whole run: %lld  [must be 0]\n", edge_violations);
    return 0;
}
