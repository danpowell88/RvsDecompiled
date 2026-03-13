/*=============================================================================
	UnFluidSurface.cpp: Fluid surface actors and primitives
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

// --- AFluidSurfaceInfo ---
void AFluidSurfaceInfo::UpdateOscillatorList()
{
}

void AFluidSurfaceInfo::RebuildClampedBitmap()
{
}

void AFluidSurfaceInfo::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void AFluidSurfaceInfo::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AFluidSurfaceInfo::SetClampedBitmap(int,int,int)
{
}

void AFluidSurfaceInfo::FillIndexBuffer(void *)
{
}

void AFluidSurfaceInfo::FillVertexBuffer(void *)
{
}

int AFluidSurfaceInfo::GetClampedBitmap(int,int)
{
	return 0;
}

void AFluidSurfaceInfo::GetNearestIndex(FVector const &,int &,int &)
{
}

FVector AFluidSurfaceInfo::GetVertexPos(int,int)
{
	return FVector(0,0,0);
}


// --- AFluidSurfaceOscillator ---
void AFluidSurfaceOscillator::UpdateOscillation(float)
{
}

void AFluidSurfaceOscillator::PostEditChange()
{
}

void AFluidSurfaceOscillator::Destroy()
{
}


// --- UFluidSurfacePrimitive ---
void UFluidSurfacePrimitive::Serialize(FArchive& Ar)
{
	// Ghidra 0x98820: delegates directly to UPrimitive::Serialize.
	UPrimitive::Serialize(Ar);
}

int UFluidSurfacePrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UFluidSurfacePrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

FBox UFluidSurfacePrimitive::GetCollisionBoundingBox(AActor const *) const
{
	// Retail: 29b. REP MOVSD 7 DWORDs from *(this+0x58)+0x448.
	return *(FBox*)(*(BYTE**)((BYTE*)this + 0x58) + 0x448);
}

FBox UFluidSurfacePrimitive::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

FSphere UFluidSurfacePrimitive::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}

