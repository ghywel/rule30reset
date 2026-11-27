// K92.1, ledger N36 (claudeIntel). Exact least seed weight in the kit's anchored left-trace languages.
//
// A seed Y < 2^H is a finite left half at a kick. Its zero-wall trace is b(t) = bit 0 of F^t(Y), where
// F(Y) = (Y >> 1) ^ (Y | (Y << 1)) is Rule30ZeroBoundary.IntegerForm.F. Every language below asks
// b(0) = 0, b(t) = 1 at odd t, and constrains the kicks (the even t with b(t) = 0). Reading j is the
// pair of ticks 2j, 2j+1; a gap is the number of readings from one kick to the next.
//   G      no two consecutive kicks                        Rule30PeriodTwoWidth13.GValid
//   GE2    G, gaps 2..5, consecutive gap pairs in {22,24,25,33,35,45,52,53,55}
//                                                          Rule30PeriodTwoWidth13.GE2 (GValid and E2Run)
//   GAP35  gaps 3 or 5                                     Rule30ZeroCoastBridge.SurvivesTo
//   WORDS  GAP35 with no gap factor 333, 3353, 3533, 3553, 5533 (Rule30GateTrapWords), from the anchor
//   CORE   WORDS with no gap factor 3535353 either (Rule30GateTrapLift), from the anchor
// The trace fixes Y one bit at a time (the kit's trace-to-seed bijection): bit t of Y is computed from
// b(0..t) on the antidiagonal by M6's recurrence, as in research/phase2/floor/strip_floor.cpp.
//
// The search runs over the kicks, depth first, and prunes a prefix whose weight exceeds the budget B.
// best[m] is the least weight of Y mod 2^(2m) over the words of m readings. It is exact wherever it is
// at most B. A level with no affordable prefix shows that the least weight exceeds B there, and at every
// later level, since weights of prefixes only grow. The visited counts do not depend on the threads.
//
// usage: ladder LANG H B THREADS [SPLIT]     (H even, at most 760)
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

using Limb = uint64_t;
constexpr int MAXL = 12;  // 768 bits
using Diag = std::array<Limb, MAXL>;

enum Lang { G, GE2, GAP35, WORDS, CORE };

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

struct State {
    int since;      // readings since the last kick
    int prevGap;    // last completed gap (0 before the first)
    int ngaps;      // completed gaps, capped at 8
    uint32_t hist;  // completed gaps, newest in bit 0, 1 for a 5
};

struct Lng {
    Lang lang;
    bool kickOK(const State& s) const {
        switch (lang) {
        case G: return s.since >= 2;
        case GE2: {
            if (s.since < 2 || s.since > 5) return false;
            if (s.prevGap == 0) return true;
            const int p = s.prevGap, g = s.since;
            static const int ok[6][6] = {{0}, {0}, {0,0,1,0,1,1}, {0,0,0,1,0,1}, {0,0,0,0,0,1}, {0,0,1,1,0,1}};
            return ok[p][g];
        }
        default: {
            if (s.since != 3 && s.since != 5) return false;
            if (lang == GAP35) return true;
            const uint32_t h = (s.hist << 1) | (s.since == 5 ? 1u : 0u);
            const int n = s.ngaps + 1;
            // oldest to newest, 3 -> 0 and 5 -> 1: 333 = 000, 3353 = 0010, 3533 = 0100, 3553 = 0110, 5533 = 1100
            if (n >= 3 && (h & 7u) == 0u) return false;
            if (n >= 4) { const uint32_t w = h & 15u; if (w == 2u || w == 4u || w == 6u || w == 12u) return false; }
            if (lang == CORE && n >= 7 && (h & 127u) == 42u) return false;  // 3535353 = 0101010
            return true;
        }
        }
    }
    bool quietOK(const State& s) const {
        if (lang == G) return true;
        return s.since <= 4;
    }
    static State afterKick(const State& s) {
        State n{1, s.since, std::min(s.ngaps + 1, 8), (s.hist << 1) | (s.since == 5 ? 1u : 0u)};
        return n;
    }
    static State afterQuiet(const State& s) { State n = s; n.since = s.since + 1; return n; }
};

struct Result {
    std::vector<int> best;
    std::vector<uint64_t> visited;
    std::vector<std::string> witness;
    explicit Result(int M, int B) : best(M + 1, B + 1), visited(M + 1, 0), witness(M + 1) {}
    void offer(int m, int mass, const std::string& path) {
        if (mass < best[m] || (mass == best[m] && (witness[m].empty() || path < witness[m]))) {
            best[m] = mass;
            witness[m] = path;
        }
    }
    void merge(const Result& o) {
        for (size_t m = 0; m < best.size(); ++m) {
            visited[m] += o.visited[m];
            if (!o.witness[m].empty()) offer(int(m), o.best[m], o.witness[m]);
        }
    }
};

struct Task { State st; int mass; Diag last, prev; std::string path; };

struct Search {
    Lng L; int M, B, split;
    std::vector<Task>* tasks = nullptr;  // phase 1 collects; phase 2 is null
    Result* res;
    std::vector<Diag> W, K;
    std::string path;
    Search(Lang lang, int M_, int B_, int split_, Result* r) : L{lang}, M(M_), B(B_), split(split_), res(r),
        W(M_ + 1), K(M_ + 1) {}

