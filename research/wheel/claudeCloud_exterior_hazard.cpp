// claudeCloud_exterior_hazard.cpp: how often does a real right half make an excursion of X or of Y and come back,
// before it enters the gate trap? (ledger K79, addendum 5)
//
// A right half beside the black-first alternating column is followed tick by tick, exactly, until its first
// sixteen columns are one of the kit's 829 trap windows at a white tick, or until TMAX ticks. Its gate (column 1 at
// the white ticks) up to that point is read as gaps between kicks, and counted:
//
//   X   the loop A = 25 and the excursion E = 33535555.  An excursion is COMPLETED when the gaps read
//       25 33535555 25: it left the loop and came back to it.
//   Y   the loop 2 and the excursions 45 and 4525.       Completed when the gaps read 2 2 45 2 2 or 2 2 4525 2 2 ... the
//       count here is of gaps of 4 that stand between two runs of at least two 2s (4 5 or 4 5 2 5 between).
//
// Two kinds of start: `random` (every cell of the row a fair coin, as far as the light cone of TMAX ticks reaches)
// and `seed N` (N fair cells, cell N black, white beyond: a finite right half of support N).
//
//   g++ -O3 -fopenmp -std=c++17 claudeCloud_exterior_hazard.cpp -o hazard
//   hazard KITFILE random TRIALS TMAX [BASE]
//   hazard KITFILE seed N TRIALS TMAX [BASE]
// Output: how many halves entered the trap, how many did not by TMAX, the histogram of completed excursions of X
// and of Y per half, the longest runs of the two loops, and the halves with the most excursions (their index, so
// they can be rebuilt: the generator is splitmix64 on BASE + index).
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <sstream>
#include <string>
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
static inline u64 splitmix(u64 &x) { u64 z = (x += 0x9E3779B97F4A7C15ULL); z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }

struct Result { int entry; int ex, ey; int loopX, loopY; };

// counts over the gap string
static int countSub(const string &s, const string &pat) {
    int n = 0; size_t p = 0;
    while ((p = s.find(pat, p)) != string::npos) { ++n; p += 1; }
    return n;
}
static int longestRun(const string &s, const string &unit) {
    int best = 0; size_t i = 0, u = unit.size();
    while (i + u <= s.size()) {
        if (s.compare(i, u, unit) == 0) { int k = 0; size_t j = i; while (j + u <= s.size() && s.compare(j, u, unit) == 0) { ++k; j += u; }
            best = max(best, k); i = j; }
        else ++i;
    }
    return best;
}

static Result follow(u64 index, u64 base, bool finite, int N, int TMAX) {
    int cells = finite ? (N + TMAX + 2) : (2 * TMAX + 80);       // random: everything the cone of TMAX ticks reads
    int words = (cells + 63) / 64 + 1;
    vector<u64> a(words, 0), nxt(words, 0);
    u64 st = base + index * 0x2545F4914F6CDD1DULL;
    if (finite) {
        for (int i = 0; i < N - 1; ++i) if (splitmix(st) & 1) a[i / 64] |= 1ULL << (i % 64);
        a[(N - 1) / 64] |= 1ULL << ((N - 1) % 64);
    } else {
        for (int w = 0; w < words - 1; ++w) a[w] = splitmix(st);
    }
    string gaps; gaps.reserve(256);
    int lastKick = -1, sample = 0, entry = -1;
    for (int t = 0; t < TMAX; ++t) {
        u64 carry = (t % 2 == 0) ? 1 : 0;                        // the centre: black at even ticks
        for (int i = 0; i < words; ++i) {
            u64 x = a[i], right = (x >> 1) | (i + 1 < words ? a[i + 1] << 63 : 0);
            nxt[i] = ((x << 1) | carry) ^ (x | right); carry = x >> 63;
        }
        a.swap(nxt);
        if ((t + 1) % 2 == 1) {                                  // a white tick: a sample
            u64 lo = a[0];
            if (trapTab[lo & 0xFFFF]) { entry = t + 1; break; }
            if (lo & 1) { if (lastKick >= 0) { int g = sample - lastKick; gaps += (g < 10 ? char('0' + g) : '9'); } lastKick = sample; }
            ++sample;
        }
    }
    Result r; r.entry = entry;
    r.ex = countSub(gaps, "253353555525");
    r.ey = countSub(gaps, "224522") + countSub(gaps, "22452522");
    r.loopX = longestRun(gaps, "25"); r.loopY = longestRun(gaps, "2");
    return r;
}

int main(int argc, char **argv) {
    require(argc >= 5, "usage: hazard KITFILE random TRIALS TMAX [BASE] | hazard KITFILE seed N TRIALS TMAX [BASE]");
    readTrap(argv[1]);
    bool finite = string(argv[2]) == "seed";
    int k = 3, N = 0;
    if (finite) N = atoi(argv[k++]);
    long trials = atol(argv[k++]); int TMAX = atoi(argv[k++]);
    u64 base = argc > k ? strtoull(argv[k], nullptr, 10) : 20261123ULL;
    const int H = 12;
    vector<long> hx(H, 0), hy(H, 0); long entered = 0, open = 0; int bestX = 0, bestY = 0, loopX = 0, loopY = 0;
    long whoX = -1, whoY = -1; double sumEntry = 0; vector<int> entries;
    #pragma omp parallel
    {
        vector<long> lx(H, 0), ly(H, 0); long le = 0, lo = 0; int bx = 0, by = 0, mx = 0, my = 0; long wx = -1, wy = -1;
        double se = 0;
        #pragma omp for schedule(dynamic, 256)
        for (long i = 0; i < trials; ++i) {
            Result r = follow(u64(i), base, finite, N, TMAX);
            if (r.entry >= 0) { ++le; se += r.entry; } else ++lo;
            ++lx[min(r.ex, H - 1)]; ++ly[min(r.ey, H - 1)];
            if (r.ex > bx) { bx = r.ex; wx = i; } if (r.ey > by) { by = r.ey; wy = i; }
            mx = max(mx, r.loopX); my = max(my, r.loopY);
        }
        #pragma omp critical
        {
            for (int j = 0; j < H; ++j) { hx[j] += lx[j]; hy[j] += ly[j]; }
            entered += le; open += lo; sumEntry += se;
            if (bx > bestX || (bx == bestX && wx >= 0 && (whoX < 0 || wx < whoX))) { bestX = bx; whoX = wx; }
            if (by > bestY || (by == bestY && wy >= 0 && (whoY < 0 || wy < whoY))) { bestY = by; whoY = wy; }
            loopX = max(loopX, mx); loopY = max(loopY, my);
        }
    }
    printf("%s%s%d: %ld halves, %d ticks each at most, base %llu\n", finite ? "seed " : "random", finite ? "N=" : " ",
           finite ? N : 0, trials, TMAX, (unsigned long long)base);
    printf("  entered the trap %ld (mean entry tick %.1f); not entered by the limit %ld\n", entered, entered ? sumEntry / entered : 0.0, open);
    printf("  completed excursions of X per half:");
    for (int j = 0; j < H; ++j) if (hx[j]) printf(" %d:%ld", j, hx[j]);
    printf("\n  completed excursions of Y per half:");
    for (int j = 0; j < H; ++j) if (hy[j]) printf(" %d:%ld", j, hy[j]);
    printf("\n  most excursions of X %d (half %ld); of Y %d (half %ld); longest loop of X %d copies of 25; of Y %d gaps of 2\n",
           bestX, whoX, bestY, whoY, loopX, loopY);
    return 0;
}
