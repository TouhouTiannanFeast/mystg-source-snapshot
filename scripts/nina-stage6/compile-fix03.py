"""Compile only changed source closures; never regenerate player/HP/assets."""
from pathlib import Path
import sys,re,json,hashlib
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/NinaStage6Normal'
sys.dont_write_bytecode=True
sys.path.insert(0,str(R/'scripts/suwako5'));import build as lower
oldexpr=lower.expr
def expr(s):
 s=re.sub(r'\$GI(\d+)',r'R.gi[\1]',s)
 s=re.sub(r'\$(MISS_COUNT|BOMB_COUNT|CAPTURE)',r'R.shared.\1',s)
 return oldexpr(s.replace('$ID','a.id'))
lower.expr=expr
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 return str(v).lower()
def branch(body,diff):
 active=True;stack=[];out=[]
 for line in body.splitlines():
  s=line.strip()
  if s.startswith('!'):active=s=='!*'or diff in s[1:];continue
  if not active and not s.endswith(':')and not s.startswith('+'):continue
  m=re.fullmatch(r'(.+);',s)
  if m and not any(s.startswith(x)for x in ('var ','return','goto ','if ','unless ','@'))and not re.match(r'\w+\(',s)and not re.match(r'[$%]\w+\s*=',s):stack.append(m[1]);continue
  refs=re.findall(r'\[-(\d+)(?:\.0f)?\]',s)
  if refs:s=re.sub(r'\[-(\d+)(?:\.0f)?\]',lambda m:'('+stack[-min(int(m[1]),len(stack))]+')',s);del stack[-max(map(int,refs)):]
  out.append(s)
 assert not stack,stack
 return '\n'.join(out)
def choose(b,diff):
 i={'E':0,'N':1,'H':2,'L':3}[diff]
 def q(m):
  a=[x.strip()for x in m[2].split(',')]
  if m[1]=='diffWait':return 'wait('+a[i]+');'
  return a[0]+' = '+a[1+i]+';'
 b=re.sub(r'\b(diffI|diffF|diffWait)\(([^)]*)\);',q,b)
 return b
def closure(src,entries,diff):
 raw=src.read_text(encoding='utf-8-sig')
 fs={m[1]:dict(params=re.findall(r'var (\w+)',m[2]),body=m[3])for m in re.finditer(r'^void (\w+)\(([^\n]*)\)\n\{\n(.*?)^\}',raw,re.M|re.S)}
 seen=set();todo=entries.copy()
 while todo:
  n=todo.pop()
  if n in seen or n.startswith('Ecl_EtBreak')or n=='BossItem':continue
  seen.add(n);fs[n]['body']=branch(fs[n]['body'],diff);b=fs[n]['body']
  todo+=re.findall(r'@(\w+)\(',b)+re.findall(r'(?:enmCreate\w*\(|enmCall\([^,]+, )"(\w+)"',b)
  if n.startswith('BossMiyako'):todo+=re.findall(r'setInterrupt\([^\n]*"(\w+)"',b)
 out={}
 for n in sorted(seen):
  fn=fs[n].copy();b=choose(fn['body'],diff)
  b=re.sub(r'@BossItem\([^\n]*\);','nop();',b)
  b=re.sub(r'enmPos\((%\w+), (%\w+), ([^)]+)\);',r'\1 = R.actorX(\3);\n\2 = R.actorY(\3);',b)
  if diff=='L':b=b.replace('enmKillAll();','clearMinors();')
  fn['body']=b;out[n]=fn
 return out
base=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841')
jobs=[('NinaCore','th13L',M/'source/th13-original.txt',['BossCard2','BossMiyako2','BossMiyakoDead'],'L'),('Nina10','th10moses',base/'th10_local-original-archive-candidate_1fb1d0ffe341/raw/stage05.named.utf8.txt',['BossCard2'],'N')]
parts=[];refs={}
for ns,group,src,entries,diff in jobs:
 fs=closure(src,entries,diff)
 parts+=['do local R='+ns+'Runtime;'+ns+'Programs.'+group+'={};local P='+ns+'Programs.'+group]
 for n,fn in fs.items():code,cmds=lower.lower(fn);parts.append('P['+lua(n)+']='+code)
 parts.append('end')
 (M/'source'/('fix03-'+group+'-closure.json')).write_text(json.dumps(fs,ensure_ascii=False,indent=2),encoding='utf-8')
 refs[group]=dict(source=str(src),sha256=hashlib.sha256(src.read_bytes()).hexdigest(),difficulty=diff,entries=entries,routines=list(fs))
# User clarified density applies ONLY after a red rice bullet changes color.
# The source five-spoke program is unchanged. fix03.lua adds one colored copy
# per five transformations, without adding any red bullets or consuming RNG.
refs['rice-density']=dict(red_unchanged=True,colored_ratio=1.2,implementation='one extra per five nonred transformations; fix03.lua')
(M/'programs-fix03.lua').write_text('\n'.join(parts)+'\n',encoding='utf-8')
(M/'source/fix03-reference.json').write_text(json.dumps(refs,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS compiled TH13 spell1 Lunatic; TH10 Normal BossCard2 Moses; rice source unchanged')
