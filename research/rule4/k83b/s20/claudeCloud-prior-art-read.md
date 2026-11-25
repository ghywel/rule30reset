# S20 packet b: prior-art read of the earlier-work paragraph

*claudeCloud, 25 November 2026 (ledger K85), as asked in M184 and M186: "claudeCloud: the earlier-work paragraph of S20
(§8.77, K84)".*

## What was read

Packet b, fetched from the store and checked against M186: archive `a064f033c40d540dfafc333e3eee9ace1cc3f3514728ed1a41c6815781a38ea2`
(83,002 bytes). Inside it:

| File | SHA-256 |
|---|---|
| `packet/essay.nb` | `95c24367aec10bcbe6703ca3edc8261c45b4a64d3a03c78dd215c97c3440bf4b` |
| `packet/essay.md` | `043588bc61dfaeb78056dfe94401d993b4c8e0f8ccc5c9ba4243435d7e1f5a25` |
| `packet/abstract.txt` | `344f5c4f1a285403c454395800b00313bfeb08cfb86f436e125dbfccfbf303ad` |
| `packet/Rule30Submission.lean` | `1626abedff4aa9c3ed446965b1f0118cf987166d3a978e8360c28af0b054c396` |
| `packet/pins.json` | `0ac0d83e24d13ff40fee9b866b12785a3dc544a35b47b7edce2b50829d5c6a38` |
| `pr/pair-trace-entropy-v2.patch` | `05b314e212b7498eaf72f40d540edaeda2728b2aad9f425826bdc3cc2bc6282a` |
| `pr/pr-v2.md` | `9e8e9e80422fed46eff181d00dfa25697eabfbe185ce7ccd0d2840acc850796d` |

- The paragraph under "Earlier work" in `essay.md` is the repository's `essay-draft.md` word for word.
- The built notebook carries the same text.
- The abstract's credit sentences and the kit patch's credit lines were read as well.

## Sentence by sentence

| Sentence | Source, and how it was read | Verdict |
|---|---|---|
| "`Mixing` proves log 2 ≤ h ≤ log 3 and describes the two-column identity." | The kit at the verifier's `5fb5915`: `log_two_le_coverEntropy`, `coverEntropy_le_log_three`. The words "the entropy is exactly the growth rate of their words" are in `equivalents/CATALOG.md` §7 item 11, not in `Mixing.lean`, whose docstring describes the pair-word cover. Read in the source. | **W1:** say that the catalogue states the identity |
| "Its cover argument is what we use … carried here since the verifier's kit has it only inside a proof." | At `5fb5915` the count `coverMincard ≤ card pairWords` occurs only inside the proof of `coverMincard_le`, whose statement is the bound 4·3^(n+2N). Read in the source. | Right |
| "Di Lena and Margara (2007, Corollary 4.6) prove that the entropy of a permutive automaton of radius r is that of its width 2r + 1 column trace, which is three columns for Rule 30." | Read in full, all ten pages, from the PDF the essay links. Corollary 4.6(2): "If (A^ℤ, F) is permutive then H(F) = H(Σ_{2r+1})". §2.2: "A CA is *permutive* if it is left or right permutive", so Rule 30 qualifies. Definition 2.2: Σ_k is "the *column subshift* of width k". The paper calls the general question open (p. 7) and has no Rule 30 and no numbers. | Exact |
| "Guillon's thesis (2008, Proposition 4.8.5) relates the entropy to that of a trace." | **Read on the owner's copy** (K85 addendum 2), on the page images. Proposition 4.8.5: "Un AC F positivement expansif à gauche (resp. à droite) de rayon r ∈ ℕ a une entropie H(F) = H(τ_F^r)". τ_F^r is "le tracé τ_F^r de largeur r" (Définition 3.5.2). | Accurate. **W3** below |
| "One column alone does not determine the cells to its west, and two do." | Computed here. The row with a period-two west (…1,0,1), cell 0 white, cell 1 black and white beyond has an all-white centre for 200 ticks, as the white row does, and the two differ at cell −1. Two columns determine the west by `RightHalfReturns.eq_left_of_eq_columns`. | Right |
| "Our notes of October 2026 had the two-column form for Rule 30 by hand, with the counts to length 17 and the bound 1.3189 bits." | §8.77, read in placego's public archive: the two-column lemma by hand, N₂(14) and N₂(17), and the bound 1.3189 bits. The full counts for n = 1 to 17 are in L427 and L436, which it cites. | Right (Q1 below) |
| "For the measure entropy, Wolfram (1986) has about 1.20 bits and Grassberger (1986) less than 1.15436" | Wolfram, *Adv. Appl. Math.* 7, read on the page images. Eq. (4.7), p. 134: "A calculation based on the method of [25] in fact shows that **h_μ ≲ 1.20**". Footnote: "Recent results [45] suggest in fact that h_μ ≈ 1 + T^−(0.6±0.1), yielding a final value of 1." Grassberger's Table 6, read in the *Tables*, Rule 30 row: h_μ **< 1.15436**, beside the left speed .2428 ± .0002 and a directional minimum < .763141. | Grassberger right. **W2:** Wolfram's figure is an approximate upper bound, and his footnote points to 1 |
| "for the topological entropy the general bound is 2 bits." | Wolfram 1986, eq. (4.6), p. 134: "It is clear from the locality of the rule (3.1) that h_μ ≤ h ≤ 2." | Right. Name the source (W2) |
| "The tables and the count past 17 are from November. The general idea of bounding a language by a weighted automaton is standard." | I234, M178, I238; no earlier source found for the tables. | Right |

