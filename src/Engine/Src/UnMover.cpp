#include "EnginePrivate.h"
struct FPropertyRetirement;
// --- AMover ---
// Retail 0x1042BC10 (1345 bytes): keyframe interpolation for movers.
// Each tick advances InterpolationSpeed based on DeltaTime, computes target
// location/rotation via linear or cubic-Hermite blend between keyframes,
// then calls MoveActor to physically move. After move, velocity is updated
// from position delta. At KeyPosition==1.0, fires KeyFrameReached event.
IMPL_MATCH("Engine.dll", 0x1042bc10)
void AMover::physMovingBrush(float DeltaTime)
{
	guard(AMover::physMovingBrush);

	// Clamp key index to [0, 24]
	DWORD key = (DWORD)(BYTE)*(BYTE*)((BYTE*)this + 0x397);  // CurrentKeyFrame
	if ((INT)key < 0)  key = 0;
	else if (key > 0x17) key = 0x18;

	// Save pre-move location
	FLOAT OldX = Location.X;
	FLOAT OldY = Location.Y;
	FLOAT OldZ = Location.Z;

	TArray<AActor*>& FollowItems = *(TArray<AActor*>*)((BYTE*)this + 0x424);

	// FollowItems: hide them while animating
	if (*(DWORD*)((BYTE*)this + 0xac) & 4)
	{
		for (INT i = 0; i < FollowItems.Num(); i++)
		{
			AActor* a = FollowItems(i);
			if (a && a->DrawType != DT_None)
				a->SetDrawType(DT_None);
		}
	}

	while ((*(DWORD*)((BYTE*)this + 0xac) & 4) && DeltaTime > 0.0f)
	{
		// Advance interpolation position: InterpolationSpeed * DeltaTime
		FLOAT InterpolationSpeed = *(FLOAT*)((BYTE*)this + 0x3d4);
		FLOAT CurPos = *(FLOAT*)((BYTE*)this + 0x3d0);
		FLOAT newPos = DeltaTime * InterpolationSpeed + CurPos;
		FLOAT alpha;
		if (newPos <= 1.0f)
		{
			DeltaTime = 0.0f;
			alpha = newPos;
		}
		else
		{
			alpha = 1.0f;
			DeltaTime = ((newPos - 1.0f) / (newPos - CurPos)) * DeltaTime;
		}

		// Compute interpolated alpha based on interpolation type (this+0x395)
		FLOAT blendAlpha;
		BYTE interpType = *(BYTE*)((BYTE*)this + 0x395);
		if (interpType == 1)
		{
			// Cubic ease in/out: 3t^2 - 2t^3
			blendAlpha = alpha * alpha * (3.0f - 2.0f * alpha);
		}
		else
		{
			blendAlpha = alpha;
		}

		// Compute target rotation
		FRotator NewRot;
		BYTE* KeyBase = (BYTE*)this + key * 0xc;
		if (!(*(BYTE*)((BYTE*)this + 0x3b8) & 0x40))
		{
			// Interpolate rotation between base and target keyframes
			FRotator* BaseRot   = (FRotator*)((BYTE*)this + 0x6a0);
			FRotator* TargetRot = (FRotator*)((BYTE*)this + 0x6ac);
			FRotator DeltaRot = *TargetRot - *BaseRot;
			NewRot = *BaseRot + DeltaRot * blendAlpha;
		}
		else if (alpha == 1.0f)
		{
			// SnapToGoal: use target rot but zero near-zero components
			FRotator* BaseRot   = (FRotator*)((BYTE*)this + 0x6a0);
			FRotator* TargetRot = (FRotator*)((BYTE*)this + 0x6ac);
			FRotator DeltaRot   = *TargetRot - *BaseRot;
			// Zero out near-zero components (< 10 units)
			INT dp = DeltaRot.Pitch; if (dp > 0x8000) dp -= 0xffff; if (dp < 0) dp = -dp; if (dp < 10) DeltaRot.Pitch = 0;
			INT dy = DeltaRot.Yaw;   if (dy > 0x8000) dy -= 0xffff; if (dy < 0) dy = -dy; if (dy < 10) DeltaRot.Yaw   = 0;
			INT dr = DeltaRot.Roll;  if (dr > 0x8000) dr -= 0xffff; if (dr < 0) dr = -dr; if (dr < 10) DeltaRot.Roll  = 0;
			NewRot = *BaseRot + DeltaRot * blendAlpha;
		}
		else
		{
			// Snap to stored keyframe rotation
			NewRot = *(FRotator*)(KeyBase + 0x550);
		}

		// Compute target location from KeyPositions and goal position
		FLOAT BaseX  = *(FLOAT*)(KeyBase + 0x430) + *(FLOAT*)((BYTE*)this + 0x670);
		FLOAT BaseY  = *(FLOAT*)(KeyBase + 0x434) + *(FLOAT*)((BYTE*)this + 0x674);
		FLOAT BaseZ  = *(FLOAT*)(KeyBase + 0x438) + *(FLOAT*)((BYTE*)this + 0x678);
		FLOAT DestX  = *(FLOAT*)((BYTE*)this + 0x67c);
		FLOAT DestY  = *(FLOAT*)((BYTE*)this + 0x680);
		FLOAT DestZ  = *(FLOAT*)((BYTE*)this + 0x684);

		FLOAT NewX = (DestX - BaseX) * blendAlpha + BaseX;
		FLOAT NewY = (DestY - BaseY) * blendAlpha + BaseY;
		FLOAT NewZ = (DestZ - BaseZ) * blendAlpha + BaseZ;

		// Compute delta from current location
		FLOAT dX = NewX - Location.X;
		FLOAT dY = NewY - Location.Y;
		FLOAT dZ = NewZ - Location.Z;

		// If attached to a Karma actor, zero out translation
		if (*(UObject**)((BYTE*)this + 0x15c) &&
		    (*(UObject**)((BYTE*)this + 0x15c))->IsA(AMover::StaticClass()))
		{
			dX = dY = dZ = 0.0f;
		}

		// MoveActor via XLevel
		FCheckResult Hit;
		appMemzero(&Hit, sizeof(FCheckResult));
		UBOOL moved = XLevel->MoveActor(this, FVector(dX, dY, dZ), NewRot, Hit, 0, 0, 0, 0, 0);

		if (moved)
		{
			*(FLOAT*)((BYTE*)this + 0x3d0) = alpha;
			if (alpha != 1.0f)
				continue;

			// Reached keyframe — clear bMovingBrush flag, fire event
			*(DWORD*)((BYTE*)this + 0xac) &= ~4u;
			eventKeyFrameReached();

			// Show FollowItems (DT_Sprite) if back at key 0
			if (key == 0)
			{
				for (INT i = 0; i < FollowItems.Num(); i++)
				{
					AActor* a = FollowItems(i);
					if (a && a->DrawType != DT_Sprite)
						a->SetDrawType(DT_Sprite);
				}
			}
		}
	}

	// Update Velocity from position delta / InterpolationSpeed
	FLOAT InterpolationSpeed = *(FLOAT*)((BYTE*)this + 0x3d4);
	Velocity.X = (Location.X - OldX) * InterpolationSpeed;
	Velocity.Y = (Location.Y - OldY) * InterpolationSpeed;
	Velocity.Z = (Location.Z - OldZ) * InterpolationSpeed;

	unguard;
}

