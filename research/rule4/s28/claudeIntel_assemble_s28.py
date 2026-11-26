"""claudeIntel's assembly of S28 packet a (N29), on gptIntel's builder, which is used unchanged.

1. Run build_submission.py and check that its portal source is the one I273 proposed and N29 read (e20b3b4d...).
2. Drop the AlternatingFiniteSupport section and its import. N29 found all three of its statements in the kit
   (Rule30PeriodTwoSideways: exact_death_center, truncation_death; Rule30ZeroBoundary and Rule30CoupledGerms:
   Theta_dep, Theta_inverse_dep, Psi_eq_of_u_eq_le, u_eq_of_Psi_eq_le). METHOD section 12: a known result is not
   submitted as new.
3. Replace three internal labels in the feedback docstrings (claudeIntel's own text). No proof changes.
4. Write the packet: Rule30Submission.lean, headlines.txt, title.txt, abstract.txt, authors.txt, agent.txt and
   essay.md, whose Lean cell carries the source byte for byte; then SHA256SUMS.

The authors line is read from a file outside the repository (the owner's name stays out of git).
Usage: python claudeIntel_assemble_s28.py OUT AUTHORS_FILE DATE
"""
import hashlib
import importlib.util
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROPOSED = "e20b3b4d8ce6bc4d2aea14edd8fc98e3172ddf425a96f32b84f1e727b605815a"
AGENT = "Claude Code with Claude Opus 5.5"
DOCSTRINGS = [
    ("/-- **The adaptive corollary of I229.** Beside", "/-- **The adaptive corollary.** Beside"),
    ("/-! ### The reduction of A1 -/", "/-! ### Reduction to purely periodic words -/"),
    ("/-- **A1 reduces to pure periodic targets from time zero.** If",
     "/-- **Almost-sure aperiodicity reduces to pure periodic targets from time zero.** If"),
]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def proposed_source():
    spec = importlib.util.spec_from_file_location("build_submission", HERE / "build_submission.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    with tempfile.TemporaryDirectory() as tmp:
        module.build(Path(tmp))
        data = (Path(tmp) / "portal/Rule30Submission.lean").read_bytes()
    assert sha(data) == PROPOSED, sha(data)
    return data.decode("utf-8")


def repaired(text):
    imp = "import Ruliology.CellularAutomata.Rule30PeriodTwoSideways\n"
    assert text.count(imp) == 1
    text = text.replace(imp, "", 1)
    cut = text.index("\n\nnamespace Rule30Submission.AlternatingFiniteSupport\n")
    assert text.endswith("end Rule30Submission.AlternatingFiniteSupport\n")
    text = text[:cut] + "\n"
    assert text.endswith("end Rule30Submission.RightHalfFeedback\n")
    for old, new in DOCSTRINGS:
        assert text.count(old) == 1, old
        text = text.replace(old, new)
    for label in ("I229", "A1", "K83", "claudeIntel", "gptIntel", "AlternatingFiniteSupport", "PeriodTwo"):
        assert label not in text, label
    assert '"' not in text and chr(92) not in text
    return text


def main(out, authors_file, date):
    source = repaired(proposed_source())
    heads = [h for h in (HERE / "headlines.txt").read_text(encoding="utf-8").split()
             if ".AlternatingFiniteSupport." not in h]
    assert len(heads) == 9 and all(f"theorem {h.rsplit('.', 1)[1]} " in source or
                                   f"theorem {h.rsplit('.', 1)[1]}\n" in source for h in heads)
    title = (HERE / "title.txt").read_text(encoding="utf-8").strip()
    abstract = (HERE / "abstract-packet-a.txt").read_text(encoding="utf-8").strip()
    authors = Path(authors_file).read_text(encoding="utf-8").strip()
    assert "Claude (Anthropic)" in authors and "GPT (OpenAI)" in authors
    cell = ('```wl\nrule30Submission = LeanImportString[(*Iconize["Lean source"]*)"' + source +
            '", "ProjectDir" -> $Rule30PrizeKit]\n```')
    essay = (HERE / "essay-packet-a.md").read_text(encoding="utf-8")
    fields = {"{TITLE}": title, "{AUTHORS}": authors, "{DATE}": date, "{ABSTRACT}": abstract,
              "{HEADS}": "{" + ", ".join(f'"{h}"' for h in heads) + "}", "{LEAN_IMPORT_CELL}": cell}
    for key, value in fields.items():
        assert essay.count(key) == 1, key
        essay = essay.replace(key, value)
    assert "{" + "LEAN" not in essay and "AlternatingFiniteSupport" not in essay
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    files = {"Rule30Submission.lean": source, "headlines.txt": "\n".join(heads) + "\n",
             "title.txt": title + "\n", "abstract.txt": abstract + "\n", "authors.txt": authors + "\n",
             "agent.txt": AGENT + "\n", "essay.md": essay}
    for name, text in files.items():
        (out / name).write_bytes(text.encode("utf-8"))
    sums = "".join(f"{sha((out / n).read_bytes())}  {n}\n" for n in sorted(files))
    (out / "SHA256SUMS").write_text(sums, encoding="utf-8")
    print(sums, end="")


if __name__ == "__main__":
    main(*sys.argv[1:4])
