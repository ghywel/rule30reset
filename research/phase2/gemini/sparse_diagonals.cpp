// Independent prefix enumeration of the white-wall sparse survival problem.
// g++ -std=c++17 -O3 sparse_diagonals.cpp -o sparse_diagonals
#include <array>
#include <cstdint>
#include <cstdio>

constexpr int horizon = 132;
constexpr int budget = 18;
constexpr int words = 1 + horizon / 64;
using Bits = std::array<std::uint64_t, words>;

struct Record {
    int tick = -1;
    Bits row{};
    std::uint64_t failures = 0;
};

std::array<Record, budget + 1> by_weight{};
std::uint64_t live_at_horizon = 0;

std::uint64_t prefix_xor(std::uint64_t x) {
    x ^= x << 1;
    x ^= x << 2;
    x ^= x << 4;
    x ^= x << 8;
    x ^= x << 16;
    return x ^ (x << 32);
}

// Diagonal j contains x(t,j-t) at bit t, for 0 <= t <= j.
// Its initial bit is supplied by the next top-row bit. For t < j, the
// difference of bits t and t+1 is D[j-1][t] OR D[j-2][t]. A missing bit
// (negative site) reads the physical white wall.
void extend(int j, int weight, Bits& top, const Bits& prev, const Bits& older) {
    const int word = j / 64;
    const int shift = j % 64;
    const auto last = std::uint64_t{1} << shift;
    const auto mask = last | (last - 1);
    Bits diagonal{};
    std::uint64_t high_input = 0;
    std::uint64_t parity = 0;
    for (int i = 0; i <= word; ++i) {
        const auto input = prev[i] | older[i];
        const auto shifted = (input << 1) | high_input;
        diagonal[i] = prefix_xor(shifted) ^ (std::uint64_t{0} - parity);
        high_input = input >> 63;
        parity = diagonal[i] >> 63;
    }
    diagonal[word] &= mask;
    for (int bit = 0; bit <= 1 && weight + bit <= budget; ++bit) {
        if (bit) {
            // Changing D[j][0] complements every defined bit on the diagonal.
            for (int i = 0; i < word; ++i) diagonal[i] = ~diagonal[i];
            diagonal[word] ^= mask;
            top[word] |= last;
        }
        if (j % 2 == 0 && !(diagonal[word] & last)) {
            auto& record = by_weight[weight + bit];
            ++record.failures;
            if (j > record.tick) {
                record.tick = j;
                record.row = top;
            }
        } else if (j == horizon) {
            ++live_at_horizon;
        } else {
            extend(j + 1, weight + bit, top, diagonal, prev);
        }
        if (bit) top[word] ^= last;
    }
}

int main() {
    Bits top{};
    const Bits wall{};
    extend(0, 0, top, wall, wall);
    std::printf("budget failures_at_exact_prefix_weight latest_failure witness_hex\n");
    Record worst;
    for (int b = 0; b <= budget; ++b) {
        const auto& record = by_weight[b];
        if (record.tick > worst.tick) worst = record;
        std::printf("%d %llu %d ", b, static_cast<unsigned long long>(record.failures), worst.tick);
        for (int i = words - 1; i >= 0; --i)
            std::printf("%016llx", static_cast<unsigned long long>(worst.row[i]));
        std::printf("\n");
    }
    std::printf("alive_at_tick_%d %llu\n", horizon, static_cast<unsigned long long>(live_at_horizon));
    return live_at_horizon != 0;
}
