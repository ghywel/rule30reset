// Compute the pulse-gap language of a Rule 30 strip with a varying second-white observation.
#include <algorithm>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <functional>
#include <map>
#include <numeric>
#include <string>
#include <unordered_map>
#include <vector>
using namespace std;
using Word = vector<int>;
using Edges = array<Word, 8>;
struct Hash {
  size_t operator()(const Word &v) const {
    size_t h = 123457;
    for (int x : v)
      h = (h ^ size_t(x + 1)) * 1099511628211ULL;
    return h;
  }
};
// Actual first neighbor two ticks after the drive pulse.
int observed(int x) { return !(x & 1) || !(x & 6); }
int evolve(int x, int d, int boundary, int w) {
  int top = 1 << (w - 1);
  return (((x << 1) | d) ^ (x | (x >> 1) | (boundary * top))) &
         ((top << 1) - 1);
}
vector<Edges> build(const Word &rows, int w) {
  unordered_map<int, int> index;
  for (int i = 0; i < (int)rows.size(); i++)
    index.emplace(rows[i], i);
  vector<Edges> graph(rows.size());
  Word reach, next;
  for (int i = 0; i < (int)rows.size(); i++) {
    reach.assign(1, rows[i]);
    for (int t = 0; t <= 16; t++) {
      next.clear();
      for (int x : reach)
        for (int b = 0; b < 2; b++)
          next.push_back(evolve(x, t == 0, b, w));
      sort(next.begin(), next.end());
      next.erase(unique(next.begin(), next.end()), next.end());
      reach.swap(next);
      if (t >= 9)
        for (int y : reach) {
          auto it = index.find(y);
          if (it != index.end())
            graph[i][t - 9].push_back(it->second);
        }
    }
  }
  return graph;
}
#include "ordinary-cone.hpp"

Word mixed(const Word &rows, const vector<Edges> &g, int &mixedCount) {
  int n = rows.size();
  Word order(n, -1), low(n), comp(n, -1), stack, active(n), color;
  int counter = 0;
  function<void(int)> visit = [&](int x) {
    order[x] = low[x] = counter++;
    stack.push_back(x);
    active[x] = 1;
    for (const auto &e : g[x])
      for (int y : e) {
        if (order[y] < 0) {
          visit(y);
          low[x] = min(low[x], low[y]);
        } else if (active[y])
          low[x] = min(low[x], order[y]);
      }
    if (order[x] == low[x]) {
      int mask = 0;
      for (;;) {
        int y = stack.back();
        stack.pop_back();
        active[y] = 0;
        comp[y] = color.size();
        mask |= 1 << observed(rows[y]);
        if (y == x)
          break;
      }
      color.push_back(mask);
    }
  };
  for (int i = 0; i < n; i++)
    if (order[i] < 0)
      visit(i);
  mixedCount = count(color.begin(), color.end(), 3);
  for (int &c : comp)
    if (color[c] != 3)
      c = -1;
  return comp;
}
// Count each input word once, independently of its number of realizing paths.
void determinize(const vector<Edges> &g, int w) {
  using State = array<int, 8>;
  vector<State> tr;
  unordered_map<Word, int, Hash> ids;
  vector<Word> subsets(1);
  subsets[0].resize(g.size());
  iota(subsets[0].begin(), subsets[0].end(), 0);
  ids[subsets[0]] = 0;
  Word mark(g.size(), -1);
  int serial = 0;
  for (int q = 0; q < (int)subsets.size(); q++) {
    State r{};
    for (int a = 0; a < 8; a++) {
      Word n;
      serial++;
      for (int x : subsets[q])
        for (int y : g[x][a])
          if (mark[y] != serial) {
            mark[y] = serial;
            n.push_back(y);
          }
      sort(n.begin(), n.end());
      auto [it, fresh] = ids.emplace(n, subsets.size());
      r[a] = it->second;
      if (fresh)
        subsets.push_back(move(n));
    }
    tr.push_back(r);
  }
  const int dead = ids.at(Word{});
  Word c(tr.size()), newC;
  c[dead] = 1;
  int classes = 2;
  for (;;) {
    map<array<int, 9>, int> groups;
    newC.clear();
    for (int i = 0; i < (int)tr.size(); i++) {
      array<int, 9> key;
      key[0] = c[i];
      for (int a = 0; a < 8; a++)
        key[a + 1] = c[tr[i][a]];
      newC.push_back(groups.emplace(key, groups.size()).first->second);
    }
    c.swap(newC);
    if (classes == (int)groups.size())
      break;
    classes = groups.size();
  }
  vector<State> mini(classes);
  for (int i = 0; i < (int)tr.size(); i++)
    for (int a = 0; a < 8; a++)
      mini[c[i]][a] = c[tr[i][a]];
  ofstream out("observer-" + to_string(w) + ".txt");
  out << classes << " " << c[0] << " " << c[dead] << "\n";
  for (const auto &r : mini) {
    for (int j : r)
      out << j << " ";
    out << "\n";
  }
  printf(" K=%d subsets=%zu minimal=%d\n", w, tr.size(), classes);
  fflush(stdout);
}
int main(int argc, char **argv) {
  int limit = argc > 1 ? atoi(argv[1]) : 19;
  bool ordinary = argc == 3 && string(argv[2]) == "--ordinary";
  if (argc > 3 || (argc == 3 && !ordinary) || limit < 8 || limit > 28)
    return 2;
  Word rows(256);
  iota(rows.begin(), rows.end(), 0);
  for (int w = 8; w <= limit; w++) {
    auto g = ordinary ? buildOrdinary(rows, w) : build(rows, w);
    int count = 0;
    Word comp = mixed(rows, g, count), idx(rows.size(), -1), surv;
    for (int i = 0; i < (int)rows.size(); i++)
      if (comp[i] >= 0) {
        idx[i] = surv.size();
        surv.push_back(rows[i]);
      }
    vector<Edges> inside(surv.size());
    for (int i = 0; i < (int)g.size(); i++)
      if (idx[i] >= 0)
        for (int a = 0; a < 8; a++)
          for (int y : g[i][a])
            if (comp[i] == comp[y])
              inside[idx[i]][a].push_back(idx[y]);
    printf("width=%d tested=%zu mixed=%d rows=%zu", w, rows.size(), count,
           surv.size());
    fflush(stdout);
    if (!count)
      return 0;
    determinize(inside, w);
    // Both lifts of each mixed row are possible candidates at the next width.
    rows = surv;
    for (int x : surv)
      rows.push_back(x + (1 << w));
  }
}
