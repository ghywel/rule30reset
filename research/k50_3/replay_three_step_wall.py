"""Reconstruct the three-tick band tables and the four-tick upper certificate."""
from functools import cache
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
STAGES = ((14, 13), (18, 20), (23, 22), (27, 26), (31, 29))


def reverse_bits(word, width):
    return int(f"{word:0{width}b}"[::-1], 2)


def forward(word, width):
    return ((word << 2) ^ ((word << 1) | word)) & ((1 << width) - 1)


def lift_cover(prefixes, old_width, new_width, depth, ticks):
    """Allow every continuation of an edge-first prefix and every reached wall bit."""
    states = {
        d: {p | (tail << old_width) for p in prefixes for tail in range(1 << (d - old_width))}
        for d in range(min(depth, new_width), new_width + 1)
    }
    for _ in range(ticks):
        successors = {}
        for d, words in states.items():
            next_depth = min(d + 1, new_width)
            dest = successors.setdefault(next_depth, set())
            dest.update(forward(word, next_depth) for word in words)
            if d < new_width:
                dest.update(forward(word | (1 << d), next_depth) for word in words)
        states = successors
    return set().union(*states.values())


def inverse_tick(state, pixel, ticks):
    result = 0
    for layer in range(ticks):
        pair = (state >> (2 * layer)) & 3
        current = pair & 1
        new_pair = (current << 1) | (pixel ^ (pair != 0))
        result |= new_pair << (2 * layer)
        pixel = current
    return result


def edge_test(ticks):
    """At edge+ticks the oldest row must start black, then finish in the zero state."""
    full = frozenset(range(1 << (2 * ticks)))
    transitions = tuple(
        tuple(inverse_tick(state, bit, ticks) for state in range(len(full))) for bit in (0, 1)
    )
    oldest = 1 << (2 * (ticks - 1))

    @cache
    def update(states, bit):
        return frozenset(transitions[bit][state] for state in states)

    @cache
    def finishes(state, suffix):
        if not state & oldest:
            return False
        for p in range(ticks, -1, -1):
            state = transitions[(suffix >> p) & 1][state]
            if state & oldest:
                return False
        return state == 0

    def check(word, width):
        states = full
        for p in range(width - 2, ticks, -1):
            states = update(states, (word >> p) & 1)
        suffix = word & ((1 << (ticks + 1)) - 1)
        return all(finishes(state, suffix) for state in states)

    return check


def reconstruct_tables():
    source = (HERE / "three-step-extension.lean").read_text(encoding="utf-8")
    sets = {
        int(w): {reverse_bits(int(v), int(w)) for v in nums.split(",")}
        for w, nums in re.findall(r"private def cover(\d+) : List Nat := \[([\d,\s]+)\]", source)
    }
    assert sets[13] == {reverse_bits(v, 13) for v in (6411, 6428, 7117, 7129)}
    for (t, old), (u, new) in zip(STAGES, STAGES[1:]):
        actual = lift_cover(sets[old], old, new, t + 2, u - t)
        assert sets[new] == actual, (u, new, len(actual))
        print(f"Age {u}, width {new}: {len(actual)} words match the Lean table.")
    return sets[29]


def sharp_witnesses():
    def at(code, p):
        return (code >> -p) & 1

    def rule(left, center, right):
        return left ^ (center | right)

    for depth, age, wall in ((2, 30, 0x192FD993), (1, 31, 0x325FB326)):
        row = [1] * depth
        for t in range(age):
            tape = [0, 0, *row, (wall >> t) & 1]
            row = [rule(*tape[j:j+3]) for j in range(len(row) + 1)]
        image = lambda p: row[p + 32] if -32 <= p < 0 else 0
        a = lambda p: at(3732015686, p)
        b = lambda p: at(1402727289, p)
        c = lambda p: 1 if p <= -32 else at(1557213517, p)
        assert all(image(p) == at(6741236716, p) for p in range(-34, 0))
        for j, (before, after) in enumerate(((a, image), (b, a), (c, b)), 1):
            assert before(0) == (wall >> (age - j)) & 1
            assert all(rule(before(p-1), before(p), before(p+1)) == after(p)
                       for p in range(-36, 0))
        assert c(-33) == 1
        print(f"Age {age}, depth {depth}: three physical inverse rows with prescribed wall bits.")


def four_tick_cover(words):
    closes = edge_test(4)
    for age in range(31, 81):
        width = age - 2
        failures = sum(not closes(word, width) for word in words)
        print(f"Four ticks at age {age}, width {width}: {len(words)} words, {failures} fail.")
        if not failures:
            assert (age, width, len(words)) == (76, 74, 5539)
            return
        words = {forward(word | (bit << width), width + 1) for word in words for bit in (0, 1)}
    raise AssertionError("No uniform four-tick bound within the tested ages")


if __name__ == "__main__":
    cover = reconstruct_tables()
    check3 = edge_test(3)
    assert all(check3(word, 29) for word in cover)
    sharp_witnesses()
    four_tick_cover(cover)
