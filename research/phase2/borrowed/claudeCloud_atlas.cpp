// claudeCloud_atlas.cpp: which relatives of rule 30 share its white-tail wall (ledger K98, pull K92.5).
//
// The eight elementary rules  new = left xor f(centre, right)  that keep a white row white:
//   240 (f = 0), 60 (centre), 90 (right), 150 (centre xor right),
//   120 (centre and right), 180 (centre and not right), 210 (not centre and right), 30 (centre or right).
// A *time hybrid* (A, B) applies A at even ticks and B at odd ticks.  A *space hybrid* (A, B) applies A at odd
// depths (wall frame) or even sites (line frame) and B at the others.  (A, A) is the rule A itself.
//
//   atlas wall MODE WMAX HFAST HSLOW CAP [A B]
//       The kit's zero-boundary frame (Rule30WallDeadlines.zr): depth 0 is a white wall, depth k + 1 lies beyond
//       depth k, and  new(k) = old(k + 1) xor f(old(k), old(k - 1)).  A finite row *survives* while depth 1 is black
//       at every even tick.  For every (A, B), every width w <= WMAX and every row of exact width w that is black at
//       depth 1: the first even tick at which depth 1 is white (its lifetime).  Rows alive at tick HFAST are carried
//       to tick HSLOW (the CAP smallest of them per width); rows alive there are immortal candidates.
//   atlas line MODE W0 T M PMAX [A B]
//       The whole line.  For every (A, B) and every start s with 1 <= s < 2^W0 (bit i at site i), T ticks, and
//       for each site from -M to W0 + M - 1: is its column eventually periodic with period at most PMAX, judged
//       on the last half of the run?
//
// MODE is time or space.  With A B (rule numbers) only that pair is run.  Output is one block per system.
// COMPUTED; nothing here is a proof.
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;
typedef unsigned __int128 u128;
typedef uint64_t u64;

static const int NAME[8] = {240, 60, 90, 150, 120, 180, 210, 30};

template <class T> static inline T ff(int f, T c, T r) {
    switch (f) {
        case 0: return (T)0;
        case 1: return c;
        case 2: return r;
        case 3: return c ^ r;
        case 4: return c & r;
        case 5: return c & ~r;
        case 6: return ~c & r;
        default: return c | r;
    }
}

// ---------------------------------------------------------------- wall frame
static const u128 ODD128 = (((u128)0x5555555555555555ULL) << 64) | 0x5555555555555555ULL;   // bit k even: depth k + 1 odd

static inline u128 wstep(u128 y, int fa, int fb, bool space, int tick) {
    u128 up = y >> 1, c = y, r = y << 1;
    if (space) return up ^ ((ff(fa, c, r) & ODD128) | (ff(fb, c, r) & ~ODD128));
    return up ^ ff((tick & 1) ? fb : fa, c, r);
}

struct Big {                                   // a row of any width: bit k of word j is depth 64 j + k + 1
    vector<u64> w;
    void step(int fa, int fb, bool space, int tick) {
        size_t n = w.size();
        if (n == 0 || w[n - 1] >> 62) { w.push_back(0); n++; }
        vector<u64> out(n);
        for (size_t j = 0; j < n; j++) {
            u64 c = w[j];
            u64 up = (c >> 1) | (j + 1 < n ? (w[j + 1] << 63) : 0);
            u64 r = (c << 1) | (j ? (w[j - 1] >> 63) : 0);
            u64 v;
            if (space) v = (ff(fa, c, r) & 0x5555555555555555ULL) | (ff(fb, c, r) & 0xAAAAAAAAAAAAAAAAULL);
            else v = ff((tick & 1) ? fb : fa, c, r);
            out[j] = up ^ v;
        }
        w.swap(out);
    }
};

static int ONLY_A = -1, ONLY_B = -1;      // optional: run one pair only (rule numbers)
static bool skip(int fa, int fb) { return ONLY_A >= 0 && (NAME[fa] != ONLY_A || NAME[fb] != ONLY_B); }

