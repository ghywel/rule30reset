// Independently verify a seven-spaced first-failure table. The input is
// suffix, number of offsets, one spike-count period per offset, then the
// count and (modulus, residue, lag) triples for each of pin and G, in order.
#include <algorithm>
#include <array>
#include <bit>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <vector>

using Word = std::uint64_t;

constexpr unsigned join = 16;
constexpr unsigned rule = 30;
constexpr std::array<unsigned, 9> masks{278, 17333, 9765, 32125, 321, 17251, 9814, 32213, 277};

unsigned reference(unsigned time, unsigned depth) {
    const unsigned phase = time == 0 ? 0 : 1 + (time - 1) % 8;
    const unsigned slot = depth < 8 ? depth : 8 + (depth - 8) % 7;
    return (masks[phase] >> slot) & 1;
}

unsigned evolve(unsigned west, unsigned self, unsigned east) {
    return (rule >> (4 * west + 2 * self + east)) & 1;
}

void require(bool ok, const char* message) {
    if (!ok) throw std::runtime_error(message);
}

unsigned read_unsigned() {
    unsigned value;
    require(bool(std::cin >> value), "truncated or invalid input");
    return value;
}

struct Check {
    unsigned time;
    unsigned lag;
    bool full_g;
};

std::vector<Check> queries(const std::vector<unsigned>& periods, bool full_g) {
    struct Residue { unsigned modulus, residue, offset; };
    std::vector<Residue> entries;
    std::vector<Check> trials;
    unsigned count = read_unsigned();
    unsigned covered = 0;
    while (count--) {
        const unsigned modulus = read_unsigned(), residue = read_unsigned(), offset = read_unsigned();
        require(std::has_single_bit(modulus) && modulus <= periods.back(), "bad rule modulus");
        require(residue < modulus && offset < periods.size(), "bad residue or offset");
        for (const auto& old : entries) {
            const unsigned common = std::min(modulus, old.modulus);
            require(residue % common != old.residue % common, "overlapping residue rules");
        }
        entries.push_back({modulus, residue, offset});
        covered += periods.back() / modulus;
        const unsigned period = std::max(modulus, periods[offset]);
        for (unsigned r = residue; r < period; r += modulus) {
            const unsigned n = r < 3 ? r + period : r;
            trials.push_back({7 * n - 15, offset, full_g});
        }
    }
    require(covered == periods.back(), "incomplete residue table");
    return trials;
}

void check_wall(Word strip, const Check& check) {
    std::vector<unsigned> cone(join + check.lag + 1);
    for (unsigned d = 0; d < join; ++d) cone[d] = reference(check.time, d);
    for (unsigned d = join; d < cone.size(); ++d) cone[d] = (strip >> (2 + d - join)) & 1;
    std::array<unsigned, 3> readings{};
    const unsigned limit = join + check.lag;
    for (unsigned u = 0; u <= limit; ++u) {
        readings[u % 3] = cone[0];
        if (u >= join) {
            const bool pinned = (check.time + u) % 2 == 1;
            const bool failed = pinned ? cone[0] == 0 : check.full_g && (cone[0] | readings[(u - 2) % 3]) == 0;
            require(failed == (u == limit), "wrong first failure");
        }
        if (u == limit) break;
        unsigned east = 0;
        for (unsigned d = 0; d + 1 < cone.size(); ++d) {
            const unsigned self = cone[d];
            cone[d] = evolve(cone[d + 1], self, east);
            east = self;
        }
        cone.pop_back();
    }
}

int main() {
    try {
        for (unsigned t = 0; t < 9; ++t) {
            for (unsigned d = 0; d < 16; ++d) {
                require(reference(t + 1, d) == evolve(reference(t, d + 1), reference(t, d),
                        d ? reference(t, d - 1) : 0), "reference evolution mismatch");
            }
        }
        std::array<Word, 28> feed{};
        for (unsigned t = 0; t < feed.size(); ++t) {
            feed[t] = reference(t, 48 - t) + 2 * reference(t, 49 - t);
        }
        const Word suffix = read_unsigned();
        const unsigned width = read_unsigned();
        require(width > 0 && width <= 61, "bad strip width");
        std::vector<unsigned> periods(width);
        unsigned previous = 8;
        for (auto& p : periods) {
            p = read_unsigned();
            require(p <= (1U << 28) && (p == previous || p == 2 * previous), "bad strip period");
            previous = p;
        }
        auto trial = queries(periods, false);
        const unsigned pin_count = static_cast<unsigned>(trial.size());
        auto g_trial = queries(periods, true);
        trial.insert(trial.end(), g_trial.begin(), g_trial.end());
        std::ranges::sort(trial, {}, &Check::time);

        const Word mask = (Word{1} << (width + 2)) - 4;
        const Word start = ((suffix << 2) & mask) | feed[0];
        Word state = start;
        unsigned returned = 0;
        auto next = trial.begin();
        const unsigned end = 7 * periods.back();
        for (unsigned t = 0; t <= end; ++t) {
            while (next != trial.end() && next->time == t) {
                check_wall(state, *next++);
            }
            while (returned < width && 7 * periods[returned] == t) {
                const Word prefix = (Word{1} << (returned + 3)) - 1;
                require(((state ^ start) & prefix) == 0, "strip does not return at stated period");
                ++returned;
            }
            state = ((state ^ ((state << 1) | (state << 2))) & mask) | feed[(t + 1) % 28];
        }
        require(next == trial.end() && returned == width, "missed checks");
        std::cout << "Suffix " << suffix << ": " << returned << " strip returns through tick " << end
                  << ", " << pin_count << " pin and " << g_trial.size() << " G representatives passed\n";
    } catch (const std::exception& err) {
        std::cerr << err.what() << '\n';
        return 1;
    }
}
