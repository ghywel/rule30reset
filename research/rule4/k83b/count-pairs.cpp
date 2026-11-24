// Exact temporal pair words of rule 30 by going one column sideways.
// Build with a C++17 compiler. Run count-pairs MAXLEN; bit zero is time zero.
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <vector>

using Word = std::uint32_t;
using Index = std::size_t;

// The last bit of the western trace never affects the eastern trace. For each
// western prefix of n-1 bits, store its distinct eastern n-bit traces in CSR.
struct Pairs {
    unsigned n = 1;
    std::vector<Index> offsets{0, 2};
    std::vector<Word> eastern{0, 1};
    // Optional integer multiplicities, measured in complete 2n-cell initial cones.
    std::vector<Word> multiplicities;
};

template<class Emit> void extensions(const Pairs& old, Emit emit) {
    Word full = Word(1) << old.n;
    Word half = full >> 1;
    std::vector<Word> seen(full, full);
    std::vector<Word> mass(old.multiplicities.empty() ? 0 : full);
    std::vector<Word> touched;
    for (Word right = 0; right < full; ++right) {
        Word prefix = right & (half-1);
        touched.clear();
        for (Index i=old.offsets[prefix]; i<old.offsets[prefix+1]; ++i) {
            Word masked = right | old.eastern[i];
            if (seen[masked]!=right) {
                seen[masked]=right;
                touched.push_back(masked);
                if (!mass.empty()) mass[masked]=0;
            }
            if (!mass.empty()) mass[masked]+=old.multiplicities[i];
        }
        for (Word masked:touched) {
            Word west = (right >> 1) ^ masked;
            Word size=mass.empty() ? 1 : mass[masked];
            emit(west, right, size);
            emit(west ^ half, right | full, size);
        }
    }
}

static Pairs next(const Pairs& old) {
    Pairs result;
    result.n = old.n+1;
    result.offsets.assign((Index(1)<<old.n)+1, 0);
    extensions(old, [&](Word w, Word, Word) { ++result.offsets[w+1]; });
    for (Index i=1; i<result.offsets.size(); ++i)
        result.offsets[i] += result.offsets[i-1];
    result.eastern.resize(result.offsets.back());
    if (!old.multiplicities.empty()) result.multiplicities.resize(result.offsets.back());
    std::vector<Index> write(result.offsets);
    extensions(old, [&](Word w, Word g, Word size) {
        Index slot=write[w]++;
        result.eastern[slot]=g;
        if (!result.multiplicities.empty()) result.multiplicities[slot]=size;
    });
    return result;
}

// Independently generate every physical initial 2n-cell cone. The centre is at
// bit n-1, its eastern neighbour at bit n. Both reconstructed outer edges lie
// outside all observations before tick n. Compare actual sets, not just totals.
static void check_cones(const Pairs& pairs) {
    const unsigned n = pairs.n;
    Word ff = Word(1)<<n;
    std::vector<Word> physical(Index(ff)*ff);
    for (Word seed=0; seed<ff*ff; ++seed) {
        Word row=seed, wall=0, gate=0;
        for (unsigned t=0; t<n; ++t) {
            wall |= ((row>>(n-1))&1) << t;
            gate |= ((row>>n)&1) << t;
            row = (row<<1) ^ (row | (row>>1));
        }
        ++physical[Index(wall)*ff+gate];
    }
    for (Word w=0; w<ff; ++w) {
        Word prefix=w & ((ff>>1)-1);
        for (Index i=pairs.offsets[prefix]; i<pairs.offsets[prefix+1]; ++i) {
            Index at=Index(w)*ff+pairs.eastern[i];
            if (!physical[at]) throw std::logic_error("spurious or duplicated pair");
            if (!pairs.multiplicities.empty() && physical[at]!=pairs.multiplicities[i])
                throw std::logic_error("wrong cylinder mass");
            physical[at]=0;
        }
    }
    if (std::any_of(physical.begin(),physical.end(),[](Word x){return x!=0;}))
        throw std::logic_error("missing physical pair");
}

struct Summary {
    std::vector<Word> degree;
    std::vector<std::vector<std::uint64_t>> suffix;
    std::vector<std::uint64_t> masses;
    unsigned n;

