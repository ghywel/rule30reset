// Temporal overlap graph of all physical length-(r+1) pair words. The language
// here is built independently of count-pairs.cpp, by direct three-valued cones.
// Usage: count-overlap r iterations [certificate.tsv]
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <unordered_map>
#include <vector>

using W = std::uint32_t;
using Big = std::uint64_t;
using Wide = unsigned __int128;

static int certain(W wall, W input, unsigned width, unsigned n) {
    W ones=input, zeros=((W(1)<<width)-1)^input, word=0;
    for (unsigned t=0; t<n; ++t) {
        if (!((ones|zeros)&1)) return -1;
        word |= (ones&1)<<t;
        W left=(wall>>t)&1;
        W z=(zeros<<1)|(1-left), o=(ones<<1)|left;
        W z_or=zeros&(zeros>>1), o_or=ones|(ones>>1);
        zeros=(z&z_or)|(o&o_or);
        ones=(z&o_or)|(o&z_or);
    }
    return int(word);
}

static void cone(W wall, W input, unsigned width, unsigned n, std::vector<W>& stamp,
                 std::vector<W>& partners) {
    int word=certain(wall,input,width,n);
    if (word>=0) {
        if (stamp[word]!=wall) {
            stamp[word]=wall;
            partners.push_back(W(word));
        }
    } else {
        if (width==n) throw std::logic_error("undecided full cone");
        cone(wall,input,width+1,n,stamp,partners);
        cone(wall,input|(W(1)<<width),width+1,n,stamp,partners);
    }
}

struct Graph {
    std::vector<Big> codes;
    std::vector<std::array<W,4>> to;
    std::vector<unsigned char> degree;
    Big edges=0;
};

static Graph build(unsigned r) {
    W size=W(1)<<r, mask=size-1;
    std::vector<std::vector<W>> words(size);
    #pragma omp parallel
    {
        std::vector<W> stamp(2*size,std::numeric_limits<W>::max());
        #pragma omp for schedule(dynamic,32)
        for (W w=0; w<size; ++w)
            cone(w,0,0,r+1,stamp,words[w]);
    }
    Graph g;
    // Insert all actual prefixes in wall/partner numeric order so the vector
    // order and optional certificate can be reproduced across compiler builds.
    for (W w=0; w<size; ++w) {
        auto& e=words[w];
        std::sort(e.begin(),e.end());
        for (W partner:e) g.codes.push_back((Big(w)<<r)|(partner&mask));
    }
    std::sort(g.codes.begin(),g.codes.end());
    g.codes.erase(std::unique(g.codes.begin(),g.codes.end()),g.codes.end());
    std::unordered_map<Big,W> index;
    for (W i=0; i<g.codes.size(); ++i) index.emplace(g.codes[i],i);
    g.to.resize(g.codes.size());
    g.degree.resize(g.codes.size());
    for (W w=0; w<size; ++w)
        for (W partner:words[w]) {
            W from=index.at((Big(w)<<r)|(partner&mask));
            for (W newest_west:{W(0),size}) {
                Big to=(Big((w|newest_west)>>1)<<r)|(partner>>1);
                W target=index.at(to);
                auto& edges=g.to[from];
                auto& k=g.degree[from];
                if (k==4 || std::find(edges.begin(),edges.begin()+k,target)!=edges.begin()+k)
                    throw std::logic_error("duplicate or excessive outdegree");
                edges[k++]=target;
                ++g.edges;
            }
        }
    return g;
}

static void multiply(const Graph& graph,const std::vector<Big>& v,std::vector<Big>& out) {
    for (W i=0; i<v.size(); ++i) {
        Big sum=0;
        for (unsigned k=0; k<graph.degree[i]; ++k) sum+=v[graph.to[i][k]];
        out[i]=sum;
    }
}

int main(int argc,char**argv) {
    if (argc<3 || argc>4) return 2;
    unsigned r=std::stoul(argv[1]), rounds=std::stoul(argv[2]);
    if (r<1 || r>29 || rounds==0) return 2;
    auto graph=build(r);
    std::vector<Big> v(graph.codes.size(),Big(1)<<42),av(v.size());
    for (unsigned step=0; step<rounds; ++step) {
        multiply(graph,v,av);
        if (*std::max_element(av.begin(),av.end())>(Big(1)<<55))
            for (auto& x:av) x=(x+3)/4;
        v.swap(av);
    }
    multiply(graph,v,av);
    W largest=0,smallest=0;
    for (W i=0; i<v.size(); ++i) {
        if (v[i]==0) throw std::logic_error("zero weight");
        if (Wide(av[i])*v[largest]>Wide(av[largest])*v[i]) largest=i;
        if (Wide(av[i])*v[smallest]<Wide(av[smallest])*v[i]) smallest=i;
    }
    const Big denominator=1000000000000ULL;
    const Big upper=Big((Wide(av[largest])*denominator+v[largest]-1)/v[largest]);
    const Big lower=Big(Wide(av[smallest])*denominator/v[smallest]);
    for (W i=0; i<v.size(); ++i)
        if (Wide(av[i])*denominator>Wide(upper)*v[i] ||
            Wide(av[i])*denominator<Wide(lower)*v[i])
            throw std::logic_error("componentwise certificate failed");
    std::cout<<"r vertices edges rounds lower upper denominator max_av max_v\n"
             <<r<<' '<<v.size()<<' '<<graph.edges<<' '<<rounds<<' '<<lower<<' '
             <<upper<<' '<<denominator<<' '<<av[largest]<<' '<<v[largest]<<'\n';
    if (argc==4) {
        std::ofstream file(argv[3]);
        if (!file) return 1;
        file<<"vertex\tweight\n";
        for (W i=0; i<v.size(); ++i) file<<graph.codes[i]<<'\t'<<v[i]<<'\n';
    }
}
