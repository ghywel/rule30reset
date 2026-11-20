// Enumerate primitive weight-five sources and their complements at fixed dyadic clocks.
// g++ -O3 -std=c++17 gptIntel_five_ticks.cpp -o five && ./five 128
// Wheel j is a 2P-bit temporal column. Bit t is its colour at time t.
#include <algorithm>
#include <array>
#include <bitset>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>

using Gaps = std::array<unsigned, 5>;

template <size_t Q>
std::bitset<Q> rotate(const std::bitset<Q>& word, unsigned k) {
    return (word << k) | (word >> (Q-k));
}

template <size_t Q>
std::bitset<Q> child(std::bitset<Q> a, std::bitset<Q> b) {
    // c = d XOR (e AND rotate(c,1)); square the affine map until e is zero.
    auto d = rotate(a ^ b, 1);
    auto e = rotate(~b, 1);
    for (unsigned k=1; e.any(); k*=2) {
        if (k >= Q) throw std::runtime_error("unforced child");
        d ^= e & rotate(d,k);
        e &= rotate(e,k);
    }
    return d;
}

template <size_t Q>
int latest(std::bitset<Q> b, unsigned cap) {
    std::bitset<Q> a, residue1, residue2, pending;
    pending.set();
    for (unsigned j=1; j<=cap; ++j) {
        if (b.none()) return -static_cast<int>(j);  // still pending before this return
        pending &= ~(residue1 & ~b);
        if (pending.none()) return static_cast<int>(j);
        auto r1 = b & ~(residue1 | residue2);
        residue2 = b & residue1;
        residue1 = r1;
        auto next = j==1 ? std::bitset<Q>().set() : child(a,b);
        a=b;
        b=next;
    }
    return 0;  // horizon, no verdict
}

bool canonical(const Gaps& gs) {
    for (size_t shift=1; shift<gs.size(); ++shift) {
        for (size_t k=0; k<gs.size(); ++k) {
            auto v=gs[(shift+k)%gs.size()];
            if (gs[k] < v) break;
            if (gs[k] > v) return false;
        }
    }
    return true;
}

template <unsigned P>
struct Survey {
    std::uint64_t count=0;
    unsigned cap, least_lo, least_hi;
    std::array<unsigned,2> missed{}, peak{};
    std::array<Gaps,2> witness{};
    std::bitset<2*P> alternating;

    void examine(const Gaps& g) {
        if (!canonical(g)) return;
        std::bitset<2*P> first;
        // Prefix XOR is black at times 1..g0, g0+g1+1..g0+g1+g2, etc.
        unsigned begin=0;
        for (size_t i=0; i<5; ++i) {
            auto end=begin+g[i];
            if (i % 2 == 0)
                for (unsigned t=begin+1; t<=end && t<P; ++t) first.set(t);
            begin=end;
        }
        std::bitset<2*P> low_mask;
        for(unsigned i=0;i<P;++i) low_mask.set(i);
        first |= (first ^ low_mask) << P;
        ++count;
        for(unsigned h=0;h<2;++h) {
            int r=latest(h ? first^alternating : first,cap);
            if(r<=0) {
                if(!missed[h]) {
                    std::cout<<"unresolved P="<<P<<" holes="<<h<<" result="<<r<<" gaps:";
                    for(auto x:g) std::cout<<" "<<x;
                    std::cout<<std::endl;
                }
                ++missed[h];
            } else if(static_cast<unsigned>(r)>peak[h]) {
                peak[h]=static_cast<unsigned>(r);
                witness[h]=g;
            }
        }
    }

    void fill(Gaps& g,unsigned i,unsigned left) {
        if(i==4) {
            if(left>=g[0]) {g[i]=left;examine(g);}
            return;
        }
        unsigned remaining=4-i;
        for(unsigned x=g[0]; x+remaining*g[0]<=left; ++x) {
            g[i]=x;
            fill(g,i+1,left-x);
        }
    }

    void run() {
        for(unsigned t=1;t<2*P;t+=2) alternating.set(t);
        Gaps g{};
        for(g[0]=least_lo;g[0]<=std::min(least_hi,P/5);++g[0])
            fill(g,1,P-g[0]);
        if(least_lo==1 && least_hi>=P/5) {
            std::uint64_t choose=1;
            for(unsigned k=1;k<=5;++k) choose=choose*(P+1-k)/k;
            if(count*P!=choose) throw std::runtime_error("necklace denominator mismatch");
        }
        for(unsigned h=0;h<2;++h) {
            std::cout<<"P="<<P<<" holes="<<h<<" least="<<least_lo<<".."<<least_hi
                     <<" classes="<<count<<" missed="<<missed[h]<<" peak="<<peak[h]<<" witness=";
            for(auto x:witness[h]) std::cout<<" "<<x;
            std::cout<<std::endl;
        }
    }
};

template<unsigned P> void execute(unsigned lo,unsigned hi) {
    Survey<P> s{};
    s.cap=140;s.least_lo=lo;s.least_hi=hi;s.run();
}

int main(int argc,char** argv) {
    if(argc!=2 && argc!=4) return 2;
    unsigned p=std::stoul(argv[1]),lo=argc==4?std::stoul(argv[2]):1,
             hi=argc==4?std::stoul(argv[3]):p/5;
    if(!lo || hi<lo) return 2;
    switch(p) {
        case 8: execute<8>(lo,hi); break;
        case 16: execute<16>(lo,hi); break;
        case 32: execute<32>(lo,hi); break;
        case 64: execute<64>(lo,hi); break;
        case 128: execute<128>(lo,hi); break;
        default: return 2;
    }
}