    explicit Summary(unsigned length,bool weighted): degree(Index(1)<<(length-1)), n(length) {
        if (weighted) masses.resize((Index(1)<<length)+1);
        for (unsigned r=1; r<=4 && r<length; ++r)
            suffix.emplace_back(Index(1)<<(2*r-1));
    }
    void add(Word west, Word gate, Word size) {
        ++degree[west];
        if (!masses.empty()) ++masses[size];
        for (unsigned i=0; i<suffix.size(); ++i) {
            unsigned r=i+1, k=n-r;
            ++suffix[i][(Index(west>>k)<<r)+(gate>>k)];
        }
    }
};

static void report(const Summary& summary, std::ostream* hist, std::ostream* massHist) {
    const unsigned n=summary.n;
    const Word half=Word(1)<<(n-1);
    Word alt=0, argmax=0;
    Word peak=0;
    std::uint64_t count=0;
    for (unsigned t=0; t+1<n; ++t) alt |= Word(t%2==0)<<t;
    const auto& degree=summary.degree;
    for (Word w=0; w<half; ++w) {
        count+=degree[w];
        if (degree[w]>peak) { peak=degree[w]; argmax=w; }
    }
    if (hist) {
        std::vector<std::uint64_t> frequencies(peak+1);
        for (Word d:degree) frequencies[d]+=2;
        for (Word d=0; d<=peak; ++d)
            if (frequencies[d]) *hist<<n<<'\t'<<d<<'\t'<<frequencies[d]<<'\n';
    }
    if (massHist) {
        std::uint64_t total=0, support=0;
        for (Index m=1; m<summary.masses.size(); ++m) {
            auto words=2*summary.masses[m];
            if (words) {
                *massHist<<n<<'\t'<<m<<'\t'<<words<<'\n';
                total+=m*words;
                support+=words;
            }
        }
        if (total!=(std::uint64_t(1)<<(2*n)) || support!=2*count)
            throw std::logic_error("weighted census lost mass or support");
    }
    std::cout << n << '\t' << 2*count << '\t' << peak << '\t'
              << argmax << '\t' << degree[alt] << '\t' << degree[(half-1)^alt];
    // Maximum number of past blocks before a fixed r-letter suffix. The last
    // western bit is independent; retaining its value does not double a bin.
    for (unsigned r=1; r<=4; ++r) {
        if (r>=n) { std::cout << "\t-"; continue; }
        const auto& bins=summary.suffix[r-1];
        std::cout << '\t' << *std::max_element(bins.begin(), bins.end());
    }
    std::cout << std::endl;
}

int main(int argc,char** argv) {
    if (argc<2 || argc>4) return 2;
    int maxlen=std::stoi(argv[1]);
    if (maxlen<1 || maxlen>=int(std::numeric_limits<Word>::digits)) return 2;
    std::cout << "n\tpair_words\tmax_partners\tfirst_max_wall_le\tblackfirst_alt"
                 "\twhitefirst_alt\tmax_past_r1\tmax_past_r2\tmax_past_r3\tmax_past_r4\n";
    std::ofstream hist,massHist;
    if (argc>=3) {
        hist.open(argv[2]);
        if (!hist) return 1;
        hist << "n\tpartners\twest_words\n";
    }
    Pairs pairs;
    const bool weighted=argc==4;
    if (weighted) {
        massHist.open(argv[3]);
        if (!massHist) return 1;
        massHist<<"n\trows_per_word\tpair_words\n";
        pairs.multiplicities={1,1};
    }
    auto output=[&](const Summary& table){
        report(table,argc>=3 ? &hist : nullptr,weighted ? &massHist : nullptr);
    };
    for (;;) {
        if (pairs.n<=10) check_cones(pairs);
        Summary current(pairs.n,weighted);
        for (Word w=0; w+1<pairs.offsets.size(); ++w)
            for (Index i=pairs.offsets[w]; i<pairs.offsets[w+1]; ++i)
                current.add(w,pairs.eastern[i],weighted ? pairs.multiplicities[i] : 1);
        output(current);
        if (int(pairs.n)==maxlen) break;
        // The largest requested table need never be materialized.
        if (int(pairs.n)+1==maxlen && maxlen>10) {
            Summary last(pairs.n+1,weighted);
            extensions(pairs,[&](Word w, Word g, Word size){last.add(w,g,size);});
            output(last);
            break;
        }
        pairs=next(pairs);
    }
}
