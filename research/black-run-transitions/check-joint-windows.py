"""Compare the cyclic phase tests on the separating stem and its extensions."""

AGES = (8, 8, 8, 15, 8, 16, 4, 14)
STEM = (16, 4, 9, 1, 4, 9)

def runs_word(runs):
    return ''.join('1' * run + '0' for run in runs)

def kit_windows(period):
    yield '1'*9
    yield '1'*4+'0'+'1'*7
    yield '1'*8+'011'
    for n in range(period):
        for pre in ('111111110','11110110','111101111110','11111111011110'):
            yield pre+'1'*(2*n+1)
        yield '11111111010'+'1'*(2*n)

def ends(w, j, v):
    return all(w[(j-len(v)+i)%len(w)] == b for i,b in enumerate(v))

def run_test(runs):
    w = runs_word(runs)
    old = tuple(kit_windows(len(w)))
    pair = tuple('1'*a+'0'+'1'*r for r,a in enumerate(AGES,1))
    return [(j, any(ends(w,j,v) for v in old), any(ends(w,j,v) for v in pair))
            for j,b in enumerate(w) if b=='0']

expected = [(16,True,False),(21,False,True),(31,True,False),(33,True,True),
            (38,True,False),(48,True,False)]
assert run_test(STEM)==expected
print('phase, old, two-run:', expected)
for extra in range(1, 17):
    runs = (*STEM,*([9]*extra))
    res=run_test(runs)
    assert all(o or p for _,o,p in res)
    assert not all(o for _,o,_ in res)
    w=runs_word(runs)
    assert all(w != w[k:]+w[:k] for k in range(1,len(w)))
print('strict extension and primitive words checked for 17 stem-plus-nine examples')
