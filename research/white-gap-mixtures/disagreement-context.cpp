// All gap orders on one four-letter support. Use the I82 ordinary graph and
// synchronized pair routines (see the reproduction instructions in the report).
#include "i82-pair-routines.hpp"
#include <limits>
#include <map>
#include <set>
#include <stdexcept>

Data read_indexed(const string &file) {
  ifstream stream(file, ios::binary);
  auto integer = [&]() {
    int value;
    if (!stream.read(reinterpret_cast<char *>(&value), sizeof(value)))
      throw runtime_error("truncated indexed graph");
    return value;
  };
  Data graph;
  int n = integer();
  if (n <= 0) throw runtime_error("empty indexed graph");
  for (int i = 0; i < n; ++i) graph.row.push_back(integer());
  graph.g.resize(n);
  for (auto &edges : graph.g) for (auto &bucket : edges) {
    int count = integer();
    if (count < 0) throw runtime_error("negative edge count");
    for (int i = 0; i < count; ++i) {
      int dest = integer();
      if (dest < 0 || dest >= n) throw runtime_error("bad destination");
      bucket.push_back(dest);
    }
  }
  if (stream.peek() != EOF) throw runtime_error("trailing data");
  return graph;
}

// Projection can add paths. Use these smaller products only to prune a final
// calculation on the original, unprojected graph.
Data project(const Data &full, int width, int letters) {
  Data small;
  V image;
  unordered_map<int,int> ids;
  const int mask = (1 << width) - 1;
  for (int row : full.row) {
    int prefix = row & mask;
    auto [pos, inserted] = ids.emplace(prefix, small.row.size());
    if (inserted) small.row.push_back(prefix);
    image.push_back(pos->second);
  }
  small.g.resize(small.row.size());
  for (size_t x = 0; x < full.row.size(); ++x)
    for (int a = 0; a < 8; ++a) if (letters & (1 << a))
      for (int y : full.g[x][a]) small.g[image[x]][a].push_back(image[y]);
  for (auto &edges : small.g) for (auto &bucket : edges) {
    sort(bucket.begin(), bucket.end());
    bucket.erase(unique(bucket.begin(), bucket.end()), bucket.end());
  }
  return small;
}

struct Context {
  const Pairs &pairs;
  const vector<unsigned char> &live;
  const G &edges;
  int special;
  // An edge of the synchronized product must use the same gap on both lanes.
  template<class Fn> void visit(int x, int y, bool common_only, Fn fn) const {
    for (int a = 0; a < 8; ++a) {
      if (common_only && a + 9 == special) continue;
      for (int u : edges[x][a]) for (int v : edges[y][a]) {
        int id = pairs.locate(u, v);
        if (id >= 0 && live[id]) fn(min(u,v), max(u,v), a+9);
      }
    }
  }
  // Longest common-letter path; any reachable directed cycle permits all lengths.
  static constexpr int infinity = numeric_limits<int>::max();
  unordered_map<Key,int> depth;
  int horizon(int x, int y) {
    Key key = pk(x,y);
    auto pos = depth.find(key);
    if (pos != depth.end()) return pos->second == -1 ? infinity : pos->second;
    depth[key] = -1;
    int best = 0;
    visit(x, y, true, [&](int u,int v,int) {
      if (best == infinity) return;
      int rest = horizon(u,v);
      best = rest == infinity ? infinity : max(best,1+rest);
    });
    depth[key] = best;
    return best;
  }
  void words(int x,int y,int n,vector<int> &path,set<vector<int>> &out) const {
    if (!n) {out.insert(path); return;}
    visit(x,y,false,[&](int u,int v,int gap) {
      path.push_back(gap);
      words(u,v,n-1,path,out);
      path.pop_back();
    });
  }
};

int main(int argc,char **argv) {
  if (argc != 5) {
    cerr << "usage: disagreement-context ARCHIVE_GRAPHS G27.bin WIDTH SPECIAL_GAP\n";
    return 2;
  }
  string dir = argv[1];
  int width = stoi(argv[3]), special = stoi(argv[4]);
  if ((width != 22 && width != 27) || (special != 13 && special != 14)) return 2;
  int letters = 11 | (1 << (special-9));
  Data full;
  if (width == 27) full = read_indexed(argv[2]);
  vector<Key> previous;
  for (int w = 8; w <= width; ++w) {
    Data input = w <= 22 ? readcore(dir+"/core-"+to_string(w)+".bin") : project(full,w,letters);
    Compact graph = compact(input,letters);
    Pairs pairs = makepairs(graph,previous,w);
    auto forward = reach(graph,pairs,false);
    auto live = reach(graph,pairs,true,&forward);
    previous.clear();
    vector<pair<int,int>> differences;
    for (int x = 0; x < (int)graph.raw.size(); ++x)
      for (int j=pairs.offsets[x]; j<pairs.offsets[x+1]; ++j) if (live[j]) {
        int y=pairs.values[j];
        previous.push_back(pk(graph.raw[x],graph.raw[y]));
        if (color(graph.raw[x]) != color(graph.raw[y])) differences.emplace_back(x,y);
      }
    if (w != width) continue;
    Context past{pairs,live,graph.r,special,{}}, future{pairs,live,graph.g,special,{}};
    map<pair<int,int>,int> horizons;
    set<pair<vector<int>,vector<int>>> contexts;
    for (auto [x,y] : differences) {
      ++horizons[{past.horizon(x,y),future.horizon(x,y)}];
      set<vector<int>> before, after;
      vector<int> path;
      past.words(x,y,4,path,before);
      future.words(x,y,2,path,after);
      for (auto left : before) {
        reverse(left.begin(),left.end());
        for (const auto &right : after) contexts.emplace(left,right);
      }
    }
    cout << "width " << w << " special " << special << " rows " << graph.raw.size()
         << " common_pairs " << previous.size() << " differences " << differences.size() << '\n';
    auto format = [](int n){return n == Context::infinity ? "inf" : to_string(n);};
    for (auto [range,count] : horizons)
      cout << "horizon " << format(range.first) << ' ' << format(range.second) << ' ' << count << '\n';
    for (auto &[left,right] : contexts) {
      cout << "context"; for (int a : left) cout << ' ' << a;
      cout << " |"; for (int a : right) cout << ' ' << a;
      cout << '\n';
    }
  }
}
