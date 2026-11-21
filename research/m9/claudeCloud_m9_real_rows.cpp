// claudeCloud_m9_real_rows.cpp: pull M9 (ledger K55). Do windows of four runs with two or more even runs die out of
// real trapped rows with time since entry?
//
// A right half is driven by the black-even alternating centre (black at even ticks). In a cohort, cells 1..N of the
// row at tick 0 are random with cell N black (exact support N), white beyond. Sample s is the odd tick 2s + 1, and
// the gate is column 1 at samples. Entry is the first sample s_e (tick at most TMAX) at which columns 1..16 are one
// of the kit's 829 trap windows. From entry on, the black gate samples (kicks) are 3 or 5 apart: the kit's theorem,
// asserted here on every row. A run is the number of 5-gaps between two consecutive 3-gaps. A run, and a word of k
// consecutive runs, is dated by its delay d = (sample of the kick that opens its first 3-gap) - s_e. This is the P of
// claudeM5_m9_sat.py: there the window is in the trap at sample 0 and the closed word 3 5^r1 3 ... 5^rk 3 starts
// with a kick at sample P.
//
// Each row is followed S + MARGIN samples after entry; a run or a word counts when its delay is below S and its
// closing 3-gap was seen. Only the light cone of the last sample is simulated (columns 1..T_end - t + 1 at tick t).
//
//   g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_m9_real_rows.cpp -o real_rows
//   real_rows KITFILE cohort N ROWS S OUT [BASE [FIRST]]   rows FIRST..FIRST+ROWS-1 of the cohort of exact support N
//                                                  (N at most 64); row i is splitmix(BASE * 0x100000001B3 + i)
//   real_rows KITFILE empty S OUT                  the empty right half (the kit: it enters at tick 293)
//   real_rows KITFILE row1 BITS S OUT              one row given at tick 1 (sample 0); BITS[0] is column 1
// Output: OUT.summary.txt, OUT.words4.tsv, OUT.words3.tsv, OUT.words2.tsv
#include <algorithm>
#include <climits>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#include <omp.h>
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

static const int TMAX = 8001;                 // latest entry tick accepted
static const long MARGIN = 2000;              // samples followed past S, so that late words can close
static const long EDGE[] = {0, 6, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000,
                            500000, 1000000, 2000000, 5000000, LONG_MAX};
static const int NB = int(sizeof(EDGE) / sizeof(EDGE[0])) - 1;
static const int G = 20;                      // groups of rows (row index mod G), for the spread
static const int HL = 64;                     // run lengths 0..62, and 63 = longer
static inline int binOf(long d) { int b = 0; while (EDGE[b + 1] <= d) ++b; return b; }
static inline u64 splitmix(u64 x) { x += 0x9E3779B97F4A7C15ULL; x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9ULL;
                                    x = (x ^ (x >> 27)) * 0x94D049BB133111EBULL; return x ^ (x >> 31); }

struct Buf { vector<u64> a, b; };

// Follows one row. cells: columns 1.. at tick t0 (bit i of word j is column 64j + i + 1), support n. Returns false
// if the row has not entered the trap by TMAX. On success gate[d] is column 1 at delay d, for d = 0..Stot-1.
static bool follow(const vector<u64> &cells, long n, int t0, long Stot, Buf &B, vector<unsigned char> &gate, long &entryTick) {
    long tEndMax = TMAX + 2 * Stot, cols = max(n + TMAX + 2, (n + tEndMax) / 2 + 2);
    size_t W = size_t(cols / 64 + 6);
    if (B.a.size() < W + 2) { B.a.assign(W + 2, 0); B.b.assign(W + 2, 0); }
    else { fill(B.a.begin(), B.a.end(), 0); fill(B.b.begin(), B.b.end(), 0); }
    u64 *a = B.a.data() + 1, *b = B.b.data() + 1;                    // a[-1] carries the wall
    for (size_t i = 0; i < cells.size(); ++i) a[i] = cells[i];
    long t = t0, tEnd = LONG_MAX; entryTick = -1; gate.clear();
    for (;;) {
        if (t & 1) {
            if (entryTick < 0) {
                if (trapTab[a[0] & 0xFFFF]) { entryTick = t; tEnd = t + 2 * (Stot - 1); gate.reserve(size_t(Stot)); }
                else if (t >= TMAX) return false;
            }
            if (entryTick >= 0) { gate.push_back((unsigned char)(a[0] & 1)); if (t == tEnd) return true; }
        }
        long supp = n + (t - t0);                                     // no black cell beyond this column at tick t
        long need = tEnd == LONG_MAX ? supp : min(supp, tEnd - t + 1);  // columns 1..need can still reach the gate
        long nw = need / 64 + 2;
        a[-1] = (t % 2 == 0) ? (1ULL << 63) : 0;                      // the centre: black at even ticks
        u64 *__restrict__ pa = a; u64 *__restrict__ pb = b;
        for (long i = 0; i < nw; ++i)                                 // new cell = left xor (cell or right)
            pb[i] = ((pa[i] << 1) | (pa[i - 1] >> 63)) ^ (pa[i] | ((pa[i] >> 1) | (pa[i + 1] << 63)));
        swap(a, b); ++t;
    }
}