static void wall(bool space, int WMAX, int HFAST, int HSLOW, int CAP) {
    printf("wall frame, %s hybrids, widths 1..%d, fast horizon %d, slow horizon %d, at most %d rows per width carried\n",
           space ? "space" : "time", WMAX, HFAST, HSLOW, CAP);
    printf("columns: w | rows | longest finite lifetime (ticks) | rows that pass every check within the support, then "
           "1, 2, 4, 8 checks more | alive at %d | carried | alive at %d | least immortal candidates\n", HFAST, HSLOW);
    for (int fa = 0; fa < 8; fa++) for (int fb = 0; fb < 8; fb++) {
        if (skip(fa, fb)) continue;
        printf("\n== %s (%d, %d)\n", space ? "space" : "time", NAME[fa], NAME[fb]);
        long long totalImm = 0, totalAliveFast = 0; int worst = 0, worstw = 0;
        for (int w = 1; w <= WMAX; w++) {
            u64 lo = (w == 1) ? 1 : ((1ULL << (w - 1)) | 1), hi = (w == 1) ? 2 : (1ULL << w);
            // The cell at depth w is first read at depth 1 at tick w - 1.  Checks at even ticks <= w - 1 lie within the
            // support; `first` is the first even tick >= w, the first check made after every cell has been read.
            int first = (w % 2 == 0) ? w : w + 1;
            long long rows = 0, past[5] = {0, 0, 0, 0, 0}, aliveFast = 0; int longest = 0;
            vector<u64> carry;
            for (u64 y0 = lo; y0 < hi; y0 += 2) {
                rows++;
                u128 y = y0; int t = 0, life = -1;
                while (t < HFAST) {
                    y = wstep(y, fa, fb, space, t); t++;
                    if (t % 2 == 0 && !(y & 1)) { life = t; break; }
                }
                if (life < 0) { aliveFast++; if ((int)carry.size() < CAP) carry.push_back(y0); life = 1 << 30; }
                else if (life > longest) longest = life;
                static const int more[5] = {0, 1, 2, 4, 8};
                for (int k = 0; k < 5; k++) if (life > first - 2 + 2 * more[k]) past[k]++;
            }
            long long imm = 0; string cand;
            for (u64 y0 : carry) {
                Big b; b.w.push_back(y0); int life = -1;
                for (int t = 0; t < HSLOW; ) {
                    b.step(fa, fb, space, t); t++;
                    if (t % 2 == 0 && !(b.w[0] & 1)) { life = t; break; }
                }
                if (life < 0) { imm++; if (imm <= 4) { char buf[32]; snprintf(buf, sizeof buf, " %llu", (unsigned long long)y0); cand += buf; } }
                else if (life > longest) longest = life;
            }
            totalImm += imm; totalAliveFast += aliveFast;
            if (longest > worst) { worst = longest; worstw = w; }
            printf("%d | %lld | %d | %lld %lld %lld %lld %lld | %lld | %zu | %lld |%s\n", w, rows, longest,
                   past[0], past[1], past[2], past[3], past[4], aliveFast, carry.size(), imm, cand.c_str());
        }
        printf("summary %s (%d, %d): immortal candidates %lld; alive at %d: %lld; longest finite lifetime %d at width %d\n",
               space ? "space" : "time", NAME[fa], NAME[fb], totalImm, HFAST, totalAliveFast, worst, worstw);
        fflush(stdout);
    }
}

