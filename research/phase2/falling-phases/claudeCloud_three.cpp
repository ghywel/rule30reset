// claudeCloud_three.cpp: the three-residue test of claudeCloud_grow.py, for wider strips (K95, addendum 3).
//
// Modulo 3, each of W cells is forbidden one residue for its falls.  A node is (tick mod 3, the W cells); an update
// with free bits at both ends is kept when no cell falls at its forbidden residue.  An assignment *escapes* when
// some strongly connected part has no two neighbouring cells whose colours are fixed by the position in the part's
// cycle.  An assignment can escape only if both of its restrictions to W - 1 neighbouring cells do, so the escaping
// assignments are grown one cell at a time.  Assignments are stored in every rotation of time.
//
//   g++ -O2 -std=c++17 -o three claudeCloud_three.cpp      ./three WMAX
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <numeric>
#include <string>
#include <vector>
#include <unordered_set>
#include <algorithm>
using namespace std;

static int W;
static uint32_t SIZE, MASK;
static uint32_t nofall[3];

static inline uint32_t stepRow(uint32_t s, int w, int e) {
    uint32_t L = ((s << 1) | (uint32_t)w) & MASK;
    uint32_t R = (s >> 1) | ((uint32_t)e << (W - 1));
    return (L ^ (s | R)) & MASK;
}

// successors of node v = t * SIZE + s; returns how many
static inline int successors(uint32_t v, uint32_t out[4]) {
    uint32_t t = v / SIZE, s = v % SIZE, nt = (t + 1) % 3;
    int n = 0;
    for (int b = 0; b < 4; b++) {
        uint32_t d = stepRow(s, b >> 1, b & 1);
        if (((s & ~d) & nofall[t]) == 0) out[n++] = nt * SIZE + d;
    }
    return n;
}

static bool escapes(const string &a) {
    nofall[0] = nofall[1] = nofall[2] = 0;
    for (int k = 0; k < W; k++) nofall[a[k] - '0'] |= 1u << k;
    uint32_t n = 3 * SIZE;
    static vector<int32_t> index, low, comp, level;
    static vector<uint8_t> ptr, onstack;
    index.assign(n, -1); low.assign(n, 0); comp.assign(n, -1); ptr.assign(n, 0); onstack.assign(n, 0);
    level.assign(n, -1);
    vector<uint32_t> stack, work, members, queue;
    int counter = 0, ncomp = 0;
    uint32_t out[4];
    for (uint32_t root = 0; root < n; root++) {
        if (index[root] != -1) continue;
        work.push_back(root);
        while (!work.empty()) {
            uint32_t v = work.back();
            if (index[v] == -1) { index[v] = low[v] = counter++; stack.push_back(v); onstack[v] = 1; }
            int cnt = successors(v, out);
            bool descended = false;
            while (ptr[v] < cnt) {
                uint32_t w = out[ptr[v]++];
                if (index[w] == -1) { work.push_back(w); descended = true; break; }
                if (onstack[w]) low[v] = min(low[v], index[w]);
            }
            if (descended) continue;
            work.pop_back();
            if (!work.empty()) { uint32_t u = work.back(); low[u] = min(low[u], low[v]); }
            if (low[v] == index[v]) {
                members.clear();
                while (true) {
                    uint32_t w = stack.back(); stack.pop_back(); onstack[w] = 0; comp[w] = ncomp; members.push_back(w);
                    if (w == v) break;
                }
                if (members.size() > 1) {
                    // the part's period, from breadth-first levels
                    long period = 0;
                    queue.clear(); queue.push_back(members[0]); level[members[0]] = 0;
                    for (size_t q = 0; q < queue.size(); q++) {
                        uint32_t x = queue[q];
                        int c2 = successors(x, out);
                        for (int j = 0; j < c2; j++) {
                            uint32_t y = out[j];
                            if (comp[y] != ncomp) continue;
                            if (level[y] == -1) { level[y] = level[x] + 1; queue.push_back(y); }
                            period = gcd(period, (long)level[x] + 1 - level[y]);
                        }
                    }
                    if (period < 0) period = -period;
                    vector<int64_t> first(period, -1);
                    uint32_t differ = 0;
                    for (uint32_t x : members) {
                        long c = level[x] % period;
                        uint32_t s = x % SIZE;
                        if (first[c] < 0) first[c] = s; else differ |= s ^ (uint32_t)first[c];
                    }
                    bool pair = false;
                    for (int k = 0; k + 1 < W; k++) if (((differ >> k) & 3) == 0) { pair = true; break; }
                    if (!pair) return true;
                }
                ncomp++;
            }
        }
    }
    return false;
}

static string rotate(const string &a, int d) {
    string b = a;
    for (auto &c : b) c = '0' + (c - '0' + d) % 3;
    return b;
}

int main(int argc, char **argv) {
    int wmax = atoi(argv[1]);
    unordered_set<string> esc;                 // every rotation
    vector<string> found;                      // west label 0
    printf("modulo 3, each cell forbidden one residue\nwidth | candidates tested | escaping (west label 0)\n");
    for (W = 2; W <= wmax; W++) {
        SIZE = 1u << W; MASK = SIZE - 1;
        vector<string> cands;
        if (W == 2) { for (char r = '0'; r < '3'; r++) cands.push_back(string("0") + r); }
        else for (const string &a : found) for (char r = '0'; r < '3'; r++) {
            string tail = a.substr(1) + r;
            if (esc.count(tail)) cands.push_back(a + r);
        }
        sort(cands.begin(), cands.end());
        vector<string> next;
        for (const string &a : cands) if (escapes(a)) next.push_back(a);
        found = next;
        esc.clear();
        for (const string &a : found) for (int d = 0; d < 3; d++) esc.insert(rotate(a, d));
        printf("%d | %zu | %zu\n", W, cands.size(), found.size());
        fflush(stdout);
        if (found.empty()) break;
    }
    return 0;
}
