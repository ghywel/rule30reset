// K92.4, ledger N39 (claudeIntel). The launch census of claudeIntel_launch_census.cpp, with 64 ticks per barrier.
//
// Same observables and output as claudeIntel_launch_census.cpp (see there). Each block of K = 64 ticks: every
// thread copies its share of the active row, with H = 2 words of halo on each side, advances it K ticks
// privately (the light cone moves one cell per tick, so the share stays exact), and writes the share back. The
// thread whose share holds the centre logs, at every tick of the block, the 8 words from six words west of the
// centre word to one east (cells -384 .. +127). The observer then reads the log tick by tick.
//
// usage: launch_census2 LOG2_TICKS THREADS
#include <algorithm>
#include <barrier>
#include <cstdint>
#include <cstdio>
#include <string>
#include <thread>
#include <vector>

using U = uint64_t;
constexpr int K = 64, H = 2, SNAP = 8;

int main(int argc, char** argv) {
    if (argc < 3) { std::fprintf(stderr, "usage: launch_census2 LOG2_TICKS THREADS\n"); return 2; }
    const int L2 = std::stoi(argv[1]), T = std::stoi(argv[2]);
    const long long N = 1LL << L2, MAXT = N + 256;
    const long long CW = (MAXT + K + 64) / 64 + 16;     // word index of the centre word
    const long long OFF = CW * 64;                       // bit index of p = 0
    const size_t W = size_t(2 * CW + 32);
    std::vector<U> row(W, 0);
    row[CW] = 1;                                         // p = 0 is bit 0 of word CW
    std::vector<std::vector<U>> snap(K, std::vector<U>(SNAP));
    const int shells = L2 + 1;
    std::vector<long long> falls(shells), l2(shells), l6(shells), arr(shells);
    int widestBar = 0, widestMark = 0; long long widestBarT = -1;
    std::vector<long long> widestMarkT;
    std::vector<std::vector<int>> due(512);
    auto shellOf = [](long long t) { int s = 0; while ((2LL << s) <= t) ++s; return t == 0 ? 0 : s + 1; };

    std::barrier sync(T + 1);  // the T workers and the observer
    long long t0 = 0;
    bool done = false;
    auto work = [&](int id) {
        std::vector<U> a, b;
        while (true) {
            sync.arrive_and_wait();
            if (done) return;
            const long long lo = std::max(1LL, CW - (t0 + K + 64) / 64 - 2), hi = std::min((long long)W - 2, CW + (t0 + K + 64) / 64 + 2);
            const long long n = hi - lo + 1, per = (n + T - 1) / T;
            const long long s = lo + id * per, e = std::min(hi + 1, s + per);   // share [s, e)
            const bool centre = (s <= CW && CW < e);
            if (s < e) {
                // the centre thread also keeps its snapshot words, with their own halo
                const long long bs = std::max(0LL, (centre ? std::min(s, CW - (SNAP - 2)) : s) - H);
                const long long be = std::min((long long)W, (centre ? std::max(e, CW + 2) : e) + H);
                const long long m = be - bs;
                a.assign(row.begin() + bs, row.begin() + be);
                b.assign(m, 0);
                for (int k = 0; k < K; ++k) {
                    if (centre) for (int j = 0; j < SNAP; ++j) snap[k][j] = a[CW - (SNAP - 2) - bs + j];
                    for (long long i = 1; i + 1 < m; ++i) {
                        const U x = a[i];
                        b[i] = ((x << 1) | (a[i - 1] >> 63)) ^ (x | ((x >> 1) | (a[i + 1] << 63)));
                    }
                    b[0] = 0; b[m - 1] = 0;  // edge words go stale; the halo absorbs them
                    a.swap(b);
                }
                sync.arrive_and_wait();      // everyone has read the old row
                std::copy(a.begin() + (s - bs), a.begin() + (e - bs), row.begin() + s);
            } else {
                sync.arrive_and_wait();
            }
            sync.arrive_and_wait();          // the new row is written
        }
    };
    std::vector<std::thread> pool;
    for (int i = 0; i < T; ++i) pool.emplace_back(work, i);
    auto cellAt = [&](const std::vector<U>& sn, int p) -> int {  // p in [-384, 127]
        const long long i = (long long)(SNAP - 2) * 64 + p;      // bit index inside the snapshot
        return int((sn[i / 64] >> (i % 64)) & 1);
    };
    for (t0 = 0; t0 <= MAXT; t0 += K) {
        sync.arrive_and_wait();   // start the block
        sync.arrive_and_wait();   // reads finished
        sync.arrive_and_wait();   // writes finished
        for (int k = 0; k < K; ++k) {
            const long long t = t0 + k;
            if (t > MAXT) break;
            const std::vector<U>& sn = snap[k];
            const int c0 = cellAt(sn, 0);
            if (t < N) {
                const int sh = shellOf(t);
                const int m3 = cellAt(sn, -3), m2 = cellAt(sn, -2), m1 = cellAt(sn, -1);
                if (m3 && m2) ++falls[sh];
                if ((m1 | c0) && m2) {
                    int w = 0;
                    while (w < 380 && cellAt(sn, -2 - w)) ++w;
                    if (w >= 380) { std::fputs("bar too wide for the snapshot\n", stderr); return 1; }
                    if (w > widestBar) { widestBar = w; widestBarT = t; }
                    if (w >= 2) ++l2[sh];
                    if (w >= 6) ++l6[sh];
                    due[(t + 1 + w) % 512].push_back(w >= 2 ? w : -w);
                }
            }
            for (int code : due[t % 512]) {
                const int w = code < 0 ? -code : code;
                const long long bt = t - 1 - w;
                if (c0) {
                    if (code >= 2) ++arr[shellOf(bt)];
                    if (w > widestMark) { widestMark = w; widestMarkT.assign(1, bt); }
                    else if (w == widestMark) widestMarkT.push_back(bt);
                }
            }
            due[t % 512].clear();
        }
    }
    done = true;
    sync.arrive_and_wait();
    for (auto& th : pool) th.join();
    std::printf("# launch census to 2^%d birth ticks (threads %d, %d ticks per barrier)\n", L2, T, K);
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
