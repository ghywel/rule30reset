// K50.1: exact graph of all W-column windows at odd times (16 <= W <= 24).
// clang++ -std=c++17 -O3 gptM5_windows.cpp -o /tmp/k50-windows
// /tmp/k50-windows PATH/Rule30Certificates/GateTrap.lean [first last [certificate]]
// SidewaysLocks.dstep: both far cells W+1, W+2 are chosen at the initial odd tick.
// A nonperiodic label in this graph need not be realizable by a finite right half.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <numeric>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using Word = uint32_t;
using Flags = std::vector<uint8_t>;
constexpr Word unseen = UINT32_MAX;

static void require(bool ok, const char *why) {
    if (!ok) throw std::runtime_error(why);
}

static Flags trap_table(const char *path) {
    std::ifstream file(path);
    require(file.good(), "cannot open trap source");
    std::ostringstream contents;
    contents << file.rdbuf();
    std::string source = contents.str();
    const std::string marker = "def trapCodes : List Nat := [";
    auto start = source.find(marker);
    require(start != std::string::npos, "trapCodes declaration missing");
    start += marker.size();
    auto end = source.find(']', start);
    require(end != std::string::npos, "unterminated trapCodes");
    std::string body = source.substr(start, end - start);
    require(body.find_first_not_of("0123456789, \t\r\n") == std::string::npos, "unexpected trap syntax");
    std::replace(body.begin(), body.end(), ',', ' ');
    std::istringstream numbers(body);
    Flags trap(1 << 16, 0);
    Word v, count = 0;
    while (numbers >> v) {
        require(v < trap.size() && !trap[v], "duplicate or out-of-range trap code");
        trap[v] = 1;
        ++count;
    }
    require(count == 829 && trap[49415], "kit trap cardinality or entry code differs");
    return trap;
}

struct Graph {
    unsigned width;
    Word size;
    const Flags &trap;
    bool simultaneous;
    Word step(Word x, Word wall, Word outside) const {
        return (((x << 1) | wall) ^ (x | (x >> 1) | (outside << (width-1)))) & (size-1);
    }
    Word next(Word x, unsigned input) const {
        Word first = input >> 1, second = input & 1;
        // The second-tick neighbour is the first update of the initial cell W+1.
        if (simultaneous) second = (x >> (width-1)) ^ (first | second);
        return step(step(x, 0, first), 1, second);
    }
    // Independent scalar Rule 30 oracle, with the wall and far bits supplied separately.
    static Word scalar_step(Word x, Word wall, Word outside, unsigned width) {
        Word y = 0;
        for (unsigned i = 0; i < width; ++i) {
            Word left = i == 0 ? wall : (x >> (i-1)) & 1;
            Word right = i+1 == width ? outside : (x >> (i+1)) & 1;
            y |= (left ^ (((x >> i) & 1) | right)) << i;
        }
        return y;
    }
    bool in_trap(Word x) const { return trap[x & 65535]; }
};

// Strip sources with zero indegree. The remaining vertices are exactly the
// descendants of cycles, including paths that can never return to themselves.
// Count parallel edges with multiplicity on both insertion and removal.
static Flags eventual_image(const Graph &g, bool trap_only) {
    std::vector<Word> indegree(g.size, 0);
    Flags keep(g.size);
    for (Word x = 0; x < g.size; ++x) {
        if (trap_only && !g.in_trap(x)) continue;
        keep[x] = 1;
        for (unsigned b = 0; b < 4; ++b) {
            Word v = g.next(x, b);
            require(!trap_only || g.in_trap(v), "trap escaped under a free input");
            ++indegree[v];
        }
    }
    std::vector<Word> queue;
    for (Word x = 0; x < g.size; ++x)
        if (keep[x] && !indegree[x]) queue.push_back(x);
    for (size_t i = 0; i < queue.size(); ++i) {
        Word x = queue[i];
        keep[x] = 0;
        for (unsigned b = 0; b < 4; ++b) {
            Word v = g.next(x, b);
            if (--indegree[v] == 0) queue.push_back(v);
        }
    }
    return keep;
}

