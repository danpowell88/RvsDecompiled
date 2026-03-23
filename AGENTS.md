This is a decompliation project for Tom Clancys Rainbow Six Ravenshield.

The goal is a maintainable, readable and as close to byte accurate version of the game as possible that can be rebuilt and played. Byte accuracy should not come at the expensive of complicated code, where possible keep it accurate but readability and maintainability / simplicity should be preferred. Document any divergences from byte parity.

Keep a dev blog as progress continues in the /blog folder. The dev blog should be aimed at someone who is a programmer but not used to unmanaged and c++  and game engine code. Introduce concepts before delving deep into the technical implementation and ensure its explained and then when it is you may continue to go into technical detail. A dev blog should be created when anything interesting is completed or a new milestone is achieved. They can be both long and short and should be informative and light hearted while still providing some good technical and educational information. Include a section that outlines how much of the decomp project is left to do at the end of every post

The build must always compile and link.

Commit frequently when small pieces of work are done.

The blog uses Docusaurus with MDX. In blog post prose (outside of code blocks), bare `<` and `>` characters are interpreted as JSX tags and will cause build failures. Always wrap operators like `<=`, `>=`, `<<`, `>>`, or any angle-bracket expressions in backticks when writing them in markdown text.


## ⚠️ Blog Post Creation — ALWAYS use the script

**Never create a blog post file by hand.** Always use the generator script:

```powershell
python tools/new_blog_post.py "Your Post Title Here" --tags tag1,tag2
```

The script auto-assigns the next available number, sets the slug, and creates the file. After running it, open the created file and replace the placeholder body with your content.

**To verify the blog builds cleanly** (run after writing any post):
```powershell
cd blog && npm run build
```

## ⚠️ Blog Internal Links — ALWAYS use the full slug

When linking to another blog post from within a post, you **must** use the exact slug from that post's frontmatter, prefixed with `/blog/`. Never use relative paths (`../`) or guess the slug.

```markdown
<!-- CORRECT — use the exact slug from the target post's frontmatter -->
See [Post #286](/blog/286-hunting-ghosts-when-blocked-functions-weren-t-really-blocked)

<!-- WRONG — relative paths cause broken links -->
See [Post #286](../286-hunting-ghosts)

<!-- WRONG — guessing the slug (apostrophes become hyphens in slugs) -->
See [Post #286](/blog/286-hunting-ghosts-when-blocked-functions-werent-really-blocked)
```

To find the correct slug for a post:
```powershell
Select-String -Path "blog/blog/286-*.md" -Pattern "^slug:"
```

## Ground Truth Priority

**The SDK included in this repo is a community-maintained project and is NOT official / NOT always correct.**

When there is any conflict between the SDK headers and Ghidra analysis of the retail binaries:

1. **Ghidra is always the ground truth.** Function signatures, struct sizes, member offsets, calling conventions — all come from Ghidra analysis of the retail DLLs, not the SDK.

2. **The unoffical Ravenshield C SDK is a useful starting point / cross-reference only.** It can help identify parameter names and intent, but must not be blindly trusted for signatures, types, or struct layouts.
3. **UT99** Check Ut99PubSrc for a guide as to what things could look like, its an earlier engine version and the Ravenshield engine could have additional modifications so its not always correct.

3. **When adding a new declaration or shim** (e.g. adding a missing function to `EnginePrivate.h` or `CorePrivate.h`), derive the signature from Ghidra's decompilation output in `ghidra/exports/`, not from the SDK. Document the Ghidra address in a comment.

4. **When a SDK declaration disagrees with Ghidra**, the Ghidra-derived version wins. Note the discrepancy with a comment: `// DIVERGENCE from SDK: Ghidra shows N params, SDK shows M`.


5. **Retail parity attribution** — every function definition must be preceded by one of these macros (see `src/Core/Inc/ImplSource.h`):
   - `IMPL_MATCH("Foo.dll", 0xaddr)` — claims exact parity with retail binary; derived from Ghidra analysis. Address must be a **full virtual address** (e.g. `0x104766d0`), not a relative offset. Engine.dll base = `0x10300000`.
   - `IMPL_EMPTY("reason")` — retail is also trivially empty (Ghidra confirmed); only use when Ghidra confirms the body is empty
   - `IMPL_TODO("reason")` — **temporary** placeholder; Ghidra body identified at a known address but implementation not yet written, or blocked by an unresolved FUN_ helper that is itself being tracked. Use this instead of IMPL_DIVERGE when the function CAN eventually be implemented.
   - `IMPL_DIVERGE("reason")` — **permanent** divergence only. Valid reasons: defunct live services (GameSpy), Karma/MeSDK proprietary binary-only SDK, rdtsc CPUID chains, functions confirmed absent from the retail export table. NOT for "pending decompilation" or "blocked by FUN_ helper" — use IMPL_TODO for those.


   **IMPL_TODO vs IMPL_DIVERGE — the key question:** *Can this function ever match retail?*
   - Yes (just needs more work) → `IMPL_TODO`
   - No (permanent external constraint) → `IMPL_DIVERGE`

