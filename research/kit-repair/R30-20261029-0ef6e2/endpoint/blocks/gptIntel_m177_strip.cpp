// Fixed-word physical strobe strips. Each entry fixes the western W-4 bits;
// a 16-bit mask records the allowed eastern four cells. The 64 possible
// outputs on the eastern six sites are computed once for every such mask.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

using Row=std::uint64_t;
using Choices=std::uint16_t;
constexpr Row empty=std::numeric_limits<Row>::max();

static Row first(Row x) { return (x<<1)^(x|(x>>1)); }
static Row second(Row x) { return ((x<<1)|1)^(x|(x>>1)); }

static Row scalar(Row x,unsigned width) {
    // Initial x has width+2 physical cells, sufficient for width cells two ticks later.
    for (unsigned tick=0; tick<2; ++tick) {
        Row out=0;
        for (unsigned j=0; j<width+1-tick; ++j) {
            Row a=j ? (x>>(j-1))&1 : tick;
            out |= (a^(((x>>j)|(x>>(j+1)))&1))<<j;
        }
        x=out;
    }
    return x;
}

static std::array<std::array<Row,65536>,16> transfer;
static void make_transfer() {
    for (unsigned low=0; low<16; ++low) {
        std::array<Row,16> single{};
        for (unsigned s=0; s<16; ++s)
            for (unsigned east=0; east<4; ++east) {
                Row x=low+(s<<4)+(east<<8);
                Row out=scalar(x,8);
                if (out!=(second(first(x))&255)) throw std::logic_error("local step");
                unsigned six=(out>>2)&63;
                single[s] |= Row(1)<<(16*(six&3)+(six>>2));
            }
        for (unsigned m=1; m<65536; ++m)
            transfer[low][m]=transfer[low][m&(m-1)] | single[__builtin_ctz(m)];
    }
}

struct Bucket {Row key=empty; Choices allowed=0;};
class Groups {
    std::vector<Bucket> slots;
    static Row hash(Row x) {
        x^=x>>23; x*=0x2127599bf4325c37ULL; return x^(x>>47);
    }
    void grow() {
        Groups larger(slots.size()*2);
        for (auto j:used) larger.add(slots[j].key,slots[j].allowed);
        swap(larger);
    }
public:
    std::vector<std::size_t> used;
    explicit Groups(std::size_t size=256):slots(size){}
    void swap(Groups& other) { slots.swap(other.slots); used.swap(other.used); }
    void add(Row key,Choices bits) {
        if (!bits) return;
        if (used.size()*4>=slots.size()*3) grow();
        std::size_t mask=slots.size()-1, j=hash(key)&mask;
        while (slots[j].key!=empty && slots[j].key!=key) j=(j+1)&mask;
        if (slots[j].key==empty) {slots[j].key=key; used.push_back(j);}
        slots[j].allowed |= bits;
    }
    const Bucket& operator[](std::size_t j) const {return slots[j];}
    void clear() {
        for (auto j:used) slots[j]=Bucket{};
        used.clear();
    }
    Row count() const {
        Row n=0;
        for (auto j:used) n+=__builtin_popcount(slots[j].allowed);
        return n;
    }
};

static void advance(Groups& out,const Groups& cur,unsigned w,unsigned target) {
    unsigned d=w-4;
    Row mask=(Row(1)<<(d-2))-1;
    for (auto j:cur.used) {
        auto [key,m]=cur[j];
        Row low=second(first(key))&mask;
        if ((low&1)!=target) continue;
        Row options=transfer[key>>(d-4)][m];
        for (unsigned k=0; k<4; ++k) {
            out.add(low+(Row(k)<<(d-2)),Choices(options));
            options>>=16;
        }
    }
}

static void widen(Groups& out,const Groups& cur,unsigned w) {
    // The lowest bit of the previous four-cell bucket joins the key and the
    // new largest site is free. Both extensions of every old row survive.
    for (auto j:cur.used) {
        auto [key,m]=cur[j];
        for (unsigned parity=0; parity<2; ++parity) {
            Choices choices=0;
            for (unsigned a=0; a<8; ++a)
                if (m & (1U<<(2*a+parity))) choices|=Choices(257U<<a);
            out.add(key|(Row(parity)<<(w-4)),choices);
        }
    }
}

