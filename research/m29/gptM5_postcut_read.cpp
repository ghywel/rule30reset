// Independent M36/M37 minima. Low bits sit at the deep end of the band.
// Decode eight target bits at a time from each of four deep entrance pairs.
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <vector>
using Word = unsigned __int128;
struct Chunk { unsigned bits, state; };
Chunk table[9][256][4];
Word step(Word v) { return (v >> 2) ^ ((v >> 1) | v); }

int main() {
    for (int n = 1; n <= 8; ++n) for (int b = 0; b < (1<<n); ++b)
        for (unsigned in = 0; in < 4; ++in) {
            unsigned s = in, bits = 0;
            for (int j = 0; j < n; ++j) {
                unsigned next = ((b>>j)&1) ^ (s!=0);
                bits |= next<<j;
                s = ((s&1)<<1) | next;
            }
            table[n][b][in] = {bits,s};
        }
    for (int w = 20; w <= 103; ++w) {
        if (w>80 && w!=81 && w!=85 && w!=86 && w!=90 && w!=91 && w!=102 && w!=103) continue;
        Word top = Word(1)<<(w-1), seed = top;
        for (int t=0; t<2000; ++t) seed=step(seed);
        std::vector<Word> cycle, layer;
        Word u=seed;
        do { cycle.push_back(u); u=step(u); } while (u!=seed);
        layer=cycle;
        for (int depth=0;;++depth) {
            if (depth>12 || layer.empty()) return 2;
            std::vector<Word> parents;
            bool hit=false;
            for (Word target : layer) {
                for (unsigned in=0; in<4; ++in) {
                    Word parent = (in>>1) | ((in&1)<<1);
                    unsigned state=in;
                    for (int pos=0; pos<w; pos+=8) {
                        int n=std::min(8,w-pos);
                        unsigned b=unsigned(target>>pos)&((1u<<n)-1);
                        Chunk out=table[n][b][state];
                        parent |= Word(out.bits)<<(pos+2);
                        state=out.state;
                    }
                    if (state) { hit=true; break; } // black tail possible after this target
                    if (step(parent)!=target || parent<top) return 3;
                    // A deterministic forward map makes different target fibres disjoint.
                    if (depth || std::find(cycle.begin(),cycle.end(),parent)==cycle.end())
                        parents.push_back(parent);
                }
                if (hit) break;
            }
            if (hit) { std::cout << w << " " << depth << "\n"; break; }
            layer.swap(parents);
        }
    }
}
