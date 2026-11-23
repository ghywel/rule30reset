// claudeM5_five_budget.cpp (ledger M144): an independent count behind I175's singleton deadline.
//
// A window is columns 1..W at a white tick of the alternating column, bit i = column i + 1. A pulse is a window with
// column 1 black whose first sixteen columns are not one of the kit's 829 trap codes. An edge of gap g (3 or 5) joins two
// pulses g samples apart, white in between, every window outside, for some choice of the cell beyond the strip at each of
// the 2 g ticks.
//
// Every run of 3- and 5-gaps that ends outside the trap projects to a path in this graph at every width (the trap is
// closed). One trim keeps the pulses that lie at or after the arrival of a 5 (3s only since) and from which a 5 can be
// reached by 3s; it costs a path its first and its last 5 and the 3s outside them.
//
//   claudeM5_five_budget TRAPCODES WMAX TRIMMASK [PASSES]
//
// TRAPCODES: a file with the 829 codes. TRIMMASK: a string of 0/1 for the widths 16, 17, ..., WMAX, 1 = trim there.
// At WMAX it takes the product with the automaton of the gap word's suffixes that are prefixes of (33355)^7 or (333355)^9
// (an edge completing either is dropped) and prints the largest number of 5s on a path, and, with 3^8 also dropped, the
// longest duration in samples. Both are exact on the product graph (strongly connected components, then longest path);
// a component with a positive cost inside means no bound.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace std;
typedef uint64_t u64;

static vector<char> inside(1 << 16, 0);

// one tick of columns 1..W with column 0 = wall and column W + 1 = e
static inline u64 tick(u64 w, int wall, int e, int W) {
    u64 mask = (W == 64) ? ~0ULL : ((1ULL << W) - 1);
    u64 left = (w << 1) | (u64)wall;              // column j - 1
    u64 right = (w >> 1) | ((u64)e << (W - 1));   // column j + 1
    return (left ^ (w | right)) & mask;
}

struct Edges { vector<pair<int, int>> e[2]; };  // e[0]: gap 3, e[1]: gap 5

static void successors(u64 w, int W, vector<u64>& three, vector<u64>& five) {
    three.clear(); five.clear();
    vector<u64> cur(1, w), nxt;
    for (int s = 1; s <= 5; s++) {
        nxt.clear();
        for (u64 x : cur)
            for (int a = 0; a < 2; a++) {
                u64 y = tick(x, 0, a, W);   // at a sample column 0 is white
                for (int b = 0; b < 2; b++) {
                    u64 z = tick(y, 1, b, W);
                    if (!inside[z & 0xFFFF]) nxt.push_back(z);
                }
            }
        sort(nxt.begin(), nxt.end());
        nxt.erase(unique(nxt.begin(), nxt.end()), nxt.end());
        cur.clear();
        for (u64 z : nxt) {
            if (z & 1) { if (s == 3) three.push_back(z); else if (s == 5) five.push_back(z); }
            else cur.push_back(z);
        }
    }
}

static Edges build(const vector<u64>& nodes, int W) {
    Edges E;
    vector<u64> t, f;
    for (size_t i = 0; i < nodes.size(); i++) {
        successors(nodes[i], W, t, f);
        for (int k = 0; k < 2; k++)
            for (u64 z : (k ? f : t)) {
                auto it = lower_bound(nodes.begin(), nodes.end(), z);
                if (it != nodes.end() && *it == z) E.e[k].push_back({(int)i, (int)(it - nodes.begin())});
            }
    }
    return E;
}

// nodes at or after the arrival of a 5 with only 3s since (rev = true: the mirror)
static vector<char> sweep(size_t n, const Edges& E, bool rev) {
    vector<vector<int>> adj(n);
    vector<char> in(n, 0);
    vector<int> stack;
    for (auto& p : E.e[0]) rev ? adj[p.second].push_back(p.first) : adj[p.first].push_back(p.second);
    for (auto& p : E.e[1]) { int v = rev ? p.first : p.second; if (!in[v]) { in[v] = 1; stack.push_back(v); } }
    while (!stack.empty()) {
        int v = stack.back(); stack.pop_back();
        for (int y : adj[v]) if (!in[y]) { in[y] = 1; stack.push_back(y); }
    }
    return in;
}

// automaton of suffixes: states are prefixes of the forbidden words
struct Auto { vector<string> st; vector<int> to[2]; };
static Auto machine(const vector<string>& cuts) {
    set<string> ps;
    for (auto& c : cuts) for (size_t i = 0; i < c.size(); i++) ps.insert(c.substr(0, i));
    Auto A; A.st.assign(ps.begin(), ps.end());
    sort(A.st.begin(), A.st.end(), [](const string& a, const string& b) { return a.size() != b.size() ? a.size() < b.size() : a < b; });
    auto id = [&](const string& s) { for (size_t i = 0; i < A.st.size(); i++) if (A.st[i] == s) return (int)i; return -1; };
    for (int k = 0; k < 2; k++) A.to[k].resize(A.st.size());
    for (size_t i = 0; i < A.st.size(); i++)
        for (int k = 0; k < 2; k++) {
            string w = A.st[i] + (k ? "5" : "3");
            bool bad = false;
            for (auto& c : cuts) if (w.size() >= c.size() && w.compare(w.size() - c.size(), c.size(), c) == 0) bad = true;
            if (bad) { A.to[k][i] = -1; continue; }
            for (size_t j = 0; j <= w.size(); j++) { int q = id(w.substr(j)); if (q >= 0) { A.to[k][i] = q; break; } }
        }
    return A;
}

