#!/usr/bin/env python3
"""claudeM5_r5_picture.py: pull R5 (ledger M134). The last 1,500 ticks before five cuts of the 001 ether enter the kit's
trap t001, as exact data.

Each panel is one cut: time runs left to right and ends at the tick of entry; column 1 (beside the drive) is at the
bottom and column 47 at the top. A cell is light when it agrees with the trunk, the 21-tick pattern of t001's first 38
columns counted back from the label at entry, and dark when it does not; columns 39 to 47 have no pattern and are grey.

  python3 claudeM5_r5_picture.py OUT.svg"""
import base64, pathlib, struct, sys, zlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f

TICKS, COLS, PX = 1500, 47, 4
CUTS = [(0, 0, 144), (1, 0, 33), (0, 0, 66), (1, 0, 120), (0, 0, 231)]
BG, AGREE, DIFF, NONE = (252, 252, 250), (226, 234, 243), (20, 60, 110), (205, 205, 200)


def png(width, height, rows):
    raw = b''.join(b'\0' + bytes(r) for r in rows)
    def chunk(t, d):
        c = t + d
        return struct.pack('>I', len(d)) + c + struct.pack('>I', zlib.crc32(c))
    pal = b''.join(bytes(c) for c in (AGREE, DIFF, NONE))
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 3, 0, 0, 0)) + \
        chunk(b'PLTE', pal) + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')


def history(j0, s, N, T, P, K):
    """rows of a cut to its entry; returns (entry tick, label, the last TICKS rows as ints)"""
    where = {(st, l % 3): l for st, l in zip(T['st'], T['lab'])}
    row = 0
    for p in range(1, N + 1):
        row |= f.ETHER[(j0 + p) % 12][s % 3] << (p - 1)
    keep, t = [], 0
    while True:
        keep.append(row & ((1 << COLS) - 1))
        if len(keep) > TICKS:
            keep.pop(0)
        l = where.get((row & ((1 << 47) - 1), (t + s) % 3))
        if l is not None:
            return t, l, keep
        full = (row << 1) | f.DRIVE[(t + s) % 3]
        row = ((full << 1) ^ (full | (full >> 1))) >> 1
        t += 1


def main(out):
    T = f.load('t001')
    P, K = f.pattern(T)
    left, top, gap, ph = 64, 96, 34, COLS * PX
    W, H = left + TICKS + 110, top + len(CUTS) * (ph + gap) + 46
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d" font-family="system-ui, sans-serif">' % (W, H, W, H),
           '<rect width="%d" height="%d" fill="rgb%s"/>' % (W, H, BG),
           '<text x="%d" y="34" font-size="22" fill="#1b1b1b" font-weight="600">Five cuts of the 001 ether climbing into the same trap</text>' % left,
           '<text x="%d" y="60" font-size="14" fill="#555">Last 1,500 ticks before entry into t001. Column 1 is at the bottom. Light: agrees with the trap’s 21-tick pattern. Dark: differs. Grey: columns 39 to 47, which have no pattern.</text>' % left]
    for i, (j0, s, N) in enumerate(CUTS):
        te, lab, keep = history(j0, s, N, T, P, K)
        n = len(keep)
        rows = []
        for c in range(COLS, 0, -1):
            line = [2] * (TICKS - n)
            for k, r in enumerate(keep):
                l = (lab - (n - 1 - k)) % T['m']
                line.append(2 if c > K else int(((r >> (c - 1)) & 1) != P[l][c]))
            rows += [line] * PX
        y = top + i * (ph + gap)
        data = base64.b64encode(png(TICKS, ph, rows)).decode()
        svg.append('<text x="%d" y="%d" font-size="13" fill="#333">cut of %d columns, class (%d, %d): entered at tick %s</text>' % (left, y - 7, N, j0, s, format(te, ',')))
        svg.append('<image x="%d" y="%d" width="%d" height="%d" image-rendering="pixelated" href="data:image/png;base64,%s"/>' % (left, y, TICKS, ph, data))
        for c, name in ((14, '14'), (17, '17'), (22, '22'), (34, '34'), (38, '38')):
            yy = y + (COLS - c) * PX
            svg.append('<line x1="%d" x2="%d" y1="%d" y2="%d" stroke="#8a8a85" stroke-width="1"/>' % (left - 6, left, yy, yy))
            svg.append('<text x="%d" y="%d" font-size="11" fill="#555" text-anchor="end">%s</text>' % (left - 9, yy + 4, name))
    y = top + len(CUTS) * (ph + gap) - gap + 20
    for k in range(0, TICKS + 1, 300):
        x = left + TICKS - k
        svg.append('<line x1="%d" x2="%d" y1="%d" y2="%d" stroke="#8a8a85"/>' % (x, x, y - 18, y - 12))
        svg.append('<text x="%d" y="%d" font-size="12" fill="#555" text-anchor="middle">%s</text>' % (x, y + 2, 'entry' if k == 0 else '−%d' % k))
    svg.append('</svg>')
    pathlib.Path(out).write_text('\n'.join(svg))
    print(out, W, H, sum(map(len, svg)))


if __name__ == '__main__':
    main(sys.argv[1])
