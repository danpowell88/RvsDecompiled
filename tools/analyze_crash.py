"""Analyze the crash dump to understand the corrupted UStruct."""
from minidump.minidumpfile import MinidumpFile
import struct

mf = MinidumpFile.parse('retail/system/RavenShield.exe_260308_052412.dmp')
reader = mf.get_reader()

ecx = 0x0123CFC0  # corrupted UStruct from crash

# Read the object
obj = reader.read(ecx, 512)
print("Object at ECX=0x%08X:" % ecx)
fmt = struct.Struct('<I')
for row in range(0, 256, 16):
    vals = [fmt.unpack_from(obj, row+i)[0] for i in range(0, 16, 4)]
    print("  +%03X: %08X %08X %08X %08X" % (row, vals[0], vals[1], vals[2], vals[3]))

# Engine.dll base = 0x10300000, Core.dll base = 0x10100000
print()
val_at_24 = fmt.unpack_from(obj, 0x24)[0]
print("ECX+24 = %08X => Engine.dll+%X" % (val_at_24, val_at_24 - 0x10300000))

# The value at +24 might be a UClass* pointer (Class field of UObject)
# Let me read the class object
class_ptr = val_at_24
print("\nReading UClass at %08X:" % class_ptr)
try:
    cls = reader.read(class_ptr, 128)
    for row in range(0, 128, 16):
        vals = [fmt.unpack_from(cls, row+i)[0] for i in range(0, 16, 4)]
        print("  +%02X: %08X %08X %08X %08X" % (row, vals[0], vals[1], vals[2], vals[3]))
except:
    print("  Cannot read")

# Also look at what 1066D5B8 is - Engine.dll+0x36D5B8
# This might be a static vtable in Engine.dll data section
# Read bytes at this address
print("\nData at Engine.dll+0x36D5B8 (1066D5B8):")
try:
    data = reader.read(0x1066D5B8, 64)
    for row in range(0, 64, 16):
        vals = [fmt.unpack_from(data, row+i)[0] for i in range(0, 16, 4)]
        print("  +%02X: %08X %08X %08X %08X" % (row, vals[0], vals[1], vals[2], vals[3]))
except:
    print("  Cannot read")

# Read FName::Names to look up some adjacent names
names_tarray = reader.read(0x102577F0, 12)
data_ptr = fmt.unpack_from(names_tarray, 0)[0]
num = fmt.unpack_from(names_tarray, 4)[0]
print(f"\nFName::Names has {num} entries")

# Read a few FNames around 1508 to understand context
for idx in [1506, 1507, 1508, 1509, 1510]:
    ep = fmt.unpack_from(reader.read(data_ptr + idx * 4, 4), 0)[0]
    if ep:
        ed = reader.read(ep, 48)
        # Name starts at offset 12 in the FNameEntry (after hash_next=4, flags=4, ?=4)
        # Or at offset 12 based on what we saw: bytes 0-3 are hash, 4-11 are other, 12+ is name
        # Actually from the raw dump of FName[1508]:
        # +00: E4 05 00 00 (0x5E4 = 1508 - this is the hash chain link/index)
        # +04: 00 00 00 00 (flags?)
        # +08: 00 00 00 00 (?)
        # +0C: 47 00 65 00 (G.e. in UTF-16) = start of name
        name = ""
        for i in range(12, 44, 2):
            ch = struct.unpack_from('<H', ed, i)[0]
            if ch == 0: break
            if 0x20 <= ch < 0x7f: name += chr(ch)
            else: name += "?"
        print(f"  FName[{idx}] = '{name}'")

# The UObject at ECX has vtable=0.
# What was at ECX+0C (Children field used in FindObjectField)?
children = fmt.unpack_from(obj, 0x0C)[0]
print(f"\nECX+0C (Children) = {children:#010x}")
# This is 0x0069006E which is UTF-16 'n','i'
# BUT: This is part of the string ".ini" that starts at offset +08
# Bytes at ECX+08: 2E 00 69 00 6E 00 69 00 = ".ini" in UTF-16
raw = obj[8:16]
print("ECX+08..+0F as UTF-16: '%s'" % raw.decode('utf-16-le', errors='replace').rstrip('\x00'))

# Key insight: the UStruct's Children field contains the 'ni' part of ".ini"
# The question is: what put ".ini" here?
# The UStruct at ECX has been partially zero-filled (vtable=0) 
# and then had ".ini" written at offset +8
# This looks like a UObject that was destroyed, and its memory was then
# used by an FString containing ".ini"

# Let me check: what's the FName at offset +1C of the UObject?
# Wait, I need to know the UObject layout first
# Let me check the value at ECX+0x20 which was 0x00001E9E
name_val = fmt.unpack_from(obj, 0x20)[0]
print(f"\nECX+20 = {name_val:#010x} (decimal {name_val})")
# If this is FName.Index, look it up
if name_val < num:
    ep = fmt.unpack_from(reader.read(data_ptr + name_val * 4, 4), 0)[0]
    if ep:
        ed = reader.read(ep, 48)
        name = ""
        for i in range(12, 44, 2):
            ch = struct.unpack_from('<H', ed, i)[0]
            if ch == 0: break
            if 0x20 <= ch < 0x7f: name += chr(ch)
            else: name += "?"
        print(f"  FName[{name_val}] = '{name}'")
