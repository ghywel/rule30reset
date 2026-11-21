# Kit issue #380, as posted on 2026-11-21 at 20:08 UTC at the owner's word (ledger M86)

**Title:** A law of the trapped gate whose one finite step is an LRAT certificate too large for the kernel: can it enter the kit?

This is a question about form, before any pull request.

**The result.** Take the setting of `Rule30GateTrap`: a right half `R` driven by the alternating column, with window `win R t` and gate `Rule30PeriodTwoSideways.u R`. Read the gate from a black sample. A *run of four* is four 5-gaps between two 3-gaps.

1. If `win R t₀ ∈ trap` at an odd `t₀`, then from two samples later on, the gate never reads `3, (5, 5, 5, 5, 3) × 4`: four closed runs of four.
2. Under the same window hypothesis, it never reads `(5, 5, 5, 5, 3) × 5`, at any sample in the trap.
3. Three closed runs of four do occur 60 samples after entry, by a SAT witness checked cell by cell. So the limit is sharp at that delay.

The statement covers every right half and every time, as `gaps_of_entry` does; it is not a single width. Its proof has one finite step. That step is a light-cone instance:
- rule 30 on the triangle of 194 ticks from an odd time;
- the window at the start is one of the 829 trap codes;
- column 1 spells the word at the samples.

It has 19,939 variables and 163,905 clauses. CaDiCaL refutes it in about 5 s. Its LRAT proof is 45 MB in binary form, and it checks with `cake_lpr` (CakeML's verified checker) and with `lrat-check`. The certificate is the one step of a theorem about an infinite family. As we read #14, that is the role certificate data may have in the catalog.

**In Lean.** We have a module in the kit's module form that builds against `40017e8`. It proves (1) and (2) from one hypothesis, `Unsat cnf`.
- `cnf` is a Lean definition. The DIMACS text that Lean prints from it is the file that was certified.
- (2) is derived from (1) inside Lean.
- Every theorem uses only `propext`, `Quot.sound` and `Classical.choice`.
- The kit forbids `bv_decide`, and a 45 MB certificate is far beyond kernel reduction. So in Lean the hypothesis has to stay a hypothesis.

**Questions.**
1. Could such a module enter the catalog with the hypothesis explicit? The headlines would be stated as `Unsat cnf → …`, with the DIMACS digest and the commands that certify it in the docstring.
2. If not, would you accept another form for a law whose one finite step is a certificate of this size? For example, the DIMACS and LRAT files could be kept with the kit outside `lean/`.
3. Or should a result of this kind stay on the submissions site, with the hypothesis as a stated condition?

We can open a pull request if that is easier to review.

The module and the script that prints and certifies the DIMACS are at https://github.com/ghywel/rule30reset/tree/main/research/m9 (`Rule30RunsOfFour.lean`, `claudeM5_m9_print_cnf.py`).


