"""Inventory only the selected Suwako source routines; never alter source archives."""
from pathlib import Path
import re, json, hashlib

ROOT=Path('G:/MySTG')
BASE=Path('G:/TouHou/MLforDanmu/data/local/touhou')
OUT=ROOT/'aex-0.8.22/game/mod/MySTG/stages/suwako5'
TH10=BASE/'20261006-022841/th10_local-original-archive-candidate_1fb1d0ffe341/raw'
DS=BASE/'th125-20261026/th125_local-original-archive-candidate_18fcf64c0a3e/raw'
ISC=BASE/'th143-20261012/th143_local-original-archive-candidate_71b4b7025d8e/raw'

def functions(text):
    return {m[1]:{'params':re.findall(r'var (\w+)',m[2]),'body':m[3]} for m in re.finditer(r'void (\w+)\(([^)]*)\)\s*\{(.*?)\n\}',text,re.S)}

def collect(path,entries):
    text=path.read_text(encoding='utf-8-sig'); fs=functions(text); seen=set(); todo=list(entries)
    while todo:
        name=todo.pop()
        if name in seen: continue
        if name not in fs: continue
        seen.add(name); body=fs[name]['body']
        todo+=re.findall(r'@(\w+)\(',body)
        todo+=re.findall(r'enmCreate\w*\("([^"]+)"',body)
    return {n:fs[n] for n in sorted(seen)}, {'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    specs=[('th10',TH10/'stage07.named.utf8.txt',[f'BossCard{i}' for i in [1,2,3,4,5,6,8,9,10]]+[f'Boss{i}' for i in [1,2,3,4,5,6,8]])]
    specs += [('ds'+c,DS/f'ecl23_{c}.named.utf8.txt',['Boss']) for c in 'abcd']
    specs += [('isc'+c,ISC/f'ec_{c}.named.utf8.txt',['AttackFunc']) for c in ['0902','0906']]
    report={}; calls={}; sources={}
    for key,path,entries in specs:
        fs,source=collect(path,entries);sources[key]=source
        report[key]=fs
        for name,f in fs.items():
            for cmd in re.findall(r'^\s*(\w+)\(',f['body'],re.M): calls.setdefault(cmd,set()).add(key)
    (OUT/'source-audit.json').write_text(json.dumps({'sources':sources,'functions':report},ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({k:sorted(v) for k,v in sorted(calls.items())},indent=2))
    print('functions', {k:len(v) for k,v in report.items()})

if __name__=='__main__':main()
