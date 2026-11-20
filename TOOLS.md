# TOOLS: the best tool for each job, and who can run it

*Brought across on 20 November 2026 by claudeCloud, at the owner's request (ledger K30), from placego's
`archived/TOOLS.md`. Local started that page on 1 November 2026, also at the owner's request, and it was left behind
when this repository was set up. [METHOD.md](METHOD.md) §2 and §10 point here. Every worker reads §1 at the start of
a session and keeps its own host's column of §3 true. A cell marked **to confirm** has not been checked on that host
since the move to this repository.*

## 1. The rule

The owner, 1 November 2026: "the AI assistants ... have a habit of 'going around the problem' when a requested tool is
unavailable and finding some other solution, but i would always rather we use the best tool for the job."

The owner, 20 November 2026: "it's important as a guard as the AI assistants have a habit of 'working around the
problem' rather than sourcing the best tool".

1. **Use the tool §4 names for the task.**
2. **If it is not on your host, do not go around it.** Either hand the task to a worker who has the tool (§3), or ask
   the owner to install it (§5). Say which in the ledger post.
3. **A substitute needs the owner's agreement.** The post then names it as a substitute and says why.
4. **An output has the status of the check behind it** (METHOD §4). A solver's answer without a certificate is
   COMPUTED. A checked certificate or a Lean kernel check is a machine proof of exactly what it states.
5. **State the caps before a substantial run**: CPU time, wall time, memory, disk (§4, "Memory caps").
6. **Keep this page true.** When a tool is installed, removed or found missing, update §3 in the same commit.
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
| **Intel**: i9, 8 cores, 16 threads, 16 GiB; RX 6600 with 8 GiB of its own | gptIntel | Lean 4.35.0; CPU and GPU compute; long scheduled blocks when the owner turns them on | No Wolfram, by the owner's decision (§6). Runs under Windows since it joined here (ledger I1); placego's inventory was taken under macOS |
| **Cloud container**: 4 CPUs, 15 GiB, Ubuntu 24.04 | claudeCloud | Exact simulation and censuses in C and Python; SAT replication; Docker; pages checked in a headless browser; long reads, reviews and the record | No Lean, no Wolfram, no GPU. Reclaimed when idle: an install lasts only if the environment's setup script carries it (§5), and long runs checkpoint to share-scratch |

No worker and no host is set aside for a specialism (METHOD §1). The hosts differ only in what they can run.

## 3. Inventory: who has which tool

- **Cloud column:** checked on the host by claudeCloud on 20 November 2026 (K30), each solver with a known-answer
  control.
- **M5 column:** carried from placego's page, checked there by Local on 1 November 2026 (L1275–L1277). **To confirm**
  by claudeM5 or gptM5.
- **Intel column:** checked on Windows by gptIntel on 20 November 2026 (K30). The standalone Lean distribution,
  w64devkit and Python review environment live under `%LOCALAPPDATA%/Rule30/toolchains`. The Codex desktop
  runtime supplies additional Python and browser tools.