// longest path of the product, all nodes as starts with empty memory; cost of an edge: 1 for a 5 (or its duration)
static long longest(size_t n, const Edges& E, const vector<string>& cuts, bool duration, size_t& verts, size_t& comps) {
    Auto A = machine(cuts);
    size_t Q = A.st.size();
    vector<vector<pair<int, int>>> adj(n);
    for (int k = 0; k < 2; k++) for (auto& p : E.e[k]) adj[p.first].push_back({p.second, k});
    vector<int> id(n * Q, -1);
    vector<pair<int, int>> S;
    for (size_t i = 0; i < n; i++) { id[i * Q] = (int)S.size(); S.push_back({(int)i, 0}); }
    vector<vector<pair<int, int>>> g;
    for (size_t x = 0; x < S.size(); x++) {
        g.push_back({});
        int i = S[x].first, q = S[x].second;
        for (auto& p : adj[i]) {
            int q2 = A.to[p.second][q];
            if (q2 < 0) continue;
            size_t key = (size_t)p.first * Q + q2;
            if (id[key] < 0) { id[key] = (int)S.size(); S.push_back({p.first, q2}); }
            g[x].push_back({id[key], p.second});
        }
    }
    size_t N = S.size(); verts = N;
    // Tarjan, iterative; components come out in reverse topological order
    vector<int> low(N, 0), num(N, 0), comp(N, -1), st, it(N, 0);
    int cnt = 0, nc = 0;
    for (size_t r = 0; r < N; r++) {
        if (num[r]) continue;
        vector<int> call(1, (int)r);
        while (!call.empty()) {
            int v = call.back();
            if (!num[v]) { num[v] = low[v] = ++cnt; st.push_back(v); }
            bool down = false;
            while (it[v] < (int)g[v].size()) {
                int w = g[v][it[v]].first;
                if (!num[w]) { call.push_back(w); down = true; break; }
                if (comp[w] < 0) low[v] = min(low[v], num[w]);
                it[v]++;
            }
            if (down) continue;
            if (low[v] == num[v]) { int w; do { w = st.back(); st.pop_back(); comp[w] = nc; } while (w != v); nc++; }
            call.pop_back();
            if (!call.empty()) { int u = call.back(); low[u] = min(low[u], low[v]); }
        }
    }
    comps = nc;
    vector<vector<int>> members(nc);
    for (size_t v = 0; v < N; v++) members[comp[v]].push_back((int)v);
    vector<long> best(nc, 0);   // the longest cost of a path starting in the component
    long ans = 0;
    for (int c = 0; c < nc; c++) {        // successors have smaller index
        for (int v : members[c])
            for (auto& p : g[v]) {
                long w = duration ? (p.second ? 5 : 3) : (p.second ? 1 : 0);
                int d = comp[p.first];
                if (d == c) { if (w) return -1; }
                else best[c] = max(best[c], best[d] + w);
            }
        ans = max(ans, best[c]);
    }
    return ans;
}

int main(int argc, char** argv) {
    ifstream in(argv[1]);
    int c, ncodes = 0;
    while (in >> c) { inside[c] = 1; ncodes++; }
    int WM = atoi(argv[2]);
    string mask = argv[3];
    vector<u64> nodes;
    for (u64 w = 1; w < (1 << 16); w += 2) if (!inside[w]) nodes.push_back(w);
    printf("trap codes %d, outside pulse windows of width 16: %zu\n", ncodes, nodes.size());
    int trims = 0;
    string r7, r9;
    for (int i = 0; i < 7; i++) r7 += "33355";
    for (int i = 0; i < 9; i++) r9 += "333355";
    for (int W = 16; W <= WM; W++) {
        if (W > 16) {
            vector<u64> up;
            for (int b = 0; b < 2; b++) for (u64 w : nodes) up.push_back(w + ((u64)b << (W - 1)));
            sort(up.begin(), up.end());
            nodes.swap(up);
        }
        bool doTrim = mask[W - 16] == '1';
        size_t before = nodes.size();
        if (W == WM) {
            Edges E = build(nodes, W);
            size_t v = 0, k = 0;
            long f = longest(nodes.size(), E, {r7, r9}, false, v, k);
            printf("W=%d nodes %zu edges %zu+%zu product %zu components %zu: most 5s on a path %ld; with %d trims the bound is %ld\n",
                   W, nodes.size(), E.e[0].size(), E.e[1].size(), v, k, f, trims, f < 0 ? -1 : f + 2 * trims);
            long d = longest(nodes.size(), E, {r7, r9, "33333333"}, true, v, k);
            printf("W=%d, no 3^8: product %zu components %zu: longest duration %ld samples; with %d trims the bound is %ld\n",
                   W, v, k, d, trims, d < 0 ? -1 : d + 52 * trims);
            break;
        }
        if (doTrim) {
            Edges E = build(nodes, W);
            vector<char> l = sweep(nodes.size(), E, false), r = sweep(nodes.size(), E, true);
            vector<u64> keep;
            for (size_t i = 0; i < nodes.size(); i++) if (l[i] && r[i]) keep.push_back(nodes[i]);
            nodes.swap(keep);
            trims++;
        }
        printf("W=%d: %zu%s", W, before, doTrim ? "" : "\n");
        if (doTrim) printf(" -> trimmed to %zu\n", nodes.size());
        fflush(stdout);
    }
    return 0;
}
