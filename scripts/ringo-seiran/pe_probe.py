from pathlib import Path
import struct, sys
sys.path.insert(0, 'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
from capstone import Cs, CS_ARCH_X86, CS_MODE_32
b=Path('G:/TouHou/MLforDanmu/data/local/touhou/th165-20261026/native-original/th165.exe').read_bytes()
p=struct.unpack_from('<I',b,0x3c)[0];o=p+24
base=struct.unpack_from('<I',b,o+28)[0];size=struct.unpack_from('<H',b,p+20)[0]
sections=[]
for j in range(struct.unpack_from('<H',b,p+6)[0]):
 s=o+size+j*40;vs,va,n,r=struct.unpack_from('<4I',b,s+8);sections.append((base+va,n,r))
def va(off):
 for a,n,r in sections:
  if r<=off<r+n:return a+off-r
def off(a):
 for v,n,r in sections:
  if v<=a<v+n:return r+a-v
for ty,anm,sprite in ((1,36,0),(6,41,96)):
 pattern=struct.pack('<4I',anm,sprite,323,336);i=b.find(pattern)
 print('TYPE',ty,'record',hex(va(i)) if i>=0 else 'not found')
 if i>=0:print('sprite0',struct.unpack_from('<I',b,i+4)[0],'sprite4',struct.unpack_from('<I',b,i+4+4*16)[0],'radius',struct.unpack_from('<f',b,i+0x104)[0])
md=Cs(CS_ARCH_X86,CS_MODE_32);md.skipdata=True
if len(sys.argv)>1:
 for arg in sys.argv[1:]:
  a,n=map(lambda x:int(x,0),arg.split(':'));i=off(a)
  for ins in md.disasm(b[i:i+n],a):print(hex(ins.address),ins.mnemonic,ins.op_str)
else:
 a,n,r=sections[0];code=list(md.disasm(b[r:r+n],a))
 for j,ins in enumerate(code):
  if ins.mnemonic in ('cmp','test') and ins.op_str.endswith(', 0x80000'):
   print('EX velocity-add candidate')
   for k in code[max(0,j-3):j+13]:print(hex(k.address),k.mnemonic,k.op_str)