static std::vector<Row> expand(const Groups& cur,unsigned w) {
    std::vector<Row> values;
    for (auto i:cur.used) {
        auto [key,m]=cur[i];
        for (unsigned s=0;s<16;++s) if ((m>>s)&1) values.push_back(key+(Row(s)<<(w-4)));
    }
    std::sort(values.begin(),values.end());
    return values;
}

static void control() {
    unsigned w=8;
    Groups cur,next;
    std::vector<Row> direct;
    for (Row x=0; x<(Row(1)<<w); ++x) {cur.add(x&15,1U<<(x>>4));direct.push_back(x);}
    unsigned survived=0;
    Row physical=0xa39e6701005bf36bULL;
    for (unsigned t=0; t<22; ++t) {
        physical=second(first(physical));
        unsigned target=physical&1;
        advance(next,cur,w,target);cur.swap(next);next.clear();
        std::vector<Row> following;
        for (Row x:direct) for (Row e=0; e<4; ++e) {
            Row v=scalar(x+(e<<w),w);
            if ((v&1)==target) following.push_back(v);
        }
        std::sort(following.begin(),following.end());
        following.erase(std::unique(following.begin(),following.end()),following.end());
        if (following!=expand(cur,w) || !std::binary_search(following.begin(),following.end(),
                physical&((Row(1)<<w)-1))) throw std::logic_error("scalar row comparison");
        direct.swap(following);
        ++survived;
        if (t==6 || t==13) {
            widen(next,cur,w);cur.swap(next);next.clear();
            auto old=direct;
            for (Row x:old) direct.push_back(x+(Row(1)<<w));
            ++w;
            if (direct!=expand(cur,w)) throw std::logic_error("widening comparison");
        }
    }
    std::cout<<survived<<" exact scalar-state comparisons and 2 width extensions passed\n";
}

int main(int argc,char**argv) {
    if (argc==2 && std::string(argv[1])=="--control") {
        make_transfer();control();return 0;
    }
    if (argc!=4 && argc!=5) return 2;
    unsigned last=std::stoul(argv[2]), dwell=std::stoul(argv[3]);
    if (last<12 || last>61 || !dwell) return 2;
    std::ifstream input(argv[1]);
    std::string word;input>>word;
    if (word.size()<=std::size_t(last-11)*dwell || word.find_first_not_of("01")!=std::string::npos)
        return 2;
    make_transfer();
    Groups cur,next;
    for (Row key=word[0]-'0'; key<256; key+=2) cur.add(key,65535);
    std::size_t t=0;
    std::cout<<"width\treading_index\tstates\tgroups\tstatus\n";
    for (unsigned w=12; w<=last; ++w) {
        for (unsigned each=0; each<dwell; ++each) {
            ++t;
            advance(next,cur,w,word[t]-'0');
            if (next.used.empty()) {
                std::cout<<w<<'\t'<<t-1<<'\t'<<cur.count()<<'\t'<<cur.used.size()<<"\tlast_live\n";
                std::cout<<w<<'\t'<<t<<"\t0\t0\tfirst_impossible\n";
                return 0;
            }
            cur.swap(next);next.clear();
        }
        std::cout<<w<<'\t'<<t<<'\t'<<cur.count()<<'\t'<<cur.used.size()<<"\tlive"<<std::endl;
        if (w!=last) {widen(next,cur,w);cur.swap(next);next.clear();}
    }
    if (argc==5) {
        std::vector<std::pair<Row,Choices>> final;
        for (auto j:cur.used) final.emplace_back(cur[j].key,cur[j].allowed);
        std::sort(final.begin(), final.end());
        std::ofstream f(argv[4],std::ios::binary);
        for (auto [key,bits]:final) {
            for (unsigned i=0;i<8;++i) f.put(char(key>>(8*i)));
            f.put(char(bits)); f.put(char(bits>>8));
        }
        if (!f) return 1;
    }
}
