/* claudeM5_r5_rungs.c: claudeM5_r5_door.c with two modes added AFTER THE FACT (ledger M134):
   rungs exc NMAX THRESHOLD OUT   every stretch with the front at THRESHOLD or more, for each of the seven label alignments
   rungs rung NMAX                how often the least front over a 21-tick cycle, for the best alignment, is at each column
   The rest is the frozen file. Entries into the kit's trap t001, and the last ticks before.

   Column 0 is driven by 0, 0, 1 repeated; a right half is bits 0.. of a row, bit p-1 being column p. The tables come
   from claudeM5_r5_tables.txt (written by claudeM5_r5_front.py's loader): lines "S window label" and "P label column bit".

   door cuts NMAX TMAX H OUT        the 001 ether on columns 1..N, white beyond, alignments (0,0) and (1,0)
   door random RUNS SUPPORT SEED TMAX H OUT   random right halves on columns 1..SUPPORT, random phase
   door coin RUNS SEED TMAX OUT     the first 47 cells only, a fair coin in column 48 at every tick, random start
   Each output line: kind, parameters, departure tick (cuts), entry tick, label at entry, then for the H ticks before
   entry the front D against t001's pattern counted back from the entry label. H = 0 prints no fronts. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
typedef uint64_t u64;
#define HB 14
static u64 hk[1 << HB]; static int hv[1 << HB];
static int P[21][40], K = 38;
static const int DRV[3] = {0, 0, 1};
static const int ETH[12][3] = {{0,0,1},{0,0,1},{0,1,1},{1,1,0},{0,1,0},{0,1,0},{1,1,0},{1,0,1},{1,0,0},{1,0,0},{1,0,1},{0,1,1}};
static unsigned hsh(u64 k) { return (unsigned)((k * 0x9E3779B97F4A7C15ULL) >> (64 - HB)); }
/* key: window (47 bits) with the phase mod 3 in bits 47-48; the value is the label mod 21 */
static void put(u64 k, int v) { unsigned h = hsh(k); while (hv[h] >= 0) h = (h + 1) & ((1 << HB) - 1); hk[h] = k; hv[h] = v; }
static int get(u64 k) { unsigned h = hsh(k); while (hv[h] >= 0) { if (hk[h] == k) return hv[h]; h = (h + 1) & ((1 << HB) - 1); } return -1; }
static void load(void) {
  memset(hv, -1, sizeof hv);
  FILE *f = fopen("claudeM5_r5_tables.txt", "r"); if (!f) { fprintf(stderr, "no tables\n"); exit(1); }
  char c; unsigned long long w; int l, j, b; char line[256];
  while (fgets(line, sizeof line, f)) {
    c = line[0];
    if (c == 'S') { sscanf(line + 1, "%llu %d", &w, &l); put((u64)w | ((u64)(l % 3) << 47), l); }
    else if (c == 'P') { sscanf(line + 1, "%d %d %d", &l, &j, &b); P[l][j] = b; }
  }
  fclose(f);
}
static u64 rng_s; static u64 rng(void) { u64 z = (rng_s += 0x9E3779B97F4A7C15ULL); z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL; z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }
static u64 *row, *nw; static size_t cap;
static u64 *ring; static int RH;
/* one tick of the whole row; phase = the drive's value now; n = words in use */
static size_t step(size_t n, int c) {
  u64 carry = (u64)c;
  if (n + 1 < cap) row[n] = 0;
  for (size_t i = 0; i < n + 1; i++) { u64 x = (i < n) ? row[i] : 0, r = (x >> 1) | ((i + 1 < n ? row[i + 1] : 0) << 63); u64 l = (x << 1) | carry; carry = x >> 63; nw[i] = l ^ (x | r); }
  u64 *t = row; row = nw; nw = t;
  return (row[n]) ? n + 1 : n;
}
static int front(u64 w, int l) { for (int j = 1; j <= K; j++) if ((int)((w >> (j - 1)) & 1) != P[l][j]) return j; return K + 1; }
/* run from the row in place; drive phase at tick t is (t + s) mod 3 as DRV; returns the entry tick or -1 */
static long run(size_t n, int s, long TMAX, int H, int *lab, int j0, long *dep) {
  *dep = -1;
  for (long t = 0; t <= TMAX; t++) {
    u64 w = row[0]; int ph = (int)((t + s) % 3);
    if (H) ring[t % H] = w;
    if (j0 >= 0 && *dep < 0) { int e = ETH[(j0 + 1) % 12][(t + s) % 3]; if ((int)(w & 1) != e) *dep = t; }
    int l = get((w & ((1ULL << 47) - 1)) | ((u64)ph << 47));
    if (l >= 0) { *lab = l; return t; }
    if (n + 2 >= cap) { fprintf(stderr, "cap\n"); exit(1); }
    n = step(n, DRV[ph]);
  }
  return -1;
}
static void out(FILE *o, long T, int lab, int H, int wide) {
  fprintf(o, " | entry %ld label %d", T, lab);
  if (H) {
    fprintf(o, " | fronts");
    long from = T - H + 1 < 0 ? 0 : T - H + 1;
    for (long t = from; t <= T; t++) { int l = (int)(((lab - (T - t)) % 21 + 21) % 21); fprintf(o, " %d", front(ring[t % H], l)); }
    if (wide) { fprintf(o, " | rows"); for (long t = T - wide + 1 < 0 ? 0 : T - wide + 1; t <= T; t++) fprintf(o, " %016llx", (unsigned long long)ring[t % H]); }
  }
  fprintf(o, "\n"); fflush(o);
}

