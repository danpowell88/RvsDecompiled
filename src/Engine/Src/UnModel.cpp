/*=============================================================================
	UnModel.cpp: UModel class registration.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() for UModel — the BSP tree geometry class
	used for level architecture. UModel method bodies (Serialize,
	LineCheck, PointRegion, etc.) currently live in EngineClassImpl.cpp
	and will migrate here as full decompilation progresses.

	This file is permanent and will grow as BSP/model code is
	decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UModel);
IMPLEMENT_CLASS(UPolys);

// =============================================================================
// Stubs imported from EngineStubs.cpp during file reorganization.
// These will be replaced with full implementations as decompilation progresses.
// =============================================================================
#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- UModel ---
IMPL_TODO("Needs Ghidra analysis")
void UModel::Render(FDynamicActor *,FLevelSceneNode *,FRenderInterface *)
{
	guard(UModel::Render);
	// Retail: renders the BSP model via the render interface.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UModel::AttachProjector(int,FProjectorRenderInfo *,FPlane *)
{
	guard(UModel::AttachProjector);
	// Retail: attaches a projector to the BSP model.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}


// --- UPolys ---
// Forward-declare the free operator<< for FPoly (defined later in this file).
extern FArchive& operator<<(FArchive& Ar, FPoly& V);
IMPL_INFERRED("Reconstructed from context")
void UPolys::Serialize(FArchive & Ar)
{
	// Retail: 0x2f9c0, 190 bytes. Serialize the FPoly TArray at this+0x2C.
	// If transient (Ar.IsTrans()), use the transient TArray serialize path.
	// Otherwise: CountBytes for memory stats, serialize count+max, then loop
	// streaming each FPoly via operator<<.
	UObject::Serialize(Ar);
	FArray& Polys = *(FArray*)((BYTE*)this + 0x2C);
	if (Ar.IsTrans()) {
		Polys.CountBytes(Ar, 0x15C);
		if (Ar.IsLoading()) {
			FCompactIndex count;
			Ar << count;
			INT n = *(INT*)&count;
			Polys.Empty(0x15C, n);
			for (INT i = 0; i < n; i++) {
				INT idx = Polys.Add(1, 0x15C);
				Ar << *(FPoly*)((BYTE*)Polys.GetData() + idx * 0x15C);
			}
		} else {
			// ArrayNum is protected; read it via Num() and serialize as FCompactIndex.
			INT num = Polys.Num();
			Ar << *(FCompactIndex*)&num;
			for (INT i = 0; i < Polys.Num(); i++)
				Ar << *(FPoly*)((BYTE*)Polys.GetData() + i * 0x15C);
		}
	} else {
		Polys.CountBytes(Ar, 0x15C);
		if (Ar.IsLoading()) {
			FCompactIndex count;
			Ar.ByteOrderSerialize((void*)&count, 4);
			INT n = *(INT*)&count;
			Polys.Empty(0x15C, n);
			for (INT i = 0; i < n; i++) {
				INT idx = Polys.Add(1, 0x15C);
				Ar << *(FPoly*)((BYTE*)Polys.GetData() + idx * 0x15C);
			}
		} else {
			// Serialize ArrayNum then ArrayMax via raw pointer to bypass protected access.
			// FArray layout: {void* Data @ 0, INT ArrayNum @ sizeof(void*), INT ArrayMax @ sizeof(void*)+4}
			INT* rawNum = (INT*)((BYTE*)&Polys + sizeof(void*));
			INT* rawMax = rawNum + 1;
			Ar.ByteOrderSerialize(rawNum, 4);
			Ar.ByteOrderSerialize(rawMax, 4);
			for (INT i = 0; i < Polys.Num(); i++)
				Ar << *(FPoly*)((BYTE*)Polys.GetData() + i * 0x15C);
		}
	}
}


// =============================================================================
// UModel (moved from EngineClassImpl.cpp)
// =============================================================================

// UModel
// =============================================================================

IMPL_INFERRED("Reconstructed from context")
UModel::UModel( ABrush* Owner, INT InRootOutside ) {}
IMPL_INFERRED("Reconstructed from context")
void UModel::PostLoad() { Super::PostLoad(); }
IMPL_INFERRED("Reconstructed from context")
void UModel::Destroy() { Super::Destroy(); }
IMPL_INFERRED("Reconstructed from context")
void UModel::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
IMPL_INFERRED("Reconstructed from context")
INT UModel::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
INT UModel::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
FBox UModel::GetRenderBoundingBox( const AActor* Owner ) { return FBox(); }
IMPL_INFERRED("Reconstructed from context")
FBox UModel::GetCollisionBoundingBox( const AActor* Owner ) const { return FBox(); }
IMPL_INFERRED("Reconstructed from context")
void UModel::Illuminate( AActor* Owner, INT bExtra ) {}
IMPL_INFERRED("Reconstructed from context")
FVector UModel::GetEncroachExtent( AActor* Owner ) { return FVector(0,0,0); }
IMPL_INFERRED("Reconstructed from context")
FVector UModel::GetEncroachCenter( AActor* Owner ) { return FVector(0,0,0); }
IMPL_INFERRED("Reconstructed from context")
INT UModel::UseCylinderCollision( const AActor* Owner ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
TArray<INT> UModel::BoxLeaves( FBox Box ) { return TArray<INT>(); }
IMPL_INFERRED("Reconstructed from context")
void UModel::BuildBound() {}
IMPL_INFERRED("Reconstructed from context")
void UModel::BuildRenderData() {}
IMPL_INFERRED("Reconstructed from context")
void UModel::ClearRenderData( URenderDevice* RenDev ) {}
IMPL_INFERRED("Reconstructed from context")
void UModel::CompressLightmaps() {}
IMPL_INFERRED("Reconstructed from context")
INT UModel::ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
void UModel::EmptyModel( INT EmptySurfs, INT EmptyPolys ) {}
IMPL_INFERRED("Reconstructed from context")
BYTE UModel::FastLineCheck( FVector Start, FVector End ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
FLOAT UModel::FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const { return 0.0f; }
IMPL_INFERRED("Reconstructed from context")
void UModel::Modify( INT DoTransArrays ) {}
IMPL_INFERRED("Reconstructed from context")
void UModel::ModifyAllSurfs( INT SetBits ) {}
IMPL_INFERRED("Reconstructed from context")
void UModel::ModifySelectedSurfs( INT SetBits ) {}
IMPL_INFERRED("Reconstructed from context")
void UModel::ModifySurf( INT iSurf, INT SetBits ) {}
IMPL_INFERRED("Reconstructed from context")
FPointRegion UModel::PointRegion( AZoneInfo* Zone, FVector Location ) const { return FPointRegion(); }
IMPL_INFERRED("Reconstructed from context")
INT UModel::PotentiallyVisible( INT iLeaf0, INT iLeaf1 ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
void UModel::PrecomputeSphereFilter( const FPlane& Sphere ) {}
IMPL_INFERRED("Reconstructed from context")
INT UModel::R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End ) { return 0; }
IMPL_INFERRED("Reconstructed from context")
void UModel::ShrinkModel() {}
IMPL_INFERRED("Reconstructed from context")
void UModel::Transform( ABrush* Brush ) {}

// =============================================================================
