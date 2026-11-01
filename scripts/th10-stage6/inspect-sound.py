import runpy,struct
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py');raw=b['data']
for name in [b'se_tan00.wav',b'se_kira00.wav']:
 off=raw.find(name);va=off+0x400c00;print(name,hex(off),hex(va))
 ptr=struct.pack('<I',va);pos=raw.find(ptr)
 while pos>=0:
  print(hex(pos+0x400c00),raw[max(0,pos-12):pos+32].hex(' '));pos=raw.find(ptr,pos+4)
md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
for op in [361,323]:
 idx=b['at'](0x411ee0+op-256,1)[0];addr=struct.unpack('<I',b['at'](0x411d30+idx*4,4))[0];print('OP',op,hex(addr))
 for i in md.disasm(b['at'](addr,100),addr): print(hex(i.address),i.mnemonic,i.op_str)
