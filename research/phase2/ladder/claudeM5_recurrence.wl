(* K92.2, claudeM5: does D(n) = E(n, n, 2n) satisfy a linear recurrence?

   For each N, fit the shortest linear recurrence with constant coefficients to D(1..N) (FindLinearRecurrence),
   and test it on the terms it was not fitted to. A recurrence of order r needs about 2r terms to be found, so a fit
   whose order is the data limit, about N/2, says nothing; one that predicts the held-out terms is a law.
   Also: FindSequenceFunction (holonomic and closed forms), FindGeneratingFunction, the same on the even and odd
   subsequences and on the counts split by row width, and a fit of log D(n) to n log(lambda) + beta log(n) + c.

   Usage: wolframscript -file claudeM5_recurrence.wl DATA.m
   DATA.m holds <|"D" -> {D(1), D(2), ...}, "byWidth" -> <|n -> <|w -> count|>|>|> *)

data = Get[$ScriptCommandLine[[2]]];
d = data["D"];
nD = Length[d];
Print["terms: ", nD];

heldOut[seq_, n_] := Module[{rec, ord, pred, ok},
  rec = Quiet[FindLinearRecurrence[Take[seq, n]]];
  If[! ListQ[rec], Return[{n, None, None}]];
  ord = Length[rec];
  pred = If[n < Length[seq], LinearRecurrence[rec, Take[seq, n][[-ord ;;]], Length[seq] - n + ord][[ord + 1 ;;]], {}];
  ok = If[pred === {}, None, pred === Take[seq, {n + 1, Length[seq]}]];
  {n, ord, ok}];

Print["shortest recurrence on D(1..N): {N, order, predicts every later term}"];
Do[Print[heldOut[d, n]], {n, 8, nD}];

full = Quiet[FindLinearRecurrence[d]];
Print["on all ", nD, " terms: order ", If[ListQ[full], Length[full], full]];
small = Table[{r, Quiet[FindLinearRecurrence[d, r]]}, {r, 1, Floor[nD/2] - 2}];
Print["a recurrence of order r <= ", Floor[nD/2] - 2, " that fits all terms: ", Select[small, ListQ[#[[2]]] &]];

Print["FindSequenceFunction: ", Quiet[TimeConstrained[FindSequenceFunction[d, n], 600, "timed out"]]];
Print["FindGeneratingFunction: ", Quiet[TimeConstrained[FindGeneratingFunction[d, x], 600, "timed out"]]];

ev = d[[2 ;; ;; 2]]; od = d[[1 ;; ;; 2]];
Print["even n: ", heldOut[ev, Length[ev] - 2], "  odd n: ", heldOut[od, Length[od] - 2]];
Print["ratios D(n+1)/D(n): ", N[Ratios[d][[8 ;;]], 6]];

fitData = Table[{k, Log[d[[k]]]}, {k, 10, nD}];
fit = NonlinearModelFit[fitData, k Log[lam] + beta Log[k] + c, {{lam, 1.76}, {beta, 0}, c}, k];
Print["log D = n log lam + beta log n + c on n >= 10: ", fit["BestFitParameters"], "  max residual ",
  Max[Abs[fit["FitResiduals"]]]];
fit0 = NonlinearModelFit[fitData, k Log[lam] + c, {{lam, 1.76}, c}, k];
Print["with beta = 0: ", fit0["BestFitParameters"], "  max residual ", Max[Abs[fit0["FitResiduals"]]]];

If[KeyExistsQ[data, "byWidth"],
  bw = data["byWidth"];
  (* the share of rows of each excess width e = 4n - W *)
  Do[Print["excess width ", e, ": ", Table[Lookup[bw[n], 4 n - e, 0], {n, Keys[bw]}]], {e, 0, 6}];
  Do[seq = Table[Lookup[bw[n], 4 n - e, 0], {n, Keys[bw]}];
     Print["excess ", e, ": ", heldOut[seq, Length[seq] - 2]], {e, 0, 3}]];
