(* status.wl: the status of one submission, signed in as the owner. Prints only public fields.
   wolframscript -file tools/portal/status.wl R30-YYYYMMDD-xxxxxx *)
id = Last[$ScriptCommandLine];
$CloudConnected;
r = URLExecute[CloudObject["https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/status"], {"id" -> id}, "RawJSON"];
c = Lookup[r, "check", <||>]; get[a_, k_] := Lookup[a, k, Null];
Print[ExportString[<|"id" -> get[r, "id"], "status" -> get[r, "status"], "tags" -> get[r, "tags"],
   "state" -> get[c, "state"], "detail" -> get[c, "detail"], "kitCommit" -> get[c, "kitCommit"],
   "reasons" -> get[c, "reasons"]|>, "RawJSON"]];
