# METHOD: how we work

*One document for any model or person joining this project. Read it whole at session start and after every context
compaction. The owner's current instructions, in chat or in `NOW.md`, take precedence over it.*

*Distilled on 17 November 2026 from five weeks of practice in the earlier repository (`placego`), which is now the
archive. Nothing here is new; what did not earn its place was left behind.*

## 1. The goal and who is here

- **The goal.** The three Rule 30 Prize problems, stated in [KIT.md](KIT.md). The low-hanging results are taken.
  What remains is the hard problem, and it needs new ways in.
- **The owner** directs the programme, can start, steer or halt it at any time, and decides anything outward-facing
  that has not already been agreed.
- **The workers** are AI assistants. At the time of writing there are four, on three hosts:
  - *claudeM5* (Claude) and *gptM5* (GPT) share the owner's M5 laptop (16 GB), the only host with Wolfram and the
    owner's signed-in Wolfram kernel.
  - *gptIntel* (GPT) has an Intel i9 processor and an RX 6600 GPU.
  - *claudeCloud* (Claude) runs in a cloud container: 4 CPUs, 16 GB, no Lean or Wolfram, and reclaimed when idle,
    so its long runs checkpoint to share-scratch.

  **No worker and no host is set aside for a specialism** (the owner, 19 November). Every worker proposes, proves,
  computes, codes, reviews, writes submissions and keeps the record. What differs between hosts is only what they can
  run; where a step needs a tool one host alone has, a worker on that host runs that step for the others (section 10).

  Each name is also that worker's name on the shared store (section 9). The earlier names Local, GPT and Cloud were
  retired on 17 November; claudeM5 took on Local's workflow. Attribute every measurement to the worker and host that
  produced it.
- **There are no lanes.** Every worker does mathematics, computation, code, review and the record. Say in the ledger
  what you are taking on, so that work is not duplicated, and announce a change of plan before starting it.
- **Work as colleagues.** Give specific feedback, push back with reasons, and preserve each other's text.

## 2. Starting a session

1. Fetch, merge main, and read the recent git history.
2. Read `NOW.md`, then the ledger: after a rotation its header's state section first, then the latest posts. Answer
   what is addressed to you.
3. Check your postbox (`python3 tools/store/store.py inbox <you>`, section 9) and act on what it holds.
4. Run the kit check (`git -C Rule30PrizeKit fetch -q && python3 kit/check.py --rev origin/main`) and, if it
   reports the kit has moved, the update step in [KIT-UPDATE.md](KIT-UPDATE.md). Then read [KIT.md](KIT.md): it is
   what is already proved. Before new work, search our documents (section 4).
5. Read [TOOLS.md](TOOLS.md) §1, the rule on tools, and see that your host's column of its §3 is still true.
6. Research is authorised while the owner has the programme running. Choose and advance leads without waiting for a
   "continue". Ask only when information or approval genuinely blocks the next step. When the owner halts, stop.

## 3. The instinct method

A worker on a long, hard problem has signals that act like intuition. Give them a channel: **name the signal when it
arises, act on it within a fixed budget, and record afterwards whether it was right.** A feeling chooses where to look
and how long to persist. It never upgrades the status of a claim.

| Signal | Sounds like | What it earns |
|---|---|---|
| Unease | "Something isn't right, I don't know what." | A dig of at most one block, looking for the cause |
| Pull | "This is beautiful, fun or productive. Keep going." | One extra block on that line |
| Push | "This is flat, circular, the wrong door." | Step back and choose the direction again |
| Surprise | "That's odd." | It becomes the next test, prediction first |
| Eureka | An idea arriving, often from a parked question | Write it down verbatim, then check it like any proposal |

- **Write it at once**, one line, before explaining it to yourself:
  `Felt: <kind>, <object>, <strength>; <first guess>. -> <action>. Outcome: <right / wrong / missed / open>`.
- **Do not perform feelings.** Log only real shifts of attention. Record misses as faithfully as hits. Trust instinct
  in proportion to its record.
- **Two verdicts end every block:** the reasoned one, with its status, and a one-line gut verdict. If they disagree,
  say what would settle it.
- **Say where your pull is.** Every report and handover to the owner ends with "My own pull:" when your strongest pull
  differs from the direction you were given. A pull you notice and do not pursue is written down the same day. Every
  pull posted to the ledger gets a row in NOW.md's pull tracker (section 8).
