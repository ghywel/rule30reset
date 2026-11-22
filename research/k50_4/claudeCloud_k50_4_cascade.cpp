// claudeCloud_k50_4_cascade.cpp: pull K50.4 (ledger K61), first test. The family tree of a white triangle.
//
// Rule 30 in its usual orientation: new(x) = old(x - 1) xor (old(x) or old(x + 1)). Read backward it is
//     old(x - 1) = new(x) xor (old(x) or old(x + 1)):
// a predecessor is fixed, from any two adjacent cells, leftward. The pair (old(x), old(x + 1)) is a register with
// four states, driven by the row below it read from right to left.
//
// THE CASCADE (mode tree). Stage 1 is the all-black row. A row of spatial period p, read through one period,
// sends the register through a map f on its four states. A bi-infinite predecessor has a register state with an
// unbounded past, so it lies on a cycle of f: the bi-infinite predecessors of a periodic row are exactly the
// cycles of f, a cycle of length c giving one row of least period c p (up to shift). So stage k + 1 is computed
// from stage k exactly: its nodes, their periods, and
//     M(k) = the sum of the periods at stage k = the number of bi-infinite rows that reach all black in k - 1 ticks.
// Every child is checked to step forward onto its parent. Also printed: the number of distinct factors of
// lengths 4 to 24 over the whole stage.
//
// A FINITE BLACK RUN (mode uniform). The word 1^RUN 0 (a black run with the white cell that ends it) has exactly
// 4^j ancestors j rows up, each a window of RUN + 1 + 2j cells, one for each choice of two free cells per row.
// For every one of them: the longest prefix (from the left end) that is a factor of a stage-(j + 1) row, the node
// it belongs to, and the DEFECT = the cells at the right end outside that prefix. This is the exact law of a
// triangle's ancestry if every window of the diagram were equally likely.
//
// THE SEED (mode seed). The diagram of the single black cell. A white triangle of side n sits under a maximal
// black run of n + 1 cells (every white run of a row lies under a black run or under a longer white run: checked
// by hand in the ledger post). For every maximal black run of MINRUN or more cells, and j = 1 .. K rows above it:
//     standard window: the ancestors of its last MINRUN cells and the white cell after them: node and defect,
//                      to be held against mode uniform with RUN = MINRUN; tabulated for the whole diagram and
//                      for three zones of a row t by the run's last cell b: left (b < -t/2), middle, right (b > t/2);
//     full window:     the ancestors of the whole run and the white cell: the matched prefix (the PATCH), and how
//                      far the same periodic pattern continues to the left of the window (cells no law forces).
//
//     g++ -O2 -o k50_4_cascade claudeCloud_k50_4_cascade.cpp
//     ./k50_4_cascade tree STAGES BUDGET            BUDGET: stop when M(k) would exceed it
//     ./k50_4_cascade uniform K RUN OUTPREFIX
//     ./k50_4_cascade seed ROWS K MINRUN OUTPREFIX
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <algorithm>

struct Node { std::vector<uint8_t> w; int parent; int cyc; };
typedef std::vector<Node> Stage;

