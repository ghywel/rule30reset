/-!
# An isolated black cell within seven wheels after a first clock loss

On a recurrent strip (`Recurrence d`, `PrefixClocks d`) with a first clock loss `FirstLoss d a e` and next permanently
white wheel `NextWhite d a b`:

* `five_ticks`: every five consecutive ticks contain one at which wheels `j`, `j + 1`, `j + 2` read white, black,
  white, with `a ≤ j` and `j + 2 ≤ min(b, a + 7)`, for every `e` and from every tick.
* `three_pairs`: among three consecutive ticks and their translates by `2 ^ e`, one has such a singleton by
  `min(b, a + 6)`.
* `cofinal_singletons`: on a strip with a black edge, one fixed tick of any five sees such singletons at first
  losses beyond every depth.

The proof follows the driver wheel `a + 1` from `firstLoss_cascade_and_immediate_catch`: a fall of the driver gives a
singleton at once; two black readings, or three white ones, make a wheel toggle beside a white one, and its next
fall is isolated (`toggle_catch`). With `Rule30FirstLossBounds` the catalogue already gives a reset in every fifteen
ticks within nine wheels. The prescribed tick of `DLMinusOne` stays open.
-/
