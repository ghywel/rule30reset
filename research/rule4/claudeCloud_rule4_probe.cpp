// claudeCloud_rule4_probe.cpp: what does a fair-coin RIGHT half do to the columns near the wall? (ledger K83)
//
// The kit's Mathlib folder proves that a fair-coin LEFT half makes the centre column a fair-coin sequence, whatever
// the right half is (rule 30 is linear in its left cell). Nothing there, or in our record, treats the other side:
// a fixed left half and a fair-coin right half. This program measures three things about it.
//
//   centre-exact M          Row: white left of 0, cell 0 black, cells 1..M every word in turn. For each m <= M the
//                           exact law of the centre column c(1..m): how many different words occur, their Shannon,
//                           collision and min entropies in bits, and the most likely word. (c(1..m) reads only cells
//                           0..m, so one enumeration at M serves every m.)   M <= 30.
//   centre-mc N T SEED      The same row with a fair-coin right half as far as the cone of T ticks reaches, N times.
//                           At checkpoints m: the share of pairs of samples with the same c(1..m), the largest group,
//                           and the share whose last 2k ticks alternate (k = 4, 8, 12, 16).
//   gate KIT N TS SEED      A fair-coin right half beside the black-first alternating column (the wall of K79's
//                           claudeCloud_exterior_hazard.cpp, same update), N times, TS white-tick samples each. The
//                           gate is site 1 at the samples. Reports: the share that enters the kit's 829-window trap
//                           and when; for each sample the least period (1..60) of the gate over the last 200
//                           samples, tabulated against trap entry; and at checkpoints s the share of pairs with the
//                           same gate over samples 0..s-1, among all pairs and among pairs both in the trap by s.
//
//   wall WALLSEED N T SEED  One fair-coin wall (column 0 prescribed for T ticks, from WALLSEED) and N fair-coin right halves
//                           beside it. Column 1 is recorded at every tick. At checkpoints m: the share of pairs of
//                           halves with the same column 1 over ticks 1..m. Its rate of fall is the collision form of
//                           the entropy that the right half adds to the pair of columns (0, 1), given column 0.
//
//   g++ -O3 -fopenmp -std=c++17 claudeCloud_rule4_probe.cpp -o rule4_probe
// The generator is splitmix64 on SEED + index * a fixed odd constant, as in the hazard program.
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <map>
#include <numeric>
#include <sstream>
#include <string>
#include <vector>
#include <omp.h>
using namespace std;
typedef uint64_t u64;
typedef uint32_t u32;

static void require(bool ok, const char *why) { if (!ok) { fprintf(stderr, "FAILED: %s\n", why); exit(1); } }
static inline u64 splitmix(u64 &x) { u64 z = (x += 0x9E3779B97F4A7C15ULL); z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }

