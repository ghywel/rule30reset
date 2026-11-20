// claudeCloud_r3_void_gaps.c: pull R3, first block (ledger K34). Do changes between the 3-gap and the 5-gap spend
// seed bits?
//
// Frame (kit Rule30ZeroCoastBridge): a seed y is a left row as an integer, bit i = depth i + 1;
// F y = (y >> 1) xor (y or (y << 1)); the trace is bit 0 of F^t y. The gap language accepts a trace that is white
// at tick 0, black at odd ticks, and at even ticks follows the gap clock: a white cell (a reset) is allowed after 3
// free steps and forced after 5. A trace prefix of n ticks fixes seed bits 0..n-1, one bit per tick (the seed bit
// "emitted" at tick t is bit t). The anti-diagonal recursion that builds the seed from the trace is placego's
// local_q01core_frontier.step_depth (L1673), rewritten here in C on 256-bit integers.
//
// What is recorded, for every accepted trace to K free steps:
//   1. WINDOWS: at every reset, the number of black seed bits emitted during the last one, two and three gaps, by
//      the gap pattern (3, 5; 33, 35, 53, 55; 333 ... 555).
//   2. VOID PHASES: for every finite seed (a prefix whose last bit is black), extend with white seed bits only
//      (the kit's Void orbit) until the trace is refused. Recorded: how many ticks it lasts, the gaps completed
//      wholly inside it, and how many times the gap length changes there.
//   3. TWO ORDERS: at every reset to K2 free steps, the 16 seed bits emitted by the extensions 3,5 and 5,3.
// usage: claudeCloud_r3_void_gaps K K2 SPLIT WORKERS ID     (one JSON object on stdout)
//        the tree is split at free step SPLIT; worker ID of WORKERS takes every WORKERS-th subtree.
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NL 6                                // 64-bit limbs: 384-bit integers
typedef struct { uint64_t w[NL]; } U;

static inline U mask_n(int n) {            // the low n bits set, 0 <= n <= 64 * NL
    U m; for (int i = 0; i < NL; i++) { int lo = i * 64; m.w[i] = n >= lo + 64 ? ~0ULL : (n > lo ? ((1ULL << (n - lo)) - 1) : 0); }
    return m;
}
static inline int parity(U x) { uint64_t v = 0; for (int i = 0; i < NL; i++) v ^= x.w[i]; return __builtin_parityll(v); }
static inline U shl1(U x) { U r; r.w[0] = x.w[0] << 1; for (int i = 1; i < NL; i++) r.w[i] = (x.w[i] << 1) | (x.w[i - 1] >> 63); return r; }
static inline uint64_t pfx64(uint64_t x) { x ^= x << 1; x ^= x << 2; x ^= x << 4; x ^= x << 8; x ^= x << 16; x ^= x << 32; return x; }
static inline U pxor(U p, int m) {         // bit i of the result is the xor of bits 0..i of p; low m bits kept
    U r; int carry = 0;
    for (int i = 0; i < NL; i++) { uint64_t v = pfx64(p.w[i]); if (carry) v = ~v; carry ^= __builtin_parityll(p.w[i]); r.w[i] = v; }
    U mk = mask_n(m); for (int i = 0; i < NL; i++) r.w[i] &= mk.w[i];
    return r;
}
// Given the anti-diagonals D_n and D_(n-1) and the trace bit c at tick n: the seed bit n and D_(n+1).
static inline int step_depth(U Dn, U Dn1, int n, int c, U *out) {
    U X, mk = mask_n(n);
    for (int i = 0; i < NL; i++) X.w[i] = (Dn.w[i] | Dn1.w[i]) & mk.w[i];
    int r = c ^ parity(X);
    U y = shl1(X); y.w[0] |= (uint64_t)r;
    *out = pxor(y, n + 1);
    return r;
}
// The same with the seed bit given as white: returns the trace bit at tick n.
static inline int step_void(U Dn, U Dn1, int n, U *out) {
    U X, mk = mask_n(n);
    for (int i = 0; i < NL; i++) X.w[i] = (Dn.w[i] | Dn1.w[i]) & mk.w[i];
    int c = parity(X);
    *out = pxor(shl1(X), n + 1);
    return c;
}

