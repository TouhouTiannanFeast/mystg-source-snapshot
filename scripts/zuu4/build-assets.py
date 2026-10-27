"""Copy only source-original HSoB assets and pin the selected attack sources."""
from pathlib import Path
import json,re,hashlib,shutil
ROOT=Path('G:/MySTG')
HS=Path('G:/TouHou/MLforDanmu/data/local/danmakufu/20261018-added/hsob')
TH=Path('G:/TouHou/MLforDanmu/data/local/touhou/th20-20261027')
OUT=ROOT/'aex-0.8.22/game/mod/MySTG/stages/zuu4'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 (OUT/'art').mkdir(exist_ok=True);(OUT/'source').mkdir(exist_ok=True)
 sources=[]
 def copy(p,d):
  shutil.copyfile(p,d);sources.append({'path':str(p),'sha256':digest(p),'copy':str(d.relative_to(OUT))})
 readable=HS/'readable/script/th_hsob'
 for f in ['06b_Attack01','06b_Attack02','06b_Spell01','06b_Spell02','06b_Spell07','06b_plural','lib_Horou','lib_HorouEffect','lib_HorouEffect01','lib_HorouEffect02','lib_HorouEffect03','lib_HorouEffect04']:
  copy(readable/f'stg/stage6/boss/{f}.dnh.utf8.txt',OUT/f'source/{f}.dnh.txt')
 th=next(TH.glob('th20_local*/raw/st06bs.named.utf8.txt'))
 copy(th,OUT/'source/th20-st06bs.ecl.txt')
 for f in ['bullet/lib_bullet_data.dnh','bullet/lib_bullet_data_ADD.dnh','bullet/lib_bullet_data_wing.dnh','bullet/lib_bullet_wing.dnh','bullet/lib_bullet.dnh','bullet/lib_bullet_ADD.dnh','bullet/MainLib.dnh','bullet/LaserLib.dnh','bullet/NuclearShot.dnh','bosslib/lib_Anime.dnh','bosslib/lib_BossUtil.dnh','lib_SystemAll.dnh','lib_Enemylibs.dnh','zakolib/lib_ZakoDraw.dnh','SpellData.dnh','loadlib/file_character.dnh']:
  copy(readable/('lib/'+f+'.utf8.txt'),OUT/('source/'+Path(f).name+'.txt'))
 # All shot art, including every TH20 type48 replacement, comes from this one HSoB sheet.
 imgs=json.loads((HS/'images.json').read_text(encoding='utf-8'))
 selected={}
 for name,pattern in [('bullet00','bullet00.png'),('wing','bullet_wing.png'),('zuu','dotHorou.png'),('nuclear','effect/nuclear.png'),('bird','zako/bird.png'),('wings','enm06a_eff.png')]:
  rows=[r for r in imgs if pattern.lower() in r['virtual_path'].lower() and r['origin']=='archive']
  assert len(rows)==1,(name,rows)
  r=rows[0];copy(HS/r['path'],OUT/f'art/{name}.png');selected[name]=r
 ids=set(range(369,385))|set(range(545,553))|set(range(353,361))|set(range(265,273))|{1,24,36,97,236,319,347,364,368,636,896,977}
 defs=[]
 for line in (HS/'shot-data.jsonl').read_text(encoding='utf-8').splitlines():
  r=json.loads(line)
  if r['definition_source'] not in ['script/th_hsob/lib/bullet/lib_bullet_data.dnh','script/th_hsob/lib/bullet/lib_bullet_data_ADD.dnh','script/th_hsob/lib/bullet/lib_bullet_data_wing.dnh'] or not r['id_expression'].isdigit() or int(r['id_expression']) not in ids:continue
  fields=r['authored_fields'];rect=r['sprite_crop']['rect'];collision=fields.get('collision',fields.get('Collision'))
  # Native parser computes the implicit radius from rcSrc, not animation frames.
  # An animation-only definition retains the constructor's zero rectangle.
  circ=list(map(float,re.findall(r'-?\d+(?:\.\d+)?',collision))) if collision else []
  radius=circ[0] if circ else max(3,min(rect[2]-rect[0],rect[3]-rect[1])//3-3) if 'rect' in fields else 3
  frames=[]
  for f in r.get('animation_frames',[]):
   frames.append({'duration':int(f['duration_expression']),'rect':list(map(int,f['rect_expression'].split(',')))})
  defs.append({'id':int(r['id_expression']),'rect':rect,'radius':radius,'offset':circ[1:3] if len(circ)==3 else [0,0],'frames':frames,'texture':'wing' if 'wing' in r['definition_source'] else 'bullet00','add':fields.get('render')=='ADD_ARGB','source':r})
 chunks=['-- Generated, HSoB original rectangles and circular collision.','Zuu4Art={shots={}}']
 for r in defs:
  frames=','.join('{duration=%d,rect={%s}}'%(f['duration'],','.join(map(str,f['rect']))) for f in r['frames'])
  chunks.append('Zuu4Art.shots[%d]={rect={%s},radius=%s,offset={%s},frames={%s},texture="%s",add=%s}'%(r['id'],','.join(map(str,r['rect'])),r['radius'],','.join(map(str,r['offset'])),frames,r['texture'],str(r['add']).lower()))
 (OUT/'art.lua').write_text('\n'.join(chunks)+'\n',encoding='utf-8')
 (OUT/'source-reference.json').write_text(json.dumps({'identity':{'boss':'BOSS_ID_HOROU','stage':6,'model':'character/Horou/dotHorou.png','spellIDs':[71,72,77]},'sources':sources,'shots':defs,'images':selected,'th20DiamondReplacement':'type48 -> HSoB BGW_CHRYSTAL_M 369..376; source collision circle radius4'},ensure_ascii=False,indent=2),encoding='utf-8')
 print('PINNED',len(sources),'sources;',len(defs),'shot definitions')
if __name__=='__main__':main()