// ---------------------------------------------------------------- centre-exact
static int centreExact(int M) {
    require(M >= 4 && M <= 30, "M must be 4..30");
    const u64 total = 1ULL << M;
    vector<u32> cnt(total, 0);
    // bit index = position + M; cell 0 black; cells 1..M = the bits of r (cell k = bit k-1 of r)
    #pragma omp parallel for schedule(static)
    for (long long r = 0; r < (long long)total; ++r) {
        u64 x = (1ULL << M) | ((u64)r << (M + 1));
        u32 v = 0;                                         // c(1) is the top bit of the M-bit word v
        for (int t = 1; t <= M; ++t) {
            x = (x << 1) ^ (x | (x >> 1));
            v = (v << 1) | (u32)((x >> M) & 1);
        }
        #pragma omp atomic
        cnt[v]++;
    }
    printf("centre-exact M=%d: white left of 0, cell 0 black, every word on cells 1..%d; the law of c(1..m)\n", M, M);
    printf("   m  words  shannon  collision  min-entropy  largest-share  most-likely-word\n");
    vector<string> lines(M + 1);
    for (int m = M; m >= 1; --m) {
        u64 size = 1ULL << m, distinct = 0, best = 0, arg = 0; long double s1 = 0, s2 = 0;
        for (u64 v = 0; v < size; ++v) { u64 c = cnt[v]; if (!c) continue; ++distinct;
            long double p = (long double)c / (long double)total; s1 -= p * log2l(p); s2 += p * p;
            if (c > best) { best = c; arg = v; } }
        string w; for (int i = m - 1; i >= 0; --i) w += char('0' + ((arg >> i) & 1));
        char buf[400];
        snprintf(buf, sizeof buf, "  %2d  %9llu  %8.4Lf  %8.4Lf  %8.4f  %.6e  %s", m, (unsigned long long)distinct, s1,
                 -log2l(s2), -log2((double)best / (double)total), (double)best / (double)total, w.c_str());
        lines[m] = buf;
        if (m > 1) for (u64 v = 0; v < size / 2; ++v) cnt[v] = cnt[2 * v] + cnt[2 * v + 1];   // drop the last tick
    }
    for (int m = 1; m <= M; ++m) puts(lines[m].c_str());
    return 0;
}

// ---------------------------------------------------------------- records of bits, most significant first
struct Recs { int W; long N; vector<u64> d; Recs(long n, int bits) : W((bits + 63) / 64), N(n), d((size_t)n * ((bits + 63) / 64), 0) {}
    inline void set(long i, int t) { d[(size_t)i * W + t / 64] |= 1ULL << (63 - t % 64); }
    inline int get(long i, int t) const { return (d[(size_t)i * W + t / 64] >> (63 - t % 64)) & 1; }
    inline const u64 *row(long i) const { return &d[(size_t)i * W]; } };
static int lcp(const Recs &R, long a, long b) {            // common prefix length in bits
    const u64 *x = R.row(a), *y = R.row(b);
    for (int w = 0; w < R.W; ++w) if (x[w] != y[w]) return w * 64 + __builtin_clzll(x[w] ^ y[w]);
    return R.W * 64;
}
static vector<long> sortedOrder(const Recs &R) {
    vector<long> ord(R.N); iota(ord.begin(), ord.end(), 0L);
    int W = R.W; const u64 *base = R.d.data();
    sort(ord.begin(), ord.end(), [&](long a, long b) { const u64 *x = base + (size_t)a * W, *y = base + (size_t)b * W;
        for (int w = 0; w < W; ++w) if (x[w] != y[w]) return x[w] < y[w]; return a < b; });
    return ord;
}