// ---------------------------------------------------------------- line frame
static void line(bool space, int W0, int T, int M, int PMAX) {
    int OFF = T + M + 70, NB = OFF + W0 + T + M + 70, NW = (NB + 63) / 64 + 1, NC = W0 + 2 * M;
    printf("line frame, %s hybrids, starts 1..%d, %d ticks, sites %d..%d, periods up to %d\n",
           space ? "space" : "time", (1 << W0) - 1, T, -M, W0 + M - 1, PMAX);
    printf("per system: starts with a column eventually periodic | with one that is not eventually white | "
           "with every column eventually periodic | periods seen (period:columns)\n");
    vector<u64> evenMask(NW), x(NW), nx(NW);
    for (int i = 0; i < NB; i++) if (((i - OFF) % 2 + 2) % 2 == 0) evenMask[i / 64] |= 1ULL << (i % 64);
    vector<vector<unsigned char>> col(NC, vector<unsigned char>(T + 1));
    for (int fa = 0; fa < 8; fa++) for (int fb = 0; fb < 8; fb++) {
        if (skip(fa, fb)) continue;
        long long some = 0, someBlack = 0, all = 0; vector<long long> per(PMAX + 1, 0);
        string single;
        for (int s = 1; s < (1 << W0); s++) {
            fill(x.begin(), x.end(), 0);
            for (int i = 0; i < W0; i++) if ((s >> i) & 1) x[(OFF + i) / 64] |= 1ULL << ((OFF + i) % 64);
            int lo = (OFF - 1) / 64, hi = (OFF + W0) / 64;                    // words that may be nonzero
            for (int t = 0; t <= T; t++) {
                for (int j = 0; j < NC; j++) { int p = OFF - M + j; col[j][t] = (x[p / 64] >> (p % 64)) & 1; }
                if (t == T) break;
                if (lo > 0) lo--;
                if (hi < NW - 1) hi++;
                for (int j = lo; j <= hi; j++) {
                    u64 c = x[j];
                    u64 l = (c << 1) | (j ? (x[j - 1] >> 63) : 0);            // the left neighbour of each site
                    u64 r = (c >> 1) | (j + 1 < NW ? (x[j + 1] << 63) : 0);   // the right neighbour
                    u64 v;
                    if (space) v = (ff(fa, c, r) & evenMask[j]) | (ff(fb, c, r) & ~evenMask[j]);
                    else v = ff((t & 1) ? fb : fa, c, r);
                    nx[j] = l ^ v;
                }
                for (int j = lo; j <= hi; j++) x[j] = nx[j];
            }
            int nper = 0, nblack = 0;
            for (int j = 0; j < NC; j++) {
                int found = 0;
                for (int p = 1; p <= PMAX && !found; p++) {
                    bool ok = true;
                    for (int t = T / 2; t + p <= T; t++) if (col[j][t] != col[j][t + p]) { ok = false; break; }
                    if (ok) found = p;
                }
                if (found) {
                    nper++; per[found]++;
                    bool white = true;
                    for (int t = T / 2; t <= T; t++) if (col[j][t]) { white = false; break; }
                    if (!white) nblack++;
                    if (s == 1) { char buf[32]; snprintf(buf, sizeof buf, " %d:%d%s", j - M, found, white ? "w" : ""); single += buf; }
                }
            }
            if (nper) some++;
            if (nblack) someBlack++;
            if (nper == NC) all++;
        }
        printf("%s (%d, %d): %lld | %lld | %lld |", space ? "space" : "time", NAME[fa], NAME[fb], some, someBlack, all);
        for (int p = 1; p <= PMAX; p++) if (per[p]) printf(" %d:%lld", p, per[p]);
        printf(" | single cell, site:period (w = white):%s\n", single.empty() ? " none" : single.c_str());
        fflush(stdout);
    }
}

int main(int argc, char **argv) {
    if (argc >= 9) { ONLY_A = atoi(argv[7]); ONLY_B = atoi(argv[8]); }
    if (argc >= 7 && !strcmp(argv[1], "wall"))
        wall(!strcmp(argv[2], "space"), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]));
    else if (argc >= 7 && !strcmp(argv[1], "line"))
        line(!strcmp(argv[2], "space"), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]));
    else { fprintf(stderr, "usage: atlas wall MODE WMAX HFAST HSLOW CAP | atlas line MODE W0 T M PMAX\n"); return 2; }
    return 0;
}
