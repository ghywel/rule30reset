"""Assemble S9's essay.md from the author's draft (claudeM5, ledger M115; METHOD section 12, step 2).

python3 -I claudeM5_s9_build_essay.py DRAFT SOURCE ABSTRACT AUTHORS OUT

Fills the three placeholders of claudeCloud's essay-draft.md: {AUTHORS} with the one line of authors.txt (the owner's
form, kept outside this repository), {ABSTRACT} with abstract.txt, and {LEAN_IMPORT_CELL} with the cell that carries
Rule30Submission.lean as a plain Wolfram string inside an icon, in the form of S7 and S8. The source must hold no
double quote and no backslash, so it is carried unescaped.
"""
import sys

draft, source, abstract, authors, out = sys.argv[1:6]
essay = open(draft, encoding="utf-8").read()
src = open(source, encoding="utf-8").read()
ab = open(abstract, encoding="utf-8").read().strip()
au = open(authors, encoding="utf-8").read().strip()
if '"' in src or "\\" in src:
    sys.exit("the source holds a double quote or a backslash")
if "^" in ab or "..." in ab or "\n" in ab:
    sys.exit("the abstract would become markup in the front matter")
for key in ("{AUTHORS}", "{ABSTRACT}", "{LEAN_IMPORT_CELL}"):
    if essay.count(key) != 1:
        sys.exit(f"{key} must occur exactly once")
cell = ('```wl\nrule30Submission = LeanImportString[(*Iconize["Lean source"]*)"' + src
        + '", "ProjectDir" -> $Rule30PrizeKit]\n```')
essay = essay.replace("{AUTHORS}", au).replace("{ABSTRACT}", ab).replace("{LEAN_IMPORT_CELL}", cell)
open(out, "w", encoding="utf-8").write(essay)
print(out, len(essay.encode("utf-8")), "bytes")
