from pathlib import Path
import sys
sys.path.insert(0,'G:/MySTG/work/suwako5/vendor')
import pefile,capstone
p=next(next(x for x in Path('G:/TouHou').iterdir() if x.name.startswith('[th18]')).rglob('th18.exe'));b=pefile.PE(str(p)).get_memory_mapped_image();md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_32)
ranges=[(0x4027d0,0x402850),(0x445a80,0x446830),(0x45ae00,0x45af40),(0x41a000,0x41c200),(0x41d260,0x41f000),(0x446f40,0x447470)]
out=[]
for lo,hi in ranges:
 out += [f'{i.address:08x} {i.mnemonic} {i.op_str}' for i in md.disasm(b[lo-0x400000:hi-0x400000],lo)]
Path('G:/MySTG/work/logs/stage5/native-items.asm').write_text('\n'.join(out))
print('\n'.join(out[:38]))
