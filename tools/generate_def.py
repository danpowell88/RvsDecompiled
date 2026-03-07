"""
generate_def.py — Generate Core.def from retail Core.dll export table.

Reads the retail DLL's export table and writes a .def file with all
2338 exports for ordinal-accurate linking.
"""

import pefile
import os

RETAIL_DLL = r"c:\Users\danpo\Desktop\rvs\retail\system\Core.dll"
OUTPUT_DEF = r"c:\Users\danpo\Desktop\rvs\src\core\Core.def"


def main():
    pe = pefile.PE(RETAIL_DLL)
    symbols = pe.DIRECTORY_ENTRY_EXPORT.symbols
    
    lines = []
    lines.append("LIBRARY Core")
    lines.append("EXPORTS")
    
    for sym in symbols:
        name = sym.name.decode('ascii') if sym.name else None
        if name:
            lines.append(f"    {name} @{sym.ordinal}")
    
    with open(OUTPUT_DEF, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    
    print(f"Generated {OUTPUT_DEF}")
    print(f"  Total exports: {len(symbols)}")
    print(f"  Named exports: {sum(1 for s in symbols if s.name)}")


if __name__ == "__main__":
    main()
