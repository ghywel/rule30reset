// Complete spatial-lift test for periodic gate traps. One edge uses one
// starting row of W+3 cells throughout a three-tick cone.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

using Row = std::uint64_t;
using Index = std::uint32_t;
constexpr Index absent = std::numeric_limits<Index>::max();

Row transition(Row row, unsigned width, unsigned exterior, const std::string& drive) {
    row |= Row(exterior) << width;
    for (char wall : drive)
        row = ((row << 1) | Row(wall-'0')) ^ (row | (row >> 1));
    return row & ((Row(1) << width)-1);
}

Row literal(Row row, unsigned width, unsigned exterior, const std::string& drive) {
    row |= Row(exterior) << width;
    for (unsigned t=0; t<3; ++t) {
        Row next=0;
        for (unsigned p=0; p<width+2-t; ++p) {
            Row left = p ? ((row>>(p-1))&1) : Row(drive[t]-'0');
            next |= (left ^ (((row>>p)|(row>>(p+1)))&1)) << p;
        }
        row=next;
    }
    return row;
}

class Lookup {
    const std::vector<Row>& rows;
    std::vector<Index> table;
    static Row hash(Row x) {
        x ^= x>>30;
        x *= 0xbf58476d1ce4e5b9ULL;
        x ^= x>>27;
        x *= 0x94d049bb133111ebULL;
        return x^(x>>31);
    }
    std::size_t next(std::size_t i) const { return (i+1)&(table.size()-1); }
public:
    explicit Lookup(const std::vector<Row>& r) : rows(r) {
        std::size_t capacity=1;
        while (capacity < rows.size()+rows.size()/2+1) capacity*=2;
        table.assign(capacity,absent);
        for (Index i=0; i<rows.size(); ++i) {
            std::size_t k=hash(rows[i])&(table.size()-1);
            while (table[k]!=absent) k=next(k);
            table[k]=i;
        }
    }
    Index operator()(Row row) const {
        std::size_t k=hash(row)&(table.size()-1);
        while (table[k]!=absent) {
            if (rows[table[k]]==row) return table[k];
            k=next(k);
        }
        return absent;
    }
};

struct Graph {
    std::vector<std::array<Index,8>> edges;
    std::vector<Index> offset, predecessor;
    std::vector<Index> indegree;
    // Parallel exterior choices are counted separately at both ends.
    Graph(const std::vector<Row>& rows, unsigned width, const std::string& drive)
      : edges(rows.size()), offset(rows.size()+1), indegree(rows.size()) {
        if (8*rows.size() >= absent) throw std::range_error("32-bit edge index limit");
        Lookup find(rows);
        for (Index v=0; v<rows.size(); ++v)
            for (unsigned e=0; e<8; ++e) {
                Index dest=find(transition(rows[v],width,e,drive));
                if (dest==absent) throw std::logic_error("previous core is not closed");
                edges[v][e]=dest;
                ++indegree[dest];
            }
        for (Index v=0; v<rows.size(); ++v) offset[v+1]=offset[v]+indegree[v];
        predecessor.resize(offset.back());
        auto cursor=offset;
        for (Index v=0; v<rows.size(); ++v)
            for (Index w : edges[v]) predecessor[cursor[w]++]=v;
    }

    std::vector<Row> remove_no_past(const std::vector<Row>& rows) {
        std::vector<Index> queue;
        for (Index v=0; v<rows.size(); ++v) if (!indegree[v]) queue.push_back(v);
        for (std::size_t i=0; i<queue.size(); ++i)
            for (Index w : edges[queue[i]]) if (!--indegree[w]) queue.push_back(w);
        std::vector<Row> core;
        core.reserve(rows.size()-queue.size());
        for (Index v=0; v<rows.size(); ++v) if (indegree[v]) core.push_back(rows[v]);
        return core;
    }

    void reverse_reach(Index root, std::vector<unsigned char>& seen, std::vector<Index>& queue) const {
        queue.clear();
        queue.push_back(root);
        seen[root]=1;
        for (std::size_t i=0; i<queue.size(); ++i) {
            Index v=queue[i];
            for (Index k=offset[v]; k<offset[v+1]; ++k) {
                Index w=predecessor[k];
                if (indegree[w] && !seen[w]) {
                    seen[w]=1;
                    queue.push_back(w);
                }
            }
        }
    }

