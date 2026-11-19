#!/usr/bin/env python3
"""test_container.py: builds the store's container image and checks the running container.

COMMAND:  python3 tools/store/docker/test_container.py [--image NAME] [--no-build] [--no-acme]
          (needs docker and openssl; nothing leaves this machine except image pulls)

Four parts, every check printing PASS or FAIL, exit non-zero if any fails:

1. The server's own checks. test_store.py runs unchanged except that each of its three servers is a container
   (plain HTTP on 127.0.0.1, settings from the environment) instead of PHP's built-in server.
2. The container's checks: it runs as an ordinary user on a read-only filesystem with no capabilities; HTTPS works
   with a private certificate authority and with certificate files; nothing but /store.php is served; no token
   reaches the container's log; the token tool works; data and certificates outlive the container; a wrong
   installation is refused with a message that says what to fix.
3. The findings of the security review (ledger I16): nothing private is reachable through the data folder; a
   misspelt security setting stops the start; a damaged token registry is never replaced; token changes made at the
   same moment all take effect; a change that cannot be saved says so; writes that arrive together cannot exceed
   the store's cap.
4. The certificate a public authority issues. Pebble, the test server of the Let's Encrypt project, plays the
   authority on a private Docker network; the container must obtain a certificate from it by the TLS-ALPN-01
   challenge on its HTTPS port alone, as it will from Let's Encrypt behind a router that forwards port 443 only.
"""
import argparse
import hashlib
import http.client
import json
import os
import pathlib
import shutil
import socket
import ssl
import subprocess
import sys
import tempfile
import threading
import time

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import test_store as T   # noqa: E402

IMAGE = 'rule30-store:test'
PEBBLE = 'ghcr.io/letsencrypt/pebble:latest'
HARD = ['--read-only', '--tmpfs', '/tmp', '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges:true']
ROOT = os.getuid() == 0
RUNAS = '568:568' if ROOT else '%d:%d' % (os.getuid(), os.getgid())   # as root, the real thing: the apps user
RESULTS = []
LIVE = []      # containers and networks to remove at the end


def check(name, ok, detail=''):
    RESULTS.append(bool(ok))
    print('%s  %s%s' % ('PASS' if ok else 'FAIL', name, ('  (' + str(detail)[:400] + ')') if detail and not ok else ''))


def docker(*args, check_rc=False, timeout=180):
    r = subprocess.run(['docker', *args], capture_output=True, text=True, timeout=timeout)
    if check_rc and r.returncode:
        raise RuntimeError('docker %s: %s' % (' '.join(args[:3]), r.stderr.strip()[-600:]))
    return r


def own(path):
    """Hand a folder to the user the container runs as."""
    if ROOT:
        subprocess.run(['chown', '-R', RUNAS, str(path)], check=True)


def run_store(name, mounts, env, port=None, inner=8443, extra=()):
    docker('rm', '-f', name)
    args = ['run', '-d', '--name', name, '--user', RUNAS, *HARD, *extra]
    for src, dst in mounts:
        args += ['-v', '%s:%s' % (src, dst)]
    for k, v in env.items():
        args += ['-e', '%s=%s' % (k, v)]
    if port:
        args += ['-p', '127.0.0.1:%d:%d' % (port, inner)]
    docker(*args, IMAGE, check_rc=True)
    LIVE.append(name)
    return name


def logs(name):
    r = docker('logs', name)
    return r.stdout + r.stderr


def wait_for(fn, seconds=40, what='the container'):
    end = time.time() + seconds
    last = None
    while time.time() < end:
        try:
            v = fn()
            if v:
                return v
        except (OSError, ssl.SSLError, http.client.HTTPException) as e:
            last = e
        time.sleep(0.3)
    raise RuntimeError('%s did not answer in %d s (%s)' % (what, seconds, last))


def https(port, name, cafile, method='GET', query='whoami', token=None, body=None, headers=None, path='/store.php'):
    """One HTTPS request to 127.0.0.1:port, asking for the site `name` and verifying its certificate like any client."""
    ctx = ssl.create_default_context(cafile=str(cafile))
    c = http.client.HTTPSConnection(name, port, timeout=30, context=ctx)
    c.sock = ctx.wrap_socket(socket.create_connection(('127.0.0.1', port), timeout=30), server_hostname=name)
    h = dict(headers or {})
    if token:
        h['X-Store-Token'] = token
    c.request(method, path + ('?' + query if query else ''), body=body, headers=h)
    r = c.getresponse()
    data = r.read()
    c.close()
    return r.status, data, r.getheader('Content-Type', '')


# ---------------------------------------------------------------- part 1: the server's own checks, on containers

CONFIGS = {}


