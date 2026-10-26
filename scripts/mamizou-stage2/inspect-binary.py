from pathlib import Path
import struct,sys
sys.path.insert(0,'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
from capstone import Cs,CS_ARCH_X86,CS_MODE_32
p=Path('G:/TouHou/[th13] 东方神灵庙 (汉化版+日文版)/th13.exe')
b=p.read_bytes();pe=struct.unpack_from('<I',b,60)[0];opt=pe+24
base=struct.unpack_from('<I',b,opt+28)[0]
sections=[]
for i in range(struct.unpack_from('<H',b,pe+6)[0]):
 s=opt+struct.unpack_from('<H',b,pe+20)[0]+i*40
 vs,va,sz,off=struct.unpack_from('<IIII',b,s+8)
 sections.append((base+va,off,sz))
def at(va,n):
 for start,off,sz in sections:
  if start<=va<start+sz:return b[off+va-start:off+va-start+n]
 raise ValueError(hex(va))
if __name__=='__main__':
 dec=Cs(CS_ARCH_X86,CS_MODE_32);dec.skipdata=True
 rows=list(dec.disasm_lite(at(0x401000,0x9a000),0x401000))
 out=[]
 for i,(a,n,m,o) in enumerate(rows):
  if (m=='fstp' and '+ 0xb90]' in o) or (m=='imul' and ('0x54' in o or '0x4c' in o)):
   out.extend(f'{a:08x} {m} {o}' for a,n,m,o in rows[max(0,i-15):i+16]);out.append('')
 Path('G:/MySTG/work/logs/mamizou-stage2/binary-windows.txt').write_text('\n'.join(out))
 print('\n'.join(out[:140]))
