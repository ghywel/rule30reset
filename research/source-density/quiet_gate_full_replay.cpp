// Reconstruct a finite left cone, then replay every witness on the ordinary line.
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

using Cells = std::vector<unsigned char>;

struct Witness {
    int period;
    int sample;
    int first;
    int second;
};

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    std::ifstream input(argv[1]);
    std::string initial;
    if (!(input >> initial)) return 2;
    auto bits = std::stoull(initial, nullptr, 16);
    std::vector<Witness> witnesses;
    Witness w{};
    int last = 0;
    while (input >> w.period >> w.sample >> w.first >> w.second) {
        assert(w.period == static_cast<int>(witnesses.size()) + 1 && w.sample >= 0);
        witnesses.push_back(w);
        last = std::max(last, 3*(w.sample+w.period)+1);
    }
    assert(!witnesses.empty() && input.eof());
    Cells driven(last+1), drive(last+1), east(last+1), nextEast(last+1);
    for (int i = 0; i < std::min(64,last+1); ++i) east[i] = (bits >> i) & 1;
    for (int t = 0; t <= last; ++t) {
        drive[t] = (t % 3 != 1);
        driven[t] = east[0];
        nextEast[0] = drive[t] ^ (east[0] | east[1]);
        for (int i = 1; i < last-t; ++i)
            nextEast[i] = east[i-1] ^ (east[i] | east[i+1]);
        east.swap(nextEast);
    }
    const int center = last;
    Cells row(2*last+2), next(row.size()), left(last+1), seen(last+1);
    row[center] = drive[0];
    for (int i = 0; i < std::min(64,last+1); ++i) row[center+i+1] = (bits >> i) & 1;
    auto mid = drive;
    for (int depth = 1; depth <= last; ++depth) {
        for (int t = 0; t <= last-depth; ++t)
            left[t] = mid[t+1] ^ (mid[t] | driven[t]);
        row[center-depth] = left[0];
        driven.swap(mid);
        mid.swap(left);
    }
    for (int t = 0; t <= last; ++t) {
        assert(row[center] == drive[t]);
        seen[t] = row[center+1];
        for (int i = t+1; i < static_cast<int>(row.size())-t-1; ++i)
            next[i] = row[i-1] ^ (row[i] | row[i+1]);
        row.swap(next);
    }
    for (const auto &pair : witnesses) {
        assert(pair.first != pair.second);
        assert(seen[3*pair.sample+1] == pair.first);
        assert(seen[3*(pair.sample+pair.period)+1] == pair.second);
    }
    std::cout << witnesses.size() << " mismatches replayed through tick " << last
              << " on one ordinary finite row\n";
}
