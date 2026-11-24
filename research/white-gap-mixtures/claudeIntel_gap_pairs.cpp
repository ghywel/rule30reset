// claudeIntel, N12 (I77).  Written from the definitions; shares no code or data with I81, I82 or R102.
//
// A driven site is black at tick 0 and white for the next q ticks, q = 9..16, then black again.  A vertex is the row
// of the W cells to its right at a pulse, nearest cell in bit 0.  There is an edge x --q--> y when one ordinary right
// half whose first W cells are x has first W cells y at the next pulse, q+1 ticks later.  Exactly the next q+1 cells
// matter, so every choice of them is tried (no exterior bit is chosen per tick).
//
//   build OUTDIR WMAX THREADS
//       W = 8 starts from all rows.  At each later W both lifts of each kept row are tried.  Kept: the strongly
//       connected components (on all eight gaps) in which both colours of the second-white sample occur.
//   pairs OUTDIR LETTERS WMIN WMAX KB KA THREADS
//       LETTERS is a bit mask (bit q-9).  On the edges with those gaps keep the components with both colours and
//       with internal edges of gaps 9 and 10.  A pair {x,y}, x != y, is COMMON when equal-gap walks from one common
//       row reach it and equal-gap walks from it reach one common row.  For every common pair whose samples differ,
//       list the words of KB gaps before it and KA gaps after it: along common pairs back (forward) to the first
//       equal pair met, and from there along the single graph.  Pairs at width W are sought among the lifts of the
//       common pairs (and equal pairs) at width W-1; a common pair projects to a common or an equal pair.
//       With TRIPLES set, at WMAX: for each differing common pair {b,w}, each common-or-equal pair {u,v} before it
//       and each {z,t} after it (equal gaps), the branches u->b->z and v->w->t are each tested for ONE ordinary
//       history across both gaps: every choice of the next s1+s2 cells.  A pair survives when some choice of
//       {u,v} and {z,t} passes on both branches.
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <map>
#include <set>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>
using namespace std;
typedef uint32_t u32;
typedef uint64_t u64;
typedef vector<u32> V;

static int THREADS = 8;
static void par(size_t n, size_t chunk, const function<void(size_t, size_t, int)> &fn) {
    atomic<size_t> next(0);
    vector<thread> ts;
    for (int t = 0; t < THREADS; t++)
        ts.emplace_back([&, t] {
            for (;;) {
                size_t a = next.fetch_add(chunk);
                if (a >= n) return;
                fn(a, min(n, a + chunk), t);
            }
        });
    for (auto &t : ts) t.join();
}

struct Graph {                       // sorted rows; per gap a CSR adjacency
    int W = 0;
    V row;
    V off[8], dst[8];
};
static int colour(u32 r) { return (r & 1) == 0 || (r & 6) == 0; }

static void save(const Graph &g, const string &f) {
    FILE *h = fopen(f.c_str(), "wb");
    u32 n = g.row.size();
    fwrite(&n, 4, 1, h);
    fwrite(g.row.data(), 4, n, h);
    for (int a = 0; a < 8; a++) {
        u32 m = g.dst[a].size();
        fwrite(&m, 4, 1, h);
        fwrite(g.off[a].data(), 4, n + 1, h);
        fwrite(g.dst[a].data(), 4, m, h);
    }
    fclose(h);
}
static Graph load(const string &f, int W) {
    Graph g;
    g.W = W;
    FILE *h = fopen(f.c_str(), "rb");
    if (!h) { fprintf(stderr, "cannot open %s\n", f.c_str()); exit(2); }
    u32 n, m;
    auto rd = [&](void *p, size_t k) { if (fread(p, 4, k, h) != k) { fprintf(stderr, "short read\n"); exit(2); } };
    rd(&n, 1);
    g.row.resize(n);
    rd(g.row.data(), n);
    for (int a = 0; a < 8; a++) {
        rd(&m, 1);
        g.off[a].resize(n + 1);
        g.dst[a].resize(m);
        rd(g.off[a].data(), n + 1);
        if (m) rd(g.dst[a].data(), m);
    }
    fclose(h);
    return g;
}

