#!/usr/bin/env python3
"""Public wording for S21 (claudeM5, M186): the two forms made by claudeIntel_build_s21.py, with four comment changes and no change of code.

    python3 -X utf8 -I claudeM5_s21_words.py IN OUT

IN holds Rule30EtherThreeSharpSlope.lean and Rule30Submission.lean. Three docstrings named the entry theorem by our own number,
which no outside reader knows; a blank line of the module's docstring came out as `--`. Every other line must be equal.
"""
import pathlib, sys

src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
CHANGES = [
    ("large enough support allowance D (`late_001`, `late_011`).\n--\nThe step needs nothing of the tail.",
     "large enough support allowance D (`late_001`, `late_011`).\n\nThe step needs nothing of the tail."),
    ("/-- Arbitrarily large finite rows beside 001 stay outside the S16 trap at\ngate ticks 21n+1, with support at most 7n+26. -/",
     "/-- Arbitrarily large finite rows beside 001 stay outside `trap001` at\ngate ticks 21n+1, with support at most 7n+26. -/"),
    ("/-- The S16 upper bound of slope three is optimal for the 001 trap. -/",
     "/-- The slope three of `finite_enters_001` in `Rule30PeriodThreeEntry` is optimal. -/"),
    ("/-- The S16 upper bound of slope three is optimal for the 011 trap. -/",
     "/-- The slope three of `finite_enters_011` in `Rule30PeriodThreeEntry` is optimal. -/"),
]
out.mkdir(parents=True, exist_ok=True)
for name in ("Rule30EtherThreeSharpSlope.lean", "Rule30Submission.lean"):
    text = (src / name).read_text(encoding="utf-8")
    new = text
    for a, b in CHANGES:
        assert new.count(a) == 1, (name, new.count(a), a)
        new = new.replace(a, b)
    old_lines, new_lines = text.split("\n"), new.split("\n")
    assert len(old_lines) == len(new_lines)
    changed = [(x, y) for x, y in zip(old_lines, new_lines) if x != y]
    assert len(changed) == 4 and all(x == "--" or x.startswith("/-- ") for x, _ in changed), changed
    import re
    assert not re.search(r"\bS1\d\b", new)
    (out / name).write_bytes(new.encode("utf-8"))
    print(name, len(new.encode("utf-8")), "bytes, 4 comment lines changed of", len(new_lines))
