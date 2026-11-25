// Maximum winning set on each finite strip, with d future block labels visible
// during each block. Lift only winning microstates of the preceding width.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <vector>

using U=std::uint64_t;
using Set=std::vector<U>;  // sorted, distinct
using Game=std::vector<std::vector<Set>>;
static U advance(U x,unsigned w,unsigned e) {
    x|=U(e)<<w;
    U mid=(x<<1)^(x|(x>>1));
    return (((mid<<1)|1)^(mid|(mid>>1)))&((U(1)<<w)-1);
}
static U literal(U x,unsigned w,unsigned e) {
    x |= U(e)<<w;
    for(unsigned t=0;t<2;++t) {
        U y=0;
        for(unsigned j=0;j<w+1-t;++j) {
            U l=j?(x>>(j-1))&1:t;
            y|=(l^(((x>>j)|(x>>(j+1)))&1))<<j;
        }
        x=y;
    }
    return x;
}
static Set common(const Set& a,const Set& b) {
    Set both;
    std::set_intersection(a.begin(),a.end(),b.begin(),b.end(),std::back_inserter(both));
    return both;
}
static void filter(Set& rows,const Set& next,unsigned w) {
    std::unordered_set<U> live(next.begin(),next.end());
    rows.erase(std::remove_if(rows.begin(),rows.end(),[&](U x) {
        for(unsigned e=0;e<4;++e) if(live.count(advance(x,w,e))) return false;
        return true;
    }),rows.end());
}
static std::size_t population(const Game& game) {
    std::size_t n=0;
    for(const auto& word:game) for(const Set& s:word) n+=s.size();
    return n;
}
static std::string block(int n) {
    std::string s="100";
    for(int i=0;i<n;++i) s+="10000";
    return s;
}
int main(int argc,char**argv) {
    if(argc!=6) {std::cerr<<"lift PREVIEW MAX_WIDTH SHORT_FIVES LONG_FIVES OUTPUT\n";return 2;}
    unsigned d=std::stoul(argv[1]),last=std::stoul(argv[2]);
    if(d>5||last<4||last>55) return 2;
    unsigned contexts=2u<<d;
    Game game(contexts);
    for(unsigned c=0;c<contexts;++c) {
        auto word=block(std::stoi(argv[(c>>d)?4:3]));
        for(char b:word) {
            Set phase;
            for(U x=b-'0';x<16;x+=2) phase.push_back(x);
            game[c].push_back(std::move(phase));
        }
    }
    std::ofstream file(argv[5]);
    if(!file) return 2;
    for(unsigned w=4;w<=last;++w) {
        if(w>4) for(auto& word:game) for(auto& p:word) {
            auto n=p.size();
            p.reserve(n*2);
            for(unsigned i=0;i<n;++i) p.push_back(p[i]|(U(1)<<(w-1)));
        }
        if(w<=10) for(U x=0;x<(U(1)<<w);++x) for(unsigned e=0;e<4;++e)
            if(advance(x,w,e)!=literal(x,w,e)) throw std::runtime_error("physical control");
        unsigned passes=0;
        std::size_t n=population(game),old;
        do {
            old=n;
            ++passes;
            for(unsigned c=0;c<contexts;++c) {
                unsigned suffix=(2*c)&(contexts-1);
                Set dest=common(game[suffix][0],game[suffix+1][0]);
                auto& phases=game[c];
                for(std::size_t j=phases.size();j-->0;) {
                    filter(phases[j],j+1==phases.size()?dest:phases[j+1],w);
                }
            }
            n=population(game);
        } while(old!=n);
        std::cout<<w<<" "<<passes<<" "<<n<<" seams";
        for(unsigned c=0;c<contexts;c+=2) {
            Set seam=common(game[c][0],game[c+1][0]);
            std::cout<<" "<<seam.size();
            if(w==last) for(U x:seam) file<<c/2<<' '<<x<<'\n';
        }
        std::cout<<std::endl;
        if(!n) break;
    }
    return file?0:1;
}
