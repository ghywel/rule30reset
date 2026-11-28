// K92.2, claudeM5 (M224), development check after the registration: on the even-pin cube, is the row at tick 2n
// determined by its wall half (depths 1..2n)? Counts distinct rows, distinct wall halves and distinct outer halves.
// The same decoder and map as claudeM5_distinct_rows.cpp. Usage: wall_half n THREADS [PIN]   (PIN 0 even, 1 odd)
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>
using u64 = std::uint64_t;
using u128 = unsigned __int128;
static inline u128 F(u128 y) { return (y >> 1) ^ (y | (y << 1)); }
static inline u64 decode(u64 tr, int n) {
    u64 a = tr, b = 0, y = 0;
    for (int d = 0; d < 2 * n; ++d) { y |= (a & 1) << d; u64 c = (a >> 1) ^ (a | b); b = a; a = c; }
    return y;
}
int main(int argc, char** argv) {
    const int n = std::atoi(argv[1]), T = std::atoi(argv[2]), pin = argc > 3 ? std::atoi(argv[3]) : 0;
    u64 pins = 0;
    for (int i = 0; i < n; ++i) pins |= 1ULL << (2 * i + pin);
    const u64 N = 1ULL << n;
    std::vector<u128> rows(N);
    std::vector<std::thread> pool;
    for (int k = 0; k < T; ++k) pool.emplace_back([&, k] {
        for (u64 f = k; f < N; f += T) {
            u64 tr = pins;
            for (int i = 0; i < n; ++i) tr |= ((f >> i) & 1) << (2 * i + 1 - pin);
            u128 y = decode(tr, n);
            for (int t = 0; t < 2 * n; ++t) {
                if ((u64)(y & 1) != ((tr >> t) & 1)) { std::fprintf(stderr, "trace mismatch\n"); std::exit(1); }
                y = F(y);
            }
            rows[f] = y;
        }
    });
    for (auto& th : pool) th.join();
    std::sort(rows.begin(), rows.end());
    rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
    const u128 mask = (((u128)1) << (2 * n)) - 1;
    std::vector<u128> inner(rows.size()), outer(rows.size());
    for (size_t i = 0; i < rows.size(); ++i) { inner[i] = rows[i] & mask; outer[i] = rows[i] >> (2 * n); }
    std::sort(inner.begin(), inner.end()); inner.erase(std::unique(inner.begin(), inner.end()), inner.end());
    std::sort(outer.begin(), outer.end()); outer.erase(std::unique(outer.begin(), outer.end()), outer.end());
    std::printf("n %d pin %d rows %zu wall_halves %zu outer_halves %zu %s\n", n, pin, rows.size(), inner.size(), outer.size(),
                rows.size() == inner.size() ? "wall half determines the row" : "NOT determined");
    return 0;
}
