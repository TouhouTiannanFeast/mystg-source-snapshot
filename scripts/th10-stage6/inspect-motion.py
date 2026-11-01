import runpy,struct
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py'); md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
for op in [280,281,282,290]:
 idx=b['at'](0x411ee0+op-256,1)[0];addr=struct.unpack('<I',b['at'](0x411d30+idx*4,4))[0];print('OP',op,hex(addr))
 for i in md.disasm(b['at'](addr,170),addr): print(hex(i.address),i.mnemonic,i.op_str)
for i in md.disasm(b['at'](0x44ff80,0x170),0x44ff80):print(hex(i.address),i.mnemonic,i.op_str)
