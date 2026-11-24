// Whole fair-coin cylinders certified by three-valued Rule 30.
// Input is the two literal membership tables written by k83a-basin.py --cover.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>

using Bits = std::uint32_t;
struct Domain { Bits zero,one; };

static Domain advance(Domain x, bool black) {
    const Bits west0=(x.zero<<1) | unsigned(!black), west1=(x.one<<1) | unsigned(black);
    const Bits or0=x.zero & (x.zero>>1), or1=x.one | (x.one>>1);
    return {(west0 & or0) | (west1 & or1), (west0 & or1) | (west1 & or0)};
}

struct Family {
    int width;
    std::vector<unsigned char> members;
    Bits mask;
    explicit Family(int w):width(w),members(1U<<w),mask((1U<<w)-1){}

    bool covers(Domain x) const {
        Bits base=x.one & mask;
        if (!members[base]) return false;
        Bits unknown=mask & ~(x.one | x.zero);
        for (Bits m=unknown; m; m=(m-1) & unknown)
            if (!members[base | m]) return false;
        return true;
    }

    int shortestPrefix() const {
        for (int n=0; n<=width; ++n) {
            Bits below=(Bits(1)<<n)-1;
            for (Bits code=0; code<=below; ++code)
                if (covers({below^code,code})) return n;
        }
        throw std::runtime_error("empty family");
    }
};

// Independently check every initial five-bit word and all eastern assignments which
// can affect its first five bits through tick seven.
static bool control() {
    for (Bits code=0; code<32; ++code) {
        Domain x{31^code,code};
        std::array<Bits,128> physical{};
        for (Bits e=0; e<128; ++e) physical[e]=code | (e<<5);
        for (int t=0; t<7; ++t) {
            x=advance(x,t%2==0);
            for (Bits& y:physical) {
                y=((y<<1) | unsigned(t%2==0)) ^ (y | (y>>1));
                if (((x.zero & y) | (x.one & ~y)) & 31) return false;
            }
        }
    }
    return true;
}

static int destination(Bits value,int width,int samples,const Family& trap,const Family& ether,
                       Bits needed) {
    Domain d{((Bits(1)<<width)-1)^value,value};
    for (int s=0; s<samples; ++s) {
        d=advance(d,true);
        if (((d.zero|d.one) & needed)==0) break;
        if (trap.covers(d)) return 1;
        if (ether.covers(d)) return 2;
        d=advance(d,false);
    }
    return 0;
}

int main(int argc,char**argv) {
    if (argc!=2 || !control()) return 1;
    Family trap(16),ether(19);
    std::ifstream input(argv[1],std::ios::binary);
    for (Family* f : {&trap,&ether})
        input.read(reinterpret_cast<char*>(f->members.data()),f->members.size());
    if (!input || input.peek()!=std::char_traits<char>::eof()) return 1;
    for (Bits code=0; code<(1U<<20); ++code) {
        const Domain out=advance({((1U<<20)-1)^code,code},true);
        const Bits physical=((code<<1)|1) ^ (code|(code>>1));
        for (Family* f : {&trap,&ether})
            if (f->covers(out)!=bool(f->members[physical & f->mask])) return 1;
    }
    int min=std::min(trap.shortestPrefix(),ether.shortestPrefix());
    // No bit at or beyond this bound can become known again under the ternary rule.
    Bits needed=~((Bits(1)<<(min-1))-1);
    std::cout<<"minimum cylinder widths "<<trap.shortestPrefix()<<' '<<ether.shortestPrefix()<<'\n';
    std::cout<<"width samples trap ether unresolved denominator\n";
    for (int width:{16,20,24,25,26,27,28}) {
        const int horizon=128;
        std::uint32_t a=0,b=0;
        #pragma omp parallel for reduction(+:a,b) schedule(static)
        for (int value=0; value<(1<<width); ++value) {
            int which=destination(value,width,horizon,trap,ether,needed);
            a+=which==1;b+=which==2;
        }
        std::cout<<width<<' '<<horizon<<' '<<a<<' '<<b<<' '<<((1U<<width)-a-b)<<' '<<(1U<<width)<<std::endl;
    }
}
