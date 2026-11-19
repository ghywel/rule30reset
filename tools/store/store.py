#!/usr/bin/env python3
"""store.py: the client for the shared store's postboxes and share-scratch (METHOD.md §9).

The store is the folder scratch/rule30reset/ on the owner's website, which is the store's data folder. Its address and
the pre-shared token come from the environment, RULE30_STORE_URL and RULE30_STORE_TOKEN (falling back to
PLACEGO_STORE_URL and PLACEGO_SITE_TOKEN). This client never prints, logs or writes either of them. Paths below are
relative to that folder: postbox/<agent>/, share-scratch/<agent>/.

  python3 tools/store/store.py join AGENT                         create postbox/AGENT/ (once, when an agent joins)
  python3 tools/store/store.py flag --from A --to B[,C] --kind K --post ID [--commit SHA] --ask TEXT
                                                            one copy of the flag in each recipient's postbox
  python3 tools/store/store.py inbox AGENT                        list and show the flags waiting in your postbox
  python3 tools/store/store.py others AGENT FLAGFILE              for a multi-agent flag: which other recipients still hold it
  python3 tools/store/store.py done AGENT FLAGFILE                remove a processed flag from your own postbox
  python3 tools/store/store.py share AGENT LOCALFILE [--as NAME]  upload to share-scratch/AGENT/ (NAME may hold a folder, S3/essay.md), read back, cite
  python3 tools/store/store.py fetch PATH LOCALFILE               download a shared file and print its SHA-256
  python3 tools/store/store.py ls [PATH]                          list a folder
Add --dry-run before the command to print the requests instead of sending them.
"""
import argparse, datetime, hashlib, json, os, pathlib, posixpath, sys, time, urllib.error, urllib.parse, urllib.request

AGENTS = ('claudeM5', 'gptM5', 'claudeCloud', 'gptIntel')
KINDS = ('READ', 'REVIEW', 'TASK', 'ANSWER', 'PRIZE')
DRY = False
STORE_TYPES = ('application/json', 'application/octet-stream')   # what store.php sends; anything else is not the store
TRIES = 6


def env():
    url = os.environ.get('RULE30_STORE_URL') or os.environ.get('PLACEGO_STORE_URL')
    tok = os.environ.get('RULE30_STORE_TOKEN') or os.environ.get('PLACEGO_SITE_TOKEN')
    if not url or not tok:
        sys.exit('store.py: set RULE30_STORE_URL and RULE30_STORE_TOKEN (ask the owner); nothing was sent')
    return url, tok


def call(op, path, body=None, soft=False):
    full = path
    if DRY:
        print('DRY %s %s%s' % ('POST' if body is not None or op == 'delete' else 'GET', op, ' ' + full),
              ('\n    ' + body[:400].decode(errors='replace').replace('\n', '\n    ') + ('\n    … (%d bytes in all)' % len(body) if len(body) > 400 else '')) if body else '')
        return {'dry': True}
    url, tok = env()
    req = urllib.request.Request('%s?%s=%s' % (url, op, urllib.parse.quote(full, safe='/')),
                                 data=body if body is not None else (b'' if op == 'delete' else None),
                                 headers={'X-Store-Token': tok}, method='POST' if (body is not None or op == 'delete') else 'GET')
    # The store answers only as JSON or as a file's bytes. The web host sometimes answers in its place with an HTML
    # verification page; that request never reached the store, so it is safe to send again.
    for attempt in range(TRIES):
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                raw, ctype = r.read(), r.headers.get('Content-Type', '')
        except urllib.error.HTTPError as e:
            raw, ctype = e.read(), e.headers.get('Content-Type', '')
        if ctype.split(';')[0].strip().lower() in STORE_TYPES:
            break
        if attempt + 1 < TRIES:
            time.sleep(min(30, 3 * 2 ** attempt))   # 3, 6, 12, 24, 30 s: the page clears after a pause
    else:
        sys.exit("store.py: %s %s: the store's host answered %d times with something other than the store (a verification "
                 "page or a proxy error); nothing was read or written. Try again." % (op, full, TRIES))
    if op == 'path':
        try:
            j = json.loads(raw)
            if isinstance(j, dict) and 'error' in j:
                sys.exit('store.py: %s: %s' % (full, j['error']))
        except (ValueError, UnicodeDecodeError):
            pass
        return raw
    try:
        j = json.loads(raw)
    except ValueError:
        return {'raw': raw.decode(errors='replace')}
    if isinstance(j, dict) and 'error' in j:
        if soft:
            return None
        sys.exit('store.py: %s: %s' % (full, j['error']))
    return j


def names(folder, soft=False):
    j = call('list', folder, soft=soft)
    return [e['name'] for e in j.get('entries', [])] if isinstance(j, dict) else []


def agent(a):
    if a not in AGENTS:
        sys.exit('store.py: agent must be one of %s (a new agent adds itself to AGENTS and to METHOD.md §9)' % ', '.join(AGENTS))
    return a


def mine(a):
    """An agent acting on its own postbox or share-scratch: the store names a token's worker, and it must be `a`."""
    agent(a)
    if not DRY:
        w = call('whoami', '').get('worker')
        if w != a:
            sys.exit("store.py: this host's token is the store's worker %r, not %r; nothing was sent" % (w, a))
    return a


def parse(text):
    out = {}
    for l in text.split('\n'):
        if ':' in l:
            k, v = l.split(':', 1); out[k.strip()] = v.strip()
    return out


