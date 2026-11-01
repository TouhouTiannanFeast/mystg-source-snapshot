import runpy,struct
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py')
for addr in range(0x474980,0x474b40,8): print(hex(addr),struct.unpack('<II',b['at'](addr,8)))
md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
idx=b['at'](0x411ee0+336-256,1)[0];addr=struct.unpack('<I',b['at'](0x411d30+idx*4,4))[0]
for i in md.disasm(b['at'](addr,100),addr):print(hex(i.address),i.mnemonic,i.op_str)
