# M181 with isolated wheel blocks

The original universal question for `A = 3 5³` and `B = 3 5⁵` has a negative answer. N19’s checked 80-column refusal of `B¹⁵`, with a free east edge, also excludes it on the infinite right half. The width-80 strip still allows fourteen copies. Here the wall alternates, starting white, and readings are taken on its white ticks. [N19’s experiments](claudeIntel-n19.md) · [Checked fifteen-turn refusal](../../../CHAT-LEDGER.md)

The successor question allows no adjacent B’s. Use macros `X = A` and `Y = AB`, of lengths 18 and 46 white readings. Every macro order avoids adjacent B’s. An A/B order with isolated B’s also parses this way after prepending A whenever it starts with B. After the first A, a driven history can be restarted on the same wall phase.

## Physical finite census

| Search | Macro depth | Leaves found | All retained witnesses replayed |
|---|---:|---:|---:|
| 160 particles | 8 | 250 / 256 | 502 |
| 1,200 particles | 8 | 256 / 256 | 510 |
| 1,200 particles | 9 | **512 / 512** | **1,022** |

Every leaf at depth nine has a genuine initial prefix through the next `1001`. The longest is `Y⁹ = (AB)⁹`, with 18 original blocks, 418 readings including that closing word, and 835 initial cells. Of the 512 leaves, 502 extend past the previous ten-original-block census. The six missing depth-eight leaves from the smaller run were recovered with the larger population.

The sampler extends N19’s tree of orders and uses its suffix resampling. One verifier replays the literal truth table with an unknown east, and a second uses independent three-valued bit masks. Both verify every retained witness. A sampled row is used only for the finite prefix replayed. The infinite isolated-B question remains open. One route forward is to build a rule that repeatedly extends a common initial prefix for both macro choices, or to find an isolated-B word and certify its refusal.

## Replay

The archive `share-scratch/gptM5/M181/m181-R129-isolated.zip` contains the frozen sampler and literal verifier, all three runs’ rows and the coverage logs. SHA-256 `9a5fbc45722c4276f6fb318ea5693df483a3d0a4baea4fc8445f3c96deefd225`. Build the sampler with C++17 and OpenMP. The largest run used `tree 1200 1 9 392177 nine.tsv --isolated-wheel` with three threads. Particle scheduling may change the sampled rows. The archived witnesses are fixed.

```sh
python3 research/wheel/block-orders/claudeIntel_verify.py nine.tsv --isolated-wheel
```

In the archive’s order column A and B are the sampler’s labels for X and Y. A row’s last field is its complete initial prefix, of length twice the number of checked readings minus one.
