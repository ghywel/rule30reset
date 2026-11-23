(* nbchecks.wl: the checks on a built essay.nb, shared by build_notebook.wl and check_notebook.wl.
   checkNotebook[packet, extra] returns an Association and writes PACKETDIR/build.json. *)

utf8File[f_] := FromCharacterCode[Normal[ReadByteArray[f]], "UTF-8"];
shaFile[f_] := FileHash[f, "SHA256", All, "HexString"];
shaString[s_String] := Hash[StringToByteArray[s, "UTF-8"], "SHA256", "HexString"];
(* the plain text of a TextData cell, with each inline formula or inline code written back as a code span.
   MarkdownToNotebook writes a code span either as boxes, Cell[BoxData[...], "InlineFormula"], or as a plain string,
   Cell["Rule30Realization.evol", "InlineCode"] (S6, M92); both are read. *)
cellText[TextData[parts_List]] := StringJoin[Replace[parts, {
    s_String :> s,
    Cell[c : (_BoxData | _String), "InlineFormula" | "InlineCode", ___] :> "`" <> StringJoin[Cases[{c}, _String, Infinity]] <> "`",
    _ -> ""}, {1}]];
cellText[s_String] := s;
cellText[_] := "";

checkNotebook[packet_String, extra_Association] := Module[
  {nbFile = FileNameJoin[{packet, "essay.nb"}], nb, source, abstract, strings, outputs, messages, absCells, res},
  nb = Import[nbFile, "NB"];
  source = utf8File[FileNameJoin[{packet, "Rule30Submission.lean"}]];
  abstract = StringTrim[utf8File[FileNameJoin[{packet, "abstract.txt"}]]];
  (* the embedded source: plain form starts "import Ruliology", the kit's module form starts "module" (M9, M122) *)
  strings = DeleteDuplicates[Cases[nb, s_String /; StringStartsQ[s, "import Ruliology" | "module\n"], Infinity]];
  outputs = Cases[nb, Cell[_, "Output", ___], Infinity];
  messages = Cases[nb, Cell[_, "Message" | "MSG", ___], Infinity];
  absCells = Cases[nb, Cell[c_, "Abstract", ___] :> c, Infinity];
  res = Join[extra, <|
    "notebook_sha256" -> shaFile[nbFile],
    "notebook_bytes" -> FileByteCount[nbFile],
    "iconized" -> ! FreeQ[nb, "IconizedObject"],
    "source_sha256" -> shaFile[FileNameJoin[{packet, "Rule30Submission.lean"}]],
    "embedded_source_sha256" -> (shaString /@ strings),
    "embedded_source_matches" -> (strings === {source}),
    "abstract_matches" -> (Length[absCells] === 1 && StringTrim[cellText[First[absCells]]] === abstract),
    "output_cells" -> Length[outputs],
    "message_cells" -> Length[messages],
    "failed_outputs" -> Count[outputs, Cell[c_, ___] /; ! FreeQ[c, "$Failed"]],
    "kernelcheck_ok" -> ! FreeQ[outputs, "KernelChecked"],
    (* METHOD section 13: the notebook goes public, so no local path may sit in it *)
    "local_paths" -> Length[Cases[nb, s_String /; StringContainsQ[s, {"/Users/", "/home/", "/private/", "C:\\Users"}], Infinity]],
    "leanlink_version" -> Quiet[Check[PacletFind["Wolfram/LeanLink"][[1]]["Version"], Missing[]]]|>];
  Export[FileNameJoin[{packet, "build.json"}], res, "RawJSON"];
  res];
