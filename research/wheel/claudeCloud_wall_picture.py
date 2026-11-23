#!/usr/bin/env python3
"""claudeCloud_wall_picture.py: two right halves beside the alternating column, drawn at the white ticks
(ledger K80; the picture of research/wheel/claudeCloud-wall.md, section 5).

Left: the finite right half with cells 1 and 2 black (seed 3 of K52's census). It reads the loop 25 twenty times and
enters the gate trap at tick 291. Right: the finite right half of support 148 that the solver found for T7: it keeps
Y's schedule for 200 samples, with seven excursions. In both, the first ten columns carry the loop and the rest of
the row is disordered.

    python3 claudeCloud_wall_picture.py KITFILE STAY.json OUT.png
"""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402

CELL, COLS = 6, 110
INK, PAPER, GUIDE, MARK, TEXT, MUTED = (28, 28, 30), (250, 249, 246), (190, 186, 178), (196, 62, 48), (28, 28, 30), (110, 108, 102)
STRIP = (252, 226, 170)


def samples_black_first(seed, n):
    """Rows at the white ticks 1, 3, ... of a finite seed (site 1 = bit 0), the wall black at even ticks."""
    r, out = seed, []
    for t in range(2 * n):
        x = (r << 1) | (1 if t % 2 == 0 else 0)
        r = x ^ ((x >> 1) | (x >> 2))
        if t % 2 == 0:
            out.append(r)
    return out


def samples_white_first(row_bits, n):
    """Rows at the samples 0, 1, ... of a row given at a sample (the solver's convention)."""
    x = sum(int(b) << i for i, b in enumerate(row_bits))
    out = []
    for s in range(n):
        out.append(x)
        for wall in (0, 1):
            r = (x << 1) | wall
            x = r ^ ((r >> 1) | (r >> 2))
    return out


def panel(img, draw, x0, y0, rows, title, lines, font, small, entry=None):
    draw.text((x0, y0 - 46), title, fill=TEXT, font=font)
    for i, line in enumerate(lines):
        draw.text((x0, y0 - 24 + 13 * i), line, fill=MUTED, font=small)
    h = len(rows) * CELL
    draw.rectangle([x0, y0, x0 + COLS * CELL, y0 + h], fill=PAPER)
    draw.rectangle([x0, y0, x0 + 10 * CELL - 1, y0 + h], fill=STRIP)          # the ten columns that carry the loop
    for s, r in enumerate(rows):
        for c in range(COLS):
            if (r >> c) & 1:
                draw.rectangle([x0 + c * CELL, y0 + s * CELL, x0 + (c + 1) * CELL - 1, y0 + (s + 1) * CELL - 1], fill=INK)
    gx = x0 + 10 * CELL
    draw.line([gx, y0, gx, y0 + h], fill=GUIDE, width=1)
    draw.text((x0, y0 + h + 4), 'columns 1 to 10 (tinted): the strip that carries the loop', fill=MUTED, font=small)
    if entry is not None:
        ey = y0 + entry * CELL
        draw.line([x0 - 8, ey, x0 + COLS * CELL, ey], fill=MARK, width=2)
        label = 'inside the trap from here'
        box = draw.textbbox((x0 + COLS * CELL - 160, ey + 6), label, font=small)
        draw.rectangle([box[0] - 4, box[1] - 3, box[2] + 4, box[3] + 3], fill=(255, 255, 255))
        draw.text((x0 + COLS * CELL - 160, ey + 6), label, fill=MARK, font=small)
    for s in range(0, len(rows) + 1, 50):
        draw.text((x0 - 30, y0 + s * CELL - 6), str(s), fill=MUTED, font=small)


def main():
    kit, stay, out = sys.argv[1], sys.argv[2], sys.argv[3]
    trap = set(int(c) for c in L.trap_codes(kit))
    a = samples_black_first(3, 160)
    entry = next(s for s, r in enumerate(a) if (r & 0xFFFF) in trap)
    d = json.loads(open(stay).read())
    b = samples_white_first(d['row'], d['samples'])
    assert all((r & 0xFFFF) not in trap for r in b)
    try:
        font = ImageFont.load_default(size=17)
        small = ImageFont.load_default(size=12)
    except TypeError:
        font = small = ImageFont.load_default()
    W = 2 * COLS * CELL + 150
    H = 200 * CELL + 110
    img = Image.new('RGB', (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    panel(img, draw, 50, 70, a, 'X: a finite half reads the loop 25, then enters the trap',
          ['cells 1 and 2 black at the start; one row per white tick, time downwards (sample numbers at left)'], font, small, entry)
    panel(img, draw, 50 + COLS * CELL + 60, 70, b, 'Y: a finite half of support 148 keeps the schedule for 200 samples',
          ['seven excursions (the breaks in the first columns); found by the solver on the whole light cone'], font, small)
    img.save(out)
    print('seed 3 enters the trap at sample', entry, '(tick %d)' % (2 * entry + 1), '; picture', img.size)


if __name__ == '__main__':
    main()
