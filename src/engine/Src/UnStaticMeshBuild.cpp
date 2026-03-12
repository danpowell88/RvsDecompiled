/*=============================================================================
	UnStaticMeshBuild.cpp: Static mesh objects (UStaticMesh, UStaticMeshInstance)
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

// --- UStaticMesh ---
void UStaticMesh::StaticConstructor()
{
}

void UStaticMesh::PostEditChange()
{
}

void UStaticMesh::PostLoad()
{
}

// (merged from earlier occurrence)
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
}
void UStaticMesh::Build()
{
}
UMaterial * UStaticMesh::GetSkin(AActor *,int)
{
	return NULL;
}
FTags * UStaticMesh::GetTag(FString)
{
	return NULL;
}
void UStaticMesh::Serialize(FArchive& Ar)
{
	// Retail: 0x10449de0. Calls UPrimitive::Serialize (if version >= 0x55) or UObject::Serialize,
	// then serializes geometry arrays: +0x154/+0x158 (v<0x5C), +0x58 (triangle data),
	// +0x2C (render bounds), +0x1C4, +0x1D0 (materials), etc.
	// Divergence: simplified to base class; geometry is loaded from package.
	UObject::Serialize(Ar);
}
int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}
int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}
void UStaticMesh::Destroy()
{
	// Retail: 0x104469d0. Calls FUN_103582d0(this) to release the static mesh collision
	// node tree and triangle arrays at this+0x164. Then calls UObject::Destroy.
	typedef void (__cdecl *FreeMeshFn)(UStaticMesh*);
	((FreeMeshFn)0x103582d0)(this);
	UObject::Destroy();
}
FBox UStaticMesh::GetCollisionBoundingBox(const AActor*) const
{
	return FBox();
}
FVector UStaticMesh::GetEncroachCenter(AActor * Actor)
{
	// Retail: 41b. Calls GetCollisionBoundingBox, then FBox::GetCenter().
	return GetCollisionBoundingBox(Actor).GetCenter();
}
FVector UStaticMesh::GetEncroachExtent(AActor * Actor)
{
	// Retail: 41b. Calls GetCollisionBoundingBox, then FBox::GetExtent().
	return GetCollisionBoundingBox(Actor).GetExtent();
}
FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x2C to return buffer.
	return *(FBox*)((BYTE*)this + 0x2C);
}
FSphere UStaticMesh::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 23b. Copy-constructs FSphere from this+0x48.
	return *(FSphere*)((BYTE*)this + 0x48);
}
void UStaticMesh::Illuminate(AActor *,int)
{
}


// --- UStaticMeshInstance ---
void UStaticMeshInstance::Serialize(FArchive &)
{
}

void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
}

void UStaticMeshInstance::DetachProjectorClipped(AProjector *)
{
}

