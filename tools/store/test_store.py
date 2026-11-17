#!/usr/bin/env python3
"""test_store.py: runs store.php under PHP's built-in server with a throwaway config and checks every rule.

COMMAND:  python3 tools/store/test_store.py      (needs the php command line; nothing leaves this machine)

It starts two servers on 127.0.0.1: one with require_https off (the functional tests) and one with it on (plain HTTP
must be refused). Three workers, alice, bob and carol, have tokens made here; the project checks play the
postbox and share-scratch protocol of METHOD.md §9 among them. Every check prints PASS or FAIL, and the script
exits non-zero if any fails.
"""
import hashlib
import http.client
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import time

HERE = pathlib.Path(__file__).resolve().parent
RESULTS = []
WRITES = [0]   # successful writes to the main server, which the log must match


def check(name, ok, detail=''):
    RESULTS.append(ok)
    print('%s  %s%s' % ('PASS' if ok else 'FAIL', name, ('  (' + detail + ')') if detail and not ok else ''))


def start(root, cfg_path, port):
    env = dict(os.environ, SHAREDSTORE_CONFIG=str(cfg_path))
    p = subprocess.Popen(['php', '-S', '127.0.0.1:%d' % port, '-t', str(root)], env=env,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(50):
        try:
            c = http.client.HTTPConnection('127.0.0.1', port, timeout=2)
            c.request('GET', '/store.php')
            c.getresponse().read()
            return p
        except OSError:
            time.sleep(0.1)
    raise RuntimeError('php server did not start')


def call(port, method, query, token=None, body=None, header='X-Store-Token', extra=None):
    c = http.client.HTTPConnection('127.0.0.1', port, timeout=10)
    headers = dict(extra or {})
    if token:
        headers[header] = token if header == 'X-Store-Token' else 'Bearer ' + token
    c.request(method, '/store.php?' + query, body=body, headers=headers)
    r = c.getresponse()
    data = r.read()
    if port == 8771 and r.status == 200 and (method in ('PUT', 'DELETE') or (method == 'POST' and any(
            query.startswith(k) for k in ('put=', 'delete=', 'append=')))):
        WRITES[0] += 1
    return r.status, data


def write_config(path, data_dir, log_file, https, tokens, cap=0):
    workers = ''.join("        '%s' => '%s',\n" % (n, hashlib.sha256(t.encode()).hexdigest()) for n, t in tokens.items())
    path.write_text("<?php\nreturn [\n    'data_dir' => '%s',\n    'log_file' => '%s',\n    'require_https' => %s,\n"
                    "    'max_bytes' => 1000,\n    'max_total_bytes' => %d,\n    'workers' => [\n%s    ],\n];\n"
                    % (data_dir, log_file, 'true' if https else 'false', cap, workers))


def main():
    if not shutil.which('php'):
        print('php not found')
        return 2
    tmp = pathlib.Path(tempfile.mkdtemp(prefix='sharedstore-test-'))
    web = tmp / 'web'
    web.mkdir()
    shutil.copy(HERE / 'store.php', web / 'store.php')
    data = tmp / 'data'
    data.mkdir()
    log = tmp / 'store.log'
    tokens = {'alice': 'a' * 64, 'bob': 'b' * 64, 'carol': 'c' * 64}
    write_config(tmp / 'config.php', data, log, False, tokens)
    write_config(tmp / 'config_https.php', data, log, True, tokens)
    A, B, C = tokens['alice'], tokens['bob'], tokens['carol']
    p1 = start(web, tmp / 'config.php', 8771)
    p2 = start(web, tmp / 'config_https.php', 8772)
    qdata = tmp / 'qdata'
    qdata.mkdir()
    write_config(tmp / 'config_quota.php', qdata, tmp / 'q.log', False, tokens, cap=2500)
    p3 = start(web, tmp / 'config_quota.php', 8773)
    P = 8771
    try:
        s, _ = call(P, 'GET', 'whoami')
        check('no token is refused (401)', s == 401, str(s))
        s, _ = call(P, 'GET', 'whoami', 'z' * 64)
        check('unknown token is refused (401)', s == 401, str(s))
        s, d = call(P, 'GET', 'whoami', A)
        check('whoami names the worker', s == 200 and json.loads(d)['worker'] == 'alice', d.decode())
        s, d = call(P, 'GET', 'whoami', B, header='Authorization')
        check('a Bearer token works too', s == 200 and json.loads(d)['worker'] == 'bob', d.decode())

        body = b'hello from alice\n'
        s, d = call(P, 'PUT', 'path=workers/alice/notes/a.txt', A, body)
        ok = s == 200 and json.loads(d)['sha256'] == hashlib.sha256(body).hexdigest()
        check('alice writes in her own area, digest returned', ok, d.decode())
        s, d = call(P, 'GET', 'path=workers/alice/notes/a.txt', B)
        check('bob reads it back byte for byte', s == 200 and d == body, str(s))
        s, d = call(P, 'GET', 'stat=workers/alice/notes/a.txt', B)
        check('stat gives the same digest', s == 200 and json.loads(d)['sha256'] == hashlib.sha256(body).hexdigest())
        s, _ = call(P, 'PUT', 'path=workers/alice/notes/a.txt', A, b'replaced\n')
        s2, d = call(P, 'GET', 'path=workers/alice/notes/a.txt', A)
        check('alice may replace her own file', s == 200 and d == b'replaced\n')

        s, _ = call(P, 'PUT', 'path=workers/bob/x.txt', A, b'x')
        check("alice may not write in bob's area (403)", s == 403, str(s))
        s, _ = call(P, 'PUT', 'path=flags/bob/f', A, b'x')
        check("alice may not write bob's flags (403)", s == 403, str(s))
        s, _ = call(P, 'PUT', 'path=flags/alice/state', A, b'busy\n')
        s2, d = call(P, 'GET', 'path=flags/alice/state', B)
        check('flags: alice writes hers, bob reads it', s == 200 and d == b'busy\n')
        s, _ = call(P, 'PUT', 'path=top.txt', A, b'x')
        check('nothing outside the areas is writable (403)', s == 403, str(s))
        s, _ = call(P, 'PUT', 'path=workers/alice', A, b'x')
        check('an area root is not a file you own (403)', s == 403, str(s))

        s, _ = call(P, 'PUT', 'path=cited/cert/k140.drup', B, b'proof\n')
        check('anyone may create a cited file', s == 200, str(s))
        s, _ = call(P, 'PUT', 'path=cited/cert/k140.drup', B, b'other\n')
        s2, d = call(P, 'GET', 'path=cited/cert/k140.drup', A)
        check('a cited file is never overwritten (409), content kept', s == 409 and d == b'proof\n', str(s))
        s, _ = call(P, 'DELETE', 'path=cited/cert/k140.drup', B)
        check('a cited file cannot be deleted (403)', s == 403, str(s))

        s1, _ = call(P, 'POST', 'append=log/manifest.jsonl', A, b'{"a": 1}\n')
        s2, _ = call(P, 'POST', 'append=log/manifest.jsonl', B, b'{"b": 2}\n')
        s3, d = call(P, 'GET', 'path=log/manifest.jsonl', A)
        check('log/: anyone appends, lines kept in order', (s1, s2, s3) == (200, 200, 200) and d == b'{"a": 1}\n{"b": 2}\n')
        s, _ = call(P, 'PUT', 'path=log/manifest.jsonl', A, b'wiped')
        check('log/ cannot be replaced (403)', s == 403, str(s))
        s, _ = call(P, 'DELETE', 'path=log/manifest.jsonl', A)
        check('log/ cannot be deleted (403)', s == 403, str(s))

        bad = ['../etc/passwd', 'workers/alice/../../x', '/etc/passwd', '.hidden', 'workers/alice/.tmp-x',
               'workers/alice/a\\b', 'workers//alice/x', 'workers/alice/x/', '']
        codes = [call(P, 'PUT', 'path=' + q, A, b'x')[0] for q in bad]
        check('bad paths are refused (400): ' + ', '.join(repr(b) for b in bad), all(c == 400 for c in codes),
              str(codes))
        codes = [call(P, 'GET', 'list=' + q, A)[0] for q in ['..', '../..', '/']]
        check('listing outside the data folder is refused (400)', all(c == 400 for c in codes), str(codes))

        s, _ = call(P, 'PUT', 'path=workers/alice/big.bin', A, b'x' * 2000)
        leftovers = [f.name for f in (data / 'workers' / 'alice').iterdir() if f.name.startswith('.tmp')]
        check('a body over the limit is refused (413), nothing left behind',
              s == 413 and not (data / 'workers/alice/big.bin').exists() and not leftovers, str(s))

        s, d = call(P, 'GET', 'list=workers/alice', B)
        names = [e['name'] for e in json.loads(d)['entries']]
        check('listing shows the folder and hides dotfiles', s == 200 and 'notes' in names and not any(
            n.startswith('.') for n in names), d.decode())

        s, _ = call(P, 'DELETE', 'path=workers/alice/notes/a.txt', B)
        check("bob may not delete alice's file (403)", s == 403, str(s))
        s, _ = call(P, 'DELETE', 'path=workers/alice/notes/a.txt', A)
        s2, _ = call(P, 'GET', 'path=workers/alice/notes/a.txt', A)
        check('alice deletes her own file; it is gone', s == 200 and s2 == 404, '%s %s' % (s, s2))

        s, _ = call(P, 'POST', 'put=workers/bob/fallback.txt', B, b'via post\n')
        s2, d = call(P, 'GET', 'path=workers/bob/fallback.txt', A)
        s3, _ = call(P, 'POST', 'delete=workers/bob/fallback.txt', B)
        s4, _ = call(P, 'GET', 'path=workers/bob/fallback.txt', A)
        check('POST fallbacks for PUT and DELETE work', (s, s2, s3, s4) == (200, 200, 200, 404) and d == b'via post\n',
              str((s, s2, s3, s4)))

        s, d = call(8772, 'GET', 'whoami', A)
        check('with require_https on, plain HTTP is refused (403)', s == 403, '%s %s' % (s, d))
        s, d = call(8772, 'GET', 'whoami', A, extra={'X-Forwarded-Proto': 'https'})
        check('a spoofed X-Forwarded-Proto over plain HTTP is refused too (403)', s == 403, '%s %s' % (s, d))

        r = [call(8773, 'PUT', 'path=workers/alice/q%d.bin' % i, A, b'q' * 900)[0] for i in range(2)]
        s, d = call(8773, 'PUT', 'path=cited/q.bin', A, b'q' * 900)
        s2, _ = call(8773, 'POST', 'append=log/q.log', A, b'q' * 900)
        left = [f for f in qdata.rglob('.tmp-*')]
        check('the total cap: two writes fit, the third and an append are refused (507), nothing left behind',
              r == [200, 200] and s == 507 and s2 == 507 and not left and not (qdata / 'cited/q.bin').exists(),
              str((r, s, s2, len(left))))

        project_checks(P, data)

        lines = [json.loads(l) for l in log.read_text().splitlines()]
        ops = [(l['worker'], l['op']) for l in lines]
        check('every successful write (%d) is logged with the worker' % WRITES[0], len(lines) == WRITES[0]
              and ('alice', 'put') in ops and ('bob', 'append') in ops and ('alice', 'delete') in ops
              and ('carol', 'delete') in ops, '%d logged, %s' % (len(lines), ops))
    finally:
        for p in (p1, p2, p3):
            p.terminate()
            p.wait()
        shutil.rmtree(tmp)
    print('\n%d of %d checks pass' % (sum(RESULTS), len(RESULTS)))
    return 0 if all(RESULTS) else 1


def project_checks(P, data):
    """The project's areas at the top of the data folder, which is the project folder: postboxes, flags and
    share-scratch."""
    A, B, C = 'a' * 64, 'b' * 64, 'c' * 64

    s, _ = call(P, 'PUT', 'path=postbox/alice/JOINED', A, b'alice joined\n')
    s2, _ = call(P, 'PUT', 'path=postbox/bob/JOINED', B, b'bob joined\n')
    check('alice and bob each make their own postbox by joining', (s, s2) == (200, 200), str((s, s2)))
    s, _ = call(P, 'PUT', 'path=postbox/carol/JOINED', A, b'x')
    check("alice may not make carol's postbox (403), nothing made",
          s == 403 and not (data / 'postbox/carol').exists(), str(s))

    flag = b'flag: 20261117T1530Z-bob-L12\nkind: READ\nfrom: bob\nto: alice, carol\n'
    name = '20261117T1530Z-bob-L12-READ.flag'
    s, _ = call(P, 'PUT', 'path=postbox/alice/%s' % name, B, flag)
    s2, d = call(P, 'GET', 'path=postbox/alice/%s' % name, C)
    check("bob posts a flag into alice's postbox; carol reads it", s == 200 and s2 == 200 and d == flag, str((s, s2)))
    s, _ = call(P, 'PUT', 'path=postbox/alice/%s' % name, B, b'changed\n')
    s2, d = call(P, 'GET', 'path=postbox/alice/%s' % name, A)
    check('a posted flag is never replaced by its sender (409), content kept', s == 409 and d == flag, str(s))
    s, _ = call(P, 'POST', 'append=postbox/alice/%s' % name, B, b'more\n')
    s2, _ = call(P, 'POST', 'append=postbox/alice/%s' % name, A, b'more\n')
    check('nobody appends to a flag (403, 403)', (s, s2) == (403, 403), str((s, s2)))
    s, _ = call(P, 'PUT', 'path=postbox/carol/%s' % name, B, flag)
    check('a flag to a worker who has not joined is refused (404), no postbox made',
          s == 404 and not (data / 'postbox/carol').exists(), str(s))
    bad = ['20261117T1531Z-carol-L12-READ.flag', 'note.txt', 'sub/20261117T1532Z-bob-L12-READ.flag',
           '20261117T1533Z-bob-L12-READ.txt', 'L12-bob-READ.flag']
    codes = [call(P, 'PUT', 'path=postbox/alice/%s' % n, B, flag)[0] for n in bad]
    check("in alice's postbox bob may create only a flag that names him as sender (403 each)",
          all(c == 403 for c in codes), str(codes))
    s, _ = call(P, 'PUT', 'path=postbox/alice/20261117T1534Z-bob-L13-READ.flag', B, b'f' * 2000)
    check('a flag over the size limit is refused (413), nothing left',
          s == 413 and not [f for f in (data / 'postbox/alice').iterdir() if f.name.startswith('.tmp')], str(s))
    s, d = call(P, 'GET', 'list=postbox/alice', C)
    names = [e['name'] for e in json.loads(d)['entries']] if s == 200 else []
    check("anyone lists alice's postbox (the multi-agent check)", s == 200 and sorted(names) == sorted(['JOINED', name]),
          d.decode())
    s, _ = call(P, 'DELETE', 'path=postbox/alice/%s' % name, B)
    s2, _ = call(P, 'POST', 'delete=postbox/alice/%s' % name, C)
    check("neither the sender nor another worker may remove alice's flag (403, 403)", (s, s2) == (403, 403),
          str((s, s2)))
    s, _ = call(P, 'DELETE', 'path=postbox/alice/%s' % name, A)
    s2, _ = call(P, 'GET', 'path=postbox/alice/%s' % name, A)
    check('alice removes the processed flag from her own postbox; it is gone', (s, s2) == (200, 404), str((s, s2)))

    s, _ = call(P, 'PUT', 'path=share-scratch/carol/S3/essay.md', C, b'essay v1\n')
    s2, d = call(P, 'GET', 'path=share-scratch/carol/S3/essay.md', A)
    check('carol shares a file in a folder of her share-scratch; alice reads it', (s, s2) == (200, 200)
          and d == b'essay v1\n', str((s, s2)))
    s, _ = call(P, 'PUT', 'path=share-scratch/carol/S3/essay.md', A, b'x')
    s2, _ = call(P, 'POST', 'append=share-scratch/carol/S3/essay.md', A, b'x')
    s3, _ = call(P, 'DELETE', 'path=share-scratch/carol/S3/essay.md', A)
    check("alice may not write, append to or delete carol's shared file (403 each)", (s, s2, s3) == (403, 403, 403),
          str((s, s2, s3)))
    s, _ = call(P, 'POST', 'append=share-scratch/carol/S3/log.txt', C, b'line\n')
    s2, _ = call(P, 'DELETE', 'path=share-scratch/carol/S3/essay.md', C)
    check('carol appends to and deletes her own shared files', (s, s2) == (200, 200), str((s, s2)))
    codes = [call(P, 'PUT', 'path=' + q, A, b'x')[0] for q in (
        'README.md', 'postbox/README', 'share-scratch/x', 'scratch/rule30reset/postbox/alice/x',
        'other/postbox/alice/x')]
    check('the rest of the project folder, the old prefixed paths and other folders are read-only (403 each)',
          all(c == 403 for c in codes) and not (data / 'scratch').exists(), str(codes))


if __name__ == '__main__':
    sys.exit(main())
