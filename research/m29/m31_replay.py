"""Replay the first failing seed per batch and age, plus prespecified samples, with M31's literal histories."""
from collections import Counter
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "r2"))
from claudeM5_r8_replay import F, histories


def replay(path):
    ages = {a: Counter() for a in range(59, 80)}
    widths = Counter()
    checked = Counter()
    witnesses = {}
    for batch in range(40):
        lines = (path / f'batch-{batch:02d}.txt').read_text().splitlines()
        cases = set()
        seen_ages = set()
        verified_witnesses = set()
        wide = None
        for line in lines:
            tag, *fields = line.split()
            if tag == 'widths':
                assert wide is None
                wide = list(map(int, fields))
                assert len(wide) == 41 and sum(wide) == 25000
                widths.update(dict(zip(range(160, 201), wide)))
            elif tag == 'age':
                age, rows, direct, failed, heads = map(int, fields)
                assert age in ages and age not in seen_ages and rows == 25000
                assert 0 <= failed <= direct <= rows and failed <= heads <= 16*failed
                assert (age in verified_witnesses) == bool(failed)
                seen_ages.add(age)
                ages[age].update(rows=rows, direct=direct, failed=failed, failed_histories=heads)
            else:
                assert tag in ('sample', 'witness', 'control')
                index, age = map(int, fields[:2])
                seed, supplied = (int(x, 16) for x in fields[2:4])
                mask = int(fields[4])
                row = seed
                for _ in range(age):
                    row = F(row)
                assert row == supplied
                bad = [h for h, p in histories(row, 4) if p is None]
                actual = sum(1 << sum(bit << j for j, bit in enumerate(h)) for h in bad)
                assert len(bad) == actual.bit_count() and actual == mask
                checked[tag] += 1
                if tag == 'sample':
                    assert index == batch*25000 and 160 <= seed.bit_length() <= 200
                    cases.add(age)
                if tag == 'witness':
                    assert 25000*batch <= index < 25000*(batch+1) and mask
                    assert age not in verified_witnesses and 160 <= seed.bit_length() <= 200
                    verified_witnesses.add(age)
                    witnesses.setdefault(age, dict(index=index, seed=hex(seed), width=seed.bit_length(),
                                                   age=age, row=hex(row), failed_mask=mask,
                                                   failed_heads=[''.join(map(str,h)) for h in bad]))
                if tag == 'control' and seed == 7815:
                    assert age == 58 and mask
        assert wide is not None and seen_ages == cases == set(ages)
    assert checked['control'] == 4 and checked['sample'] == 840
    return dict(seeds=sum(widths.values()), ages=ages, widths=widths, replays=checked,
                latest_failure=max(witnesses, default=None), witnesses=witnesses)


if __name__ == '__main__':
    print(json.dumps(replay(Path(sys.argv[1])), indent=2))
