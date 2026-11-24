// claudeIntel, N12 (I77).  The way in, layer by layer, at widths beyond the full pair product.
//
//   build DIR LETTERS WMAX THREADS     graphs on the chosen gaps only (components with both colours and gaps 9, 10)
//   layers DIR LETTERS WMIN WBASE WMAX K THREADS
//       At WBASE: the full common-pair product.  Layer 0 is the differing common pairs; layer k+1 is every common or
//       equal pair with an equal-gap edge into layer k.  Equal pairs are passed through (a lifted walk may be distinct
//       where its projection is equal).  At W+1 a state of layer k must project to a state of layer k at W, must lead
//       into layer k-1 at W+1, and (k < K) must have a state of layer k+1 before it.  A pair of walks at W+1 that meet,
//       part, disagree and meet again projects to such a walk at W, so the layers are supersets and every word they
//       exclude is excluded.  Printed per width: the words read back from layer 0 through distinct pairs (in transit)
//       and the words that first reach an equal pair.
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main

typedef vector<u64> S;
static u64 mk(u32 a, u32 b) { return a < b ? (u64)a << 32 | b : (u64)b << 32 | a; }

static void build_letters(const string &dir, int letters, int wmax) {
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
        g = keep(g, W >= 14 ? letters : 255, W >= 14, k);
        printf("W=%d candidates %zu kept %zu edges %zu components %u\n", W, c0, g.row.size(), nedges(g), k);
        fflush(stdout);
        save(g, dir + "/g" + to_string(W) + ".bin");
    }
}

// all states with an equal-gap edge into a state of `from`, kept when ok() holds; as row values
template <class OK> static S before(const Graph &g, const Graph &r, const S &from, OK ok) {
    vector<S> out(THREADS);
    auto idx = [&](u32 row) { return u32(lower_bound(g.row.begin(), g.row.end(), row) - g.row.begin()); };
    par(from.size(), 512, [&](size_t lo, size_t hi, int th) {
        for (size_t i = lo; i < hi; i++) {
            u32 x = idx(from[i] >> 32), y = idx((u32)from[i]);
            for (int a = 0; a < 8; a++)
                for (u32 e = r.off[a][x]; e < r.off[a][x + 1]; e++)
                    for (u32 f = r.off[a][y]; f < r.off[a][y + 1]; f++) {
                        u64 k = mk(g.row[r.dst[a][e]], g.row[r.dst[a][f]]);
                        if (ok(k)) out[th].push_back(k);
                    }
            if (out[th].size() > 20000000) { sort(out[th].begin(), out[th].end()); out[th].erase(unique(out[th].begin(), out[th].end()), out[th].end()); }
        }
    });
    S all;
    for (auto &o : out) { all.insert(all.end(), o.begin(), o.end()); S().swap(o); }
    sort(all.begin(), all.end());
    all.erase(unique(all.begin(), all.end()), all.end());
    return all;
}
static bool in(const S &s, u64 k) { return binary_search(s.begin(), s.end(), k); }

static void words(const Graph &g, const Graph &r, const vector<S> &L, int K, size_t cap) {
    auto idx = [&](u32 row) { return u32(lower_bound(g.row.begin(), g.row.end(), row) - g.row.begin()); };
    map<string, S> cur;
    cur[""] = L[0];
    for (int k = 1; k <= K; k++) {
        map<string, S> nxt;
        set<string> first;
        for (auto &c : cur) {
            S o[8];
            bool dg[8] = {};
            for (u64 q : c.second) {
                u32 x = idx(q >> 32), y = idx((u32)q);
                for (int a = 0; a < 8; a++)
                    for (u32 e = r.off[a][x]; e < r.off[a][x + 1]; e++)
                        for (u32 f = r.off[a][y]; f < r.off[a][y + 1]; f++) {
                            u64 s = mk(g.row[r.dst[a][e]], g.row[r.dst[a][f]]);
                            if (!in(L[k], s)) continue;
                            if ((s >> 32) == (u32)s) dg[a] = true; else o[a].push_back(s);
                        }
            }
            for (int a = 0; a < 8; a++) {
                string w = to_string(9 + a) + (c.first.empty() ? "" : " ") + c.first;
                if (dg[a]) first.insert(w);
                if (!o[a].empty()) { sort(o[a].begin(), o[a].end()); o[a].erase(unique(o[a].begin(), o[a].end()), o[a].end()); nxt[w].swap(o[a]); }
            }
        }
        size_t st = 0;
        for (auto &c : nxt) st += c.second.size();
        printf("  k=%d words in transit %zu (states %zu), first meeting %zu\n", k, nxt.size(), st, first.size());
        if (nxt.size() <= 10) for (auto &c : nxt) printf("      %s\n", c.first.c_str());
        if (!first.empty() && first.size() <= 6) for (auto &w : first) printf("      first: %s\n", w.c_str());
        fflush(stdout);
        cur.swap(nxt);
        if (cur.empty() || cur.size() > cap) break;
    }
}

