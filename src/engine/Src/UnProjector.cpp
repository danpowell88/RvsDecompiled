/*=============================================================================
	UnProjector.cpp: Projector actors (AProjector, UProjectorPrimitive)
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

// --- AProjector ---
int AProjector::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x4000)
		return 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}

void AProjector::TickSpecial(float DeltaTime)
{
	// Retail: 17b. If lifecycle state byte at this+0x2C == 5, call vtable[100] (offset 0x190).
	if (*(BYTE*)((BYTE*)this + 0x2C) == 5)
	{
		void** vtbl = *(void***)this;
		typedef void (__thiscall *FnType)(AProjector*);
		((FnType)vtbl[100])(this);
	}
}

void AProjector::UpdateParticleMaterial(UParticleMaterial *,int)
{
}

void AProjector::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AProjector::RenderWireframe(FRenderInterface *)
{
}

void AProjector::PostEditChange()
{
}

void AProjector::PostEditLoad()
{
}

void AProjector::PostEditMove()
{
}

void AProjector::Abandon()
{
}

void AProjector::Attach()
{
}

void AProjector::CalcMatrix()
{
}

void AProjector::Destroy()
{
}

void AProjector::Detach(int)
{
}

UPrimitive * AProjector::GetPrimitive()
{
	return NULL;
}


// --- UProjectorPrimitive ---
int UProjectorPrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UProjectorPrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

void UProjectorPrimitive::Destroy()
{
}

FBox UProjectorPrimitive::GetCollisionBoundingBox(AActor const *) const
{
	// Retail: 30b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x470.
	return *(FBox*)((BYTE*)this + 0x470);
}

FVector UProjectorPrimitive::GetEncroachCenter(AActor* Actor)
{
	// Retail: 41b. Allocates temp FBox, calls virtual GetCollisionBoundingBox(Actor),
	// then calls FBox::GetCenter() on the result. Mirrors UStaticMesh::GetEncroachCenter.
	return GetCollisionBoundingBox(Actor).GetCenter();
}

FVector UProjectorPrimitive::GetEncroachExtent(AActor* Actor)
{
	// Retail: 41b. Same pattern as GetEncroachCenter but calls FBox::GetExtent().
	return GetCollisionBoundingBox(Actor).GetExtent();
}

