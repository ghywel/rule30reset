// claudeIntel N12: unfixed words on the recurrent graph, classified
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main
int main(int argc, char **argv) {
    string dir = argv[1]; int W = atoi(argv[2]), letters = atoi(argv[3]), kmax = atoi(argv[4]); THREADS = atoi(argv[5]);
    size_t cap = argc > 6 ? atoi(argv[6]) : 4000;
    Graph full = load(dir + "/g" + to_string(W) + ".bin", W); u32 c; Graph g = keep(full, letters, true, c); Graph r = reversed(g);
    size_t n = g.row.size();
    struct It { vector<int> w; V b, k; };
    auto pre = [&](const V &s, int a) { V o; for (u32 x : s) for (u32 e = r.off[a][x]; e < r.off[a][x+1]; e++) o.push_back(r.dst[a][e]); sort(o.begin(), o.end()); o.erase(unique(o.begin(), o.end()), o.end()); return o; };
    It s; for (size_t i = 0; i < n; i++) (colour(g.row[i]) ? s.b : s.k).push_back(i);
    vector<It> cur; cur.push_back(move(s));
    printf("W=%d rows %zu\n", W, n);
    for (int d = 1; d <= kmax; d++) {
        vector<vector<It>> loc(THREADS);
        par(cur.size(), 1, [&](size_t lo, size_t hi, int t) { for (size_t i = lo; i < hi; i++) for (int a = 0; a < 8; a++) if (letters >> a & 1) { It y; y.b = pre(cur[i].b, a); if (y.b.empty()) continue; y.k = pre(cur[i].k, a); if (y.k.empty()) continue; y.w = cur[i].w; y.w.insert(y.w.begin(), a); loc[t].push_back(move(y)); } });
        vector<It> nx; for (auto &l : loc) for (auto &x : l) nx.push_back(move(x));
        size_t t13 = 0, t14 = 0, t9 = 0, oth = 0; vector<string> os;
        for (auto &x : nx) { auto &w = x.w; size_t m = w.size(); bool e = m >= 5 && w[m-1]==0 && w[m-2]==1 && w[m-3]==3 && w[m-4]==3;
            bool run = true; for (size_t i = 1; i < m; i++) if (w[i]) run = false;
            if (e && w[m-5]==4) t13++; else if (e && w[m-5]==5) t14++; else if (run) t9++; else { oth++; string q; for (int a : w) q += to_string(9+a) + " "; os.push_back(q); } }
        printf("  length %d: unfixed %zu = 13-branch %zu, 14-branch %zu, (x)9..9 %zu, other %zu", d, nx.size(), t13, t14, t9, oth);
        if (oth && oth <= 5) { printf("  :"); for (auto &q : os) printf(" [%s]", q.c_str()); }
        printf("\n"); fflush(stdout);
        cur.swap(nx); if (cur.empty() || cur.size() > cap) break;
    }
}
