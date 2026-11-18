// Pull M29 (M42): the white-interval graph at each gap, for every temporal period at once.
//
// Between permanent whites A and B = A + n the rows w (bit i = wheel A + i, bits 0..n) have w0 = wn = 0, w2 = 1 (the
// latched black two beyond a white) and w(n-2) = w(n-1) (the two wheels before a white agree, so B stays white).
// One tick maps w to w'(j) = w(j-2) xor (w(j-1) or w(j)) for j >= 2, w'(0) = 0, and w'(1) = e xor w(1) with the
// external bit e = D(A-1)(t) free. A periodic excursion of gap n, of any period, is a closed walk in this graph G_n.
// A row is bad when it is reset-free: no closed black run of length 1 mod 3 inside [A, B].
//   (G) at gap n: an excursion whose wheels strictly between A and B are never all white over the orbit lies in a
//       strongly connected component whose rows, OR-ed, cover bits 1..n-1 (a whole component). bad_whole(n) = 0
//       means no whole interval of gap n is reset-free in any tick, at any period.
//   The swap test (R40): a doubling with half-period P has D(A+1)(t + P) = not D(A+1)(t) under the same external
//       bit, and returns its pair (r_s, r_(s+P)) swapped after P ticks. So a reset-free doubling needs a bad x and a
//       y with (x, y) and (y, x) in one strongly connected component of the pair graph: pairs inside one component
//       of G_n with complementary bit 1, both steps taking successors whose bit 1 stays complementary.
// Components by an iterative Tarjan. Self-checks: for n <= 12 the partition equals mutual reachability by BFS; for
// pair components of at most 4,096 nodes the swap verdict equals BFS reachability; for n <= 10 every bad row on an
// exact closed walk of length 2P with bit 1 antiperiodic (P = 1..8, found by layered BFS) is swappable.
// Usage: claudeM5_gap_audit range NMIN NMAX PAIRCAP SWAPALL_MAX   (swap test on every bad component for n <= SWAPALL_MAX,
//                                                                  on whole bad components above)
//        claudeM5_gap_audit pair n XHEX YHEX DEPTH                 (BFS from (x, y) to (y, x) in the pair graph)
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef uint64_t U;
typedef uint32_t u32;
static int n;
static u32 N;
static U rowmask;

static inline U decode(u32 id) {
    U w = ((U)(id & 1) << 1) | ((U)1 << 2) | ((U)(id >> 1) << 3);
    U b = (w >> (n - 2)) & 1;
    return w | (b << (n - 1));
}
static inline u32 encode(U w) { return (u32)(((w >> 1) & 1) | (((w >> 3) & ((1ULL << (n - 4)) - 1)) << 1)); }
static inline int legal(U w) { return !(((w >> (n - 2)) ^ (w >> (n - 1))) & 1); }
static inline int succs(U w, U out[2]) {
    U R = ((w << 2) ^ ((w << 1) | w)) & rowmask;
    if ((R >> n) & 1) { fprintf(stderr, "B turned black\n"); exit(2); }
    if (!((R >> 2) & 1)) { fprintf(stderr, "A+2 turned white\n"); exit(2); }
    R &= ~(U)3;
    int k = 0;
    for (int b = 0; b < 2; b++) {
        U x = R | ((U)b << 1);
        if (legal(x)) out[k++] = x;
    }
    return k;
}
static int reset_free(U w) {
    int j = 0;
    while (j <= n) {
        if ((w >> j) & 1) {
            int k = j;
            while (k <= n && ((w >> k) & 1)) k++;
            if ((k - j) % 3 == 1) return 0;
            j = k;
        } else j++;
    }
    return 1;
}

