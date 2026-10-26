"""Bounded extraction of Normal TH08 4B timelines; no general ECL execution."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'aex-0.8.22/game/mod/MySTG/stages/th08_stage4'
REF=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th08_local-original-archive-candidate_9d7edf43b8dd/raw')
text=(REF/'ecldata4b.named.utf8.txt').read_text(encoding='utf-8')
def timeline(name):
    body=re.search(r'timeline '+name+r'\(\)\s*\{(.*?)\n\}',text,re.S)[1]
    frame=0; enabled=True; rows=[]
    for line in body.splitlines():
        line=line.strip()
        if line.startswith('!'):
            mask,line=re.match(r'!([A-Z*]+)\s*(.*)',line).groups()
            enabled='*' in mask or 'N' in mask
        if line.startswith('+'): frame+=int(re.match(r'\+(\d+)',line)[1]); continue
        if not enabled: continue
        create=re.match(r'enmCreate(M?)\("(Sub\d+)", ([^;]+)\);',line)
        if create:
            args=[float(v.strip().removesuffix('f')) for v in create[3].split(',')]
            rows.append({'frame':frame,'kind':create[2],'mirror':bool(create[1]),'x':args[0],'y':args[1],'hp':args[2],'drop':args[3]})
        elif line.startswith('resumeTimeline'): rows.append({'frame':frame,'resume':True})
        elif line.startswith('waitTimeline'): rows.append({'frame':frame,'gate':True})
    return rows
main=timeline('Timeline0'); side=timeline('Timeline1')
resumes=[r['frame'] for r in main if 'resume' in r]
gate_index=-1; gate_time=0; events=[r for r in main if 'kind' in r]
for r in side:
    if 'gate' in r: gate_index+=1; gate_time=r['frame']; continue
    if 'kind' in r:
        assert gate_index<len(resumes),'unmatched side timeline gate'
        events.append({**r,'frame':resumes[gate_index]+r['frame']-gate_time,'side_timeline':True})
events.sort(key=lambda r:r['frame'])
OUT.mkdir(parents=True,exist_ok=True)
lines=['-- Generated from pinned ecldata4b Normal timelines.','th08_schedule={']
for e in events:
    lines.append('    {at=%d,kind=%s,x=%s,y=%s,hp=%d,mirror=%s,drop=%d},'%
                 (e['frame'],json.dumps(e['kind']),e['x'],e['y'],e['hp'],str(e['mirror']).lower(),e['drop']))
lines.append('}')
(OUT/'schedule.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
sources={name:{'path':str(REF/name),'sha256':hashlib.sha256((REF/name).read_bytes()).hexdigest()}
         for name in ('ecldata4b.ecl','ecldata4b.named.utf8.txt')}
archive=next(a for a in json.loads((REF.parents[1]/'manifest.json').read_text(encoding='utf-8'))['archives'] if a['game']==8 and a['archive_sha256'].startswith('9d7edf'))
data={'game':8,'route':'4B / Marisa','difficulty':'Normal','sources':sources,'archive':archive,
      'resumes':resumes,'events':events,'standard_phases':['non1','milky','non2','stardust','non3','nondirectional','non4','master','earthlight'],
      'conditional_practice':'final','native_original_parity_verified':False,
      'approximations':['AEX sprites, spawn animations and player/scoring systems','native movement interpolation','familiar distribution and damage','Master/Final Spark ANM-special collision replaced by warned AEX beam','original time-point eligibility not implemented']}
(OUT/'reference.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'events':len(events),'small_enemies':sum(e['kind'] in ('Sub0','Sub3','Sub5','Sub7','Sub12') for e in events),'resumes':resumes,'encounters':[e for e in events if e['kind'] in ('Sub16','Sub27')]},indent=2))
