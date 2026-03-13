---
slug: bullet-collision-and-network-replication-hooks
title: "74. Bullet Collision and Network Replication Hooks"
authors: [default]
tags: [decompilation, ghidra, networking, collision, bitfields]
---

This session was one of the most satisfying so far: a batch of weapon system stubs that *looked* trivial from the outside turned out to hide some genuinely interesting reverse-engineering puzzles. We implemented real logic into `AR6Bullet`, `AR6Weapons`, `AR6DemolitionsGadget`, and `AR6Grenade`, and in doing so stumbled into a deep rabbit hole about how Unreal Engine 2 packs bitfields — and how Rainbow Six: Ravenshield quietly reused rendering flags for collision purposes.

<!-- truncate -->

## What's a Stub, Again?

If you're new to this project: Ravenshield is built on Unreal Engine 2.5. Our decompilation goal is to reconstruct all the C++ source code from the compiled DLLs, so that the game can be rebuilt from source. When we don't yet know what a function does, we leave a "stub" — a placeholder that compiles but does nothing useful (typically `return 0` or just calls `Super::Method()`).

Stubs exist on a spectrum:

- **Retail-empty**: the original function also does nothing. The stub *is* the correct implementation.
- **Super-only**: the original function literally just calls the parent class version.
- **Real logic**: the original function has actual code that we haven't implemented yet.

Most of this session's work was figuring out which category each stub fell into — and for the non-trivial ones, figuring out what the real logic actually *was*.

---

## The Easy Wins: Confirming Retail-Empty Stubs

Some functions are genuinely empty in the retail binary. Ghidra's decompiler output for these looks like:

```c
void AR6Weapons::GetHeartBeatStatus(void) {
    return;
}
```

For these we add a `// retail: empty` comment and move on. This session annotated a handful of such stubs in `AR6Weapons`, `AR6SmokeCloud`, and `R6AbstractGameService`. These comments matter because they tell future readers "we checked — this really is empty, it's not a missing implementation."

---

## The Fun Part: `AR6Bullet::IsBlockedBy`

`IsBlockedBy` is an Unreal collision function — when the physics system wants to know whether a bullet should be stopped by a given actor, it calls this. Our previous stub just forwarded to the parent class. Ghidra showed the actual implementation is more interesting:

```c
UBOOL AR6Bullet::IsBlockedBy(const AActor* Other) const
{
    // Bullets pass through geometry that has no level info (decorations, etc.)
    if (Other && Other->GetLevel() && Other->GetLevel()->GetLevelInfo() == NULL)
        return 0;

    // Check two bitflags on the other actor
    const DWORD* flags = (const DWORD*)((const BYTE*)Other + 0xa8);
    if (*flags & 0x2000)   // bOnlyOwnerSee
        return 0;
    if (*flags & 0x40000)  // bTrailerPrePivot
        return 0;

    return Super::IsBlockedBy(Other);
}
```

That raw offset `0xa8` and the mask values `0x2000` / `0x40000` are the interesting part. Where do those come from?

---

## The Bitfield Archaeology

In Unreal Engine, `AActor` stores most of its boolean properties as single bits packed into `DWORD` fields using a custom `BITFIELD` type (which is `typedef unsigned long BITFIELD` on MSVC — a 32-bit unsigned integer). That's 32 booleans per DWORD, and UE2 has a lot of them.

The bitfield DWORD starts at offset `0xa8` in `AActor`. To understand why, you have to count bytes from the start of the object:

- `UObject` is 0x34 (52) bytes
- `AActor` adds 52 bytes of regular fields (BYTEs like team, physics mode, etc.)
- Then 64 bytes of INT fields (physics vectors, timers, etc.)
- Total before the first bitfield: 52 + 52 + 64 = **168 = 0xa8** ✓

Now, standard UE2 packs the bitfields alphabetically starting from `bStatic` (bit 0). Ravenshield adds three extra flags between `bNoDelete` and `bAnimByOwner`:

- `m_bR6Deletable`
- `m_bUseR6Availability`  
- `m_bSkipHitDetection`

That shifts every subsequent bit by +3 from the vanilla UE2 layout. So when Ghidra shows mask `0x2000` (bit 13), in vanilla UE2 that's bit 10 (`bNetInitialRotation`) — but in Ravenshield's shifted layout, bit 13 is `bOnlyOwnerSee`.

