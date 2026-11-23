// limit windows of a periodic drive, lifted one column at a time; SCCs of the limit graph.
// usage: lift WORD W0 W1   (WORD like 001 or 011). Output per width: limit sizes, SCC summary.
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <vector>
#include <string>
#include <algorithm>
#include <unordered_map>
using namespace std; typedef uint32_t u32; typedef uint64_t u64;
static u64 gcdu(u64 a,u64 b){while(b){u64 t=a%b;a=b;b=t;}return a;}
static int w,P; static vector<int> D;
static inline u64 stp(u64 r,int c,u64 z){u64 f=(r<<1)|c|(z<<(w+1)); return ((f<<1)^(f|(f>>1)))>>1&((1ULL<<w)-1);}
static vector<vector<u64>> S; // sorted windows per phase
static void fix(){ // keep windows with a predecessor in the set, until stable
  for(;;){ vector<vector<u64>> img(P); u64 before=0,after=0; for(int p=0;p<P;p++) before+=S[p].size();
    for(int p=0;p<P;p++){ auto&o=img[(p+1)%P]; o.reserve(S[p].size()*2); for(u64 r:S[p]){o.push_back(stp(r,D[p],0));o.push_back(stp(r,D[p],1));} }
    for(int p=0;p<P;p++){ auto&o=img[p]; sort(o.begin(),o.end()); o.erase(unique(o.begin(),o.end()),o.end()); vector<u64> k; k.reserve(S[p].size()); set_intersection(S[p].begin(),S[p].end(),o.begin(),o.end(),back_inserter(k)); S[p].swap(k); after+=S[p].size(); }
    if(after==before) return; } }
int main(int ac,char**av){ string W=av[1]; P=W.size(); for(char c:W) D.push_back(c-'0'); int w0=atoi(av[2]),w1=atoi(av[3]);
  w=w0; S.assign(P,{}); for(int p=0;p<P;p++){ S[p].resize(1ULL<<w); for(u64 r=0;r<(1ULL<<w);r++) S[p][r]=r; } fix();
  for(;;){ u64 n=0; for(auto&s:S) n+=s.size(); printf("word %s width %d limit windows %llu (",W.c_str(),w,(unsigned long long)n); for(auto&s:S) printf(" %zu",s.size()); printf(" )\n"); fflush(stdout);
    // SCC (iterative Tarjan) on nodes id = offset+index
    vector<u64> off(P+1,0); for(int p=0;p<P;p++) off[p+1]=off[p]+S[p].size();
    auto id=[&](int p,u64 r)->long long{ auto it=lower_bound(S[p].begin(),S[p].end(),r); if(it==S[p].end()||*it!=r) return -1; return off[p]+(it-S[p].begin()); };
    vector<long long> succ(2*n); for(int p=0;p<P;p++) for(size_t i=0;i<S[p].size();i++) for(int z=0;z<2;z++) succ[2*(off[p]+i)+z]=id((p+1)%P,stp(S[p][i],D[p],z));
    vector<u32> idx(n,0),low(n,0),comp(n,0xffffffffu); vector<char> on(n,0); vector<u32> st; u32 cnt=0,nc=0; vector<pair<u32,int>> work; vector<u64> csz;
    for(u64 s=0;s<n;s++){ if(idx[s]) continue; work.push_back({(u32)s,0}); idx[s]=low[s]=++cnt; st.push_back(s); on[s]=1;
      while(!work.empty()){ u32 v=work.back().first; int&k=work.back().second; if(k<2){ long long x=succ[2*(u64)v+k]; k++; if(x<0) continue; if(!idx[x]){ idx[x]=low[x]=++cnt; st.push_back(x); on[x]=1; work.push_back({(u32)x,0}); } else if(on[x]) low[v]=min(low[v],idx[x]); }
        else { work.pop_back(); if(!work.empty()){u32 u=work.back().first; low[u]=min(low[u],low[v]);} if(low[v]==idx[v]){ u64 c=0; for(;;){u32 x=st.back(); st.pop_back(); on[x]=0; comp[x]=nc; c++; if(x==v) break;} csz.push_back(c); nc++; } } } }
    // nontrivial: size>1 (phases make self loops impossible unless P=1)
    vector<char> in(nc,0),out(nc,0); vector<u64> maxdep(nc,0); for(u64 v=0;v<n;v++) for(int z=0;z<2;z++){ long long x=succ[2*v+z]; if(x<0) continue; if(comp[x]!=comp[v]){ out[comp[v]]=1; } }
    // "entered": some nontrivial component reaches it
    // process components in topological order: Tarjan numbers components in reverse topological order
    vector<char> ent(nc,0); // reachable from a different nontrivial component
    vector<char> has(nc,0); for(u32 c=0;c<nc;c++) if(csz[c]>1) has[c]=1;
    vector<vector<u32>> dummy; // propagate from sources (high numbers) to sinks
    vector<u32> order; // nodes sorted by comp descending
    vector<u64> bycomp(n); { vector<u64> start(nc+1,0); for(u64 v=0;v<n;v++) start[comp[v]+1]++; for(u32 c=0;c<nc;c++) start[c+1]+=start[c]; vector<u64> pos(start); for(u64 v=0;v<n;v++) bycomp[pos[comp[v]]++]=v; 
      for(long long c=nc-1;c>=0;c--) for(u64 k=start[c];k<start[c+1];k++){ u64 v=bycomp[k]; for(int z=0;z<2;z++){ long long x=succ[2*v+z]; if(x<0) continue; if(comp[x]!=(u32)c && (has[c]||ent[c])) ent[comp[x]]=1; } } }
    vector<pair<u64,u32>> big; for(u32 c=0;c<nc;c++) if(has[c]) big.push_back({csz[c],c}); sort(big.rbegin(),big.rend());
    printf("   components with a cycle: %zu\n",big.size()); int shown=0; for(auto&b:big){ if(shown++>=12) break; u32 c=b.second; // column-1 gate word at phases: print if the component is a simple cycle
      u64 v0=0; for(u64 v=0;v<n;v++) if(comp[v]==c){v0=v;break;} // period gcd by BFS levels
      vector<int> lev; unordered_map<u32,int> L; L[v0]=0; vector<u32> q={(u32)v0}; u64 g=0; for(size_t h=0;h<q.size();h++){u32 v=q[h]; for(int z=0;z<2;z++){long long x=succ[2*(u64)v+z]; if(x<0||comp[x]!=c) continue; auto it=L.find(x); if(it==L.end()){L[x]=L[v]+1;q.push_back(x);} else { u64 d=llabs((long long)L[v]+1-it->second); g=gcdu(g,d);} }}
      printf("     size %llu period %llu %s %s\n",(unsigned long long)b.first,(unsigned long long)g,ent[c]?"entered":"NOT ENTERED by another component",out[c]?"":"CLOSED"); }
    if(w>=w1) break; // lift
    vector<vector<u64>> N(P); for(int p=0;p<P;p++){ N[p].reserve(S[p].size()*2); for(u64 r:S[p]) N[p].push_back(r); for(u64 r:S[p]) N[p].push_back(r|(1ULL<<w)); }
    S.swap(N); w++; fix(); }
  return 0; }