#define MAXT (64 * NL)
static int K, K2, SPLIT, WORKERS, ID;
static long split_counter = 0;
static long words_at[MAXT];                 // accepted traces by length in ticks
static long hist1[2][16], hist2[4][24], hist3[8][32];
static int min1[2], min2[4], min3[8];
static long seeds = 0, void_hist[MAXT], void_gaps_hist[16], void_changes_hist[8], void_changes_b_hist[8];
static int maxvoid_by_support[MAXT], minpop_by_changes[8], minsupp_by_changes[8];
static long overflow = 0;
static int record_void = 3;
static long xor_seen_count = 0, two_orders = 0, hamming_hist[17], popdiff_hist[33];
static uint8_t xor_seen[65536];
#define NEX 6
static struct { int kind, support, pop, voidlen, ngaps; int gaps[12]; U seed; } ex[64];
static int nex = 0, ex_kind_count[8];

static void add_example(int kind, int support, int pop, int voidlen, int ngaps, const int *gaps, U seed) {
    if (ex_kind_count[kind] >= (kind == 5 ? 24 : NEX) || nex >= 64) return;
    ex_kind_count[kind]++;
    ex[nex].kind = kind; ex[nex].support = support; ex[nex].pop = pop; ex[nex].voidlen = voidlen; ex[nex].ngaps = ngaps;
    for (int i = 0; i < ngaps && i < 12; i++) ex[nex].gaps[i] = gaps[i];
    ex[nex].seed = seed; nex++;
}

// The Void phase of the finite seed whose last black bit is bit n-1: state at tick n.
static void void_phase(int n, U Dn, U Dn1, int age, int last_reset, int pop, U seed, int prev_gap) {
    int t = n, a = age, vg[12], nvg = 0, bgap = 0, lr = last_reset;
    int since = (t - lr) / 2;                 // not used for the clock: the age carries it
    (void)since;
    for (;;) {
        if (t >= MAXT - 1) { overflow++; break; }
        U Dnext; int c = step_void(Dn, Dn1, t, &Dnext);
        if (t & 1) { if (!c) break; }
        else {
            if (c) { if (a == 4) break; a++; }
            else {
                if (a != 2 && a != 4) break;
                int g = a == 2 ? 3 : 5;
                if (lr >= n - 1) { if (nvg < 12) vg[nvg++] = g; } else bgap = g;   // a gap wholly in the Void phase, or the one in progress
                lr = t; a = 0;
            }
        }
        Dn1 = Dn; Dn = Dnext; t++;
    }
    int v = t - n;
    seeds++; void_hist[v]++;
    if (v > maxvoid_by_support[n]) maxvoid_by_support[n] = v;
    if (v > record_void) { record_void = v; add_example(5, n, pop, v, nvg, vg, seed); }   // each new longest Void phase
    void_gaps_hist[nvg < 15 ? nvg : 15]++;
    int ch = 0; for (int i = 0; i + 1 < nvg; i++) ch += vg[i] != vg[i + 1];
    int chb = ch + (bgap && nvg > 0 && bgap != vg[0]) ;
    if (!bgap && prev_gap && nvg > 0 && lr >= 0) { /* the phase began exactly at a reset: no gap in progress */ }
    void_changes_hist[ch < 7 ? ch : 7]++; void_changes_b_hist[chb < 7 ? chb : 7]++;
    int k = ch < 7 ? ch : 7;
    if (pop < minpop_by_changes[k]) minpop_by_changes[k] = pop;
    if (n < minsupp_by_changes[k]) minsupp_by_changes[k] = n;
    if (ch >= 2) add_example(2, n, pop, v, nvg, vg, seed);
    else if (ch == 1) add_example(1, n, pop, v, nvg, vg, seed);
    if (v >= 24) add_example(3, n, pop, v, nvg, vg, seed);
    if (nvg >= 3) add_example(4, n, pop, v, nvg, vg, seed);
}

