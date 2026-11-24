// uniform_entry.cpp (ledger M165): independent of uniform_entry.py. usage: ./a.out W K.txt, K.txt the 777 numbers of the closed set
// Is the graph of W-cell windows outside the closed set acyclic, and how long is its longest run? Rule 30 from its truth table.
#include <cstdio>
#include <vector>
#include <cstdint>
#include <cstdlib>
using namespace std;
static int W; static vector<char> K;
static inline int R30(int l,int c,int r){ static const int T[8]={0,1,1,1,1,0,0,0}; return T[l*4+c*2+r]; }   // 111->0 ... standard table rule 30: index l c r
static uint32_t step2(uint32_t x,int e0,int e1){ // x: cells 1..W at a white tick (wall 0), then black wall 1
  int c[64]; for(int i=0;i<W;i++) c[i]=(x>>i)&1; c[W]=e0; c[W+1]=e1;      // two free cells beyond
  int y[64]; int wall=0; for(int i=0;i<W+1;i++){ int l=i?c[i-1]:wall; y[i]=R30(l,c[i],c[i+1]); }
  int z[64]; wall=1; uint32_t out=0; for(int i=0;i<W;i++){ int l=i?y[i-1]:wall; z[i]=R30(l,y[i],y[i+1]); if(z[i]) out|=1u<<i; }
  return out; }
int main(int argc,char**argv){ W=atoi(argv[1]); FILE*f=fopen(argv[2],"r"); K.assign(1<<12,0); int v; while(fscanf(f,"%d",&v)==1) K[v]=1;
  size_t N=1u<<W; vector<int8_t> st(N,0); vector<int16_t> L(N,0); // 0 unseen 1 on stack 2 done
  auto outside=[&](uint32_t x){ return !K[x&4095]; };
  long cyc=0; int best=0; vector<uint32_t> path;
  for(uint32_t s=0;s<N;s++){ if(!outside(s)||st[s]) continue;
    vector<pair<uint32_t,int>> S; S.push_back({s,0}); st[s]=1;
    while(!S.empty()){ auto [x,i]=S.back(); if(i<4){ S.back().second++; uint32_t y=step2(x,i&1,i>>1); if(outside(y)){ if(st[y]==0){ st[y]=1; S.push_back({y,0}); } else if(st[y]==1) cyc++; else { if(L[y]+1>L[x]) L[x]=L[y]+1; } } }
      else { st[x]=2; S.pop_back(); if(!S.empty()){ auto [p,j]=S.back(); if(L[x]+1>L[p]) L[p]=L[x]+1; } if(L[x]+1>best) best=L[x]+1; } } }
  printf("W %d cycles %ld longest run of outside windows %d\n",W,cyc,best); }