struct WordStat { u64 total = 0, late = 0; long mind = LONG_MAX, maxd = -1; u64 rows = 0; long lastRow = -1;
                  vector<unsigned> bins; };
typedef unordered_map<u64, WordStat> Table;
static inline void note(Table &T, u64 key, long d, long row, bool withBins) {
    WordStat &w = T[key]; ++w.total; if (d >= 100) ++w.late; if (d < w.mind) w.mind = d; if (d > w.maxd) w.maxd = d;
    if (w.lastRow != row) { ++w.rows; w.lastRow = row; }
    if (withBins) { if (w.bins.empty()) w.bins.assign(NB, 0); ++w.bins[binOf(d)]; }
}
static void mergeTable(Table &into, Table &from) {
    for (auto &kv : from) { WordStat &w = into[kv.first]; const WordStat &f = kv.second;
        w.total += f.total; w.late += f.late; w.mind = min(w.mind, f.mind); w.maxd = max(w.maxd, f.maxd); w.rows += f.rows;
        if (!f.bins.empty()) { if (w.bins.empty()) w.bins.assign(NB, 0); for (int i = 0; i < NB; ++i) w.bins[i] += f.bins[i]; } }
}

struct Stats {
    u64 runs[NB] = {}, even[NB] = {}, sumlen[NB] = {}, hist[NB][HL] = {};
    u64 win[NB][5] = {}, winCode[NB][5] = {};                        // four-run windows by number of even runs
    u64 gRuns[G][NB] = {}, gEven[G][NB] = {}, gWin[G][NB] = {}, gWin2[G][NB] = {};
    u64 entered = 0, notEntered = 0, censored = 0, kicks = 0, gaps3 = 0, gaps5 = 0, noLateThree = 0;
    long maxRun = 0, maxRunRow = -1, maxTail = 0;
    vector<int> entryTicks; Table w2, w3, w4;
    void add(Stats &o) {
        for (int b = 0; b < NB; ++b) { runs[b] += o.runs[b]; even[b] += o.even[b]; sumlen[b] += o.sumlen[b];
            for (int h = 0; h < HL; ++h) hist[b][h] += o.hist[b][h];
            for (int k = 0; k < 5; ++k) { win[b][k] += o.win[b][k]; winCode[b][k] += o.winCode[b][k]; }
            for (int g = 0; g < G; ++g) { gRuns[g][b] += o.gRuns[g][b]; gEven[g][b] += o.gEven[g][b]; gWin[g][b] += o.gWin[g][b]; gWin2[g][b] += o.gWin2[g][b]; } }
        entered += o.entered; notEntered += o.notEntered; censored += o.censored; kicks += o.kicks; gaps3 += o.gaps3; gaps5 += o.gaps5;
        noLateThree += o.noLateThree;
        if (o.maxRun > maxRun) { maxRun = o.maxRun; maxRunRow = o.maxRunRow; }
        maxTail = max(maxTail, o.maxTail);
        entryTicks.insert(entryTicks.end(), o.entryTicks.begin(), o.entryTicks.end());
        mergeTable(w2, o.w2); mergeTable(w3, o.w3); mergeTable(w4, o.w4);
    }
};

static inline u64 key(const long *r, int k) { u64 x = 0; for (int i = 0; i < k; ++i) x = (x << 12) | u64(min(r[i], 4095L)); return x; }
static string unkey(u64 x, int k) { string s; for (int i = k - 1; i >= 0; --i) { s += to_string((x >> (12 * i)) & 4095); if (i) s += ","; } return s; }

