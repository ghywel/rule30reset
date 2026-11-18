// Pull M29 (M41): every white excursion whose source column has least period P, all phases at once.
//
// At a permanent white wheel A the two previous columns are equal, b = D(A-1) = D(A-2), and the next column has two
// lifts, c(t+1) = b(t) xor c(t). If b has an odd number of black ticks per period P (an odd source) the lifts have
// period 2P and are each other's shift by P: a period doubling. Otherwise both have period P. Every later column up
// to the next white B is the unique periodic lift c(t+1) = a(t) xor (b(t) or c(t)) of its two predecessors.
// For each necklace class of b (Lyndon words of length P, so least period exactly P) and each lift, the excursion is
// run from A with all T = 2P ticks tracked at once: a tick is done when its row has closed a black run of length 1
// mod 3 with both white endpoints in [A, B]. The excursion stops when every tick is done, at the next white B (the
// ticks not done are reset-free whole intervals), or at the cutoff. Pointed counts (gptM5's 'lifts' and 'marked
// phase') follow from the necklace counts: rotating b by r and choosing a lift is phase r of the representative.
// A reset-free excursion is followed backwards, D(j-2)(t) = D(j)(t+1) xor (D(j-1)(t) or D(j)(t)), from (b, white):
// it is rooted if it reaches two white wheels (the zero exterior beyond a black edge), unrooted if it cycles first.
// Control: P = 1, 2, 4, 8, 16 reproduce R38/R44's table, 0, 0, 2, 4 and 33 reset-free whole intervals among 2, 4, 24,
// 480 and 130,560 pointed lifts, none doubling, none rooted, every lift resolved by wheel 72 beyond A. The
// bit-parallel lift is checked against a bit-serial one on random columns; the two lifts of an odd source give the
// same reset-free ticks shifted by P.
// Predictions (written before the run): at P = 32 no odd source has a reset-free excursion in any phase (80%); every
// excursion resolves within 200 wheels of A (80%); any reset-free excursion found is unrooted (90%). Kill (for the
// doubling route at this period): a rooted odd-source excursion with a reset-free phase.
// Usage: claudeM5_doubling_census P [threads]       (prints one JSON object)
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef uint64_t U;
static int P, T, NTH = 1;
static U M;
#define CUTOFF 65536
#define ROOT_LIMIT 2000000

static inline U rotl(U x, int d) {            // bit t of the result = bit (t - d) of x: a time shift forward by d
    d %= T;
    if (!d) return x;
    return ((x << d) | (x >> (T - d))) & M;
}

static inline U child(U a, U b) {              // the unique T-periodic c(t+1) = a(t) ^ (b(t) | c(t)), b != 0
    U S = a, f = b;                            // segmented xor-scan from each black tick of b
    for (int d = 1; d < T; d <<= 1) {
        U s2 = rotl(S, d) & ~f, f2 = rotl(f, d);
        S ^= s2;
        f |= f2;
    }
    return rotl(~S & M, 1);
}

static U child_serial(U a, U b) {
    int t0 = 0;
    while (!((b >> t0) & 1)) t0++;
    int c[64];
    int t = (t0 + 1) % T;
    c[t] = !((a >> t0) & 1);
    for (int k = 0; k < T - 1; k++) {
        int n = (t + 1) % T;
        c[n] = (((a >> t) & 1) ^ (((b >> t) & 1) | c[t]));
        t = n;
    }
    U r = 0;
    for (int i = 0; i < T; i++) r |= (U)c[i] << i;
    return r;
}

static U first_lift(U bb, int c0) {           // c(t+1) = bb(t) ^ c(t), c(0) = c0
    U r = 0;
    int c = c0;
    for (int t = 0; t < T; t++) {
        r |= (U)c << t;
        c ^= (bb >> t) & 1;
    }
    return r;
}

typedef struct { U bad; int gap; int status; } Exc;   // status 0 covered, 1 white, 2 cutoff

