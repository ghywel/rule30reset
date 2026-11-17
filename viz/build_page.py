"""Fill survivors.template.html with the two exact data files and write survivors.html."""
import json, sys, os
here = os.path.dirname(os.path.abspath(__file__))
surv = json.load(open(sys.argv[1])); theta = json.load(open(sys.argv[2]))
surv.pop('rows', None); surv.pop('surv', None)
for r in theta['depths']:
    r.pop('occ', None); r.pop('bydeg', None)
data = json.dumps({'survival': surv, 'theta': theta}, separators=(',', ':'))
assert '</' not in data
page = open(os.path.join(here, 'survivors.template.html')).read().replace('/*DATA*/', data)
open(os.path.join(here, 'survivors.html'), 'w').write(page)
print('survivors.html', len(page), 'bytes')
