#!/usr/bin/env python3
"""find_known.py: search our source-of-truth documents for what is already known.

  python3 tools/find_known.py TERM [TERM ...]            each term searched on its own, case-insensitively
  python3 tools/find_known.py --all TERM                 every hit, not the first five per file
  python3 tools/find_known.py --files PRIOR-ART TERM     only files whose name contains PRIOR-ART

Searched, in order: KIT.md and KIT-INDEX.md (the kit, kept in step by KIT-UPDATE.md), PORTAL.md (the portal entries
outside the kit, kept in step by tools/portal/portal_only.py), PRIOR-ART.md and
PRIOR-ART-ARCHIVE.md (results found to be known), CHAT-LEDGER.md and its archives (our own work). Each hit is shown
with the nearest heading above it. Every file is named even when a term has no hit there, so an absence is visible.
Terms are never combined: search each name an object carries separately ("Theta odd depth", "first check").
For detail behind KIT.md, read the Lean source in Rule30PrizeKit/; for what our documents do not track (the portal's
abstracts in full, open kit pull requests, the literature), search those directly.
"""
import argparse, pathlib, re

ROOT = pathlib.Path(__file__).resolve().parents[1]
FILES = ['KIT.md', 'KIT-INDEX.md', 'PORTAL.md', 'PRIOR-ART.md', 'PRIOR-ART-ARCHIVE.md', 'CHAT-LEDGER.md']

def files(only):
    out = [ROOT / f for f in FILES]
    out += sorted((ROOT / 'archive' / 'ledgers').glob('CHAT-LEDGER.*.md')) if (ROOT / 'archive' / 'ledgers').exists() else []
    return [p for p in out if p.exists() and (not only or only in p.name)]

ap = argparse.ArgumentParser()
ap.add_argument('terms', nargs='+'); ap.add_argument('--all', action='store_true'); ap.add_argument('--files')
a = ap.parse_args()
for term in a.terms:
    pat = re.compile(re.escape(term), re.I)
    print('== %s' % term)
    total = 0
    for p in files(a.files):
        head, hits = '', []
        for k, l in enumerate(p.read_text(errors='replace').split('\n'), 1):
            if l.startswith('#'):
                head = l.lstrip('#').strip()
            if pat.search(l):
                hits.append((k, head, l.strip()))
        total += len(hits)
        print('  %-24s %d hit(s)' % (p.relative_to(ROOT), len(hits)) if hits else '  %-24s no hit' % p.relative_to(ROOT))
        for k, h, l in (hits if a.all else hits[:5]):
            i = pat.search(l).start(); s = max(0, i - 70)
            print('    %d [%s] %s%s' % (k, h[:60], '…' if s else '', l[s:s + 170]))
        if hits and not a.all and len(hits) > 5:
            print('    … %d more (--all)' % (len(hits) - 5))
    print('  total %d' % total)
