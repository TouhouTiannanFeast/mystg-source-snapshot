"""Read-only native evidence helper for DS motion and sprite fields."""
from pathlib import Path
import struct,sys
sys.path.insert(0,'G:/MySTG/scripts/milk-honey/deps')
import capstone
P=Path('G:/TouHou/MLforDanmu/data/local/touhou/th125-20261026/native-original/th125.exe');raw=P.read_bytes()
pe=struct.unpack_from('<I',raw,60)[0];ss=pe+24+struct.unpack_from('<H',raw,pe+20)[0]
sections=[struct.unpack_from('<4I',raw,ss+40*i+8)for i in range(struct.unpack_from('<H',raw,pe+6)[0])]
def offset(va):
 for vs,v,rs,off in sections:
  if v<=va-0x400000<v+max(vs,rs):return off+va-0x400000-v
 raise ValueError(hex(va))
def va(off):
 for vs,v,rs,r in sections:
  if r<=off<r+rs:return off-r+v+0x400000
 raise ValueError(hex(off))
def dump(addr,size):
 c=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
 for i in c.disasm(raw[offset(addr):offset(addr)+size],addr):print(hex(i.address),i.mnemonic,i.op_str)
if __name__=='__main__':
 if len(sys.argv)>1:dump(int(sys.argv[1],0),int(sys.argv[2],0))
 else:
  for n in [-9971,-10000]:
   for typ in ['i','f']:
    b=struct.pack('<'+typ,n);start=0
    while True:
     p=raw.find(b,start)
     if p<0:break
     print(n,typ,hex(va(p)));start=p+4