// ---------------------------------------------------------------- edges
static void edges(Graph &g) {
    int W = g.W;
    size_t n = g.row.size();
    u64 maskW = (1ull << W) - 1;
    vector<u64> present((1ull << W) / 64 + 1, 0);
    vector<u32> rank((1ull << W) / 64 + 2, 0);
    for (u32 r : g.row) present[r >> 6] |= 1ull << (r & 63);
    for (size_t i = 0; i + 1 < rank.size() && i < present.size(); i++) rank[i + 1] = rank[i] + __builtin_popcountll(present[i]);
    vector<vector<u32>> out[8];
    for (int a = 0; a < 8; a++) out[a].resize(n);
    vector<vector<u64>> bms(THREADS, vector<u64>(8 * 2048));
    par(n, 64, [&](size_t lo, size_t hi, int th) {
        u64 r[1024];
        u64 *bm = bms[th].data();
        for (size_t i = lo; i < hi; i++) {
            memset(bm, 0, 8 * 2048 * 8);
            u64 x = g.row[i], base[8];
            for (int blk = 0; blk < 128; blk++) {
                for (int k = 0; k < 1024; k++) r[k] = ((u64)(blk * 1024 + k) << W) | x;
                for (int s = 1; s <= 17; s++) {
                    if (s == 1) for (int k = 0; k < 1024; k++) r[k] = ((r[k] << 1) | 1) ^ (r[k] | (r[k] >> 1));
                    else for (int k = 0; k < 1024; k++) r[k] = (r[k] << 1) ^ (r[k] | (r[k] >> 1));
                    if (s < 10 || (u64)blk * 1024 >= (1ull << s)) continue;
                    u64 *b = bm + (s - 10) * 2048;
                    int sh = W - s;                    // W >= 17 handled below; smaller W uses the low bits only
                    if (sh >= 0) {
                        u64 km = (1ull << s) - 1;
                        for (int k = 0; k < 1024; k++) { u64 key = (r[k] >> sh) & km; b[key >> 6] |= 1ull << (key & 63); }
                        if (blk == 0) base[s - 10] = r[0] & ((1ull << sh) - 1);
                    } else {
                        for (int k = 0; k < 1024; k++) { u64 key = r[k] & maskW; b[key >> 6] |= 1ull << (key & 63); }
                        base[s - 10] = 0;
                    }
                }
            }
            for (int a = 0; a < 8; a++) {
                int s = a + 10, sh = W - s > 0 ? W - s : 0;
                int kb = min(s, W);
                size_t words = max<size_t>(1, (1ull << kb) / 64);
                for (size_t w = 0; w < words; w++) {
                    u64 m = bm[a * 2048 + w];
                    while (m) {
                        u64 key = w * 64 + __builtin_ctzll(m);
                        m &= m - 1;
                        u64 y = sh ? (key << sh) | base[a] : key;
                        if (present[y >> 6] >> (y & 63) & 1)
                            out[a][i].push_back(rank[y >> 6] + __builtin_popcountll(present[y >> 6] & ((1ull << (y & 63)) - 1)));
                    }
                }
            }
        }
    });
    for (int a = 0; a < 8; a++) {
        g.off[a].assign(n + 1, 0);
        size_t tot = 0;
        for (size_t i = 0; i < n; i++) { g.off[a][i] = tot; tot += out[a][i].size(); }
        g.off[a][n] = tot;
        g.dst[a].resize(tot);
        for (size_t i = 0; i < n; i++) { copy(out[a][i].begin(), out[a][i].end(), g.dst[a].begin() + g.off[a][i]); vector<u32>().swap(out[a][i]); }
        for (size_t i = 0; i < n; i++) sort(g.dst[a].begin() + g.off[a][i], g.dst[a].begin() + g.off[a][i + 1]);
    }
}

