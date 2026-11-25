// Enumerate a certified superset of physical black-first gate words.
// Physical right rows are a separate source of replayable lower witnesses.
#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

using Row = std::uint32_t;
using Word = std::uint64_t;

template<class Bits>
Bits step(Bits row, unsigned wall) {
    return ((row << 1) | wall) ^ (row | (row >> 1));
}

struct Strip {
    unsigned width, samples;
    Row mask;
    std::vector<std::array<Row, 4>> edges;
    std::vector<Word> seen;
    std::vector<std::uint64_t> totals;

    Strip(unsigned width, unsigned samples)
        : width(width), samples(samples), mask((Row{1} << width) - 1),
          edges(mask + 1), seen(mask + 1), totals(samples + 1) {
        for (Row row = 0; row <= mask; ++row) {
            for (Row edge = 0; edge < 4; ++edge) {
                const Row full = row | (edge << width);
                edges[row][edge] = step(step(full, 0), 1) & mask;
            }
        }
    }

    void visit(const std::vector<Row>& rows, unsigned depth, Word word) {
        ++totals[depth];
        if (depth == samples) {
            std::cout << word << '\n';
            return;
        }
        // Each parent's word has its own stamp. The two labelled children
        // have distinct stamps, even when they share a successor.
        const Word base = (Word{1} << (depth + 1)) | (word << 1);
        std::array<std::vector<Row>, 2> children;
        for (Row row : rows) {
            const unsigned gate = row & 1;
            for (Row next : edges[row]) {
                // A mark from the other child must never overwrite this one.
                if ((seen[next] & ~Word{3}) != (base << 1)) {
                    seen[next] = base << 1;
                }
                const Word bit = Word{1} << gate;
                if ((seen[next] & bit) == 0) {
                    seen[next] |= bit;
                    children[gate].push_back(next);
                }
            }
        }
        for (unsigned gate = 0; gate < 2; ++gate) {
            if (!children[gate].empty()) {
                visit(children[gate], depth + 1, (word << 1) | gate);
            }
        }
    }

    void run() {
        std::vector<Row> initial;
        std::vector<bool> listed(mask + 1);
        // At the first white sample we require a genuine black predecessor.
        for (Row row = 0; row < (Row{2} << width); ++row) {
            const Row first = step(row, 1) & mask;
            if (!listed[first]) {
                listed[first] = true;
                initial.push_back(first);
            }
        }
        visit(initial, 0, 0);
        for (unsigned i = 1; i <= samples; ++i) {
            std::cerr << i << '\t' << totals[i] << '\n';
        }
    }
};

struct Right {
    std::uint64_t low, high;

    void update(unsigned wall) {
        const auto new_low = ((low << 1) | wall) ^ (low | (low >> 1) | (high << 63));
        high = ((high << 1) | (low >> 63)) ^ (high | (high >> 1));
        low = new_low;
    }

    Word read(unsigned samples) const {
        Right row = *this;
        Word word = 0;
        for (unsigned i = 0; i < samples; ++i) {
            row.update(1);
            word = (word << 1) | (row.low & 1);
            row.update(0);
        }
        return word;
    }
};

std::uint64_t random_bits(std::uint64_t& state) {
    state += UINT64_C(0x9e3779b97f4a7c15);
    std::uint64_t n = state;
    n = (n ^ (n >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
    n = (n ^ (n >> 27)) * UINT64_C(0x94d049bb133111eb);
    return n ^ (n >> 31);
}

int main(int argc, char** argv) {
    if (argc != 4) {
        throw std::invalid_argument("strip WIDTH READINGS or sample ROWS READINGS");
    }
    const std::string mode(argv[1]);
    const auto size = std::stoul(argv[2]);
    const auto samples = std::stoul(argv[3]);
    if (samples == 0 || samples > 60) {
        throw std::invalid_argument("READINGS must be between 1 and 60");
    }
    if (mode == "strip" && size >= 1 && size <= 24) {
        Strip(size, samples).run();
    } else if (mode == "sample") {
        std::uint64_t state = UINT64_C(0xa243bffe983d7915);
        std::unordered_map<Word, Right> witnesses;
        for (std::uint64_t i = 0; i < size; ++i) {
            const Right right{random_bits(state), random_bits(state)};
            witnesses.try_emplace(right.read(samples), right);
        }
        for (const auto& [word, right] : witnesses) {
            std::cout << word << '\t' << right.low << '\t' << right.high << '\n';
        }
    } else {
        throw std::invalid_argument("unknown mode or strip width outside 1..24");
    }
}
