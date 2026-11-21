// Exact physical kick-gap factor DFA from a sorted binary list of SCC windows.
// All black vertices start and accept. Each letter counts steps to the next black,
// requiring white at every intermediate vertex. Equality of subsets is byte-exact.
// Usage: x_core_dfa WIDTH CODES.bin > transitions.txt
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

using Word = uint64_t;
using Id = uint32_t;
using Set = std::vector<Word>;
constexpr Id missing = UINT32_MAX;

static void require(bool ok, const char* what) {
    if (!ok) throw std::runtime_error(what);
}

static Word next_window(Word x, unsigned w, unsigned pair) {
    const Word mask = (Word(1) << w) - 1;
    auto tick = [&](Word v, Word wall, Word far) {
        return (((v << 1) | wall) ^ (v | (v >> 1) | (far << (w-1)))) & mask;
    };
    Word exterior = pair >> 1;
    Word propagated = (x >> (w-1)) ^ (exterior | (pair & 1));
    return tick(tick(x, 0, exterior), 1, propagated);
}

static Word scalar(Word x, unsigned w, unsigned pair) {
    std::array<unsigned, 65> r{};
    for (unsigned j=1; j<=w; j++) r[j] = (x >> (j-1)) & 1;
    r[w+1] = pair>>1;
    r[w+2] = pair&1;
    for (unsigned t=0; t<2; t++) {
        auto s = r;
        s[0] = 1-t;
        for (unsigned j=1; j<=w+1-t; j++) s[j] = r[j-1] ^ (r[j] | r[j+1]);
        r = s;
    }
    Word y = 0;
    for (unsigned j=1; j<=w; j++) y |= Word(r[j]) << (j-1);
    return y;
}

// Black indices first. Buckets narrow lookup to a small sorted range.
struct Graph {
    Id black;
    std::vector<std::array<Id,3>> edges;
    Graph(unsigned w, const char* path) {
        std::ifstream input(path, std::ios::binary | std::ios::ate);
        auto bytes = input.tellg();
        require(bytes>0 && bytes%8==0 && uint64_t(bytes)/8<missing, "invalid core file");
        std::vector<Word> raw(size_t(bytes)/8);
        input.seekg(0);
        input.read(reinterpret_cast<char*>(raw.data()),bytes);
        require(bool(input) && std::is_sorted(raw.begin(),raw.end()) &&
            std::adjacent_find(raw.begin(),raw.end())==raw.end() &&
            raw.back()<(Word(1)<<w),"invalid core code sequence");
        std::vector<Word> codes;
        codes.reserve(raw.size());
        for (Word x:raw) if (x&1) codes.push_back(x);
        black = static_cast<Id>(codes.size());
        for (Word x:raw) if (!(x&1)) codes.push_back(x);
        std::vector<Word>().swap(raw);
        const unsigned highbits = std::min(20u,w);
        const unsigned shift = w-highbits;
        const Id buckets = 1u<<highbits;
        std::array<std::vector<Id>,2> starts;
        for (unsigned bit=0; bit<2; bit++) {
            auto& a = starts[bit];
            a.resize(buckets+1);
            Id i = bit ? 0 : black, end = bit ? black : Id(codes.size());
            for (Id k=0; k<buckets; k++) {
                a[k] = i;
                while (i<end && (codes[i]>>shift)==k) ++i;
            }
            a[buckets] = end;
        }
        auto locate = [&](Word y) {
            auto& a = starts[y&1];
            Id p = Id(y>>shift), lo=a[p], hi=a[p+1];
            auto it = std::lower_bound(codes.begin()+lo,codes.begin()+hi,y);
            return it!=codes.begin()+hi && *it==y ? Id(it-codes.begin()) : missing;
        };
        edges.resize(codes.size());
        std::vector<uint8_t> pred(codes.size(),0);
        for (Id i=0; i<codes.size(); i++) {
            std::array<Word,4> dest;
            for (unsigned p=0; p<4; p++) {
                dest[p] = next_window(codes[i],w,p);
                if (i%65521==0) require(dest[p]==scalar(codes[i],w,p),"scalar disagreement");
            }
            std::sort(dest.begin(),dest.end());
            auto end = std::unique(dest.begin(),dest.end());
            require(end-dest.begin()<=3,"more than three physical successors");
            edges[i].fill(missing);
            size_t k=0;
            for (auto p=dest.begin(); p!=end; ++p) {
                Id v=locate(*p);
                if (v!=missing) {edges[i][k++]=v; pred[v]=1;}
            }
            require(k>0,"vertex has no internal successor");
        }
        require(std::find(pred.begin(),pred.end(),0)==pred.end(),"vertex has no internal predecessor");
    }
};