// ---------------------------------------------------------------- components (iterative Tarjan), then restriction
static V scc(const Graph &g, int letters, u32 &count) {
    size_t n = g.row.size();
    V comp(n, ~0u), low(n), idx(n, ~0u), st, call, pos(n);
    vector<unsigned char> let(n);
    u32 t = 0;
    count = 0;
    vector<unsigned char> on(n, 0);
    for (size_t s = 0; s < n; s++) {
        if (idx[s] != ~0u) continue;
        call.push_back(s);
        idx[s] = low[s] = t++;
        st.push_back(s);
        on[s] = 1;
        let[s] = 0;
        pos[s] = g.off[0][s];
        while (!call.empty()) {
            u32 v = call.back();
            bool moved = false;
            while (let[v] < 8) {
                int a = let[v];
                if (!(letters >> a & 1) || pos[v] >= g.off[a][v + 1]) {
                    let[v]++;
                    if (let[v] < 8) pos[v] = g.off[let[v]][v];
                    continue;
                }
                u32 u = g.dst[a][pos[v]++];
                if (idx[u] == ~0u) {
                    idx[u] = low[u] = t++;
                    st.push_back(u);
                    on[u] = 1;
                    let[u] = 0;
                    pos[u] = g.off[0][u];
                    call.push_back(u);
                    moved = true;
                    break;
                } else if (on[u]) low[v] = min(low[v], idx[u]);
            }
            if (moved) continue;
            call.pop_back();
            if (!call.empty()) low[call.back()] = min(low[call.back()], low[v]);
            if (low[v] == idx[v]) {
                for (;;) {
                    u32 u = st.back();
                    st.pop_back();
                    on[u] = 0;
                    comp[u] = count;
                    if (u == v) break;
                }
                count++;
            }
        }
    }
    return comp;
}
// keep components with both colours (and internal gaps 9 and 10 when need910); drop edges outside LETTERS or between components
static Graph keep(const Graph &g, int letters, bool need910, u32 &kept_components) {
    u32 c;
    V comp = scc(g, letters, c);
    size_t n = g.row.size();
    vector<unsigned char> flag(c, 0);
    for (size_t i = 0; i < n; i++) flag[comp[i]] |= colour(g.row[i]) ? 1 : 2;
    for (int a = 0; a < 2; a++)
        for (size_t i = 0; i < n; i++)
            for (u32 e = g.off[a][i]; e < g.off[a][i + 1]; e++)
                if (comp[g.dst[a][e]] == comp[i]) flag[comp[i]] |= a == 0 ? 4 : 8;
    int need = need910 ? 15 : 3;
    kept_components = 0;
    for (u32 k = 0; k < c; k++) if ((flag[k] & need) == need) kept_components++;
    V id(n, ~0u);
    Graph h;
    h.W = g.W;
    for (size_t i = 0; i < n; i++) if ((flag[comp[i]] & need) == need) { id[i] = h.row.size(); h.row.push_back(g.row[i]); }
    for (int a = 0; a < 8; a++) {
        h.off[a].push_back(0);
        for (size_t i = 0; i < n; i++) if (id[i] != ~0u) {
            if (letters >> a & 1)
                for (u32 e = g.off[a][i]; e < g.off[a][i + 1]; e++)
                    if (comp[g.dst[a][e]] == comp[i]) h.dst[a].push_back(id[g.dst[a][e]]);
            h.off[a].push_back(h.dst[a].size());
        }
    }
    return h;
}

static size_t nedges(const Graph &g) { size_t s = 0; for (int a = 0; a < 8; a++) s += g.dst[a].size(); return s; }

