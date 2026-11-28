// K92.5.C, claudeM5 (M231): which periodic centre masks force their white-phase 0/2 choices to repeat?
//
// In the ternary square root of Rule 30 the origin bond reads 1 when the centre is black, and 0 or 2 by the cell at
// site 1 when it is white (k98-nine-questions.md). So "a periodic 1-mask forces its 0/2 choices to repeat" is the
// statement that column 1 at the white times of an eventually periodic centre is eventually periodic, which masked
// Jen forbids. The kit's bitmask strip certificate (Rule30StripCertificates.stripCert w K k) tests exactly that on a
// strip of K cells east of the centre, driven by the centre word w with a free cell beyond the strip.
// This census decides, for every primitive word w up to length L and every K up to KMAX, whether stripCert w K k
// holds for some k: the strip sets after whole periods of w decrease from the full set to a limit, and the
// certificate exists exactly when column 1 is constant at every white phase on the limit's orbit (a larger set
// only makes colConst harder). Same stripStep as the kit:
//   stripStep K a z r = (((r << 1) | a) ^ (r | (r >> 1) | (z << (K - 1)))) mod 2^K.
//
// Usage: mask_census L KMAX THREADS      one line per word: the word, its length, the least K certifying it (or -),
//                                       and at KMAX the white phase and size of the first ambiguity if none does
#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <thread>
#include <vector>

using u64 = std::uint64_t;
using Set = std::vector<u64>;   // bitset over 2^K states

static inline unsigned stripStep(int K, int a, int z, unsigned r) {
    const unsigned M = (1u << K) - 1;
    return (((r << 1) | a) ^ (r | (r >> 1) | ((unsigned)z << (K - 1)))) & M;
}
static Set image(int K, int a, const Set& S) {
    Set T(S.size(), 0);
    for (size_t wi = 0; wi < S.size(); ++wi) {
        u64 x = S[wi];
        while (x) {
            unsigned r = (unsigned)(wi * 64 + __builtin_ctzll(x));
            x &= x - 1;
            unsigned s0 = stripStep(K, a, 0, r), s1 = stripStep(K, a, 1, r);
            T[s0 >> 6] |= 1ULL << (s0 & 63);
            T[s1 >> 6] |= 1ULL << (s1 & 63);
        }
    }
    return T;
}
static int colKind(int K, const Set& S) {   // 0: column 1 white on all; 1: black on all; 2: both; 3: empty
    bool w = false, b = false;
    for (size_t wi = 0; wi < S.size(); ++wi) {
        u64 x = S[wi];
        // state r has bit 0 = r & 1: even-indexed bits are column 1 white
        if (x & 0x5555555555555555ULL) w = true;
        if (x & 0xAAAAAAAAAAAAAAAAULL) b = true;
    }
    (void)K;
    return (w && b) ? 2 : w ? 0 : b ? 1 : 3;
}
struct Result { bool cert; int ambPhase; size_t ambSize; int periods; };
static Result test(const std::vector<int>& w, int K) {
    const size_t words = ((1u << K) + 63) / 64;
    Set S(words, ~0ULL);
    if ((1u << K) % 64) S[words - 1] = (1ULL << ((1u << K) % 64)) - 1;
    int periods = 0;
    while (true) {
        Set T = S;
        for (int a : w) T = image(K, a, T);
        ++periods;
        if (T == S) break;
        S.swap(T);
        if (periods > 100000) { std::fprintf(stderr, "no limit\n"); std::exit(1); }
    }
    Set cur = S;
    for (size_t phi = 0; phi < w.size(); ++phi) {
        if (w[phi] == 0 && colKind(K, cur) == 2) {
            size_t n = 0;
            for (u64 x : cur) n += __builtin_popcountll(x);
            return {false, (int)phi, n, periods};
        }
        cur = image(K, w[phi], cur);
    }
    return {true, -1, 0, periods};
}
int main(int argc, char** argv) {
    const int L = std::atoi(argv[1]), KMAX = std::atoi(argv[2]), T = std::atoi(argv[3]);
    std::vector<std::vector<int>> words;
    for (int n = 1; n <= L; ++n)
        for (u64 x = 0; x < (1ULL << n); ++x) {
            std::vector<int> w(n);
            for (int i = 0; i < n; ++i) w[i] = (x >> (n - 1 - i)) & 1;   // most significant first
            bool lyndon = true;
            for (int s = 1; s < n && lyndon; ++s) {
                std::vector<int> r(w.begin() + s, w.end()); r.insert(r.end(), w.begin(), w.begin() + s);
                if (!(w < r)) lyndon = false;
            }
            if (lyndon) words.push_back(w);
        }
    std::vector<std::string> out(words.size());
    std::atomic<size_t> next{0};
    std::vector<std::thread> pool;
    for (int k = 0; k < T; ++k) pool.emplace_back([&] {
        for (size_t i; (i = next.fetch_add(1)) < words.size();) {
            const auto& w = words[i];
            std::string s;
            for (int a : w) s.push_back('0' + a);
            int least = -1; Result last{};
            for (int K = 1; K <= KMAX; ++K) {
                Result r = test(w, K);
                last = r;
                if (r.cert) { least = K; break; }
            }
            char buf[200];
            if (least > 0) std::snprintf(buf, sizeof buf, "%s %zu %d", s.c_str(), w.size(), least);
            else std::snprintf(buf, sizeof buf, "%s %zu - ambiguous_phase %d limit_states %zu", s.c_str(), w.size(), last.ambPhase, last.ambSize);
            out[i] = buf;
        }
    });
    for (auto& th : pool) th.join();
    for (auto& s : out) std::printf("%s\n", s.c_str());
    return 0;
}