class Handle:
    def __init__(self, name):
        self.name = name

    def terminate(self):
        docker('rm', '-f', self.name)

    def wait(self):
        pass


def write_config(path, data_dir, log_file, https_only, tokens, cap=0):
    workers = path.with_suffix('.workers.json')
    workers.write_text(json.dumps({n: hashlib.sha256(t.encode()).hexdigest() for n, t in tokens.items()}))
    CONFIGS[str(path)] = (pathlib.Path(data_dir), pathlib.Path(log_file), https_only, cap, workers)


def start(root, cfg_path, port):
    data, log, https_only, cap, workers = CONFIGS[str(cfg_path)]
    tmp = cfg_path.parent
    own(tmp)
    rel = lambda p: '/work/' + str(p.relative_to(tmp))   # noqa: E731
    name = run_store('store-test-%d' % port, [(tmp, '/work')], {
        'STORE_TLS': 'off', 'STORE_REQUIRE_HTTPS': 'true' if https_only else 'false',
        'STORE_DATA_DIR': rel(data), 'STORE_LOG_FILE': rel(log), 'STORE_WORKERS_FILE': rel(workers),
        'STORE_MAX_BYTES': '1000', 'STORE_MAX_TOTAL_BYTES': str(cap)}, port=port, inner=8080)

    def up():
        c = http.client.HTTPConnection('127.0.0.1', port, timeout=2)
        c.request('GET', '/store.php')
        return c.getresponse().read() is not None
    try:
        wait_for(up, what='the store on port %d' % port)
    except RuntimeError:
        print(logs(name)[-1500:])
        raise
    return Handle(name)


def server_checks():
    print("\n== 1. the server's own checks (test_store.py), each server a container ==")
    which = shutil.which
    T.start, T.write_config = start, write_config
    shutil.which = lambda cmd, *a, **k: 'container' if cmd == 'php' else which(cmd, *a, **k)
    try:
        rc = T.main()
    finally:
        shutil.which = which
    check("the server's own checks all pass on the container (%d of %d)" % (sum(T.RESULTS), len(T.RESULTS)),
          rc == 0 and len(T.RESULTS) >= 45)


# ---------------------------------------------------------------- part 2: the container's checks

def refused(env, mounts, needle, name, user=None):
    """The container must exit at once, non-zero, saying `needle` and 'not started'."""
    cname = 'store-test-refused'
    docker('rm', '-f', cname)
    args = ['run', '-d', '--name', cname, '--user', user or RUNAS, *HARD]
    for src, dst in mounts:
        args += ['-v', '%s:%s' % (src, dst)]
    for k, v in env.items():
        args += ['-e', '%s=%s' % (k, v)]
    docker(*args, IMAGE, timeout=60)
    state, end = ['true', '0'], time.time() + 10
    while time.time() < end:
        state = docker('inspect', '-f', '{{.State.Running}} {{.State.ExitCode}}', cname).stdout.split() or state
        if state[0] == 'false':
            break
        time.sleep(0.2)
    out = logs(cname)
    docker('rm', '-f', cname)
    check(name, state[0] == 'false' and state[1] != '0' and needle in out and 'not started' in out,
          'it started' if state[0] == 'true' else out.strip()[-300:])


