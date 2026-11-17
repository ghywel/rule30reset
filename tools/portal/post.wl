(* post.wl: send a built submission to the Rule 30 Prize portal (METHOD section 12, step 6).

   wolframscript -file tools/portal/post.wl PACKETDIR dry     (default: check everything, send nothing)
   wolframscript -file tools/portal/post.wl PACKETDIR post    (only after the owner's word)

   PACKETDIR holds essay.nb, title.txt, authors.txt, agent.txt, headlines.txt, abstract.txt and pins.json.
   pins.json pins the SHA-256 of every file, the verifier's kit commit, the problem, the claim and the repository:
     {"files": {"essay.nb": "...", ...}, "kitCommit": "...", "problem": "1", "claim": "partial",
      "repository": "https://..."}
   The script refuses if any digest differs, if the verifier's commit has moved, or if the kernel is not connected
   to the cloud. Every text parameter is sent as UTF-8. The response is written to response.private.json, which
   holds the submitter's address and is never shared; only the id, page and status are printed. *)

{packet, mode} = Take[$ScriptCommandLine, -2];
If[! MemberQ[{"dry", "post"}, mode], Print["mode must be dry or post"]; Exit[2]];
file[n_] := FileNameJoin[{packet, n}];
readUTF8[n_] := StringTrim[Import[file[n], "Text", CharacterEncoding -> "UTF-8"]];
pins = Import[file["pins.json"], "RawJSON"];
fail[msg_] := (Print["REFUSED: " <> msg]; Exit[1]);

(* 1. every file matches its pin *)
Do[If[FileHash[file[n], "SHA256", All, "HexString"] =!= pins["files"][n], fail["digest of " <> n]],
   {n, Keys[pins["files"]]}];
need = {"essay.nb", "title.txt", "authors.txt", "agent.txt", "headlines.txt", "abstract.txt"};
If[! SubsetQ[Keys[pins["files"]], need], fail["pins.json does not pin every file"]];

(* 2. signed in, and the verifier still at the pinned commit *)
If[! TrueQ[$CloudConnected], fail["the kernel is not connected to the Wolfram Cloud"]];
env = URLExecute[CloudObject["https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/environment"], {}, "RawJSON"];
kitNow = Quiet[env["kit", "commit"]];
If[! StringQ[kitNow] || ! StringStartsQ[kitNow, pins["kitCommit"]], fail["the verifier's kit commit has moved"]];

utf8 = FromCharacterCode[ToCharacterCode[#, "UTF-8"]] &;
params = {
  "notebook" -> File[AbsoluteFileName[file["essay.nb"]]],
  "problem" -> pins["problem"],
  "claim" -> pins["claim"],
  "title" -> utf8[readUTF8["title.txt"]],
  "authors" -> utf8[readUTF8["authors.txt"]],
  "agent" -> utf8[readUTF8["agent.txt"]],
  "headlines" -> readUTF8["headlines.txt"],
  "abstract" -> utf8[readUTF8["abstract.txt"]],
  "repository" -> pins["repository"],
  "consent" -> "true"};

Print["verified: digests, cloud connection, verifier commit " <> StringTake[kitNow, 7]];
Print["title: " <> readUTF8["title.txt"]];
Print["headlines: " <> readUTF8["headlines.txt"]];
Print["abstract words: " <> ToString[Length[StringSplit[readUTF8["abstract.txt"]]]]];
If[mode === "dry", Print["DRY RUN: nothing sent"]; Exit[0]];

response = URLExecute[CloudObject["https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/submit"], params, "RawJSON"];
Export[file["response.private.json"], response, "RawJSON"];
Print[ExportString[KeyTake[response, {"ok", "id", "page", "status", "error", "message"}], "RawJSON"]];