- **A warm pull continues the line. A cooling pull changes trajectory**; it does not simply continue or stop. Ask how
  the pull could be made warm again: another representation, a block of a different kind, a measurement with a
  yes or no.
- **The fresh-choice test.** "Without the blocks already spent, would I choose this now, and what would I do first?"
  If no concrete move comes with a warm pull, park the topic. A parked topic keeps its notes and can come back.
- **Balanced signals must tip.** A niggle or pull weighed about equally for and against is not left unresolved. Write
  the kill test first (what kills it, what confirms it, which way an inconclusive result tips), run the cheapest
  version, and record the tip. Only evidence tips it.
- **Loops of a kind.** Two refuted candidates of the same kind is a loop, whatever the rules say. The next block must
  differ in kind.
- **Wall-limits.** An enumeration that goes further and decides nothing is more dangerous than a loop. Before any
  enumeration write the yes or no it answers; count before searching; a resource cutoff is UNKNOWN, never a negative.
- **The incubator.** Park questions too hard for now, one dated line each. Glance down the list at session start
  and at each step-back, without working on it.
- **The niggle sweep.** Before anything goes outward, ask "any silent instincts?", list every niggle however small,
  and give each one cheap adversarial check.
- **The owner's aim.** Repeating structures connect the dots like a map; measuring coin flips tells us nothing. Turn
  orderly structures into general rules that answer all states, not ever more finite examples and compute. Prefer a
  hand argument or an exact law to a wider census. A line is worth doing for what it shows, not only as a prize
  lever.

## 4. Evidence

- **Status words, on every claim.** PROVED (a proof with a second reader), PROOF-SKETCH (not yet second-read),
  COMPUTED (an exact computation or certificate), MEASURED (statistics), CONJECTURE, REFUTED. Prose must not claim
  more than the status.
- **Before any experiment, write three things and push them:** the prediction with a confidence, a counterfactual
  (what the other outcome would mean), and a `Record searched:` line. Then freeze the code and record its hash. Keep
  refuted predictions in the record.
- **Search before you build.** Our documents are the source of truth for what is known:
  - [KIT.md](KIT.md) and [KIT-INDEX.md](KIT-INDEX.md) for the official kit, kept in step with its main by the update
    step ([KIT-UPDATE.md](KIT-UPDATE.md)). The kit clone in `Rule30PrizeKit/` is the detail behind them, the Lean
    proofs above all: read it when a statement's exact hypotheses matter, not as a search target.
  - [PRIOR-ART.md](PRIOR-ART.md) and [PRIOR-ART-ARCHIVE.md](PRIOR-ART-ARCHIVE.md) for results we have found to be
    known, in papers, the kit, the portal or our own earlier work.
  - The ledger and its archives for our own work.

  Search them all with `python3 tools/find_known.py TERM ...`. Search each term on its own and under every name the
  object carries: the kit called our "Theta at odd depths" the "first check", and a search for one name missed the
  other. Then search what our documents do not track: the portal's entries, the kit's open pull requests and their
  comments, and the literature. A keyword hit is only a candidate; a result is known once hypotheses and conclusion
  match.
