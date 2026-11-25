// Compose one left-to-right Rule 30 transducer per physical tick. Draw an
// initial eastern bit only when an output depends on it. Keeping different
// initial prefixes avoids treating repeated samples of a cylinder as choices.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <random>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

using PoolSize=std::size_t;
static std::mt19937_64 dice;
struct State {
    // left input, and buffered middle input (2 means the stream has not supplied it).
    struct Layer {unsigned char left, middle;};
    std::vector<Layer> layer;
    std::string prefix;
    unsigned gate=0;
    unsigned consumed=0;
    unsigned read(unsigned level) {
        if(!level) {
            if(consumed==prefix.size()) prefix+=char('0'+(dice()&1));
            return prefix[consumed++]-'0';
        }
        auto& z=layer[level-1];
        unsigned middle=z.middle==2?read(level-1):z.middle;
        unsigned value;
        if(middle) {value=1;z.middle=2;}
        else {value=read(level-1);z.middle=value;}
        unsigned out=z.left^value;
        z.left=middle;
        return out;
    }
    void tick() {
        layer.push_back({(unsigned char)(layer.size()%2),(unsigned char)gate});
        gate=read(layer.size());
    }
    void sample() {tick();tick();}
};
using Pool=std::vector<State>;
static std::string block(char b) {
    std::string s="100";
    for(unsigned j=0;j<(b=='A'?3u:5u);++j) s+="10000";
    return s;
}
struct Search {
    unsigned capacity,attempts;
    std::vector<unsigned> coverage;
    std::ofstream output;
    bool unique(const State& s,std::set<std::string>& seen) {
        return seen.insert(s.prefix).second;
    }
    Pool step(const Pool& parents,unsigned bit) {
        Pool next;
        std::set<std::string> seen;
        std::vector<std::size_t> order(parents.size());
        for(std::size_t i=0;i<order.size();++i) order[i]=i;
        for(unsigned i=0;i<attempts && next.size()<capacity;++i) {
            if(i%order.size()==0) std::shuffle(order.begin(),order.end(),dice);
            State s=parents[order[i%order.size()]];
            s.sample();
            if(bit==s.gate && unique(s,seen)) next.push_back(std::move(s));
        }
        return next;
    }
    Pool extend(const Pool& parents,char b) {
        // The previous node already forced the first four readings of this block.
        std::string rest=(block(b)+"1001").substr(4);
        Pool p=parents;
        for(char c:rest) {
            p=step(p,c-'0');
            if(p.empty()) break;
        }
        return p;
    }
    void visit(const Pool& p,const std::string& order,unsigned depth) {
        if(order.size()==depth) return;
        for(char b:std::string("AB")) {
            Pool n=extend(p,b);
            if(n.empty()) continue;
            auto w=order+b;
            ++coverage[w.size()];
            const auto& s=*std::min_element(n.begin(),n.end(),
                [](const State& x,const State& y){return x.prefix.size()<y.prefix.size();});
            output<<w<<'\t'<<s.prefix<<'\n';
            visit(n,w,depth);
        }
    }
};
int main(int argc,char**argv) {
    if(argc!=7){std::cerr<<"stream DEPTH POOL TRIALS SEED ROOT OUTPUT\n";return 2;}
    unsigned depth=std::stoul(argv[1]);dice.seed(std::stoull(argv[4]));
    Search s{unsigned(std::stoul(argv[2])),unsigned(std::stoul(argv[3])),
             std::vector<unsigned>(depth+1),std::ofstream(argv[6])};
    if(!s.output||!s.capacity||!s.attempts) return 2;
    State root;root.prefix=argv[5];root.gate=root.read(0);
    for(char b:std::string("001")) {root.sample();if(root.gate!=unsigned(b-'0'))return 2;}
    if(root.consumed!=root.prefix.size()||root.prefix!=argv[5]||root.prefix.front()!='1') return 2;
    s.output<<"-\t"<<root.prefix<<'\n';
    s.visit({root},"",depth);
    for(unsigned j=1;j<=depth;++j) std::cout<<j<<" "<<s.coverage[j]<<'\n';
    return s.output?0:1;
}