static Exc excursion(U bb, int c0, int *cover_wheel) {
    Exc e = {0, 0, 0};
    U a = 0, b = first_lift(bb, c0);           // columns at A and A+1
    U r1 = 0, r2 = 0, done = 0;
    for (int j = 1;; j++) {                    // b is the column at A + j
        U c = b;
        U rs = r1 & ~c;
        done |= rs;
        U n1 = c & ~(r1 | r2), n2 = c & r1;
        r1 = n1; r2 = n2;
        if (done == M) { e.status = 0; *cover_wheel = j; return e; }
        if (c == 0) { e.status = 1; e.bad = M & ~done; e.gap = j; return e; }
        if (j >= CUTOFF) { e.status = 2; e.bad = M & ~done; e.gap = j; return e; }
        U nx = child(a, b);
        a = b; b = nx;
    }
}

static long long rooted_distance(U bb) {      // backward from (D(A-1), D(A)) = (bb, 0); -1 cycle, -2 limit
    U x = bb, y = 0;                           // (D(j-1), D(j))
    U px = x, py = y;                          // Brent
    long long power = 1, lam = 0;
    for (long long s = 1; s <= ROOT_LIMIT; s++) {
        U prev = (((y >> 1) | (y << (T - 1))) & M) ^ (x | y);
        y = x; x = prev;
        if (x == 0 && y == 0) return s;
        lam++;
        if (x == px && y == py) return -1;
        if (lam == power) { px = x; py = y; power <<= 1; lam = 0; }
    }
    return -2;
}

typedef struct {
    int tid;
    long long lyndon, pointed, bad_odd, bad_even, unknown, odd_lyndon, even_lyndon, lift_shift_fail;
    long long rooted_bad, unrooted_bad, limit_bad;
    int max_cover;
    char sample[4096];
    int slen;
} Work;

typedef struct { Work *w; int n; int a[80]; long long idx; } Gen;

static void visit(Gen *g) {
    Work *w = g->w;
    long long my = g->idx++;
    if (my % NTH != w->tid) return;
    U word = 0;
    for (int i = 1; i <= P; i++) word |= (U)g->a[i] << (i - 1);
    if (!word) return;
    w->lyndon++;
    w->pointed += 2LL * P;
    int odd = __builtin_popcountll(word) & 1;
    U bb = (word | (word << P)) & M;
    if (odd) {
        w->odd_lyndon++;
        int cw0 = 0, cw1 = 0;
        Exc e0 = excursion(bb, 0, &cw0), e1 = excursion(bb, 1, &cw1);
        if (e0.status != e1.status || e1.bad != rotl(e0.bad, P)) w->lift_shift_fail++;
        if (e0.status == 0) { if (cw0 > w->max_cover) w->max_cover = cw0; }
        else if (e0.status == 2) w->unknown++;
        else {
            int nb = __builtin_popcountll(e0.bad);
            if (nb) {
                w->bad_odd += nb;
                long long r = rooted_distance(bb);
                if (r >= 0) w->rooted_bad++; else if (r == -1) w->unrooted_bad++; else w->limit_bad++;
                if (w->slen < 3800)
                    w->slen += snprintf(w->sample + w->slen, 4096 - w->slen,
                        "%s{\"b\":\"%llx\",\"odd\":1,\"bad\":\"%llx\",\"gap\":%d,\"root\":%lld}",
                        w->slen ? "," : "", (unsigned long long)word, (unsigned long long)e0.bad, e0.gap, r);
            }
        }
    } else {
        w->even_lyndon++;
        for (int c0 = 0; c0 < 2; c0++) {
            int cw = 0;
            Exc e = excursion(bb, c0, &cw);
            if (e.status == 0) { if (cw > w->max_cover) w->max_cover = cw; }
            else if (e.status == 2) w->unknown++;
            else {
                U low = (P == 64) ? M : ((1ULL << P) - 1);
                int nb = __builtin_popcountll(e.bad & low);
                if (e.bad != rotl(e.bad, P)) w->lift_shift_fail++;   // P-periodic: symmetric under a shift by P
                if (nb) {
                    w->bad_even += nb;
                    long long r = rooted_distance(bb);
                    if (r >= 0) w->rooted_bad++; else if (r == -1) w->unrooted_bad++; else w->limit_bad++;
                    if (w->slen < 3800)
                        w->slen += snprintf(w->sample + w->slen, 4096 - w->slen,
                            "%s{\"b\":\"%llx\",\"odd\":0,\"c0\":%d,\"bad\":\"%llx\",\"gap\":%d,\"root\":%lld}",
                            w->slen ? "," : "", (unsigned long long)word, c0, (unsigned long long)(e.bad & low), e.gap, r);
                }
            }
        }
    }
}

