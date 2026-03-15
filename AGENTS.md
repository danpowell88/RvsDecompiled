This is a decompliation project for Tom Clancys Rainbow Six Ravenshield.

The goal is a maintainable, readable and as close to byte accurate version of the game as possible that can be rebuilt and played. Byte accuracy should not come at the expensive of complicated code, where possible keep it accurate but readability and maintainability / simplicity should be preferred. Document any divergences from byte parity.

Keep a dev blog as progress continues in the /blog folder. The dev blog should be aimed at someone who is a programmer but not used to unmanaged and c++  and game engine code. Introduce concepts before delving deep into the technical implementation and ensure its explained and then when it is you may continue to go into technical detail. A dev blog should be created when anything interesting is completed or a new milestone is achieved. They can be both long and short and should be informative and light hearted while still providing some good technical and educational information.

The build must always compile and link.

Commit frequently when small pieces of work are done.

The blog uses Docusaurus with MDX. In blog post prose (outside of code blocks), bare `<` and `>` characters are interpreted as JSX tags and will cause build failures. Always wrap operators like `<=`, `>=`, `<<`, `>>`, or any angle-bracket expressions in backticks when writing them in markdown text.

Blog post titles must follow the format `"NN. Title Text"` where NN is the post number matching the filename prefix (e.g. file `47-foo.md` → title `"47. Foo"`). Do not use alternative prefixes like "Batch NNN:", "Dev Blog #NN:", or "Post NN:".


## ⚠️ Blog Post Creation — ALWAYS use the script

**Never create a blog post file by hand.** Always use the generator script:

```powershell
python tools/new_blog_post.py "Your Post Title Here" --tags tag1,tag2
```

After running the script, open the created file and replace the placeholder body with your content.

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

   **The only valid macros are IMPL_MATCH, IMPL_EMPTY, and IMPL_DIVERGE.**

## Build Commands

**To build and check for errors (agents MUST use this):**
```powershell
cd C:\Users\danpo\Desktop\rvs\build-71
$VS2019_X86 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86"
$env:PATH = "C:\Users\danpo\Desktop\rvs\tools\toolchain\msvc71\bin;$VS2019_X86;$env:PATH"
$env:LIB = "C:\Users\danpo\Desktop\rvs\tools\toolchain\msvc71\lib;C:\Users\danpo\Desktop\rvs\tools\toolchain\winsdk\Lib;C:\Users\danpo\Desktop\rvs\tools\toolchain\dxsdk\Lib"
& "$VS2019_X86\nmake.exe" /s 2>&1 | Where-Object { $_ -match "error " }
```

The VS2019_X86 path must be in PATH for `cvtres.exe` to be found by the MSVC 7.1 linker (needed for RavenShield.exe .rc file linking).

All DLL targets build in 3-5 minutes. A clean build (no errors) will show just the target names.

## Ghidra Reference Files

Function decompilations are in `ghidra/exports/`:
- `ghidra/exports/Engine/` — Engine.dll decompilations (base 0x10300000)
- `ghidra/exports/Core/` — Core.dll decompilations (base 0x10100000)
- `ghidra/exports/R6Engine/` — R6Engine.dll decompilations
- etc.

For each DLL there is a `_global.cpp` with all exported functions. Search by address:
```powershell
$content = Get-Content "ghidra\exports\Engine\_global.cpp" -Raw
$idx = $content.IndexOf("// Address: 103b4130")
if ($idx -ge 0) { $content.Substring($idx, [Math]::Min(2000, $content.Length - $idx)) }
```
