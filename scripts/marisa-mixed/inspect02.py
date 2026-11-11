from pathlib import Path
import sys,struct,hashlib
sys.path.insert(0,'G:/MySTG/work/suwako5/vendor')
import pefile,capstone
P=Path('G:/TouHou/[th08] 东方永夜抄 (日文版)/th08.exe');raw=P.read_bytes();pe=pefile.PE(data=raw);base=pe.OPTIONAL_HEADER.ImageBase
def off(va):return pe.get_offset_from_rva(va-base)
def va(o):return base+pe.get_rva_from_offset(o)
def dump(addr,size):
 c=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
 for i in c.disasm(raw[off(addr):off(addr)+size],addr):print(hex(i.address),i.mnemonic,i.op_str)
if __name__=='__main__':
 print(P,'sha256',hashlib.sha256(raw).hexdigest())
 if len(sys.argv)>1:dump(int(sys.argv[1],0),int(sys.argv[2],0))
 else:
  for n in [107,108,109,110]:
   pos=0
   while True:
    pos=raw.find(struct.pack('<I',n),pos)
    if pos<0:break
    if pos+32<len(raw):print(n,hex(va(pos)),raw[pos:pos+32].hex(' '))
    pos+=4
