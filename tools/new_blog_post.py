#!/usr/bin/env python3
"""
new_blog_post.py — Create a new blog post with a guaranteed-unique date.

Scans all existing posts, finds the highest post number and the latest
date, then creates a new stub .md file with:
  - post number = max + 1
  - date        = latest_date + 15 minutes
  - slug, title, authors, tags all pre-filled with placeholders

Usage:
    python tools/new_blog_post.py "Short Title Here" [--tags tag1,tag2]

The file is created at blog/blog/<NNN>-<slug>.md and printed to stdout.
Edit the body and replace PLACEHOLDER tags before committing.
"""

import re
import sys
import argparse
from pathlib import Path
from datetime import datetime, timedelta


BLOG_DIR = Path(__file__).resolve().parent.parent / "blog" / "blog"

# Match filenames like 123-some-slug.md
POST_NUM_RE = re.compile(r"^(\d+)-")
# Match frontmatter date lines
DATE_RE = re.compile(r"^date:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2})")


def slugify(title: str) -> str:
    """Convert a title to a URL-safe slug."""
    slug = title.lower()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = slug.strip("-")
    return slug


def find_max_post_number() -> int:
    max_num = 0
    for f in BLOG_DIR.glob("*.md"):
        m = POST_NUM_RE.match(f.name)
        if m:
            max_num = max(max_num, int(m.group(1)))
    return max_num


def find_latest_date() -> datetime:
    latest = datetime(2026, 1, 1, 0, 0)
    for f in BLOG_DIR.glob("*.md"):
        try:
            for line in f.read_text(encoding="utf-8", errors="replace").splitlines():
                m = DATE_RE.match(line.strip())
                if m:
                    try:
                        d = datetime.strptime(m.group(1), "%Y-%m-%dT%H:%M")
                        if d > latest:
                            latest = d
                    except ValueError:
                        pass
                    break
        except OSError:
            pass
    return latest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("title", help="Human-readable title (e.g. 'Fixing the Physics Loop')")
    parser.add_argument("--tags", default="decompilation", help="Comma-separated tags (default: decompilation)")
    args = parser.parse_args()

    title_text = args.title.strip()
    tags = [t.strip() for t in args.tags.split(",") if t.strip()]

    post_num = find_max_post_number() + 1
    new_date = find_latest_date() + timedelta(minutes=15)
    date_str = new_date.strftime("%Y-%m-%dT%H:%M")

    slug_body = slugify(title_text)
    slug = f"{post_num}-{slug_body}"
    filename = f"{post_num}-{slug_body}.md"
    out_path = BLOG_DIR / filename

    if out_path.exists():
        print(f"ERROR: {out_path} already exists — aborting.", file=sys.stderr)
        return 1

    tags_yaml = "[" + ", ".join(tags) + "]"

    content = f"""\
---
slug: {slug}
title: "{post_num}. {title_text}"
authors: [copilot]
date: {date_str}
tags: {tags_yaml}
---

TODO: Write post body here.

<!-- truncate -->

## Section Heading

More content here.
"""

    out_path.write_text(content, encoding="utf-8", newline="\n")
    print(f"Created: {out_path}")
    print(f"  Post number : {post_num}")
    print(f"  Date        : {date_str}")
    print(f"  Slug        : {slug}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
