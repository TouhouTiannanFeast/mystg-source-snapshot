import runpy
b=runpy.run_path('G:/MySTG/scripts/stage2-full/inspect-binary.py');md=b['capstone'].Cs(b['capstone'].CS_ARCH_X86,b['capstone'].CS_MODE_32)
ops=list(md.disasm(b['at'](0x40d000,0x1760),0x40d000))
for j,i in enumerate(ops):
 if '0x2480' in i.op_str or '0x246c' in i.op_str:
  print('\nFIELD');print('\n'.join(f'{x.address:x} {x.mnemonic} {x.op_str}' for x in ops[max(0,j-3):j+11]))
for i in md.disasm(b['at'](0x43dd10,0xa0),0x43dd10):print(hex(i.address),i.mnemonic,i.op_str)