// ---------------------------------------------------------------- centre-mc
static int centreMC(long N, int T, u64 seed) {
    require(T >= 64 && T <= 4096 && N >= 2, "bad arguments");
    int cells = 2 * T + 2, words = (cells + 63) / 64 + 1;  // bit index = position + T
    Recs R(N, T);
    #pragma omp parallel
    {
        vector<u64> a(words), nx(words);
        #pragma omp for schedule(dynamic, 256)
        for (long i = 0; i < N; ++i) {
            u64 st = seed + (u64)i * 0x2545F4914F6CDD1DULL;
            fill(a.begin(), a.end(), 0);
            a[T / 64] |= 1ULL << (T % 64);
            u64 rnd = 0;
            for (int k = 0; k < T; ++k) { if (k % 64 == 0) rnd = splitmix(st);
                if ((rnd >> (k % 64)) & 1) { int p = T + 1 + k; a[p / 64] |= 1ULL << (p % 64); } }
            for (int t = 1; t <= T; ++t) {
                u64 carry = 0;
                for (int w = 0; w < words; ++w) { u64 x = a[w], right = (x >> 1) | (w + 1 < words ? a[w + 1] << 63 : 0);
                    nx[w] = ((x << 1) | carry) ^ (x | right); carry = x >> 63; }
                a.swap(nx);
                if ((a[T / 64] >> (T % 64)) & 1) R.set(i, t - 1);
            }
        }
    }
    vector<long> ord = sortedOrder(R);
    vector<int> L(N - 1);
    #pragma omp parallel for
    for (long i = 0; i < N - 1; ++i) L[i] = lcp(R, ord[i], ord[i + 1]);
    printf("centre-mc: %ld fair right halves, white left of 0, cell 0 black, %d ticks, seed %llu\n", N, T, (unsigned long long)seed);
    printf("     m  same-pairs  share-of-pairs  -log2(share)  largest-group   last 8 / 16 / 24 / 32 ticks alternate (share)\n");
    double pairs = (double)N * (double)(N - 1) / 2.0;
    for (int m : {8, 12, 16, 20, 24, 28, 32, 40, 48, 64, 80, 96, 128, 160, 192, 256, 320, 384, 512, 768, 1024, 2048, 4096}) {
        if (m > T) break;
        u64 same = 0; long run = 1, best = 1;
        for (long i = 0; i + 1 < N; ++i) { if (L[i] >= m) ++run; else { same += (u64)run * (run - 1) / 2; best = max(best, run); run = 1; } }
        same += (u64)run * (run - 1) / 2; best = max(best, run);
        long alt[4] = {0, 0, 0, 0};
        #pragma omp parallel for reduction(+ : alt[:4])
        for (long i = 0; i < N; ++i) for (int k = 0; k < 4; ++k) { int len = 8 * (k + 1); if (len > m) continue; bool ok = true;
            for (int t = m - len + 1; t < m && ok; ++t) ok = R.get(i, t) != R.get(i, t - 1); if (ok) ++alt[k]; }
        printf("  %4d  %10llu  %.6e  %8.3f  %10ld     %.3e  %.3e  %.3e  %.3e\n", m, (unsigned long long)same, same / pairs,
               same ? -log2(same / pairs) : 0.0, best, alt[0] / (double)N, alt[1] / (double)N, alt[2] / (double)N, alt[3] / (double)N);
    }
    return 0;
}

