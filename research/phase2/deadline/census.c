/* gcc -std=c11 -O3 -march=native -fopenmp census.c -o census
   census tables.txt first_seed end_exclusive sample_count output.bin
   Each seed writes four uint16 fields: fate, endpoint sample, first trap
   sample through endpoint, and class phase. 65535 means unseen. Fate 1 is
   clean, 2/5/7/8 are locks 2/5/7/7b, and 0 is unknown at the horizon.
   If clean and a lock coincide, the lock wins the tie. White sample s is
   physical tick 2s+1. Bit zero is site 1; all other initial sites are white. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

enum { MISS = UINT16_MAX, BUCKETS = 65536, MAX_CODES = 1024, CHUNK = 32768 };
struct code { uint64_t value, mask; int kind, phase, next; };
struct result { uint16_t fate, end, trap, phase; };
static struct code codes[MAX_CODES];
static int heads[BUCKETS], code_count;
static uint8_t trap[BUCKETS];

static int tables(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return 0;
    int kind, width, phase, found = 0;
    uint64_t v;
    for (int i = 0; i < BUCKETS; ++i) heads[i] = -1;
    while (fscanf(f, "%d %d %d %" SCNu64, &kind, &width, &phase, &v) == 4) {
        if (kind == 0) { trap[v] = 1; ++found; continue; }
        if (width < 16 || width > 63 || code_count == MAX_CODES) return 0;
        unsigned b = (uint16_t)v;
        codes[code_count] = (struct code){v, (UINT64_C(1) << width) - 1, kind, phase, heads[b]};
        heads[b] = code_count++;
    }
    fclose(f);
    return found == 829 && code_count != 0;
}

/* Only occupied words need updating. One sentinel word on each high end
   gives the white far field; grow the array when the bounding cone crosses
   a word boundary. Carries always come from the preceding physical row. */
static inline void tick(uint64_t *a, int w, unsigned wall) {
    uint64_t carry = wall;
    for (int i = 0; i < w; ++i) {
        uint64_t old = a[i];
        uint64_t east = (old >> 1) | (a[i+1] << 63);
        a[i] = ((old << 1) | carry) ^ (old | east);
        carry = old >> 63;
    }
}

static struct result simulate(uint32_t seed, int samples, uint64_t *a) {
    a[0] = seed;
    a[1] = 0;
    int w = 1, t = 0, clean = 0, first_trap = MISS;
    int support = seed ? 32 - __builtin_clz(seed) : 0;
    unsigned last = 0;
    for (int s = 0; s < samples; ++s) {
        int stop = 2*s+1;
        while (t < stop) {
            ++t;
            int need = (support + t + 63)/64;
            if (need > w) { ++w; a[w] = 0; }
            tick(a, w, t % 2);
        }
        uint64_t row = a[0];
        if (trap[(uint16_t)row] && first_trap == MISS) first_trap = s;
        for (int i = heads[(uint16_t)row]; i >= 0; i = codes[i].next) {
            const struct code *c = &codes[i];
            if ((row & c->mask) == c->value)
                return (struct result){c->kind, s, first_trap, c->phase};
        }
        last = ((last << 1) | (row & 1)) & 127;
        ++clean;
        /* A forbidden word ending now limits the clean suffix to len-1.
           Requiring sufficient suffix length also handles the initial padding. */
        if (clean >= 2 && (last & 3) == 3) clean = 1;                 /* 11 */
        if (clean >= 3 && (last & 7) == 5) clean = 2;                 /* 101 */
        if (clean >= 5 && ((last & 31) == 0 || (last & 31) == 17)) clean = 4;
        if (clean >= 7 && last == 73) clean = 6;                     /* 1001001 */
        if (clean == 48) {
            if (first_trap == MISS || !trap[(uint16_t)row]) abort();
            return (struct result){1, s, first_trap, MISS};
        }
        if (first_trap != MISS && s >= first_trap + 53) abort(); /* GateObserver.clean_after_six */
    }
    return (struct result){0, samples-1, first_trap, MISS};
}

int main(int argc, char **argv) {
    if (argc != 6 || !tables(argv[1])) return 1;
    uint32_t start = strtoul(argv[2], NULL, 0), end = strtoul(argv[3], NULL, 0);
    int samples = atoi(argv[4]);
    if (start >= end || end > (UINT32_C(1)<<24) || samples < 1 || samples >= MISS) return 2;
    FILE *f = fopen(argv[5], "wb");
    if (!f) return 3;
    struct result *out = malloc(CHUNK * sizeof(*out));
    if (!out) return 4;
    for (uint32_t base = start; base < end; base += CHUNK) {
        int count = end-base < CHUNK ? (int)(end-base) : CHUNK;
        #pragma omp parallel
        {
            uint64_t *a = calloc(3 + (24+2*samples)/64, sizeof(*a));
            if (!a) abort();
            #pragma omp for schedule(static)
            for (int i = 0; i < count; ++i) out[i] = simulate(base+i, samples, a);
            free(a);
        }
        if (fwrite(out, sizeof(*out), count, f) != (size_t)count) return 5;
    }
    free(out);
    return fclose(f) != 0;
}
