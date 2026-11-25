"""Replay 011 gate forks, the known 001 trap, or true initial-row evidence."""
import argparse
import re
from pathlib import Path


def step(row, wall, width, east):
    expanded = row | east << width
    return sum(((((expanded << 1 | wall) >> p) & 1)
                ^ (((expanded >> p) | (expanded >> (p+1))) & 1)) << p
               for p in range(width))


def strobe(row, drive, width, code):
    row |= code << width
    for i, wall in enumerate(drive):
        row = step(row, int(wall), width+2-i, 0)
    return row


def forks(drive, path):
    checked = []
    for line in path.read_text().splitlines():
        w, root, a, b, left, right = line.split()
        w, root, left, right = map(int, (w,root,left,right))
        assert len(a)==len(b)>0 and set(a+b)<=set("01234567")
        out = [root,root]
        for edge in zip(a,b):
            out = [strobe(row,drive,w,int(code)) for row,code in zip(out,edge)]
        assert out == [left,right] and (left^right)&1
        checked.append(w)
    assert checked == list(range(14,max(checked)+1))
    print("literal fork replay", drive, checked[0], checked[-1])


def fifteen(path):
    source = path.read_text(encoding="utf-8")
    r,l,s = (int(re.search(r"def trap001fifteen_"+tag+r" : Nat := (\d+)",source)[1]) for tag in "RLS")
    rows = [(r>>(52*i))&((1<<52)-1) for i in range(153)]
    labels = [(l>>(4*i))&15 for i in range(153)]
    drive = "001"
    gate = {}
    for i, (r,label) in enumerate(zip(rows,labels)):
        assert label<15
        if drive[label%3]=="0":
            assert gate.setdefault(label,r&1)==r&1
        for east in (0,1):
            nxt = (s>>(8*(2*i+east)))&255
            assert labels[nxt]==(label+1)%15
            assert rows[nxt]==step(r,int(drive[label%3]),52,east)
    assert "".join(str(gate[p]) for p in (4,7,10,13,1))=="11000"
    print("001 positive control, 153 width-52 labelled rows, gate 11000")


def physical(path, width):
    import numpy as np

    tagged = np.fromfile(path,dtype="<u2")
    assert len(tagged)==1<<width and np.all(tagged>>7) and int((tagged>>7).max())<=12
    # Batch by the single flipped initial site and stopping time. The
    # independent checker evaluates Boolean cell arrays at each word boundary.
    for code in sorted(map(int,np.unique(tagged))):
        rows = np.flatnonzero(tagged==code).astype(np.uint64)
        time = 3*(code&127)
        count = (time+64)//64
        a = np.zeros((len(rows),count),dtype=np.uint64)
        a[:,0] = rows
        b = a.copy()
        index = width+(code>>7)-1
        assert index <= time
        b[:,index//64] ^= np.uint64(1) << np.uint64(index%64)

        def evolve(bits, side):
            left, right = bits << 1, bits >> 1
            left[:,1:] |= bits[:,:-1] >> 63
            left[:,0] |= side
            right[:,:-1] |= bits[:,1:] << 63
            return left^(bits|right)

        for t in range(time):
            a = evolve(a, int(t%3!=0))
            b = evolve(b, int(t%3!=0))
        assert np.all((a[:,0]^b[:,0])&1)
    print("all true fork witnesses replayed",1<<width,"width",width,
          "horizon",int((tagged&127).max()))


if __name__ == "__main__":
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("mode",choices=("forks","fifteen","physical"))
    ap.add_argument("path",type=Path)
    ap.add_argument("--drive",default="011")
    ap.add_argument("--width",type=int)
    a=ap.parse_args()
    if a.mode=="forks":
        forks(a.drive,a.path)
    elif a.mode=="fifteen":
        fifteen(a.path)
    else:
        physical(a.path,a.width)
