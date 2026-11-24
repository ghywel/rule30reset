// after y 10 9^j (and y x 9^j, x != 9,10): is the sample fixed for EVERY j >= 2?  iterate the set under gap 9 until it repeats
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main
int main(int argc, char **argv) {
    string dir = argv[1]; int W = atoi(argv[2]);
    Graph full = load(dir + "/g" + to_string(W) + ".bin", W); u32 c; Graph g = keep(full, 255, true, c);
    size_t n = g.row.size();
    auto img = [&](const V &s, int a) { V o; for (u32 x : s) for (u32 e = g.off[a][x]; e < g.off[a][x+1]; e++) o.push_back(g.dst[a][e]); sort(o.begin(), o.end()); o.erase(unique(o.begin(), o.end()), o.end()); return o; };
    V all(n); for (size_t i = 0; i < n; i++) all[i] = i;
    auto col = [&](const V &s) { int m = 0; for (u32 x : s) m |= colour(g.row[x]) ? 2 : 1; return m; };
    bool ok = true;
    for (int x = 1; x < 8; x++) for (int y = -1; y < 8; y++) {
        if (x != 1 && y >= 0) continue;           // only x = 10 needs the gap before it
        if (x == 1 && y < 0) continue;
        V s = all; if (y >= 0) s = img(s, y); s = img(s, x);
        map<V, int> seen; string cs; int j = 0;
        for (;; j++) { s = img(s, 0); int k = col(s); cs += k == 0 ? '-' : k == 1 ? 'w' : k == 2 ? 'b' : '*'; if (s.empty() || seen.count(s) || j > 400) break; seen[s] = j; }
        printf("  %s %d 9^j: colours from j=1: %s%s (repeats after j=%d)\n", y >= 0 ? to_string(9 + y).c_str() : "any", 9 + x, cs.substr(0, 24).c_str(), cs.size() > 24 ? "..." : "", j);
        for (size_t i = 1; i < cs.size(); i++) if (cs[i] == '*') ok = false;
    }
    printf("W=%d: fixed for every j >= 2: %s\n", W, ok ? "yes" : "NO");
}
