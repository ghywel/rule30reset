// Exhaustive five-mark dyadic census. C++17, build with -O3 -march=native.
// Usage: five_dyadic 256 8   (source period, worker threads).
#include <algorithm>
#include <array>
#include <atomic>
#include <bitset>
#include <cstdint>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

using Gaps = std::array<unsigned,5>;

template<unsigned Shift, size_t N>
std::bitset<N> rotate_column(const std::bitset<N>& b) {
    return (b << Shift) | (b >> (N-Shift));
}

template<unsigned Shift, size_t N>
void compose(std::bitset<N>& d, std::bitset<N> e) {
    // Square the affine time transport. Once the multiplier is zero each
    // tick has a forced value. A nonwhite parent forces all N ticks by N steps.
    if (e.none()) return;
    d ^= e & rotate_column<Shift>(d);
    if constexpr (2*Shift < N) {
        e &= rotate_column<Shift>(e);
        compose<2*Shift>(d, e);
    }
}

template<size_t N>
int catch_wheel(std::bitset<N> current) {
    std::bitset<N> previous, ones, twos, pending;
    pending.set();
    for (int wheel=1; wheel<=139; ++wheel) {
        if (current.none()) return -wheel;  // return precedes a pending closure
        pending &= ~(ones & ~current);
        if (pending.none()) return wheel;
        auto next_ones = current & ~(ones | twos);
        twos = current & ones;
        ones = next_ones;
        auto next = rotate_column<1>(previous ^ current);
        if (wheel==1) next.set();
        else compose<1>(next, rotate_column<1>(~current));
        previous = current;
        current = next;
    }
    return 0;  // width cutoff
}

bool canonical(const Gaps& g) {
    for (unsigned i=1; i<5; ++i) {
        if (g[i]!=g[0]) continue;  // generator chose a least gap first
        for (unsigned j=1; j<5; ++j) {
            auto candidate = g[(i+j)%5];
            if (candidate<g[j]) return false;
            if (candidate>g[j]) break;
        }
    }
    return true;
}

struct Tally {
    uint64_t count=0, misses=0, peak_cases=0;
    std::array<uint64_t,6> certified{};
    int peak=0, first_failure=0;
    Gaps worst{}, failure{};
    void observe(const Gaps& g, int value) {
        ++count;
        if (value<=0) {
            if (!misses) {failure=g; first_failure=value;}
            ++misses;
        } else if (value>peak) {
            peak=value; peak_cases=1; worst=g;
        } else if (value==peak) {
            ++peak_cases;
            worst=std::min(worst,g);
        }
    }
    void add(const Tally& other) {
        count+=other.count;
        for (unsigned i=1;i<=5;++i) certified[i] += other.certified[i];
        if (!misses && other.misses) {failure=other.failure; first_failure=other.first_failure;}
        misses+=other.misses;
        if (other.peak>peak) {peak=other.peak; peak_cases=other.peak_cases; worst=other.worst;}
        else if (other.peak==peak) {peak_cases+=other.peak_cases; worst=std::min(worst,other.worst);}
    }
};

// A cluster between consecutive long gaps has at most m marks precisely
// when every m consecutive gaps contain one long gap. Compute the smallest
// maximum in these cyclic windows. The same five values serve both colours.
std::array<unsigned,5> gap_windows(const Gaps& g) {
    std::array<unsigned,5> result{}, window = g;
    result[0]=g[0];
    for (unsigned k=1;k<5;++k) {
        for (unsigned j=0;j<5;++j) window[j]=std::max(window[j],g[(j+k)%5]);
        result[k]=*std::min_element(window.begin(),window.end());
    }
    return result;
}

constexpr std::array<std::array<unsigned,5>,2> thresholds{{
    {20,120,132,178,217}, {29,75,117,149,191}
}};

uint64_t choose_four(int n) {
    if (n<4) return 0;
    return static_cast<uint64_t>(n)*(n-1)*(n-2)*(n-3)/24;
}

