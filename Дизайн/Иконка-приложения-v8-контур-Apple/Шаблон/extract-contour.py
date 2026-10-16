from pypdf import PdfReader
import json
from pathlib import Path
source = Path(__file__).parent / 'App Icon Template.ai'
stream = PdfReader(source).pages[0].get_contents().get_data().decode('latin1')
part = stream.split('/OC /MC5 BDC')[1].split('h\n')[0]
commands = []
for line in part.splitlines():
    tokens = line.split()
    if not tokens or tokens[-1] not in ('m','l','c'): continue
    values = list(map(float,tokens[:-1]))
    points = [[round(values[i]+1023.9999,6),round(1024-(values[i+1]+373.0001),6)] for i in range(0,len(values),2)]
    commands.append({'op':tokens[-1],'points':points})
assert len(commands) == 44, len(commands)
(Path(__file__).parent / 'contour.json').write_text(json.dumps(commands,indent=2))
print('Extracted original Apple contour:',len(commands),'segments')
