// check_entry.cpp (ledger M152): exhaustive check of the entry step, by plain sets. For a width W: the windows of W cells at period m that lie on a
// path of m periods before and n after, outside the trap (first 14 cells) at every gate tick, outer cell free at every tick.
// usage: check_entry WORD KFILE W m n ; prints the number of windows and, if at most 20, the windows
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <vector>
using namespace std; typedef uint32_t u32;
int main(int ac,char**av){ const char*w=av[1]; int W=atoi(av[3]),m=atoi(av[4]),n=atoi(av[5]); int d[3]; if(!strcmp(w,"001")){d[0]=0;d[1]=1;d[2]=0;} else {d[0]=0;d[1]=1;d[2]=1;}
 vector<char> K(1<<14,0); FILE*f=fopen(av[2],"r"); unsigned v; while(fscanf(f,"%u",&v)==1) K[v]=1; fclose(f);
 u32 N=1u<<W; auto step=[&](u32 x,int wall,int e){ u32 y=0; for(int i=0;i<W;i++){ int l=i?(x>>(i-1))&1:wall,c=(x>>i)&1,r=i+1<W?(x>>(i+1))&1:e; if(l!=(c|r)) y|=1u<<i;} return y; };
 // fast step table free: use bit formula but check it against the cell formula on a sample
 auto fast=[&](u32 x,int wall,int e){ uint64_t r=(uint64_t)x|((uint64_t)e<<W); return (u32)(((r<<1|wall)^(r|(r>>1)))&(N-1)); };
 for(u32 i=0;i<200000;i++){ u32 x=(i*2654435761u)&(N-1); for(int a=0;a<2;a++)for(int e=0;e<2;e++) if(step(x,a,e)!=fast(x,a,e)){printf("step mismatch\n");return 1;} }
 auto out=[&](u32 x){return !K[x&16383];};
 vector<char> A(N),B(N);
 for(u32 x=0;x<N;x++) A[x]=out(x);
 for(int t=0;t<m;t++){ for(int k=0;k<3;k++){ fill(B.begin(),B.end(),0); for(u32 x=0;x<N;x++) if(A[x]){ B[fast(x,d[k],0)]=1; B[fast(x,d[k],1)]=1; } A.swap(B);} for(u32 x=0;x<N;x++) A[x]=A[x]&&out(x); }
 vector<char> C(N),D(N); for(u32 x=0;x<N;x++) C[x]=out(x);
 for(int t=0;t<n;t++){ for(int k=2;k>=0;k--){ for(u32 x=0;x<N;x++) D[x]=C[fast(x,d[k],0)]||C[fast(x,d[k],1)]; C.swap(D);} for(u32 x=0;x<N;x++) C[x]=C[x]&&out(x); }
 long c=0; for(u32 x=0;x<N;x++) if(A[x]&&C[x]) c++; printf("%s W %d m %d n %d: windows at period m on such a path: %ld",w,W,m,n,c); if(c<=20){ printf(" ="); for(u32 x=0;x<N;x++) if(A[x]&&C[x]) printf(" %u",x);} { vector<char> P(1<<18,0); long q=0; for(u32 x=0;x<N;x++) if(A[x]&&C[x]&&W>=18&&!P[x&262143]){P[x&262143]=1;q++;} if(W>=18){ printf("; first 18 cells: %ld =",q); if(q<=24) for(u32 y=0;y<262144;y++) if(P[y]) printf(" %u",y);} } printf("\n"); return 0; }
