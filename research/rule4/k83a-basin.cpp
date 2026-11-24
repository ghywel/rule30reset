// K83.A: black-first wall, odd ticks only. The Python driver supplies the kit tables.
// Emit signed 32-bit little-endian tuples: first white sample in each of five
// families (or -1), followed by the least period up to 60 of the final 200 samples.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

using U = std::uint64_t;
using Record = std::array<std::int32_t,6>;
constexpr int trap = 0, seven = 1, sevenB = 2, ether = 3, five = 4;

struct Tables {
    std::array<unsigned char,65536> flags{};
    std::array<std::vector<U>,5> codes;
    std::array<std::array<bool,8192>,4> walls{};
    std::array<int,4> first{}, next{};

    explicit Tables(const char* path) {
        std::ifstream input(path);
        for (int family : {trap,seven,sevenB,five}) {
            int size;
            input >> size;
            for (int i=0; i<size; ++i) {
                U code;
                input >> code;
                codes[family].push_back(code);
                flags[code & 65535] |= 1 << family;
            }
            std::sort(codes[family].begin(), codes[family].end());
        }
        for (int phase=0; phase<4; ++phase) {
            int size;
            input >> first[phase] >> next[phase] >> size;
            for (int i=0; i<size; ++i) {
                int wall;
                input >> wall;
                walls[phase].at(wall) = true;
            }
        }
        if (!input) throw std::runtime_error("incomplete kit tables");
    }

    bool inLock(U row, int family, int width) const {
        U code = row & ((U(1) << width)-1);
        return std::binary_search(codes[family].begin(), codes[family].end(), code);
    }

    bool inEther(U row) const {
        // The two compatible ether phases at a white tick. k+13 <= 61.
        for (int phase : {0,2}) {
            if (int(row & 63) != first[phase]) continue;
            U tail = row >> 6;
            for (int k=6; k<=48; k+=7) {
                if (walls[phase][tail & 8191]) return true;
                if (int(tail & 127) != next[phase]) break;
                tail >>= 7;
            }
        }
        return false;
    }
};

static U randomWord(U &state) {
    U v = (state += 0x9E3779B97F4A7C15ULL);
    v = (v ^ (v >> 30)) * 0xBF58476D1CE4E5B9ULL;
    v = (v ^ (v >> 27)) * 0x94D049BB133111EBULL;
    return v ^ (v >> 31);
}

static Record run(const Tables& tables, U seed, int samples) {
    const int ticks = 2*samples-1;
    const int words = (ticks+64+63)/64;
    std::vector<U> row(words+1), image(words+1);
    for (int j=0; j<words; ++j) row[j]=randomWord(seed);
    std::array<bool,200> tail{};
    Record result{-1,-1,-1,-1,-1,0};
    for (int t=0; t<ticks; ++t) {
        // Future observations use only the shrinking causal cone through site 64.
        const int last = (ticks-t-1+64-1)/64;
        U x=row[0];
        image[0]=((x << 1) | (1-(t%2))) ^ (x | (x >> 1) | (row[1] << 63));
        for (int j=1; j<=last; ++j) {
            U y=row[j];
            image[j]=((y << 1) | (row[j-1] >> 63))
                     ^ (y | (y >> 1) | (row[j+1] << 63));
        }
        row.swap(image);
        if (t%2) continue;
        const int s=t/2;
        x=row[0];
        if (s>=samples-200) tail[s-(samples-200)]=(x & 1)!=0;
        const auto flags=tables.flags[x & 65535];
        if (result[trap]<0 && (flags & (1<<trap))) result[trap]=s;
        if (result[seven]<0 && (flags & (1<<seven)) && tables.inLock(x,seven,30)) result[seven]=s;
        if (result[sevenB]<0 && (flags & (1<<sevenB)) && tables.inLock(x,sevenB,45)) result[sevenB]=s;
        if (result[five]<0 && (flags & (1<<five)) && tables.inLock(x,five,34)) result[five]=s;
        if (result[ether]<0 && result[trap]<0 && tables.inEther(x)) result[ether]=s;
    }
    for (int period=1; period<=60; ++period) {
        if (std::equal(tail.begin(),tail.end()-period,tail.begin()+period)) {
            result[5]=period;
            break;
        }
    }
    return result;
}

int main(int argc, char**argv) {
    if (argc!=6) return 1;
    const Tables tables(argv[1]);
    const int samples=std::stoi(argv[2]);
    const U seed=std::stoull(argv[3]);
    // Input row IDs allow later re-use of exactly the same prefixes on a longer cone.
    std::ifstream input(argv[4],std::ios::binary|std::ios::ate);
    auto bytes=input.tellg();
    if (!input || bytes<0 || bytes%4 || samples<200) return 1;
    std::vector<std::uint32_t> ids(static_cast<std::size_t>(bytes)/4);
    input.seekg(0);
    input.read(reinterpret_cast<char*>(ids.data()),bytes);
    std::vector<Record> results(ids.size());
    #pragma omp parallel for schedule(static)
    for (int i=0; i<static_cast<int>(ids.size()); ++i)
        results[i]=run(tables,seed+U(ids[i])*0x2545F4914F6CDD1DULL,samples);
    std::ofstream output(argv[5],std::ios::binary);
    output.write(reinterpret_cast<const char*>(results.data()),results.size()*sizeof(Record));
    return input && output ? 0 : 1;
}
