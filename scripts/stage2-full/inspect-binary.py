from pathlib import Path
import sys,struct
sys.path.insert(0,'G:/TouHou/MLforDanmu/work/research/capstone-5.0.9')
import capstone
p=Path('G:/TouHou/[th10] 东方风神录 (汉化版+日文版)/th10.exe');data=p.read_bytes()
pe=struct.unpack_from('<I',data,0x3c)[0];n=struct.unpack_from('<H',data,pe+6)[0];opt=struct.unpack_from('<H',data,pe+20)[0];base=struct.unpack_from('<I',data,pe+24+28)[0]
sections=[struct.unpack_from('<8sIIII',data,pe+24+opt+40*i) for i in range(n)]
def at(va,size):
 rva=va-base
 for name,vs,rv,rs,off in sections:
  if rv<=rva<rv+max(vs,rs):return data[off+rva-rv:off+rva-rv+size]
 raise ValueError(hex(va))
if __name__=='__main__':
 md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
 for i in md.disasm(at(0x4067d0,0x5c0),0x4067d0):
  if i.address>0x406b30:print(hex(i.address),i.mnemonic,i.op_str)