def main():
    global DRY
    ap = argparse.ArgumentParser(); ap.add_argument('--dry-run', action='store_true')
    sp = ap.add_subparsers(dest='cmd', required=True)
    p = sp.add_parser('join'); p.add_argument('agent')
    p = sp.add_parser('flag'); p.add_argument('--from', dest='frm', required=True); p.add_argument('--to', required=True)
    p.add_argument('--kind', required=True, choices=KINDS); p.add_argument('--post', required=True)
    p.add_argument('--commit', default=''); p.add_argument('--ask', required=True)
    p = sp.add_parser('inbox'); p.add_argument('agent')
    p = sp.add_parser('others'); p.add_argument('agent'); p.add_argument('flagfile')
    p = sp.add_parser('done'); p.add_argument('agent'); p.add_argument('flagfile')
    p = sp.add_parser('share'); p.add_argument('agent'); p.add_argument('localfile'); p.add_argument('--as', dest='name')
    p = sp.add_parser('fetch'); p.add_argument('path'); p.add_argument('localfile')
    p = sp.add_parser('ls'); p.add_argument('path', nargs='?', default='')
    a = ap.parse_args(); DRY = a.dry_run
    now = datetime.datetime.now(datetime.timezone.utc)
    if a.cmd == 'join':
        call('put', 'postbox/%s/JOINED' % mine(a.agent),
             ('%s joined %s UTC\n' % (a.agent, now.strftime('%Y-%m-%d %H:%M'))).encode())
        print('postbox/%s/ ready' % a.agent)
    elif a.cmd == 'flag':
        frm = mine(a.frm); to = [agent(t.strip()) for t in a.to.split(',') if t.strip()]
        if frm in to:
            sys.exit('store.py: do not flag yourself')
        fid = '%s-%s-%s' % (now.strftime('%Y%m%dT%H%MZ'), frm, a.post)
        body = ('flag: %s\nkind: %s\nfrom: %s\nto: %s\npost: %s\ncommit: %s\nsent: %s UTC\nask: %s\n' % (
            fid, a.kind, frm, ', '.join(to), a.post, a.commit or '-', now.strftime('%Y-%m-%d %H:%M'), a.ask)).encode()
        if not DRY:
            missing = [t for t in to if call('list', 'postbox/%s' % t, soft=True) is None]
            if missing:
                sys.exit('store.py: no postbox for %s (not joined yet); no copy was sent' % ', '.join(missing))
        for t in to:
            call('put', 'postbox/%s/%s-%s.flag' % (t, fid, a.kind), body)
        print('flag %s (%s) posted to %s%s' % (fid, a.kind, ', '.join(to), ' (multi-agent)' if len(to) > 1 else ''))
    elif a.cmd == 'inbox':
        fl = [n for n in names('postbox/%s' % agent(a.agent)) if n.endswith('.flag')]
        if not fl:
            print('postbox/%s: empty' % a.agent)
        for n in sorted(fl):
            f = parse(call('path', 'postbox/%s/%s' % (a.agent, n)).decode(errors='replace'))
            multi = len([x for x in f.get('to', '').split(',') if x.strip()]) > 1
            print('%s\n  %s from %s, post %s, sent %s%s\n  ask: %s' % (n, f.get('kind'), f.get('from'), f.get('post'), f.get('sent'),
                  '\n  MULTI-AGENT, also to: ' + ', '.join(x.strip() for x in f['to'].split(',') if x.strip() != a.agent) if multi else '', f.get('ask')))
    elif a.cmd == 'others':
        f = parse(call('path', 'postbox/%s/%s' % (agent(a.agent), a.flagfile)).decode(errors='replace'))
        for o in [x.strip() for x in f.get('to', '').split(',') if x.strip() and x.strip() != a.agent]:
            held = a.flagfile in names('postbox/%s' % o)
            print('%-6s %s' % (o, 'still holds it: not yet processed' if held else 'has removed it: processed; read its reply to %s first' % f.get('post')))
    elif a.cmd == 'done':
        if not a.flagfile.endswith('.flag'):
            sys.exit('store.py: only .flag files are removed this way')
        call('delete', 'postbox/%s/%s' % (mine(a.agent), a.flagfile)); print('removed', a.flagfile)
    elif a.cmd == 'share':
        data = pathlib.Path(a.localfile).read_bytes(); h = hashlib.sha256(data).hexdigest()
        name = a.name or pathlib.Path(a.localfile).name
        if name.startswith('/') or '..' in name.split('/') or '' in name.split('/'):
            sys.exit('store.py: --as takes a relative name such as S3/essay.md')
        path = 'share-scratch/%s/%s' % (mine(a.agent), name)
        if not DRY and posixpath.basename(path) in names(posixpath.dirname(path), soft=True):
            sys.exit('store.py: %s exists; a cited file is never overwritten: choose a new name with --as' % path)
        call('put', path, data)
        if not DRY:
            back = call('path', path)
            if hashlib.sha256(back).hexdigest() != h:
                sys.exit('store.py: read-back of %s does not match: do not cite it' % path)
        print('shared: `%s`, SHA-256 `%s`, %d bytes%s' % (path, h, len(data), '' if DRY else ', read back and verified'))
    elif a.cmd == 'fetch':
        data = call('path', a.path)
        if not DRY:
            pathlib.Path(a.localfile).write_bytes(data)
            print('%s: %d bytes, SHA-256 %s' % (a.localfile, len(data), hashlib.sha256(data).hexdigest()))
    elif a.cmd == 'ls':
        for n in names(a.path):
            print(n)


if __name__ == '__main__':
    main()
