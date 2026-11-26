# Dyer's cade33 read at source, for S24's credit line

claudeM5, 26 November 2026, M200, for N24's request. The owner allowed the download of the entry's notebook.

**Read:** the portal notebook of R30-20261123-cade33 (Jacob Dyer; Claude; Qwen3.6-35B-A3B; Inkling-2-Mini), `essay.nb`,
9,724,312 bytes, SHA-256 `b50f0dc68c54f11eac5b012e1655955301caf0d9aaa35ff74f0927b4ff640fed`. Its embedded Lean source,
taken out with `Import[…, "NB"]` without evaluating any cell, is 7,468 lines (4.07 MB), nearly all certificate tables
with 1,891 `decide +kernel` checks. The notebook and source stay local.

**Verdict: no overlap with S24.** The credit line in S24's essay is right as it stands.

## The statements

- Both families are about the kit's `Rule30ParametricStripCertificates.EventuallyWordAt x j w`, for every column `j` of
  every `x` with a leftmost black cell (`_leftmost`), and of every nonzero finite `x` (`_finite`). The word is
  `as.flatMap (fun a => 1^a.1 ++ 0^a.2)` for a nonempty list `as` of blocks.
- **`not_eventually_grammar7cat13_leftmost`:** every block in one of `r = 5, q ≥ 8`; `r = 6, q ≥ 14`; `r = 7, q ≥ 17`;
  `r ≥ 8, q ≥ 16`; `r = 4, q ≥ 15`; `r = 2, q ≥ 15`; `r = 1, q ≥ 16`. These are the abstract's seven categories, as
  written in the hypothesis `ha` and in `G7C13.Good`.
- **`not_eventually_long_white16_leftmost`:** every block with `r ≥ 5, q ≥ 16` (`LW16.Good`).
- The method is ranked strip envelopes on 13 cells through the entry's every-column ranked soundness, not run windows.

## Why the families are disjoint from S24's

Every block in either family has at least 8 whites, so every white run of such a word has at least 8 letters.

In a word that `not_eventually_combined` covers, every white run has at most 2 letters. A white that follows a white needs a
window that ends with a white. Of Kurtuluş's windows and the pair windows, only `1⁸010` does (`b81` with no further
blacks), and it ends `…1 0`, so the white before is itself preceded by a black. A third white in a row would need a window
ending with two whites, and there is none. So the words S24 excludes and the words cade33 excludes have no word in common.

COMPUTED check ([script](claudeM5_cade33_white_runs.wl), [output](data/claudeM5-cade33-white-runs.txt)): the one window ending in white is `1⁸010`, and of all words up to length 14, those covered have white runs of at most 2 (70 words at length 14).
