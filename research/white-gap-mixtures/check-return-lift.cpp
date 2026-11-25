// R118: carry extra right cells through every candidate distance-11 return.
#define main gap_program_main
#include "claudeIntel_gap_pairs.cpp"
#undef main

namespace {
constexpr int baseWidth = 29;
constexpr int mark = 18;

// The bar in each factor follows its seventh gap.
const vector<vector<int>> slots = {
    {10,14}, {12}, {14}, {12}, {12}, {10}, {9}, {10}, {10,12},
    {9,10,11,12,13,14,15,16}, {9,10,11,12,13,14,15,16},
    {10,14}, {12}, {14}, {12}, {12}, {10}, {9}, {10}, {10,12}
};

using Table = vector<vector<unsigned char>>;

Table suffixRows(const Graph &graph, int sample) {
    Table live(slots.size()+1, vector<unsigned char>(graph.row.size(), 1));
    for (int t = int(slots.size())-1; t >= 0; --t) {
        for (size_t i = 0; i < graph.row.size(); ++i) {
            bool canFinish = false;
            if (t != mark || sample < 0 || colour(graph.row[i]) == sample) {
                for (int gap : slots[t]) {
                    int a = gap-9;
                    for (u32 j = graph.off[a][i]; j < graph.off[a][i+1]; ++j)
                        canFinish |= live[t+1][graph.dst[a][j]];
                }
            }
            live[t][i] = canFinish;
        }
    }
    return live;
}

struct Row {
    u64 value;
    u32 baseIndex;
    u32 parent;
    int gap;
};

// Exactly which upper s bits can follow this row after s driven ticks.
void outcomes(u64 row, int width, int s, vector<u64> &bits, u64 &lower) {
    const int fixed = width-s;
    const u64 leftMask = (1ull << fixed)-1;
    const u64 upperMask = (1ull << s)-1;
    bits.assign((1u << s)/64, 0);
    u64 lane[1024];
    for (u32 begin = 0; begin < (1u << s); begin += 1024) {
        for (u32 i = 0; i < 1024; ++i) lane[i] = (u64(begin+i) << width) | row;
        for (u32 i = 0; i < 1024; ++i) lane[i] = 1 ^ (lane[i] << 1) ^ (lane[i] | (lane[i] >> 1));
        for (int t = 1; t < s; ++t)
            for (u32 i = 0; i < 1024; ++i) lane[i] = (lane[i] << 1) ^ (lane[i] | (lane[i] >> 1));
        if (!begin) lower = lane[0] & leftMask;
        for (u64 value : lane) {
            u64 key = (value >> fixed) & upperMask;
            bits[key >> 6] |= 1ull << (key & 63);
        }
    }
}

vector<Row> step(const Graph &graph, const vector<Row> &rows,
                const vector<unsigned char> &live, int slot, int hidden) {
    int width = baseWidth + hidden;
    vector<vector<Row>> output(THREADS);
    par(rows.size(), 16, [&](size_t lo, size_t hi, int thread) {
        vector<u64> bits;
        vector<u32> targets;
        for (size_t parent = lo; parent < hi; ++parent) {
            auto &src = rows[parent];
            for (int gap : slots[slot]) {
                int a = gap-9;
                targets.clear();
                for (u32 j = graph.off[a][src.baseIndex]; j < graph.off[a][src.baseIndex+1]; ++j) {
                    u32 dst = graph.dst[a][j];
                    if (live[dst]) targets.push_back(dst);
                }
                if (targets.empty()) continue;
                u64 lower = 0;
                const int fixed = width-gap-1;
                if (hidden) outcomes(src.value, width, gap+1, bits, lower);
                for (u32 dst : targets) {
                    for (int tail = 0; tail < (1 << hidden); ++tail) {
                        u64 value = graph.row[dst] | (u64(tail) << baseWidth);
                        if (hidden) {
                            if ((value & ((1ull << fixed)-1)) != lower) continue;
                            u64 key = value >> fixed;
                            if (!(bits[key >> 6] >> (key & 63) & 1)) continue;
                        }
                        output[thread].push_back({value, dst, u32(parent), gap});
                    }
                }
            }
        }
    });
    vector<Row> result;
    for (auto &part : output) result.insert(result.end(), part.begin(), part.end());
    sort(result.begin(), result.end(), [](const Row &a, const Row &b) {
        if (a.value != b.value) return a.value < b.value;
        if (a.parent != b.parent) return a.parent < b.parent;
        return a.gap < b.gap;
    });
    result.erase(unique(result.begin(), result.end(), [](const Row &a, const Row &b) {
        return a.value == b.value;
    }), result.end());
    return result;
}
} // namespace

int main(int argc, char **argv) {
    if (argc != 5) {
        fprintf(stderr, "usage: check-return-lift GRAPH HIDDEN SAMPLE THREADS\n");
        return 2;
    }
    int hidden = atoi(argv[2]), sample = atoi(argv[3]);
    THREADS = atoi(argv[4]);
    if (hidden < 0 || hidden > 4 || sample < -1 || sample > 1 || THREADS < 1) return 2;
    Graph graph = load(argv[1], baseWidth);
    Table live = suffixRows(graph, sample);
    vector<vector<Row>> paths(1);
    for (u32 i = 0; i < graph.row.size(); ++i) if (live[0][i])
        for (int tail = 0; tail < (1 << hidden); ++tail)
            paths[0].push_back({graph.row[i] | (u64(tail) << baseWidth), i, 0, 0});
    for (size_t t = 0; t <= slots.size(); ++t) {
        printf("slot %zu rows %zu\n", t, paths[t].size());
        fflush(stdout);
        if (paths[t].empty()) return 0;
        if (t < slots.size()) paths.push_back(step(graph, paths[t], live[t+1], int(t), hidden));
    }
    vector<Row> witness;
    size_t index = 0;
    for (size_t t = paths.size(); t > 0; --t) {
        Row row = paths[t-1][index];
        witness.push_back(row);
        index = row.parent;
    }
    reverse(witness.begin(), witness.end());
    for (size_t t = 0; t < witness.size(); ++t)
        printf("witness %zu %d %llu\n", t, witness[t].gap, (unsigned long long)witness[t].value);
}
