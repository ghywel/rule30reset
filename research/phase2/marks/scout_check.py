"""Independent singleton records through a small age. Ages name births, not arrivals."""
import argparse


def records(ages):
    centre = []
    gaps = []
    row = 1
    for t in range(ages + 1):
        centre.append((row >> t) & 1)
        west = row & ((1 << t)-1)
        gaps.append(t-west.bit_length() if west else None)
        row = (row << 2) ^ ((row << 1) | row)
    best = {"mark": -1, "failure": -1, "run0": 0, "run1": 0}
    for s, bit in enumerate(centre):
        l = gaps[s]
        if l is not None and s+l <= ages and centre[s+l] and l > best["mark"]:
            best["mark"] = l
            print("mark", s, l)
        # The true rule for western cells. Use the literal rule table here.
        west = []
        for t in range(ages-s):
            c = centre[s+t]
            if c and (west[0] if west else 0) == centre[s+t+1]:
                if t > best["failure"]:
                    best["failure"] = t
                    print("failure", s, t)
                break
            extended = west + [0,0]
            west = [(30 >> (4*extended[i+1]+2*extended[i]+(c if i==0 else extended[i-1]))) & 1
                    for i in range(len(west)+1)]
        if s==0 or bit!=centre[s-1]:
            start=s
        if s<ages and bit!=centre[s+1]:
            name=f"run{bit}"
            if s-start+1>best[name]:
                best[name]=s-start+1
                print(name,start,s-start+1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--age", type=int, default=768)
    records(parser.parse_args().age)
