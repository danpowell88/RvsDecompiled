import struct
data = open('retail/system/Engine.dll','rb').read()
iat_names = {0x10529068:'op/(FRotator)',0x10529170:'op/(FVector)',0x10529174:'op*(FRotator)',0x10529178:'op*(FVector)',0x10529190:'op/(FScale)',0x10529194:'op*(FScale)'}
regs = ['EAX','ECX','EDX','EBX','ESP','EBP','ESI','EDI']

def decode_insn(code, i):
    b = code[i]
    if b == 0x81 and code[i+1] == 0xEC: return (6,'SUB ESP, 0x%x'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0x81 and code[i+1] == 0xC4: return (6,'ADD ESP, 0x%x'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0x83 and code[i+1] == 0xEC: return (3,'SUB ESP, 0x%02x'%code[i+2])
    if b == 0x83 and code[i+1] == 0xC4: return (3,'ADD ESP, 0x%02x'%code[i+2])
    if b == 0x83 and code[i+1] == 0xC1: return (3,'ADD ECX, 0x%02x'%code[i+2])
    if b == 0x81 and code[i+1] == 0xC1: return (6,'ADD ECX, 0x%x'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0xD9 and code[i+1] == 0xE0: return (2,'FABS')
    if b == 0xD9 and code[i+1] == 0x81: return (6,'FLD [ECX+0x%x]'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0xD9 and code[i+1] == 0x44 and code[i+2] == 0x24: return (4,'FLD [ESP+0x%02x]'%code[i+3])
    if b == 0xD9 and code[i+1] == 0x5C and code[i+2] == 0x24: return (4,'FSTP [ESP+0x%02x]'%code[i+3])
    if 0x50 <= b <= 0x57: return (1,'PUSH %s'%regs[b-0x50])
    if 0x58 <= b <= 0x5F: return (1,'POP %s'%regs[b-0x58])
    if b == 0x8B and code[i+1] == 0xC8: return (2,'MOV ECX, EAX')
    if b == 0x8B and code[i+1] == 0xC6: return (2,'MOV EAX, ESI')
    if b == 0x8B and code[i+1] == 0x0D: return (6,'MOV ECX, [0x%010x]'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0x8B and code[i+1] == 0x74 and code[i+2] == 0x24: return (4,'MOV ESI, [ESP+0x%02x]'%code[i+3])
    if b == 0x8B and code[i+1] == 0xB4 and code[i+2] == 0x24: return (7,'MOV ESI, [ESP+0x%x]'%struct.unpack_from('<I',code,i+3)[0])
    if b == 0x8D and code[i+1] == 0x81: return (6,'LEA EAX, [ECX+0x%x]'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0x8D and code[i+1] == 0x91: return (6,'LEA EDX, [ECX+0x%x]'%struct.unpack_from('<I',code,i+2)[0])
    if b == 0x8D and code[i+1] == 0x44 and code[i+2] == 0x24: return (4,'LEA EAX, [ESP+0x%02x]'%code[i+3])
    if b == 0x8D and code[i+1] == 0x84 and code[i+2] == 0x24: return (7,'LEA EAX, [ESP+0x%x]'%struct.unpack_from('<I',code,i+3)[0])
    if b == 0x8D and code[i+1] == 0x4C and code[i+2] == 0x24: return (4,'LEA ECX, [ESP+0x%02x]'%code[i+3])
    if b == 0x8D and code[i+1] == 0x8C and code[i+2] == 0x24: return (7,'LEA ECX, [ESP+0x%x]'%struct.unpack_from('<I',code,i+3)[0])
    if b == 0x8D and code[i+1] == 0x54 and code[i+2] == 0x24: return (4,'LEA EDX, [ESP+0x%02x]'%code[i+3])
    if b == 0xFF and code[i+1] == 0x15:
        va = struct.unpack_from('<I',code,i+2)[0]
        return (6,'CALL [0x%010x] ; %s'%(va, iat_names.get(va,'???')))
    if b == 0xC2: return (3,'RET %d'%struct.unpack_from('<H',code,i+1)[0])
    if b == 0xC3: return (1,'RET')
    if b == 0xCC: return (1,'INT3')
    return (1,'db 0x%02x'%b)

def decode_func(addr, name):
    code = data[addr:addr+300]
    print('== %s =='%name)
    i = 0
    while i < 300:
        sz, txt = decode_insn(code, i)
        print('  +%3d  %s'%(i,txt))
        if txt.startswith('RET') or txt == 'INT3': break
        i += sz
    print()

for addr, name in [(0x7B40,'ABrush::ToLocal'),(0x7BC0,'ABrush::ToWorld'),(0x77D0,'ABrush::OldToLocal'),(0x7880,'ABrush::OldToWorld')]:
    decode_func(addr, name)
