// claudeCloud_alt_strips.cpp: how many time-periodic columns beside the alternating column force one of the four
// loop gates? (ledger K79, addendum 6)
//
// claudeCloud_alt_periodic.cpp lists the columns b (time period N) that stand beside the alternating column in a
// pattern periodic in time and space: for N up to 24 they are the columns of four rings, whose gates are the loops
// 2, 3, 5 and 2,5. This program takes every OTHER column b and extends the strip (alternating, b) to the right one
// column at a time, keeping every column of time period N. Rule 30 gives, for neighbours (a, b), the next column c
// by   (b or c) = a xor b shifted one tick,   so c exists only if b is black nowhere that word is white, and then c
// is free exactly where b is black. A strip is followed as its last pair of columns; equal pairs are merged.
//
// Since two neighbouring columns determine everything to their left, a strip that starts at a column outside the
// four rings can never join a ring, and (the rings being all the doubly periodic patterns) it cannot go on for
// ever. The program finds the width at which the last of them stops:
//
//     if columns 1 .. W of a right half beside the alternating column all have time period N, and W is at least
//     the width printed, then column 1 is a column of one of the four rings, and the gate is a loop.
//
//   g++ -O3 -std=c++17 claudeCloud_alt_strips.cpp -o alt_strips
//   alt_strips N CENSUS.txt         CENSUS.txt = the output of alt_periodic (the ring columns for this N are read
//                                   from its lines `N <N> column <bits> ...`)
// Output: per width, the number of strips (last pairs) that started outside the rings and the gap words of their
// gates; then the least width at which none is left.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <set>
#include <sstream>
#include <string>
#include <vector>
using namespace std;
typedef uint64_t u64;

static int N; static u64 MASK;
static inline u64 ror1(u64 a) { return ((a >> 1) | (a << (N - 1))) & MASK; }

static string gapWord(u64 b) {                     // the gate (even ticks) as a least rotation of its primitive gap word
    vector<int> ks; int n = N / 2;
    for (int s = 0; s < n; ++s) if ((b >> (2 * s)) & 1) ks.push_back(s);
    if (ks.empty()) return "-";
    string w;
    for (size_t i = 0; i < ks.size(); ++i) { int g = ((ks[(i + 1) % ks.size()] - ks[i] - 1) % n + n) % n + 1; w += (g < 10 ? char('0' + g) : '+'); }
    for (size_t d = 1; d <= w.size(); ++d) if (w.size() % d == 0) {
        bool ok = true; for (size_t i = d; i < w.size() && ok; ++i) ok = w[i] == w[i - d];
        if (ok) { w = w.substr(0, d); break; }
    }
    string best = w;
    for (size_t i = 1; i < w.size(); ++i) { string r = w.substr(i) + w.substr(0, i); if (r < best) best = r; }
    return best;
}

int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "usage: alt_strips N CENSUS.txt\n"); return 1; }
    N = atoi(argv[1]);
    if (N < 2 || N > 30 || (N & 1)) { fprintf(stderr, "N must be even, 2..30\n"); return 1; }
    MASK = (1ULL << N) - 1;
    u64 ALT = 0; for (int t = 1; t < N; t += 2) ALT |= 1ULL << t;
    set<u64> ring;
    { ifstream in(argv[2]); string line;
      while (getline(in, line)) { istringstream ss(line); string a, b, c, bits; int n;
          if (!(ss >> a >> n >> c >> bits) || a != "N" || c != "column" || n != N) continue;
          u64 v = 0; for (int t = 0; t < N; ++t) if (bits[t] == '1') v |= 1ULL << t; ring.insert(v); } }
    // width 1: every column outside the rings. A strip of width W is kept as (first column, last pair); to bound
    // memory only the last pair and the gate's gap word class of the first column are kept: one frontier per word.
    // Here the first columns are grouped by gap word, and each group is run on its own.
    vector<u64> starts;
    for (u64 b = 0; b <= MASK; ++b) if (!ring.count(b) && ((b & ~(ALT ^ ror1(b)) & MASK) == 0)) starts.push_back(b);
    printf("N %d: %zu ring columns; %zu other columns can take a second column\n", N, ring.size(), starts.size());
    // group by gap word
    vector<pair<string, u64>> tagged; tagged.reserve(starts.size());
    for (u64 b : starts) tagged.push_back({gapWord(b), b});
    sort(tagged.begin(), tagged.end());
    int overall = 1; string lastWord; int lastWidth = 0;
    size_t i = 0;
    while (i < tagged.size()) {
        size_t j = i; while (j < tagged.size() && tagged[j].first == tagged[i].first) ++j;
        vector<u64> frontier;                                      // pairs (a, b) packed as a << N | b
        for (size_t k = i; k < j; ++k) frontier.push_back((ALT << N) | tagged[k].second);
        int W = 1; size_t peak = frontier.size();
        while (!frontier.empty()) {
            vector<u64> next;
            for (u64 key : frontier) {
                u64 a = key >> N, b = key & MASK, m = a ^ ror1(b);
                if (b & ~m & MASK) continue;
                u64 base = m & ~b & MASK, sub = b;
                while (true) { next.push_back((b << N) | base | sub); if (sub == 0) break; sub = (sub - 1) & b; }
            }
            sort(next.begin(), next.end()); next.erase(unique(next.begin(), next.end()), next.end());
            frontier.swap(next); ++W; peak = max(peak, frontier.size());
            if (W > 4000) { fprintf(stderr, "a strip outside the rings is still alive at width 4000\n"); return 2; }
        }
        // W is the first width that no strip of this group reaches
        printf("  gate %-10s %6zu first columns: none reaches width %d (most strips at one width %zu)\n",
               tagged[i].first.c_str(), j - i, W, peak);
        if (W > overall) { overall = W; lastWord = tagged[i].first; lastWidth = W; }
        i = j;
    }
    printf("N %d: every strip of %d columns of time period %d beside the alternating column starts at a ring column"
           " (the last other gate to stop: %s)\n", N, overall, N, lastWord.c_str());
    (void)lastWidth;
    return 0;
}