## Build Commands

**To build and check for errors (agents MUST use this):**
```powershell
cd C:\Users\danpo\Desktop\rvs\build-71
$VS2019_X86 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86"
$env:PATH = "C:\Users\danpo\Desktop\rvs\tools\toolchain\msvc71\bin;$VS2019_X86;$env:PATH"
$env:LIB = "C:\Users\danpo\Desktop\rvs\tools\toolchain\msvc71\lib;C:\Users\danpo\Desktop\rvs\tools\toolchain\winsdk\Lib;C:\Users\danpo\Desktop\rvs\tools\toolchain\dxsdk\Lib"
& "$VS2019_X86\nmake.exe" /s 2>&1 | Where-Object { $_ -match "error " }
```

**To verify byte-parity after building (compares rebuilt DLLs against retail):**
```powershell
cd C:\Users\danpo\Desktop\rvs\build-71
& "$VS2019_X86\nmake.exe" verify
```
The verify step runs `verify_byte_parity.py` against all IMPL_MATCH annotations and exits non-zero on any mismatch. Results are also written to `build-71/parity_report.txt`.

The VS2019_X86 path must be in PATH for `cvtres.exe` to be found by the MSVC 7.1 linker (needed for RavenShield.exe .rc file linking).

All DLL targets build in 3-5 minutes. A clean build (no errors) will show just the target names.


**Before adding, removing, or changing any parameter**, cross-check the mangled name in the module's `.def` file. Adding or removing even one parameter changes the mangled name and causes a linker error (`LNK2001`).

```powershell
# Check Engine.dll export for MoveActor — the mangled name encodes parameter types
Select-String -Path "src/Engine/Src/Engine.def" -Pattern "MoveActor"
# Output: ?MoveActor@ULevel@@UAEHPAVAActor@@VFVector@@VFRotator@@AAUFCheckResult@@HHHHH@Z
# HHHHH = 5 INT params — do NOT add a 6th without verifying the retail mangled name
```

Mangled name suffix type codes (most common):
| Code | C++ type |
|------|----------|
| `H` | `int` / `BOOL` |
| `M` | `float` |
| `N` | `double` |
| `E` | `unsigned char` / `BYTE` |
| `G` | `unsigned short` / `WORD` |
| `I` | `unsigned int` / `DWORD` |
| `_N` | `bool` |
| `PA...` | pointer to … |
| `V...@@` | value type (class/struct) |
| `AA...` | reference to … |

**The lesson from MoveActor:** A `FLOAT fStepDist` 10th param was mistakenly added, generating `HHHHHM@Z` in the `.obj` but the `.def` exports `HHHHH@Z`. Always count the trailing type codes before touching a signature.

## Ghidra Reference Files

Function decompilations are in `ghidra/exports/`:
- `ghidra/exports/Engine/` — Engine.dll decompilations (base 0x10300000)
- `ghidra/exports/Core/` — Core.dll decompilations (base 0x10100000)
- `ghidra/exports/R6Engine/` — R6Engine.dll decompilations
- etc.

For each DLL there is a `_global.cpp` (decompiled C) and `_global.asm` (raw disassembly) with all exported functions. When the decompiler output is ambiguous, check the `.asm` for ground truth.

**When to use raw exports vs structured reports:**
- Need the **full decompiled body** of a function → `_global.cpp` / `_unnamed.cpp`
- Need the **exact instruction bytes** or ambiguous operand encoding → `_global.asm` / `_unnamed.asm`
- Need **metadata** (size, params, convention, vtable slot, struct offset) → use the JSON reports below instead

Search by address in C decompilation:
```powershell
$content = Get-Content "ghidra\exports\Engine\_global.cpp" -Raw
$idx = $content.IndexOf("// Address: 0x103b4130")
if ($idx -ge 0) { $content.Substring($idx, [Math]::Min(2000, $content.Length - $idx)) }
```

