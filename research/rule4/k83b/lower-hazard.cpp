// Counts of undetected finite changes in Rule 30, grouped by the number of
// differing driven gates. Input rows and wall words are independent fair bits.
// Compile as C++17 and run lower-hazard H MASK. Mask bit 0 is site +1.
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>

using Row = std::uint32_t;
using Count = std::uint64_t;
constexpr unsigned maxTicks = 30;  // 4^T and each conditional count fit in 64 bits
using Counts = std::array<Count, maxTicks + 1>;

static Row drive(Row row, unsigned wall, unsigned width) {
    return (((row << 1) | wall) ^ (row | (row >> 1))) & ((Row(1) << width) - 1);
}

class Counter {
    std::array<std::unordered_map<Count, Counts>, 10> cache;
public:
    Counts run(unsigned n, Row a, Row b) {
        Counts out{};
        if (a == b || n == 0) {
            out[0] = Count(1) << n;
            return out;
        }
        if (a > b) std::swap(a,b);
        const Count key = (Count(a) << n) | b;
        if (n < cache.size()) {
            const auto found = cache[n].find(key);
            if (found != cache[n].end()) return found->second;
        }
        const unsigned differs = (a ^ b) & 1;
        for (unsigned wall = differs; wall <= 1; ++wall) {
            auto child = run(n - 1, drive(a,wall,n-1), drive(b,wall,n-1));
            for (unsigned k = 0; k < n; ++k) out[k+differs] += child[k];
        }
        if (n < cache.size()) cache[n].emplace(key, out);
        return out;
    }
};

// Independent test on ordinary full Rule 30 rows. The westernmost initial
// cell at -T is set to zero: it can first affect site 0 at T and enters that
// value as an XOR, equally in the two rows. All other cone cells are swept.
static Counts fullRows(unsigned T, Row mask) {
    Counts count{};
    const Row centre = Row(1) << (T-1);
    const Row gate = centre << 1;
    for (Row x=0; x < (Row(1) << (2*T)); ++x) {
        Row a=x, b=x ^ (mask << T);
        unsigned misses=0;
        bool survived=true;
        for (unsigned t=0; t<T; ++t) {
            misses += bool((a^b) & gate);
            a = (a << 1) ^ (a | (a >> 1));
            b = (b << 1) ^ (b | (b >> 1));
            if ((a^b) & centre) { survived=false; break; }
        }
        if (survived) ++count[misses];
    }
    return count;
}

int main(int argc,char** argv) {
    if (argc != 3) return 2;
    const unsigned T = std::stoul(argv[1]);
    if (T == 0 || T > maxTicks) return 2;
    const Row limit = Row(1) << T;
    const Row mask = Row(std::stoul(argv[2])) & (limit-1);
    Counter counter;
    Counts totals{};
    for (Row r=0; r<limit; ++r) {
        const auto row = counter.run(T,r,r^mask);
        Count weighted = 0;
        for (unsigned k=0; k<=T; ++k) {
            weighted += row[k] << k;
            totals[k] += row[k];
        }
        if (weighted != limit) throw std::runtime_error("conditional stopped-wall law");
    }
    if (T <= 8 && totals != fullRows(T,mask)) throw std::runtime_error("physical cone");
    Count survived=0;
    for (Count n:totals) survived+=n;
    std::cout<<T<<' '<<mask<<' '<<(Count(1)<<(2*T))<<' '<<survived;
    for (unsigned k=0; k<=T; ++k) std::cout<<' '<<totals[k];
    std::cout<<'\n';
}
