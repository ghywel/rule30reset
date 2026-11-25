// Fill gaps in a finite word census. An initial seed is a replayed physical
// cone for a neighbouring word. Keep part of its west prefix and vary the
// eastern tail. Only a complete, directly replayable word is written.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <random>
#include <string>
#include <vector>

using U=std::uint64_t;
using Row=std::vector<U>;
static std::mt19937_64 rng;
static void tick(Row& x,int width,int wall) {
    U left=wall;
    for(int i=0;i<(width+63)/64;++i) {
        U u=x[i];x[i]=((u<<1)|left)^(u|(u>>1)|(x[i+1]<<63));left=u>>63;
    }
}
static bool known(const Row& initial,int w,int t) {
    Row x=initial;
    for(int i=0;i<t;++i) {
        bool last=x[(w-1)/64]>>((w-1)%64)&1;
        tick(x,w,i%2);
        if(!last && --w==0)return false;
    }
    return true;
}
static int needed(const Row& x,int s) {
    int lo=1,hi=2*s+1;
    while(lo<hi){int m=(lo+hi)/2;if(known(x,m,2*s))hi=m;else lo=m+1;}
    return lo;
}
static Row scramble(const Row& start,int keep,int full) {
    Row result((full+63)/64+1);
    for(auto& x:result)x=rng();
    for(int i=0;i<keep/64;++i) result[i]=start[i];
    if(keep%64) {
        U m=(U(1)<<(keep%64))-1;
        result[keep/64]=(result[keep/64]&~m)|(start[keep/64]&m);
    }
    return result;
}
static int score(const Row& initial,const std::string& w) {
    Row x=initial;
    int T=2*(int(w.size())-1);
    for(int t=0;t<=T;++t){
        if(!(t%2) && (x[0]&1)!=unsigned(w[t/2]-'0'))return t/2;
        if(t<T)tick(x,T-t,t%2);
    }
    return w.size();
}
static std::string target(const std::string& order) {
    std::string w;
    for(char b:order){w+="100";for(int j=0;j<(b=='A'?3:5);++j)w+="10000";}
    return w+"1";
}
static std::string word(int n,unsigned code) {
    std::string w(n,'A');
    for(int i=n-1;i>=0;--i,code>>=1)if(code&1)w[i]='B';
    return w;
}
struct Seed {std::string order;Row row;int width;};
static Seed load_seed(std::string order,const std::string& p) {
    Row x((p.size()+63)/64+1);
    for(std::size_t i=0;i<p.size();++i)if(p[i]=='1')x[i/64]|=U(1)<<(i%64);
    return {order,x,int(p.size())};
}
static int prefix_match(const std::string& a,const std::string& b) {
    int i=0;while(i<int(std::min(a.size(),b.size()))&&a[i]==b[i])++i;return i;
}
static std::string find(const std::string& order,const std::vector<Seed>& seeds,int attempts) {
    const std::string w=target(order);
    int n=2*int(w.size())-1;
    std::vector<std::vector<unsigned>> near(order.size()+1);
    for(unsigned i=0;i<seeds.size();++i)near[prefix_match(order,seeds[i].order)].push_back(i);
    int hi=near.size()-1;while(hi>0 && near[hi].empty())--hi;
    Row best;
    int bestScore=-1;
    std::map<int,int> cuts;
    for(int i=0;i<attempts;++i) {
        Row trial;
        if(best.empty()||i%48==0) {
            int j=hi-int(rng()%3);while(j>0 && near[j].empty())--j;
            if(j<0 || near[j].empty())j=hi;
            const auto& seed=seeds[near[j][rng()%near[j].size()]];
            trial=scramble(seed.row,std::min(seed.width,n),n);
            if(i%384==0){bestScore=-1;cuts.clear();}
        } else {
            int back=1+int(rng()%std::min(68,std::max(1,bestScore)));
            int s=std::max(0,bestScore-back);
            if(!cuts.count(s))cuts[s]=needed(best,s);
            trial=scramble(best,cuts[s],n);
        }
        int h=score(trial,w);
        if(h==int(w.size())) {
            std::string p;
            for(int j=0;j<n;++j)p+=char('0'+((trial[j/64]>>(j%64))&1));
            return p;
        }
        if(h>bestScore || (h==bestScore && rng()%8==0)) {
            bestScore=h;best=std::move(trial);cuts.clear();
        }
    }
    return {};
}
int main(int argc,char**argv) {
    if(argc<6){std::cerr<<"complete PHYSICAL_TSV DEPTH ATTEMPTS SEED OUTPUT [ADDITIONAL_ROWS ...]\n";return 2;}
    std::ifstream in(argv[1]);std::ofstream out(argv[5]);
    int depth=std::stoi(argv[2]), attempts=std::stoi(argv[3]);rng.seed(std::stoull(argv[4]));
    if(!in||!out||depth<1||depth>20) return 2;
    std::vector<Seed> seeds;std::map<std::string,unsigned> seen;
    int n,len;unsigned code,start;U s;std::string p;
    while(in>>n>>code>>s>>start>>len>>p){
        auto w=word(n,code);seen[w]=seeds.size();seeds.push_back(load_seed(w,p));
    }
    for(int arg=6;arg<argc;++arg) {
        std::ifstream extra(argv[arg]);
        if(!extra) return 2;
        std::string w;
        while(extra>>w>>p) {
            if(w.empty() || w.find_first_not_of("AB")!=w.npos ||
               p.find_first_not_of("01")!=p.npos) return 2;
            seen[w]=seeds.size();seeds.push_back(load_seed(w,p));
        }
    }
    for(n=1;n<=depth;++n) {
        unsigned count=0;
        for(code=0;code<(1u<<n);++code) {
            auto w=word(n,code);
            if(!seen.count(w)) {
                auto p=find(w,seeds,attempts);
                if(p.empty())continue;
                seen[w]=seeds.size();seeds.push_back(load_seed(w,p));out<<w<<'\t'<<p<<'\n';
            }
            ++count;
        }
        out.flush();std::cout<<n<<" "<<count<<"/"<<(1u<<n)<<std::endl;
    }
}