static void controls(const Graph &g, const Flags &core) {
    // At W=16 test every cell of every transition. At larger W sample evenly
    // across the domain, including the first and last words.
    Word stride = g.width == 16 ? 1 : (g.size-1) / 1024;
    for (Word x = 0; ; x = std::min(x+stride, g.size-1)) {
        for (unsigned b = 0; b < 4; ++b) {
            Word extended = x | ((b >> 1) << g.width) | ((b & 1) << (g.width+1));
            Word next_row = Graph::scalar_step(extended, 0, 0, g.width+2);
            Word oracle = Graph::scalar_step(next_row, 1, 0, g.width+1) & (g.size-1);
            require(g.next(x,b) == oracle, "xx transition differs from scalar finite cone");
        }
        if (x == g.size-1) break;
    }
    // Adjacent two black cells just before a white cell at W: p=1,q=0 is
    // possible with successive free inputs and impossible with two initial bits.
    Word witness = 3u << (g.width-3);
    Word spurious = g.step(g.step(witness, 0, 1), 1, 0);
    for (unsigned b = 0; b < 4; ++b)
        require(g.next(witness,b) != spurious, "successive inputs were mistaken for initial cells");
    if (g.width == 16) {
        // Directly iterate the forward image to its fixed point.
        Flags image(g.size, 1);
        while (true) {
            Flags next_image(g.size, 0);
            for (Word x = 0; x < g.size; ++x) if (image[x])
                for (unsigned b = 0; b < 4; ++b) next_image[g.next(x, b)] = 1;
            if (image == next_image) break;
            image.swap(next_image);
        }
        require(image == core, "global eventual image differs from direct iteration");
    }
}

// The directed period of an SCC is the gcd of depth[u]+1-depth[v] over all
// internal edges. A uniform label on each residue class forces its cyclic word.
// If one class contains both labels, same-length paths can reach each colour
// (by the period theorem); arbitrary concatenations of rooted equal-length
// return walks with different labels then include aperiodic labelled paths.
static std::string primitive_word(const std::string &s) {
    std::vector<Word> prefix(s.size(), 0);
    for (Word i = 1; i < s.size(); ++i) {
        Word j = prefix[i-1];
        while (j && s[j] != s[i]) j = prefix[j-1];
        if (s[j] == s[i]) ++j;
        prefix[i] = j;
    }
    size_t p = s.size() - prefix.back();
    return s.substr(0, s.size() % p ? s.size() : p);
}

struct Summary {
    Word components = 0, cyclic = 0, sinks = 0, cycle_vertices = 0;
    Word trap_cycle_vertices = 0, exterior_variable = 0, exterior_variable_sinks = 0;
};

// Check the reverse direction separately from Tarjan: within each component,
// every vertex must be reachable from the representative on reversed edges.
static void verify_return_paths(const Graph &g, const std::vector<Word> &members,
                                const std::vector<Word> &component, std::vector<Word> &index) {
    if (members.size() == 1) return;
    Word id = component[members[0]];
    for (Word i = 0; i < members.size(); ++i) index[members[i]] = i;
    std::vector<Word> offset(members.size()+1, 0);
    for (Word x : members) for (unsigned b = 0; b < 4; ++b) {
        Word v = g.next(x,b);
        if (component[v] == id) ++offset[index[v]+1];
    }
    std::partial_sum(offset.begin(), offset.end(), offset.begin());
    std::vector<Word> predecessor(offset.back()), cursor(offset);
    for (Word x : members) for (unsigned b = 0; b < 4; ++b) {
        Word v = g.next(x,b);
        if (component[v] == id) predecessor[cursor[index[v]]++] = index[x];
    }
    Flags seen(members.size(), 0);
    seen[0] = 1;
    std::vector<Word> queue{0};
    for (size_t i = 0; i < queue.size(); ++i) {
        Word v = queue[i];
        for (Word j = offset[v]; j < offset[v+1]; ++j) {
            Word pred = predecessor[j];
            if (!seen[pred]) { seen[pred] = 1; queue.push_back(pred); }
        }
    }
    require(queue.size() == members.size(), "component fails the reverse reachability check");
}

