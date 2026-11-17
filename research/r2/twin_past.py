"""R2: exact four-step inversion beside the white wall. Run with standard Python 3."""

C20 = (820683, 822904, 911005, 912610)  # Rule30LateTwins.inC20


def step(row):
    return (row >> 1) ^ (row | (row << 1))


def edge_step(word):
    return (word >> 2) ^ ((word >> 1) | word)


def iterate(f, value, ticks):
    for _ in range(ticks):
        value = f(value)
    return value


def scan(symbol, state, layers):
    """Each pair holds the previous and current predecessor bits at the same cut."""
    after = 0
    for layer in range(layers):
        pair = (state >> (2 * layer)) & 3
        current = pair & 1
        following = symbol ^ int(pair != 0)
        after |= ((2 * current) | following) << (2 * layer)
        symbol = current
    return after


def residuals(word, width, layers):
    states = set(range(4 ** layers))
    for i in range(width):
        symbol = (word >> i) & 1
        states = {scan(symbol, state, layers) for state in states}
    return states


def edge_certificate():
    assert all(residuals(word, 20, 2) == {0} for word in C20)
    phase_counts = [len(residuals(word, 20, 4) - {0}) for word in C20]
    print("C20 nonzero residual counts (kit order):", phase_counts)
    if not any(phase_counts):
        return 26, 20, sorted(C20)

    # Top b bits evolve autonomously. At age >= max(26,b-1) all b bits exist.
    for width in (24, 28, 32):
        extra = width - 20
        ticks = 46 - max(26, width - 1)
        words = {iterate(edge_step, (p << extra) | tail, ticks)
                 for p in C20 for tail in range(1 << extra)}
        bad = [w for w in words if residuals(w, width, 4) != {0}]
        print("age 46 fixed band", width, "words", len(words), "unclosed", len(bad))
        if not bad:
            return 46, width, sorted(words)

    words = set(C20)
    for age in range(27, 107):
        width = 20 + age - 26
        words = {edge_step(2 * p + bit) for p in words for bit in (0, 1)}
        if len(words) > 4096:
            break
        if all(residuals(w, width, 4) == {0} for w in words):
            return age, width, sorted(words)
    return None


def inverse_rows(row):
    """Enumerate all finite parents; a nonzero finite parent gains one bit per tick."""
    assert row > 0
    for head in (0, 1):
        parent = head
        prev, cur = 0, head
        for i in range(row.bit_length() - 1):
            following = ((row >> i) & 1) ^ (cur | prev)
            parent |= following << (i + 1)
            prev, cur = cur, following
        if step(parent) == row:
            yield parent


def odd_grandparents(row):
    return sorted(pre for mid in inverse_rows(row) for pre in inverse_rows(mid) if pre & 1)


def finite_replay():
    # Independent exhaustive forward comparison for all nonzero roots below 2^10.
    buckets = {}
    for p in range(1, 1 << 9):
        buckets.setdefault(step(p), set()).add(p)
    for z in range(1, 1 << 10):
        assert set(inverse_rows(z)) == buckets.get(z, set())

    examined = 0
    for pattern in range(64):
        seed = 0
        for t in range(47):
            want = 1 if t % 2 == 0 else (pattern >> ((t // 2) % 6)) & 1
            if (iterate(step, seed, t) & 1) != want:
                seed |= 1 << t
        for extension in (0, 1, 2, 3):
            start = seed | (extension << 47)
            actual = [start]
            for _ in range(46):
                actual.append(step(actual[-1]))
            assert all(x & 1 for x in actual[::2])
            parents = odd_grandparents(actual[-1])
            twins = [x for x in parents if x != actual[-3]]
            assert actual[-3] in parents and twins
            examined += 1
            if all(not odd_grandparents(x) for x in twins):
                print("physical counterexample seed, t, parents:", start, 46, parents)
                return
    print("physical age-46 surviving cases with a surviving twin grandparent:", examined)


def stripe_prefix(width):
    return sum(1 << i for i in range(0, width, 2))


def psi(row, level, inverse=False):
    """Conjugacy on finite inputs, excluding the exceptional inverse at the planted row."""
    out = 0
    match = True
    for i in range(row.bit_length() + 3):
        stripe = int(i % 2 == 0)
        bit = (row >> i) & 1
        transformed = bit ^ int(match and stripe and i >= 2 * level)
        out |= transformed << i
        match = match and (transformed if inverse else bit) == stripe
    assert not match
    return out


def planted_control():
    for level in (2, 3, 4):
        plant = stripe_prefix(2 * level - 1)

        def planted_step(y):
            if y == plant:  # inverse is the infinite fixed stripe; T_fixed
                return plant
            pre = psi(y, level, inverse=True)
            assert psi(pre, level) == y
            return psi(step(pre), level)

        parents = [p for p in range(1 << 10) if p & 1 and iterate(planted_step, p, 2) == plant]
        assert parents == [plant]
        print("planted control L, fixed row, odd double-step parents below 1024:", level, plant, parents)


if __name__ == "__main__":
    print("four-step edge certificate (sufficient age, width, words):", edge_certificate())
    finite_replay()
    planted_control()
