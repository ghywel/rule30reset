// claudeCloud_m9_exterior.cpp: pull M9, third block (ledger K51). The gate OUTSIDE the kit's gate trap, at wider
// windows: do the two exterior components that still allow an aperiodic gate at 24 columns (R65: least codes 519
// and 1,799) survive when more columns are seen?
//
// Frame (kit Rule30GateTrap, Rule30SidewaysLocks.dstep; gptM5's R65 and research/k50_1/gptM5_windows.cpp, whose
// conventions are followed so that its table can be reproduced). A right half is driven by the alternating centre.
// A WINDOW is columns 1..W at an odd tick, bit i = column i + 1. One edge is two physical ticks, for each of the four
// choices of the two exterior cells W+1, W+2 of the INITIAL row (the value of column W+1 at the second tick is then
// fixed by the rule). The GATE label of a window is its column 1 (bit 0): black = a kick.
//
// The trap (829 windows of 16 columns) is closed, so a window outside it has only ancestors outside it. This program
// keeps the windows OUTSIDE the trap:
//   one-sided set   windows with arbitrarily long histories (the eventual image, outside the trap);
//   two-sided set   those that also have an infinite future outside the trap. A right half that never enters the
//                   trap has its late windows here.
// The set at W + 1 lies inside the set at W extended by one column (project a path), so each width is computed from
// the last: extend, then peel (remove windows with no predecessor; in the two-sided set also those with no successor).
//
// Strongly connected components (Tarjan). For a cyclic component: its period (gcd of cycle lengths); its classes
// modulo the period; if every class has one gate label the component FORCES the periodic gate word printed; if some
// class has both labels the gate is VARIABLE (aperiodic paths exist in the graph). A SINK has no edge leaving it.
// From width ABSORB on, a sink that forces a periodic gate is ABSORBED: its windows, and every wider window that
// projects onto them, are certified periodic and leave the computation, as the trap's do.
//
//   g++ -O3 -std=c++17 claudeCloud_m9_exterior.cpp -o exterior
//   exterior KITFILE two  WMAX ABSORB [MAXNODES]     the two-sided ladder from 16 to WMAX
//   exterior KITFILE one  WMAX WORDS...              the one-sided ladder; at each width, which kick-gap words
//                                                    (digits, e.g. 5225) are read
// KITFILE is the kit's Rule30Certificates/GateTrap.lean.
#include <bits/stdc++.h>
using namespace std;
typedef uint64_t u64;
typedef uint32_t u32;
static const u32 NONE = 0xFFFFFFFFu;
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

static inline u64 stepw(u64 x, u64 wall, u64 outside, unsigned W) {
    return (((x << 1) | wall) ^ (x | (x >> 1) | (outside << (W - 1)))) & ((1ULL << W) - 1);
}
// input: bit 1 = cell W+1, bit 0 = cell W+2, both at the initial odd tick
static inline u64 nextw(u64 x, unsigned input, unsigned W) {
    u64 first = input >> 1, second = input & 1;
    u64 s2 = ((x >> (W - 1)) & 1) ^ (first | second);
    return stepw(stepw(x, 0, first, W), 1, s2, W);
}
// the same double step cell by cell, as a control
static u64 scalarNext(u64 x, unsigned input, unsigned W) {
    vector<int> r(W + 4, 0);                        // r[j] = column j, j = 0..W+2
    r[0] = 0; for (unsigned j = 1; j <= W; ++j) r[j] = (x >> (j - 1)) & 1;
    r[W + 1] = input >> 1; r[W + 2] = input & 1;
    vector<int> s(W + 3, 0); s[0] = 1;
    for (unsigned j = 1; j <= W + 1; ++j) s[j] = r[j - 1] ^ (r[j] | r[j + 1]);
    u64 out = 0;
    for (unsigned j = 1; j <= W; ++j) out |= u64(s[j - 1] ^ (s[j] | s[j + 1])) << (j - 1);
    return out;
}

