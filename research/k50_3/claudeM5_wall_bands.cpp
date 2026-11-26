// claudeM5_wall_bands.cpp: Hughes's good bands beside a driven wall, for every narrow row (K50.3, K63's open form, M196).
//
//   c++ -O2 -std=c++17 -o wall_bands claudeM5_wall_bands.cpp && ./wall_bands
//
// A row of n cells, 0..n-1, black at 0, white to its left, with a prescribed wall value w(s) as the right neighbour of
// cell n-1 at tick s. Rule 30: c'(q) = c(q-1) xor (c(q) or c(q+1)). At age s the row is the n+s cells from the edge -s.
// For a band width W (8 or 20) the W cells from the edge evolve by the band map R once the row is W cells wide, which
// is at age W-n; then the band is the whole row, a function of the row and the wall values at ticks 0..W-n-1.
// G = R^A(every black-leading W-bit word), A = 8 for W = 8 and A = 24 for W = 20: Hughes's good bands.
// For each n < W the program takes every row and every wall prefix, computes the band at age W-n, and checks that
// R^(a-(W-n)) of it is in G at the age a = A (and A+1), counting the failures. Rows of W cells or more meet no wall.
#include <cstdint>
#include <cstdio>
#include <set>
#include <vector>

static uint32_t Rmap(uint32_t u, int W) {   // bit W-1 is the edge cell; next band from one cell further left
  // cells: c[j] = bit (W-1-j), j = 0..W-1 (j = 0 the edge). Next band d[j] at position f-1+j:
  // d[0] = 0 xor (0 or c[0]) = c[0]; d[j] = c[j-2] xor (c[j-1] or c[j]) with c[-1] = 0.
  auto c = [&](int j) -> uint32_t { return (j < 0 || j >= W) ? 0u : (u >> (W - 1 - j)) & 1u; };
  uint32_t v = 0;
  for (int j = 0; j < W; ++j) {
    uint32_t d = (j == 0) ? c(0) : (c(j - 2) ^ (c(j - 1) | c(j)));
    v |= d << (W - 1 - j);
  }
  return v;
}

int main() {
  for (int W : {8, 20}) {
    int A = (W == 8) ? 8 : 24;
    std::vector<uint32_t> R(1u << W);
    for (uint32_t u = 0; u < (1u << W); ++u) R[u] = Rmap(u, W);
    std::set<uint32_t> G;
    for (uint32_t u = 1u << (W - 1); u < (1u << W); ++u) {
      uint32_t v = u;
      for (int t = 0; t < A; ++t) v = R[v];
      G.insert(v);
    }
    bool closed = true;
    for (uint32_t g : G) closed = closed && G.count(R[g]);
    printf("W=%d A=%d good bands:", W, A);
    for (uint32_t g : G) printf(" %u", g);
    printf("  closed under R: %s\n", closed ? "yes" : "no");
    for (int n = 1; n < W; ++n) {
      int ticks = W - n;                       // wall ticks that reach the band, and the age the row is W wide
      uint64_t pairs = 0, badA = 0, badA1 = 0;
      for (uint64_t tail = 0; tail < (1ull << (n - 1)); ++tail) {
        for (uint64_t pre = 0; pre < (1ull << ticks); ++pre) {
          ++pairs;
          // x bit k = cell at position k - s (k = 0 the edge), n + s cells
          uint64_t x = 1ull;                     // cell 0 black
          for (int q = 1; q < n; ++q) x |= ((tail >> (q - 1)) & 1ull) << q;
          for (int s = 0; s < ticks; ++s) {
            uint64_t xt = x | (((pre >> s) & 1ull) << (n + s));   // the wall at position n
            uint64_t y = (xt << 2) ^ ((xt << 1) | xt);
            y &= (1ull << (n + s + 1)) - 1;                        // positions -s-1 .. n-1
            x = y;
          }
          // band: the W cells, edge first = most significant
          uint32_t u = 0;
          for (int j = 0; j < W; ++j) u |= (uint32_t)((x >> j) & 1ull) << (W - 1 - j);
          uint32_t v = u;
          for (int t = ticks; t < A; ++t) v = R[v];
          if (!G.count(v)) ++badA;
          if (!G.count(R[v])) ++badA1;
        }
      }
      printf("  n=%2d pairs %8llu  bad at age %d: %6llu  at age %d: %llu\n", n, (unsigned long long)pairs, A,
             (unsigned long long)badA, A + 1, (unsigned long long)badA1);
    }
  }
  return 0;
}
