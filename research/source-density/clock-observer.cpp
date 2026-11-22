// Read one byte per frame: low two bits encode 00,01,10,11 on the
// observed bond (00=0,01=1,10=2,11=3); bit two is the hidden target for QA.
// The acceptance decision reads only the ternary recoding of the low bits.
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>
using namespace std;
constexpr unsigned states = 1u << 12, mask = states - 1;
struct Reader {
  array<array<array<unsigned, 2>, states>, 2> next{};
  Reader() {
    for (unsigned e : {0u, 1u})
      for (unsigned s = 0; s < states; s++)
        for (unsigned ghost : {0u, 1u})
          next[e][s][ghost] =
              (((s << 1) | e) ^ (s | (s >> 1) | (ghost << 11))) & mask;
  }
  bool test(const vector<unsigned> &code, size_t t, unsigned phase) {
    for (unsigned k = 0; k < 28; k++) {
      bool r = code[t + k] == 1, rn = code[t + k + 1] == 1;
      if (!r && (rn != (code[t + k] == 2) || (phase + k) % 3 == 2))
        return false;
    }
    vector<unsigned> current(states), after;
    for (unsigned s = 0; s < states; s++)
      current[s] = s;
    for (unsigned k = 0; k < 28; k++) {
      bool e = (phase + k) % 3 == 2, en = (phase + k + 1) % 3 == 2,
           r = code[t + k] == 1;
      array<bool, states> visited{};
      after.clear();
      for (unsigned s : current) {
        if ((r ^ (e | bool(s & 1))) != en)
          continue;
        for (unsigned n : next[e][s])
          if (!visited[n]) {
            visited[n] = true;
            after.push_back(n);
          }
      }
      if (after.empty())
        return false;
      current.swap(after);
    }
    return true;
  }
};
int main(int argc, char **argv) {
  if (argc != 2)
    return 2;
  ifstream in(argv[1], ios::binary);
  if (!in)
    return 3;
  vector<unsigned char> bytes((istreambuf_iterator<char>(in)), {});
  if (bytes.size() < 31)
    return 4;
  Reader reader;
  vector<unsigned> code, phase(bytes.size());
  for (auto b : bytes)
    code.push_back((b & 1) ? 1 : (b & 2));
  size_t rejected = 0, defects = 0, local = 0, accepts = 0, exact = 0,
         acceptedDefects = 0, rejectedPure = 0;
  for (size_t s = 0; s + 28 < bytes.size(); s++) {
    for (unsigned p = 0; p < 3; p++)
      if (reader.test(code, s, p))
        phase[s] |= 1u << p;
  }
  for (size_t s = 0; s + 30 < bytes.size(); s++) {
    bool ok = false;
    for (unsigned p = 0; p < 3; p++)
      if ((phase[s] & (1u << p)) && (phase[s + 1] & (1u << ((p + 1) % 3))) &&
          (phase[s + 2] & (1u << ((p + 2) % 3))))
        ok = true;
    bool pure = true;
    for (unsigned i = 0; i <= 28; i++) {
      bool bad = (bool(bytes[s + i] & 4) + bool(bytes[s + i + 1] & 4) +
                      bool(bytes[s + i + 2] & 4) !=
                  1);
      if (i == 23) {
        local += bad;
        acceptedDefects += bad && ok;
      }
      pure &= !bad;
    }
    if (ok && accepts < 8)
      cout << "accepted at " << s << "\n";
    accepts += ok;
    rejected += !ok;
    exact += pure;
    rejectedPure += !ok && pure;
  }
  for (size_t t = 0; t + 2 < bytes.size(); t++)
    defects +=
        bool(bytes[t] & 4) + bool(bytes[t + 1] & 4) + bool(bytes[t + 2] & 4) !=
        1;
  cout << "frames " << bytes.size() << ", rejected " << rejected
       << ", accepted " << accepts << ", clean full windows " << exact
       << ", interior bad triples " << local << ", all bad triples " << defects
       << ", accepted with interior defect " << acceptedDefects
       << ", rejected pure " << rejectedPure << "\n";
  return acceptedDefects || rejectedPure || local > rejected ||
         rejected > 29 * defects;
}
