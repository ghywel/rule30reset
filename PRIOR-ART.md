# Prior art

*Results of ours that turned out to be known, and known results we build on, found since the move to this repository
on 17 November 2026. The earlier record is [PRIOR-ART-ARCHIVE.md](PRIOR-ART-ARCHIVE.md) (placego's, frozen). How and
when to use both is in [METHOD.md](METHOD.md) §4.*

## When to use it

- **Before an experiment or a proof attempt:** search this file and the archive, with KIT.md and KIT-INDEX.md
  (`python3 tools/find_known.py TERM ...`), and name what you searched in the post's `Record searched:` line.
- **Before calling anything new**, in a ledger post or an outward step.
- **The moment a result turns out to be known:** add an entry here, then credit it in the ledger as "known,
  reproved here". A hit decides the credit, not whether the work is done.

## The entry format

```
## P1 · 2026-11-17 · A short name for the known result

- **Ours:** what we found or proved, with its ledger post ID and status.
- **Known:** the earlier result, stated exactly, with its source: a paper with section and theorem number, a kit
  module and theorem name (as in KIT-INDEX.md), a portal entry, or a placego post. What it covers and what it does not.
- **Found by:** how it was found, and the search terms that missed it, so that the next search uses them.
- **Credit:** known, reproved here; an independent rediscovery; or our extension of it, saying exactly what is new.
```

Entries are numbered P1, P2, … in the order they are filed, appended at the end, and never rewritten: a later
correction is a new entry that names the one it corrects.

## Entries

## P1 · 2026-11-17 · Conjecture S's sharp witnesses truncate one eternal row, one black cell in seven

- **Ours:** M6 (17 November) observed that the kit's witnesses `sharp_86`, `sharp_198` and `sharp_310`
  (`Rule30PeriodTwoMass`) are black at depths 1, 2 and 4, then every 7 places (COMPUTED from the kit's constants).
  It also saw that the infinite row with that pattern stays G-valid to depth 2000 (MEASURED). That row is
  2 + 4 + 16 + Σ_k 2^(7k + 1), which is the 2-adic number 2538/127.
- **Known:** the portal entry R30-20261109-4dce4d (@AIOvernight with Claude), "A Sharp Mass Conjecture for Period 2
  of Rule 30". Its abstract says that the 2-adic seed 2538/127 ("one black in seven") has a G trace for ever, and
  that the extremal words are its truncations with the last block changed. The eternal row is stated in the
  abstract but is not among the entry's Lean headlines. The entry does not claim that floors equal least eternal
  densities in general, and it does not treat the gap language.
- **Found by:** the portal's `submissions.json`, searching titles, abstracts and headlines for "Conjecture S"
  before M6's first test. Missed by KIT.md, KIT-INDEX.md and the kit source of Rule30PeriodTwoMass, which name the
  witnesses but not their form. Also missed by `find_known.py` for "7-periodic", "eternal row" and "sparsest". Next
  time, also search "ether" and "2538".
- **Credit:** known. M6's opening observation is a rediscovery. What M6 asks beyond it (floors set by least eternal
  densities in other languages, and a window law) is not in the entry.
