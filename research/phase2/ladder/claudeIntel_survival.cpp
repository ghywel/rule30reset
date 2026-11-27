// K92.2, ledger N38 (claudeIntel). Exact survival past the support beside the white wall, for every width at once.
//
// A seed y < 4^n is a finite left half beside a white wall; its trace is b(t) = bit 0 of F^t(y), with
// F(y) = (y >> 1) ^ (y | (y << 1)) (Rule30ZeroBoundary.IntegerForm.F). With pins at the ticks of parity P
// (P = 0: even ticks, the convention of Benboubakeur et al.'s A j r and of I283's even phase), the seeds whose
// trace is black at every pinned tick below 2n are 2^n, one for each choice of the other n readings (the kit's
// trace-to-seed bijection). L[n][k] counts those whose next k pinned ticks, from 2n on, are black and whose
// (k+1)-th is white: they pass exactly k checks past their support. A(k, n) = sum over j >= k of L[n][j].
//
// The search runs over the free readings depth first, fixing the seed two bits at a time through M6's
// antidiagonal recurrence (as in research/phase2/floor/strip_floor.cpp). At every depth r it then runs the white
// tail: each later seed bit is white, which fixes each later trace bit, until a pinned tick reads white.
// So one run gives L[r][k] for every r up to N.
//
// usage: survival N PIN THREADS [SPLIT]
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <string>
#include <thread>
#include <vector>

using Limb = uint64_t;
constexpr int MAXL = 4;  // 256 bits: N up to 48 with up to 80 checks past the support
using Diag = std::array<Limb, MAXL>;
constexpr int MAXN = 48, MAXK = 81;

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
// The same antidiagonal with every bit 0..t complemented: the trace bit at t raised by one.
static inline void flip(Diag& d, int t) {
    for (int k = 0; k < t / 64; ++k) d[k] = ~d[k];
    d[t / 64] ^= ~Limb(0) >> (63 - t % 64);
}

struct Counts {
    std::vector<std::array<uint64_t, MAXK + 1>> L;
    std::vector<int> best;             // most checks passed at each depth
    std::vector<std::string> bestPath; // first free word (low reading first) attaining it
    Counts() : L(MAXN + 1), best(MAXN + 1, -1), bestPath(MAXN + 1) { for (auto& a : L) a.fill(0); }
    void merge(const Counts& o) {
        for (int r = 0; r <= MAXN; ++r) {
            for (int k = 0; k <= MAXK; ++k) L[r][k] += o.L[r][k];
            if (o.best[r] > best[r] || (o.best[r] == best[r] && o.best[r] >= 0 && o.bestPath[r] < bestPath[r])) {
                best[r] = o.best[r]; bestPath[r] = o.bestPath[r];
            }
        }
    }
};

struct Search {
    int N, P;
    Counts* c;
    std::vector<Diag> A, Bk;  // antidiagonals after the first and second tick of each reading
    std::string path;
    Search(int N_, int P_, Counts* c_) : N(N_), P(P_), c(c_), A(N_ + 1), Bk(N_ + 1) {}

    // white tail from depth r: last = antidiagonal at tick 2r-1, prev = at tick 2r-2
    int tail(int r, Diag last, Diag prev) {
        int passed = 0;
        Diag out;
        for (int t = 2 * r;; ++t) {
            extend(last, prev, t, false, out);
            const int f = bitAt(out, t);   // the trace bit that keeps the seed bit at t white
            if (f) flip(out, t);
            if ((t & 1) == P) {
                if (!f) return passed;
                if (++passed >= MAXK) return passed;
            }
            prev = last; last = out;
        }
    }
    void record(int r, int k) {
        ++c->L[r][k];
        if (k > c->best[r] || (k == c->best[r] && path < c->bestPath[r])) { c->best[r] = k; c->bestPath[r] = path; }
    }
    // reading r covers ticks 2r and 2r+1; the pinned one is black, the other free
    void visit(int r, const Diag& last, const Diag& prev, std::vector<std::pair<std::string, std::array<Diag, 2>>>* tasks, int split) {
        if (r == N) return;
        if (tasks && r == split) { tasks->push_back({path, {last, prev}}); return; }
        for (int g = 0; g < 2; ++g) {
            const bool b0 = (P == 0) ? true : bool(g), b1 = (P == 1) ? true : bool(g);
            extend(last, prev, 2 * r, b0, A[r]);
            extend(A[r], last, 2 * r + 1, b1, Bk[r]);
            path.push_back(char('0' + g));
            record(r + 1, tail(r + 1, Bk[r], A[r]));
            visit(r + 1, Bk[r], A[r], tasks, split);
            path.pop_back();
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 4) { std::fprintf(stderr, "usage: survival N PIN THREADS [SPLIT]\n"); return 2; }
    const int N = std::stoi(argv[1]), P = std::stoi(argv[2]), T = std::stoi(argv[3]);
    const int split = argc > 4 ? std::stoi(argv[4]) : 16;
    if (N < 1 || N > MAXN || (P != 0 && P != 1) || T < 1) { std::fprintf(stderr, "bad arguments\n"); return 2; }
    Counts total;
    std::vector<std::pair<std::string, std::array<Diag, 2>>> tasks;
    {
        Search s(N, P, &total);
        Diag z{};
        s.visit(0, z, z, &tasks, std::min(split, N));
    }
    std::atomic<size_t> next{0};
    std::vector<Counts*> parts;
    for (int i = 0; i < T; ++i) parts.push_back(new Counts());
    std::vector<std::thread> pool;
    for (int i = 0; i < T; ++i)
        pool.emplace_back([&, i] {
            Search s(N, P, parts[i]);
            for (size_t k; (k = next.fetch_add(1)) < tasks.size();) {
                s.path = tasks[k].first;
                s.visit(int(s.path.size()), tasks[k].second[0], tasks[k].second[1], nullptr, -1);
            }
        });
    for (auto& th : pool) th.join();
    for (auto* p : parts) total.merge(*p);
    std::printf("# survival N %d pin %d threads %d split %d\n", N, P, T, split);
    std::printf("# n  k_max  first_free_word_attaining_it  L[n][0] L[n][1] ... (exactly k checks past the support)\n");
    for (int r = 1; r <= N; ++r) {
        int top = 0;
        for (int k = 0; k <= MAXK; ++k) if (total.L[r][k]) top = k;
        std::printf("%d %d %s", r, total.best[r], total.bestPath[r].c_str());
        for (int k = 0; k <= top; ++k) std::printf(" %llu", (unsigned long long)total.L[r][k]);
        std::printf("\n");
    }
    return 0;
}