    // If one vertex is reachable from every vertex, the last root found
    // in a reverse traversal forest has that property. Verify it.
    Index common_destination(std::size_t live) const {
        Index candidate=absent;
        std::vector<Index> queue;
        std::vector<unsigned char> seen(edges.size());
        for (Index v=0; v<edges.size(); ++v)
            if (indegree[v] && !seen[v]) {
                reverse_reach(v,seen,queue);
                candidate=v;
            }
        std::fill(seen.begin(),seen.end(),0);
        if (candidate!=absent) reverse_reach(candidate,seen,queue);
        return queue.size()==live ? candidate : absent;
    }

    // When every core row can reach root, its forward component is a sink SCC.
    // The period is the gcd of the edge differences of BFS depths.
    Index sink_period(Index root, const std::vector<Row>& rows, std::size_t& size, bool& mixed) const {
        std::vector<Index> depth(edges.size(),absent), queue{root};
        Index period=0;
        depth[root]=0;
        for (std::size_t i=0; i<queue.size(); ++i) {
            Index next=depth[queue[i]]+1;
            for (Index w : edges[queue[i]]) {
                if (depth[w]==absent) {
                    depth[w]=next;
                    queue.push_back(w);
                } else {
                    period=std::gcd(period,next-depth[w]); // BFS cannot skip a level.
                }
            }
        }
        if (!period) throw std::logic_error("finite sink has no cycle");
        std::vector<unsigned> colours(period);
        for (Index w : queue) colours[depth[w]%period] |= 1u<<(rows[w]&1);
        mixed=std::find(colours.begin(),colours.end(),3)!=colours.end();
        size=queue.size();
        return period;
    }
};

struct PathNode {
    Index row;
    std::size_t parent;
    unsigned char input;
};

std::string path(const std::vector<PathNode>& nodes, std::size_t node) {
    std::string out;
    for (; node; node=nodes[node].parent) out.push_back(char('0'+nodes[node].input));
    std::reverse(out.begin(),out.end());
    return out;
}

// A mixed cyclic class guarantees a split. BFS by exact length produces
// the two short paths needed to replay it directly.
std::array<std::string,2> find_split(const Graph& graph, const std::vector<Row>& rows, Index root) {
    std::vector<PathNode> nodes{{root,0,0}};
    std::vector<Index> stamp(rows.size());
    std::size_t begin=0, end=1;
    for (Index step=1; step!=absent; ++step) {
        Index gate=absent;
        for (std::size_t i=begin; i<end; ++i)
            for (unsigned e=0; e<8; ++e) {
                Index w=graph.edges[nodes[i].row][e];
                if (stamp[w]==step) continue;
                stamp[w]=step;
                nodes.push_back({w,i,static_cast<unsigned char>(e)});
                Index bit=rows[w]&1;
                if (gate!=absent && bit!=gate) return {path(nodes,end),path(nodes,nodes.size()-1)};
                gate=bit;
            }
        begin=end;
        end=nodes.size();
    }
    throw std::range_error("split exceeds 32-bit length");
}

// Iterate the image after one prescribed complete word. Each new seam set
// is nested in the old one. A fixed nonempty set has a cycle with this gate.
void test_words(const Graph& graph, const std::vector<Row>& rows, unsigned width,
                std::vector<std::string>& words, std::ostream& output) {
    std::vector<std::uint32_t> seen(rows.size());
    std::uint32_t stamp=0;
    std::vector<Index> core;
    for (Index i=0; i<rows.size(); ++i) if (graph.indegree[i]) core.push_back(i);
    std::vector<std::string> survivors;
    for (const std::string& word : words) {
        auto current=core;
        std::vector<Index> next;
        std::size_t duration=0, before;
        do {
            before=current.size();
            for (char bit : word) {
                ++duration;
                if (++stamp==0) {
                    std::fill(seen.begin(),seen.end(),0);
                    ++stamp;
                }
                next.clear();
                for (Index i : current) if ((rows[i]&1)==Row(bit-'0'))
                    for (Index j : graph.edges[i]) if (seen[j]!=stamp) {
                        seen[j]=stamp;
                        next.push_back(j);
                    }
                next.swap(current);
                if (current.empty()) break;
            }
        } while (!current.empty() && current.size()!=before);
        if (!current.empty()) survivors.push_back(word);
        output<<width<<'\t'<<word<<'\t'<<duration<<'\t'<<current.size()<<'\n';
    }
    output.flush();
    words.swap(survivors);
}

