"""Diagnostic: trace where the out-of-class methods come from"""
import re

with open('src/engine/EngineClasses.h') as f:
    lines = f.readlines()

# Show lines 5455-5510 with raw repr to see indentation
print("=== Patched file lines 5455-5510 ===")
for i in range(5454, 5510):
    # Show first 80 chars with repr to see tabs vs spaces
    raw = repr(lines[i][:80])
    print(f'{i+1}: {raw}')

# Check if there's a duplicate: same methods appear again later
print("\n=== Check for SoftSelect at output line 6102 ===")
for i in range(6095, 6110):
    if i < len(lines):
        print(f'{i+1}: {lines[i].rstrip()}')
