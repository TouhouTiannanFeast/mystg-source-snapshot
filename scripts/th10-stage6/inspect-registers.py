import runpy,struct
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py'); md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
for addr,n in [(0x412aa0,0x620),(0x40ecfb,0x50)]:
 for i in md.disasm(b['at'](addr,n),addr): print(hex(i.address),i.mnemonic,i.op_str)
