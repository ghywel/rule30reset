#!/usr/bin/env python3
"""ledger_check.py: CHAT-LEDGER.md is well formed, under its rotation limit, and free of resurrected posts.

  python3 tools/ledger_check.py                       check; exit 0 when clean. Run after every merge, before every push.
  python3 tools/ledger_check.py --next L              print the next post ID in series L
  python3 tools/ledger_check.py --stale origin/main   before merging main into a branch: is the branch from before a rotation?
  python3 tools/ledger_check.py --rotate              archive the live ledger and start the next generation

Why the guards. CHAT-LEDGER.md merges with merge=union (.gitattributes), so two workers appending at once never
conflict. The price, met in the old repository: a branch begun before a rotation that appended a post can, when merged,
pour the archived text back into the live ledger without any conflict. So the check fails on any post ID that is
already archived, on any repeated or out-of-order ID, and on any archive whose SHA-256 no longer matches its row in
the header (archives are frozen), and --stale warns before such a merge is made.
"""
import argparse, datetime, hashlib, pathlib, re, shutil, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
LIVE = ROOT / 'CHAT-LEDGER.md'
ARCH = ROOT / 'archive' / 'ledgers'
LIMIT, WARN = 2000, 1800
POST = re.compile(r'^## ([A-Z])(\d+) · (\d{4}-\d{2}-\d{2} \d{2}:\d{2}) UTC · (.+?) → (.+?) · (\S.*)$')
ANYPOST = re.compile(r'^## ([A-Z])(\d+) ')
ADDENDUM = re.compile(r'^\*\*([A-Z])(\d+), addendum (\d+) \((\d{4}-\d{2}-\d{2} \d{2}:\d{2}) UTC\)')
ARCROW = re.compile(r'^\|\s*\[CHAT-LEDGER\.(\d+)\.md\].*\|\s*`([0-9a-f]{64})`\s*\|\s*$')
WORKER = re.compile(r'^\|\s*([A-Z])\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*$')
CONFLICT = re.compile(r'^(<<<<<<< |=======$|>>>>>>> )')
TODO = 'TO WRITE'
SECTIONS = ('## Archives', '## Workers', '## State of the work')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def split(text):
    lines = text.split('\n')
    i = next((k for k, l in enumerate(lines) if ANYPOST.match(l)), len(lines))
    return lines[:i], lines[i:], i


def parse_header(head):
    archives, workers, last = [], {}, {}
    for l in head:
        m = ARCROW.match(l)
        if m:
            archives.append((int(m.group(1)), m.group(2)))
        m = WORKER.match(l)
        if m:
            workers[m.group(1)] = m.group(2)
            n = re.search(r'([A-Z])(\d+)', m.group(4))
            last[m.group(1)] = int(n.group(2)) if n else 0
    return archives, workers, last


def archived_ids():
    ids, top = set(), {}
    for p in sorted(ARCH.glob('CHAT-LEDGER.*.md')) if ARCH.exists() else []:
        for l in p.read_text().split('\n'):
            m = ANYPOST.match(l)
            if m:
                ids.add((m.group(1), int(m.group(2))))
                top[m.group(1)] = max(top.get(m.group(1), 0), int(m.group(2)))
    return ids, top


