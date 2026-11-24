// Independent replay on ONE indexed ordinary graph. No smaller-width graph or
// previously computed pair is used. Input format is I81's convert.py output.
#include <algorithm>
#include <array>
#include <bit>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

using Edges = std::array<std::vector<int>, 4>;
using Graph = std::vector<Edges>;
using Pair = std::pair<int, int>;

struct Graphs {
  Graph next, prev;
  std::vector<uint32_t> rows;
  explicit Graphs(int n) : next(n), prev(n), rows(n) {}
  void edge(int u, int a, int v) {
    next[u][a].push_back(v);
    prev[v][a].push_back(u);
  }
};

int read_int(std::ifstream &in) {
  int32_t value;
  if (!in.read(reinterpret_cast<char *>(&value), 4))
    throw std::runtime_error("short graph file");
  return value;
}

Graphs read_graph(const char *path, const std::array<int, 4> &letters) {
  std::ifstream in(path, std::ios::binary);
  int n = read_int(in);
  if (n <= 0) throw std::runtime_error("invalid row count");
  Graphs graph(n);
  for (auto &row : graph.rows) row = read_int(in);
  for (int u = 0; u < n; ++u) {
    for (int q = 9; q <= 16; ++q) {
      int count = read_int(in);
      if (count < 0) throw std::runtime_error("invalid edge count");
      auto a = std::find(letters.begin(), letters.end(), q);
      for (int i = 0; i < count; ++i) {
        int v = read_int(in);
        if (v < 0 || v >= n) throw std::runtime_error("invalid endpoint");
        if (a != letters.end()) graph.edge(u, int(a - letters.begin()), v);
      }
    }
  }
  if (in.peek() != EOF) throw std::runtime_error("extra graph data");
  return graph;
}

// Kosaraju's two passes. The first stack uses a negative number as a finish
// event, allowing vertices to finish only after their descendants.
std::vector<std::vector<int>> components(const Graphs &g) {
  std::vector<bool> seen(g.rows.size());
  std::vector<int> order, stack;
  for (int root = 0; root < int(seen.size()); ++root) {
    if (seen[root]) continue;
    stack.push_back(root);
    while (!stack.empty()) {
      int x = stack.back();
      stack.pop_back();
      if (x < 0) { order.push_back(~x); continue; }
      if (seen[x]) continue;
      seen[x] = true;
      stack.push_back(~x);
      for (const auto &bucket : g.next[x])
        for (int y : bucket) if (!seen[y]) stack.push_back(y);
    }
  }
  std::fill(seen.begin(), seen.end(), false);
  std::vector<std::vector<int>> result;
  for (auto it = order.rbegin(); it != order.rend(); ++it) {
    if (seen[*it]) continue;
    auto &part = result.emplace_back();
    stack.push_back(*it);
    seen[*it] = true;
    while (!stack.empty()) {
      int x = stack.back();
      stack.pop_back();
      part.push_back(x);
      for (const auto &bucket : g.prev[x]) for (int y : bucket) {
        if (!seen[y]) { seen[y] = true; stack.push_back(y); }
      }
    }
  }
  return result;
}

// The first cell after two updates sees left inputs black, then white.
// Compute the relevant two cells at the intermediate tick directly.
bool second_white(uint32_t row) {
  bool first = row & 1, second = row & 2, third = row & 4;
  bool a = true ^ (first || second);
  bool b = first ^ (second || third);
  return a || b;
}

struct Triangle {
  std::vector<uint64_t> bits;
  uint64_t count = 0;
  explicit Triangle(uint64_t n) : bits((n * (n + 1) / 2 + 63) / 64) {}
  static uint64_t key(int u, int v) {
    if (u > v) std::swap(u, v);
    return uint64_t(v) * (v + 1) / 2 + u;
  }
  bool has(uint64_t k) const { return (bits[k / 64] >> (k % 64)) & 1; }
  void put(uint64_t k) { bits[k / 64] |= uint64_t(1) << (k % 64); ++count; }
};

Triangle flood(const Graph &g, const Triangle *permitted, const std::vector<uint32_t> &rows,
               std::vector<Pair> &differences) {
  Triangle visited(g.size());
  std::vector<Pair> pending;
  auto admit = [&](int x, int y) {
    uint64_t k = Triangle::key(x, y);
    if (visited.has(k) || (permitted && !permitted->has(k))) return;
    visited.put(k);
    pending.emplace_back(x, y);
    if (permitted && second_white(rows[x]) != second_white(rows[y]))
      differences.emplace_back(x, y);
  };
  for (int x = 0; x < int(g.size()); ++x) admit(x, x);
  while (!pending.empty()) {
    auto [x, y] = pending.back();
    pending.pop_back();
    for (int a = 0; a < 4; ++a)
      for (int u : g[x][a]) for (int v : g[y][a]) admit(u, v);
  }
  return visited;
}

using Word = std::array<int, 7>;
void signatures(const Graphs &g, const Triangle &live, Pair centre, Pair at, int depth,
                const std::array<int, 4> &letters, Word &word, std::set<Word> &found) {
  if (depth == 7) { found.insert(word); return; }
  if (depth == 5) at = centre;
  const Graph &dir = depth < 5 ? g.prev : g.next;
  for (int a = 0; a < 4; ++a) {
    word[depth < 5 ? 4 - depth : depth] = letters[a];
    for (int u : dir[at.first][a]) for (int v : dir[at.second][a]) {
      if (live.has(Triangle::key(u, v)))
        signatures(g, live, centre, {u, v}, depth + 1, letters, word, found);
    }
  }
}

int main(int argc, char **argv) {
  if (argc != 3 || std::endian::native != std::endian::little) {
    std::cerr << "usage on little-endian hosts: check-disagreement-context G.bin 13|14\n";
    return 2;
  }
  int special = std::stoi(argv[2]);
  if (special != 13 && special != 14) return 2;
  std::array<int, 4> letters{9, 10, 12, special};
  auto full = read_graph(argv[1], letters);
  auto parts = components(full);
  std::vector<int> index(full.rows.size(), -1);
  uint64_t row_count = 0, live_count = 0, difference_count = 0;
  std::set<Word> found;
  for (const auto &part : parts) {
    int colors = 0, labels = 0;
    for (int i = 0; i < int(part.size()); ++i) {
      index[part[i]] = i;
      colors |= 1 << second_white(full.rows[part[i]]);
    }
    for (int u : part) for (int a = 0; a < 2; ++a)
      for (int v : full.next[u][a]) if (index[v] >= 0) labels |= 1 << a;
    if (colors == 3 && labels == 3) {
      Graphs g(part.size());
      for (int u : part) {
        g.rows[index[u]] = full.rows[u];
        for (int a = 0; a < 4; ++a) for (int v : full.next[u][a])
          if (index[v] >= 0) g.edge(index[u], a, index[v]);
      }
      std::vector<Pair> differences;
      auto starts = flood(g.next, nullptr, g.rows, differences);
      auto live = flood(g.prev, &starts, g.rows, differences);
      for (auto pair : differences) {
        Word word{};
        signatures(g, live, pair, pair, 0, letters, word, found);
      }
      row_count += part.size();
      live_count += live.count;
      difference_count += differences.size();
    }
    for (int u : part) index[u] = -1;
  }
  std::cout << "special " << special << " rows " << row_count << " common_pairs "
            << live_count << " differences " << difference_count << '\n';
  for (auto &word : found) {
    for (int i = 0; i < 7; ++i)
      std::cout << (i == 5 ? " | " : i ? " " : "") << word[i];
    std::cout << '\n';
  }
}
