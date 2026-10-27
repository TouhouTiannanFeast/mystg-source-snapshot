"""Read-only indexed-dispatch evidence from the supplied TH20 executable."""
from pathlib import Path
import sys,struct,json
sys.path.insert(0,'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
from capstone import Cs,CS_ARCH_X86,CS_MODE_32
p=Path('G:/TouHou/MLforDanmu/data/local/touhou/th20-20261027/native-original/th20.exe')
b=p.read_bytes();pe=struct.unpack_from('<I',b,0x3c)[0];opt=pe+24;imagebase=struct.unpack_from('<I',b,opt+28)[0]
ns=struct.unpack_from('<H',b,pe+6)[0];sz=struct.unpack_from('<H',b,pe+20)[0];sections=[]
for i in range(ns):
 s=opt+sz+i*40;vsize,va,rawsz,raw=struct.unpack_from('<4I',b,s+8);sections.append((imagebase+va,rawsz,raw))
def off(va):
 for start,size,raw in sections:
  if start<=va<start+size:return raw+va-start
 raise ValueError(hex(va))
def va(o):
 for start,size,raw in sections:
  if raw<=o<raw+size:return start+o-raw
 raise ValueError(o)
md=Cs(CS_ARCH_X86,CS_MODE_32)
for pos in range(len(b)-7):
 if b[pos:pos+2]==b'\xff\x24' and b[pos+2] in [0x85,0x8d,0x95,0x9d,0xa5,0xad,0xb5,0xbd]:
  table=struct.unpack_from('<I',b,pos+3)[0]
  try:
   to=off(table);targets=struct.unpack_from('<40I',b,to)
   if not all(0x400000<=t<0x600000 for t in targets[:34]):continue
   context=list(md.disasm(b[pos-24:pos+7],va(pos-24)))
   print('DISPATCH',hex(va(pos)),hex(table),[(hex(x.address),x.mnemonic,x.op_str) for x in context])
   print('TARGETS',[(i,hex(targets[i])) for i in [0,1,7,12,21,25,30,33]])
  except ValueError:continue
