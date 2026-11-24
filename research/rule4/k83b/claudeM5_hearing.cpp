// Exhaustive count of silent (right half, wall) pairs through T ticks, for a flip mask on the right (claudeM5)
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>
#include <atomic>
using namespace std; typedef uint32_t v;
int main(int c,char**a){ int T=atoi(a[1]); v mask=strtoul(a[2],0,0); v M=(T<32)?((1u<<T)-1):~0u; atomic<unsigned long long> sil{0}; vector<thread> th; int K=6; for(int id=0;id<K;++id) th.emplace_back([&,id]{ unsigned long long loc=0; for(v W=id;W<=M;W+=K) for(v x0=0;x0<=M;++x0){ v x=x0,y=(x0^mask)&M; bool ok=true; for(int t=0;t<T;++t){ v w=(W>>t)&1; if(((x^y)&1)&&!w){ok=false;break;} x=((x<<1|w)^(x|(x>>1)))&M; y=((y<<1|w)^(y|(y>>1)))&M; } loc+=ok; } sil+=loc; }); for(auto&t:th) t.join(); printf("T %d mask %u silent %llu of 2^%d heard %.5f%%\n",T,mask,(unsigned long long)sil.load(),2*T,100.0*(1-(double)sil.load()/(double)(1ull<<(2*T)))); }
