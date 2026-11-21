// Determinize the kick-gap language inside one of K52's Y components.
// Input is one sorted raw little-endian uint64 per W-bit member, with column 1 in bit 0.
// All starting kicks are allowed; every nonempty subset accepts. Edges leaving Y are ignored.
// The output stores the complete reachable subset DFA. gptM5_y_returns.py minimizes and reads it.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

using Id = uint32_t;
using Word = uint64_t;
using Set = std::vector<Id>;
constexpr Id missing = std::numeric_limits<Id>::max();
constexpr std::array<unsigned,3> letters = {2,4,5};

static void check(bool ok, const char* why) {
    if (!ok) throw std::runtime_error(why);
}

static Word tick(Word x, unsigned w, unsigned wall, unsigned outside) {
    const Word mask = (Word(1)<<w)-1;
    return (((x<<1) | wall) ^ (x | (x>>1) | (Word(outside)<<(w-1)))) & mask;
}

static Word successor(Word x, unsigned w, unsigned input) {
    const unsigned a = input>>1, b = input&1;
    const unsigned middle_boundary = unsigned(x>>(w-1)) ^ (a|b);
    return tick(tick(x,w,0,a),w,1,middle_boundary);
}

static Word scalar_successor(Word x, unsigned w, unsigned input) {
    std::vector<unsigned> row(w+3), middle(w+2);
    for (unsigned j=1;j<=w;++j) row[j]=(x>>(j-1))&1;
    row[w+1]=input>>1; row[w+2]=input&1;
    middle[0]=1;
    for (unsigned j=1;j<=w+1;++j) middle[j]=row[j-1]^(row[j]|row[j+1]);
    Word result=0;
    for (unsigned j=1;j<=w;++j)
        result |= Word(middle[j-1]^(middle[j]|middle[j+1]))<<(j-1);
    return result;
}

static std::vector<Word> load_words(const char* file, unsigned w) {
    std::ifstream in(file,std::ios::binary|std::ios::ate);
    check(bool(in),"cannot open membership file");
    const auto len = in.tellg();
    check(len>0 && len%8==0 && len/8<missing,"bad membership file length");
    std::vector<Word> words(size_t(len)/8);
    in.seekg(0);
    for (auto& x:words) {
        std::array<unsigned char,8> b;
        in.read(reinterpret_cast<char*>(b.data()),8);
        x=0;
        for (unsigned i=0;i<8;++i) x|=Word(b[i])<<(8*i);
    }
    check(bool(in),"short membership file");
    check(std::is_sorted(words.begin(),words.end()) &&
          std::adjacent_find(words.begin(),words.end())==words.end() &&
          words.back()<(Word(1)<<w),"members not strictly sorted W-bit words");
    return words;
}

struct GapEdges { Set offsets{0}, targets; };
using Graph = std::array<GapEdges,3>;