// ---------- generic iterative Tarjan on an implicit graph ----------
typedef int (*SuccFn)(u32 v, u32 out[4], void *ctx);
static int32_t *tarjan(u32 M, SuccFn f, void *ctx, u32 *ncomp_out, uint8_t **selfloop_out) {
    int32_t *idx = malloc(sizeof(int32_t) * M), *low = malloc(sizeof(int32_t) * M), *comp = malloc(sizeof(int32_t) * M);
    uint8_t *on = calloc(M, 1), *self = calloc(M, 1);
    u32 *S = malloc(sizeof(u32) * M), *cs = malloc(sizeof(u32) * M);
    uint8_t *ci = malloc(M);
    if (!idx || !low || !comp || !on || !self || !S || !cs || !ci) { fprintf(stderr, "oom\n"); exit(3); }
    memset(idx, 0xff, sizeof(int32_t) * M);
    int32_t counter = 0;
    u32 sp = 0, ncomp = 0;
    for (u32 r = 0; r < M; r++) {
        if (idx[r] >= 0) continue;
        u32 top = 0;
        cs[top] = r; ci[top] = 0; idx[r] = low[r] = counter++; S[sp++] = r; on[r] = 1;
        while (1) {
            u32 v = cs[top];
            u32 out[4];
            int deg = f(v, out, ctx);
            if (ci[top] < deg) {
                u32 w = out[ci[top]++];
                if (w == v) self[v] = 1;
                if (idx[w] < 0) {
                    top++; cs[top] = w; ci[top] = 0; idx[w] = low[w] = counter++; S[sp++] = w; on[w] = 1;
                } else if (on[w] && idx[w] < low[v]) low[v] = idx[w];
            } else {
                if (low[v] == idx[v]) {
                    u32 x;
                    do { x = S[--sp]; on[x] = 0; comp[x] = (int32_t)ncomp; } while (x != v);
                    ncomp++;
                }
                if (top == 0) break;
                top--;
                u32 p = cs[top];
                if (low[v] < low[p]) low[p] = low[v];
            }
        }
    }
    free(idx); free(low); free(on); free(S); free(cs); free(ci);
    *ncomp_out = ncomp;
    *selfloop_out = self;
    return comp;
}

// ---------- the base graph ----------
static int base_succ(u32 v, u32 out[4], void *ctx) {
    (void)ctx;
    U o[2];
    int k = succs(decode(v), o);
    for (int i = 0; i < k; i++) out[i] = encode(o[i]);
    return k;
}

// ---------- the pair graph inside one component ----------
typedef struct {
    u32 *Lm, *Rm, nL, nR;      // members with bit 1 = 1 (L) and = 0 (R)
    u32 *loc;                  // node -> local index in L or R
    int32_t *comp; int32_t c;  // base components and the one in use
} PairCtx;
static inline u32 pair_id(PairCtx *P, u32 x, u32 y) {     // x, y nodes with complementary bit 1
    if (x & 1) return P->loc[x] * P->nR + P->loc[y];      // node id bit 0 is row bit 1
    return P->nL * P->nR + P->loc[x] * P->nL + P->loc[y];
}
static inline void pair_nodes(PairCtx *P, u32 id, u32 *x, u32 *y) {
    u32 h = P->nL * P->nR;
    if (id < h) { *x = P->Lm[id / P->nR]; *y = P->Rm[id % P->nR]; }
    else { id -= h; *x = P->Rm[id / P->nL]; *y = P->Lm[id % P->nL]; }
}
static int pair_succ(u32 v, u32 out[4], void *ctx) {
    PairCtx *P = ctx;
    u32 x, y;
    pair_nodes(P, v, &x, &y);
    u32 a[4], b[4];
    int ka = base_succ(x, a, NULL), kb = base_succ(y, b, NULL), k = 0;
    for (int i = 0; i < ka; i++) {
        if (P->comp[a[i]] != P->c) continue;
        for (int j = 0; j < kb; j++) {
            if (P->comp[b[j]] != P->c) continue;
            if (((a[i] ^ b[j]) & 1) == 0) continue;
            out[k++] = pair_id(P, a[i], b[j]);
        }
    }
    return k;
}

static int pair_bfs(u32 x, u32 y, u32 tx, u32 ty, int depth);

static void selfcheck_base(int32_t *comp, uint8_t *self, int *ok) {
    if (n > 12) return;
    uint8_t *R = calloc((size_t)N * N, 1);
    u32 *q = malloc(sizeof(u32) * N);
    for (u32 s = 0; s < N; s++) {
        u32 h = 0, t = 0;
        u32 o[4];
        int k = base_succ(s, o, NULL);
        for (int i = 0; i < k; i++) if (!R[(size_t)s * N + o[i]]) { R[(size_t)s * N + o[i]] = 1; q[t++] = o[i]; }
        while (h < t) {
            u32 v = q[h++];
            k = base_succ(v, o, NULL);
            for (int i = 0; i < k; i++) if (!R[(size_t)s * N + o[i]]) { R[(size_t)s * N + o[i]] = 1; q[t++] = o[i]; }
        }
    }
    for (u32 u = 0; u < N; u++) {
        for (u32 v = 0; v < N; v++) {
            int mutual = (u == v) || (R[(size_t)u * N + v] && R[(size_t)v * N + u]);
            if (mutual != (comp[u] == comp[v])) *ok = 0;
        }
    }
    // cyclic check: u on a cycle iff reachable from itself
    u32 *csz = calloc(N, sizeof(u32));
    for (u32 u = 0; u < N; u++) csz[comp[u]]++;
    for (u32 u = 0; u < N; u++) {
        int cyc = csz[comp[u]] > 1 || self[u];
        if (cyc != (R[(size_t)u * N + u] != 0)) *ok = 0;
    }
    free(csz); free(R); free(q);
}