static void build(const string &dir, int wmax) {
    Graph g;
    g.W = 8;
    for (u32 r = 0; r < 256; r++) g.row.push_back(r);
    for (int W = 8; W <= wmax; W++) {
        if (W > 8) {
            V cand;
            for (u32 r : g.row) { cand.push_back(r); cand.push_back(r | (1u << (W - 1))); }
            sort(cand.begin(), cand.end());
            g = Graph();
            g.W = W;
            g.row = cand;
        }
        size_t c0 = g.row.size();
        edges(g);
        u32 k;
        g = keep(g, 255, false, k);
        printf("W=%d candidates %zu kept %zu edges %zu components %u\n", W, c0, g.row.size(), nedges(g), k);
        fflush(stdout);
        save(g, dir + "/g" + to_string(W) + ".bin");
    }
}

// ---------------------------------------------------------------- pairs
struct Pairs { V off, y; };                                   // CSR over x; y > x, sorted
static u32 locate(const Pairs &p, u32 a, u32 b) {
    if (a > b) swap(a, b);
    auto lo = p.y.begin() + p.off[a], hi = p.y.begin() + p.off[a + 1];
    auto it = lower_bound(lo, hi, b);
    return it != hi && *it == b ? u32(it - p.y.begin()) : ~0u;
}
static u32 xof(const Pairs &p, u32 id) { return u32(upper_bound(p.off.begin(), p.off.end(), id) - p.off.begin()) - 1; }

static Graph reversed(const Graph &g) {
    Graph r;
    r.W = g.W;
    r.row = g.row;
    size_t n = g.row.size();
    for (int a = 0; a < 8; a++) {
        r.off[a].assign(n + 1, 0);
        for (u32 d : g.dst[a]) r.off[a][d + 1]++;
        for (size_t i = 0; i < n; i++) r.off[a][i + 1] += r.off[a][i];
        r.dst[a].resize(g.dst[a].size());
        V c(r.off[a].begin(), r.off[a].end() - 1);
        for (size_t i = 0; i < n; i++)
            for (u32 e = g.off[a][i]; e < g.off[a][i + 1]; e++) r.dst[a][c[g.dst[a][e]]++] = i;
    }
    return r;
}
// pairs reachable from the diagonal along the edges of g, within `allowed` (empty: all)
static vector<unsigned char> reach(const Graph &g, const Pairs &p, const vector<unsigned char> *allowed) {
    size_t np = p.y.size(), n = g.row.size();
    vector<unsigned char> seen(np, 0);
    vector<V> local(THREADS);
    auto visit = [&](u32 x, u32 y, int th) {
        for (int a = 0; a < 8; a++)
            for (u32 e = g.off[a][x]; e < g.off[a][x + 1]; e++)
                for (u32 f = g.off[a][y]; f < g.off[a][y + 1]; f++) {
                    u32 u = g.dst[a][e], v = g.dst[a][f];
                    if (u == v || (x == y && u > v)) continue;
                    u32 id = locate(p, u, v);
                    if (id == ~0u || (allowed && !(*allowed)[id])) continue;
                    if (!__atomic_exchange_n(&seen[id], 1, __ATOMIC_RELAXED)) local[th].push_back(id);
                }
    };
    par(n, 256, [&](size_t lo, size_t hi, int th) { for (size_t i = lo; i < hi; i++) visit(i, i, th); });
    V front;
    for (;;) {
        front.clear();
        for (auto &l : local) { front.insert(front.end(), l.begin(), l.end()); V().swap(l); }
        if (front.empty()) break;
        par(front.size(), 4096, [&](size_t lo, size_t hi, int th) {
            for (size_t i = lo; i < hi; i++) { u32 x = xof(p, front[i]); visit(x, p.y[front[i]], th); }
        });
    }
    return seen;
}

