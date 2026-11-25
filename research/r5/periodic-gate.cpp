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

int main(int argc, char** argv) {
    if (argc!=5) {
        std::cerr << "periodic-gate DRIVE INITIAL_CODES MAX_WIDTH FORKS_TSV\n";
        return 2;
    }
    std::string drive=argv[1];
    unsigned last=std::stoul(argv[3]);
    if (drive.size()!=3 || drive.find_first_not_of("01")!=std::string::npos || last<14 || last>60)
        return 2;
    std::ifstream input(argv[2]);
    std::ofstream output(argv[4]);
    if (!input || !output) return 2;
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
        std::cout<<" split "<<fork[0].size()<<std::endl;
        if (width==last) break;
        std::size_t n=core.size();
        core.reserve(2*n);
        for (std::size_t i=0; i<n; ++i) core.push_back(core[i]|(Row(1)<<width));
        rows.swap(core);
    }
    return output?0:2;
}
