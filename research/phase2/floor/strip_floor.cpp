// Bound the kick-anchored mass on the 22-cell free-edge right strip of I246.
// A real right half gives a path in this labelled graph. A path need not lift.
// The antidiagonal calculation is M6's extend on the white-tick wall trace.
#include <algorithm>
#include <array>
#include <cstdint>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

using Row = uint32_t;
using Limb = uint64_t;
using Diagonal = std::array<Limb, 5>;
using Set = std::vector<Row>;

Diagonal extend(const Diagonal& last, const Diagonal& previous, int t, bool bit) {
    Diagonal out{};
    Limb parity = 0, previous_shift = 0, prefix_shift = 0;
    for (int k = 0; k <= t / 64; ++k) {
        Limb prefix = last[k] | ((previous[k] << 1) | previous_shift);
        previous_shift = previous[k] >> 63;
        for (int shift = 1; shift <= 32; shift *= 2) prefix ^= prefix << shift;
        prefix ^= Limb(0) - parity;
        parity = prefix >> 63;
        out[k] = ((prefix << 1) | prefix_shift) ^ (Limb(0) - bit);
        prefix_shift = parity;
    }
    out[t / 64] &= ~Limb(0) >> (63 - t % 64);
    return out;
}

int last_bit(const Diagonal& d, int t) { return (d[t/64] >> (t%64)) & 1; }
Row step(Row r, Row wall) { return ((r << 1) | wall) ^ (r | (r >> 1)); }

struct Search {
    Row mask;
    int horizon, budget;
    std::vector<std::array<Row,4>> edges;
    std::map<Set,int> states;
    std::vector<const Set*> sets;
    std::vector<std::array<int,2>> transitions;
    std::vector<int> best;
    std::vector<std::string> witness;
    std::vector<Limb> visited;
    std::string path;

    Search(int width, int H, int B) : mask((Row(1) << width) - 1),
            horizon(H), budget(B), edges(mask + 1), best(H/2 + 1, B + 1),
            witness(H/2 + 1), visited(H/2 + 1) {
        for (Row r = 0; r <= mask; ++r)
            for (Row ext = 0; ext < 4; ++ext)
                edges[r][ext] = step(step(r | (ext << width), 0), 1) & mask;
        std::vector<bool> appears(mask + 1);
        for (Row r = 0; r <= (mask << 1 | 1); ++r) appears[step(r,1) & mask] = true;
        Set initial;
        for (Row r = 0; r <= mask; ++r) if (appears[r]) initial.push_back(r);
        intern(std::move(initial));
    }

    int intern(Set s) {
        const int id = states.size();
        auto [it, fresh] = states.try_emplace(std::move(s), id);
        if (fresh) {
            sets.push_back(&it->first);
            transitions.push_back({-2,-2});
        }
        return it->second;
    }

    int child(int id, Row gate) {
        if (transitions[id][gate] == -2) {
            Set s;
            for (Row r : *sets[id]) if ((r & 1) == gate)
                s.insert(s.end(), edges[r].begin(), edges[r].end());
            std::sort(s.begin(), s.end());
            s.erase(std::unique(s.begin(), s.end()), s.end());
            int next = s.empty() ? -1 : intern(std::move(s));
            transitions[id][gate] = next;
        }
        return transitions[id][gate];
    }

    void visit(int state, int ticks, const Diagonal& last, const Diagonal& previous, int weight) {
        if (ticks == horizon) return;
        for (Row gate = ticks == 0 ? 1 : 0; gate < 2; ++gate) {
            const int next = child(state, gate);
            if (next < 0) continue;
            const auto white = extend(last, previous, ticks, !gate);
            const auto black = extend(white, last, ticks + 1, true);
            const int mass = weight + last_bit(white,ticks) + last_bit(black,ticks+1);
            if (mass > budget) continue;
            const int m = ticks / 2 + 1;
            ++visited[m];
            path.push_back('0' + gate);
            if (mass < best[m]) {
                best[m] = mass;
                witness[m] = path;
            }
            visit(next,ticks + 2,black,white,mass);
            path.pop_back();
        }
    }
};

int main(int argc, char** argv) {
    if (argc != 4) throw std::invalid_argument("usage: strip_floor WIDTH EVEN_H BUDGET");
    const int width = std::stoi(argv[1]), H = std::stoi(argv[2]), B = std::stoi(argv[3]);
    if (width < 1 || width > 24 || H < 2 || H > 320 || H % 2 || B < 0)
        throw std::invalid_argument("invalid width, even horizon or budget");
    Search search(width,H,B);
    search.visit(0,0,{},{},0);
    std::cout << "# width " << width << " H " << H << " budget " << B << " DFA subsets "
              << search.states.size() << "\n# H lower_bound affordable_prefixes first_strip_witness\n";
    for (int m = 1; m <= H/2; ++m)
        std::cout << 2*m << ' ' << search.best[m] << ' ' << search.visited[m] << ' '
                  << (search.witness[m].empty() ? "-" : search.witness[m]) << '\n';
}
