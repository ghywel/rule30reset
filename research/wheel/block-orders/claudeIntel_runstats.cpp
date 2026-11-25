// run statistics late in the gate of random right halves beside the alternating wall.  usage: stat ROWS READS FROM SEED
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <map>
#include <string>
#include <algorithm>
#include <omp.h>
typedef uint64_t u64;
struct Rng { u64 s; u64 next() { s += 0x9E3779B97F4A7C15ull; u64 z = s; z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ull; z = (z ^ (z >> 27)) * 0x94D049BB133111EBull; return z ^ (z >> 31); } };
int main(int c, char **v) {
    long rows = atol(v[1]); int R = atoi(v[2]), from = atoi(v[3]); u64 seed = strtoull(v[4], 0, 10); int NW = (2 * R + 130) / 64;
    std::vector<long> maxrun(64, 0); std::map<std::string, long> runs, tri; long other = 0, locked = 0; long hist[64] = {0}, histB[64] = {0};
    #pragma omp parallel
    {
        std::vector<u64> a(NW); std::map<std::string, long> lr; long oth = 0, lk = 0; long hB[64] = {0}, hA[64] = {0};
        #pragma omp for schedule(dynamic, 64)
        for (long i = 0; i < rows; i++) {
            Rng g{seed * 1000003ull + (u64)i * 2654435761ull}; for (auto &x : a) x = g.next();
            int last = -1, run = -1; std::vector<int> rs; bool bad = false;
            for (int s = 0; s < R; s++) {
                if (s) for (u64 wall = 0; wall < 2; wall++) { int n = std::min(NW, (2 * (R - s) + 130) / 64 + 1); u64 cc = wall;
                    for (int k = 0; k < n; k++) { u64 x = a[k], l = (x << 1) | cc, r = (x >> 1) | (k + 1 < NW ? a[k + 1] << 63 : 0); cc = x >> 63; a[k] = l ^ (x | r); } }
                if (a[0] & 1) { if (last >= from) { int d = s - last; if (d == 3) { if (run >= 0) rs.push_back(run); run = 0; } else if (d == 5) { if (run >= 0) run++; } else { bad = true; run = -1; } } last = s; }
            }
            if (bad) oth++;
            int kB = 0, kA = 0;
            for (int r : rs) { lr[std::to_string(r)]++; if (r == 5) { kB++; } else { if (kB) hB[kB < 63 ? kB : 63]++; kB = 0; } if (r == 3) kA++; else { if (kA) hA[kA < 63 ? kA : 63]++; kA = 0; } }
            if (kB) hB[kB]++; if (kA) hA[kA < 63 ? kA : 63]++;
            if (rs.empty()) lk++;
        }
        #pragma omp critical
        { for (auto &x : lr) runs[x.first] += x.second; other += oth; locked += lk; for (int z = 0; z < 64; z++) { histB[z] += hB[z]; hist[z] += hA[z]; } }
    }
    printf("rows %ld, readings %d to %d, with another gap %ld, with no run %ld\n", rows, from, R, other, locked); for (auto &x : runs) printf("run %s: %ld\n", x.first.c_str(), x.second);
    printf("maximal B-trains (k: count):"); for (int z = 1; z < 64; z++) if (histB[z]) printf(" %d:%ld", z, histB[z]); printf("\nmaximal A-trains:"); for (int z = 1; z < 64; z++) if (hist[z]) printf(" %d:%ld", z, hist[z]); printf("\n");
}
