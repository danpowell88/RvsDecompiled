#!/usr/bin/env python3
"""Analyze trivial stubs to plan Phase 1C implementation."""

import csv
import re
from collections import Counter, defaultdict

CSV_PATH = "build/stub_triage.csv"

def main():
    # Count ALL stubs by category
    all_stubs = []
    with open(CSV_PATH) as f:
        for row in csv.DictReader(f):
            all_stubs.append(row)

    # Vtable symbols still in stubs
    vtable_classes = Counter()
    ctor_classes = Counter()
    dtor_classes = Counter()
    getter_classes = Counter()
    assign_classes = Counter()

    for row in all_stubs:
        m = row['mangled']
        d = row['demangled']
        cat = row['category']
        sub = row['subcategory']

        # Extract class name from demangled
        cm = re.search(r'(\w+)::', d)
        cls = cm.group(1) if cm else 'global'

        if '??_7' in m:
            vtable_classes[cls] += 1
        elif sub == 'constructor':
            ctor_classes[cls] += 1
        elif sub == 'destructor':
            dtor_classes[cls] += 1
        elif sub == 'simple_getter' and cat == 'TRIVIAL':
            getter_classes[cls] += 1
        elif sub == 'assignment_op':
            assign_classes[cls] += 1

    print("=== Vtable symbols in stubs (82) ===")
    for cls, cnt in vtable_classes.most_common(20):
        print(f"  {cnt:3d}  {cls}")

    print("\n=== Constructor stubs (296) ===")
    for cls, cnt in ctor_classes.most_common(20):
        print(f"  {cnt:3d}  {cls}")

    print("\n=== Destructor stubs (72) ===")
    for cls, cnt in dtor_classes.most_common(20):
        print(f"  {cnt:3d}  {cls}")

    print("\n=== Simple getter stubs (265) ===")
    for cls, cnt in getter_classes.most_common(20):
        print(f"  {cnt:3d}  {cls}")

    print("\n=== Assignment op stubs (110) ===")
    for cls, cnt in assign_classes.most_common(20):
        print(f"  {cnt:3d}  {cls}")

    # Find classes that would yield the most resolved stubs if declared
    class_total = Counter()
    for counter in [vtable_classes, ctor_classes, dtor_classes, assign_classes]:
        class_total.update(counter)
    
    print("\n=== Classes by total auto-resolvable stubs (vtable+ctor+dtor+assign) ===")
    for cls, cnt in class_total.most_common(40):
        parts = []
        if cls in vtable_classes: parts.append(f"vt:{vtable_classes[cls]}")
        if cls in ctor_classes: parts.append(f"ct:{ctor_classes[cls]}")
        if cls in dtor_classes: parts.append(f"dt:{dtor_classes[cls]}")
        if cls in assign_classes: parts.append(f"as:{assign_classes[cls]}")
        if cls in getter_classes: parts.append(f"get:{getter_classes[cls]}")
        print(f"  {cnt:3d}  {cls:40s}  {', '.join(parts)}")


if __name__ == "__main__":
    main()
