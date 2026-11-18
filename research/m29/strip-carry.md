# Carrying read of the inverse bounds and the reset-word test

**R29 verdict.** M32, M33 and M34 pass for the stated finite upper bounds. This is a computer-assisted carrying read. The thresholds at depths 5–11 have upper bounds 78, 108, 131, 132, 144, 157 and 172 ticks, respectively. The lower bounds 73 and 104 at depths five and six have the M30 witnesses carried in R23.

## What was independently checked

Read a band from its inner end to its outer edge. At each layer the incoming pair is (previous, current). Given input b its successor is (current, b XOR (previous OR current)), and the next layer reads the old current bit. The joint state is all zero at the edge of any finite inverse history, by exact forward edge growth. Conversely the all-zero state remains zero on the white exterior. For age at least k the true k-tick orbit is one of the physical histories and closes. If all physical joint states coincide at some cut at or before the output edge, the common state therefore follows that orbit to closure. Conversely if all close, they coincide at the edge. This equivalence concerns agreement of the full register at one cut.

The [independent replay](gptM5_strip_review.py) starts with the singleton zero terminal register and pulls it back through the bits in reverse order. A four-way tree on incoming pairs represents its preimage. Identical subtrees are shared, and an all-true subtree certifies every entrance register beneath it. This produced the exact reported number of failing words on all 62 recorded cover/age/depth combinations, and the 127 narrow seeds passed the physical-parent test wherever the seed cover passed. A direct forward scan first checked the reverse recurrence on every register through depth three on all nonzero words of up to seven bits.

At each width 20–128 we independently found the first repeating band on the orbit starting from the single edge bit, replayed S1's cover until **every** projected band entered that cycle, and verified that every phase reset the reported depth K and some phase failed at K+1. No width below 20 reset two layers on its entire cycle. The 109 convergence ages and capacities match M34. The finite verification uses all projected bands; the random-start check is unnecessary. Receipt in `share-scratch/gptM5/M29/reverse-review-r28-v1.jsonl`, SHA-256 `dc7a7ef4429f406b9e22c71385226787d7a0ceb2a8416f973fde5ce61cc90c1d`.

## Scope of the two-factor argument

At any width w where every physical band enters the tested cycle by g(w), and that cycle clears every entrance register to depth k, the physical k-layer state clears too. Age monotonicity gives f(k) ≤ g(w). The state becomes all zero, which is stronger than merely showing that a set of arbitrary entrances coalesces. M34's rate estimates describe the tested bands. They give neither a linear upper bound at every width nor a necessary lower bound on the sharp physical threshold.

There is a useful simplification of the qualitative all-depth question (**PROOF-SKETCH**). In edge alignment every nonzero row has at least w bits by age w−1. Its top w bits subsequently follow a deterministic map on just 2^(w−1) possible words. Every seed therefore reaches *some* width-w cycle by age w−1+2^(w−1). If for each k there is **any** width w at which **every** cycle clears k layers, this already gives a finite f(k). Linear convergence is needed only if aiming for a correspondingly good rate. At larger widths different cycles can occur, as the kit's four-left-sides classification demonstrates. No extrapolation from the single-edge-bit orbit suffices on its own. One could instead bound which cycles the seed family reaches.

## How much one-layer reset words explain

An input of the form 0, then 3m+1 ones, then 0 and one more bit synchronises the four incoming states of one layer. This family is known. To see its necessity for finite words, group the pair states as A = 00, C = 10 and E = {01,11}. Input 1 rotates A → E → C → A. Input 0 sends A to A and both C and E to E. After the first zero the possible classes are {A,E}. After the next zero they collapse exactly if the intervening black run has length 1 modulo 3. At that collapse the actual last two possibilities are 01 and 11, so one further bit is necessary and sufficient for full pair agreement. This also explains why the two independently programmed one-layer schedules gave the same capacity at all 109 widths. [Prior art in P6](../../PRIOR-ART.md)

