// claudeCloud_m181_rho.cpp: does a periodic gate beside the alternating column sit on a spatial ring? (ledger K86)
//
// The wall is column 0, white at even ticks and black at odd ticks. The gate is column 1 read at the even ticks; a
// gap word such as 3555 gives the kicks (black readings), repeated for ever, so the gate has N/2 readings and the
// time period is N ticks. Rule 30 is new = left xor (centre or right), so two neighbouring columns (b, c) fix the
// column on their left:  D(b,c)(t) = b(t+1) xor (b(t) or c(t)).  For the wall a and any column 1 with that gate,
// column -1 is black at odd ticks and the complement of the gate at even ticks, so the pair (column -1, wall) is
// fixed by the gate alone: the forced pair.  F(b,c) = (D(b,c), b) walks west.
//
// K79 and K81: a right half all of whose columns are eventually periodic with one bound on their periods exists for
// this gate if and only if the forced pair returns to itself under F (a ring).  This program finds the exact tail
// length mu and cycle length lambda of the forced pair's orbit (Brent), for each gap word on standard input.
//   mu = 0: a ring of lambda columns.   mu > 0: no ring, so no right half of bounded column periods reads the gate.
//
//   g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_m181_rho.cpp -o m181_rho
//   m181_rho LOG2BUDGET < words.txt       one gap word per line, as digits (3555) or comma-separated (3,5,5,5);
//                                         N = 2 * (sum of gaps) <= 126
// Output, one line per word:  word N mu lambda      or      word N open BUDGET   (no cycle closed within the budget)
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>
typedef unsigned __int128 u128;
struct Pair { u128 b, c; bool operator==(const Pair &o) const { return b == o.b && c == o.c; } };
struct Sys {
    int N; u128 MASK;
    inline Pair F(const Pair &p) const {
        u128 b1 = ((p.b >> 1) | (p.b << (N - 1))) & MASK;           // b(t+1) at bit t
        return Pair{ (b1 ^ (p.b | p.c)) & MASK, p.b };
    }
};
int main(int argc, char **argv) {
    int lg = argc > 1 ? atoi(argv[1]) : 30;
    uint64_t budget = 1ULL << lg;
    std::vector<std::string> words; std::string w;
    while (std::cin >> w) words.push_back(w);
    std::vector<std::string> out(words.size());
    #pragma omp parallel for schedule(dynamic, 1)
    for (size_t i = 0; i < words.size(); ++i) {
        const std::string &g = words[i];
        std::vector<int> gaps;
        if (g.find(',') == std::string::npos) { for (char ch : g) gaps.push_back(ch - '0'); }
        else { size_t p = 0; while (p < g.size()) { size_t q = g.find(',', p); if (q == std::string::npos) q = g.size(); gaps.push_back(atoi(g.substr(p, q - p).c_str())); p = q + 1; } }
        int n = 0; for (int d : gaps) n += d;
        Sys S; S.N = 2 * n;
        char buf[256];
        if (S.N > 126 || S.N < 2) { snprintf(buf, sizeof buf, "%s %d skipped", g.c_str(), S.N); out[i] = buf; continue; }
        S.MASK = (S.N == 128) ? ~(u128)0 : (((u128)1 << S.N) - 1);
        u128 wall = 0, west = 0;
        for (int t = 1; t < S.N; t += 2) { wall |= (u128)1 << t; west |= (u128)1 << t; }   // black at odd ticks
        { int s = 0; std::vector<int> kick(n, 0); for (int d : gaps) { kick[s] = 1; s += d; }
          for (s = 0; s < n; ++s) if (!kick[s]) west |= (u128)1 << (2 * s); }               // complement of the gate
        Pair x0{west, wall};
        // Brent
        uint64_t power = 1, lam = 1, steps = 0; Pair tort = x0, hare = S.F(x0); bool open = false;
        while (!(tort == hare)) {
            if (power == lam) { tort = hare; power <<= 1; lam = 0; }
            hare = S.F(hare); ++lam; ++steps;
            if (steps > budget) { open = true; break; }
        }
        if (open) { snprintf(buf, sizeof buf, "%s %d open %llu", g.c_str(), S.N, (unsigned long long)budget); out[i] = buf; continue; }
        uint64_t mu = 0; tort = hare = x0;
        for (uint64_t k = 0; k < lam; ++k) hare = S.F(hare);
        while (!(tort == hare)) { tort = S.F(tort); hare = S.F(hare); ++mu; }
        snprintf(buf, sizeof buf, "%s %d %llu %llu", g.c_str(), S.N, (unsigned long long)mu, (unsigned long long)lam);
        out[i] = buf;
        #pragma omp critical
        { fprintf(stderr, "%s\n", buf); }
    }
    for (auto &s : out) puts(s.c_str());
    return 0;
}
