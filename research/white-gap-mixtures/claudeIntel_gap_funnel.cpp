// claudeIntel, N12 (I77).  The funnel: the common pairs met going back from the differing pairs, as rows, per word.
// Usage: funnel GRAPHDIR LETTERS WMIN W KMAX THREADS   prints: k word x y  (rows)  to stdout, for every state.
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main
int main(int argc, char **argv) {
    string dir = argv[1];
    int letters = atoi(argv[2]), wmin = atoi(argv[3]), wmax = atoi(argv[4]), kmax = atoi(argv[5]);
    THREADS = atoi(argv[6]);
    vector<pair<u32, u32>> prev;
    for (int W = wmin; W <= wmax; W++) {
        Graph full = load(dir + "/g" + to_string(W) + ".bin", W);
        u32 comps;
        Graph g = keep(full, letters, true, comps);
        size_t n = g.row.size();
        auto find = [&](u32 r) -> u32 { auto it = lower_bound(g.row.begin(), g.row.end(), r); return it != g.row.end() && *it == r ? u32(it - g.row.begin()) : ~0u; };
        Pairs p;
        p.off.assign(n + 1, 0);
        vector<u64> keys;
        if (W == wmin) {
            for (size_t i = 0; i < n; i++) for (size_t j = i + 1; j < n; j++) keys.push_back((u64)i << 32 | j);
        } else {
            u32 top = 1u << (W - 1);
            for (size_t i = 0; i < n; i++) if (!(g.row[i] & top)) { u32 j = find(g.row[i] | top); if (j != ~0u) keys.push_back((u64)i << 32 | j); }
            for (auto &q : prev) for (int s = 0; s < 4; s++) {
                u32 i = find(q.first | (s & 1 ? top : 0)), j = find(q.second | (s & 2 ? top : 0));
                if (i != ~0u && j != ~0u) keys.push_back((u64)min(i, j) << 32 | max(i, j));
            }
            sort(keys.begin(), keys.end());
        }
        for (u64 k : keys) { p.off[(k >> 32) + 1]++; p.y.push_back((u32)k); }
        for (size_t i = 0; i < n; i++) p.off[i + 1] += p.off[i];
        Graph r = reversed(g);
        auto fwd = reach(g, p, nullptr);
        auto live = reach(r, p, &fwd);
        prev.clear();
        vector<u64> cur;
        for (size_t x = 0; x < n; x++) for (u32 k = p.off[x]; k < p.off[x + 1]; k++) if (live[k]) {
            prev.emplace_back(g.row[x], g.row[p.y[k]]);
            if (colour(g.row[x]) != colour(g.row[p.y[k]])) cur.push_back((u64)x << 32 | p.y[k]);
        }
        if (W < wmax) continue;
        map<string, vector<u64>> st;
        st["-"] = cur;
        for (int k = 0; k <= kmax; k++) {
            for (auto &c : st) for (u64 q : c.second) printf("%d %s %u %u\n", k, c.first.c_str(), g.row[q >> 32], g.row[(u32)q]);
            map<string, vector<u64>> nx;
            for (auto &c : st) for (u64 q : c.second) {
                u32 x = q >> 32, y = (u32)q;
                for (int a = 0; a < 8; a++)
                    for (u32 e = r.off[a][x]; e < r.off[a][x + 1]; e++) for (u32 f = r.off[a][y]; f < r.off[a][y + 1]; f++) {
                        u32 u = r.dst[a][e], v = r.dst[a][f];
                        if (u == v) continue;
                        if (u > v) swap(u, v);
                        u32 id = locate(p, u, v);
                        if (id == ~0u || !live[id]) continue;
                        string w = to_string(9 + a) + (c.first == "-" ? "" : "," + c.first);
                        nx[w].push_back((u64)u << 32 | v);
                    }
            }
            for (auto &c : nx) { sort(c.second.begin(), c.second.end()); c.second.erase(unique(c.second.begin(), c.second.end()), c.second.end()); }
            st.swap(nx);
        }
    }
}
