// Exact four-tick wall histories on wide finite rows. One reproducible batch per process.
#include <array>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>

using Row = std::array<uint64_t, 5>;
constexpr int first_age = 59, last_age = 79, batch_size = 25000;
using Counts = std::array<int, last_age + 1>;
static uint8_t single[2][256], octet[256][256];

void build_tables() {
    for (int b = 0; b < 2; ++b)
        for (int s = 0; s < 256; ++s) {
            int result = 0, input = b;
            for (int layer = 0; layer < 4; ++layer) {
                int pair = (s >> (2 * layer)) & 3;
                int next = input ^ (pair != 0);
                input = pair & 1;
                result |= (2 * input + next) << (2 * layer);
            }
            single[b][s] = result;
        }
    for (int byte = 0; byte < 256; ++byte)
        for (int s = 0; s < 256; ++s) {
            int r = s;
            for (int j = 0; j < 8; ++j) r = single[(byte >> j) & 1][r];
            octet[byte][s] = r;
        }
}

Row forward(const Row &row) {
    Row out{};
    for (int i = 0; i < 5; ++i) {
        auto left = (row[i] << 1) | (i ? row[i-1] >> 63 : 0);
        auto right = (row[i] >> 1) | (i < 4 ? row[i+1] << 63 : 0);
        out[i] = right ^ (row[i] | left);
    }
    return out;
}

std::string hexrow(const Row &row) {
    std::ostringstream os;
    int i = 4;
    while (i && !row[i]) --i;
    os << std::hex << row[i--];
    for (; i >= 0; --i) os << std::setfill('0') << std::setw(16) << row[i];
    return os.str();
}

int draw_width(std::mt19937_64 &rng) {
    constexpr uint64_t mod = 41, threshold = (uint64_t(0) - mod) % mod;
    uint64_t v;
    do { v = rng(); } while (v < threshold);
    return 160 + int(v % mod);
}

Row draw_seed(std::mt19937_64 &rng, int width) {
    Row row{};
    int top = (width-1)/64, bit = (width-1)%64;
    for (int i = 0; i <= top; ++i) row[i] = rng();
    uint64_t leading = uint64_t(1) << bit;
    row[top] = leading | (row[top] & (leading-1));
    return row;
}

uint64_t outer_word(const Row &row, int width) {
    int offset = width-64, i = offset/64, bit = offset%64;
    return (row[i] >> bit) | (bit ? row[i+1] << (64-bit) : 0);
}

bool resets(uint64_t top) {
    for (int incoming = 0; incoming < 256; ++incoming) {
        int s = incoming;
        for (int j = 0; j < 8; ++j) s = octet[(top >> (8*j)) & 255][s];
        if (s) return false;
    }
    return true;
}

unsigned physical_mask(const Row &row, int width) {
    unsigned failed = 0;
    for (int history = 0; history < 16; ++history) {
        int s = 0;
        for (int j = 0; j < 4; ++j) s |= ((history >> j) & 1) << (2*j);
        int i = 0;
        for (; i + 8 <= width; i += 8) s = octet[(row[i/64] >> (i%64)) & 255][s];
        for (; i < width; ++i) s = single[(row[i/64] >> (i%64)) & 1][s];
        if (s) failed |= 1u << history;
    }
    return failed;
}

void emit_case(const char *tag, int index, int age, const Row &seed, const Row &row, unsigned mask) {
    std::cout << tag << ' ' << index << ' ' << age << ' ' << hexrow(seed)
              << ' ' << hexrow(row) << ' ' << mask << '\n';
}

int main(int argc, char **argv) {
    if (argc != 2) throw std::invalid_argument("expected batch number 0..39");
    int batch = std::stoi(argv[1]);
    if (batch < 0 || batch >= 40) throw std::out_of_range("batch");
    build_tables();
    if (batch == 0) {
        for (auto [seed, age] : {std::pair{7815, 58}, {1, 80}, {13, 46}, {617, 30}}) {
            Row initial{uint64_t(seed)}, row = initial;
            for (int t = 0; t < age; ++t) row = forward(row);
            int width = (32 - __builtin_clz(unsigned(seed))) + age;
            emit_case("control", -1, age, initial, row, physical_mask(row, width));
        }
    }
    std::mt19937_64 rng(0x4d33315233300000ULL + batch);
    std::unordered_map<uint64_t, bool> cache;
    Counts direct{}, failures{}, bad_heads{};
    std::array<int, 41> widths{};
    for (int local = 0; local < batch_size; ++local) {
        int width = draw_width(rng);
        ++widths[width-160];
        Row seed = draw_seed(rng, width), row = seed;
        for (int age = 1; age <= last_age; ++age) {
            row = forward(row);
            if (age < first_age) continue;
            uint64_t top = outer_word(row, width+age);
            auto [it, inserted] = cache.try_emplace(top, false);
            if (inserted) it->second = resets(top);
            unsigned mask = 0;
            if (!it->second) {
                ++direct[age];
                mask = physical_mask(row, width+age);
            }
            int index = batch*batch_size + local;
            if (local == 0) emit_case("sample", index, age, seed, row, mask);
            if (mask) {
                if (!failures[age]) emit_case("witness", index, age, seed, row, mask);
                ++failures[age];
                bad_heads[age] += __builtin_popcount(mask);
            }
        }
    }
    for (int a = first_age; a <= last_age; ++a)
        std::cout << "age " << a << ' ' << batch_size << ' ' << direct[a] << ' '
                  << failures[a] << ' ' << bad_heads[a] << '\n';
    std::cout << "widths";
    for (int n : widths) std::cout << ' ' << n;
    std::cout << '\n';
}
