// Count finite trapped preimages of the two spatial prefixes in I224.
// The argument is the trap.txt produced by gptIntel_late_pair.py.
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>

using Row = std::uint64_t;
std::array<bool, 65536> trapped{};
int inverse_byte[4][256];

// Given two eastern input bits and eight output bits, reconstruct the next
// eight input bits to the west. Rule 30 gives a = output XOR (b OR c).
void prepare_inverse() {
    for (int east = 0; east < 4; ++east) {
        for (int outputs = 0; outputs < 256; ++outputs) {
            int inputs = east << 8;
            for (int j = 7; j >= 0; --j) {
                int bit = ((outputs >> j) ^ ((inputs >> (j+1)) | (inputs >> (j+2)))) & 1;
                inputs |= bit << j;
            }
            inverse_byte[east][outputs] = inputs & 255;
        }
    }
}

template <class Visit>
void each_parent(Row target, int width, int wall, Visit visit) {
    for (int east = 0; east < 4; ++east) {
        Row row = Row(east) << (width-1);
        int j = width-1;
        while (j >= 8) {
            int byte = inverse_byte[(row >> j) & 3][(target >> (j-7)) & 255];
            row |= Row(byte) << (j-8);
            j -= 8;
        }
        for (; j > 0; --j) {
            Row bit = ((target >> j) ^ ((row >> j) | (row >> (j+1)))) & 1;
            row |= bit << (j-1);
        }
        if ((wall ^ int((row | (row >> 1)) & 1)) == int(target & 1))
            visit(row);
    }
}

struct Census {
    int horizon;
    int origin_width;
    std::array<Row, 13> counts{};
    std::map<Row, Row> penultimate{};

    void walk(Row target, int width, int depth) {
        ++counts[depth];
        if (depth+1 == horizon)
            ++penultimate[target & ((Row(1) << origin_width)-1)];
        if (depth == horizon)
            return;
        each_parent(target, width, 1, [&](Row mid) {
            each_parent(mid, width+1, 0, [&](Row parent) {
                if (trapped[parent & 65535])
                    walk(parent, width+2, depth+1);
            });
        });
    }
};

void report(Row target, int width, int horizon, int origin_width) {
    Census census{horizon, origin_width};
    census.walk(target, width, 0);
    std::cout << "Target " << target << ", width " << width << "\nCounts:";
    for (int d = 0; d <= horizon; ++d)
        std::cout << ' ' << census.counts[d];
    std::cout << "\nFirst " << origin_width << " sites at depth " << horizon-1 << ':';
    for (const auto& [prefix, count] : census.penultimate)
        std::cout << ' ' << prefix << '=' << count;
    std::cout << std::endl;
}

int main(int argc, char** argv) {
    if (argc != 2)
        return 1;
    std::ifstream input(argv[1]);
    int code, count = 0;
    while (input >> code) {
        if (code < 0 || code >= 65536 || trapped[code])
            return 1;
        trapped[code] = true;
        ++count;
    }
    if (!input.eof() || count != 829)
        return 1;
    prepare_inverse();
    report(13674235287ULL, 36, 11, 22);
    report(5084300695ULL, 34, 12, 17);
}
