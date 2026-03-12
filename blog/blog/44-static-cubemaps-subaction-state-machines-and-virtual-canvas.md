---
slug: 44-static-cubemaps-subaction-state-machines-and-virtual-canvas
title: "44. Static Cubemaps, SubAction State Machines, and Virtual Canvas"
authors: [danpo]
tags: [decompilation, texture, animation, canvas, scene-manager, batch-159]
---

Batch 159 picks up where the last batch's cleanup left off. The function targets
this time span three subsystems: the `FStaticCubemap` render interface (mirroring
a pattern we'd already solved for `FStaticTexture`), the `UVertMeshInstance` single-channel
animation system, and the `ASceneManager` sub-action machinery — including the
`UMatSubAction` base-class state machine that everything else depended on.

<!-- truncate -->

## FStaticCubemap: Same Pattern, Different Wrapper

`FStaticTexture` was solved in an earlier batch. It wraps a `UTexture*` and provides
a `FBaseTexture` interface (GetHeight, GetWidth, GetFormat, etc.) used by the renderer.

`FStaticCubemap` looked like it would be different — it wraps a `UCubemap` rather than
a plain `UTexture`. But the memory layout turned out to parallel `FStaticTexture`
closely, with one shift: the texture pointer is at `Pad[0]` (this+4) rather than
`Pad[8]`, and the CacheId QWORD begins at `Pad[4]` (this+8).

```cpp
// FStaticTexture layout
// Pad[0..7]  = CacheId (QWORD)
// Pad[8..11] = UTexture* pointer
// Pad[12..15] = Revision INT

// FStaticCubemap layout
// Pad[0..3]   = UCubemap* pointer
// Pad[4..11]  = CacheId (QWORD)
// Pad[12..15] = Revision INT
```

We confirmed this by cross-referencing the copy constructor (which copies 0x10 bytes
starting at this+4) and `GetCacheId` (which returns `*(QWORD*)(Pad+4)` = this+8).

Since `UCubemap` inherits from `UTexture`, all eight accessor methods could simply
cast the pointer and delegate:

```cpp
int FStaticCubemap::GetHeight()
{
    UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
    return tex ? tex->VSize : 0;
}

int FStaticCubemap::GetRevision()
{
    UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
    if (tex && tex->bRealtimeChanged) {
        ++(*(INT*)&Pad[12]);
        tex->bRealtimeChanged = 0;
    }
    return *(INT*)&Pad[12];
}
```

The `GetRevision` implementation is shared with `FStaticTexture`: it increments
a local revision counter when the texture marks itself as having changed, then
clears the flag. Renderers use this to detect when GPU-side data needs updating.

## UVertMeshInstance: Single-Channel Animation State

Vertex meshes in Unreal use a simpler animation system than skeletal meshes.
There's only one animation channel (channel 0), and state is stored directly
as flat fields on the instance rather than in a channel TArray.

The memory map we've been building up over several batches:

| Offset | Field |
|--------|-------|
| +0xB8 | FName: active sequence name |
| +0xBC | FLOAT: animation rate |
| +0xC0 | FLOAT: current frame |
| +0xC4 | FLOAT: end frame |
| +0xDC | INT: loop flag 0 |
| +0xE0 | INT: loop flag 1 |
| +0xE4 | INT: tween flag |

This batch filled in three methods using that map:

- **`StopAnimating()`** — clears the FName at +0xB8 to NAME_None, returns 1
- **`GetRenderBoundingBox()`** — delegates to `GetMesh()->GetRenderBoundingBox(Owner)`, same pattern as the already-implemented `GetRenderBoundingSphere`
- **`IsAnimTweening()`** — returns the raw INT at +0xE4

```cpp
int UVertMeshInstance::StopAnimating(INT)
{
    *(FName*)((BYTE*)this + 0xB8) = FName(NAME_None);
    return 1;
}

int UVertMeshInstance::IsAnimTweening(int)
{
    return *(INT*)((BYTE*)this + 0xE4);
}
```

## UMatSubAction: The Missing State Machine

The `UMatSubAction` hierarchy drives cutscene sub-actions — things like FOV changes,
game-speed lerps, orientation overrides, and camera shake effects. These are driven
by an `ASceneManager` ticking through a percentage value from 0.0 to 1.0.

Every sub-action calls `UMatSubAction::Update(float Pct, ASceneManager*)` at the
base of its call chain. That base implementation was returning 0 unconditionally
in our stub — meaning all sub-action `Update` methods were dead. The real
implementation is a simple state machine:

```cpp
int UMatSubAction::Update(float Pct, ASceneManager*)
{
    // State at this+0x2C: 0=idle, 1=running, 2=ending, 3=done
    BYTE state = *(BYTE*)((BYTE*)this + 0x2C);
    if (state == 2) {
        *(BYTE*)((BYTE*)this + 0x2C) = 3;  // ending -> done, signal stop
        return 0;
    }
    FLOAT StartPct = *(FLOAT*)((BYTE*)this + 0x4C);
    FLOAT EndPct   = *(FLOAT*)((BYTE*)this + 0x50);
    if (StartPct < Pct && Pct < EndPct) {
        *(BYTE*)((BYTE*)this + 0x2C) = 1;  // in range -> running
        return 1;
    }
    if (EndPct <= Pct) {
        *(BYTE*)((BYTE*)this + 0x2C) = 2;  // past end -> ending
    }
    return 1;
}
```

The `StartPct` and `EndPct` fields define which portion of the overall scene
percentage this sub-action is active for—each sub-action has its own window
within the full 0–1 scene timeline.

With the base class fixed, two derived classes became implementable:

**`USubActionGameSpeed::Update`** — lerps `LevelInfo.TimeDilation` (at LI+0x458)
from a saved start value to a target end value. The "saved start" field at
`this+0x58` is written once on the first active tick (when it's still 0.0).

**`USubActionSceneSpeed::Update`** — identical pattern, but targets
`SceneMgr+0x3C8` instead (the scene-local time scale, not the global LevelInfo
TimeDilation).

```cpp
int USubActionGameSpeed::Update(float Pct, ASceneManager* SceneMgr)
{
    if (!UMatSubAction::Update(Pct, SceneMgr)) return 0;
    // Get SceneManager via virtual GetSceneManager() at vtable+0x6C
    typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionGameSpeed*);
    ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
    if (!mgr) return 1;
    FLOAT* SavedStart = (FLOAT*)((BYTE*)this + 0x58);
    FLOAT* EndSpeed   = (FLOAT*)((BYTE*)this + 0x5C);
    ALevelInfo* LI    = *(ALevelInfo**)((BYTE*)mgr + 0x144);
    if (*SavedStart == 0.0f)
        *SavedStart = *(FLOAT*)((BYTE*)LI + 0x458);
    FLOAT t = (Pct - *(FLOAT*)((BYTE*)this + 0x4C)) / *(FLOAT*)((BYTE*)this + 0x54);
    t = Clamp(t, 0.0001f, 1.0f);
    if (*(BYTE*)((BYTE*)this + 0x2C) == 2) t = 1.0f;
    *(FLOAT*)((BYTE*)LI + 0x458) = (*EndSpeed - *SavedStart) * t + *SavedStart;
    return 1;
}
```

`USubActionOrientation::IsRunning` is also in this batch — it reads the state
byte and returns true if the sub-action is state 1 (running) or 2 (ending), but
only outside the editor:

```cpp
int USubActionOrientation::IsRunning()
{
    if (!GIsEditor) {
        BYTE state = *(BYTE*)((BYTE*)this + 0x2C);
        if (state == 1 || state == 2) return 1;
    }
    return 0;
}
```

## UCanvas::UseVirtualSize

`UCanvas::UseVirtualSize` is one of those functions that looks like it should be
one line but turns out to be a full virtual coordinate system toggle. It switches
between the canvas's "native" coordinate system and a virtual one with custom
dimensions and automatic stretch compensation.

The Ghidra decompilation at 0x89fd0 was clear enough to follow directly:

```cpp
void UCanvas::UseVirtualSize(int bEnable, float SizeX, float SizeY)
{
    if (bEnable == 0) {
        // Restore: set OrgX/OrgY from VirtualX/Y (saved dims)
        // or from viewport dimensions if virtual is unset.
        FLOAT vx = *(FLOAT*)((BYTE*)this + 0xA4);  // VirtualX
        FLOAT vy = *(FLOAT*)((BYTE*)this + 0xA8);  // VirtualY
        if (vx <= 0.0f || vy <= 0.0f) {
            INT* Viewport = *(INT**)((BYTE*)this + 0x7C);
            FLOAT w = (FLOAT)*(INT*)((BYTE*)Viewport + 0xA4);
            *(FLOAT*)((BYTE*)this + 0x40) = w;  // OrgX
            *(FLOAT*)((BYTE*)this + 0x44) = w;  // OrgY
        } else {
            *(FLOAT*)((BYTE*)this + 0x40) = vx;
            *(FLOAT*)((BYTE*)this + 0x44) = vy;
        }
        *(FLOAT*)((BYTE*)this + 0x94) = 1.0f;  // StretchX
        *(FLOAT*)((BYTE*)this + 0x98) = 1.0f;  // StretchY
    } else {
        // Save current OrgX/OrgY into VirtualX/VirtualY
        // then set up the new virtual coordinate system.
        // ...
        // Compute stretch ratios: StretchX = ViewportW / SizeX
    }
    // Always update HalfClipX/Y
    *(FLOAT*)((BYTE*)this + 0x48) = *(FLOAT*)((BYTE*)this + 0x40) * 0.5f;
    *(FLOAT*)((BYTE*)this + 0x4C) = *(FLOAT*)((BYTE*)this + 0x44) * 0.5f;
}
```

The UCanvas coordinate space has several layers: the "origin" clip (OrgX/OrgY),
the virtual size dimensions (VirtualX/VirtualY used to save the pre-virtual state),
and the stretch multipliers (StretchX/StretchY) that compensate for the coordinate
change. `UseVirtualSize(1, 1024, 768)` would set up a virtual 1024×768 space and
compute the appropriate stretch to map it to whatever the actual viewport dimensions
are.

## What's Next

Batch 160 will continue through the sub-action hierarchy (USubActionFade,
USubActionFOV) and pick up more of the `ASceneManager` path-following logic.
The scene manager code has been stubbed for a while — now that the sub-action
base class is correct, more of it becomes tractable.