| Tool | M5 (claudeM5, gptM5) | Intel (gptIntel) | Cloud (claudeCloud) |
|---|---|---|---|
| Python 3 | 3.15.2: numpy 2.5.4, scipy 1.18.1, sympy 1.14.0, networkx 3.7, gmpy2 2.3.2, mpmath 1.3.0, python-sat 1.9.dev17, z3-solver 5.3.3.0, cvc5 1.4.2 | Default `py -3` 3.15.2. `review-py` uses 3.13.17 with networkx 3.7, python-sat 1.9.dev24 and z3-solver 5.4.1.0. Codex Python 3.12.14 supplies numpy 2.3.5. No scipy, sympy, gmpy2, mpmath or cvc5 in these environments | **3.13.18**: numpy 2.5.3, python-sat 1.9.dev23, z3-solver 5.4.1.0, sympy 1.14.0, gmpy2 2.3.2, mpmath 1.3.0, pypdf, pdfminer. **Absent:** scipy, networkx, cvc5 |
| C | Apple clang; GMP | w64devkit GCC 16.2.0 compiled and ran a C control. Lean bundles clang 23.1.0. No GMP development headers found | gcc 13.3.0, clang 18.1.3; **no GMP headers** |
| GPU compute | Metal on the M5 GPU | RX 6600, AMD OpenCL 2.1. An integer kernel matched all 256 CPU Rule 30 updates. Vulkan enumerates the RX 6600 with API 1.4.315 | none |
| SAT solvers | Kissat and CaDiCaL (command line); python-sat in Python | CaDiCaL 2.1.2 CLI in Lean’s bin directory. It and PySAT’s CaDiCaL 1.5.3/1.9.5/3.0, Glucose 4, MiniSat 2.2, Lingeling and MapleChrono passed SAT/UNSAT controls. PySAT Kissat 4.0.4 crashed in the control; no standalone Kissat or Gimsatul found | python-sat only: CaDiCaL 1.9.5 and 1.5.3, Glucose 4, MiniSat 2.2, Lingeling and MapleChrono each pass an UNSAT and a SAT control. **No Kissat or CaDiCaL command line** |
| Proof-certificate checkers | `cake_lpr` (verified LRAT checker), `drat-trim`; the CaDiCaL LRAT to `cake_lpr` pipeline passed its controls | No standalone `cake_lpr`, `drat-trim` or `lrat-check` found. Use the M5 for the specified checked-LRAT pipeline | **none** |
| Lean 4 | `elan` with 4.35.0, the kit's version | Standalone Lean 4.35.0 (x86_64-w64-windows-gnu) and Lake; independent kernel replays in I29 and I34 | **none**: Lean sources may be prepared here and are built on the M5 or the Intel |
| Wolfram | Wolfram Engine, `wolframscript`, LeanLink, the Wolfram MCP | None, by the owner's decision (§6) | none |
| SMT | z3 5.3.3 (command line and Python); cvc5 1.4.2 (Python) | Z3 5.4.1 CLI (`review-py/bin/z3.exe`) and Python (`review-py/Scripts/python.exe`); both give 43691 as the inverse of 3 modulo 2¹⁶. No cvc5 found | z3 5.4.1, command line and Python: gives the inverse of 3 modulo 2^16 as 43691. No cvc5 |
| PARI/GP | 2.19.0, `gp` on the path | No Windows `gp.exe` found | none |
| Sage | not installed | None found. WSL is not installed | none |
| `gh` | signed in | No `gh.exe` found. Git pushes to origin are authenticated separately | 2.89.0, but this session reaches GitHub only through its own tools and one repository's scope |
| Our search and checks | `tools/find_known.py`, `tools/ledger_check.py`, `kit/check.py` | `tools/find_known.py`, `tools/ledger_check.py` and `kit/check.py` run with `py -3` | the same; the portal's list and the kit's pull requests are read from the M5 or the Intel |
| The store client | `tools/store/store.py` | `tools/store/store.py`; authenticated NAS listing checked | the same |
| Capped runner | placego's `run_capped.py`, not yet in this repository (§5) | No Windows port of placego’s `run_capped.py` found | none: the runner reads macOS memory figures |
| Docker | to confirm | No Docker CLI or Desktop found | 29.10.0; builds and tests the store's container |
| Headless browser | to confirm | Microsoft Edge 157.0.4341.60; headless DOM and Playwright 1.62.1 (bundled Node) controls passed | Chromium with Playwright, for checking pages before they are published |
| PDF text | to confirm | Codex Python: pypdf 6.21.4 extracted a known PDF text, pdfminer.six 20251230 imports. No `pdftotext.exe` found | `pdftotext`; pypdf |

## 4. Task to tool

| Task | Best tool | Who runs it | Status of the output |
|---|---|---|---|
| Is it already known? | `tools/find_known.py`, each term on its own; then the kit source behind each hit; the portal's list and the kit's open pull requests; then the literature, read at the page (METHOD §4, §12) | anyone for our documents; the M5 or the Intel for the portal and the kit's pull requests | — |
| Small exact simulation | Python with numpy, or C; Wolfram for exploration and pictures | anyone; Wolfram on the M5 | COMPUTED |
| Large census or bit-parallel search | C with bit-sliced lanes; GPU kernels only after a CPU oracle agrees | any host for C; the M5 and the Intel for GPU | COMPUTED or MEASURED |
| A finite "does such a configuration exist?" question | SAT: Kissat or CaDiCaL. For UNSAT, an LRAT proof checked by `cake_lpr`, with `drat-trim` as a second checker | the M5 or the Intel. The cloud host replicates with python-sat and checks SAT witnesses; it cannot certify UNSAT | SAT: the witness checks itself. UNSAT: a machine proof of that finite case once the certificate checks; otherwise COMPUTED |
| Guessing a law from exact data: a closed form, a recurrence, a generating function | Wolfram `FindSequenceFunction`, `FindLinearRecurrence`, `FindGeneratingFunction`, `FindFormula` | the M5 | CONJECTURE until proved |
| Exact symbolic work: recurrences and sums, real inequalities, exact intervals, polynomials over GF(2), Boolean normal forms | Wolfram (`RSolve`, `Reduce`, `Resolve`, `CylindricalDecomposition`, `Interval`, `GroebnerBasis[..., Modulus -> 2]`, `BooleanConvert`) | the M5 | COMPUTED: no certificate; PROVED only through a hand proof or Lean |
| Exact numbers: fractions, big integers, 2-adic valuations, residues, continued fractions, roots of polynomials | Wolfram to explore; PARI/GP as the fast open cross-check; the replayable probe in Python (`fractions`, sympy, gmpy2) or C with GMP. Never a decimal | the M5 explores; anyone replays | COMPUTED |
| Finite questions about arithmetic with carries, as constraints | SMT over bit-vectors: z3 or cvc5. A claim that needs a certificate is re-encoded as SAT with LRAT | any host with z3; certification on the M5 or the Intel | COMPUTED; certified through SAT and LRAT |
| A formal proof for the kit or the portal | Lean 4.35, core, against a kit checkout at a recorded commit; standard axioms only; a second build on another host (METHOD §5) | the M5 or the Intel | machine proof of the stated theorem |
| A portal notebook build and check | `tools/portal/`: LeanLink in `WolframKernel -script`, under the capped runner | the M5 only | — |
| Hand proofs | written in the pull's document, each step numbered; a second reader carries it (METHOD §5) | anyone | PROOF-SKETCH until the second read |
| Pictures for the owner | Wolfram (`ArrayPlot`, `Graphics`), or a page with its generator beside it (METHOD §7), checked in a headless browser | the M5 for Wolfram; the cloud host for pages | — |
| Reading a paper | the PDF itself, its text extracted and quoted at the page; a summary is not a reading | any host that can fetch it | — |
| The store's container | Docker and `tools/store/docker/test_container.py`; the image workflow on GitHub | the cloud host | — |
| Data that does not belong in git | the shared store's share-scratch, cited by SHA-256 (METHOD §9) | anyone | — |
| The record and coordination | `CHAT-LEDGER.md`, flags, `tools/ledger_check.py` (METHOD §8, §9) | anyone | — |
| Long reads, reviews, rotation, closing summaries | no tool; any worker | anyone | — |

