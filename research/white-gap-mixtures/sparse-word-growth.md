# How many sparse gap orders can a periodic Rule 30 column use?

Fix any site on a full-line initial row with a leftmost black cell. Suppose its eventual period consists of isolated blacks separated by at least nine whites. The singleton centre is a special case. By I78 the gaps lie in 9 through 16, and a ten must immediately precede a nine somewhere around the cycle. [I78 theorem](ordered-gaps.md).

**Across all such putative periods, at most 474 × 3ⁿ different ordered strings of n successive gaps can occur.** There are 8ⁿ unrestricted strings. This is an upper bound on the candidate language for every period and onset. Whether any candidate actually occurs remains open.

### Where an irregular response must appear

For an arbitrary drive with gaps between 9 and 16, set phase zero at each black pulse and count its white ticks from one. From tick **33**, the first right neighbor is black at the pulse, white on the first white tick, and black on every white tick from the third onwards. This applies from any legal initial phase and to arbitrary positive initial halves. The second white is the only unrestricted phase. The bound is sharp. With a pure nine-gap drive starting in phase four, the finite positive initial row `0x1ffc41dbc` gives a white neighbor on tick 32, in phase six. The kit's realization theorem supplies the rest of the full-line row.

The upper and lower results both pass Lean. The upper certificate propagates width-fifteen row sets for 33 ticks using the kit's verified fast image. An independent ordinary-cone CNF for a wrong nonexceptional bit at tick 33 has 1,173 variables and 8,588 clauses. Both lrat-check and cake_lpr accepted the UNSAT proof. A local version of finite-left masked Jen now locates a period mismatch at the *second white tick* inside each sufficiently late Jen window. At the singleton centre those windows are [n,2n). [Finite-left masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean).

### Counting inputs independently of their period

At consecutive pulses, encode the first K right cells with the closest cell in the low bit. A gap q advances by one black tick followed by q whites, with either exterior bit allowed at each step. If the three closest initial bits are a,b,c, the right-neighbor bit at the second white is ¬a ∨ ¬(b ∨ c).

An eventually constant second-white bit on a periodic drive would make the entire right-neighbor word periodic, contradicting finite-left masked Jen. Any nonsettling walk on a finite graph eventually remains in one strongly connected component containing both output colors. Starting at width eight, keep the components with both colors. At the next width admit both choices of the additional initial cell and repeat. This is sound because projection preserves the drive and the observed bit. For a nonperiodic drive with a nonsettling second-white response, every sufficiently late finite gap string must also label a path in the resulting graph. For a periodic drive, every factor occurs arbitrarily late, so the restriction applies to all rotations.

At width 27 the surviving component contains 163,889 pulse rows. Starting from this whole component and tracking sets of states gives a deterministic input reader with 293,330 reachable subsets, or 155,373 states after minimization. An integer weight h is zero at the rejecting state, at least one at every other state, and 474 initially. On each state the sum of the eight successor weights is at most three times its weight. Induction gives the stated count for all n.

The numerical threshold has a control. The width-26 language grows between 3.008 and 3.010 per gap and the width-27 language between 2.951 and 2.953. These are bounds verified with integer inequalities. The narrower graphs contain the width-26 language, so 27 is the first width of this specific construction with growth below three. These rates describe the finite-strip languages. They give upper bounds on physical candidate orders.

If the eight gaps are chosen independently and uniformly, the chance that an n-gap window is in the candidate language is at most min(1, 474 × (3/8)ⁿ). Almost surely every compatible physical history eventually has a constant second-white response. Indeed a nonsettling history would require the entire drive tail after some integer onset to be readable. Each fixed onset has probability zero, and there are countably many onsets. This conclusion permits all right halves for the same sampled drive.

### Other exclusions and prior work

The I78 minimum of four pulses and span 41 is now a literal Lean theorem for all leftmost-black starts. Two independent component calculations extend the minimum to **six pulses and span at least 61**. They verify all 7,764 primitive necklaces with one through five gap symbols. Each individual history eventually has periodic output, including the possible doubled response for pure nine. The generic component argument passed Lean. The necklace tables were checked externally.

There is also an irregular family with a sharp physical deadline. When gaps alternate between nine and an independently chosen length from ten through sixteen, every right neighbor follows the standard pattern, including white on the second white tick, from tick **102** for every starting phase. A full-line history fails at tick 101. This family admits arbitrarily many ten-nine joins and need never repeat. Independent window and ordinary-cone checks are in the packet below.

AIOvernight's GrammarRuns and ResetMixtures provide the earlier uniform exclusions. WhiteEndNine supplies the earlier mode analysis for constant gap length. The maintainer accepted the uniform grammar and asked on PR 378 for a family or criterion beyond individual starts. The growth bound and the 33-tick theorem both use a single construction across arbitrary gap counts. [GrammarRuns review](https://github.com/WolframInstitute/Rule30PrizeKit/pull/36) · [ResetMixtures](https://github.com/WolframInstitute/Rule30PrizeKit/pull/43) · [Maintainer's request](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378).

### Replay

Compile the C++20 generator and run it with argument 27 in an empty directory. Its recursive component search needs a large stack. On Linux set the shell stack limit to 128 MiB. On Windows with MinGW add `-Wl,--stack,134217728` when linking. Run the Python checker with arguments `26 27` in the output directory. It uses NumPy and verifies the rational growth bounds and the integer weight 474. The graph construction and concrete word counts are computational certificates. The physical 33-tick upper bound, sharp ordinary witness, Jen-window localization, abstract finite-graph reduction and word-count induction have native Lean proofs. [Generator](sparse-language.cpp) · [Integer checker](check-sparse-growth.py).

Private store paths below are relative to `share-scratch/gptIntel/`. The main archive includes the generated automata and the six native/stock headline receipts, with 17 passing headlines, 129 replayed declarations and no new axioms.

| Packet | Contents | Verified SHA-256 |
|---|---|---|
| `I79/sparse-language.zip` | Sharp 33, Jen window, graph construction, growth bounds, CNF/LRAT and source replay | `1fffee83fe58e7c90da54dfdf9ada45c90e2e56c5da43e22afe0cce408dada76` |
| `I79/clock-family.zip` | One through five pulses, both component algorithms, physical reduction | `39795e6a6523aafdae41d24b2cd3aeca9a1c2b3ec2a984037bd1248370dc4f19` |
| `I79/irregular-sync.zip` | Alternating nine and variable long gaps, exact 102-tick bound and boundary histories | `732613fbce252de676e4606600a0163198207e175c7aeadc0b8b47ab69b7bab7` |
| `I78/short-gap-41-kernel-e7d1bfa4a0e2.zip` | Literal four-pulse and 41-tick minimum, kernel-checked | `e7d1bfa4a0e2f245a749dfb1d6ff67926f4f386f418377c9a215cfc766c3fff6` |
| `I78/finite-mixed-gap-center-deadline.zip` | I78's guarded sparse language, finite singleton mismatch by tick 4(s+40)+10P+16 | `fa99d30d4cc0849e6323793ca627d6b1e6feb66fb20d2c7312d1c34dc968ef57` |

The next test is to remove components where fixing the input also fixes the response, even though both colors occur for different inputs. The present count retains such components. An observation about possible continuations could lower the candidate growth rate without enlarging the strip.