static Graph gap_graph(const std::vector<Word>& words,unsigned w) {
    const Id n=words.size();
    std::unordered_map<Word,Id> index;
    index.reserve(n);
    Set kicks;
    Set kick_index(n,missing);
    for (Id i=0;i<n;++i) {
        index.emplace(words[i],i);
        if (words[i]&1) { kick_index[i]=kicks.size(); kicks.push_back(i); }
    }
    std::vector<std::array<Id,4>> edges(n);
    Set indeg(n,0);
    for (Id i=0;i<n;++i) {
        bool has_edge=false;
        for (unsigned k=0;k<4;++k) {
            const Word next=successor(words[i],w,k);
            if (i%257==0 || i+1==n) check(next==scalar_successor(words[i],w,k),"scalar double step");
            const auto it=index.find(next);
            auto& e=edges[i][k];
            e=it==index.end()? missing : it->second;
            if (e!=missing) { ++indeg[e]; has_edge=true; }
        }
        check(has_edge,"member without internal successor");
    }

    // Prove the files are single strongly connected components on the reconstructed internal edges.
    Set offsets(n+1,0);
    for (Id i=0;i<n;++i) offsets[i+1]=offsets[i]+indeg[i];
    Set incoming(offsets.back()),fill=offsets;
    for (Id i=0;i<n;++i) for (Id j:edges[i]) if (j!=missing) incoming[fill[j]++]=i;
    for (bool backwards:{false,true}) {
        std::vector<char> seen(n,0);
        Set todo{0}; seen[0]=1;
        auto add=[&](Id x) { if (x!=missing && !seen[x]) { seen[x]=1; todo.push_back(x); } };
        for (size_t h=0;h<todo.size();++h) {
            const auto v=todo[h];
            if (backwards) for (Id i=offsets[v];i<offsets[v+1];++i) add(incoming[i]);
            else for (Id j:edges[v]) add(j);
        }
        check(todo.size()==n,"membership is not strongly connected");
    }

    Graph result;
    Set seen(n,0), frontier, silent;
    Id generation=0;
    for (Id start:kicks) {
        frontier.assign(1,start);
        for (unsigned d=1;d<=5;++d) {
            silent.clear(); ++generation;
            for (Id v:frontier) for (Id j:edges[v]) {
                if (j==missing || seen[j]==generation) continue;
                seen[j]=generation;
                if (kick_index[j]==missing) silent.push_back(j);
                else {
                    auto it=std::find(letters.begin(),letters.end(),d);
                    check(it!=letters.end(),"unexpected kick gap");
                    result[it-letters.begin()].targets.push_back(kick_index[j]);
                }
            }
            frontier.swap(silent);
        }
        check(frontier.empty(),"more than five samples without a kick");
        for (auto& rel:result) {
            check(rel.targets.size()<missing,"gap relation too large");
            rel.offsets.push_back(rel.targets.size());
        }
    }
    std::cerr<<"W"<<w<<" vertices "<<n<<", kicks "<<kicks.size()<<", gap edges";
    for (const auto& rel:result) std::cerr<<" "<<rel.targets.size();
    std::cerr<<"\n";
    return result;
}

static size_t hash_set(const Set& s) {
    Word h=14695981039346656037ull;
    for (Id i:s) { h^=i; h*=1099511628211ull; }
    return size_t(h);
}

static void write_dfa(const Graph& edges,unsigned w,const char* path) {
    const auto n=edges[0].offsets.size()-1;
    Set all(n),seen(n,0);
    for (Id i=0;i<n;++i) all[i]=i;
    std::vector<Set> states;
    std::unordered_map<size_t,Set> buckets;
    std::vector<std::array<Id,3>> trans;
    size_t items=0;
    auto intern=[&](Set s)->Id {
        auto& bucket=buckets[hash_set(s)];
        for (Id q:bucket) if (states[q]==s) return q;
        items+=s.size();
        check(states.size()<150000 && items<=268435456,"resource cap: exact DFA incomplete");
        const Id q=states.size();
        bucket.push_back(q); states.push_back(std::move(s)); return q;
    };
    intern(std::move(all)); intern({});
    Id generation=0;
    for (Id q=0;q<states.size();++q) {
        std::array<Id,3> row;
        for (size_t l=0;l<letters.size();++l) {
            Set dest; ++generation;
            for (Id v:states[q]) {
                const auto& rel=edges[l];
                for (Id i=rel.offsets[v];i<rel.offsets[v+1];++i) {
                    const auto j=rel.targets[i];
                    if (seen[j]!=generation) { seen[j]=generation; dest.push_back(j); }
                }
            }
            std::sort(dest.begin(),dest.end());
            row[l]=intern(std::move(dest));
        }
        trans.push_back(row);
    }
    check(trans.at(1)==std::array<Id,3>{1,1,1},"rejecting sink mismatch");
    std::ofstream out(path);
    check(bool(out),"cannot write DFA");
    out<<"Y1 "<<w<<" "<<states.size()<<" "<<n<<"\n";
    for (auto row:trans) out<<row[0]<<" "<<row[1]<<" "<<row[2]<<"\n";
    out.close(); check(bool(out),"DFA write failed");
    std::cerr<<"W"<<w<<" full subsets "<<states.size()<<", payload IDs "<<items<<"\n";
}

int main(int argc,char** argv) {
    try {
        if (argc!=4) throw std::runtime_error("usage: y_grammar WIDTH sorted-members.bin raw.dfa");
        const unsigned w=std::stoul(argv[1]);
        check(w>=40 && w<=43,"expected W40..W43");
        const auto words=load_words(argv[2],w);
        const std::array<Id,4> expected={303693,392355,510780,630829};
        check(words.size()==expected[w-40],"core size differs from K52");
        write_dfa(gap_graph(words,w),w,argv[3]);
    } catch (const std::exception& e) {
        std::cerr<<e.what()<<"\n"; return 1;
    }
}
