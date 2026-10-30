from pathlib import Path
import struct,sys
sys.path.insert(0,'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
from capstone import Cs, CS_ARCH_X86, CS_MODE_32
p=Path('G:/TouHou/[th15]+东方绀珠传+(汉化版+日文版)/th15.exe')
b=p.read_bytes(); pe=struct.unpack_from('<I',b,0x3c)[0]; opt=pe+24
ib=struct.unpack_from('<I',b,opt+28)[0]; ns=struct.unpack_from('<H',b,pe+6)[0]; sz=struct.unpack_from('<H',b,pe+20)[0]
sections=[]
for j in range(ns):
 s=opt+sz+j*40;vs,va,rs,raw=struct.unpack_from('<4I',b,s+8);sections.append((ib+va,rs,raw))
def off(a):
 for va,n,r in sections:
  if va<=a<va+n:return r+a-va
 raise ValueError(hex(a))
md=Cs(CS_ARCH_X86,CS_MODE_32);md.skipdata=True
if len(sys.argv)>1 and sys.argv[1]=='tables':
 for ty in (1,6,18):
  a=0x4e0f60+ty*0x114
  print('TYPE',ty,'base',hex(a),'anm',struct.unpack_from('<I',b,off(a))[0], 'radius/sprite/etc',struct.unpack_from('<f3I',b,off(a+0x104)))
  print('SPRITES',struct.unpack_from('<8I',b,off(a+0x10)))
  print('RECORD',struct.unpack_from('<21I',b,off(a)))
 for a in (0x4d0060,0x4cff68,0x4cff3c):print('FLOAT',hex(a),struct.unpack_from('<f',b,off(a))[0])
 print('STEP MODES', [hex(x) for x in struct.unpack_from('<8I',b,off(0x41c56c))])
 print('AIM MODES', [hex(x) for x in struct.unpack_from('<13I',b,off(0x41b114))])
 print('FUNC1',hex(struct.unpack_from('<I',b,off(0x4caf5c))[0]))
 for op in (412,607,632):
  idx=b[off(0x42de78)+op-300];a=struct.unpack_from('<I',b,off(0x42dbcc)+idx*4)[0]
  print('OP',op,hex(a))
  for i in md.disasm(b[off(a):off(a)+110],a):print(hex(i.address),i.mnemonic,i.op_str)
elif len(sys.argv)>1:
 for arg in sys.argv[1:]:
  a,n=map(lambda x:int(x,0),arg.split(':'))
  for i in md.disasm(b[off(a):off(a)+n],a):print(hex(i.address),i.mnemonic,i.op_str)
else:
 va,n,r=sections[0]; code=list(md.disasm(b[r:r+n],va))
 for j,i in enumerate(code):
  if any(v in i.op_str for v in ('0x4e0f','0x4e10','0x4ca6','0x4ca7')):
   print(hex(i.address),i.mnemonic,i.op_str)