int main(int argc, char **argv) {
    if (argc == 6 && !strcmp(argv[1], "build")) { THREADS = atoi(argv[5]); build_letters(argv[2], atoi(argv[3]), atoi(argv[4])); return 0; }
    if (argc != 9 || strcmp(argv[1], "layers")) { fprintf(stderr, "usage: build DIR LETTERS WMAX THREADS | layers DIR LETTERS WMIN WBASE WMAX K THREADS\n"); return 2; }
    string dir = argv[2];
    int letters = atoi(argv[3]), wmin = atoi(argv[4]), wbase = atoi(argv[5]), wmax = atoi(argv[6]), K = atoi(argv[7]);
    THREADS = atoi(argv[8]);
    vector<pair<u32, u32>> prev;
    vector<S> L;
    for (int W = wmin; W <= wmax; W++) {
        Graph full = load(dir + "/g" + to_string(W) + ".bin", W);
        u32 comps;
        Graph g = keep(full, letters, true, comps);
        full = Graph();
        Graph r = reversed(g);
        size_t n = g.row.size();
        auto find = [&](u32 row) -> u32 { auto it = lower_bound(g.row.begin(), g.row.end(), row); return it != g.row.end() && *it == row ? u32(it - g.row.begin()) : ~0u; };
        u32 top = 1u << (W - 1);
        if (W <= wbase) {
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
            S common, diff;
            for (size_t x = 0; x < n; x++) for (u32 k = p.off[x]; k < p.off[x + 1]; k++) if (live[k]) {
                prev.emplace_back(g.row[x], g.row[p.y[k]]);
                if (W == wbase) {
                    common.push_back(mk(g.row[x], g.row[p.y[k]]));
                    if (colour(g.row[x]) != colour(g.row[p.y[k]])) diff.push_back(mk(g.row[x], g.row[p.y[k]]));
                }
            }
            printf("W=%d rows %zu common %zu\n", W, n, prev.size());
            fflush(stdout);
            if (W < wbase) continue;
            sort(common.begin(), common.end());
            sort(diff.begin(), diff.end());
            L.assign(1, diff);
            for (int k = 1; k <= K; k++) L.push_back(before(g, r, L.back(), [&](u64 s) { return (s >> 32) == (u32)s || in(common, s); }));
        } else {
            u64 m = ((u64)(top - 1) << 32) | (top - 1);
            auto proj = [&](u64 s) { u64 q = s & m; return mk(q >> 32, (u32)q); };
            vector<S> N(1);
            for (u64 s : L[0]) {
                u32 a = s >> 32, b = (u32)s;
                for (int t = 0; t < 4; t++) { u32 x = a | (t & 1 ? top : 0), y = b | (t & 2 ? top : 0); if (find(x) != ~0u && find(y) != ~0u) N[0].push_back(mk(x, y)); }
            }
            sort(N[0].begin(), N[0].end());
            N[0].erase(unique(N[0].begin(), N[0].end()), N[0].end());
            for (int k = 1; k <= K; k++) { N.push_back(before(g, r, N.back(), [&](u64 s) { return in(L[k], proj(s)); })); }
            for (int k = K - 1; k >= 0; k--) {            // a state of layer k < K needs a state of layer k+1 before it
                S keepS;
                auto idx = [&](u32 row) { return u32(lower_bound(g.row.begin(), g.row.end(), row) - g.row.begin()); };
                vector<unsigned char> ok(N[k].size(), 0);
                par(N[k].size(), 512, [&](size_t lo, size_t hi, int) {
                    for (size_t i = lo; i < hi; i++) {
                        u64 s = N[k][i];
                        u32 x = idx(s >> 32), y = idx((u32)s);
                        for (int a = 0; a < 8 && !ok[i]; a++)
                            for (u32 e = r.off[a][x]; e < r.off[a][x + 1] && !ok[i]; e++)
                                for (u32 f = r.off[a][y]; f < r.off[a][y + 1]; f++)
                                    if (in(N[k + 1], mk(g.row[r.dst[a][e]], g.row[r.dst[a][f]]))) { ok[i] = 1; break; }
                    }
                });
                for (size_t i = 0; i < N[k].size(); i++) if (ok[i]) keepS.push_back(N[k][i]);
                N[k].swap(keepS);
            }
            for (int k = 1; k <= K; k++) {                // and it must still lead into layer k-1
                S re = before(g, r, N[k - 1], [&](u64 s) { return in(N[k], s); });
                N[k].swap(re);
            }
            L.swap(N);
        }
        printf("W=%d rows %zu layers:", W, n);
        for (auto &l : L) {
            size_t d = 0;
            for (u64 s : l) d += (s >> 32) == (u32)s;
            printf(" %zu(%zu=)", l.size(), d);
        }
        printf("\n");
        fflush(stdout);
        if (L[0].empty()) { printf("  no differing pair is left\n"); return 0; }
        words(g, r, L, K, 3000);
    }
}
