# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** Docusaurus 3.x, MDX, blog at `blog/`
- **Created:** 2026-03-22
- **My Role:** Tech Blogger — dev blog posts explaining decompilation progress to programmers new to unmanaged C++ and game engine code
- **Key Blog Info:**
  - Blog directory: `blog/blog/`
  - Generator script: `python tools/new_blog_post.py "Title" --tags tag1,tag2` — ALWAYS use this, never create manually
  - Build check: `cd blog && npm run build`
  - NEVER use bare `<` or `>` in prose — wrap in backticks: `<=`, `>=`
  - Internal links: use full slug from frontmatter prefixed with `/blog/`
  - Tone: informative, light-hearted, aimed at programmers who don't know unmanaged C++
  - Structure: introduce concept → explain it → technical detail → project impact
  - End every post with a "How much is left?" progress section
- **Audience:** Programmers who know code but not game engine internals or unmanaged C++

## Learnings

<!-- Append new learnings below. -->