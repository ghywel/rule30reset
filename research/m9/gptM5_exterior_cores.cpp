// Reconstruct the exact cyclic components X and Y of K52 from R65's W24.scc.
// c++ -O3 -std=c++17 gptM5_exterior_cores.cpp -o cores
// cores W24.scc <X|Y> <max-width 24..43> <output-directory> [first-output-width]
//
// A lifted path projects to a path. If both lifted endpoints communicate, their
// parent windows communicate. Consequently the component of a given lifted word
// is computed exactly within the two extensions of its parent component.
// K52's representative names a component; its reported cardinality is a control.
// Outputs are sorted little-endian uint64 window codes, one file per component.
#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

using Code = std::uint64_t;
using Index = std::uint32_t;
using Edges = std::array<Index,4>;
constexpr Index missing = std::numeric_limits<Index>::max();
struct Record { Code least; Index size; };

// K52 two48.txt, largest variable descendant of each W24 ancestor.
constexpr Record xRecords[] = {
  {519,15826}, {2368,23780}, {2368,36729}, {2368,56597}, {5927,86533},
  {5927,126054}, {13876,193420}, {13876,300234}, {20999,466147}, {20999,719016},
  {21576,1111328}, {21576,1705307}, {21576,2375471}, {21576,3680227},
  {21576,5685718}, {21576,8755692}, {21576,13467586}, {21576,20710807},
  {23890,31806428}, {96670,48895838}
};
constexpr Record yRecords[] = {
  {1799,11069}, {1799,15423}, {1799,19175}, {1799,15977}, {1799,19659},
  {6176,23670}, {23634,29220}, {49138,36272}, {49138,46399}, {49138,61019},
  {269593,76496}, {385184,93343}, {385184,110834}, {385184,145002},
  {762804,185923}, {762804,244685}, {762804,303693}, {778777,392355},
  {778777,510780}, {778777,630829}
};

static void check(bool ok, const char* message) {
    if (!ok) throw std::runtime_error(message);
}
static Index read32(std::istream& input) {
    std::array<unsigned char,4> b{};
    input.read(reinterpret_cast<char*>(b.data()), b.size());
    check(bool(input), "short W24 certificate");
    return Index(b[0]) | (Index(b[1])<<8) | (Index(b[2])<<16) | (Index(b[3])<<24);
}
struct Core { unsigned width; std::vector<Code> codes; std::vector<Edges> edges; };
static Index lookup(const std::vector<Code>& words, Code word) {
    auto it = std::lower_bound(words.begin(), words.end(), word);
    return it == words.end() || *it != word ? missing : Index(it-words.begin());
}
// Packed calculation of two physical steps, with the two exterior cells of the
// *initial* window in bits 1 then 0 of input. The center is white then black.
static Code direct(Code word, unsigned input, unsigned width) {
    const Code mask = (Code(1)<<width)-1;
    Code extended = word | (Code(input>>1)<<width) | (Code(input&1)<<(width+1));
    Code middle = (extended<<1) ^ (extended | (extended>>1));
    return (((middle<<1)|1) ^ (middle | (middle>>1))) & mask;
}
static Core readBase(const char* path, Record expected) {
    std::ifstream in(path,std::ios::binary);
    char header[8];
    in.read(header,8);
    check(in && std::string(header,8)=="K50SCC1\n" && read32(in)==24, "bad W24 certificate");
    Core core{24,{},{}};
    while (in.peek()!=std::istream::traits_type::eof()) {
        Index least = read32(in), size = read32(in);
        if (least==expected.least) {
            check(size==expected.size && core.codes.empty(),"wrong or duplicate W24 component");
            for (Index i=0;i<size;++i) core.codes.push_back(read32(in));
        } else in.seekg(std::streamoff(size)*4,std::ios::cur);
        check(bool(in),"invalid W24 certificate");
    }
    std::sort(core.codes.begin(),core.codes.end());
    check(core.codes.size()==expected.size && core.codes.front()==expected.least &&
          std::adjacent_find(core.codes.begin(),core.codes.end())==core.codes.end(),"missing or invalid W24 member");
    core.edges.resize(core.codes.size());
    for (Index i=0;i<core.codes.size();++i)
        for (unsigned input=0;input<4;++input)
            core.edges[i][input] = lookup(core.codes,direct(core.codes[i],input,24));
    return core;
}

static unsigned rule(unsigned l, unsigned m, unsigned r) { return l^(m|r); }
struct Lift {
    const Core& parent;
    Index n;
    std::vector<unsigned char> upperPair;
    std::array<unsigned,32> top{};
    explicit Lift(const Core& core) : parent(core), n(Index(core.codes.size())), upperPair(n) {
        for (Index v=0;v<n;++v) upperPair[v] = core.codes[v]>>(core.width-2);
        for (unsigned i=0;i<32;++i) {
            unsigned a=i&1, b=(i>>1)&1, c=(i>>2)&1, d=(i>>3)&1, e=i>>4;
            top[i] = rule(rule(a,b,c),rule(b,c,d),rule(c,d,e));
        }
    }
    Code code(Index u) const {
        return u<n ? parent.codes[u] : parent.codes[u-n] | (Code(1)<<parent.width);
    }
    Index candidate(Code word) const {
        Index v = lookup(parent.codes,word&((Code(1)<<parent.width)-1));
        return v==missing ? missing : v+Index(word>>parent.width)*n;
    }
    Index edge(Index u, unsigned input) const {
        unsigned z = u>=n;
        Index v=u-z*n;
        unsigned a=input>>1, b=input&1;
        // Removing the new top cell changes the pair of exterior input bits from (a,b) to (z,a).
        Index target = parent.edges[v][2*z+a];
        if (target==missing) return missing;
        return target + n*top[upperPair[v] | (z<<2) | (a<<3) | (b<<4)];
    }
};

