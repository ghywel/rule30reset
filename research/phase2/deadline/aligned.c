/* Reclassify every seed up to its original first event allowing an aligned
   13-cell ether wall at every certified k=6+7j and either compatible phase.
   gcc -std=c11 -O3 -march=native -fopenmp aligned.c -o aligned
   aligned ether.txt original.bin extension.bin result.bin */
#define main original_main
#include "census.c"
#undef main

struct extension { uint32_t seed; struct result row; };
static unsigned prefix[2], extra[2];
static unsigned char walls[2][8192];

static unsigned section(const uint64_t *a, int w, int shift, unsigned mask) {
    int i=shift/64, j=shift%64;
    if (i>=w) return 0;
    uint64_t bits=a[i] >> j;
    if (j && i+1 < w) bits |= a[i+1] << (64-j);
    return (unsigned)bits & mask;
}

static int match(const uint64_t *a, int w) {
    for (int p=0;p<2;++p) {
        if ((a[0]&63)!=prefix[p]) continue;
        for (int k=6;;k+=7) {
            unsigned bits=section(a,w,k,8191);
            if (walls[p][bits]) return k;
            if ((bits&127)!=extra[p]) break;
        }
    }
    return 0;
}

static struct result first(uint32_t seed, struct result old, uint64_t *a) {
    a[0]=seed;
    a[1]=0;
    int w=1,t=0,support=seed ? 32-__builtin_clz(seed) : 0;
    for (int s=0;s<=old.end;++s) {
        while (t < 2*s+1) {
            ++t;
            if ((support+t+63)/64>w) {++w; a[w]=0;}
            tick(a,w,t%2);
        }
        int k=match(a,w);
        if (k && (!old.fate || s < old.end)) {
            if (old.trap!=MISS && old.trap<=s) abort();
            return (struct result){9,s,MISS,k};
        }
    }
    return old;
}

int main(int argc, char **argv) {
    if (argc!=5) return 1;
    FILE *tab=fopen(argv[1],"r"),*base=fopen(argv[2],"rb"),*ext=fopen(argv[3],"rb"),*out=fopen(argv[4],"wb");
    if(!tab || !base || !ext || !out) return 2;
    unsigned ph,pre,rep,wall;
    while(fscanf(tab,"%u%u%u%u",&ph,&pre,&rep,&wall)==4) {
        if((ph!=0 && ph!=2) || !rep || wall>=8192) return 3;
        prefix[ph/2]=pre; extra[ph/2]=rep; walls[ph/2][wall]=1;
    }
    fclose(tab);
    struct result *rows=malloc(CHUNK*sizeof(*rows));
    if(!rows) return 4;
    uint32_t seed=0;
    size_t count;
    while((count=fread(rows,sizeof(*rows),CHUNK,base))!=0) {
        int maxend=0;
        for(unsigned i=0;i<count;++i) {
            if(!rows[i].fate) {
                struct extension next;
                if(fread(&next,sizeof(next),1,ext)!=1 || next.seed!=seed+i) return 5;
                rows[i]=next.row;
            }
            if(rows[i].end>maxend) maxend=rows[i].end;
        }
        #pragma omp parallel
        {
            uint64_t *a=calloc(4+(24+2*maxend)/64,sizeof(*a));
            if(!a) abort();
            #pragma omp for schedule(static)
            for(int i=0;i<(int)count;++i) rows[i]=first(seed+i,rows[i],a);
            free(a);
        }
        if(fwrite(rows,sizeof(*rows),count,out)!=count) return 6;
        seed+=(uint32_t)count;
    }
    if(!feof(base)||fgetc(ext)!=EOF) return 7;
    free(rows); fclose(base);fclose(ext);
    return fclose(out)!=0;
}
