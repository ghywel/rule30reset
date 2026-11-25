// Growth of the OR words beside one periodic wall (in time order), on a strip of cells with the far edge free (claudeM5, M191). Usage: walls CELLS WALL
// growth of OR words beside one periodic wall, strip of w cells: only the sets met along that wall are made
#include <vector>
#include <string>
#include <unordered_map>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <algorithm>
using namespace std; typedef unsigned long long u64;
int w; size_t NW; struct H{size_t operator()(const vector<u64>&v)const{size_t h=1469598103934665603ULL;for(u64 x:v){h^=x;h*=1099511628211ULL;h^=h>>29;}return h;}};
static inline int stepc(int x,int b,int e){int r=0;for(int j=0;j<w;j++){int l=j?(x>>(j-1)&1):b;int c=x>>j&1;int rr=j==w-1?e:(x>>(j+1)&1);r|=(l^(c|rr))<<j;}return r;}
int main(int argc,char**argv){ w=atoi(argv[1]); string p=argv[2]; size_t cap=argc>3?atoll(argv[3]):4000000; int P=p.size(); int N=1<<w; NW=max<size_t>(1,(N+63)/64); int C=(N+7)/8;
  vector<vector<vector<u64>>> T(3); for(int l=0;l<3;l++){int b=l==2,o=l>=1; vector<vector<u64>> single(N,vector<u64>(NW,0)); for(int x=0;x<N;x++){if((b|(x&1))!=o)continue;for(int e=0;e<2;e++){int y=stepc(x,b,e);single[x][y>>6]|=1ULL<<(y&63);}} T[l].assign(C*256,vector<u64>(NW,0)); for(int c=0;c<C;c++)for(int v=1;v<256;v++){int lo=__builtin_ctz(v);auto&t=T[l][c*256+v];t=T[l][c*256+(v&(v-1))];int s=c*8+lo;if(s<N)for(size_t i=0;i<NW;i++)t[i]|=single[s][i];}}
  // nodes (phase, set)
  vector<unordered_map<vector<u64>,int,H>> id(P); vector<vector<u64>> st; vector<int> ph; vector<array<int,2>> nx; vector<u64> full(NW,~0ULL); if(N<64)full[0]=(1ULL<<N)-1; st.push_back(full); ph.push_back(0); id[0][full]=0;
  for(size_t i=0;i<st.size();i++){ int b=p[ph[i]]-'0', q=(ph[i]+1)%P; array<int,2> a={-1,-1}; for(int k=0;k<(b?1:2);k++){int l=b?2:k; vector<u64> r(NW,0); vector<u64> s=st[i]; for(int c=0;c<C;c++){int v=s[c>>3]>>((c&7)*8)&255;if(!v)continue;auto&t=T[l][c*256+v];for(size_t j=0;j<NW;j++)r[j]|=t[j];} bool z=true;for(u64 x:r)if(x){z=false;break;} if(z)continue; auto it=id[q].find(r); if(it==id[q].end()){int n=st.size();id[q].emplace(r,n);st.push_back(r);ph.push_back(q);a[k]=n;if(st.size()>cap){printf("w=%d wall %s: more than %zu sets\n",w,p.c_str(),cap);return 0;}} else a[k]=it->second;} nx.push_back(a);}
  size_t n=st.size(); vector<double> V(n,1),U(n); double lg=0; int its=P*200; for(int it=0;it<its;it++){double mx=0;for(size_t i=0;i<n;i++){double s=0;for(int k=0;k<2;k++)if(nx[i][k]>=0)s+=V[nx[i][k]];U[i]=s;mx=max(mx,s);} for(size_t i=0;i<n;i++)V[i]=U[i]/mx; if(it>=its-P*40)lg+=log(mx);} double g=exp(lg/(P*40)); printf("w=%d wall %-12s sets %8zu growth %.6f = %.5f bits a tick\n",w,p.c_str(),n,g,log2(g)); fflush(stdout);}