static Core extend(const Core& parent, Record expected, bool needEdges) {
    Lift lift(parent);
    Index count=2*lift.n;
    Index root=lift.candidate(expected.least);
    check(root!=missing,"known component representative fails to project into parent");
    // Every W at most 4,096 regularly spaced windows; compare all four edges with
    // packed two-step evolution and direct ordered lookup of the resulting code.
    for (Index i=0;i<count;i+=std::max(Index(1),count/4096))
        for (unsigned k=0;k<4;++k)
            check(lift.edge(i,k)==lift.candidate(direct(lift.code(i),k,parent.width+1)),
                  "lifted edge differs from direct physical evolution");

    // Tarjan search rooted at the representative. Completed components have index
    // 'missing', unseen vertices 0, active vertices their positive discovery index.
    // When the root's last edge finishes, the remaining stack is exactly its SCC.
    std::vector<Index> index(count);
    {
        struct Frame { Index vertex, next, low; };
        std::vector<Frame> dfs;
        std::vector<Index> stack;
        Index clock=0;
        auto enter = [&](Index vertex) {
            index[vertex]=++clock;
            stack.push_back(vertex);
            dfs.push_back({vertex,0,clock});
        };
        enter(root);
        while (!dfs.empty()) {
            Frame& frame=dfs.back();
            if (frame.next<4) {
                Index t=lift.edge(frame.vertex,frame.next++);
                if (t==missing) continue;
                if (index[t]==0) enter(t);
                else frame.low=std::min(frame.low,index[t]);
                continue;
            }
            const Frame done=frame;
            dfs.pop_back();
            if (done.vertex==root) break;
            if (done.low==index[done.vertex]) {
                Index t;
                do {
                    t=stack.back(); stack.pop_back(); index[t]=missing;
                } while(t!=done.vertex);
            }
            dfs.back().low=std::min(dfs.back().low,done.low);
        }
        check(stack.size()==expected.size,"SCC cardinality differs from K52");
        for (Index v:stack) index[v]=1;
    }
    Core out{parent.width+1,{},{}};
    out.codes.reserve(expected.size);
    for (Index v=0;v<count;++v) {
        if (index[v]==1) {
            index[v]=Index(out.codes.size());
            out.codes.push_back(lift.code(v));
        } else index[v]=missing;
    }
    check(out.codes.size()==expected.size && out.codes.front()==expected.least,"SCC name or size differs");
    if (needEdges) {
        out.edges.resize(expected.size);
        for (Index v=0;v<count;++v) if (index[v]!=missing) {
            Edges& e=out.edges[index[v]];
            for (unsigned k=0;k<4;++k) {
                Index t=lift.edge(v,k);
                e[k]=t==missing ? missing : index[t];
            }
        }
    }
    return out;
}

static void save(const Core& core, const std::filesystem::path& dest) {
    Index one=1;
    check(*reinterpret_cast<const unsigned char*>(&one)==1,"output requires a little-endian host");
    auto temporary=dest.string()+".tmp";
    std::ofstream file(temporary,std::ios::binary);
    file.write(reinterpret_cast<const char*>(core.codes.data()),core.codes.size()*sizeof(Code));
    file.close();
    check(bool(file),"could not finish core file");
    std::filesystem::rename(temporary,dest);
}
int main(int argc,char** argv) {
    try {
        check(argc==5 || argc==6,"usage: cores W24.scc X|Y last-width out-directory [first-output-width]");
        std::string name=argv[2];
        check(name=="X" || name=="Y","component must be X or Y");
        const Record* records=name=="X"?xRecords:yRecords;
        int stop=std::stoi(argv[3]), first=argc==6?std::stoi(argv[5]):40;
        check(stop>=24 && stop<=43 && first>=24 && first<=43,"unsupported width");
        std::filesystem::path dir=argv[4];
        std::filesystem::create_directories(dir);
        Core core=readBase(argv[1],records[0]);
        for (;;) {
            if (int(core.width)>=first) save(core,dir/(name+std::to_string(core.width)+".bin"));
            std::cout << name << " W=" << core.width << " members=" << core.codes.size()
                      << " least=" << core.codes.front() << std::endl;
            if (int(core.width)==stop) break;
            core=extend(core,records[core.width+1-24],int(core.width)+1<stop);
        }
    } catch(const std::exception& e) { std::cerr<<e.what()<<'\n'; return 1; }
}
