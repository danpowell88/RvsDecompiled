#!/usr/bin/env python3
"""Scan blog posts for bare JSX tag issues outside code blocks."""
import os, re

blog_dir = r'C:\Users\danpo\Desktop\rvs\blog\blog'
issues = []

for fname in sorted(os.listdir(blog_dir)):
    if not fname.endswith('.md'):
        continue
    path = os.path.join(blog_dir, fname)
    with open(path, encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    in_code = False
    fm_count = 0
    in_frontmatter = True

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        if stripped == '---':
            fm_count += 1
            if fm_count >= 2:
                in_frontmatter = False
            continue
        if in_frontmatter:
            continue

        # Toggle code fence tracking
        if stripped.startswith('```'):
            in_code = not in_code
            continue
        if in_code:
            continue

        # Look for bare JSX: < followed by letter, not inside backtick spans
        segments = line.split('`')
        # Odd-indexed segments are inside backticks
        for seg_i, seg in enumerate(segments):
            if seg_i % 2 == 1:
                continue  # inside backtick, skip
            if re.search(r'<[A-Za-z/]', seg):
                issues.append((fname, i, stripped[:80]))
                break

for fname, lineno, text in issues:
    print(f'{fname}:{lineno}: {text}')

print(f'\nTotal: {len(issues)} potential JSX issues found')