struct Words {                                                // words of k gaps away from a pair, as base-16 numbers
    const Graph &g;
    const Pairs &p;
    const vector<unsigned char> &live;
    map<u64, set<u64>> memo;                                  // key: (x,y,k); diagonal pairs: x == y
    const set<u64> &get(u32 x, u32 y, int k) {
        if (x > y) swap(x, y);
        u64 key = ((u64)x << 36) | ((u64)y << 8) | k;
        auto it = memo.find(key);
        if (it != memo.end()) return it->second;
        set<u64> out;
        if (k == 0) out.insert(0);
        else
            for (int a = 0; a < 8; a++) {
                if (x == y) {
                    for (u32 e = g.off[a][x]; e < g.off[a][x + 1]; e++)
                        for (u64 w : get(g.dst[a][e], g.dst[a][e], k - 1)) out.insert(w << 4 | a);
                } else
                    for (u32 e = g.off[a][x]; e < g.off[a][x + 1]; e++)
                        for (u32 f = g.off[a][y]; f < g.off[a][y + 1]; f++) {
                            u32 u = g.dst[a][e], v = g.dst[a][f];
                            if (u != v) { u32 id = locate(p, u, v); if (id == ~0u || !live[id]) continue; }
                            for (u64 w : get(u, v, k - 1)) out.insert(w << 4 | a);
                        }
            }
        return memo[key] = out;
    }
};

// rows z (indices) such that one history has first W cells x at a pulse, y at the next (s1 ticks), z at the next (s2 ticks)
static V continuous(const Graph &g, u32 x, u32 y, int s1, int s2) {
    int W = g.W;
    u64 mask = (1ull << W) - 1, X = g.row[x], Y = g.row[y];
    set<u32> out;
    u64 r[1024];
    u64 blocks = 1ull << (s1 + s2 - 10);
    for (u64 blk = 0; blk < blocks; blk++) {
        for (int k = 0; k < 1024; k++) r[k] = ((blk * 1024 + k) << W) | X;
        for (int k = 0; k < 1024; k++) r[k] = ((r[k] << 1) | 1) ^ (r[k] | (r[k] >> 1));
        for (int s = 2; s <= s1; s++) for (int k = 0; k < 1024; k++) r[k] = (r[k] << 1) ^ (r[k] | (r[k] >> 1));
        for (int k = 0; k < 1024; k++) if ((r[k] & mask) == Y) {
            u64 q = r[k];
            q = ((q << 1) | 1) ^ (q | (q >> 1));
            for (int s = 2; s <= s2; s++) q = (q << 1) ^ (q | (q >> 1));
            out.insert(u32(q & mask));
        }
    }
    V res;
    for (u32 z : out) {
        auto it = lower_bound(g.row.begin(), g.row.end(), z);
        if (it != g.row.end() && *it == z) res.push_back(it - g.row.begin());
    }
    return res;
}
static void triples(const Graph &g, const Graph &r, const Pairs &p, const vector<unsigned char> &live, const vector<pair<u32, u32>> &diff) {
    auto ok = [&](u32 u, u32 v) { if (u == v) return true; u32 id = locate(p, u, v); return id != ~0u && live[id] != 0; };
    struct Leg { int a; u32 u, v; };
    vector<vector<Leg>> pre(diff.size()), suc(diff.size());
    typedef array<u32, 4> Key;                                 // x, y, s1, s2
    map<Key, V> table;
    for (size_t i = 0; i < diff.size(); i++) {
        u32 b = diff[i].first, w = diff[i].second;
        if (!colour(g.row[b])) swap(b, w);
        for (int dir = 0; dir < 2; dir++) {
            const Graph &h = dir ? g : r;
            for (int a = 0; a < 8; a++)
                for (u32 e = h.off[a][b]; e < h.off[a][b + 1]; e++)
                    for (u32 f = h.off[a][w]; f < h.off[a][w + 1]; f++)
                        if (ok(h.dst[a][e], h.dst[a][f])) (dir ? suc : pre)[i].push_back({a, h.dst[a][e], h.dst[a][f]});
        }
        for (auto &P : pre[i]) for (auto &S : suc[i]) {
            table[{P.u, b, u32(P.a + 10), u32(S.a + 10)}];
            table[{P.v, w, u32(P.a + 10), u32(S.a + 10)}];
        }
    }
    vector<map<Key, V>::iterator> its;
    for (auto it = table.begin(); it != table.end(); ++it) its.push_back(it);
    printf("  triples: %zu distinct two-gap legs to test\n", its.size());
    fflush(stdout);
    par(its.size(), 1, [&](size_t lo, size_t hi, int) {
        for (size_t i = lo; i < hi; i++) its[i]->second = continuous(g, its[i]->first[0], its[i]->first[1], its[i]->first[2], its[i]->first[3]);
    });
    size_t both = 0, black = 0, white = 0;
    map<pair<int, int>, size_t> gaps;
    FILE *h = getenv("SURVIVORS") ? fopen(getenv("SURVIVORS"), "w") : nullptr;
    for (size_t i = 0; i < diff.size(); i++) {
        u32 b = diff[i].first, w = diff[i].second;
        if (!colour(g.row[b])) swap(b, w);
        bool B = false, Wt = false, J = false;
        for (auto &P : pre[i]) for (auto &S : suc[i]) {
            auto &zb = table[{P.u, b, u32(P.a + 10), u32(S.a + 10)}];
            auto &zw = table[{P.v, w, u32(P.a + 10), u32(S.a + 10)}];
            bool cb = binary_search(zb.begin(), zb.end(), S.u), cw = binary_search(zw.begin(), zw.end(), S.v);
            B |= cb;
            Wt |= cw;
            if (cb && cw) {
                J = true;
                gaps[{P.a + 9, S.a + 9}]++;
                if (h) fprintf(h, "%d %d %u %u %u %u %u %u\n", P.a + 9, S.a + 9, g.row[P.u], g.row[b], g.row[S.u], g.row[P.v], g.row[w], g.row[S.v]);
            }
        }
        black += B;
        white += Wt;
        both += J;
    }
    if (h) fclose(h);
    printf("  differing pairs %zu: black branch continuous %zu, white branch continuous %zu, both on one pair of legs %zu\n", diff.size(), black, white, both);
    for (auto &k : gaps) printf("    gaps %d | %d: %zu pairs of legs\n", k.first.first, k.first.second, k.second);
    fflush(stdout);
}

