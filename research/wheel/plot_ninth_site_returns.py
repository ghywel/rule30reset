"""Draw the two physical patches with Matplotlib. Run this file to regenerate the PNG."""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.patches import Rectangle


STARTS = (335, 535)
SPAN = 20
INK, GRID = "#172026", "#bdc7c9"
BLUE, ORANGE = "#006a83", "#a74113"


def measure():
    """Evolve the empty right half cell by cell. The east edge is beyond both light cones."""
    end = max(STARTS) + SPAN
    row = [0] * (end + 12)
    patches = {s: [] for s in STARTS}
    for t in range(end + 1):
        row[0] = int(t % 2 == 0)
        for s in STARTS:
            if s <= t <= s + SPAN:
                patches[s].append(row[:10])
        row = [0] + [row[j-1] ^ (row[j] | row[j+1])
                     for j in range(1, len(row)-1)] + [0]

    assert patches[335][0][1:9] == patches[535][0][1:9] == [1,1,1,0,0,1,1,0]
    assert [patches[s][0][9] for s in STARTS] == [1,0]
    for s, expected in zip(STARTS, ([0,10,16], [0,10,20])):
        data = patches[s]
        actual = [dt for dt,r in enumerate(data) if r[0] == 0 and r[1] == 1]
        first = 6 if data[0][5] else 10
        second = 6 if data[0][9] and (data[0][7] or not data[0][8]) else 10
        assert actual == expected == [0,first,first+second]
    return patches


def outline(ax, x, y, width, color):
    ax.add_patch(Rectangle((x-.45,y-.45),width-.10,.90,fill=False,
                           edgecolor=color,linewidth=2.5,zorder=5))


def panel(fig, left, start, data):
    ax = fig.add_axes([left, .137, .278, .664])
    ax.imshow(data, cmap=ListedColormap(["white", INK]), vmin=0, vmax=1,
              origin="upper", interpolation="nearest", aspect="equal")
    for x in range(11):
        ax.axvline(x-.5, color=GRID, lw=.48)
    for y in range(SPAN+2):
        ax.axhline(y-.5, color=GRID, lw=.48)
    ax.axvline(.5, color="#647274", lw=1.15)
    ax.set_xticks(range(10), labels=range(10))
    ax.xaxis.tick_top()
    ax.set_yticks(range(0,SPAN+1,2), labels=range(start,start+SPAN+1,2))
    ax.tick_params(length=0, pad=5, labelsize=9, colors=INK)
    ax.set_ylabel("Physical tick", labelpad=8, fontsize=10, color=INK)
    ax.set_xlim(-.5,9.5)
    ax.set_ylim(SPAN+.5,-.5)
    for spine in ax.spines.values():
        spine.set_color(GRID)
    ax.text(0,1.093,f"Start at tick {start}", transform=ax.transAxes, size=15,
            weight="bold", color=INK, va="bottom")
    ax.text(0,1.052,"Site", transform=ax.transAxes, fontsize=10, color=INK)

    outline(ax,1,0,8,BLUE)
    outline(ax,9,0,1,ORANGE)
    arrivals = [dt for dt,r in enumerate(data) if dt and r[0] == 0 and r[1] == 1]
    labels = [(0, ORANGE, "Site 9", "Black" if data[0][9] else "White"),
              (arrivals[0], BLUE, "First return", f"+{arrivals[0]} ticks"),
              (arrivals[1], ORANGE, "Second return", f"+{arrivals[1]} ticks")]
    for dt, color, title, value in labels:
        if dt:
            outline(ax,1,dt,1,color)
        ax.plot([9.65,10.03],[dt,dt], color=color, lw=1, clip_on=False)
        ax.annotate(title,(10.15,dt),xytext=(0,2),textcoords="offset points",
                    color=color,weight="bold",size=9.5,va="bottom",annotation_clip=False)
        ax.annotate(value,(10.15,dt),xytext=(0,-2),textcoords="offset points",
                    color=INK,size=9.5,va="top",annotation_clip=False)


def main():
    patches = measure()
    fig = plt.figure(figsize=(10.6,7.65),facecolor="white")
    fig.text(.055,.951,"The ninth site separates two returns on the same orbit",
             fontsize=20.5,weight="bold",color=INK)
    fig.text(.055,.910,"Rule 30 from an empty right half. At both starts, sites 1–8 read 11100110.",
             fontsize=11,color=INK)
    for left,start in zip((.095,.566),STARTS):
        panel(fig,left,start,patches[start])
    handles = [Rectangle((0,0),1,1,facecolor=c,edgecolor=INK,linewidth=.9)
               for c in (INK,"white")]
    fig.legend(handles,["Black cell","White cell"],loc="lower left",
               bbox_to_anchor=(.046,.057),frameon=False,ncol=2,fontsize=9.5,
               handlelength=1,handleheight=.9,columnspacing=1.5)
    fig.text(.055,.035,"Outlined returns are predicted black pulses at site 1, sampled when the alternating wall at site 0 is white.",
             color=INK,fontsize=10)
    dest = Path(__file__).with_name("ninth-site-returns.png")
    fig.savefig(dest,dpi=200,facecolor="white",metadata={"Software":"Matplotlib"})
    plt.close(fig)


if __name__ == "__main__":
    main()