IMPL_DIVERGE("Ghidra 0x103F3470: retail subtracts/adds rdtsc samples into DAT_10799554[DAT_1079976c]; profiler accounting is omitted, gameplay logic matches")
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

IMPL_MATCH("Engine.dll", 0x10374f40)
INT* AMover::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(AMover::GetOptimizedRepList);
	static DWORD   s_InitFlags            = 0;
	static UObject* s_SimOldPosProp        = NULL;
	static UObject* s_SimOldRotPitchProp   = NULL;
	static UObject* s_SimOldRotYawProp     = NULL;
	static UObject* s_SimOldRotRollProp    = NULL;
	static UObject* s_SimInterpolateProp   = NULL;
	static UObject* s_RealPositionProp     = NULL;
	static UObject* s_RealRotationProp     = NULL;
	static UObject* s_VelocityProp         = NULL;

	Ptr = AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

	// DAT_1077e224 is AMover::PrivateStaticClass.ClassFlags; only CLASS_NativeReplication
	// (0x800) is tested here, and AMover's class constructor in Ghidra _unnamed.cpp
	// initialises that field with 0x800.
	if (Role == ROLE_Authority)
	{
		if ((*(INT*)((BYTE*)this + 0x6C4) != *(INT*)(Mem + 0x6C4)) ||
			(*(INT*)((BYTE*)this + 0x6C8) != *(INT*)(Mem + 0x6C8)) ||
			(*(INT*)((BYTE*)this + 0x6CC) != *(INT*)(Mem + 0x6CC)))
		{
			if (!(s_InitFlags & 1))
			{
				s_InitFlags |= 1;
				s_SimOldPosProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("SimOldPos"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_SimOldPosProp + 0x4A));
		}

		if (*(INT*)((BYTE*)this + 0x3A4) != *(INT*)(Mem + 0x3A4))
		{
			if (!(s_InitFlags & 2))
			{
				s_InitFlags |= 2;
				s_SimOldRotPitchProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("SimOldRotPitch"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_SimOldRotPitchProp + 0x4A));
		}

		if (*(INT*)((BYTE*)this + 0x3A8) != *(INT*)(Mem + 0x3A8))
		{
			if (!(s_InitFlags & 4))
			{
				s_InitFlags |= 4;
				s_SimOldRotYawProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("SimOldRotYaw"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_SimOldRotYawProp + 0x4A));
		}

		if (*(INT*)((BYTE*)this + 0x3AC) != *(INT*)(Mem + 0x3AC))
		{
			if (!(s_InitFlags & 8))
			{
				s_InitFlags |= 8;
				s_SimOldRotRollProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("SimOldRotRoll"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_SimOldRotRollProp + 0x4A));
		}

		if ((*(INT*)((BYTE*)this + 0x6D0) != *(INT*)(Mem + 0x6D0)) ||
			(*(INT*)((BYTE*)this + 0x6D4) != *(INT*)(Mem + 0x6D4)) ||
			(*(INT*)((BYTE*)this + 0x6D8) != *(INT*)(Mem + 0x6D8)))
		{
			if (!(s_InitFlags & 0x10))
			{
				s_InitFlags |= 0x10;
				s_SimInterpolateProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("SimInterpolate"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_SimInterpolateProp + 0x4A));
		}

		if ((*(INT*)((BYTE*)this + 0x6DC) != *(INT*)(Mem + 0x6DC)) ||
			(*(INT*)((BYTE*)this + 0x6E0) != *(INT*)(Mem + 0x6E0)) ||
			(*(INT*)((BYTE*)this + 0x6E4) != *(INT*)(Mem + 0x6E4)))
		{
			if (!(s_InitFlags & 0x20))
			{
				s_InitFlags |= 0x20;
				s_RealPositionProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("RealPosition"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_RealPositionProp + 0x4A));
		}

		if ((*(INT*)((BYTE*)this + 0x6E8) != *(INT*)(Mem + 0x6E8)) ||
			(*(INT*)((BYTE*)this + 0x6EC) != *(INT*)(Mem + 0x6EC)) ||
			(*(INT*)((BYTE*)this + 0x6F0) != *(INT*)(Mem + 0x6F0)))
		{
			if (!(s_InitFlags & 0x40))
			{
				s_InitFlags |= 0x40;
				s_RealRotationProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("RealRotation"), 0);
			}
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_RealRotationProp + 0x4A));
		}
	}

	if ((*(INT*)((BYTE*)this + 0x24C) != *(INT*)(Mem + 0x24C)) ||
		(*(INT*)((BYTE*)this + 0x250) != *(INT*)(Mem + 0x250)) ||
		(*(INT*)((BYTE*)this + 0x254) != *(INT*)(Mem + 0x254)))
	{
		if (!(s_InitFlags & 0x80))
		{
			s_InitFlags |= 0x80;
			s_VelocityProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), AActor::StaticClass(), TEXT("Velocity"), 0);
		}
		*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_VelocityProp + 0x4A));
	}

	return Ptr;
	unguard;
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
	guard(AMover::PostLoad);
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
	unguard;
}