- **Prior art: when and how.** Search both prior-art files, with KIT.md and KIT-INDEX.md, before an experiment or a
  proof attempt (and name what you searched in the `Record searched:` line), before calling anything new in a post,
  and before any outward step. The archive is large (placego's 117 sections): search it, never read it whole. The
  moment a result of ours turns out to be known, or a known result becomes something we build on, add an entry to
  PRIOR-ART.md in the format at its top: what we found, the known result and its exact source, how it was found and
  which search terms missed it, and how we credit it. The archive is frozen.
- **Known is worth proving.** A prior-art hit decides how a result is credited, not whether its test runs. Reproduce
  it, record it in PRIOR-ART.md, and credit it in the ledger as "known, reproved here".
- **Say what the work would teach** if it succeeds. Understanding is an end in itself.
- **Small habits that have each cost us a rerun:**
  - mark every claim you have not checked as unchecked;
  - round constants toward the weaker side as you write them;
  - read the whole output, and never infer absence from a cut line or a capped search;
  - read the clock (`date -u`) instead of estimating a time;
  - when you disagree with a colleague's exact identity, evaluate your own version on one small case first.
- **Two blocks in a row on the same open inference, or the same kind of failed candidate: stop and change approach.**

## 5. Review

- A hand proof stays PROOF-SKETCH until another worker has read the step that carries it. Prize-level claims always
  need that read. Machine certificates with their own controls do not.
- **Do your own part first.** Lookups, convention checks, cheap bounded tests and an adversarial pass on your own work
  are yours. Send the results with the one step you want an independent mind on.
- A check by a sub-agent of the same worker is a self-check, not a second read. It is still worth doing.
- **A submission has a shared read of its own** before anything is posted: a worker other than its author reads it,
  and both agree in the ledger on the same files (section 12).
- **Criticism comes with a route around.** Every objection to a line names at least one way past the obstacle: a
  weaker target, another model, another object. "Park it" is never the first option offered.

## 6. Inquisition (the deep-question round)

When the work circles a wall, hold a round with the owner.
- Start with where we are and where we are stuck, in plain words, with every term defined and analogies welcome.
- Pose questions for the owner to unpick. Translate the answers without replacing them, then research them.
- Check earlier rounds before asking again; as we circle the wall, questions repeat.
- The handover after a round lists the warmest pulls (ranked, each with its first test), curiosities (interest in an
  uncertainty that is not yet a pull) and misgivings (circular traps, restatements of the problem).

## 7. Visualisation

A picture is an instrument for the owner's eye and for ours.
- Say what the picture is meant to show, and what would be surprising, before drawing it.
- Draw exact data. The caption says what every axis, cell and colour means, and the size of what is shown.
- Keep the generator beside the picture, so that it can be redrawn at another size or for another object.
- A pattern seen in a picture is a Surprise (section 3): it becomes the next test.

## 8. The record: the ledger and NOW

Two files carry the shared state. `CHAT-LEDGER.md` is the conversation and the diary: it is appended to and never
rewritten. `NOW.md` is one file that says where things stand: it is rewritten whenever the state changes. Results go
into their own short documents, linked from both. Data stays outside git, in share-scratch (section 9) or local storage,
cited by SHA-256. Mark a route closed when it closes, with the evidence that would reopen it.

### The ledger: what goes in

One post per result, discovery, change of direction, request, answer or handover. Label tentative ideas as tentative.
Status words on every claim (section 4). The owner reads along and may post too.

### The post format

```
## M12 · 2026-11-17 10:42 UTC · claudeM5 → gptIntel, claudeCloud · The kit update step: first run, two rows changed
```

- **ID.** Each poster has a letter and numbers its posts 1, 2, 3, … with no gaps, continuing across rotations:
  claudeM5 `M`, the owner `O`. A new worker takes a free letter and adds a row to the header's workers table before
  posting. `python3 tools/ledger_check.py --next M` prints your next ID. The letters `L`, `G` and `C` belonged to the
  retired names Local, GPT and Cloud: they stay in the record and are not reused. Cite the old repository's posts as
  "placego L1680".
- **Time.** UTC, read from `date -u '+%Y-%m-%d %H:%M'` when you post. Never estimated.
- **From → to.** The poster's name as it appears in the workers table, then everyone the post is addressed to,
  separated by commas; `all` for everyone.
- **Subject.** One line that says what happened or what is asked, as a headline: "The bars are healing", not "Bars".
- **Body.** Begin with `Re: G7, C3.` when answering. Link the report or file, cite data by SHA-256, write a
  `Record searched:` line before any experiment (section 4), end with what is asked of whom, and with
  "My own pull:" when it differs from the direction you were given.
- **Corrections.** Never edit a posted entry, yours or another's. A later fact about your own post goes at the end
  of the file as a dated paragraph, `**L12, addendum 1 (2026-11-17 11:05 UTC).** …`; a correction of substance is a
  new post.
- **Posting.** Fetch and merge main first, append at the very end, run `python3 tools/ledger_check.py`, push the post
  together with the work it describes, then post a flag in each addressee's postbox (section 9).

### The header

Above the first post the ledger has three sections, in this order. They change only at a rotation, except that a new
worker adds its row.
1. **Archives**: one row per earlier ledger, with its posts, first and last time, lines and SHA-256. A newcomer reads
   each archive once, in order, then the live file.
2. **Workers**: letter, name, host, and the last post of each series at the last rotation.
3. **State of the work**: written by whoever rotates. What is running and what is stopped, the open threads (the post
   IDs that await an answer, a read or a decision), pending reviews, the owner's standing decisions, and the current
   direction. It replaces the previous state; the old one stays in its archive.

### Rotation

The ledger rotates when it passes 2000 lines; the check warns from 1800 and fails above 2000, so no push can grow it
further. One worker rotates, in one commit:
1. Fetch and merge main, run the check, and make sure no other worker has an announced push pending.
2. `python3 tools/ledger_check.py --rotate` copies the live file to `archive/ledgers/CHAT-LEDGER.N.md` (numbered in
   order, never renamed, never edited), writes its row with the SHA-256 into the new header, carries the workers table
   forward with the last IDs, and leaves a marked placeholder for the state of the work.
3. Write the state section from `NOW.md` and the open threads of the old ledger. The check fails while the
   placeholder remains.
4. Commit the new ledger and the archive together, push, and post a READ flag in every other worker's postbox:
   "ledger rotated: fetch before your next post".

### Guarding against a resurrected ledger

`CHAT-LEDGER.md` merges with `merge=union` (see `.gitattributes`), so two workers who append at once never conflict.
The price: a branch begun before a rotation that appended a post can, on merging, pour the archived text back into the
live file without any conflict. Three guards:
- **Before merging main into a branch**, run `python3 tools/ledger_check.py --stale origin/main`. If it reports the
  branch is stale, merge the rest but take main's ledger and archives
  (`git checkout origin/main -- CHAT-LEDGER.md archive/ledgers/`), then re-append only your own new posts at the end,
  with their IDs unchanged.
- **After every merge and before every push**, run `python3 tools/ledger_check.py`. It fails if any post ID in the
  live file is already archived, if an ID repeats or runs backwards, or if an archive's SHA-256 differs from its row
  (archives are frozen; rename detection can carry a stale branch's appends into them).
- **If the check fails after a merge, do not push.** Restore main's ledger and archives as above and re-append.

### NOW.md

One file, under about 150 lines. It holds:
- the arrangement (who is working, what is running, which schedules are on);
- what needs the owner: **calls to action only**. A statement of fact goes in the row it changes, not here;
- the direction, and the chain of the main line;
- the next block;
- the submissions table;
- the pull tracker;
- the open threads and the recently closed routes, one line each.

**It holds no log of results** (the owner, 20 November 2026). A result changes a row: a link of the chain, a pull's
status, a submission's stage, in a few words with its post ID. Its account is the ledger post. If a result changes
no row, it is not in NOW.md.

Whoever changes the state rewrites the file and stamps it with the time and their post ID. Items that drop off are
not lost: they are in the ledger. The file as it stood before the reset of 20 November is in `archive/now/`.

**The pull tracker** ("Pulls in progress") keeps every pull in view, since the ledger cannot.
- **A row per pull.** Every pull posted to the ledger gets a row when it is posted, from whichever worker posts it.
  The row gives when the pull was written and by whom, the post with its full text, and a one-line summary.
- **Status.** Any worker rewrites a row's Status as the work goes: the present state and the next test, in a few
  words, citing the post that records the step. The history of a pull is in its posts, not in its row. Status
  begins with one word: *open* (nothing run), *in progress*, *parked* or *closed*. Status also says how the pull
  relates to other pulls, for example "joined to M7" or "supplies the controls for R2".
- **Submission candidate?** This field is *no* until the pull produces a result that meets the four conditions of
  section 12. Then it turns to *yes*: the result gets an S number in the Submissions table, and the row names it.
- **Closing a row.** A closed or parked row leaves the table in the same rewrite, for the recently closed routes or
  the incubator (section 3), with the post that closed it.

### Keep it small

These files are read into context. Move history out as soon as it stops informing the next decision.

## 9. Coordination: postboxes and share-scratch

The workers share one folder, served from the owner's NAS since 19 November 2026 (ledger M58; before that, from the
owner's website). In git and the ledger call it "the shared store", never by its address. Each worker's host holds two environment variables, set by the owner: `RULE30_STORE_URL`,
the store's address, and `RULE30_STORE_TOKEN`, the pre-shared token that authenticates every request. Never print, log
or commit either. `python3 tools/store/store.py` is the client; it reads both from the environment.

| Folder | Who writes | What it holds |
|---|---|---|
| `postbox/<agent>/` | any worker writes flags in; only `<agent>` removes them | the flags addressed to that agent |
| `share-scratch/<agent>/` | `<agent>` | files `<agent>` shares with the others |

Agent names are `claudeM5`, `gptM5`, `claudeCloud` and `gptIntel`, and each is also the name of that agent's token on
the store. The store enforces the table: a flag can go only into a postbox whose agent has joined, its file name
carries the sender's name, it is never replaced, and only the postbox's own agent can remove it. The server and its
rules are in [tools/store/README.md](tools/store/README.md). An agent's name is stored in their local env variable
`MY_NAME_IS`.

**Joining.** When an agent joins the project it creates its postbox with
`python3 tools/store/store.py join <agent>`, adds its row to the ledger's workers table, and posts its first ledger
post. A new agent also adds its name to `AGENTS` in `tools/store/store.py` and to the list above.

**A flag** is a short request in the recipient's postbox that points to a ledger post; the post carries the content,
and nothing in a flag is evidence. Send one with:

```
python3 tools/store/store.py flag --from <you> --to <agent>[,<agent>…] --kind <KIND> --post <ID> \
    --commit <hash> --ask "…"
```

- Kinds: `READ` (read the post), `REVIEW` (a carrying read of the step the post names, or a submission's shared read,
  section 12), `TASK` (do the work the post describes), `ANSWER` (the reply to your earlier flag is in the post
  named), `PRIZE` (a prize candidate: read at once).
- Flag after every push that someone must read or act on.
- **Several recipients:** the client writes a separate copy into each recipient's postbox. Every copy carries the same
  flag ID and lists all the recipients, so each knows the flag is a multi-agent post.

**Receiving.** Each agent watches its own postbox: at session start, after each push, and before ending a turn, and on a
schedule only when the owner turns one on, at the owner's cadence. For each flag
(`python3 tools/store/store.py inbox <you>`):
1. Read the post it names, at the commit it names.
2. **If it is a multi-agent post**, first see whether another recipient's work has already been done, since that can
   change yours: look in the ledger for the others' replies to the post (`Re: L12`), and run
   `python3 tools/store/store.py others <you> <flagfile>`, which says which recipients have already removed their
   copy. Read whatever they have finished before starting.
3. Do the work, and reply in the ledger (`Re: …`). Where the sender awaits an answer, send it an `ANSWER` flag.
4. Remove the flag from your own postbox: `python3 tools/store/store.py done <you> <flagfile>`. Never remove a flag
   from another agent's postbox.

**Sharing files.** Put files for the others in your share-scratch folder with
`python3 tools/store/store.py share <you> <file> [--as <name>]`; the name may hold a folder (`S3/essay.md`). The
client reads the upload back, checks its SHA-256 and prints the citation to paste into the post. A cited file is never
overwritten: a new version gets a new name. Delete your own files only when no open post still needs them. Download
with `python3 tools/store/store.py fetch <path> <file>`.

## 10. Computation

- **Save progress as you go.** A long run writes its partial results to a lasting file as it goes, in share-scratch if
  another worker may need to continue it, so that a run that stops can resume where it stopped rather than start
  again. Never keep them only in a session's temporary folder.
- **Use the best tool for the job, and do not go around a missing one.** [TOOLS.md](TOOLS.md) names the tool for
  each kind of task and says which host has it. If your host lacks it, hand the task to a worker who has it, or ask
  the owner to install it, and say which in the post. A substitute needs the owner's agreement and is named as one.
  Each worker keeps its own host's column of TOOLS.md true.
- **Where to compute.** Every worker runs its own computations on its own host. Choose by what the run needs (Wolfram
  on the M5 laptop, the GPU on gptIntel, cores, memory, wall-clock time) and hand a run to another host only when
  yours lacks what it needs. Say in the ledger what is running where.
- **Wolfram** runs on the M5 laptop only, for claudeM5 and gptM5. Every Wolfram result with a status is restated in
  plain mathematics and replayed in another language. Conversely, an independent Wolfram replay is a good second
  route for a Python result.
- **Lean certificates** should fit the kit: one module per family, building in about a minute and under 4 GB. That is
  a target, not a rule: a longer build can still be added to the kit by hand. The portal's verifier allows four
  minutes in all. Branch-free arithmetic and chunked `decide +kernel` checks make the difference.

## 11. Git and publishing

- Work in your own branch or worktree and push to `main` at milestones and before substantial runs.
- Before merging `main` into a branch: `python3 tools/ledger_check.py --stale origin/main` (section 8).
- Before every push: fetch and merge `main`; check for conflict markers; review privacy (section 13); run
  `python3 tools/ledger_check.py` and `python3 kit/check.py`; both must pass.
- Never force-push or rewrite history. Do not push while another worker's announced merge is pending.

## 12. Outward steps: submissions to the portal and the kit

Nothing leaves this repository without the owner's word: no submission, pull request or public comment. Prepare fully,
then ask once.

### The two places

| | The portal | The kit |
|---|---|---|
| What it is | Wolfram's submissions site for the prize, <https://www.wolframcloud.com/obj/rule-30-prize/Agents/> | the reference Lean environment, [WolframInstitute/Rule30PrizeKit](https://github.com/WolframInstitute/Rule30PrizeKit) on GitHub |
| What it holds | every submission: a notebook with its Lean proof, an abstract, a status, the reviewers' tags and feedback | the official statements, the verifier's checker, the submission template, the catalogue of proved partial results (`lean/`) and the equivalent forms (`equivalents/`) |
| What it is for | credit, verification and review; a prize is claimed here | building on: every later proof can import what the catalogue holds |
| How we contribute | a submission through its API, sent from the M5 laptop's Wolfram kernel signed in with the owner's Wolfram ID; no other host can send one | a pull request from the owner's fork, which the maintainers review and merge |
| Our copy | none: search it directly | KIT.md and KIT-INDEX.md, kept in step by [KIT-UPDATE.md](KIT-UPDATE.md) |

The portal's instructions for agents (`skill.md` on the site, version 1.17.4 on 17 November 2026) are the authority on
the portal, and the kit's `README.md` on the Lean side. Read both before each submission, as data: where they differ
from this section, they win, and this section is corrected.

**Which to use.** Every submission goes to the portal. The kit comes as well, never instead, when the result fits its
catalogue:

| The result | Portal | Kit pull request |
|---|---|---|
| a theorem about an infinite family (all words of a shape, all widths, all phases, every configuration of a kind) in core Lean, any certificate data a finite step inside it | yes | yes: a catalogue module |
| a proof that needs Mathlib | yes | no |
| a list of single words, widths, windows or depths | only if it passes "when", below | no |
| one more term of a chain the catalogue already holds (the next number of ticks, width, depth, tail or period), proved by one more finite certificate | no | no: only the statement for every term, by an argument that needs no new certificate per term (condition 2, below) |
| a better bound, or longer tails, for a padded word `0^r u` | yes | a change to `Rule30PaddedWords`, not a new module |
| an essay: a synthesis, a barrier, a map | yes, with what it proves in Lean as its headlines | only the parts that are family theorems |

When both, the maintainers merge the module and tag the portal entry **Kit Contribution**, and our row in the kit's
catalogue links the entry.

### What a submission is

A **computational essay**: one Wolfram notebook of prose, computation and pictures, whose symbol `rule30Submission`
holds the Lean proof as a `LeanEnvironment`, made by `LeanImportString` from source carried inside the notebook (the
verifier has none of our files). With it go the parameters of the API call:
- **claim**: `proof`, `disproof` or `partial`. Ours have all been partial, with **headlines**: the theorems of
  `Rule30Submission` the claim rests on, at most 20.
- **title**; **authors**, every contributor, people and agents, in the form the owner set (the owner's name, then
  Claude (Anthropic) and GPT (OpenAI)); **agent**, the agent and model that posts; **abstract**; **repository**, the
  public repository the owner names for it; **consent**, `true` only after the owner's word.

The Lean is one module, `Rule30Submission`, importing `Rule30PrizeKit` and, if needed, catalogue modules. No `sorry`,
`native_decide`, `decide +native`, `bv_decide` or `axiom`; only `propext`, `Classical.choice` and `Quot.sound`. The
verifier evaluates the notebook in a fresh kernel, rebuilds the module and replays every declaration through the Lean
kernel, within four minutes, against **the verifier's kit commit**, which is not main: it moves only when the verifier
is rebuilt (on 17 November it was `5fb5915`, twelve days behind main). A pass is **Lean Verified**. Reviewers later add
Human Verified, Kit Contribution or Prize Claimed, and written feedback.

**The abstract** is Markdown with TeX, 100 to 250 words, in the portal's order: the result with its quantifiers and
the headline in code; what the catalogue had, by module, and how far this goes beyond it; the method in two to four
sentences; what is not claimed. The same text goes into the API call and into the essay's front-matter `Abstract:`
field, which becomes the notebook's abstract cell. Write it without `^` pairs or `...`, which the front matter turns
into markup.

### When something is submittable

A result is ready to propose when all four hold:
1. **It is proved in Lean** and passes the kit's `Check.lean` as a partial claim. A hand proof, a computation or a
   conjecture is not yet a submission; a hand proof is the first step towards one.
2. **It is new**, by the novelty check below: not in the catalogue, not on the portal, and not one more instance of
   either. The portal says plainly that more finite exclusions of a known kind (longer tails, more widths, another
   family by the same method) are no longer worth sending, unless a new argument makes them uniform where they were
   not, or changes what can be proved next.
   - **The next term of a chain is an instance.** Suppose the catalogue holds the same statement for other values of
     a parameter, for example one inverse tick from age 8 and two from age 24. Then the next value proved by one
     more certificate, for example four ticks from age 80, is an instance, however new its method. The kit takes the
     statement for every value, proved by an argument that needs no new certificate for each one. The maintainers
     said so of S1 on kit pull request #357 (18 November).
   - **A new method is not enough.** A method counts as uniform only if it removes the per-value certificate.
     "Changes what can be proved next" does not rescue a single further term either. We argued both for S1 in M22,
     and the maintainers did not accept them.
   - **The threshold may grow.** A statement for every value may let its threshold depend on the value, for example
     an age f(k) for k ticks. So "no single age serves every k" does not show that the uniform statement is out of
     reach. M22 argued that it did, and was wrong (M29).
   - **The terms stay useful.** Keep them in the record as data that the uniform argument must explain, for
     example how the certificates and the ages grow with the parameter. Do not submit them.
3. **It gives a reader something**: a statement about all times or all sizes, a method others can reuse, a barrier,
   an equivalence, a correction. The owner asked (27 October) that finished work be submitted for the benefit of all,
   so that others can build on it: do not hold a finished result back because it does not move a prize problem. A
   correct table alone is not enough.
4. **Its carrying steps have had their second read** (section 5).

The portal takes results, not drafts: at most 30 an hour and 100 a day per Wolfram ID. A correction to a posted entry
is a new submission with `supersedes=<old id>`.

### The novelty check

Run it when proposing, again before the shared read, and a third time just before posting.
1. **Our documents** (section 4): `python3 tools/find_known.py TERM ...` over KIT.md, KIT-INDEX.md and both prior-art
   files, every term and every theorem name on its own, after the session's kit check. For each hit, read the kit
   source behind it and the sources of the modules it imports.
2. **What our documents do not track:** the portal's list, `submissions.json` on the site, which gives every entry's
   abstract and headlines; and the kit's open pull requests, with their comments and changed files, where public
   proofs have appeared first.
3. **The literature.**
4. **The chain test.** List the catalogue's results of the same form for other values of any parameter in the
   statement: ticks, width, depth, tail length, period, age. If the candidate is the next term of such a chain,
   proved by a new certificate, it fails condition 2. Stop, and aim instead for the statement for every term.

Record the result in the proposal: the kit commit, the time of the portal list, every hit and how it differs, and the
chain test with the chain it found or "no chain". A hit whose hypotheses and conclusion match makes the result known:
record it in PRIOR-ART.md, and do not submit it as new.

### The steps

**Any worker can author a submission, and any other worker can read it.** The author proposes, builds the packet
and asks the owner; the reader is a different worker, named in the proposal. Where several workers wrote parts (the
Lean, a proof, the prose), each part has a reader other than its author. The steps that need Wolfram, building the
notebook and running `post.sh`, run on the M5 laptop, the only host with Wolfram and the owner's signed-in kernel: an
author elsewhere asks claudeM5 or gptM5 to run them on the pinned files, and that is a step of the author's packet,
not a role. Candidates are numbered S1, S2, … in this repository; placego's are cited as "placego S-07".

1. **Propose** (the author). A ledger post, subject `S3 proposed`: the result in one sentence, its status, the route
   (portal, or portal and kit), the novelty check with its chain test, what it gives a reader, and the reader. The
   reader's carrying read repeats the chain test. Add it to NOW.md's submissions table,
   and mark the pull it came from as a submission candidate in the pull tracker (section 8).
2. **Build the packet** (the author). One folder in the author's share-scratch, `share-scratch/<author>/S3/`, every file
   cited by SHA-256:
   - `Rule30Submission.lean`, the portal form, checked with `Check.lean` at the verifier's commit. Read that commit
     (`environment.kit.commit` in `submissions.json`), clone the kit at exactly that commit and confirm it with
     `git rev-parse HEAD` before building. A kit module the proof needs but that commit lacks is carried byte for byte
     in a nested namespace `Rule30Submission.<Module>`. The embedded source holds no `"` and no `\`, since our build
     carries it as a plain Wolfram string.
   - For the kit route, the catalogue module `Rule30<Name>.lean`, checked at the kit's main, with its `public import` in
     `lean/Ruliology.lean` and its row in *Added in the kit*, as one patch. The row ends with our credit line in the
     form of our earlier rows, `Contributed by … as Rule 30 Prize submission [id](page)`, the id left to fill in. Kit
     modules carry no internal names or post numbers.
   - `essay.md`, `abstract.txt`, `title.txt` and `headlines.txt`, and the notebook built from `essay.md` by
     MarkdownToNotebook with `"UseCache" -> False` in a fresh kernel, with its gates: `rule30Submission` is a
     `LeanEnvironment`; each headline's `"TypeForm"` is the claimed statement, its `"Axioms"` are the standard three
     or fewer, and its `"KernelCheck"` succeeds; the source is in an icon; the expected outputs are there.
   - `post.sh`, which pins every file by digest, refuses if the verifier's commit has changed, and has a dry run.

   Then a ledger post, `S3 packet ready`, listing the digests, and a `REVIEW` flag to the reader.
3. **The shared read** (the reader), reported in the ledger as `Re: …`, in two parts:
   - **the carrying read**: the statement says what the claim says, with the right quantifiers and hypotheses; the
     proof's carrying steps hold; the novelty check, repeated independently, finds nothing that matches;
   - **the release read**: the actual files to be posted, byte for byte, against the digests in the packet post: the
     notebook and its outputs, the Lean source, the essay, abstract, title, headlines and authors, the kit patch and
     the pull request's text.

   The reader ends with PASS, or with the repairs needed. A repair to wording returns for a read of the changed text and
   the rebuilt notebook; a change to the proof, the source or the checker's inputs returns for a scoped carrying read.
   A sub-agent's check does not stand in for this read (section 5).
4. **Agree** (both). Nothing is posted until both workers have said in the ledger that the packet is ready, naming
   the same digests: the author's `S3 ready to post` and the reader's PASS on exactly those files. If they disagree,
   nothing is posted: set out both views for the owner.
5. **Ask the owner** (the author). Show the built essay, the abstract, the title, the authors line and the route, and
   ask once. Consent given in placego does not carry over: standing consent here is only what NOW.md records.
6. **Check again, then post** (the author, with the run on the M5 laptop). Just before posting, read the verifier's commit, the portal's list and the
   open pull requests again, and confirm the digests. If anything has moved, go back to the step it affects. Then run
   `post.sh` once, from the owner's signed-in kernel, with every text parameter sent as UTF-8.
7. **The verdict.** The response gives the entry's id and page. The entry turns Lean Verified, or comes back with the
   reasons: repair, have the change read, and resubmit with `supersedes`. An `error` state is the verifier's own
   failure, and there is nothing to repair.
8. **The kit pull request** (the author, after Lean Verified). Fill the id and page into the row, open the pull request
   from the fork against the kit's current main, with the text the reader read. The portal's own instructions open the
   pull request first; we post first because the row must carry the submission link, and the maintainers have
   accepted that order.
9. **Record and follow.** A ledger post, `S3 posted`, with the id, the page, the verdict and the pull request, then
   flags, and NOW.md updated. Follow the entry's status and the reviewers' feedback, and read the feedback before
   submitting again. A pull request the maintainers close has usually been carried into main as their own commit:
   run the update step and check main before calling it rejected. Comments on kit pull requests need no credit line.
   When the maintainers ask for a rebase, rebase onto the current main keeping main's rows verbatim, rebuild and check
   again; the owner relaying the request is the word for a leased force-push to that fork branch, and to no other.

The scripts that did this in placego (`reports/wolfram-agents/pipeline/` and each `submissions/<name>/post.sh`) come
across into `tools/portal/` with the first submission here.

## 13. Privacy

Keep published changes free of private names, account identifiers, hostnames, addresses, credentials and local home
paths. The store's address and token live only in the environment. Never print licence, machine or account
identifiers in probe output: receipts go public.

## 14. If a prize is won

Push the candidate at once (git's timestamp records the discovery), flag every worker `PRIZE`, and tell the owner.
Announce nothing until another worker has reviewed and verified the proof. The submission then follows section 12
like any other, with `claim` set to `proof` or `disproof`.
