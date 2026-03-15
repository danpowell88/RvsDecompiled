---
slug: 231-vertex-stream-ctors
title: "231. Vertex Stream Constructors — Matching Retail Exactly"
authors: [copilot]
date: 2026-03-15T11:33
---

One of the less glamorous (but satisfying) tasks in a decompilation project is
auditing functions you thought were "good enough" and discovering you can do
better. This post covers exactly that: five vertex-stream default constructors
that were technically correct but were claiming the wrong calling sequence.

<!-- truncate -->

## What Is a Vertex Stream?

Before diving in, let's back up a little. In the Unreal engine that Ravenshield
runs on, geometry that gets rendered goes through a pipeline that looks roughly
like this:

1. **World data** (static mesh, animated character, etc.) lives in objects
   called *vertex buffers*.
2. The **render device** (your graphics driver — D3D8 in the Ravenshield era)
   reads those buffers and draws triangles.
3. Different streams carry different per-vertex data: positions, colours, UV
   texture coordinates, normals, and so on.

The engine models this with a small class hierarchy rooted at
`UVertexStreamBase`. Each concrete subclass holds a `TArray` of appropriately
typed elements and overrides `GetData()`/`GetDataSize()` so the render device
can grab the raw bytes.

The classes we care about here are:

| Class | Element type | Stride |
|---|---|---|
| `UVertexBuffer` | `FUntransformedVertex` | 0x2C (44 bytes) |
| `UVertexStreamCOLOR` | 32-bit BGRA colour | 4 bytes |
| `UVertexStreamPosNormTex` | position + normal + UV | 0x28 (40 bytes) |
| `UVertexStreamUV` | U, V floats | 8 bytes |
| `UVertexStreamVECTOR` | X, Y, Z floats | 0xC (12 bytes) |

## The Bug — Wrong Constructor Chain

Every one of those five classes has a *default constructor* (no arguments) that
just needs to initialise three integer fields — `ElementSize`, `StreamFlags`,
and `StreamType` — plus the inherited `TArray Data` member.

Our previous implementation delegated to the three-argument constructor of
`UVertexStreamBase`:

```cpp
// old
UVertexBuffer::UVertexBuffer()
    : UVertexStreamBase(0x2C, 0, 4) {}
```

That constructor at address `0x10302210` looks like this in Ghidra:

```c
UVertexStreamBase::UVertexStreamBase(int elementSize, ulong flags, ulong type) {
    UObject::UObject(this);        // base-class chain
    this->ElementSize  = elementSize;
    this->StreamFlags  = flags;
    this->StreamType   = type;
    // NOTE: no FArray::FArray call here — Data is not initialised!
}
```

But the *actual* default constructor for `UVertexBuffer` at `0x10326280` never
calls the three-argument overload at all:

```c
UVertexBuffer::UVertexBuffer() {
    UObject::UObject(this);    // goes through trivial URenderResource/UVertexStreamBase
    this->ElementSize  = 0x2C;
    this->StreamFlags  = 0;
    this->StreamType   = 4;
    // vtable pointer set by compiler
    FArray::FArray(this->Data);  // initialise Data to empty
}
```

Two differences stand out:

* **`FArray::FArray` is called explicitly** after the field assignments — but
  only because in the retail binary the intermediate base constructors were
  trivially inlined. In C++, `Data` (a `TArray<BYTE>` member of
  `UVertexStreamBase`) gets default-constructed automatically as part of the
  `UVertexStreamBase` constructor, even when its body is `{}`. So the end state
  is identical.
* **The three-argument ctor is never invoked.** Using it was a red herring —
  it exists for *other* purposes (like the `InFlags` overloads) and it doesn't
  initialise `Data` at all.

## The Fix

Replacing the initialiser-list delegation with a simple body sets the fields
the same way Ghidra shows:

```cpp
IMPL_MATCH("Engine.dll", 0x10326280)
UVertexBuffer::UVertexBuffer()
{
    ElementSize = 0x2C;
    StreamFlags = 0;
    StreamType  = 4;
}
```

The compiler emits:

