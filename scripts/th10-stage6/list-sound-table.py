import runpy,struct
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py')
for addr in range(0x474b00,0x474c20,4):
 p=struct.unpack('<I',b['at'](addr,4))[0]
 try:s=b['at'](p,40).split(b'\0')[0].decode('ascii')
 except:s='?'
 print(hex(addr),hex(p),s)
