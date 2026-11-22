#!/usr/bin/env python3
"""claudeCloud_k50_4_picture.py: pull K50.4 (ledger K62). Two pictures of white triangles with their family trees.

Same definitions as claudeCloud_k50_4_cascade.cpp, written again in Python: the cascade by the four-state register,
the window of a maximal black run j rows up (the run, the white cell after it, j cells either side), and the PATCH,
the longest prefix of that window that is a factor of a stage-(j + 1) row of the cascade.

Colour is one blue ramp, light to dark with the number of rows up (an ordered quantity: one hue). A black cell of
a patch takes the step's colour, a white cell of a patch a pale tint of it. The run itself is the darkest step.
The triangle under the run is a warm tint. Cells of a window outside its patch (the defect) are hatched grey.

    python3 claudeCloud_k50_4_picture.py OUT_OVERVIEW.png OUT_ZOOM.png
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

RAMP = ['#b7d3f6', '#9ec5f4', '#86b6ef', '#6da7ec', '#5598e7', '#3987e5', '#2a78d6', '#256abf', '#1c5cab', '#184f95',
        '#104281', '#0d366b']                       # rows up 12 (lightest) .. 1 (darkest); reversed below
SURFACE, INK, INK2, MUTED = '#fcfcfb', '#0b0b0b', '#52514e', '#898781'
RUNCOL, TRI = '#0d366b', '#fbe6c4'
K = 12


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def tint(h, a):                                      # towards the surface
    c, s = rgb(h), rgb(SURFACE)
    return tuple(int(round(s[i] + (c[i] - s[i]) * a)) for i in range(3))


def diagram(rows):
    W = 2 * rows + 1 + 64
    g = np.zeros((rows, W), dtype=np.uint8); off = rows + 32
    g[0, off] = 1
    for t in range(1, rows):
        p = g[t - 1]
        g[t, 1:-1] = p[:-2] ^ (p[1:-1] | p[2:])
    return g, off


def adv(s, a):
    bx, bx1 = s & 1, s >> 1
    return (a ^ (bx | bx1)) | (bx << 1)


def cascade(stages):
    T = {1: [[1]]}
    for k in range(1, stages):
        nxt = []
        for u in T[k]:
            p = len(u); f = []
            for s in range(4):
                st = s
                for x in range(p - 1, -1, -1):
                    st = adv(st, u[x])
                f.append(st)
            cyc = [s for s in range(4) if any(s == z for z in orbit(f, f[f[f[f[s]]]]))]
            seen = set()
            for s in cyc:
                if s in seen:
                    continue
                c, st = 0, s
                while True:
                    seen.add(st); st = f[st]; c += 1
                    if st == s:
                        break
                q = c * p; v = [0] * q; st = s
                for x in range(p - 1, p - 1 - q, -1):
                    v[x % q] = st & 1; st = adv(st, u[x % p])
                assert all(v[(x - 1) % q] ^ (v[x] | v[(x + 1) % q]) == u[x % p] for x in range(q))
                nxt.append(v)
        T[k + 1] = nxt
    return T


def orbit(f, s):
    out = []
    for _ in range(4):
        out.append(s); s = f[s]
    return out


def match(W, nodes):
    best = 0
    for u in nodes:
        p = len(u)
        for ph in range(p):
            k = 0
            while k < len(W) and W[k] == u[(ph + k) % p]:
                k += 1
            best = max(best, k)
    return best


def runs_in(g, off, t, minrun):
    row = g[t]; out = []; x = 0; n = len(row)
    while x < n:
        if row[x]:
            y = x
            while y + 1 < n and row[y + 1]:
                y += 1
            if y - x + 1 >= minrun:
                out.append((x, y))
            x = y + 1
        else:
            x += 1
    return out


def paint(g, off, T, tri_list, r0, r1, c0, c1, scale, grid):
    """tri_list: (t, a, b) in array columns. Returns an RGB image of rows r0..r1-1, array columns c0..c1-1."""
    H, Wd = r1 - r0, c1 - c0
    col = np.zeros((H, Wd, 3), dtype=np.uint8)
    base_b, base_w = rgb('#c3c2b7'), rgb(SURFACE)   # cells of no family: recessive grey and the surface
    col[:] = base_w
    col[g[r0:r1, c0:c1] == 1] = base_b
    hatch = np.zeros((H, Wd), dtype=bool)
    ramp = RAMP[::-1]                                # index j - 1: rows up 1 darkest .. 12 lightest
    for (t, a, b) in sorted(tri_list, key=lambda z: z[2] - z[1]):
        L = b - a + 1
        # the triangle under the run
        lo, hi, tt = a + 1, b, t + 1
        while tt < g.shape[0] and lo <= hi and not g[tt, lo:hi + 1].any():
            if r0 <= tt < r1:
                for x in range(max(lo, c0), min(hi, c1 - 1) + 1):
                    col[tt - r0, x - c0] = rgb(TRI)
            lo += 1; hi -= 1; tt += 1
        # the run
        if r0 <= t < r1:
            for x in range(max(a, c0), min(b, c1 - 1) + 1):
                col[t - r0, x - c0] = rgb(RUNCOL)
        # the family tree
        for j in range(1, K + 1):
            tr = t - j
            if tr < 0:
                break
            W = [int(v) for v in g[tr, a - j:b + 2 + j]]
            m = match(W, T[j + 1])
            if not (r0 <= tr < r1):
                continue
            for q in range(len(W)):
                x = a - j + q
                if not (c0 <= x < c1):
                    continue
                if q < m:
                    col[tr - r0, x - c0] = rgb(ramp[j - 1]) if W[q] else tint(ramp[j - 1], 0.28)
                    hatch[tr - r0, x - c0] = False
                else:
                    hatch[tr - r0, x - c0] = True
    img = Image.fromarray(col, 'RGB').resize((Wd * scale, H * scale), Image.NEAREST)
    d = ImageDraw.Draw(img)
    if scale >= 6:
        ys, xs = np.nonzero(hatch)
        for y, x in zip(ys, xs):
            X, Y = x * scale, y * scale
            d.line([(X, Y + scale - 1), (X + scale - 1, Y)], fill=rgb(MUTED), width=1)
    if grid:
        for x in range(Wd + 1):
            d.line([(x * scale, 0), (x * scale, H * scale)], fill=rgb('#e6e5e0'), width=1)
        for y in range(H + 1):
            d.line([(0, y * scale), (Wd * scale, y * scale)], fill=rgb('#e6e5e0'), width=1)
    return img


def font(size, bold=False):
    for path in ('/usr/share/fonts/opentype/inter/Inter-%s.otf' % ('SemiBold' if bold else 'Regular'),
                 '/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf' % ('-Bold' if bold else '')):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            pass
    return ImageFont.load_default()


def legend(d, x, y, f, with_hatch):
    ramp = RAMP[::-1]
    d.text((x, y), 'rows above the run', font=f, fill=rgb(INK2)); y += 26
    for j in range(1, K + 1):
        d.rectangle([x + (j - 1) * 34, y, x + (j - 1) * 34 + 30, y + 18], fill=rgb(ramp[j - 1]))
        d.text((x + (j - 1) * 34 + 15, y + 22), str(j), font=f, fill=rgb(INK2), anchor='ma')
    y += 54
    items = [(RUNCOL, 'the black run'), (TRI, 'its white triangle'), ('#c3c2b7', 'black cells of no family shown')]
    xx = x
    for c, label in items:
        d.rectangle([xx, y, xx + 18, y + 18], fill=rgb(c), outline=rgb('#e6e5e0'))
        d.text((xx + 26, y - 1), label, font=f, fill=rgb(INK2)); xx += 44 + int(d.textlength(label, font=f))
    if with_hatch:
        d.rectangle([xx, y, xx + 18, y + 18], fill=rgb(SURFACE), outline=rgb('#e6e5e0'))
        d.line([(xx, y + 18), (xx + 18, y)], fill=rgb(MUTED), width=1)
        d.text((xx + 26, y - 1), 'defect: in the window, outside the patch', font=f, fill=rgb(INK2))


def compose(img, title, sub, with_hatch):
    pad, top, bottom = 28, 96, 150
    out = Image.new('RGB', (img.width + 2 * pad, img.height + top + bottom), rgb(SURFACE))
    out.paste(img, (pad, top))
    d = ImageDraw.Draw(out)
    d.text((pad, 22), title, font=font(26, True), fill=rgb(INK))
    d.text((pad, 60), sub, font=font(17), fill=rgb(INK2))
    legend(d, pad, top + img.height + 22, font(16), with_hatch)
    return out


def main():
    out1, out2 = sys.argv[1], sys.argv[2]
    T = cascade(K + 1)
    rows = 1200
    g, off = diagram(rows)
    # overview: the first 300 rows, every run of 8 or more cells
    R = 300
    tris = [(t, a, b) for t in range(K, R) for (a, b) in runs_in(g, off, t, 8)]
    n_over = len(tris)
    img = paint(g, off, T, tris, 0, R, off - R, off + R + 1, 3, False)
    compose(img, 'Rule 30 from one black cell: every white triangle of side 7 or more, with its family tree',
            'Rows 0 to %d. Above each black run, the patch of the backward cascade it comes from, one blue step per row.' % (R - 1),
            False).save(out1)
    # zoom: the longest run of the middle half in rows 200 to 1150
    best = None
    for t in range(200, 1150):
        for (a, b) in runs_in(g, off, t, 12):
            if abs(2 * (b - off)) <= t and (best is None or b - a > best[2] - best[1]):
                best = (t, a, b)
    t, a, b = best
    tris = [(tt, aa, bb) for tt in range(t - 14, t + 2) for (aa, bb) in runs_in(g, off, tt, 9) if (tt, aa, bb) == best]
    img = paint(g, off, T, tris, t - 13, t + 12, a - 16, b + 18, 22, True)
    compose(img, 'One triangle and its family tree: a black run of %d cells at row %d' % (b - a + 1, t),
            'Each row above is the run\'s window (two cells wider per row). Blue: the patch of the cascade. Hatched: the defect at the right end.',
            True).save(out2)
    print('overview: %d runs drawn; zoom: run of %d cells at row %d, positions %d to %d' % (n_over, b - a + 1, t, a - off, b - off))


if __name__ == '__main__':
    main()