// A certificate is ASCII K50SCC1 plus LF, then little-endian uint32 words:
// W, followed by (least vertex, positive size, increasing member words) for each
// cyclic SCC in stdout order. EOF ends the file. Transient components are omitted.
static void write_word(std::ostream &out, Word x) {
    const std::array<char,4> bytes{char(x),char(x>>8),char(x>>16),char(x>>24)};
    out.write(bytes.data(), bytes.size());
}

static void classify(const Graph &g, const std::vector<Word> &members, const std::vector<Word> &component,
                     std::vector<Word> &depth, Summary &totals, std::ostream *cert) {
    Word id = component[members.front()];
    Word root = *std::min_element(members.begin(), members.end());
    if (members.size() == 1) {
        bool loop = false;
        for (unsigned b = 0; b < 4; ++b) {
            Word v = g.next(root,b);
            require(component[v] <= id, "singleton condensation edge not in sink-first order");
            loop |= v == root;
        }
        if (!loop) return;
    }
    verify_return_paths(g, members, component, depth);
    if (cert) {
        auto sorted = members;
        std::sort(sorted.begin(), sorted.end());
        write_word(*cert, root);
        write_word(*cert, Word(sorted.size()));
        for (Word x : sorted) write_word(*cert, x);
    }
    ++totals.cyclic;
    totals.cycle_vertices += members.size();
    if (g.in_trap(root)) totals.trap_cycle_vertices += members.size();
    Word period = 0, black = 0;
    uint64_t exits = 0;
    Word exit_from = unseen, exit_to = unseen;
    for (Word x : members) depth[x] = unseen;
    std::vector<Word> queue{root};
    depth[root] = 0;
    for (size_t i = 0; i < queue.size(); ++i) {
        Word x = queue[i];
        require(g.in_trap(x) == g.in_trap(root), "SCC crosses the invariant trap boundary");
        black += x & 1;
        for (unsigned b = 0; b < 4; ++b) {
            Word v = g.next(x, b);
            if (component[v] != id) {
                require(component[v] < id, "condensation edge not in sink-first order");
                if (!exits) { exit_from = x; exit_to = v; }
                ++exits;
            } else {
                if (depth[v] == unseen) {
                    depth[v] = depth[x] + 1;
                    queue.push_back(v);
                }
                int diff = int(depth[x]) + 1 - int(depth[v]);
                period = std::gcd(period, Word(diff < 0 ? -diff : diff));
            }
        }
    }
    require(queue.size() == members.size() && period, "bad cyclic SCC");
    std::string labels(period, '?');
    std::vector<Word> first(period, unseen);
    Word conflict_a = unseen, conflict_b = unseen;
    for (Word x : queue) {
        Word phase = depth[x] % period;
        char label = char('0' + (x & 1));
        if (first[phase] == unseen) { labels[phase] = label; first[phase] = x; }
        if (labels[phase] != label && conflict_a == unseen) { conflict_a = first[phase]; conflict_b = x; }
    }
    require(labels.find('?') == std::string::npos, "missing cyclic class");
    bool variable = conflict_a != unseen;
    totals.sinks += exits == 0;
    totals.exterior_variable += !g.in_trap(root) && variable;
    totals.exterior_variable_sinks += !g.in_trap(root) && variable && !exits;
    std::cout << "SCC W=" << g.width << " min=" << root << " vertices=" << members.size()
              << " black=" << black << " trap=" << g.in_trap(root) << " period=" << period
              << " exit_edges=" << exits;
    if (exits) std::cout << " exit_witness=" << exit_from << ',' << exit_to;
    if (variable) std::cout << " gate=variable same_phase=" << conflict_a << ',' << conflict_b;
    else std::cout << " gate=" << primitive_word(labels);
    std::cout << '\n';
}

