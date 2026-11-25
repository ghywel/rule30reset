#!/usr/bin/env python3
"""Proposed sources for S21, R5 sharp slope (claudeIntel, N18): the kit module with the extension, and a trimmed portal form.

    python3 -X utf8 -I claudeIntel_build_s21.py CARRIED OUT [--no-extension]

CARRIED is the Rule30Submission.lean of S16's packet b or of I242's packet (both begin with the same S16 source). Of S16 the
portal form keeps, byte for byte, only what its theorems use: the two trap lists, `code`, `InTrap`, `half`, and the section
carried from `Rule30EtherThreeDeparture` up to `ten_ticks`. It leaves out the tables, the walks and S16's own theorems. OUT gets
Rule30EtherThreeSharpSlope.lean (kit form) and Rule30Submission.lean (portal form).
"""
import pathlib, re, sys

here = pathlib.Path(__file__).resolve().parent
carried, out = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").split("\n"), pathlib.Path(sys.argv[2])
extend = "--no-extension" not in sys.argv[3:]

NAME = "Ruliology.CellularAutomata.Rule30EtherThreeSharpSlope"
module = (here.parent / "Rule30EtherThreeSharpSlope.lean").read_text(encoding="utf-8")
END = "\nend " + NAME + "\n"
assert module.endswith(END) and module.count(END) == 1
if extend:
    part = (here / "claudeIntel_extension.lean").read_text(encoding="utf-8")
    note, section = part.split("\n-- BEGIN\n", 1)
    old = "large enough support allowance D (`late_001`, `late_011`).\n"
    assert module.count(old) == 1
    module = module.replace(old, old + re.search(r"-- HEADER\n(.*)", note, re.S).group(1).rstrip().replace("\n-- ", "\n").removeprefix("-- ") + "\n")
    module = module[: -len(END)] + "\n" + section.strip("\n") + "\n" + END


def find(prefix, start=0):
    return next(k for k in range(start, len(carried)) if carried[k].startswith(prefix))


def paragraph(prefix):
    """From a docstring line to the next blank line."""
    i = j = find(prefix)
    while carried[j].strip():
        j += 1
    return "\n".join(carried[i:j]) + "\n"


doc = module[module.index("/-!") : module.index("-/\n") + 3]
doc = doc.replace("-/\n", "\n**Carried here.** The verifier's kit predates `Rule30PeriodThreeEntry` (R30-20261124-629dac) and `Rule30EtherThreeDeparture`\n"
                  "(R30-20261123-f214f2). The trap lists, `code`, `InTrap` and `half` are the first's, unchanged, and the namespace\n"
                  "`Rule30EtherThreeDeparture` is the second's up to `ten_ticks`. The upper bounds of slope three, `finite_enters_001` and\n"
                  "`finite_enters_011`, are theorems of the first and are not repeated here.\n-/\n")
i, j = find("@[expose] public section"), find("open Rule30DrivenPrefix")
k, l = find("/-! ### Carried from `Rule30EtherThreeDeparture`"), find("end Rule30EtherThreeDeparture")
portal = ["module\n\npublic import Ruliology.CellularAutomata.Rule30EtherThreeErosion\n", doc, "\n".join(carried[i:j]) + "\n"]
portal += [paragraph(p) for p in ("/-- The gate trap of `001`", "/-- The gate trap of `011`", "/-- The first `n` cells of the half",
                                  "/-- The first fourteen cells of the half at tick", "/-- The right half `R`, driven by the word")]
portal += ["\n".join(carried[k : l + 1]) + "\n", "end Rule30Submission\n"]
body = module[module.index("\nnamespace ") + 1 :]
body = body.replace("open Rule30EtherThreeDeparture Rule30PeriodThreeEntry Rule30PeriodThreeEntryTables",
                    "open Rule30Submission Rule30Submission.Rule30EtherThreeDeparture")
body = body.replace(NAME, "Rule30Submission.SharpSlope")
body = body.replace("open Rule30Ether Rule30EtherThree", "open Ruliology.CellularAutomata\nopen Rule30Ether Rule30EtherThree", 1)
portal.append(body)
text = "\n".join(portal)
assert '"' not in text and "\\" not in text, "the embedded source must hold no quote and no backslash"

out.mkdir(parents=True, exist_ok=True)
(out / "Rule30EtherThreeSharpSlope.lean").write_bytes(module.encode("utf-8"))
(out / "Rule30Submission.lean").write_bytes(text.encode("utf-8"))
print(len(module.encode("utf-8")), "bytes kit form,", len(text.encode("utf-8")), "bytes portal form,", text.count("\n"), "lines")
