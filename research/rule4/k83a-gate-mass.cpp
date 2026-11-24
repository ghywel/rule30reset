// Exact fair-right probability law of finite gate words beside an alternating wall.
// Build with g++ -O3 -std=c++17 -fopenmp k83a-gate-mass.cpp -o gate-mass
// Run gate-mass 15 > gate-counts.tsv. Words are in temporal order, earliest bit first.
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

using Bits = std::uint32_t;
using Histogram = std::vector<std::uint64_t>;

static int certainWord(Bits prefix, int width, int horizon, bool blackFirst) {
    Bits ones = prefix, zeros = ((Bits(1) << width) - 1) ^ prefix;
    int word = 0;
    const int lastTick = 2 * (horizon - 1) + int(blackFirst);
    for (int tick = 0; tick <= lastTick; ++tick) {
        bool black = (tick % 2 == 0) == blackFirst;
        if (!black) {
            if (((ones | zeros) & 1) == 0) return -1;
            word = 2 * word + (ones & 1);
        }
        const Bits west0 = (zeros << 1) | unsigned(!black);
        const Bits west1 = (ones << 1) | unsigned(black);
        const Bits or0 = zeros & (zeros >> 1), or1 = ones | (ones >> 1);
        zeros = (west0 & or0) | (west1 & or1);
        ones = (west0 & or1) | (west1 & or0);
    }
    return word;
}

static void visit(Bits prefix, int width, int fullWidth, int horizon,
                  bool blackFirst, Histogram& counts) {
    int word = certainWord(prefix, width, horizon, blackFirst);
    if (word >= 0) {
        counts[word] += Bits(1) << (fullWidth - width);
        return;
    }
    if (width == fullWidth) throw std::logic_error("incomplete physical light cone");
    visit(prefix, width + 1, fullWidth, horizon, blackFirst, counts);
    visit(prefix | (Bits(1) << width), width + 1, fullWidth, horizon, blackFirst, counts);
}

static Histogram distribution(int horizon, bool blackFirst) {
    int fullWidth = 2 * horizon - int(!blackFirst);
    int baseWidth = std::min(fullWidth, 12);
    Histogram counts(1U << horizon);
    #pragma omp parallel
    {
        Histogram local(counts.size());
        #pragma omp for schedule(dynamic, 8)
        for (int prefix = 0; prefix < (1 << baseWidth); ++prefix)
            visit(prefix, baseWidth, fullWidth, horizon, blackFirst, local);
        #pragma omp critical
        for (std::size_t i = 0; i < counts.size(); ++i) counts[i] += local[i];
    }
    return counts;
}

// Independent short-cone control: binary site-by-site truth table, all inputs.
static Histogram physical(int horizon, bool blackFirst) {
    int fullWidth = 2 * horizon - int(!blackFirst);
    Histogram counts(1U << horizon);
    for (Bits p = 0; p < (Bits(1) << fullWidth); ++p) {
        std::vector<int> row(fullWidth);
        for (int j = 0; j < fullWidth; ++j) row[j] = (p >> j) & 1;
        int word = 0;
        for (int t = 0; t < fullWidth; ++t) {
            int wall = (t % 2 == 0) == blackFirst;
            if (!wall) word = 2 * word + row[0];
            int west = wall;
            for (int j = 0; j < fullWidth - t - 1; ++j) {
                int curr = row[j];
                row[j] = west ^ (curr | row[j+1]);
                west = curr;
            }
        }
        ++counts[word];
    }
    return counts;
}

int main(int argc, char** argv) {
    const int maxH = argc == 2 ? std::stoi(argv[1]) : 15;
    if (maxH < 1 || maxH > 15) return 2;
    std::cout << "wall\tH\tword\tcount\tdenominator\n";
    for (bool black : {true, false}) {
        Histogram counts = distribution(maxH, black);
        for (int h = maxH; h > 0; --h) {
            auto den = Bits(1) << (2*h - int(!black));
            if (std::accumulate(counts.begin(), counts.end(), std::uint64_t(0)) != den)
                throw std::logic_error("distribution does not sum to one");
            if (h <= 9 && counts != physical(h, black)) throw std::logic_error("control mismatch");
            for (unsigned word = 0; word < counts.size(); ++word) {
                if (!counts[word]) continue;
                if (word & (word >> 1)) throw std::logic_error("consecutive black gate readings");
                std::string bits;
                for (int i = h-1; i >= 0; --i) bits += char('0' + ((word >> i) & 1));
                std::cout << (black ? "black" : "white") << '\t' << h << '\t' << bits
                          << '\t' << counts[word] << '\t' << den << '\n';
            }
            if (h == 1) continue;
            Histogram shorter(counts.size()/2);
            for (unsigned w = 0; w < shorter.size(); ++w) {
                auto joined = counts[2*w] + counts[2*w+1];
                if (joined % 4) throw std::logic_error("two-bit cylinder subdivision failed");
                shorter[w] = joined / 4;
            }
            counts.swap(shorter);
        }
    }
}
