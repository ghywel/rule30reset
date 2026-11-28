# Settling waits on the western side of Rule 30

**I295.4, R144–R145, 28 November 2026.** Number the wheels from zero at the seed’s western edge. The kit’s forced tick $F(j)$ is a sufficient time to settle wheel $j$ on a specified strip. Write $T(j)$ for the first tick at which the singleton’s entire prefix through wheel $j$ agrees with itself sixteen ticks later. A prefix evolves autonomously, so that agreement persists. On the kit’s period-16 band the eventual phase is $A_0$. [K106’s window question](claudeCloud-snapshot-repeats.md) · [Kit settling recursion](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30FourFrontsBase.lean) · [Kit seed alignment](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30SeedLeftSide.lean)

## How much can one wait cost?

On the singleton’s strip $A_0$, every forced increment up to wheel 87,866 is **at most 15**. The transition from wheel 25,545 to 25,546 attains 15, from tick 51,580 to 51,595. On strip $B_0$, a transition actually costs **16**. All four forced clocks satisfy the stronger cumulative bound **$10F(j)\le21j$** throughout the same band. The kernel certificate checks each transition of the existing recursion, sharing the work below each fork. [Lean proof](ForcedWaitScan.lean) · [Independent replay](strip_waits.py)

| Kit strip | Largest increment | First wheel before that jump | $F(53{,}207)$ | $F(87{,}866)$ |
|---|---:|---:|---:|---:|
| $A_0$ | 15 | 25,545 | 107,310 | 176,968 |
| $A_1$ | 15 | 25,545 | 107,310 | 177,229 |
| $B_0$ | 16 | 85,305 | 107,310 | 177,170 |
| $B_1$ | 15 | 25,545 | 107,310 | 177,560 |

The individual and cumulative bounds and the $A_0,B_0$ witnesses are theorems. The first-occurrence column comes from the independent replay. The endpoint values also occur in the kit. At wheel 53,207 the forced tick already exceeds $7j/5$ by more than 32,000 ticks. The near-1.4 estimate concerns the actual seed. [Kit fronts](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30FourFronts.lean)

## Three waits on any compatible strip

Three consecutive increments $a,b,c$ cost at most **$2P+1$** ticks whenever the wheels share a period $P$ and each increment is at most $P$. An increment skips a white wheel or ends one tick after the first black. For $P=16$, this gives **33 ticks per triple** on every rule-compatible strip, of any width. Group the increments by threes. The initial values satisfy $F(0)=0$, $F(1)=1$, $F(2)\le17$, and $F(3)\le33$. Induction gives **$F(j)\le11j$**. [Lean proof](SettlingWaits.lean)

To see the triple bound, suppose the waits start at tick $t$ and total at least $2P+2$. Each wait must be positive. Set $i=t+a+b+c-2-2P$. The first wheel is still white at $i$, the second at $i+P$, and the third at $i+2P$. Periodicity puts three white parents at time $i$. But the last wait ends with a black reading at $i+1+2P$, forcing the third wheel black at $i+1$. Rule 30 sends three white parents to white.

The triple constant is sharp given the local recurrence alone. For $P\ge2$, let the second and third wheels be black only at residue zero, and the first at residues zero and $P-1$. They satisfy the third wheel’s full update at every phase. Starting at residue zero gives waits $1,P,P$. Extending such a triple into a whole rooted strip requires additional conditions.

## When does the singleton itself settle?

For **every $0\le j\le87{,}866$** the physical seed agrees with $A_0$ on every wheel through $j$, at every tick from **$\lfloor 7j/5\rfloor+6$** onward. The allowance of six is sharp. Wheel 85 differs at ticks 124 and 140, and the prefix has settled by tick 125. At the far endpoint $T(87{,}866)=117{,}324$. Wheel 87,865 still differs sixteen ticks apart at tick 117,323. From 117,324 onward the next wheel, 87,867, flips every sixteen ticks. [Lean proof](SeedSettling.lean)

| Last wheel $j$ | 85 | 400 | 4,096 | 53,207 | 58,288 | 87,866 |
|---|---:|---:|---:|---:|---:|---:|
| First tick $T(j)$, direct replay | 125 | 501 | 5,393 | 71,116 | 77,912 | 117,324 |

The independent replay evolves two copies of the physical seed sixteen ticks apart. The first differing bit gives the length of the returned prefix. The Lean certificate evolves one seed through **127 checkpoints**. At each checkpoint it advances the row a further sixteen ticks and compares low bits. It checks that the checkpoint is early enough for the first wheel it newly covers. Prefix autonomy propagates the equality for every later tick. The kit’s eventual alignment identifies the phase. The witnesses at wheels 85 and 87,866 and the full uniform inequality have kernel proofs. [Replay and checkpoint generator](settling_front.py)

## Consequence for I295.4

At age $t\ge w$ the window reads wheels $t-w,\ldots,t$. Every wheel $i$ in that interval satisfying $i\le87{,}866$ and $7i+30\le5t+4$ is provably on $A_0$. At $t=5w/2$ for even $w$, this certifies about $2w/7$ western cells when the band endpoint does not truncate the segment. The remaining finite window question is whether two ages can give identical settled segments at their respective positions in the sixteen phase rows. Beyond wheel 87,866 a depth-uniform settling theorem must track the changing period, and the quadratic range of the vocabulary problem still requires control of the unsettled part.

## Reproduction

From the research repository, with the kit at `10a4b86`, run `python3 research/phase2/vocabulary/strip_waits.py` and `python3 research/phase2/vocabulary/settling_front.py --cuts`. For the period change use `settling_front.py 87868 32 117324`. The Lean modules use the kit’s Lean 4.35.0 toolchain. Build the kit’s `Ruliology.CellularAutomata.Rule30SeedLeftSide` import, compile the three local modules with their output directory and the kit library on `LEAN_PATH`, and run the stock checker in partial mode. The receipt lists the checked propositions and source hashes. [Verification record](data/settling-waits-check.txt)
