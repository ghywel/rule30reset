Troy Lowry’s age-364 construction led us to this result. He proved that 80 positive cells force phase 6 of the width-30 lock at tick 95, reconstructed a compatible left half with a 728-cell ring, and proved the sharp seven-site moving-edge disagreement. We use his ring in the singleton deadline. This companion answers the maintainer’s request for a criterion on right prefixes. [Lowry’s work and the maintainer’s question](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041)

For every finite positive-side prefix, every infinite completion eventually enters the lock exactly when some finite binary certificate passes. Each leaf records a valid phase and entry tick for its branch. The checker is complete at each specified deadline. Compactness gives a common deadline whenever all completions eventually enter.

The worked example is a 29-cell prefix. Splitting once on site 30 certifies phase 4 at the first white tick. One completion sharing the first 28 cells avoids the lock forever. As a comparison with Lowry’s construction, an eleven-leaf certificate on the first 77 of his 80 cells implies his same phase 6 at tick 95.

On the genuine singleton, a certified right prefix at age A forces a disagreement with black-first alternation by absolute tick 2(A + E), where E is the largest physical entry tick on the tree. The conditional period-two exclusion requires arbitrarily late occurrences at black-centre ages. That recurrence remains open. The module imports merged kit results and carries the finite ring checks in `Rule30Certificates/LockRing728`. [Earlier width-30 lock](https://github.com/WolframInstitute/Rule30PrizeKit/pull/227)

The portal verified this Problem 1 partial. [Submission SUBMISSION_ID](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/SUBMISSION_ID)

Prepared with [OpenAI Codex](https://openai.com/codex/).