    // reading j is about to be decided; last = black antidiagonal of reading j-1, prev = its white one
    void visit(int j, const State& st, int mass, const Diag& last, const Diag& prev) {
        if (j == M) return;
        if (tasks && j == split) { tasks->push_back(Task{st, mass, last, prev, path}); return; }
        for (int g = 1; g >= 0; --g) {
            if (j == 0 && g == 0) continue;           // the anchor is a kick
            if (j > 0 && g == 1 && !L.kickOK(st)) continue;
            if (j > 0 && g == 0 && !L.quietOK(st)) continue;
            extend(last, prev, 2 * j, g == 0, W[j]);
            extend(W[j], last, 2 * j + 1, true, K[j]);
            const int m2 = mass + bitAt(W[j], 2 * j) + bitAt(K[j], 2 * j + 1);
            if (m2 > B) continue;
            ++res->visited[j + 1];
            path.push_back(char('0' + g));
            res->offer(j + 1, m2, path);
            const State nst = (j == 0) ? State{1, 0, 0, 0} : (g ? Lng::afterKick(st) : Lng::afterQuiet(st));
            visit(j + 1, nst, m2, K[j], W[j]);
            path.pop_back();
        }
    }
};

static std::string gapsOf(const std::string& path) {
    std::string out; int last = 0;
    for (size_t j = 1; j < path.size(); ++j)
        if (path[j] == '1') { if (!out.empty()) out += ','; out += std::to_string(int(j) - last); last = int(j); }
    out += ";+" + std::to_string(int(path.size()) - last);
    return out;
}

// The seed of a gate path, Y mod 2^(2m), as hexadecimal (low bit = depth one).
static std::string seedHex(const std::string& path) {
    Diag last{}, prev{}, w{}, k{};
    std::vector<int> bits;
    for (size_t j = 0; j < path.size(); ++j) {
        extend(last, prev, 2 * int(j), path[j] == '0', w);
        extend(w, last, 2 * int(j) + 1, true, k);
        bits.push_back(bitAt(w, 2 * int(j)));
        bits.push_back(bitAt(k, 2 * int(j) + 1));
        prev = w; last = k;
    }
    std::string hex;
    for (int grp = (int(bits.size()) - 1) / 4; grp >= 0; --grp) {
        int v = 0;
        for (int b = 3; b >= 0; --b) { const int idx = 4 * grp + b; v = v * 2 + (idx < int(bits.size()) ? bits[idx] : 0); }
        hex.push_back("0123456789abcdef"[v]);
    }
    size_t nz = hex.find_first_not_of('0');
    return nz == std::string::npos ? "0" : hex.substr(nz);
}

int main(int argc, char** argv) {
    if (argc < 5) { std::fprintf(stderr, "usage: ladder LANG H B THREADS [SPLIT]\n"); return 2; }
    const std::string ln = argv[1];
    Lang lang;
    if (ln == "G") lang = G; else if (ln == "GE2") lang = GE2; else if (ln == "GAP35") lang = GAP35;
    else if (ln == "WORDS") lang = WORDS; else if (ln == "CORE") lang = CORE;
    else throw std::invalid_argument("language");
    const int H = std::stoi(argv[2]), B = std::stoi(argv[3]), T = std::stoi(argv[4]);
    const int split = argc > 5 ? std::stoi(argv[5]) : 24;
    if (H < 2 || H % 2 || H > 64 * MAXL - 8 || B < 0 || T < 1) throw std::invalid_argument("arguments");
    const int M = H / 2;

    Result total(M, B);
    std::vector<Task> tasks;
    {
        Search s(lang, M, B, std::min(split, M), &total);
        s.tasks = &tasks;
        Diag z{};
        s.visit(0, State{0, 0, 0, 0}, 0, z, z);
    }
    std::atomic<size_t> next{0};
    std::vector<Result> parts(T, Result(M, B));
    std::vector<std::thread> pool;
    for (int i = 0; i < T; ++i)
        pool.emplace_back([&, i] {
            Search s(lang, M, B, -1, &parts[i]);
            for (size_t k; (k = next.fetch_add(1)) < tasks.size();) {
                const Task& tk = tasks[k];
                s.path = tk.path;
                s.visit(int(tk.path.size()), tk.st, tk.mass, tk.last, tk.prev);
            }
        });
    for (auto& th : pool) th.join();
    for (auto& p : parts) total.merge(p);

    std::printf("# lang %s H %d budget %d threads %d split %d tasks %zu\n", ln.c_str(), H, B, T, split, tasks.size());
    std::printf("# H least_weight affordable_prefixes gaps_of_first_minimiser seed_hex\n");
    for (int m = 1; m <= M; ++m) {
        if (total.witness[m].empty()) std::printf("%d >%d %llu - -\n", 2 * m, B, (unsigned long long)total.visited[m]);
        else std::printf("%d %d %llu %s %s\n", 2 * m, total.best[m], (unsigned long long)total.visited[m],
                         gapsOf(total.witness[m]).c_str(), seedHex(total.witness[m]).c_str());
    }
    return 0;
}
