"""Write Rule30DrivenLeftFourLower.lean from the witnesses in ../data (claudeIntel, N27)."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
K = 80
rule = lambda l, c, r: (30 >> (4 * l + 2 * c + r)) & 1


def witness(w):
    m, age = w["m"], w["age"]
    seed = [int(ch) for ch in w["seed"]]
    wall = [int(ch) for ch in w["wallTapeBitT"]]
    far = 300
    row = {p: 0 for p in range(-far, 0)}
    for j, b in enumerate(seed):
        row[-m + j] = b
    for t in range(age):
        row = {p: rule(row.get(p - 1, 0), row[p], wall[t] if p + 1 == 0 else row[p + 1]) for p in range(-far, 0)}
    image = [row[p] for p in range(-(m + age), 0)]
    preds, above = [], row
    for k in range(4):
        z = {-1: (w["register"] >> (2 * k)) & 1, 0: (w["register"] >> (2 * k + 1)) & 1}
        for p in range(-1, -far, -1):
            z[p - 1] = above[p] ^ (z[p] | z[p + 1])
        tail = z[-K - 1]
        assert all(z[p] == tail for p in range(-far + 2, -K))
        preds.append((z[0], tail, [z[p] for p in range(-K, 0)]))
        above = z
    tape = sum(b << t for t, b in enumerate(wall))
    return m, age, tape, seed, image, preds


def lean_list(bits):
    return "[" + ", ".join("true" if b else "false" for b in bits) + "]"


def lean_bool(b):
    return "true" if b else "false"


HEADER = (HERE / "header.lean.txt").read_text(encoding="utf-8")
WITNESS = (HERE / "witness.lean.txt").read_text(encoding="utf-8")
FOOTER = (HERE / "footer.lean.txt").read_text(encoding="utf-8")


def main():
    W = json.loads((HERE.parent / "data" / "claudeIntel-four-tick-witnesses.json").read_text())
    text = HEADER
    for label, tag, name in (("m2-age71", "A", "nonadjacent"), ("m1-age72", "B", "adjacent")):
        m, age, tape, seed, image, preds = witness(W[label])
        fields = dict(tag=tag, name=name, m=m, age=age, tape=tape, seed=lean_list(seed), image=lean_list(image))
        for k, (w0, tail, M) in enumerate(preds, 1):
            fields[f"p{k}"] = lean_list(M)
            fields[f"t{k}"] = lean_bool(tail)
            fields[f"w{k}"] = lean_bool(w0)
        piece = WITNESS
        for key, value in fields.items():
            piece = piece.replace("{" + key + "}", str(value))
        text += piece
    text += FOOTER
    out = HERE / "Rule30DrivenLeftFourLower.lean"
    out.write_text(text, encoding="utf-8", newline="\n")
    print(hashlib.sha256(out.read_bytes()).hexdigest(), out.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