// ---------------------------------------------------------------- gate
static vector<char> trapTab(1 << 16, 0);
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
static int gateMode(const char *kit, long N, int TS, u64 seed) {
    require(TS >= 300 && TS <= 4000 && N >= 2, "bad arguments");
    readTrap(kit);
    int TMAX = 2 * TS, cells = 2 * TMAX + 80, words = (cells + 63) / 64 + 1;
    Recs R(N, TS); vector<int> entry(N, -1), period(N, 0);
    #pragma omp parallel
    {
        vector<u64> a(words), nx(words);
        #pragma omp for schedule(dynamic, 64)
        for (long i = 0; i < N; ++i) {
            u64 st = seed + (u64)i * 0x2545F4914F6CDD1DULL;
            for (int w = 0; w < words - 1; ++w) a[w] = splitmix(st);
            a[words - 1] = 0;
            int sample = 0;
            for (int t = 0; t < TMAX; ++t) {
                u64 carry = (t % 2 == 0) ? 1 : 0;                       // the wall: black at even ticks
                for (int w = 0; w < words; ++w) { u64 x = a[w], right = (x >> 1) | (w + 1 < words ? a[w + 1] << 63 : 0);
                    nx[w] = ((x << 1) | carry) ^ (x | right); carry = x >> 63; }
                a.swap(nx);
                if ((t + 1) % 2 == 1) {                                 // a white tick: a sample
                    u64 lo = a[0];
                    if (entry[i] < 0 && trapTab[lo & 0xFFFF]) entry[i] = sample;
                    if (lo & 1) R.set(i, sample);
                    ++sample;
                }
            }
            int from = TS - 200;
            for (int p = 1; p <= 60 && !period[i]; ++p) { bool ok = true;
                for (int s = from; s + p < TS && ok; ++s) ok = R.get(i, s) == R.get(i, s + p); if (ok) period[i] = p; }
        }
    }
    printf("gate: %ld fair right halves beside the black-first alternating column, %d samples each, seed %llu\n", N, TS, (unsigned long long)seed);
    long in = 0; double sum = 0; vector<int> es;
    for (long i = 0; i < N; ++i) if (entry[i] >= 0) { ++in; sum += entry[i]; es.push_back(entry[i]); }
    sort(es.begin(), es.end());
    printf("  entered the trap: %ld of %ld (%.5f)", in, N, in / (double)N);
    if (in) printf("; entry sample mean %.1f, median %d, 99%% %d, 99.9%% %d, last %d", sum / in, es[es.size() / 2], es[(size_t)(es.size() * 0.99)],
                   es[(size_t)(es.size() * 0.999)], es.back());
    printf("\n  the gate's least period over the last 200 samples (0 = none up to 60), against trap entry:\n");
    map<pair<int, int>, long> tab;
    for (long i = 0; i < N; ++i) tab[{period[i], entry[i] >= 0 ? 1 : 0}]++;
    for (auto &kv : tab) printf("    period %2d  %s  %9ld  (%.6f)\n", kv.first.first, kv.first.second ? "in the trap " : "never entered", kv.second, kv.second / (double)N);
    // one example gap word per periodic class outside and inside the trap
    map<pair<int, int>, long> ex;
    for (long i = 0; i < N; ++i) if (period[i]) ex.insert({{period[i], entry[i] >= 0 ? 1 : 0}, i});
    for (auto &kv : ex) { long i = kv.second; string g; for (int s = TS - 2 * kv.first.first - 1; s < TS; ++s) g += char('0' + R.get(i, s));
        printf("    example, period %2d %s: sample %ld, last readings %s\n", kv.first.first, kv.first.second ? "in the trap" : "outside", i, g.c_str()); }
    vector<long> ord = sortedOrder(R);
    vector<int> L(N - 1);
    #pragma omp parallel for
    for (long i = 0; i < N - 1; ++i) L[i] = lcp(R, ord[i], ord[i + 1]);
    double pairs = (double)N * (double)(N - 1) / 2.0;
    printf("  pairs of halves with the same gate over samples 0..s-1:\n");
    printf("      s   all pairs: count, share, -log2   largest group |  both in the trap by s and aperiodic at the end: count, share of such pairs, -log2\n");
    for (int s : {8, 16, 24, 32, 48, 64, 96, 128, 160, 192, 256, 320, 384, 448, 512, 640, 768, 1024, 2048, 4000}) {
        if (s > TS) break;
        u64 same = 0, sameT = 0; long run = 1, best = 1, runT = 0, nT = 0;
        auto isT = [&](long idx) { return entry[idx] >= 0 && entry[idx] < s && period[idx] == 0; };
        for (long i = 0; i < N; ++i) if (isT(i)) ++nT;
        runT = isT(ord[0]) ? 1 : 0;
        for (long i = 0; i + 1 < N; ++i) {
            if (L[i] >= s) { ++run; if (isT(ord[i + 1])) ++runT; }
            else { same += (u64)run * (run - 1) / 2; sameT += (u64)runT * (runT - 1) / 2; best = max(best, run); run = 1; runT = isT(ord[i + 1]) ? 1 : 0; }
        }
        same += (u64)run * (run - 1) / 2; sameT += (u64)runT * (runT - 1) / 2; best = max(best, run);
        double pairsT = (double)nT * (double)(nT - 1) / 2.0;
        printf("   %4d  %12llu  %.6e  %7.3f  %9ld |  %12llu  %.6e  %7.3f   (%ld halves)\n", s, (unsigned long long)same, same / pairs,
               same ? -log2(same / pairs) : 0.0, best, (unsigned long long)sameT, pairsT > 0 ? sameT / pairsT : 0.0,
               sameT ? -log2(sameT / pairsT) : 0.0, nT);
    }
    return 0;
}

