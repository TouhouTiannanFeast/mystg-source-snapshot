"""Compare the actual Lua-exported schedule to pinned TH10 Easy ECL constants."""
from pathlib import Path
import csv, hashlib, json, math, re
ROOT=Path('G:/MySTG')
MOD=ROOT/'aex-0.8.22/game/mod/MystiaAyaNon3EasyLarge'
REF=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage04.named.utf8.txt')
text=REF.read_text(encoding='utf-8')
def body(name):
    return re.search(r'void '+name+r'\([^)]*\)\s*\{(.*?)\n\}',text,re.S)[1]
blue,red,base,ring=map(body,('Boss3_at2','Boss3_at3','Boss3','Boss2_at'))
assert '$E = 12;' in ring and 'moveRand(40, 0, 4.0f);' in base
assert '+80: //260' in base and 'goto Boss3_708 @ 120;' in base
def initial(src):
    angle=float(re.search(r'%A = ([\d.]+)f;',src)[1])
    radius=float(re.search(r'%C = ([\d.]+)f;',src)[1])
    speed=float(re.search(r'diffF\(%B, [^,]+, ([\d.]+)f',src)[1])
    steps=int(re.search(r'\$D = (\d+);',src)[1])
    return angle,radius,speed,steps
ba,br,bs,bn=initial(blue); ra,rr,rs,rn=initial(red)
assert (bs,rs,bn,rn)==(1,3,32,32)
expected=[]
for cycle in range(18):
    for n in range(32):
        t=180+200*cycle+5*n
        if t>=3600: continue
        for offset in (0,): expected.append((t,'red',rs,-(ra+n*0.314159+offset)*180/math.pi,rr))
        for offset in (0,): expected.append((t,'blue',bs,-(ba-n*0.314159+offset)*180/math.pi,br))
actual=list(csv.DictReader((ROOT/'work/logs/mystia-aya-easy-large/native-schedule.csv').open()))
assert len(actual)==len(expected)==1096
for row,wanted in zip(actual,expected):
    t,c,s,a,r=wanted
    assert int(row['tick'])==t and row['color']==c
    assert abs(float(row['speed'])-s)<1e-8 and abs(float(row['angle'])-a)<1e-7 and float(row['radius'])==r
assert sum(r['color']=='blue' for r in actual)==548
assert sum(r['color']=='red' for r in actual)==548
source_data={'difficulty':'Easy','behavior_source':str(REF),'source_sha256':hashlib.sha256(REF.read_bytes()).hexdigest(),
    'original_subs':['Boss3','Boss3_at2','Boss3_at3','Boss2_at'],'replacement':'12 ring bullets -> one native TH08 type10 large orb at their arithmetic center',
    'frames':3600,'first_emission':180,'cycle':200,'volley_steps':32,'interval':5,'blue_speed':bs,'red_speed':rs,
    'native_original_parity_verified':False,'limits':['AEX player, damage, bullet fade and scoring','AEX RNG differs from original seed','moveRand polar interpolation independently implemented; frame parity not proven'],
    'sprite_source':'G:/TouHou/[th08] 东方永夜抄 (日文版)/th08.dat : stg2enm.anm',
    'sprite_sha256':hashlib.sha256((MOD/'mystia-local.png').read_bytes()).hexdigest(),
    'bullet_type':10,'bullet_sprite_indices':{'red':168,'blue':169},'bullet_collision_half_extents':[12,12],'bullet_collision_shape':'rectangle'}
for color,index in [('red',168),('blue',169)]:
    source=Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/20261010-all-works/th08_9d7edf43b8/sprites')/f'etama.entry1.sprite{index}.png'
    assert (MOD/f'th08-large-{color}.png').read_bytes()==source.read_bytes(), 'native sprite changed'
(MOD/'reference.json').write_text(json.dumps(source_data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
result={'schedule_comparisons':len(actual),'blue':548,'red':548,'first_cycle':64,'passed':True}
(ROOT/'work/logs/mystia-aya-easy-large/static-result.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: all 1096 Lua emission records match pinned Easy ECL schedule, colors, speeds and angles.')
