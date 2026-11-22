#!/usr/bin/env python3
"""portal_only.py: compare the portal's list with PORTAL.md (ledger M97).

  python3 tools/portal/portal_only.py                 read the live list from the portal
  python3 tools/portal/portal_only.py --file LIST     read a saved copy of submissions.json instead

PORTAL.md lists every portal entry that has no kit modules (an empty `kitContribution` in the portal's list). This
prints the list's time and counts, then:
  - NEW: portal-only entries that PORTAL.md does not list, with date, authors, status and title (add a row for each);
  - IN KIT NOW: entries PORTAL.md lists that have since gained kit modules (move them out);
  - GONE: entries PORTAL.md lists that the portal no longer shows.
Exit status 0 when PORTAL.md is in step, 1 when something needs doing. It reads only the public list.
"""
import argparse, json, pathlib, re, sys, urllib.request

URL = 'https://www.wolframcloud.com/obj/rule-30-prize/Agents/submissions.json'
ROOT = pathlib.Path(__file__).resolve().parents[2]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--file')
    a = ap.parse_args()
    if a.file:
        data = json.loads(pathlib.Path(a.file).read_text())
    else:
        req = urllib.request.Request(URL, headers={'User-Agent': 'rule30-portal-check'})
        with urllib.request.urlopen(req, timeout=120) as r:
            data = json.loads(r.read().decode('utf-8'))
    entries = data['entries']
    by_id = {e['id']: e for e in entries}
    portal_only = {e['id'] for e in entries if not e.get('kitContribution')}
    listed = set(re.findall(r'^\| \[(R30-\d{8}-[0-9a-f]{6})\]', (ROOT / 'PORTAL.md').read_text(), re.M))
    print('portal list %s: %d entries, %d portal-only; PORTAL.md lists %d' % (
        data.get('updated', '?'), len(entries), len(portal_only), len(listed)))
    new = sorted(portal_only - listed, key=lambda i: by_id[i]['submitted'])
    in_kit = sorted(i for i in listed if i in by_id and i not in portal_only)
    gone = sorted(i for i in listed if i not in by_id)
    for i in new:
        e = by_id[i]
        tags = ', '.join(e.get('tags') or [])
        print('NEW %s %s | %s | %s%s | %s' % (i, e['submitted'][:10], e.get('authors', ''), e['status'],
                                            (', ' + tags) if tags else '', e['title']))
    for i in in_kit:
        mods = (by_id[i].get('kitContribution') or {}).get('modules', [])
        print('IN KIT NOW %s: %s' % (i, ', '.join(m.split('.')[-1] for m in mods)))
    for i in gone:
        print('GONE %s' % i)
    if not (new or in_kit or gone):
        print('PORTAL.md is in step with the portal list.')
    sys.exit(1 if (new or in_kit or gone) else 0)


if __name__ == '__main__':
    main()
