from pathlib import Path
import sys,struct,json
sys.path.insert(0,'G:/MySTG/work/suwako5/vendor');import pefile
for game in [17,20]:
 base=next(p for p in Path('G:/TouHou').iterdir() if p.name.startswith('[th17]')) if game==17 else Path('G:/TouHou/th20')
 exe=next(base.rglob('th'+str(game)+'.exe'));pe=pefile.PE(str(exe));data=pe.get_memory_mapped_image()
 out=[]
 for i in range(0,len(data)-0x114*40,4):
  try:
   ids=[struct.unpack_from('<I',data,i+4+16*c)[0]for c in range(16)]
   radius=struct.unpack_from('<f',data,i+0x104)[0]
   if ids==list(range(ids[0],ids[0]+16)) and 1<=radius<=16 and ids[0]<1000:
    out.append((hex(i),ids[0],radius))
  except:pass
 print(game,exe,out[:90])
