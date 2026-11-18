// Cyclic reset-free rows with wheel 0 white, wheel 2 black.
// Test if a row itself recurs with the white/black anchor preserved at all times.
#include <algorithm>
#include <cstdint>
#include <iostream>
using U=uint64_t;
struct Audit {
    unsigned n; U mask;
    uint64_t tested=0,unknown=0,found=0;
    explicit Audit(unsigned width):n(width),mask((U(1)<<width)-1){}
    U forward(U v)const {
        U s=((v<<1)|(v>>(n-1)))&mask;
        U ss=((s<<1)|(s>>(n-1)))&mask;
        return ss^(s|v);
    }
    void trace(U v) {
        ++tested; U a=v,tortoise=v; unsigned power=1,length=0;
        for (unsigned t=1;t<=200000;++t) {
            a=forward(a);
            if ((a&5)!=4) return;
            if (a==v) { ++found; if(found<=3)std::cout<<n<<" "<<v<<" "<<t<<"\n"; return; }
            ++length; if(a==tortoise) return;
            if(length==power){tortoise=a;power*=2;length=0;}
        }
        ++unknown;
    }
    void generate(unsigned i,U v,unsigned run) {
        if(i==n){if(run%3!=1)trace(v); return;}
        if(i!=2 && run%3!=1)generate(i+1,v,0);
        generate(i+1,v|(U(1)<<i),run+1);
    }
};
int main(int argc,char**argv){
 unsigned bound=argc>1?std::stoul(argv[1]):30;
 for(unsigned n=3;n<=bound;++n){
     Audit a(n); a.generate(1,0,0);
     std::cerr<<n<<" "<<a.tested<<" "<<a.found<<" "<<a.unknown<<"\n";
 }
}
