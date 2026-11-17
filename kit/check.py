"""The sync check: are KIT.md, KIT-INDEX.md and kit/index.jsonl in step with the kit at REV?

  python3 kit/check.py                       # against the clone's HEAD
  python3 kit/check.py --rev origin/main     # preview an update after `git -C Rule30PrizeKit fetch`
  python3 kit/check.py --rev origin/main --todo /tmp/kit-todo.md   # write the rows to digest, with their text

Reports: the three stamps; catalogue rows that are NEW, CHANGED (text differs from the digested row) or REMOVED;
watched prose blocks that changed (KIT.md sections to review); Lean modules no catalogue row names (informational);
theorem names cited in KIT.md or the index that the kit at REV does not declare. Exit 0 only when fully in step.
"""
import argparse, sys
import kitlib as K

ap = argparse.ArgumentParser()
ap.add_argument('--rev', default='HEAD')
ap.add_argument('--todo')
ap.add_argument('--no-names', action='store_true')
a = ap.parse_args()
rev_full = K.resolve(a.rev)
idx, stamp = K.load_index(), K.load_stamp()
fail = []
st = stamp.get('commit', '')
s_md, s_ix = K.doc_stamp(K.KIT_MD), K.doc_stamp(K.KIT_INDEX_MD)
print('kit at %s: %s (%s)' % (a.rev, rev_full[:7], K.commit_date(a.rev)))
print('stamps: kit/stamp.json %s, KIT.md %s, KIT-INDEX.md %s' % (st[:7] or 'none', s_md or 'none', s_ix or 'none'))
if not st or s_md != st[:7] or s_ix != st[:7]:
    fail.append('the three stamps disagree')
pm = K.PROSE_RE.search(open(K.KIT_MD).read())
if not pm or not st.startswith(pm.group(1)):
    fail.append('KIT.md names commit %s in its first paragraph, not the stamped one' % (pm.group(1) if pm else 'none'))
if st and st != rev_full:
    behind = K.git('rev-list', '--count', '%s..%s' % (st, rev_full)).strip()
    fail.append('stamped %s, kit at %s: %s commit(s) to bring in' % (st[:7], rev_full[:7], behind))
live = {r['key']: r for s in ('lean', 'equivalents') for r in K.rows(a.rev, s)}
new = [r for k, r in live.items() if k not in idx]
changed = [r for k, r in live.items() if k in idx and idx[k]['sha'] != r['sha']]
removed = [idx[k] for k in idx if k not in live]
for label, rs in (('NEW', new), ('CHANGED', changed), ('REMOVED', removed)):
    for r in rs:
        print('%-8s %s (line %s)' % (label, r['key'], r['line']))
if new or changed or removed:
    fail.append('%d new, %d changed, %d removed catalogue row(s)' % (len(new), len(changed), len(removed)))
wnow = K.watched(a.rev)
wchg = [n for n, h in wnow.items() if stamp.get('watched', {}).get(n) != h]
for n in wchg:
    print('WATCHED  %s changed: review the matching KIT.md section' % n)
if wchg:
    fail.append('%d watched block(s) changed' % len(wchg))
full, last, mods = K.declared(a.rev)
cells = ' '.join(r['text'] for r in live.values())
uncat = sorted(m for m in mods if '.' not in m and m.startswith('Rule30') and m not in cells)
if uncat:
    print('INFO     %d Lean module(s) named by no catalogue row (data modules or catalogue lag): %s'
          % (len(uncat), ', '.join(uncat[:12]) + (' …' if len(uncat) > 12 else '')))
if not a.no_names:
    text = open(K.KIT_MD).read() + ' '.join(r.get('proved', '') + ' ' + r.get('open', '') + ' ' + r.get('form', '') for r in idx.values())
    unknown = sorted(n for n in K.cited_names(text) if not K.name_known(n, full, last, mods))
    for n in unknown:
        print('NAME     `%s` is cited but not declared in the kit at %s' % (n, rev_full[:7]))
    if unknown:
        fail.append('%d cited name(s) not found' % len(unknown))
if a.todo:
    out = ['# Kit update: rows to digest, %s → %s\n' % (st[:7], rev_full[:7])]
    for label, rs in (('New', new), ('Changed', changed)):
        out.append('## %s rows (%d)\n' % (label, len(rs)))
        for r in sorted(rs, key=lambda r: (r['src'], r['line'])):
            out.append('- `%s` line %d: `%s`\n\n  ```\n  %s\n  ```' % (r['src'], r['line'], r['cell'], r['text']))
            if r['key'] in idx:
                o = idx[r['key']]
                out.append('  Previous record: ' + (o.get('proved', '') + ' | ' + o.get('open', '') if r['src'] == 'lean' else o.get('form', '')))
    out.append('\n## Removed rows (%d)\n' % len(removed))
    out += ['- `%s`' % r['key'] for r in removed]
    out.append('\n## Watched blocks changed (%d)\n' % len(wchg))
    out += ['- `%s`: see `git -C Rule30PrizeKit diff %s %s -- %s`' % (n, st[:7], rev_full[:7], dict((w[0], w[1]) for w in K.WATCH)[n]) for n in wchg]
    open(a.todo, 'w').write('\n'.join(out) + '\n')
    print('wrote', a.todo)
print('IN STEP' if not fail else 'OUT OF STEP: ' + '; '.join(fail))
sys.exit(0 if not fail else 1)
