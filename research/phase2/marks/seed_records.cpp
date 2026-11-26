// Single-seed Rule 30 marks, all-white restart failures, and centre run records.
// g++ -std=c++20 -O3 -march=native seed_records.cpp -o seed_records
// seed_records OUTPUT_DIRECTORY [last_onset=4194304] [lookahead=512]
// Every onset 0..last_onset is classified up to the common lookahead endpoint.
#include <algorithm>
#include <array>
#include <bit>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <stdexcept>
#include <vector>

using U = std::uint64_t;
using Data = std::uint32_t;
namespace fs = std::filesystem;
constexpr int collar = 512;
constexpr std::array<int,4> diagonals{2,7,28,399};
constexpr Data missing = std::numeric_limits<Data>::max();

// D_j(t)=cell(t,-t+j). Its next value reads D_{j-2}, D_{j-1}, D_j,
// so the leftmost 400 bits evolve independently even where the diamond narrows.
void edge_tick(std::array<U,7>& x) {
    for (int i=6;i>=0;--i) {
        U pre = i ? x[i-1] : 0;
        x[i] = ((x[i]<<2) | (pre>>62)) ^ (x[i] | (x[i]<<1) | (pre>>63));
    }
}

// Packed observations: bit 0 = centre; bits 1..10 = west white gap + 1
// (zero means no black predecessor); bits 11..14 = D2,D7,D28,D399.
std::vector<Data> observe(int T) {
    const int peak=(T+collar+1)/2;
    const int mid=(peak+63)/64+2;
    std::vector<U> x(2*mid+5), y(x.size());
    x[mid]=1;
    std::vector<Data> obs(T+1);
    std::array<U,7> edge{1};
    for (int t=0;t<=T;++t) {
        int gap=0;
        if (t) {
            while (gap<collar && !x[mid-1-gap/64]) gap+=64;
            if (gap>=collar) throw std::runtime_error("entire west collar white; enlarge and rerun");
            gap+=std::countl_zero(x[mid-1-gap/64]);
            if (gap>=t) throw std::runtime_error("left frontier missing");
        }
        Data o=(x[mid]&1) | ((t ? gap+1 : 0)<<1);
        for (int i=0;i<4;++i) {
            int j=diagonals[i];
            o |= ((edge[j/64]>>(j%64))&1)<<(11+i);
            int pos=j-t;
            int rad=std::min(t,T-t+collar);
            if (-rad<=pos && pos<=rad) {
                int bit=64*mid+pos;
                if (((o>>(11+i))&1)!=((x[bit/64]>>(bit%64))&1))
                    throw std::runtime_error("diagonal and physical cone disagree");
            }
        }
        obs[t]=o;
        if (t==T) break;
        edge_tick(edge);
        int radius=std::min(t+1,T-(t+1)+collar);
        int lo=(64*mid-radius)/64, hi=(64*mid+radius)/64;
        for (int i=lo;i<=hi;++i)
            y[i]=((x[i]<<1)|(x[i-1]>>63)) ^ (x[i] | (x[i]>>1) | (x[i+1]<<63));
        x.swap(y);
    }
    return obs;
}

// All-white driven west, bit 0 = depth 1 (opposite packing to the physical row).
// At a black centre Failed compares its west bit with the complement of the next
// centre. The fast register is exact up to time 64 since the initial west is white.
Data failure(const std::vector<Data>& obs, int s) {
    U west=0;
    int limit=int(obs.size())-1-s;
    for (int t=0;t<std::min(64,limit);++t) {
        U c=obs[s+t]&1;
        if (c && ((west&1)==(obs[s+t+1]&1))) return t;
        west=(west>>1) ^ (west | (west<<1) | c);
    }
    if (limit<=64) return missing;
    std::vector<U> w{west,0}, y(2);
    for (int t=64;t<limit;++t) {
        U c=obs[s+t]&1;
        if (c && ((w[0]&1)==(obs[s+t+1]&1))) return t;
        auto need=std::size_t((t+1)/64+1);
        w.resize(need); y.resize(need);
        for (std::size_t i=0;i<need;++i) {
            U left=(w[i]>>1) | (i+1<need ? w[i+1]<<63 : 0);
            U right=(w[i]<<1) | (i ? w[i-1]>>63 : c);
            y[i]=left ^ (w[i]|right);
        }
        w.swap(y);
    }
    return missing;
}

template<class T> void save(fs::path p,const std::vector<T>& xs) {
    static_assert(std::endian::native==std::endian::little);
    std::ofstream f(p,std::ios::binary);
    f.write(reinterpret_cast<const char*>(xs.data()),xs.size()*sizeof(T));
    f.close(); if (!f) throw std::runtime_error("binary write failed");
}

int main(int argc,char** argv) {
    if (argc<2 || argc>4) return 2;
    fs::path dest(argv[1]);
    int H=argc>2 ? std::stoi(argv[2]) : (1<<22), look=argc>3 ? std::stoi(argv[3]) : 512;
    if (H<1 || look<1 || std::int64_t(H)+look+2*collar+256>std::numeric_limits<int>::max()) return 2;
    int T=H+look;
    auto o=observe(T);
    save(dest/"observations.u32le",o);
    std::ofstream records(dest/"records.tsv"), summary(dest/"counts.tsv"), unresolved(dest/"unresolved.tsv");
    records<<"kind\tonset\tlength_or_delay\tlast_cell_or_failure_tick\n";
    summary<<"kind\tlength_or_delay\tcount\n";
    unresolved<<"kind\tonset\tlast_observed_age\n";
    std::map<std::string,int> maxima;
    std::map<std::pair<std::string,int>,unsigned> counts;
    auto add=[&](const std::string& kind,int s,int v,int end) {
        ++counts[{kind,v}];
        if (!maxima.contains(kind) || v>maxima[kind]) {
            maxima[kind]=v; records<<kind<<'\t'<<s<<'\t'<<v<<'\t'<<end<<'\n';
        }
    };
    std::vector<Data> failed(H+1,missing);
    // The initial seed has an empty west at s=0; it agrees with the driven restart
    // forever, by the local rule, hence has neither a mark nor a finite failure.
    unresolved<<"initial_empty_west_proved_forever\t0\t"<<T<<'\n';
    unsigned censored=0;
    for (int s=1;s<=H;++s) {
        int gap=int((o[s]>>1)&1023)-1;
        if (s+gap>T) throw std::runtime_error("insufficient lookahead for deciding a mark");
        Data d=failure(o,s);
        if (o[s+gap]&1) {
            if (d!=Data(gap)) throw std::runtime_error("first_failure_of_mark mismatch");
            add("mark",s,gap,s+gap);
        }
        if (d==missing) { unresolved<<"failure\t"<<s<<'\t'<<T<<'\n'; ++censored; }
        else add("failure",s,d,s+int(d));
        failed[s]=d;
    }
    save(dest/"failures.u32le",failed);
    for (int s=0;s<=H;) {
        int end=s;
        while (end<T && (o[end+1]&1)==(o[s]&1)) ++end;
        if (end==T) unresolved<<"run\t"<<s<<'\t'<<T<<'\n';
        else add(o[s]&1 ? "black_run" : "white_run",s,end-s+1,end);
        s=end+1;
    }
    for (const auto& [key,number] : counts) summary<<key.first<<'\t'<<key.second<<'\t'<<number<<'\n';
    records.close(); summary.close(); unresolved.close();
    if (!records || !summary || !unresolved) return 1;
    std::cout<<"last onset "<<H<<" last observed "<<T<<" unresolved restarts beyond seed "<<censored<<"\n";
}