// Reads one row's gate into the statistics. S: only delays below S are counted.
static void account(const vector<unsigned char> &gate, long S, long row, Stats &st) {
    vector<long> three;                                               // delays of the kicks that open a 3-gap
    long prev = -1, tail = 0;
    for (long d = 0; d < (long)gate.size(); ++d) if (gate[d]) {
        ++st.kicks;
        if (prev >= 0) { long gap = d - prev;
            if (gap == 3) { three.push_back(prev); ++st.gaps3; tail = 0; }
            else if (gap == 5) { ++st.gaps5; ++tail; }
            else { fprintf(stderr, "row %ld: gap %ld at delay %ld after entry\n", row, gap, prev); require(false, "a gap after entry is neither 3 nor 5"); } }
        prev = d;
    }
    st.maxTail = max(st.maxTail, tail);
    if (three.empty() || three.back() < S) ++st.noLateThree;          // no 3-gap in the margin: a lock candidate
    size_t m = three.size(); vector<long> r(m ? m - 1 : 0);
    for (size_t k = 0; k + 1 < m; ++k) r[k] = (three[k + 1] - three[k] - 3) / 5;
    int g = int(row % G);
    for (size_t k = 0; k + 1 < m; ++k) {
        long d = three[k]; if (d >= S) break;
        int b = binOf(d); long len = r[k]; bool ev = len >= 4 && len % 2 == 0;
        ++st.runs[b]; st.sumlen[b] += u64(len); ++st.hist[b][min(len, long(HL - 1))]; ++st.gRuns[g][b];
        if (ev) { ++st.even[b]; ++st.gEven[g][b]; }
        if (len > st.maxRun) { st.maxRun = len; st.maxRunRow = row; }
        if (k + 2 < m) note(st.w2, key(&r[k], 2), d, row, false);
        if (k + 3 < m) note(st.w3, key(&r[k], 3), d, row, false);
        if (k + 4 < m) {
            int ne = 0; bool code = true;
            for (int i = 0; i < 4; ++i) { long x = r[k + i]; if (x >= 4 && x % 2 == 0) ++ne; if (x < 3) code = false; }
            ++st.win[b][ne]; if (code) ++st.winCode[b][ne];
            ++st.gWin[g][b]; if (ne >= 2) ++st.gWin2[g][b];
            note(st.w4, key(&r[k], 4), d, row, true);
        } else ++st.censored;
    }
}

static void writeTable(const string &path, Table &T, int k, bool withBins) {
    vector<pair<u64, const WordStat *>> v; for (auto &kv : T) v.push_back({kv.first, &kv.second});
    sort(v.begin(), v.end(), [](auto &x, auto &y) { return x.first < y.first; });
    FILE *f = fopen(path.c_str(), "w"); require(f, "cannot write a table");
    fprintf(f, "word\ttotal\tlate100\tmin_delay\tmax_delay\trows");
    if (withBins) for (int b = 0; b < NB; ++b) fprintf(f, "\tbin%ld", EDGE[b]);
    fprintf(f, "\n");
    for (auto &p : v) { const WordStat &w = *p.second;
        fprintf(f, "%s\t%llu\t%llu\t%ld\t%ld\t%llu", unkey(p.first, k).c_str(), (unsigned long long)w.total, (unsigned long long)w.late, w.mind, w.maxd, (unsigned long long)w.rows);
        if (withBins) for (int b = 0; b < NB; ++b) fprintf(f, "\t%u", w.bins.empty() ? 0u : w.bins[b]);
        fprintf(f, "\n"); }
    fclose(f);
}

