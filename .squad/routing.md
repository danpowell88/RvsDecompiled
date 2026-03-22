# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Ghidra analysis, IMPL macros, architecture calls | John Wick | IMPL_MATCH vs IMPL_DIVERGE decisions, vtable layout, struct sizing, calling convention disputes |
| Code review, PR review | John Wick | Review decompiled functions for accuracy and correctness |
| C++ implementation of decompiled functions | Jack Reacher | Translating Ghidra C output to clean C++, guard/unguard patterns, type resolution |
| Batch function implementation | Jack Reacher | Working through large blocks of functions from a single class or module |
| Build system, toolchain, linker errors | Ethan Hunt | nmake errors, .def file mangled names, cvtres, LNK errors, CMake |
| Tools and scripts to accelerate decompilation | Ethan Hunt | bindiff.py, funcmatch.py, import helpers, analysis scripts, PowerShell tooling |
| UT99/UE reference lookup | Jason Bourne | Finding equivalent functions in UT99 source, comparing UT99 vs Ravenshield implementations |
| UnrealScript (.uc) source lookup | Jason Bourne | 1.56/1.66 .uc source cross-reference, native function table analysis |
| SDK header analysis | Jason Bourne | Raven_Shield_C_SDK struct layouts, 432Core Inc headers, Unreal Engine type resolution |
| Binary comparison, byte accuracy | Sarah Connor | IMPL_MATCH address verification, bindiff.py runs, regression checks |
| Build verification | Sarah Connor | Confirming the build compiles and links after changes |
| Dev blog posts | Wade Wilson | Writing Docusaurus MDX blog posts, explaining engine concepts, progress milestones |
| Session logging | Scribe | Automatic — never needs routing |
| Work queue monitoring | Ralph | GitHub issues, PR status, board management |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze, assign `squad:{member}` label | John Wick |
| `squad:john-wick` | Lead decompiler analysis work | John Wick |
| `squad:jack-reacher` | Implementation tasks | Jack Reacher |
| `squad:ethan-hunt` | Build/tooling tasks | Ethan Hunt |
| `squad:jason-bourne` | Reference/lookup tasks | Jason Bourne |
| `squad:sarah-connor` | Verification/QA tasks | Sarah Connor |
| `squad:wade-wilson` | Blog post tasks | Wade Wilson |

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for simple questions.
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a function is implemented, Sarah Connor can verify it simultaneously.
7. **Ground truth is Ghidra.** John Wick's IMPL decisions override SDK claims.
8. **Build must always compile.** Ethan Hunt is the last line of defense before any commit.

---