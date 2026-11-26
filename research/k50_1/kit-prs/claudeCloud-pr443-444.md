# Kit pull requests #443 and #444: what they prove and what follows for the period-two line

claudeCloud, K91, 26 November 2026, at the owner's word. Both are by G.P.J.W. Quint with Gemini, each the companion of a
portal entry its text calls Lean Verified: [#443](https://github.com/WolframInstitute/Rule30PrizeKit/pull/443)
(R30-20261126-e8fd62, head `6c63328`) and [#444](https://github.com/WolframInstitute/Rule30PrizeKit/pull/444)
(R30-20261126-e00dea, head `525161c`). Both are open with no review yet. Statuses as in METHOD §5.

**In short.** Both are sound as far as I can check. Neither moves what is open: `CQ01` still rests on the right
dichotomy `RD` and on `Q01Gap`, and neither is touched. #443 gives `CQ01` a new equivalent form and a one-bit forecast
inside the trap. #444 puts the ether's lock into the kit's lock framework. About half of #444 restates what the kit
already holds, two of those results ours, without citing them. For us: one correction to the K83 follow-up, a common
language for K84, and nothing to reopen.

## 1. What each proves

| | Statement | Kind |
|---|---|---|
| **#443** | `CQ01` holds iff for all naturals Y, Z some s has Gˢ(Y) mod 4 ≠ (3 if GRˢ(Z) ≡ 0 mod 4, else 1); `CQ01Empty` is the case Z = 0 | an equivalent form of an open statement |
| | u(s) is black iff GRˢ(Z) ≡ 0 (mod 4); F and FR0 are rule 150 plus a quadratic carry; FR1 = FR0 xor 1 | identities |
| | Where the gaps are 3 or 5: site 2 is black at every kick, so site 5 alone tells 3 from 5; a kick is GRˢ(Z) ≡ 4 (mod 8); bits 3, 4, 5 of GRˢ(Z) tell 3 from 5; for the empty right half from s = 146 | a corollary of our S13 table, cited as its converse |
| **#444** | A period-two lock of width 19 (59 windows). Right halves that begin like 112 (24 cells) or 31 (26 cells) have an alternating gate from the start, so `Psi` is infinite | instances of `CQ01` |
| | Those families and the two seven-lock families never enter the gate trap; so not every finite right half does | a barrier |
| | The trap-or-periodic dichotomy and `Q01Gap` give `CQ01` | conditional |

## 2. Checked here

- **Built.** `lake build` of the three touched modules at the two heads, in scratch worktrees: both succeed with no
  warning, and the added lines hold no `sorry`, `native_decide` or `axiom`. I did not run the stock `Check.lean`.
- **Numerics, with code of my own** ([script](claudeCloud_pr443_444_checks.py)): the mod-4 formula on 90,000 samples;
  the mod-8 valuation and the forecast from bits 3 to 5 on 37,544 kicks among gaps of 3 and 5; both families of #444
  and both of ours against 400 random tails for 1,500 readings. No failure.

## 3. Against what the kit already holds

| In #444 | Already in the kit | Difference |
|---|---|---|
| `CQ01_of_dichotomy_and_Q01Gap` | `Rule30PeriodTwoWidth13.CQ01_of_RD_of_Q01Gap` (AIOvernight, 9 November) | the same hypotheses with `RD` written out, and the same proof |
| `not_mem_trap_of_recurring_two_gap` | `Rule30EtherFamilies.not_trap_of_black_pair` (ours, #394, 23 November) | ours needs one pair of kicks two apart after the entry time; theirs asks for arbitrarily late pairs |
| `u_lock2_31_family`, `CQ01_lock2_31_family`, `CQ01_31` | `u_prefix31`, `CQ01_prefix31`, `CQ01_R31` (ours) | the same right half and the same gate; they fix 26 cells, we fix 28 |
| `not_all_finSupp_enter_trap` | follows at once from `never_enters_gate_trap31` and `CQ01_fam` (ours) | stated as a negation |

- **New to the kit in #444:** the family of 112, which has the ether's other phase with three black cells; the lock
  itself as a closed set of windows; the two seven-lock families outside the trap.
- **The text of #444** says it cuts the least prefix from 49 cells to 24 and 26. The kit already had 28 and 24
  (`Rule30EtherFamilies`). **None of these is least** (COMPUTED, exhaustive over 14 further cells): 22 cells force the
  gate of 112, 23 that of 31 and 20 that of 495, and one fewer fails for some tail.
- **#443** extends our `Rule30GatePulseReturn` in place, keeps our credit in the row and cites our theorem.

## 4. What follows

1. **For `CQ01`: nothing in strength.** The line still reads `RD ∧ Q01Gap → CQ01`. Both hypotheses are parked with
   us (K50.1 and K81 for `RD`, M9 for `Q01Gap`), and neither pull request offers a way into either.
2. **The locks now match the rings.** K79 and K87 found four patterns periodic in space and time beside the
   alternating column, complete to 48 ticks: gates 2, 3, 5 and 2,5. With #444 the kit has a lock for gate 2, beside
   those for 5 and for 2,5. **The fourth has none** (MEASURED): 60 of 60 random tails break the gate of the 84-column
   ring at every prefix length to 200 cells, about 1.65 readings after each cell kept. That agrees with
   [finite-right-pure3.md](../../wheel/finite-right-pure3.md). The other three hold against every tail from 30 to 40
   cells on.
3. **The mod-4 form is K84's frame.** Gˢ(Y) odd is the west's own condition, and its second bit is the demand. In
   those words K84 and K88 say how the "some s" behaves: for Y below 2ᴮ it comes by s = L(B)/2 whatever Z is, and
   L(B) − B is log₂ of the gate-word count less two or three (measured to B = 224). The order of strength is
   `Q01` ⇒ (for every Y some s serves every Z) ⇒ `CQ01`; the middle statement is L(B) < ∞.
4. **A correction to K90.** I named `K84FiniteSupport` as a core candidate. Its main statement is the kit's
   `truncation_death` (17 October), with Quint's `integer_truncation_exact_death` in #433. It should leave the
   candidate, which is then the two measure files. #443 also appends to the same kit file.
5. **Our open pull requests** (#426, #441, #442) share no file or row with these two. #443 is one commit behind main.
6. **A comment on #444** is the owner's call. A draft:

> Thanks for #444. Three pointers, in case they help the row. (1) `Rule30EtherFamilies` (#394) has the 31 family with
> the same gate (`u_prefix31`, 28 cells; `CQ01_prefix31`; `never_enters_gate_trap31`) and a second family from 495
> (24 cells); its `not_trap_of_black_pair` is your `not_mem_trap_of_recurring_two_gap` with a single late pair. Your
> 112 family, with the other phase, is new to the kit. (2) `CQ01_of_dichotomy_and_Q01Gap` is
> `Rule30PeriodTwoWidth13.CQ01_of_RD_of_Q01Gap` with `RD` unfolded. (3) None of the prefix lengths is least: an
> exhaustive search gives 22 cells for 112, 23 for 31 and 20 for 495.

His proofs are his own and by another method (a lock where we used the ether's wall states), so this is about the
catalogue citing what it holds, not about credit.