// The 16 seed bits emitted by the gap pairs 3,5 and 5,3 from a reset at tick n-1 (state at tick n, age 0).
static void two_orders_at(int n, U Dn, U Dn1) {
    static const int order[2][2] = {{3, 5}, {5, 3}};
    int bits[2] = {0, 0};
    for (int o = 0; o < 2; o++) {
        U a = Dn, b = Dn1; int t = n, w = 0, i = 0;
        for (int gi = 0; gi < 2; gi++) {
            int g = order[o][gi];
            for (int fs = 1; fs <= g; fs++) {
                U nx; int r = step_depth(a, b, t, 1, &nx); w |= r << i++; b = a; a = nx; t++;          // an odd tick: black
                r = step_depth(a, b, t, fs == g ? 0 : 1, &nx); w |= r << i++; b = a; a = nx; t++;      // an even tick
            }
        }
        bits[o] = w;
    }
    int x = bits[0] ^ bits[1];
    two_orders++;
    if (!xor_seen[x]) { xor_seen[x] = 1; xor_seen_count++; }
    hamming_hist[__builtin_popcount(x)]++;
    popdiff_hist[16 + __builtin_popcount(bits[0]) - __builtin_popcount(bits[1])]++;
}

// The node: ticks 0..n-1 fixed; n is the next tick. s = free steps done. gaps[0..ng-1], cp[i] = black seed bits
// emitted up to and including the i-th reset (cp[0] is the reset at tick 0).
static int gaps[MAXT], cp[MAXT];
static void rec(int n, U Dn, U Dn1, int age, int s, int pop, int ng, int last_reset, U seed) {
    words_at[n]++;
    if (s >= K) return;
    if (n + 2 >= MAXT - 40) { overflow++; return; }
    if (s == SPLIT) { long idx = split_counter++; if (idx % WORKERS != ID) return; }
    if (age == 0 && s <= K2 && s >= 1) two_orders_at(n, Dn, Dn1);
    // tick n is odd: black
    U D1; int r1 = step_depth(Dn, Dn1, n, 1, &D1);
    U seed1 = seed; if (r1) seed1.w[n >> 6] |= 1ULL << (n & 63);
    int pop1 = pop + r1;
    if (r1) void_phase(n + 1, D1, Dn, age, last_reset, pop1, seed1, ng ? gaps[ng - 1] : 0);
    // tick n+1 is even: the choices of the gap clock
    for (int reset = 0; reset < 2; reset++) {
        if (reset ? (age != 2 && age != 4) : (age == 4)) continue;
        U D2; int r2 = step_depth(D1, Dn, n + 1, reset ? 0 : 1, &D2);
        U seed2 = seed1; if (r2) seed2.w[(n + 1) >> 6] |= 1ULL << ((n + 1) & 63);
        int pop2 = pop1 + r2, age2 = reset ? 0 : age + 1, ng2 = ng, lr2 = last_reset;
        if (reset) {
            gaps[ng] = age == 2 ? 3 : 5; cp[ng + 1] = pop2; ng2 = ng + 1; lr2 = n + 1;
            int g1 = gaps[ng] == 5;
            int w = cp[ng2] - cp[ng2 - 1]; hist1[g1][w < 15 ? w : 15]++; if (w < min1[g1]) min1[g1] = w;
            if (ng2 >= 2) { int p = (gaps[ng - 1] == 5) * 2 + g1; w = cp[ng2] - cp[ng2 - 2]; hist2[p][w < 23 ? w : 23]++; if (w < min2[p]) min2[p] = w; }
            if (ng2 >= 3) { int p = (gaps[ng - 2] == 5) * 4 + (gaps[ng - 1] == 5) * 2 + g1; w = cp[ng2] - cp[ng2 - 3]; hist3[p][w < 31 ? w : 31]++; if (w < min3[p]) min3[p] = w; }
        }
        if (r2) void_phase(n + 2, D2, D1, age2, lr2, pop2, seed2, ng2 ? gaps[ng2 - 1] : 0);
        rec(n + 2, D2, D1, age2, s + 1, pop2, ng2, lr2, seed2);
    }
}

static void print_arr(const char *name, const long *a, int n, int last) {
    printf("\"%s\": [", name); for (int i = 0; i < n; i++) printf("%s%ld", i ? ", " : "", a[i]); printf("]%s", last ? "" : ", ");
}

