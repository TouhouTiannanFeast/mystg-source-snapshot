from pathlib import Path
import struct,sys,re
sys.path.insert(0,'G:/MySTG/scripts/milk-honey/deps')
import capstone
P=next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith('[th11]'))/'th11.exe'
b=P.read_bytes();p=struct.unpack_from('<I',b,60)[0];o=p+24+struct.unpack_from('<H',b,p+20)[0]
sec=[struct.unpack_from('<8sIIII',b,o+i*40) for i in range(struct.unpack_from('<H',b,p+6)[0])]
def at(va,size):
 for nm,vs,v,rs,raw in sec:
  r=va-0x400000
  if v<=r<v+max(vs,rs):return b[raw+r-v:raw+r-v+size]
 raise ValueError(hex(va))
def va(off):
 for nm,vs,v,rs,raw in sec:
  if raw<=off<raw+rs:return off-raw+v+0x400000
c=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
c.skipdata=True
if __name__=='__main__':
 if len(sys.argv)>1:
  start=int(sys.argv[1],0);size=int(sys.argv[2],0)if len(sys.argv)>2 else 300
  for i in c.disasm(at(start,size),start):print(hex(i.address),i.mnemonic,i.op_str)
 else:
  # Source's classic small bullet tables are contiguous ANM base indices.
  for pat in [[0,64,80,96],[0,16,32,48],[64,80,96,112],[0,4,8,12]]:
   q=struct.pack('<'+'I'*len(pat),*pat);start=0
   while (k:=b.find(q,start))>=0:print('TABLE',pat,hex(va(k)),struct.unpack_from('<24I',b,k));start=k+4
  for nm,vs,v,rs,raw in sec:
   if nm.rstrip(b'\0') in [b'.rdata',b'.data']:
    for k in range(raw,raw+rs-100,4):
     vals=struct.unpack_from('<20I',b,k)
     if all(0<=x<1000 for x in vals[:8])and sum(vals[i+1]-vals[i] in [8,16,32]for i in range(7))>=6:
      print('BASES',hex(va(k)),vals)
   if nm.rstrip(b'\0')!=b'.text':continue
   ops=list(c.disasm(b[raw:raw+rs],v+0x400000))
   for j,i in enumerate(ops):
    if i.mnemonic=='jmp' and ('*4' in i.op_str or '* 4' in i.op_str) and 'ptr' in i.op_str:
     prev=ops[max(0,j-6):j+1]
     if True:
      print('DISPATCH');print('\n'.join(f'{x.address:x} {x.mnemonic} {x.op_str}'for x in prev))
