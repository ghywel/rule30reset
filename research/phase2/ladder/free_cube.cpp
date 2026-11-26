// Exact post-support checks in the zero-wall model. Bit 0 of a packed row is depth 1.
// Build: g++ -std=c++20 -O3 -march=native free_cube.cpp -o free_cube
// Run: free_cube SUMMARY.tsv HISTOGRAM.tsv [max_n=24]. Sparse joint histogram, low bit first.
#include <algorithm>
#include <array>
#include <bit>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>

using U = std::uint64_t;
using Word = std::uint16_t;
constexpr int checks = 12, words = 1 << checks;
constexpr U odd_depth = 0x5555555555555555ULL;
enum class Rule { r30, r90, r150, hybrid };
using Histogram = std::array<unsigned, words>;
using Degrees = std::array<int, checks>;

U step(U x, Rule rule) {
    if (rule == Rule::r30) return (x >> 1) ^ (x | (x << 1));
    U used = rule == Rule::r150 ? x : (rule == Rule::hybrid ? x & odd_depth : 0);
    return (x >> 1) ^ (x << 1) ^ used;
}

// Centre wall is white. From the free wall bits and pin phase, reconstruct only the W
// initial bits; all greater depths are white. Each step exchanges space for one tick.
template<Rule rule>
U inverse(unsigned free_bits, int width, int pin) {
    U even = free_bits;
    even = (even | (even << 16)) & 0x0000ffff0000ffffULL;
    even = (even | (even << 8)) & 0x00ff00ff00ff00ffULL;
    even = (even | (even << 4)) & 0x0f0f0f0f0f0f0f0fULL;
    even = (even | (even << 2)) & 0x3333333333333333ULL;
    even = (even | (even << 1)) & odd_depth;
    U a = (even << (1-pin)) | (odd_depth << pin), b = 0, row = 0;
    for (int d = 1; d <= width; ++d) {
        row |= (a & 1) << (d-1);
        U side;
        if constexpr (rule == Rule::r30) side = b | a;
        else side = b ^ ((rule == Rule::r150 || (rule == Rule::hybrid && (d & 1))) ? a : 0);
        U c = (a >> 1) ^ side;
        b = a;
        a = c;
    }
    return row;
}

template<Rule rule>
Word outcomes(U row, int width, int pin) {
    // Earliest missing high bit at depth 65 starts at t >= 65-W; arrival at
    // depth 1 requires another 64 ticks. W<=48 and all reads are at t<=71.
    const int first = width + ((width & 1) != pin);
    for (int t = 0; t < first; ++t) row = step(row, rule);
    Word word = 0;
    for (int j = 0; j < checks; ++j) {
        word |= (row & 1) << j;
        row = step(step(row, rule), rule);
    }
    return word;
}

Word prefix_products(Word w) { return w & ~(w + 1); }

template<class T>
void print_list(std::ostream& os, const T& xs) {
    bool first = true;
    for (auto x : xs) { if (!first) os << ','; os << x; first = false; }
}

void write(std::ostream& summary, std::ostream& histogram, const char* name, int n,
           int width, int pin, const Histogram& hist, const Degrees* degrees = nullptr) {
    std::array<unsigned, checks> survivors{};
    unsigned total = 0;
    for (int w = 0; w < words; ++w) if (hist[w]) {
        histogram << name << '\t' << n << '\t' << width << '\t' << pin << '\t' << w << '\t' << hist[w] << '\n';
        for (int j = 0; j < checks && (w >> j & 1); ++j) survivors[j] += hist[w];
        total += hist[w];
    }
    if (total != (1u << n)) throw std::runtime_error("free cube size");
    Degrees linear{};
    if (!degrees) {
        for (int j = 0; j < checks; ++j) {
            unsigned s = survivors[j];
            if (s && !std::has_single_bit(s)) throw std::runtime_error("affine system size");
            linear[j] = s ? n - std::countr_zero(s) : -1; // Indicator of a codimension-r affine flat has degree r.
        }
        degrees = &linear;
    }
    summary << name << '\t' << n << '\t' << width << '\t' << pin << '\t' << total << '\t';
    print_list(summary,survivors); summary << '\t'; print_list(summary,*degrees); summary << '\n';
}

