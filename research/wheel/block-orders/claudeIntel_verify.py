# claudeIntel, N19: independent replay.  Each line "ORDER COST ROW": with every cell east of ROW unknown (None), the literal Rule 30 table must read the order
# and the next 1001 beside the alternating wall, white first.   usage: verify.py FILE [A-run B-run]
import sys
ra, rb = (int(sys.argv[2]), int(sys.argv[3])) if len(sys.argv) > 3 else (3, 5)
TAB = {(l, c, r): int('00011110'[7-(l*4+c*2+r)]) for l in (0, 1) for c in (0, 1) for r in (0, 1)}      # rule number 30: 111->0 ... 000->0, in order 111..000
blk = {'A': '100'+'10000'*ra, 'B': '100'+'10000'*rb}
def target(o): return ''.join(blk[c] for c in o)+'1001'
def reads(row, n):
    # three-valued: None beyond the row; a value is used only if both fillings agree
    x = [int(c) for c in row]; out = [x[0]]
    for s in range(1, n):
        for wall in (0, 1):
            y = []
            for p in range(len(x)):
                l = wall if p == 0 else x[p-1]; c = x[p]
                if p+1 < len(x): y.append(TAB[l, c, x[p+1]])
                else:
                    a, b = TAB[l, c, 0], TAB[l, c, 1]
                    if a == b: y.append(a)
                    else: break
            x = y
        out.append(x[0])
    return ''.join(map(str, out))
if __name__ == '__main__':
    seen = {}; bad = 0
    for ln in open(sys.argv[1]):
        o, _, row = ln.split(); t = target(o)
        if reads(row, len(t)) != t: bad += 1; print('BAD', o)
        else: seen.setdefault(len(o), set()).add(o)
    print({k: (len(v), 2**k) for k, v in sorted(seen.items())}, 'bad', bad)
