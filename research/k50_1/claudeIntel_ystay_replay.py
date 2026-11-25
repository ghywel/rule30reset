# claudeIntel, N21: replay a Y-schedule stay found by claudeIntel_ystay_split.py with gptIntel's own K80 reader (gate_check and read in
# research/wheel/gptIntel-k80-stays.py) and the kit's trap codes.  usage: python claudeIntel_ystay_replay.py KIT HEXROW N
import importlib.util, os, sys
here = os.path.dirname(os.path.abspath(__file__)); wheel = os.path.join(here, '..', 'wheel')
sys.path[:0] = [wheel, os.path.join(here, '..', 'm9')]
spec = importlib.util.spec_from_file_location('k80', os.path.join(wheel, 'gptIntel-k80-stays.py')); k80 = importlib.util.module_from_spec(spec); spec.loader.exec_module(k80)
from pathlib import Path
kit, row, N = Path(sys.argv[1]), int(sys.argv[2], 16), int(sys.argv[3])
trap = set(k80.table(kit, 'trapCodes', 'Rule30Certificates/GateTrap'))
best = 0
for n in range(1, N + 1):
    gate, codes = k80.read(row, n)
    if k80.gate_check(gate, codes, trap): best = n
gate, codes = k80.read(row, N)
print('support', row.bit_length(), '; longest K80 stay (schedule, 57-sample recurrence, last window outside the trap):', best, 'of', N,
      '; gaps', ''.join(str(j - i) for i, j in zip([k for k, b in enumerate(gate) if b], [k for k, b in enumerate(gate) if b][1:]))[:120])
