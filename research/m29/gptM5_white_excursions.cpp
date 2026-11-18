// Classify both exits from an all-white column, at a fixed time origin.
// State b encodes the column immediately before white, bit t = value at time t.
// The reachability test for a bad exit runs spatially backward to the black edge.
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <vector>
using U = uint64_t;

U mask(unsigned p) { return p==64 ? ~U(0) : (U(1)<<p)-1; }
U next_time(U b, unsigned p) { return (b>>1) | ((b&1)<<(p-1)); }
unsigned least(U b, unsigned p) {
    while (p>1 && (b & mask(p/2)) == (b>>(p/2))) { p/=2; b &= mask(p); }
    return p;
}
U following(U a, U b, unsigned p) {
    // A black tick of b fixes the bit emitted one tick later.
    unsigned t=__builtin_ctzll(b);
    U out=0;
    unsigned c=0;
    for (unsigned i=0; i<p; ++i) {
        c=((a>>t)&1) ^ (((b>>t)&1)|c);
        t=(t+1)%p;
        out |= U(c)<<t;
    }
    return out;
}
struct Result { char type; unsigned span, period; U out; };
Result exit_from(U b, unsigned p, unsigned s, unsigned cap) {
    unsigned q=__builtin_parityll(b) ? 2*p : p;
    if (q>64) return {'?',0,0,0};
    U x=0;
    unsigned v=s;
    for (unsigned t=0;t<q;++t) { x|=U(v)<<t; v^=(b>>(t%p))&1; }
    if (v!=s) std::abort();
    U a=0, c=x;
    unsigned run=0;
    for (unsigned d=1; d<=cap; ++d) {
        if (c&1) ++run;
        else {
            if (run%3==1) return {'R',d,q,0};
            run=0;
        }
        if (!c) {
            unsigned k=least(a,q);
            return {'W',d,k,a&mask(k)};
        }
        U n=following(a,c,q);
        if ((next_time(n,q) ^ (c|n)) != a) std::abort();
        a=c; c=n;
    }
    return {'?',cap,q,0};
}
int main(int argc,char**argv) {
    unsigned maxp=argc>1 ? std::stoul(argv[1]):16, cap=4096;
    if (maxp>16) return 2;
    for (unsigned p=1;p<=maxp;p*=2) {
        unsigned long long counts[3]={};
        unsigned deepest=0;
        for (U b=1;b<=mask(p);++b) if (least(b,p)==p) {
            for (unsigned s=0; s<2; ++s) {
                auto r=exit_from(b,p,s,cap);
                ++counts[r.type=='R' ? 0 : r.type=='W' ? 1 : 2];
                deepest=std::max(deepest,r.span);
                if (r.type!='R') std::cout<<p<<" "<<b<<" "<<s<<" "<<r.type<<" "<<r.span<<" "<<r.period<<" "<<r.out<<"\n";
            }
        }
        std::cerr<<p<<" "<<counts[0]<<" "<<counts[1]<<" "<<counts[2]<<" "<<deepest<<"\n";
    }
}