def container_checks(tmp):
    print('\n== 2. the container ==')
    data, config = tmp / 'data', tmp / 'config'
    data.mkdir()
    config.mkdir()
    own(tmp)
    vols = [(data, '/data'), (config, '/config')]

    # A wrong installation says what is wrong and does not start.
    refused({'STORE_TLS': 'internal'}, [], 'map a NAS folder', 'with no folder mapped it refuses to start and says so')
    locked = tmp / 'locked'
    locked.mkdir()
    os.chmod(locked, 0o555)
    refused({'STORE_TLS': 'internal'}, [(locked, '/data'), (config, '/config')], 'not writable',
            'with a data folder its user cannot write it refuses to start and says so',
            user='12345:12345' if ROOT else None)
    refused({'STORE_TLS': 'acme'}, vols, 'needs STORE_DOMAIN', 'acme without a name is refused')
    refused({'STORE_TLS': 'sideways'}, vols, 'must be acme, internal, files or off', 'an unknown STORE_TLS is refused')
    refused({'STORE_TLS': 'internal', 'STORE_DOMAIN': 'x.test { respond 200 }'}, vols, 'bare host name',
            'a name carrying web-server syntax is refused')
    refused({'STORE_TLS': 'off', 'STORE_HTTP_PORT': '443'}, vols, 'cannot listen on port 443',
            'plain HTTP on port 443 is refused')

    # The token tool before the server has ever run.
    r = docker('run', '--rm', '--user', RUNAS, *HARD, '-v', '%s:/config' % config, IMAGE, 'store-admin', 'token', 'add', 'alice')
    A = r.stdout.strip().splitlines()[-1] if r.returncode == 0 and r.stdout.strip() else ''
    stored = json.loads((config / 'workers.json').read_text()) if (config / 'workers.json').exists() else {}
    check('store-admin makes a token before the first start; only its SHA-256 is stored',
          len(A) == 64 and stored == {'alice': hashlib.sha256(A.encode()).hexdigest()}
          and A not in (config / 'workers.json').read_text(), r.stderr)

    # HTTPS with the container's own certificate authority.
    name = run_store('store-test-tls', vols, {'STORE_TLS': 'internal', 'STORE_DOMAIN': 'store.test'}, port=8774,
                     extra=['--health-interval', '2s'])
    ca = config / 'tls/pki/authorities/local/root.crt'
    wait_for(lambda: ca.exists() and https(8774, 'store.test', ca)[0] in (401, 403), what='the HTTPS store')
    s, d, ct = https(8774, 'store.test', ca, token=A)
    check('over HTTPS on a port other than 443 the store knows it is HTTPS: whoami answers',
          s == 200 and json.loads(d) == {'worker': 'alice'} and ct == 'application/json', '%s %s' % (s, d))
    c = http.client.HTTPConnection('127.0.0.1', 8774, timeout=10)
    c.request('GET', '/store.php?whoami', headers={'X-Store-Token': A})
    r = c.getresponse()
    check('plain HTTP to the HTTPS port never reaches the store (400)', r.status == 400 and b'worker' not in r.read(), r.status)

    codes = [https(8774, 'store.test', ca, token=A, query='', path=p)[0] for p in (
        '/', '/index.php', '/config.php', '/store-admin', '/store.php/extra', '/.env', '/app/config.php',
        '/store.php%00.txt', '/public/store.php')]
    check('nothing but /store.php is served (404 or 400 each)', all(c in (400, 404) for c in codes), codes)
    s, d, _ = https(8774, 'store.test', ca, 'POST', 'put=workers/alice/m.txt', A, b'--x--\r\n',
                    {'Content-Type': 'multipart/form-data; boundary=x'})
    check('a multipart body is refused before PHP sees it (415), nothing written',
          s == 415 and not (data / 'workers/alice/m.txt').exists(), s)

    big = os.urandom(5 * 1024 * 1024)
    s, d, _ = https(8774, 'store.test', ca, 'PUT', 'path=workers/alice/big.bin', A, big)
    s2, d2, ct2 = https(8774, 'store.test', ca, 'GET', 'path=workers/alice/big.bin', A)
    f = data / 'workers/alice/big.bin'
    check('a 5 MB file goes up and comes back byte for byte', s == 200 and s2 == 200 and d2 == big
          and json.loads(d)['sha256'] == hashlib.sha256(big).hexdigest() and ct2 == 'application/octet-stream',
          '%s %s' % (s, s2))
    st = f.stat() if f.exists() else None
    check('the file is on the mapped folder, owned by the container user %s' % RUNAS,
          st is not None and '%d:%d' % (st.st_uid, st.st_gid) == RUNAS and st.st_size == len(big))
    wlog = data / 'store.log'
    check('the write log is kept outside what the store serves',
          (config / 'store.log').exists() and not wlog.exists()
          and https(8774, 'store.test', ca, 'GET', 'path=store.log', A)[0] == 404)

    r = docker('exec', name, 'store-admin', 'token', 'add', 'bob')
    B = r.stdout.strip().splitlines()[-1] if r.returncode == 0 else ''
    s, d, _ = https(8774, 'store.test', ca, token=B)
    names = docker('exec', name, 'store-admin', 'token', 'list').stdout.split()
    check('a token added while the server runs works at once', s == 200 and json.loads(d) == {'worker': 'bob'}
          and names == ['alice', 'bob'], '%s %s %s' % (s, d, names))
    docker('exec', name, 'store-admin', 'token', 'remove', 'bob')
    check('a removed token is refused at once (401)', https(8774, 'store.test', ca, token=B)[0] == 401)
    C = 'c' * 64
    r = docker('exec', name, 'store-admin', 'token', 'import', 'carol', hashlib.sha256(C.encode()).hexdigest())
    s, d, _ = https(8774, 'store.test', ca, token=C)
    check('a token a worker already holds is kept by importing its SHA-256',
          r.returncode == 0 and s == 200 and json.loads(d) == {'worker': 'carol'}, r.stderr)
    r2 = docker('exec', name, 'store-admin', 'token', 'add', 'bad name')
    check('store-admin refuses a bad name', r2.returncode != 0 and 'bad name' not in (config / 'workers.json').read_text())

    out = logs(name)
    check('no token appears in the container log, and requests are logged',
          not any(t in out for t in (A, B, C)) and '"uri":"/store.php?whoami"' in out)
    check('nothing in the settings folder holds a token',
          not any(t.encode() in p.read_bytes() for p in config.rglob('*') if p.is_file() for t in (A, B, C)))

    who = docker('exec', name, 'sh', '-c', 'id -u; id -g; grep -E "^(CapEff|CapBnd|NoNewPrivs)" /proc/1/status; '
                 'touch /app/public/x 2>&1; touch /usr/local/bin/x 2>&1').stdout
    check('it runs as %s with no capabilities, no new privileges, and a read-only filesystem' % RUNAS,
          who.split()[:2] == RUNAS.split(':') and who.count('0000000000000000') == 2 and 'NoNewPrivs:\t1' in who
          and who.count('Read-only file system') == 2, who)

    def healthy():
        return docker('inspect', '-f', '{{.State.Health.Status}}', name).stdout.strip() == 'healthy'
    try:
        ok = wait_for(healthy, 30, 'the health check')
    except RuntimeError:
        ok = False
    check("the image's health check reports healthy", ok, docker('inspect', '-f', '{{json .State.Health}}', name).stdout)

    warn = [l for l in out.splitlines() if '"level":"error"' in l or 'not formatted' in l]
    check('the server starts without errors in its log', not warn, warn[:2])

    # An update replaces the container: the data, the tokens and the certificate authority must still be there.
    before = ca.read_bytes()
    docker('rm', '-f', name)
    name = run_store('store-test-tls', vols, {'STORE_TLS': 'internal', 'STORE_DOMAIN': 'store.test'}, port=8774)
    wait_for(lambda: https(8774, 'store.test', ca)[0] in (401, 403), what='the HTTPS store, restarted')
    s, d, _ = https(8774, 'store.test', ca, 'GET', 'path=workers/alice/big.bin', A)
    check('after the container is replaced: same data, same tokens, same certificate authority',
          s == 200 and d == big and ca.read_bytes() == before)
    docker('rm', '-f', name)

    # HTTPS with certificate files the owner supplies.
    cert, key = config / 'tls/cert.pem', config / 'tls/key.pem'
    subprocess.run(['openssl', 'req', '-x509', '-newkey', 'ec', '-pkeyopt', 'ec_paramgen_curve:prime256v1', '-nodes',
                    '-keyout', str(key), '-out', str(cert), '-days', '2', '-subj', '/CN=files.test',
                    '-addext', 'subjectAltName=DNS:files.test'], check=True, capture_output=True)
    own(config)
    name = run_store('store-test-files', vols, {'STORE_TLS': 'files', 'STORE_DOMAIN': 'files.test',
                                                'STORE_HTTPS_PORT': '9443'}, port=8775, inner=9443)
    wait_for(lambda: https(8775, 'files.test', cert)[0] in (401, 403), what='the store with certificate files')
    s, d, _ = https(8775, 'files.test', cert, token=A)
    check('with certificate files, and another listening port set by STORE_HTTPS_PORT, whoami answers over HTTPS',
          s == 200 and json.loads(d) == {'worker': 'alice'}, '%s %s' % (s, d))
    docker('rm', '-f', name)

    # Behind a reverse proxy: plain HTTP, HTTPS judged by the proxy's header only when told to trust it.
    name = run_store('store-test-proxy', vols, {'STORE_TLS': 'off', 'STORE_TRUST_FORWARDED_PROTO': 'true'}, port=8776,
                     inner=8080)

    def plain(headers):
        c = http.client.HTTPConnection('127.0.0.1', 8776, timeout=10)
        c.request('GET', '/store.php?whoami', headers=dict(headers, **{'X-Store-Token': A}))
        return c.getresponse().status
    wait_for(lambda: plain({}) == 403, what='the store behind a proxy')
    codes = [plain({'X-Forwarded-Proto': 'https'}), plain({}), plain({'Host': 'store.test:443'}),
             plain({'Host': 'store.test:0443'}), plain({'Host': '[::1]:443'})]
    check("behind a proxy: its X-Forwarded-Proto is believed (200); without it, and with a Host header that names "
          "port 443, plain HTTP is refused (403 each)", codes == [200, 403, 403, 403, 403], codes)
    docker('rm', '-f', name)