int main(int argc, char **argv) {
    require(argc >= 5, "usage: KITFILE cohort N ROWS S OUT [BASE [FIRST]] | KITFILE empty S OUT | KITFILE row1 BITS S OUT");
    readTrap(argv[1]); string mode = argv[2];
    long N = 0, ROWS = 1, S = 0, FIRST = 0; string out; u64 BASE = 20261121; vector<u64> fixed; int t0 = 0;
    if (mode == "cohort") { require(argc >= 7, "cohort N ROWS S OUT [BASE]"); N = atol(argv[3]); ROWS = atol(argv[4]); S = atol(argv[5]); out = argv[6];
        if (argc > 7) BASE = strtoull(argv[7], 0, 10); if (argc > 8) FIRST = atol(argv[8]); require(N >= 1 && N <= 64, "N from 1 to 64"); }
    else if (mode == "empty") { S = atol(argv[3]); out = argv[4]; fixed.assign(1, 0); }
    else if (mode == "row1") { require(argc >= 6, "row1 BITS S OUT"); string bits = argv[3]; S = atol(argv[4]); out = argv[5]; t0 = 1; N = (long)bits.size();
        fixed.assign(bits.size() / 64 + 1, 0); for (size_t i = 0; i < bits.size(); ++i) if (bits[i] == '1') fixed[i / 64] |= 1ULL << (i % 64); }
    else require(false, "unknown mode");
    require(S >= 1, "S at least 1");
    long Stot = S + MARGIN + 1;
    Stats total; double t1 = omp_get_wtime();
    #pragma omp parallel
    { Stats st; Buf B; vector<unsigned char> gate; vector<u64> cells(1);
      #pragma omp for schedule(dynamic, 16) nowait
      for (long row = FIRST; row < FIRST + ROWS; ++row) {
          long entry = -1; bool ok;
          if (mode == "cohort") { u64 x = splitmix(BASE * 0x100000001B3ULL + u64(row));
              cells[0] = (N == 64 ? x : (x & ((1ULL << N) - 1))) | (1ULL << (N - 1));
              ok = follow(cells, N, 0, Stot, B, gate, entry); }
          else ok = follow(fixed, N, t0, Stot, B, gate, entry);
          if (!ok) { ++st.notEntered; continue; }
          ++st.entered; st.entryTicks.push_back(int(entry)); account(gate, S, row, st);
      }
      #pragma omp critical
      total.add(st);
    }
    double secs = omp_get_wtime() - t1;
    sort(total.entryTicks.begin(), total.entryTicks.end());
    FILE *f = fopen((out + ".summary.txt").c_str(), "w"); require(f, "cannot write the summary");
    fprintf(f, "mode %s N %ld rows %ld first %ld S %ld margin %ld base %llu seconds %.1f threads %d\n", mode.c_str(), N, ROWS, FIRST, S, MARGIN, (unsigned long long)BASE, secs, omp_get_max_threads());
    size_t ne = total.entryTicks.size();
    fprintf(f, "entered %llu not_entered_by_%d %llu", (unsigned long long)total.entered, TMAX, (unsigned long long)total.notEntered);
    if (ne) fprintf(f, " entry_tick_median %d p90 %d p99 %d max %d", total.entryTicks[ne / 2], total.entryTicks[size_t(0.9 * (ne - 1))], total.entryTicks[size_t(0.99 * (ne - 1))], total.entryTicks[ne - 1]);
    fprintf(f, "\nkicks %llu gaps3 %llu gaps5 %llu censored_windows %llu max_run %ld in_row %ld max_trailing_5gaps %ld rows_without_3gap_in_margin %llu\n",
            (unsigned long long)total.kicks, (unsigned long long)total.gaps3, (unsigned long long)total.gaps5, (unsigned long long)total.censored,
            total.maxRun, total.maxRunRow, total.maxTail, (unsigned long long)total.noLateThree);
    fprintf(f, "BINS delay_from delay_to runs even_runs sum_of_lengths windows w_even0 w_even1 w_even2 w_even3 w_even4 code_windows c_even0 c_even1 c_even2 c_even3 c_even4\n");
    for (int b = 0; b < NB; ++b) { if (!total.runs[b]) continue;
        u64 w = 0, c = 0; for (int k = 0; k < 5; ++k) { w += total.win[b][k]; c += total.winCode[b][k]; }
        fprintf(f, "BIN %ld %ld %llu %llu %llu %llu", EDGE[b], EDGE[b + 1] == LONG_MAX ? -1 : EDGE[b + 1], (unsigned long long)total.runs[b], (unsigned long long)total.even[b], (unsigned long long)total.sumlen[b], (unsigned long long)w);
        for (int k = 0; k < 5; ++k) fprintf(f, " %llu", (unsigned long long)total.win[b][k]);
        fprintf(f, " %llu", (unsigned long long)c);
        for (int k = 0; k < 5; ++k) fprintf(f, " %llu", (unsigned long long)total.winCode[b][k]);
        fprintf(f, "\n"); }
    fprintf(f, "GROUPS group delay_from runs even_runs windows windows_with_2_or_more_even\n");
    for (int g = 0; g < G; ++g) for (int b = 0; b < NB; ++b) if (total.gRuns[g][b])
        fprintf(f, "GROUP %d %ld %llu %llu %llu %llu\n", g, EDGE[b], (unsigned long long)total.gRuns[g][b], (unsigned long long)total.gEven[g][b], (unsigned long long)total.gWin[g][b], (unsigned long long)total.gWin2[g][b]);
    fprintf(f, "HIST delay_from then the number of runs of length 0, 1, ..., 62, and longer\n");
    for (int b = 0; b < NB; ++b) { if (!total.runs[b]) continue; fprintf(f, "HIST %ld", EDGE[b]);
        for (int h = 0; h < HL; ++h) fprintf(f, " %llu", (unsigned long long)total.hist[b][h]); fprintf(f, "\n"); }
    fclose(f);
    writeTable(out + ".words4.tsv", total.w4, 4, true); writeTable(out + ".words3.tsv", total.w3, 3, false); writeTable(out + ".words2.tsv", total.w2, 2, false);
    printf("%s N %ld rows %ld S %ld: entered %llu, not entered %llu, %llu kicks, %.1f s\n", mode.c_str(), N, ROWS, S,
           (unsigned long long)total.entered, (unsigned long long)total.notEntered, (unsigned long long)total.kicks, secs);
    return 0;
}
