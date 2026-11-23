"""Generate checked layer checkpoints for the sharp pure-three exit proof."""
from pathlib import Path
import argparse
from wheel_bridge import table
from audit_gap_observers import sample_bits


def step(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def layers(gaps, trap):
    word = list(map(int,sample_bits(gaps)))
    points = [[b] for b in word]
    yield 1,points
    for w in range(2,24):
        modulus = 1 << w
        candidates = [[y for x in xs for y in (x,x+(modulus >> 1))] for xs in points]
        if w==16:
            candidates[-1] = [x for x in candidates[-1] if x not in trap]
        def succ(x):
            return [step(step(x+(hi<<w),0),1) % modulus for hi in range(4)]
        left=[candidates[0]]
        for allowed in candidates[1:]:
            ids={y % 8191 for x in left[-1] for y in succ(x)}
            left.append([x for x in allowed if x%8191 in ids])
        points=[left[-1]]
        for allowed in reversed(left[:-1]):
            ids={x%8191 for x in points[-1]}
            points.append([x for x in allowed if any(y%8191 in ids for y in succ(x))])
        points.reverse()
        yield w,points
        if not points[0]:
            return


def main(kit, output):
    trap=set(table(kit,"trapCodes","Rule30Certificates/GateTrap"))
    text=[]
    for name,word,last in (("forbidden","3"*7+"53","false"),("entering","3"*8+"55","true")):
        prev = None
        for w,grid in layers(word,trap if name=="entering" else set()):
            n=w-1
            if n==0:
                continue
            if not grid[0]:
                text.append(f"theorem {name}_empty : (layers {name} {last} {n}).head? = some [] := by")
                if prev:
                    text.append(f"  rw [layers,{prev}]")
                text.append("  decide +kernel\n")
                break
            ds=str(n)
            # Each statement only needs to reduce one spatial lift. Values
            # are little-endian blocks of width w, preserving the list order.
            blocks=",".join(f"({len(xs)},0x{sum(x<<(i*w) for i,x in enumerate(xs)):x})" for xs in grid)
            dat=f"{name}Data{ds}"
            text.append(f"private def {dat} : Grid := (["+blocks+f"] : List (Nat × Nat)).map (fun p => unpackLayer {w} p.1 p.2)")
            cur=f"{name}Layer{ds}"
            text.append(f"private theorem {cur} : layers {name} {last} {n} = {dat} := by")
            if prev:
                text.append(f"  rw [layers,{prev}]")
            text.append("  decide +kernel\n")
            prev=cur
    output.write_text("\n".join(text)+"\n",encoding="utf8")


if __name__=="__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path); p.add_argument("output",type=Path)
    a=p.parse_args(); main(a.kit,a.output)
