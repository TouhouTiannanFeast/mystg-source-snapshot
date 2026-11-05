"""Copy the user's current encounter; only local HP/path/exports adaptations."""
from pathlib import Path
import json,shutil,hashlib
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/TH11Stage6Normal';S=R/'aex-0.8.22/game/mod/MilkHoney'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for p in (S/'art').glob('*.png'):shutil.copy2(p,M/'milk/art'/p.name)
shutil.copy2(S/'pattern.lua',M/'milk/pattern.lua')
n=(S/'nonspell.lua').read_text(encoding='utf-8')
assert 'hp=8000' in n and "60,8000,{0,0,0}" in n
n=n.replace('hp=8000','hp=12000',1).replace("60,8000,{0,0,0}","60,N.hp,{0,0,0}",1)
n=n.replace('duration=3600','duration=2400',1).replace('60,N.hp,{0,0,0}','40,N.hp,{0,0,0}',1)
n=n.replace("'art/ofuda-'","'milk/art/ofuda-'").replace('setting.milk_test','setting.th11s6_milk_test')
n=n.replace('then Del(self) end','then self.offscreenRemoval=true;Del(self) end')
n=n.replace('N.owned[self]=nil;bullet.del(self)','N.owned[self]=nil;if not self.offscreenRemoval then bullet.del(self)end')
(M/'milk/nonspell.lua').write_text(n,encoding='utf-8')
s=(S/'root.lua').read_text(encoding='utf-8');s=s[s.index('local P=MilkHoneyPattern'):s.index("stage.group.New('Extra'")]
s=s.replace("'art/sprite'","'milk/art/sprite'")
assert '50,2250,{0,0,0}' in s
s=s.replace('50,2250,{0,0,0}','50,24000,{0,0,0}',1)
s=s.replace('    MilkHoneyNonspell.clean()','    MilkHoneyNonspell.clean();TH11S6Suwako.clean()',1)
s=s.replace('card.init=function(o)','card.init=function(o)\n    TH11S6Suwako.startSpell(o,D)',1)
s=s.replace("    Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y,0,1.3,1.3)",'    TH11S6Suwako.body(self)')
s=s.replace('local Suwako=Class(boss)','local nonspell=MilkHoneyNonspell.create(P)\nlocal Suwako=Class(boss)')
s=s.replace('{MilkHoneyNonspell.create(P),card}','{nonspell,card}')
s=s.replace('MilkHoneyState=D','TH11S6MilkState=D').replace('setting.milk_test','setting.th11s6_milk_test')
s=s.replace('then Del(self) end','then self.offscreenRemoval=true;Del(self) end')
s=s.replace('D.owned[self]=nil;bullet.del(self)','D.owned[self]=nil;if not self.offscreenRemoval then bullet.del(self)end')
s=s.replace("boss.init(self,0,128,'Suwako'", "boss.init(self,-224,256,'Suwako'")
s+='\nTH11S6Milk={Boss=Suwako,clean=clean,nonspell=nonspell,nonspellState=MilkHoneyNonspell,card=card,state=D}\n'
(M/'milk/boss.lua').write_text(s,encoding='utf-8')
(M/'source/milk-reference.json').write_text(json.dumps(dict(source_root=str(S/'root.lua'),source_root_sha256=sha(S/'root.lua'),source_nonspell=str(S/'nonspell.lua'),source_nonspell_sha256=sha(S/'nonspell.lua'),pattern_sha256=sha(S/'pattern.lua'),nonspell_hp=12000,hp=24000,duration=3000,nonspell_duration=2400,nonspell_included=True,adaptations='local HP12000/24000; nonspell40s; original Suwako body+frog visual; manual nonspell speed/color and spell logic preserved'),indent=2),encoding='utf-8')
print('Copied current MilkHoney nonspell -> spell; localHP12000/24000; times2400/3000; original Suwako+frog visual; manual data retained')
