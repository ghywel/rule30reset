// K92.2: longest common wall prefix of distinct tick-(2n) images.
// Usage: wall_projection [max-pinned-n (1..24)] [max-unpinned-n (0..11)]
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <vector>

using Word = unsigned __int128;
using Small = std::uint64_t;

static Word step(Word row) {
    return (row >> 1) ^ (row | (row << 1));
}

static Small reconstruct(Small trace, int width) {
    Small seed = 0, wall = 0;
    for (int depth = 0; depth < width; ++depth) {
        seed |= (trace & 1) << depth;
        const Small next = (trace >> 1) ^ (trace | wall);
        wall = trace;
        trace = next;
    }
    return seed;
}

static Small interleave(Small v) {
    v = (v | (v << 16)) & 0x0000ffff0000ffffULL;
    v = (v | (v << 8)) & 0x00ff00ff00ff00ffULL;
    v = (v | (v << 4)) & 0x0f0f0f0f0f0f0f0fULL;
    v = (v | (v << 2)) & 0x3333333333333333ULL;
    return (v | (v << 1)) & 0x5555555555555555ULL;
}

static Small reverse(Small v) {
    v = ((v & 0x5555555555555555ULL) << 1) | ((v >> 1) & 0x5555555555555555ULL);
    v = ((v & 0x3333333333333333ULL) << 2) | ((v >> 2) & 0x3333333333333333ULL);
    v = ((v & 0x0f0f0f0f0f0f0f0fULL) << 4) | ((v >> 4) & 0x0f0f0f0f0f0f0f0fULL);
    return __builtin_bswap64(v);
}

static Word wall_order(Word row) {
    return (static_cast<Word>(reverse(static_cast<Small>(row))) << 64)
           | reverse(static_cast<Small>(row >> 64));
}

static int common_wall(Word difference) {
    const auto lo = static_cast<Small>(difference);
    return lo ? __builtin_ctzll(lo) : 64 + __builtin_ctzll(static_cast<Small>(difference >> 64));
}

static int width(Word row) {
    const auto hi = static_cast<Small>(row >> 64), lo = static_cast<Small>(row);
    return hi ? 128 - __builtin_clzll(hi) : (lo ? 64 - __builtin_clzll(lo) : 0);
}

struct Image {
    Word order;
    Small seed;
};

struct Witness {
    int length = -1;
    Small first = 0, second = 0;

    void update(const Image& a, const Image& b) {
        const int candidate = common_wall(wall_order(a.order ^ b.order));
        if (candidate > length) {
            length = candidate;
            first = a.seed;
            second = b.seed;
        }
    }

    void print() const {
        std::cout << length << '[' << first << ',' << second << ']';
    }
};

static void census(int n, int pin) {
    const int horizon = 2 * n;
    const Small count = Small{1} << (pin == -1 ? horizon : n);
    const Small pins = interleave((Small{1} << n) - 1);
    std::vector<Image> images;
    images.reserve(count);
    for (Small i = 0; i < count; ++i) {
        const Small readings = pin == -1 ? 0 :
            (pins << pin) | (interleave(i) << (1 - pin));
        const Small seed = pin == -1 ? i : reconstruct(readings, horizon);
        Word row = seed;
        for (int t = 0; t < horizon; ++t) {
            if (pin != -1 && ((row ^ (readings >> t)) & 1)) std::exit(3);
            row = step(row);
        }
        images.push_back({wall_order(row), seed});
    }
    std::sort(images.begin(), images.end(), [](const Image& a, const Image& b) {
        return a.order < b.order || (a.order == b.order && a.seed < b.seed);
    });
    images.erase(std::unique(images.begin(), images.end(), [](const Image& a, const Image& b) {
        return a.order == b.order;
    }), images.end());
    Witness same, different;
    std::vector<int> previous(4 * n + 1, -1);
    int previous_width = -1;
    int projection_count = 0;
    for (int i = 0; i < static_cast<int>(images.size()); ++i) {
        const auto& image = images[i];
        const int support = width(wall_order(image.order));
        if (previous[support] != -1) same.update(images[previous[support]], image);
        if (i > 0 && previous_width != support) different.update(images[i - 1], image);
        if (!i || common_wall(wall_order(image.order ^ images[i - 1].order)) < horizon)
            ++projection_count;
        previous[support] = i;
        previous_width = support;
    }
    std::cout << "n=" << n << " pin=" << pin << " rows=" << images.size()
              << " wall=" << projection_count << " same=";
    same.print();
    std::cout << " different=";
    different.print();
    std::cout << std::endl;
}

int main(int argc, char** argv) {
    const int pinned = argc > 1 ? std::atoi(argv[1]) : 20;
    const int unpinned = argc > 2 ? std::atoi(argv[2]) : 9;
    if (pinned < 1 || pinned > 24 || unpinned < 0 || unpinned > 11) return 2;
    for (int n = 1; n <= pinned; ++n) {
        census(n, 0);
        census(n, 1);
    }
    for (int n = 1; n <= unpinned; ++n) census(n, -1);
}
