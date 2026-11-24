// Independent certificate checker. Rebuilds every spatial transition site by site.
// A successful run proves h_top <= log(numerator/denominator) in natural units.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

using U32=std::uint32_t;
using U64=std::uint64_t;
constexpr U32 none=std::numeric_limits<U32>::max();
struct State { unsigned w; U64 weight; std::array<U32,4> edge; std::vector<U64> rows; };

template<class T> static T read(std::istream& in) {
    T x=0;
    for (unsigned i=0; i<sizeof(T); ++i) {
        int byte=in.get();
        if (byte<0) throw std::runtime_error("truncated certificate");
        x |= static_cast<T>(byte) << (8*i);
    }
    return x;
}
static void check(bool test,const char* error) {
    if (!test) throw std::runtime_error(error);
}
static bool contains(const State& state, unsigned row) {
    row &= (1U<<state.w)-1;
    return (state.rows[row/64]>>(row%64))&1;
}

static void verify(const char* path) {
    std::ifstream in(path,std::ios::binary);
    char magic[8];
    in.read(magic,8);
    check(in && std::string(magic,8)=="R30B4V01","header");
    unsigned wmax=read<U32>(in), n=read<U32>(in);
    U64 numerator=read<U64>(in),denominator=read<U64>(in);
    check(wmax>=1 && wmax<=20 && n && numerator && denominator,"invalid dimensions or rate");
    std::vector<State> states(n);
    for (State& s : states) {
        s.w=read<std::uint8_t>(in);
        s.weight=read<U64>(in);
        check(s.w>=1 && s.w<=wmax && s.weight,"invalid state");
        for (auto& j : s.edge) {
            j=read<U32>(in);
            check(j==none || j<n,"invalid destination");
        }
        s.rows.resize(((1U<<s.w)+63)/64);
        for (auto& chunk : s.rows) chunk=read<U64>(in);
    }
    check(in.peek()==std::char_traits<char>::eof(),"extra bytes");
    for (unsigned row=0; row<(1U<<states[0].w); ++row)
        check(contains(states[0],row),"initial state omits a terminal row");

    // Each entry gives the two possible following words for a specified old row.
    // For a growing window the free eastern site lies outside the checked cone.
    using Outcomes=std::array<std::array<unsigned,2>,2>;
    std::vector<std::vector<Outcomes>> following(wmax+1);
    for (unsigned w=1; w<=wmax; ++w) {
        unsigned readWidth=std::min(w+1,wmax);
        following[w].resize(1U<<readWidth);
        for (unsigned x=0; x<(1U<<readWidth); ++x) {
            for (unsigned wall=0; wall<2; ++wall) for (unsigned east=0; east<2; ++east) {
                unsigned y=0;
                for (unsigned pos=0;pos<w;++pos) {
                    const unsigned left=pos ? (x>>(pos-1))&1 : wall;
                    const unsigned middle=(x>>pos)&1;
                    const unsigned right=pos+1<readWidth ? (x>>(pos+1))&1 : east;
                    y |= (left^(middle|right))<<pos;
                }
                following[w][x][wall][east]=y;
            }
        }
    }
    for (const State& s : states) {
        __uint128_t sum=0;
        for (U32 j : s.edge) if (j!=none) {
            check(states[j].w<=s.w+1,"destination reads beyond the tested cone");
            sum+=states[j].weight;
        }
        check(sum<=std::numeric_limits<U64>::max(),"edge sum overflow");
        check(sum*denominator<=__uint128_t(numerator)*s.weight,"weight inequality");
        for (unsigned x=0; x<following[s.w].size(); ++x) for (unsigned wall=0;wall<2;++wall) {
            const auto& possible=following[s.w][x][wall];
            if (contains(s,possible[0]) || contains(s,possible[1])) {
                U32 j=s.edge[2*wall+(x&1)];
                check(j!=none && contains(states[j],x),"missing physical predecessor");
            }
        }
    }
    std::cout<<"VERIFIED "<<n<<" states, width "<<wmax<<", growth <= "
             <<numerator<<"/"<<denominator<<"\n";
}

int main(int argc,char** argv) {
    if (argc!=2) return 2;
    try {
        verify(argv[1]);
        return 0;
    } catch (const std::exception& error) {
        std::cerr<<"REJECTED: "<<error.what()<<"\n";
        return 1;
    }
}