Each schedule retains the common parent suffix after the first pair reset and admits all four entrances again at the next layer. At width 25 this proves two layers of the true three, at 96 it proves six of eight, and at 128 it proves nine of eleven. It gives the exact capacity at five of 109 widths. Changing to a different one-layer synchronising word cannot recover that gap. The remaining information lies in which states and parent bits can occur together across layers. The test measures this specific scheduling rule.

## What survives when two or three layers are kept together

R30–R31, **COMPUTED**. For each block of d layers, enumerate all 4^d entrance registers, and require a zero joint state at the edge for all of them. Record the deepest layer's emitted bit at each cell. The positions after its last disagreement form the longest parent suffix common to every entrance. Keep that suffix for the next block and again admit every entrance register. Dynamic programming chooses the best segmentation into blocks of at most B layers, separately for each phase, then takes the minimum over phases. Each successful schedule suffices for physical closure. At the cut it deliberately discards the relation between a discarded parent prefix and the next register.

| Band width | Single layers | Blocks up to two | Blocks up to three | Full joint capacity |
|---:|---:|---:|---:|---:|
| 25 | 2 | 3 | 3 | 3 |
| 62 | 3 | 4 | 4 | 4 |
| 81 | 4 | 6 | 6 | 6 |
| 91 | 6 | 7 | 7 | 8 |
| 96 | 6 | 7 | 7 | 8 |
| 128 | 9 | 10 | 10 | 11 |

Across widths 20–128, two-layer blocks recover the full strip capacity at 71 of 109 widths, up from five with single layers. Allowing triples gives the same worst-phase count as allowing pairs at every tested width. The first loss for either rule is at width 91. In the phase word `0x6f671619da217f6c637c9ac` (outer edge at the high bit), one optimal schedule takes 3, 3 and 1 layers, retaining 68, 17 and 8 common cells after the respective blocks. Every schedule under the block-size-three cut rule stops at seven or earlier, yet the exact eight-layer reverse scan accepts every incoming register. This supplies a specific phase and cut for testing a representation that retains which entrance states remain compatible with each parent suffix.

Scope: this separates a specified suffix-only calculation from the joint register. Other two- or three-layer summaries could retain more information, and these measurements give no asymptotic separation. [Frozen block test](gptM5_reset_blocks.py). Receipt in `share-scratch/gptM5/M29/reset-blocks-r30-v1.json`, SHA-256 `7c6643c22cbd485ee291671ab54ff98f6313f634128f8858a8a9448e2caffdfa`.

## The missing bit in the width-91 phase

**R32–R33, COMPUTED.** On the exhibited phase, the 3+3 cut leaves the outer 17 cells of the sixth predecessor row. Their value is `0x6f3` with the leading zeros retained. Scanned by the last two layers, this suffix fails on exactly the eight even incoming registers and succeeds on all eight odd ones. The low register bit is the **current cell in layer seven**. Only that bit matters to the verdict at this cut.

Projecting all 65,536 original eight-layer entrances through the first 74 input cells leaves exactly one register for the last two layers, 13. There is also a shorter way to certify why the needed bit is 1. All 4,096 six-layer entrances give the same three parent bits immediately before the 17-cell suffix: **010** in scanning order. Reading 010 maps any one-layer pair to 01 or 11. Either possibility has current bit 1 when the 17-cell suffix starts, so both remaining layers close. The first bit of the suffix completes the known one-layer reset factor. Equivalently the common 20-cell suffix is `0x379a` and clears all 16 registers. In a scan starting with fresh registers, keeping only one or two extra bits still fails.

The first cut in 3+3 is where the spurious alternative enters. If the middle three layers start independently at the 68-cell suffix, then even using *all* 68 of their output positions leaves 21 possible words, four failing when scanned by the last two layers from free entrances. In contrast the original six-layer block forces 010 at the decisive positions. This identifies the specific missing information on one phase. The recurrence of such guards across phases and depths is open. [Probe](gptM5_width91_cut.py) · `share-scratch/gptM5/M29/width91-cut-r32-v1.json`, SHA-256 `f8951ae68d364fabf2d3bc9453b24ddaea196ea3d56d22651711480e986372b4`.
