"""K92.4, claudeM5 (M234): writes TwoCerts.lean and TwoFalls.lean for the modulus-two strip theorem.

TwoCerts: the fifteen certified assignments of the any-period census (claudeM5_any_period_strips.cpp, fall 2 27).
The nine of width at most 10 get full any-lag tables (LagCert); the six wider ones are cut in two, and get a table
of where each half eventually stays (EvCert) and a table over the product of those sets (ProdCert). TwoFalls: the
substrip classification of widths 3 to 27 from the census's uncertified lists, in the order of Lean's `ruledOut`.
Every certificate is checked by simulating its Lean checker before it is written (claudeM5_two_certs.py).
Usage: python3 claudeM5_two_lean.py CENSUS_OUTPUT OUTDIR
"""
import sys, pathlib
import claudeM5_two_certs as T
import claudeM5_two_chain as C

SMALL = ['0011', '0110', '01010', '01011', '011101', '0111101', '01111101', '011111101', '0000000010']
WIDE = [('000000000000', 6), ('00100000000001', 7), ('000000010000001', 8), ('00000001000000010', 9),
        ('000000010000000001', 9), ('00000001000000000001', 10)]

def certs():
    out = ['import LagCert', '', '/-! The fifteen modulus-two certificates, generated and checked by the generator before writing. -/',
           'namespace PhaseFalls.Moduli', 'set_option maxRecDepth 100000', 'set_option maxHeartbeats 0', '']
    for k, pat in enumerate(SMALL):
        a = [int(c) for c in pat]; L = T.lag_final(a)
        out.append(T.lean_lag(f'lag{k}', L))
        out.append(f'theorem lag{k}_ok : checkLag {len(a)} 2 lag{k} = true := by decide +kernel')
        out.append(f'theorem good_{pat} : GoodAny {len(a)} 2 (fun j => lag{k}.labels.getD j 0) := goodAny_of_checkLag (by decide) lag{k}_ok')
        out.append('')
    for k, (pat, wa) in enumerate(WIDE):
        a = [int(c) for c in pat]; A, B, P = T.prod_final(a, wa)
        out.append(T.lean_ev(f'blockA{k}', A)); out.append(T.lean_ev(f'blockB{k}', B)); out.append(T.lean_prod(f'prod{k}', P))
        out.append(f'theorem blockA{k}_ok : checkEv prod{k}.wa 2 blockA{k} = true := by decide +kernel')
        out.append(f'theorem blockB{k}_ok : checkEv ({len(a)} - prod{k}.wa) 2 blockB{k} = true := by decide +kernel')
        out.append(f'theorem prod{k}_ok : checkProd {len(a)} 2 blockA{k} blockB{k} prod{k} = true := by decide +kernel')
        out.append(f'theorem good_{pat} : GoodAny {len(a)} 2 (fun j => prod{k}.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA{k}_ok blockB{k}_ok prod{k}_ok')
        out.append('')
    out.append('end PhaseFalls.Moduli')
    return '\n'.join(out) + '\n'

def falls(census):
    steps = C.chain(census, 27)
    certified = {''.join(map(str, c)) for _, _, cs in steps for c in cs}
    assert certified == set(SMALL) | {p for p, _ in WIDE}, certified
    L = lambda xs: '[' + ', '.join('[' + ', '.join(map(str, x)) + ']' for x in xs) + ']'
    out = ['import TwoCerts', 'import TwoCover', '',
           '/-! Generated: the substrip classification of the modulus-two assignments, widths 3 to 27,',
           'from the uncertified lists of the any-period census, with the fifteen certificates of `TwoCerts`. -/',
           'namespace PhaseFalls.Moduli', 'set_option maxRecDepth 100000', 'set_option maxHeartbeats 0', '']
    prev = '(pairs_classifyAny 2)'
    for w, rem, cs in steps:
        out.append(f'private def two{w} : List (List Nat) := {L(rem)}')
        if cs:
            names = ['good_' + ''.join(map(str, c)) for c in cs]
            pats = ' | '.join(['rfl'] * len(cs))
            certs = (f'(by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with {pats} <;> first '
                     + ' '.join(f'| exact {n}' for n in names) + ')')
        else:
            certs = '(by simp)'
        prevlist = 'pairs 2' if w == 3 else f'two{w-1}'
        out.append(f'private theorem cover{w} : ruledOut 2 ({prevlist}) two{w} = {L(cs)} := by rw [← ruledOutFast_eq]; decide +kernel')
        out.append(f'private theorem cls{w} : ClassifiesAny {w} 2 two{w} :=')
        out.append(f'  classify_stepAny (w := {w-1}) (by decide) (by decide) {prev} {certs} cover{w}')
        out.append('')
        prev = f'cls{w}'
    out += ['/-- Every phase assignment of a 27-cell strip, falls on one parity per cell, forces a repeating adjacent pair. -/',
            'theorem goodAny27 (a : Nat → Nat) (ha : ∀ j, j < 27 → a j < 2) : GoodAny 27 2 a :=',
            '  of_emptyAny (by decide) cls27 ha', '',
            '/-- **Modulus two.** Every 27 adjacent singleton Rule 30 columns contain a column whose black-to-white falls',
            'start on even ticks and on odd ticks, each after every cutoff. -/',
            'theorem two_parities_every_27 (i : Int) :',
            '    ∃ (j : Fin 27) (r q : Fin 2), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=',
            '  two_cofinal_from_goodAny (by decide) (by decide) i goodAny27', '', 'end PhaseFalls.Moduli']
    return '\n'.join(out) + '\n'

if __name__ == '__main__':
    census, outdir = sys.argv[1], pathlib.Path(sys.argv[2])
    (outdir / 'TwoCerts.lean').write_text(certs(), encoding='utf-8')
    (outdir / 'TwoFalls.lean').write_text(falls(census), encoding='utf-8')
    print('wrote', outdir / 'TwoCerts.lean', outdir / 'TwoFalls.lean')