Search by address in assembly:
```powershell
$content = Get-Content "ghidra\exports\Engine\_global.asm" -Raw
$idx = $content.IndexOf("; Address: 0x103b4130")
if ($idx -ge 0) { $content.Substring($idx, [Math]::Min(2000, $content.Length - $idx)) }
```

## Structured Analysis Reports

Pre-computed analysis data lives in `ghidra/exports/reports/`. Each report type exists per-binary (16 total). These JSON files are the preferred way to look up metadata rather than searching raw .cpp/.asm files.

**Quick decision guide — "I need to…":**

| I need to… | Use this report | Example query |
|---|---|---|
| Find small/easy functions to implement next | `{Module}_function_index.json` | Sort by `size`, filter `exported` and not `unnamed` |
| Check a function's calling convention or param count | `{Module}_function_index.json` | Look up by `addr` or `name` |
| Validate a class's vtable layout or slot order | `{Module}_vtables.json` | Find class by name, check slot indices |
| Check `sizeof(ClassName)` or member offsets | `{Module}_structs.json` | Look up struct by name |
| Find what a function calls (or what calls it) | `{Module}_callgraph.json` | Search `edges` by caller/callee |
| Find functions with no dependencies (safe to start) | `{Module}_callgraph.json` | Use `leaf_functions` list |
| Decide which FUN_ helper to resolve first | `blocker_map.json` | Check `top_blockers` — highest impact first |
| See overall project progress or per-DLL status | `progress_report.json` | Read `summary` or `per_dll` |
| Look up a function's mangled export name | `{Module}_function_index.json` | Search by `name`, read `mangled` field |
| Check how many functions a DLL has total | `{Module}_function_index.json` | Read `total_functions` from top-level |

### Function Index (`{Module}_function_index.json`)
Per-function: address, size (bytes), calling convention, param count, return type, mangled name, exported flag. **Use this to find quick-win functions (sort by size), check calling conventions, or locate unexported helpers.**

```powershell
# Find all Engine.dll functions smaller than 20 bytes (easy IMPL_MATCH targets)
python -c "import json; data=json.load(open('ghidra/exports/reports/Engine_function_index.json')); [print(f['addr'],f['size'],f['name']) for f in data['functions'] if f['size']<20 and f['exported'] and not f['unnamed']]"
```

### Vtable Layouts (`{Module}_vtables.json`)
Per-class vtable: base address, slot count, method name at each slot offset. **Use this to validate virtual dispatch and check vftable slot assignments.**

```powershell
# Look up AActor vtable layout in Engine.dll
python -c "import json; data=json.load(open('ghidra/exports/reports/Engine_vtables.json')); vt=[v for v in data['vtables'] if 'AActor' in v['class']]; [print(v['class'],v['slot_count'],'slots') for v in vt]"
```

### Struct/Class Layouts (`{Module}_structs.json`)
Per-struct: name, size, alignment, member offsets and types. **Use this for sizeof() validation and offset arithmetic checks.**

### Call Graph (`{Module}_callgraph.json`)
Intra-DLL caller→callee edges, leaf functions (no outgoing calls), root functions (no incoming calls). **Use leaf functions as safe starting points for implementation — they have no internal dependencies.**

### FUN_ Blocker Map (`blocker_map.json`)
Maps every unresolved `FUN_XXXXXXXX` helper to the named functions that depend on it, sorted by impact. **Use this to prioritize which unnamed helpers to identify first.**

```powershell
# Top 10 blockers (resolving these unblocks the most functions)
python -c "import json; data=json.load(open('ghidra/exports/reports/blocker_map.json')); [print(b['name'],b['blocks'],'blocked') for b in data['top_blockers'][:10]]"
```

### Progress Report (`progress_report.json` / `progress_summary.txt`)
Per-DLL and overall counts of IMPL_MATCH, IMPL_EMPTY, IMPL_TODO, IMPL_DIVERGE annotations vs total Ghidra function count. **Re-generate after implementing functions:**

```powershell
python tools/gen_progress_report.py
```

### Regenerating All Analysis

To re-run the full Ghidra analysis pipeline (imports, symbols, exports, vtables, structs, callgraph, function index):
```powershell
$env:GHIDRA_HOME = "C:\Users\danpo\Desktop\rvs\tools\ghidra"
.\tools\run_headless.ps1 -SkipImport   # re-run scripts on existing project
```

To run just the standalone tools (no Ghidra needed):
```powershell
python tools/gen_blocker_map.py
python tools/gen_progress_report.py
```
