#!/usr/bin/env python3
"""Check vtable slots for AProjector."""
import json
data = json.load(open('ghidra/exports/reports/Engine_vtables.json'))
for vt in data['vtables']:
    if 'AProjector' in vt['class']:
        print(f"Class: {vt['class']}  slots: {vt['slot_count']}")
        for slot in vt.get('slots', []):
            offset = slot.get('offset', 0)
            if offset in [0x10c, 0x184, 0x108, 0x110, 0x180, 0x188]:
                print(f"  offset 0x{offset:x}: {slot.get('name', '?')}")