struct Absorbed { unsigned W; vector<u64> codes; string word; };
static vector<Absorbed> absorbed;
static bool isAbsorbed(u64 x) {
    for (auto &a : absorbed) if (binary_search(a.codes.begin(), a.codes.end(), x & ((1ULL << a.W) - 1))) return true;
    return false;
}

struct Level {
    unsigned W; vector<u64> codes; vector<u32> succ;      // succ[4 i + k]
    u32 n() const { return (u32)codes.size(); }
    void build() {
        succ.assign(4ull * codes.size(), NONE);
        for (u64 i = 0; i < codes.size(); ++i) for (unsigned k = 0; k < 4; ++k) {
            u64 y = nextw(codes[i], k, W);
            auto it = lower_bound(codes.begin(), codes.end(), y);
            if (it != codes.end() && *it == y) succ[4 * i + k] = u32(it - codes.begin());
        }
    }
    // remove windows with no predecessor (and, two-sided, with no successor), repeatedly
    void peel(bool twoSided) {
        for (;;) {
            build();
            u32 N = n(); vector<u32> indeg(N, 0), outdeg(N, 0);
            for (u64 e = 0; e < succ.size(); ++e) if (succ[e] != NONE) { ++indeg[succ[e]]; ++outdeg[e / 4]; }
            vector<u32> rstart(N + 1, 0);
            for (u64 e = 0; e < succ.size(); ++e) if (succ[e] != NONE) ++rstart[succ[e] + 1];
            for (u32 i = 0; i < N; ++i) rstart[i + 1] += rstart[i];
            vector<u32> redge(rstart[N]), fill(rstart.begin(), rstart.end() - 1);
            for (u64 e = 0; e < succ.size(); ++e) if (succ[e] != NONE) redge[fill[succ[e]]++] = u32(e / 4);
            vector<char> dead(N, 0); vector<u32> stack;
            for (u32 i = 0; i < N; ++i) if (!indeg[i] || (twoSided && !outdeg[i])) { dead[i] = 1; stack.push_back(i); }
            if (stack.empty()) return;
            while (!stack.empty()) {
                u32 v = stack.back(); stack.pop_back();
                for (unsigned k = 0; k < 4; ++k) { u32 t = succ[4ull * v + k];
                    if (t != NONE && !dead[t] && --indeg[t] == 0) { dead[t] = 1; stack.push_back(t); } }
                if (twoSided) for (u32 j = rstart[v]; j < rstart[v + 1]; ++j) { u32 u = redge[j];
                    if (!dead[u] && --outdeg[u] == 0) { dead[u] = 1; stack.push_back(u); } }
            }
            vector<u64> keep; keep.reserve(N);
            for (u32 i = 0; i < N; ++i) if (!dead[i]) keep.push_back(codes[i]);
            codes.swap(keep);
        }
    }
};

struct Scc { u64 least; u32 size, period; bool variable, sink; string word; u64 toTrap, toAbsorbed, toOther; vector<u32> members; };

static string primitive(const string &s) {
    for (size_t p = 1; p <= s.size(); ++p) if (s.size() % p == 0) {
        bool ok = true; for (size_t i = p; i < s.size() && ok; ++i) ok = s[i] == s[i - p];
        if (ok) return s.substr(0, p);
    }
    return s;
}
static string leastRotation(string s) { string best = s; for (size_t i = 1; i < s.size(); ++i) { rotate(s.begin(), s.begin() + 1, s.end()); best = min(best, s); } return best; }