### Memory caps (the owner, 4 November 2026)

- **Intel, Lean builds:** a process-tree memory cap of 8 GiB and a stop when swap has grown by 4 GiB since launch. In
  placego: `run_capped.py --track-tree --rss-mib 8192 --swap-growth-mib 4096`.
- **M5:** memory caps of at least 4 GiB, 8 GiB for Lean and notebook builds, and the same 4 GiB swap stop. The
  free-memory floor stays at 1 GiB: it is a floor, and raising it would stop runs sooner.
- **Kit modules** should build in about a minute and under 4 GB (METHOD §10).
- **Cloud:** 4 CPUs and 15 GiB in all. State the wall time and memory in the post; checkpoint anything over a few
  minutes (METHOD §10).

### CPU threads or the GPU on the Intel (measured in placego, GC2383, under macOS)

| Task shape | Default | Change when |
|---|---|---|
| Tiny exact checks, short serial recurrences, small graph sweeps | one optimised CPU thread | enough independent cases exist to repay the scheduling |
| Many independent packed bitwise trajectories | CPU batches; try 2, then 4 threads | the measured wall time repays the extra CPU |
| Large regular batches with many ticks | a GPU candidate, with a CPU oracle | a bounded pilot on the real workload shows an end-to-end gain. None was established |
| SAT and certificate checking | the CPU solver and checker | a supported parallel portfolio passes its controls |
| A large prefix census | batch and bit-pack first | the layout and the witnesses pass a small case; more threads do not fix an oversized array |

At 4,096 trajectories the GPU's 0.021 ms command became 0.694 ms end to end, and CPU threads won. Transfer, queueing
and setup belong in the comparison. Never let floating-point output stand for an exact threshold or a certificate.
The full study is placego's `archived/reports/GPT-METAL-SCOPE-20261102.md`.

## 5. Gaps: proposed, waiting for the owner or for the host's worker

1. **The M5 column awaits its worker’s confirmation.** Asked in K30. The Intel inventory has been checked on Windows.
2. **The capped runner and the install check did not come across.** `run_capped.py` and `toolchain_smoke.py` are in
   placego, under `archived/tests/probes/`. The runner reads macOS memory figures, so it serves the M5 as it is; the
   Intel under Windows and the cloud host would each need a port. Proposed: bring both into `tools/`, on the
   owner's word, by claudeM5.
3. **Cloud: installs did not last; now they should.** The environment had no setup script, so python-sat and z3,
   installed in this session at the owner's word, would have gone with the container. On 20 November the owner
   approved a setup script (K30, K31): it installs python-sat, z3-solver, sympy, gmpy2 and mpmath and clones the kit
   at each fresh start. Each line was run here first. It is unproven until a fresh container starts on it; the
   first session after that checks the cloud column of §3 and says so in the ledger.
4. **Cloud: no certified UNSAT, no Lean, no Wolfram.** Not proposed for install: these go to the M5 or the Intel.
5. **`mathcheck/check.py` and `doc_links.py`** (placego) are not here. Hand proofs here are in Markdown.

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
- **Operations.** The MCP kernel is for small evaluations only. Heavy builds run as `WolframKernel -script` under the
  capped runner. After a fault, ask the owner to restart Wolfram before debugging. Never print licence, machine or
  account identifiers (METHOD §13).
