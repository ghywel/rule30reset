// limit windows of the 001 drive at width w, and the windows of the limit that can reach a trap's cut
// usage: limit w trapfile(m K then P rows) ; windows: bit j-1 = column j
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <vector>
#include <string>
using namespace std; typedef uint32_t u32; typedef uint64_t u64;
static int w; static const int DRV[3]={0,0,1};
static inline u32 stp(u32 r,int c,int z){u64 f=((u64)r<<1)|c|((u64)z<<(w+1)); return (u32)((((f<<1)^(f|(f>>1)))>>1)&((1ULL<<w)-1));}
int main(int ac,char**av){ w=atoi(av[1]); FILE*f=fopen(av[2],"r"); int m,K; if(fscanf(f,"%d %d",&m,&K)!=2) return 1; vector<string> P(m); char buf[512]; for(int l=0;l<m;l++){ if(fscanf(f,"%s",buf)!=1) return 1; P[l]=buf; } // P[l][j], j=0..K
 u64 N=1ULL<<w; vector<bool> S[3],Q[3]; for(int p=0;p<3;p++) S[p].assign(N,true);
 int it=0; u64 prev[3]={N,N,N};
 for(;;){ bool ch=false; // S_{n+1}(p+1)=image of S_n(p); simultaneous
   for(int p=0;p<3;p++){ Q[(p+1)%3].assign(N,false); }
   for(int p=0;p<3;p++){ auto&A=S[p]; auto&B=Q[(p+1)%3]; for(u64 r=0;r<N;r++) if(A[r]){ B[stp(r,DRV[p],0)]=true; B[stp(r,DRV[p],1)]=true; } }
   for(int p=0;p<3;p++){ u64 c=0; for(u64 r=0;r<N;r++) if(Q[p][r]) c++; if(c!=prev[p]) ch=true; prev[p]=c; S[p].swap(Q[p]); }
   it++; if(!ch) break; }
 printf("w %d limit after %d ticks: %llu %llu %llu windows\n",w,it-1,(unsigned long long)prev[0],(unsigned long long)prev[1],(unsigned long long)prev[2]); fflush(stdout);
 // backward closure inside the limit
 vector<bool> C[3]; for(int p=0;p<3;p++) C[p].assign(N,false); u64 cut=0; vector<pair<int,u32>> todo;
 for(int l=0;l<m;l++){ u32 r=0; for(int j=1;j<=w;j++) if(P[l][j]=='1') r|=1u<<(j-1); int p=l%3; if(!S[p][r]){printf("pattern window of label %d not in the limit\n",l);} if(!C[p][r]){C[p][r]=true; todo.push_back({p,r}); cut++;} }
 // iterate by scanning predecessors: predecessor of v at phase p+1: choose last cell b and z
 u64 cnt=cut; size_t h=0; vector<int> hist(w+2,0);
 while(h<todo.size()){ int p1=todo[h].first; u32 v=todo[h].second; h++; int p=(p1+2)%3; for(int b=0;b<2;b++) for(int z=0;z<2;z++){ // old cells x_w=b, x_{w+1}=z ; x_{j-1}=v_j ^ (x_j|x_{j+1})
      int xj=b,xj1=z; u32 r=(u32)b<<(w-1); int c=0; for(int j=w;j>=1;j--){ int left=((v>>(j-1))&1)^(xj|xj1); if(j>=2) r|=(u32)left<<(j-2); else c=left; xj1=xj; xj=left; }
      if(c!=DRV[p]) continue; if(!S[p][r]||C[p][r]) continue; C[p][r]=true; cnt++; todo.push_back({p,r}); if(todo.size()>400000000ULL){printf("too many\n");return 1;} } }
 u64 tot=prev[0]+prev[1]+prev[2]; printf("   windows of the limit that can reach the cut: %llu of %llu (cut %llu)\n",(unsigned long long)cnt,(unsigned long long)tot,(unsigned long long)cut);
 // least agreement depth over the closure: for each window the best label of its phase
 vector<u64> dep(w+1,0); for(auto&q:todo){ int best=0; for(int l=q.first;l<m;l+=3){ int d=0; while(d<w && (((q.second>>d)&1)==(u32)(P[l][d+1]-'0'))) d++; if(d>best)best=d; } dep[best]++; }
 printf("   by agreement with the pattern (columns agreed: windows):"); for(int d=0;d<=w;d++) if(dep[d]) printf(" %d:%llu",d,(unsigned long long)dep[d]); printf("\n"); return 0; }