static inline int adv(int s, int a) {                  // state = old(x) | old(x + 1) << 1; reads new(x); returns state at x - 1
    int bx = s & 1, bx1 = s >> 1;
    int n = a ^ (bx | bx1);
    return n | (bx << 1);
}
static void children(const Node &u, int self, Stage &out, std::string &type) {
    long long p = (long long)u.w.size();
    int f[4];
    for (int s = 0; s < 4; s++) { int st = s; for (long long x = p - 1; x >= 0; x--) st = adv(st, u.w[x]); f[s] = st; }
    bool cyclic[4];
    for (int s = 0; s < 4; s++) { int st = s; for (int i = 0; i < 4; i++) st = f[st]; int z = st; cyclic[s] = false; for (int i = 0; i < 4; i++) { if (z == s) cyclic[s] = true; z = f[z]; } }
    bool seen[4] = { false, false, false, false };
    std::vector<int> lens;
    for (int s = 0; s < 4; s++) if (cyclic[s] && !seen[s]) {
        int c = 0, st = s; do { seen[st] = true; st = f[st]; c++; } while (st != s);
        lens.push_back(c);
        long long q = c * p;
        Node v; v.parent = self; v.cyc = c; v.w.assign(q, 0);
        st = s;                                         // state at x = p - 1: (old(p - 1), old(p))
        for (long long x = p - 1; x > p - 1 - q; x--) {
            v.w[((x % q) + q) % q] = st & 1;
            st = adv(st, u.w[((x % p) + p) % p]);
        }
        if (st != s) { fprintf(stderr, "cycle did not close\n"); exit(1); }
        for (long long x = 0; x < q; x++) {             // the child steps forward onto the parent
            int nw = v.w[(x + q - 1) % q] ^ (v.w[x] | v.w[(x + 1) % q]);
            if (nw != u.w[x % p]) { fprintf(stderr, "child does not map to parent\n"); exit(1); }
        }
        out.push_back(v);
    }
    std::sort(lens.begin(), lens.end());
    type.clear(); for (size_t i = 0; i < lens.size(); i++) { if (i) type += "+"; type += (char)('0' + lens[i]); }
}
static std::vector<Stage> build(int stages, long long budget, bool verbose) {
    std::vector<Stage> T(stages + 2);
    Node root; root.w.assign(1, 1); root.parent = -1; root.cyc = 1; T[1].push_back(root);
    for (int k = 1; k <= stages; k++) {
        const Stage &S = T[k];
        long long M = 0; std::map<long long, int> per;
        for (const Node &n : S) { M += (long long)n.w.size(); per[(long long)n.w.size()]++; }
        Stage next; std::map<std::string, int> types; std::string ty;
        long long Mnext = 0; bool over = false;
        if (k < stages) for (size_t i = 0; i < S.size(); i++) {
            size_t before = next.size();
            children(S[i], (int)i, next, ty); types[ty]++;
            for (size_t j = before; j < next.size(); j++) Mnext += (long long)next[j].w.size();
            if (Mnext > budget) { over = true; break; }
        }
        if (verbose) {
            printf("stage %2d: nodes %zu, M = %lld, periods", k, S.size(), M);
            for (auto &kv : per) printf(" %lld x%d", kv.first, kv.second);
            if (k < stages && !over) { printf("; cycle types of f"); for (auto &kv : types) printf(" [%s] x%d", kv.first.c_str(), kv.second); }
            if (M <= (1 << 26)) {
                printf("; distinct factors");
                for (int n = 4; n <= 24; n += 4) {
                    std::vector<bool> bm((size_t)1 << n); long long cnt = 0; uint32_t mask = (n == 32) ? 0xffffffffu : ((1u << n) - 1);
                    for (const Node &nd : S) {
                        long long p = (long long)nd.w.size(); uint32_t v = 0;
                        for (long long i = 0; i < p + n - 1; i++) { v = ((v << 1) | nd.w[i % p]) & mask; if (i >= n - 1 && !bm[v]) { bm[v] = true; cnt++; } }
                    }
                    printf(" %d:%lld", n, cnt);
                }
            }
            printf("\n");
            if (M <= 96) for (size_t i = 0; i < S.size(); i++) {
                printf("      node %zu (parent %d, cycle %d): ", i, S[i].parent, S[i].cyc);
                for (uint8_t b : S[i].w) printf("%d", b);
                printf("\n");
            }
            fflush(stdout);
        }
        if (over) { if (verbose) printf("stage %d would exceed the budget of %lld cells: stopped\n", k + 1, budget); T.resize(k + 1); break; }
        if (k < stages) T[k + 1] = next;
    }
    return T;
}

// longest prefix of W[0..n) that is a factor of a node of S; returns length, node, phase; ties counts other nodes equal
static int match(const uint8_t *W, int n, const Stage &S, int &node, int &phase, int &tie) {
    int best = -1; node = -1; phase = 0; tie = 0;
    for (size_t i = 0; i < S.size(); i++) {
        const std::vector<uint8_t> &u = S[i].w; int p = (int)u.size(); int bi = -1, bp = 0;
        for (int ph = 0; ph < p; ph++) {
            if (u[ph] != W[0]) continue;
            int k = 1, q = ph + 1; if (q == p) q = 0;
            while (k < n && W[k] == u[q]) { k++; if (++q == p) q = 0; }
            if (k > bi) { bi = k; bp = ph; }
        }
        if (bi > best) { best = bi; node = (int)i; phase = bp; tie = 0; }
        else if (bi == best) tie++;
    }
    if (node < 0) { node = 0; phase = 0; }
    return best < 0 ? 0 : best;
}

