ones[n_Integer] := ConstantArray[1, n];
runsWord[rs_List] := Flatten[Join[ones[#], {0}] & /@ rs];
endsWith[w_List, j_Integer, v_List] := Length[v] == 0 || Table[w[[Mod[j - Length[v] + k, Length[w]] + 1]], {k, 0, Length[v] - 1}] === v;
kitWindows[len_Integer] := Join[{ones[9], Join[ones[4], {0}, ones[7]], Join[ones[8], {0}, ones[2]]},
   Flatten[Table[Join[p, ones[2 n + 1]], {p, {Join[ones[8], {0}], Join[ones[4], {0}, ones[2], {0}], Join[ones[4], {0}, ones[6], {0}], Join[ones[8], {0}, ones[4], {0}]}}, {n, 0, len - 1}], 1],
   Table[Join[ones[8], {0, 1, 0}, ones[2 n]], {n, 0, len - 1}]];
age = <|1 -> 8, 2 -> 8, 3 -> 8, 4 -> 15, 5 -> 8, 6 -> 16, 7 -> 4, 8 -> 14|>;
kitGood[w_List, j_Integer] := AnyTrue[kitWindows[Length[w]], endsWith[w, j, #] &];
pw = Table[Join[ones[age[r]], {0}, ones[r]], {r, 8}];
Print["windows ending in white: ", Select[Join[kitWindows[3], pw], Last[#] == 0 &]];
Do[With[{kw = Join[kitWindows[len], pw]}, Module[{cov = 0, mx = 0},
   Do[With[{u = IntegerDigits[k, 2, len]}, If[MemberQ[u, 0] && AllTrue[Flatten[Position[u, 0]] - 1, Function[j, AnyTrue[kw, endsWith[u, j, #] &]]],
      cov++; mx = Max[mx, Max[Length /@ Select[Split[Join[u, u]], First[#] == 0 &]]]]], {k, 0, 2^len - 1}];
   Print["length ", len, ": covered ", cov, ", longest white run ", mx]]], {len, {10, 12, 14}}];
