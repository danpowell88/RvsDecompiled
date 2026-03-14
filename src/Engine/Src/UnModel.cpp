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
// BSP helper function stubs -- implementations pending decompilation of
// UnBsp.cpp / unnamed Ghidra code segments.
// =============================================================================

// DAT_1079bfe4 -- Nodes.Data pointer cached for BSP traversal helpers.
static INT GBspNodes = 0;

// 0x1046cd40 -- fast BSP line check: traverses the BSP tree to classify a line segment.
IMPL_DIVERGE("Ghidra 0x1046cd40: BSP traversal helper called from UModel::FastLineCheck; full body in UnBsp.cpp, pending extraction")
static BYTE bspFastLineCheck( INT iNode, FLOAT sx, FLOAT sy, FLOAT sz,
                               FLOAT ex, FLOAT ey, FLOAT ez, BYTE rootOutside )
{
    return rootOutside;
}

// 0x104704f0 -- BSP nearest-vertex finder.
IMPL_DIVERGE("Ghidra 0x104704f0: BSP nearest-vertex helper called from UModel::FindNearestVertex; full body in UnBsp.cpp, pending extraction")
static FLOAT bspFindNearestVertexHelper( UModel* Model, const FVector* Src, FVector* Dst,
                                          FLOAT MinRadius, INT P5, INT* iVertex )
{
    return -1.0f;
}

// 0x103ccc70 -- BSP leaf enumerator: collects leaf indices overlapping a box.
IMPL_DIVERGE("Ghidra 0x103ccc70: BSP box-leaves traversal helper called from UModel::BoxLeaves; full body in UnBsp.cpp, pending extraction")
static void bspBoxLeavesHelper( UModel* Model, INT iNode,
                                 FLOAT cx, FLOAT cy, FLOAT cz,
                                 FLOAT ex, FLOAT ey, FLOAT ez,
                                 FArray* Result )
{
}

// 0x1046de10 -- BSP sphere filter precomputation pass.
IMPL_DIVERGE("Ghidra 0x1046de10: BSP sphere filter traversal helper called from UModel::PrecomputeSphereFilter; full body in UnBsp.cpp, pending extraction")
static void bspPrecomputeSphereFilterHelper( UModel* Model, INT iNode, const FPlane* Sphere )
{
}


// =============================================================================
// UPolys
// =============================================================================

