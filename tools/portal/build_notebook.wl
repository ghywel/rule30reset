(* build_notebook.wl: build a submission's notebook from its essay.md and check the result (METHOD section 12).

   wolframscript -file tools/portal/build_notebook.wl PACKETDIR KITDIR

   PACKETDIR holds essay.md, abstract.txt and Rule30Submission.lean; essay.nb and build.json are written there.
   KITDIR is a built kit at the verifier's commit; it is passed to the essay as RULE30PRIZE_KIT, as the verifier
   does. The notebook is built with MarkdownToNotebook, "UseCache" -> False, in this fresh kernel. Checks:
   the source sits in an icon; the embedded source equals Rule30Submission.lean byte for byte; the notebook's
   abstract equals abstract.txt; no output is $Failed and no message cell appears; the kernel check succeeded.
   Nothing here prints account, licence or machine identifiers. *)

{packet, kit} = Take[$ScriptCommandLine, -2];
md = FileNameJoin[{packet, "essay.md"}];
nbFile = FileNameJoin[{packet, "essay.nb"}];

SetEnvironment["RULE30PRIZE_KIT" -> kit];
$CloudConnected;
md2nb = ResourceFunction["https://www.wolframcloud.com/obj/wolframinstitute/DeployedResources/Function/MarkdownToNotebook"];
t0 = AbsoluteTime[];
built = md2nb[md, nbFile, "UseCache" -> False];
seconds = Round[AbsoluteTime[] - t0, 0.1];

Get[FileNameJoin[{DirectoryName[$InputFileName], "nbchecks.wl"}]];
result = checkNotebook[packet, <|"built" -> FileExistsQ[nbFile], "build_seconds" -> seconds|>];
Print[ExportString[result, "RawJSON"]];