// ---- mode uniform
static int UK, URUN; static std::vector<Stage> UT;
static std::vector<std::map<int, long long>> Unode, Udef; static std::vector<long long> Utie, Umax;
static void udfs(const std::vector<uint8_t> &W, int j) {
    if (j >= 1) {
        int node, ph, tie; int m = match(W.data(), (int)W.size(), UT[j + 1], node, ph, tie);
        int d = (int)W.size() - m;
        Unode[j][node]++; Udef[j][d]++; if (tie) Utie[j]++; if (d > Umax[j]) Umax[j] = d;
    }
    if (j == UK) return;
    int n = (int)W.size(); std::vector<uint8_t> V(n + 2);
    for (int fr = 0; fr < 4; fr++) {
        V[n + 1] = fr >> 1; V[n] = fr & 1;                // V[i + 1] sits above W[i]
        for (int i = n - 1; i >= 0; i--) V[i] = W[i] ^ (V[i + 1] | V[i + 2]);
        udfs(V, j + 1);
    }
}
static void dump(const char *path, const std::vector<std::map<int, long long>> &H, const char *head) {
    FILE *f = fopen(path, "w"); fprintf(f, "%s\n", head);
    for (size_t j = 1; j < H.size(); j++) for (auto &kv : H[j]) fprintf(f, "%zu\t%d\t%lld\n", j, kv.first, kv.second);
    fclose(f);
}

