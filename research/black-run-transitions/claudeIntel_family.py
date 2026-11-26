# claudeIntel, carrying read of I259: the kit's rules (as stated in Rule30RunTransitions' docstring) and the pair rule, phase by phase,
# on the cyclic words of runs (16,4,9,1,4,9) + 9^n, one white after each run.  My own reading of the rules, no shared code.
AGE = {1: 8, 2: 8, 3: 8, 4: 15, 5: 8, 6: 16, 7: 4, 8: 14}
def ones(n): return '1' * n
def word(runs): return ''.join(ones(r) + '0' for r in runs)
def before(w, j, L):                      # the L cyclic letters before phase j
    n = len(w); return ''.join(w[(j - L + k) % n] for k in range(L))
def ends(w, j, v): return before(w, j, len(v)) == v
def kit_good(w, j, rmax):
    if any(ends(w, j, v) for v in (ones(9), ones(4) + '0' + ones(7), ones(8) + '0' + ones(2))): return True
    for r in range(0, rmax + 1):
        if r % 2 == 1:
            for p in (ones(8) + '0', ones(4) + '0' + ones(2) + '0', ones(4) + '0' + ones(6) + '0', ones(8) + '0' + ones(4) + '0'):
                if ends(w, j, p + ones(r)): return True
        if r % 2 == 0 and ends(w, j, ones(8) + '010' + ones(r)): return True
    return False
def pair_good(w, j): return any(ends(w, j, ones(AGE[r]) + '0' + ones(r)) for r in AGE)
def primitive(w): return all(w != w[k:] + w[:k] for k in range(1, len(w)) if len(w) % k == 0)
for n in range(0, 41):
    w = word([16, 4, 9, 1, 4, 9] + [9] * n)
    whites = [j for j in range(len(w)) if w[j] == '0']
    k = [kit_good(w, j, len(w)) for j in whites]; p = [pair_good(w, j) for j in whites]
    comb = all(a or b for a, b in zip(k, p))
    kfail = [j for j, a in zip(whites, k) if not a]; pfail = [j for j, b in zip(whites, p) if not b and not kit_good(w, j, len(w))]
    paironly_fail = [j for j, b in zip(whites, p) if not b]
    if n < 3 or n % 10 == 0:
        print('n=%d len=%d combined=%s kit fails at %s pair fails at %s primitive=%s' % (n, len(w), comb, kfail, paironly_fail[:4], primitive(w)))
    assert comb and kfail == [21] and 38 in paironly_fail and primitive(w)
print('all 41 members: combined covers, kit alone fails only at phase 21, pair alone fails at 38, primitive')
