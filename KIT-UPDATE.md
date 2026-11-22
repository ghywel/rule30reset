# The kit update step

*How to keep [KIT.md](KIT.md) and [KIT-INDEX.md](KIT-INDEX.md) in step with the official kit's main. Any worker can
run it. It takes a few minutes when nothing has changed, and about a minute per changed catalogue row otherwise.*

## What "in step" means

`python3 kit/check.py` prints `IN STEP` and exits 0. That holds exactly when:

1. `kit/stamp.json`, the stamp line at the top of `KIT.md`, the commit named in `KIT.md`'s first paragraph and the
   stamp line at the top of `KIT-INDEX.md` all name the same kit commit, and the kit clone (`Rule30PrizeKit/`) is
   checked out at that commit;
2. every table row of the kit's two catalogues (`lean/README.md`, `equivalents/README.md`) at that commit has a
   record in `kit/index.jsonl` whose stored SHA-256 matches the row's exact text, and no record is left over;
3. the kit's prose blocks that `KIT.md` summarises (the statements, the status table, the three introductions) have
   the hashes recorded when `KIT.md` was last reviewed;
4. every theorem or module name cited in `KIT.md` or the index is declared in the kit at that commit.

A row is keyed by file, section and module cell, so a new row, an edited row and a deleted row are each caught, even
when the edit is one word.

## The pieces

| File | Role |
|---|---|
| `kit/index.jsonl` | one record per catalogue row: key, row hash, and the digest fields below. The source of `KIT-INDEX.md`. |
| `kit/stamp.json` | the synced kit commit, its date, and the hashes of the watched prose blocks |
| `kit/check.py` | the check; read-only; `--rev origin/main` previews an update, `--todo FILE` writes the rows to digest |
| `kit/merge.py` | merges digest lines into the index, keyed to the rows they describe |
| `kit/build.py` | regenerates `KIT-INDEX.md`; `--restamp REV` records a new synced commit, and refuses while any row is out of step |
| `KIT.md` | written by hand; carries the stamp line |
| `KIT-INDEX.md` | generated; never edit it by hand |

## When to run it

- **At the start of every session:**
  ```bash
  git -C Rule30PrizeKit fetch -q && python3 kit/check.py --rev origin/main
  ```
  `IN STEP` means there is nothing to do. `OUT OF STEP` means run the step below before relying on `KIT.md`.
- **With every run of the step, and before any novelty claim,** check the portal entries outside the kit:
  ```bash
  python3 tools/portal/portal_only.py
  ```
  It names every portal-only entry that [PORTAL.md](PORTAL.md) does not list, and every listed entry that has since
  gained kit modules. Add or move rows as PORTAL.md's last section says, and restamp its first line.
- **Before any outward step** (a submission, a kit pull request, a novelty claim), since those rest on the current kit.

## The step

1. **Preview.** Run the check against the remote and write the work list:
   ```bash
   git -C Rule30PrizeKit fetch -q
   python3 kit/check.py --rev origin/main --todo kit/todo.md
   ```
   Note the old and new commits from the first lines of the report. `kit/todo.md` lists each new and changed row
   with its exact text (and the previous record, for a changed row), each removed row, and each changed prose block
   with the `git diff` command that shows it.

2. **Advance the clone.**
   ```bash
   git -C Rule30PrizeKit pull --ff-only
   ```
   Never edit files inside the clone. If the pull refuses, something in the clone was changed: stop and find out what.

3. **Digest each new or changed row** into one line, in the format below, using the line number the todo gives.
   Read the row's text; open the module's Lean source only where the row is unclear about what is proved and what is
   open. For a changed row, compare with the previous record and say in the ledger what changed. For more than a
   few rows, hand them to reading agents with the brief below, at most 40 rows each. A digest by a sub-agent is a
   self-check, not a second read.

4. **Merge.** Put the lines in a file per catalogue and merge them at the commit they were read from:
   ```bash
   python3 kit/merge.py --rev HEAD --src lean digest-lean.txt
   python3 kit/merge.py --rev HEAD --src equivalents digest-equivalents.txt
   python3 kit/merge.py --rev HEAD --drop-removed        # only when the check listed REMOVED rows
   ```
   `merge.py` rejects a line whose number is not a catalogue row at that commit, and any unknown theme, kind, weight
   or problem number. A renamed module shows as one removed row and one new row: carry the old text over if it
   still holds.

5. **Review `KIT.md`.** Go through every changed item and ask which section it touches:
   - a case changes status → §2, the status table;
   - a new open statement, or a new proved implication between open statements → §3, both the diagram and the
     words;
   - a new barrier or refuted statement → §4;
   - a new unconditional result with reach (an infinite family of periods, words or widths) → §5;
   - a new equivalent form, or new counts → §6 and the opening paragraph;
   - a changed prose block: `top:statements` → §1, `lean:status` → §2, the three intros → the opening paragraph
     and §6;
   - a removed row or a `NAME` failure → remove or rename the citation.

   Replace rather than append: `KIT.md` stays under about 20 KB so that it can be read whole every session. A
   weight-1 row rarely changes `KIT.md`; a weight-3 row usually does.

