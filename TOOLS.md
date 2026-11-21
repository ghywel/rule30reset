# TOOLS: the best tool for each job, and who can run it

*Brought across on 20 November 2026 by claudeCloud, at the owner's request (ledger K30), from placego's
`archived/TOOLS.md`. Local started that page on 1 November 2026, also at the owner's request, and it was left behind
when this repository was set up. [METHOD.md](METHOD.md) §2 and §10 point here. Every worker reads §1 at the start of
a session and keeps its own host's column of §3 true. A cell marked **to confirm** has not been checked on that host
since the move to this repository.*

*The owner, 20 November 2026 (K32), on whether placego's helper scripts should come too: "they can be left out as the
document itself is it's own kind of trap." The page is the guard: the rule in §1 catches the habit, and it needs no
machinery behind it. The tables are reference; a row that is not true is worse than no row.*

## 1. The rule

The owner, 1 November 2026: "the AI assistants ... have a habit of 'going around the problem' when a requested tool is
unavailable and finding some other solution, but i would always rather we use the best tool for the job."

The owner, 20 November 2026: "it's important as a guard as the AI assistants have a habit of 'working around the
problem' rather than sourcing the best tool".

The owner, 21 November 2026: "cloud SAT solving is fine, wolfram is the only software limited to the M5, everything
else is fine if your sandbox can run it".

1. **Use the tool §4 names for the task.** Which host runs it is free, except Wolfram: that is the M5's.
2. **If it is not on your host, do not go around it.** Either hand the task to a worker who has the tool (§3), or ask
   the owner to install it (§5). Say which in the ledger post.
3. **A substitute needs the owner's agreement.** The post then names it as a substitute and says why.
4. **An output has the status of the check behind it** (METHOD §4). A solver's answer without a certificate is
   COMPUTED. A checked certificate or a Lean kernel check is a machine proof of exactly what it states.
5. **State the limits before a substantial run**: wall time, memory, disk (§4, "Limits").
6. **Keep this page true.** When a tool is installed, removed or found missing, update §3 in the same commit, and
   confirm a new install with a known-answer test.
7. **A task that §4 does not list** gets a row before the work is reported, so the next worker finds it.

**Signs that you are going around the problem.** Added here, from our own slips.
- An exact value read off a decimal. K29 read 31/60 off 0.516666667; the exact check came a post later (K30).
- An UNSAT answer with no checked certificate, reported as more than COMPUTED.
- Lean source read by eye where a build was needed.
- A fresh script for something a named tool already does: the search, the ledger check, the store client.
- A page fetched through a summary when the PDF itself can be read (P14).
- "My host cannot, so I did it another way", with no line in the post that says so and no hand-over.

## 2. The hosts

| Host | Workers | Suited to | Limits |
|---|---|---|---|
| **M5 laptop**: 10 cores, 16 GiB unified memory shared by CPU and GPU | claudeM5, gptM5 | The Wolfram side (§6); current-kit Lean and portal builds; SAT with checked certificates; Metal on the M5 GPU | Runs only while the owner has a session open; memory is shared with the owner's other applications |
| **Intel**: i9, 8 cores, 16 threads, 16 GiB; RX 6600 with 8 GiB of its own | gptIntel | Lean 4.35.0, SAT with checked certificates, and CPU and GPU compute. Long scheduled blocks when the owner turns them on | No Wolfram, by the owner's decision (§6). Runs under Windows since it joined here (ledger I1); placego's inventory was taken under macOS |
| **Cloud container**: 4 CPUs, 15 GiB, Ubuntu 24.04 | claudeCloud | Exact simulation and censuses in C and Python; SAT replication; Docker; pages checked in a headless browser; long reads, reviews and the record | No Lean, no Wolfram, no GPU. Reclaimed when idle: an install lasts only if the environment's setup script carries it (§5), and long runs checkpoint to share-scratch |

No worker and no host is set aside for a specialism (METHOD §1). The hosts differ only in what they can run.

## 3. Inventory: who has which tool

- **Cloud column:** checked on the host by claudeCloud on 20 November 2026 (K30), each solver with a known-answer
  control.
- **M5 column:** checked on the host by claudeM5 on 20 November 2026 (M69), each tool that computes with a
  known-answer control. gptM5 runs on the same host; its own agent environment was not checked.
- **Intel column:** checked on Windows by gptIntel on 20 November 2026 (I41–I43). The per-user command lines resolve in a fresh terminal. In PowerShell use `gp.exe` for PARI because `gp` is an existing PowerShell alias. The Codex desktop runtime supplies additional Python and browser tools.

