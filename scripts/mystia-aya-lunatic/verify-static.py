"""Compare native Lua-exported events with TH10 Boss3 Lunatic parameters."""
from pathlib import Path
import csv,json,math,hashlib,re
ROOT=Path('G:/MySTG')
LOG=ROOT/'work/logs/mystia-aya-lunatic'
MOD=ROOT/'aex-0.8.22/game/mod/MystiaAyaNon3Lunatic'
REF=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage04.named.utf8.txt')
text=REF.read_text(encoding='utf-8')
def body(name): return re.search(r'void '+name+r'\([^)]*\)\s*\{(.*?)\n\}',text,re.S)[1]
blue,red=body('Boss3_at2'),body('Boss3_at3')
assert 'diffF(%B, 1.0f, 1.0f, 1.5f, 2.0f);' in blue
assert 'diffF(%B, 3.0f, 3.0f, 4.0f, 5.0f);' in red
assert '0.20944f;' in red and '%A - 5.026548f' in red
expected=[]
for cycle in range(18):
    for n in range(32):
        tick=180+200*cycle+5*n
        if tick>=3600: continue
        for offset in (0,-6.2831855/5,-2.513274,-3.769911,-5.026548):
            expected.append((tick,'red',5,-(0.628319+n*0.20944+offset)*180/math.pi,16))
        for offset in (0,-3.1415927):
            expected.append((tick,'blue',2,-(2.356194-n*0.314159+offset)*180/math.pi,20))
rows=list(csv.DictReader((LOG/'native-schedule.csv').open()))
assert len(rows)==len(expected)==3836
for row,(t,c,s,a,r) in zip(rows,expected):
    assert int(row['tick'])==t and row['color']==c
    assert float(row['speed'])==s and abs(float(row['angle'])-a)<1e-7 and float(row['radius'])==r
for color,index in [('red',168),('blue',169)]:
    source=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites')/f'etama.entry1.sprite{index}.png'
    assert (MOD/f'th08-large-{color}.png').read_bytes()==source.read_bytes()
result={'passed':True,'difficulty':'Lunatic','schedule_comparisons':3836,'blue':1096,'red':2740,'blue_speed':2,'red_speed':5,'first_cycle':224,
    'source':str(REF),'source_sha256':hashlib.sha256(REF.read_bytes()).hexdigest(),
    'bullet_type':10,'bullet_sprite_indices':{'red':168,'blue':169},'sprite_size':[64,64],'blend':'mul+add','collision_half_extents':[12,12],
    'native_original_movement_parity_verified':False}
(LOG/'static-result.json').write_text(json.dumps(result,indent=2)+'\n')
(MOD/'reference.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: 3836 Lunatic emission records and native TH08 type10 large-orb sprites match.')
