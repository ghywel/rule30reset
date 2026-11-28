/* K92.4, claudeM5 (M233): an independent check of the modulus-two certificates, written apart from
 * claudeM5_any_period_strips.cpp after its runs.
 *
 * Differences from the first program: Rule 30 is evaluated cell by cell (new = left XOR (self OR right)); the graph
 * is built explicitly with its reverse; components come from Kosaraju's two passes instead of Tarjan; and the test
 * is the stricter lag-two property of ModulusStrip.Good: in every nontrivial component some adjacent pair (bits
 * j, j + 1) reads the same at u and w for every two-step walk u -> v -> w inside the component. In a strongly
 * connected graph every walk of even length splits into two-step walks, so this makes the pair constant on each
 * parity class, and every run that ends in the component repeats the pair at lag two. A component with no such pair
 * is then tested with any period: its period d from breadth-first levels, and a pair constant on each class mod d
 * (a cycle of length four or eight passes this and not the lag-two test; Jen's theorem needs only some period).
 *
 * Usage: lag2_verify ASSIGNMENT     (west cell first, 0 = even ticks, 1 = odd ticks)
 *        lag2_verify cover W FILE   every normalized width-W assignment contains, as a window and up to a global flip,
 *                                   one of the assignments listed in FILE (one per line)
 * Output: "verify ASSIGNMENT: ... certified at lag two", "certified with any period" or "not certified".
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int W;
static unsigned char par[64];

static uint32_t step(uint32_t r, int zw, int ze) {
    uint32_t d = 0;
    for (int i = 0; i < W; ++i) {
        int left = (i == 0) ? zw : (int)((r >> (i - 1)) & 1);
        int self = (int)((r >> i) & 1);
        int right = (i == W - 1) ? ze : (int)((r >> (i + 1)) & 1);
        if (left ^ (self | right)) d |= 1u << i;
    }
    return d;
}

static int verify(const char* a) {
    W = (int)strlen(a);
    for (int i = 0; i < W; ++i) par[i] = (unsigned char)(a[i] - '0');
    const int64_t S = (int64_t)1 << W, N = 2 * S;     /* node = 2 * row + phase */
    int32_t* succ = malloc(sizeof(int32_t) * 4 * N);
    for (int64_t v = 0; v < N; ++v) {
        uint32_t r = (uint32_t)(v >> 1); int p = (int)(v & 1);
        for (int k = 0; k < 4; ++k) {
            uint32_t d = step(r, k >> 1, k & 1);
            int ok = 1;
            for (int i = 0; i < W && ok; ++i)
                if (((r >> i) & 1) && !((d >> i) & 1) && par[i] != p) ok = 0;   /* a fall at a forbidden phase */
            succ[4 * v + k] = ok ? (int32_t)(2 * (int64_t)d + (1 - p)) : -1;
        }
    }
    /* reverse graph, compressed */
    int32_t* deg = calloc((size_t)N + 1, sizeof(int32_t));
    for (int64_t e = 0; e < 4 * N; ++e) if (succ[e] >= 0) ++deg[succ[e] + 1];
    for (int64_t v = 0; v < N; ++v) deg[v + 1] += deg[v];
    int32_t* pred = malloc(sizeof(int32_t) * (size_t)(deg[N] + 1));
    int32_t* fill = malloc(sizeof(int32_t) * (size_t)N);
    memcpy(fill, deg, sizeof(int32_t) * (size_t)N);
    for (int64_t e = 0; e < 4 * N; ++e) if (succ[e] >= 0) pred[fill[succ[e]]++] = (int32_t)(e / 4);
    /* pass 1: finishing order on the forward graph */
    char* seen = calloc((size_t)N, 1);
    int32_t* order = malloc(sizeof(int32_t) * (size_t)N);
    int32_t* stk = malloc(sizeof(int32_t) * (size_t)N);
    unsigned char* it = calloc((size_t)N, 1);
    int64_t no = 0;
    for (int64_t s = 0; s < N; ++s) {
        if (seen[s]) continue;
        int64_t top = 0; stk[top++] = (int32_t)s; seen[s] = 1;
        while (top) {
            int32_t v = stk[top - 1];
            if (it[v] < 4) {
                int32_t w = succ[4 * (int64_t)v + it[v]++];
                if (w >= 0 && !seen[w]) { seen[w] = 1; stk[top++] = w; }
            } else { order[no++] = v; --top; }
        }
    }
    /* pass 2: components on the reverse graph, in decreasing finishing time */
    int32_t* comp = malloc(sizeof(int32_t) * (size_t)N);
    for (int64_t v = 0; v < N; ++v) comp[v] = -1;
    int32_t nc = 0, nontrivial = 0, bad = 0, lagLonger = 0;
    int64_t maxLag = 0;
    int32_t* members = malloc(sizeof(int32_t) * (size_t)N);
    int32_t* lev = malloc(sizeof(int32_t) * (size_t)N);
    for (int64_t i = N - 1; i >= 0; --i) {
        int32_t s = order[i];
        if (comp[s] != -1) continue;
        int64_t top = 0, nm = 0; stk[top++] = s; comp[s] = nc;
        while (top) {
            int32_t v = stk[--top]; members[nm++] = v;
            for (int32_t q = deg[v]; q < deg[v + 1]; ++q) { int32_t u = pred[q]; if (comp[u] == -1) { comp[u] = nc; stk[top++] = u; } }
        }
        int nontriv = nm > 1;
        if (!nontriv) for (int k = 0; k < 4; ++k) if (succ[4 * (int64_t)s + k] == s) nontriv = 1;
        if (nontriv) {
            ++nontrivial;
            int found = 0;
            for (int j = 0; j + 1 < W && !found; ++j) {
                int ok = 1;
                for (int64_t m = 0; m < nm && ok; ++m) {
                    int32_t u = members[m];
                    for (int k = 0; k < 4 && ok; ++k) {
                        int32_t v = succ[4 * (int64_t)u + k];
                        if (v < 0 || comp[v] != nc) continue;
                        for (int l = 0; l < 4 && ok; ++l) {
                            int32_t w = succ[4 * (int64_t)v + l];
                            if (w < 0 || comp[w] != nc) continue;
                            if ((((uint32_t)u >> 1 >> j) & 3) != (((uint32_t)w >> 1 >> j) & 3)) ok = 0;
                        }
                    }
                }
                if (ok) found = 1;
            }
            if (!found) {   /* fall back to any period: BFS levels, the period d, a pair constant on each class mod d */
                int64_t qh = 0, qt = 0, d = 0;
                for (int64_t m = 0; m < nm; ++m) lev[members[m]] = -1;
                lev[members[0]] = 0; stk[qt++] = members[0];
                while (qh < qt) {
                    int32_t v = stk[qh++];
                    for (int k = 0; k < 4; ++k) {
                        int32_t w = succ[4 * (int64_t)v + k];
                        if (w < 0 || comp[w] != nc) continue;
                        if (lev[w] < 0) { lev[w] = lev[v] + 1; stk[qt++] = w; }
                        else { int64_t g = lev[v] + 1 - lev[w]; if (g < 0) g = -g; while (g) { int64_t t = d % g; d = g; g = t; } }
                    }
                }
                int rigid = 0;
                int* cls = malloc(sizeof(int) * (size_t)d);
                for (int j = 0; j + 1 < W && !rigid; ++j) {
                    for (int64_t c = 0; c < d; ++c) cls[c] = -1;
                    int ok = 1;
                    for (int64_t m = 0; m < nm && ok; ++m) {
                        int32_t v = members[m]; int rd = (int)(((uint32_t)v >> 1 >> j) & 3);
                        int* s = &cls[lev[v] % d];
                        if (*s < 0) *s = rd; else if (*s != rd) ok = 0;
                    }
                    if (ok) rigid = 1;
                }
                free(cls);
                if (rigid) { ++lagLonger; if (d > maxLag) maxLag = d; } else ++bad;
            }
        }
        ++nc;
    }
    printf("verify %s: components %d nontrivial %d, rigid only at a longer lag %d (largest %lld), with no rigid pair %d: %s\n",
           a, nc, nontrivial, lagLonger, (long long)maxLag, bad,
           bad ? "not certified" : (lagLonger ? "certified with any period" : "certified at lag two"));
    free(succ); free(deg); free(pred); free(fill); free(seen); free(order); free(stk); free(it); free(comp); free(members);
    free(lev);
    return bad == 0;
}

