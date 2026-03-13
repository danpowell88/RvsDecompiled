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

int AEmitter::Tick(float,ELevelTick)
{
	return 0;
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
	return 0;
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

int UBeamEmitter::UpdateParticles(float)
{
	return 0;
}

int UBeamEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
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
int UMeshEmitter::UpdateParticles(float)
{
	return 0;
}

int UMeshEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
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

int UParticleEmitter::UpdateParticles(float)
{
	return 0;
}

int UParticleEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
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

int USparkEmitter::UpdateParticles(float)
{
	return 0;
}

int USparkEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
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
int USpriteEmitter::UpdateParticles(float)
{
	return 0;
}

int USpriteEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
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

int USpriteEmitter::FillVertexBuffer(FSpriteParticleVertex *,FLevelSceneNode *)
{
	return 0;
}

void USpriteEmitter::Initialize(int)
{
	guard(USpriteEmitter::Initialize);
	unguard;
}

