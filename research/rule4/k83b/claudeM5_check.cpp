// Independent checker for the reverse strip certificates (claudeM5): bit-parallel rule, different loop order, own reader.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <thread>
#include <atomic>
using namespace std; typedef uint64_t u; typedef uint32_t v;
int main(int c,char**a){ FILE*f=fopen(a[1],"rb"); fseek(f,0,SEEK_END); size_t L=ftell(f); rewind(f); vector<unsigned char> B(L); if(fread(B.data(),1,L,f)!=L) return 2; size_t p=0; auto rd=[&](int k){ u x=0; if(p+k>L){puts("TRUNCATED"); exit(1);} for(int i=0;i<k;++i) x|=(u)B[p+i]<<(8*i); p+=k; return x; };
  if(memcmp(B.data(),"R30B4V01",8)) { puts("HEADER"); return 1;} p=8; unsigned wm=rd(4); size_t n=rd(4); u num=rd(8),den=rd(8);
  vector<unsigned char> w(n); vector<u> wt(n); vector<v> ed(4*n); vector<size_t> off(n);
  for(size_t i=0;i<n;++i){ w[i]=rd(1); wt[i]=rd(8); for(int k=0;k<4;++k) ed[4*i+k]=(v)rd(4); if(w[i]<1||w[i]>wm||!wt[i]){puts("BAD STATE");return 1;} off[i]=p; p+=8*(((1ull<<w[i])+63)/64); }
  if(p!=L){ puts("EXTRA"); return 1; }
  auto has=[&](size_t s,u row){ row&=(1ull<<w[s])-1; return (B[off[s]+(row>>3)]>>(row&7))&1; };
  for(u r=0;r<(1ull<<w[0]);++r) if(!has(0,r)){puts("START");return 1;}
  atomic<long> bad{0}; atomic<size_t> tested{0}; unsigned T=9; vector<thread> th; atomic<size_t> nx{0}; u minW=~0ull,maxW=0; for(size_t i=0;i<n;++i){minW=min(minW,wt[i]);maxW=max(maxW,wt[i]);}
  auto work=[&]{ size_t loc=0; while(1){ size_t i=nx.fetch_add(256); if(i>=n) break; for(size_t s=i;s<min(n,i+256);++s){ __uint128_t sum=0; for(int k=0;k<4;++k){ v j=ed[4*s+k]; if(j!=0xffffffffu){ if(j>=n||w[j]>w[s]+1||w[j]>wm){bad++;continue;} sum+=wt[j];} }
      if(sum*(__uint128_t)den>(__uint128_t)num*wt[s]) bad++;
      unsigned rw=min<unsigned>(w[s]+1,wm); u Mw=(1ull<<w[s])-1;
      for(u x=0;x<(1ull<<rw);++x) for(u b=0;b<2;++b){ u base=((x<<1)|b), orr=x|(x>>1); u y0=(base^orr)&Mw, y1=y0; if(rw==w[s]) y1=(base^(orr|(1ull<<(w[s]-1))))&Mw;
        ++loc; if(has(s,y0)||has(s,y1)){ v j=ed[4*s+2*b+(x&1)]; if(j==0xffffffffu||!has(j,x)) bad++; } } } } tested+=loc; };
  for(unsigned i=0;i<T;++i) th.emplace_back(work); for(auto&t:th) t.join();
  printf("%s states %zu width %u q %llu/%llu bad %ld tested %zu weight(start) %llu min %llu max %llu\n",bad?"REJECTED":"VERIFIED",n,wm,(unsigned long long)num,(unsigned long long)den,bad.load(),tested.load(),(unsigned long long)wt[0],(unsigned long long)minW,(unsigned long long)maxW); return bad?1:0; }