/* coverage: does every normalized width-Wc assignment contain a listed assignment as a window, up to a flip? */
static int cover(int Wc, const char* file) {
    FILE* f = fopen(file, "r");
    if (!f) { perror(file); return 0; }
    char line[128];
    int n = 0; int len[256]; uint32_t bits[256];
    while (fgets(line, sizeof line, f)) {
        int L = (int)strcspn(line, "\r\n");
        if (L == 0) continue;
        uint32_t b = 0;
        for (int i = 0; i < L; ++i) if (line[i] == '1') b |= 1u << i;
        len[n] = L; bits[n] = b; ++n;
    }
    fclose(f);
    int64_t missing = 0, total = (int64_t)1 << (Wc - 1);
    for (int64_t x = 0; x < total; ++x) {
        uint32_t a = (uint32_t)x << 1;   /* bit 0 (the west cell) is 0 */
        int hit = 0;
        for (int p = 0; p < n && !hit; ++p) {
            uint32_t M = (len[p] == 32) ? 0xffffffffu : ((1u << len[p]) - 1);
            for (int o = 0; o + len[p] <= Wc && !hit; ++o) {
                uint32_t win = (a >> o) & M;
                if (win == bits[p] || (win ^ M) == bits[p]) hit = 1;
            }
        }
        if (!hit) { if (missing < 5) printf("uncovered: %llx\n", (unsigned long long)a); ++missing; }
    }
    printf("cover width %d: %lld normalized assignments, %lld uncovered by %d listed assignments\n", Wc,
           (long long)total, (long long)missing, n);
    return missing == 0;
}

int main(int argc, char** argv) {
    if (argc == 2) return verify(argv[1]) ? 0 : 2;
    if (argc == 4 && !strcmp(argv[1], "cover")) return cover(atoi(argv[2]), argv[3]) ? 0 : 2;
    fprintf(stderr, "usage: lag2_verify ASSIGNMENT | lag2_verify cover W FILE\n");
    return 1;
}
