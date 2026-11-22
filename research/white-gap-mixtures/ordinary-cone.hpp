// Single-gap ordinary Rule 30 endpoint relation. Included by
// sparse-language.cpp.
#include <cstdint>
#include <memory>
using Bits = array<uint64_t, 4>;
using FirstTable = array<Bits, 512>;
struct Class {
  int high;
  Bits tail;
};
using LastTable = array<vector<Class>, 8>;
uint64_t step64(uint64_t x, bool drive = false) {
  return ((x << 1) | uint64_t(drive)) ^ (x | (x >> 1));
}
bool overlap(const Bits &a, const Bits &b) {
  return ((a[0] & b[0]) | (a[1] & b[1]) | (a[2] & b[2]) | (a[3] & b[3])) != 0;
}
// Inputs are nine known cells to the left, and 9+8 initially free cells to the
// right. For each first nine free cells, record possible eight-cell right
// fringes at tick nine.
const FirstTable &firstNineTicks(int context) {
  static array<unique_ptr<FirstTable>, 512> tables;
  auto &ptr = tables[context];
  if (ptr)
    return *ptr;
  ptr = make_unique<FirstTable>();
  for (int e = 0; e < 512; e++) {
    for (int u = 0; u < 256; u++) {
      uint64_t x = context | (e << 9) | (u << 18);
      for (int t = 0; t < 9; t++)
        x = step64(x);
      int y = (x >> 9) & 255;
      (*ptr)[e][y / 64] |= uint64_t(1) << (y % 64);
    }
  }
  return *ptr;
}
// At tick nine, the final s high bits (s=1..8) depend solely on the top 2s core
// bits and first s fringe bits. Classify all 256 fringe assignments by those
// outputs.
unique_ptr<LastTable> remainingTicks(int context, int width) {
  auto table = make_unique<LastTable>();
  for (int s = 1; s <= 8; s++) {
    array<Bits, 256> pre{};
    for (int y = 0; y < 256; y++) {
      uint64_t x = (uint64_t(y) << width) | context;
      for (int t = 0; t < s; t++)
        x = step64(x);
      int c = (x >> (width - s)) & ((1 << s) - 1);
      pre[c][y / 64] |= uint64_t(1) << (y % 64);
    }
    for (int c = 0; c < (1 << s); c++)
      if (pre[c] != Bits{})
        (*table)[s - 1].push_back({c, pre[c]});
  }
  return table;
}
vector<Edges> buildOrdinary(const Word &rows, int w) {
  unordered_map<int, int> index;
  for (int i = 0; i < (int)rows.size(); i++)
    index.emplace(rows[i], i);
  vector<Edges> graph(rows.size());
  const int mask = (1 << w) - 1, width = min(16, w);
  vector<unique_ptr<LastTable>> cache(1 << width);
  // Keep a separate epoch timestamp per gap for endpoint deduplication.
  vector<array<int, 8>> mark(rows.size());
  for (int i = 0; i < (int)rows.size(); i++) {
    int x = rows[i];
    // At width eight, the black drive bit is the ninth known left input.
    int context = w >= 9 ? (x >> (w - 9)) : ((x << 1) | 1);
    const auto &fringe = firstNineTicks(context);
    // Merge initial choices that produce the same midpoint core, retaining
    // their union of feasible fringes. The second half must use a fringe in
    // that union.
    array<Bits, 512> allowed{};
    Word active;
    uint64_t bulk = x;
    for (int t = 0; t < 9; t++)
      bulk = step64(bulk, t == 0);
    int low = int(bulk) & ((1 << (max(w - 9, 0))) - 1);
    for (int e = 0; e < 512; e++) {
      uint64_t r = (uint64_t(e) << w) | x;
      for (int t = 0; t < 9; t++)
        r = step64(r, t == 0);
      int high = (int(r) & mask) >> max(w - 9, 0);
      if (allowed[high] == Bits{})
        active.push_back(high);
      for (int j = 0; j < 4; j++)
        allowed[high][j] |= fringe[e][j];
    }
    for (int high : active) {
      int mid = (high << max(w - 9, 0)) | low;
      int key = mid >> (w - width);
      if (!cache[key])
        cache[key] = remainingTicks(key, width);
      uint64_t r = mid;
      for (int s = 1; s <= 8; s++) {
        r = step64(r);
        int base = int(r) & ((1 << (w - s)) - 1);
        for (const auto &entry : (*cache[key])[s - 1]) {
          if (!overlap(entry.tail, allowed[high]))
            continue;
          auto it = index.find(base | (entry.high << (w - s)));
          if (it != index.end() && mark[it->second][s - 1] != i + 1) {
            mark[it->second][s - 1] = i + 1;
            graph[i][s - 1].push_back(it->second);
          }
        }
      }
    }
  }
  return graph;
}
