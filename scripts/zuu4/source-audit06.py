"""Read-only original PE/SHT probes; all output stays in the encounter audit."""
from pathlib import Path
import struct, sys
sys.path.insert(0,'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
from capstone import Cs, CS_ARCH_X86, CS_MODE_32

p=Path('G:/TouHou/MLforDanmu/data/local/touhou/th20-20261027/native-original/th20.exe')
b=p.read_bytes(); pe=struct.unpack_from('<I',b,0x3c)[0]; opt=pe+24
ib=struct.unpack_from('<I',b,opt+28)[0]; ns=struct.unpack_from('<H',b,pe+6)[0]; sz=struct.unpack_from('<H',b,pe+20)[0]
sections=[]
for i in range(ns):
 s=opt+sz+i*40; vs,va,rs,raw=struct.unpack_from('<4I',b,s+8);sections.append((ib+va,rs,raw))
def off(va):
 for a,n,r in sections:
  if a<=va<a+n:return r+va-a
 raise ValueError(hex(va))
md=Cs(CS_ARCH_X86,CS_MODE_32)
md.skipdata=True
def dis(a,n):return list(md.disasm(b[off(a):off(a)+n],a))
if len(sys.argv)>1:
 for arg in sys.argv[1:]:
  a,n=[int(v,0) for v in arg.split(':')]
  for i in dis(a,n):print(hex(i.address),i.mnemonic,i.op_str)
else:
 for start,size,raw in sections:
  if start!=0x401000:continue
  code=list(md.disasm(b[raw:raw+size],start))
  for j,i in enumerate(code):
   if 0x47c700<=i.address<0x47dd30 and ('0x1000' in i.op_str or '+ 0x44]' in i.op_str):
    print('BULLET USE',hex(i.address))
    for x in code[max(0,j-5):j+10]:print(hex(x.address),x.mnemonic,x.op_str)
  for j,i in enumerate(code):
   if ('0x51' in i.op_str or '0x50' in i.op_str) and i.mnemonic=='push' and False:pass
 for name in ('pl00','pl01'):
  p=p.parents[1]/'auxiliary-raw'/f'{name}.sht' if name=='pl00' else p.with_name('pl01.sht')
  s=p.read_bytes();print('SHT',p,len(s))
  for o in range(0xc0,0x400,16):print(hex(o),struct.unpack_from('<4I',s,o))
