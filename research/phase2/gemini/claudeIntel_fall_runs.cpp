// K92.4.A, ledger N44 (claudeIntel). Falls at -2 against the centre's runs, on the singleton, by the evolution of
// claudeIntel_launch_census2.cpp (validated against I323's census). A fall at -2 at tick t is cell(t,-3) = cell(t,-2)
// = 1 (fall_iff). A run is a maximal interval of constant centre colour. Reports: F(N), the number of runs R(N), the
// falls inside each run (largest, by colour), the black runs of length >= 3 and whether each has a fall at v-2,
// where v is its last tick; per dyadic shell.
//
// usage: fall_runs LOG2_TICKS THREADS
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

    std::vector<long long> F(shells), R(shells), B3(shells), B3ok(shells);
    int runColour = -1; long long runStart = 0, runFalls = 0, lastFall = -10;
    int fallHist[4] = {0, 0, 0, 0};
    std::vector<long long> fallTicks;             // recent falls, trimmed
    long long maxFallsBlack = 0, maxFallsWhite = 0, maxFallsBlackT = -1, maxFallsWhiteT = -1;
    auto closeRun = [&](long long v) {
        const int sh = shellOf(runStart);
        ++R[sh];
        if (runColour == 1) { if (runFalls > maxFallsBlack) { maxFallsBlack = runFalls; maxFallsBlackT = runStart; } }
        else { if (runFalls > maxFallsWhite) { maxFallsWhite = runFalls; maxFallsWhiteT = runStart; } }
        if (runColour == 1 && v - runStart + 1 >= 3) {
            ++B3[sh];
            bool ok = false;
            for (long long x : fallTicks) if (x == v - 2) ok = true;
            if (ok) ++B3ok[sh];
        }
        while (fallTicks.size() > 8) fallTicks.erase(fallTicks.begin());
    };
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
            const int fall = cellAt(sn, -3) & cellAt(sn, -2);
            if (t < N) {
                if (t == 0 || c0 != runColour) {          // a run ends at t-1
                    if (t > 0) closeRun(t - 1);
                    runColour = c0; runStart = t; runFalls = 0;
                }
                if (fall) { ++F[shellOf(t)]; ++runFalls; }
                fallHist[t % 4] = fall;
                lastFall = fall ? t : lastFall;
                if (fall) fallTicks.push_back(t);
            }
        }
    }
    done = true;
    sync.arrive_and_wait();
    for (auto& th : pool) th.join();
    std::printf("# falls at -2 against centre runs, birth ticks < 2^%d (threads %d)\n", L2, T);
    std::printf("# shell [start,end) falls runs black_runs_len>=3 of_them_with_fall_at_v-2\n");
    long long tF = 0, tR = 0, tB = 0, tO = 0;
    for (int q = 0; q < shells; ++q) {
        const long long st = q == 0 ? 0 : (1LL << (q - 1)), en = 1LL << q;
        std::printf("%d [%lld,%lld) %lld %lld %lld %lld\n", q, st, en, F[q], R[q], B3[q], B3ok[q]);
        tF += F[q]; tR += R[q]; tB += B3[q]; tO += B3ok[q];
    }
    std::printf("total %lld %lld %lld %lld\n", tF, tR, tB, tO);
    std::printf("most falls inside one black run %lld (run from %lld); inside one white run %lld (run from %lld)\n",
                maxFallsBlack, maxFallsBlackT, maxFallsWhite, maxFallsWhiteT);
    return 0;
}
