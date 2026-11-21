// claudeCloud_m9_exterior_read.cpp: pull M9 (ledger K53). A reader's spot check of R69's table for X: which
// sequences of SPACINGS between excursions does the exterior core read at 40 to 43 columns?
// X is the loop A = 25 (kick gaps 2, 5) with the excursion E = 33535555. A spacing list n1,n2,...,nk stands for the
// kick-gap word E A^n1 E A^n2 E ... A^nk E. The two-sided ladder of claudeCloud_m9_exterior.cpp (included, frozen)
// is rebuilt to WMAX with absorption from 24 columns, and from WREAD on each word is pushed through the kept windows.
//   g++ -O3 -std=c++17 claudeCloud_m9_exterior_read.cpp -o exterior_read
//   exterior_read KITFILE WMAX WREAD LIST [LIST ...]        LIST like 4,4 or 4,11,4
#define main exterior_main
#include "claudeCloud_m9_exterior.cpp"
#undef main

static bool readsFast(const Level &L, const string &word, vector<u32> &stamp, u32 &tick) {
    string lab = "1"; for (char g : word) { lab += string(g - '0' - 1, '0'); lab += '1'; }
    vector<u32> cur, nxt; u32 N = L.n();
    for (u32 i = 0; i < N; ++i) if (L.codes[i] & 1) cur.push_back(i);
    for (size_t j = 1; j < lab.size() && !cur.empty(); ++j) { ++tick; nxt.clear(); u64 want = lab[j] - '0';
        for (u32 i : cur) for (unsigned k = 0; k < 4; ++k) { u32 t = L.succ[4ull * i + k];
            if (t != NONE && (L.codes[t] & 1) == want && stamp[t] != tick) { stamp[t] = tick; nxt.push_back(t); } }
        cur.swap(nxt); }
    return !cur.empty();
}

int main(int argc, char **argv) {
    require(argc >= 5, "usage: KITFILE WMAX WREAD LIST...");
    readTrap(argv[1]); unsigned WMAX = atoi(argv[2]), WREAD = atoi(argv[3]);
    const string A = "25", E = "33535555";
    vector<pair<string, string>> words;
    for (int a = 4; a < argc; ++a) { string w = E, s = argv[a]; stringstream ss(s); string tok;
        while (getline(ss, tok, ',')) { for (int i = 0; i < atoi(tok.c_str()); ++i) w += A; w += E; }
        words.push_back({s, w}); }
    Level L; L.W = 16;
    for (u64 x = 0; x < 65536; ++x) if (!trapTab[x]) L.codes.push_back(x);
    for (;;) {
        L.peel(true);
        vector<Scc> cs = components(L);
        vector<char> drop(L.n(), 0); bool dropped = false; u32 big = 0;
        for (auto &s : cs) { big = max(big, s.size);
            if (L.W >= 24 && s.sink && !s.variable) { Absorbed a; a.W = L.W; a.word = s.word;
                for (u32 v : s.members) { a.codes.push_back(L.codes[v]); drop[v] = 1; }
                sort(a.codes.begin(), a.codes.end()); absorbed.push_back(move(a)); dropped = true; } }
        printf("W=%u kept=%u largest_component=%u\n", L.W, L.n(), big); fflush(stdout);
        if (L.W >= WREAD) { vector<u32> stamp(L.n(), 0); u32 tick = 0;
            for (auto &w : words) printf("  W=%u spacings %s: %s\n", L.W, w.first.c_str(), readsFast(L, w.second, stamp, tick) ? "read" : "NOT READ");
            fflush(stdout); }
        if (L.W >= WMAX) break;
        vector<u64> next; next.reserve(2 * L.codes.size());
        for (int top = 0; top < 2; ++top) for (u32 i = 0; i < L.n(); ++i) if (!drop[i]) {
            u64 y = L.codes[i] | (u64(top) << L.W); if (!dropped || !isAbsorbed(y)) next.push_back(y); }
        L.codes.swap(next); L.W += 1; L.succ.clear();
        if (!absorbed.empty()) { vector<u64> f; f.reserve(L.codes.size()); for (u64 y : L.codes) if (!isAbsorbed(y)) f.push_back(y); L.codes.swap(f); }
    }
    return 0;
}
