// claudeCloud_k84_far.cpp: lower bounds on the excess far beyond the exact range, by sampling right halves (ledger K88).
//
// The centre is black at even ticks.  A right half is 256 cells (bit 0 = site 1), white beyond.  Its gate word is
// site 1 at ticks 1, 3, ..., 2M - 1; cells beyond site 256 cannot reach site 1 in that time when 2M + 1 <= 255.
// The west that keeps the centre alternating is decoded sideways (I246's K84FiniteSupport; the kit's Psi):
//   depth 1 as a column is black at even ticks and the opposite of the reading at odd ticks,
//   west(b, c)(t) = b(t+1) xor (b(t) or c(t)) gives the next column, and its bit at tick 0 is the next depth.
// If the decoded west is white at depths B + 1 .. T, the west cut at B and this right half keep the centre alternating
// through tick T.  So the longest white run ending at depth T, over the samples, is a lower bound on excess(T), and
// each bound comes with its right half and can be replayed on the whole line.
//
//   g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_k84_far.cpp -o k84_far
//   k84_far M LOG2N SEED            M readings (at most 127), 2^LOG2N samples
//   k84_far M show SEED INDEX       one sample: its right half, gate word and decoded west, for cross-checking
// Output: per depth T = 1 .. 2M + 1:  T, the longest white run ending at T, the share of samples white at T, and the
// right half (hex, site 1 = lowest bit) and sample index of the first sample attaining the run.
#include <bitset>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <omp.h>
typedef std::bitset<256> Row;
static inline uint64_t splitmix(uint64_t &x) { uint64_t z = (x += 0x9e3779b97f4a7c15ULL); z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL; z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL; return z ^ (z >> 31); }
static Row randomRow(uint64_t seed, uint64_t index) {
    uint64_t s = seed * 0x100000001b3ULL + index * 0x9e3779b97f4a7c15ULL + 1; Row r;
    for (int w = 0; w < 4; ++w) { uint64_t v = splitmix(s); for (int b = 0; b < 64; ++b) if ((v >> b) & 1) r.set(64 * w + b); }
    return r;
}
static std::string hex(const Row &r) { static const char *d = "0123456789abcdef"; std::string s; for (int i = 63; i >= 0; --i) { int v = 0; for (int b = 0; b < 4; ++b) v |= r[4 * i + b] << b; s += d[v]; } return s; }
static void decode(const Row &right, int M, std::vector<int> &gate, std::vector<int> &west) {
    Row row = right; const Row one(1);
    gate.assign(M, 0);
    for (int i = 0; i < M; ++i) {
        row = ((row << 1) | one) ^ (row | (row >> 1));      // tick 2i -> 2i+1, centre black
        gate[i] = row[0];
        row = (row << 1) ^ (row | (row >> 1));              // tick 2i+1 -> 2i+2, centre white
    }
    int T = 2 * M + 1;
    Row parent, column;
    for (int t = 0; t < T; ++t) { if (t % 2 == 0) { parent.set(t); column.set(t); } else if (!gate[t / 2]) column.set(t); }
    west.assign(T, 0);
    for (int d = 0; d < T; ++d) {
        west[d] = column[0];
        Row next = (column >> 1) ^ (column | parent);
        parent = column; column = next;
    }
}
int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: k84_far M LOG2N SEED | k84_far M show SEED INDEX\n"); return 1; }
    int M = atoi(argv[1]); if (M < 1 || M > 127) return 1; int T = 2 * M + 1;
    if (!strcmp(argv[2], "show")) {
        uint64_t seed = strtoull(argv[3], 0, 10), index = strtoull(argv[4], 0, 10);
        Row r = randomRow(seed, index); std::vector<int> g, w; decode(r, M, g, w);
        printf("right %s\ngate ", hex(r).c_str()); for (int x : g) putchar('0' + x); printf("\nwest "); for (int x : w) putchar('0' + x); putchar('\n');
        return 0;
    }
    int lg = atoi(argv[2]); uint64_t seed = strtoull(argv[3], 0, 10); uint64_t N = 1ULL << lg;
    std::vector<int> best(T + 1, -1); std::vector<uint64_t> bestIdx(T + 1, 0); std::vector<uint64_t> white(T + 1, 0);
    #pragma omp parallel
    {
        std::vector<int> lb(T + 1, -1), g, w; std::vector<uint64_t> li(T + 1, 0), lw(T + 1, 0);
        #pragma omp for schedule(static)
        for (uint64_t i = 0; i < N; ++i) {
            Row r = randomRow(seed, i); decode(r, M, g, w);
            int run = 0;
            for (int d = 1; d <= T; ++d) {
                if (w[d - 1]) run = 0; else { ++run; ++lw[d]; }
                if (run > lb[d] || (run == lb[d] && i < li[d])) { lb[d] = run; li[d] = i; }
            }
        }
        #pragma omp critical
        for (int d = 1; d <= T; ++d) { white[d] += lw[d]; if (lb[d] > best[d] || (lb[d] == best[d] && li[d] < bestIdx[d])) { best[d] = lb[d]; bestIdx[d] = li[d]; } }
    }
    printf("# M %d samples 2^%d seed %llu\n", M, lg, (unsigned long long)seed);
    for (int d = 1; d <= T; ++d) printf("%d %d %.5f %s %llu\n", d, best[d], (double)white[d] / (double)N, hex(randomRow(seed, bestIdx[d])).c_str(), (unsigned long long)bestIdx[d]);
    return 0;
}