template<Rule rule>
Histogram affine(int n, int width, int pin) {
    auto read = [&](unsigned f) { return outcomes<rule>(inverse<rule>(f,width,pin),width,pin); };
    int origin = read(0);
    Histogram h{};
    h[origin] = 1;
    for (int b = 0; b < n; ++b) {
        int delta = origin ^ read(1u << b);
        auto previous = h;
        for (int w = 0; w < words; ++w) h[w] += previous[w ^ delta];
    }
    return h;
}

Histogram brute(Rule rule, int width, int pin) {
    Histogram hist{};
    for (U x = 0; x < (1ULL << width); ++x) {
        U r = x;
        bool inside = true;
        Word w = 0;
        int j = 0;
        for (int t = 0; j < checks; ++t) {
            if ((t & 1) == pin) {
                if (t < width) inside &= bool(r & 1);
                else w |= (r & 1) << j++;
            }
            r = step(r,rule);
        }
        if (inside) ++hist[w];
    }
    return hist;
}

void census(std::ostream& summary, std::ostream& histogram, int n, int width, int pin) {
    const unsigned size = 1u << n;
    std::vector<Word> poly(size);
    Histogram h{};
    Word stripe_word = 0;
    for (unsigned f = 0; f < size; ++f) {
        U row = inverse<Rule::r30>(f,width,pin);
        Word w = outcomes<Rule::r30>(row,width,pin);
        if (f == size-1) {
            if (row != (odd_depth & ((1ULL << width)-1))) throw std::runtime_error("stripe inverse");
            stripe_word = w;
        }
        poly[f] = prefix_products(w);
        ++h[w];
    }
    if (n <= 5 && h != brute(Rule::r30,width,pin)) throw std::runtime_error("physical rule30 histogram");
    for (unsigned stride=1; stride < size; stride *= 2)
        for (unsigned start=0; start <size; start += 2*stride)
            for (unsigned j=0;j<stride;++j) poly[start+stride+j] ^= poly[start+j];
    Degrees degree{}, planted{};
    degree.fill(-1);
    std::array<Word,25> by_order{};
    for (unsigned m=0; m<size-1; ++m) by_order[std::popcount(m)] |= poly[m];
    for (int j=0; j<checks; ++j) {
        for (int d=0; d<n; ++d) if (by_order[d] >> j & 1) degree[j]=d;
        planted[j]=degree[j];
        if (poly.back() >> j & 1) degree[j]=n;
        // L=1 planting replaces the one finite truncated stripe by the immortal
        // stripe. Its free word is all ones; its delta contributes only the full ANF monomial.
        Word corrected = poly.back() ^ (prefix_products(stripe_word) ^ (words-1));
        if (corrected >> j & 1) planted[j]=n;
    }
    if (!pin && degree[0] != (n%2 ? n : n-1)) throw std::runtime_error("main check_degree");
    if (pin && width == 2*n-1 && degree[0] != n) throw std::runtime_error("opposite check_degree");
    write(summary,histogram,"r30",n,width,pin,h,&degree);
    --h[stripe_word]; ++h[words-1];
    write(summary,histogram,"plant1",n,width,pin,h,&planted);
    auto linear = [&](const char* name, Rule rule, const Histogram& hx) {
        if (n <= 5 && hx != brute(rule,width,pin)) throw std::runtime_error("physical affine histogram");
        write(summary,histogram,name,n,width,pin,hx);
    };
    linear("r90",Rule::r90,affine<Rule::r90>(n,width,pin));
    linear("r150",Rule::r150,affine<Rule::r150>(n,width,pin));
    linear("hybrid",Rule::hybrid,affine<Rule::hybrid>(n,width,pin));
}

int main(int argc,char** argv) {
    if (argc < 3 || argc>4) return 2;
    int limit = argc == 4 ? std::stoi(argv[3]) : 24;
    if (limit < 1 || limit > 24) return 2;
    std::ofstream out(argv[1]), hist(argv[2]);
    out << "rule\tn\twidth\tpin_parity\tbase\tsurvivors_1_to_12\tANF_degree_1_to_12\n";
    hist << "rule\tn\twidth\tpin_parity\tword_low_bit_first\tcount\n";
    for (int n=1; n<=limit; ++n) {
        census(out,hist,n,2*n,0);
        census(out,hist,n,2*n,1);
        census(out,hist,n,2*n-1,1);
    }
    out.close(); hist.close();
    return !(out && hist);
}
