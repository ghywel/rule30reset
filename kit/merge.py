"""Merge digest lines into kit/index.jsonl.

  python3 kit/merge.py --rev REV --src lean DIGEST.txt [...]
  python3 kit/merge.py --rev REV --src equivalents DIGEST.txt [...]
  python3 kit/merge.py --rev REV --drop-removed

Digest lines carry the README line number at REV, so each record is keyed to the exact kit row it describes:
  lean:        LINE | MODULES | DATE | WHO | P | THEME | W | PROVED | OPEN
  equivalents: LINE | MODULE | KIND | FIELD | FORM
Other lines (ROWS n, NOTES, prose) are ignored. A record whose row text has changed since must be digested again.
"""
import argparse, re, sys
import kitlib as K

ap = argparse.ArgumentParser()
ap.add_argument('--rev', required=True)
ap.add_argument('--src', choices=['lean', 'equivalents'])
ap.add_argument('--drop-removed', action='store_true')
ap.add_argument('files', nargs='*')
a = ap.parse_args()
idx = K.load_index()
themes, kinds = {t for t, _ in K.THEMES}, {k for k, _ in K.KINDS}
errors, n = [], 0
if a.files:
    if not a.src:
        sys.exit('--src is required with digest files')
    at = {r['line']: r for r in K.rows(a.rev, a.src)}
    for path in a.files:
        for raw in open(path):
            if not re.match(r'^\s*\d+ \| ', raw):
                continue
            p = [x.strip() for x in raw.strip().split(' | ')]
            want = 9 if a.src == 'lean' else 5
            if len(p) < want:
                errors.append('%s: too few fields: %s' % (path, raw[:70])); continue
            if len(p) > want:      # a ' | ' inside the free text: rejoin the text field
                p = p[:want - 2] + [' | '.join(p[want - 2:-1]), p[-1]] if a.src == 'lean' else p[:4] + [' | '.join(p[4:])]
            line = int(p[0])
            row = at.get(line)
            if row is None:
                errors.append('%s: line %d is not a catalogue row at %s' % (path, line, a.rev)); continue
            rec = {k: row[k] for k in ('src', 'section', 'cell', 'key', 'line', 'sha')}
            if a.src == 'lean':
                _, mods, date, who, P, theme, W, proved, opn = p
                if theme not in themes: errors.append('line %d: unknown theme %r' % (line, theme)); continue
                if W not in ('1', '2', '3'): errors.append('line %d: W must be 1, 2 or 3' % line); continue
                if P not in ('1', '2', '3', '-'): errors.append('line %d: P must be 1, 2, 3 or -' % line); continue
                rec.update(name=mods, date=date, who=who, P=P, theme=theme, W=int(W), proved=proved, open=opn)
            else:
                _, mod, kind, field, form = p
                if kind not in kinds: errors.append('line %d: unknown kind %r' % (line, kind)); continue
                rec.update(name=mod, kind=kind, field=field, form=form)
            idx[rec['key']] = rec; n += 1
dropped = 0
if a.drop_removed:
    live = {r['key'] for s in ('lean', 'equivalents') for r in K.rows(a.rev, s)}
    for k in [k for k in idx if k not in live]:
        del idx[k]; dropped += 1
K.save_index(idx)
print('merged %d record(s), dropped %d, index now %d' % (n, dropped, len(idx)))
for e in errors:
    print('ERROR', e)
sys.exit(1 if errors else 0)
