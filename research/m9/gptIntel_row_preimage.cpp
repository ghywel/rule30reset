// Backward open-strip reachability for one sampled gate word. A reduced ordered
// binary decision diagram describes an entire set of rows, bit 0 = column 1.
// Input on stdin: the kit's trap codes, as whitespace-separated decimal integers.
// Usage: row_preimage WIDTH DELAY GAPS
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

using Id = std::uint32_t;
struct Node { int bit; Id low; Id high; };

struct Diagram {
    int width;
    std::vector<Node> nodes;
    std::vector<std::unordered_map<std::uint64_t, Id>> tables;
    explicit Diagram(int w) : width(w), nodes{{w,0,0},{w,1,1}}, tables(w) {}

    Id branch(int bit, Id low, Id high) {
        if (low == high) return low;
        auto key = (std::uint64_t(low) << 32) | high;
        auto [it, added] = tables[bit].emplace(key, Id(nodes.size()));
        if (added) nodes.push_back({bit, low, high});
        return it->second;
    }
    Id take(Id id, int bit, bool value) const {
        auto n = nodes[id];
        if (n.bit < bit) throw std::logic_error("skipped a decision");
        return n.bit == bit ? (value ? n.high : n.low) : id;
    }
    Id prefix(const std::vector<unsigned>& codes, int i) {
        if (codes.empty()) return 0;
        if (i == std::min(16,width)) return 1;
        std::array<std::vector<unsigned>,2> groups;
        for (auto code : codes) groups[(code >> i) & 1].push_back(code);
        return branch(i, prefix(groups[0],i+1), prefix(groups[1],i+1));
    }
};

// Read predecessor bits from left to right. At bit i the last two bits and
// this input determine output bit i-1. At the right edge either exterior
// bit is allowed. The second diagram supplies today's trap and observation.
struct Preimage {
    const Diagram& next;
    const Diagram& guard;
    Diagram current;
    std::vector<std::unordered_map<std::uint64_t,Id>> memo;
    bool drive;
    Preimage(const Diagram& n, const Diagram& g, bool d)
        : next(n), guard(g), current(n.width), memo((n.width+1)*4), drive(d) {}
    Id walk(int i, unsigned pair, Id q, Id p) {
        if (!q || !p) return 0;
        if (p == 1 && q == 1) return 1;
        if (i == next.width) {
            if (p != 1) throw std::logic_error("unread guard bit");
            auto zero = (pair >> 1) ^ (pair & 1);
            auto one = (pair >> 1) ^ 1u;
            return next.take(q,i-1,zero) | next.take(q,i-1,one);
        }
        auto later = std::min(guard.nodes[p].bit, next.nodes[q].bit - 1);
        if (later > i) return walk(later, 0, q, p);
        auto& bucket = memo[4*i+pair];
        auto key = (std::uint64_t(q) << 32) | p;
        if (auto it=bucket.find(key); it!=bucket.end()) return it->second;
        Id child[2];
        for (unsigned b=0; b<2; ++b) {
            auto out = (pair >> 1) ^ ((pair & 1) | b);
            Id target = i ? next.take(q,i-1,out) : q;
            unsigned carry = i ? (pair & 1) : unsigned(drive);
            child[b] = walk(i+1, 2*carry+b, target, guard.take(p,i,b));
        }
        auto id = current.branch(i,child[0],child[1]);
        bucket.emplace(key,id);
        return id;
    }
};

int main(int argc,char** argv) {
    if (argc != 4) return 2;
    int w=std::stoi(argv[1]), delay=std::stoi(argv[2]);
    if (w < 1 || delay < 0) return 2;
    std::vector<unsigned> codes;
    for (unsigned n; std::cin>>n;) codes.push_back(n);
    if (codes.size()!=829) throw std::runtime_error("expected 829 trap codes");
    std::vector<int> samples(delay,-1);
    samples.push_back(1);
    for (char c : std::string(argv[3])) {
        if (c<'1' || c>'9') return 2;
        samples.insert(samples.end(),c-'1',0);
        samples.push_back(1);
    }
    Diagram guards(w);
    std::array<Id,3> gate;
    for (int colour=-1;colour<=1;++colour) {
        std::vector<unsigned> selected;
        for (auto code : codes)
            if (colour<0 || int(code&1)==colour) selected.push_back(code);
        gate[colour+1]=guards.prefix(selected,0);
    }
    Diagram rows=guards;
    Id root=gate[samples.back()+1];
    const int ticks=2*int(samples.size()-1);
    std::size_t peak=0;
    for (int t=ticks-1;t>=0;--t) {
        Preimage step(rows,guards,(t&1)!=0);
        Id filter = (t&1) ? 1 : gate[samples[t/2]+1];
        root=step.walk(0,0,root,filter);
        rows=std::move(step.current);
        peak=std::max(peak,rows.nodes.size());
        if (t%10==0 || !root)
            std::cout<<"tick "<<t<<" nodes "<<rows.nodes.size()<<" peak "<<peak<<std::endl;
        if (!root) break;
    }
    std::cout<<(root ? "PATH" : "EMPTY")<<" width "<<w<<" peak "<<peak<<std::endl;
}
