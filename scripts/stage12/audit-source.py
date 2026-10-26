from pathlib import Path
import re,json,struct,hashlib
R=Path('G:/MySTG');P=R/'aex-0.8.22/game/mod/Stage12Normal/source/balance';results=[]
for g in (10,14):
 desc=(P/f'struct_{g}.js').read_text();fields=re.findall(r'"(\w+)", "(\w+)"',re.search(r'sht_arr: \[(.*?)\n\s*\]',desc,re.S)[1]);formats={'byte':'B','int16':'h','int32':'i','uint32':'I','float':'f'}
 for path in sorted((P/f'th{g}').glob('*.sht')):
  b=path.read_bytes();cnt=struct.unpack_from('<H',b,2)[0];header=32 if g==10 else 64;table=header+(240 if g==10 else 160);stride=8 if g==10 else 4;array=table+cnt*stride
  offsets=[struct.unpack_from('<I',b,table+i*stride)[0] for i in range(cnt)];sets=[]
  for idx,o in enumerate(offsets):
   pos=o if g==10 else array+o;rows=[]
   while b[pos:pos+4]!=b'\xff'*4:
    row={}
    for name,typ in fields:
     if typ=='flags':row[name]=list(struct.unpack_from('<16h',b,pos));pos+=32
     else:fmt='<'+formats[typ];row[name]=struct.unpack_from(fmt,b,pos)[0];pos+=struct.calcsize(fmt)
    assert 0<row['fire_rate']<=30;rows.append(row)
   cycle=16 if g==10 else 15
   def rate(row):return sum(t>=row['start_delay'] and t%row['fire_rate']==0 for t in range(cycle))*60/cycle
   sets.append({'mode':'focused' if idx>=5 else 'unfocused','power':idx%5,'shooters':rows,'main_nominal_dps':sum(rate(r)*r['dmg'] for r in rows if r['option']==0),'all_nominal_dps':sum(rate(r)*r['dmg'] for r in rows)})
  result={'game':g,'path':str(path),'sha256':hashlib.sha256(b).hexdigest(),'max_damage_per_frame':struct.unpack_from('<I',b,40)[0] if g==14 else None,'sets':sets};results.append(result)
  p1=sets[1];print(g,path.name,'main',p1['main_nominal_dps'],'all_P1',p1['all_nominal_dps'],'all_P4',sets[4]['all_nominal_dps'],'cap',result['max_damage_per_frame'])
(P/'shots.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
# Original literal enemy health variants, including support emitters labelled explicitly.
bank=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841');enemies=[]
for g,folder,file in [(10,'th10_local-original-archive-candidate_1fb1d0ffe341','stage01.named.utf8.txt'),(10,'th10_local-original-archive-candidate_1fb1d0ffe341','stage02.named.utf8.txt'),(14,'th14_local-original-archive-candidate_57d84a5cbe82','st01.named.utf8.txt')]:
 p=bank/folder/'raw'/file;s=p.read_text(encoding='utf-8');groups={}
 for name,hp in re.findall(r'enmCreate\w*\("(\w+)", [^,]+, [^,]+, (\d+),',s):groups.setdefault(name,set()).add(int(hp))
 enemies.append({'game':g,'stage_file':file,'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'literal_hp_variants':{n:sorted(h) for n,h in groups.items()}})
(P/'enemy-health.json').write_text(json.dumps(enemies,indent=2),encoding='utf-8')
