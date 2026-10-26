"""Lower selected decompiled ECL to Lua 5.1 instruction tables, retaining timelines."""
from pathlib import Path
import re,json
import source_audit as S

def q(s):return json.dumps(s,ensure_ascii=False)

def expr(s):
    s=s.strip()
    # String literals must not pass through register/operator rewriting.
    strings=[]
    def save(m):strings.append(m[0]);return f'ZZSTRING{len(strings)-1}ZZ'
    s=re.sub(r'"(?:[^"\\]|\\.)*"',save,s)
    s=re.sub(r'(\d+(?:\.\d*)?(?:e[+-]?\d+)?)f\b',r'\1',s,flags=re.I)
    s=re.sub(r'\$([A-Z])--',lambda m:'R.dec(e.i,'+q(m[1])+')',s)
    def reg(m):
        sig,n=m[1],m[2]
        if len(n)==1:return ('e.i.' if sig=='$' else 'e.f.')+n
        if re.fullmatch('[IF][0-9]+',n):return ('a.i' if n[0]=='I' else 'a.f')+'['+n[1:]+']'
        return 'R.value(a,'+q(n)+')'
    s=re.sub(r'([$%])([A-Z][A-Z_0-9]*)',reg,s)
    s=s.replace('&&',' and ').replace('||',' or ').replace('!=','~=')
    s=re.sub(r'\b_f\(', 'R.float(',s)
    s=re.sub(r'\b_S\(', 'math.floor(',s)
    s=re.sub(r'\b(sin|cos|sqrt|atan2)\(',r'math.\1(',s)
    for i,t in enumerate(strings):s=s.replace(f'ZZSTRING{i}ZZ',t)
    return s

def lower(fn):
    ops=[];labels={};t=0;commands=set()
    for raw in fn['body'].splitlines():
        s=raw.strip()
        if not s or s.startswith('var '):continue
        m=re.fullmatch(r'\+(\d+):\s*//(\d+)',s)
        if m:t=int(m[2]);continue
        if s.endswith(':'):labels[s[:-1]]=len(ops)+1;continue
        if s=='return;':ops.append((t,'return',None));continue
        m=re.fullmatch(r'(?:(if|unless) \((.*)\) )?goto (\w+) @ (-?\d+);',s)
        if m:
            cond='true' if not m[1] else 'R.truth('+expr(m[2])+')'
            if m[1]=='unless':cond='not ('+cond+')'
            ops.append((t,'jump',(cond,m[3],int(m[4]))));continue
        m=re.fullmatch(r'@(\w+)\((.*)\)(?: async(?: (\d+))?)?;',s)
        if m:
            async_=bool(re.search(r'\) async',s)); arg=expr(m[2]);cmd='R.spawn' if async_ else 'R.call'
            code=f'{cmd}(a,{q(m[1])},{{{arg}}}'+(','+str(m[3] or -1) if async_ else '')+')'
            ops.append((t,'do',code));continue
        m=re.fullmatch(r'([$%][A-Z][A-Z0-9_]*) = (.*);',s)
        if m:
            value=expr(m[2])
            if m[1].startswith('$'):value='R.integer('+value+')'
            ops.append((t,'do',expr(m[1])+'='+value));continue
        m=re.fullmatch(r'(\w+)\((.*)\);',s)
        if m:
            cmd,args=m[1],m[2];commands.add(cmd)
            if cmd=='validRad':code=expr(args)+'=R.rad('+expr(args)+')'
            elif cmd=='circlePos':
                vals=args.split(',');code=expr(vals[0])+','+expr(vals[1])+'=R.polar('+expr(','.join(vals[2:]))+')'
            elif cmd=='diffI':
                vals=args.split(',');code=expr(vals[0])+'='+expr(vals[2]) # Extra uses its branch, same as Normal here.
            else:code='R.command(a,e,'+q(cmd)+',{'+expr(args)+'})'
            ops.append((t,'do',code));continue
        raise ValueError('Unparsed ECL: '+s)
    result=[]
    for tm,kind,data in ops:
        if kind=='return':code='return 0'
        elif kind=='jump':
            cond,label,target=data;code=f'if {cond} then return {labels[label]},{target} end'
        else:code=data
        result.append('{t='+str(tm)+',run=function(a,e) '+code+' end}')
    return '{params={'+','.join(q(v) for v in fn['params'])+'},ops={\n'+',\n'.join(result)+'\n}}',commands

def main():
    S.main();audit=json.loads((S.OUT/'source-audit.json').read_text(encoding='utf-8'));chunks=['-- Generated from hash-pinned source. Do not hand edit.','Suwako5Programs={}; local P=Suwako5Programs; local R=Suwako5Runtime']
    calls=set()
    for group,fs in audit['functions'].items():
        chunks.append('P['+q(group)+']={}')
        for name,fn in fs.items():
            code,cmd=lower(fn);calls|=cmd;chunks.append('P['+q(group)+']['+q(name)+']='+code)
    (S.OUT/'programs.lua').write_text('\n'.join(chunks)+'\n',encoding='utf-8')
    (S.OUT/'command-inventory.json').write_text(json.dumps(sorted(calls),indent=2),encoding='utf-8')
    print('LOWERED',sum(len(v) for v in audit['functions'].values()),'routines')
    print('REGISTERS',sorted(set(re.findall(r'[$%]([A-Z][A-Z0-9_]*)',json.dumps(audit)))))

if __name__=='__main__':main()