# ---------------------------------------------------------------- the security review's findings (ledger I16)

def admin(name, *args):
    """store-admin inside the running container `name`: (exit code, stdout, stderr)."""
    r = docker('exec', name, 'store-admin', *args)
    return r.returncode, r.stdout, r.stderr


def together(port, token, jobs):
    """Send every request up to its last byte, then all the last bytes at once: the writes arrive together."""
    barrier = threading.Barrier(len(jobs))
    codes = [0] * len(jobs)

    def one(i, method, query, body):
        s = socket.create_connection(('127.0.0.1', port), timeout=30)
        s.sendall(('%s /store.php?%s HTTP/1.1\r\nHost: 127.0.0.1:%d\r\nX-Store-Token: %s\r\nContent-Length: %d\r\n'
                   'Connection: close\r\n\r\n' % (method, query, port, token, len(body))).encode() + body[:-1])
        try:
            barrier.wait(timeout=20)
        except threading.BrokenBarrierError:
            pass
        s.sendall(body[-1:])
        data = b''
        while True:
            chunk = s.recv(65536)
            if not chunk:
                break
            data += chunk
        s.close()
        codes[i] = int(data.split(b' ', 2)[1]) if data.startswith(b'HTTP/') else 0
    threads = [threading.Thread(target=one, args=(i, *job)) for i, job in enumerate(jobs)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    return codes


def review_checks(tmp):
    print("\n== 3. the security review's findings (ledger I16) ==")
    base = tmp / 'review'
    data, config = base / 'data', base / 'config'
    for d in (data, config):
        d.mkdir(parents=True)
    A, C = 'a' * 64, 'c' * 64
    sha = lambda t: hashlib.sha256(t.encode()).hexdigest()   # noqa: E731
    registry = config / 'workers.json'
    registry.write_text(json.dumps({'alice': sha(A), 'carol': sha(C)}))
    own(base)
    vols = [(data, '/data'), (config, '/config')]
    plain_env = {'STORE_TLS': 'off', 'STORE_REQUIRE_HTTPS': 'false'}

    def whoami(port, token):
        c = http.client.HTTPConnection('127.0.0.1', port, timeout=10)
        c.request('GET', '/store.php?whoami', headers={'X-Store-Token': token})
        r = c.getresponse()
        r.read()
        return r.status

    # I16.3: nothing private may be reachable through the data folder.
    reach = 'can be reached through the data folder'
    refused(plain_env, [(data, '/data'), (data, '/config')], reach,
            'the same folder mapped as data and as settings is refused')
    nested = base / 'nested'
    (nested / 'private').mkdir(parents=True)
    own(nested)
    refused(plain_env, [(nested, '/data'), (nested / 'private', '/config')], reach,
            'a settings folder inside the data folder is refused')
    refused(dict(plain_env, STORE_LOG_FILE='/data/store.log'), vols, reach,
            'a write log placed in the data folder is refused')
    (data / 'private').mkdir()
    own(data)
    refused(dict(plain_env, STORE_WORKERS_FILE='/data/private/workers.json'), vols, reach,
            'a token registry placed under the data folder is refused')
    refused({'STORE_TLS': 'internal', 'STORE_DOMAIN': 'store.test', 'STORE_TLS_DIR': '/data/private/tls'}, vols, reach,
            'a certificate folder placed under the data folder is refused')
    left = sorted(q.name for q in (data / 'private').iterdir())
    check('a refused start leaves nothing behind in the data folder', not left, left)
    shutil.rmtree(data / 'private')

    # I16.5: a misspelt security setting stops the start, and never reads as "off".
    refused({'STORE_TLS': 'off', 'STORE_REQUIRE_HTTPS': 'ture'}, vols, 'must be true or false',
            'a misspelt STORE_REQUIRE_HTTPS is refused')
    refused({'STORE_TLS': 'off', 'STORE_TRUST_FORWARDED_PROTO': 'yes please'}, vols, 'must be true or false',
            'a misspelt STORE_TRUST_FORWARDED_PROTO is refused')
    refused(dict(plain_env, STORE_MAX_TOTAL_BYTES='2GB'), vols, 'whole number of bytes', 'a size that is not a number is refused')
    r = docker('run', '--rm', '--user', RUNAS, *HARD, '-v', '%s:/config' % config, '-e', 'STORE_REQUIRE_HTTPS=ture',
               '-e', 'STORE_TRUST_FORWARDED_PROTO=ture', IMAGE, 'store-admin', 'check')
    cfg = json.loads(r.stdout) if r.returncode == 0 and r.stdout.strip().startswith('{') else {}
    check('were such a value ever to reach the settings file, it keeps HTTPS required and the proxy header unbelieved',
          cfg.get('require_https') is True and cfg.get('trust_forwarded_proto') is False, r.stdout[-200:] + r.stderr[-200:])

    name = run_store('store-test-review', vols, plain_env, port=8779, inner=8080)
    wait_for(lambda: whoami(8779, A) == 200, what='the store for the review checks')

    # I16.4: a registry that exists but cannot be read is never taken for an empty one.
    good = registry.read_bytes()
    results = []
    for damaged in (b'{"alice": "' + sha(A).encode()[:40], b'["alice"]', b'{"alice": "not-a-hash"}',
                    json.dumps({'alice': sha(A), 'twin': sha(A)}).encode()):
        registry.write_bytes(damaged)
        rc1, out1, err1 = admin(name, 'token', 'add', 'mallory')
        rc2, out2, err2 = admin(name, 'token', 'import', 'mallory', sha('m' * 64))
        rc3, out3, err3 = admin(name, 'token', 'remove', 'alice')
        rc4, out4, err4 = admin(name, 'token', 'list')
        results.append(rc1 != 0 and rc2 != 0 and rc3 != 0 and rc4 != 0 and 'damaged' in err1 and not out1.strip()
                       and registry.read_bytes() == damaged and whoami(8779, A) == 401)
    check('a damaged registry (cut short, a list, a bad hash, one token under two names) is never replaced, '
          'every change is refused, and it authenticates nobody', all(results), results)
    registry.write_bytes(b'{"alice": "not-a-hash"}')
    refused(plain_env, vols, 'repair or restore', 'the store refuses to start on a damaged registry and says so')
    registry.write_bytes(good)
    rc, out, err = admin(name, 'token', 'import', 'dave', sha(C))
    rc2, out2, err2 = admin(name, 'token', 'import', 'alice', sha('z' * 64))
    check("importing a token that already names another worker, or over a worker that has one, is refused",
          rc != 0 and 'already belongs' in err and rc2 != 0 and 'already has a token' in err2
          and registry.read_bytes() == good, err + err2)

    # I16.2: changes made at the same moment must all take effect.
    for n in ('old1', 'old2', 'old3', 'old4'):
        admin(name, 'token', 'add', n)
    script = ('cd /tmp; for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do store-admin token add new$i > add$i.out 2>&1 & done; '
              'for i in 1 2 3 4; do store-admin token remove old$i > rm$i.out 2>&1 & done; wait; '
              'for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do tail -n 1 add$i.out; done')
    r = docker('exec', name, 'sh', '-c', script)
    tokens = r.stdout.split()
    names = set(admin(name, 'token', 'list')[1].split())
    want = {'alice', 'carol'} | {'new%d' % i for i in range(1, 17)}
    check('twenty changes made at the same moment all take effect: sixteen additions kept, four removals kept',
          names == want and len(tokens) == 16 and all(len(t) == 64 for t in tokens)
          and all(whoami(8779, t) == 200 for t in tokens), sorted(names ^ want))
    mode = registry.stat().st_mode & 0o777
    stray = [q.name for q in config.iterdir() if '.tmp-' in q.name]
    check('the registry is readable by its owner only, and no temporary file is left', mode == 0o600 and not stray,
          '%o %s' % (mode, stray))
    docker('rm', '-f', name)

    # I16.1: a change that cannot be saved must say so, and must leave the old registry in force.
    uid, gid = RUNAS.split(':')
    small = ['--tmpfs', '/config:size=16k,mode=0700,uid=%s,gid=%s' % (uid, gid)]
    name = run_store('store-test-full', [(data, '/data')], plain_env, port=8779, inner=8080, extra=small)
    wait_for(lambda: whoami(8779, A) == 401, what='the store on a small settings folder')
    rc, out, err = admin(name, 'token', 'add', 'alice')
    T = out.strip().splitlines()[-1] if rc == 0 and out.strip() else ''
    docker('exec', name, 'sh', '-c', 'dd if=/dev/zero of=/config/filler bs=1k count=64 2>/dev/null; true')
    before = docker('exec', name, 'cat', '/config/workers.json').stdout
    rc1, out1, err1 = admin(name, 'token', 'remove', 'alice')
    rc2, out2, err2 = admin(name, 'token', 'add', 'bob')
    after = docker('exec', name, 'cat', '/config/workers.json').stdout
    left = docker('exec', name, 'sh', '-c', 'ls -a /config | grep -c tmp-').stdout.strip()
    check('with no space left, a removal and an addition both report failure, print no token, leave the registry '
          'as it was, and the old token still works',
          len(T) == 64 and rc1 != 0 and 'removed' not in out1 and rc2 != 0 and not out2.strip()
          and before == after and before.strip() and left == '0' and whoami(8779, T) == 200,
          (rc1, out1, err1, rc2, out2, err2, left))
    docker('exec', name, 'rm', '/config/filler')
    rc3, out3, err3 = admin(name, 'token', 'remove', 'alice')
    check('once there is space, the removal succeeds and the token is refused at once',
          rc3 == 0 and 'removed' in out3 and whoami(8779, T) == 401, err3)
    docker('rm', '-f', name)

    if ROOT:
        # The save's last step fails (a registry owned by another user, in a folder that forbids replacing it).
        sticky = base / 'sticky'
        sticky.mkdir()
        os.chmod(sticky, 0o1777)
        (sticky / 'workers.json').write_text(json.dumps({'alice': sha(A)}))
        os.chmod(sticky / 'workers.json', 0o644)
        name = run_store('store-test-sticky', [(data, '/data'), (sticky, '/config')], plain_env, port=8779, inner=8080)
        wait_for(lambda: whoami(8779, A) == 200, what='the store on a registry it cannot replace')
        rc, out, err = admin(name, 'token', 'remove', 'alice')
        stray = [q.name for q in sticky.iterdir() if '.tmp-' in q.name]
        check('when the new registry cannot replace the old one, the removal reports failure and the token still works',
              rc != 0 and 'removed' not in out and whoami(8779, A) == 200 and not stray, (rc, out, err, stray))
        docker('rm', '-f', name)
    else:
        print('SKIP  the failed-replacement check needs root to make a registry owned by another user')

    # I16.6: writes that arrive together cannot both be admitted against the same remaining space.
    qdata = base / 'qdata'
    qdata.mkdir()
    own(qdata)
    registry.write_bytes(good)
    own(config)
    name = run_store('store-test-quota', [(qdata, '/data'), (config, '/config')],
                     dict(plain_env, STORE_MAX_BYTES='1000', STORE_MAX_TOTAL_BYTES='2500'), port=8779, inner=8080)
    wait_for(lambda: whoami(8779, A) == 200, what='the store with a small cap')
    rounds = []
    for n in range(6):
        jobs = [('PUT', 'path=workers/alice/r%d-%d.bin' % (n, i), b'q' * 900) for i in range(3)]
        jobs += [('POST', 'append=workers/alice/r%d-%d.log' % (n, i), b'q' * 900) for i in range(3)]
        codes = together(8779, A, jobs)
        files = [f for f in qdata.rglob('*') if f.is_file() and f.name != '.lock']
        used = sum(f.stat().st_size for f in files if not f.name.startswith('.tmp-'))
        rounds.append((sorted(codes), used, len([f for f in files if f.name.startswith('.tmp-')])))
        for f in files:
            if not f.name.startswith('.'):
                c = http.client.HTTPConnection('127.0.0.1', 8779, timeout=10)
                c.request('DELETE', '/store.php?path=' + str(f.relative_to(qdata)), headers={'X-Store-Token': A})
                c.getresponse().read()
    check('six writes of 900 bytes arriving together, six times over, under a 2,500-byte cap: each time exactly two '
          'are stored, four are refused (507), and nothing is left behind',
          all(r == ([200, 200, 507, 507, 507, 507], 1800, 0) for r in rounds), rounds)
    docker('rm', '-f', name)


# ---------------------------------------------------------------- part 3: a certificate from a public authority

def acme_checks(tmp):
    print("\n== 4. a certificate from an ACME authority (Pebble standing in for Let's Encrypt) ==")
    if docker('pull', '-q', PEBBLE, timeout=300).returncode:
        print('SKIP  the Pebble image could not be pulled')
        return
    data, config, peb = tmp / 'adata', tmp / 'aconfig', tmp / 'pebble'
    for d in (data, config, peb):
        d.mkdir()
    net = 'store-test-acme'
    docker('rm', '-f', 'store-test-pebble', 'store-test-acme')
    docker('network', 'rm', net)
    docker('network', 'create', net, check_rc=True)
    LIVE.append('net:' + net)
    docker('create', '--name', 'store-test-pebble-src', PEBBLE, check_rc=True)
    docker('cp', 'store-test-pebble-src:/test/config/pebble-config.json', str(peb / 'default.json'), check_rc=True)
    docker('cp', 'store-test-pebble-src:/test/certs/pebble.minica.pem', str(config / 'authority-root.pem'), check_rc=True)
    docker('rm', 'store-test-pebble-src')
    cfg = json.loads((peb / 'default.json').read_text())
    # The authority validates on what it takes for port 443: here the container's HTTPS port, as a router's forward
    # makes it. Its port-80 check points at a port nothing listens on: only TLS-ALPN-01 can succeed.
    cfg['pebble'].update(tlsPort=8443, httpPort=8099)
    (peb / 'config.json').write_text(json.dumps(cfg))
    os.chmod(peb, 0o755)
    os.chmod(peb / 'config.json', 0o644)
    docker('run', '-d', '--name', 'store-test-pebble', '--network', net, '--network-alias', 'pebble',
           '-e', 'PEBBLE_VA_NOSLEEP=1', '-e', 'PEBBLE_WFE_NONCEREJECT=0', '-v', '%s:/cfg:ro' % peb,
           '-p', '127.0.0.1:8778:15000', PEBBLE, '-config', '/cfg/config.json', check_rc=True)
    LIVE.append('store-test-pebble')
    own(tmp)
    A = 'a' * 64
    (config / 'workers.json').write_text(json.dumps({'alice': hashlib.sha256(A.encode()).hexdigest()}))
    own(config)
    env = {'STORE_TLS': 'acme', 'STORE_DOMAIN': 'store.test', 'STORE_ACME_CA': 'https://pebble:14000/dir',
           'STORE_ACME_CA_ROOT': '/config/authority-root.pem', 'STORE_ACME_EMAIL': 'owner@store.test'}
    extra = ['--network', net, '--network-alias', 'store.test']
    name = run_store('store-test-acme', [(data, '/data'), (config, '/config')], env, port=8777, extra=extra)

    # The root that signs what Pebble issues, from its management door (itself verified with Pebble's own root).
    def pebble_root():
        ctx = ssl.create_default_context(cafile=str(config / 'authority-root.pem'))
        c = http.client.HTTPSConnection('localhost', 8778, timeout=5, context=ctx)
        c.request('GET', '/roots/0')
        r = c.getresponse()
        return r.read() if r.status == 200 else None
    root = tmp / 'issuing-root.pem'
    root.write_bytes(wait_for(pebble_root, 30, 'Pebble'))
    try:
        wait_for(lambda: https(8777, 'store.test', root)[0] in (401, 403), 90, 'a certificate from the authority')
        issued = True
    except RuntimeError as e:
        issued = False
        print('      ', e)
    out = logs(name)
    check('the container obtains a certificate from the authority, and a client that trusts only that authority '
          'verifies it', issued, [l for l in out.splitlines() if '"level":"error"' in l][-2:])
    if not issued:
        return
    s, d, _ = https(8777, 'store.test', root, token=A)
    check('whoami answers over the issued certificate', s == 200 and json.loads(d) == {'worker': 'alice'}, '%s %s' % (s, d))
    check('it was the TLS-ALPN-01 challenge on the HTTPS port (no port 80 involved)',
          'tls-alpn-01' in out and '"challenge_type":"http-01"' not in out and 'certificate obtained successfully' in out,
          [l[:200] for l in out.splitlines() if 'challenge' in l][:3])
    certs = [p for p in (config / 'tls/certificates').rglob('*.crt')] if (config / 'tls/certificates').exists() else []
    check('the certificate and its key are kept on the mapped settings folder', len(certs) == 1
          and certs[0].with_suffix('.key').exists(), certs)
    before = certs[0].read_bytes() if certs else b''
    docker('rm', '-f', name)
    docker('rm', '-f', 'store-test-pebble')     # the authority is gone: a restart must not need it
    name = run_store('store-test-acme', [(data, '/data'), (config, '/config')], env, port=8777, extra=extra)
    try:
        wait_for(lambda: https(8777, 'store.test', root, token=A)[0] == 200, 30, 'the store, restarted')
        again = True
    except RuntimeError:
        again = False
    check('after the container is replaced it serves the kept certificate without asking the authority again',
          again and certs[0].read_bytes() == before)


def main():
    global IMAGE
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--image', help='test this image instead of building one')
    ap.add_argument('--no-build', action='store_true', help='use the image %s as it is' % IMAGE)
    ap.add_argument('--no-acme', action='store_true', help='skip part 4 (it pulls the Pebble image)')
    a = ap.parse_args()
    for tool in ('docker', 'openssl'):
        if not shutil.which(tool):
            print('%s not found' % tool)
            return 2
    if a.image:
        IMAGE = a.image
    elif not a.no_build:
        print('building %s from %s' % (IMAGE, HERE.parent))
        r = subprocess.run(['docker', 'build', '-q', '-f', str(HERE / 'Dockerfile'), '-t', IMAGE, str(HERE.parent)])
        if r.returncode:
            return 2
    tmp = pathlib.Path(tempfile.mkdtemp(prefix='store-container-test-'))
    os.chmod(tmp, 0o755)
    try:
        server_checks()
        container_checks(tmp)
        review_checks(tmp)
        if not a.no_acme:
            acme_checks(tmp)
    finally:
        for x in LIVE:
            if x.startswith('net:'):
                docker('network', 'rm', x[4:])
            else:
                docker('rm', '-f', x)
        subprocess.run(['chmod', '-R', 'u+rwX', str(tmp)], capture_output=True)
        shutil.rmtree(tmp, ignore_errors=True)
    print('\n%d of %d checks pass' % (sum(RESULTS), len(RESULTS)))
    return 0 if all(RESULTS) else 1


if __name__ == '__main__':
    sys.exit(main())
