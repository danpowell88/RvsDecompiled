#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;
// --- AMover ---
void AMover::physMovingBrush(float DeltaTime)
{
	guard(AMover::physMovingBrush);
	// Ghidra 0x12bc10: cubic/linear interpolation between keyframes.
	// Clamp MoverEncroachType byte at +0x397 to [0, 0x18].
	// Main loop interpolates position and rotation, checks encroach, fires notifies.
	// TODO: full implementation — complex interpolation state machine with many
	//       local FVector/FRotator temporaries and unidentified actor-move helpers.
	DWORD key = (DWORD)(BYTE)*(BYTE*)((BYTE*)this + 0x397);
	if ((INT)key < 0)  key = 0;
	else if (key > 0x17) key = 0x18;
	(void)DeltaTime;
	(void)key;
	unguard;
}

void AMover::performPhysics(float DeltaTime)
{
	guard(AMover::performPhysics);
	// TODO: RDTSC profiling bookend (DAT_10799554, DAT_1079976c — unknown globals)
	void** vtbl = *(void***)this;
	switch (*(BYTE*)((BYTE*)this + 0x2C)) // Physics
	{
	case 0x2: // PHYS_Falling: vtable +0x130 = physWalking
		((void(__thiscall*)(void*,float,INT))vtbl[0x130/4])(this, DeltaTime, 0);
		break;
	case 0x6: // PHYS_Projectile
		physProjectile(DeltaTime, 0);
		break;
	case 0x8: // PHYS_MovingBrush (AMover-specific)
		physMovingBrush(DeltaTime);
		break;
	case 0xA: // PHYS_Trailer
		physTrailer(DeltaTime);
		break;
	case 0xD: // PHYS_Karma: vtable +0x144 = physKarma_internal
		((void(__thiscall*)(void*,float))vtbl[0x144/4])(this, DeltaTime);
		break;
	case 0xE: // PHYS_KarmaRagDoll
		physKarmaRagDoll(DeltaTime);
		break;
	}
	// Set net dirty flag for non-static physics modes
	if ( *(char*)((BYTE*)this + 0xA4) < 0
	  && *(BYTE*)((BYTE*)this + 0x2C) != 0x5  // PHYS_Rotating
	  && *(BYTE*)((BYTE*)this + 0x2C) != 0x8  // PHYS_MovingBrush
	  && *(BYTE*)((BYTE*)this + 0x2C) != 0x0) // PHYS_None
	{
		*(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000;
	}
	// Apply rotation physics if DesiredRotation is non-zero
	if (!((FRotator*)((BYTE*)this + 0x2F0))->IsZero()
	    && (*(BYTE*)((BYTE*)this + 0xAC) & 4) == 0)
	{
		BYTE phys = *(BYTE*)((BYTE*)this + 0x2C);
		if ( phys != 0x5 // PHYS_Rotating
		  || (*(DWORD*)((BYTE*)this + 0x3B8) & 0x4000) == 0
		  || *(float*)(*(INT*)((BYTE*)this + 0x144) + 0x45C) - *(float*)((BYTE*)this + 0xB4) < 2.0f)
		{
			physicsRotation(DeltaTime);
		}
	}
	// Dispatch pending PostTouch event
	UObject* pendingTouch = *(UObject**)((BYTE*)this + 0x188);
	if (pendingTouch)
	{
		float selfRef = (float)(INT)this; // UE2 script-call convention: pass this as float
		UFunction* fn = pendingTouch->FindFunctionChecked(ENGINE_PostTouch, 0);
		(*(void(__thiscall**)(UObject*, UFunction*, void*, INT))(*(INT*)pendingTouch + 0x10))
			(pendingTouch, fn, &selfRef, 0);
		INT next = *(INT*)((BYTE*)this + 0x188);
		*(INT*)((BYTE*)this + 0x188) = *(INT*)(next + 0x188);
		*(INT*)(next + 0x188) = 0;
	}
	// TODO: RDTSC profiling end
	unguard;
}

int AMover::ShouldTrace(AActor*,DWORD TraceFlags)
{
	return TraceFlags & 2;
}

void AMover::AddMyMarker(AActor *)
{
	guard(AMover::AddMyMarker);
	// Ghidra 0x1651d0: shared empty-stub address — function body is empty.
	unguard;
}

INT* AMover::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AMover ---
void AMover::SetWorldRaytraceKey()
{
	guard(AMover::SetWorldRaytraceKey);
	// Ghidra 0xd5520: clamp WorldRaytraceKey, remove from hash, reposition, add to hash.
	BYTE key = *(BYTE*)((BYTE*)this + 0x39A); // WorldRaytraceKey
	if (key == 0xFF) return;
	if (key > 0x16) key = 0x17;
	*(BYTE*)((BYTE*)this + 0x39A) = key;
	// Remove actor from collision hash if it has one
	INT lvl  = *(INT*)((BYTE*)this + 0x328);
	void* hash = *(void**)(lvl + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash; // vtable
		((void(__thiscall*)(void*,AMover*))hv[3])(hash, this); // RemoveActor
	}
	// Compute new Location = KeyPos[key] + BasePos
	BYTE* kp = (BYTE*)this + (DWORD)key * 0xC + 0x430;
	float nx = *(float*)(kp + 0x0) + *(float*)((BYTE*)this + 0x670);
	float ny = *(float*)(kp + 0x4) + *(float*)((BYTE*)this + 0x674);
	float nz = *(float*)(kp + 0x8) + *(float*)((BYTE*)this + 0x678);
	*(float*)((BYTE*)this + 0x234) = nx;
	*(float*)((BYTE*)this + 0x238) = ny;
	*(float*)((BYTE*)this + 0x23C) = nz;
	// Compute new Rotation = BaseRot + KeyRot[key]
	FRotator* baseRot = (FRotator*)((BYTE*)this + 0x6A0);
	FRotator* keyRot  = (FRotator*)((BYTE*)this + (DWORD)key * 0xC + 0x550);
	FRotator newRot   = *baseRot + *keyRot;
	*(FRotator*)((BYTE*)this + 0x240) = newRot;
	// Re-add actor to hash at new key position
	hash = *(void**)(*(INT*)((BYTE*)this + 0x328) + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash;
		((void(__thiscall*)(void*,AMover*,BYTE*))hv[2])(hash, this, (BYTE*)keyRot); // AddActor
	}
	unguard;
}

void AMover::Spawned()
{
	// Ghidra 0xd4f30: copy BasePos/BaseRot from this+0x234..0x24B to KeyPos0/KeyRot0 at +0x670..0x6A8.
	appMemcpy((BYTE*)this + 0x670, (BYTE*)this + 0x234, 12); // BasePos -> KeyPos0
	appMemcpy((BYTE*)this + 0x6A0, (BYTE*)this + 0x240, 12); // BaseRot -> KeyRot0
}

void AMover::SetBrushRaytraceKey()
{
	guard(AMover::SetBrushRaytraceKey);
	// Ghidra 0xd5680: same as SetWorldRaytraceKey but uses BrushRaytraceKey (+0x39B),
	// no 0xFF guard, and clamps unconditionally to max 0x17.
	BYTE key = *(BYTE*)((BYTE*)this + 0x39B); // BrushRaytraceKey
	if (key > 0x16) key = 0x17;
	*(BYTE*)((BYTE*)this + 0x39B) = key;
	// Remove actor from collision hash
	INT lvl  = *(INT*)((BYTE*)this + 0x328);
	void* hash = *(void**)(lvl + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash;
		((void(__thiscall*)(void*,AMover*))hv[3])(hash, this);
	}
	// Compute new Location = KeyPos[key] + BasePos
	BYTE* kp = (BYTE*)this + (DWORD)key * 0xC + 0x430;
	float nx = *(float*)(kp + 0x0) + *(float*)((BYTE*)this + 0x670);
	float ny = *(float*)(kp + 0x4) + *(float*)((BYTE*)this + 0x674);
	float nz = *(float*)(kp + 0x8) + *(float*)((BYTE*)this + 0x678);
	*(float*)((BYTE*)this + 0x234) = nx;
	*(float*)((BYTE*)this + 0x238) = ny;
	*(float*)((BYTE*)this + 0x23C) = nz;
	// Compute new Rotation = BaseRot + KeyRot[key]
	FRotator* baseRot = (FRotator*)((BYTE*)this + 0x6A0);
	FRotator* keyRot  = (FRotator*)((BYTE*)this + (DWORD)key * 0xC + 0x550);
	FRotator newRot   = *baseRot + *keyRot;
	*(FRotator*)((BYTE*)this + 0x240) = newRot;
	// Re-add actor to hash
	hash = *(void**)(*(INT*)((BYTE*)this + 0x328) + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash;
		((void(__thiscall*)(void*,AMover*,BYTE*))hv[2])(hash, this, (BYTE*)keyRot);
	}
	unguard;
}

void AMover::PostEditChange()
{
	guard(AMover::PostEditChange);
	// Ghidra 0xd52a0: call parent, clamp key, recompute BasePos/BaseRot from
	// current Location/KeyPos, then update Location/Rotation to key position.
	AActor::PostEditChange();
	BYTE key = *(BYTE*)((BYTE*)this + 0x397);
	if (key > 0x16) key = 0x17;
	*(BYTE*)((BYTE*)this + 0x397) = key;
	// BasePos = Location - SavedPos
	float bpX = *(float*)((BYTE*)this + 0x234) - *(float*)((BYTE*)this + 0x67C);
	float bpY = *(float*)((BYTE*)this + 0x238) - *(float*)((BYTE*)this + 0x680);
	float bpZ = *(float*)((BYTE*)this + 0x23C) - *(float*)((BYTE*)this + 0x684);
	*(float*)((BYTE*)this + 0x670) = bpX;
	*(float*)((BYTE*)this + 0x674) = bpY;
	*(float*)((BYTE*)this + 0x678) = bpZ;
	// BaseRot = Rotation - SavedRot (FRotator subtract)
	FRotator* rot     = (FRotator*)((BYTE*)this + 0x240);
	FRotator  bpRot   = *rot - *(FRotator*)&bpX; // uses temp FRotator at bpX/Y/Z
	*(FRotator*)((BYTE*)this + 0x6A0) = bpRot;
	// Snap KeyPos[key] and KeyRot[key] from SavedPos/SavedRot
	BYTE* kp = (BYTE*)this + (DWORD)key * 0xC;
	*(float*)(kp + 0x430) = *(float*)((BYTE*)this + 0x67C);
	*(DWORD*)(kp + 0x434) = *(DWORD*)((BYTE*)this + 0x680);
	*(DWORD*)(kp + 0x438) = *(DWORD*)((BYTE*)this + 0x684);
	*(DWORD*)(kp + 0x550) = *(DWORD*)((BYTE*)this + 0x6AC);
	*(DWORD*)(kp + 0x554) = *(DWORD*)((BYTE*)this + 0x6B0);
	*(DWORD*)(kp + 0x558) = *(DWORD*)((BYTE*)this + 0x6B4);
	// Recompute Location = KeyPos[key] + BasePos
	float nx = *(float*)(kp + 0x430) + *(float*)((BYTE*)this + 0x670);
	float ny = *(float*)(kp + 0x434) + *(float*)((BYTE*)this + 0x674);
	float nz = *(float*)(kp + 0x438) + *(float*)((BYTE*)this + 0x678);
	*(float*)((BYTE*)this + 0x234) = nx;
	*(float*)((BYTE*)this + 0x238) = ny;
	*(float*)((BYTE*)this + 0x23C) = nz;
	// Recompute Rotation = BaseRot + KeyRot[key]
	FRotator newRot = *(FRotator*)((BYTE*)this + 0x6A0) + *(FRotator*)&nx;
	*(FRotator*)((BYTE*)this + 0x240) = newRot;
	// vtable +0x80: move-to-key helper (unknown name, Ghidra: *(int*)this + 0x80)
	void** vtbl = *(void***)this;
	BYTE* pKeyRot = (BYTE*)this + (DWORD)key * 0xC + 0x550;
	((void(__thiscall*)(void*,BYTE*,BYTE*))vtbl[0x80/4])(this, (BYTE*)((BYTE*)this + 0x6AC), pKeyRot);
	unguard;
}

void AMover::PostEditMove()
{
	guard(AMover::PostEditMove);
	// Ghidra 0xd5090: if key==0, update BasePos from Location-SavedPos and BaseRot.
	// Otherwise update KeyPos[key]/KeyRot[key] from Location delta, then resync.
	BYTE key = *(BYTE*)((BYTE*)this + 0x397);
	if (key == 0)
	{
		// BasePos = Location - SavedPos
		float bpX = *(float*)((BYTE*)this + 0x234) - *(float*)((BYTE*)this + 0x67C);
		float bpY = *(float*)((BYTE*)this + 0x238) - *(float*)((BYTE*)this + 0x680);
		float bpZ = *(float*)((BYTE*)this + 0x23C) - *(float*)((BYTE*)this + 0x684);
		*(float*)((BYTE*)this + 0x670) = bpX;
		*(float*)((BYTE*)this + 0x674) = bpY;
		*(float*)((BYTE*)this + 0x678) = bpZ;
		FRotator bpRot = *(FRotator*)((BYTE*)this + 0x240) - *(FRotator*)&bpX;
		*(FRotator*)((BYTE*)this + 0x6A0) = bpRot;
	}
	else
	{
		// KeyPos[key] delta from Location relative to (KeyPos[key]+BasePos)
		BYTE* kp = (BYTE*)this + (DWORD)key * 0xC + 0x430;
		float dk0 = *(float*)((BYTE*)this + 0x234)
		          - (*(float*)(kp) + *(float*)((BYTE*)this + 0x670));
		float dk1 = *(float*)((BYTE*)this + 0x238)
		          - (*(float*)(kp+4) + *(float*)((BYTE*)this + 0x674));
		float dk2 = *(float*)((BYTE*)this + 0x23C)
		          - (*(float*)(kp+8) + *(float*)((BYTE*)this + 0x678));
		*(float*)(kp + 0) = dk0;
		*(float*)(kp + 4) = dk1;
		*(float*)(kp + 8) = dk2;
		// KeyRot[key] = Rotation - (BaseRot + KeyRot[key])
		FRotator* baseRot = (FRotator*)((BYTE*)this + 0x6A0);
		FRotator* keyRot  = (FRotator*)((BYTE*)this + (DWORD)key * 0xC + 0x550);
		FRotator  pivot   = *baseRot + *keyRot; // FRotator::operator+
		FRotator  newKR   = *(FRotator*)((BYTE*)this + 0x240) - pivot;
		*keyRot = newKR;
		// Sync SavedPos to KeyPos[key], SavedRot to KeyRot[key]
		*(DWORD*)((BYTE*)this + 0x67C) = *(DWORD*)(kp);
		*(DWORD*)((BYTE*)this + 0x680) = *(DWORD*)(kp + 4);
		*(DWORD*)((BYTE*)this + 0x684) = *(DWORD*)(kp + 8);
		*(DWORD*)((BYTE*)this + 0x6AC) = *(DWORD*)((BYTE*)this + (DWORD)key * 0xC + 0x550);
		*(DWORD*)((BYTE*)this + 0x6B0) = *(DWORD*)((BYTE*)this + (DWORD)key * 0xC + 0x554);
		*(DWORD*)((BYTE*)this + 0x6B4) = *(DWORD*)((BYTE*)this + (DWORD)key * 0xC + 0x558);
	}
	// Update Location = KeyPos[key] + BasePos
	BYTE* kp2 = (BYTE*)this + (DWORD)key * 0xC + 0x430;
	*(float*)((BYTE*)this + 0x234) = *(float*)(kp2 + 0) + *(float*)((BYTE*)this + 0x670);
	*(float*)((BYTE*)this + 0x238) = *(float*)(kp2 + 4) + *(float*)((BYTE*)this + 0x674);
	*(float*)((BYTE*)this + 0x23C) = *(float*)(kp2 + 8) + *(float*)((BYTE*)this + 0x678);
	unguard;
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
	guard(AMover::PostRaytrace);
	// Ghidra 0xd57d0: same reposition pattern as SetWorldRaytraceKey but uses
	// MoverEncroachType (+0x397) as the key index, not WorldRaytraceKey.
	// Remove from hash, recompute Location/Rotation, re-add to hash.
	INT lvl  = *(INT*)((BYTE*)this + 0x328);
	void* hash = *(void**)(lvl + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash;
		((void(__thiscall*)(void*,AMover*))hv[3])(hash, this); // RemoveActor
	}
	BYTE key = *(BYTE*)((BYTE*)this + 0x397); // MoverEncroachType used as key
	BYTE* kp = (BYTE*)this + (DWORD)key * 0xC + 0x430;
	float nx = *(float*)(kp + 0x8) + *(float*)((BYTE*)this + 0x678);
	float ny = *(float*)(kp + 0x4) + *(float*)((BYTE*)this + 0x674);
	float nz = *(float*)(kp + 0x0) + *(float*)((BYTE*)this + 0x670);
	*(float*)((BYTE*)this + 0x234) = nz;
	*(float*)((BYTE*)this + 0x238) = ny;
	*(float*)((BYTE*)this + 0x23C) = nx;
	FRotator* baseRot = (FRotator*)((BYTE*)this + 0x6A0);
	FRotator* keyRot  = (FRotator*)((BYTE*)this + (DWORD)key * 0xC + 0x550);
	FRotator  newRot  = *baseRot + *keyRot;
	*(FRotator*)((BYTE*)this + 0x240) = newRot;
	hash = *(void**)(*(INT*)((BYTE*)this + 0x328) + 0xF0);
	if ((*(DWORD*)((BYTE*)this + 0xA8) & 0x800) && hash)
	{
		void** hv = *(void***)hash;
		((void(__thiscall*)(void*,AMover*,BYTE*))hv[2])(hash, this, (BYTE*)keyRot); // AddActor
	}
	unguard;
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


