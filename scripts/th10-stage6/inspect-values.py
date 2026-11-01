import runpy
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py'); md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
for i in md.disasm(b['at'](0x412000,0x228),0x412000): print(hex(i.address),i.mnemonic,i.op_str)