// Ghidra: Engine.dll 0x1032f9c0, 229 bytes.
// Non-trans path: CountBytes, ByteOrderSerialize Num+Max, stream each FPoly.
// Trans path: CountBytes then compact-index count, then stream each FPoly.
IMPL_DIVERGE("Ghidra 0x1032f9c0: IsTrans path calls FUN_1032c490 (trans-array serialize helper); pending extraction")
void UPolys::Serialize( FArchive& Ar )
{
guard(UPolys::Serialize);
UObject::Serialize(Ar);
FArray& Polys = *(FArray*)((BYTE*)this + 0x2c);
if (Ar.IsTrans())
{
    Polys.CountBytes(Ar, FPOLY_STRIDE);
    if (Ar.IsLoading())
    {
        INT n = 0;
        Ar << *(FCompactIndex*)&n;
        Polys.Empty(FPOLY_STRIDE, n);
        for (INT i = 0; i < n; i++)
        {
            INT idx = Polys.Add(1, FPOLY_STRIDE);
            Ar << *(FPoly*)((BYTE*)Polys.GetData() + idx * FPOLY_STRIDE);
        }
    }
    else
    {
        INT num = Polys.Num();
        Ar << *(FCompactIndex*)&num;
        for (INT i = 0; i < Polys.Num(); i++)
            Ar << *(FPoly*)((BYTE*)Polys.GetData() + i * FPOLY_STRIDE);
    }
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
// Initialises 13 FArray members via raw offsets, stores UModel* back-references
// for the first 5 arrays (Nodes/Verts/Points/Vectors/Surfs), zeroes 256 zone
// property entries (0x40 bytes zeroed per 0x48-byte slot starting at this+0x128),
// sets RF_Transactional, calls EmptyModel(1,1), and -- if Owner is non-NULL --
// stores this as Owner->Brush (at Owner+0x178) and calls Owner::InitPosRotScale
// via vtable slot 0x188.
IMPL_DIVERGE("Ghidra 0x103d06d0: 446-byte ctor uses in-place TTransArray construction and calls ABrush->vtable[98]; pending decompilation")
UModel::UModel( ABrush* Owner, INT InRootOutside )
{
guard(UModel::UModel);
new((FArray*)((BYTE*)this + 0x5c)) FArray();  *(UModel**)((BYTE*)this + 0x68) = this;
new((FArray*)((BYTE*)this + 0x6c)) FArray();  *(UModel**)((BYTE*)this + 0x78) = this;
new((FArray*)((BYTE*)this + 0x7c)) FArray();  *(UModel**)((BYTE*)this + 0x88) = this;
new((FArray*)((BYTE*)this + 0x8c)) FArray();  *(UModel**)((BYTE*)this + 0x98) = this;
new((FArray*)((BYTE*)this + 0x9c)) FArray();  *(UModel**)((BYTE*)this + 0xa8) = this;
new((FArray*)((BYTE*)this + 0xac)) FArray();
new((FArray*)((BYTE*)this + 0xb8)) FArray();
new((FArray*)((BYTE*)this + 0xc4)) FArray();
new((FArray*)((BYTE*)this + 0xd0)) FArray();
new((FArray*)((BYTE*)this + 0xdc)) FArray();
new((FArray*)((BYTE*)this + 0xe8)) FArray();
new((FArray*)((BYTE*)this + 0xf4)) FArray();
new((FArray*)((BYTE*)this + 0x100)) FArray();
MODEL_ROOTOUTSIDE(this) = InRootOutside;
// Zero the first 0x40 bytes of each 0x48-byte zone-property slot.
// 256 entries -- Ravenshield BSP_MAX_ZONES == 256 (Ghidra-confirmed).
DWORD* p = (DWORD*)((BYTE*)this + 0x128);
for (INT i = 0; i < 0x100; i++)
{
    for (INT j = 0; j < 16; j++)
        p[j] = 0;
    p = (DWORD*)((BYTE*)p + 0x48);
}
SetFlags(RF_Transactional);
EmptyModel(1, 1);
if (Owner != NULL)
{
    *(UModel**)((BYTE*)Owner + 0x178) = this;
    // InitPosRotScale -- vtable slot 0x188 on ABrush.
    (*(void(__thiscall**)(ABrush*))(*((INT*)Owner) + 0x188))(Owner);
}
unguard;
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
IMPL_DIVERGE("Ghidra 0x103ce9a0: ref-count loop calls FUN_103719b0 (projector dtor) and FUN_1033bbc0 (remove variant); pending extraction")
void UModel::Destroy()
{
guard(UModel::Destroy);
// Projector ref-count loop and per-node cleanup pending extraction of
// FUN_103719b0 (projector dtor) and FUN_1033bbc0 (remove variant).
Super::Destroy();
unguard;
}

// Ghidra: Engine.dll 0x103d02e0, 948 bytes.
// Serialises all BSP arrays via unnamed TArray<T> specialisation helpers:
// FUN_103ce2a0 (Points, Vectors), FUN_103d0250 (Nodes), FUN_103ce7f0 (Surfs),
// FUN_103cd140 (Verts), FUN_103cd010 (LightMap), FUN_103218c0 (VertIndices).
// Handles version-gated legacy data (Ver < 0x5c, < 0x69, < 0x6b, < 0x6e).
// Primary fields serialised below; full BSP-array serialisation pending extraction.
IMPL_DIVERGE("Ghidra 0x103d02e0: uses unnamed TArray serialize helpers FUN_103ce2a0/FUN_103d0250/FUN_103ce7f0/FUN_103cd140; pending extraction")
void UModel::Serialize( FArchive& Ar )
{
guard(UModel::Serialize);
Super::Serialize(Ar);
Ar << *(UObject**)((BYTE*)this + 0x58);          // Polys UObject ref
Ar.ByteOrderSerialize((BYTE*)this + 0x10c, 4);   // RootOutside
Ar.ByteOrderSerialize((BYTE*)this + 0x110, 4);   // Linked
Ar.ByteOrderSerialize((BYTE*)this + 0x118, 4);   // NumSharedSides
Ar.ByteOrderSerialize((BYTE*)this + 0x11c, 4);   // NumZones
// Full BSP array serialisation (Nodes, Verts, Points, Vectors, Surfs, LightMap,
// VertIndices) via unnamed FUN_ helpers -- pending extraction.
unguard;
}

// Ghidra: Engine.dll 0x1046ed90, 651 bytes -- complex BSP point collision.
// Full body requires unnamed BSP traversal helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x1046ed90: 651-byte BSP point collision uses unnamed FUN helpers; pending decompilation")
INT UModel::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{
guard(UModel::PointCheck);
return 1;
unguard;
}

// Ghidra: Engine.dll 0x1046feb0, 1542 bytes -- complex BSP line collision.
// Full body requires unnamed BSP traversal helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x1046feb0: BSP line collision uses unnamed FUN helpers; pending decompilation")
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
IMPL_DIVERGE("Ghidra 0x1046cbe0: Owner!=NULL path calls Owner->vtable[0xac/4] for FMatrix; vtable slot not yet identified")
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

// Ghidra: Engine.dll 0x103d46f0, 2027 bytes -- complex BSP lighting pass.
// Full body requires unnamed lighting helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x103d46f0: 2027-byte BSP lighting pass calls unnamed lightmap FUN helpers; pending decompilation")
void UModel::Illuminate( AActor* Owner, INT bExtra )
{
guard(UModel::Illuminate);
unguard;
}

// Ghidra: Engine.dll 0x10304990, 41 bytes.
// Calls vtable[0x74/4] (GetCollisionBoundingBox) then FBox::GetExtent.
// Shared stub -- also used by UProjectorPrimitive and UStaticMesh at the same address.
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
// Shared stub -- also used by UProjectorPrimitive and UStaticMesh at the same address.
IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UModel::GetEncroachCenter( AActor* Owner )
{
guard(UModel::GetEncroachCenter);
FBox box(0);
(*(FBox*(__thiscall**)(UModel*, AActor*, FBox*))(*((INT*)this) + 0x74))(this, Owner, &box);
return box.GetCenter();
unguard;
}

// Ghidra: Engine.dll 0x103cba10, 8 bytes -- always returns 1 (always visible).
IMPL_MATCH("Engine.dll", 0x103cba10)
INT UModel::PotentiallyVisible( INT iLeaf0, INT iLeaf1 )
{
return 1;
}

// Ghidra: Engine.dll 0x10466269 (shared stub), 5 bytes -- always returns 0.
IMPL_MATCH("Engine.dll", 0x10466269)
INT UModel::UseCylinderCollision( const AActor* Owner )
{
return 0;
}

// Ghidra: Engine.dll 0x103ccf00, 219 bytes.
// Decomposes Box into centre+extent, then calls FUN_103ccc70 (BSP leaf collector)
// if the model has nodes.
IMPL_DIVERGE("Ghidra 0x103ccf00: calls FUN_103ccc70 (BSP leaf collector traversal); pending extraction")
TArray<INT> UModel::BoxLeaves( FBox Box )
{
guard(UModel::BoxLeaves);
TArray<INT> result;
if (MODEL_NODES(this)->Num() != 0)
{
    FVector center, extent;
    Box.GetCenterAndExtents(center, extent);
    bspBoxLeavesHelper(this, 0,
                       center.X, center.Y, center.Z,
                       extent.X, extent.Y, extent.Z,
                       (FArray*)&result);
}
return result;
unguard;
}

// Ghidra: Engine.dll 0x103cd490, 351 bytes.
// Iterates all polys, collects vertices into a temporary FVector array (FArray of
// 0xc-byte elements), then builds FBox (this+0x2c) and FSphere (this+0x48) from
// those points.  Falls back to an invalid FBox when no polys exist.
// Vertex layout within FPoly: header is 0x30 bytes (4 x FVector), then numVerts
// vertices at stride 0xc; numVerts is stored at FPoly+0x100.
IMPL_MATCH("Engine.dll", 0x103cd490)
void UModel::BuildBound()
{
guard(UModel::BuildBound);
BYTE* polysPtr = MODEL_POLYS(this);
if (polysPtr != NULL)
{
    FArray* polysArr = (FArray*)(polysPtr + 0x2c);
    INT numPolys = polysArr->Num();
    if (numPolys != 0)
    {
        {
            FArray verts;
            BYTE* polyData = (BYTE*)polysArr->GetData();
            for (INT j = 0; j < numPolys; j++)
            {
                BYTE* poly   = polyData + j * FPOLY_STRIDE;
                INT numVerts = *(INT*)(poly + 0x100);
                for (INT i = 0; i < numVerts; i++)
                {
                    FVector* vtx = (FVector*)(poly + 0x30 + i * 0x0c);
                    INT idx      = verts.Add(1, 0x0c);
                    *(FVector*)((BYTE*)verts.GetData() + idx * 0x0c) = *vtx;
                }
            }
            INT      count  = verts.Num();
            FVector* points = (FVector*)verts.GetData();
            FBox box(points, count);
            DWORD* bsrc = (DWORD*)&box;
            DWORD* bdst = (DWORD*)((BYTE*)this + 0x2c);
            for (INT k = 7; k != 0; k--) *bdst++ = *bsrc++;
            FSphere sphere(points, count);
            *(FSphere*)((BYTE*)this + 0x48) = sphere;
        }
        return;
    }
}
// No polys: store an invalid (empty) bounding box.
FBox empty(0);
DWORD* esrc = (DWORD*)&empty;
DWORD* edst = (DWORD*)((BYTE*)this + 0x2c);
for (INT k = 7; k != 0; k--) *edst++ = *esrc++;
unguard;
}

// Ghidra: Engine.dll 0x103cf020, 880 bytes -- builds BSP render sections from nodes/surfs.
// Full body requires unnamed section-builder helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x103cf020: 880-byte BuildRenderData calls unnamed render section helpers and FUN_10317670; pending decompilation")
void UModel::BuildRenderData()
{
guard(UModel::BuildRenderData);
unguard;
}

// Ghidra: Engine.dll 0x103cef10, 220 bytes.
// If sections non-empty: optionally releases GPU resources via RenDev vtable[0x78/4],
// clears FirstRenderSection (+0x78) and NumRenderSections (+0x7c) on all nodes to -1,
// calls FUN_10324a50 (unnamed) per section, then empties the sections array.
IMPL_DIVERGE("Ghidra 0x103cef10: calls FUN_10324a50 (unnamed section destructor) per section before emptying; pending extraction")
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
// FUN_10324a50: per-section cleanup -- unnamed, pending extraction.
sections->Empty(0x2c, 0);
unguard;
}

// Ghidra: Engine.dll 0x103d2f10, 801 bytes -- compresses lightmap data in-place.
// Full body requires unnamed lightmap-compression helpers.
IMPL_DIVERGE("Ghidra 0x103d2f10: 801-byte CompressLightmaps calls unnamed lightmap FUN helpers; pending decompilation")
void UModel::CompressLightmaps()
{
guard(UModel::CompressLightmaps);
unguard;
}

// Ghidra: Engine.dll 0x10470aa0, 419 bytes.
// Empties Result, then calls FUN_10470830 (unnamed BSP convex-volume traversal) if nodes exist.
IMPL_DIVERGE("Ghidra 0x10470aa0: calls FUN_10470830 (BSP convex-volume traversal); pending extraction")
INT UModel::ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius )
{
guard(UModel::ConvexVolumeMultiCheck);
*(FArray*)&Result = FArray();
if (MODEL_NODES(this)->Num() == 0)
    return 0;
// FUN_10470830: unnamed BSP convex-volume multi-check traversal -- pending extraction.
return Result.Num() > 0 ? 1 : 0;
unguard;
}

// Ghidra: Engine.dll 0x103cfd80, 1176 bytes.
// Frees projectors on all nodes, records undo via GUndo, destructs node arrays,
// empties Nodes (always), Surfs (if EmptySurfs), Polys (if EmptyPolys), zone arrays.
// Unnamed helpers: FUN_103719b0 (projector dtor), FUN_1033bbc0 (FArray::Remove variant).
// Full EmptyPolys branch and undo tracking pending extraction.
IMPL_DIVERGE("Ghidra 0x103cfd80: 1176-byte EmptyModel with undo tracking and unnamed ref-count/array helpers; pending decompilation")
void UModel::EmptyModel( INT EmptySurfs, INT EmptyPolys )
{
guard(UModel::EmptyModel);
MODEL_NODES(this)->Empty(NODE_STRIDE, 0);
if (EmptySurfs)
    MODEL_SURFS(this)->Empty(SURF_STRIDE, 0);
unguard;
}

// Ghidra: Engine.dll 0x1046d250, 173 bytes.
// Caches Nodes.Data into DAT_1079bfe4 (GBspNodes), then if nodes exist calls
// FUN_1046cd40 (fast BSP line traversal); otherwise returns (BYTE)RootOutside.
IMPL_DIVERGE("Ghidra 0x1046d250: stores Nodes.Data to DAT_1079bfe4 then calls FUN_1046cd40 (fast BSP traversal); pending extraction")
BYTE UModel::FastLineCheck( FVector Start, FVector End )
{
guard(UModel::FastLineCheck);
FArray* nodes = MODEL_NODES(this);
GBspNodes = *(INT*)nodes;
if (nodes->Num() == 0)
    return (BYTE)MODEL_ROOTOUTSIDE(this);
return bspFastLineCheck(0,
                        Start.X, Start.Y, Start.Z,
                        End.X,   End.Y,   End.Z,
                        (BYTE)MODEL_ROOTOUTSIDE(this));
unguard;
}

// Ghidra: Engine.dll 0x10470770, 129 bytes.
// Returns -1 if no nodes; otherwise calls FUN_104704f0 (BSP nearest-vertex finder).
IMPL_DIVERGE("Ghidra 0x10470770: calls FUN_104704f0 (BSP nearest-vertex finder); pending extraction")
FLOAT UModel::FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const
{
guard(UModel::FindNearestVertex);
if (MODEL_NODES(this)->Num() == 0)
    return -1.f;
return bspFindNearestVertexHelper(const_cast<UModel*>(this),
                                   &SourcePoint, &DestPoint,
                                   MinRadius, 0, &iVertex);
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

// Ghidra: Engine.dll 0x103ce6b0, 95 bytes -- calls ModifySurf for every surface.
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
// Records undo for Surfs[iSurf] via GUndo->SaveArray (vtable+4).
// If SetBits is set and the surf has an actor back-ref (surf+0x1c), also records
// the undo entry for that actor's brush poly (surf+0x18 gives poly index).
IMPL_DIVERGE("Ghidra 0x103ce5c0: SaveArray via GUndo uses internal callbacks LAB_10317600/LAB_10326190; pending decompilation")
void UModel::ModifySurf( INT iSurf, INT SetBits )
{
guard(UModel::ModifySurf);
if (GUndo)
    GUndo->SaveArray(*(UObject**)((BYTE*)this + 0xa8),
                     (FArray*)((BYTE*)this + 0x9c),
                     iSurf, 1, 0, SURF_STRIDE, NULL, NULL);
if (SetBits)
{
    INT surfBase = *(INT*)((BYTE*)this + 0x9c) + iSurf * SURF_STRIDE;
    INT actor    = *(INT*)(surfBase + 0x1c);
    if (actor != 0)
    {
        INT polysPtr = *(INT*)(*(INT*)(actor + 0x178) + 0x58);
        if (GUndo)
            GUndo->SaveArray(*(UObject**)(polysPtr + 0x38),
                             (FArray*)(polysPtr + 0x2c),
                             *(INT*)(surfBase + 0x18), 1, 0, FPOLY_STRIDE, NULL, NULL);
    }
}
unguard;
}

// Ghidra: Engine.dll 0x1046dc70, 353 bytes.
// Traverses the BSP tree to find which zone contains Location.
// Full body requires raw FBspNode child-index navigation (pending UnBsp extraction).
IMPL_DIVERGE("Ghidra 0x1046dc70: PointRegion traverses BSP zone tree via raw FBspNode child navigation; pending decompilation")
FPointRegion UModel::PointRegion( AZoneInfo* Zone, FVector Location ) const
{
guard(UModel::PointRegion);
check(Zone != NULL);
FPointRegion result;
result.Zone       = Zone;
result.iLeaf      = INDEX_NONE;
result.ZoneNumber = 0;
return result;
unguard;
}

// Ghidra: Engine.dll 0x1046de90, 89 bytes.
// Calls FUN_1046de10 (BSP sphere filter precomputation) if nodes exist.
IMPL_DIVERGE("Ghidra 0x1046de90: calls FUN_1046de10 (BSP sphere filter precomputation); pending extraction")
void UModel::PrecomputeSphereFilter( const FPlane& Sphere )
{
guard(UModel::PrecomputeSphereFilter);
if (MODEL_NODES(this)->Num() != 0)
    bspPrecomputeSphereFilterHelper(this, 0, &Sphere);
unguard;
}

// Ghidra: Engine.dll 0x1046db50, 288 bytes.
// Loads FPlane from Nodes[iNode] (stride NODE_STRIDE, first 16 bytes).
// Computes PlaneDot for Start and End.  If they straddle the plane (within +-0.001),
// computes intersection t and stores Result.Location = Start + (End-Start)*t, returns 1.
// Otherwise logs via GLog and returns 0.
IMPL_DIVERGE("Ghidra 0x1046db50: uses unaff_retaddr pattern; complex PlaneDot straddling logic; pending decompilation")
INT UModel::R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End )
{
guard(UModel::R6LineCheck);
// unaff_retaddr pattern prevents clean reconstruction; pending decompilation.
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
IMPL_DIVERGE("Ghidra 0x103cd620: undo recording uses internal callback LAB_103171d0; pending decompilation")
void UModel::Transform( ABrush* Brush )
{
guard(UModel::Transform);
check(Brush != NULL);
BYTE*   polys   = MODEL_POLYS(this);
FArray* polyArr = (FArray*)(polys + 0x2c);
// GUndo undo recording omitted -- GUndo is NULL during normal gameplay.
FModelCoords coords;
FLOAT orient = Brush->BuildCoords(&coords, NULL);
INT numPolys = polyArr->Num();
for (INT i = 0; i < numPolys; i++)
{
    FPoly* poly = (FPoly*)((BYTE*)polyArr->GetData() + i * FPOLY_STRIDE);
    poly->Transform(coords, *(FVector*)((BYTE*)Brush + 0x2c8),
                            *(FVector*)((BYTE*)Brush + 0x234), orient);
}
unguard;
}

// Ghidra: Engine.dll 0x103cd750, 2842 bytes -- full BSP render pass.
// Full body requires many unnamed rendering helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x103cd750: 2842-byte Render dispatches to unnamed BSP render helpers; pending decompilation")
void UModel::Render( FDynamicActor*, FLevelSceneNode*, FRenderInterface* )
{
guard(UModel::Render);
unguard;
}

// Ghidra: Engine.dll 0x103cea90, 1081 bytes -- attaches projector to BSP nodes/surfs.
// Full body requires many unnamed projector-attachment helpers.
IMPL_DIVERGE("Ghidra 0x103cea90: 1081-byte AttachProjector uses unnamed projector-mesh-intersection helpers; pending decompilation")
void UModel::AttachProjector( int iNode, FProjectorRenderInfo* ProjInfo, FPlane* Planes )
{
guard(UModel::AttachProjector);
unguard;
}

// =============================================================================