int target(int argc, char** argv) {
    if (argc!=7) {
        std::cerr<<"periodic-gate --target DRIVE INITIAL_CODES GATE_WORD MAX_WIDTH RESULT\n";
        return 2;
    }
    std::string drive=argv[2], word=argv[4];
    unsigned last=std::stoul(argv[5]);
    if (last<14 || last>60 || drive.size()!=3 || drive.find_first_not_of("01")!=std::string::npos ||
        word.empty() || word.find_first_not_of("01")!=std::string::npos) return 2;
    std::ifstream input(argv[3]);
    std::ofstream output(argv[6]);
    if (!input || !output) return 2;
    std::vector<std::vector<Row>> phases(word.size());
    for (Row r; input>>r;) {
        if (r>=1<<14) return 2;
        for (std::size_t b=0; b<word.size(); ++b)
            if ((r&1)==Row(word[b]-'0')) phases[b].push_back(r);
    }
    if (!input.eof()) return 2;
    for (auto& slot : phases) {
        std::sort(slot.begin(),slot.end());
        if (std::adjacent_find(slot.begin(),slot.end())!=slot.end()) return 2;
    }
    for (unsigned width=14; width<=last; ++width) {
        std::vector<std::size_t> offset{0};
        for (const auto& phase : phases) offset.push_back(offset.back()+phase.size());
        std::size_t n=offset.back();
        if (8*n>=absent) throw std::range_error("32-bit edge index limit");
        std::vector<std::array<Index,8>> edges(n);
        std::vector<Index> indegree(n);
        for (std::size_t p=0; p<word.size(); ++p) {
            std::size_t end=(p+1)%word.size();
            Lookup find(phases[end]);
            for (Index i=0; i<phases[p].size(); ++i)
                for (unsigned e=0; e<8; ++e) {
                    Index j=find(transition(phases[p][i],width,e,drive));
                    if (j!=absent) ++indegree[j+=offset[end]];
                    edges[offset[p]+i][e]=j;
                }
        }
        std::vector<Index> incoming(n+1);
        for (Index i=0; i<n; ++i) incoming[i+1]=incoming[i]+indegree[i];
        std::vector<Index> pred(incoming.back());
        {
            auto cursor=incoming;
            for (Index i=0; i<n; ++i)
                for (Index j : edges[i]) if (j!=absent) pred[cursor[j]++]=i;
        }

        // Forward-limit deletion. Any cycle of a labelled trap survives.
        std::vector<Index> queue;
        for (Index i=0; i<n; ++i) if (!indegree[i]) queue.push_back(i);
        for (std::size_t i=0; i<queue.size(); ++i)
            for (Index j : edges[queue[i]]) if (j!=absent && !--indegree[j]) queue.push_back(j);
        std::size_t live=n-queue.size();

        // Remove every row that can leave the surviving labelled set.
        // The complement is the greatest universally closed subset.
        std::vector<unsigned char> unsafe(n);
        for (Index i : queue) unsafe[i]=1;
        for (Index i=0; i<n; ++i) if (!unsafe[i])
            for (Index j : edges[i]) if (j==absent) {
                unsafe[i]=1;
                queue.push_back(i);
                break;
            }
        for (std::size_t i=0; i<queue.size(); ++i)
            for (Index k=incoming[queue[i]]; k<incoming[queue[i]+1]; ++k) {
                Index j=pred[k];
                if (!unsafe[j]) {
                    unsafe[j]=1;
                    queue.push_back(j);
                }
            }
        std::size_t safe=n-queue.size();
        std::cout<<"gate "<<word<<" width "<<width<<" lifted "<<n
                 <<" past "<<live<<" closed "<<safe<<std::endl;
        if (safe) {
            for (std::size_t p=0; p<word.size(); ++p)
                for (Index i=0; i<phases[p].size(); ++i)
                    if (!unsafe[offset[p]+i])
                        output<<width<<'\t'<<p<<'\t'<<phases[p][i]<<'\n';
            return output?0:2;
        }
        if (!live || width==last) break;
        std::vector<std::vector<Row>> lifted(word.size());
        for (std::size_t p=0; p<word.size(); ++p) {
            auto& rows=lifted[p];
            for (Index i=0; i<phases[p].size(); ++i)
                if (indegree[offset[p]+i]) rows.push_back(phases[p][i]);
            std::size_t count=rows.size();
            rows.reserve(2*count);
            for (std::size_t i=0; i<count; ++i) rows.push_back(rows[i]|(Row(1)<<width));
        }
        phases.swap(lifted);
    }
    return output?0:2;
}

