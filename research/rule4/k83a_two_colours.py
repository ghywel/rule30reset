"""Find two extensions of one initial prefix forcing opposite gates at the same sample.

The first pair found has minimum joint depth for this three-valued recognizer and
horizon. Each reported pair gives an unconditional upper bound on d for every target.
"""
import json
from k83a_escape import seeds, trace


def advance(zero, one, black):
    low = zero & (zero >> 1)
    high = one | (one >> 1)
    west0, west1 = (zero << 1) | (1-black), (one << 1) | black
    return (west0 & low) | (west1 & high), (west0 & high) | (west1 & low)


def forced_readings(low, width, samples):
    zero, one = ((1 << width) - 1) ^ low, low
    for s in range(samples):
        zero, one = advance(zero, one, 1)
        if not (zero | one):
            break
        if (zero | one) & 1:
            yield s, one & 1
        zero, one = advance(zero, one, 0)


def pair(seed, width, depth, samples):
    low = seed % (1 << width)
    for k in range(1, depth + 1):
        seen = [{}, {}]
        for word in range(1 << k):
            for s, value in forced_readings(low | (word << width), width+k, samples):
                if s in seen[1-value]:
                    words = [word, word]
                    words[1-value] = seen[1-value][s]
                    for bit, w in enumerate(words):
                        branch = low | (w << width)
                        assert trace(branch, s+1)[s] == bit
                        assert trace(branch | (1234567 << (width+k)), s+1)[s] == bit
                    return {"k": k, "sample": s, "white": words[0], "black": words[1]}
                seen[value].setdefault(s, word)
    return None


if __name__ == "__main__":
    starts = seeds()
    for label in ("trap", "train", "lock"):
        widths = (29,) if label == "lock" else (16, 24, 32, 40, 48, 56, 64, 80, 96)
        for width in widths:
            answer = pair(starts[label], width, 12, 512)
            print(json.dumps({"label": label, "width": width, "depth": 12, "samples": 512,
                              "pair": answer}), flush=True)