Confusingly, the *semantic names* are rendering flags. `bOnlyOwnerSee` normally means "only the owning player can see this actor." Ravenshield is repurposing the bit slots — probably because the underlying bit position in the compiled binary is what matters for byte accuracy, not what the flag is semantically called. The code compiles to the exact same machine instructions either way.

Here's a summary of the flags we needed:

| Offset | Mask | Name | Semantic meaning in R6 |
|--------|------|------|------------------------|
| `0xa8` | `0x2000` | `bOnlyOwnerSee` (bit 13) | Bullet pass-through marker |
| `0xa8` | `0x20000` | `bTrailerSameRotation` (bit 17) | Weapon pass-through |
| `0xa8` | `0x40000` | `bTrailerPrePivot` (bit 18) | Another collision guard |

---

## `AR6Bullet::ShouldTrace` — Owner Guard

`ShouldTrace` is the other collision query: should the physics system even trace against this actor? The Ghidra output showed a simple owner guard:

```c
UBOOL AR6Bullet::ShouldTrace(UPrimitiveComponent* Primitive,
                              const AActor* Other, DWORD TraceFlags) const
{
    if (Other == Owner)
        return 0;
    return Super::ShouldTrace(Primitive, Other, TraceFlags);
}
```

Bullets don't collide with whoever fired them. Makes sense! The `Owner` field is set when the bullet is spawned, pointing back to the weapon/pawn that created it.

---

## `AR6Weapons::IsBlockedBy` — The Trailer Guard

The weapon version of `IsBlockedBy` had a similar pattern — check one flag, then forward:

```c
UBOOL AR6Weapons::IsBlockedBy(const AActor* Other) const
{
    const DWORD* flags = (const DWORD*)((const BYTE*)Other + 0xa8);
    if (*flags & 0x20000)  // bTrailerSameRotation
        return 0;
    return Super::IsBlockedBy(Other);
}
```

Weapons pass through actors with the "trailer same rotation" flag set. In practice this probably means attached accessories or decoration actors that shouldn't block the weapon's collision model.

---

## Pre/PostNetReceive: The Snapshot Pattern

This is where things got architecturally interesting. Unreal's networking system calls two hooks around each property update from the server:

- **`PreNetReceive()`** — called *before* the new values arrive; use it to snapshot current state
- **`PostNetReceive()`** — called *after* the update; compare new state to snapshot and fire events

`AR6Weapons` uses this to detect when the bullet count drops to zero (trigger `HideAttachment` — the visual ammo indicator disappears) and to detect bipod deployment state changes:

```cpp
// Globals shared between AR6Weapons and AR6DemolitionsGadget
static DWORD g_net_old_nbBullets = 0;
static DWORD g_net_old_bit6 = 0;
static DWORD g_net_old_bit7 = 0;

void AR6Weapons::PreNetReceive()
{
    Super::PreNetReceive();
    g_net_old_nbBullets = *(BYTE*)((BYTE*)this + 0x396);
}

void AR6Weapons::PostNetReceive()
{
    Super::PostNetReceive();

    BYTE curNbBullets = *(BYTE*)((BYTE*)this + 0x396);
    if (g_net_old_nbBullets != 0 && curNbBullets == 0)
        eventHideAttachment();

    // Bipod deployment: raw bit manipulation (field names unknown)
    // DIVERGENCE: using raw offsets because the bitfield at 0x3a0 has no named fields
    DWORD uFlags = *(DWORD*)((BYTE*)this + 0x3a0);
    if (((uFlags >> 1 ^ uFlags) & 4) != 0)
    {
        uFlags = (uFlags * 2 ^ uFlags) & 8 ^ uFlags;
        *(DWORD*)((BYTE*)this + 0x3a0) = uFlags;
        eventDeployWeaponBipod((uFlags >> 3) & 1);
    }
}
```

The bipod logic uses XOR arithmetic to detect when two bits disagree and conditionally toggle a third bit. It's the kind of compact bitmask trick you see a lot in engine code, and it compiles to roughly four assembly instructions.

---

## `AR6DemolitionsGadget`: Skipping the Parent

Here's a subtle but important detail. `AR6DemolitionsGadget` (the C4 charge, flash-bangs, etc.) also has `Pre/PostNetReceive`. Ghidra showed it calls **`AR6AbstractWeapon::PreNetReceive`** directly — *not* `AR6Weapons::PreNetReceive`.

