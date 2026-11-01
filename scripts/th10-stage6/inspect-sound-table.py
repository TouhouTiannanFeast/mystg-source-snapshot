import runpy,struct,re
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py');raw=b['data']
def va(off):
 for name,vs,rv,rs,p in b['sections']:
  if p<=off<p+rs:return b['base']+rv+off-p
for name in [b'se_tan00.wav',b'se_kira00.wav']:
 off=raw.find(name);v=va(off);print(name,hex(v));ptr=struct.pack('<I',v)
 for m in re.finditer(re.escape(ptr),raw):print(hex(va(m.start())),raw[max(0,m.start()-8):m.start()+32].hex(' '))
