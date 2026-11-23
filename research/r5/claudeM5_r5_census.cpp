// claudeM5_r5_census.cpp: pull R5, third block (ledger M136). Every wall of w cells for a drive whose labels count mod L,
// and every column of small period that its leftward chain holds.
//
// A drive is a word s of length L, read as a column; the half-line beyond it has windows of w cells, the cell beyond free
// at every tick. A WALL is a closed strongly connected set of (label, window) on which the first cell is one value at each
// white label of s. Column by column to the left everything is then determined: left(t) = u(t+1) xor (u(t) or v(t)), so a
// wall fixes the columns of a whole chain, until the pair of adjacent columns repeats. A column of the chain that repeats
// a short word is a TRAP for that word, of (distance + w) cells, with labels mod L.
//
//   census L W FROM TO MAXCHAIN OUT   all necklaces of length L (binary, least rotation) with index in [FROM, TO) of 2^L words;
//                                     non-primitive words too, so labels mod L of a shorter word are covered
// Output lines:  W  word  values(at the white labels, '-' at black)  size  chain  cycle
//                T  word  values  distance  small-word  gate(the next column's values at its white labels)
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <vector>
#include <string>
#include <unordered_map>
using namespace std; typedef uint32_t u32; typedef uint64_t u64;
static int L, w; static vector<u32> ST[2][2];
static string bits(u32 x, int n) { string s; for (int i = 0; i < n; i++) s += ((x >> i) & 1) ? '1' : '0'; return s; }
static int leastPeriod(u32 x) { for (int p = 1; p <= L; p++) if (L % p == 0) { bool ok = true; for (int t = 0; t < L && ok; t++) ok = ((x >> t) & 1) == ((x >> ((t + p) % L)) & 1); if (ok) return p; } return L; }
static inline u32 rotl1(u32 x) { return (x >> 1) | ((x & 1) << (L - 1)); } // x(t+1)
int main(int ac, char **av) {
  if (ac < 7) { fprintf(stderr, "usage: census L W FROM TO MAXCHAIN OUT\n"); return 2; }
  L = atoi(av[1]); w = atoi(av[2]); u64 from = strtoull(av[3], 0, 10), to = strtoull(av[4], 0, 10); long maxc = atol(av[5]); FILE *o = fopen(av[6], "w");
  u32 N = 1u << w, full = (L == 32) ? 0xffffffffu : ((1u << L) - 1);
  for (int c = 0; c < 2; c++) for (int z = 0; z < 2; z++) { ST[c][z].resize(N); for (u32 r = 0; r < N; r++) { u64 f = ((u64)r << 1) | c | ((u64)z << (w + 1)); ST[c][z][r] = (u32)((((f << 1) ^ (f | (f >> 1))) >> 1) & (N - 1)); } }
  u32 nn = L * N; vector<u32> idx(nn), low(nn), stk; vector<char> on(nn); vector<u64> work; stk.reserve(nn); work.reserve(nn);
  u64 words = 0, walls = 0, traps = 0;
  for (u64 s64 = from; s64 < to; s64++) {
    u32 s = (u32)s64; bool canon = true; { u32 r = s; for (int k = 1; k < L; k++) { r = rotl1(r); if (r < s) { canon = false; break; } } } if (!canon) continue;
    words++;
    if (s == full) continue;                         // a constant black drive needs no cell beyond it
    memset(idx.data(), 0, nn * 4); u32 cnt = 0; stk.clear();
    auto succ = [&](u32 v, int z) -> u32 { u32 l = v / N, r = v % N, m = l + 1 == (u32)L ? 0 : l + 1; return m * N + ST[(s >> l) & 1][z][r]; };
    for (u32 root = 0; root < N; root++) { if (idx[root]) continue; // every closed set meets label 0
      work.clear(); work.push_back((u64)root << 2); idx[root] = low[root] = ++cnt; stk.push_back(root); on[root] = 1;
      while (!work.empty()) { u32 v = (u32)(work.back() >> 2); int k = (int)(work.back() & 3);
        if (k < 2) { work.back()++; u32 x = succ(v, k); if (!idx[x]) { idx[x] = low[x] = ++cnt; stk.push_back(x); on[x] = 1; work.push_back((u64)x << 2); } else if (on[x] && low[x] < low[v]) low[v] = low[x]; }
        else { work.pop_back(); if (!work.empty()) { u32 u = (u32)(work.back() >> 2); if (low[v] < low[u]) low[u] = low[v]; }
          if (low[v] == idx[v]) { size_t b = stk.size(); while (stk[--b] != v) {} bool closed = true; int val[40]; for (int t = 0; t < L; t++) val[t] = -1; bool lock = true;
            // is the component closed? members are stk[b..]; mark by on = 2
            for (size_t i = b; i < stk.size(); i++) on[stk[i]] = 2;
            for (size_t i = b; i < stk.size() && closed; i++) for (int z = 0; z < 2; z++) if (on[succ(stk[i], z)] != 2) { closed = false; break; }
            if (closed) { for (size_t i = b; i < stk.size() && lock; i++) { u32 l = stk[i] / N, r = stk[i] % N; if (!((s >> l) & 1)) { int f = r & 1; if (val[l] < 0) val[l] = f; else if (val[l] != f) lock = false; } } }
            size_t size = stk.size() - b;
            if (closed && lock) { walls++;
              u32 v1 = 0; string vs; for (int t = 0; t < L; t++) { if ((s >> t) & 1) vs += '-'; else { vs += val[t] == 1 ? '1' : '0'; if (val[t] == 1) v1 |= 1u << t; } }
              // leftward chain; v1 is the column to the right at the white labels (its value at black labels does not matter)
              u32 u = s, vv = v1; long d = 0; unordered_map<u64, long> seen; long cyc = -1; vector<string> hits;
              while (d <= maxc) { int p = leastPeriod(u); u32 vm = vv & ~u; // values at white labels only
                u64 key = ((u64)u << 32) | vm; auto it = seen.find(key); if (it != seen.end()) { cyc = d - it->second; break; } seen[key] = d;
                if (p <= 6 && u != 0 && u != full) { string g; for (int t = 0; t < L; t++) g += ((u >> t) & 1) ? '-' : (((vm >> t) & 1) ? '1' : '0'); char buf[512]; snprintf(buf, sizeof buf, "T %s %s %ld %s %s", bits(s, L).c_str(), vs.c_str(), d, bits(u, p).c_str(), g.c_str()); hits.push_back(buf); }
                u32 left = rotl1(u) ^ (u | vv); vv = u; u = left & full; d++; }
              fprintf(o, "W %s %s size %zu chain %ld cycle %ld\n", bits(s, L).c_str(), vs.c_str(), size, d, cyc);
              for (auto &h : hits) { fprintf(o, "%s\n", h.c_str()); traps++; } }
            for (size_t i = b; i < stk.size(); i++) on[stk[i]] = 0; stk.resize(b); } } } }
  }
  fprintf(o, "END L %d w %d from %llu to %llu necklaces %llu walls %llu small columns %llu\n", L, w, (unsigned long long)from, (unsigned long long)to, (unsigned long long)words, (unsigned long long)walls, (unsigned long long)traps);
  fclose(o); return 0;
}
