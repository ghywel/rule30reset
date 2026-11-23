// Enumerate finite black-first seeds and report closed, late trapped wheel runs.
// Usage: k81_finite_streaks GateTrap.lean seed_bits samples
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using Word = std::uint64_t;

std::array<bool, 65536> read_trap(const char *path) {
    std::ifstream stream(path);
    const std::string text{std::istreambuf_iterator<char>(stream), {}};
    const std::string key = "def trapCodes : List Nat := [";
    const auto at = text.find(key);
    if (at == std::string::npos) throw std::runtime_error("missing kit trap");
    const auto start = at + key.size();
    std::string list = text.substr(start, text.find(']', start) - start);
    std::replace(list.begin(), list.end(), ',', ' ');
    std::istringstream values(list);
    std::array<bool, 65536> trap{};
    unsigned code;
    while (values >> code) {
        if (trap.at(code)) throw std::runtime_error("duplicate trap window");
        trap[code] = true;
    }
    if (std::count(trap.begin(), trap.end(), true) != 829) throw std::runtime_error("wrong trap");
    return trap;
}

struct Streak { int copies = 0, start = -1, end = -1; };
struct RowResult { int entry = -1; std::array<Streak, 2> best{}; };

RowResult inspect(unsigned seed, int samples, const std::array<bool, 65536> &trap) {
    // Even at the final sample, the full initial cone of the 16 measured
    // sites fits. Fixed zeros beyond this computational boundary cannot return.
    std::vector<Word> row((2 * samples + 16 + 63) / 64);
    row[0] = seed;
    RowResult result;
    int last_pulse = -1, last_three = -1, fives = 0;
    int previous_run = -1, consecutive = 0, opening = -1;
    for (int tick = 0; tick < 2 * samples - 1; ++tick) {
        Word left = (tick % 2 == 0);
        for (size_t j = 0; j < row.size(); ++j) {
            const Word x = row[j];
            const Word east = j + 1 < row.size() ? row[j + 1] << 63 : 0;
            row[j] = ((x << 1) | left) ^ (x | (x >> 1) | east);
            left = x >> 63;
        }
        if (tick % 2) continue;
        const int sample = tick / 2;  // physical time 2*sample+1
        if (result.entry < 0 && trap[row[0] & 65535]) result.entry = sample;
        if (result.entry < 0 || sample < result.entry + 60 || !(row[0] & 1)) continue;
        if (last_pulse >= 0) {
            const int gap = sample - last_pulse;
            if (gap == 3) {
                if (last_three >= 0) {
                    if (fives != previous_run) { consecutive = 0; opening = last_three; }
                    ++consecutive;
                    if (fives == 3 || fives == 5) {
                        auto &best = result.best[fives == 5];
                        if (consecutive > best.copies) best = {consecutive, opening, sample};
                    }
                    previous_run = fives;
                }
                last_three = last_pulse;  // first pulse of this closing/opening gap
                fives = 0;
            } else if (gap == 5) {
                ++fives;
            } else {
                throw std::runtime_error("unexpected late trapped gap");
            }
        }
        last_pulse = sample;
    }
    return result;
}

int main(int argc, char **argv) {
    if (argc != 4) return 2;
    const auto trap = read_trap(argv[1]);
    const int width = std::stoi(argv[2]), samples = std::stoi(argv[3]);
    if (width < 0 || width > 24 || samples < 65 || samples > 1000000) return 2;
    const unsigned seeds = 1u << width;
    std::vector<RowResult> results(seeds);
    #pragma omp parallel for schedule(static)
    for (int seed = 0; seed < int(seeds); ++seed) results[seed] = inspect(seed, samples, trap);
    std::cout << "seeds " << seeds << " samples " << samples << "\n";
    for (unsigned index = 0; index < 2; ++index) {
        const int run = index ? 5 : 3, target = index ? 5 : 18;
        unsigned best = 0, count = 0, first = seeds;
        for (unsigned s = 0; s < seeds; ++s) {
            if (results[s].best[index].copies > results[best].best[index].copies) best = s;
            if (results[s].best[index].copies >= target) { ++count; first = std::min(first,s); }
        }
        std::cout << "run " << run << " target " << target << " qualifying_seeds " << count << "\n";
        for (unsigned s : {first, best}) if (s < seeds) {
            const auto &r = results[s]; const auto &b = r.best[index];
            std::cout << "seed " << s << " entry " << r.entry << " copies " << b.copies
                      << " start " << b.start << " end " << b.end << "\n";
        }
    }
}