// iterative Tarjan; returns the cyclic components
static vector<Scc> components(const Level &L) {
    u32 N = L.n(); vector<u32> idx(N, NONE), low(N, 0), comp(N, NONE), stk; vector<char> on(N, 0);
    vector<pair<u32, unsigned>> call; u32 counter = 0, ncomp = 0; vector<vector<u32>> groups;
    for (u32 r = 0; r < N; ++r) if (idx[r] == NONE) {
        call.push_back({r, 0}); idx[r] = low[r] = counter++; stk.push_back(r); on[r] = 1;
        while (!call.empty()) {
            u32 v = call.back().first; unsigned &k = call.back().second;
            if (k < 4) { u32 t = L.succ[4ull * v + k]; ++k;
                if (t == NONE) continue;
                if (idx[t] == NONE) { idx[t] = low[t] = counter++; stk.push_back(t); on[t] = 1; call.push_back({t, 0}); }
                else if (on[t]) low[v] = min(low[v], idx[t]);
            } else {
                if (low[v] == idx[v]) { vector<u32> g; u32 w;
                    do { w = stk.back(); stk.pop_back(); on[w] = 0; comp[w] = ncomp; g.push_back(w); } while (w != v);
                    groups.push_back(move(g)); ++ncomp; }
                call.pop_back();
                if (!call.empty()) { u32 p = call.back().first; low[p] = min(low[p], low[v]); }
            }
        }
    }
    vector<Scc> out; vector<u32> depth(N, NONE);
    for (auto &g : groups) {
        bool cyclic = g.size() > 1;
        if (!cyclic) for (unsigned k = 0; k < 4; ++k) if (L.succ[4ull * g[0] + k] == g[0]) cyclic = true;
        if (!cyclic) continue;
        Scc s; s.size = (u32)g.size(); s.period = 0; s.toTrap = s.toAbsorbed = s.toOther = 0; s.sink = true;
        u32 c = comp[g[0]]; vector<u32> q{g[0]}; depth[g[0]] = 0;
        for (size_t h = 0; h < q.size(); ++h) { u32 v = q[h];
            for (unsigned k = 0; k < 4; ++k) { u32 t = L.succ[4ull * v + k];
                if (t != NONE && comp[t] == c) {
                    if (depth[t] == NONE) { depth[t] = depth[v] + 1; q.push_back(t); }
                    else { long d = (long)depth[v] + 1 - (long)depth[t]; s.period = (u32)std::gcd<long,long>(s.period, d < 0 ? -d : d); }
                } else { s.sink = false; u64 y = nextw(L.codes[v], k, L.W);
                    if (trapTab[y & 0xFFFF]) ++s.toTrap; else if (isAbsorbed(y)) ++s.toAbsorbed; else ++s.toOther; }
            } }
        require(q.size() == g.size() && s.period > 0, "bad cyclic component");
        string lab(s.period, '?'); s.variable = false; s.least = ~0ULL;
        for (u32 v : g) { u32 ph = depth[v] % s.period; char l = char('0' + (L.codes[v] & 1));
            if (lab[ph] == '?') lab[ph] = l; else if (lab[ph] != l) s.variable = true;
            s.least = min(s.least, L.codes[v]); }
        s.word = s.variable ? "variable" : leastRotation(primitive(lab));
        s.members = g; sort(s.members.begin(), s.members.end());
        out.push_back(move(s));
    }
    sort(out.begin(), out.end(), [](const Scc &a, const Scc &b) { return a.least < b.least; });
    return out;
}

// is the kick-gap word (e.g. "5225") read along some path of the level?
static bool reads(const Level &L, const string &word) {
    string lab = "1"; for (char g : word) { lab += string(g - '0' - 1, '0'); lab += '1'; }
    u32 N = L.n(); vector<char> cur(N, 0), nxt(N, 0); bool any = false;
    for (u32 i = 0; i < N; ++i) if (L.codes[i] & 1) { cur[i] = 1; any = true; }
    for (size_t j = 1; j < lab.size() && any; ++j) { fill(nxt.begin(), nxt.end(), 0); any = false; u64 want = lab[j] - '0';
        for (u32 i = 0; i < N; ++i) if (cur[i]) for (unsigned k = 0; k < 4; ++k) { u32 t = L.succ[4ull * i + k];
            if (t != NONE && (L.codes[t] & 1) == want) { nxt[t] = 1; any = true; } }
        cur.swap(nxt); }
    return any;
}

