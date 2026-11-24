// claudeIntel, N12 (I77).  Transit pairs only.
//
// A pair {x,y} of distinct rows at width W is a TRANSIT pair when it is reached from an equal pair by equal-gap walks
// through distinct pairs, and it leads to a differing pair the same way (a differing pair is one itself).  After the
// differing pair the two walks must be able to meet again; at the base width that is the full test (the pair is
// common), and at larger widths a differing pair must be a lift of one kept at the previous width.  So the sets are
// supersets of the true ones, and every word excluded here is excluded.  Candidates at W are the lifts of the transit
// pairs at W-1 (two distinct lifts of one row cannot differ in the sample and are kept only as the first pair met).
//
// Usage: transit GRAPHDIR LETTERS WMIN WBASE WMAX KMAX THREADS
//   widths WMIN..WBASE run the full common-pair product; WBASE..WMAX lift transit pairs only.
#define main frozen_main
#include "claudeIntel_gap_pairs.cpp"
#undef main
#include <chrono>

static Pairs csr(vector<u64> &keys, size_t n) {
    sort(keys.begin(), keys.end());
    keys.erase(unique(keys.begin(), keys.end()), keys.end());
    Pairs p;
    p.off.assign(n + 1, 0);
    p.y.reserve(keys.size());
    for (u64 k : keys) { p.off[(k >> 32) + 1]++; p.y.push_back((u32)k); }
    for (size_t i = 0; i < n; i++) p.off[i + 1] += p.off[i];
    return p;
}
// pairs reached from the seeds (pair ids) along g through distinct pairs within `allowed`
static vector<unsigned char> reach_from(const Graph &g, const Pairs &p, const V &seeds, const vector<unsigned char> *allowed) {
    vector<unsigned char> seen(p.y.size(), 0);
    vector<V> local(THREADS);
    V front;
    for (u32 s : seeds) if (!seen[s] && (!allowed || (*allowed)[s])) { seen[s] = 1; front.push_back(s); }
    while (!front.empty()) {
        par(front.size(), 1024, [&](size_t lo, size_t hi, int th) {
            for (size_t i = lo; i < hi; i++) {
                u32 x = xof(p, front[i]), y = p.y[front[i]];
                for (int a = 0; a < 8; a++)
                    for (u32 e = g.off[a][x]; e < g.off[a][x + 1]; e++)
                        for (u32 f = g.off[a][y]; f < g.off[a][y + 1]; f++) {
                            u32 u = g.dst[a][e], v = g.dst[a][f];
                            if (u == v) continue;
                            u32 id = locate(p, u, v);
                            if (id == ~0u || (allowed && !(*allowed)[id])) continue;
                            if (!__atomic_exchange_n(&seen[id], 1, __ATOMIC_RELAXED)) local[th].push_back(id);
                        }
            }
        });
        front.clear();
        for (auto &l : local) { front.insert(front.end(), l.begin(), l.end()); V().swap(l); }
    }
    return seen;
}

int main(int argc, char **argv) {
    if (argc != 8) { fprintf(stderr, "usage: transit GRAPHDIR LETTERS WMIN WBASE WMAX KMAX THREADS\n"); return 2; }
    string dir = argv[1];
    int letters = atoi(argv[2]), wmin = atoi(argv[3]), wbase = atoi(argv[4]), wmax = atoi(argv[5]), kmax = atoi(argv[6]);
    THREADS = atoi(argv[7]);
    vector<pair<u32, u32>> prev, prevdiff;
    for (int W = wmin; W <= wmax; W++) {
        Graph full = load(dir + "/g" + to_string(W) + ".bin", W);
        u32 comps;
        Graph g = keep(full, letters, true, comps);
        full = Graph();
        size_t n = g.row.size();
        auto find = [&](u32 r) -> u32 { auto it = lower_bound(g.row.begin(), g.row.end(), r); return it != g.row.end() && *it == r ? u32(it - g.row.begin()) : ~0u; };
        vector<u64> keys;
        u32 top = 1u << (W - 1);
        if (W == wmin) {
            for (size_t i = 0; i < n; i++) for (size_t j = i + 1; j < n; j++) keys.push_back((u64)i << 32 | j);
        } else {
            for (size_t i = 0; i < n; i++) if (!(g.row[i] & top)) { u32 j = find(g.row[i] | top); if (j != ~0u) keys.push_back((u64)i << 32 | j); }
            for (auto &q : prev) for (int s = 0; s < 4; s++) {
                u32 i = find(q.first | (s & 1 ? top : 0)), j = find(q.second | (s & 2 ? top : 0));
                if (i != ~0u && j != ~0u) keys.push_back((u64)min(i, j) << 32 | max(i, j));
            }
        }
        Pairs p = csr(keys, n);
        vector<u64>().swap(keys);
        Graph r = reversed(g);
        auto fwd = reach(g, p, nullptr);
        vector<unsigned char> live;
        V seeds;
        vector<pair<u32, u32>> diff;
        if (W <= wbase) live = reach(r, p, &fwd);
        for (size_t x = 0; x < n; x++) for (u32 k = p.off[x]; k < p.off[x + 1]; k++) {
            if (!fwd[k] || (W <= wbase && !live[k]) || colour(g.row[x]) == colour(g.row[p.y[k]])) continue;
            if (W > wbase) {                                  // a lift of a kept differing pair
                u32 a = g.row[x] & (top - 1), b = g.row[p.y[k]] & (top - 1);
                if (!binary_search(prevdiff.begin(), prevdiff.end(), make_pair(min(a, b), max(a, b)))) continue;
            }
            seeds.push_back(k);
            diff.emplace_back(x, p.y[k]);
        }
        auto tr = reach_from(r, p, seeds, W <= wbase ? &live : &fwd);
        size_t nt = 0, nl = 0;
        for (size_t i = 0; i < p.y.size(); i++) { nt += tr[i]; if (W <= wbase) nl += live[i]; }
        printf("W=%d letters %d rows %zu candidates %zu common %zu differing %zu transit %zu\n", W, letters, n, p.y.size(), nl, diff.size(), nt);
        fflush(stdout);
        if (W >= wbase) transit(r, p, tr, diff, kmax);
        prev.clear();
        prevdiff.clear();
        // up to the base the next width needs every common pair; from the base on only the transit pairs
        for (size_t x = 0; x < n; x++) for (u32 k = p.off[x]; k < p.off[x + 1]; k++)
            if (W < wbase ? live[k] : tr[k]) prev.emplace_back(g.row[x], g.row[p.y[k]]);
        for (auto &d : diff) { u32 a = g.row[d.first], b = g.row[d.second]; prevdiff.emplace_back(min(a, b), max(a, b)); }
        sort(prevdiff.begin(), prevdiff.end());
    }
}
