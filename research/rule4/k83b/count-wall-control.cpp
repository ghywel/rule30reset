// Independent physical check for one prescribed western column: enumerate
// every eastern initial word, evolving 64 different rows in packed bit planes.
// Usage: count-wall-control n western_word [western_word ...]. Bit 0 is time 0.
#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <vector>

int main(int argc, char** argv) {
    if (argc < 3) return 2;
    const unsigned n=std::stoul(argv[1]);
    if (n<6 || n>30) return 2;
    const std::uint32_t total=std::uint32_t(1)<<n;
    for (int a=2; a<argc; ++a) {
        const auto wall=std::stoul(argv[a]);
        std::vector<bool> present(total);
        unsigned different=0;
        for (std::uint32_t base=0; base<total; base+=64) {
            std::array<std::uint64_t,32> row{},samples{};
            for (unsigned j=0; j<6; ++j)
                for (unsigned lane=0; lane<64; ++lane)
                    row[j] |= std::uint64_t((lane>>j)&1)<<lane;
            for (unsigned j=6; j<n; ++j)
                row[j] = -std::uint64_t((base>>j)&1);
            for (unsigned t=0; t<n; ++t) {
                samples[t]=row[0];
                std::uint64_t west=-std::uint64_t((wall>>t)&1);
                for (unsigned j=0; j+1<n-t; ++j) {
                    auto centre=row[j];
                    row[j]=west^(centre|row[j+1]);
                    west=centre;
                }
            }
            for (unsigned lane=0; lane<64; ++lane) {
                std::uint32_t word=0;
                for (unsigned t=0; t<n; ++t) word|=((samples[t]>>lane)&1)<<t;
                if (!present[word]) { present[word]=true; ++different; }
            }
        }
        std::cout<<n<<'\t'<<wall<<'\t'<<different<<'\n';
    }
}