// Static snapshot of mover's SimInterpolate position, set by PreNetReceive and read by
// PostNetReceive (maps to DAT_10666730/34/38 in Ghidra retail binary).
static FVector s_AMoverNetRecvSnapshot(0.f, 0.f, 0.f);

IMPL_MATCH("Engine.dll", 0x1037da40)
void AMover::PostNetReceive()
{
	guard(AMover::PostNetReceive);
	// DAT_10666730/34/38 is the static snapshot stored by PreNetReceive.
	AActor::PostNetReceive();
	if (s_AMoverNetRecvSnapshot != *(FVector*)((BYTE*)this + 0x6D0))
	{
		*(INT*)((BYTE*)this + 0x67C) = *(INT*)((BYTE*)this + 0x6C4);
		*(float*)((BYTE*)this + 0x3D0) = *(float*)((BYTE*)this + 0x6D0) * 0.01f;
		*(INT*)((BYTE*)this + 0x680) = *(INT*)((BYTE*)this + 0x6C8);
		*(INT*)((BYTE*)this + 0x684) = *(INT*)((BYTE*)this + 0x6CC);
		*(float*)((BYTE*)this + 0x3D4) = *(float*)((BYTE*)this + 0x6D4) * 0.01f;
		*(INT*)((BYTE*)this + 0x6B0) = *(INT*)((BYTE*)this + 0x3A8);
		*(INT*)((BYTE*)this + 0x6AC) = *(INT*)((BYTE*)this + 0x3A4);
		*(INT*)((BYTE*)this + 0x6B4) = *(INT*)((BYTE*)this + 0x3AC);
		// SimInterpolate.Z packs PrevKeyNum*256 + KeyNum as a float; retail converts that
		// packed value back to an integer via __ftol2.
		INT uKeyframe = (INT)(*(float*)((BYTE*)this + 0x6D8));
		((BYTE*)this)[0x397] = (BYTE)(uKeyframe & 0xFF);
		((BYTE*)this)[0x398] = (BYTE)((uKeyframe >> 8) & 0xFF);
		setPhysics(PHYS_MovingBrush, NULL, FVector(0.f, 0.f, 1.f));
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

// Static snapshot of mover's SimInterpolate position is defined before PostNetReceive above.
IMPL_MATCH("Engine.dll", 0x10378100)
void AMover::PreNetReceive()
{
	guard(AMover::PreNetReceive);
	// Ghidra 0x78100: snapshot this+0x6D0..0x6D8 (SimInterpolate FVector) to global
	// DAT_10666730/34/38 before the net receive updates the field.
	s_AMoverNetRecvSnapshot = *(FVector*)((BYTE*)this + 0x6D0);
	AActor::PreNetReceive();
	unguard;
}

// Ghidra 0x103D5460 (134b): copies FVector0_exref (confirmed = (0,0,0) from FCoords and mover
// usage patterns) into this+0x694..0x69C, then FRotator(0,0,0) into this+0x6B8..0x6C0,
// then calls vtable[0x184/4=97] on this (no extra args per Ghidra).
// FVector0_exref confirmed zero: FCoords::FCoords(coords, FVector0_exref) = identity origin.
IMPL_MATCH("Engine.dll", 0x103D5460)
void AMover::PreRaytrace()
{
	guard(AMover::PreRaytrace);
	*(float*)((BYTE*)this + 0x694) = 0.0f;
	*(float*)((BYTE*)this + 0x698) = 0.0f;
	*(float*)((BYTE*)this + 0x69C) = 0.0f;
	FRotator ZeroRot(0, 0, 0);
	*(FRotator*)((BYTE*)this + 0x6B8) = ZeroRot;
	void** vtbl = *(void***)this;
	((void(__thiscall*)(void*))vtbl[0x184 / sizeof(void*)])(this);
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


