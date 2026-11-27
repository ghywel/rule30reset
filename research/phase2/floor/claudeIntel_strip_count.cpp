// K92.1, ledger N36 (claudeIntel). Count the gate words of the free-edge right strip of I246, from a kick.
// The strip, its initial set and its gate step are gptIntel's strip_floor.cpp, unchanged: a window of WIDTH
// cells beside the centre, every first white-tick window with a genuine black predecessor, the next window
// with any choice of its two missing rightmost cells, and the gate read as the window's nearest cell.
// A gate word is read by the strip when some path of windows reads it; words are counted by determinising
// level by level (the set of windows still possible after each prefix), so each word is counted once.
// Output per reading m: the number of words of m readings, and the number of distinct window sets.
//
// usage: strip_count WIDTH READINGS [MAXSETS]
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

using Row = uint32_t;
using Set = std::vector<Row>;

static Row step(Row r, Row wall) { return ((r << 1) | wall) ^ (r | (r >> 1)); }

int main(int argc, char** argv) {
    if (argc < 3) throw std::invalid_argument("usage: strip_count WIDTH READINGS [MAXSETS]");
    const int width = std::stoi(argv[1]), M = std::stoi(argv[2]);
    const size_t maxsets = argc > 3 ? std::stoull(argv[3]) : 20000000;
    const Row mask = (Row(1) << width) - 1;
    std::vector<Row> edges(size_t(mask + 1) * 4);
    for (Row r = 0; r <= mask; ++r)
        for (Row ext = 0; ext < 4; ++ext) edges[size_t(r) * 4 + ext] = step(step(r | (ext << width), 0), 1) & mask;
    std::vector<bool> appears(mask + 1);
    for (Row r = 0; r <= (mask << 1 | 1); ++r) appears[step(r, 1) & mask] = true;
    Set initial;
    for (Row r = 0; r <= mask; ++r) if (appears[r]) initial.push_back(r);
    auto child = [&](const Set& s, Row gate) {
        Set out;
        for (Row r : s) if ((r & 1) == gate) for (Row e = 0; e < 4; ++e) out.push_back(edges[size_t(r) * 4 + e]);
        std::sort(out.begin(), out.end());
        out.erase(std::unique(out.begin(), out.end()), out.end());
        return out;
    };
    std::map<Set, long double> cur;
    cur[initial] = 1;  // before reading 0; reading 0 is the anchor kick
    std::printf("# width %d initial windows %zu\n# readings words window_sets\n", width, initial.size());
    for (int m = 0; m < M; ++m) {
        std::map<Set, long double> nxt;
        for (const auto& [s, c] : cur)
            for (Row g = (m == 0 ? 1 : 0); g < 2; ++g) {
                Set t = child(s, g);
                if (!t.empty()) nxt[std::move(t)] += c;
            }
        long double words = 0;
        for (const auto& kv : nxt) words += kv.second;
        std::printf("%d %.0Lf %zu\n", m + 1, words, nxt.size());
        std::fflush(stdout);
        if (nxt.size() > maxsets) { std::printf("# stopped: more than %zu window sets\n", maxsets); break; }
        cur.swap(nxt);
    }
    return 0;
}