6. **Restamp and regenerate.**
   ```bash
   python3 kit/build.py --restamp HEAD
   ```
   This writes `kit/stamp.json`, rewrites the stamp line and the commit named at the top of `KIT.md`, and rebuilds
   `KIT-INDEX.md`. It refuses while any row is new, changed or missing. Restamping also records the prose hashes,
   which says you reviewed `KIT.md` against them, so run it only after step 5.

7. **Verify.**
   ```bash
   python3 kit/check.py
   ```
   It must print `IN STEP`. Then open three of the new records beside their kit rows and read them against each
   other.

8. **Record.** Commit `kit/`, `KIT.md` and `KIT-INDEX.md` together, with a message of the form
   `Kit update step: 8b397bd → 345f7d7 (0 new, 2 changed, 0 removed)`. Add one ledger line naming the changed rows
   and any `KIT.md` section you changed. Flag the other workers when §2, §3 or §4 changed. Delete `kit/todo.md`.

## The record format

**Lean catalogue** (`lean/README.md`), one line per row:

```
LINE | MODULES | DATE | WHO | P | THEME | W | PROVED | OPEN
```

- `LINE`: the row's line number in `lean/README.md` at the commit being merged.
- `MODULES`: the module name or names, without backticks. A short parenthetical may name the part of the module the
  row is about, as in `Rule30Ether (Lock)`.
- `DATE`: the row's *Added* entry (a date, or one of the catalogue's labels `10-10`, `start`, `R1`, `R2`, `final`).
- `WHO`: the credit as the row gives it, shortened, for example `Herbert (Claude, GPT) +ext: Quint (Gemini)`;
  `kit` when the row names nobody.
- `P`: the prize problem the row bears on: `1`, `2`, `3`, or `-` for a side result.
- `THEME`: exactly one of `statements`, `period1`, `small-periods`, `period2-left` (the zero-boundary left half: Q01,
  Theta, free bits, gap languages), `period2-right` (the right half: CQ01, Psi, gates, sideways reconstruction),
  `period3`, `period4-ether`, `long-period-words`, `diagonals-left-edge`, `right-edge`, `jen-sideways`,
  `barriers-controls`, `density-P2`, `complexity-P3`, `algebra`, `finite-rings`, `tools`, `other`.
- `W`: `3` for a reduction between open statements, a new open statement, a barrier or no-go theorem, or an
  exclusion of an infinite family; `2` for a substantial standalone theorem; `1` for corollaries, extensions,
  tooling and certificate data.
- `PROVED`: at most 40 words of exact mathematical content, with one or two headline theorem names in backticks.
  Keep the hypotheses that matter ("not rule 30", "conditional on Q01 failing"). Notable extensions in at most 12
  more words after `Ext:`.
- `OPEN`: the open statements the row defines or uses, with its proved implications written `A ⇒ B` or `A ⇔ B`;
  `-` if none. Never call an open statement proved. A statement the row shows false is marked `REFUTED`.

**Equivalents catalogue** (`equivalents/README.md`):

```
LINE | MODULE | KIND | FIELD | FORM
```

- `KIND`: `iff` (proved equivalent to Problem 1), `implies` (sufficient for Problem 1, one way), `P2`, `P3`, or
  `other` (no new form).
- `FIELD`: one or two words for the area of mathematics.
- `FORM`: at most 30 words: the statement in plain mathematics, with the headline theorem name in backticks.

Do not round numbers, invent theorem names or soften inequalities. `" | "` inside a field is allowed only in the
last field.

## The brief for reading agents

> Condense rows of the Rule 30 Prize kit's catalogue into one-line records. Read-only: write no files. Source:
> `Rule30PrizeKit/lean/README.md` [or `equivalents/README.md`] at commit `NEW`. Digest exactly these lines: LINES.
> Work from the catalogue text; open a Lean source only when a row is genuinely ambiguous about what is proved and
> what is open. Output one record per row, in line order, in this format, and nothing else except a final line
> `ROWS n`: [paste the format and field definitions above]. Be exact: do not round numbers, do not invent theorem
> names, keep inequalities and constants as written.

## Pitfalls

- **Line numbers belong to a commit.** Digest and merge at the same commit; after `git pull`, `HEAD` is the new one.
- **The catalogue can lag the source.** The check's `INFO` line lists Lean modules that no catalogue row names. At
  `8b397bd` they are `Rule30Challenge`, `Rule30Submission` (templates) and `Rule30EtherSingleCellAux` (a helper). A
  new name there is a module merged without a row: note it in the ledger. The index covers catalogue rows only.
- **The portal's verifier lags main** (its `environment.kit.commit`). `KIT.md` describes main. A submission must be
  built against the verifier's commit, and a novelty check must also search the portal and open kit pull requests
  (METHOD §12), which this step does not cover.
- **A cosmetic edit changes a row's hash.** Re-read it anyway; usually the old line carries over with its new line
  number.
- **Mathlib names cannot be checked here**, since the clone holds no Mathlib source. Add one to `EXTERNAL` in
  `kit/kitlib.py` only after confirming it in Mathlib.
