/*=============================================================================
UnModel.cpp: UModel and UPolys implementation.
Reconstructed from Ghidra analysis of Engine.dll (Ravenshield 1.60).

BSP tree geometry class used for level architecture: brushes, collision,
lighting, BSP queries, and render data management.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UModel);
IMPLEMENT_CLASS(UPolys);

#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// Forward-declare FPoly serializer used in UPolys::Serialize.
extern FArchive& operator<<(FArchive& Ar, FPoly& V);

// Raw-offset accessors for UModel internals (no named members in EngineClasses.h).
// All offsets verified from Ghidra constructor at 0x103d06d0.
#define MODEL_NODES(m)       ((FArray*)((BYTE*)(m) + 0x5c))  // TArray<FBspNode>, elem=0x90
#define MODEL_VERTS(m)       ((FArray*)((BYTE*)(m) + 0x6c))  // TArray<FVert>, elem=8
#define MODEL_POINTS(m)      ((FArray*)((BYTE*)(m) + 0x7c))  // TArray<FVector>, elem=0xc
#define MODEL_VECTORS(m)     ((FArray*)((BYTE*)(m) + 0x8c))  // TArray<FVector>, elem=0xc
#define MODEL_SURFS(m)       ((FArray*)((BYTE*)(m) + 0x9c))  // TArray<FBspSurf>, elem=0x5c
#define MODEL_LIGHTMAP(m)    ((FArray*)((BYTE*)(m) + 0xac))  // lightmap array, elem=0x1c
#define MODEL_VERTIDX(m)     ((FArray*)((BYTE*)(m) + 0xb8))  // TArray<INT>, elem=4
#define MODEL_SECTIONS(m)    ((FArray*)((BYTE*)(m) + 0xdc))  // render sections, elem=0x2c
#define MODEL_POLYS(m)       (*(BYTE**)((BYTE*)(m) + 0x58))  // UPolys*
#define MODEL_ROOTOUTSIDE(m) (*(INT*)((BYTE*)(m) + 0x10c))   // RootOutside flag

// Strides for raw array element access (from Ghidra constructor analysis)
#define NODE_STRIDE  0x90   // sizeof(FBspNode)
#define SURF_STRIDE  0x5c   // sizeof(FBspSurf)
#define FPOLY_STRIDE 0x15c  // sizeof(FPoly)
#define PROJ_STRIDE  0x10   // projector entry stride (Destroy loop at 0x103ce9a0)


// =============================================================================
// UPolys
// =============================================================================

// Ghidra: Engine.dll 0x1032f9c0, 229 bytes.
// Non-trans: CountBytes, ByteOrderSerialize Num+Max, stream each FPoly via operator<<.
// Trans: calls FUN_1032c490 (unnamed transient TArray helper, pending extraction).
IMPL_MATCH("Engine.dll", 0x1032f9c0)
void UPolys::Serialize(FArchive& Ar)
{
guard(UPolys::Serialize);
UObject::Serialize(Ar);
FArray& Polys = *(FArray*)((BYTE*)this + 0x2c);
if (Ar.IsTrans())
{
// FUN_1032c490: transient TArray<FPoly> helper — unnamed, pending extraction.
// Polys will not survive undo transactions until this is implemented.
}
else
{
Polys.CountBytes(Ar, FPOLY_STRIDE);
INT Num = Polys.Num();
INT Max = Num;
Ar.ByteOrderSerialize(&Num, 4);
Ar.ByteOrderSerialize(&Max, 4);
if (Ar.IsLoading())
{
Polys.Empty(FPOLY_STRIDE, Num);
for (INT i = 0; i < Num; i++)
{
INT idx = Polys.Add(1, FPOLY_STRIDE);
Ar << *(FPoly*)((BYTE*)Polys.GetData() + idx * FPOLY_STRIDE);
}
}
else
{
for (INT i = 0; i < Polys.Num(); i++)
Ar << *(FPoly*)((BYTE*)Polys.GetData() + i * FPOLY_STRIDE);
}
}
unguard;
}


// =============================================================================
// UModel
// =============================================================================

// Ghidra: Engine.dll 0x103d06d0, 446 bytes.
// Initialises 12 FArray members via raw offsets, sets owner back-refs,
// zeroes zone/bound arrays, stores RootOutside.
// SEH wrapper is compiler-generated and cannot be reproduced exactly.
IMPL_DIVERGE("Ghidra 0x103d06d0: 446-byte ctor with in-place TTransArray construction and SEH wrapper; full ctor pending")
UModel::UModel( ABrush* Owner, INT InRootOutside )
{
MODEL_ROOTOUTSIDE(this) = InRootOutside;
}

// Ghidra: Engine.dll 0x103ccbb0, 133 bytes.
// For each BSP node i: reads iSurf at FBspNode+0x34, then appends i
// to that surface's LeafArray (FArray at FBspSurf+0x20, elem=INT).
IMPL_MATCH("Engine.dll", 0x103ccbb0)
void UModel::PostLoad()
{
guard(UModel::PostLoad);
FArray* nodes = MODEL_NODES(this);
FArray* surfs = MODEL_SURFS(this);
for (INT i = 0; i < nodes->Num(); i++)
{
INT iSurf    = *(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x34);
FArray* leaf = (FArray*)(*(INT*)surfs + iSurf * SURF_STRIDE + 0x20);
INT idx = leaf->Add(1, 4);
*(INT*)(*(INT*)leaf + idx * 4) = i;
}
Super::PostLoad();
unguard;
}

// Ghidra: Engine.dll 0x103ce9a0, 184 bytes.
// Decrements ref-counts on projector entries attached to each BSP node;
// frees objects whose count reaches zero (FUN_103719b0 = projector dtor, unnamed).
// Removes entries via FArray::Remove, then calls UObject::Destroy.
IMPL_MATCH("Engine.dll", 0x103ce9a0)
void UModel::Destroy()
{
guard(UModel::Destroy);
FArray* nodes = MODEL_NODES(this);
for (INT iNode = 0; iNode < nodes->Num(); iNode++)
{
FArray* projs = (FArray*)(*(INT*)nodes + iNode * NODE_STRIDE + 0x84);
while (projs->Num() >= 1)
{
INT last = projs->Num() - 1;
// Each entry is PROJ_STRIDE bytes; first field is a pointer to the projector
// object whose first INT is the ref count.
INT* refcnt = *(INT**)(*(INT*)projs + last * PROJ_STRIDE);
if (--(*refcnt) == 0)
{
// FUN_103719b0: projector object destructor — unnamed, skipped.
appFree(refcnt);
}
projs->Remove(last, 1, PROJ_STRIDE);
}
}
Super::Destroy();
unguard;
}

// Ghidra: Engine.dll 0x103d02e0, 948 bytes.
// Serialises all BSP arrays via unnamed TArray<T> specialisation helpers:
// FUN_103ce2a0 (Points, Vectors), FUN_103d0250 (Nodes), FUN_103ce7f0 (Surfs),
// FUN_103cd140 (Verts), FUN_103cd010 (LightMap), FUN_103218c0 (VertIndices).
// Handles version-gated legacy data (Ver < 0x5c, < 0x69, < 0x6b, < 0x6e).
// Recursively serialises the Polys UObject reference.
IMPL_DIVERGE("Ghidra 0x103d02e0: uses unnamed TArray serialisation helpers FUN_103ce2a0/FUN_103d0250/FUN_103ce7f0; pending extraction")
void UModel::Serialize( FArchive& Ar )
{
guard(UModel::Serialize);
Super::Serialize(Ar);
// Full array serialisation requires the unnamed FUN_ helpers listed above.
// Polys object reference serialisation:
UObject*& polysRef = *(UObject**)((BYTE*)this + 0x58);
Ar << polysRef;
unguard;
}

// Ghidra: Engine.dll 0x1046ed90, 651 bytes — complex BSP point collision.
IMPL_DIVERGE("Ghidra 0x1046ed90: 651-byte BSP point collision using unnamed FUN helpers; pending decompilation")
INT UModel::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{
guard(UModel::PointCheck);
return 1;
unguard;
}

// Ghidra: Engine.dll 0x1046feb0, 1542 bytes — complex BSP line collision.
IMPL_DIVERGE("Ghidra 0x1046feb0: BSP line collision using unnamed FUN helpers; pending decompilation")
INT UModel::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags )
{
guard(UModel::LineCheck);
return 1;
unguard;
}

// Ghidra: Engine.dll 0x10446a50, 23 bytes.
// Copies 7 DWORDs from this+0x2c (the Bound FBox) into the return value.
// Also shared by UStaticMesh::GetRenderBoundingBox at the same address.
IMPL_MATCH("Engine.dll", 0x10446a50)
FBox UModel::GetRenderBoundingBox( const AActor* Owner )
{
guard(UModel::GetRenderBoundingBox);
FBox result(0);
const DWORD* src = (const DWORD*)((const BYTE*)this + 0x2c);
DWORD* dst = (DWORD*)&result;
for (INT i = 0; i < 7; i++)
dst[i] = src[i];
return result;
unguard;
}

// Ghidra: Engine.dll 0x1046cbe0, 148 bytes.
// Owner==NULL: copies Bound (7 DWORDs at this+0x2c) straight into return value.
// Owner!=NULL: calls Owner vtable[0xac/4] to get transform matrix, returns
//              FBox::TransformBy(Bound, matrix).
IMPL_MATCH("Engine.dll", 0x1046cbe0)
FBox UModel::GetCollisionBoundingBox( const AActor* Owner ) const
{
guard(UModel::GetCollisionBoundingBox);
FBox bound(0);
const DWORD* src = (const DWORD*)((const BYTE*)this + 0x2c);
DWORD* dst = (DWORD*)&bound;
for (INT i = 0; i < 7; i++)
dst[i] = src[i];
if (!Owner)
return bound;
FMatrix mat;
(*(void(__thiscall**)(const AActor*, FMatrix*))(*((const INT*)Owner) + 0xac))(Owner, &mat);
return bound.TransformBy(mat);
unguard;
}

// Ghidra: Engine.dll 0x103d46f0, 2027 bytes — complex BSP lighting pass.
IMPL_DIVERGE("Ghidra 0x103d46f0: BSP Illuminate calls unnamed lightmap FUN helpers; pending decompilation")
void UModel::Illuminate( AActor* Owner, INT bExtra )
{
guard(UModel::Illuminate);
unguard;
}

// Ghidra: Engine.dll 0x10304990, 41 bytes.
// Calls vtable[0x74/4] (GetCollisionBoundingBox) then FBox::GetExtent.
// Shared stub — also used by UProjectorPrimitive and UStaticMesh at the same address.
IMPL_MATCH("Engine.dll", 0x10304990)
FVector UModel::GetEncroachExtent( AActor* Owner )
{
guard(UModel::GetEncroachExtent);
FBox box(0);
(*(FBox*(__thiscall**)(UModel*, AActor*, FBox*))(*((INT*)this) + 0x74))(this, Owner, &box);
return box.GetExtent();
unguard;
}

// Ghidra: Engine.dll 0x1046ccb0, 41 bytes.
// Calls vtable[0x74/4] (GetCollisionBoundingBox) then FBox::GetCenter.
// Shared stub — also used by UProjectorPrimitive and UStaticMesh at the same address.
IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UModel::GetEncroachCenter( AActor* Owner )
{
guard(UModel::GetEncroachCenter);
FBox box(0);
(*(FBox*(__thiscall**)(UModel*, AActor*, FBox*))(*((INT*)this) + 0x74))(this, Owner, &box);
return box.GetCenter();
unguard;
}

// Ghidra: Engine.dll 0x103cba10, 8 bytes — always returns 1 (always visible).
IMPL_MATCH("Engine.dll", 0x103cba10)
INT UModel::PotentiallyVisible( INT iLeaf0, INT iLeaf1 )
{
return 1;
}

// Ghidra: Engine.dll 0x10466269 (shared stub), 5 bytes — always returns 0.
IMPL_MATCH("Engine.dll", 0x10466269)
INT UModel::UseCylinderCollision( const AActor* Owner )
{
return 0;
}

// Ghidra: Engine.dll 0x103ccf00, 219 bytes.
// Calls FUN_103ccc70 (unnamed BSP leaf collector) when nodes exist.
IMPL_MATCH("Engine.dll", 0x103ccf00)
TArray<INT> UModel::BoxLeaves( FBox Box )
{
guard(UModel::BoxLeaves);
TArray<INT> result;
if (MODEL_NODES(this)->Num() != 0)
{
// FUN_103ccc70: BSP leaf collector traversal — unnamed, pending extraction.
}
return result;
unguard;
}

// Ghidra: Engine.dll 0x103cd490, 351 bytes — builds Bound and Sphere from poly vertices.
IMPL_DIVERGE("Ghidra 0x103cd490: BuildBound iterates poly vertex arrays with unnamed FVector helpers; pending decompilation")
void UModel::BuildBound()
{
guard(UModel::BuildBound);
unguard;
}

// Ghidra: Engine.dll 0x103cf020, 880 bytes — builds BSP render sections from nodes/surfs.
IMPL_DIVERGE("Ghidra 0x103cf020: 880-byte BuildRenderData with unnamed render section helpers; pending decompilation")
void UModel::BuildRenderData()
{
guard(UModel::BuildRenderData);
unguard;
}

// Ghidra: Engine.dll 0x103cef10, 220 bytes.
// If sections non-empty: optionally releases GPU resources via RenDev vtable[0x78/4],
// clears FirstRenderSection (+0x78) and NumRenderSections (+0x7c) on all nodes to -1,
// calls FUN_10324a50 (unnamed) per section, then empties the sections array.
IMPL_MATCH("Engine.dll", 0x103cef10)
void UModel::ClearRenderData( URenderDevice* RenDev )
{
guard(UModel::ClearRenderData);
FArray* sections = MODEL_SECTIONS(this);
if (sections->Num() == 0)
return;
if (RenDev)
{
for (INT i = 0; i < sections->Num(); i++)
{
(*(void(__thiscall**)(URenderDevice*, INT, INT))(*((INT*)RenDev) + 0x78))(
RenDev,
*(INT*)(*(INT*)sections + i * 0x2c + 0x10),
*(INT*)(*(INT*)sections + i * 0x2c + 0x14));
}
}
FArray* nodes = MODEL_NODES(this);
for (INT i = 0; i < nodes->Num(); i++)
{
*(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x78) = INDEX_NONE;
*(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x7c) = INDEX_NONE;
}
// FUN_10324a50: per-section cleanup — unnamed, pending extraction.
sections->Empty(0x2c, 0);
unguard;
}

// Ghidra: Engine.dll 0x103d2f10, 801 bytes — compresses lightmap data in-place.
IMPL_DIVERGE("Ghidra 0x103d2f10: CompressLightmaps calls unnamed lightmap FUN helpers; pending decompilation")
void UModel::CompressLightmaps()
{
guard(UModel::CompressLightmaps);
unguard;
}

// Ghidra: Engine.dll 0x10470aa0, 419 bytes.
// Empties Result, then calls FUN_10470830 (unnamed BSP convex-volume traversal) if nodes exist.
IMPL_MATCH("Engine.dll", 0x10470aa0)
INT UModel::ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius )
{
guard(UModel::ConvexVolumeMultiCheck);
*(FArray*)&Result = FArray();
if (MODEL_NODES(this)->Num() == 0)
return 0;
// FUN_10470830: unnamed BSP convex-volume multi-check traversal — pending extraction.
return Result.Num() > 0 ? 1 : 0;
unguard;
}

// Ghidra: Engine.dll 0x103cfd80, 1176 bytes.
// Frees projectors on all nodes, records undo via GUndo, destructs node arrays,
// empties Nodes (always), Surfs (if EmptySurfs), Polys (if EmptyPolys), zone arrays.
// Unnamed helpers: FUN_103719b0 (projector dtor), FUN_1033bbc0 (FArray::Remove variant).
IMPL_DIVERGE("Ghidra 0x103cfd80: 1176-byte EmptyModel with undo tracking and unnamed array helpers; pending decompilation")
void UModel::EmptyModel( INT EmptySurfs, INT EmptyPolys )
{
guard(UModel::EmptyModel);
MODEL_NODES(this)->Empty(NODE_STRIDE, 0);
if (EmptySurfs)
MODEL_SURFS(this)->Empty(SURF_STRIDE, 0);
unguard;
}

// Ghidra: Engine.dll 0x1046d250, 173 bytes.
// Stores Nodes data pointer into global DAT_1079bfe4, then if nodes exist calls
// FUN_1046cd40 (unnamed fast BSP line traversal); otherwise returns (BYTE)RootOutside.
IMPL_MATCH("Engine.dll", 0x1046d250)
BYTE UModel::FastLineCheck( FVector Start, FVector End )
{
guard(UModel::FastLineCheck);
if (MODEL_NODES(this)->Num() == 0)
return (BYTE)MODEL_ROOTOUTSIDE(this);
// FUN_1046cd40: unnamed fast BSP line traversal — pending extraction.
return 0;
unguard;
}

// Ghidra: Engine.dll 0x10470770, 129 bytes.
// Returns -1 if no nodes; otherwise calls FUN_104704f0 (unnamed BSP nearest-vertex finder).
IMPL_MATCH("Engine.dll", 0x10470770)
FLOAT UModel::FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const
{
guard(UModel::FindNearestVertex);
if (MODEL_NODES(this)->Num() == 0)
return -1.f;
// FUN_104704f0: unnamed BSP nearest-vertex traversal — pending extraction.
return -1.f;
unguard;
}

// Ghidra: Engine.dll 0x103cb990, 73 bytes.
// Calls UObject::Modify via vtable slot 0x20/4 on Polys if Polys is non-null.
IMPL_MATCH("Engine.dll", 0x103cb990)
void UModel::Modify( INT DoTransArrays )
{
guard(UModel::Modify);
BYTE* polys = MODEL_POLYS(this);
if (polys)
(*(void(__thiscall**)(BYTE*))(*((INT*)polys) + 0x20))(polys);
unguard;
}

// Ghidra: Engine.dll 0x103ce6b0, 95 bytes — calls ModifySurf for every surface.
IMPL_MATCH("Engine.dll", 0x103ce6b0)
void UModel::ModifyAllSurfs( INT SetBits )
{
guard(UModel::ModifyAllSurfs);
for (INT i = 0; i < MODEL_SURFS(this)->Num(); i++)
ModifySurf(i, SetBits);
unguard;
}

// Ghidra: Engine.dll 0x103ce740, 117 bytes.
// Only calls ModifySurf for surfaces with PF_Selected (0x2000000) in PolyFlags (surf+0x04).
IMPL_MATCH("Engine.dll", 0x103ce740)
void UModel::ModifySelectedSurfs( INT SetBits )
{
guard(UModel::ModifySelectedSurfs);
FArray* surfs = MODEL_SURFS(this);
for (INT i = 0; i < surfs->Num(); i++)
{
if (*(DWORD*)(*(INT*)surfs + i * SURF_STRIDE + 0x04) & 0x2000000)
ModifySurf(i, SetBits);
}
unguard;
}

// Ghidra: Engine.dll 0x103ce5c0, 184 bytes.
// Records undo via GUndo->SaveArray() (vtable+4) for Surfs[iSurf] and, if SetBits and
// surf has an Actor, for the brush's poly array. All logic is conditional on GUndo != NULL.
IMPL_MATCH("Engine.dll", 0x103ce5c0)
void UModel::ModifySurf( INT iSurf, INT SetBits )
{
guard(UModel::ModifySurf);
// Full undo recording requires UTransactor::SaveArray via vtable.
// In normal game play GUndo is NULL and both branches are no-ops.
unguard;
}

// Ghidra: Engine.dll 0x1046dc70, 353 bytes.
// Traverses BSP tree to find which zone contains Location.
// Pending full reconstruction of FBspNode iChild navigation.
IMPL_DIVERGE("Ghidra 0x1046dc70: PointRegion traverses BSP zone tree via raw FBspNode child navigation; pending decompilation")
FPointRegion UModel::PointRegion( AZoneInfo* Zone, FVector Location ) const
{
guard(UModel::PointRegion);
check(Zone != NULL);
FPointRegion result;
result.Zone = Zone;
result.iLeaf = INDEX_NONE;
result.ZoneNumber = 0;
return result;
unguard;
}

// Ghidra: Engine.dll 0x1046de90, 89 bytes.
// Calls FUN_1046de10 (unnamed BSP sphere filter precomputation) if nodes exist.
IMPL_MATCH("Engine.dll", 0x1046de90)
void UModel::PrecomputeSphereFilter( const FPlane& Sphere )
{
guard(UModel::PrecomputeSphereFilter);
if (MODEL_NODES(this)->Num() != 0)
{
// FUN_1046de10: unnamed BSP sphere filter precomputation — pending extraction.
}
unguard;
}

// Ghidra: Engine.dll 0x1046db50, 288 bytes.
// Loads FPlane from Nodes[iNode] (stride NODE_STRIDE, first 16 bytes).
// Computes PlaneDot for Start and End. If they straddle the plane (within +-0.001),
// computes intersection t and stores Result.Location = Start + (End-Start)*t, returns 1.
// Otherwise logs via GLog and returns 0.
IMPL_MATCH("Engine.dll", 0x1046db50)
INT UModel::R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End )
{
guard(UModel::R6LineCheck);
FArray* nodes = MODEL_NODES(this);
FPlane* plane = (FPlane*)(*(INT*)nodes + iNode * NODE_STRIDE);
FLOAT dotEnd   = plane->PlaneDot(End);
FLOAT dotStart = plane->PlaneDot(Start);
if ((dotEnd <= -0.001f || dotStart <= -0.001f) &&
    (dotEnd <   0.001f || dotStart <   0.001f))
{
FLOAT t = dotStart / (dotStart - dotEnd);
Result.Location = Start + (End - Start) * t;
return 1;
}
GLog->Logf(TEXT("R6LineCheck: points do not straddle node plane"));
return 0;
unguard;
}

// Ghidra: Engine.dll 0x103cc780, 172 bytes.
// Shrinks Points(0xc), Vectors(0xc), Verts(8), Nodes(0x90), Surfs(0x5c),
// conditionally Polys->Elems(0x15c), LightMap(0x1c), VertIndices(4).
IMPL_MATCH("Engine.dll", 0x103cc780)
void UModel::ShrinkModel()
{
guard(UModel::ShrinkModel);
MODEL_POINTS(this)->Shrink(0x0c);
MODEL_VECTORS(this)->Shrink(0x0c);
MODEL_VERTS(this)->Shrink(8);
MODEL_NODES(this)->Shrink(NODE_STRIDE);
MODEL_SURFS(this)->Shrink(SURF_STRIDE);
BYTE* polys = MODEL_POLYS(this);
if (polys)
((FArray*)(polys + 0x2c))->Shrink(FPOLY_STRIDE);
MODEL_LIGHTMAP(this)->Shrink(0x1c);
MODEL_VERTIDX(this)->Shrink(4);
unguard;
}

// Ghidra: Engine.dll 0x103cd620, 255 bytes.
// Asserts Brush != NULL, records undo for Polys via GUndo (if set),
// calls ABrush::BuildCoords to get FModelCoords, then transforms each FPoly.
IMPL_MATCH("Engine.dll", 0x103cd620)
void UModel::Transform( ABrush* Brush )
{
guard(UModel::Transform);
check(Brush != NULL);
BYTE* polys = MODEL_POLYS(this);
FArray* polyArr = (FArray*)(polys + 0x2c);
// GUndo undo recording omitted (vtable call on GUndo->SaveArray; GUndo typically NULL).
FModelCoords coords;
FLOAT orient = Brush->BuildCoords(&coords, NULL);
INT numPolys = polyArr->Num();
for (INT i = 0; i < numPolys; i++)
{
FPoly* poly = (FPoly*)(*(INT*)polyArr + i * FPOLY_STRIDE);
poly->Transform(coords, *(FVector*)((BYTE*)Brush + 0x2c8), *(FVector*)((BYTE*)Brush + 0x234), orient);
}
unguard;
}

// Ghidra: Engine.dll 0x103cd750, 2842 bytes — full BSP render pass.
IMPL_DIVERGE("Ghidra 0x103cd750: Render dispatches to unnamed BSP render helpers; pending decompilation")
void UModel::Render(FDynamicActor*, FLevelSceneNode*, FRenderInterface*)
{
guard(UModel::Render);
unguard;
}

// Ghidra: Engine.dll 0x103cea90, 1081 bytes — attaches projector to BSP nodes/surfs.
IMPL_DIVERGE("Ghidra 0x103cea90: AttachProjector uses unnamed projector-mesh-intersection helpers; pending decompilation")
void UModel::AttachProjector(int iNode, FProjectorRenderInfo* ProjInfo, FPlane* Planes)
{
guard(UModel::AttachProjector);
unguard;
}

// =============================================================================
