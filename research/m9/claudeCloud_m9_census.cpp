// claudeCloud_m9_census.cpp: pull M9, third block (ledger K51, addendum 1). Where does EVERY finite right half of
// support up to NMAX go, and how long does it take?
//
// A right half is driven by the black-even alternating centre (black at even ticks). Its cells 1..n are the bits of
// a seed, cell n black (exact support n), white beyond. At each odd tick the window is tested, in this order:
//   trap      columns 1..16 are one of the kit's 829 windows (closed for ever: the gate then has gaps 3 or 5);
//   sink k    columns 1..W_k are in a certified periodic sink of the exterior ladder (claudeCloud_m9_exterior.cpp,
//             run here to 33 columns with absorption from 19: the ether sinks and the 30-column period-seven lock).
// A half not resolved by TMAX is tested for a periodic gate over its last 2,048 odd ticks and reported by seed.
// RD (kit Rule30PeriodTwoWidth13) says every finite right half enters the trap or has an eventually periodic gate.
//
//   g++ -O3 -fopenmp -std=c++17 claudeCloud_m9_census.cpp -o census
//   census KITFILE NMAX [TMAX]          TMAX at most 8000 (default 8000)
#define main exterior_main
#include "claudeCloud_m9_exterior.cpp"
#undef main
#include <omp.h>

static const int NW = 132;                              // 8,448 cells

struct Row { u64 a[NW]; int words; };
static inline void rowStep(Row &r, u64 wall) {          // new cell = left xor (cell or right); column 0 is the wall
    int w = r.words; u64 carry = wall; u64 nxt[NW];
    for (int i = 0; i < w; ++i) {
        u64 x = r.a[i], right = (x >> 1) | (i + 1 < w ? r.a[i + 1] << 63 : 0);
        nxt[i] = ((x << 1) | carry) ^ (x | right); carry = x >> 63;
    }
    if (carry && w < NW) { nxt[w] = carry; ++w; }       // the edge moves one cell right each tick
    else if (w < NW && w > 0 && (nxt[w - 1] >> 63)) { /* top word full: next tick will carry */ }
    memcpy(r.a, nxt, sizeof(u64) * w); r.words = w;
}

struct Fate { int dest; int tick; };                    // dest: 0 trap, k >= 1 sink k, -1 periodic gate, -2 unresolved

static Fate follow(u64 seed, int TMAX, string *gateOut = nullptr) {
    Row r; memset(r.a, 0, sizeof(r.a)); r.a[0] = seed; r.words = 1;
    vector<char> gate;
    for (int t = 0; t < TMAX; ++t) {
        rowStep(r, (t % 2 == 0) ? 1 : 0);               // the centre at tick t: black when t is even
        int now = t + 1;
        if (now % 2 == 1) {
            u64 lo = r.a[0];
            if (trapTab[lo & 0xFFFF]) return {0, now};
            for (size_t k = 0; k < absorbed.size(); ++k)
                if (binary_search(absorbed[k].codes.begin(), absorbed[k].codes.end(), lo & ((1ULL << absorbed[k].W) - 1)))
                    return {int(k) + 1, now};
            gate.push_back(char(lo & 1));
        }
    }
    int m = (int)gate.size();
    for (int p = 1; p <= 512; ++p) { bool ok = true;
        for (int i = m - 2048; i + p < m && ok; ++i) ok = gate[i] == gate[i + p];
        if (ok) { if (gateOut) { gateOut->clear(); for (int i = m - p; i < m; ++i) *gateOut += char('0' + gate[i]); } return {-1, p}; } }
    return {-2, TMAX};
}

int main(int argc, char **argv) {
    require(argc >= 3, "usage: KITFILE NMAX [TMAX]");
    int NMAX = atoi(argv[2]), TMAX = argc > 3 ? atoi(argv[3]) : 8000;
    require(TMAX <= 8000 && NMAX <= 40, "limits");
    { char a0[] = "exterior", a2[] = "two", a3[] = "33", a4[] = "19"; char *av[] = {a0, argv[1], a2, a3, a4};
      printf("--- the exterior ladder to 33 columns, absorbing from 19 (it supplies the certified sinks)\n");
      exterior_main(5, av); }
    printf("--- certified sinks:");
    for (size_t k = 0; k < absorbed.size(); ++k) printf(" [%zu] %u columns, %zu windows, gate %s;", k + 1, absorbed[k].W, absorbed[k].codes.size(), absorbed[k].word.c_str());
    printf("\n");
    { Fate f = follow(0, TMAX); printf("control: the empty right half: dest %d at tick %d (kit: the trap at 293)\n", f.dest, f.tick);
      require(f.dest == 0 && f.tick == 293, "the empty right half does not enter the trap at tick 293"); }
    { // control: the packed row step against the window step of the ladder, on random seeds
      mt19937_64 rng(7); for (int i = 0; i < 2000; ++i) { u64 s = rng() & ((1ULL << 40) - 1); Row r; memset(r.a, 0, sizeof(r.a)); r.a[0] = s; r.words = 1;
          rowStep(r, 1); u64 odd = r.a[0]; rowStep(r, 0); rowStep(r, 1);
          u64 w = odd & ((1ULL << 20) - 1); unsigned in = unsigned((((odd >> 20) & 1) << 1) | ((odd >> 21) & 1));
          require((r.a[0] & ((1ULL << 20) - 1)) == nextw(w, in, 20), "row step and window step disagree"); } }
    int ND = (int)absorbed.size() + 1;
    printf("  n       seeds  %s  periodic unresolved | worst tick (seed) | worst tick-n | share trap\n", "trap and each sink");
    for (int n = 1; n <= NMAX; ++n) {
        u64 lo = 1ULL << (n - 1), hi = 1ULL << n;
        vector<u64> cnt(ND + 2, 0); int worst = 0; u64 worstSeed = 0; vector<u64> odd;
        #pragma omp parallel
        { vector<u64> c(ND + 2, 0); int w = 0; u64 ws = 0; vector<u64> od;
          #pragma omp for schedule(dynamic, 4096) nowait
          for (long long s = (long long)lo; s < (long long)hi; ++s) { Fate f = follow((u64)s, TMAX);
              if (f.dest >= 0) { ++c[f.dest]; if (f.tick > w) { w = f.tick; ws = (u64)s; } }
              else { ++c[f.dest == -1 ? ND : ND + 1]; if (od.size() < 20) od.push_back((u64)s); } }
          #pragma omp critical
          { for (int i = 0; i < ND + 2; ++i) cnt[i] += c[i]; if (w > worst || (w == worst && ws < worstSeed)) { worst = w; worstSeed = ws; }
            for (u64 x : od) if (odd.size() < 20) odd.push_back(x); } }
        printf("%3d %11llu ", n, (unsigned long long)(hi - lo));
        for (int i = 0; i < ND; ++i) printf(" %llu", (unsigned long long)cnt[i]);
        printf("  %llu %llu | %d (%llu) | %d | %.4f\n", (unsigned long long)cnt[ND], (unsigned long long)cnt[ND + 1], worst,
               (unsigned long long)worstSeed, worst - n, double(cnt[0]) / double(hi - lo));
        sort(odd.begin(), odd.end());
        for (u64 x : odd) { string g; Fate f = follow(x, TMAX, &g);
            printf("      seed %llu: %s%s\n", (unsigned long long)x, f.dest == -1 ? "periodic gate, word " : "UNRESOLVED at TMAX", f.dest == -1 ? g.c_str() : ""); }
        fflush(stdout);
    }
    return 0;
}
