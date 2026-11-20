#!/usr/bin/env python3
"""claudeCloud_gate3_picture.py: the picture for the inquisition round of Gate 3 (ledger K16; METHOD section 7).

MEANT TO SHOW. The six doubled excursions whose source has one black tick per period, at source periods 1 to 6:
for each tick (row), where its reset words are, and how far the first one is from the wheel at which white returns.
Period 5 is the one doubled excursion known in which some tick never gets a reset word.

WHAT WOULD SURPRISE. If period 5 looked different in kind from its neighbours: another texture, another start.
What the record expects is that it looks the same in kind and merely ends early.

COMMAND:  python3 claudeCloud_gate3_picture.py [OUT.svg]      (exact data, from claudeCloud_excursions.py beside it)
"""
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)

CELL, LEFT, TOP = 9, 64, 96
BLACK, WHITE, RESET, EDGE, BAD, INK, MUTED = '#2a2a2e', '#ffffff', '#e0760a', '#d6e6f5', '#c62828', '#1b1b1f', '#5c5f66'
WORDS = ['1', '01', '001', '0001', '00001', '000001']
NOTE = {1: "the single black cell's own first interval, wheels 2 to 7",
        2: "the single black cell's second interval, wheels 7 to 28"}


def main():
    out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / 'gate3-single-pulse.svg'
    data = []
    for w in WORDS:
        wheels, gap = ex.excursion(w)
        data.append((w, wheels, gap, ex.first_resets(wheels)))
    width = LEFT + (max(g for _, _, g, _ in data) + 1) * CELL + 250
    parts, y = [], TOP
    for w, wheels, gap, first in data:
        p, q = len(w), 2 * len(w)
        bad = [t for t in range(q) if first[t] is None]
        head = 'Source period %d: white returns at wheel %d.' % (p, gap)
        tail = ('  Rows %s have no reset word.' % ' and '.join(str(t) for t in bad) if bad
                else '  Every row has a reset word; the last row to get its first one gets it at wheel %d.' % max(first))
        parts.append('<text x="%d" y="%d" class="h">%s<tspan class="%s">%s</tspan></text>'
                     % (LEFT, y, head, 'bad' if bad else 'm', tail))
        if p in NOTE:
            parts.append('<text x="%d" y="%d" class="m">(%s)</text>' % (LEFT + (gap + 1) * CELL + 12, y + 16 + q * CELL / 2, NOTE[p]))
        y += 10
        parts.append('<rect x="%d" y="%d" width="%d" height="%d" fill="%s"/>' % (LEFT, y, (gap + 1) * CELL, q * CELL, WHITE))
        for j in (0, gap):
            parts.append('<rect x="%d" y="%d" width="%d" height="%d" fill="%s"/>' % (LEFT + j * CELL, y, CELL, q * CELL, EDGE))
        for t in range(q):
            marks = set()
            for a, b, _ in ex.resets(wheels, t):
                marks.update(range(a, b + 1))
            j = 1
            while j < gap:                      # one rectangle for each run of cells of one colour
                colour = RESET if j in marks else BLACK if wheels[j][t] else None
                k = j
                while k + 1 < gap and (RESET if k + 1 in marks else BLACK if wheels[k + 1][t] else None) == colour:
                    k += 1
                if colour:
                    parts.append('<rect x="%d" y="%d" width="%d" height="%d" fill="%s"/>'
                                 % (LEFT + j * CELL, y + t * CELL, (k - j + 1) * CELL, CELL, colour))
                j = k + 1
            parts.append('<text x="%d" y="%d" class="t" text-anchor="end">%d</text>' % (LEFT - 8, y + t * CELL + 8, t))
            if t in bad:
                parts.append('<rect x="%d" y="%d" width="%d" height="%d" fill="none" stroke="%s" stroke-width="2"/>'
                             % (LEFT - 1, y + t * CELL, (gap + 1) * CELL + 2, CELL, BAD))
                parts.append('<text x="%d" y="%d" class="bad">no reset word</text>' % (LEFT + (gap + 1) * CELL + 12, y + t * CELL + 8))
        grid = ''.join('M%d %dv%d' % (LEFT + j * CELL, y, q * CELL) for j in range(gap + 2))
        grid += ''.join('M%d %dh%d' % (LEFT, y + t * CELL, (gap + 1) * CELL) for t in range(q + 1))
        parts.append('<path d="%s" class="g" fill="none"/>' % grid)
        for j in range(0, gap + 1, 10):
            parts.append('<text x="%d" y="%d" class="t" text-anchor="middle">%d</text>' % (LEFT + j * CELL + CELL / 2, y + q * CELL + 12, j))
        parts.append('<text x="%d" y="%d" class="t" text-anchor="end">tick</text>' % (LEFT - 8, y - 3))
        y += q * CELL + 44
    legend = [(BLACK, 'black cell'), (RESET, 'black cells of a reset word: a run of 1, 4, 7, … between two whites'),
              (EDGE, 'the wheel that is white at every tick: where the excursion starts and where it ends')]
    lx = LEFT
    head = ['<text x="%d" y="26" class="title">Doubled excursions of rule 30\'s left side, from a source with one black tick per period</text>' % LEFT,
            '<text x="%d" y="46" class="m">Wheels across, counted from the white wheel where the clock doubles (wheel 0). Ticks down, one full period: twice the source period.</text>' % LEFT]
    for colour, label in legend:
        head.append('<rect x="%d" y="58" width="12" height="12" fill="%s" stroke="#9aa0a6" stroke-width="0.5"/>' % (lx, colour))
        head.append('<text x="%d" y="68" class="m">%s</text>' % (lx + 18, label))
        lx += 30 + int(len(label) * 6.1)
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" role="img" '
           'aria-label="Six doubled excursions of rule 30, source periods 1 to 6, with reset words marked">'
           '<style>text{font-family:Helvetica,Arial,sans-serif;fill:%s}.title{font-size:16px;font-weight:600}'
           '.h{font-size:13px;font-weight:600}.m{font-size:12px;fill:%s;font-weight:400}.t{font-size:9px;fill:%s}'
           '.bad{font-size:12px;fill:%s;font-weight:600}.g{stroke:#c9ccd1;stroke-width:0.5}</style>'
           '<rect width="100%%" height="100%%" fill="#fbfbf9"/>%s%s</svg>'
           % (width, y, width, y, INK, MUTED, MUTED, BAD, ''.join(head), ''.join(parts)))
    out.write_text(svg)
    print('%s: %d by %d, %d bytes' % (out.name, width, y, len(svg)))


if __name__ == '__main__':
    main()
