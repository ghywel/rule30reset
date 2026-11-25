// Exact counts of OR words beside every wall, and N(n+1) = 4 * (their sum) (claudeM5, M191). Usage: exact NMAX (22 takes 8 s and 3 GB).
// Exact: E_n(g) = set of east partners of west word g (length n). Pairs (f,g) of length n+1: f(t)=g(t+1)^(g(t)|h(t)), h in E_n(g[0..n-1]), f(n) free.
// Omega(g) = number of distinct (g|h), the OR words beside wall g. Check N(n+1) = 4 sum Omega, and report the largest Omega and its wall.
#include <vector>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <algorithm>
#include <cmath>
using namespace std; typedef uint32_t u32; typedef uint64_t u64;
int main(int c,char**v){int nmax=atoi(v[1]);
  // n=1: all four pairs
  vector<u64> off(3); vector<u32> lst; off[0]=0;off[1]=2;off[2]=4; lst={0,1,0,1}; int n=1; u64 N=4;
  for(;;){ // have E_n as CSR; compute Omega_n(g)
    u64 tot=0,mx=0;u32 mg=0; double sq=0; vector<u32> tmp; vector<u64> cnt; // for next: pairs keyed by f
    size_t G=(size_t)1<<n; vector<u32> om(G); vector<vector<u32>> dummy;
    vector<u32> flat; vector<u64> foff(G+1); foff[0]=0;
    for(size_t g=0;g<G;g++){tmp.clear();for(u64 i=off[g];i<off[g+1];i++)tmp.push_back(lst[i]|(u32)g); sort(tmp.begin(),tmp.end()); tmp.erase(unique(tmp.begin(),tmp.end()),tmp.end()); om[g]=tmp.size(); tot+=tmp.size(); if(tmp.size()>mx){mx=tmp.size();mg=g;} for(u32 x:tmp)flat.push_back(x); foff[g+1]=flat.size();}
    // wall words printed in time order, bit t = time t
    char buf[64]; for(int t=0;t<n;t++)buf[t]='0'+(mg>>t&1); buf[n]=0;
    u32 a1=0,a0=0; for(int t=0;t<n;t++){ if(t%2==0)a1|=1u<<t; else a0|=1u<<t; }
    printf("n=%2d N=%llu  sumOmega=%llu  maxOmega=%llu (wall %s)  max^(1/n)=%.6f = %.5f bits  mean^(1/n)=%.6f  alternating %u %u\n",n,(unsigned long long)N,(unsigned long long)tot,(unsigned long long)mx,buf,pow(mx,1.0/n),log2((double)mx)/n,pow((double)tot/G,1.0/n),om[a1],om[a0]); fflush(stdout);
    if(n==nmax)break;
    // next level: g' of length n+1 = g + top bit; f(t)=g'(t+1)^or(t) t<n; f(n) free. pairs (f,g') : east list of f gets g'
    size_t G2=(size_t)1<<(n+1); vector<u64> off2(G2+1,0); u32 mask=(1u<<n)-1; 
    for(size_t g=0;g<G;g++)for(int top=0;top<2;top++){u32 gp=g|((u32)top<<n);u32 sh=gp>>1; for(u64 i=foff[g];i<foff[g+1];i++){u32 f=(sh^flat[i])&mask; off2[f+1]++; off2[(f|(1u<<n))+1]++;}}
    for(size_t i=0;i<G2;i++)off2[i+1]+=off2[i]; vector<u32> lst2(off2[G2]); vector<u64> pos(off2.begin(),off2.end()-1);
    for(size_t g=0;g<G;g++)for(int top=0;top<2;top++){u32 gp=g|((u32)top<<n);u32 sh=gp>>1; for(u64 i=foff[g];i<foff[g+1];i++){u32 f=(sh^flat[i])&mask; lst2[pos[f]++]=gp; lst2[pos[f|(1u<<n)]++]=gp;}}
    off.swap(off2); lst.swap(lst2); n++; N=lst.size();
  }
}