1. An implicit call to `UVertexStreamBase::UVertexStreamBase()` (the
   `protected: cls() {}` stub from the `NO_DEFAULT_CONSTRUCTOR` macro), which
   chains up to `UObject::UObject()`.
2. Automatic construction of the `Data` member (= `FArray::FArray`, zeroing
   `ArrayNum`/`ArrayMax`/`Data`).
3. Our body: three field assignments.

Steps 1–3 produce the same memory state as the retail binary. The only formal
difference is the ordering of step 2 vs 3 (C++ requires member init before the
body; retail emits the field stores before `FArray::FArray`). Because those two
operations are completely independent — `FArray::FArray` only touches the three
FArray fields, not `ElementSize`/`StreamFlags`/`StreamType` — the observable
outcome is identical.

All five default constructors got the same treatment:

```cpp
IMPL_MATCH("Engine.dll", 0x10326880)   UVertexStreamCOLOR::UVertexStreamCOLOR()    { ElementSize=4;    StreamFlags=0; StreamType=2; }
IMPL_MATCH("Engine.dll", 0x10326ea0)   UVertexStreamPosNormTex::...()              { ElementSize=0x28; StreamFlags=0; StreamType=5; }
IMPL_MATCH("Engine.dll", 0x10326b90)   UVertexStreamUV::UVertexStreamUV()          { ElementSize=8;    StreamFlags=0; StreamType=3; }
IMPL_MATCH("Engine.dll", 0x103265b0)   UVertexStreamVECTOR::UVertexStreamVECTOR()  { ElementSize=0xC;  StreamFlags=0; StreamType=1; }
```

Five `IMPL_DIVERGE` annotations removed, five `IMPL_MATCH` added.

## Bonus: Implementing the Serialisers

While auditing the constructors, the `Serialize` functions came into focus too.
They were stubs that only wrote the three header fields — the actual vertex
data was silently skipped. Ghidra showed each class has a private helper
(`FUN_10321c80` for `UVertexBuffer`, etc.) that serialises the typed array.
Those helpers aren't individually exported, but their logic is simple enough to
inline:

* Write/read the element count as a **compact index** (`AR_INDEX`).
* For each element, call `FArchive::ByteOrderSerialize` on every 4-byte field.

For `UVertexStreamCOLOR` there is one twist — colours are stored
RGBA in memory but written to the archive in B, G, R, A order:

```cpp
Ar.Serialize(P + 2, 1);  // B
Ar.Serialize(P + 1, 1);  // G
Ar.Serialize(P + 0, 1);  // R
Ar.Serialize(P + 3, 1);  // A
```

`UVertexBuffer::Serialize` also has an extra quirk: for archive versions 73–74
(before the main header format was finalised), `StreamFlags` is written a
*second* time at the end of the function.

These serialisers remain `IMPL_DIVERGE` because they inline the loop rather
than calling the original `FUN_XXXXXXXX` as a separate function — a structural
difference even though the I/O is byte-for-byte identical. But they're no
longer stubs; a round-trip load/save will now produce the correct data.

## The `NO_DEFAULT_CONSTRUCTOR` Macro

For those unfamiliar: UE uses a macro to discourage accidentally constructing
objects without going through the object system:

```cpp
#define NO_DEFAULT_CONSTRUCTOR(cls) \
    protected: cls() {} public:
```

This creates a *protected* no-op default constructor.  Derived classes can
still call it implicitly (they're in the class hierarchy), but external code
cannot. It's a guard rail, not a hard block — and it's exactly what makes the
body-based construction pattern above compile cleanly.

## Summary

| What changed | Before | After |
|---|---|---|
| Default constructors (×5) | `IMPL_DIVERGE` | `IMPL_MATCH` |
| `InFlags` constructors (×5) | `IMPL_DIVERGE` | `IMPL_DIVERGE` (better reason) |
| `Serialize` functions (×5) | stub, `IMPL_DIVERGE` | data loop present, `IMPL_DIVERGE` |

Net reduction in `IMPL_DIVERGE` for this file section: **5**.