// Iterative Tarjan DFS. Finished SCCs are classified in sink-first order.
// Discovery indices of already popped nodes are reused for the per-SCC BFS.
static Summary classify_core(const Graph &g, const Flags &core, std::ostream *cert) {
    struct Frame { Word node; unsigned next_input; };
    std::vector<Word> index(g.size, unseen), low(g.size), component(g.size, unseen), active, members;
    std::vector<Frame> dfs;
    Word serial = 0;
    Summary totals;
    auto enter = [&](Word x) {
        index[x] = low[x] = serial++;
        active.push_back(x);
        dfs.push_back({x, 0});
    };
    for (Word start = 0; start < g.size; ++start) {
        if (!core[start] || component[start] != unseen) continue;
        enter(start);
        while (!dfs.empty()) {
            Word x = dfs.back().node;
            if (dfs.back().next_input < 4) {
                Word v = g.next(x, dfs.back().next_input++);
                require(core[v], "global eventual image is not forward closed");
                if (component[v] != unseen) continue;
                if (index[v] == unseen) enter(v);
                else low[x] = std::min(low[x], index[v]);
                continue;
            }
            if (low[x] == index[x]) {
                members.clear();
                do {
                    Word v = active.back();
                    active.pop_back();
                    component[v] = totals.components;
                    members.push_back(v);
                } while (members.back() != x);
                ++totals.components;
                classify(g, members, component, index, totals, cert);
            }
            dfs.pop_back();
            if (!dfs.empty()) {
                Word parent = dfs.back().node;
                low[parent] = std::min(low[parent], low[x]);
            }
        }
    }
    return totals;
}

static void run(const Flags &trap, unsigned w, std::ostream *cert) {
    const Graph g{w, Word(1)<<w, trap, true};
    if (cert) { *cert << "K50SCC1\n"; write_word(*cert, w); }
    Flags core = eventual_image(g, false);
    controls(g, core);
    Word core_size = 0, trap_in_core = 0, trap_local_size = 0, trap_local_black = 0;
    {
        auto local = eventual_image(g, true);
        for (Word x = 0; x < g.size; ++x) {
            core_size += core[x];
            trap_in_core += core[x] && g.in_trap(x);
            trap_local_size += local[x];
            trap_local_black += local[x] && (x & 1);
            require(!local[x] || core[x], "trap eventual image outside global core");
        }
        if (!(w%2)) {
            const Graph successive{w, g.size, trap, false};
            auto pq = eventual_image(successive, true);
            Word pq_black = 0;
            for (Word x = 0; x < g.size; ++x) {
                require(!local[x] || pq[x], "xx trapped core outside pq trapped core");
                pq_black += pq[x] && (x & 1);
            }
            const std::array<Word,5> k47{173,460,1180,2979,7662};
            require(pq_black == k47[(w-16)/2], "K47 successive-input trapped black count differs");
        }
    }
    const Summary s = classify_core(g, core, cert);
    require(core_size-s.cycle_vertices == s.components-s.cyclic, "noncyclic SCC accounting failed");
    std::cout << "SUMMARY W=" << w << " windows=" << g.size << " core=" << core_size
              << " core_in_trap=" << trap_in_core << " trap_only_core=" << trap_local_size
              << " trap_only_black=" << trap_local_black << " core_SCCs=" << s.components
              << " cyclic_SCCs=" << s.cyclic << " sinks=" << s.sinks << " cycle_vertices=" << s.cycle_vertices
              << " trap_cycle_vertices=" << s.trap_cycle_vertices
              << " core_noncyclic_vertices=" << core_size-s.cycle_vertices
              << " exterior_variable_SCCs=" << s.exterior_variable
              << " exterior_variable_sinks=" << s.exterior_variable_sinks << std::endl;
}

int main(int argc, char **argv) {
    try {
        require(argc == 2 || argc == 4 || argc == 5, "usage: windows GateTrap.lean [first last [certificate]]");
        int first = argc >= 4 ? std::stoi(argv[2]) : 16;
        int last = argc >= 4 ? std::stoi(argv[3]) : 24;
        require(16 <= first && first <= last && last <= 24, "supported widths are 16 to 24");
        const auto trap = trap_table(argv[1]);
        std::ofstream certificate;
        if (argc == 5) {
            require(first == last, "specify one width per certificate");
            certificate.open(argv[4], std::ios::binary);
            require(certificate.good(), "cannot create certificate");
        }
        for (int w = first; w <= last; ++w) run(trap, w, argc == 5 ? &certificate : nullptr);
        if (argc == 5) {
            certificate.close();
            require(!certificate.fail(), "failed to finish certificate");
        }
        std::cout << "CONTROLS PASS\n";
    } catch (const std::exception &e) {
        std::cerr << "FAIL " << e.what() << '\n';
        return 1;
    }
}
