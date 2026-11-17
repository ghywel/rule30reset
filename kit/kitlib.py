"""Shared parsing for the kit update step: catalogue rows, watched blocks, declared names, stamps.

Everything is read from the kit clone with `git show REV:path`, so any revision (HEAD, origin/main, a past commit)
can be inspected without changing the checkout.
"""
import hashlib, json, os, re, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KIT = os.path.join(ROOT, 'Rule30PrizeKit')
INDEX = os.path.join(ROOT, 'kit', 'index.jsonl')
STAMP = os.path.join(ROOT, 'kit', 'stamp.json')
KIT_MD = os.path.join(ROOT, 'KIT.md')
KIT_INDEX_MD = os.path.join(ROOT, 'KIT-INDEX.md')

FILES = {'lean': 'lean/README.md', 'equivalents': 'equivalents/README.md'}
HEADERS = {'lean': '| Module | Added |', 'equivalents': '| Module | Problem 1 is equivalent to'}
# Prose blocks whose change can alter KIT.md even when no catalogue row changes: (name, file, first heading, stop prefix)
WATCH = [
    ('top:intro', 'README.md', None, '## '),
    ('top:statements', 'README.md', '## The statements', '## '),
    ('lean:intro', 'lean/README.md', None, '## '),
    ('lean:status', 'lean/README.md', '## Status by period', '## '),
    ('equivalents:intro', 'equivalents/README.md', None, '## '),
]
THEMES = [('statements', 'The statements'), ('period1', 'Period 1 and constant runs'),
    ('small-periods', 'Small periods and windows'),
    ('period2-left', 'Period 2: the zero-boundary left half (Q01 and its relatives)'),
    ('period2-right', 'Period 2: the right half and the coupled question (CQ01, Psi, the gate trap)'),
    ('period3', 'Period 3'), ('period4-ether', 'Period 4 and the ether'),
    ('long-period-words', 'Longer periods: excluded words'), ('diagonals-left-edge', 'Left diagonals and the left edge'),
    ('right-edge', 'Right diagonals and the right edge'), ('jen-sideways', "Jen's theorem and sideways reconstruction"),
    ('barriers-controls', 'Barriers and controls'), ('density-P2', 'Density (Problem 2)'),
    ('complexity-P3', 'Complexity (Problem 3)'), ('algebra', 'Algebra'), ('finite-rings', 'Rings and moving frames'),
    ('tools', 'Certificates and tooling'), ('other', 'Other')]
KINDS = [('iff', 'Proved equivalent to Problem 1'), ('implies', 'Sufficient for Problem 1 (one way)'),
    ('P2', 'Problem 2'), ('P3', 'Problem 3'), ('other', 'Supporting results (no new form)')]
PROSE_RE = re.compile(r'at commit `([0-9a-f]{7,40})`\s*\(main, [^)]*\)')   # the commit named in KIT.md's first paragraph
STAMP_RE = re.compile(r'<!-- kit-commit: ([0-9a-f]{7,40}) (\d{4}-\d{2}-\d{2}) -->')

def need_kit():
    if not os.path.isdir(os.path.join(KIT, '.git')):
        raise SystemExit('kit: no kit clone at Rule30PrizeKit/ in this repository; restore it with\n'
                         '  git clone https://github.com/WolframInstitute/Rule30PrizeKit Rule30PrizeKit\n'
                         'nothing was checked')


def git(*a):
    need_kit()
    return subprocess.run(['git', '-C', KIT, *a], capture_output=True, text=True, check=True).stdout

def resolve(rev):
    return git('rev-parse', rev).strip()

def commit_date(rev):
    return git('log', '-1', '--format=%cs', rev).strip()

def show(rev, path):
    return git('show', '%s:%s' % (rev, path))

def sha(s):
    return hashlib.sha256(s.encode()).hexdigest()

def norm_cell(c):
    c = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', c)
    return re.sub(r'\s+', ' ', c.replace('`', '')).strip()

def rows(rev, src):
    """Every row of every catalogue table in FILES[src] at rev, with a stable key and the hash of its exact text."""
    out, section, in_table = [], '', False
    for i, l in enumerate(show(rev, FILES[src]).split('\n'), 1):
        if l.startswith('#'):
            section, in_table = l.lstrip('#').strip(), False
            continue
        if l.startswith(HEADERS[src]):
            in_table = True
            continue
        if in_table:
            if not l.startswith('|'):
                in_table = False
                continue
            if re.match(r'^\|\s*:?-', l):
                continue
            cell = norm_cell(l.split('|')[1])
            out.append({'src': src, 'section': section, 'cell': cell, 'key': '%s::%s::%s' % (src, section, cell),
                        'line': i, 'text': l, 'sha': sha(l)})
    return out

def block(text, heading, stop):
    lines = text.split('\n')
    start = 0
    if heading is not None:
        start = next(i for i, l in enumerate(lines) if l.strip() == heading)
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith(stop)), len(lines))
    return '\n'.join(lines[start:end]).strip()

def watched(rev):
    out = {}
    for name, path, heading, stop in WATCH:
        out[name] = sha(block(show(rev, path), heading, stop))
    return out

def declared(rev):
    """Declared Lean names (full and last component) and module names at rev."""
    pat = r"(theorem|lemma|def|abbrev|structure|inductive|class|instance|opaque|axiom)[[:space:]]+[^[:space:]:({]+"
    need_kit()
    out = subprocess.run(['git', '-C', KIT, 'grep', '-h', '-o', '-E', pat, rev, '--', '*.lean'],
                         capture_output=True, text=True).stdout
    full = set()
    for l in out.split('\n'):
        p = l.split()
        if len(p) >= 2:
            full.add(p[-1])
    last = {n.split('.')[-1] for n in full}
    mods = set()
    for path in git('ls-tree', '-r', '--name-only', rev).split('\n'):
        if path.endswith('.lean'):
            mods.add(os.path.basename(path)[:-5])
            mods.add(path[:-5].replace('/', '.'))
    return full, last, mods

# Mathlib names the catalogues cite; the kit clone does not contain Mathlib's source, so they cannot be checked here.
EXTERNAL = {'Real.ofDigits'}
NOT_LEAN = EXTERNAL | {'environment.kit.commit', 'lean-toolchain', 'decide', 'native_decide', 'sorry', 'propext',
            'Classical.choice', 'Quot.sound'}

def cited_names(text):
    out = set()
    for tok in re.findall(r'`([^`\n]+)`', text):
        tok = tok.strip()
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_'.]*", tok) or tok in NOT_LEAN:
            continue
        if '_' in tok or '.' in tok or re.match(r'Rule30|[A-Z][a-z]+[A-Z0-9]', tok):
            out.add(tok)
    return out

def name_known(n, full, last, mods):
    tail = n.split('.')[-1]
    return n in full or tail in last or n in mods or tail in mods or any(f.endswith('.' + n) for f in full)

def load_index():
    if not os.path.exists(INDEX):
        return {}
    recs = [json.loads(l) for l in open(INDEX) if l.strip()]
    return {r['key']: r for r in recs}

def save_index(idx):
    with open(INDEX, 'w') as f:
        for r in sorted(idx.values(), key=lambda r: (r['src'], r['line'])):
            f.write(json.dumps(r, ensure_ascii=False, sort_keys=True) + '\n')

def load_stamp():
    return json.load(open(STAMP)) if os.path.exists(STAMP) else {}

def doc_stamp(path):
    if not os.path.exists(path):
        return None
    m = STAMP_RE.search(open(path).read(2000))
    return m.group(1) if m else None
