// Finite physical gate forks. Compare true initial rows with a shared
// western prefix and no further boundary choices.
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

using Word = std::uint64_t;
using Row = std::array<Word,4>;

Word draw(Word& state) {
    Word x=(state+=0x9e3779b97f4a7c15ULL);
    x=(x^(x>>30))*0xbf58476d1ce4e5b9ULL;
    x=(x^(x>>27))*0x94d049bb133111ebULL;
    return x^(x>>31);
}

void tick(Row& row, Word wall) {
    for (unsigned i=0; i<row.size(); ++i) {
        Word word=row[i];
        Word east=(word>>1) | (i+1<row.size()?row[i+1]<<63:0);
        row[i]=((word<<1)|wall)^(word|east);
        wall=word>>63;
    }
}

void period(Row& row, const std::string& drive) {
    for (char wall : drive) tick(row,wall-'0');
}

std::vector<Row> tails(unsigned width, unsigned count, Word key) {
    std::vector<Row> rows;
    for (unsigned i=0; i<count; ++i) {
        Row row{};
        if (i<12) {
            unsigned p=width+i;
            row[p/64]=Word(1)<<(p%64);
        } else {
            Word state=key+i;
            for (Word& w : row) w=draw(state);
            row[0]&=~((Word(1)<<width)-1);
        }
        rows.push_back(row);
    }
    return rows;
}

std::uint16_t compare(unsigned x, const std::vector<Row>& east, unsigned horizon,
                      const std::string& drive) {
    Row row{x,0,0,0};
    std::array<unsigned char,86> reference{};
    for (unsigned s=0; s<=horizon; ++s) {
        reference[s]=row[0]&1;
        if (s<horizon) period(row,drive);
    }
    for (unsigned i=0; i<east.size(); ++i) {
        row=east[i];
        row[0]|=x;
        for (unsigned s=1; s<=horizon; ++s) {
            period(row,drive);
            if ((row[0]&1)!=reference[s]) return ((i+1)<<7)|s;
        }
    }
    return 0;
}

int main(int argc,char** argv) {
    if (argc!=8) {
        std::cerr<<"physical-fork DRIVE WIDTH HORIZON TAILS SEED THREADS EVIDENCE\n";
        return 2;
    }
    std::string drive=argv[1];
    unsigned width=std::stoul(argv[2]), horizon=std::stoul(argv[3]), count=std::stoul(argv[4]);
    unsigned threads=std::stoul(argv[6]);
    if (drive.size()!=3 || drive.find_first_not_of("01")!=std::string::npos ||
        width<1 || width>30 || horizon<1 || horizon>85 || count<1 || count>255 || threads<1)
        return 2;
    auto exterior=tails(width,count,std::stoull(argv[5]));
    unsigned size=1u<<width;
    std::vector<std::uint16_t> evidence(size);
    std::atomic<unsigned> start{0};
    std::vector<std::thread> jobs;
    for (unsigned j=0; j<threads; ++j) {
        jobs.emplace_back([&]() {
            while (true) {
                unsigned lo=start.fetch_add(4096,std::memory_order_relaxed);
                if (lo>=size) break;
                for (unsigned x=lo;x<std::min(size,lo+4096);++x)
                    evidence[x]=compare(x,exterior,horizon,drive);
            }
        });
    }
    for (auto& t : jobs) t.join();
    std::ofstream output(argv[7],std::ios::binary);
    unsigned missed=0, latest=0, highest=0;
    for (unsigned x=0; x<size; ++x) {
        auto r=evidence[x];
        char bytes[]={char(r&255),char(r>>8)};
        output.write(bytes,sizeof bytes);
        if (!r) {
            if (missed<32) std::cout<<"missing "<<x<<'\n';
            ++missed;
        }
        if ((r&127)>latest) {
            latest=r&127;
            highest=x;
        }
    }
    std::cout<<"width "<<width<<" witnessed "<<size-missed<<'/'<<size
             <<" latest first witness "<<latest<<" example "<<highest
             <<" encoding "<<evidence[highest]<<'\n';
    return output?0:2;
}