static void fkm(Gen *g, int t, int p) {       // binary necklaces (FKM); Lyndon words when p == n
    if (t > g->n) {
        if (p == g->n) visit(g);
        return;
    }
    g->a[t] = g->a[t - p];
    fkm(g, t + 1, p);
    if (g->a[t - p] == 0) {
        g->a[t] = 1;
        fkm(g, t + 1, t);
    }
}

static void *run(void *arg) {
    Work *w = (Work *)arg;
    Gen g;
    memset(&g, 0, sizeof g);
    g.w = w; g.n = P; g.idx = 0;
    fkm(&g, 1, 1);
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 2) return 1;
    P = atoi(argv[1]);
    if (argc > 2) NTH = atoi(argv[2]);
    T = 2 * P;
    M = (T == 64) ? ~0ULL : ((1ULL << T) - 1);
    // self-test of the bit-parallel lift
    U s = 0x9E3779B97F4A7C15ULL;
    int lift_ok = 1;
    for (int i = 0; i < 20000; i++) {
        s ^= s << 13; s ^= s >> 7; s ^= s << 17;
        U a = s & M;
        s ^= s << 13; s ^= s >> 7; s ^= s << 17;
        U b = s & M;
        if (!b) continue;
        U c = child(a, b);
        if (c != child_serial(a, b)) lift_ok = 0;
        // the defining relation
        U want = ((a ^ (b | c)));
        if (rotl(want, 1) != c) lift_ok = 0;
    }
    Work *ws = calloc(NTH, sizeof(Work));
    pthread_t *th = calloc(NTH, sizeof(pthread_t));
    for (int i = 0; i < NTH; i++) { ws[i].tid = i; pthread_create(&th[i], NULL, run, &ws[i]); }
    long long tot[11] = {0};
    int maxc = 0;
    printf("{\"P\":%d,\"T\":%d,\"lift_selftest_ok\":%s,\"bad\":[", P, T, lift_ok ? "true" : "false");
    int first = 1;
    for (int i = 0; i < NTH; i++) {
        pthread_join(th[i], NULL);
        Work *w = &ws[i];
        tot[0] += w->lyndon; tot[1] += w->pointed; tot[2] += w->bad_odd; tot[3] += w->bad_even;
        tot[4] += w->unknown; tot[5] += w->odd_lyndon; tot[6] += w->even_lyndon; tot[7] += w->lift_shift_fail;
        tot[8] += w->rooted_bad; tot[9] += w->unrooted_bad; tot[10] += w->limit_bad;
        if (w->max_cover > maxc) maxc = w->max_cover;
        if (w->slen) { printf("%s%s", first ? "" : ",", w->sample); first = 0; }
    }
    printf("],\"lyndon_nonzero\":%lld,\"pointed_lifts\":%lld,\"reset_free_pointed_odd\":%lld,"
           "\"reset_free_pointed_even\":%lld,\"cutoff_lifts\":%lld,\"odd_classes\":%lld,\"even_classes\":%lld,"
           "\"lift_shift_failures\":%lld,\"bad_rooted\":%lld,\"bad_unrooted\":%lld,\"bad_root_limit\":%lld,"
           "\"max_cover_wheel\":%d}\n",
           tot[0], tot[1], tot[2], tot[3], tot[4], tot[5], tot[6], tot[7], tot[8], tot[9], tot[10], maxc);
    return 0;
}
