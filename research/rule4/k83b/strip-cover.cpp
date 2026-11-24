// Reverse deterministic cover of the temporal two-column language of Rule 30.
// Usage: strip-cover width states_per_width output.bin
// A finite state records a superset of compatible rows on sites 1 through w.
// A capacity restricts the precision of this enclosure, never the length of a trace.
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

using Chunk = std::uint64_t;
using Mask = std::vector<Chunk>;
using Id = std::uint32_t;
constexpr Id absent = std::numeric_limits<Id>::max();
using Edges = std::array<Id,4>;

struct MaskHash {
    std::size_t operator()(const Mask& m) const {
        Chunk h = 0xcbf29ce484222325ULL;
        for (Chunk v : m) { h ^= v; h *= 0x100000001b3ULL; h ^= h >> 29; }
        return h;
    }
};

// Existentially forget the highest site. The flag reports whether anything was lost.
static Mask project(const Mask& m, int w, bool& changed) {
    const unsigned half = 1U << (w-1);
    if (half < 64) {
        const Chunk a = m[0] & ((Chunk(1)<<half)-1), b = m[0] >> half;
        changed = a != b;
        return {a | b};
    }
    const unsigned n = half/64;
    Mask out(n);
    changed = false;
    for (unsigned i=0; i<n; ++i) {
        changed |= m[i]!=m[n+i];
        out[i] = m[i] | m[n+i];
    }
    return out;
}

struct State {
    int width;
    const Mask* mask; // unordered_map nodes retain their addresses across rehashes.
    Edges edges{};
};

struct Parent { unsigned x, label; };

class Cover {
    int width;
    std::size_t capacity;
    std::vector<std::unordered_map<Mask, Id, MaskHash>> byWidth;
    std::vector<std::vector<std::vector<Parent>>> parents;

    Id destination(Mask m, int w) {
        if (std::all_of(m.begin(), m.end(), [](Chunk x){return x==0;})) return absent;
        while (true) {
            Mask smaller;
            bool lossy = false;
            if (w>1) {
                smaller = project(m, w, lossy);
                if (!lossy) { m.swap(smaller); --w; continue; }
            }
            auto& dict = byWidth[w];
            auto it = dict.find(m);
            if (it!=dict.end()) return it->second;
            if (dict.size()<capacity || w==1) {
                Id id = static_cast<Id>(states.size());
                auto inserted = dict.emplace(std::move(m),id);
                states.push_back({w,&inserted.first->first,{}});
                return id;
            }
            ++enlargements;
            m.swap(smaller);
            --w;
        }
    }

public:
    std::vector<State> states;
    std::uint64_t enlargements=0;
    Cover(int w, std::size_t cap): width(w), capacity(cap), byWidth(w+1), parents(w+1) {
        for (int old=1; old<=width; ++old) {
            unsigned n=1U<<old, next=1U<<std::min(old+1,width);
            parents[old].resize(n);
            for (unsigned x=0; x<next; ++x) for (unsigned wall=0; wall<2; ++wall) {
                unsigned y=(((x<<1)|wall) ^ (x|(x>>1))) & (n-1);
                Parent p{x,2*wall+(x&1)};
                parents[old][y].push_back(p);
                if (next==n && !(x&(n/2))) parents[old][y^(n/2)].push_back(p);
            }
        }
        destination({3},1);
        for (std::size_t i=0; i<states.size(); ++i) {
            const int old = states[i].width, next = std::min(old+1,width);
            const Mask& m = *states[i].mask;
            std::array<Mask,4> pre;
            for (auto& a : pre) a.resize(((1U<<next)+63)/64);
            for (unsigned k=0; k<m.size(); ++k) {
                for (Chunk bits=m[k]; bits; bits&=bits-1) {
                    const unsigned y=64*k+__builtin_ctzll(bits);
                    for (Parent p : parents[old][y]) pre[p.label][p.x/64] |= Chunk(1)<<(p.x%64);
                }
            }
            Edges e;
            for (unsigned j=0; j<4; ++j) e[j]=destination(std::move(pre[j]),next);
            states[i].edges=e;
        }
    }
};

// Floating point chooses a candidate vector. The final inequality uses only integers.
static std::vector<Chunk> weights(const std::vector<State>& states) {
    std::vector<double> v(states.size(),1), next(states.size());
    for (int pass=0; pass<100; ++pass) {
        double largest=0;
        for (std::size_t i=0; i<v.size(); ++i) {
            double n=0;
            for (Id j : states[i].edges) if (j!=absent) n+=v[j];
            next[i]=n;
            largest=std::max(largest,n);
        }
        for (double& x : next) x/=largest;
        next.swap(v);
    }
    std::vector<Chunk> out;
    for (double x : v) out.push_back(std::max<Chunk>(1,std::llround(x*1e12)));
    return out;
}

template<class T> static void emit(std::ofstream& f, T x) {
    for (unsigned b=0; b<sizeof(T); ++b) { f.put(static_cast<char>(x & 255)); x>>=8; }
}

int main(int argc,char** argv) {
    if (argc!=4) {std::cerr<<"usage: strip-cover WIDTH STATES_PER_WIDTH OUTPUT\n"; return 2;}
    const int width=std::stoi(argv[1]);
    const unsigned capacity=std::stoul(argv[2]);
    if (width<1 || width>20 || !capacity) return 2;
    Cover graph(width,capacity);
    auto v=weights(graph.states);
    const Chunk denominator=100000000;
    Chunk numerator=0;
    std::ofstream file(argv[3],std::ios::binary);
    if (!file) return 1;
    for (std::size_t i=0; i<v.size(); ++i) {
        Chunk sum=0;
        for (Id j : graph.states[i].edges) if (j!=absent) sum+=v[j];
        __uint128_t rounded=(__uint128_t(sum)*denominator+v[i]-1)/v[i];
        numerator=std::max(numerator,static_cast<Chunk>(rounded));
    }
    file.write("R30B4V01",8);
    emit(file,static_cast<Id>(width)); emit(file,static_cast<Id>(v.size()));
    emit(file,numerator); emit(file,denominator);
    for (std::size_t i=0; i<v.size(); ++i) {
        const State& s=graph.states[i];
        emit(file,static_cast<std::uint8_t>(s.width)); emit(file,v[i]);
        for (Id j : s.edges) emit(file,j);
        for (Chunk x : *s.mask) emit(file,x);
    }
    file.close();
    if (!file) return 1;
    std::cout<<width<<" "<<capacity<<" "<<v.size()<<" "<<graph.enlargements<<" "
             <<numerator<<"/"<<denominator<<" "<<std::log2(double(numerator)/denominator)<<"\n";
}
