/* Extend just the unresolved seeds in a preceding full census binary.
   gcc -std=c11 -O3 -march=native -fopenmp extend.c -o extend
   extend tables.txt full_census.bin old_sample_count new_sample_count sparse_output.bin
   Sparse records: uint32 seed, then the four uint16 census result fields. */
#define main original_census_main
#include "census.c"
#undef main

struct extension { uint32_t seed; struct result result; };

int main(int argc, char **argv) {
    if (argc != 6 || !tables(argv[1])) return 1;
    int old=atoi(argv[3]), samples=atoi(argv[4]);
    if (old < 1 || samples <= old || samples >= MISS) return 2;
    FILE *input=fopen(argv[2],"rb"), *output=fopen(argv[5],"wb");
    if (!input || !output) return 3;
    struct result previous;
    size_t capacity=256, n=0;
    struct extension *rows=malloc(capacity*sizeof(*rows));
    if (!rows) return 4;
    for (uint32_t seed=0; fread(&previous,sizeof(previous),1,input)==1; ++seed) {
        if (previous.fate) continue;
        if (previous.end != old-1) return 5;
        if (n==capacity) {
            capacity*=2;
            struct extension *more=realloc(rows,capacity*sizeof(*rows));
            if (!more) return 6;
            rows=more;
        }
        rows[n++].seed=seed;
    }
    if (!feof(input)) return 7;
    fclose(input);
    #pragma omp parallel
    {
        uint64_t *a=calloc(3+(24+2*samples)/64,sizeof(*a));
        if (!a) abort();
        #pragma omp for schedule(dynamic,16)
        for (int i=0; i<(int)n; ++i) {
            rows[i].result=simulate(rows[i].seed,samples,a);
            if (rows[i].result.end < old) abort();
        }
        free(a);
    }
    if (fwrite(rows,sizeof(*rows),n,output)!=n) return 8;
    free(rows);
    return fclose(output)!=0;
}