static FILE *EX; static int TH=18;
static long exc(size_t n,int s,long TMAX,int id){
  long start[7]; int minf[7],maxf[7]; for(int a=0;a<7;a++){start[a]=-1;minf[a]=99;maxf[a]=0;}
  for(long t=0;t<=TMAX;t++){ u64 w=row[0]; int ph=(int)((t+s)%3);
    int l=get((w&((1ULL<<47)-1))|((u64)ph<<47));
    for(int a=0;a<7;a++){ int lb=(int)((ph+3*(((t+s)/3+a)%7))%21); int d=front(w,lb);
      if(d>=TH){ if(start[a]<0){start[a]=t;minf[a]=99;maxf[a]=0;} if(d<minf[a])minf[a]=d; if(d>maxf[a])maxf[a]=d; }
      else if(start[a]>=0){ fprintf(EX,"F %d %d %ld %ld min %d max %d endlabel %d\n",id,a,start[a],t-start[a],minf[a],maxf[a],lb); start[a]=-1; } }
    if(l>=0){ for(int a=0;a<7;a++) if(start[a]>=0) fprintf(EX,"E %d %d %ld %ld min %d max %d\n",id,a,start[a],t-start[a],minf[a],maxf[a]); return t; }
    n=step(n,DRV[ph]); }
  return -1; }

/* minimum over one 21-tick cycle of the front for the best alignment: the RUNG held for a whole cycle */
static long long HIST[64]; static long long RESU[64],RESN[64];
static void rung(size_t n,int s,long TMAX){ int mn[7]; for(int a=0;a<7;a++) mn[a]=99; int last=-1; long since=0;
  for(long t=0;t<=TMAX;t++){ u64 w=row[0]; int ph=(int)((t+s)%3);
    int l=get((w&((1ULL<<47)-1))|((u64)ph<<47));
    for(int a=0;a<7;a++){ int lb=(int)((ph+3*(((t+s)/3+a)%7))%21); int d=front(w,lb); if(d<mn[a]) mn[a]=d; }
    if(t%21==20){ int b=0; for(int a=0;a<7;a++){ if(mn[a]>b) b=mn[a]; mn[a]=99; } HIST[b]++; }
    if(l>=0) return; n=step(n,DRV[ph]); } }
