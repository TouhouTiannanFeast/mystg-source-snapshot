from pathlib import Path
import sys,struct
sys.path.insert(0,str(Path(__file__).parent/'deps'));import capstone
b=Path('G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/th10.exe').read_bytes();p=struct.unpack_from('<I',b,60)[0];o=p+24+struct.unpack_from('<H',b,p+20)[0]
def read(va,size):
 for i in range(struct.unpack_from('<H',b,p+6)[0]):
  vs,v,rs,raw=struct.unpack_from('<4I',b,o+i*40+8);r=va-0x400000
  if v<=r<v+max(vs,rs):return b[raw+r-v:raw+r-v+size]
c=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
for start,size in [(0x406160,112),(0x406b9b,0xb8)]:
 for i in c.disasm(read(start,size),start):
  print(hex(i.address),i.mnemonic,i.op_str)
  import re
  for va in re.findall(r'\[0x([0-9a-f]+)\]',i.op_str):
   va=int(va,16)
   if 0x470000<=va<0x480000: print(' float constant:',struct.unpack('<f',read(va,4))[0])
for t,col in [(18,0),(3,8)]:print('TYPE',t,'SCRIPT',struct.unpack('<i',read(0x474170+t*4,4))[0]+col,'COLLISION WIDTH',struct.unpack('<f',read(0x4741e0+t*4,4))[0])
