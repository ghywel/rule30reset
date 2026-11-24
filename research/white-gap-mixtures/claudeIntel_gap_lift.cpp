// claudeIntel, N12 (I77).  The layers of claudeIntel_gap_layers.cpp, lifted without any graph above the base width.
//
// Base width B: layer 0 is the differing common pairs of the full product on the chosen gaps; layer k+1 is every
// common or equal pair with an equal-gap edge into layer k.  Above B a state of layer k at width W+1 must project to a
// state of layer k at W and have an equal-gap edge into layer k-1 at W+1 and one out of layer k+1.  A one-lane edge
// u --q--> x at W+1 is tested directly: some choice of the q+1 cells beyond the W+1 of u gives x at the next pulse.
// No recurrence is imposed above B, so the layers are supersets of those that use the recurrent graph.  An empty layer
// excludes every gap order on the alphabet.
//
// Usage: lift GRAPHDIR LETTERS WMIN B WMAX K THREADS        (rows are 64-bit; WMAX <= 46)
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main
typedef pair<u64, u64> St;                                    // row values, first <= second
typedef vector<St> L1;
static St st(u64 a, u64 b) { return a < b ? St(a, b) : St(b, a); }
static bool has(const L1 &l, const St &s) { return binary_search(l.begin(), l.end(), s); }
template <class T> static void uniq(vector<T> &v) { sort(v.begin(), v.end()); v.erase(unique(v.begin(), v.end()), v.end()); }

// one-lane edges per gap: pred[a][x] = rows u with u --a+9--> x
typedef unordered_map<u64, vector<u64>> Pred;

// For one row u (W cells) and a gap of s-1: which of the sorted targets are reached by some choice of the next s cells
static void reached(u64 u, int W, int s, const vector<u64> &targets, vector<unsigned char> &hit) {
    u64 r[1024];
    static thread_local vector<u64> bm;
    int sh = W - s;
    u64 base = 0, km = (1ull << s) - 1;
    bm.assign((1u << s) / 64 + 1, 0);
    u32 blocks = 1u << (s - 10);
    for (u32 blk = 0; blk < blocks; blk++) {
        for (int k = 0; k < 1024; k++) r[k] = ((u64)(blk * 1024 + k) << W) | u;
        for (int k = 0; k < 1024; k++) r[k] = ((r[k] << 1) | 1) ^ (r[k] | (r[k] >> 1));
        for (int t = 2; t <= s; t++) for (int k = 0; k < 1024; k++) r[k] = (r[k] << 1) ^ (r[k] | (r[k] >> 1));
        for (int k = 0; k < 1024; k++) { u64 key = (r[k] >> sh) & km; bm[key >> 6] |= 1ull << (key & 63); }
        if (!blk) base = r[0] & ((1ull << sh) - 1);
    }
    hit.assign(targets.size(), 0);
    for (size_t i = 0; i < targets.size(); i++) {
        u64 y = targets[i];
        if ((y & ((1ull << sh) - 1)) != base) continue;
        u64 key = y >> sh;
        if (bm[key >> 6] >> (key & 63) & 1) hit[i] = 1;
    }
}

// the states of `pool` with an equal-gap edge into a state of `to`
static L1 into(const Pred *pred, const L1 &to, const function<bool(const St &)> &ok) {
    vector<L1> out(THREADS);
    par(to.size(), 256, [&](size_t lo, size_t hi, int th) {
        for (size_t i = lo; i < hi; i++)
            for (int a = 0; a < 8; a++) {
                auto p = pred[a].find(to[i].first), q = pred[a].find(to[i].second);
                if (p == pred[a].end() || q == pred[a].end()) continue;
                for (u64 u : p->second) for (u64 v : q->second) { St s = st(u, v); if (ok(s)) out[th].push_back(s); }
            }
    });
    L1 all;
    for (auto &o : out) { all.insert(all.end(), o.begin(), o.end()); L1().swap(o); }
    uniq(all);
    return all;
}