// Words before the differing pairs, one gap further back at a time.  A state is a common pair or an equal pair.  A
// word is FORCED at length k while some walk for it has not yet met an equal pair; `first` words meet one at exactly k.
static void transit(const Graph &r, const Pairs &p, const vector<unsigned char> &live, const vector<pair<u32, u32>> &diff, int kmax) {
    map<string, vector<u64>> cur;
    vector<u64> st;
    for (auto &d : diff) st.push_back((u64)d.first << 32 | d.second);
    sort(st.begin(), st.end());
    cur[""] = st;
    for (int k = 1; k <= kmax; k++) {
        map<string, vector<u64>> nxt;
        set<string> first;
        vector<pair<string, vector<u64>>> items(cur.begin(), cur.end());
        vector<array<vector<u64>, 8>> res(items.size());
        vector<array<bool, 8>> dg(items.size());
        par(items.size(), 1, [&](size_t lo, size_t hi, int) {
            for (size_t i = lo; i < hi; i++)
                for (int a = 0; a < 8; a++) {
                    auto &o = res[i][a];
                    dg[i][a] = false;
                    for (u64 q : items[i].second) {
                        u32 x = q >> 32, y = (u32)q;
                        for (u32 e = r.off[a][x]; e < r.off[a][x + 1]; e++)
                            for (u32 f = r.off[a][y]; f < r.off[a][y + 1]; f++) {
                                u32 u = r.dst[a][e], v = r.dst[a][f];
                                if (u == v) { dg[i][a] = true; continue; }
                                if (u > v) swap(u, v);
                                u32 id = locate(p, u, v);
                                if (id != ~0u && live[id]) o.push_back((u64)u << 32 | v);
                            }
                    }
                    sort(o.begin(), o.end());
                    o.erase(unique(o.begin(), o.end()), o.end());
                }
        });
        for (size_t i = 0; i < items.size(); i++)
            for (int a = 0; a < 8; a++) {
                string w = to_string(9 + a) + (items[i].first.empty() ? "" : " ") + items[i].first;
                if (dg[i][a]) first.insert(w);
                if (!res[i][a].empty()) nxt[w].swap(res[i][a]);
            }
        size_t states = 0;
        for (auto &c : nxt) states += c.second.size();
        printf("  k=%d words still in transit %zu (states %zu), words first meeting an equal pair %zu\n", k, nxt.size(), states, first.size());
        int shown = 0;
        if (nxt.size() <= 14) for (auto &c : nxt) { printf("      %s\n", c.first.c_str()); shown++; }
        if (first.size() && first.size() <= 10) for (auto &w : first) printf("      first: %s\n", w.c_str());
        fflush(stdout);
        cur.swap(nxt);
        if (cur.empty() || cur.size() > 20000) break;
    }
}

