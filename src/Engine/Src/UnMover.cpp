#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;
// --- AMover ---
IMPL_DIVERGE("Ghidra 0x1042BC10: 1345-byte keyframe interpolation with encroach checking not yet reconstructed")
void AMover::physMovingBrush(float DeltaTime)
{
	guard(AMover::physMovingBrush);
	// DIVERGENCE: full physMovingBrush implementation not yet reconstructed.
	// GHIDRA REF: 0x12bc10 — cubic/linear interpolation between mover keyframes,
	// encroach checking, and anim notifies. Requires unidentified actor-move helper
	// functions and complex FVector/FRotator temporaries not yet resolved.
	DWORD key = (DWORD)(BYTE)*(BYTE*)((BYTE*)this + 0x397);
	if ((INT)key < 0)  key = 0;
	else if (key > 0x17) key = 0x18;
	(void)DeltaTime;
	(void)key;
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103F3470: RDTSC profiling bookends (DAT_10799554/DAT_1079976c) omitted — hardware-counter globals not reproduced")
void AMover::performPhysics(float DeltaTime)
{
	guard(AMover::performPhysics);
	// DIVERGENCE: RDTSC profiling bookends omitted (DAT_10799554, DAT_1079976c are
	// internal profiling counters with no observable effect on gameplay).
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
	// DIVERGENCE: RDTSC profiling end omitted (see performPhysics entry comment).
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103072b0)
int AMover::ShouldTrace(AActor*,DWORD TraceFlags)
{
	return TraceFlags & 2;
}

IMPL_MATCH("Engine.dll", 0x104651d0)
void AMover::AddMyMarker(AActor *)
{
	guard(AMover::AddMyMarker);
	// Ghidra 0x1651d0: shared empty-stub address — function body is empty.
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10374f40: global property-handle caches (DAT_106669c8 et al.) and StaticFindObjectChecked_exref call pattern not reproduced")
INT* AMover::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AMover ---
IMPL_MATCH("Engine.dll", 0x103d5520)
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

IMPL_MATCH("Engine.dll", 0x103d4f30)
void AMover::Spawned()
{
	// Ghidra 0xd4f30: copy BasePos/BaseRot from this+0x234..0x24B to KeyPos0/KeyRot0 at +0x670..0x6A8.
	appMemcpy((BYTE*)this + 0x670, (BYTE*)this + 0x234, 12); // BasePos -> KeyPos0
	appMemcpy((BYTE*)this + 0x6A0, (BYTE*)this + 0x240, 12); // BaseRot -> KeyRot0
}

IMPL_MATCH("Engine.dll", 0x103d5680)
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

IMPL_MATCH("Engine.dll", 0x103d52a0)
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

IMPL_MATCH("Engine.dll", 0x103d5090)
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

IMPL_MATCH("Engine.dll", 0x103d4f70)
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

IMPL_DIVERGE("Ghidra 0x1037DA40: FUN_1050557c unresolved; BYTE fields +0x397/+0x398 and vtable +0x11c call not reproduced")
void AMover::PostNetReceive()
{
	guard(AMover::PostNetReceive);
	// DAT_10666730/34/38 is the static snapshot stored by PreNetReceive.
	// Declared as file-static below PreNetReceive.
	extern FVector AMoverNetRecvSnapshot;
	AActor::PostNetReceive();
	if (AMoverNetRecvSnapshot != *(FVector*)((BYTE*)this + 0x6D0))
	{
		*(INT*)((BYTE*)this + 0x67C) = *(INT*)((BYTE*)this + 0x6C4);
		*(float*)((BYTE*)this + 0x3D0) = *(float*)((BYTE*)this + 0x6D0) * 0.01f;
		*(INT*)((BYTE*)this + 0x680) = *(INT*)((BYTE*)this + 0x6C8);
		*(INT*)((BYTE*)this + 0x684) = *(INT*)((BYTE*)this + 0x6CC);
		*(float*)((BYTE*)this + 0x3D4) = *(float*)((BYTE*)this + 0x6D4) * 0.01f;
		*(INT*)((BYTE*)this + 0x6B0) = *(INT*)((BYTE*)this + 0x3A8);
		*(INT*)((BYTE*)this + 0x6AC) = *(INT*)((BYTE*)this + 0x3A4);
		*(INT*)((BYTE*)this + 0x6B4) = *(INT*)((BYTE*)this + 0x3AC);
		// DIVERGENCE: FUN_1050557c() (unresolved) would set *(BYTE*)(this+0x397) and
		// *(BYTE*)(this+0x398) from a 16-bit counter value here.
		// DIVERGENCE: vtable +0x11c call (BeginState-like notify) omitted.
		*(DWORD*)((BYTE*)this + 0xAC) |= 4;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d57d0)
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

// Static snapshot of mover's SimInterpolate position, set by PreNetReceive and read by
// PostNetReceive (maps to DAT_10666730/34/38 in Ghidra retail binary).
FVector AMoverNetRecvSnapshot(0.f, 0.f, 0.f);

IMPL_MATCH("Engine.dll", 0x10378100)
void AMover::PreNetReceive()
{
	guard(AMover::PreNetReceive);
	// Ghidra 0x78100: snapshot this+0x6D0..0x6D8 (SimInterpolate FVector) to global
	// DAT_10666730/34/38 before the net receive updates the field.
	AMoverNetRecvSnapshot = *(FVector*)((BYTE*)this + 0x6D0);
	AActor::PreNetReceive();
	unguard;
}

IMPL_DIVERGE("Ghidra 0x103D5460: FVector0_exref substituted with zero literals; vtable +0x184 slot unidentified")
void AMover::PreRaytrace()
{
	guard(AMover::PreRaytrace);
	// Ghidra 0xd5460: copy FVector(0,0,0) from FVector0_exref into this+0x694..0x69C,
	// then store FRotator(0,0,0) at this+0x6B8..0x6C0, then call vtable +0x184.
	// FVector0_exref is the global Engine.dll FVector zero constant; zeroing directly
	// is equivalent since it's always (0,0,0).
	*(float*)((BYTE*)this + 0x694) = 0.0f;
	*(float*)((BYTE*)this + 0x698) = 0.0f;
	*(float*)((BYTE*)this + 0x69C) = 0.0f;
	FRotator ZeroRot(0, 0, 0);
	*(FRotator*)((BYTE*)this + 0x6B8) = ZeroRot;
	// vtable[0x184/4] = slot 97; call with implicit this (no extra args per Ghidra)
	void** vtbl = *(void***)this;
	((void(__thiscall*)(void*))vtbl[0x184 / 4])(this);
	unguard;
}


// --- ADoor ---
IMPL_MATCH("Engine.dll", 0x103d66b0)
void ADoor::PostaddReachSpecs(APawn *)
{
	guard(ADoor::PostaddReachSpecs);
	// Part 1: set bForce flag on this door's own path specs
	TArray<UReachSpec*>* pl = (TArray<UReachSpec*>*)((BYTE*)this + 0x3d8);
	for (INT i = 0; i < pl->Num(); i++)
		*(DWORD*)((BYTE*)(*pl)(i) + 0x3c) |= 0x10;

	// Part 2: find any specs in the level that point TO this door and mark them too
	BYTE* LevelBase = (BYTE*)(*(DWORD*)((BYTE*)this + 0x144)); // Level (ALevelInfo*)
	for (ANavigationPoint* Nav = *(ANavigationPoint**)(LevelBase + 0x4d0);
		 Nav;
		 Nav = *(ANavigationPoint**)((BYTE*)Nav + 0x3a8))
	{
		TArray<UReachSpec*>* navPl = (TArray<UReachSpec*>*)((BYTE*)Nav + 0x3d8);
		for (INT j = 0; j < navPl->Num(); j++)
		{
			UReachSpec* spec = (*navPl)(j);
			if (*(ADoor**)((BYTE*)spec + 0x4c) == this)
				*(DWORD*)((BYTE*)spec + 0x3c) |= 0x10;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d60c0)
void ADoor::PostPath()
{
	guard(ADoor::PostPath);
	// Ghidra 0xd60c0: re-enable collision for linked door actors if bTempNoCollide was set
	if (*(DWORD*)((BYTE*)this + 1000) & 8)
	{
		for (AActor* A = *(AActor**)((BYTE*)this + 0x3ec); A; A = *(AActor**)((BYTE*)A + 0x3e0))
		{
			DWORD f = *(DWORD*)((BYTE*)A + 0xa8);
			A->SetCollision(1, (f >> 0xd) & 1, (f >> 0xe) & 1);
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d6000)
void ADoor::PrePath()
{
	guard(ADoor::PrePath);
	// Ghidra 0xd6000: disable collision on linked door actors that block both BSP and actors
	for (AActor* A = *(AActor**)((BYTE*)this + 0x3ec); A; A = *(AActor**)((BYTE*)A + 0x3e0))
	{
		DWORD f = *(DWORD*)((BYTE*)A + 0xa8);
		if ((f & 0x2000) && (f & 0x800))
		{
			A->SetCollision(0, (f >> 0xd) & 1, (f >> 0xe) & 1);
			*(DWORD*)((BYTE*)this + 1000) |= 8;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d5af0)
AActor * ADoor::AssociatedLevelGeometry()
{
	// Ghidra 0xd5af0, 7B: return pointer at offset 0x3ec
	return *(AActor**)((BYTE*)this + 0x3ec);
}

IMPL_MATCH("Engine.dll", 0x103d6d10)
void ADoor::FindBase()
{
	guard(ADoor::FindBase);
	// Ghidra 0xd6d10: editor-only; wrap parent FindBase with unknown vtable hooks
	if (GIsEditor)
	{
		// vtable[0x178](this) -- unknown editor pre-FindBase hook
		typedef void (__thiscall* tVoidHook)(ADoor*);
		((tVoidHook*)((BYTE*)(*(void**)this) + 0x178))[0](this);
		ANavigationPoint::FindBase();
		// vtable[0x17c](this) -- unknown editor post-FindBase hook
		((tVoidHook*)((BYTE*)(*(void**)this) + 0x17c))[0](this);
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d5b20)
int ADoor::HasAssociatedLevelGeometry(AActor * Other)
{
	// Ghidra 0xd5b20, 45B: walk linked list at 0x3ec, next ptr at 0x3e0
	if (Other)
	{
		for (AActor* Node = *(AActor**)((BYTE*)this + 0x3ec); Node; Node = *(AActor**)((BYTE*)Node + 0x3e0))
		{
			if (Node == Other)
				return 1;
		}
	}
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103d8030)
void ADoor::InitForPathFinding()
{
	guard(ADoor::InitForPathFinding);
	// Ghidra 0xd8030: build linked list of associated movers by DoorTag
	FName DoorTag = *(FName*)((BYTE*)this + 0x3f4);
	if (DoorTag == FName(NAME_None))
		return;

	*(INT*)((BYTE*)this + 0x3ec) = 0; // clear list head

	ULevel* lev = *(ULevel**)((BYTE*)this + 0x328);
	for (INT i = 0; i < lev->Actors.Num(); i++)
	{
		UObject* actor = lev->Actors(i);
		if (!actor || !actor->IsA(AMover::StaticClass()))
			continue;

		INT match = (*(FName*)((BYTE*)actor + 0x19c) == DoorTag) ? 1 : 0;

		if (!match && *(INT*)((BYTE*)this + 0x3ec) != 0)
		{
			FName headTag408 = *(FName*)(*(INT*)((BYTE*)this + 0x3ec) + 0x408);
			if (headTag408 != FName(NAME_None) &&
				*(FName*)((BYTE*)actor + 0x408) == headTag408)
				match = 1;
		}
		if (!match)
			continue;

		// Link this mover into the list
		*(ADoor**)((BYTE*)actor + 0x3fc) = this;
		if (*(INT*)((BYTE*)this + 0x3ec) == 0)
		{
			*(UObject**)((BYTE*)this + 0x3ec) = actor;
			*(UObject**)((BYTE*)actor + 0x3dc) = actor;
			*(INT*)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0) = 0;
		}
		else
		{
			*(INT*)((BYTE*)actor + 0x3dc) = *(INT*)((BYTE*)this + 0x3ec);
			*(DWORD*)((BYTE*)actor + 0x3e0) = *(DWORD*)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0);
			*(UObject**)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0) = actor;
		}
	}

	if (*(INT*)((BYTE*)this + 0x3ec) == 0)
		GWarn->Logf(TEXT("No Mover found for this Door"));
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103d5d60)
int ADoor::IsIdentifiedAs(FName Name)
{
	guard(ADoor::IsIdentifiedAs);
	// Ghidra 0xd5d60: compare Name against own name, then against linked mover (this+0x3ec).
	if (Name == GetFName())
		return 1;
	UObject* mover = *(UObject**)((BYTE*)this + 0x3ec); // linked mover actor field
	if (mover != NULL && Name == mover->GetFName())
		return 1;
	return 0;
	unguard;
}


