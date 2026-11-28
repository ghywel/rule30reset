// K92.5.C, claudeM5 (M231), after the registration: ring orbits that defeat every bitmask strip certificate.
//
// A Rule 30 orbit on a ring of q cells, read from cell 0 eastward and repeated, is a right half of the line that
// satisfies Rule 30 at every site east of the centre for all time, with the centre column its cell 0 (a spatially
// periodic right half x_{i+q} = x_i forces x_q = x_0, so the centre itself evolves by the ring rule). Its restriction
// to any K cells east of the centre lies, at the matching phase, in every strip set the kit's bitmask certificate
// iterates: it has a strip history of every length, with the free exterior cell supplying cell K + 1. So if, for a
// primitive word w, two ring orbits whose cell 0 reads w repeated (at aligned phases) give different values at cell 1
// on some white phase of w, or one orbit gives both values there at different periods, then column 1 is not
// constant on the limit set at that phase for any K, and no bitmask certificate of any width exists for w.
//
// Usage: ring_phantoms QMAX LMAX   for each primitive w of length <= LMAX met as the centre of a ring orbit:
//                                  the ring sizes, and the first white phase at which cell 1 is ambiguous
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>

using u32 = std::uint32_t;
static inline u32 ringStep(u32 x, int q) {
    const u32 M = (q == 32) ? 0xffffffffu : ((1u << q) - 1);
    u32 left = ((x << 1) | (x >> (q - 1))) & M;   // cell i-1 moved to i: bit i of left is cell i-1
    u32 right = ((x >> 1) | (x << (q - 1))) & M;  // bit i of right is cell i+1
    return left ^ (x | right);
}
static std::string lyndon(const std::string& s, int& shift) {   // least rotation and its offset
    std::string best = s; shift = 0;
    for (size_t k = 1; k < s.size(); ++k) {
        std::string r = s.substr(k) + s.substr(0, k);
        if (r < best) { best = r; shift = (int)k; }
    }
    return best;
}
int main(int argc, char** argv) {
    const int QMAX = std::atoi(argv[1]), LMAX = std::atoi(argv[2]);
    // per primitive word: per phase, the set of cell-1 values seen; and the ring sizes
    std::map<std::string, std::vector<int>> seen;      // phase -> bitmask {1: saw 0, 2: saw 1}
    std::map<std::string, std::set<int>> sizes;
    for (int q = 1; q <= QMAX; ++q) {
        const u32 N = 1u << q;
        std::vector<uint8_t> mark(N, 0);   // 0 unseen, 1 on current walk, 2 done
        std::vector<u32> walk;
        for (u32 s0 = 0; s0 < N; ++s0) {
            if (mark[s0]) continue;
            walk.clear();
            u32 x = s0;
            while (!mark[x]) { mark[x] = 1; walk.push_back(x); x = ringStep(x, q); }
            if (mark[x] == 1) {   // a new cycle starting at x
                std::vector<u32> cyc;
                u32 y = x;
                do { cyc.push_back(y); y = ringStep(y, q); } while (y != x);
                std::string c0, c1;
                for (u32 z : cyc) { c0.push_back('0' + (z & 1)); c1.push_back('0' + ((z >> 1) & 1)); }
                if (q == 1) for (size_t i = 0; i < c1.size(); ++i) c1[i] = c0[i];   // cell 1 is cell 0 on a 1-ring
                // primitive period of the centre column
                size_t L = c0.size(), p = L;
                for (size_t d = 1; d <= L; ++d) if (L % d == 0) {
                    bool ok = true;
                    for (size_t i = 0; i + d < L && ok; ++i) if (c0[i] != c0[i + d]) ok = false;
                    if (ok) { p = d; break; }
                }
                if ((int)p <= LMAX) {
                    int shift;
                    std::string w = lyndon(c0.substr(0, p), shift);
                    auto& v = seen[w];
                    if (v.empty()) v.assign(p, 0);
                    sizes[w].insert(q);
                    for (size_t t = 0; t < L; ++t) {
                        int phase = (int)((t + p - shift) % p);   // phase of w at time t
                        if (w[phase] == '0') v[phase] |= (c1[t] == '1') ? 2 : 1;
                    }
                }
            }
            for (u32 z : walk) mark[z] = 2;
        }
    }
    for (auto& [w, v] : seen) {
        int amb = -1;
        for (size_t i = 0; i < v.size(); ++i) if (v[i] == 3) { amb = (int)i; break; }
        std::printf("%s rings", w.c_str());
        for (int q : sizes[w]) std::printf(" %d", q);
        if (amb >= 0) std::printf(" | ambiguous at white phase %d: no bitmask certificate at any width\n", amb);
        else std::printf(" | cell 1 constant at every white phase across these orbits\n");
    }
    return 0;
}
