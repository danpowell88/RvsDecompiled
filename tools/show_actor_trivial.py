#!/usr/bin/env python3
"""Show AActor trivial getters/setters from triage CSV."""
import csv

with open("build/stub_triage.csv") as f:
    for row in csv.DictReader(f):
        if row["category"] == "TRIVIAL" and "AActor" in row["demangled"]:
            sub = row["subcategory"]
            if sub in ("simple_getter", "simple_setter"):
                print(f"{sub:15s}  {row['demangled'][:120]}")
