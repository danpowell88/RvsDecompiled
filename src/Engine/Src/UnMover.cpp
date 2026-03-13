#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;
// --- AMover ---
void AMover::physMovingBrush(float)
{
}

void AMover::performPhysics(float)
{
}

int AMover::ShouldTrace(AActor*,DWORD TraceFlags)
{
	return TraceFlags & 2;
}

void AMover::AddMyMarker(AActor *)
{
}

INT* AMover::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AMover ---
void AMover::SetWorldRaytraceKey()
{
}

void AMover::Spawned()
{
	// Ghidra 0xd4f30: copy BasePos/BaseRot from this+0x234..0x24B to KeyPos0/KeyRot0 at +0x670..0x6A8.
	appMemcpy((BYTE*)this + 0x670, (BYTE*)this + 0x234, 12); // BasePos -> KeyPos0
	appMemcpy((BYTE*)this + 0x6A0, (BYTE*)this + 0x240, 12); // BaseRot -> KeyRot0
}

void AMover::SetBrushRaytraceKey()
{
}

void AMover::PostEditChange()
{
}

void AMover::PostEditMove()
{
}

void AMover::PostLoad()
{
	// Ghidra 0xd4f70: AActor::PostLoad, init position sentinel (-12345.678f = 0xC640E400)
	// at DeltaPosition fields, and store a default rotation at this+0x6B8..0x6C0.
	AActor::PostLoad();
	const DWORD kSentinel = 0xC640E400u; // -12345.678f
	*(DWORD*)((BYTE*)this + 0x694) = kSentinel;
	*(DWORD*)((BYTE*)this + 0x698) = kSentinel;
	*(DWORD*)((BYTE*)this + 0x69C) = kSentinel;
	// Store default rotation {0x7B, 0x1C8, 0x315} = Pitch/Yaw/Roll at +0x6B8
	*(INT*)((BYTE*)this + 0x6B8) = 0x7B;
	*(INT*)((BYTE*)this + 0x6BC) = 0x1C8;
	*(INT*)((BYTE*)this + 0x6C0) = 0x315;
}

void AMover::PostNetReceive()
{
	// Ghidra 0x7da40: AActor::PostNetReceive, then apply interpolated position
	// if location changed since PreNetReceive snapshot. Complex - simplified to super call.
	// Divergence: mover position interpolation state at +0x67C..0x6CC not updated.
	AActor::PostNetReceive();
}

void AMover::PostRaytrace()
{
}

void AMover::PreNetReceive()
{
	// Ghidra 0x78100: snapshot current position this+0x6D0 to a static global,
	// then call AActor::PreNetReceive. Divergence: snapshot not stored (not needed
	// without the full PostNetReceive interpolation).
	AActor::PreNetReceive();
}

void AMover::PreRaytrace()
{
	// Ghidra 0xd5460: copy FVector(0,0,0) from FVector0_exref into this+0x694..0x69C
	// (resets DeltaPosition sentinel before raytrace pass). Divergence: skip external ref;
	// zero the sentinel directly (same effect).
	appMemzero((BYTE*)this + 0x694, 12);
}