static void run_range(int nmin, int nmax, u32 cap, int swapall_max) {
    for (n = nmin; n <= nmax; n++) {
        N = 1u << (n - 3);
        rowmask = (n + 1 >= 64) ? ~0ULL : ((1ULL << (n + 1)) - 1);
        u32 ncomp;
        uint8_t *self;
        int32_t *comp = tarjan(N, base_succ, NULL, &ncomp, &self);
        u32 *csize = calloc(ncomp, sizeof(u32)), *cbad = calloc(ncomp, sizeof(u32));
        U *cor = calloc(ncomp, sizeof(U));
        uint8_t *cself = calloc(ncomp, 1);
        for (u32 v = 0; v < N; v++) {
            int32_t c = comp[v];
            csize[c]++;
            U w = decode(v);
            cor[c] |= w;
            if (self[v]) cself[c] = 1;
            if (reset_free(w)) cbad[c]++;
        }
        U interior = ((n >= 64) ? ~0ULL : ((1ULL << n) - 1)) & ~(U)1;      // bits 1..n-1
        long long cyc_nodes = 0, cyc_comps = 0, bad_cyc = 0, bad_whole = 0, whole_comps = 0, whole_nodes = 0;
        u32 maxc = 0, maxbadc = 0;
        for (u32 c = 0; c < ncomp; c++) {
            int cyc = csize[c] > 1 || cself[c];
            if (!cyc) continue;
            cyc_nodes += csize[c]; cyc_comps++;
            if (csize[c] > maxc) maxc = csize[c];
            bad_cyc += cbad[c];
            if (cbad[c] && csize[c] > maxbadc) maxbadc = csize[c];
            if ((cor[c] & interior) == interior) { whole_comps++; whole_nodes += csize[c]; bad_whole += cbad[c]; }
        }
        int base_ok = 1;
        selfcheck_base(comp, self, &base_ok);
        // period of each cyclic component with bad rows: gcd over its edges of level(u) + 1 - level(v)
        int32_t *lev = malloc(sizeof(int32_t) * N);
        u32 *bq = malloc(sizeof(u32) * N);
        memset(lev, 0xff, sizeof(int32_t) * N);
        u32 *cg = calloc(ncomp, sizeof(u32));
        for (u32 v = 0; v < N; v++) {
            int32_t c = comp[v];
            if (!cbad[c] || !(csize[c] > 1 || cself[c]) || lev[v] >= 0) continue;
            // v is the first node met in component c: BFS inside c
            u32 h = 0, t = 0, g = 0;
            lev[v] = 0; bq[t++] = v;
            while (h < t) {
                u32 u = bq[h++];
                u32 o[4];
                int k = base_succ(u, o, NULL);
                for (int e = 0; e < k; e++) {
                    if (comp[o[e]] != c) continue;
                    if (lev[o[e]] < 0) { lev[o[e]] = lev[u] + 1; bq[t++] = o[e]; }
                    else {
                        long long dlt = (long long)lev[u] + 1 - lev[o[e]];
                        if (dlt < 0) dlt = -dlt;
                        u32 a2 = g, b2 = (u32)dlt;
                        while (b2) { u32 r2 = a2 % b2; a2 = b2; b2 = r2; }
                        g = a2;
                    }
                }
            }
            cg[c] = g;
        }
        long long bad_whole_dyadic = 0, bad_cyc_dyadic = 0;
        char gl[256] = "";
        int gll = 0;
        for (u32 c = 0; c < ncomp; c++) {
            if (!cbad[c] || !(csize[c] > 1 || cself[c])) continue;
            int dy = cg[c] && !(cg[c] & (cg[c] - 1));
            if (dy) bad_cyc_dyadic += cbad[c];
            if ((cor[c] & interior) == interior) {
                if (dy) bad_whole_dyadic += cbad[c];
                if (gll < 200) gll += snprintf(gl + gll, sizeof gl - gll, "%s%u", gll ? "," : "", cg[c]);
            }
        }
        free(lev); free(bq);
        // members by component
        u32 *off = calloc(ncomp + 1, sizeof(u32)), *ord = malloc(sizeof(u32) * N), *fill = calloc(ncomp, sizeof(u32));
        for (u32 c = 0; c < ncomp; c++) off[c + 1] = off[c] + csize[c];
        for (u32 v = 0; v < N; v++) { int32_t c = comp[v]; ord[off[c] + fill[c]++] = v; }
        u32 *loc = malloc(sizeof(u32) * N);
        long long swappable = 0, swappable_bad = 0, untested = 0, tested_pairs = 0, comps_tested = 0;
        int pair_check_ok = 1, pair_checked = 0;
        char wit[512] = "";
        for (u32 c = 0; c < ncomp; c++) {
            int cyc = csize[c] > 1 || cself[c];
            if (!cyc || !cbad[c]) continue;
            int whole = (cor[c] & interior) == interior;
            if (n > swapall_max && !whole) continue;
            PairCtx P;
            P.comp = comp; P.c = (int32_t)c; P.loc = loc;
            P.nL = 0; P.nR = 0;
            for (u32 i = off[c]; i < off[c + 1]; i++) { if (ord[i] & 1) P.nL++; else P.nR++; }
            U size = 2ULL * P.nL * P.nR;
            if (size == 0) { comps_tested++; continue; }
            if (size > cap) { untested += (long long)size; continue; }
            P.Lm = malloc(sizeof(u32) * P.nL); P.Rm = malloc(sizeof(u32) * P.nR);
            u32 a = 0, b = 0;
            for (u32 i = off[c]; i < off[c + 1]; i++) {
                u32 v = ord[i];
                if (v & 1) { loc[v] = a; P.Lm[a++] = v; } else { loc[v] = b; P.Rm[b++] = v; }
            }
            u32 pnc;
            uint8_t *pself;
            int32_t *pc = tarjan((u32)size, pair_succ, &P, &pnc, &pself);
            u32 *pcs = calloc(pnc, sizeof(u32));
            for (u32 i = 0; i < size; i++) pcs[pc[i]]++;
            for (u32 i = 0; i < size; i++) {
                if (!(pcs[pc[i]] > 1 || pself[i])) continue;
                u32 x, y;
                pair_nodes(&P, i, &x, &y);
                u32 j = pair_id(&P, y, x);
                if (pc[j] == pc[i]) {
                    swappable++;
                    if (reset_free(decode(x))) {
                        swappable_bad++;
                        if (!wit[0]) snprintf(wit, sizeof wit, "{\"x\":\"%llx\",\"y\":\"%llx\"}",
                                              (unsigned long long)decode(x), (unsigned long long)decode(y));
                    }
                }
            }
            // self-check: small pair graphs against BFS
            if (size <= 4096) {
                pair_checked++;
                uint8_t *seen = malloc(size);
                u32 *q = malloc(sizeof(u32) * size);
                for (u32 i = 0; i < size; i++) {
                    u32 x, y;
                    pair_nodes(&P, i, &x, &y);
                    u32 j = pair_id(&P, y, x);
                    memset(seen, 0, size);
                    u32 h = 0, t = 0;
                    u32 o[4];
                    int k = pair_succ(i, o, &P);
                    for (int e = 0; e < k; e++) if (!seen[o[e]]) { seen[o[e]] = 1; q[t++] = o[e]; }
                    while (h < t) {
                        u32 v = q[h++];
                        k = pair_succ(v, o, &P);
                        for (int e = 0; e < k; e++) if (!seen[o[e]]) { seen[o[e]] = 1; q[t++] = o[e]; }
                    }
                    int cyc_i = pcs[pc[i]] > 1 || pself[i];
                    int bfs_swap = seen[j] && seen[i];       // i ->* j and (by the swap symmetry) j ->* i
                    if ((cyc_i && pc[j] == pc[i]) != bfs_swap) pair_check_ok = 0;
                }
                free(seen); free(q);
            }
            tested_pairs += (long long)size; comps_tested++;
            free(pc); free(pself); free(pcs); free(P.Lm); free(P.Rm);
        }
        // exact closed walks for small n: bad rows on a length-2P antiperiodic walk must be swappable
        long long realized_bad = 0, realized_not_swappable = 0, realized_bad_dyadic = 0;
        if (n <= 10) {
            // unrestricted pair graph on all nodes: ids x * N + y with complementary bit 1
            u32 M2 = N * N;
            uint8_t *cur = malloc(M2), *nxt = malloc(M2);
            uint8_t *isbad = calloc(N, 1), *real = calloc(N, 1), *reald = calloc(N, 1), *swapx = calloc(N, 1);
            for (u32 v = 0; v < N; v++) isbad[v] = reset_free(decode(v));
            for (u32 x = 0; x < N; x++) {
                if (!isbad[x]) continue;
                for (u32 y = 0; y < N; y++) {
                    if (((x ^ y) & 1) == 0) continue;
                    memset(cur, 0, M2);
                    cur[x * N + y] = 1;
                    for (int Pp = 1; Pp <= 8; Pp++) {
                        memset(nxt, 0, M2);
                        for (u32 s = 0; s < M2; s++) {
                            if (!cur[s]) continue;
                            u32 a[4], b[4];
                            int ka = base_succ(s / N, a, NULL), kb = base_succ(s % N, b, NULL);
                            for (int i = 0; i < ka; i++) for (int j = 0; j < kb; j++)
                                if ((a[i] ^ b[j]) & 1) nxt[a[i] * N + b[j]] = 1;
                        }
                        uint8_t *tmp = cur; cur = nxt; nxt = tmp;
                        if (cur[y * N + x]) { real[x] = 1; if (!(Pp & (Pp - 1))) reald[x] = 1; }
                    }
                }
            }
            // swappable first components from the component computation, recomputed per x
            for (u32 c = 0; c < ncomp; c++) {
                int cyc = csize[c] > 1 || cself[c];
                if (!cyc) continue;
                for (u32 i = off[c]; i < off[c + 1]; i++) {
                    u32 x = ord[i];
                    if (!isbad[x]) continue;
                    for (u32 k2 = off[c]; k2 < off[c + 1]; k2++) {
                        u32 y = ord[k2];
                        if (((x ^ y) & 1) == 0) continue;
                        // BFS inside the component for the swap
                        PairCtx P;
                        P.comp = comp; P.c = (int32_t)c; P.loc = loc; P.nL = 0; P.nR = 0;
                        for (u32 t2 = off[c]; t2 < off[c + 1]; t2++) { if (ord[t2] & 1) P.nL++; else P.nR++; }
                        P.Lm = malloc(sizeof(u32) * (P.nL + 1)); P.Rm = malloc(sizeof(u32) * (P.nR + 1));
                        u32 aa = 0, bb2 = 0;
                        for (u32 t2 = off[c]; t2 < off[c + 1]; t2++) {
                            u32 v = ord[t2];
                            if (v & 1) { loc[v] = aa; P.Lm[aa++] = v; } else { loc[v] = bb2; P.Rm[bb2++] = v; }
                        }
                        u32 size = 2u * P.nL * P.nR;
                        uint8_t *seen = calloc(size, 1);
                        u32 *q = malloc(sizeof(u32) * size);
                        u32 st = pair_id(&P, x, y), tg = pair_id(&P, y, x), h = 0, t = 0;
                        u32 o[4];
                        int k = pair_succ(st, o, &P);
                        for (int e = 0; e < k; e++) if (!seen[o[e]]) { seen[o[e]] = 1; q[t++] = o[e]; }
                        while (h < t) {
                            u32 v = q[h++];
                            k = pair_succ(v, o, &P);
                            for (int e = 0; e < k; e++) if (!seen[o[e]]) { seen[o[e]] = 1; q[t++] = o[e]; }
                        }
                        if (seen[tg]) swapx[x] = 1;
                        free(seen); free(q); free(P.Lm); free(P.Rm);
                    }
                }
            }
            for (u32 x = 0; x < N; x++) {
                if (real[x]) { realized_bad++; if (!swapx[x]) realized_not_swappable++; }
                if (reald[x]) realized_bad_dyadic++;
            }
            free(cur); free(nxt); free(isbad); free(real); free(reald); free(swapx);
        }
        printf("{\"gap\":%d,\"nodes\":%u,\"cyclic\":%lld,\"components\":%lld,\"largest_component\":%u,"
               "\"bad_cyclic\":%lld,\"largest_bad_component\":%u,\"whole_components\":%lld,\"whole_nodes\":%lld,"
               "\"bad_whole\":%lld,\"components_tested\":%lld,\"tested_pairs\":%lld,\"untested_pairs\":%lld,"
               "\"swappable_pairs\":%lld,\"swappable_bad_pairs\":%lld,\"witness\":%s,"
               "\"base_selfcheck_ok\":%s,\"pair_selfcheck_ok\":%s,\"pair_graphs_checked\":%d,"
               "\"exact_walk_bad_rows\":%lld,\"exact_walk_bad_rows_dyadic\":%lld,\"exact_walk_rows_not_swappable\":%lld,"
               "\"bad_cyclic_dyadic_period\":%lld,\"bad_whole_dyadic_period\":%lld,\"bad_whole_component_periods\":[%s]",
               n, N, cyc_nodes, cyc_comps, maxc, bad_cyc, maxbadc, whole_comps, whole_nodes, bad_whole,
               comps_tested, tested_pairs, untested, swappable, swappable_bad, wit[0] ? wit : "null",
               base_ok ? "true" : "false", pair_check_ok ? "true" : "false", pair_checked,
               realized_bad, realized_bad_dyadic, realized_not_swappable, bad_cyc_dyadic, bad_whole_dyadic, gl);
        // bad rows in whole components (for the census cross-check), when few
        if (bad_whole <= 5000) {
            printf(",\"bad_whole_rows\":[");
            int first = 1;
            for (u32 c = 0; c < ncomp; c++) {
                int cyc = csize[c] > 1 || cself[c];
                if (!cyc || !cbad[c] || (cor[c] & interior) != interior) continue;
                for (u32 i = off[c]; i < off[c + 1]; i++) {
                    U w = decode(ord[i]);
                    if (reset_free(w)) { printf("%s\"%llx:%u\"", first ? "" : ",", (unsigned long long)w, cg[c]); first = 0; }
                }
            }
            printf("]");
        }
        printf("}\n");
        fflush(stdout);
        free(comp); free(self); free(csize); free(cbad); free(cor); free(cself); free(off); free(ord); free(fill); free(cg);
        free(loc);
    }
}