int main(int argc, char **argv) {
    require(argc >= 4, "usage: KITFILE two WMAX ABSORB [MAXNODES] | KITFILE one WMAX WORDS...");
    readTrap(argv[1]); string mode = argv[2]; unsigned WMAX = atoi(argv[3]);
    bool two = mode == "two"; unsigned ABSORB = two && argc > 4 ? atoi(argv[4]) : 99;
    u64 MAXN = two && argc > 5 ? strtoull(argv[5], 0, 10) : 300000000ULL;
    { mt19937_64 rng(30); for (int i = 0; i < 200000; ++i) { unsigned W = 16 + rng() % 30; u64 x = rng() & ((1ULL << W) - 1); unsigned k = rng() % 4;
          require(nextw(x, k, W) == scalarNext(x, k, W), "the packed double step differs from the cell-by-cell one"); } }
    Level L; L.W = 16;
    for (u64 x = 0; x < 65536; ++x) if (!trapTab[x]) L.codes.push_back(x);
    map<u64, u64> tag24;                               // 24-column window on a cycle -> least code of its component
    for (;;) {
        auto t0 = chrono::steady_clock::now(); u64 cand = L.codes.size();
        L.peel(two);
        vector<Scc> cs = components(L);
        u64 onCycles = 0; for (auto &s : cs) onCycles += s.size;
        printf("W=%u candidates=%llu kept=%u on_cycles=%llu cyclic_components=%zu absorbed_sets=%zu\n", L.W,
               (unsigned long long)cand, L.n(), (unsigned long long)onCycles, cs.size(), absorbed.size());
        vector<char> drop(L.n(), 0); bool dropped = false;
        for (auto &s : cs) {
            string tags;
            if (L.W == 24) for (u32 v : s.members) tag24[L.codes[v]] = s.least;
            if (L.W > 24) { set<u64> ts; u64 none = 0; for (u32 v : s.members) { auto it = tag24.find(L.codes[v] & 0xFFFFFF);
                    if (it == tag24.end()) ++none; else ts.insert(it->second); }
                for (u64 t : ts) tags += " " + to_string(t); if (none) tags += " (+" + to_string(none) + " off the 24-column cycles)"; }
            bool absorb = two && L.W >= ABSORB && s.sink && !s.variable;
            printf("  component least=%llu size=%u period=%u gate=%s sink=%d exits: trap=%llu absorbed=%llu other=%llu%s%s%s\n",
                   (unsigned long long)s.least, s.size, s.period, s.word.c_str(), int(s.sink), (unsigned long long)s.toTrap,
                   (unsigned long long)s.toAbsorbed, (unsigned long long)s.toOther, tags.empty() ? "" : " from24:", tags.c_str(),
                   absorb ? " ABSORBED" : "");
            if (absorb) { Absorbed a; a.W = L.W; a.word = s.word; for (u32 v : s.members) { a.codes.push_back(L.codes[v]); drop[v] = 1; }
                sort(a.codes.begin(), a.codes.end()); absorbed.push_back(move(a)); dropped = true; }
        }
        if (!two) for (int a = 4; a < argc; ++a) printf("  kick gaps %s: %s\n", argv[a], reads(L, argv[a]) ? "read" : "NOT READ");
        printf("  seconds=%.0f\n", chrono::duration<double>(chrono::steady_clock::now() - t0).count());
        fflush(stdout);
        if (L.W >= WMAX) break;
        vector<u64> next; next.reserve(2 * L.codes.size());
        for (int top = 0; top < 2; ++top) for (u32 i = 0; i < L.n(); ++i) if (!drop[i]) {
            u64 y = L.codes[i] | (u64(top) << L.W); if (!dropped || !isAbsorbed(y)) next.push_back(y); }
        if (next.size() > MAXN) { printf("STOPPED: %zu candidates at the next width exceed the cap\n", next.size()); break; }
        L.codes.swap(next); L.W += 1; L.succ.clear();
        if (!absorbed.empty()) { vector<u64> f; f.reserve(L.codes.size()); for (u64 y : L.codes) if (!isAbsorbed(y)) f.push_back(y); L.codes.swap(f); }
    }
    return 0;
}