// ---------------------------------------------------------------- wall
static int wallMode(u64 wallSeed, long N, int T, u64 seed) {
    require(T >= 64 && T <= 4096 && N >= 2, "bad arguments");
    vector<char> wall(T); { u64 st = wallSeed; u64 rnd = 0; for (int t = 0; t < T; ++t) { if (t % 64 == 0) rnd = splitmix(st); wall[t] = (rnd >> (t % 64)) & 1; } }
    int cells = T + 80, words = (cells + 63) / 64 + 1;
    Recs R(N, T);
    #pragma omp parallel
    {
        vector<u64> a(words), nx(words);
        #pragma omp for schedule(dynamic, 256)
        for (long i = 0; i < N; ++i) {
            u64 st = seed + (u64)i * 0x2545F4914F6CDD1DULL;
            for (int w = 0; w < words - 1; ++w) a[w] = splitmix(st);
            a[words - 1] = 0;
            for (int t = 0; t < T; ++t) {
                u64 carry = wall[t];
                for (int w = 0; w < words; ++w) { u64 x = a[w], right = (x >> 1) | (w + 1 < words ? a[w + 1] << 63 : 0);
                    nx[w] = ((x << 1) | carry) ^ (x | right); carry = x >> 63; }
                a.swap(nx);
                if (a[0] & 1) R.set(i, t);
            }
        }
    }
    vector<long> ord = sortedOrder(R);
    vector<int> L(N - 1);
    #pragma omp parallel for
    for (long i = 0; i < N - 1; ++i) L[i] = lcp(R, ord[i], ord[i + 1]);
    int black = 0; for (int t = 0; t < T; ++t) black += wall[t];
    printf("wall: one fair-coin wall (seed %llu, %d of %d ticks black), %ld fair right halves, seed %llu\n", (unsigned long long)wallSeed, black, T, N, (unsigned long long)seed);
    printf("     m  same-pairs  share-of-pairs  -log2(share)  largest-group  different-words-seen\n");
    double pairs = (double)N * (double)(N - 1) / 2.0;
    for (int m : {8, 12, 16, 20, 24, 28, 32, 40, 48, 64, 80, 96, 128, 160, 192, 256, 320, 384, 512, 768, 1024, 2048, 4096}) {
        if (m > T) break;
        u64 same = 0; long run = 1, best = 1, groups = 1;
        for (long i = 0; i + 1 < N; ++i) { if (L[i] >= m) ++run; else { same += (u64)run * (run - 1) / 2; best = max(best, run); run = 1; ++groups; } }
        same += (u64)run * (run - 1) / 2; best = max(best, run);
        printf("  %4d  %10llu  %.6e  %8.3f  %10ld  %10ld\n", m, (unsigned long long)same, same / pairs, same ? -log2(same / pairs) : 0.0, best, groups);
    }
    return 0;
}

int main(int argc, char **argv) {
    require(argc >= 3, "usage: rule4_probe centre-exact M | centre-mc N T SEED | gate KIT N TS SEED | wall WALLSEED N T SEED");
    string mode = argv[1];
    if (mode == "centre-exact") return centreExact(atoi(argv[2]));
    if (mode == "centre-mc") { require(argc >= 5, "centre-mc N T SEED"); return centreMC(atol(argv[2]), atoi(argv[3]), strtoull(argv[4], nullptr, 10)); }
    if (mode == "gate") { require(argc >= 6, "gate KIT N TS SEED"); return gateMode(argv[2], atol(argv[3]), atoi(argv[4]), strtoull(argv[5], nullptr, 10)); }
    if (mode == "wall") { require(argc >= 6, "wall WALLSEED N T SEED"); return wallMode(strtoull(argv[2], nullptr, 10), atol(argv[3]), atoi(argv[4]), strtoull(argv[5], nullptr, 10)); }
    require(false, "unknown mode"); return 1;
}
