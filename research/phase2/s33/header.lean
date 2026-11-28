/-!
# An isolated black cell within seven wheels after a first clock loss

On a recurrent left-edge strip of Rule 30 (`Recurrence d`, `PrefixClocks d`), let `FirstLoss d a e` say that wheel `a`
is permanently white, the prefix through `a` has least clock `2 ^ e`, and wheel `a + 1` reads its complement `2 ^ e`
ticks later. Let `NextWhite d a b` say that `b` is the next permanently white wheel.

* `ClockPhasePairs.five_ticks`: every five consecutive ticks contain one at which wheels `j`, `j + 1`, `j + 2` read
  white, black, white, with `a ≤ j` and `j + 2 ≤ min(b, a + 7)`, for every `e` and from every tick.
* `ClockPhasePairs.three_pairs`: among three consecutive ticks and their translates by `2 ^ e`, one has such a
  singleton by `min(b, a + 6)`.
* `ClockPhasePairs.cofinal_singletons`: on a strip with a black edge, one fixed tick of any five sees such
  singletons at first losses beyond every depth.

The verifier's kit revision lacks four of the modules used. They are carried first, from the kit at `ea5d70e`, in
the namespaces `Rule30Submission.Kit…`. `Rule30ThreePhaseReturn`, `Rule30RootedWhiteReturns` and
`Rule30RecurrentStrip` are carried whole (Rule 30 Prize submission R30-20261120-eb2bcc). From `Rule30RelaxedWindows`
the definitions, `DLMinusOne`, `unbounded_first_losses` and `exists_next_white` (R30-20261120-8dc0b3) and Quint
and Gemini's `DL`, `dlMinusOne_of_dl` and `firstLoss_cascade_and_immediate_catch` (R30-20261123-98c017) are
carried. The theorems that need the every-k modules, and two certificates, are left out.
-/