def check(text=None, quiet=False):
    errors, warns = [], []
    text = LIVE.read_text() if text is None else text
    lines = text.rstrip('\n').split('\n')
    for k, l in enumerate(lines, 1):
        if CONFLICT.match(l):
            errors.append('line %d: conflict marker' % k)
    if len(lines) > LIMIT:
        errors.append('%d lines, over the limit of %d: rotate (python3 tools/ledger_check.py --rotate)' % (len(lines), LIMIT))
    elif len(lines) > WARN:
        warns.append('%d lines: rotate soon (limit %d)' % (len(lines), LIMIT))
    head, body, start = split(text)
    htext = '\n'.join(head)
    for s in SECTIONS:
        if not any(l.startswith(s) for l in head):
            errors.append('header has no section starting "%s"' % s)
    if TODO in htext:
        errors.append('header still says "%s": write the state of the work before pushing' % TODO)
    archives, workers, last = parse_header(head)
    gens = sorted(g for g, _ in archives)
    if gens != list(range(1, len(gens) + 1)):
        errors.append('archive generations in the header are %s, not 1..%d' % (gens, len(gens)))
    listed = set()
    for g, h in archives:
        p = ARCH / ('CHAT-LEDGER.%d.md' % g)
        listed.add(p.name)
        if not p.exists():
            errors.append('archive %s is listed but missing' % p.name)
        elif sha(p) != h:
            errors.append('archive %s has changed (SHA-256 %s…, header says %s…): archives are frozen; restore it '
                          'with git checkout origin/main -- %s' % (p.name, sha(p)[:12], h[:12], p.relative_to(ROOT)))
    for p in sorted(ARCH.glob('CHAT-LEDGER.*.md')) if ARCH.exists() else []:
        if p.name not in listed:
            errors.append('archive %s exists but the header does not list it' % p.name)
    aids, atop = archived_ids()
    for L, n in atop.items():
        if last.get(L, 0) != n:
            warns.append('workers table says the last %s post at rotation was %s%d; the archives end at %s%d'
                         % (workers.get(L, L), L, last.get(L, 0), L, n))
    seen, prev_time, counts = {}, None, {}
    now = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)
    for k, l in enumerate(body, start + 1):
        if l.startswith('## '):
            m = POST.match(l)
            if not m:
                errors.append('line %d: malformed post heading: %s' % (k, l[:80])); continue
            L, n, ts, frm, to, subj = m.group(1), int(m.group(2)), m.group(3), m.group(4).strip(), m.group(5), m.group(6)
            pid = '%s%d' % (L, n)
            if L not in workers:
                errors.append('line %d: %s: no worker has letter %s in the header' % (k, pid, L))
            elif frm != workers[L]:
                errors.append('line %d: %s is posted from "%s", but %s is %s\'s series' % (k, pid, frm, L, workers[L]))
            for t in [x.strip() for x in to.split(',')]:
                if t != 'all' and t not in workers.values():
                    errors.append('line %d: %s is addressed to unknown "%s"' % (k, pid, t))
            if (L, n) in aids:
                errors.append('line %d: %s is already in an archive: an old ledger has been merged back in. Restore '
                              'main\'s ledger and re-append only your new posts' % (k, pid))
            if L in seen and n <= seen[L]:
                errors.append('line %d: %s comes after %s%d: repeated or out of order' % (k, pid, L, seen[L]))
            elif L in seen and n != seen[L] + 1:
                warns.append('line %d: %s skips from %s%d' % (k, pid, L, seen[L]))
            elif L not in seen and n != max(atop.get(L, 0), last.get(L, 0)) + 1:
                (errors if n <= atop.get(L, 0) else warns).append(
                    'line %d: %s is the first %s post here; the series stood at %s%d' % (k, pid, L, L, max(atop.get(L, 0), last.get(L, 0))))
            seen[L] = max(seen.get(L, 0), n)
            counts[L] = counts.get(L, 0) + 1
            try:
                t = datetime.datetime.strptime(ts, '%Y-%m-%d %H:%M')
                if t > now + datetime.timedelta(minutes=15):
                    errors.append('line %d: %s is dated in the future (%s UTC): read the clock with date -u' % (k, pid, ts))
                if prev_time and t < prev_time - datetime.timedelta(minutes=60):
                    warns.append('line %d: %s is dated more than an hour before the post above it' % (k, pid))
                prev_time = t
            except ValueError:
                errors.append('line %d: %s has an impossible time %s' % (k, pid, ts))
        m = ADDENDUM.match(l)
        if m:
            key = (m.group(1), int(m.group(2)))
            if key not in aids and seen.get(key[0], 0) < key[1]:
                errors.append('line %d: addendum to %s%d, which has not been posted' % (k, key[0], key[1]))
    if not quiet:
        for w in warns:
            print('WARN ', w)
        for e in errors:
            print('ERROR', e)
        print('ledger: %d lines, %d archive(s), posts here %s' % (len(lines), len(archives),
              ', '.join('%s %d (to %s%d)' % (workers.get(L, L), c, L, seen[L]) for L, c in sorted(counts.items())) or 'none'))
        print('LEDGER IN ORDER' if not errors else 'LEDGER CHECK FAILS (%d error(s))' % len(errors))
    return errors, seen, atop, archives, workers, last


