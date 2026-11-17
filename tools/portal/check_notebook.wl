(* check_notebook.wl: rerun the checks on a packet's built essay.nb without rebuilding it.
   wolframscript -file tools/portal/check_notebook.wl PACKETDIR *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "nbchecks.wl"}]];
packet = Last[$ScriptCommandLine];
Print[ExportString[checkNotebook[packet, <|"rebuilt" -> False|>], "RawJSON"]];