static int pair_bfs(u32 x, u32 y, u32 tx, u32 ty, int depth) {
    // layered walk over pairs of nodes (unrestricted): the first length at which (tx, ty) is reached, -1 if not by
    // depth, -3 if a layer exceeds 2^22 walks
    size_t cap = (size_t)1 << 22;
    U *cur = malloc(sizeof(U) * cap), *nx = malloc(sizeof(U) * cap);
    size_t nc = 1, nn;
    U target = ((U)tx << 32) | ty;
    cur[0] = ((U)x << 32) | y;
    for (int d = 1; d <= depth; d++) {
        nn = 0;
        for (size_t i = 0; i < nc; i++) {
            u32 a[4], b[4];
            int ka = base_succ((u32)(cur[i] >> 32), a, NULL), kb = base_succ((u32)cur[i], b, NULL);
            for (int p = 0; p < ka; p++) for (int q = 0; q < kb; q++) {
                if (!((a[p] ^ b[q]) & 1)) continue;
                if (nn == cap) { free(cur); free(nx); return -3; }
                nx[nn++] = ((U)a[p] << 32) | b[q];
            }
        }
        for (size_t i = 0; i < nn; i++) if (nx[i] == target) { free(cur); free(nx); return d; }
        U *t = cur; cur = nx; nx = t; nc = nn;
        if (!nc) break;
    }
    free(cur); free(nx);
    return -1;
}

