// Independent count of words of two neighbouring Rule 30 columns (claudeM5). Forward: every wall, every right half of n cells.
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <thread>
#include <vector>
#include <mutex>
using namespace std; typedef uint64_t u;
int main(int c,char**v){ int n=atoi(v[1]); int T=atoi(v[2]); u W=1ull<<(n-1), X=1ull<<n, M=X-1; u total=0; unsigned mx=0; u alt0=0,alt1=0; vector<u> hist(X+1,0); mutex mu; long double ent=0; vector<thread> th; 
 auto work=[&](int id){ vector<uint32_t> cnt(X); u tot=0; unsigned lm=0; long double le=0; u a0=0,a1=0; map<u,u> lh;
   for(u s=id;s<W;s+=T){ fill(cnt.begin(),cnt.end(),0); for(u x0=0;x0<X;++x0){ u x=x0,g=x&1; for(int t=0;t<n-1;++t){ x=((x<<1|((s>>t)&1))^(x|(x>>1)))&M; g|=(x&1)<<(t+1);} cnt[g]++; }
     unsigned k=0; long double e=0; for(u g=0;g<X;++g) if(cnt[g]){++k; lh[cnt[g]]++; e+=(long double)cnt[g]*log2l((long double)cnt[g]); }
     tot+=k; lm=max(lm,k); le+=e; // alternating walls: s_t = t&1 (white first) and black first
     u wf=0,bf=0; for(int t=0;t<n-1;++t){ if(t&1) wf|=1ull<<t; else bf|=1ull<<t; } if(s==wf) a0=k; if(s==bf) a1=k; }
   lock_guard<mutex> l(mu); total+=tot; mx=max(mx,lm); ent+=le; alt0+=a0; alt1+=a1; for(auto&p:lh) hist[p.first]+=p.second; };
 for(int i=0;i<T;++i) th.emplace_back(work,i); for(auto&t:th) t.join();
 // each wall of n-1 bits stands for two walls of n bits; pair mass = count/4^n
 long double H=2.0L*n-ent/((long double)W*(long double)X); // sum over s,g (cnt/(W X)) ... see note
 printf("n %d N %llu max %u white-first %llu black-first %llu H %.12Lf\n",n,(unsigned long long)(2*total),mx,(unsigned long long)alt0,(unsigned long long)alt1,H);
 if(c>3){ FILE*f=fopen(v[3],"w"); for(u m=1;m<=X;++m) if(hist[m]) fprintf(f,"%llu %llu\n",(unsigned long long)m,(unsigned long long)(2*hist[m])); fclose(f);} }