## The earlier source the paragraph leaves out (M1)

**Wolfram 1986 already has the mechanism, for Rule 30 itself**, read on the page images and in the text layer:

- §3, p. 131: the spacetime patterns "can be found not only by direct time evolution according to (3.1) from a given
  initial configuration, but also by extending spatially according to (3.3), starting with the temporal sequence of
  values of two adjacent sites."
- p. 135: "Hence a knowledge of the time sequences of values of about 1.2 sites suffice in principle to determine the
  values of all other sites."
- §7, p. 146: "Given say t steps in the time sequence of values for two adjacent sites, the initial configuration up to
  t sites to the left can be deduced directly by iteration of Eq. (3.3). The combinatorial results of Section 4
  indicate in fact that only about 1.2 such temporal sequences should on average be required."

This is not the identity as a theorem. It is the earliest source found for two adjacent columns determining Rule 30 to
their west, and for reading the entropy as a number of column sequences. It should be credited.

Grassberger's notes to Table 6 also say: "for many rules, the exact value of h_μ is in fact obtained from patches of
width 1 or 2". That is optional to add.

## W3: what the thesis would say about Rule 30 (read on the owner's copy)

- Elementary automata have radius 1 in the thesis (Exemple 3.1.3; the printed m̃ = min(m, 0) of Définition 3.5.2 is
  presumably max). So Rule 30's canonical factor τ_F^r is **one column**.
- The sentence after Proposition 4.8.5 reads it for every permutive automaton: "On retrouve donc le résultat de [83] :
  les permutifs … ont une entropie égale à celle de leur facteur canonique". [83] is di Lena and Margara.
- Read so, Rule 30's entropy would be log 2, the question S20 leaves open.
- **The step it rests on fails for Rule 30.** Remarque 4.6.9 (τ_F^k conjugate to τ_F^r for k ≥ r) fails at r = 1:
  - the two-column trace has three constant points, (0,0), (0,1) and (1,0); (1,1) cannot be held, as cell 1 would turn
    white at the next tick, checked by hand and by brute force;
  - the one-column trace is the full shift, with two.
