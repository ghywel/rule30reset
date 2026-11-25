// Build a tree of nested prefixes of ONE initial half. Each edge fixes more
// eastern cells. The separate ternary checker is the authority on every node.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <set>
#include <string>
#include <vector>

using U64=std::uint64_t;
using Row=std::vector<U64>;
static U64 rng;
static U64 random_word() {
    U64 x=(rng+=0x9e3779b97f4a7c15ULL);
    x=(x^(x>>30))*0xbf58476d1ce4e5b9ULL;
    x=(x^(x>>27))*0x94d049bb133111ebULL;
    return x^(x>>31);
}
static void tick(Row& x,int width,int wall) {
    U64 left=wall;
    for(int i=0;i<(width+63)/64;++i) {
        U64 u=x[i]; x[i]=((u<<1)|left)^(u|(u>>1)|(x[i+1]<<63)); left=u>>63;
    }
}
static bool known_to(const Row& initial,int width,int ticks) {
    Row x=initial;
    for(int t=0;t<ticks;++t) {
        bool last=(x[(width-1)/64]>>((width-1)%64))&1;
        tick(x,width,t%2);
        if(!last && --width==0) return false;
    }
    return true;
}
static std::string bits(const Row& x,int w) {
    std::string p;
    for(int j=0;j<w;++j) p+=char('0'+((x[j/64]>>(j%64))&1));
    return p;
}
static std::string block(char b) {
    std::string w="100";
    for(int i=0;i<(b=='A'?3:5);++i) w+="10000";
    return w;
}
struct Node {std::string order,prefix;};
struct Search {
    int trials,candidates;
    U64 probes=0;
    std::string child(const std::string& prefix,const std::string& target) {
        int T=2*(int(target.size())-1), n=T+1;
        Row initial((n+63)/64+1);
        for(auto& q:initial) q=random_word();
        for(int i=0;i<int(prefix.size());++i) {
            U64 bit=U64(1)<<(i%64);
            if(prefix[i]=='1') initial[i/64]|=bit; else initial[i/64]&=~bit;
        }
        ++probes;
        Row x=initial;
        for(int t=0;t<=T;++t) {
            if(t%2==0 && ((x[0]&1)!=unsigned(target[t/2]-'0'))) return {};
            if(t<T) tick(x,n-t-1,t%2);
        }
        int lo=std::max(1,int(prefix.size())),hi=n;
        while(lo<hi) {
            int mid=lo+(hi-lo)/2;
            if(known_to(initial,mid,T)) hi=mid; else lo=mid+1;
        }
        return bits(initial,lo);
    }
    bool build(const Node& node,const std::string& past,int depth,std::vector<Node>& answer) {
        if(!depth) {answer.push_back(node);return true;}
        std::vector<Node> branches;
        for(char b:std::string("BA")) {
            std::string next=past+block(b),target=next+"1001";
            std::set<std::string> tried;
            bool success=false;
            for(int i=0;i<trials && int(tried.size())<candidates;++i) {
                std::string p=child(node.prefix,target);
                if(p.empty()||!tried.insert(p).second) continue;
                if(build({node.order+b,p},next,depth-1,branches)) {success=true;break;}
            }
            if(!success) return false;
        }
        answer.push_back(node); answer.insert(answer.end(),branches.begin(),branches.end());
        return true;
    }
};
int main(int argc,char**argv) {
    if(argc!=7) {std::cerr<<"tree DEPTH TRIALS CANDIDATES SEED ROOT_PREFIX OUTPUT\n";return 2;}
    int depth=std::stoi(argv[1]); Search search{std::stoi(argv[2]),std::stoi(argv[3])};
    rng=std::stoull(argv[4]); std::string root=argv[5];
    if(root.empty()||root.size()>7||root.find_first_not_of("01")!=std::string::npos) return 2;
    std::vector<Node> result;
    bool found=search.build({"",root},"",depth,result);
    std::cout<<"depth "<<depth<<" found "<<found<<" probes "<<search.probes<<" nodes "<<result.size()<<"\n";
    if(!found) return 1;
    std::ofstream file(argv[6]);
    for(const auto& n:result) file<<(n.order.empty()?"-":n.order)<<'\t'<<n.prefix<<'\n';
    return file?0:1;
}
