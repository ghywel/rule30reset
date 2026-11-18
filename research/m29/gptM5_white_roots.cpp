// Read the non-reset returns printed by gptM5_white_excursions. Rotate each
// source to its least integer representative and test its unique spatial past.
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <set>
#include <string>
#include <utility>

using Word = uint64_t;
struct Pair {
    Word a, b;
    bool operator==(const Pair& other) const { return a==other.a && b==other.b; }
};
int main() {
    unsigned p,s,span,q; Word b,c; std::string kind;
    std::set<std::pair<unsigned,Word>> seen;
    while (std::cin>>p>>b>>s>>kind>>span>>q>>c) {
        if (kind!="W" || p>32 || !p) return 2;
        Word mask=(Word(1)<<p)-1;
        auto rot=[p](Word v){return (v>>1)|((v&1)<<(p-1));};
        Word v=b;
        for (unsigned k=0;k<p;++k){v=rot(v); b=std::min(b,v);}
        if (!seen.emplace(p,b).second) continue;
        auto back=[&](Pair z){return Pair{rot(z.b)^(z.a|z.b),z.a};};
        Pair slow{b,0},fast=slow;
        for (unsigned i=0;;++i) {
            if (slow==Pair{mask,mask}) {std::cout<<p<<" "<<b<<" root "<<i+1<<"\n";break;}
            slow=back(slow);fast=back(back(fast));
            if (slow==fast) {
                if (slow==Pair{0,0}) return 3;  // the black edge must have occurred first
                std::cout<<p<<" "<<b<<" other_cycle "<<i+1<<"\n";break;
            }
            if (i>=100000000) {std::cout<<p<<" "<<b<<" cutoff\n";break;}
        }
    }
}
