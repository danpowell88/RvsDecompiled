"""Fix short-form RVA addresses in IMPL_MATCH annotations to full VAs."""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

try:
    import pefile
except ImportError:
    print("pip install pefile first")
    sys.exit(1)

REPO = Path(__file__).parent.parent

def detect_base(dll_name):
    path = REPO / "retail" / "system" / dll_name
    if path.exists():
        pe = pefile.PE(str(path), fast_load=True)
        return pe.OPTIONAL_HEADER.ImageBase
    return None

BASES = {}
for dll in ["Engine.dll", "Core.dll", "R6Engine.dll", "R6Game.dll",
            "R6Abstract.dll", "Fire.dll", "IpDrv.dll", "R6Weapons.dll"]:
    b = detect_base(dll)
    if b:
        BASES[dll] = b
        print(f"  {dll}: base 0x{b:08x}")

# Pattern: matches addresses with 1-7 hex digits (< 0x10000000)
SHORT_ADDR = re.compile(r'(IMPL_MATCH\("([^"]+)",\s*)(0x[0-9a-fA-F]{1,7})\)')

total_fixed = 0

for cpp in (REPO / "src").rglob("*.cpp"):
    text = cpp.read_text(encoding="utf-8", errors="replace")
    if "IMPL_MATCH" not in text:
        continue

    count = 0

    def replace(m):
        global count
        prefix   = m.group(1)  # e.g. IMPL_MATCH("Engine.dll", 
        dll_name = m.group(2)  # e.g. Engine.dll
        addr_str = m.group(3)  # e.g. 0xA37A0
        addr = int(addr_str, 16)
        base = BASES.get(dll_name)
        if base and addr < 0x01000000:
            count += 1
            return f'{prefix}0x{base + addr:08x})'
        return m.group(0)

    new_text = SHORT_ADDR.sub(replace, text)
    if count:
        cpp.write_text(new_text, encoding="utf-8")
        print(f"  {cpp.name}: fixed {count} addresses")
        total_fixed += count

print(f"\nTotal fixed: {total_fixed}")
