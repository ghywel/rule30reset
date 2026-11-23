// claudeCloud_exterior_cores.cpp: the window graph outside the gate trap, widened one column at a time, keeping
// only the components whose gate can vary (ledger K78).
//
// A right half is driven by the alternating column 0. A WINDOW is columns 1..W at a sample (a tick at which column
// 0 is white), bit i = column i + 1. A double step takes a window to step(step(w, 0, x1), 1, x2), where x1 and x2
// are the two values of column W + 1, which the window does not fix: four successors. The EXTERIOR is every window
// whose first sixteen columns are not one of the kit's 829 trap windows. Every right half that stays outside the
// trap for ever gives an endless path in this graph, and an endless path ends inside one strongly connected
// component. The GATE is bit 0.
//
// A component is FIXED when every endless path inside it reads the same periodic gate (up to its starting point),
// and VARIABLE otherwise. Test: levels by breadth-first search inside the component; g = the gcd of
// level(u) + 1 - level(v) over its edges; the component is fixed exactly when the gate is constant on each class of
// levels modulo g.
//
// Widening. A cycle at W + 1 columns projects to a closed walk at W columns, so a component at W + 1 projects into
// one component at W, and if that one is fixed so is the wider one. Hence the variable components at W + 1 lie
// among the two extensions of the windows of the variable components at W. The program starts from every exterior
// window at 16 columns and repeats: successors among the candidates, components, the test, keep the variable ones.
//
// R65 (gptM5) has the two variable components at 24 columns, X (its least window is 519) and Y (1799). From 24
// columns on each variable component is named by the 24-column component its windows project to.
//
//   g++ -O3 -march=native -std=c++17 claudeCloud_exterior_cores.cpp -o exterior_cores
//   exterior_cores KITFILE WMAX [X|Y|XY]      follow both, or from 24 columns on only X or only Y
// One line per width: the number of windows tried, the cyclic components and how many are fixed, and for each
// variable component its name, its windows, its kick windows (gate black) and its period g.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <numeric>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
using namespace std;
typedef uint64_t u64;

static vector<char> trapTab(1 << 16, 0);
static void require(bool ok, const char *why) { if (!ok) { fprintf(stderr, "FAILED: %s\n", why); exit(1); } }
static void readTrap(const char *path) {
    ifstream in(path); require(bool(in), "cannot open the kit file");
    string text((istreambuf_iterator<char>(in)), istreambuf_iterator<char>());
    size_t a = text.find("def trapCodes : List Nat := ["); require(a != string::npos, "trapCodes not found");
    a = text.find('[', a); size_t b = text.find(']', a);
    string body = text.substr(a + 1, b - a - 1);
    for (char &c : body) if (c == ',') c = ' ';
    istringstream nums(body); u64 v, n = 0;
    while (nums >> v) { require(v < 65536 && !trapTab[v], "bad trap code"); trapTab[v] = 1; ++n; }
    require(n == 829 && trapTab[49415], "the kit trap is not the expected one");
}

static inline u64 step(u64 w, u64 c0, u64 x, int W) {
    u64 r = (w << 1) | c0 | (x << (W + 1));
    return (r ^ ((r >> 1) | (r >> 2))) & ((W == 64) ? ~0ULL : ((1ULL << W) - 1));
}
static inline u64 step2(u64 w, u64 x1, u64 x2, int W) { return step(step(w, 0, x1, W), 1, x2, W); }