// Store canonical bitmaps in a temporary file. The digest is only an index;
// colliding candidates are always loaded and compared, even after expansion.
struct Subsets {
    struct Ref { off_t offset; uint32_t count; };
    std::vector<Ref> refs;
    std::map<Word,std::vector<size_t>> candidates;
    FILE* file;
    size_t words;
    explicit Subsets(size_t n) : file(std::tmpfile()), words((n+63)/64) {
        require(file!=nullptr,"cannot create scratch file");
    }
    ~Subsets() {std::fclose(file);}
    Set get(size_t id) {
        Set bits(words);
        require(fseeko(file,refs.at(id).offset,SEEK_SET)==0 &&
            fread(bits.data(),sizeof(Word),words,file)==words,"read subset");
        return bits;
    }
    size_t add(const Set& s, uint32_t count) {
        Word hash=1469598103934665603ull;
        for (Word x:s) {hash ^= x; hash *= 1099511628211ull;}
        auto& ids=candidates[hash];
        for (auto id:ids) if (refs[id].count==count && get(id)==s) return id;
        require(refs.size()<20000 && (refs.size()+1)*words*sizeof(Word)<6ull*1024*1024*1024,
                "subset or scratch storage limit");
        require(fseeko(file,0,SEEK_END)==0,"seek subset file");
        auto offset=ftello(file);
        require(offset>=0 && fwrite(s.data(),sizeof(Word),words,file)==words,"write subset");
        ids.push_back(refs.size());
        refs.push_back({offset,count});
        return refs.size()-1;
    }
};

static void extract(const Graph& g) {
    Subsets states(g.black);
    Set all((g.black+63)/64,~Word(0));
    require(!all.empty(),"no black gate");
    if (g.black%64) all.back()=(Word(1)<<(g.black%64))-1;
    states.add(all,g.black);
    std::vector<uint8_t> seen(g.edges.size(),0);
    uint8_t generation=0;
    std::cout << "# state black_count next_gap_2 next_gap_3 next_gap_4 next_gap_5\n";
    for (size_t id=0; id<states.refs.size(); id++) {
        Set src=states.get(id);
        std::vector<Id> current, later;
        current.reserve(states.refs[id].count);
        for (size_t i=0; i<src.size(); i++) for (Word x=src[i];x;x &= x-1)
            current.push_back(Id(i*64+__builtin_ctzll(x)));
        std::array<int,6> transitions; transitions.fill(-1);
        for (unsigned gap=1; !current.empty(); gap++) {
            require(gap<=5,"white continuation beyond fifth sample");
            if (++generation==0) {std::fill(seen.begin(),seen.end(),0); generation=1;}
            Set hit(states.words,0);
            uint32_t count=0;
            later.clear();
            for (Id v:current) for (Id t:g.edges[v]) {
                if (t==missing) break;
                if (seen[t]==generation) continue;
                seen[t]=generation;
                if (t<g.black) {hit[t/64] |= Word(1)<<(t%64); ++count;}
                else later.push_back(t);
            }
            if (count) {
                require(gap>=2,"unexpected gap one");
                transitions[gap]=int(states.add(hit,count));
            }
            current.swap(later);
        }
        std::cout << id << ' ' << states.refs[id].count;
        for (size_t k=2;k<=5;k++) std::cout << ' ' << transitions[k];
        std::cout << '\n';
    }
    std::cout << "# complete " << states.refs.size() << " states "
              << states.words*sizeof(Word)*states.refs.size() << " scratch bytes\n";
}

int main(int argc,char** argv) {
    try {
        require(argc==3,"usage: x_core_dfa WIDTH CODES.bin");
        unsigned w=std::stoul(argv[1]);
        require(w>=16 && w<=61,"width outside supported range");
        extract(Graph(w,argv[2]));
    } catch (const std::exception& e) {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