int main(int argc, char **argv) {
    if (argc < 6) { fprintf(stderr, "usage: K K2 SPLIT WORKERS ID\n"); return 2; }
    K = atoi(argv[1]); K2 = atoi(argv[2]); SPLIT = atoi(argv[3]); WORKERS = atoi(argv[4]); ID = atoi(argv[5]);
    for (int i = 0; i < 2; i++) min1[i] = 99; for (int i = 0; i < 4; i++) min2[i] = 99; for (int i = 0; i < 8; i++) min3[i] = 99;
    for (int i = 0; i < 8; i++) { minpop_by_changes[i] = 9999; minsupp_by_changes[i] = 9999; }
    // tick 0 is white
    U zero; memset(&zero, 0, sizeof zero); U D1; int r0 = step_depth(zero, zero, 0, 0, &D1);
    if (r0) { fprintf(stderr, "root seed bit is black\n"); return 1; }
    cp[0] = 0;
    rec(1, D1, zero, 0, 0, 0, 0, 0, zero);
    printf("{\"K\": %d, \"K2\": %d, \"split\": %d, \"workers\": %d, \"id\": %d, \"overflow\": %ld, \"seeds\": %ld, ", K, K2, SPLIT, WORKERS, ID, overflow, seeds);
    print_arr("words_at", words_at, MAXT, 0);
    printf("\"hist1\": {"); for (int p = 0; p < 2; p++) { char nm[8]; snprintf(nm, 8, "%d", p ? 5 : 3); print_arr(nm, hist1[p], 16, p == 1); } printf("}, ");
    printf("\"hist2\": {"); for (int p = 0; p < 4; p++) { char nm[8]; snprintf(nm, 8, "%d%d", p & 2 ? 5 : 3, p & 1 ? 5 : 3); print_arr(nm, hist2[p], 24, p == 3); } printf("}, ");
    printf("\"hist3\": {"); for (int p = 0; p < 8; p++) { char nm[8]; snprintf(nm, 8, "%d%d%d", p & 4 ? 5 : 3, p & 2 ? 5 : 3, p & 1 ? 5 : 3); print_arr(nm, hist3[p], 32, p == 7); } printf("}, ");
    print_arr("void_hist", void_hist, 64, 0);
    print_arr("void_gaps_hist", void_gaps_hist, 16, 0);
    print_arr("void_changes_hist", void_changes_hist, 8, 0);
    print_arr("void_changes_with_boundary_hist", void_changes_b_hist, 8, 0);
    printf("\"maxvoid_by_support\": ["); for (int i = 0; i < MAXT; i++) printf("%s%d", i ? ", " : "", maxvoid_by_support[i]); printf("], ");
    printf("\"minpop_by_changes\": ["); for (int i = 0; i < 8; i++) printf("%s%d", i ? ", " : "", minpop_by_changes[i]); printf("], ");
    printf("\"minsupport_by_changes\": ["); for (int i = 0; i < 8; i++) printf("%s%d", i ? ", " : "", minsupp_by_changes[i]); printf("], ");
    printf("\"two_orders\": %ld, \"xor_patterns\": %ld, ", two_orders, xor_seen_count);
    print_arr("hamming_hist", hamming_hist, 17, 0);
    print_arr("popdiff_hist", popdiff_hist, 33, 0);
    printf("\"xor_list\": ["); int first = 1; for (int x = 0; x < 65536 && xor_seen_count <= 64; x++) if (xor_seen[x]) { printf("%s%d", first ? "" : ", ", x); first = 0; } printf("], ");
    printf("\"examples\": [");
    for (int i = 0; i < nex; i++) {
        printf("%s{\"kind\": %d, \"support\": %d, \"pop\": %d, \"void\": %d, \"gaps\": [", i ? ", " : "", ex[i].kind, ex[i].support, ex[i].pop, ex[i].voidlen);
        for (int j = 0; j < ex[i].ngaps; j++) printf("%s%d", j ? ", " : "", ex[i].gaps[j]);
        printf("], \"seed\": \""); for (int j = NL - 1; j >= 0; j--) printf("%016llx", (unsigned long long)ex[i].seed.w[j]); printf("\"}");
    }
    printf("]}\n");
    return 0;
}