def rotate():
    errors, seen, atop, archives, workers, last = check(quiet=True)
    errors = [e for e in errors if 'over the limit' not in e]
    if errors:
        print('refusing to rotate: fix these first'); [print('ERROR', e) for e in errors]; return 1
    gen = len(archives) + 1
    ARCH.mkdir(parents=True, exist_ok=True)
    dst = ARCH / ('CHAT-LEDGER.%d.md' % gen)
    if dst.exists():
        print('refusing to rotate: %s already exists' % dst.name); return 1
    text = LIVE.read_text()
    head, body, _ = split(text)
    posts = [POST.match(l) for l in body if POST.match(l)]
    if not posts:
        print('refusing to rotate: no posts to archive'); return 1
    shutil.copyfile(LIVE, dst)
    rng = {}
    for m in posts:
        a, b = rng.get(m.group(1), (10 ** 9, 0)); n = int(m.group(2)); rng[m.group(1)] = (min(a, n), max(b, n))
    ids = ', '.join('%s%d to %s%d' % (L, a, L, b) for L, (a, b) in sorted(rng.items()))
    row = '| [CHAT-LEDGER.%d.md](archive/ledgers/CHAT-LEDGER.%d.md) | %s (%d posts) | %s to %s UTC | %d | `%s` |' % (
        gen, gen, ids, len(posts), posts[0].group(3), posts[-1].group(3), len(text.rstrip('\n').split('\n')), sha(dst))
    out, section = [], None
    for l in head:
        if l.startswith('## '):
            section = l
        if section and section.startswith('## State of the work'):
            continue
        m = WORKER.match(l)
        if m and section and section.startswith('## Workers'):
            L = m.group(1); top = max(last.get(L, 0), rng.get(L, (0, 0))[1])
            l = '| %s | %s | %s | %s |' % (L, m.group(2), m.group(3), '%s%d' % (L, top) if top else 'none')
        if l.startswith('None yet.') and section and section.startswith('## Archives'):
            continue
        out.append(l)
    while out and not out[-1].strip():
        out.pop()
    k = max(i for i, l in enumerate(out[:next(j for j, l in enumerate(out) if l.startswith('## Workers'))]) if l.startswith('|'))
    out.insert(k + 1, row)
    out += ['', '## State of the work at rotation %d (%s UTC)' % (gen, datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M')), '',
            '%s: what is running and stopped, the open threads (post IDs awaiting an answer or a read), pending' % TODO,
            'reviews, the owner\'s standing decisions, and the direction. Then delete this paragraph.', '']
    LIVE.write_text('\n'.join(out) + '\n')
    print('archived %d posts to %s; started generation %d.' % (len(posts), dst.relative_to(ROOT), gen + 1))
    print('Now: write the state section, run the check, commit CHAT-LEDGER.md and the archive together, push, flag all.')
    return 0


def stale(rev):
    def count(tree):
        out = subprocess.run(['git', '-C', str(ROOT), 'ls-tree', '--name-only', tree, 'archive/ledgers/'],
                             capture_output=True, text=True).stdout
        return len([l for l in out.split('\n') if re.search(r'CHAT-LEDGER\.\d+\.md$', l)])
    mine, theirs = count('HEAD'), count(rev)
    if theirs > mine:
        print('STALE: %s holds %d ledger archive(s), this branch %d. The ledger was rotated since this branch began.' % (rev, theirs, mine))
        print('Do not merge the ledger. After merging, take %s\'s ledger and archives:' % rev)
        print('  git checkout %s -- CHAT-LEDGER.md archive/ledgers/' % rev)
        print('then re-append only your own new posts at the end, keeping their IDs, and run this check.')
        return 1
    print('not stale: %d archive(s) here, %d in %s' % (mine, theirs, rev))
    return 0


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--next'); ap.add_argument('--stale'); ap.add_argument('--rotate', action='store_true')
    a = ap.parse_args()
    if a.next:
        errors, seen, atop, archives, workers, last = check(quiet=True)
        print('%s%d' % (a.next, max(seen.get(a.next, 0), atop.get(a.next, 0), last.get(a.next, 0)) + 1)); sys.exit(0)
    if a.stale:
        sys.exit(stale(a.stale))
    if a.rotate:
        sys.exit(rotate())
    sys.exit(1 if check()[0] else 0)
