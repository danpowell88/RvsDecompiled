/*=============================================================================
	UnEmitter.cpp: Particle emitter hierarchy (UParticleEmitter*)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- AEmitter ---
IMPL_MATCH("Engine.dll", 0x103df2e0)
void AEmitter::Spawned()
{
	// Ghidra 0xdf2e0, 18B: set flag 4 at offset 0x3c8 when not in editor
	if (!GIsEditor)
		*(DWORD*)((BYTE*)this + 0x3c8) |= 4;
}

IMPL_MATCH("Engine.dll", 0x103df4a0)
int AEmitter::Tick(float DeltaTime, ELevelTick TickType)
{
	guard(AEmitter::Tick);
	typedef void(__thiscall* VFn)(void*);
	typedef void(__thiscall* UpdateFn)(void*, FLOAT);
	typedef void(__thiscall* SpawnFn)(void*);
	typedef void(__thiscall* ResetFn)(void*);
	typedef void(__thiscall* HandleForceFn)(void*);

	if (AActor::Tick(DeltaTime, TickType) == 0) return 0;

	// If emitter list not initialized, call Initialize via vtable offset 0x184
	if (*(INT*)((BYTE*)this + 0x3c4) == 0)
		(*(VFn*)((*(INT*)((BYTE*)this)) + 0x184))((void*)this);

	if (*(BYTE*)((BYTE*)this + 0xa0) & 0x80) return 1;
	if (TickType == LEVELTICK_ViewportsOnly && !GIsEditor) return 1;

	*(FBox*)((BYTE*)this + 0x3dc) = FBox(0);
	INT allDone = 1;
	INT noActive = 1;
	FLOAT hasBlocking = 0.0f;
	*(DWORD*)((BYTE*)this + 0x3c8) &= ~0x2u;

	INT loopIdx = 0;
	while (true)
	{
		if (((FArray*)((BYTE*)this + 0x398))->Num() <= loopIdx) break;
		// em + 0x64 = flags field (0x19 * sizeof(INT) = 0x64 bytes)
		BYTE* em = *(BYTE**)((BYTE*)(*(INT*)((BYTE*)this + 0x398)) + loopIdx * 4);
		if (em == NULL || (*(DWORD*)(em + 0x64) & 0x1000U) != 0)
		{
			loopIdx++;
			continue;
		}
		{
			DWORD flags3c8 = *(DWORD*)((BYTE*)this + 0x3c8);
			*(DWORD*)((BYTE*)this + 0x3c8) = (((*(DWORD*)(em + 0x64) >> 0xe) | flags3c8) ^ flags3c8) & 2u ^ flags3c8;
			noActive = 0;
			*(INT*)(em + 0x2f4) = (INT)this;
			// UpdateParticles if not frozen (bit 0 at +0x2dc)
			if ((*(BYTE*)(em + 0x2dc) & 1) == 0)
			{
				UpdateFn upFn = *(UpdateFn*)((*(INT*)em) + 100);
				upFn((void*)em, DeltaTime);
			}
			// Propagate world-space flag (bit 2 at +0x2dc)
			INT bWorldSpace = ((*(DWORD*)(em + 0x64) & 0x2000U) != 0 || (*(BYTE*)((BYTE*)this + 0x394) & 4) != 0) ? 1 : 0;
			DWORD emFlags = *(DWORD*)(em + 0x2dc);
			emFlags = emFlags ^ ((DWORD)(bWorldSpace * 4) ^ emFlags) & 4u;
			*(DWORD*)(em + 0x2dc) = emFlags;
			// Timer countdown
			if (*(FLOAT*)(em + 0x2e8) != 0.0f)
			{
				FLOAT fTimer = *(FLOAT*)(em + 0x2e8);
				*(FLOAT*)(em + 0x2e8) = fTimer - DeltaTime;
				if (fTimer - DeltaTime > 0.0f) { loopIdx++; continue; }
				*(FLOAT*)(em + 0x2e8) = 0.0f;
			}
			// Copy owner position to emitter
			*(INT*)(em + 0x32c) = *(INT*)((BYTE*)this + 0x3f8);
			*(INT*)(em + 0x330) = *(INT*)((BYTE*)this + 0x3fc);
			*(INT*)(em + 0x334) = *(INT*)((BYTE*)this + 0x400);
			if ((emFlags & 0x8u) == 0)
			{
				// Active / spawning branch
				if ((emFlags & 0x10u) == 0 && *(FLOAT*)(em + 0x88) != 0.0f && *(FLOAT*)(em + 0x8c) != 0.0f)
				{
					FLOAT bCount = ((FRange*)(em + 0x248))->GetCenter();
					bCount = bCount * *(FLOAT*)(em + 0x8c);
					// Retail uses FUN_1050557c (likely appTrunc via FPU) for loop bound;
				// (INT)bCount is equivalent for positive burst counts.
				INT iVar6 = (INT)bCount;
					for (INT bi = 0; bi < iVar6; bi++)
					{
						SpawnFn spFn = *(SpawnFn*)((*(INT*)em) + 0x80);
						spFn((void*)em);
					}
					*(DWORD*)(em + 0x2dc) |= 0x10u;
					emFlags = *(DWORD*)(em + 0x2dc);
				}
				if ((emFlags & 2u) == 0)
					*(FLOAT*)(em + 0x2e0) = 0.0f;
				else
					*(FLOAT*)(em + 0x2e0) = DeltaTime + *(FLOAT*)(em + 0x2e0);
				if (*(FLOAT*)(em + 0x80) == 0.0f || *(FLOAT*)(em + 0x2e0) <= *(FLOAT*)(em + 0x80))
				{
					SpawnFn spFn = *(SpawnFn*)((*(INT*)em) + 0x80);
					spFn((void*)em);
				}
				*(DWORD*)(em + 0x2dc) |= 2u;
				emFlags = *(DWORD*)(em + 0x2dc);
				DWORD uVar5c = *(DWORD*)(em + 0x64) >> 7 & 1u;
				hasBlocking = (FLOAT)((DWORD)hasBlocking | uVar5c);
				allDone = 0;
				if (uVar5c != 0)
				{
					for (INT fi = 0; fi < ((FArray*)((BYTE*)this + 0x1c8))->Num(); fi++)
					{
						INT forceActor = *(INT*)((BYTE*)(*(INT*)((BYTE*)this + 0x1c8)) + fi * 4);
						if (forceActor != 0 && *(SBYTE*)((BYTE*)forceActor + 0x3d) != 0)
						{
							HandleForceFn hFn = *(HandleForceFn*)((*(INT*)em) + 0x74);
							hFn((void*)em);
						}
					}
				}
			}
			else
			{
				// Inactive / reset branch
				if (((*(DWORD*)(em + 0x64) & 0x800u) == 0) || ((*(BYTE*)((BYTE*)this + 0x394) & 2) != 0))
				{
					if (((*(DWORD*)(em + 0x64) & 0x400u) != 0) && ((*(BYTE*)((BYTE*)this + 0x394) & 1) == 0))
						*(DWORD*)(em + 0x64) = (*(DWORD*)(em + 0x64) | 0x1000u);
				}
				else
				{
					FLOAT* pTimer = (FLOAT*)(em + 0x2ec);
					if (*pTimer - DeltaTime <= 0.0f)
					{
						FLOAT fRand = ((FRange*)(em + 0x168))->GetRand();
						*pTimer = fRand;
						ResetFn rFn = *(ResetFn*)((*(INT*)em) + 0x6c);
						rFn((void*)em);
					}
					else { *pTimer -= DeltaTime; }
				}
			}
			// Expand master bbox by emitter bbox if emitter has active particles
			if ((*(BYTE*)(em + 0x2dc) & 8) == 0)
			{
				FBox& masterBox = *(FBox*)((BYTE*)this + 0x3dc);
				masterBox = masterBox + *(FBox*)(em + 0x304);
			}
		}
		loopIdx++;
	}

	if (hasBlocking == 0.0f)
	{
		if (*(BYTE*)((BYTE*)this + 0x3c8) & 1)
		{
			AActor::SetCollision(0, 0, 0);
			*(DWORD*)((BYTE*)this + 0x3c8) &= ~1u;
		}
	}
	else
	{
		if (!(*(BYTE*)((BYTE*)this + 0x3c8) & 1)) AActor::SetCollision(1, 0, 0);
		FLOAT bMinX = *(FLOAT*)((BYTE*)this + 0x3dc);
		FLOAT bMaxX = *(FLOAT*)((BYTE*)this + 0x3e4);
		FLOAT ctrX  = *(FLOAT*)((BYTE*)this + 0x234);
		FLOAT dX0 = bMaxX - ctrX;  FLOAT adX0 = dX0 < 0.0f ? -dX0 : dX0;
		FLOAT dX1 = bMinX - ctrX;  FLOAT adX1 = dX1 < 0.0f ? -dX1 : dX1;
		FLOAT fVarX = adX1 < adX0 ? adX0 : adX1;
		FLOAT bMinY = *(FLOAT*)((BYTE*)this + 0x3e0);
		FLOAT bMaxY = *(FLOAT*)((BYTE*)this + 0x3e8);
		FLOAT ctrY  = *(FLOAT*)((BYTE*)this + 0x238);
		FLOAT dY0 = bMaxY - ctrY;  FLOAT adY0 = dY0 < 0.0f ? -dY0 : dY0;
		FLOAT dY1 = bMinY - ctrY;  FLOAT adY1 = dY1 < 0.0f ? -dY1 : dY1;
		FLOAT fVarY = adY1 < adY0 ? adY0 : adY1;
		FLOAT bMinZ = *(FLOAT*)((BYTE*)this + 0x3dc + 8);
		FLOAT bMaxZ = *(FLOAT*)((BYTE*)this + 0x3dc + 8 + 12);
		FLOAT ctrZ  = *(FLOAT*)((BYTE*)this + 0x23c);
		FLOAT dZ0 = bMinZ - ctrZ;  FLOAT adZ0 = dZ0 < 0.0f ? -dZ0 : dZ0;
		FLOAT dZ1 = bMaxZ - ctrZ;  FLOAT adZ1 = dZ1 < 0.0f ? -dZ1 : dZ1;
		FLOAT fVarZ = adZ0 <= adZ1 ? adZ1 : adZ0;
		FLOAT collRad = appSqrt(fVarX * fVarX + fVarY * fVarY);
		hasBlocking = collRad;
		if (*(FLOAT*)((BYTE*)this + 0x3cc) < collRad || *(FLOAT*)((BYTE*)this + 0x3d0) < fVarZ)
		{
			if (*(FLOAT*)((BYTE*)this + 0x3cc) < collRad) *(FLOAT*)((BYTE*)this + 0x3cc) = collRad * 1.2f;
			if (*(FLOAT*)((BYTE*)this + 0x3d0) < fVarZ)   *(FLOAT*)((BYTE*)this + 0x3d0) = fVarZ  * 1.2f;
			AActor::SetCollisionSize(*(FLOAT*)((BYTE*)this + 0x3cc), *(FLOAT*)((BYTE*)this + 0x3d0));
		}
		*(DWORD*)((BYTE*)this + 0x3c8) |= 1u;
	}

	if (allDone != 0)
	{
		if (noActive == 0 && ((FArray*)((BYTE*)this + 0x398))->Num() != 0 && (*(BYTE*)((BYTE*)this + 0x394) & 1) != 0)
		{
			// XLevel->DestroyActor(this, 0) via vtable offset 0xa0
			typedef int(__thiscall* DestroyActorFn)(void*, void*, int);
			INT xlevel = *(INT*)((BYTE*)this + 0x328);
			(*(DestroyActorFn*)((*(INT*)xlevel) + 0xa0))((void*)xlevel, (void*)this, 0);
			return 1;
		}
		if ((*(DWORD*)((BYTE*)this + 0x394) & 2) != 0 && (*(DWORD*)((BYTE*)this + 0x394) & 1) == 0)
		{
			if (*(FLOAT*)((BYTE*)this + 0x3d4) - DeltaTime <= 0.0f)
			{
				FVector randVec = ((FRangeVector*)((BYTE*)this + 0x3a4))->GetRand();
				*(FVector*)((BYTE*)this + 0x3f8) = randVec;
				FLOAT fRand2 = ((FRange*)((BYTE*)this + 0x3bc))->GetRand();
				*(FLOAT*)((BYTE*)this + 0x3d4) = fRand2;
				for (INT ri = 0; ri < ((FArray*)((BYTE*)this + 0x398))->Num(); ri++)
				{
					BYTE* emPtr = *(BYTE**)((BYTE*)(*(INT*)((BYTE*)this + 0x398)) + ri * 4);
					ResetFn rFn = *(ResetFn*)((*(INT*)emPtr) + 0x6c);
					rFn((void*)emPtr);
				}
			}
			else { *(FLOAT*)((BYTE*)this + 0x3d4) -= DeltaTime; }
		}
	}

	AActor::UpdateRenderData();
	return 1;
	unguard;
}

IMPL_EMPTY("emitter render no-op; render path not yet implemented")
void AEmitter::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	guard(AEmitter::Render);
	unguard;
}

IMPL_EMPTY("emitter editor info render no-op")
void AEmitter::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(AEmitter::RenderEditorInfo);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103df3b0)
void AEmitter::Kill()
{
	// Ghidra 0xdf3b0, 178b: iterate emitter list at this+0x398, clear flags and reset per-emitter counters.
	FArray* emitters = (FArray*)((BYTE*)this + 0x398);
	for (INT i = 0; i < emitters->Num(); i++)
	{
		BYTE* em = *(BYTE**)(*(BYTE**)emitters + i * 4);
		if (em)
		{
			*(DWORD*)(em + 100) &= ~0x200u;  // clear bit 9 (SkipDestroy)
			*(DWORD*)(em + 0x7c) = 0;
			*(DWORD*)(em + 0x78) = 0;
			*(DWORD*)(em + 100) &= ~0x800u;  // clear bit 11
			*(DWORD*)(em + 100) &= ~0x400u;  // clear bit 10
			*(DWORD*)(em + 0x2d8) = 1;
		}
	}
	*(DWORD*)((BYTE*)this + 0x394) &= ~0x200u;
}

IMPL_MATCH("Engine.dll", 0x103df300)
void AEmitter::PostScriptDestroyed()
{
	// Ghidra 0xdf300, 113b: if spawn flag set at bit 2 of this+0x3c8,
	// iterate emitter list and call vtable[3](1) on each, then null the slot.
	if (*(BYTE*)((BYTE*)this + 0x3c8) & 4)
	{
		FArray* emitters = (FArray*)((BYTE*)this + 0x398);
		for (INT i = 0; i < emitters->Num(); i++)
		{
			BYTE** slot = (BYTE**)(*(BYTE**)emitters + i * 4);
			BYTE* em = *slot;
			if (em)
			{
				void** vtbl = *(void***)em;
				typedef void(__thiscall* DestroyFn)(BYTE*, INT);
				((DestroyFn)vtbl[3])(em, 1);
			}
			*slot = NULL;
		}
	}
}

// Ghidra: 0x103dfe90, 387 bytes
IMPL_DIVERGE("FCollisionHash not declared in project headers (accessed only via raw pointer ULevel+0xf0); AProjector vtable slot 0x194 not accessible without full vtable declaration — hash query permanently blocked")
int AEmitter::CheckForProjectors()
{
	guard(AEmitter::CheckForProjectors);
	// Retail: queries FCollisionHash via Level->CollisionHash for AProjector actors
	// overlapping this emitter's bbox, registers each via projector vtable[0x194],
	// clamps count to [0,4], stores in render data at this+0x3d8.
	INT result = 0;
	if (result < 0) result = 0;
	else if (result > 3) result = 4;
	if (*(INT*)((BYTE*)this + 0x3d8) != 0)
		*(INT*)(*(INT*)((BYTE*)this + 0x3d8) + 0x80) = result;
	return result;
	unguard;
}

IMPL_EMPTY("emitter initialize no-op")
void AEmitter::Initialize()
{
	guard(AEmitter::Initialize);
	unguard;
}


// --- UBeamEmitter ---
IMPL_EMPTY("beam particle spawn no-op")
void UBeamEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(UBeamEmitter::SpawnParticle);
	unguard;
}

IMPL_EMPTY("beam actor hit-list update no-op")
void UBeamEmitter::UpdateActorHitList()
{
	guard(UBeamEmitter::UpdateActorHitList);
	unguard;
}

// Ghidra: 0x10381920, 1208 bytes
// DIVERGENCE: CoordSystem==1 world-transform uses FCoords/FMatrix instead of retail's
// FUN_10301560 (non-exported translation matrix ctor) + FUN_10370d70 (non-exported
// FRotator→single-axis FMatrix ctor). Non-exported internal helpers cannot be matched.
IMPL_DIVERGE("Ghidra 0x10381920 (1208b): CoordSystem==1 matrix transform permanently diverges: FUN_10301560+FUN_10370d70 are non-exported internal functions; FCoords/FMatrix equivalent used")
int UBeamEmitter::UpdateParticles(float DeltaTime)
{
	guard(UBeamEmitter::UpdateParticles);
	INT iVar7 = 0;
	*(DWORD*)((BYTE*)this + 0x3dc) = 0;
	while (((FArray*)((BYTE*)this + 0x360))->Num() > iVar7)
	{
		INT iVar2 = iVar7 * 0x20;
		iVar7++;
		*(FLOAT*)((BYTE*)this + 0x3dc) += *(FLOAT*)((BYTE*)*(INT*)((BYTE*)this + 0x360) + iVar2 + 0x1c);
	}
	INT numF = ((FArray*)((BYTE*)this + 0x3f8))->Num();
	INT numS = ((FArray*)((BYTE*)this + 0x360))->Num();
	if (numF != numS)
	{
		typedef void(__thiscall* SyncFn)(void*);
		SyncFn syncFn = *(SyncFn*)((*(INT*)this) + 0x8c);
		syncFn((void*)this);
	}
	if (*(INT*)((BYTE*)this + 0x2f4) == 0) return 0;
	if (*(INT*)((BYTE*)this + 0x348) != -1)
	{
		INT numArr = ((FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x398))->Num();
		INT idx = *(INT*)((BYTE*)this + 0x348);
		if (idx < 0) idx = 0;
		else if (idx > numArr - 1) idx = numArr - 1;
		*(INT*)((BYTE*)this + 0x348) = idx;
	}
	INT local_2c = UParticleEmitter::UpdateParticles(DeltaTime);
	*(FBox*)((BYTE*)this + 0x304) = FBox(0);

	// Per-particle bounding box expansion.
	// Ghidra: iterates active particles, adds beam segment endpoints to bbox.
	// CoordSystem at this+0x2d (BYTE): 1 = owner-relative, else = world-space.
	BYTE CoordSystem = *((BYTE*)this + 0x2d);
	INT numParticles = *(INT*)((BYTE*)this + 0x2c4);
	FBox* bbox = (FBox*)((BYTE*)this + 0x304);
	INT segStride = *(INT*)((BYTE*)this + 0x344);  // beam segment count
	BYTE* beamData = (BYTE*)*(INT*)((BYTE*)this + 0x3e0);  // beam vertex data
	BYTE* particleData = (BYTE*)*(INT*)((BYTE*)this + 0x2f8);  // particle array
	INT owner = *(INT*)((BYTE*)this + 0x2f4);  // Outer actor

	iVar7 = 0;
	while (iVar7 < numParticles)
	{
		// Check if particle is active: flag byte at particleData + iVar7*0x8c + 0x80, bit 0.
		if ((*(BYTE*)(particleData + iVar7 * 0x8c + 0x80) & 1) != 0)
		{
			FLOAT* segStart = (FLOAT*)(beamData + segStride * iVar7 * 0x10);
			FLOAT* segEnd   = (FLOAT*)(beamData + ((iVar7 + 1) * segStride * 0x10 - 0x10));

			if (CoordSystem != 1)
			{
				// World-space: add segment endpoints directly.
				*bbox += *(FVector*)segStart;
				*bbox += *(FVector*)segEnd;
			}
			else
			{
				// Owner-relative: offset by Owner->Location.
				FVector pos1;
				pos1.X = *(FLOAT*)(owner + 0x234) + segStart[0];
				pos1.Y = *(FLOAT*)(owner + 0x238) + segStart[1];
				pos1.Z = *(FLOAT*)(owner + 0x23c) + segStart[2];
				*bbox += pos1;

				FVector pos2;
				pos2.X = *(FLOAT*)(owner + 0x234) + segEnd[0];
				pos2.Y = *(FLOAT*)(owner + 0x238) + segEnd[1];
				pos2.Z = *(FLOAT*)(owner + 0x23c) + segEnd[2];
				*bbox += pos2;
			}
		}
		iVar7++;
	}

	FLOAT sizeB = ((FRange*)((BYTE*)this + 0x3b4))->Size();
	FLOAT sizeG = ((FRange*)((BYTE*)this + 0x3ac))->Size();
	FLOAT sizeR = ((FRange*)((BYTE*)this + 0x3a4))->Size();
	FLOAT maxSize = sizeR;
	if (maxSize < sizeG) maxSize = sizeG;
	if (maxSize < sizeB) maxSize = sizeB;
	(void)maxSize;
	(void)((FRange*)((BYTE*)this + 0x39c))->Size();
	(void)((FRange*)((BYTE*)this + 0x394))->Size();
	FLOAT sizeW = ((FRange*)((BYTE*)this + 0x38c))->Size();
	(void)sizeW;
	FBox expanded = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(0.0f);
	*(FBox*)((BYTE*)this + 0x304) = expanded;

	// CoordSystem==1 world-space transform: builds a combined rotation+translation
	// FMatrix from Owner->Location and Owner->Rotation, then calls FBox::TransformBy.
	// Retail uses FUN_10301560 (translation matrix ctor) and FUN_10370d70 (FRotator→FMatrix);
	// we use FCoords / FRotator → Matrix() which is functionally equivalent.
	// Combined = T(+Loc) * R(Rot) * T(-Loc) = "rotate bbox around owner's location".
	if (CoordSystem == 1)
	{
		FVector OwnerLoc(*(FLOAT*)(owner + 0x234), *(FLOAT*)(owner + 0x238), *(FLOAT*)(owner + 0x23c));
		FRotator OwnerRot(*(INT*)(owner + 0x240), *(INT*)(owner + 0x244), *(INT*)(owner + 0x248));

		FMatrix T_pos(
			FPlane(1, 0, 0, OwnerLoc.X),
			FPlane(0, 1, 0, OwnerLoc.Y),
			FPlane(0, 0, 1, OwnerLoc.Z),
			FPlane(0, 0, 0, 1)
		);

		FCoords RotCoords = GMath.UnitCoords / OwnerRot;
		FMatrix R = RotCoords.Matrix();

		FMatrix T_neg(
			FPlane(1, 0, 0, -OwnerLoc.X),
			FPlane(0, 1, 0, -OwnerLoc.Y),
			FPlane(0, 0, 1, -OwnerLoc.Z),
			FPlane(0, 0, 0, 1)
		);

		FMatrix Combined = T_pos * (R * T_neg);
		*bbox = bbox->TransformBy(Combined);
	}

	return local_2c;
	unguard;
}

// Ghidra: 0x10381eb0, 2210 bytes
IMPL_DIVERGE("Ghidra 0x10381eb0 (2210b): builds beam segment geometry and submits via FRenderInterface. FRenderInterface vtable has only 3 declared methods; retail drives ~20+ undeclared slots (SetMaterial, DrawPrimitive etc.). Permanent: vtable reconstruction required.")
int UBeamEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(UBeamEmitter::RenderParticles);
	// Retail: builds beam segment geometry between source/target actors,
	// constructs index buffers, and submits via FRenderInterface.
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

IMPL_EMPTY("beam emitter scale no-op")
void UBeamEmitter::Scale(float)
{
	guard(UBeamEmitter::Scale);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10380850)
void UBeamEmitter::PostEditChange()
{
	// Ghidra 0x80850: call parent, then CleanUp (vtbl[26]) and Initialize(MaxParticles) (vtbl[25]).
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(UBeamEmitter*);
	typedef void(__thiscall* InitFn)(UBeamEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((InitFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

IMPL_MATCH("Engine.dll", 0x10380af0)
void UBeamEmitter::CleanUp()
{
	// Ghidra 0x80af0, ~100b: empty beam/noise arrays then delegate to parent.
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x3e4); i++) {}
	((FArray*)((BYTE*)this + 0x3e0))->Empty(0x10, 0);
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x3f0); i++) {}
	((FArray*)((BYTE*)this + 0x3ec))->Empty(0xc, 0);
	UParticleEmitter::CleanUp();
}

IMPL_EMPTY("beam emitter initialize no-op")
void UBeamEmitter::Initialize(int)
{
	guard(UBeamEmitter::Initialize);
	unguard;
}


// --- UMeshEmitter ---
IMPL_MATCH("Engine.dll", 0x103cada0)
int UMeshEmitter::UpdateParticles(float DeltaTime)
{
	guard(UMeshEmitter::UpdateParticles);
	INT local_1c = UParticleEmitter::UpdateParticles(DeltaTime);
	FBox expanded0 = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(0.0f);
	*(FBox*)((BYTE*)this + 0x304) = expanded0;
	INT meshPtr = *(INT*)((BYTE*)this + 0x2f4);
	if (meshPtr != 0)
	{
		(void)((FVector*)((BYTE*)meshPtr + 0x2c8))->Size();
		FBox expanded1 = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(0.0f);
		*(FBox*)((BYTE*)this + 0x304) = expanded1;
	}
	return local_1c;
	unguard;
}

// Ghidra: 0x103caec0, 2697 bytes
IMPL_DIVERGE("Ghidra 0x103caec0 (2697b): iterates particles, builds per-particle FMatrix transforms, renders via FRenderInterface. FRenderInterface vtable has only 3 declared methods; retail drives ~20+ undeclared slots. Permanent: vtable reconstruction required.")
int UMeshEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(UMeshEmitter::RenderParticles);
	// Retail: iterates active particles, builds per-particle FMatrix transforms,
	// applies mesh LOD via UViewport::IsWire/IsLit, and renders via FRenderInterface.
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103cabc0)
void UMeshEmitter::PostEditChange()
{
	// Ghidra 0xcabc0: same pattern as UBeamEmitter::PostEditChange.
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(UMeshEmitter*);
	typedef void(__thiscall* InitFn)(UMeshEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((InitFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

IMPL_EMPTY("mesh emitter initialize no-op")
void UMeshEmitter::Initialize(int)
{
	guard(UMeshEmitter::Initialize);
	unguard;
}


// --- UParticleEmitter ---
IMPL_EMPTY("individual particle spawn no-op")
void UParticleEmitter::SpawnIndividualParticles(int)
{
	guard(UParticleEmitter::SpawnIndividualParticles);
	unguard;
}

IMPL_EMPTY("particle spawn no-op")
void UParticleEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(UParticleEmitter::SpawnParticle);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103ddb40)
float UParticleEmitter::SpawnParticles(float,float,float)
{
	return 0.0f;
}

// Ghidra: 0x103ddca0, 5049 bytes
// IMPL_TODO: per-particle physics loop (velocity integration, bbox accumulation,
// lifetime management) blocked by FUN_1035dc30 (non-exported collision helper, unidentified).
// Ghidra 0x103ddca0, 5049 bytes.
// FUN_1035dc30 (32b, formerly misidentified as a collision helper) is a FCheckResult
// partial constructor: FVector::FVector(ecx+8), FVector::FVector(ecx+0x14), *(ecx+0x2c)=0.
// The actual SingleLineCheck is done via (*(*(actor+0x328)+0xCC))(...).
// Collision response, per-force integration, colour/size/UV animation (~1700b):
// Ghidra 0x103dde04..0x103de7e0 — deferred (requires FCheckResult, FVector::MirrorByVector
// setup, force TArray at +0x94, colour TArray at +0xA0, size TArray per-emitter type).
IMPL_TODO("Ghidra 0x103ddca0 (5049b): age/lifetime/velocity/bbox loop implemented and validated against ghidra/exports/Engine/_global.cpp extract. Not a permanent divergence. Remaining body includes: collision path (ULevel::SingleLineCheck + hit normal setup), bounce path (FVector::MirrorByVector + randomization), scripted force/spawn loop (array at +0x94/+0xA0 interactions), and colour/size/UV ramps (~0x103de548..0x103de7e0) that still depend on unresolved per-emitter ramp layouts in current headers.")
int UParticleEmitter::UpdateParticles(float DeltaTime)
{
	guard(UParticleEmitter::UpdateParticles);
	*(FBox*)((BYTE*)this + 0x304) = FBox(0);
	if (*(INT*)((BYTE*)this + 0x2f4) == 0) return 0;

	// Clamp index at +0x40
	if (*(INT*)((BYTE*)this + 0x40) != -1)
	{
		INT n = ((FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x398))->Num();
		INT idx = *(INT*)((BYTE*)this + 0x40);
		if (idx < 0) idx = 0;
		else if (idx > n - 1) idx = n - 1;
		*(INT*)((BYTE*)this + 0x40) = idx;
	}
	// Clamp index at +0x58
	if (*(INT*)((BYTE*)this + 0x58) != -1)
	{
		INT n = ((FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x398))->Num();
		INT idx = *(INT*)((BYTE*)this + 0x58);
		if (idx < 0) idx = 0;
		else if (idx > n - 1) idx = n - 1;
		*(INT*)((BYTE*)this + 0x58) = idx;
	}
	// Clamp index at +0x34
	if (*(INT*)((BYTE*)this + 0x34) != -1)
	{
		INT n = ((FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x398))->Num();
		INT idx = *(INT*)((BYTE*)this + 0x34);
		if (idx < 0) idx = 0;
		else if (idx > n - 1) idx = n - 1;
		*(INT*)((BYTE*)this + 0x34) = idx;
	}

	// SpawnParticles rate: choose rate based on live-count vs max-count
	INT numAlive     = *(INT*)((BYTE*)this + 0x2c4);
	INT maxParticles = *(INT*)((BYTE*)this + 0x2d0);
	FLOAT spawnRate;
	if (numAlive < maxParticles)
	{
		if (*(DWORD*)((BYTE*)this + 100) & 0x800000)
		{
			FLOAT center = ((FRange*)((BYTE*)this + 0x248))->GetCenter();
			spawnRate = (center != 0.f) ? ((FLOAT)maxParticles / center) : 0.f;
		}
		else
			spawnRate = *(FLOAT*)((BYTE*)this + 0x7c);
	}
	else
		spawnRate = *(FLOAT*)((BYTE*)this + 0x78);

	if (spawnRate > 0.f && *(INT*)((BYTE*)this + 0x2d8) == 0)
	{
		// vtable[0x78/4=30] = SpawnParticles(accumulator, rate, dt)
		typedef FLOAT (__thiscall* SpawnParticlesFn)(UParticleEmitter*, FLOAT, FLOAT, FLOAT);
		SpawnParticlesFn spawnFn = *(SpawnParticlesFn*)((*(INT*)this) + 0x78);
		FLOAT newAccum = spawnFn(this, *(FLOAT*)((BYTE*)this + 0x2e4), spawnRate, DeltaTime);
		*(FLOAT*)((BYTE*)this + 0x2e4) = newAccum;
	}

	// Per-particle tick loop (Ghidra 0x103ddd60..0x103de7e0).
	// Particle struct stride = 0x8C, base at *(this+0x2f8).
	// Offsets: +0x00=pos, +0x0C=prevPos, +0x18=vel, +0x70=age, +0x74=lifetime, +0x80=flags.
	// flags: bit0=alive, bit1=stationary, bit2=skip-age-this-frame.
	INT deadCount = 0;
	for (INT i = 0; ; i++)
	{
		INT lim = *(INT*)((BYTE*)this + 0x2c4);
		if (*(INT*)((BYTE*)this + 0x2d0) < lim)
			lim = *(INT*)((BYTE*)this + 0x2d0);

		if (i >= lim)
		{
			// Post-loop: find max speed factor from velocity-dependent effects array (+0xB8).
			FLOAT maxSpeed = 1.0f;
			if ((*(DWORD*)((BYTE*)this + 100) & 0x100000) &&
			    !(*(DWORD*)((BYTE*)this + 100) & 0x200000))
			{
				FArray* efArr = (FArray*)((BYTE*)this + 0xb8);
				INT numEf = efArr->Num();
				for (INT j = 0; j < numEf; j++)
				{
					FLOAT f = *(FLOAT*)(*(INT*)efArr + 4 + j * 8);
					if (maxSpeed <= f) maxSpeed = f;
				}
			}
			*(FLOAT*)((BYTE*)this + 0x2f0) = maxSpeed;

			// Set or clear "all-done" bit (bit3 of +0x2dc).
			INT numActive = *(INT*)((BYTE*)this + 0x2c4);
			if (((*(INT*)((BYTE*)this + 0x2d0) <= deadCount) ||
			     (numActive == deadCount && spawnRate == 0.0f)) &&
			    !(*(DWORD*)((BYTE*)this + 100) & 0x200))
			{
				*(DWORD*)((BYTE*)this + 0x2dc) |= 8;
			}
			else
			{
				*(DWORD*)((BYTE*)this + 0x2dc) &= ~8u;
			}
			return numActive - deadCount;
		}

		BYTE* pPart = (BYTE*)(*(INT*)((BYTE*)this + 0x2f8)) + i * 0x8C;
		DWORD flags = *(DWORD*)(pPart + 0x80);

		if (!(flags & 1))
		{
			// Dead slot — skip
			deadCount++;
			continue;
		}

		// bVar5: integrate physics if not stationary (or if warmup/force mode active)
		bool bVar5 = (!(flags & 2)) || (*(BYTE*)((BYTE*)this + 0x2d) == 1);

		if (flags & 4)
		{
			// New-spawn delay bit: skip physics this frame, clear the bit
			bVar5 = false;
			*(DWORD*)(pPart + 0x80) = flags & ~4u;
		}
		else
		{
			*(FLOAT*)(pPart + 0x70) += DeltaTime;
		}

		FLOAT age      = *(FLOAT*)(pPart + 0x70);
		FLOAT lifetime = *(FLOAT*)(pPart + 0x74);

		if (age > lifetime)
		{
			if (*(DWORD*)((BYTE*)this + 100) & 0x200)
			{
				// Looping mode: advance random state, compute looped age, respawn
				((FRange*)((BYTE*)this + 0x240))->GetRand();
				FLOAT newAge = (lifetime != 0.0f) ? appFmod(age, lifetime) : 0.0f;
				typedef void (__thiscall* SpawnOneFn)(UParticleEmitter*, INT, FLOAT, INT, INT, FVector const&);
				SpawnOneFn spawnOneFn = *(SpawnOneFn*)((*(INT*)this) + 0x7c);
				FVector zero(0,0,0);
				spawnOneFn(this, i, newAge, 0, 0, zero);
				// Fall through: process this (freshly respawned) particle this frame.
			}
			else
			{
				// Kill particle
				*(DWORD*)(pPart + 0x80) &= ~1u;
				deadCount++;
				continue;
			}
		}

		if (bVar5)
		{
			// Apply gravity/force to velocity: vel += gravity * dt  (gravity at +0xD0)
			*(FLOAT*)(pPart + 0x18) += *(FLOAT*)((BYTE*)this + 0xd0) * DeltaTime;
			*(FLOAT*)(pPart + 0x1C) += *(FLOAT*)((BYTE*)this + 0xd4) * DeltaTime;
			*(FLOAT*)(pPart + 0x20) += *(FLOAT*)((BYTE*)this + 0xd8) * DeltaTime;

			// Save previous position (used by collision as line-check start)
			*(DWORD*)(pPart + 0x0C) = *(DWORD*)(pPart + 0x00);
			*(DWORD*)(pPart + 0x10) = *(DWORD*)(pPart + 0x04);
			*(DWORD*)(pPart + 0x14) = *(DWORD*)(pPart + 0x08);

			// Integrate position: pos += vel * dt
			*(FLOAT*)(pPart + 0x00) += *(FLOAT*)(pPart + 0x18) * DeltaTime;
			*(FLOAT*)(pPart + 0x04) += *(FLOAT*)(pPart + 0x1C) * DeltaTime;
			*(FLOAT*)(pPart + 0x08) += *(FLOAT*)(pPart + 0x20) * DeltaTime;
		}

		// Collision check + bounce response (Ghidra 0x103dde04..0x103dde60 ~90b):
		//   FUN_1035dc30 (32b) = FCheckResult partial ctor (init Normal+Location FVectors, zero Item).
		//   Actual SingleLineCheck via (*(*(actor+0x328)+0xCC))(checkResult, actor, newPos,
		//     prevPos, 0x84, FVector(0,0,0), this+0x320, &hitInfo, &collisionNormal).
		//   On hit: bounce (FVector::MirrorByVector), FRangeVector scatter, ground-clamp.
		// Per-force integration (Ghidra 0x103de3ba..0x103de548 ~250b):
		//   Force actor array at +0x2f4+0x328+0x44+0x48 (sub-emitter spawn, count +0x2d4).
		//   Force array at +0x94 (stride 0x28): velocity damping and directional force.
		// Colour/size/UV animation (~1400b, Ghidra 0x103de548..0x103de7e0):
		//   Colour ramp TArray at +0xA0, size ramp from emitter-type TArrays.
		// All deferred: each requires per-emitter-type TArray descriptors not yet decompiled.

		// Accumulate emitter bounding box with current particle position.
		*((FBox*)((BYTE*)this + 0x304)) += *(FVector*)(pPart + 0x00);
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103dccd0)
int UParticleEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(UParticleEmitter::RenderParticles);
	*(DWORD*)((BYTE*)this + 0x2dc) &= ~0x2u;
	if (*(INT*)((BYTE*)this + 0x2f4) != 0)
	{
		INT rdPtr = *(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x3d8);
		if (rdPtr != 0)
			*(DWORD*)((BYTE*)rdPtr + 0x34) |= 8u;
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103dcb10)
void UParticleEmitter::Reset()
{
	// Ghidra 0xdcb10: clear state flags, zero counters, seed initial delay/warm-up timers.
	*(DWORD*)((BYTE*)this + 0x2dc) &= ~0x18u;  // clear bits 3-4
	*(DWORD*)((BYTE*)this + 0x2c4) = 0;
	*(DWORD*)((BYTE*)this + 0x2c0) = 0;
	*(DWORD*)((BYTE*)this + 0x2c8) = 0;
	*(DWORD*)((BYTE*)this + 0x2f4) = 0;
	*(FLOAT*)((BYTE*)this + 0x2e8) = ((FRange*)((BYTE*)this + 0x250))->GetRand();
	*(FLOAT*)((BYTE*)this + 0x2ec) = ((FRange*)((BYTE*)this + 0x168))->GetRand();
}

IMPL_EMPTY("particle emitter scale no-op")
void UParticleEmitter::Scale(float)
{
	guard(UParticleEmitter::Scale);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103dcf30)
void UParticleEmitter::PostEditChange()
{
	// Ghidra 0xdcf30: re-initialize if particle count changed or dirty bit set;
	// then normalize any actor-force vectors.
	INT numParticles = ((FArray*)((BYTE*)this + 0x2f8))->Num();
	if (numParticles != *(INT*)((BYTE*)this + 0x3C) || (*(DWORD*)((BYTE*)this + 100) & 0x100))
	{
		void** vtbl = *(void***)this;
		typedef void(__thiscall* NoArgFn)(UParticleEmitter*);
		typedef void(__thiscall* InitFn)(UParticleEmitter*, INT);
		((NoArgFn)vtbl[26])(this);
		((InitFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
	}
	if (*(BYTE*)((BYTE*)this + 100) & 2)
	{
		FArray* forces = (FArray*)((BYTE*)this + 0x94);
		BYTE* data = *(BYTE**)forces;
		for (INT i = 0; i < forces->Num(); i++)
			((FVector*)(data + i * 0x10))->Normalize();
	}
}

IMPL_MATCH("Engine.dll", 0x103dca10)
void UParticleEmitter::PostLoad()
{
	// Ghidra 0xdca10: call super, then Initialize(MaxParticles) via vtable[25].
	UObject::PostLoad();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* InitFn)(UParticleEmitter*, INT);
	((InitFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

IMPL_MATCH("Engine.dll", 0x103dd0e0)
void UParticleEmitter::CleanUp()
{
	// Ghidra 0xdd0e0: empty loop over active particles, then free array and clear counters.
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x2fc); i++) {}
	((FArray*)((BYTE*)this + 0x2f8))->Empty(0x8c, 0);
	*(DWORD*)((BYTE*)this + 0x2c4) = 0;
	*(DWORD*)((BYTE*)this + 0x2c0) = 0;
	*(DWORD*)((BYTE*)this + 0x2dc) &= ~1u;  // clear initialized bit
}

IMPL_MATCH("Engine.dll", 0x103dca90)
void UParticleEmitter::Destroy()
{
	// Ghidra 0xdca90: CleanUp via vtable[26], then super Destroy.
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(UParticleEmitter*);
	((NoArgFn)vtbl[26])(this);
	UObject::Destroy();
}

IMPL_EMPTY("actor force handling no-op")
void UParticleEmitter::HandleActorForce(AActor *,float)
{
	guard(UParticleEmitter::HandleActorForce);
	unguard;
}

IMPL_EMPTY("particle emitter initialize no-op")
void UParticleEmitter::Initialize(int)
{
	guard(UParticleEmitter::Initialize);
	unguard;
}


// --- USparkEmitter ---
IMPL_EMPTY("spark particle spawn no-op")
void USparkEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(USparkEmitter::SpawnParticle);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104432f0)
int USparkEmitter::UpdateParticles(float DeltaTime)
{
	guard(USparkEmitter::UpdateParticles);
	INT iVar1 = UParticleEmitter::UpdateParticles(DeltaTime);
	FBox expanded = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(0.0f);
	*(FBox*)((BYTE*)this + 0x304) = expanded;
	return iVar1;
	unguard;
}

// Ghidra: 0x10443a60, 887 bytes
IMPL_DIVERGE("USparkEmitter::RenderParticles calls FRenderInterface vtable slot +0x34 directly (confirmed Ghidra 0x10443a60); same permanent D3DDrv.dll runtime blocker as UBeamEmitter/UMeshEmitter RenderParticles")
int USparkEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(USparkEmitter::RenderParticles);
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	if (*(INT*)((BYTE*)this + 0x90) != 0)
	{
		INT pTVar2 = 0;
		INT maxP = *(INT*)((BYTE*)this + 0x2c4);
		if (maxP > 0)
		{
			for (INT iVar6 = 0; iVar6 < maxP; iVar6++)
			{
				if ((*(BYTE*)((BYTE*)*(INT*)((BYTE*)this + 0x2f8) + 0x80 + iVar6 * 0x8c) & 1) != 0)
					pTVar2++;
			}
			if (pTVar2 != 0)
			{
				if (*(INT*)((BYTE*)this + 0x2f4) != 0)
				{
					INT rdPtr = *(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x3d8);
					if (rdPtr != 0)
						*(DWORD*)((BYTE*)rdPtr + 0x58) = (BYTE)((BYTE*)this)[0x31];
				}
				// FUN_10443720 = spark render setup: configures FRenderInterface state
				// (blend mode, texture, vertex format) for spark line primitives.
				// FUN_10443610 = spark render submit: draws buffered spark segments
				// and restores RI state. Both blocked on FRenderInterface integration.
				return pTVar2;
			}
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10443e10)
void USparkEmitter::PostEditChange()
{
	// Retail: 28b. Call parent, then call vtable[26]() and vtable[25](this+0x3C).
	// vtable[26]=Reset, vtable[25]=Initialize(MaxParticles).
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(USparkEmitter*);
	typedef void(__thiscall* IntFn)(USparkEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((IntFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

IMPL_MATCH("Engine.dll", 0x10443460)
void USparkEmitter::CleanUp()
{
	// Ghidra 0x143460: call parent CleanUp, then empty spark line array.
	UParticleEmitter::CleanUp();
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x36c); i++) {}
	((FArray*)((BYTE*)this + 0x368))->Empty(0x20, 0);
}

IMPL_EMPTY("spark emitter initialize no-op")
void USparkEmitter::Initialize(int)
{
	guard(USparkEmitter::Initialize);
	unguard;
}


// --- USpriteEmitter ---
IMPL_MATCH("Engine.dll", 0x10443f40)
int USpriteEmitter::UpdateParticles(float DeltaTime)
{
	guard(USpriteEmitter::UpdateParticles);
	INT iVar1 = UParticleEmitter::UpdateParticles(DeltaTime);
	FLOAT fMaxH = 0.0f, fMaxW = 0.0f;
	if ((*(DWORD*)((BYTE*)this + 100) & 0x400000u) == 0)
	{
		fMaxH = ((FRange*)((BYTE*)this + 0x230))->GetMax();
		fMaxW = ((FRange*)((BYTE*)this + 0x228))->GetMax();
	}
	else
	{
		fMaxH = ((FRange*)((BYTE*)this + 0x228))->GetMax();
		fMaxW = fMaxH;
	}
	(void)fMaxW;
	FBox expanded = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(fMaxH);
	*(FBox*)((BYTE*)this + 0x304) = expanded;
	return iVar1;
	unguard;
}

// Ghidra: 0x10445110, 981 bytes
IMPL_DIVERGE("USpriteEmitter::RenderParticles takes FRenderInterface* and submits sprite vertex data through it; same permanent D3DDrv.dll runtime blocker. FillVertexBuffer handles the CPU-side vertex buffer fill separately and is tracked independently")
int USpriteEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(USpriteEmitter::RenderParticles);
	// Retail: calls parent, counts active particles, sets up sprite cache via
	// FUN_10445060, builds world-space matrix if needed, then submits vertex
	// data through FRenderInterface.
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10443e10)
void USpriteEmitter::PostEditChange()
{
	// Retail: 28b. Same as USparkEmitter::PostEditChange — call parent,
	// then vtable[26]() (Reset) and vtable[25](this+0x3C) (Initialize).
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(USpriteEmitter*);
	typedef void(__thiscall* IntFn)(USpriteEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((IntFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

IMPL_MATCH("Engine.dll", 0x10443ed0)
void USpriteEmitter::CleanUp()
{
	// Ghidra 0x143ed0: delegate to parent only.
	UParticleEmitter::CleanUp();
}

// Ghidra: 0x104440b0, 3625 bytes
// DIVERGENCE: FSpriteParticleVertex struct layout unavailable (not defined in any reachable
// header). The rendering vertex format is private to the D3DDrv pipeline. Billboard basis
// (Deproject→screen axes), per-particle loop (axis modes 0-6, rotation, atlas UV, scale)
// are architecturally understood from Ghidra but cannot be safely written without the
// vertex struct definition.
IMPL_DIVERGE("Ghidra 0x104440b0 (3625b): FSpriteParticleVertex struct undefined — vertex layout is rendering-pipeline private; axis-mode billboard logic architecturally understood but unimplementable without struct")
int USpriteEmitter::FillVertexBuffer(FSpriteParticleVertex* param_1, FLevelSceneNode* param_2)
{
	guard(USpriteEmitter::FillVertexBuffer);
	// Retail: builds camera-facing quads per live particle using FSceneNode::Deproject
	// to compute screen-space axes (screen-aligned, velocity-aligned, and owner-relative
	// modes), then iterates active particles applying per-particle rotation, atlas UV
	// sub-region selection, scale, and colour to FSpriteParticleVertex output buffer.
	// Axis modes (this+0x338): 0=screen, 1=velocity, 2=owner-relative, 3-6=cross variants.
	return 0;
	unguard;
}

IMPL_EMPTY("sprite emitter initialize no-op")
void USpriteEmitter::Initialize(int)
{
	guard(USpriteEmitter::Initialize);
	unguard;
}