int main(int argc, char **argv) {
    require(argc >= 3, "usage: exterior_cores KITFILE WMAX [X|Y|XY]");
    readTrap(argv[1]);
    int WMAX = atoi(argv[2]);
    string only = argc > 3 ? argv[3] : "XY";
    require(WMAX >= 16 && WMAX <= 62, "WMAX must be 16..62");
    vector<u64> nodes;
    for (u64 w = 0; w < 65536; ++w) if (!trapTab[w]) nodes.push_back(w);
    unordered_map<uint32_t, char> name24;            // 24-column window -> 'X' or 'Y'
    for (int W = 16; W <= WMAX; ++W) {
        size_t n = nodes.size();
        if (n == 0) { printf("W %d: no window left: every component is fixed from here on\n", W); break; }
        require(n < 2000000000ULL, "too many windows for 32-bit indices");
        // successors among the candidates
        vector<int32_t> succ(4 * n, -1);
        for (size_t i = 0; i < n; ++i) for (int e = 0; e < 4; ++e) {
            u64 v = step2(nodes[i], e & 1, e >> 1, W);
            if (trapTab[v & 0xFFFF]) continue;
            auto it = lower_bound(nodes.begin(), nodes.end(), v);
            if (it != nodes.end() && *it == v) succ[4 * i + e] = int32_t(it - nodes.begin());
        }
        // strongly connected components (Tarjan, iterative)
        vector<int32_t> index(n, -1), low(n, 0), comp(n, -1);
        vector<char> onstack(n, 0);
        vector<int32_t> stack; vector<pair<int32_t, int>> work;
        int32_t counter = 0, ncomp = 0;
        for (size_t root = 0; root < n; ++root) {
            if (index[root] != -1) continue;
            index[root] = low[root] = counter++; stack.push_back(int32_t(root)); onstack[root] = 1;
            work.push_back({int32_t(root), 0});
            while (!work.empty()) {
                int32_t v = work.back().first; int &e = work.back().second;
                if (e < 4) {
                    int32_t w = succ[4 * size_t(v) + e]; ++e;
                    if (w < 0) continue;
                    if (index[w] == -1) {
                        index[w] = low[w] = counter++; stack.push_back(w); onstack[w] = 1; work.push_back({w, 0});
                    } else if (onstack[w]) { if (index[w] < low[v]) low[v] = index[w]; }
                } else {
                    work.pop_back();
                    if (!work.empty()) { int32_t u = work.back().first; if (low[v] < low[u]) low[u] = low[v]; }
                    if (low[v] == index[v]) {
                        while (true) { int32_t w = stack.back(); stack.pop_back(); onstack[w] = 0; comp[w] = ncomp; if (w == v) break; }
                        ++ncomp;
                    }
                }
            }
        }
        // sizes, and which components have an edge inside them
        vector<int32_t> size(ncomp, 0); vector<char> cyclic(ncomp, 0);
        for (size_t i = 0; i < n; ++i) {
            ++size[comp[i]];
            for (int e = 0; e < 4; ++e) { int32_t w = succ[4 * i + e]; if (w >= 0 && comp[w] == comp[i]) cyclic[comp[i]] = 1; }
        }
        // levels by breadth-first search inside each cyclic component
        vector<int32_t> level(n, -1), queue; queue.reserve(n);
        vector<int32_t> firstOf(ncomp, -1);
        for (size_t i = 0; i < n; ++i) if (cyclic[comp[i]] && firstOf[comp[i]] < 0) firstOf[comp[i]] = int32_t(i);
        for (int32_t c = 0; c < ncomp; ++c) {
            if (!cyclic[c]) continue;
            size_t head = queue.size();
            level[firstOf[c]] = 0; queue.push_back(firstOf[c]);
            while (head < queue.size()) {
                int32_t v = queue[head++];
                for (int e = 0; e < 4; ++e) {
                    int32_t w = succ[4 * size_t(v) + e];
                    if (w >= 0 && comp[w] == c && level[w] < 0) { level[w] = level[v] + 1; queue.push_back(w); }
                }
            }
        }
        vector<int64_t> g(ncomp, 0);
        for (size_t i = 0; i < n; ++i) {
            int32_t c = comp[i]; if (!cyclic[c]) continue;
            for (int e = 0; e < 4; ++e) {
                int32_t w = succ[4 * i + e];
                if (w >= 0 && comp[w] == c) { int64_t d = int64_t(level[i]) + 1 - level[w]; if (d < 0) d = -d; g[c] = std::gcd(g[c], d); }
            }
        }
        // fixed or variable
        vector<char> variable(ncomp, 0);
        vector<size_t> offset(ncomp + 1, 0);
        for (int32_t c = 0; c < ncomp; ++c) offset[c + 1] = offset[c] + (cyclic[c] ? size_t(g[c]) : 0);
        vector<signed char> bitOf(offset[ncomp], -1);
        for (size_t i = 0; i < n; ++i) {
            int32_t c = comp[i]; if (!cyclic[c]) continue;
            require(g[c] > 0, "a cyclic component with gcd zero");
            size_t slot = offset[c] + size_t(level[i] % g[c]);
            signed char b = nodes[i] & 1;
            if (bitOf[slot] < 0) bitOf[slot] = b; else if (bitOf[slot] != b) variable[c] = 1;
        }
        long nCyclic = 0, nFixed = 0; size_t fixedWindows = 0;
        for (int32_t c = 0; c < ncomp; ++c) if (cyclic[c]) { ++nCyclic; if (!variable[c]) { ++nFixed; fixedWindows += size[c]; } }
        // names: at 24 columns by the least window (519 is in X, 1799 in Y); wider, by projection to 24 columns
        vector<char> nameOf(ncomp, '?');
        if (W == 24) {
            for (size_t i = 0; i < n; ++i) if (variable[comp[i]]) {
                if (nodes[i] == 519) nameOf[comp[i]] = 'X';
                if (nodes[i] == 1799) nameOf[comp[i]] = 'Y';
            }
            for (size_t i = 0; i < n; ++i) if (variable[comp[i]]) name24[uint32_t(nodes[i])] = nameOf[comp[i]];
        } else if (W > 24) {
            for (size_t i = 0; i < n; ++i) if (variable[comp[i]] && nameOf[comp[i]] == '?') {
                auto it = name24.find(uint32_t(nodes[i] & 0xFFFFFF));
                if (it != name24.end()) nameOf[comp[i]] = it->second;
            }
        }
        vector<long> kicks(ncomp, 0);
        for (size_t i = 0; i < n; ++i) if (variable[comp[i]] && (nodes[i] & 1)) ++kicks[comp[i]];
        printf("W %d: tried %zu windows; cyclic components %ld, fixed %ld (%zu windows); variable:", W, n, nCyclic, nFixed, fixedWindows);
        vector<int32_t> vars;
        for (int32_t c = 0; c < ncomp; ++c) if (variable[c]) vars.push_back(c);
        sort(vars.begin(), vars.end(), [&](int32_t a, int32_t b) { return size[a] > size[b]; });
        if (vars.empty()) printf(" none");
        for (int32_t c : vars) printf(" [%c %d windows, %ld kicks, g %lld]", nameOf[c], size[c], kicks[c], (long long)g[c]);
        printf("\n"); fflush(stdout);
        // next width: both extensions of the windows of the variable components that are followed
        vector<u64> next;
        for (size_t i = 0; i < n; ++i) {
            int32_t c = comp[i]; if (!variable[c]) continue;
            if (W >= 24 && only != "XY" && nameOf[c] != only[0]) continue;
            next.push_back(nodes[i]); next.push_back(nodes[i] | (1ULL << W));
        }
        sort(next.begin(), next.end());
        nodes.swap(next);
    }
    return 0;
}
