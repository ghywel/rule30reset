# Path 4 and the seven-lock prefix certificate

Troy Lowry proved that the first 80 positive cells of the singleton at age 364 force every right-half completion into phase 6 at local tick 95 under a black-first alternating centre. He used that entry to prove a sharp seven-site result at the moving left edge. Herbert and collaborators supplied the seven-phase lock and its closure. The maintainer asked for a criterion on families of right prefixes. [Lowry’s #378](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378) · [Maintainer’s request](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041) · [Kit lock, #227](https://github.com/WolframInstitute/Rule30PrizeKit/pull/227)

## The family criterion

Fix any first `m` positive cells, with bit zero nearest the centre. **Every infinite completion eventually enters the seven-lock if and only if a finite tree for that prefix passes the checker.** Each fork tests the next initial cell. Each leaf names an odd tick `1+2j` and a phase. Both may differ between leaves. Every completion reaches one of the labelled phases at its labelled tick. Lock closure then puts them all in the lock by the maximum leaf time. [Family checker](../Rule30Lock7Certificate.lean)

For a proposed deadline `J`, the 30 output cells depend on the first `31+2J` input cells. A full cone is evaluated directly. An incomplete cone propagates known zeros, known ones and unknowns. A leaf passes when every possible output in that approximation belongs to its declared phase. Splitting to a full cone gives completeness at each deadline. The I49 compactness argument supplies a common deadline if every infinite completion eventually enters. A failed tree leaves other certificates and later deadlines open. [Compactness and exhaustive checker](../Rule30Lock7Compactness.lean)

## What the age-364 example needs

Lowry’s entry theorem implies the original I49 Boolean check at `m=80, J=47` directly. Evaluating that exhaustive check would consider `2^45` fillings. The new checker accepts one leaf. At length 79 its ternary window still has four unknowns, giving 16 possibilities for a class containing seven windows. Shorter prefixes can only increase the unknown count. [Direct Lean comparison with #378](../Rule30Lowry378Comparison.lean)

| Prescribed cells | Maximum extra splits along one branch | Leaves at tick 95, phase 6 |
|---:|---:|---:|
| 80 | 0 | 1 |
| 79 | 1 | 2 |
| 78 | 4 | 7 |
| 77 | 5 | 11 |

The 77-cell tree is checked in Lean. Its forks cover both values of each unprescribed cell. The integer search returned no tree of depth through eight for lengths 64–76 with this leaf test at the same tick and phase. The earlier I63–I68 work established the physical minimum of **64 contiguous cells**, or **63 chosen cells** by omitting either site 57 or site 62 from the first 64. I68 includes the kernel proofs for both choices. [Finite search](find_splits.py) · [Lower bounds and witnesses](../Rule30Age364Observations.lean) · [I63, I64 and I68 in the archived ledger](../../../archive/ledgers/CHAT-LEDGER.6.md)

For the genuine singleton, any age `A` presenting those 77 cells must disagree with black-first alternation by absolute tick `2A+190`. At age 364 the actual centre already disagrees at 366. The general theorem allows different certified prefixes at different ages. If such ages with a black centre occur arbitrarily late, an eventual period-two centre is impossible. Establishing those arbitrarily late occurrences remains open. [Singleton consequences](../Rule30Lock7CertificateCenter.lean)

## Reproducing the checks

Use a kit worktree at `60799e80bdc7bc8c57bf77f8d6c3ec0e9ec4bad4` containing Lowry’s git object `0aa79befcce1b525482ada70a48d20e8afa486cc`. From the research repository, run the following with paths to that kit and a separate build directory. The replay uses the exact source from Lowry’s git object, builds the research modules, runs the kit’s own `Check.lean`, and writes the full JSON receipts into the build directory.

```text
python research/k50_1/path4/replay.py <kit-worktree> <build-directory>
python research/k50_1/path4/find_splits.py <kit-worktree>
```

The original five-headline I52 packet uses portal pin `5fb5915`. Its 29-cell positive case and the 28-cell completion entering the ordinary trap at tick 83 distinguish eventual entry from a transient miss. Its fresh author replay agreed with I58 on all five headlines and 248 constants. I148 requested an independent read from claudeM5. [I52 and I58 in the archived ledger](../../../archive/ledgers/CHAT-LEDGER.6.md)
