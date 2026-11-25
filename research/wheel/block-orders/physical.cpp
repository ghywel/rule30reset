// Sample complete Rule 30 cones. Count actual factors A=3555, B=355555 and
// retain an initial row at the block seam for each observed order.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using U64=std::uint64_t;
static U64 draw(U64& state) {
    U64 x=(state+=0x9e3779b97f4a7c15ULL);
    x=(x^(x>>30))*0xbf58476d1ce4e5b9ULL;
    x=(x^(x>>27))*0x94d049bb133111ebULL;
    return x^(x>>31);
}
static void tick(std::vector<U64>& row, unsigned cells, unsigned wall) {
    U64 left=wall;
    for (unsigned i=0;i<(cells+63)/64;++i) {
        U64 old=row[i], right=(old>>1)|(row[i+1]<<63);
        row[i]=((old<<1)|left)^(old|right);
        left=old>>63;
    }
}
static std::vector<U64> initial(U64 seed,unsigned samples) {
    std::vector<U64> row((2*samples+63)/64+1);
    for (auto& word:row) word=draw(seed);
    return row;
}
static std::string prefix(U64 seed,unsigned T,unsigned start,unsigned cells) {
    auto row=initial(seed,T);
    for (unsigned i=0;i<2*start;++i) tick(row,2*T-i-1,i%2);
    std::string bits;
    for (unsigned j=0;j<cells;++j) bits+=char('0'+((row[j/64]>>(j%64))&1));
    return bits;
}
int main(int argc,char**argv) {
    if(argc!=7) {std::cerr<<"physical SAMPLES ROWS MAX_BLOCKS LONG_FIVES FIRST_SEED OUTPUT\n";return 2;}
    unsigned T=std::stoul(argv[1]),rows=std::stoul(argv[2]),k=std::stoul(argv[3]),longRun=std::stoul(argv[4]);
    U64 firstSeed=std::stoull(argv[5]);
    if(k<1||k>20||longRun<=3||T<3) return 2;
    std::ofstream out(argv[6]);
    if(!out) return 2;
    std::vector<bool> seen(1u<<(k+1));
    std::vector<unsigned> counts(k+1);
    unsigned record=0;
    for(unsigned s=0;s<rows;++s) {
        U64 seed=firstSeed+s;
        auto x=initial(seed,T);
        int previous=-1, start=-1, fives=0;
        std::vector<unsigned> labels,starts;
        for(unsigned t=0;t<T;++t) {
            if(x[0]&1) {
                int gap=int(t)-previous;
                if(previous>=0 && gap==3) {
                    if(start>=0 && (fives==3 || unsigned(fives)==longRun)) {
                        labels.push_back(unsigned(fives)==longRun); starts.push_back(start);
                        record=std::max(record,unsigned(labels.size()));
                        unsigned code=0;
                        for(unsigned n=1;n<=k && n<=labels.size();++n) {
                            code|=labels[labels.size()-n]<<(n-1);
                            unsigned key=(1u<<n)|code;
                            if(seen[key]) continue;
                            seen[key]=true; ++counts[n];
                            unsigned a=starts[starts.size()-n],length=unsigned(previous)-a;
                            out<<n<<'\t'<<code<<'\t'<<seed<<'\t'<<a<<'\t'<<length<<'\t'
                               <<prefix(seed,T,a,2*length+1)<<'\n';
                        }
                    } else {labels.clear();starts.clear();}
                    start=previous; fives=0;
                } else if(previous>=0 && gap==5 && start>=0) {++fives;}
                else {start=-1; fives=0; labels.clear();starts.clear();}
                previous=t;
            }
            if(t+1<T) {tick(x,2*(T-t)-1,0);tick(x,2*(T-t)-2,1);}
        }
    }
    if(!out) return 1;
    std::cout<<"longest parsed order "<<record<<"\n";
    for(unsigned n=1;n<=k;++n) std::cout<<n<<" "<<counts[n]<<"/"<<(1u<<n)<<"\n";
}
