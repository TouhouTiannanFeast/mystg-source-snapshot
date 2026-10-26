from pathlib import Path
import re,json,hashlib,sys,shutil,subprocess,struct
ROOT=Path('G:/MySTG');OUT=ROOT/'aex-0.8.22/game/mod/MySTG/stages/th18_stage5';OUT.mkdir(parents=True,exist_ok=True)
SRC=Path('G:/TouHou/MLforDanmu/data/local/touhou/20261006-022841/th18_local-original-archive-candidate_3949e7c01bde/raw')
sys.path.insert(0,str(ROOT/'scripts/suwako5'));from source_audit import functions
import build as B

def normal(body):
 active=True;stack=[];out=[]
 for line in body.splitlines():
  s=line.strip()
  if s.startswith('!'):active=s=='!*' or 'N' in s[1:];continue
  if not active:continue
  m=re.fullmatch(r'(.+);',s)
  if m and not any(s.startswith(x) for x in ('var ','return','goto ','if ','unless ','@')) and not re.match(r'\w+\(',s) and not re.match(r'[$%]\w+\s*=',s):stack.append(m[1]);continue
  refs=re.findall(r'\[-(\d+)(?:\.0f)?\]',s)
  if refs:
   s=re.sub(r'\[-(\d+)(?:\.0f)?\]',lambda m:'('+stack[-int(m[1])]+')',s)
   del stack[-max(map(int,refs)):]
  out.append(s)
 assert not stack,stack
 return '\n'.join(out)
fs={};sources=[]
for n in ['st04','st04mbs','default']:
 p=SRC/(n+'.named.utf8.txt');fs.update(functions(p.read_text(encoding='utf-8-sig')));sources.append({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
entries=['MainFront','MainLatter','MBoss','MBossDead','MBossEscape']
seen=set();todo=entries.copy()
while todo:
 n=todo.pop()
 if n in seen or n in ['Ecl_EtBreak','Ecl_EtBreak_ni']:continue
 seen.add(n);f=fs[n];todo+=re.findall(r'@(\w+)\(',f['body']);todo+=re.findall(r'enmCreate\w*\("([^"]+)"',f['body'])
fs={n:fs[n] for n in sorted(seen)}
for f in fs.values():
 f['body']=normal(f['body'])
 f['body']=re.sub(r'\$GI(\d+) = ([^;]+);',r'nop();',f['body'])
fs['BossItemPhase']['params']=['A','B','C','D']
# Output-register instructions cannot be passed as evaluated values.
for f in fs.values():
 f['body']=re.sub(r'enmAlive\((\$\w+), ([^;]+)\);',r'\1 = R.alive(\2);',f['body'])
 f['body']=re.sub(r'floatTime\((\d+), ([%$]\w+), ([^;]+)\);',lambda m:'setFloatTween('+m[1]+', "'+m[2]+'", '+m[3]+');',f['body'])
chunks=['-- Source-generated TH18 stage4 Normal route; no original boss routines.','Th18Stage5Programs={th18={}};local R=Th18Stage5Runtime;local P=Th18Stage5Programs.th18'];cmd=set()
for n,f in fs.items():
 c,k=B.lower(f);c=re.sub(r'R.value\(a,"(MISS_COUNT|BOMB_COUNT|CAPTURE)"\)=',r'R.globals["\1"]=',c);chunks.append('P['+json.dumps(n)+']='+c);cmd|=k
(OUT/'programs.lua').write_text('\n'.join(chunks).replace('Suwako5','Th18Stage5'),encoding='utf-8')
(OUT/'route-source.json').write_text(json.dumps({'sources':sources,'difficulty':'Normal','functions':fs,'commands':sorted(cmd)},ensure_ascii=False,indent=2),encoding='utf-8')
print('GENERATED',len(fs),sorted(cmd))