int main(int argc, char** argv) {
    if (argc>1 && std::string(argv[1])=="--target") return target(argc,argv);
    if (argc!=5 && argc!=7) {
        std::cerr << "periodic-gate DRIVE INITIAL_CODES MAX_WIDTH FORKS_TSV [WORDS WORDS_TSV]\n";
        return 2;
    }
    std::string drive=argv[1];
    unsigned last=std::stoul(argv[3]);
    if (drive.size()!=3 || drive.find_first_not_of("01")!=std::string::npos || last<14 || last>60)
        return 2;
    std::ifstream input(argv[2]);
    std::ofstream output(argv[4]);
    if (!input || !output) return 2;
    std::vector<std::string> words;
    std::ofstream word_results;
    if (argc==7) {
        std::ifstream words_in(argv[5]);
        word_results.open(argv[6]);
        for (std::string word; words_in>>word;) {
            if (word.find_first_not_of("01")!=std::string::npos) return 2;
            words.push_back(word);
        }
        if (!words_in.eof() || !word_results || words.empty()) return 2;
    }
    std::vector<Row> rows;
    for (Row r; input>>r;) rows.push_back(r);
    if (!input.eof() || rows.empty()) return 2;
    std::sort(rows.begin(),rows.end());
    if (rows.back()>=(1<<14) || std::adjacent_find(rows.begin(),rows.end())!=rows.end()) return 2;
    for (Row r=0; r<(1<<14); ++r)
        for (unsigned e=0; e<8; ++e)
            if (transition(r,14,e,drive)!=literal(r,14,e,drive)) return 3;
    for (unsigned width=14; width<=last; ++width) {
        Graph graph(rows,width,drive);
        auto core=graph.remove_no_past(rows);
        Index root=graph.common_destination(core.size());
        std::cout << "width " << width << " lifted " << rows.size() << " core " << core.size();
        if (root==absent) {
            std::cout << " no common destination; classify all sinks" << std::endl;
            return 4;
        }
        std::size_t sink=0;
        bool mixed=false;
        Index period=graph.sink_period(root,rows,sink,mixed);
        std::cout<<" sink "<<sink<<" period "<<period<<" root "<<rows[root];
        if (!mixed) {
            std::cout << " phase-pure candidate" << std::endl;
            return 5;
        }
        auto fork=find_split(graph,rows,root);
        std::array<Row,2> terminal{rows[root],rows[root]};
        for (unsigned i=0; i<2; ++i)
            for (char e : fork[i]) terminal[i]=literal(terminal[i],width,e-'0',drive);
        if (fork[0].size()!=fork[1].size() || !((terminal[0]^terminal[1])&1)) return 6;
        output<<width<<'\t'<<rows[root]<<'\t'<<fork[0]<<'\t'<<fork[1]<<'\t'
              <<terminal[0]<<'\t'<<terminal[1]<<'\n'<<std::flush;
        std::cout<<" split "<<fork[0].size();
        if (!words.empty()) {
            test_words(graph,rows,width,words,word_results);
            std::cout<<" periodic words left "<<words.size();
        }
        std::cout<<std::endl;
        if (width==last) break;
        std::size_t n=core.size();
        core.reserve(2*n);
        for (std::size_t i=0; i<n; ++i) core.push_back(core[i]|(Row(1)<<width));
        rows.swap(core);
    }
    return output?0:2;
}
