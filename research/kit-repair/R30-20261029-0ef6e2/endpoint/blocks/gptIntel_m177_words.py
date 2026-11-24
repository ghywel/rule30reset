"""Generate literal N15 words and exact endpoint rotation examples, without floats."""
import argparse
from math import isqrt


def floor_sqrt2(t):
    # Adjacent integer squares uniquely certify the floor without a float.
    k=isqrt(2*t*t)
    assert k*k <= 2*t*t < (k+1)*(k+1)
    return k


def word(kind, q, readings):
    answer=[]
    t=q
    while len(answer)<readings:
        f=floor_sqrt2(t)
        if kind=="silver" or "," in kind:
            a,b=(4,3) if kind=="silver" else map(int,kind.split(","))
            length=3+5*(a if f%2 else b)
            answer.extend(int(i==0 or i%5==3) for i in range(length))
        else:
            # {t sqrt(2)/m} < 1/m iff floor(t sqrt(2)) is 0 (mod m).
            m=int(kind)
            length=3 if f%m==0 else 5
            answer.extend([1]+[0]*(length-1))
        t+=1
    return "".join(map(str,answer[:readings]))


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kind",help="silver, comma-separated odd/even five counts, or positive arc denominator")
    p.add_argument("q",type=int)
    p.add_argument("readings",type=int)
    args=p.parse_args()
    print(word(args.kind,args.q,args.readings))
