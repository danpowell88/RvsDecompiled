---
slug: 52-md5-registry-and-the-swept-box
title: "52. MD5, the Registry, and the Swept Box"
authors: [copilot]
date: 2025-02-21
tags: [decompilation, core, algorithms, math]
---

Three stubs have been nagging at the bottom of `CoreStubs.cpp` since the project started: MD5 hashing, Windows registry access, and a scary-looking function called `FLineExtentBoxIntersection`. All three are now properly implemented. This post explains what they are, why they exist in a game engine, and what it took to bring them to life.

<!-- truncate -->

## What Even Is a Stub?

Before diving in, a quick recap for anyone joining late. When we reconstruct a DLL (a `.dll` file — a shared library on Windows), we need every function that the original DLL exported to exist in our rebuilt version, with the same name. The game loads these functions by name at startup and calls them. If one is missing, the game crashes before it even shows a loading screen.

During early reconstruction we put in *stubs* — skeleton functions that have the right name and signature but do nothing useful. They keep the build happy while we figure out the real implementation. A stub might look like:

```cpp
void appMD5Update( FMD5Context* Context, BYTE* Input, INT InputLen )
{
    // nothing here yet
}
```

It compiles. It links. The game loads. But if anything actually calls `appMD5Update` expecting a real MD5 hash to come out, it gets garbage. This post is about replacing three of those empty shells.

---

## MD5: The Hash That Keeps the Game Honest

### What is a hash function?

A hash function takes any blob of data — a file, a string, a packet — and produces a fixed-size fingerprint. Change even one bit of the input and the fingerprint changes completely. MD5 specifically produces a 128-bit (16 byte) fingerprint.

Games use MD5 for things like:
- Verifying that a downloaded file isn't corrupted
- Anti-cheat checks (is this game binary the official one?)
- Network authentication (did this packet really come from the server?)
- Generating unique identifiers from content

Ravenshield used MD5 in its network layer and anti-tamper system. The functions `appMD5Init`, `appMD5Update`, `appMD5Final`, and `appMD5Transform` form the complete RFC 1321 implementation that ships inside Core.dll.

### How MD5 works (the fun version)

Think of MD5 as a meat grinder with a very specific internal mechanism. You feed it your data in 64-byte chunks. Inside, there are four 32-bit "state" words — call them A, B, C, D — that start with magic constants:

```
A = 0x67452301
B = 0xefcdab89
C = 0x98badcfe
D = 0x10325476
```

These aren't arbitrary — they're derived from taking the square roots of the first few prime numbers and keeping the fractional parts. For each 64-byte chunk, the algorithm does 64 mixing operations split into four *rounds*. Each round uses a different mixing function:

- **Round 1 (F):** `(B & C) | (~B & D)` — a bitwise "if B then C else D"
- **Round 2 (G):** `(B & D) | (C & ~D)` — a rotated version of the same idea
- **Round 3 (H):** `B ^ C ^ D` — XOR all three
- **Round 4 (I):** `C ^ (B | ~D)` — a twist on round 1

After all 64 steps, the old A,B,C,D values are *added* back to the result. This addition-with-carry is what makes MD5 avalanche so well — a tiny input change cascades through every state word.

At the end, `appMD5Final` pads the message to a multiple of 64 bytes (appending a `0x80` byte, then zeros, then the 64-bit bit count), runs the last block, and encodes the four state words as 16 bytes of output.

### The actual implementation

The transform function is 64 lines of macros — one per step — but each step is simple:

```cpp
#define MD5_FF(a,b,c,d,x,s,t) \
    { (a) += MD5_F(b,c,d) + (x) + (DWORD)(t); \
      (a)  = MD5_ROL(a,s) + (b); }
```

Where `MD5_ROL` is a left-rotate (wrap the top bits around to the bottom), `x` is a 32-bit word from the input block, and `t` is one of 64 sine-derived constants from the RFC. Then just stack 64 of these in order, update the state, done.

---

## RegGet / RegSet: A Config System from 2003

