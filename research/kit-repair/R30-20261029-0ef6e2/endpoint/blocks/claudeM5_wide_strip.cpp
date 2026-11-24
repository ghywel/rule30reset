// Which gate words can a right half of Rule 30 read beside an alternating column? (claudeM5, M177)
//
//   clang++ -O3 -std=c++20 -o wide claudeM5_wide_strip.cpp;  ./wide WORDFILE WMAX DWELL CAP
//
// WORDFILE holds 0s and 1s: the first cell at consecutive white ticks, starting at a kick. The program keeps the set of
// all rows of W cells compatible with the word so far, with both eastern inputs of each pair of ticks free, so the set
// contains the first W cells of every right half that reads the word. It runs DWELL samples at each width, then adds one
// cell with both values and goes on from the same sample. An empty set means that no right half, finite or infinite,
// reads the word up to that sample. A set that is never empty is finite evidence only.
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>
using namespace std;
typedef uint64_t u;
static inline u st(u x, u d) { return ((x << 1) | d) ^ (x | (x >> 1)); }  // one tick, centre colour d

int main(int c, char** v) {
  if (c < 5) return 2;
  ifstream f(v[1]);
  string s((istreambuf_iterator<char>(f)), {});
  vector<int> w;
  for (char ch : s) if (ch == '0' || ch == '1') w.push_back(ch - '0');
  int Wmax = atoi(v[2]), per = atoi(v[3]), W = 12;
  size_t cap = strtoull(v[4], 0, 10), t = 0;
  vector<u> S;
  for (u x = 0; x < (1ull << W); ++x) if ((x & 1) == (u)w[0]) S.push_back(x);
  while (1) {
    u mask = (1ull << W) - 1;
    size_t t1 = t + per, mx = 0;
    bool dead = false;
    for (; t < t1 && t + 1 < w.size(); ++t) {
      vector<u> N;
      N.reserve(S.size() * 2);
      for (u x : S) for (u e = 0; e < 4; ++e) {        // two cells beyond the window, free
        u z = st(st(x | (e << W), 0), 1) & mask;       // a white tick, then a black one
        if ((z & 1) == (u)w[t + 1]) N.push_back(z);
      }
      sort(N.begin(), N.end());
      N.erase(unique(N.begin(), N.end()), N.end());
      S.swap(N);
      mx = max(mx, S.size());
      if (S.empty()) { dead = true; break; }
      if (S.size() > cap) { printf("width %d cap at sample %zu: %zu states\n", W, t, S.size()); return 0; }
    }
    printf("width %d sample %zu states %zu (max %zu)%s\n", W, t, S.size(), mx, dead ? " DEAD" : "");
    fflush(stdout);
    if (dead || W >= Wmax || t + 1 >= w.size()) return 0;
    vector<u> E;
    E.reserve(S.size() * 2);
    for (u x : S) { E.push_back(x); E.push_back(x | (1ull << W)); }
    sort(E.begin(), E.end());
    S.swap(E);
    ++W;
  }
}