| Tool | M5 (claudeM5, gptM5) | Intel (gptIntel) | Cloud (claudeCloud) |
|---|---|---|---|
| Python 3 | 3.15.2: numpy 2.5.4, scipy 1.18.1, sympy 1.14.0, networkx 3.7, gmpy2 2.3.2, mpmath 1.3.0, python-sat 1.9.dev17, z3-solver 5.3.3, cvc5 1.4.2; numpy reproduced 256 Rule 30 updates, gmpy2 inverted 3 modulo 2¹⁶ (43691), mpmath found κ = 0.847810. No pypdf, pdfminer or Playwright | Default `py -3` 3.15.2. `rule30-python` runs the 3.13.17 review environment with numpy 2.5.5, scipy 1.18.1, sympy 1.14.0, networkx 3.7, gmpy2 2.3.2, mpmath 1.3.0, python-sat 1.9.dev24, z3-solver 5.4.1.0 and cvc5 1.4.2. Linear solve, exact factorisation, modular inverse and κ controls pass. `pip check` is clean | **3.13.18**: numpy 2.5.3, python-sat 1.9.dev23, z3-solver 5.4.1.0, sympy 1.14.0, gmpy2 2.3.2, mpmath 1.3.0, pypdf, pdfminer. **Absent:** scipy, networkx, cvc5 |
| C | Apple clang 21.0.0; GMP from Homebrew: a compiled control inverted 3 modulo 2¹⁶ (43691) | w64devkit GCC 16.2.0 and MSYS2 GMP 6.3.0. A C control linked against `libgmp.a` returned 43691 for the inverse of 3 modulo 2¹⁶. Lean bundles clang 23.1.0 | gcc 13.3.0, clang 18.1.3; **no GMP headers** |
| GPU compute | Metal on the M5 GPU: a kernel compiled at run time matched all 256 CPU Rule 30 updates (Swift and `swiftc` from Xcode) | RX 6600, AMD OpenCL 2.1. An integer kernel matched all 256 CPU Rule 30 updates. Vulkan enumerates the RX 6600 with API 1.4.315 | none |
| SAT solvers | Kissat 4.0.4 and CaDiCaL 3.0.1 (command line), each passing an UNSAT and a SAT control; CaDiCaL writes LRAT. python-sat's CaDiCaL 1.5.3 and 1.9.5, Glucose 4, MiniSat 2.2, Lingeling, MapleChrono and Kissat 4.0.4 pass the same controls | CaDiCaL 3.1.0, Kissat 4.0.4 and Gimsatul 1.1.2 command lines, built from upstream release sources with MSYS2. Each produced a SAT model and a checked PHP(5,4) UNSAT proof. Gimsatul ran with two threads. Lean also bundles CaDiCaL 2.1.2. Seven PySAT backends passed both controls (CaDiCaL 1.5.3/1.9.5/3.0, Glucose 4, MiniSat 2.2, Lingeling and MapleChrono). The Windows PySAT Kissat binding crashes on the control. The standalone Windows `kissat` and the Ubuntu PySAT 1.9.dev24 Kissat binding both pass SAT and UNSAT | python-sat only: CaDiCaL 1.9.5 and 1.5.3, Glucose 4, MiniSat 2.2, Lingeling and MapleChrono each pass an UNSAT and a SAT control. **No Kissat or CaDiCaL command line** |
| Proof-certificate checkers | `cake_lpr` (CakeML's verified LRAT/LPR checker, the ARM64 build of upstream `033aad5`, its released checksums verified) and `drat-trim` with `lrat-check` (upstream `2e3b2dc`), built in the owner's scratch tool folder outside git and linked from Homebrew's `bin`. Controls on the pigeonhole formula PHP(5,4): `cake_lpr` verified CaDiCaL's LRAT in binary and in text, `lrat-check` the text form (it does not read binary LRAT), and `drat-trim` Kissat's DRAT; a truncated proof was rejected by each. `cake_lpr` exits 0 even when it rejects: read its `s VERIFIED UNSAT` line | Native `cake_lpr` (CakeML 033aad5, released x64 checker assembly with a Windows runtime wrapper), `drat-trim` and `lrat-check` (2e3b2dc). On PHP(5,4), CakeML accepted CaDiCaL 3.1.0 binary and text LRAT, lrat-check accepted text LRAT, and drat-trim accepted text and binary DRAT plus Kissat and Gimsatul proofs. Each checker rejected an incomplete proof. Require CakeML stdout `s VERIFIED UNSAT` for acceptance | **none** |
| Lean 4 | `elan` 4.2.4 with 4.35.0, the kit's version, and 4.33.1; not on the agent shells' path, and no default toolchain, so it runs inside a project with a `lean-toolchain` (the kit). Kernel-checked builds and `Check.lean` runs at the verifier's commit and at main on 20 November (M63–M68) | Standalone Lean 4.35.0 (x86_64-w64-windows-gnu) and Lake; independent kernel replays in I29 and I34 | **none**: Lean sources may be prepared here and are built on the M5 or the Intel |
| Wolfram | Wolfram Engine 15.0 with `wolframscript` (the kernel is inside the app, not on the path); LeanLink 1.2.2; the portal builds of S4 and S5 ran here (M63–M68). The Wolfram MCP is AgentTools 2.2.0's `WolframLanguage` server: a stdio handshake listed its seven tools and evaluated `PowerMod[3, -1, 2^16]` as 43691 (M70). The owner restored its link in the Claude app on 20 November, and it reached open sessions too: claudeM5's evaluated through it (M71) | None, by the owner's decision (§6) | none |
| SMT | z3 5.3.3 (command line and Python) and cvc5 1.4.2 (Python only, no command line): both give 43691 as the inverse of 3 modulo 2¹⁶ | Z3 5.4.1 and cvc5 1.4.2, both command line and Python. Each recovered 43691 as the 16-bit inverse of 3 | z3 5.4.1, command line and Python: gives the inverse of 3 modulo 2^16 as 43691. No cvc5 |
| PARI/GP | 2.19.0, `gp` on the path: gives 43691 and the root κ = 0.847810 of 4κ³ − 2κ² − 1 | 2.19.1 (`gp.exe` in PowerShell). Returned 43691 for the modular inverse and −2 for the Frobenius trace of curve 11a1 at 2 using the bundled database | none |
| Sage | not installed | 10.10 installed from 386 checksum-verified conda-forge packages in Ubuntu 26.04.1 LTS on WSL 2. Sage returned 43691 for the inverse of 3 modulo 2¹⁶ and verified `(x+1)^32 = x^32+1` over GF(2). Run `sage` in an Ubuntu login shell (§5) | none |
| `gh` | signed in; it opened kit PR #375 (M68) | GitHub CLI 2.105.0. Verified upstream Windows release checksum and exercised a local CLI alias. `gh auth status` reports no CLI login. Git pushes to origin have separate working authentication | 2.89.0, but this session reaches GitHub only through its own tools and one repository's scope |
| Our search and checks | `tools/find_known.py`, `tools/ledger_check.py`, `kit/check.py` (IN STEP once the kit clone was advanced to `d01ab27`) | `tools/find_known.py`, `tools/ledger_check.py` and `kit/check.py` run with `py -3` | the same; the portal's list and the kit's pull requests are read from the M5 or the Intel |
| The store client | `tools/store/store.py`: inbox, flag, share and fetch used on 20 November | `tools/store/store.py`; authenticated NAS listing checked | the same |
| Docker | not installed | Ubuntu on WSL 2 runs Docker Engine 29.10.0, Buildx 0.39.1 and Compose 5.8.0. The official hello-world image ran, a local image built, and Compose ran it. From PowerShell use `wsl -d Ubuntu -- sudo docker info`. The Windows CLI 29.10.0 and Compose 5.7.0 are installed separately. Docker Desktop is uninstalled | 29.10.0; builds and tests the store's container |
| Headless browser | Google Chrome 156 in headless mode: ran a page's script and printed its DOM, and printed a page to PDF. No Playwright. The desktop app's own browser pane is a session tool, not a host tool | Microsoft Edge 157.0.4341.60; headless DOM and Playwright 1.62.1 (bundled Node) controls passed | Chromium with Playwright, for checking pages before they are published |
| PDF text | `pdftotext` 26.10.0 (Poppler) extracted the known text of a PDF printed by Chrome. No pypdf | Poppler 25.07.0 `pdftotext` extracted the exact one-page control text. Codex Python also provides pypdf 6.21.4 and pdfminer.six 20251230 | `pdftotext`; pypdf |

**Intel tool locations.** Under `%LOCALAPPDATA%/Rule30/toolchains`, `sat-solvers/bin` supplies the three upstream solver launchers and `sat-solvers/controls` holds their formulas and generated proofs. The launchers select their private MSYS2 runtime. The native checkers and their build notes are in `sat-checkers/bin` and `sat-checkers/BUILD-AND-CONTROLS.txt`. For C with GMP, pass w64devkit GCC the include directory `gmp-6.3.0-mingw64/mingw64/include` and link `gmp-6.3.0-mingw64/mingw64/lib/libgmp.a` by path. WinGet manages the Docker clients and Poppler.

## 4. Task to tool

| Task | Best tool | Who runs it | Status of the output |
|---|---|---|---|
| Is it already known? | `tools/find_known.py`, each term on its own; then the kit source behind each hit; the portal's list and the kit's open pull requests; then the literature, read at the page (METHOD §4, §12) | anyone for our documents; the M5 or the Intel for the portal and the kit's pull requests | — |
| Small exact simulation | Python with numpy, or C; Wolfram for exploration and pictures | anyone; Wolfram on the M5 | COMPUTED |
| Large census or bit-parallel search | C with bit-sliced lanes; GPU kernels only after a CPU oracle agrees | any host for C; the M5 and the Intel for GPU | COMPUTED or MEASURED |
| A finite "does such a configuration exist?" question | SAT: Kissat or CaDiCaL. For UNSAT, an LRAT proof checked by `cake_lpr`, with `drat-trim` as a second checker | any host with a solver, the cloud host included (python-sat's CaDiCaL; the owner, 21 November 2026); proof checking on a host with a checker, today the M5 and the Intel | SAT: the witness checks itself. UNSAT: a machine proof of that finite case once the certificate checks; otherwise COMPUTED |
| Guessing a law from exact data: a closed form, a recurrence, a generating function | Wolfram `FindSequenceFunction`, `FindLinearRecurrence`, `FindGeneratingFunction`, `FindFormula` | the M5 | CONJECTURE until proved |
| Exact symbolic work: recurrences and sums, real inequalities, exact intervals, polynomials over GF(2), Boolean normal forms | Wolfram (`RSolve`, `Reduce`, `Resolve`, `CylindricalDecomposition`, `Interval`, `GroebnerBasis[..., Modulus -> 2]`, `BooleanConvert`) | the M5 | COMPUTED: no certificate; PROVED only through a hand proof or Lean |
| Exact numbers: fractions, big integers, 2-adic valuations, residues, continued fractions, roots of polynomials | Wolfram to explore; PARI/GP as the fast open cross-check; the replayable probe in Python (`fractions`, sympy, gmpy2) or C with GMP. Never a decimal | the M5 explores; anyone replays | COMPUTED |
| Finite questions about arithmetic with carries, as constraints | SMT over bit-vectors: z3 or cvc5. A claim that needs a certificate is re-encoded as SAT with LRAT | any host with z3; certification on the M5 or the Intel | COMPUTED; certified through SAT and LRAT |
| A formal proof for the kit or the portal | Lean 4.35, core, against a kit checkout at a recorded commit; standard axioms only; a second build on another host (METHOD §5) | the M5 or the Intel | machine proof of the stated theorem |
| A portal notebook build and check | `tools/portal/`: LeanLink in `WolframKernel -script` | the M5 only | — |
| Hand proofs | written in the pull's document, each step numbered; a second reader carries it (METHOD §5) | anyone | PROOF-SKETCH until the second read |
| Pictures for the owner | Wolfram (`ArrayPlot`, `Graphics`), or a page with its generator beside it (METHOD §7), checked in a headless browser | the M5 for Wolfram; the cloud host for pages | — |
| Reading a paper | the PDF itself, its text extracted and quoted at the page; a summary is not a reading | any host that can fetch it | — |
| The store's container | Docker and `tools/store/docker/test_container.py`; the image workflow on GitHub | the cloud host | — |
| Data that does not belong in git | the shared store's share-scratch, cited by SHA-256 (METHOD §9) | anyone | — |
| The record and coordination | `CHAT-LEDGER.md`, flags, `tools/ledger_check.py` (METHOD §8, §9) | anyone | — |
| Long reads, reviews, rotation, closing summaries | no tool; any worker | anyone | — |

### Limits

- **The M5 is the owner's working laptop,** and its 16 GiB is shared with everything else on it. The owner's caps of
  4 November 2026: a run may use at least 4 GiB, and up to 8 GiB for Lean and notebook builds; stop a run that pushes
  the machine into swap.
- **The Intel, Lean builds:** up to 8 GiB (the owner, 4 November 2026).
- **Kit modules** should build in about a minute and under 4 GB (METHOD §10).
- **Cloud:** 4 CPUs and 15 GiB in all; checkpoint anything over a few minutes (METHOD §10).
- **Use the limits the tool itself has**: a solver's time limit, the shell's `timeout`. State them in the post.

### CPU threads or the GPU

Measured in placego on the Intel under macOS (GC2383), so a lesson and not a measurement of today's hosts: at small
sizes CPU threads beat the GPU, because transfer, queueing and setup belong in the comparison. Try the GPU only after
a CPU oracle agrees and a bounded pilot on the real workload shows an end-to-end gain. Never let floating-point output
stand for an exact threshold or a certificate.

## 5. Gaps: proposed, waiting for the owner or for the host's worker

1. **Closed, 20 November (M70): the M5's certificate checkers are back.** M69 found `cake_lpr` gone and `drat-trim`'s
   link broken, after the folder they lived in was cleared. At the owner's word they were rebuilt from upstream in the
   owner's scratch tool folder, which is the place for such tools, and passed the controls of §3. The Intel also has checked Windows builds (I42).
2. **Left out, by the owner's decision (20 November 2026, K32):** placego's `run_capped.py` and
   `toolchain_smoke.py`.
   - *What the first did:* ran one command under enforced limits on time, memory and disk, stopped it cleanly when
     one was passed, and left a receipt. A safety harness for the M5, written for macOS; it computes nothing.
   - *What the second did:* a known-answer test of every tool on one host's list, printing PASS. It assumes the
     full M5 list and fails on any host that lacks one tool.
   - Nothing in this repository has used either. They stay in placego's archive, under `archived/tests/probes/`.
     If a runaway job ever troubles the M5, bring the first back then.
3. **Cloud: installs did not last; now they should.** The environment had no setup script, so python-sat and z3,
   installed in this session at the owner's word, would have gone with the container. On 20 November the owner
   approved a setup script (K30, K31): it installs python-sat, z3-solver, sympy, gmpy2 and mpmath and clones the kit
   at each fresh start. Each line was run here first. It is unproven until a fresh container starts on it; the
   first session after that checks the cloud column of §3 and says so in the ledger.
4. **Cloud: no certified UNSAT, no Lean, no Wolfram.** Not proposed for install: these go to the M5 or the Intel.
5. **`mathcheck/check.py` and `doc_links.py`** (placego) are not here. Hand proofs here are in Markdown.
6. **Closed, 20 November (I43).** The Intel runs Ubuntu 26.04.1 LTS under WSL 2. From PowerShell:

   ```powershell
   wsl -d Ubuntu -- bash -lc 'sage --version'
   wsl -d Ubuntu -- sudo docker info
   ```

   Sage and its Python environment live under `~/.local/share/rule30/sage-10.10` in Ubuntu. The user launcher at `~/.local/bin/sage` selects that environment. Its Python has the tested PySAT Kissat binding. Inside Sage, pass Python integers (e.g. `int(1)`) as PySAT literals. Docker Engine runs as a systemd service on Ubuntu's local Unix socket. The default Ubuntu user accesses it with `sudo`.

## 6. Wolfram (the owner, 1 November 2026)

- **Wolfram stays off the Intel. The M5 holds the Wolfram side.** The other workers design or suggest Wolfram tasks
  for claudeM5 or gptM5 to run. Put the request in the ledger with the code or its intent, the prediction, and the
  output wanted back.
- **The results matter, not the workings, and they must translate.** In the owner's words: "the precise working of
  wolfram doesn't matter, the results it can produce matter, which must always be translatable into a different
  language anyway." Every Wolfram result that carries a status is restated in plain mathematics. If it is a
  computation, the post gives the Wolfram code and a replay in Python, C or Lean, so that a worker without Wolfram
  can check it (METHOD §10).
- **Use it for:** guessing laws from data, exact symbolic algebra, exploration and pictures, and LeanLink builds.
- **Not for:** certified UNSAT (Wolfram's SAT functions give no certificate, as far as we know), large censuses (C
  and the GPU are much faster), or anything another worker must replay without a translation.
- **Operations.** The MCP kernel is for small evaluations only. Heavy builds run as `WolframKernel -script`. After a
  fault, ask the owner to restart Wolfram before debugging. Never print licence, machine or
  account identifiers (METHOD §13).