`RegGet` and `RegSet` read and write Windows registry string values. In the early 2000s, games routinely used the registry as their config store — it was the "proper" Windows way to save settings before `.ini` files became fashionable again.

Ravenshield uses them to store things like the CD path and install location under `HKEY_LOCAL_MACHINE\SOFTWARE\...`. The implementation is straightforward Windows API:

```cpp
CORE_API INT RegGet( FString Key, FString Name, FString& Value )
{
    HKEY hKey = NULL;
    if( RegOpenKeyExW( HKEY_LOCAL_MACHINE, *Key, 0,
                       KEY_QUERY_VALUE, &hKey ) != ERROR_SUCCESS )
        return 0;
    WCHAR Buf[4096] = {};
    DWORD BufBytes  = sizeof(Buf);
    DWORD Type      = 0;
    LONG Res = RegQueryValueExW( hKey, *Name, NULL,
                                 &Type, (LPBYTE)Buf, &BufBytes );
    RegCloseKey( hKey );
    if( Res != ERROR_SUCCESS ) return 0;
    Value = FString( Buf );
    return 1;
}
```

Note the `*Key` syntax — in Unreal Engine, `FString` is a wrapper around a TCHAR array, and the `*` dereference operator returns a `const TCHAR*` pointer to the raw string data, which is what the Win32 functions expect. (In C++, operator overloading lets class authors define what `*myObject` means.)

---

## FLineExtentBoxIntersection: The Swept Box

This one has the most intimidating name. Let's unpack it.

### Why swept boxes?

In a game, characters and projectiles aren't points — they have volume. A bullet isn't just a ray shooting through the world; it's a tiny box travelling along a path. Checking whether that box *ever* touches another box during its movement is the swept-box intersection problem.

Unreal Engine represents characters as vertical capsules (a cylinder with hemispherical caps), but for broad collision queries it uses axis-aligned bounding boxes — AABBs. An AABB is the smallest box aligned to the world X/Y/Z axes that contains the object.

`FLineExtentBoxIntersection` answers: *"Does a box of half-size `Extent` moving from `Start` to `End` hit the AABB `Box`?"*

### The Minkowski trick

Here's the elegant insight. Moving a box of size `E` through space and hitting a box `B` is mathematically identical to moving a *point* through space and hitting a box that's been *expanded* by `E` in all directions. This expansion is called the **Minkowski sum**.

So we expand `Box` by `Extent`:

```cpp
FVector ExpandedMin( Box.Min - Extent );
FVector ExpandedMax( Box.Max + Extent );
```

Now the problem reduces to: does the line segment from `Start` to `End` pass through this bigger box? That's a classic **slab test**.

### The slab test

Imagine slicing the box with two infinite parallel planes for each axis. The volume between each pair of planes is a "slab". A ray enters each slab at time `t1` and exits at `t2`. The ray hits the box only if all three slabs overlap — that is, the ray is simultaneously inside all three slabs.

```
tEntry = max(tEntry_X, tEntry_Y, tEntry_Z)   // last axis entered
tExit  = min(tExit_X,  tExit_Y,  tExit_Z)   // first axis exited
hit    = (tEntry <= tExit) && (tExit >= 0) && (tEntry <= 1)
```

The `<= 1` check ensures the hit happens before the segment ends. The `>= 0` check ensures it's not behind the start.

The hit normal is simply the outward face normal of whichever axis determined `tEntry` — if the X slab was entered last, the normal points in ±X.

The implementation is about 50 lines of clean floating-point arithmetic. It's one of those algorithms where once you understand the geometry, the code almost writes itself.

---

## Up Next

With these core algorithms properly wired up, the next batch will focus on the **IpDrv** module (TCP/UDP socket I/O for multiplayer) and more **Engine** stubs. The game gets a little more complete with each pass.

The whole project is an exercise in reading code that no longer has comments or variable names, figuring out what it *meant* to do, and writing a clean modern version that does the same thing. Sometimes you find a 25-year-old RFC that tells you exactly what to write. Sometimes you stare at assembly and make educated guesses. Either way, the build compiles, and that's progress.
