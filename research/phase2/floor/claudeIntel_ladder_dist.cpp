// K92.1, ledger N36 (claudeIntel). The whole weight distribution of a language's words, for the annealed test.
// Same languages, decoder and anchor as claudeIntel_ladder.cpp (whose search this repeats with no budget):
// count[m][w] is the number of words of m readings whose seed Y mod 2^(2m) has weight w. From it,
// Z_m(z) = sum_w count[m][w] z^w, the weight partition function; a bound Z_m(z) <= C rho^m with rho < 1 for
// one z < 1 gives a linear floor by Chernoff's bound (#{w <= A} <= z^-A Z_m(z)).
//
// usage: ladder_dist LANG H THREADS [SPLIT]
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

using Limb = uint64_t;
constexpr int MAXL = 6;  // 384 bits
using Diag = std::array<Limb, MAXL>;

static void extend(const Diag& last, const Diag& prev, int t, bool bit, Diag& out) {
    Limb parity = 0, prev_shift = 0, prefix_shift = 0;
    const int top = t / 64;
    for (int k = 0; k <= top; ++k) {
        Limb prefix = last[k] | ((prev[k] << 1) | prev_shift);
        prev_shift = prev[k] >> 63;
        prefix ^= prefix << 1; prefix ^= prefix << 2; prefix ^= prefix << 4;
        prefix ^= prefix << 8; prefix ^= prefix << 16; prefix ^= prefix << 32;
        prefix ^= Limb(0) - parity;
        parity = prefix >> 63;
        out[k] = ((prefix << 1) | prefix_shift) ^ (Limb(0) - Limb(bit));
        prefix_shift = parity;
    }
    out[top] &= ~Limb(0) >> (63 - t % 64);
    for (int k = top + 1; k < MAXL; ++k) out[k] = 0;
}
static inline int bitAt(const Diag& d, int t) { return int((d[t / 64] >> (t % 64)) & 1); }

enum Lang { GE2, GAP35, WORDS, CORE };
struct State { int since, prevGap, ngaps; uint32_t hist; };

static bool kickOK(Lang lang, const State& s) {
    if (lang == GE2) {
        if (s.since < 2 || s.since > 5) return false;
        if (s.prevGap == 0) return true;
        static const int ok[6][6] = {{0}, {0}, {0,0,1,0,1,1}, {0,0,0,1,0,1}, {0,0,0,0,0,1}, {0,0,1,1,0,1}};
        return ok[s.prevGap][s.since];
    }
    if (s.since != 3 && s.since != 5) return false;
    if (lang == GAP35) return true;
    const uint32_t h = (s.hist << 1) | (s.since == 5 ? 1u : 0u);
    const int n = s.ngaps + 1;
    if (n >= 3 && (h & 7u) == 0u) return false;
    if (n >= 4) { const uint32_t w = h & 15u; if (w == 2u || w == 4u || w == 6u || w == 12u) return false; }
    if (lang == CORE && n >= 7 && (h & 127u) == 42u) return false;
    return true;
}

struct Counter {
    Lang lang; int M;
    std::vector<std::vector<uint64_t>> count;
    std::vector<Diag> W, K;
    Counter(Lang l, int M_) : lang(l), M(M_), count(M_ + 1, std::vector<uint64_t>(2 * M_ + 1, 0)), W(M_ + 1), K(M_ + 1) {}
    void visit(int j, const State& st, int mass, const Diag& last, const Diag& prev, int stop,
               std::vector<std::tuple<State, int, Diag, Diag, int>>* tasks) {
        if (j == M) return;
        if (tasks && j == stop) { tasks->emplace_back(st, mass, last, prev, j); return; }
        for (int g = 1; g >= 0; --g) {
            if (j == 0 && g == 0) continue;
            if (j > 0 && g == 1 && !kickOK(lang, st)) continue;
            if (j > 0 && g == 0 && st.since > 4) continue;
            extend(last, prev, 2 * j, g == 0, W[j]);
            extend(W[j], last, 2 * j + 1, true, K[j]);
            const int m2 = mass + bitAt(W[j], 2 * j) + bitAt(K[j], 2 * j + 1);
            ++count[j + 1][m2];
            const State nst = (j == 0) ? State{1, 0, 0, 0}
                : g ? State{1, st.since, st.ngaps < 8 ? st.ngaps + 1 : 8, (st.hist << 1) | (st.since == 5 ? 1u : 0u)}
                    : State{st.since + 1, st.prevGap, st.ngaps, st.hist};
            visit(j + 1, nst, m2, K[j], W[j], stop, tasks);
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 4) { std::fprintf(stderr, "usage: ladder_dist LANG H THREADS [SPLIT]\n"); return 2; }
    const std::string ln = argv[1];
    Lang lang = ln == "GE2" ? GE2 : ln == "GAP35" ? GAP35 : ln == "WORDS" ? WORDS : ln == "CORE" ? CORE
        : throw std::invalid_argument("language");
    const int H = std::stoi(argv[2]), T = std::stoi(argv[3]), split = argc > 4 ? std::stoi(argv[4]) : 20;
    if (H % 2 || H > 64 * MAXL - 8) throw std::invalid_argument("H");
    const int M = H / 2;
    Counter root(lang, M);
    std::vector<std::tuple<State, int, Diag, Diag, int>> tasks;
    Diag z{};
    root.visit(0, State{0, 0, 0, 0}, 0, z, z, split, &tasks);
    std::atomic<size_t> next{0};
    std::vector<Counter*> parts;
    for (int i = 0; i < T; ++i) parts.push_back(new Counter(lang, M));
    std::vector<std::thread> pool;
    for (int i = 0; i < T; ++i)
        pool.emplace_back([&, i] {
            for (size_t k; (k = next.fetch_add(1)) < tasks.size();) {
                auto& [st, mass, last, prev, j] = tasks[k];
                parts[i]->visit(j, st, mass, last, prev, -1, nullptr);
            }
        });
    for (auto& th : pool) th.join();
    std::printf("# lang %s H %d: per even H, the number of words with each seed weight (weight:count)\n", ln.c_str(), H);
    for (int m = 1; m <= M; ++m) {
        std::printf("%d", 2 * m);
        for (int w = 0; w <= 2 * m; ++w) {
            uint64_t c = root.count[m][w];
            for (auto* p : parts) c += p->count[m][w];
            if (c) std::printf(" %d:%llu", w, (unsigned long long)c);
        }
        std::printf("\n");
    }
    return 0;
}