int main(int argc, char **argv) {
    if (argc < 2) return 1;
    std::string mode = argv[1];
    if (mode == "tree") {
        build(atoi(argv[2]), atoll(argv[3]), true);
        return 0;
    }
    if (mode == "uniform") {
        UK = atoi(argv[2]); URUN = atoi(argv[3]); std::string out = argv[4];
        UT = build(UK + 1, 1LL << 26, false);
        Unode.assign(UK + 1, {}); Udef.assign(UK + 1, {}); Utie.assign(UK + 1, 0); Umax.assign(UK + 1, 0);
        std::vector<uint8_t> W(URUN + 1, 1); W[URUN] = 0;
        udfs(W, 0);
        dump((out + ".node.tsv").c_str(), Unode, "rows_up\tnode\tcount");
        dump((out + ".defect.tsv").c_str(), Udef, "rows_up\tdefect\tcount");
        for (int j = 1; j <= UK; j++) {
            double mean = 0, tot = 0; for (auto &kv : Udef[j]) { mean += (double)kv.first * kv.second; tot += kv.second; }
            printf("rows up %2d (stage %2d): windows %.0f, width %d, mean defect %.3f, largest %lld, least patch %lld, windows matched by two nodes equally %lld; nodes",
                   j, j + 1, tot, URUN + 1 + 2 * j, mean / tot, Umax[j], (long long)(URUN + 1 + 2 * j) - Umax[j], Utie[j]);
            for (auto &kv : Unode[j]) printf(" %d:%.4f", kv.first, kv.second / tot);
            printf("\n");
        }
        return 0;
    }
    if (mode == "seed") {
        int ROWS = atoi(argv[2]), K = atoi(argv[3]), MINRUN = atoi(argv[4]); std::string out = argv[5];
        std::vector<Stage> T = build(K + 1, 1LL << 26, false);
        const int PAD = 128; long long OFF = ROWS + PAD; long long NB = 2LL * ROWS + 1 + 2 * PAD; long long NW = (NB + 63) / 64 + 2;
        std::vector<std::vector<uint64_t>> ring(K + 1, std::vector<uint64_t>(NW, 0));
        auto cell = [&](const std::vector<uint64_t> &r, long long x) -> int { long long i = x + OFF; return (int)((r[i >> 6] >> (i & 63)) & 1); };
        ring[0][OFF >> 6] |= 1ULL << (OFF & 63);
        std::vector<std::map<int, long long>> Snode(K + 1), Sdef(K + 1), Sfull(K + 1), Sext(K + 1); std::vector<long long> Stie(K + 1, 0);
        std::vector<std::map<int, long long>> Znode[3], Zdef[3]; long long Ztri[3] = { 0, 0, 0 };
        for (int z = 0; z < 3; z++) { Znode[z].assign(K + 1, {}); Zdef[z].assign(K + 1, {}); }
        std::vector<double> sumPatch(K + 1, 0), sumRun(K + 1, 0), cntJ(K + 1, 0);
        std::map<int, long long> runs; long long tri = 0; int bestL = 0; long long bestRow = 0, bestPos = 0;
        std::vector<uint8_t> W;
        for (long long t = 1; t <= ROWS; t++) {
            const std::vector<uint64_t> &prev = ring[(t - 1) % (K + 1)]; std::vector<uint64_t> &cur = ring[t % (K + 1)];
            long long lo = std::max(1LL, ((OFF - t - 1) >> 6) - 1), hi = std::min(NW - 2, ((OFF + t + 1) >> 6) + 1);
            std::fill(cur.begin(), cur.end(), 0);
            for (long long k = lo; k <= hi; k++) {
                uint64_t w = prev[k], L = (w << 1) | (prev[k - 1] >> 63), R = (w >> 1) | (prev[k + 1] << 63);
                cur[k] = L ^ (w | R);
            }
            if (t < K) continue;
            for (long long k = lo; k <= hi; k++) {
                uint64_t w = cur[k], nx = cur[k + 1], m = w;
                for (int s = 1; s < MINRUN && m; s++) m &= (w >> s) | (nx << (64 - s));
                while (m) {
                    int bit = __builtin_ctzll(m); m &= m - 1;
                    long long i = (k << 6) + bit - OFF;                    // cells i .. i + MINRUN - 1 black
                    if (cell(cur, i + MINRUN)) continue;                   // not the right end of its run
                    long long b = i + MINRUN - 1, a = i; while (cell(cur, a - 1)) a--;
                    int Lr = (int)(b - a + 1); runs[Lr]++; tri++;
                    if (Lr > bestL) { bestL = Lr; bestRow = t; bestPos = a; }
                    int zone = (2 * b < -t) ? 0 : (2 * b > t) ? 2 : 1; Ztri[zone]++;
                    for (int j = 1; j <= K; j++) {
                        const std::vector<uint64_t> &r = ring[(t - j) % (K + 1)];
                        int node, ph, tie;
                        int n = MINRUN + 1 + 2 * j; W.resize(n);
                        for (int q = 0; q < n; q++) W[q] = cell(r, b - MINRUN + 1 - j + q);
                        int ms = match(W.data(), n, T[j + 1], node, ph, tie);
                        Snode[j][node]++; Sdef[j][n - ms]++; if (tie) Stie[j]++;
                        Znode[zone][j][node]++; Zdef[zone][j][n - ms]++;
                        n = Lr + 1 + 2 * j; W.resize(n);
                        for (int q = 0; q < n; q++) W[q] = cell(r, a - j + q);
                        int mf = match(W.data(), n, T[j + 1], node, ph, tie);
                        Sfull[j][std::max(-60, std::min(60, mf - Lr))]++;
                        sumPatch[j] += mf; sumRun[j] += Lr; cntJ[j]++;
                        const std::vector<uint8_t> &u = T[j + 1][node].w; int p = (int)u.size(); int x = 0;
                        while (x < 64 && cell(r, a - j - 1 - x) == u[(((ph - 1 - x) % p) + p) % p]) x++;
                        Sext[j][x]++;
                    }
                }
            }
        }
        dump((out + ".node.tsv").c_str(), Snode, "rows_up\tnode\tcount");
        dump((out + ".defect.tsv").c_str(), Sdef, "rows_up\tdefect\tcount");
        const char *zn[3] = { "left", "middle", "right" };
        for (int z = 0; z < 3; z++) {
            dump((out + "." + zn[z] + ".node.tsv").c_str(), Znode[z], "rows_up\tnode\tcount");
            dump((out + "." + zn[z] + ".defect.tsv").c_str(), Zdef[z], "rows_up\tdefect\tcount");
        }
        dump((out + ".full.tsv").c_str(), Sfull, "rows_up\tpatch_minus_run\tcount");
        dump((out + ".ext.tsv").c_str(), Sext, "rows_up\tcells_continued_left\tcount");
        FILE *f = fopen((out + ".runs.tsv").c_str(), "w"); fprintf(f, "run\tcount\n"); for (auto &kv : runs) fprintf(f, "%d\t%lld\n", kv.first, kv.second); fclose(f);
        printf("rows %d, maximal black runs of %d or more cells (rows %d on): %lld; longest %d cells at row %lld, from position %lld\n", ROWS, MINRUN, K, tri, bestL, bestRow, bestPos);
        printf("by zone: left %lld, middle %lld, right %lld\n", Ztri[0], Ztri[1], Ztri[2]);
        for (int j = 1; j <= K; j++) {
            double ext = 0, tot = 0; for (auto &kv : Sext[j]) { ext += (double)kv.first * kv.second; tot += kv.second; }
            double def = 0; for (auto &kv : Sdef[j]) def += (double)kv.first * kv.second;
            printf("rows up %2d (stage %2d): mean defect (standard window) %.3f; mean run %.3f, mean patch %.3f; mean cells continued left %.3f; matched by two nodes equally %lld\n",
                   j, j + 1, def / tot, sumRun[j] / cntJ[j], sumPatch[j] / cntJ[j], ext / tot, Stie[j]);
        }
        return 0;
    }
    return 1;
}