template<unsigned P>
int run(unsigned workers, unsigned start, unsigned end) {
    constexpr unsigned Q = 2*P;
    std::array<std::bitset<Q>,P> mark{};
    std::bitset<Q> alternating;
    for (unsigned i=0;i<P;++i) {
        // The prefix XOR of one mark at i is black at times i+1..i+P.
        for (unsigned t=i+1;t<=i+P;++t) mark[i].set(t);
        alternating.set(2*i+1);
    }
    std::vector<std::array<unsigned,2>> jobs;
    for (unsigned a=start; a<=end && a<=P/5; ++a)
        for (unsigned b=a; a+b+3*a<=P; ++b) jobs.push_back({a,b});
    std::atomic<size_t> cursor{0};
    std::vector<std::array<Tally,2>> parts(workers);
    std::vector<std::thread> threads;
    for (unsigned id=0; id<workers; ++id) {
        threads.emplace_back([&,id] {
            for (;;) {
                size_t index=cursor++;
                if (index>=jobs.size()) break;
                auto [a,b]=jobs[index];
                auto head=mark[0] ^ mark[a] ^ mark[a+b];
                for (unsigned c=a; a+b+c+2*a<=P; ++c) {
                    auto prefix=head ^ mark[a+b+c];
                    for (unsigned d=a; a+b+c+d+a<=P; ++d) {
                        Gaps g{a,b,c,d,P-a-b-c-d};
                        if (!canonical(g)) continue;
                        auto first=prefix ^ mark[a+b+c+d];
                        std::array<unsigned,5> windows{};
                        if constexpr (P==512) windows=gap_windows(g);
                        for (unsigned h=0;h<2;++h) {
                            auto& part=parts[id][h];
                            if constexpr (P==512) {
                                unsigned m=0;
                                while (m<5 && windows[m]<thresholds[h][m]) ++m;
                                if (m<5) {
                                    ++part.count;
                                    ++part.certified[m+1];
                                    continue;
                                }
                            }
                            part.observe(g,catch_wheel(h ? first ^ alternating : first));
                        }
                    }
                }
            }
        });
    }
    for (auto& worker:threads) worker.join();
    // Every admissible five-gap tuple has five distinct rotations at dyadic P.
    uint64_t expected=(choose_four(static_cast<int>(P)-5*static_cast<int>(start)+4)
                      -choose_four(static_cast<int>(P)-5*static_cast<int>(end+1)+4))/5;
    bool passed=true;
    for (unsigned h=0;h<2;++h) {
        Tally t;
        for (const auto& part:parts) t.add(part[h]);
        if (t.count!=expected || t.misses) passed=false;
        uint64_t direct=t.count;
        for (auto n:t.certified) direct-=n;
        std::cout<<"P="<<P<<" holes="<<h<<" least="<<start<<".."<<end<<" classes="<<t.count
                 <<" direct="<<direct<<" covered(m=1..5)=";
        for (unsigned m=1;m<=5;++m) std::cout<<" "<<t.certified[m];
        std::cout<<" misses="<<t.misses<<" direct_peak="<<t.peak
                 <<" peak_cases="<<t.peak_cases<<" first_peak_gaps=";
        for (auto v:t.worst) std::cout<<" "<<v;
        if (t.misses) {
            std::cout<<" first_failure="<<t.first_failure<<" gaps=";
            for (auto v:t.failure) std::cout<<" "<<v;
        }
        std::cout<<std::endl;
    }
    return passed ? 0 : 1;
}

int main(int argc, char** argv) {
    if (argc!=3 && argc!=5) return 2;
    unsigned p=std::stoul(argv[1]), workers=std::stoul(argv[2]);
    unsigned lo=argc==5 ? std::stoul(argv[3]) : 1, hi=argc==5 ? std::stoul(argv[4]) : p/5;
    if (!workers || !lo || hi<lo) return 2;
    switch(p) {
    case 8: return run<8>(workers,lo,hi);
    case 64: return run<64>(workers,lo,hi);
    case 128: return run<128>(workers,lo,hi);
    case 256: return run<256>(workers,lo,hi);
    case 512: return run<512>(workers,lo,hi);
    default: return 2;
    }
}
