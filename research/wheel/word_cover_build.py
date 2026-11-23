"""Generate occasional kernel-checked row checkpoints for each required marker."""
import argparse
from pathlib import Path
from word_cover_layers import grids
from wheel_bridge import table


MARKERS = [(0,20,0x12121), (1,23,0x484842), (3,26,0x484242), (5,29,0x2108424), (6,29,0x12108421),
           (7,30,0x24210908), (9,30,0x24210909), (10,31,0x10842108),
           (11,33,0x21084842), (13,38,0x212108424)]


def module(marks, trap, stride, literal=False):
    dep="word_cover_split" if any(i==10 for i,_,_ in marks) else "word_cover_fast"
    text=["module","public import "+dep,"", "@[expose] public section",
          "namespace Ruliology.CellularAutomata.WordCover","open PureThreeExit",
          "set_option maxRecDepth 100000","set_option maxHeartbeats 0","set_option Elab.async false",""]
    for i,n,code in marks:
        bits="".join(str(code>>j&1) for j in range(n))
        previous=0
        for w,rows,_ in grids(bits,trap,endpoint=True):
            if rows[0] and (w-1)%stride:
                continue
            call=f"layers (word {n} {code:#x}) true {w-1}"
            split = i in (5,10) and w==16 and previous==15
            if split:
                text += [
                    f"private def cand{i} : Grid := wordStage {n} {code:#x} 16 0",
                    f"private def front{i} : Grid := wordStage {n} {code:#x} 16 1",
                    f"private theorem lift{i} : lift 15 (admit true (word {n} {code:#x}).length 16) 0 grid{i}_15 = cand{i} := by",
                    "  rw [fast_admit]", "  decide +kernel"]
                if i==10:
                    text.extend([
                        "private theorem right10a : right 16 (cand10.take 15) = front10.take 15 := by decide +kernel",
                        "private theorem right10b : forward 16 ((front10.take 15).getLastD []) (cand10.drop 15) = front10.drop 15 := by decide +kernel",
                        "private theorem right10 : right 16 cand10 = front10 := right_split _ _ _ _ (by decide +kernel) right10a right10b",""])
                else:
                    text.extend([f"private theorem right{i} : right 16 cand{i} = front{i} := by decide +kernel",""])
            if rows[0]:
                if literal:
                    blocks=[f"({len(row)},0x{sum(x<<(w*j) for j,x in enumerate(row)):x})" for row in rows]
                    value=f"decodeGrid {w} ["+",".join(blocks)+"]"
                else:
                    value=f"wordCheckpoint {n} {code:#x} {w}"
                text.append(f"private def grid{i}_{w} : Grid := {value}")
                text.append(f"private theorem layer{i}_{w} : {call} = grid{i}_{w} := by")
            else:
                text.append(f"theorem cut{i} : ({call}).head? = some [] := by")
            if previous:
                steps=["layers"]*(w-previous)+[f"layer{i}_{previous}"]
                if split:
                    steps.extend([f"lift{i}",f"right{i}"])
                elif previous<16<=w:
                    steps.append("fast_admit")
                unfolds=", ".join(steps)
                text.append(f"  rw [{unfolds}]")
            text.extend(["  decide +kernel",""])
            previous=w
        assert not rows[0]
    text.append("end Ruliology.CellularAutomata.WordCover")
    return "\n".join(text)+"\n"


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("kit",type=Path)
    p.add_argument("output",type=Path);p.add_argument("ids",type=int,nargs="+");p.add_argument("--stride",type=int,default=1)
    p.add_argument("--literal",action="store_true")
    a=p.parse_args()
    trap=set(table(a.kit,"trapCodes","Rule30Certificates/GateTrap"))
    marks=[m for m in MARKERS if m[0] in a.ids]
    a.output.write_bytes(module(marks,trap,a.stride,a.literal).encode())