int main(int ac, char **av) {
  load();
  cap = 1 << 13; row = calloc(cap, 8); nw = calloc(cap, 8);
  if (ac > 1 && !strcmp(av[1], "selftest")) {
    ring = calloc(64, 8); memset(row, 0, cap * 8); int lab; long dep; long T = run(1, 0, 5000, 64, &lab, 0, &dep);
    printf("empty half: entry %ld label %d departure %ld (the kit: 1270)\n", T, lab, dep);
    printf("SELFTEST %s\n", T == 1270 ? "PASS" : "FAIL"); return 0;
  }
  if (ac > 2 && !strcmp(av[1], "rung")) { int NM=atoi(av[2]); int als[2][2]={{0,0},{1,0}};
    for(int a=0;a<2;a++){int j0=als[a][0],ss=als[a][1];int lastblack=-1; for(int N=0;N<=NM;N++){int top=0;for(int p=1;p<=N;p++) if(ETH[(j0+p)%12][ss%3]) top=p; if(top==lastblack) continue; lastblack=top;
      memset(row,0,cap*8);memset(nw,0,cap*8);for(int p=1;p<=N;p++) if(ETH[(j0+p)%12][ss%3]) row[(p-1)/64]|=1ULL<<((p-1)%64);
      rung((size_t)(N/64+1),ss,400000);}} long long tot=0; for(int i=0;i<64;i++) tot+=HIST[i]; for(int i=0;i<64;i++) if(HIST[i]) printf("least front over a 21-tick cycle %d: %lld (%.4f)\n",i,HIST[i],(double)HIST[i]/tot); return 0; }
  if (ac > 4 && !strcmp(av[1], "exc")) { int NM=atoi(av[2]); TH=atoi(av[3]); EX=fopen(av[4],"w"); int als[2][2]={{0,0},{1,0}}; int id=0;
    for(int a=0;a<2;a++){int j0=als[a][0],ss=als[a][1];int lastblack=-1; for(int N=0;N<=NM;N++){int top=0;for(int p=1;p<=N;p++) if(ETH[(j0+p)%12][ss%3]) top=p; if(top==lastblack) continue; lastblack=top;
      memset(row,0,cap*8);memset(nw,0,cap*8);for(int p=1;p<=N;p++) if(ETH[(j0+p)%12][ss%3]) row[(p-1)/64]|=1ULL<<((p-1)%64);
      exc((size_t)(N/64+1),ss,400000,id++);}} fclose(EX); return 0; }
  if (ac > 5 && !strcmp(av[1], "cuts")) {
    int NM = atoi(av[2]); long TM = atol(av[3]); int H = atoi(av[4]); FILE *o = fopen(av[5], "w"); ring = calloc(H ? H : 1, 8);
    int als[2][2] = {{0, 0}, {1, 0}};
    for (int a = 0; a < 2; a++) { int j0 = als[a][0], s = als[a][1]; int lastblack = -1;
      for (int N = 0; N <= NM; N++) {
        int top = 0; for (int p = 1; p <= N; p++) if (ETH[(j0 + p) % 12][s % 3]) top = p;
        if (top == lastblack) continue; lastblack = top;            /* the same start row as an earlier cut */
        memset(row, 0, cap * 8); memset(nw, 0, cap * 8);
        for (int p = 1; p <= N; p++) if (ETH[(j0 + p) % 12][s % 3]) row[(p - 1) / 64] |= 1ULL << ((p - 1) % 64);
        int lab = -1; long dep; long T = run((size_t)(N / 64 + 1), s, TM, H, &lab, j0, &dep);
        fprintf(o, "cut %d %d %d dep %ld", j0, s, N, dep); out(o, T, lab, T < 0 ? 0 : H, T < 0 ? 0 : 420 < H ? 420 : H);
      } }
    fclose(o); return 0;
  }
  if (ac > 7 && !strcmp(av[1], "random")) {
    long R = atol(av[2]); int SP = atoi(av[3]); rng_s = strtoull(av[4], 0, 10); long TM = atol(av[5]); int H = atoi(av[6]); FILE *o = fopen(av[7], "w"); ring = calloc(H ? H : 1, 8);
    for (long i = 0; i < R; i++) {
      memset(row, 0, cap * 8); memset(nw, 0, cap * 8); int s = (int)(rng() % 3);
      for (int p = 0; p < SP; p++) if (rng() & 1) row[p / 64] |= 1ULL << (p % 64);
      int lab = -1; long dep; long T = run((size_t)(SP / 64 + 1), s, TM, H, &lab, -1, &dep);
      fprintf(o, "random %ld phase %d", i, s); out(o, T, lab, T < 0 ? 0 : H, 0);
    }
    fclose(o); return 0;
  }
  if (ac > 5 && !strcmp(av[1], "coin")) {
    long R = atol(av[2]); rng_s = strtoull(av[3], 0, 10); long TM = atol(av[4]); FILE *o = fopen(av[5], "w"); u64 M = (1ULL << 47) - 1;
    for (long i = 0; i < R; i++) {
      u64 w = rng() & M; int s = (int)(rng() % 3); long t; int l = -1; u64 bits = 0; int nb = 0;
      for (t = 0; t <= TM; t++) {
        int ph = (int)((t + s) % 3); l = get(w | ((u64)ph << 47)); if (l >= 0) break;
        if (!nb) { bits = rng(); nb = 64; }
        u64 full = w | ((bits & 1) << 47); bits >>= 1; nb--;
        w = (((full << 1) | (u64)DRV[ph]) ^ (full | (full >> 1))) & M;
      }
      fprintf(o, "coin %ld | entry %ld label %d\n", i, l >= 0 ? t : -1, l);
    }
    fclose(o); return 0;
  }
  fprintf(stderr, "see the source for usage\n"); return 2;
}