int main(int argc, char **argv) {
    if (argc >= 6 && !strcmp(argv[1], "range")) {
        run_range(atoi(argv[2]), atoi(argv[3]), (u32)strtoul(argv[4], NULL, 10), atoi(argv[5]));
        return 0;
    }
    if (argc >= 6 && !strcmp(argv[1], "pair")) {
        n = atoi(argv[2]);
        N = 1u << (n - 3);
        rowmask = (1ULL << (n + 1)) - 1;
        U x = strtoull(argv[3], NULL, 16), y = strtoull(argv[4], NULL, 16);
        int depth = atoi(argv[5]);
        int okx = !(x & 1) && ((x >> 2) & 1) && !((x >> n) & 1) && legal(x) && x <= rowmask;
        int oky = !(y & 1) && ((y >> 2) & 1) && !((y >> n) & 1) && legal(y) && y <= rowmask;
        int d = (okx && oky && ((x ^ y) & 2)) ? pair_bfs(encode(x), encode(y), encode(y), encode(x), depth) : -2;
        printf("{\"gap\":%d,\"x\":\"%llx\",\"y\":\"%llx\",\"rows_valid\":%s,\"swap_depth\":%d}\n", n,
               (unsigned long long)x, (unsigned long long)y, (okx && oky) ? "true" : "false", d);
        return 0;
    }
    fprintf(stderr, "usage\n");
    return 1;
}
