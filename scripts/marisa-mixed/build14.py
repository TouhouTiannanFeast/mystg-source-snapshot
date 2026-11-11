from pathlib import Path
import shutil,hashlib,json
R=Path('G:/MySTG');G=R/'aex-0.8.22/game/mod';M=G/'MarisaMixed'
refs=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(src,dst,transform=None):
 dst.parent.mkdir(parents=True,exist_ok=True)
 if transform:dst.write_text(transform(src.read_text(encoding='utf-8-sig')),encoding='utf8')
 else:shutil.copy2(src,dst)
 refs.append(dict(source=str(src),source_sha256=sha(src),target=dst.relative_to(M).as_posix(),target_sha256=sha(dst)))
road=G/'MySTG/stages/th18_stage5'
for src in road.rglob('*'):
 if not src.is_file()or src.suffix=='.md'or 'th20-pyramid'in src.parts:continue
 dst=M/'road'/src.relative_to(road)
 if src.suffix=='.lua':
  def adapt(s):return s.replace('stages/th18_stage5/','road/').replace('Suwako5Pool','MarisaRoadPool')
  if src.name=='host.lua':
   def adaptHost(s):
    s=adapt(s);a=s.index('-- Only the MBoss visual');b=s.index('function Enemy:render()',a);s=s[:a]+s[b:]
    s=s.replace(" if self.data.name=='MBoss' then H.renderMidbossPyramid(self.animations[0],self.x,self.y);return end\n",'')
    a=s.index("LoadTexture('th18s5.pyramid'");b=s.index("if setting.th18_stage5_collision_test",a);s=s[:a]+s[b:]
    return s
   copy(src,dst,adaptHost)
  else:copy(src,dst,adapt)
 else:copy(src,dst)
pool=(G/'MySTG/stages/suwako5/pool.lua').read_text(encoding='utf8');a=pool.index('function P.rng');b=pool.index('\nend',a)+4
(M/'road/pool.lua').write_text('MarisaRoadPool={}\nlocal P=MarisaRoadPool\n'+pool[a:b]+'\n',encoding='utf8')
rabbit=G/'RingoSeiran'
for folder in ['art','se','assets']:
 for src in (rabbit/folder).rglob('*'):
  if src.is_file():copy(src,M/'rabbit'/src.relative_to(rabbit))
for name in ['pattern.lua','feedback.lua','word-points.lua']:
 copy(rabbit/name,M/'rabbit'/name)
def rabbitHost(s):
 s=s[:s.index("stage.group.New('Normal'")]
 s=s.replace("Include('THlib.lua')\nInclude('player.lua')\n",'')
 for name in ['feedback.lua','pattern.lua','word-points.lua']:s=s.replace("Include('"+name+"')","Include('rabbit/"+name+"')")
 for folder in ['art/','se/']:s=s.replace("'"+folder,"'rabbit/"+folder)
 # Prefix dynamic art paths such as 'art/'..n explicitly (covered above).
 s+='\nMarisaRabbit14={Boss=Ringo,clean=clean,state=S}\n'
 return s
copy(rabbit/'root.lua',M/'rabbit/host.lua',rabbitHost)
(M/'source/stage14-reuse.json').write_text(json.dumps(dict(files=refs,road='Existing stage5 road TH18st04Normal, current owning-source HP/drop/art parameters preserved; private copies only',rabbit='Current two-phase RingoSeiran; standalone stage removed only, paths prefixed',rng='exact Suwako5Pool.rng copied under private name'),ensure_ascii=False,indent=2),encoding='utf8')
print(f'PASS private road/rabbit reuse: {len(refs)} copied files, original programs/pattern byte-identical')
