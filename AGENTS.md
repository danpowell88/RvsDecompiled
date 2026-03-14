This is a decompliation project for Tom Clancys Rainbow Six Ravenshield.

The goal is a maintainable, readable and as close to byte accurate version of the game as possible that can be rebuilt and played. Byte accuracy should not come at the expensive of complicated code, where possible keep it accurate but readability and maintainability / simplicity should be preferred. Document any divergences from byte parity.

Keep a dev blog as progress continues in the /blog folder. The dev blog should be aimed at someone who is a programmer but not used to unmanaged and c++  and game engine code. Introduce concepts before delving deep into the technical implementation and ensure its explained and then when it is you may continue to go into technical detail. A dev blog should be created when anything interesting is completed or a new milestone is achieved. They can be both long and short and should be informative and light hearted while still providing some good technical and educational information.

The build must always compile and link.

Commit frequently when small pieces of work are done.

The blog uses Docusaurus with MDX. In blog post prose (outside of code blocks), bare `<` and `>` characters are interpreted as JSX tags and will cause build failures. Always wrap operators like `<=`, `>=`, `<<`, `>>`, or any angle-bracket expressions in backticks when writing them in markdown text.

Blog post titles must follow the format `"NN. Title Text"` where NN is the post number matching the filename prefix (e.g. file `47-foo.md` → title `"47. Foo"`). Do not use alternative prefixes like "Batch NNN:", "Dev Blog #NN:", or "Post NN:".

## Blog Frontmatter Rules (CRITICAL — missing/wrong dates hide posts entirely)

Docusaurus sorts posts by the `date` field. Posts with a missing, duplicate, or wrong-year date will either vanish from the listing or appear far out of order. This has caused posts to disappear before — always follow these rules:

1. **Every post MUST have a `date:` field.** A missing date causes the post to be silently omitted or mis-sorted.

2. **Dates must be unique across all posts.** Two posts with the same timestamp collide; only one may appear in navigation. Use 15-minute increments to separate posts created in the same session:
   - Post N: `date: 2026-03-14T08:00`
   - Post N+1: `date: 2026-03-14T08:15`
   - Post N+2: `date: 2026-03-14T08:30`

3. **Dates must increase with post number.** The blog listing is sorted newest-first. If post N+5 has an earlier date than post N, posts N+1 through N+4 will appear AFTER post N+5 in the listing, making them look missing. Always assign a date strictly later than the previous post's date — even if you are writing posts N+1 through N+5 in a single session, increment by 15 minutes per post so the listing order matches the post numbers.

3. **Never copy frontmatter from an earlier post without updating the date.** This is the most common source of duplicates.

4. **The year must be correct.** Accidentally writing `2025` instead of `2026` sends a post to the very beginning of the chronological listing. *(Note: posts 01–66 intentionally carry 2025 dates — they were written in 2025. All new posts use 2026.)*

5. **Every post MUST have a `slug:` field.** Without it, Docusaurus derives one from the filename, which can collide with auto-generated slugs or cause unexpected URLs. The slug MUST be the first field after the opening `---`, and MUST follow the pattern `NNN-kebab-title` matching the filename prefix. A missing slug has caused posts to silently disappear before.

6. **After writing a new post, verify the next date slot is free** by checking what `date:` the previous post uses, then incrementing by 15 minutes. Also verify the new date is **strictly greater than the previous post's date** (posts must have monotonically increasing dates matching their post numbers).

7. **Before committing any blog post, run `npm run build` inside the `/blog` directory.** A successful build confirms the frontmatter parses cleanly and no JSX errors exist.

8. **Before committing, run this quick audit** to catch any missing fields or date ordering problems:
   ```powershell
   # Run from repo root — lists any blog post missing date, slug, or truncate marker
   Get-ChildItem blog\blog\*.md | ForEach-Object {
       $content = Get-Content $_ -Raw
       $missing = @()
       if ($content -notmatch 'date:') { $missing += 'date' }
       if ($content -notmatch 'slug:') { $missing += 'slug' }
       if ($content -notmatch '<!-- truncate -->') { $missing += 'truncate' }
       if ($missing) { Write-Host "$($_.Name): missing $($missing -join ', ')" }
   }
   # Also check date ordering — dates must increase with post number
   Get-ChildItem blog\blog\*.md | Sort-Object Name | ForEach-Object {
       $content = Get-Content $_ -Raw
       $date = if ($content -match 'date:\s*(\S+)') { $Matches[1] } else { $null }
       [PSCustomObject]@{ Name = $_.Name; Date = $date }
   } | Where-Object Date | ForEach-Object -Begin { $prev = $null } -Process {
       if ($prev -and $_.Date -lt $prev.Date) {
           Write-Host "DATE ORDER: $($_.Name) ($($_.Date)) is earlier than $($prev.Name) ($($prev.Date))"
       }
       $prev = $_
   }
   ```