static void words(const Pred *pred, const vector<L1> &L, int K) {
    map<string, L1> cur;
    cur[""] = L[0];
    for (int k = 1; k <= K; k++) {
        map<string, L1> nxt;
        set<string> first;
        for (auto &c : cur) for (auto &s : c.second) for (int a = 0; a < 8; a++) {
            auto p = pred[a].find(s.first), q = pred[a].find(s.second);
            if (p == pred[a].end() || q == pred[a].end()) continue;
            string w = to_string(9 + a) + (c.first.empty() ? "" : " ") + c.first;
            for (u64 u : p->second) for (u64 v : q->second) {
                St t = st(u, v);
                if (!has(L[k], t)) continue;
                if (u == v) first.insert(w); else nxt[w].push_back(t);
            }
        }
        size_t n = 0;
        for (auto &c : nxt) { uniq(c.second); n += c.second.size(); }
        printf("    k=%d words in transit %zu (states %zu), first meeting %zu\n", k, nxt.size(), n, first.size());
        if (nxt.size() <= 6 && k >= 5) for (auto &c : nxt) printf("        %s\n", c.first.c_str());
        cur.swap(nxt);
        if (cur.empty() || cur.size() > 400) break;
    }
    fflush(stdout);
}

int main(int argc, char **argv) {
    if (argc != 8) { fprintf(stderr, "usage: lift GRAPHDIR LETTERS WMIN B WMAX K THREADS\n"); return 2; }
    string dir = argv[1];
    int letters = atoi(argv[2]), wmin = atoi(argv[3]), B = atoi(argv[4]), wmax = atoi(argv[5]), K = atoi(argv[6]);
    THREADS = atoi(argv[7]);
    vector<pair<u32, u32>> prev;
    vector<L1> L;
    Pred pred[8];
    for (int W = wmin; W <= B; W++) {
        Graph full = load(dir + "/g" + to_string(W) + ".bin", W);
        u32 comps;
        Graph g = keep(full, letters, true, comps);
        Graph r = reversed(g);
        size_t n = g.row.size();
        auto find = [&](u32 row) -> u32 { auto it = lower_bound(g.row.begin(), g.row.end(), row); return it != g.row.end() && *it == row ? u32(it - g.row.begin()) : ~0u; };
        u32 top = 1u << (W - 1);
        vector<u64> keys;
        if (W == wmin) {
            for (size_t i = 0; i < n; i++) for (size_t j = i + 1; j < n; j++) keys.push_back((u64)i << 32 | j);
        } else {
            for (size_t i = 0; i < n; i++) if (!(g.row[i] & top)) { u32 j = find(g.row[i] | top); if (j != ~0u) keys.push_back((u64)i << 32 | j); }
            for (auto &q : prev) for (int s = 0; s < 4; s++) {
                u32 i = find(q.first | (s & 1 ? top : 0)), j = find(q.second | (s & 2 ? top : 0));
                if (i != ~0u && j != ~0u) keys.push_back((u64)min(i, j) << 32 | max(i, j));
            }
            sort(keys.begin(), keys.end());
        }
        Pairs p;
        p.off.assign(n + 1, 0);
        for (u64 k : keys) { p.off[(k >> 32) + 1]++; p.y.push_back((u32)k); }
        for (size_t i = 0; i < n; i++) p.off[i + 1] += p.off[i];
        vector<u64>().swap(keys);
        auto fwd = reach(g, p, nullptr);
        auto live = reach(r, p, &fwd);
        prev.clear();
        L1 common, diff;
        for (size_t x = 0; x < n; x++) for (u32 k = p.off[x]; k < p.off[x + 1]; k++) if (live[k]) {
            prev.emplace_back(g.row[x], g.row[p.y[k]]);
            if (W == B) {
                common.push_back(st(g.row[x], g.row[p.y[k]]));
                if (colour(g.row[x]) != colour(g.row[p.y[k]])) diff.push_back(common.back());
            }
        }
        if (W < B) continue;
        uniq(common);
        uniq(diff);
        printf("base W=%d rows %zu common %zu differing %zu\n", W, n, common.size(), diff.size());
        for (int a = 0; a < 8; a++)
            for (size_t x = 0; x < n; x++) if (r.off[a][x + 1] > r.off[a][x]) {
                auto &v = pred[a][g.row[x]];
                for (u32 e = r.off[a][x]; e < r.off[a][x + 1]; e++) v.push_back(g.row[r.dst[a][e]]);
            }
        L.assign(1, diff);
        for (int k = 1; k <= K; k++) L.push_back(into(pred, L.back(), [&](const St &s) { return s.first == s.second || has(common, s); }));
    }
    for (int W = B; W <= wmax; W++) {
        if (W > B) {
            u64 top = 1ull << (W - 1), m = top - 1;
            // one-lane edges met between layers k+1 and k at W-1
            vector<pair<u64, u64>> E[8];
            for (int a = 0; a < 8; a++) {
                vector<vector<pair<u64, u64>>> o(THREADS);
                for (int k = 0; k < K; k++)
                    par(L[k].size(), 256, [&](size_t lo, size_t hi, int th) {
                        for (size_t i = lo; i < hi; i++) {
                            auto p = pred[a].find(L[k][i].first), q = pred[a].find(L[k][i].second);
                            if (p == pred[a].end() || q == pred[a].end()) continue;
                            for (u64 u : p->second) for (u64 v : q->second)
                                if (has(L[k + 1], st(u, v))) { o[th].push_back({u, L[k][i].first}); o[th].push_back({v, L[k][i].second}); }
                            if (o[th].size() > 4000000) uniq(o[th]);
                        }
                    });
                for (auto &x : o) { E[a].insert(E[a].end(), x.begin(), x.end()); }
                uniq(E[a]);
            }
            Pred np[8];
            size_t tested = 0, kept = 0;
            for (int a = 0; a < 8; a++) {
                // group by u
                vector<pair<size_t, size_t>> grp;
                for (size_t i = 0; i < E[a].size();) { size_t j = i; while (j < E[a].size() && E[a][j].first == E[a][i].first) j++; grp.push_back({i, j}); i = j; }
                vector<vector<pair<u64, u64>>> res(THREADS);
                par(grp.size(), 4, [&](size_t lo, size_t hi, int th) {
                    vector<unsigned char> hit;
                    for (size_t gi = lo; gi < hi; gi++) {
                        vector<u64> T;
                        for (size_t i = grp[gi].first; i < grp[gi].second; i++) { T.push_back(E[a][i].second); T.push_back(E[a][i].second | top); }
                        for (int b = 0; b < 2; b++) {
                            u64 u = E[a][grp[gi].first].first | (b ? top : 0);
                            reached(u, W, a + 10, T, hit);
                            for (size_t i = 0; i < T.size(); i++) if (hit[i]) res[th].push_back({T[i], u});
                        }
                    }
                });
                for (auto &x : res) for (auto &e : x) { np[a][e.first].push_back(e.second); kept++; }
                tested += E[a].size() * 4;
            }
            auto proj = [&](const St &s) { return st(s.first & m, s.second & m); };
            vector<L1> N(1);
            for (auto &s : L[0]) for (int t = 0; t < 4; t++) N[0].push_back(st(s.first | (t & 1 ? top : 0), s.second | (t & 2 ? top : 0)));
            uniq(N[0]);
            for (int k = 1; k <= K; k++) N.push_back(into(np, N.back(), [&](const St &s) { return has(L[k], proj(s)); }));
            for (int k = K - 1; k >= 0; k--) {
                vector<unsigned char> ok(N[k].size(), 0);
                par(N[k].size(), 256, [&](size_t lo, size_t hi, int) {
                    for (size_t i = lo; i < hi; i++)
                        for (int a = 0; a < 8 && !ok[i]; a++) {
                            auto p = np[a].find(N[k][i].first), q = np[a].find(N[k][i].second);
                            if (p == np[a].end() || q == np[a].end()) continue;
                            for (u64 u : p->second) { for (u64 v : q->second) if (has(N[k + 1], st(u, v))) { ok[i] = 1; break; } if (ok[i]) break; }
                        }
                });
                L1 kp;
                for (size_t i = 0; i < N[k].size(); i++) if (ok[i]) kp.push_back(N[k][i]);
                N[k].swap(kp);
            }
            for (int k = 1; k <= K; k++) { L1 re = into(np, N[k - 1], [&](const St &s) { return has(N[k], s); }); N[k].swap(re); }
            L.swap(N);
            for (int a = 0; a < 8; a++) pred[a].swap(np[a]);
            printf("W=%d one-lane edges tested %zu kept %zu\n", W, tested, kept);
        }
        printf("W=%d layers:", W);
        for (auto &l : L) { size_t d = 0; for (auto &s : l) d += s.first == s.second; printf(" %zu(%zu=)", l.size(), d); }
        printf("\n");
        fflush(stdout);
        if (L[0].empty()) { printf("  no differing pair is left\n"); return 0; }
        words(pred, L, K);
    }
}