static void pairs_cmd(const string &dir, int letters, int wmin, int wmax, int KB, int KA) {
    V prevRows;                                               // rows at W-1
    vector<pair<u32, u32>> prev;                              // common pairs at W-1, as rows
    for (int W = wmin; W <= wmax; W++) {
        Graph full = load(dir + "/g" + to_string(W) + ".bin", W);
        u32 comps;
        Graph g = keep(full, letters, true, comps);
        full = Graph();
        size_t n = g.row.size();
        auto find = [&](u32 r) -> u32 { auto it = lower_bound(g.row.begin(), g.row.end(), r); return it != g.row.end() && *it == r ? u32(it - g.row.begin()) : ~0u; };
        Pairs p;
        p.off.assign(n + 1, 0);
        if (W == wmin) {
            for (size_t i = 0; i < n; i++) p.off[i + 1] = p.off[i] + (n - 1 - i);
            p.y.resize(p.off[n]);
            for (size_t i = 0; i < n; i++) for (size_t j = i + 1; j < n; j++) p.y[p.off[i] + j - i - 1] = j;
        } else {
            u32 top = 1u << (W - 1);
            auto lifts = [&](const function<void(u32, u32)> &fn) {
                for (size_t i = 0; i < n; i++) if (!(g.row[i] & top)) { u32 j = find(g.row[i] | top); if (j != ~0u) fn(i, j); }
                for (auto &q : prev)
                    for (int s = 0; s < 2; s++) {
                        u32 i = find(q.first | (s ? top : 0));
                        if (i == ~0u) continue;
                        for (int t = 0; t < 2; t++) { u32 j = find(q.second | (t ? top : 0)); if (j != ~0u) fn(min(i, j), max(i, j)); }
                    }
            };
            vector<u64> cnt(n + 1, 0);
            lifts([&](u32 i, u32) { cnt[i + 1]++; });
            for (size_t i = 0; i < n; i++) cnt[i + 1] += cnt[i];
            if (cnt[n] > 4000000000ull) { printf("too many candidate pairs: %llu\n", (unsigned long long)cnt[n]); return; }
            for (size_t i = 0; i <= n; i++) p.off[i] = cnt[i];
            p.y.resize(cnt[n]);
            vector<u64> at(cnt.begin(), cnt.end() - 1);
            lifts([&](u32 i, u32 j) { p.y[at[i]++] = j; });
            par(n, 1024, [&](size_t lo, size_t hi, int) { for (size_t i = lo; i < hi; i++) sort(p.y.begin() + p.off[i], p.y.begin() + p.off[i + 1]); });
        }
        vector<pair<u32, u32>>().swap(prev);
        Graph r = reversed(g);
        auto fwd = reach(g, p, nullptr);
        auto live = reach(r, p, &fwd);
        size_t nf = 0, nl = 0;
        for (size_t i = 0; i < p.y.size(); i++) { nf += fwd[i]; nl += live[i]; }
        vector<unsigned char>().swap(fwd);
        vector<pair<u32, u32>> diff;
        prev.reserve(nl);
        for (size_t x = 0; x < n; x++)
            for (u32 k = p.off[x]; k < p.off[x + 1]; k++) if (live[k]) {
                prev.emplace_back(g.row[x], g.row[p.y[k]]);
                if (colour(g.row[x]) != colour(g.row[p.y[k]])) diff.emplace_back(x, p.y[k]);
            }
        printf("W=%d letters %d rows %zu edges %zu components %u candidates %zu forward %zu common %zu differing %zu\n", W, letters, n,
               nedges(g), comps, p.y.size(), nf, nl, diff.size());
        fflush(stdout);
        Words past{r, p, live, {}}, fut{g, p, live, {}};
        map<pair<u64, u64>, size_t> ctx;
        for (auto &d : diff) {
            auto &A = past.get(d.first, d.second, KB);
            auto &B = fut.get(d.first, d.second, KA);
            for (u64 a : A) for (u64 b : B) ctx[{a, b}]++;
        }
        printf("  contexts (%d before, %d after): %zu\n", KB, KA, ctx.size());
        // A word w from get() holds the letter nearest the pair in its low nibble.
        size_t shown = 0;
        map<string, size_t> before;
        for (auto &c : ctx) {
            string s;
            for (int k = KB - 1; k >= 0; k--) s += to_string(9 + int(c.first.first >> (4 * k) & 15)) + " ";
            before[s] += 0;
            if (ctx.size() <= 60 || shown < 12) {
                string t;
                for (int k = 0; k < KA; k++) t += " " + to_string(9 + int(c.first.second >> (4 * k) & 15));
                printf("    %s|%s   pairs %zu\n", s.c_str(), t.c_str(), c.second);
                shown++;
            }
        }
        // per position: the gaps that occur
        for (int k = KB - 1; k >= 0; k--) {
            set<int> S;
            for (auto &c : ctx) S.insert(9 + int(c.first.first >> (4 * k) & 15));
            printf("  position -%d:", k + 1);
            for (int v : S) printf(" %d", v);
            printf("\n");
        }
        for (int k = 0; k < KA; k++) {
            set<int> S;
            for (auto &c : ctx) S.insert(9 + int(c.first.second >> (4 * k) & 15));
            printf("  position +%d:", k + 1);
            for (int v : S) printf(" %d", v);
            printf("\n");
        }
        fflush(stdout);
        if (const char *t = getenv("TRANSIT")) transit(r, p, live, diff, atoi(t));
        if (getenv("TRIPLES") && W == wmax) triples(g, r, p, live, diff);
        if (const char *f = getenv("DUMP")) {                 // differing pairs, as rows, at the last width
            if (W == wmax) {
                FILE *h = fopen(f, "w");
                for (auto &d : diff) fprintf(h, "%u %u\n", g.row[d.first], g.row[d.second]);
                fclose(h);
            }
        }
    }
}

int main(int argc, char **argv) {
    if (argc >= 5 && !strcmp(argv[1], "build")) { THREADS = atoi(argv[4]); build(argv[2], atoi(argv[3])); return 0; }
    if (argc >= 9 && !strcmp(argv[1], "pairs")) {
        THREADS = atoi(argv[8]);
        pairs_cmd(argv[2], atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));
        return 0;
    }
    fprintf(stderr, "usage: build OUTDIR WMAX THREADS | pairs OUTDIR LETTERS WMIN WMAX KB KA THREADS\n");
    return 2;
}
