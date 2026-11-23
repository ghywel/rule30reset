// full backward closure (no past condition) of a trap's cut at width w; ether windows in it or not; also depth of dead ends
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <vector>
#include <string>
using namespace std; typedef uint32_t u32; typedef uint64_t u64;
static int w; static const int DRV[3]={0,0,1};
static const int ETH[12][3]={{0,0,1},{0,0,1},{0,1,1},{1,1,0},{0,1,0},{0,1,0},{1,1,0},{1,0,1},{1,0,0},{1,0,0},{1,0,1},{0,1,1}};
static const int A[6][2]={{0,0},{1,0},{4,2},{5,2},{8,1},{9,1}};
int main(int ac,char**av){ w=atoi(av[1]); FILE*f=fopen(av[2],"r"); int m,K; if(fscanf(f,"%d %d",&m,&K)!=2) return 1; vector<string> P(m); char buf[512]; for(int l=0;l<m;l++){ if(fscanf(f,"%511s",buf)!=1) return 1; P[l]=buf; }
 u64 N=1ULL<<w; vector<bool> C[3]; for(int p=0;p<3;p++) C[p].assign(N,false); vector<pair<int,u32>> todo;
 for(int l=0;l<m;l++){ u32 r=0; for(int j=1;j<=w;j++) if(P[l][j]=='1') r|=1u<<(j-1); int p=l%3; if(!C[p][r]){C[p][r]=true; todo.push_back({p,r});} }
 size_t h=0; while(h<todo.size()){ int p1=todo[h].first; u32 v=todo[h].second; h++; int p=(p1+2)%3; for(int b=0;b<2;b++) for(int z=0;z<2;z++){ int xj=b,xj1=z; u32 r=(u32)b<<(w-1); int c=0; for(int j=w;j>=1;j--){ int left=((v>>(j-1))&1)^(xj|xj1); if(j>=2) r|=(u32)left<<(j-2); else c=left; xj1=xj; xj=left; }
   if(c!=DRV[p]||C[p][r]) continue; C[p][r]=true; todo.push_back({p,r}); } }
 printf("w %d full backward closure %zu of %llu",w,todo.size(),(unsigned long long)(3*N)); int in=0,tot=0; for(auto&a:A) for(int t=0;t<3;t++){ u32 r=0; for(int j=1;j<=w;j++) if(ETH[(a[0]+j)%12][(t+a[1])%3]) r|=1u<<(j-1); tot++; if(C[t][r]) in++; }
 int zero=0; for(int p=0;p<3;p++) if(C[p][0]) zero++;
 printf(" | ether windows inside %d of %d | white window inside at %d of 3 phases\n",in,tot,zero); return 0; }
