// K92.4, ledger N39 (claudeIntel). Gap launches on the singleton Rule 30 spacetime, by direct evolution.
//
// cell(t, p) is Rule30Jen.cell: one black cell at p = 0, then new(p) = old(p-1) xor (old(p) or old(p+1)).
// At each tick t (I321, MarkLaunch.lean): a fall at -2 is cell(t,-3) = cell(t,-2) = 1; the pair (-1, 0) is
// active when either is black; Bar(t, w) holds when the pair is active and the black run read westward from -2
// has exactly w cells (w >= 1) with a white cell beyond. Its gap's marked arrival is cell(t+1+w, 0) = 1.
// Counts per dyadic shell of birth ticks: falls at -2, launches of width >= 2 and >= 6, width >= 2 launches with
// a black arrival; the widest bar and the widest marked birth, with their ticks.
//
// usage: launch_census LOG2_TICKS THREADS
#include <algorithm>
#include <barrier>
#include <cstdint>
#include <cstdio>
#include <string>
#include <thread>
#include <vector>

using U = uint64_t;

int main(int argc, char** argv) {
    if (argc < 3) { std::fprintf(stderr, "usage: launch_census LOG2_TICKS THREADS\n"); return 2; }
    const int L2 = std::stoi(argv[1]), T = std::stoi(argv[2]);
    const long long N = 1LL << L2;                      // birth ticks 0 .. N-1
    const long long MAXT = N + 200;                     // arrivals up to N + 1 + width
    const long long OFF = ((MAXT + 2 + 63) / 64 + 1) * 64; // bit index of p = 0
    const size_t W = size_t((2 * OFF + 64) / 64) + 2;
    std::vector<U> a(W, 0), b(W, 0);
    a[OFF / 64] |= U(1) << (OFF % 64);
    auto bit = [&](const std::vector<U>& r, long long p) -> int {
        const long long i = OFF + p; return int((r[i / 64] >> (i % 64)) & 1);
    };
    // pending arrivals, a ring indexed by tick mod 256 (widths stay far below 256)
    std::vector<std::vector<int>> due(256);
    const int shells = L2 + 1;
    std::vector<long long> falls(shells), l2(shells), l6(shells), arr(shells);
    int widestBar = 0, widestMark = 0; long long widestBarT = -1;
    std::vector<long long> widestMarkT;
    auto shellOf = [](long long t) { int s = 0; while ((2LL << s) <= t) ++s; return t == 0 ? 0 : s + 1; };

    std::barrier sync(T);
    long long t = 0;
    std::vector<U>* cur = &a; std::vector<U>* nxt = &b;
    bool done = false;
    // the single thread observes; all threads share the word update of each tick
    auto update = [&](int id) {
        while (true) {
            sync.arrive_and_wait();            // the observer has finished tick t
            if (done) return;
            const long long lo = (OFF - t - 2) / 64, hi = (OFF + t + 2) / 64 + 1;
            const long long n = hi - lo + 1, per = (n + T - 1) / T;
            const long long s = lo + id * per, e = std::min(hi + 1, s + per);
            const std::vector<U>& r = *cur; std::vector<U>& o = *nxt;
            for (long long k = std::max(s, 1LL); k < e && k + 1 < (long long)W; ++k) {
                const U x = r[k];
                const U left = (x << 1) | (r[k - 1] >> 63);    // cell p-1 sits one bit lower
                const U right = (x >> 1) | (r[k + 1] << 63);   // cell p+1 sits one bit higher
                o[k] = left ^ (x | right);
            }
            sync.arrive_and_wait();            // tick t+1 is written
        }
    };
    std::vector<std::thread> pool;
    for (int i = 1; i < T; ++i) pool.emplace_back(update, i);
    for (t = 0; t <= MAXT; ++t) {
        // observe tick t on *cur
        const int c0 = bit(*cur, 0);
        if (t < N) {
            const int sh = shellOf(t);
            const int m3 = bit(*cur, -3), m2 = bit(*cur, -2), m1 = bit(*cur, -1);
            if (m3 && m2) ++falls[sh];
            if ((m1 | c0) && m2) {
                int w = 0;
                while (bit(*cur, -2 - w)) ++w;
                if (w > widestBar) { widestBar = w; widestBarT = t; }
                if (w >= 2) ++l2[sh];
                if (w >= 6) ++l6[sh];
                if (w >= 250) { std::fputs("bar too wide\n", stderr); return 1; }
                if (t + 1 + w <= MAXT) due[(t + 1 + w) % 256].push_back(w >= 2 ? w : -w);
            }
        }
        // resolve arrivals due now
        for (int code : due[t % 256]) {
            const int w = code < 0 ? -code : code;
            const long long bt = t - 1 - w;
            if (c0) {
                if (code >= 2) ++arr[shellOf(bt)];
                if (w > widestMark) { widestMark = w; widestMarkT.assign(1, bt); }
                else if (w == widestMark) widestMarkT.push_back(bt);
            }
        }
        due[t % 256].clear();
        if (t == MAXT) break;
        // advance: all threads update, the observer takes part as thread 0
        sync.arrive_and_wait();
        {
            const long long lo = (OFF - t - 2) / 64, hi = (OFF + t + 2) / 64 + 1;
            const long long n = hi - lo + 1, per = (n + T - 1) / T;
            const long long s = lo, e = std::min(hi + 1, s + per);
            const std::vector<U>& r = *cur; std::vector<U>& o = *nxt;
            for (long long k = std::max(s, 1LL); k < e && k + 1 < (long long)W; ++k) {
                const U x = r[k];
                o[k] = ((x << 1) | (r[k - 1] >> 63)) ^ (x | ((x >> 1) | (r[k + 1] << 63)));
            }
        }
        sync.arrive_and_wait();
        std::swap(cur, nxt);
    }
    done = true;
    sync.arrive_and_wait();
    for (auto& th : pool) th.join();
    std::printf("# launch census to 2^%d birth ticks (threads %d)\n", L2, T);
    std::printf("# shell [start,end) falls_at_-2 launches_w>=2 launches_w>=6 w>=2_with_black_arrival\n");
    long long F = 0, A2 = 0, A6 = 0, AR = 0;
    for (int s = 0; s < shells; ++s) {
        const long long st = s == 0 ? 0 : (1LL << (s - 1)), en = 1LL << s;
        std::printf("%d [%lld,%lld) %lld %lld %lld %lld\n", s, st, en, falls[s], l2[s], l6[s], arr[s]);
        F += falls[s]; A2 += l2[s]; A6 += l6[s]; AR += arr[s];
    }
    std::printf("total %lld %lld %lld %lld\n", F, A2, A6, AR);
    std::printf("widest bar %d at tick %lld\nwidest marked birth %d at ticks", widestBar, widestBarT, widestMark);
    for (long long x : widestMarkT) std::printf(" %lld", x);
    std::printf("\n");
    return 0;
}