### Required frontmatter template

```md
---
slug: NNN-short-kebab-title
title: "NNN. Full Human-Readable Title"
authors: [copilot]
date: YYYY-MM-DDTHH:MM
tags: [tag1, tag2]
---
```

All six fields (`slug`, `title`, `authors`, `date`, `tags`, and the `<!-- truncate -->` marker somewhere in the body) are mandatory. Place `slug:` **first** in the block so it is never accidentally omitted.

## Ground Truth Priority

**The SDK included in this repo is a community-maintained project and is NOT official / NOT always correct.**

When there is any conflict between the SDK headers and Ghidra analysis of the retail binaries:

1. **Ghidra is always the ground truth.** Function signatures, struct sizes, member offsets, calling conventions — all come from Ghidra analysis of the retail DLLs, not the SDK.

2. **The SDK is a useful starting point / cross-reference only.** It can help identify parameter names and intent, but must not be blindly trusted for signatures, types, or struct layouts.

3. **When adding a new declaration or shim** (e.g. adding a missing function to `EnginePrivate.h` or `CorePrivate.h`), derive the signature from Ghidra's decompilation output in `ghidra/exports/`, not from the SDK. Document the Ghidra address in a comment.

4. **When a SDK declaration disagrees with Ghidra**, the Ghidra-derived version wins. Note the discrepancy with a comment: `// DIVERGENCE from SDK: Ghidra shows N params, SDK shows M`.


5. **Retail parity attribution** — every function definition must be preceded by one of these macros (see `src/Core/Inc/ImplSource.h`):
   - `IMPL_MATCH("Foo.dll", 0xaddr)` — claims exact byte parity with retail; build fails if compiled size diverges
   - `IMPL_APPROX("reason")` — intentional or unverified deviation; parity check skipped; **reason is mandatory**
   - `IMPL_EMPTY("reason")` — retail is also trivially empty (Ghidra confirmed)
   - `IMPL_DIVERGE("reason")` — permanent divergence (Karma physics, GameSpy, etc.)
   - `IMPL_TODO("reason")` — not yet implemented; **BUILD FAILS**

   **The macros express parity status, not code origin.** Where the code came from (Ghidra, UT99 reference, inferred) belongs in a regular `//` comment above the macro. `IMPL_APPROX` is used for UT99-reference-derived code, Ghidra approximations, and anything inferred — all are unverified until confirmed.

   Do NOT use the old `IMPL_GHIDRA`, `IMPL_GHIDRA_APPROX`, `IMPL_UT99_REF`, `IMPL_INFERRED`, `IMPL_INTENTIONALLY_EMPTY`, `IMPL_SDK`, or `IMPL_PERMANENT_DIVERGENCE` macros (all renamed/removed).

   **IMPL_STRICT is permanently ON** (default changed in `CMakeLists.txt`, 2026-03-14). The build fails on any unannotated function or `IMPL_TODO`. Do NOT add `IMPL_TODO` annotations — decide the correct macro before committing. If you genuinely cannot classify a function yet, use `IMPL_APPROX("reason TBD")` as a placeholder.

   **CRITICAL: IMPL_xxx macros MUST be on a single line.** The attribution scanner (`tools/verify_impl_sources.py`) walks backward one line at a time; a multi-line macro with a string continuation on the next line confuses it. Always write the whole reason on one line:
   ```cpp
   // ✅ Correct — single line
   IMPL_DIVERGE("Retail registers properties; omitted: vtable mismatch with Core.dll")
   void Foo::Bar() { ... }

   // ❌ Wrong — continuation line confuses the scanner
   IMPL_DIVERGE("Retail registers properties; "
       "omitted: vtable mismatch with Core.dll")
   void Foo::Bar() { ... }
   ```
