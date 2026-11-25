# Bound Rule 30 topological entropy using adjacent-column words

This adds a supporting result for catalogue §7, item 11. Let Nₐ(n) be the number of length-n words seen at columns a and a + 1 over all initial configurations on ℤ. The new module proves the catalogue’s assertion that the growth rate of Nₐ equals the topological entropy of one physical tick. Each positive k gives the upper bound log(Nₐ(k))/k.

A weighted reverse cover turns a finite transition table into a bound for every time horizon. Every physical pair word follows a path backwards from the terminal state. If q times the sum of successor weights at each state is at most p times its own weight, then the path count grows at most as (p/q)ⁿ, up to the initial weight. The five-site example verifies this condition on 140 rows and checks the predecessor relation directly against Rule 30.

Together with the lower bound in `Mixing`, this gives **1 ≤ h < 1.232039 bits per tick** for the full two-sided map. The Lean upper bound is the exact natural logarithm of 1679211/714866. Whether h exceeds one bit remains open.

The existing window-cover construction in `Mixing` now exposes the physical word count before applying its three-letter estimate. The new module is imported by `Rule30Equivalents`. The default kit build, kernel replay of both changed modules, and the axiom checks passed on Lean 4.35.0. The module built in 9.3 seconds with dependencies already built.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI).
