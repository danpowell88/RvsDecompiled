/*=============================================================================
	UnEmitter.cpp: Particle emitter hierarchy (UParticleEmitter*)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- AEmitter ---
void AEmitter::Spawned()
{
	// Ghidra 0xdf2e0, 18B: set flag 4 at offset 0x3c8 when not in editor
	if (!GIsEditor)
		*(DWORD*)((BYTE*)this + 0x3c8) |= 4;
}

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
					// FUN_1050557c = FString::Printf used internally to format burst count.
				// Retail converts bCount (float) to an integer burst amount.
				// DIVERGENCE: burst count computation omitted; no burst spawn occurs.
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
			// Retail: calls Level->DestroyActor(this) via vtable when all emitters done.
			// DIVERGENCE: Level pointer not available at this call site without ULevel integration.
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

void AEmitter::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	guard(AEmitter::Render);
	unguard;
}

void AEmitter::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(AEmitter::RenderEditorInfo);
	unguard;
}

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
			*slot = nullptr;
		}
	}
}

int AEmitter::CheckForProjectors()
{
	guard(AEmitter::CheckForProjectors);
	INT result = 0;
	// FUN_0xdfe90 = collision hash projector check: queries FCollisionHash for projector
	// actors whose bounds overlap this emitter's bbox, returns the count clamped to [0,4].
	// DIVERGENCE: FCollisionHash integration not yet implemented; returns 0 (no projectors).
	if (result < 0) result = 0;
	else if (result > 3) result = 4;
	if (*(INT*)((BYTE*)this + 0x3d8) != 0)
		*(INT*)(*(INT*)((BYTE*)this + 0x3d8) + 0x80) = result;
	return result;
	unguard;
}

void AEmitter::Initialize()
{
	guard(AEmitter::Initialize);
	unguard;
}


// --- UBeamEmitter ---
void UBeamEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(UBeamEmitter::SpawnParticle);
	unguard;
}

void UBeamEmitter::UpdateActorHitList()
{
	guard(UBeamEmitter::UpdateActorHitList);
	unguard;
}

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
	iVar7 = 0;
	while (iVar7 < *(INT*)((BYTE*)this + 0x2c4)) { iVar7++; } // empty loop per Ghidra
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
	// FUN_10301560 = world-space transform helper for beam emitter; FUN_10370d70 = matrix
	// multiply to apply owner transform. DIVERGENCE: world-space transform not applied.
	return local_2c;
	unguard;
}

int UBeamEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(UBeamEmitter::RenderParticles);
	// FUN_0xcb0b0 = complex beam particle renderer: builds vertex buffers, applies matrix
	// transforms, sets up beam segments between source/target actors, and submits to RI.
	// DIVERGENCE: beam rendering omitted; too complex to implement without full vertex-buffer
	// infrastructure and actor-to-beam linking logic.
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

void UBeamEmitter::Scale(float)
{
	guard(UBeamEmitter::Scale);
	unguard;
}

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

void UBeamEmitter::CleanUp()
{
	// Ghidra 0x80af0, ~100b: empty beam/noise arrays then delegate to parent.
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x3e4); i++) {}
	((FArray*)((BYTE*)this + 0x3e0))->Empty(0x10, 0);
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x3f0); i++) {}
	((FArray*)((BYTE*)this + 0x3ec))->Empty(0xc, 0);
	UParticleEmitter::CleanUp();
}

void UBeamEmitter::Initialize(int)
{
	guard(UBeamEmitter::Initialize);
	unguard;
}


// --- UMeshEmitter ---
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

int UMeshEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(UMeshEmitter::RenderParticles);
	// DIVERGENCE: complex mesh particle rendering not implemented (requires full vertex
	// buffer + per-particle mesh-instance transform pipeline).
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

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

void UMeshEmitter::Initialize(int)
{
	guard(UMeshEmitter::Initialize);
	unguard;
}


// --- UParticleEmitter ---
void UParticleEmitter::SpawnIndividualParticles(int)
{
	guard(UParticleEmitter::SpawnIndividualParticles);
	unguard;
}

void UParticleEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(UParticleEmitter::SpawnParticle);
	unguard;
}

float UParticleEmitter::SpawnParticles(float,float,float)
{
	return 0.0f;
}

int UParticleEmitter::UpdateParticles(float DeltaTime)
{
	guard(UParticleEmitter::UpdateParticles);
	*(FBox*)((BYTE*)this + 0x304) = FBox(0);
	INT iVar20 = 0;
	if (*(INT*)((BYTE*)this + 0x2f4) == 0) return 0;
	if (*(INT*)((BYTE*)this + 0x40) != -1)
	{
		INT n = ((FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x2f4) + 0x398))->Num();
		INT idx = *(INT*)((BYTE*)this + 0x40);
		if (idx < 0) idx = 0;
		else if (idx >= n) idx = n - 1;
		*(INT*)((BYTE*)this + 0x40) = idx;
	}
	// TODO: SpawnParticles call and main particle tick loop.
	// DIVERGENCE: particle spawning and per-particle physics not implemented.
	return iVar20;
	unguard;
}

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

void UParticleEmitter::Scale(float)
{
	guard(UParticleEmitter::Scale);
	unguard;
}

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

void UParticleEmitter::PostLoad()
{
	// Ghidra 0xdca10: call super, then Initialize(MaxParticles) via vtable[25].
	UObject::PostLoad();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* InitFn)(UParticleEmitter*, INT);
	((InitFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

void UParticleEmitter::CleanUp()
{
	// Ghidra 0xdd0e0: empty loop over active particles, then free array and clear counters.
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x2fc); i++) {}
	((FArray*)((BYTE*)this + 0x2f8))->Empty(0x8c, 0);
	*(DWORD*)((BYTE*)this + 0x2c4) = 0;
	*(DWORD*)((BYTE*)this + 0x2c0) = 0;
	*(DWORD*)((BYTE*)this + 0x2dc) &= ~1u;  // clear initialized bit
}

void UParticleEmitter::Destroy()
{
	// Ghidra 0xdca90: CleanUp via vtable[26], then super Destroy.
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(UParticleEmitter*);
	((NoArgFn)vtbl[26])(this);
	UObject::Destroy();
}

void UParticleEmitter::HandleActorForce(AActor *,float)
{
	guard(UParticleEmitter::HandleActorForce);
	unguard;
}

void UParticleEmitter::Initialize(int)
{
	guard(UParticleEmitter::Initialize);
	unguard;
}


// --- USparkEmitter ---
void USparkEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
	guard(USparkEmitter::SpawnParticle);
	unguard;
}

int USparkEmitter::UpdateParticles(float DeltaTime)
{
	guard(USparkEmitter::UpdateParticles);
	INT iVar1 = UParticleEmitter::UpdateParticles(DeltaTime);
	FBox expanded = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(0.0f);
	*(FBox*)((BYTE*)this + 0x304) = expanded;
	return iVar1;
	unguard;
}

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
				// FUN_10443720 = spark render setup: configures RenderInterface state
			// (blend mode, texture, vertex format) for spark line primitives.
			// FUN_10443610 = spark render submit/cleanup: draws buffered spark segments
			// and restores RI state.
			// DIVERGENCE: spark rendering omitted — RI setup/submit infrastructure needed.
			return pTVar2;
			}
		}
	}
	return 0;
	unguard;
}

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

void USparkEmitter::CleanUp()
{
	// Ghidra 0x143460: call parent CleanUp, then empty spark line array.
	UParticleEmitter::CleanUp();
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0x36c); i++) {}
	((FArray*)((BYTE*)this + 0x368))->Empty(0x20, 0);
}

void USparkEmitter::Initialize(int)
{
	guard(USparkEmitter::Initialize);
	unguard;
}


// --- USpriteEmitter ---
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

int USpriteEmitter::RenderParticles(FDynamicActor* param_1, FLevelSceneNode* param_2, TList<FDynamicLight*>* param_3, FRenderInterface* param_4)
{
	guard(USpriteEmitter::RenderParticles);
	// TODO: complex sprite particle rendering (~700 lines in Ghidra)
	UParticleEmitter::RenderParticles(param_1, param_2, param_3, param_4);
	return 0;
	unguard;
}

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

void USpriteEmitter::CleanUp()
{
	// Ghidra 0x143ed0: delegate to parent only.
	UParticleEmitter::CleanUp();
}

int USpriteEmitter::FillVertexBuffer(FSpriteParticleVertex* param_1, FLevelSceneNode* param_2)
{
	guard(USpriteEmitter::FillVertexBuffer);
	// TODO: complex vertex buffer fill (Ghidra line 166974)
	return 0;
	unguard;
}

void USpriteEmitter::Initialize(int)
{
	guard(USpriteEmitter::Initialize);
	unguard;
}