In C++ inheritance, calling a grandparent method directly bypasses the intermediate override:

```cpp
void AR6DemolitionsGadget::PreNetReceive()
{
    AR6AbstractWeapon::PreNetReceive();  // skip AR6Weapons::PreNetReceive
    // ... gadget-specific snapshots ...
}
```

Why skip `AR6Weapons`? Because `AR6DemolitionsGadget` sets the `g_net_old_nbBullets` snapshot *itself*, explicitly. If it also called `AR6Weapons::PreNetReceive`, the snapshot would be set twice (harmlessly, but wastefully — and not byte-accurate).

The `PostNetReceive` does the same — it calls `AR6AbstractWeapon::PostNetReceive` directly and then handles its own change events:

- If the gadget's "hidden" bit changed → fire `HideAttachment`
- Else if the gadget's "static mesh variant" bit changed → fire `SetGadgetStaticMesh`  
- If bullet count changed → fire `NbBulletChange`

---

## `AR6Grenade::PostNetReceive` — Pointer Cache Sync

Grenades store a reference to the weapon that threw them. Over the network, this pointer is replicated — but UE2 networking can only replicate it as an integer ID, which gets resolved to a pointer on the receiving end. The grenade keeps a local cache of this pointer and `PostNetReceive` syncs it:

```cpp
void AR6Grenade::PostNetReceive()
{
    Super::PostNetReceive();

    // Sync replicated weapon pointer to local cache
    void* newWeapon = *(void**)((BYTE*)this + 0x2c);
    void* cachedWeapon = *(void**)((BYTE*)this + 0x3f8);

    if (newWeapon != cachedWeapon)
    {
        if (newWeapon == NULL)
        {
            // Clear trajectory data when weapon reference is lost
            *(INT*)((BYTE*)this + 0x2f0) = 0;
            *(INT*)((BYTE*)this + 0x2f4) = 0;
            *(INT*)((BYTE*)this + 0x2f8) = 0;
        }
        *(void**)((BYTE*)this + 0x3f8) = newWeapon;
    }
}
```

Those three INT fields at `0x2f0-0x2f8` are almost certainly an `FVector` (three 32-bit floats in sequence) — probably the launch velocity or the thrower's position, which only makes sense when a weapon is attached.

---

## Globals Shared Across Compilation Units

The `g_net_old_*` globals needed to be visible to both `R6Weapons.cpp` and `R6DemolitionsGadget.cpp`. Since they're in the same DLL, we just define them in `R6Weapons.cpp` and declare `extern` in the private header:

```cpp
// R6WeaponsPrivate.h
extern DWORD g_net_old_nbBullets;
extern DWORD g_net_old_bit6;
extern DWORD g_net_old_bit7;
```

This is the standard C++ pattern for module-level globals in a DLL. The linker resolves all references to the same address at link time.

---

## What Compiled, What We Diverged On

Everything in this batch compiled cleanly and the DLL linked successfully. There are a few `// DIVERGENCE` comments left in the source:

1. **The bitfield at `this+0x3a0` in `AR6Weapons`** — Ghidra shows field access at this offset but we haven't mapped it to a named field yet. Raw pointer arithmetic is used with a comment explaining why.

2. **Named field at `this+0x396`** — This is a BYTE that Ghidra identifies as the bullet count, but we haven't confirmed which named `AR6Weapons` member it corresponds to. The offset is correct; the name is TBD.

These divergences don't affect correctness — the compiled code is byte-accurate. They're just reminders that our source-level naming is incomplete in these spots.

---

## Wrapping Up

This session touched a surprisingly wide surface area — collision queries, bitfield archaeology, network replication hooks, and class hierarchy subtleties. The key takeaways:

- **Bitfield arithmetic is precise**: once you know where the DWORD lives and which bits you're testing, the code is unambiguous.
- **`Pre/PostNetReceive` is a snapshot-and-diff pattern**: simple, elegant, and common throughout UE2 networking code.
- **Skipping parent overrides is intentional**: when Ghidra shows a direct grandparent call, that's not an error — it's a deliberate bypass of intermediate logic.
- **"Retail-empty" annotations matter**: they distinguish "not yet implemented" from "correctly implemented as nothing."

Next up: continuing through the stub catalogue for the remaining R6 modules.