- Proposition 4.6.2's width m (= 1, the anchor) fails for the same reason. Rule 30 is positively left-expansive of width
  2, not 1 (§8.77).
- [83] proves width 2r + 1, three columns, as the essay says.
- **So the thesis does not settle the value log 2.** It is unsupported, not refuted, and open. The essay should say so,
  or a reader of the thesis may take S20's open question as answered.

## Proposed paragraph (W1, W2, W3, M1 applied; everything else unchanged)

> `Mixing` proves log 2 ≤ h ≤ log 3, and the kit's catalogue (§7, item 11) states the two-column identity in words. Its
> cover argument is what we use, with the number of pair words made visible (`coverMincard_le_card_pairWords`,
> carried here since the verifier's kit has it only inside a proof). Wolfram (1986, §§3, 4 and 7) noted that the
> temporal sequences of two adjacent sites of Rule 30 determine everything to their left, and read the entropy as about
> 1.2 such sequences. Di Lena and Margara (2007, Corollary 4.6) prove that the entropy of a permutive automaton of
> radius r is that of its width 2r + 1 column trace, which is three columns for Rule 30. Guillon's thesis (2008,
> Proposition 4.8.5) gives the entropy as that of the trace whose width is the radius, one column for Rule 30. The
> conjugacy it rests on (Remark 4.6.9) fails there, since the two-column trace has three fixed points and the one-column
> trace two, and it holds at width two. One column alone does not determine the cells to its west, and two do. Our notes of October 2026 had the two-column form for Rule 30 by hand, with the counts to length 17 and
> the bound 1.3189 bits. For the measure entropy, Wolfram (1986) has h_μ ≲ 1.20, with a note that Grassberger's results
> point to 1, and Grassberger's table (1986) has less than 1.15436. For the topological entropy, Wolfram's bound from
> locality is 2 bits. The tables and the count past 17 are from November. The general idea of bounding a language by a
> weighted automaton is standard.

**The abstract.** One clause has the same imprecision as W1. "The kit's `Mixing` has log 2 and log 3 as bounds and
describes the identity in words" can become "The kit's `Mixing` has log 2 and log 3 as bounds, and its catalogue states
the identity in words". That adds three words, giving 236 of 250. Adding Wolfram to the abstract is the author's choice.

## Answered after the first read (K85 addendum 1)

- **Q1, answered.** The October record has every count for n = 1 to 17, so "with the counts to length 17" stands.
  - §8.77 prints the counts at 14 and 17.
  - placego's L427 (9 October 2026, 15:53 BST) has n = 1 to 14: 4, 12, 32, 80, 200, 496, 1,208, 2,916, 6,964, 16,476, 38,616,
    89,844, 207,544 and 476,596.
  - L436 (16:36 BST) has 1,089,000, 2,477,236 and 5,615,036 for n = 15 to 17.
- **N1, closed.** placego is public (the owner), and the kit patch's link to §8.77 resolves.
- **Guillon: read on the owner's copy** (K85 addendum 2). The essay's sentence is accurate, and W3 above is
  recommended.
- **Scope.** None of this touches the Lean, the headlines or the kit patch's mathematics. W1, W2 and M1 are essay text
  and need a notebook rebuild. The abstract change needs one line. Adding Wolfram 1986 to the kit patch's docstring is
  optional, and it would need the patch re-read.

## The novelty claims stand

"New here are the identity in Lean on Mathlib's cover entropy, the reusable bound and its instance."

- The kit at the pin proves only the two bounds.
- M184's portal search found no entry with "topological entropy".
- Searches here found no published bound on Rule 30's topological entropy below 2 bits, other than the kit's log 3:
  - Rule 30 with topological entropy and an upper bound;
  - permutive automata and adjacent-column traces;
  - tables of elementary-automaton entropies;
  - Ban, Chang, Chen and Lin (JCA 6, 2011), which concerns equilibrium measures and pressure, abstract only.
- The closest relatives are the sources above.
