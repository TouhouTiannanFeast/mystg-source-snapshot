import runpy
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py')
md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
for addr,n in [(0x40e7e1,420),(0x40eb16,287),(0x40ec35,230)]:
 print('\nHANDLER',hex(addr))
 for i in md.disasm(b['at'](addr,n),addr): print(hex(i.address),i.mnemonic,i.op_str)
