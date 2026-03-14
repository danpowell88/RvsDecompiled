This is a decompliation project for Tom Clancys Rainbow Six Ravenshield.

The goal is a maintainable, readable and as close to byte accurate version of the game as possible that can be rebuilt and played. Byte accuracy should not come at the expensive of complicated code, where possible keep it accurate but readability and maintainability / simplicity should be preferred. Document any divergences from byte parity.

Keep a dev blog as progress continues in the /blog folder. The dev blog should be aimed at someone who is a programmer but not used to unmanaged and c++  and game engine code. Introduce concepts before delving deep into the technical implementation and ensure its explained and then when it is you may continue to go into technical detail. A dev blog should be created when anything interesting is completed or a new milestone is achieved. They can be both long and short and should be informative and light hearted while still providing some good technical and educational information.

The build must always compile and link.

Commit frequently when small pieces of work are done.

The blog uses Docusaurus with MDX. In blog post prose (outside of code blocks), bare `<` and `>` characters are interpreted as JSX tags and will cause build failures. Always wrap operators like `<=`, `>=`, `<<`, `>>`, or any angle-bracket expressions in backticks when writing them in markdown text.

Blog post titles must follow the format `"NN. Title Text"` where NN is the post number matching the filename prefix (e.g. file `47-foo.md` → title `"47. Foo"`). Do not use alternative prefixes like "Batch NNN:", "Dev Blog #NN:", or "Post NN:".

## Blog Frontmatter Rules
1. **Every post MUST have a `date:` field.** A missing date causes the post to be silently omitted or mis-sorted.
2. Use the current date and time for the value
3. **Never copy frontmatter from an earlier post without updating the date.** This is the most common source of duplicates.
4. **Every post MUST have a `slug:` field.**

### Required frontmatter template

```md
---
slug: NNN-short-kebab-title
title: "NNN. Full Human-Readable Title"
authors: [copilot]
date: YYYY-MM-DDTHH:MM
---
```

## ⚠️ Blog Post Numbering — CRITICAL (recurring issue)

Multiple agents running in parallel **will collide on post numbers** unless each one checks
the current highest number before writing a new post.

**Before creating any blog post, always run:**
```powershell
ls blog/blog/*.md | Sort-Object Name | Select-Object -Last 1 -ExpandProperty Name
```
This shows the highest existing post number. Use `N+1` for your new post.

**Rules:**
- Never hardcode a post number like `100` without checking first.
- If a conflict is discovered after the fact, renumber the duplicate to `(current_max + 1)`.
- The filename prefix **must** match the `slug:` NNN and the `title: "NNN."` prefix exactly.
- After renaming, search for `"Post 100!"` or similar in the post body and update it too.

## Ground Truth Priority

**The SDK included in this repo is a community-maintained project and is NOT official / NOT always correct.**

When there is any conflict between the SDK headers and Ghidra analysis of the retail binaries:

1. **Ghidra is always the ground truth.** Function signatures, struct sizes, member offsets, calling conventions — all come from Ghidra analysis of the retail DLLs, not the SDK.

2. **The SDK is a useful starting point / cross-reference only.** It can help identify parameter names and intent, but must not be blindly trusted for signatures, types, or struct layouts.

3. **When adding a new declaration or shim** (e.g. adding a missing function to `EnginePrivate.h` or `CorePrivate.h`), derive the signature from Ghidra's decompilation output in `ghidra/exports/`, not from the SDK. Document the Ghidra address in a comment.

4. **When a SDK declaration disagrees with Ghidra**, the Ghidra-derived version wins. Note the discrepancy with a comment: `// DIVERGENCE from SDK: Ghidra shows N params, SDK shows M`.


5. **Retail parity attribution** — every function definition must be preceded by one of these macros (see `src/Core/Inc/ImplSource.h`):
   - `IMPL_MATCH("Foo.dll", 0xaddr)` — claims exact parity with retail binary; derived from Ghidra analysis. Address must be a **full virtual address** (e.g. `0x104766d0`), not a relative offset. Engine.dll base = `0x10300000`.
   - `IMPL_EMPTY("reason")` — retail is also trivially empty (Ghidra confirmed); only use when Ghidra confirms the body is empty
   - `IMPL_DIVERGE("reason")` — **permanent** divergence only (defunct live services, hardware globals, etc.). NOT for "pending decompilation"
   - `IMPL_APPROX("reason")` — **BANNED, causes build failure**
   - `IMPL_TODO("reason")` — **BANNED, causes build failure**

   **The only valid macros are IMPL_MATCH, IMPL_EMPTY, and IMPL_DIVERGE.**