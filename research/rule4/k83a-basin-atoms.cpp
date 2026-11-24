// Exact lower bounds for the seven infinite gate atoms, by finite physical preimages.
// Input lines on stdin: kit lock width (30 or 45), canonical phase, window code.
#include <array>
#include <cstdint>
#include <iostream>
#include <vector>

using Row = std::uint64_t;
constexpr std::array<int,7> word{0,1,0,1,0,0,0};
struct Window { int width, phase; Row code; };

static Row parents(Row target, int width, int tick, int origin) {
    if (tick%2 && int(target & 1)!=word[(origin+tick/2)%7]) return 0;
    if (tick==0) return 1;
    Row total=0;
    // The two eastern input bits determine the rest: a = output XOR (b OR c).
    for (int pair=0; pair<4; ++pair) {
        Row row=Row(pair) << (width-1);
        for (int j=width-1; j>0; --j) {
            Row west=((target>>j) ^ ((row>>j) | (row>>(j+1)))) & 1;
            row |= west << (j-1);
        }
        const int wall=tick%2;  // wall was black at predecessor tick iff tick is odd
        if ((wall ^ int((row | (row>>1)) & 1))==int(target & 1))
            total+=parents(row,width+1,tick-1,origin);
    }
    return total;
}

int main() {
    std::vector<Window> windows;
    Window x{};
    while (std::cin>>x.width>>x.phase>>x.code) {
        if ((x.width!=30 && x.width!=45) || x.phase<0 || x.phase>=7 ||
            x.code>=(Row(1)<<x.width) || int(x.code & 1)!=word[x.phase]) return 1;
        windows.push_back(x);
    }
    if (!std::cin.eof() || windows.size()!=99) return 1;
    std::cout<<"sample phase lock30_count lock45_count common_numerator common_denominator\n";
    for (int sample=0; sample<=4; ++sample) {
        std::array<std::array<Row,2>,7> counts{};
        const int tick=2*sample+1;
        for (const auto& win:windows) {
            const int origin=(win.phase+7-sample)%7;
            counts[origin][win.width==45]+=parents(win.code,win.width,tick,origin);
        }
        for (int phase=0; phase<7; ++phase) {
            auto [a,b]=counts[phase];
            std::cout<<sample<<' '<<phase<<' '<<a<<' '<<b<<' '<<((a<<15)+b)
                     <<' '<<(Row(1)<<(45+tick))<<'\n';
        }
    }
}
